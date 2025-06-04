# Use the official PHP image with FPM
FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory
WORKDIR /var/www

# Copy composer files first for faster rebuilds
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --ignore-platform-reqs --no-scripts --no-autoloader

# Copy the rest of the application files
COPY . .

# Run optimized autoload
RUN composer dump-autoload --optimize

# Set Laravel permissions
RUN chown -R www-data:www-data \
    /var/www/storage \
    /var/www/bootstrap/cache

# Expose port for Laravel development server
EXPOSE 8080

# Start the Laravel app
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
