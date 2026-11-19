#!/bin/bash
#
#
# proot-distro run -b "/data/data/com.termux/files/home/fado:/var/www/localhost/htdocs" alpine -- /bin/busybox sh /var/www/localhost/htdocs/docker/deploy-alpine.sh

cd /var/www/localhost/htdocs

if [ -f /var/www/isdeployed ]; then
    mv /var/lib/mysql/aria_log_control /var/lib/mysql/aria_log_control.orig
    /etc/init.d/apache2 restart
    /etc/init.d/memcached restart
    /etc/init.d/mariadb restart
    rc-status
    tail -f /var/log/apache2/access.log
fi

echo "Download & install packages"
echo "nameserver 74.82.42.42" > /etc/resolv.conf
echo "fado-srv" > /etc/hostname
apk add nano openrc apache2 php php-intl php-pdo_mysql php-mbstring php-cli mariadb php-memcache memcached musl-locales icu-data-full mariadb-common mariadb-openrc mariadb-connector-c mariadb-client mariadb-server-utils apache2-ssl apache2-proxy apache2-openrc apache-mod-fcgid php85-apache2 apache2-http2
adduser -D apache
adduser -D memcached
adduser -D mariadb
adduser -D mysql
chown -Rvf apache:apache /var/www/localhost/htdocs
chmod -Rvf 770 /var/www/localhost/htdocs
chmod -Rvf 770 /var
chmod -Rvf 777 /tmp
echo 'rc_need="!dev !net"' >> /etc/rc.conf
sed -i -e "s/skip-networking/#skip-networking/g" /etc/my.cnf.d/mariadb-server.cnf
touch /run/openrc/softlevel

echo "Start & prepare MariaDB"

/etc/init.d/mariadb setup
/etc/init.d/mariadb start

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

cat <<EOF >> "$PWD/.htaccess"

EOF

echo "Configure and start Apache webserver and memcached RAM"

sed -i -e 's/#LoadModule http2_module/LoadModule http2_module/g' /etc/apache2/httpd.conf
sed -i -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/g' /etc/apache2/httpd.conf
sed -i -e 's/LoadModule mpm_worker_module/#LoadModule mpm_worker_module/g' /etc/apache2/httpd.conf
sed -i -e 's/LoadModule mpm_event_module/#LoadModule mpm_event_module/g' /etc/apache2/httpd.conf
sed -i -e 's/#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/g' /etc/apache2/httpd.conf
sed -i -e 's/# Mutex default:\/run\/apache2/Mutex file:\/run\/apache2/g' /etc/apache2/httpd.conf
sed -i -e 's/Listen 80/Listen 2080/g' /etc/apache2/httpd.conf
mv /etc/apache2/conf.d/proxy.conf /etc/apache2/conf.d/proxy.conf.old
mv /etc/apache2/conf.d/mod_fcgid.conf /etc/apache2/conf.d/mod_fcgid.conf.old
mv /etc/apache2/conf.d/http2.conf /etc/apache2/conf.d/http2.conf.old
mv /etc/apache2/conf.d/ssl.conf /etc/apache2/conf.d/ssl.conf.old
rm /etc/apache2/conf.d/fado.conf
rm /var/www/localhost/htdocs/index.html

cat <<EOF >> /etc/apache2/conf.d/fado.conf
DirectoryIndex index.php index.html
LoadModule php_module modules/mod_php85.so
ServerName fado.org

<VirtualHost _default_:2080>
        ServerAdmin admin@fado.org
        DocumentRoot /var/www/localhost/htdocs
        ServerName fado.org

        <FilesMatch "\.(php|phtml)\$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        <IfModule mod_headers.c>
            Header set Access-Control-Allow-Origin "*"
            Header set Access-Control-Allow-Credentials "true"
            Header set Access-Control-Max-Age "3600"
        </IfModule>

        <IfModule mod_ssl.c>
            <IfModule mod_rewrite.c>
                RewriteEngine on
                RewriteCond "%{HTTPS}" !=on
                RewriteRule "^/?(.*)" "https://%{SERVER_NAME}/\$1" [L,R=301]
            </IfModule>
        </IfModule>

        <IfModule mod_rewrite.c>
            RewriteEngine on
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule "^/(.+)/\$" "/index.php?page=\$1" [L,QSA]
        </IfModule>

        <FilesMatch "\.(htaccess|csv|md|sql|sh|log|gz|yml|conf|gz)\$">
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

        <FilesMatch "\.(php|phtml)\$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        <IfModule mod_headers.c>
            Header set Access-Control-Allow-Origin "*"
            Header set Access-Control-Allow-Credentials "true"
        </IfModule>

        <IfModule mod_rewrite.c>
            RewriteEngine on
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule "^/(.+)/\$" "/index.php?page=\$1" [L,QSA]
        </IfModule>

        SSLEngine on
        SSLCertificateFile ~/SSL/ca.pem
        SSLCertificateChainFile ~/SSL/ca.chain.pem
        SSLCertificateKeyFile ~/SSL/key.pem

        <FilesMatch "\.(htaccess|csv|md|sql|sh|log|gz|yml|conf)\$">
            Require all denied
        </FilesMatch>

        ErrorDocument 404 /index.php?page=404
        ErrorDocument 403 /index.php?page=403
    </VirtualHost>
</IfModule>
EOF

/etc/init.d/apache2 restart
/etc/init.d/memcached restart
rc-status

touch /var/www/isdeployed
echo "true" > /var/www/isdeployed
#tail -f /var/log/apache2/access.log
