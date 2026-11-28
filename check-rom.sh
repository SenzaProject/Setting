#!/bin/sh
# Pakai: bash check-rom.sh [ts_out]
# Cek apakah ROM/APK ini cocok untuk Senza Addon's. Jalankan setelah: apktool d -r TranSettings.apk -o ts_out
D="${1:-ts_out}"
[ -d "$D" ] || { echo "Folder $D tidak ada. Jalankan dulu: apktool d -r TranSettings.apk -o ts_out"; exit 1; }

max=1
for d in "$D"/smali*; do
  b="$(basename "$d")"; k="${b#smali_classes}"; [ "$b" = "smali" ] && k=1
  [ "$k" -gt "$max" ] && max="$k"
done
echo "== Dex terbesar: classes${max}.dex  (dex Senza Addon's akan jadi classes$((max + 1)).dex, kecuali sudah ada dex Senza lama)"

echo "== Kelas halaman Sistem"
F="$(find "$D" -path '*com/android/settings/system/SystemDashboardFragment.smali' | head -1)"
if [ -n "$F" ]; then echo "[OK] $F"
else
  F="$(grep -rl --include='*.smali' '"SystemDashboardFrag"' "$D" | head -1)"
  if [ -n "$F" ]; then echo "[OK] ketemu lewat log tag (nama di-obfuscate): $F"
  else echo "[X] tidak ketemu. Cari manual (lihat panduan ROM lain)"; fi
fi
if [ -n "$F" ]; then
  echo "    super : $(grep -m1 '^\.super ' "$F")"
  grep -q 'onResume()V' "$F" && echo "    onResume : ada (akan disisipi)" || echo "    onResume : tidak ada (akan ditambahkan)"
  grep -q 'onActivityResult(IILandroid/content/Intent;)V' "$F" && echo "    onActivityResult : ada (akan disisipi)" || echo "    onActivityResult : tidak ada (akan ditambahkan)"
fi

echo "== Kelas androidx yang dipakai Senza Addon's"
chk() {
  file="$(find "$D"/smali* -path "*/$1.smali" 2>/dev/null | head -1)"
  if [ -z "$file" ]; then echo "[X] $3: kelas tidak ada"; return; fi
  if [ -n "$2" ]; then
    grep -q -- "$2" "$file" && echo "[OK] $3" || echo "[X] $3: method tidak ada"
  else echo "[OK] $3"; fi
}
chk androidx/preference/Preference ' setOnPreferenceClickListener(' "Preference.setOnPreferenceClickListener"
chk androidx/preference/Preference ' setKey(Ljava/lang/String;)V' "Preference.setKey"
chk androidx/preference/PreferenceCategory '' "PreferenceCategory"
chk androidx/preference/PreferenceGroup ' addPreference(Landroidx/preference/Preference;)Z' "PreferenceGroup.addPreference"
chk androidx/preference/PreferenceGroup ' findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;' "PreferenceGroup.findPreference"
chk 'androidx/preference/PreferenceGroup$PreferencePositionCallback' '' "PreferencePositionCallback"
chk androidx/preference/PreferenceFragmentCompat ' getListView()' "PreferenceFragmentCompat.getListView"
chk androidx/preference/PreferenceFragmentCompat ' getPreferenceScreen()' "PreferenceFragmentCompat.getPreferenceScreen"
chk androidx/fragment/app/Fragment ' startActivityForResult(Landroid/content/Intent;I)V' "Fragment.startActivityForResult"
chk androidx/recyclerview/widget/RecyclerView ' getChildAdapterPosition(Landroid/view/View;)I' "RecyclerView.getChildAdapterPosition"

echo "== Senza Addon's sudah ada di APK ini?"
O="$(find "$D" -maxdepth 4 -type d -path "$D/smali*/com/senza/addons" | head -1)"
[ -n "$O" ] && echo "[!] ya: $O (patch-apk.sh akan menggantinya dengan dex baru)" || echo "[OK] belum"
echo "== Selesai. Semua [OK] berarti aman dilanjutkan. [X] pada androidx = menu bisa tidak muncul (aplikasi tidak crash)."
