#!/bin/bash
# Modul: Instalasi SSL Let's Encrypt & Konfigurasi Auto Renewal

echo "Mempersiapkan instalasi SSL Let's Encrypt dan Auto Renewal..."

# 1. Install Certbot
echo "[1/6] Menginstall Certbot dan plugin web server..."
apt install certbot python3-certbot-nginx python3-certbot-apache -y || { echo "Gagal install Certbot!"; exit 1; }

# 2. Pilih Web Server
echo "Pilih Web Server yang digunakan:"
echo "1) Apache"
echo "2) Nginx"
read -p "Pilihan [1-2]: " ws_choice

if [ "$ws_choice" != "1" ] && [ "$ws_choice" != "2" ]; then
    echo "Pilihan tidak valid!"; exit 1
fi

# 3. List Domain yang terdaftar
echo "[2/6] Mencari domain yang terdaftar..."
DOMAINS=()

if [ "$ws_choice" == "2" ] && [ -d "/etc/nginx/sites-available" ]; then
    for file in /etc/nginx/sites-available/*; do
        if [ -f "$file" ]; then
            fname=$(basename "$file")
            [[ "$fname" != "default" ]] && DOMAINS+=("$fname")
        fi
    done
elif [ "$ws_choice" == "1" ] && [ -d "/etc/apache2/sites-available" ]; then
    for file in /etc/apache2/sites-available/*.conf; do
        if [ -f "$file" ]; then
            fname=$(basename "$file" .conf)
            [[ "$fname" != "default" && "$fname" != "default-ssl" ]] && DOMAINS+=("$fname")
        fi
    done
fi

if [ ${#DOMAINS[@]} -eq 0 ]; then
    echo "Tidak ada domain yang terdaftar di web server. Silakan add domain terlebih dahulu."
    exit 1
fi

echo "Domain yang tersedia:"
printf -- "- %s\n" "${DOMAINS[@]}"

# 4. Input Domain
read -p "Masukkan domain yang ingin dipasangi SSL (sesuai daftar di atas): " domain
if [ -z "$domain" ]; then echo "Domain kosong!"; exit 1; fi

# Validasi domain
found=0
for d in "${DOMAINS[@]}"; do
    if [[ "$d" == "$domain" ]]; then found=1; break; fi
done

if [ $found -eq 0 ]; then
    echo "Error: Domain '$domain' tidak ditemukan di konfigurasi web server!"
    exit 1
fi

# 5. Eksekusi Certbot
echo "[3/6] Meminta sertifikat SSL dari Let's Encrypt..."
echo "PERINGATAN: Pastikan DNS domain $domain SUDAH mengarah ke IP VPS ini!"
read -p "Apakah DNS sudah diarahkan? (y/n): " dns_confirm
if [ "$dns_confirm" != "y" ]; then
    echo "Proses dibatalkan. Arahkan DNS terlebih dahulu."; exit 0
fi

if [ "$ws_choice" == "2" ]; then
    # Nginx
    certbot --nginx -d $domain -d www.$domain --non-interactive --agree-tos --redirect || { echo "Gagal memasang SSL di Nginx! Cek apakah port 80 terbuka."; exit 1; }
elif [ "$ws_choice" == "1" ]; then
    # Apache
    certbot --apache -d $domain -d www.$domain --non-interactive --agree-tos --redirect || { echo "Gagal memasang SSL di Apache! Cek apakah port 80 terbuka."; exit 1; }
fi

# 6. Optimasi Pasca SSL (Aktifkan HSTS di Security Headers)
echo "[4/6] Mengaktifkan HSTS pada Security Headers (Karena SSL sudah terpasang)..."
if [ "$ws_choice" == "2" ] && [ -f "/etc/nginx/snippets/security-headers.conf" ]; then
    sed -i 's/# add_header Strict-Transport-Security/add_header Strict-Transport-Security/' /etc/nginx/snippets/security-headers.conf
    nginx -t && systemctl reload nginx
elif [ "$ws_choice" == "1" ] && [ -f "/etc/apache2/conf-available/security-headers.conf" ]; then
    sed -i 's/# Header always set Strict-Transport-Security/Header always set Strict-Transport-Security/' /etc/apache2/conf-available/security-headers.conf
    systemctl reload apache2
fi

# =====================================================
# INTEGRASI AUTO RENEW SSL (SEBELUMNYA MODUL 18)
# =====================================================

echo "[5/6] Mengkonfigurasi Auto Renewal SSL (Cron & Auto-Reload)..."
CRON_FILE="/etc/cron.d/certbot-auto-renew"

# Buat cron job harian jam 2 pagi dengan deploy-hook untuk auto-reload web server
cat <<EOF > $CRON_FILE
# Certbot Auto Renewal - Jalankan setiap hari jam 02:00 pagi
0 2 * * * root certbot renew --quiet --deploy-hook "systemctl reload nginx apache2 2>/dev/null" >> /var/log/certbot-renew.log 2>&1
EOF
chmod 644 $CRON_FILE || { echo "Gagal mengatur permission cron!"; exit 1; }

# Nonaktifkan timer bawaan certbot agar tidak konflik dengan cron custom kita
if systemctl is-active --quiet certbot.timer 2>/dev/null; then
    systemctl stop certbot.timer
    systemctl disable certbot.timer
    systemctl mask certbot.timer
fi

echo "[6/6] Menjalankan tes Auto-Renewal (Dry-Run)..."
echo "Ini hanya simulasi, tidak akan mengubah sertifikat Anda."
certbot renew --dry-run 2>&1

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}Tes Auto-Renewal BERHASIL!${NC}"
else
    echo -e "\n${YELLOW}Peringatan: Tes Auto-Renewal gagal, namun SSL sudah terpasang. Cek log untuk detailnya.${NC}"
fi

echo -e "\n========================================"
echo "  SSL LET'S ENCRYPT BERHASIL DIPASANG!"
echo "  Website kini dapat diakses via HTTPS."
echo "  Auto-Renewal aktif (Cron jam 02:00)."
echo "  Jika SSL diperpanjang, Web Server akan"
echo "  otomatis di-reload."
echo "  Log: /var/log/certbot-renew.log"
echo "========================================"

exit 0