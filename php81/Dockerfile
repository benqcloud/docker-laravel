FROM php:8.1-apache-bullseye

LABEL maintainer="Richard Ting"

ARG MONGODB_DRIVER_VERSION=1.12.1
ARG NODE_VERSION=16

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends git zlib1g-dev curl libxml2-dev libpng-dev libssl-dev libzip-dev zip unzip \
    # Laravel required extensions (ctype curl fileinfo json dom mbstring tokenizer xml extensions are already loaded)
    && docker-php-ext-install bcmath pdo_mysql \
    # BenQ app required extensions
    && docker-php-ext-install gd intl opcache sockets zip \
    # LDAP extension
    && apt-get install -y --no-install-recommends libldap2-dev \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    # MongoDB extension
    && pecl install "mongodb-${MONGODB_DRIVER_VERSION}"\
    && docker-php-ext-enable mongodb \
    # Redis extension
    && pecl install redis \
    && docker-php-ext-enable redis \
    # Enable apache2 module: headers, rewrite
    && a2enmod headers && a2enmod rewrite \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY conf/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY laravel-env-loader /usr/local/bin/

CMD ["/bin/bash", "-c", "laravel-env-loader && apache2-foreground"]
