#!/bin/bash
#
# cd /var/www/html/docker
# ./compilephp.sh true true true true
#
# (x) debian:trixie
#

down=$1
extract=$2
pak=$3
op=$4

cd /var/www/
libsdir="$PWD/libs"

if [ "$down" = "" ]; then
   down="true"
   extract="true"
   pak="true"
   op="true"
fi

if [ "$pak" = "true" ]; then
   dpkg-statoverride --remove "/etc/redis/redis.conf"
   dpkg-statoverride --remove "/etc/ssl/private"
   dpkg-statoverride --remove "/usr/lib/dbus-1.0/dbus-daemon-launch-helper"
   dpkg-statoverride --remove "/usr/bin/crontab"
   echo "nameserver 8.8.4.4" > /etc/resolv.conf
   apt-get update && apt-get upgrade -y
   apt-get install -y git patch make autoconf libtool binutils bison re2c wget tar gcc cpp clang cpp-for-build linux-libc-dev-arm64-cross llvm  mold lld binutils-dev pkgconf python3-icu libpsl-dev libselinux-dev libsystemd-dev libacl1-dev python3-pylibacl libevent-dev libnpth0-dev python3-libxml2 locales cmake libapr1-dev libaprutil1-dev libpcre2-dev libpcre2-32-0 pcre2-utils python3-pcre2 libpcre2-posix3 devscripts dh-exec dh-package-notes cracklib-runtime default-jdk flex gdb libaio-dev libboost-atomic-dev libboost-chrono-dev libboost-date-time-dev libboost-dev libboost-filesystem-dev libboost-regex-dev libboost-thread-dev libbz2-dev libcrack2-dev libedit-dev libedit-dev libfmt-dev libjemalloc-dev libjudy-dev libkrb5-dev liblz4-dev liblzo2-dev libnuma-dev libpam0g-dev libsnappy-dev libssl-dev liburing-dev libzstd-dev unixodbc-dev bison liblzma-dev libsystemd-dev libsctp-dev python3 gawk lsb-release gnupg libpng-dev libzmq5-dev libgcrypt20-dev libhiredis-dev libmaxminddb-dev libjson-c-dev libncurses-dev ccache libpcap-dev libidn2-dev libgtest-dev librrd-dev libcrypto++-dev libpthreadpool-dev libjson-c-dev libpthread-stubs0-dev libxml2-dev libsqlite3-dev libssl-dev libpcap-dev libcurl4-openssl-dev libicu-dev libxml2-dev libonig-dev libz-dev
   locale-gen es_ES
   localedef -f UTF-8 -i es_ES es_ES.utf8
fi

export LC_ALL=es_ES.utf8
update-locale
locale -a

if [ "$down" = "true" ]; then
   rm -r "$libsdir"
   mkdir -p "$libsdir"
   cd "$libsdir"
   wget -O "$libsdir/php.tar.gz" https://www.php.net/distributions/php-8.5.12.tar.gz
   wget -O "$libsdir/zlib.tar.gz" https://zlib.net/current/zlib.tar.gz
   wget -O "$libsdir/oniguruma.tar.gz" https://github.com/kkos/oniguruma/releases/download/v6.9.10/onig-6.9.10.tar.gz
   wget -O "$libsdir/icu.tgz" https://github.com/unicode-org/icu/releases/download/release-78.2/icu4c-78.2-sources.tgz
   wget -O "$libsdir/libxml.tar.gz" https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.15.3/libxml2-v2.15.3.tar.gz
   wget -O "$libsdir/openssl.tar.gz" https://github.com/openssl/openssl/releases/download/openssl-4.0.0/openssl-4.0.0.tar.gz
   wget -O "$libsdir/gettext.tar.gz" https://ftp.gnu.org/pub/gnu/gettext/gettext-0.26.tar.gz
   wget -O "$libsdir/curl.tar.gz" https://curl.se/download/curl-8.20.0.tar.gz
   wget -O "$libsdir/sqlite.tar.gz" https://sqlite.org/2026/sqlite-autoconf-3540000.tar.gz
   wget -O "$libsdir/ntp.tar.gz" https://downloads.nwtime.org/ntp/ntp-4.2.8p18.tar.gz
   wget -O "$libsdir/httpd.tar.gz" https://archive.apache.org/dist/httpd/httpd-2.4.66.tar.gz
   wget -O "$libsdir/gnupth.tar.gz" ftp://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz
   wget -O "$libsdir/memc.tar.gz" https://memcached.org/files/memcached-1.6.40.tar.gz
   wget -O "$libsdir/libevent.tar.gz" https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
   wget -O "$libsdir/glibc.tar.gz" https://ftp.gnu.org/gnu/libc/glibc-2.43.tar.gz

