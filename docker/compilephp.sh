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
   apt-get install -y git patch make autoconf libtool binutils bison re2c wget tar gcc cpp clang g++-arm-linux-gnueabi gcc-arm-linux-gnueabi cpp-arm-linux-gnueabi cpp-for-build linux-libc-dev-arm64-cross llvm pkgconf python3-icu libpsl-dev libtestsweeper1 libselinux-dev libsystemd-dev libacl1-dev python3-pylibacl libevent-dev libnpth0-dev python3-libxml2 locales cmake libapr1-dev libaprutil1-dev libpcre2-dev libpcre2-32-0 pcre2-utils python3-pcre2 libpcre2-posix3 devscripts dh-exec dh-package-notes cracklib-runtime default-jdk flex gdb libaio-dev libboost-atomic-dev libboost-chrono-dev libboost-date-time-dev libboost-dev libboost-filesystem-dev libboost-regex-dev libboost-thread-dev libbz2-dev libcrack2-dev libedit-dev libedit-dev libfmt-dev libjemalloc-dev libjudy-dev libkrb5-dev liblz4-dev liblzo2-dev libnuma-dev libpam0g-dev libsnappy-dev libssl-dev liburing-dev libzstd-dev unixodbc-dev bison liblzma-dev libsystemd-dev libsctp-dev python3 gawk lsb-release gnupg libpng-dev libzmq5-dev libgcrypt20-dev libhiredis-dev libmaxminddb-dev libjson-c-dev mariadb-server libncurses-dev ccache libpcap-dev libidn2-dev  libgtest-dev librrd-dev libcrypto++-dev libpthreadpool-dev libjson-c-dev libpthread-stubs0-dev
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
   wget -O "$libsdir/php.tar.gz" https://www.php.net/distributions/php-8.5.8.tar.gz
   wget -O "$libsdir/zlib.tar.gz" https://zlib.net/current/zlib.tar.gz
   wget -O "$libsdir/oniguruma.tar.gz" https://github.com/kkos/oniguruma/releases/download/v6.9.10/onig-6.9.10.tar.gz
   wget -O "$libsdir/icu.tgz" https://github.com/unicode-org/icu/releases/download/release-78.2/icu4c-78.2-sources.tgz
   wget -O "$libsdir/libxml.tar.gz" https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.15.3/libxml2-v2.15.3.tar.gz
   wget -O "$libsdir/openssl.tar.gz" https://github.com/openssl/openssl/releases/download/openssl-4.0.0/openssl-4.0.0.tar.gz
   wget -O "$libsdir/gettext.tar.gz" https://ftp.gnu.org/pub/gnu/gettext/gettext-0.26.tar.gz
   wget -O "$libsdir/curl.tar.gz" https://curl.se/download/curl-8.20.0.tar.gz
   wget -O "$libsdir/sqlite.tar.gz" https://sqlite.org/2025/sqlite-autoconf-3510100.tar.gz
   wget -O "$libsdir/ntp.tar.gz" https://downloads.nwtime.org/ntp/ntp-4.2.8p18.tar.gz
   wget -O "$libsdir/httpd.tar.gz" https://archive.apache.org/dist/httpd/httpd-2.4.66.tar.gz
   wget -O "$libsdir/gnupth.tar.gz" ftp://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz
   wget -O "$libsdir/memc.tar.gz" https://memcached.org/files/memcached-1.6.40.tar.gz
   wget -O "$libsdir/libevent.tar.gz" https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
   wget -O "$libsdir/glibc.tar.gz" https://ftp.gnu.org/gnu/libc/glibc-2.43.tar.gz

   git clone https://github.com/MariaDB/server.git
   git clone https://github.com/ntop/ntopng.git
   cd ntopng
   git clone https://github.com/ntop/nDPI.git
fi

if [ "$extract" = "true" ]; then
   cd "$libsdir"
   tar xvfz "zlib.tar.gz"
   tar xvfz "oniguruma.tar.gz"
   tar xvf "icu.tgz"
   tar xvfz "libxml.tar.gz"
   tar xvfz "ntp.tar.gz"
   tar xvfz "gnupth.tar.gz"
   tar xvfz "curl.tar.gz"
   tar xvfz "sqlite.tar.gz"
   tar xvfz "gettext.tar.gz"
   tar xvfz "httpd.tar.gz"
   tar xvfz "memc.tar.gz"
   tar xvfz "libevent.tar.gz"
   tar xvfz "php.tar.gz"
   tar xvfz "openssl.tar.gz"
   tar xvfz "glibc.tar.gz"
