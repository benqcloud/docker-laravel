FROM php:8.1.33-fpm-trixie

LABEL maintainer="Richard Ting"

ARG MONGODB_DRIVER_VERSION=1.21.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends git zlib1g-dev curl libxml2-dev libpng-dev libssl-dev libzip-dev zip unzip \
    # OpenJDK 21
    && apt-get install -y --no-install-recommends openjdk-21-jdk \
    # Laravel required extensions (ctype curl fileinfo json dom mbstring tokenizer xml extensions are already loaded)
    && docker-php-ext-install bcmath pdo_mysql \
    # BenQ app required extensions
    && apt-get install -y --no-install-recommends libicu-dev \
    && docker-php-ext-install intl opcache sockets zip pcntl \
    # BenQ app required extension - gd with JPEG support
    && apt-get install -y --no-install-recommends libjpeg-dev \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install gd \
    # LDAP extension
    && apt-get install -y --no-install-recommends libldap2-dev \
    && docker-php-ext-configure ldap --with-libdir=lib/$(uname -m)-linux-gnu/ \
    && docker-php-ext-install ldap \
    # APCu extension
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    # MongoDB extension
    && pecl install "mongodb-${MONGODB_DRIVER_VERSION}"\
    && docker-php-ext-enable mongodb \
    # Redis extension
    && pecl install redis \
    && docker-php-ext-enable redis \
    # Prepare php.ini
    && ln -sf /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    # Install nginx
    && apt-get install -y --no-install-recommends nginx \
    # forward nginx request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get dist-clean

COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY conf/nginx/conf.d/security-headers.conf /etc/nginx/conf.d/security-headers.conf
COPY conf/nginx/conf.d/server-identification.conf /etc/nginx/conf.d/server-identification.conf
COPY conf/php/conf.d/laravel.ini /usr/local/etc/php/conf.d/laravel.ini
COPY conf/php-fpm.d/pid-docker.conf /usr/local/etc/php-fpm.d/pid-docker.conf
COPY nginx-php-fpm-foreground /usr/local/bin

EXPOSE 80

CMD ["nginx-php-fpm-foreground"]
