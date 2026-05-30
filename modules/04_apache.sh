#!/bin/bash
echo "[1/3] Menginstall Apache2..."
apt install apache2 -y || { echo "Gagal install Apache!"; exit 1; }
echo "[2/3] Membuka Firewall..."
ufw allow 'Apache Full'
echo "[3/3] Mengecek status..."
systemctl enable apache2
systemctl is-active --quiet apache2 || { echo "Apache gagal berjalan!"; exit 1; }
exit 0