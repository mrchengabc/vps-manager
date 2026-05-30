#!/bin/bash
echo "[1/4] Menginstall UFW..."
apt install ufw -y || { echo "Gagal install UFW!"; exit 1; }
echo "[2/4] Membuka Port SSH Baru (5631)..."
ufw allow 5631/tcp || { echo "Gagal menambahkan port 5631!"; exit 1; }
echo "[3/4] Membuka Port Web (80, 443)..."
ufw allow 80/tcp
ufw allow 443/tcp
echo "[4/4] Mengaktifkan UFW..."
ufw --force enable
ufw status
exit 0