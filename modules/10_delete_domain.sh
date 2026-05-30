#!/bin/bash
DOMAINS=()
if [ -d "/etc/nginx/sites-available" ]; then
    for f in /etc/nginx/sites-available/*; do [[ -f "$f" && "$(basename $f)" != "default" ]] && DOMAINS+=("$(basename $f)"); done
fi
if [ -d "/etc/apache2/sites-available" ]; then
    for f in /etc/apache2/sites-available/*.conf; do 
        fname=$(basename "$f" .conf); [[ -f "$f" && "$fname" != "default" && "$fname" != "default-ssl" ]] && DOMAINS+=("$fname")
    done
fi

if [ ${#DOMAINS[@]} -eq 0 ]; then echo "Tidak ada domain terdaftar."; exit 0; fi

echo "Domain terdaftar:"; printf -- "- %s\n" "${DOMAINS[@]}"
read -p "Masukkan domain yang akan dihapus: " domain
[[ -z "$domain" ]] && { echo "Kosong!"; exit 1; }
[[ ! " ${DOMAINS[@]} " =~ " ${domain} " ]] && { echo "Domain tidak ada di daftar!"; exit 1; }

db_name=$(echo $domain | tr '.' '_' | sed 's/-/_/g'); db_user="user_${db_name}"
echo "PERINGATAN: Ini akan menghapus /var/www/$domain dan Database $db_name!"
read -p "OTORISASI: Ketik ulang '$domain' untuk melanjutkan: " confirm
[[ "$confirm" != "$domain" ]] && { echo "Tidak cocok. Dibatalkan."; exit 0; }

echo "Menghapus..."
rm -rf /var/www/$domain
[ -f "/etc/nginx/sites-available/$domain" ] && { rm -f /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/$domain; nginx -t && systemctl reload nginx; }
[ -f "/etc/apache2/sites-available/$domain.conf" ] && { a2dissite $domain.conf > /dev/null; rm -f /etc/apache2/sites-available/$domain.conf; apachectl configtest && systemctl reload apache2; }
mysql -e "DROP DATABASE IF EXISTS ${db_name}; DROP USER IF EXISTS '${db_user}'@'localhost'; FLUSH PRIVILEGES;"
exit 0