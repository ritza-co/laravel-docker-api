FROM composer:2.0 as build
COPY . /app/
RUN composer install --prefer-dist --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

FROM php:8.1-apache-buster as production
RUN echo "ServerName 0.0.0.0" >> /etc/apache2/apache2.conf

ENV APP_ENV=production
ENV APP_DEBUG=true

RUN docker-php-ext-configure opcache --enable-opcache 

COPY --from=build /app /var/www/html

RUN php artisan config:cache && \
    php artisan route:cache && \
    chmod 777 -R /var/www/html/storage/ && \
    chown -R www-data:www-data /var/www/
    
CMD ["php", "artisan", "serve", "--host=127.0.0.1"]