FROM hub.tich.us/tawazz/nginx-php7.3
COPY . /app
WORKDIR /app
RUN chown -R www-data:www-data .