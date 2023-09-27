# [docker-laravel](https://github.com/benqcloud/docker-laravel)

[![php81-fpm](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-fpm-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-fpm-workflow.yml)

[![php71-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-apache-workflow.yml)
[![php74-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-apache-workflow.yml)
[![php81-apache](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-apache-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-apache-workflow.yml)

[![php71-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-cli-workflow.yml)
[![php74-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-cli-workflow.yml)
[![php81-cli](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-cli-workflow.yml/badge.svg)](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-cli-workflow.yml)

## Supported Architectures

| Architecture | Available
| :----: | :----: |
| x86-64 | ✅ |
| arm64 | ✅ |

## Usage

### docker-compose (recommended)

- Download laravel project (Different laravel version may need different docker image, please check it too)

```docker-compose
---
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
        networks:
            - benq

    php-composer:
        image: ghcr.io/benqcloud/composer:php-8.1
        user: 1000:1000 # optional
        volumes:
            - ${PWD}:/var/www/html
        working_dir: /var/www/html
        command: bash -c "composer install --optimize-autoloader --no-dev --ignore-platform-reqs"
        networks:
            - benq

    mysql80:
        image: mysql:latest
        volumes:
            - mysql-data:/var/lib/mysql
        environment:
            - MYSQL_ROOT_PASSWORD=example
        networks:
            - benq

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
        networks:
            - benq

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
            - benq

volumes:
    mysql-data:

networks:
    benq:
        driver: bridge
```

### docker-cli

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
