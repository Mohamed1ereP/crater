FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \ 
    libzip-dev \ 
    libmagickwand-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install imagick \ 
    && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd 

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user
RUN apk add --no-cache libpng-dev libxml2-dev oniguruma-dev libzip-dev gnu-libiconv && \
    docker-php-ext-install bcmath ctype json gd mbstring pdo pdo_mysql tokenizer xml zip

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Set container's working dir
WORKDIR /app
 
# Copy everything from project root into php container's working dir
COPY . /app

# Copy vendor folder from composer container into php container
COPY --from=composer /app/vendor /app/vendor

RUN chown -R www-data:www-data . && \
    chmod -R 755 . && \
    chmod -R 775 storage/framework/ && \
    chmod -R 775 storage/logs/ && \
    chmod -R 775 bootstrap/cache/  

EXPOSE 9000

CMD ["php-fpm", "--nodaemonize"]
