FROM local/php-fpm:7.3-base

RUN set -x && \
#
	apt update && \
	apt-mark showmanual > /tmp/savedAptMark && \
#
	docker-php-source extract && \
# bcmath
	docker-php-ext-install bcmath && \
# bz2
	apt-get install -y --no-install-recommends libbz2-dev && \
	docker-php-ext-install bz2 && \
# calendar
	docker-php-ext-install calendar && \
# exif
	docker-php-ext-install exif && \
# gd
	apt-get install -y --no-install-recommends libjpeg-dev libpng-dev libfreetype6-dev && \
	docker-php-ext-configure gd --with-jpeg-dir --with-png-dir --with-freetype-dir && \
	docker-php-ext-install gd && \
# gmp
	apt-get install -y --no-install-recommends libgmp-dev && \
	docker-php-ext-install gmp && \
# imap
	apt-get install -y --no-install-recommends libc-client-dev libkrb5-dev && \
	docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
	docker-php-ext-install imap && \
# intl
	apt-get install -y --no-install-recommends libicu-dev && \
	docker-php-ext-install intl && \
# ldap
	apt-get install -y --no-install-recommends libldap2-dev && \
	docker-php-ext-install ldap && \
# mysqli
	docker-php-ext-install mysqli && \
# opcache
	docker-php-ext-install opcache && \
# pcntl
	docker-php-ext-install pcntl && \
# pdo_mysql
	docker-php-ext-install pdo_mysql && \
# pdo_pgsql
	apt-get install -y --no-install-recommends libpq-dev && \
	docker-php-ext-install pdo_pgsql && \
# pgsql
	docker-php-ext-install pgsql && \
# soap
	apt-get install -y --no-install-recommends libxml2-dev && \
	docker-php-ext-install soap && \
# sockets
	docker-php-ext-install sockets && \
# tidy
	apt-get install -y --no-install-recommends libtidy-dev && \
	docker-php-ext-install tidy && \
# xmlrpc
	docker-php-ext-install xmlrpc && \
# xsl
	apt-get install -y --no-install-recommends libxslt1-dev && \
	docker-php-ext-install xsl && \
# zip
	apt-get install -y --no-install-recommends zlib1g-dev libzip-dev && \
	docker-php-ext-install zip && \
# pecl: amqp
	apt-get install -y --no-install-recommends librabbitmq-dev && \
	pecl install -f amqp && \
	docker-php-ext-enable amqp && \
# pecl: memcached
	apt-get install -y --no-install-recommends libmemcached-dev && \
	pecl install -f memcached && \
	docker-php-ext-enable memcached && \
# pecl: xdebug
	pecl install -f xdebug-beta && \
	docker-php-ext-enable xdebug && \
# pecl: apcu
	pecl install -f apcu && \
	docker-php-ext-enable apcu && \
# pecl: ast
	pecl install -f ast && \
	docker-php-ext-enable ast && \
# pecl: event
	pecl install -f ds && \
	apt-get install -y --no-install-recommends libevent-dev && \
	pecl install -f event && \
	docker-php-ext-enable event && \
# pecl: geoip
	apt-get install -y --no-install-recommends libgeoip-dev && \
	pecl install -f geoip-beta && \
	docker-php-ext-enable geoip && \
# pecl: grpc
	pecl install -f grpc && \
	docker-php-ext-enable grpc && \
# pecl: igbinary
	pecl install -f igbinary && \
	docker-php-ext-enable igbinary && \
# pecl: imagick
	apt-get install -y --no-install-recommends libmagick++-dev && \
	pecl install -f imagick && \
	docker-php-ext-enable imagick && \
# pecl: mongodb
	pecl install -f mongodb && \
	docker-php-ext-enable mongodb && \
# pecl: oauth
	pecl install -f oauth && \
	docker-php-ext-enable oauth && \
# pecl: rdkafka
	apt-get install -y --no-install-recommends librdkafka-dev && \
	pecl install -f rdkafka && \
	docker-php-ext-enable rdkafka && \
# pecl: redis
	pecl install -f redis && \
	docker-php-ext-enable redis && \
# pecl: uuid
	apt-get install -y --no-install-recommends uuid-dev && \
	pecl install -f uuid && \
	docker-php-ext-enable uuid && \
# pecl: yaml
	apt-get install -y --no-install-recommends libyaml-dev && \
	pecl install -f yaml && \
	docker-php-ext-enable yaml && \
#
	docker-php-source delete && \
#
	apt-mark auto '.*' > /dev/null && \
	[ -z "$(cat /tmp/savedAptMark)" ] || apt-mark manual $(cat /tmp/savedAptMark) && \
	find /usr/local -type f -name '*.so*' -exec ldd '{}' ';' | awk '/=>/ { print $(NF-1) }' | sort -u | \
		xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual && \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
	rm -rf /tmp/* ~/.pearrc /var/lib/apt/lists/*
