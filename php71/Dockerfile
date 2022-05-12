FROM php:7.1-apache-buster

LABEL maintainer="Richard Ting"

ARG MONGODB_DRIVER_VERSION=1.9.1
ARG NODE_VERSION=12

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y git zlib1g-dev curl libxml2-dev libpng-dev libssl-dev libzip-dev zip unzip \
    && pecl install "mongodb-${MONGODB_DRIVER_VERSION}"\
    && docker-php-ext-enable mongodb \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-install zip bcmath sockets pdo_mysql gd opcache \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY conf/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
