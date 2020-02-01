FROM php:7-apache
MAINTAINER Kevin Williams (@llslim) <info@llslim.com>

RUN set -eux; \
	if command -v a2enmod; then \
		a2enmod rewrite ssl; \
	fi; \
 buildDeps=' \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
		libzip-dev \
		libonig-dev \
	'; \
  supportServices=' \
				msmtp \
				msmtp-mta \
				gdb \
	'; \
	 apt-get update; \
	 apt-get install -y --no-install-recommends $supportServices; \
	 savedAptMark="$(apt-mark showmanual)"; \
	 apt-get install -y --no-install-recommends $buildDeps; \
	# build php extensions with development dependencies, and install them
	docker-php-ext-configure \
	  gd --with-jpeg \
		; \
	docker-php-ext-install -j "$(nproc)" gd mbstring opcache pdo pdo_mysql pdo_pgsql mysqli zip \
	; \
	 # install xdebug extension
	touch /tmp/xdebug.ini; \
	chmod 666 /tmp/xdebug.ini; \
	pecl channel-update pecl.php.net; \
	pecl config-set php_ini /usr/local/etc/php/conf.d/xdebug.ini; \
	pecl install xdebug; \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	 rm -rf /var/lib/apt/lists/*

#	 openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#	  -keyout /etc/ssl/private/ssl-cert-llslim.key -out /etc/ssl/certs/ssl-cert-llslim.pem \
#		 -subj "/C=US/ST=NC/L=Vien/O=Security/OU=Development/CN=localhost"


	 COPY drupal-* /usr/local/etc/php/conf.d/
	 COPY ./msmtprc /etc/msmtprc

	 EXPOSE 443
	 WORKDIR /var/www/html/
