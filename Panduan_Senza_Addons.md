# Panduan Pemasangan Senza Addon's (TranSettings)

Panduan ini menambahkan menu **Senza Addon's** di **Pengaturan > Sistem** pada `TranSettings.apk`. Aplikasi tidak memakai root.

---

## 1. Gambaran singkat

Menu bisa muncul karena **dua file dex** diubah. Tiap file punya tugas sendiri:

| File | Tugasnya | Siapa yang membuat |
|---|---|---|
| `classes2.dex` | Berisi halaman Sistem. Kita **tambah 1 baris** agar halaman itu memanggil Senza Addon's | Kamu (atau skrip otomatis) |
| `classes5.dex` | Berisi isi menu Senza Addon's (dialog dan fitur) | GitHub Actions |

Keduanya wajib ada. Tanpa `classes2.dex` yang diubah, menu tidak muncul. Tanpa `classes5.dex`, Pengaturan bisa crash.

Fitur yang butuh **eksekutor ROM** (lihat bagian 8): thermal, CPU, GPU, mode performa, Vulkan.
Fitur yang langsung jalan tanpa itu: tap rotation, ANGLE/OpenGL, banner dari galeri.

---

## 2. Bahan yang dibutuhkan

1. `TranSettings.apk` **asli** (belum pernah diubah). Buat cadangan dulu:
   ```
   cp TranSettings.apk TranSettings_cadangan.apk
   ```
2. `classes5.dex`: unduh dari GitHub, tab **Actions**, run terbaru, artifact **`classes5-dex`** (file zip, ekstrak, isinya `classes5.dex`).
3. Folder kit di `~/Setting` (berisi `patch-apk.sh`, `patched/`, `rom/`).
4. MT Manager dan Termux.

---

## 3. Cara A: otomatis lewat Termux (disarankan)

Cara ini mengerjakan perubahan `classes2.dex` dan `classes5.dex` sekaligus.

1. Salin file ke folder kerja:
   ```
   cd ~/Setting
   cp /sdcard/Download/TranSettings.apk .
   cp /sdcard/Download/classes5.dex .
   ```
2. Jalankan skrip:
   ```
   bash patch-apk.sh TranSettings.apk classes5.dex
   ```
3. Tunggu beberapa menit sampai muncul tulisan **"Selesai: TranSettings_senza.apk"**.
4. Salin hasilnya ke Download:
   ```
   cp TranSettings_senza.apk /sdcard/Download/
   ```
5. Lanjut ke **bagian 6** (align dan tanda tangan). Bagian 4 dan 5 **tidak perlu** dikerjakan.

Catatan: selalu pakai `TranSettings.apk` yang **asli** sebagai masukan, bukan `TranSettings_senza.apk`.

---

## 4. Cara B: manual lewat MT Manager (ubah `classes2.dex`)

Pakai cara ini hanya kalau tidak memakai skrip.

### 4.1 Membuka kelas yang benar

1. Di MT Manager, ketuk `TranSettings.apk`, pilih **Lihat**.
2. Ketuk **`classes2.dex`**, pilih **Dex Editor++**. Kalau muncul daftar dex, centang **hanya `classes2.dex`**.
3. Buka folder berurutan: **`com`** > **`android`** > **`settings`** > **`system`**.
4. Ketuk file **`SystemDashboardFragment`**. Kode smali terbuka.

Tulisan `com/android/settings/system/SystemDashboardFragment` adalah alamat kelas ini. Atau pakai ikon **cari**, ketik `SystemDashboardFragment`, lalu pilih hasil yang berakhiran `/settings/system/`.

### 4.2 Cara mudah: ganti seluruh isi

1. Salin file patch ke Download supaya terbaca MT Manager:
   ```
   cp ~/Setting/patched/SystemDashboardFragment.smali /sdcard/Download/
   ```
2. Di MT Manager buka `/sdcard/Download/SystemDashboardFragment.smali`, pilih semua isinya, salin.
3. Kembali ke kelas `SystemDashboardFragment` di Dex Editor++, pilih semua isinya, hapus, lalu tempel.
4. Simpan, lalu **Simpan & keluar**.

Selesai. Kalau memakai cara ini, lewati 4.3 dan 4.4.

