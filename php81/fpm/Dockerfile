FROM php:8.1.30-fpm-bookworm

LABEL maintainer="Richard Ting"

ARG MONGODB_DRIVER_VERSION=1.19.3

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends git zlib1g-dev curl libxml2-dev libpng-dev libssl-dev libzip-dev zip unzip \
    # OpenJDK 17
    && apt-get install -y --no-install-recommends openjdk-17-jdk \
    # Laravel required extensions (ctype curl fileinfo json dom mbstring tokenizer xml extensions are already loaded)
    && docker-php-ext-install bcmath pdo_mysql \
    # BenQ app required extensions
    && docker-php-ext-install gd intl opcache sockets zip pcntl \
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
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY conf/php/conf.d/laravel.ini /usr/local/etc/php/conf.d/laravel.ini
COPY conf/php-fpm.d/pid-docker.conf /usr/local/etc/php-fpm.d/pid-docker.conf
COPY nginx-php-fpm-foreground /usr/local/bin

EXPOSE 80

CMD ["nginx-php-fpm-foreground"]
