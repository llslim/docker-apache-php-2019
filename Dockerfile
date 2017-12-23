# this dockerfile is a modified version of the official drupal dockerfile
# https://github.com/docker-library/drupal/blob/cdbfea0a45633dbdbec997334cb902405445a49c/8.4/apache/Dockerfile

FROM php:7.1-apache
MAINTAINER Kevin Williams (@llslim) <info@llslim.com>
RUN a2enmod rewrite

# install PHP extensions
RUN set -ex \
	&& buildDeps=' \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libpq-dev \
		libxml2-dev \
	'  \
	&&  supportServices='msmtp msmtp-mta' \
	&& apt-get update && apt-get install -y --no-install-recommends $buildDeps $supportServices \
	&& rm -rf /var/lib/apt/lists/*

	RUN docker-php-ext-configure gd \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	&& docker-php-ext-install -j "$(nproc)" gd mbstring opcache pdo pdo_mysql pdo_pgsql zip bcmath soap

	RUN pecl config-set php_ini /usr/local/etc/php/conf.d/xdebug.ini \
	&& pecl install xdebug \
	&& apt-mark manual \
		libjpeg62-turbo \
		libpq5 \
	&& apt-get purge -y --auto-remove $buildDeps

COPY drupal-*.ini /usr/local/etc/php/conf.d/

COPY msmtprc /etc/msmtprc

WORKDIR /var/www/html/
