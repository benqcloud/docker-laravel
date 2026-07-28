FROM php:8.1.34-apache-trixie

LABEL maintainer="Richard Ting"

ARG MONGODB_DRIVER_VERSION=1.21.5

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    # Manually update debian system packages duo to php:8.1 EOL
    && apt-get upgrade -y \
    # Install Laravel required packages
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
    # Download Amazon RDS & DocumentDB TLS certificate
    && curl -o /usr/local/share/ca-certificates/aws-ww-rds-global-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
    && curl -o /usr/local/share/ca-certificates/aws-cn-rds-global-bundle.pem https://rds-truststore.s3.cn-north-1.amazonaws.com.cn/global/global-bundle.pem \
    # Enable apache2 module: headers, rewrite
    && a2enmod headers && a2enmod rewrite \
    # Prepare php.ini
    && ln -sf /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get dist-clean

COPY conf/apache2/security-headers-hardened.conf /etc/apache2/conf-available/security-headers-hardened.conf.disabled
COPY conf/apache2/security-headers.conf /etc/apache2/conf-enabled/security-headers.conf
COPY conf/apache2/server-identification.conf /etc/apache2/conf-enabled/server-identification.conf
COPY conf/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY conf/php/conf.d/laravel.ini /usr/local/etc/php/conf.d/laravel.ini

COPY custom-entrypoint.sh /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

ENTRYPOINT ["custom-entrypoint.sh"]
