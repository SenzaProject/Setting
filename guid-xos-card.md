# Kartu XOS di "Ponsel saya": ubah teks tombol dan banner

Panduan untuk dua hal di halaman **Pengaturan > Ponsel saya** pada `TranSettings.apk`:

1. Mengubah tulisan tombol **"Periksa Pembaruan"** menjadi **"SenzaProject"**.
2. Mengganti **banner (latar gradasi hijau-biru)** kartu XOS.

Semua ini diubah lewat **MT Manager**, tanpa root. Belum diuji di perangkat; ikuti bagian Verifikasi.

---

## 1. Hasil pemindaian (apa yang ditemukan di APK)

| Bagian kartu | Resource | Isi |
|---|---|---|
| Teks tombol | `string/tran_myphone_check_for_updates` (id `0x7f15235c`) | Default: `Check for Updates`, bahasa Indonesia (`in`): `Periksa Pembaruan` |
| Banner / latar kartu | `drawable/tran_myphone_background` (id `0x7f080f2d`) | File **`res/RN6.webp`**, ukuran **2064 x 648 px** |
| Banner varian lain | `drawable/tran_myphone_background_for_pova` | File `res/hZ1.webp` (2064 x 648), bukan yang dipakai di HP-mu |
| Logo XOS | `drawable/tran_myphone_logo` | File `res/oyG.xml` (vector) |
| Layout kartu | `layout/tran_os_version_layout_xos` | File `res/huT.xml`; id view: `os_version_bg` (`0x7f0b0861`), `os_version_card`, `os_version_layout`, `os_version_logo` |

Teks "Periksa Pembaruan" hanya dipakai oleh resource `tran_myphone_check_for_updates` (satu-satunya entri dengan nilai itu). Mengubahnya tidak mengenai teks lain.

> Nama file di dalam `res/` (seperti `RN6.webp`) diacak oleh pembuat ROM. Jika APK-mu berasal dari build lain, nama file bisa berbeda. Cara mencarinya ada di Troubleshooting.

---

## 2. Persiapan

1. Pakai `TranSettings_senza.apk` (hasil `patch-apk.sh`) atau APK asli, **yang belum ditandatangani/di-align ulang**. Kerjakan semua perubahan di bawah, baru zipalign + tanda tangan **sekali** di akhir.
2. Cadangkan APK: `cp TranSettings_senza.apk TranSettings_senza_backup.apk`.
3. `resources.arsc` berukuran sekitar 108 MB. Tutup aplikasi lain di HP agar MT Manager tidak kehabisan RAM.

---

## 3. Ubah "Periksa Pembaruan" menjadi "SenzaProject"

1. Buka APK di MT Manager (ketuk file, pilih **Lihat**).
2. Ketuk **`resources.arsc`**, pilih **Editor ARSC++** (ARSC Editor++). Tunggu sampai terbuka (bisa memakan waktu).
3. Cari entrinya, dua cara (pilih salah satu):
   - Ketuk ikon **cari**, ketik nama resource `tran_myphone_check_for_updates`; atau
   - Cari **nilai** `Periksa Pembaruan` (hanya ada satu hasil).
4. Buka entri `tran_myphone_check_for_updates`. Akan tampil daftar bahasa.
5. Ubah nilainya menjadi `SenzaProject` pada minimal dua baris ini:
   - **default** (`Check for Updates`)
   - **in** (`Periksa Pembaruan`)

   Kalau ingin teks sama di semua bahasa, ubah semua baris di entri itu (sekitar 88 baris). Untuk HP berbahasa Indonesia, dua baris di atas sudah cukup.
6. Simpan perubahan (**Simpan**, lalu keluar dengan **Simpan & keluar**). MT Manager menyusun ulang `resources.arsc`.

Hasil: tombol di kartu XOS menampilkan **SenzaProject**.

---

## 4. Ganti banner kartu XOS (cara statis, paling pasti jalan)

Banner adalah gambar `res/RN6.webp`. Cukup ganti file itu.

### 4a. Siapkan gambar
- Ukuran: **2064 x 648 px** (rasio sama dengan aslinya, supaya tidak melar atau terpotong).
- Format: **WebP** (nama file tujuan tetap `RN6.webp`). Konversi dari JPG/PNG memakai aplikasi/situs konversi WebP apa pun, kualitas 85 ke atas.
- Perhatikan bagian tengah gambar: logo XOS, teks versi, dan tombol tampil **di atas** banner. Hindari detail ramai di tengah, atau gunakan gambar yang cukup terang atau gelap sesuai warna teks.

