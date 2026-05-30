#!/bin/bash
echo "PERINGATAN: Pastikan Anda sudah menjalankan Modul 2 (Firewall)!"
read -p "Apakah port 5631 sudah dibuka di UFW? (y/n): " confirm
if [ "$confirm" != "y" ]; then echo "Dibatalkan."; exit 1; fi

SSHD_CONFIG="/etc/ssh/sshd_config"
sed -i 's/^#Port 22/Port 5631/' $SSHD_CONFIG
sed -i 's/^Port 22/Port 5631/' $SSHD_CONFIG
grep -q "^Port 5631" $SSHD_CONFIG || echo "Port 5631" >> $SSHD_CONFIG

systemctl restart sshd || { echo "Gagal restart SSHD!"; exit 1; }
echo "Port SSH berhasil diganti ke 5631!"
exit 0