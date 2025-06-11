FROM php:8.1-fpm

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
    libmagickwand-dev \
    mariadb-client

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Imagick extension
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Declare build arguments
ARG user=myuser
ARG uid=1000

# Set environment variables
ENV USER=$user
ENV UID=$uid

# Create system user
RUN useradd -G www-data,root -u $UID -d /home/$USER $USER && \
    mkdir -p /home/$USER/.composer && \
    chown -R $USER:$USER /home/$USER

# Set working directory
WORKDIR /var/www

# Copy Laravel project files
COPY . /var/www

# Optional: Fix permissions
RUN chown -R $USER:$USER /var/www

# Switch to non-root user
USER $USER

# Expose Laravel port
EXPOSE 8000

# Run Laravel app
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
