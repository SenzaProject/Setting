#!/data/data/com.termux/files/usr/bin/bash
# Pakai: bash patch-apk.sh TranSettings.apk classes5.dex
# Butuh: apktool, zip, zipalign. Hasil harus ditandatangani dengan signer kamu.
set -e
APK="${1:-TranSettings.apk}"
DEX="${2:-classes5.dex}"
cd "$(dirname "$0")"
[ -f "$APK" ] || { echo "APK tidak ada: $APK"; exit 1; }
[ -f "$DEX" ] || { echo "dex tidak ada: $DEX"; exit 1; }
for t in apktool zip zipalign; do command -v $t >/dev/null || { echo "Install dulu: $t"; exit 1; }; done

rm -rf ts_out tmp_dex
apktool d -r -f "$APK" -o ts_out

FRAG="$(find ts_out -path '*com/android/settings/system/SystemDashboardFragment.smali' | head -1)"
[ -n "$FRAG" ] || { echo "SystemDashboardFragment.smali tidak ketemu"; exit 1; }
cp "$FRAG" "$FRAG.bak"
cp patched/SystemDashboardFragment.smali "$FRAG"
echo "Patch smali: $FRAG"

apktool b -f ts_out -o TranSettings_unsigned.apk

mkdir tmp_dex && cp "$DEX" tmp_dex/classes5.dex
( cd tmp_dex && zip -q ../TranSettings_unsigned.apk classes5.dex )

zipalign -f -p 4 TranSettings_unsigned.apk TranSettings_senza.apk
echo "Selesai: TranSettings_senza.apk (belum ditandatangani)"