fi

    export LIBSDIR="$PWD/libs"
    export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/openssl-4.0.0/libcrypto.pc"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/include/libxml2"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/sqlite-autoconf-3510100/sqlite3.pc"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/zlib-1.3.2/zlib.pc"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/onig-6.9.10/src"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/icu/source/i18n"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/icu/source/common"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/icu/source/io"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/icu/source/stubdata"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/icu/source/layout"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/icu/source/tools"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/libevent-2.1.12-stable/include"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/curl-8.20.0/include"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/gettext-0.26"
#    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBSDIR/pth-2.0.7/include"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/include/glibc/lib/libc.so.6"
    export LIBXML_CFLAGS="-I/usr/include/libxml2"
    export LIBXML_LIBS="-L$LIBSDIR/libxml2-v2.15.3"
    export OPENSSL_CFLAGS="-I$LIBSDIR/openssl-4.0.0/include"
    export OPENSSL_LIBS="-L$LIBSDIR/openssl-4.0.0"
    export PHP_SQLITE_CFLAGS="-I$LIBSDIR/sqlite-autoconf-3510100/sqlite3.pc"
    export PHP_SQLITE_LIBS="-L$LIBSDIR/sqlite-autoconf-3510100"
    export ICU_CFLAGS="-I$LIBSDIR/icu/source/i18n -I$LIBSDIR/icu/source/common -I$LIBSDIR/icu/source/io -I$LIBSDIR/icu/source/layout -I$LIBSDIR/icu/source/data -I$LIBSDIR/icu/source/stubdata -I$LIBSDIR/icu/source/tools"
    export ICU_LIBS="-L$LIBSDIR/icu/source/stubdata -L$LIBSDIR/icu/source/common -L$LIBSDIR/icu/source/i18n -L$LIBSDIR/icu/source/io -L$LIBSDIR/icu/source/data -L$LIBSDIR/icu/source/layout -L$LIBSDIR/icu/source/tools"
    export ONIG_CFLAGS="-I$LIBSDIR/onig-6.9.10/src"
    export ONIG_LIBS="-L$LIBSDIR/onig-6.9.10/src"
    export ZLIB_CFLAGS="-I$LIBSDIR/zlib-1.3.2/include"
    export ZLIB_LIBS="-L$LIBSDIR/zlib-1.3.2/lib"
    export INTL_CFLAGS="-I$LIBSDIR/gettext-0.26/include"
    export INTL_LIBS="-L$LIBSDIR/gettext-0.26/lib"
    export CURL_CFLAGS="-I$LIBSDIR/curl-8.20.0/include"
    export CURL_LIBS="-L$LIBSDIR/curl-8.20.0/lib"
    export SQLITE_LIBS="-L$LIBSDIR/sqlite-autoconf-3510100"
    export SQLITE_CFLAGS="-I$LIBSDIR/sqlite-autoconf-3510100"
    export NTP_LIBS="-L$LIBSDIR/ntp-4.2.8p18/lib"
    export NTP_CFLAGS="-I$LIBSDIR/ntp-4.2.8p18/include"
#    export GNU_PTH="-L$LIBSDIR/pth-2.0.7"
#    export GNU_CFLAGS="-I$LIBSDIR/pth-2.0.7"
    export GLIBC_LIBS="-L/usr/include/glibc/lib/libc.so.6"
    export GLIBC_CFLAGS="-I/usr/include/glibc/include"
    export LIBS="$GLIBC_LIBS $GNU_PTH $LIBXML_LIBS $OPENSSL_LIBS $ICU_LIBS $ONIG_LIBS $ZLIB_LIBS $INTL_LIBS $CURL_LIBS $SQLITE_LIBS $NTP_LIBS"
    export LDFLAGS="--symbolic --pie -lc -lpthread -lstdc++ -lxml2 -lsqlite3 -lpcap $LIBS"
    export LD_LIBRARY_PATH="/lib:/usr/lib:/usr/include:/usr/local/lib:/usr/local/include:/usr/bin:/bin:/usr/local/bin:$PKG_CONFIG_PATH"
    export ALL_CFLAGS="$LIBXML_CFLAGS $OPENSSL_CFLAGS $GNU_CFLAGS $ICU_CFLAGS $ONIG_CFLAGS $ZLIB_CFLAGS $INTL_CFLAGS $CURL_CFLAGS $SQLITE_CFLAGS $NTP_CFLAGS $GLIBC_CFLAGS"
    export CFLAGS="-rdynamic -shared -fPIE -march=native -nostartfiles -std=c17 -std=gnu17 -pthread $ALL_CFLAGS"
    export CPPFLAGS=""
    export ICU_CFLAGS="-rdynamic -nostartfiles -shared -fPIE -std=c17 -std=gnu17 -pthread $ALL_CFLAGS"
    export ICU_CXXFLAGS=""
    export CXXFLAGS="-rdynamic -shared -fPIE -march=native -nostartfiles -std=c++17 -std=gnu++17 -pthread $ALL_CFLAGS"
    export PHP_INTL_STDCXX="-std=c++11"
    export PHP_INTL_CXX_FLAGS="$CXXFLAGS"
    export PATH="$PATH:$LD_LIBRARY_PATH"

