# Install Git dan Clone Repository #
* Jalankan perintah berikut secara berurutan. Perintah ini akan menginstall git, mengunduh (clone) script dari GitHub Anda, dan langsung masuk ke folder project:
# Update dan install git
* apt update && apt install git -y

# Clone repository dari GitHub
*git clone https://github.com/mrchengabc/vps-manager.git

# Masuk ke folder vps-manager
* cd vps-manager

# Jalankan Script
* sudo bash main.sh

# Menggunakan Perintah Manual di Terminal (CLI)
* Jika Anda tidak mau membuka menu dan hanya ingin mengetik perintah di terminal, ikuti langkah ini:

# Masuk ke folder vps-manager:
* cd vps-manager

# Tarik (pull) versi terbaru dari GitHub:
* git pull origin main

# Perbaiki izin eksekusi agar script tidak error (karena kadang Git mengubah permission file):
* chmod +x main.sh
* chmod +x modules/*.sh

# Jalankan kembali scriptnya:
* sudo bash main.sh

# ⚠️ Troubleshooting: Jika git pull Gagal (Conflict)
* Jika Anda yakin ingin menimpa file lama dengan versi terbaru dari GitHub (mengabaikan editan lokal Anda), jalankan perintah "Force Reset" ini:
* cd vps-manager
* git fetch origin
* git reset --hard origin/main
* chmod +x main.sh modules/*.sh

