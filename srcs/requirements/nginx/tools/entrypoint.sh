#!/bin/bash

set -e

echo "[NGINX] Starting entrypoint..."

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f "/etc/nginx/ssl/nginx.crt" ] || [ ! -f "/etc/nginx/ssl/nginx.key" ]; then
    echo "[NGINX] Generating self-signed SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=TR/ST=Istanbul/L=Istanbul/O=42/OU=42/CN=${DOMAIN_NAME:-localhost}"
    echo "[NGINX] SSL certificate generated."
else
    echo "[NGINX] SSL certificate already exists."
fi

echo "[NGINX] Starting NGINX..."
exec nginx -g "daemon off;"
