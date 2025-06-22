FROM nextcloud:31-apache

# Install smbclient and PHP smbclient extension
RUN apt-get update && \
  apt-get install -y smbclient libsmbclient-dev && \
  pecl install smbclient && \
  docker-php-ext-enable smbclient && \
  apt-get clean && rm -rf /var/lib/apt/lists/*