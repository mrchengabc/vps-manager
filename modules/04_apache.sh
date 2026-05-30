#!/bin/bash
# Modul: Instalasi Apache (Auto Remove Nginx jika ada)

# Cek apakah Nginx terinstall
if command -v nginx &> /dev/null; then
    echo "========================================"
    echo "PERINGATAN: Nginx terdeteksi terinstall di server ini!"
    echo "Menjalankan Apache dan Nginx bersamaan akan menyebabkan konflik Port 80/443."
    
    # Cek apakah ada domain aktif di Nginx
    NGINX_DOMAINS=$(ls /etc/nginx/sites-available/ 2>/dev/null | grep -v default)
    if [ -n "$NGINX_DOMAINS" ]; then
        echo "PERINGATAN KERAS: Ada domain aktif di Nginx:"
        echo "$NGINX_DOMAINS"
        echo "Jika Anda melanjutkan, Nginx akan dihapus dan domain tersebut TIDAK bisa diakses sampai dipindahkan ke Apache!"
    fi
    
    echo "========================================"
    read -p "Apakah Anda yakin ingin MENGHAPUS Nginx dan menggantinya dengan Apache? (y/n): " confirm_remove
    
    if [ "$confirm_remove" != "y" ]; then
        echo "Instalasi Apache dibatalkan. Nginx tetap dipertahankan."
        exit 0
    fi

    echo "[0/3] Menghapus Nginx dan konfigurasinya..."
    systemctl stop nginx
    apt purge nginx nginx-common nginx-full -y || { echo "Gagal menghapus Nginx!"; exit 1; }
    apt autoremove -y
    echo "Nginx berhasil dihapus."
fi

echo "[1/3] Menginstall Apache2..."
apt install apache2 -y || { echo "Gagal install Apache!"; exit 1; }

echo "[2/3] Membuka Firewall..."
ufw allow 'Apache Full'

echo "[3/3] Mengecek status..."
systemctl enable apache2
systemctl is-active --quiet apache2 || { echo "Apache gagal berjalan!"; exit 1; }

exit 0
