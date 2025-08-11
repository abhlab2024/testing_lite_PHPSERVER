# Use the official PHP Apache image
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli

# Enable Apache mod_rewrite
RUN a2enmod rewrite

##############################################
# Set ServerName and permissions
##############################################
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Ensure Apache allows .htaccess overrides for specific directories
RUN echo '<Directory /var/www/html>' >> /etc/apache2/apache2.conf && \
    echo '    AllowOverride All' >> /etc/apache2/apache2.conf && \
    echo '</Directory>' >> /etc/apache2/apache2.conf

# Extended PHP configuration limits
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/custom.ini && \
    echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "max_input_time = 600" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "post_max_size = 128M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "upload_max_filesize = 128M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/custom.ini

# Set correct permissions for the web server user (after copying files)
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

##############################################
# COPY PHP application files from php_server to container
##############################################
COPY php_server/ /var/www/html/

# Set correct permissions for the web server user (after copying files)
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Expose the container port
EXPOSE 80
