#!/data/data/com.termux/files/usr/bin/bash
# Pakai: bash patch-apk.sh TranSettings.apk classes5.dex
# Butuh: apktool, zip. Hasil: TranSettings_senza.apk (belum ditandatangani).
# Aman untuk ROM lain (HiOS 16.x dll): kelas target dicari otomatis, patch disisipkan di tempat
# (tidak mengganti isi kelas), dan nama dex baru dipilih yang masih kosong.
set -e
APK="${1:-TranSettings.apk}"
DEX="${2:-classes5.dex}"
cd "$(dirname "$0")"
[ -f "$APK" ] || { echo "APK tidak ada: $APK"; exit 1; }
[ -f "$DEX" ] || { echo "dex tidak ada: $DEX"; exit 1; }
for t in apktool zip; do command -v $t >/dev/null || { echo "Install dulu: $t"; exit 1; }; done

rm -rf ts_out tmp_dex
apktool d -r -f "$APK" -o ts_out

# 1) cari kelas halaman Sistem (nama biasa, lalu lewat string log tag jika nama di-obfuscate)
FRAG="$(find ts_out -path '*com/android/settings/system/SystemDashboardFragment.smali' | head -1)"
if [ -z "$FRAG" ]; then
  FRAG="$(grep -rl --include='*.smali' '"SystemDashboardFrag"' ts_out | head -1)"
fi
[ -n "$FRAG" ] || { echo "Kelas halaman Sistem tidak ketemu. Jalankan: bash check-rom.sh"; exit 1; }
echo "Target: $FRAG"

# 2) sisipkan panggilan (tanpa mengganti isi kelas)
sh patch-smali.sh "$FRAG"
mv -f "$FRAG.bak" ./SystemDashboardFragment.smali.bak

# 3) tentukan nama dex untuk kode Senza Addon's
NAME=""
OLD="$(find ts_out -maxdepth 4 -type d -path 'ts_out/smali*/com/senza/addons' | head -1)"
if [ -n "$OLD" ]; then
  # APK sudah pernah berisi Senza Addon's: buang yang lama, ganti dengan yang baru
  ROOT="${OLD%/com/senza/addons}"
  rm -rf "$OLD"
  rmdir "$ROOT/com/senza" "$ROOT/com" 2>/dev/null || true
  if [ -z "$(find "$ROOT" -type f | head -1)" ]; then
    rm -rf "$ROOT"
    b="$(basename "$ROOT")"; k="${b#smali_classes}"; [ "$b" = "smali" ] && k=1
    NAME="classes${k}.dex"
  fi
fi
if [ -z "$NAME" ]; then
  max=1
  for d in ts_out/smali*; do
    b="$(basename "$d")"; k="${b#smali_classes}"; [ "$b" = "smali" ] && k=1
    [ "$k" -gt "$max" ] && max="$k"
  done
  NAME="classes$((max + 1)).dex"
fi
echo "Dex Senza Addon's akan jadi: $NAME"

# 4) bangun ulang + tambahkan dex
apktool b -f ts_out -o TranSettings_unsigned.apk
mkdir tmp_dex && cp "$DEX" "tmp_dex/$NAME"
( cd tmp_dex && zip -q ../TranSettings_unsigned.apk "$NAME" )
cp TranSettings_unsigned.apk TranSettings_senza.apk
echo "Selesai: TranSettings_senza.apk (belum diluruskan/ditandatangani)"
