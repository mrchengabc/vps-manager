#!/bin/bash
read -p "Masukkan domain (contoh: example.com): " domain
[[ -z "$domain" ]] && { echo "Domain kosong!"; exit 1; }
echo "Pilih Web Server: 1) Apache  2) Nginx"
read -p "Pilihan [1-2]: " ws

mkdir -p /var/www/$domain || exit 1
echo "<h1>Selamat Datang di $domain</h1>" > /var/www/$domain/index.html
chown -R www-data:www-data /var/www/$domain

if [ "$ws" == "2" ]; then
    cat <<EOF > /etc/nginx/sites-available/$domain
server {
    listen 80; server_name $domain www.$domain; root /var/www/$domain; index index.html;
    location / { try_files \$uri \$uri/ =404; }
}
EOF
    ln -sf /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
    nginx -t && systemctl reload nginx || { echo "Gagal reload Nginx!"; exit 1; }
elif [ "$ws" == "1" ]; then
    cat <<EOF > /etc/apache2/sites-available/$domain.conf
<VirtualHost *:80>
    ServerName $domain; ServerAlias www.$domain; DocumentRoot /var/www/$domain
</VirtualHost>
EOF
    a2ensite $domain.conf > /dev/null
    apachectl configtest && systemctl reload apache2 || { echo "Gagal reload Apache!"; exit 1; }
fi
exit 0