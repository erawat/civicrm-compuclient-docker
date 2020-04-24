FROM ubuntu:18.04

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
       ssh \
       mysql-client && \
       rm -r /var/lib/apt/lists/*

RUN pecl install imagick xdebug

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get -y install google-chrome-stable

ENV CHROME_BIN /usr/bin/google-chrome

RUN apt purge -y software-properties-common && \
    apt autoremove -y --purge && \
    apt clean -y

ARG COMPUCORP_UID=1000
ARG COMPUCORP_GID=$COMPUCORP_UID
RUN addgroup --gid=$COMPUCORP_GID compucorp
RUN useradd --home-dir /compucorp --create-home --uid $COMPUCORP_UID --gid $COMPUCORP_GID compucorp
COPY compucorp-sudoers /etc/sudoers.d/compucorp
COPY --chown=compucorp:compucorp amp.services.yml /compucorp/.amp/services.yml

RUN su - compucorp -c "git clone https://github.com/civicrm/civicrm-buildkit" && \
    su - compucorp -c "/compucorp/civicrm-buildkit/bin/civi-download-tools" && \
    rm -rf /tmp/*

ENV PATH /compucorp/civicrm-buildkit/bin:$PATH

COPY .ssh /compucorp/.ssh/

RUN su - compucorp -c "git clone git@bitbucket.org:compucorp/compuclient.git" && \
    su - compucorp -c "cd /compucorp/compuclient/ && /compucorp/civicrm-buildkit/bin/drush make site.make.yml /compucorp/build/compuclient"

RUN rm -rf .ssh/*

COPY settings/settings.php /compucorp/build/compuclient/sites/default/settings.php
COPY settings/civicrm.settings.php /compucorp/build/compuclient/sites/default/civicrm.settings.php

ENV CIVICRM_SETTINGS /compucorp/build/compuclient/sites/default/civicrm.settings.php

COPY databases/civicrm.sql /compucorp/civicrm.sql
COPY databases/drupal.sql /compucorp/drupal.sql