### 4.3 Cara edit manual, perubahan 1: method `onResume`

Letaknya **setelah** method `onDynamicTileInsertionFinished` dan **sebelum** method `onViewCreated`. Nomor baris di bawah dihitung dari file asli.

Ubah empat baris ini:

| Baris | Tulisan asli | Ganti menjadi |
|---|---|---|
| 635 | `.registers 2` | `.registers 3` |
| 643 | `move-result-object p0` | `move-result-object v1` |
| 645 | `if-eqz p0, :cond_10` | `if-eqz v1, :cond_10` |
| 649 | `invoke-virtual {p0, v0}, Landroid/view/View;->setVerticalScrollBarEnabled(Z)V` | `invoke-virtual {v1, v0}, Landroid/view/View;->setVerticalScrollBarEnabled(Z)V` |

Lalu **tambah satu baris baru** di antara `:cond_10` (baris 651) dan `return-void` (baris 652):

```
    invoke-static {p0}, Lcom/senza/addons/SenzaAddons;->onResume(Ljava/lang/Object;)V
```

Hasil akhir method:

```smali
.method public final onResume()V
    .registers 3

    invoke-super {p0}, Lcom/android/settings/dashboard/DashboardFragment;->onResume()V

    invoke-virtual {p0}, Landroidx/preference/PreferenceFragmentCompat;->getPreferenceScreen()Landroidx/preference/PreferenceScreen;

    invoke-virtual {p0}, Landroidx/preference/PreferenceFragmentCompat;->getListView()Landroidx/recyclerview/widget/RecyclerView;

    move-result-object v1

    if-eqz v1, :cond_10

    const/4 v0, 0x0

    invoke-virtual {v1, v0}, Landroid/view/View;->setVerticalScrollBarEnabled(Z)V

    :cond_10
    invoke-static {p0}, Lcom/senza/addons/SenzaAddons;->onResume(Ljava/lang/Object;)V

    return-void
.end method
```

### 4.4 Cara edit manual, perubahan 2: tambah method baru

Letaknya di **paling akhir file**, **setelah** `.end method` terakhir (method `onViewCreated`, baris 674). Beri satu baris kosong, lalu tempel:

```smali
.method public onActivityResult(IILandroid/content/Intent;)V
    .registers 4

    invoke-super {p0, p1, p2, p3}, Lcom/android/settings/dashboard/DashboardFragment;->onActivityResult(IILandroid/content/Intent;)V

    invoke-static {p0, p1, p2, p3}, Lcom/senza/addons/SenzaAddons;->onActivityResult(Ljava/lang/Object;IILandroid/content/Intent;)V

    return-void
.end method
```

Selain dua perubahan ini, jangan mengubah apa pun di kelas itu. Simpan, lalu **Simpan & keluar**.

---

## 5. Cara B: tambah `classes5.dex` (hanya untuk cara manual)

1. Kembali ke tampilan isi APK (paling atas, tempat `classes.dex` dan `classes2.dex` berada).
2. Ketuk tombol **+** (tambah), pilih **Tambah file**, lalu pilih `classes5.dex`.
3. Kalau sudah ada `classes5.dex`, pilih **Timpa**.
4. Namanya harus persis `classes5.dex` dan berada di **paling atas** APK, bukan di dalam folder.
5. Keluar dan simpan APK.

---

## 6. Align dan tanda tangan (wajib)

1. Tekan lama APK, pilih **Fungsi**, lalu **Tanda tangan APK**.
2. Aktifkan **Zip Align**.
3. Pakai kunci tanda tangan yang sama dengan ROM-mu.
4. Simpan hasilnya, misalnya `TranSettings_signed.apk`.
5. Pastikan `resources.arsc` tidak terkompresi:
   ```
   unzip -v TranSettings_signed.apk resources.arsc
   ```
   Kolom metode harus **`Stored`**. Kalau `Defl:N`, aktifkan opsi menyimpan `resources.arsc` tanpa kompresi di MT Manager, lalu tanda tangani ulang.

APK yang tidak di-align atau tidak ditandatangani bisa membuat HP bootloop.

---

## 7. Pasang ke ROM

