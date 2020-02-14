FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update -yyq && \
    apt-get install -yqq software-properties-common && \
    apt-get install -yqq curl && \
    rm -rf /var/lib/apt/lists/

RUN add-apt-repository ppa:ondrej/php

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
       libkrb5-dev \
       libmagickwand-dev \
       libpng-dev \
       libxml2-dev \
       make \
       openssl \
       wget \
       unzip \
       zip \
       wget \
       vim \
       zlib1g-dev \
       lsb-release \
       nginx \
       php7.2 php7.2-fpm php7.2-cli php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml php-pear \
       php7.2-gd \
       php7.2-gettext \
       php7.2-imap \
       php7.2-intl \
       php7.2-mysqli \
       php7.2-opcache \
       php7.2-pdo-mysql \
       php7.2-soap \
       php7.2-zip \
       nodejs \
       mysql-client \
       mysql-server && \
       rm -r /var/lib/apt/lists/*

RUN pecl install imagick 

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get -y install google-chrome-stable

ENV CHROME_BIN /usr/bin/google-chrome

RUN apt purge -y software-properties-common && \
    apt autoremove -y --purge && \
    apt clean -y

ARG BUILDKIT_UID=1000
ARG BUILDKIT_GID=$BUILDKIT_UID
RUN addgroup --gid=$BUILDKIT_GID buildkit
RUN useradd --home-dir /buildkit --create-home --uid $BUILDKIT_UID --gid $BUILDKIT_GID buildkit
COPY buildkit-sudoers /etc/sudoers.d/buildkit
COPY --chown=buildkit:buildkit amp.services.yml /buildkit/.amp/services.yml

ENV PATH /buildkit/civicrm-buildkit/bin:$PATH

RUN service mysql restart && \
    mysql -e "CREATE USER 'buildkit'@'localhost' IDENTIFIED BY 'mysql'; GRANT ALL ON *.* to 'buildkit'@'localhost' IDENTIFIED BY 'mysql' WITH GRANT OPTION; FLUSH PRIVILEGES" && \
    su - buildkit -c "git clone https://github.com/civicrm/civicrm-buildkit" && \
    su - buildkit -c "/buildkit/civicrm-buildkit/bin/civi-download-tools" && \
    su - buildkit -c "/buildkit/civicrm-buildkit/bin/civibuild create drupal-clean --civi-ver 5.19.4" && \
    su - buildkit -c "mkdir /buildkit/civicrm-buildkit/build/drupal-clean/web/sites/all/modules/civicrm/ext" && \
    rm -rf /tmp/*

ENV CIVICRM_SETTINGS /buildkit/civicrm-buildkit/build/drupal-clean/web/sites/default/civicrm.settings.php