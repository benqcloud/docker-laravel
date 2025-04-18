FROM php:7.1.33-cli-buster

LABEL maintainer="Richard Ting"

ARG MONGODB_DRIVER_VERSION=1.9.1
ARG REDIS_DRIVER_VERSION=5.3.7
ARG NODE_VERSION=12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends git zlib1g-dev curl libxml2-dev libpng-dev libssl-dev libzip-dev zip unzip \
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
    && pecl install "redis-${REDIS_DRIVER_VERSION}" \
    && docker-php-ext-enable redis \
    # Prepare php.ini
    && ln -sf /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG PHP_COMPOSER_VERSION=2

RUN curl -sS https://getcomposer.org/installer | php -- --$PHP_COMPOSER_VERSION --install-dir=/usr/bin/ --filename=composer \
    && curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
