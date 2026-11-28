# Panduan Senza Addon's untuk ROM Lain (HiOS 16.2 / 16.3 dan sejenisnya)

Panduan ini untuk memasang Senza Addon's di `TranSettings.apk` dari ROM yang **berbeda** dari XOS 16.3 milik kita, misalnya HiOS 16.2 atau 16.3.

> Status: skrip dan pengecekan di panduan ini sudah dites pada struktur contoh di sandbox, tetapi **belum dicoba di HiOS 16.2/16.3 asli**. Hasil `check-rom.sh` (bagian 3) akan menunjukkan apakah ROM-nya cocok sebelum kamu memasang apa pun.

---

## 1. Apa yang bisa berbeda antar ROM

| Bagian | Bisa berbeda? | Keterangan |
|---|---|---|
| Kelas halaman Sistem berada di dex yang mana | Ya | Di XOS 16.3 ada di `classes2.dex`. Di ROM lain bisa `classes3.dex`, dst. |
| Isi dan urutan method di kelas itu | Ya | Nomor baris, nama register, dan label bisa lain |
| Nama kelas | Kadang | Bisa di-obfuscate (diacak) |
| Nama file di `res/` (misal `RN6.webp`) dan id resource | Ya | Diacak per build |
| Kelas androidx (Preference, RecyclerView, dst.) | Biasanya sama | Perlu dicek |
| Node sysfs CPU/GPU/thermal | Bisa | Tergantung chipset dan kernel |

## 2. Yang sudah ditangani skrip (tidak perlu kamu pikirkan lagi)

- **Nomor dex tidak penting.** `patch-apk.sh` mencari kelas halaman Sistem di semua dex.
- **File `SystemDashboardFragment.smali` dari XOS 16.3 tidak diganti ke ROM lain.** Skrip memakai `patch-smali.sh` yang hanya **menyisipkan satu baris** di tempat yang tepat, jadi isi kelas aslinya aman.
- **Nama dex baru dipilih otomatis**, yaitu nomor terbesar + 1 (misalnya `classes6.dex`). Kalau APK sudah berisi Senza Addon's lama, yang lama diganti.
- **Id kartu XOS dicari lewat nama** (`os_version_bg`), bukan angka tetap.

> Jangan pernah menempel `patched/SystemDashboardFragment.smali` ke ROM lain. File itu hanya cocok dengan XOS 16.3 dan bisa membuat Pengaturan crash di ROM lain.

---

## 3. Langkah (lakukan untuk tiap ROM)

### Langkah 1: siapkan bahan
1. Ambil `TranSettings.apk` **asli dari ROM tujuan** (HiOS 16.2 dan 16.3 pakai file masing-masing). Jangan pakai APK hasil patch dari ROM lain.
2. Pakai kit terbaru (berisi `patch-apk.sh`, `patch-smali.sh`, `check-rom.sh`) dan `classes5.dex` dari GitHub Actions.
3. Taruh semuanya di `~/Setting`:
   ```
   cd ~/Setting
   cp /sdcard/Download/TranSettings.apk .
   cp /sdcard/Download/classes5.dex .
   ```

### Langkah 2: cek dulu apakah ROM cocok
```
cd ~/Setting
apktool d -r -f TranSettings.apk -o ts_out
bash check-rom.sh
```

Cara membaca hasilnya:

| Baris | Artinya |
|---|---|
| `Dex terbesar: classesN.dex` | Dex Senza Addon's nanti jadi `classes(N+1).dex` |
| `[OK] .../SystemDashboardFragment.smali` | Kelas halaman Sistem ketemu |
| `[OK] ketemu lewat log tag (nama di-obfuscate)` | Nama kelasnya diacak tapi tetap ketemu lewat teks `SystemDashboardFrag` |
| `onResume : ada` atau `tidak ada` | Keduanya aman; skrip menyisipkan atau menambahkan sendiri |
| `[OK]` pada kelas androidx | Kelas dan method yang dipakai Senza Addon's tersedia |
| `[X]` pada kelas androidx | Lihat bagian 5 |
| `[!] ya: ...smali_classesN/com/senza/addons` | APK ini sudah pernah dipasangi Senza Addon's; skrip akan menggantinya |

Kalau kelas halaman Sistem `[X] tidak ketemu`, lanjut ke bagian 4.

### Langkah 3: patch otomatis
```
bash patch-apk.sh TranSettings.apk classes5.dex
```

