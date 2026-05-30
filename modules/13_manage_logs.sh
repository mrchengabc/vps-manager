#!/bin/bash
echo "1) Lihat Log  2) Hapus Log"
read -p "Pilihan: " log_choice
if [ "$log_choice" == "1" ]; then
    echo "1) Nginx Err  2) Nginx Acc  3) Apache Err  4) Apache Acc"
    read -p "Pilihan: " lt
    case $lt in 1) tail -f /var/log/nginx/error.log ;; 2) tail -f /var/log/nginx/access.log ;; 3) tail -f /var/log/apache2/error.log ;; 4) tail -f /var/log/apache2/access.log ;; esac
elif [ "$log_choice" == "2" ]; then
    [ -d /var/log/nginx ] && truncate -s 0 /var/log/nginx/*.log
    [ -d /var/log/apache2 ] && truncate -s 0 /var/log/apache2/*.log
fi
exit 0