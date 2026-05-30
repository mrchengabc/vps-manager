#!/bin/bash
# Modul: Security Headers

echo "Menambahkan Security Headers (X-Frame-Options, XSS Protection, dll)..."

# NGINX
if command -v nginx &> /dev/null; then
    echo "[Nginx] Membuat snippet security headers..."
    mkdir -p /etc/nginx/snippets
    cat <<EOF > /etc/nginx/snippets/security-headers.conf
# Security Headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
# Hanya aktifkan HSTS jika Anda SUDAH memasang SSL/HTTPS. Jika belum, biarkan di-comment.
# add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
EOF

    # Suntikkan include ke dalam blok http di nginx.conf agar berlaku global
    if ! grep -q "include /etc/nginx/snippets/security-headers.conf;" /etc/nginx/nginx.conf; then
        sed -i '/http {/a \    include /etc/nginx/snippets/security-headers.conf;' /etc/nginx/nginx.conf
    fi
    
    echo "[Nginx] Mereload konfigurasi..."
    nginx -t || { echo "Konfigurasi Nginx gagal!"; exit 1; }
    systemctl reload nginx || { echo "Gagal reload Nginx!"; exit 1; }
    echo "[Nginx] Security headers berhasil dipasang."
fi

# APACHE
if command -v apache2 &> /dev/null; then
    echo "[Apache] Mengaktifkan mod_headers & membuat konfigurasi..."
    a2enmod headers > /dev/null 2>&1
    
    cat <<EOF > /etc/apache2/conf-available/security-headers.conf
<IfModule mod_headers.c>
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
    # Hanya aktifkan HSTS jika Anda SUDAH memasang SSL/HTTPS. Jika belum, biarkan di-comment.
    # Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
</IfModule>
EOF

    a2enconf security-headers > /dev/null 2>&1 || { echo "Gagal mengaktifkan conf!"; exit 1; }
    
    echo "[Apache] Mereload konfigurasi..."
    apachectl configtest || { echo "Konfigurasi Apache gagal!"; exit 1; }
    systemctl reload apache2 || { echo "Gagal reload Apache!"; exit 1; }
    echo "[Apache] Security headers berhasil dipasang."
fi

# Jika tidak ada web server
if ! command -v nginx &> /dev/null && ! command -v apache2 &> /dev/null; then
    echo "Tidak ada web server (Nginx/Apache) yang terdeteksi!"
    exit 1
fi

exit 0