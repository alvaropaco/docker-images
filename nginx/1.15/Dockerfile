ARG NGINX_VERSION=1.15.8-1~stretch
ARG NJS_VERSION=1.15.8.0.2.7-1~stretch
ARG NGX_PAGESPEED_VERSION=1.13.35.2
ARG NGX_CACHE_PURGE_VERSION=2.3
ARG OPENSSL_VERSION=1.1.1a

FROM debian:9.6-slim

ARG NGINX_VERSION
ARG NJS_VERSION
ARG NGX_PAGESPEED_VERSION
ARG NGX_CACHE_PURGE_VERSION
ARG OPENSSL_VERSION

ENV NGINX_VERSION=${NGINX_VERSION} \
	NJS_VERSION=${NJS_VERSION} \
	NGX_PAGESPEED_VERSION=${NGX_PAGESPEED_VERSION} \
	NGX_CACHE_PURGE_VERSION=${NGX_CACHE_PURGE_VERSION} \
	OPENSSL_VERSION=${OPENSSL_VERSION}

RUN set -x && \
#
	apt update && \
	apt-get install -y --no-install-recommends git curl && \
	apt-get install -y --no-install-recommends apt-transport-https ca-certificates && \
#
	apt-get install -y --no-install-recommends gnupg1 && \
	curl -s https://nginx.org/keys/nginx_signing.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true apt-key add && \
	NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
	( \
		(APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true apt-key list --with-colons | grep -q "${NGINX_GPGKEY}") || \
		(echo >&2 "Error: failed checking GPG key $NGINX_GPGKEY" && exit 1) \
	) && \
	rm -rf /var/lib/apt/lists/* && \
#
	echo "deb-src https://nginx.org/packages/mainline/debian/ stretch nginx" > /etc/apt/sources.list.d/nginx.list && \
	apt update && \
#
	NGINX_PACKAGES=" \
		nginx=${NGINX_VERSION} \
		nginx-module-xslt=${NGINX_VERSION} \
		nginx-module-geoip=${NGINX_VERSION} \
		nginx-module-image-filter=${NGINX_VERSION} \
		nginx-module-njs=${NJS_VERSION} \
	" && \
	apt-get build-dep -y ${NGINX_PACKAGES} && \
#
	cd /usr/src && \
	apt-get source ${NGINX_PACKAGES} && \
#
	NGINX_DIR=/usr/src/nginx-$(echo ${NGINX_VERSION} | sed 's/^\(.*\)-\([0-9]*\)\~stretch$/\1/') && \
	MODULES_DIR=${NGINX_DIR}/debian/modules && \
# ngx-pagespeed
	apt-get install -y --no-install-recommends uuid-dev && \
	MODULE_PAGESPEED_DIR=${MODULES_DIR}/ngx-pagespeed-${NGX_PAGESPEED_VERSION} && \
	mkdir -p ${MODULE_PAGESPEED_DIR} && \
	curl -sL https://codeload.github.com/apache/incubator-pagespeed-ngx/tar.gz/v${NGX_PAGESPEED_VERSION}-stable | \
		tar xz -C ${MODULE_PAGESPEED_DIR} --strip-components=1 && \
	curl -sL https://dl.google.com/dl/page-speed/psol/${NGX_PAGESPEED_VERSION}-x64.tar.gz | \
		tar xz -C ${MODULE_PAGESPEED_DIR} && \
	sed -i "/LDFLAGS /a WITH_NGX_PAGESPEED := --add-module=${MODULE_PAGESPEED_DIR}" ${NGINX_DIR}/debian/rules && \
	sed -i 's/^\s\+CFLAGS=.*$/& $(WITH_NGX_PAGESPEED)/g' ${NGINX_DIR}/debian/rules && \
# ngx-brotli
	MODULE_BROTLI_DIR=${MODULES_DIR}/ngx-brotli && \
	git clone https://github.com/google/ngx_brotli.git ${MODULE_BROTLI_DIR} && \
	cd ${MODULE_BROTLI_DIR} && \
	git submodule update --init && \
	cd - && \
	sed -i "/LDFLAGS /a WITH_NGX_BROTLI := --add-module=${MODULE_BROTLI_DIR}" ${NGINX_DIR}/debian/rules && \
	sed -i 's/^\s\+CFLAGS=.*$/& $(WITH_NGX_BROTLI)/g' ${NGINX_DIR}/debian/rules && \
# ngx-cache-purge
	MODULE_CACHE_PURGE_DIR=${MODULES_DIR}/ngx-cache-purge-${NGX_CACHE_PURGE_VERSION} && \
	mkdir -p ${MODULE_CACHE_PURGE_DIR} && \
	curl -sL https://codeload.github.com/FRiCKLE/ngx_cache_purge/tar.gz/${NGX_CACHE_PURGE_VERSION} | \
		tar xz -C ${MODULE_CACHE_PURGE_DIR} --strip-components=1 && \
	sed -i "/LDFLAGS /a WITH_NGX_CACHE_PURGE := --with-openssl=${MODULE_CACHE_PURGE_DIR} --with-openssl-opt=enable-tls1_3" ${NGINX_DIR}/debian/rules && \
	sed -i 's/^\s\+CFLAGS=.*$/& $(WITH_NGX_CACHE_PURGE)/g' ${NGINX_DIR}/debian/rules && \
# openssl
	OPENSSL_DIR=/usr/src/openssl-${OPENSSL_VERSION} && \
	mkdir -p ${OPENSSL_DIR} && \
	curl -sL https://codeload.github.com/openssl/openssl/tar.gz/OpenSSL_$(echo ${OPENSSL_VERSION} | tr '.' '_') | \
		tar xz -C ${OPENSSL_DIR} --strip-components=1 && \
	sed -i "/LDFLAGS /a WITH_OPENSSL := --with-openssl=${OPENSSL_DIR}" ${NGINX_DIR}/debian/rules && \
	sed -i 's/^\s\+CFLAGS=.*$/& $(WITH_OPENSSL)/g' ${NGINX_DIR}/debian/rules && \
	sed -i 's/CFLAGS="$CFLAGS -Werror"/# CFLAGS="$CFLAGS -Werror"/' ${NGINX_DIR}/auto/cc/gcc && \
# zlib
	ZLIB_DIR=/usr/src/zlib-cloudflare && \
	git clone https://github.com/cloudflare/zlib.git ${ZLIB_DIR} && \
	cd ${ZLIB_DIR} && \
	./configure && \
	cd - && \
	sed -i "/LDFLAGS /a WITH_ZLIB := --with-zlib=${ZLIB_DIR}" ${NGINX_DIR}/debian/rules && \
	sed -i 's/^\s\+CFLAGS=.*$/& $(WITH_ZLIB)/g' ${NGINX_DIR}/debian/rules && \
#
	DEB_BUILD_OPTIONS="nocheck parallel=$(nproc)" apt-get source --compile ${NGINX_PACKAGES} && \
#
	mkdir -p /usr/src/nginx-deb && \
	mv /usr/src/*.deb /usr/src/nginx-deb/ && \
	cd /usr/src/nginx-deb/ && \
	dpkg-scanpackages . > /usr/src/nginx-deb/Packages && \
	cd - && \
	echo "deb [ trusted=yes ] file:///usr/src/nginx-deb ./" > /etc/apt/sources.list.d/nginx.list && \
	apt-get -o Acquire::GzipIndexes=false update


FROM debian:9.6-slim

ARG NGINX_VERSION

ENV NGINX_VERSION=${NGINX_VERSION}

COPY --from=0 /usr/src/nginx-deb /usr/src/nginx-deb/
COPY --from=0 /var/lib/apt /var/lib/apt
COPY --from=0 /etc/apt/sources.list.d/nginx.list /etc/apt/sources.list.d/nginx.list

RUN set -x && \
#
	apt-get install -y --no-install-recommends git zip unzip curl ca-certificates vim-tiny net-tools procps less rclone tree && \
#
	apt-get install -y --no-install-recommends openssl certbot && \
#
	{ \
		echo '# quiet = true'; \
		echo 'staging = true'; \
		echo 'break-my-certs = true'; \
		echo 'non-interactive = true'; \
		echo 'agree-tos = true'; \
		echo 'authenticator = webroot'; \
		echo 'webroot-path = /var/www/letsencrypt'; \
	} | tee /etc/letsencrypt/cli.ini && \
	mkdir -p /var/www/letsencrypt && \
#
	apt-get install -y --no-install-recommends nginx nginx-module-* && \
#
	mkdir -p /etc/nginx/certificates && \
#
	rm -rf /tmp/* /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list /usr/src/* && \
#
	ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

STOPSIGNAL SIGTERM

ADD *.sh /
RUN set -x && \
	chmod +x /*.sh && \
	ln -s /docker-entrypoint.sh /usr/local/bin/cmd

ENTRYPOINT ["/docker-entrypoint.sh"]
