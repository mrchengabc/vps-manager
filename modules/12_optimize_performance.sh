#!/bin/bash
if command -v nginx &> /dev/null; then
    sed -i 's/# gzip/gzip/g' /etc/nginx/nginx.conf; sed -i 's/gzip off/gzip on/g' /etc/nginx/nginx.conf
    grep -q "gzip_types" /etc/nginx/nginx.conf || sed -i '/gzip on/a\        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;' /etc/nginx/nginx.conf
    sed -i 's/keepalive_timeout.*/keepalive_timeout 65;/' /etc/nginx/nginx.conf
    nginx -t && systemctl reload nginx
fi
if command -v apache2 &> /dev/null; then
    a2enmod deflate headers expires > /dev/null 2>&1
    echo "<IfModule mod_deflate.c>\nAddOutputFilterByType DEFLATE text/html text/plain text/xml text/css\nAddOutputFilterByType DEFLATE application/javascript application/json\n</IfModule>" > /etc/apache2/mods-available/deflate.conf
    sed -i 's/KeepAlive.*/KeepAlive On/' /etc/apache2/apache2.conf
    apachectl configtest && systemctl reload apache2
fi
exit 0