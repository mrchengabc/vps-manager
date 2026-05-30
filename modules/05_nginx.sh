#!/bin/bash
# Modul: Instalasi Nginx (Auto Remove Apache jika ada)

# Cek apakah Apache terinstall
if command -v apache2 &> /dev/null; then
    echo "========================================"
    echo "PERINGATAN: Apache terdeteksi terinstall di server ini!"
    echo "Menjalankan Nginx dan Apache bersamaan akan menyebabkan konflik Port 80/443."
    
    # Cek apakah ada domain aktif di Apache
    APACHE_DOMAINS=$(ls /etc/apache2/sites-available/*.conf 2>/dev/null | grep -v default | sed 's/.conf$//' | xargs -n 1 basename)
    if [ -n "$APACHE_DOMAINS" ]; then
        echo "PERINGATAN KERAS: Ada domain aktif di Apache:"
        echo "$APACHE_DOMAINS"
        echo "Jika Anda melanjutkan, Apache akan dihapus dan domain tersebut TIDAK bisa diakses sampai dipindahkan ke Nginx!"
    fi
    
    echo "========================================"
    read -p "Apakah Anda yakin ingin MENGHAPUS Apache dan menggantinya dengan Nginx? (y/n): " confirm_remove
    
    if [ "$confirm_remove" != "y" ]; then
        echo "Instalasi Nginx dibatalkan. Apache tetap dipertahankan."
        exit 0
    fi

    echo "[0/3] Menghapus Apache dan konfigurasinya..."
    systemctl stop apache2
    apt purge apache2 apache2-bin apache2-utils apache2-data -y || { echo "Gagal menghapus Apache!"; exit 1; }
    apt autoremove -y
    echo "Apache berhasil dihapus."
fi

echo "[1/3] Menginstall Nginx..."
apt install nginx -y || { echo "Gagal install Nginx!"; exit 1; }

echo "[2/3] Membuka Firewall..."
ufw allow 'Nginx Full'

echo "[3/3] Mengecek status..."
systemctl enable nginx
systemctl is-active --quiet nginx || { echo "Nginx gagal berjalan!"; exit 1; }

exit 0
