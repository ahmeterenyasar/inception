# Inception Project

## Important Security Notice
⚠️ **NEVER commit the following files to git:**
- `srcs/.env`
- `secrets/*`

These files contain sensitive credentials and passwords.

## Setup Instructions

1. **Update your /etc/hosts file:**
   Add the following line to `/etc/hosts`:
   ```
   127.0.0.1 ayasar.42.fr
   ```

2. **Create data directories:**
   ```bash
   sudo mkdir -p /home/ayasar/data/mysql
   sudo mkdir -p /home/ayasar/data/wordpress
   ```

3. **Update credentials:**
   Edit `srcs/.env` and replace all placeholder passwords with secure passwords.

4. **Build and run:**
   ```bash
   make
   ```

5. **Access WordPress:**
   Open your browser and navigate to: `https://ayasar.42.fr`
   
   Accept the self-signed certificate warning.

## Makefile Commands

- `make` or `make up` - Build and start all containers
- `make build` - Build all Docker images
- `make down` - Stop and remove containers
- `make clean` - Stop containers and remove images
- `make fclean` - Clean everything including volumes
- `make re` - Rebuild everything from scratch
- `make logs` - Show container logs

## Project Structure

```
inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── setup.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── setup.sh
        └── wordpress/
            ├── Dockerfile
            ├── .dockerignore
            └── tools/
                └── setup.sh
```

## Services

- **NGINX**: Web server with TLSv1.2/1.3 support on port 443
- **WordPress**: CMS with php-fpm on port 9000
- **MariaDB**: Database server on port 3306

## Volumes

- `db_data`: MariaDB database files → `/home/ayasar/data/mysql`
- `wp_data`: WordPress files → `/home/ayasar/data/wordpress`

## Network

- `inception`: Bridge network connecting all containers
