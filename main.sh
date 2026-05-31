#!/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Cek root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Script ini harus dijalankan sebagai root!${NC}"
   exit 1
fi

# Mendapatkan path absolut
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULES_DIR="$SCRIPT_DIR/modules"

# ==========================================
# AUTO CHMOD (Memastikan semua script bisa dieksekusi)
# ==========================================
chmod +x "$SCRIPT_DIR/main.sh"
chmod +x "$MODULES_DIR/"*.sh

# Fungsi untuk menjalankan modul
run_module() {
    local module_path="$MODULES_DIR/$1"
    
    if [ ! -f "$module_path" ]; then
        echo -e "${RED}Error: Modul $module_path tidak ditemukan!${NC}"
        read -p "Tekan Enter untuk kembali ke menu..."
        return 1
    fi
    
    bash "$module_path"
    local status=$?
    
    # Jika modul update mengirim sinyal exit 99, tutup main.sh agar user menjalankan ulang
    if [ $status -eq 99 ]; then
        exit 0
    elif [ $status -ne 0 ]; then
        echo -e "${RED}Modul $1 gagal dieksekusi. Silakan cek error di atas.${NC}"
    else
        echo -e "${GREEN}Modul $1 berhasil dieksekusi.${NC}"
    fi
    
    read -p "Tekan Enter untuk melanjutkan..."
}

# Menu Utama
while true; do
    clear
    echo -e "${GREEN}========================================"
    echo "   VPS WEB SERVER MANAGER (Modular)"
    echo "========================================${NC}"
    echo "1.  Update System (Ubuntu/Debian)"
    echo "2.  Konfigurasi Firewall (UFW)"
    echo "3.  Ganti SSH Port (22 -> 5631)"
    echo "----------------------------------------"
    echo "4.  Instalasi Apache"
    echo "5.  Instalasi Nginx"
    echo "6.  Instalasi Database (MySQL/MariaDB)"
    echo "7.  Instalasi PHP 8.3 & PHP-FPM"
    echo "----------------------------------------"
    echo "8.  Add Domain (HTML - Tanpa DB)"
    echo "9.  Add Domain (PHP / WordPress)"
    echo "10. Delete Domain & Database"
    echo "----------------------------------------"
    echo "11. Rsync Import/Export Domain & DB"
    echo "12. Optimasi Performa (Gzip, Keepalive)"
    echo "13. Monitoring & Log"
    echo "14. Update Tool (Cek Update dari GitHub)"
    echo "----------------------------------------"
    echo "15. Security Headers (XSS, Clickjacking)"
    echo "16. Konfigurasi Swap Server"
    echo "17. Instalasi SSL Let's Encrypt + Auto Renew"
    echo "----------------------------------------"
    echo "18. Backup Domain & Database (Download)"
	echo "19. Keluar"
    echo -e "${GREEN}========================================${NC}"
    read -p "Pilih menu [1-19]: " choice

    case $choice in
        1) run_module "01_update.sh" ;;
        2) run_module "02_firewall.sh" ;;
        3) run_module "03_ssh_port.sh" ;;
        4) run_module "04_apache.sh" ;;
        5) run_module "05_nginx.sh" ;;
        6) run_module "06_database.sh" ;;
        7) run_module "07_php.sh" ;;
        8) run_module "08_add_html_domain.sh" ;;
        9) run_module "09_add_php_wp_domain.sh" ;;
        10) run_module "10_delete_domain.sh" ;;
        11) run_module "11_rsync_transfer.sh" ;;
        12) run_module "12_optimize_performance.sh" ;;
        13) run_module "13_manage_logs.sh" ;;
        14) run_module "14_update_tool.sh" ;;
        15) run_module "15_security_headers.sh" ;;
        16) run_module "16_swap_server.sh" ;;
        17) run_module "17_ssl_letsencrypt.sh" ;;
		18) run_module "18_backup_domain.sh" ;;
        19) exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}" && sleep 1 ;;
    esac
done
