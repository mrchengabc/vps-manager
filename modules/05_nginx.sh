#!/bin/bash
echo "[1/3] Menginstall Nginx..."
apt install nginx -y || { echo "Gagal install Nginx!"; exit 1; }
echo "[2/3] Membuka Firewall..."
ufw allow 'Nginx Full'
echo "[3/3] Mengecek status..."
systemctl enable nginx
systemctl is-active --quiet nginx || { echo "Nginx gagal berjalan!"; exit 1; }
exit 0