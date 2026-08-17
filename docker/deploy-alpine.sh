#!/bin/bash
#
# udocker run --platform="linux/arm64/v8" --volume="/data/data/com.termux/files/home/git/fado/:/var/www/localhost/htdocs" alpine:latest /bin/busybox sh
# cd /var/www/localhost/htdocs/docker
# busybox sh deploy-alpine.sh

echo "nameserver 8.8.4.4" > /etc/resolv.conf
export XDG_RUNTIME_DIR=/run/$(id -u)
mkdir -p /run/openrc
touch /run/openrc/softlevel
mkdir -p "$XDG_RUNTIME_DIR/openrc/"
touch /run/openrc/softlevel
touch "$XDG_RUNTIME_DIR/openrc/softlevel"
mkdir -p "$XDG_RUNTIME_DIR/0/openrc"
touch "$XDG_RUNTIME_DIR/0/openrc/softlevel"
adduser -D apache
adduser -D memcached
adduser -D mariadb
adduser -D mysql
adduser -D fcgiwrap
adduser -D rngd
adduser -D messagebus

cwd=$(dirname "$PWD")

if [ -f /var/www/isdeployed ]; then
mount -t  devtmpfs devtmpfs /dev
mount -t  devtmpfs devtmpfs /dev/shm
mv /var/lib/mysql/aria_log_control /var/lib/mysql/aria_log_control.orig 
/etc/init.d/networking -U restart
/etc/init.d/rngd -U restart
/etc/init.d/fcgiwrap -U restart
/etc/init.d/spawn-fcgi-U restart
/etc/init.d/apache2 -U restart
/etc/init.d/php-fpm85 -U restart
/etc/init.d/memcached -U restart
rc-status
tail -f /var/log/apache2/access.log
exit 0

fi

echo "Download & install packages"

apk add openrc apache2 php php-fpm php-intl php-pdo_mysql php-mbstring php-cli mariadb php-memcache memcached musl-locales icu-data-full mariadb-common mariadb-openrc mariadb-connector-c mariadb-client mariadb-server-utils apache2-ssl apache2-proxy apache2-openrc apache-mod-fcgid php85-apache2 php85-sysvshm php85-sysvmsg php85-sysvsem apache2-utils fcgi fcgiwrap fcgiwrap-openrc spawn-fcgi spawn-fcgi-openrc util-linux-openrc apache2-http2 udev-init-scripts-openrc akms openrc-init openrc-settingsd openrc-settingsd-openrc openrc-user openrc-user-pam dbus dbus-openrc dbus-libs dbus-glib dbus-daemon-launch-helper rng-tools rng-tools-openrc s6 s6-ipcserver s6-openrc s6-rc s6-networking s6-linux-utils s6-overlay s6-portable-utils s6-dns s6-static s6-rc-static s6-overlay-helpers s6-overlay-syslogd util-linux-misc s6-ipcserver s6-openrc s6-rc s6-networking s6-linux-utils s6-overlay s6-portable-utils s6-dns s6-static s6-rc-static s6-overlay-helpers s6-overlay-syslogd util-linux-misc iptables-openrc iptables alpine-conf net-tools haveged alsa-tools device-mapper ncurses openrc-settingsd alpine-conf sc-controller-udev eudev udev-init-scripts-openrc ncurses eudev-openrc eudev-netifnames openntpd linux-stable alpine-conf libnfnetlink mdevd abuild bc binutils build-base cmake gcc ncurses-dev ca-certificates wget

