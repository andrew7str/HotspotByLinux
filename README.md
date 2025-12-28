#  Hotspot Manager Pro  hotspot-manager-pro

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey.svg)
![Language](https://img.shields.io/badge/Shell-Bash-green.svg)

**Hotspot Manager Pro** adalah sebuah skrip shell (bash) yang menyediakan antarmuka baris perintah (CLI) yang interaktif dan penuh warna untuk membuat, mengelola, dan memonitor hotspot Wi-Fi di sistem operasi Linux.

Dirancang untuk kemudahan penggunaan, skrip ini menyederhanakan proses konfigurasi jaringan yang kompleks menjadi beberapa pilihan menu yang mudah dipahami. Sangat cocok untuk pengguna yang ingin dengan cepat berbagi koneksi internet mereka tanpa harus berurusan dengan konfigurasi manual `hostapd`, `dnsmasq`, dan `iptables`.

---

###  डेमो Tampilan
```
===================================
      MANAJER HOTSPOT PRO
===================================
Status: AKTIF | SSID: MyHotspot_2.4Ghz
-----------------------------------
  1. Mulai Hotspot
  2. Hentikan Hotspot
  3. Lihat Perangkat Terhubung
  4. Lihat Total Penggunaan
  5. Pantau Jaringan (Real-time)
  0. Keluar
-----------------------------------
Pilih opsi:
```

---

## ✨ Fitur Utama

- **Antarmuka Interaktif**: Menu yang mudah dinavigasi dengan UI penuh warna untuk pengalaman pengguna yang lebih baik.
- **Konfigurasi Mudah**: Atur Nama Hotspot (SSID) dan Kata Sandi dengan cepat langsung dari menu.
- **Memonitor Klien**: Lihat daftar semua perangkat yang terhubung ke hotspot Anda, lengkap dengan alamat IP dan MAC.
- **Statistik Penggunaan**: Dapatkan ringkasan total data yang diunduh (RX) dan diunggah (TX) selama sesi hotspot.
- **Pemantauan Real-Time**: Integrasi dengan `iftop` untuk memantau penggunaan bandwidth setiap klien secara *real-time*.
- **Pemeriksa Dependensi**: Skrip secara otomatis memeriksa apakah perangkat lunak yang diperlukan sudah terinstal.
- **Instalasi Terpandu untuk Kali Linux**: Dilengkapi dengan skrip pembantu untuk menginstal dependensi utama (`create_ap`) yang tidak ada di repositori default Kali.

---

## ⚙️ Kebutuhan Sistem

Skrip ini memerlukan beberapa paket agar dapat berfungsi dengan baik.

- **Dependensi Utama**:
  - `create_ap`: Inti dari fungsionalitas pembuatan hotspot.
  - `iftop`: Diperlukan untuk fitur pemantauan jaringan *real-time*.
- **Dependensi Lainnya** (biasanya sudah terinstal, tetapi skrip instalasi akan memastikannya):
  - `git`, `make`, `gcc`
  - `hostapd`, `dnsmasq`, `iptables`
  - `iw`, `rfkill`

---

## 🚀 Instalasi

Proses instalasi sedikit berbeda tergantung pada distribusi Linux Anda.

### 1. Unduh Proyek

Pertama, unduh (clone) repositori ini ke sistem lokal Anda.
```bash
git clone https://github.com/andrew7str/HotspotByLinux/
```
> **Catatan**: Ganti `NAMA_PENGGUNA_ANDA` dan `NAMA_REPO_ANDA` dengan detail repositori GitHub Anda.

### 2. Instal Dependensi

#### Untuk Debian / Ubuntu (dan turunannya)
Pada sistem ini, `create_ap` dan `iftop` dapat diinstal langsung menggunakan `apt`.
```bash
sudo apt update
sudo apt install create_ap iftop
```

#### Untuk Kali Linux (atau Instalasi Manual)
Kali Linux tidak memiliki `create_ap` di repositori default-nya. Gunakan skrip `install_create_ap_kali.sh` yang telah disediakan untuk menginstal semuanya secara otomatis.

```bash
# Beri izin eksekusi pada skrip instalasi
chmod +x install_create_ap_kali.sh

# Jalankan skrip dengan sudo
sudo ./install_create_ap_kali.sh
```
Skrip ini akan mengurus semua dependensi yang dibutuhkan. Anda hanya perlu menjalankannya sekali.

---

## usage Penggunaan

Setelah instalasi selesai, Anda siap untuk menjalankan manajer hotspot.

1.  **Beri Izin Eksekusi**
    Pastikan skrip utama dapat dieksekusi.
    ```bash
    chmod +x hotspot_manager_color.sh
    ```

2.  **Jalankan Skrip**
    Jalankan skrip dengan hak akses `sudo` karena diperlukan untuk memanipulasi pengaturan jaringan.
    ```bash
    sudo ./hotspot_manager_color.sh
    ```

3.  **Navigasi Menu**
    - **Mulai Hotspot**: Pilih opsi `1` dan ikuti petunjuk untuk mengatur SSID, kata sandi, dan antarmuka jaringan.
    - **Pantau Jaringan (Real-time)**: Pilih opsi `5` untuk masuk ke `iftop`. Tekan `q` untuk keluar dari layar pemantauan dan kembali ke menu utama.
    - **Keluar**: Pilih `0`. Jika hotspot sedang aktif, Anda akan ditanya apakah ingin mematikannya sebelum keluar.

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Jika Anda memiliki ide untuk fitur baru, perbaikan, atau menemukan bug, silakan buka *Issue* atau kirimkan *Pull Request*.

1.  *Fork* repositori ini.
2.  Buat *branch* fitur baru (`git checkout -b fitur/FiturBaru`).
3.  *Commit* perubahan Anda (`git commit -m 'Menambahkan FiturBaru'`).
4.  *Push* ke *branch* Anda (`git push origin fitur/FiturBaru`).
5.  Buka *Pull Request*.

---

## 📜 Lisensi

Proyek ini dilisensikan di bawah **MIT License**. Lihat file `LICENSE` untuk detail lebih lanjut.
