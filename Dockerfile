FROM php:8.0-fpm-alpine3.13

COPY --from=composer:1.10.22 /usr/bin/composer /usr/bin/composer

ENV REDIS_VERSION 4.0.2

ENV PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=www --with-fpm-group=www --disable-cgi"

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# COPY PHP config
COPY ./config /usr/local/etc/

# Install PHP extension dependencies
RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN apk add --update --upgrade \
	supervisor \
	bash \
	git \
	openssh \
	curl \
	openssl \
	icu-dev \
	libpng-dev \
    	libzip-dev \
    	libxml2-dev \
    	icu-dev \
    	libmcrypt-dev \
    	zlib-dev \
    	libxslt-dev

RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv

# Installk AWS SSM
RUN wget https://github.com/Droplr/aws-env/raw/v0.4/bin/aws-env-linux-amd64 -O /bin/aws-env && \
  chmod +x /bin/aws-env

# Install PHPcs
RUN wget https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && \
  mv phpcs.phar /usr/local/bin/phpcs && \
  chmod +x /usr/local/bin/phpcs

# Create the user and group
RUN addgroup -S -g 1000 www && adduser -S -D -u 1000 -G www www

# Create workdir
RUN mkdir /www && touch /www/docker-volume-not-mounted
WORKDIR /www

# Supervisor will run PHP-FPM and Laravel queue workers
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/supervisord.conf"]
