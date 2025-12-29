# [docker-laravel](https://github.com/benqcloud/docker-laravel)

[![php71-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-apache-workflow.yml)
[![php74-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-apache-workflow.yml)
[![php81-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-apache-workflow.yml)
[![php83-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php83-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php83-apache-workflow.yml)
[![php85-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php85-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php85-apache-workflow.yml)

[![php71-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-cli-workflow.yml)
[![php74-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-cli-workflow.yml)
[![php81-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-cli-workflow.yml)
[![php83-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php83-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php83-cli-workflow.yml)
[![php85-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php85-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php85-cli-workflow.yml)

## Supported Architectures

| Architecture | Available
| :----: | :----: |
| x86-64 | ✅ |
| arm64 | ✅ |

## Feature Table

|     |  php-7.1-apache-dev | php-7.4-apache-dev | php-8.1-apache-dev | php-8.3-apache-dev | php-8.5-apache-dev |
| :-- | :------------: | :----------------: | :------------: | :----------------: | :----------------: |
| Build | 2024-11-28 | 2024-11-28 | 2025-12-10 | 2025-12-10 | N/A |
| Laravel | 5.8 / 5.7 / 5.6 / 5.5 | 8 / 7 / 6 | 10 / 9 | 13 / 12 / 11 | 13 / 12 / 11 |
| OS | buster-20191118 | bullseye-2022114 | trixie-20251208 | trixie-20251208 | trixie-20251208 |
| Apache | v2.4.38 | v2.4.54 | v2.4.65 | v2.4.65 | v2.4.65 |
| php | v7.1.33 | v7.4.33 | v8.1.33 | v8.3.28 | v8.5.1 |
| php xdebug | v2.9.8 | v3.1.6 | v3.4.7 | v3.4.7 | | v3.4.7 |
| php composer | v2.2.24 | v2.8.3 | v2.9.2 | v2.9.2 | | v2.9.2 |
| php mongodb | v1.9.1 | v1.12.1 | v1.21.2 | v1.21.2 | | v2.1.4 |
| node | v12.22.12 | v14.21.3 | v20.19.6 | v20.19.6 | | v24.12.0 |
| npm | v6.14.16 | v6.14.18 | v10.8.2 | v11.6.2 |
| yarn | v1.22.22 | v1.22.22 | v1.22.22 | v1.22.22 |

## Usage

### docker-compose (recommended)

- Download laravel project (Different laravel version may need different docker image, please check it too)

```docker-compose
services:
    laravel:
        image: ghcr.io/benqcloud/docker-laravel:php-8.1-apache-dev
        volumes:
            - ${PWD}:/var/www/html
        working_dir: /var/www/html
        command:
            - /bin/bash
            - -c
            - |
              groupmod -g $GID www-data
              usermod -u $UID -g $GID www-data
              composer install --optimize-autoloader --no-dev
              apache2-foreground"
        depends_on:
            - mysql80
        labels:
            - "traefik.enable=true"
            - "traefik.http.routers.laravel.rule=Host(`laravel.traefik.me`)"
            - "traefik.http.services.laravel.loadbalancer.server.port=80"
            - "traefik.http.routers.laravel.entrypoints=websecure"
            - "traefik.http.routers.laravel.tls.certresolver=myresolver"
        networks:
            - example

    mysql80:
        image: mysql:8.0
        volumes:
            - mysql-data:/var/lib/mysql
        environment:
            - MYSQL_ROOT_PASSWORD=example
        networks:
            - laravel

    adminer:
        image: adminer:latest
        restart: always
        environment:
            ADMINER_DESIGN: nette
            ADMINER_PLUGINS: dump-json slugify
        labels:
            - "traefik.enable=true"
            - "traefik.http.routers.adminer.rule=Host(`adminer.traefik.me`)"
            - "traefik.http.services.adminer.loadbalancer.server.port=8080"
            - "traefik.http.routers.adminer.entrypoints=websecure"
            - "traefik.http.routers.adminer.tls.certresolver=myresolver"
        networks:
            - laravel

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
        networks:
            - laravel

volumes:
    mysql-data:

networks:
    laravel:
        name: laravel
        ipam:
            driver: default
            config:
                - subnet: 192.168.0.0/24
                  gateway: 192.168.0.254
```

### docker-cli

- Case 1: Local development

```bash
docker run --rm \
    -v $(pwd):/var/www/html \
    -w /var/www/html \
    -p 80:80 \
    --detach \
    ghcr.io/benqcloud/docker-laravel:php-8.1-apache-dev \
    bash -c "groupmod -g $GID www-data && \
    usermod -u $UID -g $GID www-data && \
    composer install --optimize-autoloader --no-dev && \
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