export KERNELVER=9.4.9
wget -nv -P /srv https://www.kernel.org/pub/linux/kernel/v4.x/linux-$KERNELVER.tar.gz
tar -C /srv -zxf /srv/linux-$KERNELVER.tar.gz
rm -f /srv/linux-$KERNELVER.tar.gz
cd /srv/linux-$KERNELVER
make defconfig
([ ! -f /proc/1/root/proc/config.gz ] || zcat /proc/1/root/proc/config.gz > .config) 
echo 'CONFIG_USB=m' >> .config
echo 'CONFIG_USB_HID=m' >> .config
echo 'CONFIG_USB_SUPPORT=y' >> .config
echo 'CONFIG_USB_COMMON=m' >> .config
echo 'CONFIG_USB_ARCH_HAS_HCD=y' >> .config
echo 'CONFIG_USB_DEFAULT_PERSIST=y' >> .config
echo 'CONFIG_USBIP_CORE=m' >> .config
echo 'CONFIG_USBIP_VHCI_HCD=m' >> .config
echo 'CONFIG_USBIP_VHCI_HC_PORTS=8' >> .config
echo 'CONFIG_USBIP_VHCI_NR_HCS=1' >> .config
echo 'CONFIG_USBIP_HOST=m' >> .config
echo 'CONFIG_DEVTMPFS=y' >> .config
echo 'CONFIG_DEVTMPFS_MOUNT=y' >> .config
sed -i '.bak' '/hcd->amd_resume_bug/{s/^/\/\//;n;s/^/\/\//}' ./drivers/usb/core/hcd-pci.c 
sed -u -e 's/YYLTYPE yylloc;/\/* YYLTYPE yylloc; *\//g' scripts/dtc/dtc-lexer.lex.c
make oldconfig -j $(nproc)
make modules_prepare -j $(nproc)
make modules -j $(nproc)
make modules_install -j $(nproc)

#sed -i -e 's/# skip_mount_dev="NO"/skip_mount_dev="YES"/g' /etc/conf.d/devfs
echo "/dev            /dev            devtmpfs noauto,nodev,rw 0 0" >> /etc/fstab
mount -t devtmpfs devtmpfs /dev
mount -t devtmpfs devtmpfs /dev/shm

unlink /lib/modules/15
ln -s /lib/modules/7.1.5-0-stable/ /lib/modules/15

#chown -Rvf apache:apache $cwd/*
#chmod -Rvf 770 $cwd/*

echo "Start & prepare MariaDB"

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

mkdir /run/mod_fcgid/
touch /run/mod_fcgid/fcgid.sock

rm /etc/apache2/conf.d/fado.conf

cat <<EOF >> /etc/apache2/conf.d/fado.conf
DirectoryIndex index.php index.html
LoadModule php_module modules/mod_php85.so
ServerName fado.org

FcgidIPCDir /run/mod_fcgid/fcgid.sock
FcgidProcessTableFile /run/mod_fcgid/shm
SharememPath /dev/shm

<VirtualHost _default_:2080>
        ServerAdmin admin@fado.org
        DocumentRoot /var/www/localhost/htdocs
        ServerName fado.org

        <FilesMatch "\.php$">
            SetHandler application/x-httpd-php
            SetHandler "proxy:fcgi://127.0.0.1:9000"
            Allow from all
            FcgidWrapper "/usr/bin/fcgiwrap" .php
         </FilesMatch>
         <FilesMatch "\.phtml$">
            SetHandler application/x-httpd-php
            SetHandler "proxy:fcgi://127.0.0.1:9000"
            Allow from all
            FcgidWrapper "/usr/bin/fcgiwrap" .phtml
        </FilesMatch>

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

        <FilesMatch "\.php$">
            SetHandler "proxy:fcgi://127.0.0.1:9000"
            Allow from all
            FcgidWrapper "/usr/bin/fcgiwrap" .php
         </FilesMatch>
         <FilesMatch "\.phtml$">
            SetHandler "proxy:fcgi://127.0.0.1:9000"
            Allow from all
            FcgidWrapper "/usr/bin/fcgiwrap" .phtml
        </FilesMatch>

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
#rm /etc/apache2/conf.d/http2.conf

/etc/init.d/firstart -U restart
/etc/init.d/modules -U restart
/etc/init.d/networking -U restart
/etc/init.d/rngd -U restart
/etc/init.d/fcgiwrap -U restart
/etc/init.d/spawn-fcgi-U restart
/etc/init.d/apache2 -U restart
/etc/init.d/php-fpm85 -U restart
/etc/init.d/memcached -U restart

rc-status

touch /var/www/isdeployed
echo "true" > /var/www/isdeployed
tail -f /var/log/apache2/access.log
exit 0
