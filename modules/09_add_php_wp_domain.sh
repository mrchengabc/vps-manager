#!/bin/bash
read -p "Masukkan domain: " domain
[[ -z "$domain" ]] && { echo "Domain kosong!"; exit 1; }
echo "Pilih Web Server: 1) Apache  2) Nginx"
read -p "Pilihan [1-2]: " ws
echo "Pilih Jenis Aplikasi: 1) PHP Murni  2) WordPress"
read -p "Pilihan [1-2]: " app

db_name=$(echo $domain | tr '.' '_' | sed 's/-/_/g'); db_user="user_${db_name}"
db_pass=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)

echo "[1/4] Membuat Database..."
mysql -e "CREATE DATABASE ${db_name};" || exit 1
mysql -e "CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';"
mysql -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost'; FLUSH PRIVILEGES;"

mkdir -p /var/www/$domain
echo "[2/4] Menyiapkan File..."
if [ "$app" == "2" ]; then
    cd /tmp && rm -f latest.tar.gz
    wget -q https://wordpress.org/latest.tar.gz || { echo "Gagal download WP!"; exit 1; }
    tar -xzf latest.tar.gz && cp -a /tmp/wordpress/. /var/www/$domain/
elif [ "$app" == "1" ]; then
    echo "<?php phpinfo(); ?>" > /var/www/$domain/index.php
fi
chown -R www-data:www-data /var/www/$domain

echo "[3/4] Konfigurasi Web Server..."
if [ "$ws" == "2" ]; then
    cat <<EOF > /etc/nginx/sites-available/$domain
server {
    listen 80; server_name $domain www.$domain; root /var/www/$domain; index index.php index.html;
    location / { try_files \$uri \$uri/ /index.php?\$args; }
    location ~ \.php$ { include snippets/fastcgi-php.conf; fastcgi_pass unix:/run/php/php8.3-fpm.sock; }
}
EOF
    ln -sf /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
    nginx -t && systemctl reload nginx || exit 1
elif [ "$ws" == "1" ]; then
    cat <<EOF > /etc/apache2/sites-available/$domain.conf
<VirtualHost *:80>
    ServerName $domain; ServerAlias www.$domain; DocumentRoot /var/www/$domain
    <Directory /var/www/$domain> AllowOverride All; Require all granted </Directory>
</VirtualHost>
EOF
    a2ensite $domain.conf > /dev/null; a2enmod rewrite proxy_fcgi setenvif > /dev/null; a2enconf php8.3-fpm > /dev/null
    apachectl configtest && systemctl reload apache2 || exit 1
fi

echo -e "\n========================================"
echo -e "DB Name  : \e[33m$db_name\e[0m"
echo -e "DB User  : \e[33m$db_user\e[0m"
echo -e "DB Pass  : \e[33m$db_pass\e[0m"
echo -e "========================================"
exit 0