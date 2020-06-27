FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ENV user=crater-user
ENV uid=1000

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
    libmagickwand-dev \
    nginx \
    ffmpeg \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install imagick \ 
    && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd intl soap opcache curl cli imap

RUN rm /etc/nginx/sites-enabled/default

COPY docker-compose/nginx/nginx.conf /etc/nginx/sites-enabled/app.conf
COPY docker-compose/supervisor/supervisor.conf /etc/supervisor/conf.d/start.conf

EXPOSE 80
EXPOSE 443
EXPOSE 9001

CMD ["/usr/bin/supervisord" ,"-n"]


# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user