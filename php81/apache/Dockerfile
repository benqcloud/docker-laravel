FROM php:8.1.33-apache-bookworm

LABEL maintainer="Richard Ting"

ARG MONGODB_DRIVER_VERSION=1.21.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends git zlib1g-dev curl libxml2-dev libpng-dev libssl-dev libzip-dev zip unzip \
    # OpenJDK 17
    && apt-get install -y --no-install-recommends openjdk-17-jdk \
    # Laravel required extensions (ctype curl fileinfo json dom mbstring tokenizer xml extensions are already loaded)
    && docker-php-ext-install bcmath pdo_mysql \
    # BenQ app required extensions
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
    # Enable apache2 module: headers, rewrite
    && a2enmod headers && a2enmod rewrite \
    # Prepare php.ini
    && ln -sf /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY conf/apache2/security-headers.conf /etc/apache2/conf-enabled/security-headers.conf
COPY conf/apache2/server-identification.conf /etc/apache2/conf-enabled/server-identification.conf
COPY conf/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY conf/php/conf.d/laravel.ini /usr/local/etc/php/conf.d/laravel.ini
