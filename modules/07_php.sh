#!/bin/bash
# Modul: Instalasi PHP 8.3 & FPM (Tanpa add-apt-repository)

echo "[1/5] Menginstall dependensi dasar (ca-certificates, curl, gnupg)..."
apt install -y ca-certificates curl gnupg || { echo "Gagal install dependensi!"; exit 1; }

echo "[2/5] Menambahkan Repository PHP 8.3 secara manual..."

# Buat direktori keyrings jika belum ada
install -m 0755 -d /etc/apt/keyrings

# Deteksi OS (Ubuntu atau Debian)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    CODENAME=$VERSION_CODENAME
else
    echo "Tidak dapat mendeteksi OS!"; exit 1
fi

if [ "$OS" = "debian" ]; then
    # Konfigurasi untuk Debian (Repository Sury)
    curl -fsSL https://packages.sury.org/php/apt.gpg -o /etc/apt/keyrings/sury-php.gpg
    echo "deb [signed-by=/etc/apt/keyrings/sury-php.gpg] https://packages.sury.org/php/ $CODENAME main" > /etc/apt/sources.list.d/php.list
    
elif [ "$OS" = "ubuntu" ]; then
    # Konfigurasi untuk Ubuntu (Repository Ondrej PPA tanpa add-apt-repository)
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c" | gpg --dearmor -o /etc/apt/keyrings/ondrej-php.gpg
    echo "deb [signed-by=/etc/apt/keyrings/ondrej-php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu $CODENAME main" > /etc/apt/sources.list.d/ondrej-php.list
    
else
    echo "OS ($OS) tidak didukung oleh script ini!"; exit 1
fi

echo "[3/5] Memperbarui daftar paket..."
apt update -y || { echo "Gagal apt update setelah menambah repository!"; exit 1; }

echo "[4/5] Menginstall PHP 8.3 dan ekstensi..."
apt install -y php8.3 php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring php8.3-curl php8.3-zip php8.3-gd || { echo "Gagal install PHP!"; exit 1; }

echo "[5/5] Mengaktifkan PHP 8.3 FPM..."
systemctl enable php8.3-fpm
systemctl start php8.3-fpm

if systemctl is-active --quiet php8.3-fpm; then
    echo "PHP 8.3 FPM berjalan dengan baik!"
else
    echo "Error: PHP 8.3 FPM gagal berjalan! Cek log: journalctl -u php8.3-fpm"
    exit 1
fi

exit 0
