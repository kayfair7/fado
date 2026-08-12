#!/bin/bash
#
# udocker run --platform="linux/arm64/v8" --volume="/data/data/com.termux/files/home/git/fado/:/var/www/localhost/htdocs" alpine:latest /bin/busybox sh
# cd /var/www/localhost/htdocs/docker
# busybox sh deploy-alpine.sh

echo "nameserver 8.8.4.4" > /etc/resolv.conf
export XDG_RUNTIME_DIR=/run/$(id -u)
mkdir -p "$XDG_RUNTIME_DIR/openrc/"
touch "$XDG_RUNTIME_DIR/openrc/softlevel"
mkdir -p "$XDG_RUNTIME_DIR/0/openrc"
touch "$XDG_RUNTIME_DIR/0/openrc/softlevel"
adduser -D apache
adduser -D memcached
adduser -D mariadb
adduser -D mysql
adduser -D fcgiwrap
adduser -D rngd

cwd=$(dirname "$PWD")

if [ -f /var/www/isdeployed ]; then
    mv /var/lib/mysql/aria_log_control /var/lib/mysql/aria_log_control.orig
    /etc/init.d/rngd -U restart
    /etc/init.d/fcgiwrap -U restart
    /etc/init.d/apache2 -U restart
    /etc/init.d/mariadb -U restart
    /etc/init.d/php-fpm85 -U restart
    /etc/init.d/memcached -U restart
    /etc/init.d/rngd -U status
    /etc/init.d/fcgiwrap -U status
    /etc/init.d/apache2 -U status
    /etc/init.d/mariadb -U status
    /etc/init.d/php-fpm85 -U status
    /etc/init.d/memcached -U status
    rc-service -l -s -U
    rc-status -s -l -U
    tail -f /var/log/apache2/access.log
    exit 0
fi

echo "Download & install packages"

apk add openrc apache2 php php-fpm php-intl php-pdo_mysql php-mbstring php-cli mariadb php-memcache memcached musl-locales icu-data-full mariadb-common mariadb-openrc mariadb-connector-c mariadb-client mariadb-server-utils apache2-ssl apache2-proxy apache2-openrc apache-mod-fcgid php85-apache2 php85-sysvshm php85-sysvmsg php85-sysvsem apache2-utils fcgi fcgiwrap fcgiwrap-openrc spawn-fcgi spawn-fcgi-openrc util-linux-openrc apache2-http2 udev-init-scripts-openrc akms openrc-init openrc-settingsd openrc-settingsd-openrc openrc-user openrc-user-pam dbus dbus-openrc dbus-libs dbus-glib dbus-daemon-launch-helper rng-tools rng-tools-openrc

#chown -Rvf apache:apache $cwd/*
#chmod -Rvf 770 $cwd/*

echo "Start & prepare MariaDB"

#chown -Rvf mysql /var/lib/mysql/*
#chmod -Rvf 770 /var/lib/mysql/*
mv /var/lib/mysql/aria_log_control /var/lib/mysql/aria_log_control.orig
/etc/init.d/mariadb -U setup
/etc/init.d/mariadb -U start

mariadb -u root -e "CREATE USER IF NOT EXISTS fado@localhost IDENTIFIED BY 'rood';"
mariadb -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'fado'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mariadb -u root -e "DROP DATABASE IF EXISTS fado; CREATE DATABASE fado DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mariadb -u root -e "GRANT ALL PRIVILEGES ON fado.* TO 'fado'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mariadb -u fado -prood fado < /var/www/localhost/htdocs/fado-DML.sql

rm /var/www/localhost/htdocs/database.csv

cat <<EOF >> /var/www/localhost/htdocs/database.csv
user;fado
pwd;rood
db;fado
host;127.0.0.1
port;3306
charset;utf8
socket;/var/mysqld/mysqld.pid
EOF

echo "Configure and start Apache webserver and memcached RAM"

sed -i -e 's/#LoadModule http2_module/LoadModule http2_module/g' /etc/apache2/httpd.conf
sed -i -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/g' /etc/apache2/httpd.conf
sed -i -e 's/LoadModule mpm_worker_module/#LoadModule mpm_worker_module/g' /etc/apache2/httpd.conf
sed -i -e 's/LoadModule mpm_event_module/#LoadModule mpm_event_module/g' /etc/apache2/httpd.conf
sed -i -e 's/#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/g' /etc/apache2/httpd.conf
sed -i -e 's/# Mutex default:\/run\/apache2/Mutex file:\/run\/apache2/g' /etc/apache2/httpd.conf
sed -i -e 's/Listen 80/Listen 2080/g' /etc/apache2/httpd.conf