Baris yang harus muncul:
```
Target: ts_out/smali_classesN/.../SystemDashboardFragment.smali
onResume: disisipi panggilan setelah invoke-super     (atau: method baru ditambahkan)
onActivityResult: method baru ditambahkan             (atau: disisipi ...)
Dex Senza Addon's akan jadi: classesM.dex
Selesai: TranSettings_senza.apk
```

Kalau `apktool b` gagal dengan pesan error smali, kirim pesannya ke aku.

### Langkah 4: align, tanda tangan, pasang
Sama seperti panduan utama:
1. Salin `TranSettings_senza.apk` ke Download.
2. MT Manager: **Tanda tangan APK** dengan **Zip Align** aktif, kunci yang sama dengan ROM tujuan.
3. Cek `resources.arsc` harus `Stored`:
   ```
   unzip -v TranSettings_signed.apk resources.arsc
   ```
4. Ganti APK di ROM, hapus folder `oat` di sampingnya, reboot.

---

## 4. Kalau kelas halaman Sistem tidak ketemu

Artinya nama kelas diacak **dan** teks `SystemDashboardFrag` tidak ada. Cara mencari manual:

1. Di terminal (setelah `apktool d`):
   ```
   grep -rl "DashboardFragment" ts_out | head -20
   grep -rl "SystemDashboard" ts_out | head
   ```
2. Atau di MT Manager: buka dex (Dex Editor++), pakai **cari** dengan jenis **string**, lalu coba `SystemDashboardFrag`, `SystemDashboard`, atau `system_dashboard`.
3. Kelas yang benar adalah halaman **Pengaturan > Sistem**: turunan `DashboardFragment`, punya method `getLogTag` yang mengembalikan teks nama kelasnya.
4. Setelah ketemu, patch langsung file itu:
   ```
   sh patch-smali.sh ts_out/smali_classesN/.../NamaKelas.smali
   ```
   lalu bangun dan tambahkan dex seperti di `patch-apk.sh`, atau kirim hasil `grep` ke aku untuk dibantu.

---

## 5. Kalau `check-rom.sh` menampilkan `[X]` pada androidx

Senza Addon's memakai kelas androidx bawaan Pengaturan. Kalau salah satu tidak ada di ROM itu, **menu tidak akan muncul atau fitur tertentu tidak jalan**. Pengaturan tidak akan crash (semua pemanggilan dibungkus penangkap error).

Jangan lanjut memasang. Kirim seluruh hasil `check-rom.sh` ke aku supaya kodenya disesuaikan dengan ROM itu.

---

## 6. Patch manual di MT Manager untuk ROM lain

Pakai hanya kalau tidak memakai skrip. **Jangan mengganti seluruh isi kelas.** Cukup sisipkan, seperti ini:

### 6.1 `onResume()`
1. Buka kelas halaman Sistem di Dex Editor++.
2. Cari `.method ... onResume()V`.
3. Di dalamnya cari baris `invoke-super {p0}, ...->onResume()V`.
4. Tambahkan **satu baris tepat di bawahnya**:
   ```
       invoke-static {p0}, Lcom/senza/addons/SenzaAddons;->onResume(Ljava/lang/Object;)V
   ```
5. Jangan ubah `.registers` maupun baris lain.

Kalau kelas **tidak punya** method `onResume`, tambahkan di akhir kelas (ganti `<SUPER>` dengan isi baris `.super` di bagian atas kelas, tanpa kata `.super`):
```smali
.method public onResume()V
    .registers 1

    invoke-super {p0}, <SUPER>->onResume()V

    invoke-static {p0}, Lcom/senza/addons/SenzaAddons;->onResume(Ljava/lang/Object;)V

    return-void
.end method
```

### 6.2 `onActivityResult`
Kalau kelas sudah punya `onActivityResult(IILandroid/content/Intent;)V`: tambahkan di bawah `invoke-super`-nya
```
    invoke-static {p0, p1, p2, p3}, Lcom/senza/addons/SenzaAddons;->onActivityResult(Ljava/lang/Object;IILandroid/content/Intent;)V
```
Kalau build error "register out of range", pakai bentuk ini:
```
    invoke-static/range {p0 .. p3}, Lcom/senza/addons/SenzaAddons;->onActivityResult(Ljava/lang/Object;IILandroid/content/Intent;)V
```

