FROM benqcloud/docker-laravel:php-8.1-apache

ARG NODE_MAJOR=20
ARG PHP_COMPOSER_VERSION=2

RUN apt-get update \
    # xdebug extension
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    # Install composer v2
    && curl -sS https://getcomposer.org/installer | php -- --$PHP_COMPOSER_VERSION --install-dir=/usr/bin/ --filename=composer \
    # Install Node.js 20
    && apt-get install -y gnupg \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
