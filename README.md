# Senza Addon's untuk TranSettings (tanpa root di aplikasi)

1. Push folder ini ke GitHub, jalankan Actions "Build Senza Addons dex", unduh artifact `classes5-dex`.
2. `apktool d -r -f TranSettings.apk -o ts_out && bash check-rom.sh` (cek ROM cocok)
3. `bash patch-apk.sh TranSettings.apk classes5.dex` (otomatis, aman untuk ROM lain)
4. Zip Align + tanda tangan, ganti di ROM, hapus `oat/`, reboot.
5. Thermal/CPU/GPU/mode performa: pasang `rom/senza_addons.rc` -> /system/etc/init/ dan `rom/senza_apply.sh` -> /system/bin/ (0755).

Panduan: Panduan_Senza_Addons.md (XOS 16.3), Panduan_ROM_Lain.md (HiOS 16.2/16.3 dll).
