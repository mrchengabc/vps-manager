# ⚙️ VPS Web Server Manager (Modular) #
Skrip Bash otomatis untuk menginstal dan mengonfigurasi Web Server di VPS Linux (Ubuntu/Debian). Didesain dengan arsitektur modular untuk kemudahan debugging dan update.

# ✨ Fitur Utama # 
1. Update System & Konfigurasi Firewall (UFW)
2. Ganti SSH Port (22 ke 5631) secara aman
3. Instalasi Apache / Nginx
4. Instalasi Database (MariaDB / MySQL)
5. Instalasi PHP 8.3 + PHP-FPM
6. Manajemen Domain (Add HTML, Add PHP/WordPress, Delete Domain + Database)
7. Migrasi Server via Rsync (Import/Export)
8. Optimasi Performa (Gzip & Keepalive)
9. Monitoring & Pembersihan Log
10. Auto Update dari GitHub (Tanpa install ulang)

# Cara Update #
# Jika ada versi baru di GitHub, cukup pilih Menu 14 (Update Tool) di script, atau jalankan perintah:
1. cd vps-manager
2. git pull
3. sudo ./main.sh


# Cara Install & Jalankan #
# Clone repository ini ke VPS Anda:
1. git clone https://github.com/usernameanda/vps-manager.gitcd vps-manager

# Jalankan script utama sebagai root: #
1. sudo ./main.sh

# ⚠️ Peringatan Penting #
Jalankan Menu 2 (Firewall) SEBELUM Menu 3 (Ganti SSH Port). Jika tidak, Anda akan terkunci dari VPS!
Fitur Update (Menu 14) hanya bekerja jika Anda meng-install script ini melalui git clone, bukan download ZIP.
# 📂 Struktur Folder #
Lihat dokumentasi struktur folder pada repository ini untuk detail modul.
1. git init
2. git add .
3. git commit -m "Rilis awal: VPS Web Server Manager Modular"
4. git branch -M main
5. git remote add origin https://github.com/USERNAME_ANDA/vps-manager.git
6. git push -u origin main

# Jika tidak jalan #
1. https://github.com/mrchengabc/vps-manager/pull/new/main
2. https://github.com/mrchengabc/vps-manager.git
