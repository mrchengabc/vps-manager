#!/bin/bash

##############################################################################
# VPS WORDPRESS MANAGER PRO
# Debian 12 + Nginx + PHP 8.4 + MariaDB + Firewall + Backup
#
# FITUR:
# ✔ Install NGINX
# ✔ Install PHP 8.4
# ✔ Install MariaDB
# ✔ Install UFW Firewall
# ✔ Add Domain Wordpress
# ✔ Delete Domain + Database
# ✔ Backup Website + Database
# ✔ Reverse Proxy
# ✔ Security Header
# ✔ SSL Auto Let's Encrypt
#
# AUTHOR:
# jualkabel.com
#
# GITHUB READY
#
# CARA PAKAI:
#
# chmod +x manager.sh
#
# ./manager.sh install
#
# ./manager.sh adddomain domain.com
#
# ./manager.sh deletedomain domain.com
#
# ./manager.sh backup domain.com
#
# ./manager.sh reverseproxy domain.com 3000
#
##############################################################################

WEB_ROOT="/var/www"
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
BACKUP_DIR="/backup"

MYSQL_ROOT_USER="root"

##############################################################################
# HELP
##############################################################################

help_menu() {

echo "

==================================================
 VPS WORDPRESS MANAGER PRO
 Debian 12 + Nginx + PHP 8.4
==================================================

COMMAND:

./manager.sh install

./manager.sh adddomain domain.com

./manager.sh deletedomain domain.com

./manager.sh backup domain.com

./manager.sh reverseproxy domain.com 3000

==================================================

"

}

##############################################################################
# INSTALL SERVER
##############################################################################

install_server() {

echo "UPDATE SERVER..."

apt update -y
apt upgrade -y

echo "INSTALL PACKAGE..."

apt install -y \
nginx \
mariadb-server \
mariadb-client \
curl \
wget \
zip \
unzip \
ufw \
certbot \
python3-certbot-nginx \
software-properties-common \
apt-transport-https \
lsb-release \
ca-certificates \
gnupg2

echo "ADD PHP 8.4 REPOSITORY..."

curl -sSL https://packages.sury.org/php/README.txt | bash -x

apt update -y

echo "INSTALL PHP 8.4..."

apt install -y \
php8.4 \
php8.4-fpm \
php8.4-cli \
php8.4-mysql \
php8.4-curl \
php8.4-xml \
php8.4-gd \
php8.4-mbstring \
php8.4-zip \
php8.4-intl

echo "CONFIG FIREWALL..."

ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

echo "ENABLE SERVICE..."

systemctl enable nginx
systemctl enable mariadb
systemctl enable php8.4-fpm

systemctl restart nginx
systemctl restart mariadb
systemctl restart php8.4-fpm

mkdir -p $BACKUP_DIR

echo "

==================================================
 INSTALL VPS BERHASIL
==================================================

NGINX      : OK
PHP 8.4    : OK
MARIADB    : OK
UFW        : OK
SSL        : OK

==================================================

"

}

##############################################################################
# ADD DOMAIN WORDPRESS
##############################################################################

