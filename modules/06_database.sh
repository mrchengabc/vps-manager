#!/bin/bash
echo "Pilih Database Server: 1) MariaDB  2) MySQL"
read -p "Pilihan [1-2]: " db_choice
if [ "$db_choice" == "1" ]; then
    apt install mariadb-server -y || { echo "Gagal install MariaDB!"; exit 1; }
elif [ "$db_choice" == "2" ]; then
    apt install mysql-server -y || { echo "Gagal install MySQL!"; exit 1; }
else echo "Tidak valid!"; exit 1; fi
mysql_secure_installation
exit 0