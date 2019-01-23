FROM php:7.3-fpm-stretch

ARG USE_PORT_AS_VERSION=

ENV COMPOSER_NO_INTERACTION=1 \
	COMPOSER_ALLOW_SUPERUSER=1

RUN set -x && \
#
	apt update && \
	apt-get install -y --no-install-recommends git zip unzip curl vim-tiny net-tools procps less && \
	rm -rf /var/lib/apt/lists/* && \
#
	sed -i "s/^listen = \(.*\)$/;listen = \1/" /usr/local/etc/php-fpm.d/zz-docker.conf && \
	printf "user = www-data\ngroup = www-data\n" >> /usr/local/etc/php-fpm.d/zz-docker.conf && \
	{ \
		echo '[www]'; \
		echo 'listen = 0.0.0.0:90'`[ $USE_PORT_AS_VERSION ] && echo $(echo $PHP_VERSION | sed "s/^\([0-9]*\).\([0-9]*\)\([0-9.]*\)$/\1\2/") || echo 00`''; \
		echo; \
		echo 'pm = dynamic'; \
		echo 'pm.max_children = 5'; \
		echo 'pm.start_servers = 2'; \
		echo 'pm.min_spare_servers = 1'; \
		echo 'pm.max_spare_servers = 3'; \
		echo; \
	} | tee /usr/local/etc/php-fpm.d/www.conf && \
#
	rm -rf /var/www/html && \
	chown -R www-data:www-data /var/www && \
#
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www
