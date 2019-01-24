FROM mastappl/php-fpm:7.2-base

MAINTAINER d2cio <reg@d2c.io>

# Set ENVIROINMENTS
ENV OPENCART_VERSION 3.0.3.1

# Install extensions
RUN apt-get update && \
    apt-mark showmanual > /tmp/savedAptMark && \
    docker-php-source extract && \
    apt-get install -y libicu-dev libxml2-dev libxslt-dev libwebp-dev libfreetype6-dev libgif-dev libpng-dev libjpeg-dev libjpeg62-turbo-dev --no-install-recommends && \
    docker-php-ext-configure gd --with-webp-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr --with-freetype-dir=/usr && \
    docker-php-ext-install mysqli opcache soap gd zip && \
# Cleaner
    docker-php-source delete && \
    apt-mark auto '.*' > /dev/null && \
    [ -z "$(cat /tmp/savedAptMark)" ] || apt-mark manual $(cat /tmp/savedAptMark) && \
    find /usr/local -type f -name '*.so*' -exec ldd '{}' ';' | awk '/=>/ { print $(NF-1) }' | sort -u | \
    xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /tmp/* ~/.pearrc /var/lib/apt/lists/* && \
# Get opencart
    mkdir /var/www/opencart && \
    curl https://codeload.github.com/opencart/opencart/tar.gz/$OPENCART_VERSION | tar xz -C /var/www/opencart --strip-components=1 && \
    chown -R www-data:www-data /var/www/opencart && \
# Run Composer
    rm -rf /var/www/opencart/upload/system/storage/vendor && \
    su -l www-data -s /bin/bash -c "cd /var/www/opencart && composer install" && \
    tar -cJf /var/www/opencart_3.tar * && \
    rm -rf /var/www/opencart

COPY ./configs /var/www/configs
