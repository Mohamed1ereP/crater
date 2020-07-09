#!/bin/sh

docker-compose exec app composer install --no-interaction --prefer-dist --optimize-autoloader

docker-compose exec app php artisan key:generate --force
docker-compose exec app php artisan passport:keys --force
docker-compose exec app php artisan migrate --force
docker-compose exec app chmod 755 storage
