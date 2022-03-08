FROM php:7.4-apache-bullseye

LABEL maintainer="Richard Ting"

ARG NODE_VERSION=14

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y git zlib1g-dev curl libxml2-dev libpng-dev libssl-dev libzip-dev zip unzip \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install zip bcmath sockets pdo_mysql gd opcache

COPY conf/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN groupadd --gid 1000 laravel && \
    useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home laravel && \
    usermod -a -G www-data laravel

USER laravel