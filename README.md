# docker-laravel

![php71-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-workflow.yml/badge.svg)
![php74-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-workflow.yml/badge.svg)
![php81-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-workflow.yml/badge.svg)

![php71-dev-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php71-dev-workflow.yml/badge.svg)
![php74-dev-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php74-dev-workflow.yml/badge.svg)
![php81-dev-workflow](https://github.com/benqcloud/docker-laravel/actions/workflows/php81-dev-workflow.yml/badge.svg)

## Using `dev` image For Existing Applications

```bash
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v $(pwd):/var/www/html \
    -w /var/www/html \
    ghcr.io/benqcloud/docker-laravel:php81-dev \
    php artisan serve --host=0.0.0.0 --port=80
```

## Use `apache` image in Dockerfile

```dockerfile
FROM ghcr.io/benqcloud/docker-laravel:php81

WORKDIR /var/www/html

COPY --chown=www-data:www-data . /var/www/html
```