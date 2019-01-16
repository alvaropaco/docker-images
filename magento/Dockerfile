FROM mastappl/php-fpm:7.2-base

MAINTAINER d2cio <reg@d2c.io>

# Set envs
ENV MAGENTO_VERSION 2.3.0
ENV INSTALL_DIR /var/www/magento_2

# Install extensions
RUN apt-get update && \
    apt-get install -y libicu-dev libxml2-dev libxslt-dev libwebp-dev libfreetype6-dev libgif-dev libpng-dev libjpeg-dev libjpeg62-turbo-dev --no-install-recommends && \
    docker-php-ext-configure gd --with-webp-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr --with-freetype-dir=/usr && \
    docker-php-ext-install mysqli opcache intl soap bcmath pdo_mysql xsl gd zip

# Install Redis Pecl package
RUN docker-php-pecl-install redis

# Get magento
RUN mkdir $INSTALL_DIR && \
curl https://codeload.github.com/magento/magento2/tar.gz/$MAGENTO_VERSION -o $MAGENTO_VERSION.tar.gz && \
tar xf $MAGENTO_VERSION.tar.gz && \
mv magento2-$MAGENTO_VERSION/* $INSTALL_DIR && \
# Set www-data permissions
chown -R www-data:www-data /var/www

USER www-data

RUN cd $INSTALL_DIR && \
composer install && \
#composer config repositories.magento "composer https://repo.magento.com/" && \
find $INSTALL_DIR -type f -exec chmod 644 {} \; && \
find $INSTALL_DIR -type d -exec chmod 755 {} \; && \
find $INSTALL_DIR/var -type d -exec chmod 777 {} \; && \
find $INSTALL_DIR/pub/media -type d -exec chmod 777 {} \; && \
find $INSTALL_DIR/pub/static -type d -exec chmod 777 {} \; && \
chmod 777 $INSTALL_DIR/app/etc && \
chmod 644 $INSTALL_DIR/app/etc/*.xml

USER root

RUN rm -rf /var/www/html

WORKDIR $INSTALL_DIR