rm /etc/apache2/conf.d/mod_fcgid.conf

cat <<EOF >> /etc/apache2/conf.d/mod_fcgid.conf 
AddHandler fcgid-script fcg fcgi fpl

<IfModule mod_fcgid>
    <Files ~ "\.php$">
        Options +ExecCGI
        SetHandler fcgid-script
        Allow from all
        FcgidWrapper "/usr/bin/fcgiwrap" .php
     </Files>
     <Files ~ "\.phtml$">
        Options +ExecCGI
        SetHandler fcgid-script
        Allow from all
        FcgidWrapper "/usr/bin/fcgiwrap" .phtml
     </Files>
</IfModule>
EOF

rm /etc/apache2/conf.d/default.conf

rm /etc/apache2/conf.d/fado.conf

cat <<EOF >> /etc/apache2/conf.d/fado.conf

DirectoryIndex index.php index.html
LoadModule php_module /var/www/modules/mod_php85.so
ServerName fado.org

<VirtualHost _default_:2080>
        ServerAdmin admin@fado.org
        DocumentRoot /var/www/localhost/htdocs
        ServerName fado.org

        <IfModule mod_headers.c>
            Header set Access-Control-Allow-Origin "*"
            Header set Access-Control-Allow-Credentials "true"
            Header set Access-Control-Max-Age "3600"
        </IfModule>

        <IfModule mod_ssl.c>
            <IfModule mod_rewrite.c>
                RewriteEngine on
                RewriteCond "%{HTTPS}" on
                RewriteRule "^/?(.*)" "https://%{SERVER_NAME}/$1" [L,R=301]
            </IfModule>
        </IfModule>

        <IfModule mod_rewrite.c>
            RewriteEngine on
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule "/(.*)/$" "/index.php?page=$1" [L,QSA]
        </IfModule>

        <FilesMatch "\.(csv|md|sql|sh|log)$">
            Require all denied
        </FilesMatch>

        ErrorDocument 404 /index.php?page=404
        ErrorDocument 403 /index.php?page=403
</VirtualHost>
<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerAdmin admin@fado.org
        DocumentRoot /var/www/localhost/htdocs
        ServerName fado.org

        <IfModule mod_headers.c>
            Header set Access-Control-Allow-Origin "*"
            Header set Access-Control-Allow-Credentials "true"
        </IfModule>

        <IfModule mod_rewrite.c>
            RewriteEngine on
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule "/(.*)/$" "/index.php?page=$1" [L,QSA]
        </IfModule>

        SSLEngine on
        SSLCertificateFile /home/fado/Desktop/SSL/ca.pem
        SSLCertificateChainFile /home/fado/Desktop/SSL/ca.chain.pem
        SSLCertificateKeyFile /home/fado/Desktop/SSL/key.pem

        <FilesMatch "\.(csv|md|sql|sh|log)$">
            Require all denied
        </FilesMatch>

        ErrorDocument 404 /index.php?page=404
        ErrorDocument 403 /index.php?page=403
    </VirtualHost>
</IfModule>
EOF

rm /var/www/localhost/htdocs/index.html
rm /etc/apache2/conf.d/ssl.conf
rm /etc/apache2/conf.d/http2.conf
rm /etc/apache2/conf.d/php*

/etc/init.d/rngd -U restart
/etc/init.d/fcgiwrap -U restart
/etc/init.d/apache2 -U restart
/etc/init.d/php-fpm85 -U restart
/etc/init.d/memcached -U restart

/etc/init.d/rngd -U status
/etc/init.d/fcgiwrap -U status
/etc/init.d/apache2 -U status
/etc/init.d/mariadb -U status
/etc/init.d/php-fpm85 -U status
/etc/init.d/memcached -U status

rc-service -l -s -U
rc-status -s -l -U

touch /var/www/isdeployed
echo "true" > /var/www/isdeployed
tail -f /var/log/apache2/access.log
exit 0
