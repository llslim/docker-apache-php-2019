# from https://www.drupal.org/requirements/php#drupalversions
FROM php:7-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN set -ex \
	&& buildDeps=' \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libpq-dev \
	' \
	&& apt-get update && apt-get install -y --no-install-recommends $buildDeps \
	&& docker-php-ext-configure gd \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	&& docker-php-ext-install -j "$(nproc)" gd mbstring pdo pdo_mysql pdo_pgsql zip \
# PHP Warning:  PHP Startup: Unable to load dynamic library '/usr/local/lib/php/extensions/no-debug-non-zts-20151012/gd.so' - libjpeg.so.62: cannot open shared object file: No such file or directory in Unknown on line 0
# PHP Warning:  PHP Startup: Unable to load dynamic library '/usr/local/lib/php/extensions/no-debug-non-zts-20151012/pdo_pgsql.so' - libpq.so.5: cannot open shared object file: No such file or directory in Unknown on line 0
	&& apt-mark manual \
		libjpeg62-turbo \
		libpq5 \
	&& apt-get purge -y --auto-remove $buildDeps

	# download and load the nodejs 8.x setup
	RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

	# install mstmp to simulate sendmail, and connect to mta with php.
	# install mysql-client to talk to mysql server container.
	# install nodejs to use in conjunction to php.
RUN apt-get install -y --no-install-recommends msmtp msmtp-mta nodejs \
	&& rm -rf /var/lib/apt/lists/* \

# base production configuration for apache PHP module
COPY ./php.ini-production /usr/local/etc/php/php.ini

#set error_log and sendmail_path for container
COPY ./default-docker.ini /usr/local/etc/php/conf.d/default-docker.ini

# MSMTP Configuration for mailhog
COPY ./msmtprc /etc/msmtprc

# download, verify, and install composer
RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > composer-setup.php.sig \
    && curl -sS https://getcomposer.org/installer | tee composer-setup.php | sha384sum -c composer-setup.php.sig \
    && php composer-setup.php -- --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup* \
		&& composer config -g vendor-dir /usr/local/php/vendor

ENV PATH ${PATH}:/usr/local/php/vendor/bin

WORKDIR /var/www/html
