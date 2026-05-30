#!/bin/bash
echo "1) Export (Ke Remote)  2) Import (Dari Remote)"
read -p "Pilihan [1-2]: " act; read -p "Domain: " domain; read -p "IP Remote: " remote_ip; read -p "User Remote [root]: " ssh_user; ssh_user=${ssh_user:-root}
db_name=$(echo $domain | tr '.' '_' | sed 's/-/_/g')

if [ "$act" == "1" ]; then
    mysqldump $db_name > /tmp/${db_name}.sql || exit 1
    rsync -avz /var/www/$domain/ ${ssh_user}@${remote_ip}:/var/www/$domain/ || exit 1
    rsync -avz /tmp/${db_name}.sql ${ssh_user}@${remote_ip}:/tmp/${db_name}.sql || exit 1
    rm /tmp/${db_name}.sql
elif [ "$act" == "2" ]; then
    rsync -avz ${ssh_user}@${remote_ip}:/var/www/$domain/ /var/www/$domain/ || exit 1
    rsync -avz ${ssh_user}@${remote_ip}:/tmp/${db_name}.sql /tmp/${db_name}.sql || exit 1
    mysql -e "CREATE DATABASE IF NOT EXISTS ${db_name};" && mysql $db_name < /tmp/${db_name}.sql || exit 1
    rm /tmp/${db_name}.sql; chown -R www-data:www-data /var/www/$domain
fi
exit 0