#   git clone https://github.com/MariaDB/server.git
   git clone https://github.com/ntop/ntopng.git
   cd ntopng
   git clone https://github.com/ntop/nDPI.git
fi

if [ "$extract" = "true" ]; then
   cd "$libsdir"
   tar xfzv "zlib.tar.gz"
   tar xfzv "oniguruma.tar.gz"
   tar xfv "icu.tgz"
   tar xfzv "libxml.tar.gz"
   tar xfzv "ntp.tar.gz"
   tar xfzv "gnupth.tar.gz"
   tar xfzv "curl.tar.gz"
   tar xfzv "sqlite.tar.gz"
   tar xfzv "gettext.tar.gz"
   tar xfzv "httpd.tar.gz"
   tar xfzv "memc.tar.gz"
   tar xfzv "libevent.tar.gz"
   tar xfzv "php.tar.gz"
   tar xfzv "openssl.tar.gz"
   tar xfzv "glibc.tar.gz"
fi

    export LIBSDIR="$PWD/libs"
    export ICU_CFLAGS="-I$LIBSDIR/icu/source/i18n -I$LIBSDIR/icu/source/common -I$LIBSDIR/icu/source/io -I$LIBSDIR/icu/source/layout -I$LIBSDIR/icu/source/data -I$LIBSDIR/icu/source/stubdata -I$LIBSDIR/icu/source/tools"
    export ICU_LIBS="-L$LIBSDIR/icu/source/stubdata -L$LIBSDIR/icu/source/common -L$LIBSDIR/icu/source/i18n -L$LIBSDIR/icu/source/io -L$LIBSDIR/icu/source/data -L$LIBSDIR/icu/source/layout -L$LIBSDIR/icu/source/tools"
    export LIBS="-lpthread -lxml2 -lsqlite3 -lpcap"


if [ "$op" = "true" ]; then

    cd "$libsdir"

    rm -rf  "glibc-build" && mkdir "glibc-build"

    cd "glibc-build"

    /bin/bash "$libsdir/glibc-2.43/configure" --target=aarch64 --prefix="/usr/include/glibc" --srcdir="$libsdir/glibc-2.43"

    make -j $(nproc)

    make install

    cd "$libsdir/openssl-4.0.0/"

    ./Configure linux-armv4 --prefix="/usr/bin"

    make -j $(nproc)

    make install

    cd "$libsdir/pth-2.0.7"

    ./configure --host=arm-linux-gnu \
                --build=arm --target=aarch64

    make -j $(nproc)

    make install

    cd "$libsdir/libevent-2.1.12-stable"

    cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 .

    cmake --build . --parallel $(nproc)

    cmake --install .

    cd "$libsdir/ntp-4.2.8p18"

    ./configure --with-crypto \
                --with-openssl-libdir="$libsdir/openssl-4.0.0" \
                --with-openssl-incdir="$libsdir/openssl-4.0.0/include" \
                --enable-local-libevent="$libsdir/libevent-release-2.1.12-stable" \
                --prefix="/usr/bin" \
                --host=aarch64-linux-gnu \
                --build=aarch64

    make -j $(nproc)

    make install

    cd "$libsdir/zlib-1.3.2/"

    cmake $PWD

    cmake --build $PWD --parallel $(nproc)

    cmake --install $PWD

    cd "$libsdir/libxml2-v2.15.3/"

    cmake $PWD

    cmake --build $PWD \
          --parallel $(nproc)

    cmake --install $PWD

    cd "$libsdir/icu/source/"

    ./configure --host=aarch64-linux-gnu

    make -j $(nproc)

    make install

    cd "$libsdir/gettext-0.26"

    ./configure --host=aarch64-linux-gnu

    make -j $(nproc)

    make install

    cd "$libsdir/curl-8.20.0/"

    ./configure --with-openssl \
                --host=aarch64-linux-gnu \
                --prefix="/usr/bin"

    make -j $(nproc)

    make install

    cd "$libsdir/ntopng/nDPI"

    ./autogen.sh

    ./configure

    make -j $(nproc)

    cd  "$libsdir/ntopng"

    ./autogen.sh

    ./configure --host=aarch64-linux-gnu --build=aarch64 --with-json-c-static --with-zmq-static --with-maxminddb-static

    make -j $(nproc)

    make install

    ln -s /usr/local/bin/ntopng /usr/local/bin/ntop

    cd "$libsdir/onig-6.9.10/"

    autoreconf -vfi

    ./configure --host=aarch64-linux-gnu

    make -j $(nproc)

    make install

    cd "$libsdir/sqlite-autoconf-3540000/"

    ./configure --host=aarch64-linux-gnu \
                --with-icu-ldflags="$ICU_LIBS" \
                --with-icu-cflags="$ICU_CFLAGS" \
                --icu-collations \
                --disable-math

    make -j $(nproc)

    make install

