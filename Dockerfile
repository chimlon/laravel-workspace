FROM php:7.1

# Install "software-properties-common" (for the "add-apt-repository")
RUN apt-get update
    # && apt-get install -y software-properties-common

# RUN locale-gen en_US.UTF-8

# ENV LANGUAGE=en_US.UTF-8
# ENV LC_ALL=en_US.UTF-8
# ENV LC_CTYPE=UTF-8
# ENV LANG=en_US.UTF-8
# ENV TERM xterm

# Install some useful Tools with APT
RUN apt-get install -y --force-yes \
    libcurl4-openssl-dev \
    libedit-dev \
    libssl-dev \
    libxml2-dev \
    xz-utils \
    apt-utils \
    # sqlite3 \
    libsqlite3-dev \
    git \
    curl \
    # vim \
    # nano \
    net-tools \
    pkg-config \
    iputils-ping

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# remove load xdebug extension (only load on phpunit command)
# RUN sed -i 's/^/;/g' /etc/php/7.1/cli/conf.d/20-xdebug.ini

# Load xdebug Zend extension with phpunit command
RUN echo "alias phpunit='php -dzend_extension=xdebug.so /var/www/laravel/vendor/bin/phpunit'" >> ~/.bashrc

# Install Nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g eslint babel-eslint eslint-plugin-react yarn

# Install Composer, PHPCS and Framgia Coding Standard,
# PHPMetrics, PHPDepend, PHPMessDetector, PHPCopyPasteDetector
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Add bin folder of composer to PATH.
RUN echo "export PATH=${PATH}:/var/www/laravel/vendor/bin:/root/.composer/vendor/bin" >> ~/.bashrc

# Install phpcs
RUN composer global require 'squizlabs/php_codesniffer=*' \
    && cd ~/.composer/vendor/squizlabs/php_codesniffer/src/Standards/ \
    && git clone https://github.com/wataridori/framgia-php-codesniffer.git Framgia

# Create symlink
RUN ln -s /root/.composer/vendor/bin/phpcs /usr/bin/phpcs

# Install framgia-ci-tool
RUN curl -o /usr/bin/framgia-ci https://raw.githubusercontent.com/framgia/ci-report-tool/master/dist/framgia-ci \
    && chmod +x /usr/bin/framgia-ci

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www/laravel
