#!/bin/bash
# Modul: Backup Domain & Database (Untuk Download/Pindah Hosting)

echo "Mempersiapkan proses backup..."

# 1. List Domain
echo "Mencari domain yang terdaftar..."
DOMAINS=()

if [ -d "/etc/nginx/sites-available" ]; then
    for file in /etc/nginx/sites-available/*; do
        if [ -f "$file" ]; then fname=$(basename "$file"); [[ "$fname" != "default" ]] && DOMAINS+=("$fname"); fi
    done
fi
if [ -d "/etc/apache2/sites-available" ]; then
    for file in /etc/apache2/sites-available/*.conf; do
        if [ -f "$file" ]; then fname=$(basename "$file" .conf); [[ "$fname" != "default" && "$fname" != "default-ssl" ]] && DOMAINS+=("$fname"); fi
    done
fi

if [ ${#DOMAINS[@]} -eq 0 ]; then echo "Tidak ada domain terdaftar."; exit 1; fi

echo "Domain yang tersedia:"
printf -- "- %s\n" "${DOMAINS[@]}"
echo "------------------------------------------------"

# 2. Input Domain
read -p "Masukkan domain yang ingin di-backup: " domain
[[ -z "$domain" ]] && { echo "Domain kosong!"; exit 1; }

# Validasi domain dan folder
if [ ! -d "/var/www/$domain" ]; then
    echo "Error: Direktori /var/www/$domain tidak ditemukan!"; exit 1
fi

# 3. Setup Direktori Backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/root/backups"
TEMP_DIR="/tmp/backup_${domain}_${TIMESTAMP}"
BACKUP_FILE="$BACKUP_DIR/${domain}_BACKUP_${TIMESTAMP}.tar.gz"

mkdir -p $BACKUP_DIR
mkdir -p $TEMP_DIR/web_files

echo "[1/3] Mem-backup file web dari /var/www/$domain..."
# Menggunakan cp -a agar permission dan kepemilikan file tetap terjaga
cp -a /var/www/$domain/. $TEMP_DIR/web_files/ || { echo "Gagal backup file web!"; exit 1; }

# 4. Cek dan Backup Database
db_name=$(echo $domain | tr '.' '_' | sed 's/-/_/g')

# Cek apakah database ada di MySQL
DB_EXISTS=$(mysql -e "SHOW DATABASES LIKE '$db_name';" | grep "$db_name")

if [ -n "$DB_EXISTS" ]; then
    echo "[2/3] Mem-backup database '$db_name'..."
    mysqldump $db_name > $TEMP_DIR/database.sql || { echo "Gagal dump database!"; exit 1; }
    echo "Database berhasil di-backup."
else
    echo "[2/3] Tidak ada database ditemukan untuk domain ini (Domain HTML). Melewati proses DB..."
fi

# 5. Kompres ke Tar.GZ
echo "[3/3] Mengkompres file menjadi arsip TAR.GZ..."
tar -czf $BACKUP_FILE -C $TEMP_DIR . || { echo "Gagal membuat file kompres!"; exit 1; }

# 6. Cleanup folder sementara
rm -rf $TEMP_DIR

# 7. Hasil
FILE_SIZE=$(du -sh $BACKUP_FILE | cut -f1)

echo -e "\n========================================"
echo -e "  BACKUP DOMAIN BERHASIL!"
echo -e "========================================"
echo -e "File Backup : \e[33m$BACKUP_FILE\e[0m"
echo -e "Ukuran File : \e[33m$FILE_SIZE\e[0m"
echo "----------------------------------------"
echo "Isi File Backup:"
echo "- /web_files/ (Seluruh isi dari /var/www/$domain)"
if [ -n "$DB_EXISTS" ]; then
echo "- /database.sql (Dump database $db_name)"
fi
echo "----------------------------------------"
echo -e "Cara Download ke Komputer Lokal (Jalankan di terminal PC Anda):"
echo -e "\e[32mscp root@IP_VPS_ANDA:$BACKUP_FILE .\e[0m"
echo "========================================"

exit 0
