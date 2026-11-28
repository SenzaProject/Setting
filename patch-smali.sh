#!/bin/sh
# Pakai: sh patch-smali.sh <SystemDashboardFragment.smali>
# Menyisipkan panggilan Senza Addon's ke kelas halaman Sistem TANPA mengganti isi kelas.
# Aman untuk ROM lain: tidak bergantung pada nomor baris, nama register, atau method lain.
set -e
F="$1"
[ -f "$F" ] || { echo "File tidak ada: $F"; exit 1; }
grep -q 'com/senza/addons/SenzaAddons' "$F" && { echo "Sudah dipatch: $F"; exit 0; }

SUPER="$(grep -m1 '^\.super ' "$F" | sed 's/^\.super //')"
[ -n "$SUPER" ] || { echo "Baris .super tidak ketemu"; exit 1; }
cp "$F" "$F.bak"

R1='    invoke-static {p0}, Lcom/senza/addons/SenzaAddons;->onResume(Ljava/lang/Object;)V'
R2='    invoke-static {p0, p1, p2, p3}, Lcom/senza/addons/SenzaAddons;->onActivityResult(Ljava/lang/Object;IILandroid/content/Intent;)V'

# insert_after_super <signature-regex> <baris-yang-disisipkan>
# return 0 jika method ada dan berhasil disisipi
insert_after_super() {
  start="$(grep -n "^\.method .* $1" "$F" | head -1 | cut -d: -f1)"
  [ -n "$start" ] || return 1
  rel="$(sed -n "${start},\$p" "$F" | grep -n 'invoke-super' | head -1 | cut -d: -f1)"
  [ -n "$rel" ] || return 1
  line=$((start + rel - 1))
  sed -i "${line}a\\
$2" "$F"
  return 0
}

# 1) onResume
if insert_after_super 'onResume()V' "$R1"; then
  echo "onResume: disisipi panggilan setelah invoke-super"
else
  {
    echo ""
    echo ".method public onResume()V"
    echo "    .registers 1"
    echo ""
    echo "    invoke-super {p0}, ${SUPER}->onResume()V"
    echo ""
    echo "$R1"
    echo ""
    echo "    return-void"
    echo ".end method"
  } >> "$F"
  echo "onResume: method baru ditambahkan"
fi

# 2) onActivityResult
if insert_after_super 'onActivityResult(IILandroid/content/Intent;)V' "$R2"; then
  echo "onActivityResult: disisipi panggilan setelah invoke-super"
else
  {
    echo ""
    echo ".method public onActivityResult(IILandroid/content/Intent;)V"
    echo "    .registers 4"
    echo ""
    echo "    invoke-super {p0, p1, p2, p3}, ${SUPER}->onActivityResult(IILandroid/content/Intent;)V"
    echo ""
    echo "$R2"
    echo ""
    echo "    return-void"
    echo ".end method"
  } >> "$F"
  echo "onActivityResult: method baru ditambahkan"
fi
echo "OK: $F (cadangan: $F.bak)"
