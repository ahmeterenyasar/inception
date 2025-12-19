#!/bin/bash

# Generate secure random passwords
MYSQL_ROOT_PASS=$(openssl rand -base64 16)
MYSQL_USER_PASS=$(openssl rand -base64 16)
WP_ADMIN_PASS=$(openssl rand -base64 16)
WP_USER_PASS=$(openssl rand -base64 16)

echo "=== Generating secure passwords ==="
echo ""

# Update .env file
cat > srcs/.env << EOF
# Domain Configuration
DOMAIN_NAME=ayasar.42.fr

# MySQL/MariaDB Configuration
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASS}
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=${MYSQL_USER_PASS}

# WordPress Admin Configuration
WP_TITLE=Inception WordPress
WP_ADMIN_USER=ayasar
WP_ADMIN_PASSWORD=${WP_ADMIN_PASS}
WP_ADMIN_EMAIL=ayasar@student.42.fr

# WordPress Regular User Configuration
WP_USER=wpregular
WP_USER_EMAIL=wpregular@student.42.fr
WP_USER_PASSWORD=${WP_USER_PASS}
EOF

# Update secrets directory
mkdir -p secrets

cat > secrets/credentials.txt << EOF
# Inception Project Credentials
# WARNING: Keep this file secure and never commit to Git

## WordPress Admin
Username: ayasar
Password: ${WP_ADMIN_PASS}
Email: ayasar@student.42.fr

## WordPress Regular User
Username: wpregular
Password: ${WP_USER_PASS}
Email: wpregular@student.42.fr

## MySQL/MariaDB
Database: wordpress
User: wpuser
Password: ${MYSQL_USER_PASS}
Root Password: ${MYSQL_ROOT_PASS}

## Access URL
Website: https://ayasar.42.fr
WordPress Admin: https://ayasar.42.fr/wp-admin
EOF

echo "${MYSQL_USER_PASS}" > secrets/db_password.txt
echo "${MYSQL_ROOT_PASS}" > secrets/db_root_password.txt

echo "✅ Credentials updated successfully!"
echo ""
echo "=== Your Generated Credentials ==="
echo ""
cat secrets/credentials.txt
echo ""
echo "⚠️  IMPORTANT: Save these credentials in a secure place!"
echo "📁 Full credentials are saved in: secrets/credentials.txt"
