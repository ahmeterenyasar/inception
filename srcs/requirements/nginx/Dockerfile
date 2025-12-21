FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx openssl curl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    mkdir -p /etc/nginx/ssl && \
    mkdir -p /var/log/nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

CMD ["/usr/local/bin/entrypoint.sh"]