#    export CC="/usr/bin/aarch64-linux-gnu-g++"
#    export CXX="/usr/bin/aarch64-linux-gnu-g++"
#    export CPP="/usr/bin/aarch64-linux-gnu-cpp"
#    export LD="/usr/bin/aarch64-linux-gnu-ld"

    env


if [ "$op" = "true" ]; then

    cd "$libsdir"

    rm -rf  "glibc-build" && mkdir "glibc-build"

    cd "glibc-build"

    /bin/bash "$libsdir/glibc-2.43/configure" --target=aarch64 --prefix="/usr/include/glibc" --srcdir="$libsdir/glibc-2.43"

    make -j $(nproc)

    make install

    cd "$libsdir/openssl-4.0.0/"

    ./Configure linux-aarch64 --prefix="/usr/bin"

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

    cd "$libsdir/sqlite-autoconf-3510100"

    ./configure --host=aarch64-linux-gnu \
                --with-icu-ldflags="$ICU_LIBS" \
                --with-icu-cflags="$ICU_CFLAGS" \
                --icu-collations

    make -j $(nproc)

    make install

fi

    cd "$libsdir/php-8.5.8/"

    rm "$libsdir/php-8.5.8/conf.patch"

    cat <<EOF >> "$libsdir/php-8.5.8/conf.patch"
--- ext/intl/config.m4  2026-08-06 20:03:55.432399564 +0200
+++ ext/intl/config.m4  2026-08-06 19:40:33.312400567 +0200
@@ -90,10 +90,10 @@
   AC_MSG_CHECKING([if intl requires -std=gnu++17])
   AS_IF([$PKG_CONFIG icu-uc --atleast-version=74],[
     AC_MSG_RESULT([yes])
-    PHP_CXX_COMPILE_STDCXX([17], [mandatory], [PHP_INTL_STDCXX])
+#    PHP_CXX_COMPILE_STDCXX([17], [mandatory], [PHP_INTL_STDCXX])
   ],[
     AC_MSG_RESULT([no])
-    PHP_CXX_COMPILE_STDCXX([11], [mandatory], [PHP_INTL_STDCXX])
+#    PHP_CXX_COMPILE_STDCXX([11], [mandatory], [PHP_INTL_STDCXX])
   ])

   PHP_INTL_CXX_FLAGS="$INTL_COMMON_FLAGS $PHP_INTL_STDCXX $ICU_CXXFLAGS"
EOF

    patch -p0 < "$libsdir/php-8.5.8/conf.patch"

    make clean

    ./buildconf -f

    ./configure --enable-fpm=shared \
            --with-fpm-user=www-data \
            --with-fpm-group=www-data \
            --with-fpm-systemd \
            --with-fpm-acl \
            --with-fpm-selinux \
            --with-pdo-mysql=shared \
            --with-mysql-sock="/var/mysqld/mysqld.pid" \
            --with-libxml=shared \
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
            --host=aarch64-linux-gnu \
            --build=aarch64 \
            --prefix="/usr/bin"

     make -j $(nproc)

     make install

     cd "$libsdir/server/"

     git submodule update --init --recursive

     cmake $PWD -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_EMBEDDED_SERVER=ON -DCMAKE_INSTALL_PREFIX=/usr/bin/mariadb -DPLUGIN_ROCKSDB=NO

     cmake --build $PWD --parallel $(nproc)

     cmake --install $PWD

     cd "$libsdir/memcached-1.6.40"

     make clean

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

php -v

php-fpm -v

httpd -v

memcached -v

exit 0