1. Ganti `TranSettings.apk` di ROM dengan hasil bagian 6.
2. Hapus folder **`oat`** di samping APK itu.
3. Reboot.

---

## 8. Eksekutor ROM (untuk thermal, CPU, GPU, mode performa, Vulkan)

Dua file ini **terpisah dari APK** dan harus kamu taruh di ROM:

| File | Taruh di | Izin |
|---|---|---|
| `rom/senza_addons.rc` | `/system/etc/init/senza_addons.rc` | `0644` |
| `rom/senza_apply.sh` | `/system/bin/senza_apply.sh` | `0755` |

Konteks SELinux keduanya: `u:object_r:system_file:s0`.

Langkah:
1. Salin dua file itu ke folder tujuan di ROM.
2. Atur izinnya sesuai tabel.
3. Reboot. File `.rc` hanya dibaca saat boot.
4. Buka Senza Addon's, ubah satu fitur. Tulisan di atas dialog berubah jadi **"Eksekutor ROM: aktif"**.

**Uji tanpa aplikasi** (Termux):
```
su -c "setprop sys.senza.cfg 't=0,g=bal,m=100,u=0,r=gl,n=1'"
sleep 3
getprop sys.senza.status
```
Kalau muncul `ok <waktu> t=0 ...`, eksekutor jalan.

**Kalau tidak jalan:**
```
getenforce
dmesg | grep avc | grep -E "senza|system_app|init"
```
Kalau `getenforce` menjawab `Enforcing`, SELinux bisa menolaknya. Kirim hasil `dmesg` untuk dibuatkan aturannya.

---

## 9. Kartu XOS di "Ponsel saya" (opsional)

Kerjakan **sebelum** bagian 6.

**Ubah tulisan "Periksa Pembaruan" menjadi "SenzaProject":**
1. Di MT Manager, buka APK, ketuk **`resources.arsc`**, pilih **Editor ARSC++**.
2. Cari `tran_myphone_check_for_updates`.
3. Ubah baris **default** dan baris **in** menjadi `SenzaProject`. Simpan.

**Ganti banner kartu:**
1. Siapkan gambar WebP ukuran **2064 x 648 px**.
2. Di APK, buka folder **`res`**, tekan lama **`RN6.webp`**, pilih **Ganti**, pilih gambarmu.
3. Nama file harus tetap `RN6.webp`.

**Banner dari galeri:** Senza Addon's > Banner kartu XOS > Pilih dari galeri. Aktif setelah halaman Sistem dibuka sekali sejak Pengaturan berjalan.

---

## 10. Cek berhasil

1. Buka **Pengaturan > Sistem**. Kartu **Senza Addon's** ada di paling bawah.
2. Ketuk kartunya. Dialog terbuka.
3. Cek status di Termux:
   ```
   getprop sys.senza.status
   settings get secure show_rotation_suggestions
   ```

---

## 11. Masalah umum

| Masalah | Penyebab dan solusi |
|---|---|
| Menu tidak muncul | `classes2.dex` belum diubah atau `classes5.dex` tidak ikut. Cek `unzip -l TranSettings_signed.apk \| grep classes` (harus ada `classes5.dex`). Hapus folder `oat`, lalu reboot |
| Pengaturan crash | Ambil log (di bawah) dan kirim |
| Bootloop | Pulihkan APK cadangan. Pastikan Zip Align aktif dan tanda tangan benar |
| "Eksekutor ROM: belum aktif" | Dua file bagian 8 belum terpasang atau izinnya salah. Cek `ls -lZ /system/etc/init/senza_addons.rc /system/bin/senza_apply.sh`, lalu reboot |
| Fitur GPU tidak berefek | Node GPU tidak ada di kernel. Cek `ls /proc/gpufreq* /sys/kernel/ged/hal/` |

Ambil log:
```
logcat -c
# buka Pengaturan > Sistem, ubah satu fitur
logcat -d | grep -E "SenzaAddons|AndroidRuntime|NoClassDef|FATAL|senza" > /sdcard/Download/log.txt
```

---

## 12. Mengembalikan ke semula

1. Ganti dengan `TranSettings_cadangan.apk`, hapus folder `oat`, reboot.
2. Hapus `senza_addons.rc` dan `senza_apply.sh` dari ROM.