### 4b. Pasang ke APK
1. Di tampilan isi APK, masuk ke folder **`res`**.
2. Cari **`RN6.webp`**. Ketuk lama, pilih **Ganti** (Replace), lalu pilih gambar WebP-mu.
3. Pastikan nama tetap persis `RN6.webp`. Jangan menambah file baru dengan nama lain.

### 4c. (Opsional) Ganti atau hapus logo XOS
`res/oyG.xml` adalah logo vector. Anda bisa menggantinya dengan vector lain, atau mengosongkannya agar logo tidak tampil. Untuk mengosongkan, ganti isinya dengan vector kosong berukuran sama.

---

## 5. Ganti banner dari galeri langsung di HP (cara dinamis)

Kit terbaru (`SenzaAddons.java` yang baru) menambahkan ini ke dialog **Senza Addon's**:
- Bagian **"Banner kartu XOS (Ponsel saya)"** dengan tombol **Pilih dari galeri** dan **Kembalikan banner asli**.
- Gambar yang dipilih dipasang sebagai latar kartu XOS (view `os_version_bg`, id `0x7f0b0861`).

**Cara pakai:** push kode baru ke GitHub, ambil `classes5.dex` yang baru, lalu patch ulang APK (lihat guid.md). Setelah terpasang: Pengaturan > Sistem > Senza Addon's > Pilih dari galeri, lalu buka **Ponsel saya**.

**Keterbatasan versi ini:**
- Pengait banner baru aktif setelah halaman **Sistem** dibuka minimal sekali sejak proses Pengaturan hidup. Kalau Pengaturan dibuka langsung ke Ponsel saya, banner bawaan tampil dulu. Cara statis (bagian 4) tidak punya batasan ini.
- Sudut membulat kartu bisa hilang kalau latar kartu memakai bentuk khusus. Cek hasilnya; kalau tampilannya kurang rapi, kirim screenshot.
- Kalau `os_version_bg` bukan ImageView, gambar dipasang sebagai latar view tersebut.

---

## 6. Simpan, align, tanda tangan, pasang

1. Keluar dari APK dan pilih **Simpan** saat ditanya.
2. Tekan lama APK, **Fungsi > Tanda tangan APK**, aktifkan **Zip Align**, pakai kunci yang sama seperti panduan utama (`guid.md`).
3. **Cek `resources.arsc` tetap tidak terkompresi** (wajib di Android 11 ke atas):
   ```
   unzip -v TranSettings_senza_signed.apk resources.arsc
   ```
   Kolom metode harus `Stored` (kompresi 0%). Kalau `Defl:N`, aktifkan opsi menyimpan `resources.arsc` tanpa kompresi di pengaturan optimasi/tanda tangan MT Manager, lalu ulangi.
4. Ganti APK di ROM, hapus folder `oat/` di sampingnya, reboot.

---

## 7. Verifikasi

1. Buka **Pengaturan > Ponsel saya**.
2. Tombol di kartu XOS bertuliskan **SenzaProject**.
3. Banner berubah (cara statis: langsung; cara dinamis: setelah memilih dari galeri).
4. Tampilan halaman lain di Pengaturan normal.

---

## 8. Troubleshooting

| Gejala | Penyebab | Solusi |
|---|---|---|
| Teks tombol belum berubah | Bahasa HP bukan Indonesia/default, atau odex lama | Ubah juga baris bahasa yang dipakai HP; hapus `oat/`; reboot |
| MT Manager gagal membuka `resources.arsc` | RAM kurang | Tutup aplikasi lain, coba lagi |
| Pengaturan crash setelah ganti banner | File `RN6.webp` rusak, atau format bukan WebP | Pulihkan cadangan; ulangi dengan WebP valid 2064 x 648 |
| Banner melar atau terpotong | Rasio gambar berbeda | Pakai tepat 2064 x 648 |
| Bootloop | APK tidak di-align atau `resources.arsc` terkompresi | Pulihkan cadangan lewat recovery; ulangi langkah bagian 6 |
| Nama file bukan `RN6.webp` di APK-mu | Build berbeda | Di Editor ARSC++, cari `tran_myphone_background`, buka entrinya, dan lihat path file yang tertulis |

---

## 9. Mengembalikan ke semula

Ganti kembali dengan APK cadangan, hapus `oat/`, reboot.
