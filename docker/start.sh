#/bin/bash

if [ ! -f /var/www/isdeployed ]; then
    /bin/bash /var/www/html/docker/deploy-forky.sh
fi

service apache2 restart
service nginx restart
service mariadb restart
service php8.5-fpm restart
service php8.4-fpm restart
service memcached restart
service --status-all
tail -f /var/log/apache2/other_vhosts_access.log
tail -f /var/log/nginx/access.log