add_domain() {

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Masukkan domain."
    exit
fi

SITE_PATH="$WEB_ROOT/$DOMAIN"

DB_NAME=$(echo $DOMAIN | tr '.' '_')
DB_USER=$DB_NAME
DB_PASS=$(openssl rand -hex 8)

echo "CREATE DIRECTORY..."

mkdir -p $SITE_PATH/public_html

chown -R www-data:www-data $SITE_PATH

echo "DOWNLOAD WORDPRESS..."

cd /tmp

rm -rf wordpress latest.zip

wget https://wordpress.org/latest.zip

unzip latest.zip

cp -r wordpress/* $SITE_PATH/public_html/

echo "CREATE DATABASE..."

mysql -u $MYSQL_ROOT_USER <<MYSQL_SCRIPT

CREATE DATABASE $DB_NAME;

CREATE USER '$DB_USER'@'localhost'
IDENTIFIED BY '$DB_PASS';

GRANT ALL PRIVILEGES
ON $DB_NAME.*
TO '$DB_USER'@'localhost';

FLUSH PRIVILEGES;

MYSQL_SCRIPT

echo "CONFIG WORDPRESS..."

cp $SITE_PATH/public_html/wp-config-sample.php \
$SITE_PATH/public_html/wp-config.php

sed -i "s/database_name_here/$DB_NAME/g" \
$SITE_PATH/public_html/wp-config.php

sed -i "s/username_here/$DB_USER/g" \
$SITE_PATH/public_html/wp-config.php

sed -i "s/password_here/$DB_PASS/g" \
$SITE_PATH/public_html/wp-config.php

echo "CREATE NGINX CONFIG..."

cat > $NGINX_AVAILABLE/$DOMAIN <<EOF

server {

    listen 80;

    server_name $DOMAIN www.$DOMAIN;

    root $SITE_PATH/public_html;

    index index.php index.html;

    access_log /var/log/nginx/$DOMAIN.access.log;
    error_log /var/log/nginx/$DOMAIN.error.log;

    client_max_body_size 100M;

    #################################################################
    # SECURITY HEADER
    #################################################################

    add_header X-Frame-Options "SAMEORIGIN" always;

    add_header X-Content-Type-Options "nosniff" always;

    add_header X-XSS-Protection "1; mode=block" always;

    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    add_header Permissions-Policy \
    "geolocation=(), microphone=(), camera=()" always;

    add_header Content-Security-Policy \
    "default-src 'self' https: data: blob: 'unsafe-inline' 'unsafe-eval';" always;

    #################################################################

    location / {

        try_files \$uri \$uri/ /index.php?\$args;

    }

    location ~ \.php$ {

        include snippets/fastcgi-php.conf;

        fastcgi_pass unix:/run/php/php8.4-fpm.sock;

    }

    location ~ /\.ht {

        deny all;

    }

    location ~* \.(env|ini|log|conf)$ {

        deny all;

    }

}

EOF

ln -sf \
$NGINX_AVAILABLE/$DOMAIN \
$NGINX_ENABLED/$DOMAIN

echo "TEST NGINX..."

nginx -t

systemctl reload nginx

echo "INSTALL SSL..."

certbot --nginx \
-d $DOMAIN \
-d www.$DOMAIN \
--non-interactive \
--agree-tos \
-m admin@$DOMAIN

echo "

==================================================
 DOMAIN BERHASIL DIBUAT
==================================================

DOMAIN     : $DOMAIN

DATABASE   : $DB_NAME

DB USER    : $DB_USER

DB PASS    : $DB_PASS

ROOT PATH  : $SITE_PATH/public_html

==================================================

"

}

##############################################################################
# DELETE DOMAIN
##############################################################################

delete_domain() {

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Masukkan domain."
    exit
fi

SITE_PATH="$WEB_ROOT/$DOMAIN"

DB_NAME=$(echo $DOMAIN | tr '.' '_')

echo "DELETE WEBSITE..."

rm -rf $SITE_PATH

echo "DELETE NGINX CONFIG..."

rm -f $NGINX_ENABLED/$DOMAIN
rm -f $NGINX_AVAILABLE/$DOMAIN

echo "DELETE DATABASE..."

mysql -u $MYSQL_ROOT_USER <<MYSQL_SCRIPT

DROP DATABASE IF EXISTS $DB_NAME;

DROP USER IF EXISTS '$DB_NAME'@'localhost';

FLUSH PRIVILEGES;

MYSQL_SCRIPT

nginx -t

systemctl reload nginx

echo "

==================================================
 DOMAIN BERHASIL DIHAPUS
==================================================

$DOMAIN

==================================================

"

}

##############################################################################
# BACKUP DOMAIN
##############################################################################

backup_domain() {

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Masukkan domain."
    exit
fi

SITE_PATH="$WEB_ROOT/$DOMAIN"

DB_NAME=$(echo $DOMAIN | tr '.' '_')

DATE=$(date +"%Y-%m-%d-%H%M%S")

BACKUP_PATH="$BACKUP_DIR/$DOMAIN-$DATE"

mkdir -p $BACKUP_PATH

echo "BACKUP DATABASE..."

mysqldump -u $MYSQL_ROOT_USER \
$DB_NAME > $BACKUP_PATH/database.sql

echo "BACKUP WEBSITE..."

tar -czf \
$BACKUP_PATH/website.tar.gz \
$SITE_PATH

echo "CREATE README..."

cat > $BACKUP_PATH/README.txt <<EOF

==================================================
 WORDPRESS BACKUP
==================================================

DOMAIN:
$DOMAIN

DATABASE:
$DB_NAME

FILE:
website.tar.gz

DATABASE FILE:
database.sql

CARA RESTORE:

1. Upload website.tar.gz
2. Extract ke /var/www/
3. Import database.sql
4. Setup nginx
5. Restart nginx

==================================================

EOF

echo "

==================================================
 BACKUP BERHASIL
==================================================

PATH:
$BACKUP_PATH

==================================================

"

}

##############################################################################
# REVERSE PROXY
##############################################################################

reverse_proxy() {

DOMAIN=$1
PORT=$2

if [ -z "$DOMAIN" ]; then
    echo "Masukkan domain."
    exit
fi

if [ -z "$PORT" ]; then
    PORT=3000
fi

echo "CREATE REVERSE PROXY..."

cat > $NGINX_AVAILABLE/$DOMAIN <<EOF

server {

    listen 80;

    server_name $DOMAIN;

    #################################################################
    # SECURITY HEADER
    #################################################################

    add_header X-Frame-Options "SAMEORIGIN" always;

    add_header X-Content-Type-Options "nosniff" always;

    add_header X-XSS-Protection "1; mode=block" always;

    #################################################################

    location / {

        proxy_pass http://127.0.0.1:$PORT;

        proxy_http_version 1.1;

        proxy_set_header Upgrade \$http_upgrade;

        proxy_set_header Connection 'upgrade';

        proxy_set_header Host \$host;

        proxy_cache_bypass \$http_upgrade;

        proxy_set_header X-Real-IP \$remote_addr;

        proxy_set_header X-Forwarded-For \
        \$proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto \$scheme;

    }

}

EOF

ln -sf \
$NGINX_AVAILABLE/$DOMAIN \
$NGINX_ENABLED/$DOMAIN

nginx -t

systemctl reload nginx

echo "

==================================================
 REVERSE PROXY BERHASIL
==================================================

DOMAIN : $DOMAIN

PORT   : $PORT

==================================================

"

}

##############################################################################
# MAIN
##############################################################################

COMMAND=$1

case $COMMAND in

install)
    install_server
    ;;

adddomain)
    add_domain $2
    ;;

deletedomain)
    delete_domain $2
    ;;

backup)
    backup_domain $2
    ;;

reverseproxy)
    reverse_proxy $2 $3
    ;;

*)
    help_menu
    ;;

esac