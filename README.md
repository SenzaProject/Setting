# Senza Addon's untuk TranSettings (tanpa root di aplikasi)

1. Push folder ini ke GitHub, jalankan Actions "Build Senza Addons dex", unduh artifact `classes5-dex`.
2. `bash patch-apk.sh TranSettings.apk classes5.dex` (atau ikuti guid.md untuk MT Manager).
3. Zipalign + tanda tangani, ganti di ROM, hapus `oat/`, reboot.
4. Untuk thermal/CPU/GPU/mode performa: pasang `rom/senza_addons.rc` -> /system/etc/init/ dan `rom/senza_apply.sh` -> /system/bin/ (0755). Lihat guid.md bagian 6b.