Kalau belum ada, tambahkan di akhir kelas:
```smali
.method public onActivityResult(IILandroid/content/Intent;)V
    .registers 4

    invoke-super {p0, p1, p2, p3}, <SUPER>->onActivityResult(IILandroid/content/Intent;)V

    invoke-static {p0, p1, p2, p3}, Lcom/senza/addons/SenzaAddons;->onActivityResult(Ljava/lang/Object;IILandroid/content/Intent;)V

    return-void
.end method
```

### 6.3 Tambah dex
Tambahkan `classes5.dex` ke root APK dengan nama **yang belum dipakai**: `classes(N+1).dex`, N = nomor dex terbesar di APK itu. Contoh: APK punya `classes.dex` sampai `classes4.dex`, maka namanya `classes5.dex`. Kalau APK sudah punya `classes5.dex`, pakai `classes6.dex`.

---

## 7. Eksekutor ROM di ROM lain

`senza_addons.rc` dan `senza_apply.sh` umumnya bisa dipakai apa adanya. Yang perlu dicek:

1. **Lokasi `.rc`**: `/system/etc/init/` sudah cukup. Alternatif: `/system_ext/etc/init/` atau `/product/etc/init/`.
2. **SELinux**: `getenforce`. Kalau `Enforcing`, cek `dmesg | grep avc | grep -E "senza|system_app|init"`.
3. **Node CPU/GPU/thermal**: chipset lain punya node berbeda. Cek:
   ```
   ls /sys/devices/system/cpu/cpufreq/
   ls /proc/gpufreq* /sys/kernel/ged/hal/ 2>/dev/null
   ls /sys/class/thermal/ | head
   ```
   Node yang tidak ada diabaikan, tidak membuat error. Fitur GPU hanya untuk MediaTek; di chipset Unisoc atau Qualcomm fitur itu tidak berefek.
4. **Uji eksekutor**:
   ```
   su -c "setprop sys.senza.cfg 't=0,g=bal,m=100,u=0,r=gl,n=1'"
   sleep 3
   getprop sys.senza.status
   ```

---

## 8. Kartu XOS di ROM lain

Nama resource bisa sama, tapi **nama file dan id berbeda**. Cari di Editor ARSC++:

| Cari | Untuk |
|---|---|
| `tran_myphone_check_for_updates` | Teks tombol "Periksa Pembaruan" |
| `tran_myphone_background` | Banner kartu. Buka entrinya, path file yang tertulis adalah file yang diganti (di XOS 16.3: `res/RN6.webp`) |

Fitur banner dari galeri mencari view bernama `os_version_bg` secara otomatis. Kalau di ROM lain namanya beda, banner dari galeri tidak berefek (tanpa crash); ganti banner lewat file seperti di panduan utama.

---

## 9. Daftar periksa tiap ROM

1. [ ] Pakai `TranSettings.apk` asli dari ROM tujuan, cadangan sudah dibuat
2. [ ] `bash check-rom.sh` tidak ada `[X]` pada kelas halaman Sistem dan androidx
3. [ ] `bash patch-apk.sh` selesai dan menampilkan "Selesai: TranSettings_senza.apk"
4. [ ] Zip Align aktif, tanda tangan benar, `resources.arsc` berstatus `Stored`
5. [ ] APK dipasang, folder `oat` dihapus, reboot
6. [ ] Menu Senza Addon's muncul di Pengaturan > Sistem
7. [ ] Eksekutor ROM dipasang dan diuji (bagian 7)

## 10. Masalah umum

| Masalah | Solusi |
|---|---|
| Menu tidak muncul di ROM baru | Jalankan `check-rom.sh`; ada `[X]` androidx atau kelas tidak ketemu. Kirim hasilnya |
| Pengaturan crash | Pastikan tidak memakai `patched/SystemDashboardFragment.smali` dari XOS 16.3. Ambil log dan kirim |
| `apktool b` error smali | Kirim pesan errornya. Kemungkinan method `onActivityResult` lama memakai register tinggi (lihat 6.2) |
| Bootloop | Pulihkan APK cadangan; cek Zip Align dan tanda tangan |
| Dex baru tidak terbaca | Pastikan nama dex belum dipakai dan ada di root APK |

Ambil log:
```
logcat -c
# buka Pengaturan > Sistem
logcat -d | grep -E "SenzaAddons|AndroidRuntime|NoClassDef|FATAL" > /sdcard/Download/log.txt
```
