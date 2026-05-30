#!/bin/bash
echo "[1/3] Menambahkan Repository PHP 8.3..."
add-apt-repository ppa:ondrej/php -y || { echo "Gagal add PPA!"; exit 1; }
apt update -y
echo "[2/3] Menginstall PHP 8.3 & FPM..."
apt install php8.3 php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring php8.3-curl php8.3-zip php8.3-gd -y || { echo "Gagal install PHP!"; exit 1; }
echo "[3/3] Menyalakan FPM..."
systemctl enable php8.3-fpm
systemctl start php8.3-fpm
exit 0