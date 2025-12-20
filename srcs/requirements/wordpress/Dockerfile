FROM debian:bullseye

# Install PHP-FPM, PHP extensions, and required tools, clean up apt cache
RUN apt-get update && \
    apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-xmlrpc \
    php7.4-zip \
    php7.4-intl \
    curl \
    mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on port 9000

# Eski Durum: Varsayılan olarak PHP-FPM, "Unix Socket" üzerinden dinler. Bu, sadece aynı bilgisayar (container) içindeki programların konuşması içindir.
# Sorun: Senin NGINX sunucun başka bir konteynerde. Başka bir konteynerden socket dosyasına erişemez.
# Çözüm: Ayarı listen = 9000 olarak değiştiriyoruz. Yani PHP'ye diyoruz ki: "Sen bir ağ kapısı (Port 9000) aç ve oradan gelecek istekleri bekle." Böylece NGINX, TCP/IP üzerinden buraya bağlanabilir.
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;clear_env = no/clear_env = no/g' /etc/php/7.4/fpm/pool.d/www.conf

# Create directory for PHP-FPM
RUN mkdir -p /run/php

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

# Start WordPress via entrypoint
CMD ["/usr/local/bin/entrypoint.sh"]
