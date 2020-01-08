FROM php:7.2-fpm-stretch

ENV DEBIAN_FRONTEND=noninteractive

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get update -yqq && \
    apt-get install --no-install-recommends -yqq \
       sudo \
       autoconf \
       build-essential \
       gcc \
       git \
       libjansson-dev \
       libc-client-dev \
       libicu-dev \
       libjpeg62-turbo-dev \
       libkrb5-dev \
       libmagickwand-dev \
       libpng-dev \
       libxml2-dev \
       make \
       openssl \
       software-properties-common \
       unzip \
       zip \
       wget \
       zlib1g-dev \
       lsb-release \
       nodejs \
       mysql-client \
       mysql-server && \
       rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install bcmath \
  && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && docker-php-ext-install gettext \
  && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install imap \
  && docker-php-ext-install intl \
  && docker-php-ext-install mysqli \
  && docker-php-ext-install opcache \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-install soap \
  && docker-php-ext-install zip

RUN pecl install imagick \
  && docker-php-ext-enable imagick

RUN apt purge -y software-properties-common && \
    apt autoremove -y --purge && \
    apt clean -y

ARG BUILDKIT_UID=1000
ARG BUILDKIT_GID=$BUILDKIT_UID
RUN addgroup --gid=$BUILDKIT_GID buildkit
RUN useradd --home-dir /buildkit --create-home --uid $BUILDKIT_UID --gid $BUILDKIT_GID buildkit
COPY buildkit-sudoers /etc/sudoers.d/buildkit
COPY --chown=buildkit:buildkit amp.services.yml /buildkit/.amp/services.yml

RUN service mysql restart && \
    mysql -e "CREATE USER 'buildkit'@'localhost' IDENTIFIED BY 'mysql'; GRANT ALL ON *.* to 'buildkit'@'localhost' IDENTIFIED BY 'mysql' WITH GRANT OPTION; FLUSH PRIVILEGES" && \
    su - buildkit -c "git clone https://github.com/civicrm/civicrm-buildkit" && \
    su - buildkit -c "/buildkit/civicrm-buildkit/bin/civi-download-tools" && \
    su - buildkit -c "/buildkit/civicrm-buildkit/bin/civibuild create drupal-clean --civi-ver 5.19.4" && \
    rm -rf /tmp/*
