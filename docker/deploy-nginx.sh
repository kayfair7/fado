#!/bin/bash
#
# debian
#

cwd=$(dirname "$PWD")

if [ -f /var/www/isdeployed ]; then
    dpkg-statoverride --remove "/etc/ssl/private"
    dpkg-statoverride --remove "/usr/lib/dbus-1.0/dbus-daemon-launch-helper"
    dpkg-statoverride --remove "/usr/bin/crontab"
    dpkg-statoverride --remove "/etc/exim4/passwd.client"
    dpkg-reconfigure --force mariadb-server
    #dpkg-reconfigure --force memcached
    service nginx restart
    service mariadb restart
    service php8.4-fpm restart
    service memcached restart
    service --status-all
    tail -f /var/log/nginx/error.log
    exit 0
fi

adduser --disabled-password --no-create-home --verbose --quiet memcache

echo "Download & install packages"

echo "nameserver 1.1.1.1" > /etc/resolv.conf
apt update && apt -f upgrade -y
apt install -y nginx-full libnginx-mod-http-memc libnginx-mod-http-set-misc libnginx-mod-http-headers-more-filter php php-pdo-mysql php-intl php-mbstring php-mysql php-memcache php-fpm mariadb-server memcached nginx-snippets lua-nginx-memcached php-xml locales

echo "Compile locales"

locale-gen tr_TR.UTF-8
locale-gen tr_TR
locale-gen de_DE.UTF-8
locale-gen de_DE
locale-gen en_GB.UTF-8
locale-gen en_GB
locale-gen es_ES.UTF-8
locale-gen es_ES
locale-gen nl_NL.UTF-8
locale-gen nl_NL
locale-gen fr_FR.UTF-8
locale-gen fr_FR
locale-gen fa_IR.UTF-8
locale-gen fa_IR
locale-gen iw_IL.UTF-8
locale-gen iw_IL
locale-gen ar_AR.UTF-8
locale-gen ar_AR
locale-gen ru_RU.UTF-8
locale-gen ru_RU
localedef -f UTF-8 -i tr_TR tr_TR.utf8
localedef -f UTF-8 -i de_DE de_DE.utf8
localedef -f UTF-8 -i en_GB en_GB.utf8
localedef -f UTF-8 -i es_ES es_ES.utf8
localedef -f UTF-8 -i nl_NL nl_NL.utf8
localedef -f UTF-8 -i fr_FR fr_FR.utf8
localedef -f UTF-8 -i fa_IR fa_IR.utf8
localedef -f UTF-8 -i iw_IL iw_IL.utf8
localedef -f UTF-8 -i ar_AR ar_AR.utf8
localedef -f UTF-8 -i ru_RU ru_RU.utf8
update-locale
locale -a

#chown -Rvf wordpress_user $cwd/*
#chmod -Rvf 770 $cwd/*
#chgrp -Rvf wordpress_user $cwd/*

echo "Start & prepare MariaDB"

service mariadb restart

mariadb -u root -e "CREATE USER IF NOT EXISTS fado@localhost IDENTIFIED BY 'rood';"
mariadb -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'fado'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mariadb -u root -e "DROP DATABASE IF EXISTS fado; CREATE DATABASE fado DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mariadb -u root -e "GRANT ALL PRIVILEGES ON fado.* TO 'fado'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mariadb -u fado -prood fado < "$cwd/fado-DML.sql"

rm "$cwd/database.csv"

cat <<EOF >> "$cwd/database.csv"
user;fado
pwd;rood
db;fado
host;127.0.0.1
port;3306
charset;utf8
socket;/var/mysqld/mysqld.pid
EOF

echo "Configure and start Nginx and PHP FPM"

touch /run/php/php8.4-fpm.sock
rm /etc/nginx/sites-available/default
unlink /etc/nginx/sites-enabled/default

rm /etc/nginx/sites-available/fado.org
cat <<EOF >> /etc/nginx/sites-available/fado.org
server {
    listen 2080;
    server_name fado.org;
    root /var/www/html;
    index index.php
    add_header Access-Control-Allow-Origin "*" always;
    add_header Access-Control-Allow-Credentials "true" always;
    add_header Access-Control-Max-Age "3600" always;

    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.(php|phtml)$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}

EOF

ln -s /etc/nginx/sites-available/fado.org /etc/nginx/sites-enabled/fado.org


service nginx restart
service mariadb restart
service php8.4-fpm restart

echo "Start memcached RAM"
service memcached restart
service --status-all

touch /var/www/isdeployed
echo "true" > /var/www/isdeployed
tail -f /var/log/nginx/error.log

exit 0
