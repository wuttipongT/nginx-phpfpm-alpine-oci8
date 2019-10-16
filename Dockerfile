FROM php:7.3-fpm-alpine

COPY installer /installer/
ENV ORACLE_HOME=/usr/local

RUN apk upgrade --update && apk --no-cache add \
    unzip autoconf tzdata openntpd file g++ gcc binutils isl libatomic libc-dev musl-dev make re2c libstdc++ libgcc libcurl curl-dev mpc1 mpfr3 gmp libgomp coreutils freetype-dev libjpeg-turbo-dev libltdl libmcrypt-dev libpng-dev openssl-dev libxml2-dev expat-dev libffi-dev unixodbc-dev freetds-dev libmcrypt-dev postgresql-dev sqlite-dev libzip-dev

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk --no-cache add --update libaio libnsl \
    && ln -nsf /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1

RUN unzip -o /installer/instantclient/*.zip -d ${ORACLE_HOME} \
    && unzip /installer/sdk/*.zip \
    && cd /installer/sdk \
    && cd $(find -name 'instantclient_*') \
    && cp -rf . ${ORACLE_HOME}/instantclient \
    && cd ${ORACLE_HOME}/instantclient \
    && ln -nsf $(find -name "libclntsh.so*") libclntsh.so \
    && ln -nsf $(find -name "libocci.so*") libocci.so \
    && ln -nsf ${ORACLE_HOME}/lib/stubs/libresolv.so.2 /usr/lib/libresolv.so.2 \
    && ln -nsf ${ORACLE_HOME}/lib/stubs/ld-linux-x86-64.so.2 /usr/lib/ld-linux-x86-64.so.2

RUN set -ex; \
    docker-php-source extract; \
    { \
        echo '# https://github.com/docker-library/php/issues/103#issuecomment-271413933'; \
        echo 'AC_DEFUN([PHP_ALWAYS_SHARED],[])dnl'; \
        echo; \
        cat /usr/src/php/ext/odbc/config.m4; \
    } > temp.m4; \
    mv temp.m4 /usr/src/php/ext/odbc/config.m4; \
    apk add --no-cache unixodbc-dev; \
    docker-php-ext-configure odbc --with-unixODBC=shared,/usr; \
    docker-php-ext-install odbc; \
    docker-php-source delete

RUN docker-php-ext-install -j$(nproc) bcmath curl fileinfo iconv json mbstring mysqli opcache pdo pdo_dblib pdo_mysql pdo_pgsql pdo_sqlite pgsql soap sockets xml zip \
    && echo 'instantclient,${ORACLE_HOME}/instantclient' | pecl install oci8 \
    && mkdir -p /etc/php7/conf.d \
    && echo "extension=oci8.so" >> /etc/php7/conf.d/oci8.ini \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,${ORACLE_HOME}/instantclient \
    && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install -j$(nproc) gd pdo_oci pdo_odbc\
    && docker-php-ext-enable oci8

# TimeZone
RUN cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime \
&& echo "Asia/Bangkok" >  /etc/timezone

# Install Composer && Assets Plugin
RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer \
&& composer global require --no-progress "fxp/composer-asset-plugin:~1.2" \
&& apk del tzdata unzip \
&& rm -rf /var/cache/apk/* /installer

EXPOSE 9000

CMD ["php-fpm"]