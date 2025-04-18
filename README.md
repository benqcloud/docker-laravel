# [docker-laravel](https://github.com/benqcloud/docker-laravel)

[![php81-fpm](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-fpm-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-fpm-workflow.yml)

[![php71-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-apache-workflow.yml)
[![php74-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-apache-workflow.yml)
[![php81-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-apache-workflow.yml)
[![php83-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php83-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php83-apache-workflow.yml)

[![php71-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-cli-workflow.yml)
[![php74-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-cli-workflow.yml)
[![php81-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-cli-workflow.yml)
[![php83-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php83-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php83-cli-workflow.yml)

## Supported Architectures

| Architecture | Available
| :----: | :----: |
| x86-64 | ✅ |
| arm64 | ✅ |

## Feature Table

|     |  php-7.1-apache-dev | php-7.4-apache-dev | php-8.1-apache-dev | php-8.3-apache-dev |
| :-- | :------------: | :----------------: | :------------: | :----------------: |
| Build | 2024-11-28 | 2024-11-28 | 2025-04-18 | 2024-04-18 |
| Laravel | 5.8 / 5.7 / 5.6 / 5.5 | 8 / 7 / 6 | 10 / 9 | 12 / 11 |
| OS | buster-20191118 | bullseye-2022114 | bookworm-20250407 | bookworm-20250407 |
| Apache | v2.4.38 | v2.4.54 | v2.4.62 | v2.4.62 |
| php | v7.1.33 | v7.3.44 | v8.1.32 | v8.3.20 |
| php xdebug | v2.9.8 | v3.1.6 | v3.4.2 | v3.4.2 |
| php composer | v2.2.24 | v2.8.3 | v2.8.8 | v2.8.8 |
| node | v12.22.12 | v14.21.3 | v20.19.0 | v20.19.0 |
| npm | v6.14.16 | v6.14.18 | v10.8.2 | v10.8.2 |
| yarm | v1.22.22 | v1.22.22 | v1.22.22 | v1.22.22 |

## Usage

### docker-compose (recommended)

- Download laravel project (Different laravel version may need different docker image, please check it too)

```docker-compose
version: '3.9'

services:
    laravel:
        image: ghcr.io/benqcloud/docker-laravel:php-8.1-apache
        volumes:
            - ${PWD}:/var/www/html
        working_dir: /var/www/html
        command: bash -c "groupmod -g $GID www-data &&
            usermod -u $UID -g $GID www-data &&
            apache2-foreground"
        depends_on:
            - mysql80
        labels:
            - "traefik.enable=true"
            - "traefik.http.routers.laravel.rule=Host(`laravel.benq.test`)"
            - "traefik.http.services.laravel.loadbalancer.server.port=80"
            - "traefik.http.routers.laravel.entrypoints=websecure"
            - "traefik.http.routers.laravel.tls.certresolver=myresolver"
        network_node: bridge

    php-composer:
        image: ghcr.io/benqcloud/composer:php-8.1
        user: 1000:1000 # optional
        volumes:
            - ${PWD}:/var/www/html
        working_dir: /var/www/html
        command: bash -c "composer install --optimize-autoloader --no-dev --ignore-platform-reqs"
        network_node: bridge

    mysql80:
        image: mysql:8.0
        volumes:
            - mysql-data:/var/lib/mysql
        environment:
            - MYSQL_ROOT_PASSWORD=example
        network_node: bridge

    adminer:
        image: adminer:latest
        restart: always
        environment:
            ADMINER_DESIGN: nette
            ADMINER_PLUGINS: dump-json slugify
        labels:
            - "traefik.enable=true"
            - "traefik.http.routers.adminer.rule=Host(`adminer.benq.test`)"
            - "traefik.http.services.adminer.loadbalancer.server.port=8080"
            - "traefik.http.routers.adminer.entrypoints=websecure"
            - "traefik.http.routers.adminer.tls.certresolver=myresolver"
        network_node: bridge

    traefik:
        image: traefik:latest
        command:
            - "--api.insecure=true"
            - "--providers.docker"
            - "--providers.docker.network=benq"
            - "--entryPoints.web.address=:80"
            - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
            - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
            - "--entrypoints.websecure.address=:443"
            - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
            - "--certificatesresolvers.myresolver.acme.email=postmaster@example.com"
            - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
        ports:
            - "80:80"
            - "443:443"
            - "8080:8080"
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock:ro
        network_node: bridge

volumes:
    mysql-data:

```

### docker-cli

- Case 1: Local development

```bash
docker run --rm \
    -v $(pwd):/var/www/html \
    -w /var/www/html \
    -p 80:80 \
    --detach \
    ghcr.io/benqcloud/docker-laravel:php-8.1-apache \
    bash -c "groupmod -g $GID www-data && \
    usermod -u $UID -g $GID www-data && \
    apache2-foreground"
```

- Case 2: Unit test

```bash
docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e HOME=/var/www/html \
    -v $(pwd):/var/www/html \
    -w /var/www/html \
    ghcr.io/benqcloud/docker-laravel:php-8.1-cli \
    bash -c "composer install && php vendor/bin/phpunit"
```

### Dockerfile

```dockerfile
### builder stage
FROM ghcr.io/benqcloud/composer:php-8.1 AS composer-builder

WORKDIR /usr/src/app

COPY . /usr/src/app
RUN composer install --optimize-autoloader --no-dev --ignore-platform-reqs

### runtime stage
FROM ghcr.io/benqcloud/docker-laravel:php-8.1-apache

WORKDIR /var/www/html

COPY --from=composer-builder --chown=www-data:www-data /usr/src/app /var/www/html
```
