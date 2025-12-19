FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create directory for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Copy nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy SSL generation script
COPY tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

# Generate self-signed SSL certificate
RUN /tmp/setup.sh

# Create directory for PID file
RUN mkdir -p /run/nginx

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
