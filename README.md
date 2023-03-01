# [docker-laravel](https://github.com/benqcloud/docker-laravel)

![php71-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-workflow.yml/badge.svg)
![php74-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-workflow.yml/badge.svg)
![php81-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-workflow.yml/badge.svg)

![php71-dev-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-dev-workflow.yml/badge.svg)
![php74-dev-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-dev-workflow.yml/badge.svg)
![php81-dev-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-dev-workflow.yml/badge.svg)

## Supported Architectures

| Architecture | Available
| :----: | :----: |
| x86-64 | ✅ |
| arm64 | ✅ |

## Usage

### docker-compose (recommended)

- Download laravel project (Different laravel version may need different docker image, please check it too)
- Host OS
    - Linux: should use correct `UID` & `GID` for `user` config
    - Windows: remove `user` config

```docker-compose
---
version: '3.9'

services:
    laravel:
        image: ghcr.io/benqcloud/docker-laravel:php81-dev
        user: 1000:1000 # optional
        volumes:
            - ${PWD}:/var/www/html
        working_dir: /var/www/html
        command: bash -c "composer install &&
            php artisan serve --host=0.0.0.0 --port=80"
        depends_on:
            - mysql80
        labels:
            - "traefik.enable=true"
            - "traefik.http.routers.laravel.rule=Host(`laravel.benq.localhost`)"
            - "traefik.http.services.laravel.loadbalancer.server.port=80"
            - "traefik.http.routers.laravel.entrypoints=websecure"
            - "traefik.http.routers.laravel.tls.certresolver=myresolver"
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
            - "traefik.http.routers.adminer.rule=Host(`adminer.benq.localhost`)"
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
    -u "$(id -u):$(id -g)" \
    -v $(pwd):/var/www/html \
    -w /var/www/html \
    -p 80:80
    ghcr.io/benqcloud/docker-laravel:php81-dev \
    php artisan serve --host=0.0.0.0 --port=80
```

### Dockerfile

```dockerfile
### builder stage
FROM ghcr.io/benqcloud/composer:php81 AS composer-builder

WORKDIR /usr/src/app

COPY . /usr/src/app
RUN composer install --optimize-autoloader --no-dev --ignore-platform-reqs

### runtime stage
FROM ghcr.io/benqcloud/docker-laravel:php81

WORKDIR /var/www/html

COPY --from=composer-builder --chown=www-data:www-data /usr/src/app /var/www/html
```