fi

#     cd "$libsdir/server/"

#     mkdir -p /usr/bin/mariadb/bin

#     git submodule update --init --recursive

#     cmake $PWD -DCMAKE_BUILD_TYPE=RelWithDebInfo \
#                -DWITH_EMBEDDED_SERVER=ON \
#                -DCMAKE_INSTALL_PREFIX=/usr/bin/mariadb \
#                -DPLUGIN_ROCKSDB=NO \
#                -DCURL_INCLUDE_DIR="$libsdir/curl-8.20.0/include" \
#                -DCURL_LIBRARY="$libsdir/curl-8.20.0/lib" \
#                -DLDFLAGS="-lcurl"

#     cmake --build $PWD --parallel $(nproc - 1)

#     cmake --install $PWD

     cd "$libsdir/memcached-1.6.40"

     ./configure --prefix="/usr/local/bin" \
            --enable-tls \
            --with-libevent="$libsdir/libevent-2.1.12-stable" \
            --prefix="/usr/bin" \
            --host=aarch64-linux-gnu \
            --target=aarch64

     make -j $(nproc)

     make install

     cd "$libsdir/httpd-2.4.66"

     make clean

     ./configure ap_cv_void_ptr_lt_long=no \
                 --prefix="/usr/bin" \
                 --enable-rewrite \
                 --enable-unixd \
                 --enable-rewrite \
                 --enable-curl \
                 --enable-proxy \
                 --enable-proxy-fcgi \
                 --enable-heartbeat \
                 --enable-heartbeatmonitor \
                 --host=aarch64-linux-gnu \
                 --target=aarch64 \
                 --with-curl="$libsdir/curl-8.20.0" \
                 --with-pcre="/usr/bin/pcre2-config"

     make -j $(nproc)

     make install

    env

    cd "$libsdir/php-8.5.12/"

    make clean

    ./buildconf -f

    ./configure --enable-fpm=shared \
            --with-fpm-user=www-data \
            --with-fpm-group=www-data \
            --with-fpm-systemd \
            --with-fpm-acl \
            --with-fpm-selinux \
            --with-pdo-mysql \
            --with-mysql-sock="/var/mysqld/mysqld.pid" \
            --with-libxml \
            --with-zlib \
            --enable-libgcc \
            --with-gnu-ld \
            --enable-calendar \
            --enable-intl \
            --enable-mbstring \
            --enable-cli \
            --enable-soap \
            --disable-cgi \
            --disable-debug \
            --disable-phpdbg-debug \
            --build=aarch64 \
            --target=aarch64 \
            --host=aarch64-linux-gnu \
            --prefix=/usr/bin

     make -j $(nproc)

     make install

php -v

php-fpm -v

httpd -v

memcached -v
exit 0
