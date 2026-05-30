# ⚙️ VPS Web Server Manager (Modular) #
Skrip Bash otomatis untuk menginstal dan mengonfigurasi Web Server di VPS Linux (Ubuntu/Debian). Didesain dengan arsitektur modular untuk kemudahan debugging dan update.

# ✨ Fitur Utama # 
1. Update System & Konfigurasi Firewall (UFW)
2. Ganti SSH Port (22 ke 5631) secara aman
Instalasi Apache / Nginx
Instalasi Database (MariaDB / MySQL)
Instalasi PHP 8.3 + PHP-FPM
Manajemen Domain (Add HTML, Add PHP/WordPress, Delete Domain + Database)
. Migrasi Server via Rsync (Import/Export)
. Optimasi Performa (Gzip & Keepalive)
. Monitoring & Pembersihan Log
. Auto Update dari GitHub (Tanpa install ulang)

# Cara Update #
Jika ada versi baru di GitHub, cukup pilih Menu 14 (Update Tool) di script, atau jalankan perintah:
cd vps-manager
git pull
sudo ./main.sh


# Cara Install & Jalankan #
Clone repository ini ke VPS Anda:
git clone https://github.com/usernameanda/vps-manager.gitcd vps-manager

# Jalankan script utama sebagai root: #
sudo ./main.sh

# ⚠️ Peringatan Penting #
Jalankan Menu 2 (Firewall) SEBELUM Menu 3 (Ganti SSH Port). Jika tidak, Anda akan terkunci dari VPS!
Fitur Update (Menu 14) hanya bekerja jika Anda meng-install script ini melalui git clone, bukan download ZIP.
# 📂 Struktur Folder #
Lihat dokumentasi struktur folder pada repository ini untuk detail modul.
git init
git add .
git commit -m "Rilis awal: VPS Web Server Manager Modular"
git branch -M main
git remote add origin https://github.com/USERNAME_ANDA/vps-manager.git
git push -u origin main

* Jika tidak jalan *
https://github.com/mrchengabc/vps-manager/pull/new/main
https://github.com/mrchengabc/vps-manager.git
