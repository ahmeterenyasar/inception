#!/bin/bash

set -e

# Check if database is already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[MariaDB] Initializing database..."
    
    # Initialize the database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    echo "[MariaDB] Database initialized."
fi

# Check if our database exists
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "[MariaDB] Starting temporary instance for configuration..."
    
    # Start MariaDB temporarily
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$!
    
    # Wait for MariaDB to start
    echo "[MariaDB] Waiting for server to start..."
    for i in {1..30}; do
        if mysqladmin ping --silent 2>/dev/null; then
            break
        fi
        sleep 1
    done
    
    echo "[MariaDB] Configuring database and users..."
    
    # Run initialization SQL
    mysql -u root << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    echo "[MariaDB] Configuration complete."
    
    # Stop the temporary instance
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $MYSQL_PID
    
    echo "[MariaDB] Temporary instance stopped."
fi

echo "[MariaDB] Starting MariaDB server..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
