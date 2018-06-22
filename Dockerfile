FROM php:7.2-apache
MAINTAINER Kevin Williams (@llslim) <info@llslim.com>

RUN set -ex \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
 buildDeps=' \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
	'; \
  supportServices=' \
				msmtp \
				msmtp-mta \
	'; \
	 apt-get update; \
	 apt-get install -y --no-install-recommends $buildDeps $supportServices; \
	 \
	# build php extensions with development dependencies, and install them
	docker-php-ext-configure gd \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr ; \
	docker-php-ext-install -j "$(nproc)" gd mbstring opcache pdo pdo_mysql pdo_pgsql zip; \
	 # install xdebug extension
	touch /usr/local/etc/php/conf.d/xdebug.ini; \
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

	 COPY drupal-* /usr/local/etc/php/conf.d/
	 WORKDIR /var/www/html/
