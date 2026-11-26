#!/system/bin/sh
# Senza Addon's - eksekutor. Pasang di /system/bin/senza_apply.sh (0755, u:object_r:system_file:s0)
# Input (argumen 1): t=0|1,g=auto|bal|perf,m=100|85|70|55|40,u=0|1|2,r=gl|vk,n=<angka>
# Nilai di-whitelist; isi property tidak pernah dieksekusi (bukan eval).

CFG="$1"
[ -z "$CFG" ] && exit 0

T=0; G=auto; M=100; U=0; R=gl
OLDIFS="$IFS"; IFS=','
for kv in $CFG; do
  case "$kv" in
    t=0|t=1) T="${kv#t=}" ;;
    g=auto|g=bal|g=perf) G="${kv#g=}" ;;
    m=100|m=85|m=70|m=55|m=40) M="${kv#m=}" ;;
    u=0|u=1|u=2) U="${kv#u=}" ;;
    r=gl|r=vk) R="${kv#r=}" ;;
  esac
done
IFS="$OLDIFS"

# ---------- Thermal
SVC="thermal thermald thermal_manager thermal-engine vendor.thermal-hal-2-0 vendor.thermal-hal-2-0-mtk vendor.thermal-hal-2-0.mtk vendor.thermal_manager"
if [ "$T" = "1" ]; then
  for z in /sys/class/thermal/thermal_zone*; do [ -e "$z/mode" ] && echo disabled > "$z/mode" 2>/dev/null; done
  for s in $SVC; do stop "$s" 2>/dev/null; done
else
  for z in /sys/class/thermal/thermal_zone*; do [ -e "$z/mode" ] && echo enabled > "$z/mode" 2>/dev/null; done
  for s in $SVC; do start "$s" 2>/dev/null; done
fi

# ---------- CPU
pick() { for w in "$@"; do case "$AVAIL" in *" $w "*) echo "$w"; return;; esac; done; }
for p in /sys/devices/system/cpu/cpufreq/policy*; do
  [ -d "$p" ] || continue
  AVAIL=" $(cat "$p/scaling_available_governors" 2>/dev/null) "
  GOV=""
  case "$G" in
    perf) GOV="$(pick performance schedutil sugov_ext)" ;;
    bal)  GOV="$(pick schedutil sugov_ext)" ;;
  esac
  [ -n "$GOV" ] && echo "$GOV" > "$p/scaling_governor" 2>/dev/null
  HW="$(cat "$p/cpuinfo_max_freq" 2>/dev/null)"
  [ -n "$HW" ] && echo $((HW * M / 100)) > "$p/scaling_max_freq" 2>/dev/null
done

# ---------- GPU (MediaTek: gpufreq / ged)
GED=/sys/kernel/ged/hal
w() { [ -e "$1" ] && echo "$2" > "$1" 2>/dev/null; }
unfix() { w /proc/gpufreqv2/fix_target_opp_index -1; w /proc/gpufreq/gpufreq_opp_freq 0; }
case "$U" in
  1)
    w $GED/custom_upbound_gpu_freq 0
    w /proc/gpufreqv2/fix_target_opp_index 0
    if [ -e /proc/gpufreq/gpufreq_opp_freq ]; then
      F="$(grep -o 'freq = [0-9]*' /proc/gpufreq/gpufreq_opp_dump 2>/dev/null | head -1 | grep -o '[0-9]*')"
      [ -n "$F" ] && echo "$F" > /proc/gpufreq/gpufreq_opp_freq 2>/dev/null
    fi ;;
  2) unfix; w $GED/custom_upbound_gpu_freq 8 ;;
  *) unfix; w $GED/custom_upbound_gpu_freq 0 ;;
esac

# ---------- Renderer UI (Vulkan / OpenGL)
if [ "$R" = "vk" ]; then setprop debug.hwui.renderer skiavk; else setprop debug.hwui.renderer skiagl; fi

# ---------- Status (dibaca aplikasi untuk konfirmasi)
setprop sys.senza.status "ok $(date +%s) t=$T g=$G m=$M u=$U r=$R"
exit 0
