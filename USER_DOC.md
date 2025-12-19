# User Documentation

## Overview

This Inception project provides a fully containerized infrastructure for running a WordPress website with NGINX as a reverse proxy and MariaDB as the database. All services run in separate Docker containers and communicate through a secure internal network.

## Services Provided

The stack includes the following services:

1. **NGINX** - Web server and reverse proxy
   - Handles HTTPS connections on port 443
   - Uses TLSv1.2 and TLSv1.3 protocols
   - Serves as the only entry point to the infrastructure

2. **WordPress** - Content Management System
   - Runs with PHP-FPM (PHP 7.4)
   - Accessible through NGINX
   - Includes two pre-configured users (admin and regular user)

3. **MariaDB** - Database server
   - Stores WordPress data
   - Runs on internal network only (not exposed to host)

## Getting Started

### Prerequisites

- Docker and Docker Compose must be installed
- Sufficient disk space (at least 2GB recommended)
- Root/sudo access for directory creation

### First-Time Setup

1. **Configure the domain name:**
   
   Add the following line to `/etc/hosts`:
   ```bash
   127.0.0.1 ayasar.42.fr
   ```

2. **Update credentials:**
   
   Edit the following files with secure passwords:
   - `srcs/.env` - Main environment configuration
   - `secrets/credentials.txt` - Reference file for credentials
   - `secrets/db_password.txt` - Database password
   - `secrets/db_root_password.txt` - Database root password

   ⚠️ **IMPORTANT:** Use strong, unique passwords for each credential!

## Starting the Project

To build and start all services:

```bash
make
```

Or explicitly:

```bash
make up
```

The first run will take several minutes as Docker builds all images and initializes the database.

## Stopping the Project

To stop all containers:

```bash
make down
```

This preserves your data in the volumes.

## Accessing the Website

Once the containers are running:

1. **Website:** Open your browser and navigate to `https://ayasar.42.fr`
2. **WordPress Admin Panel:** Go to `https://ayasar.42.fr/wp-admin`

⚠️ **SSL Certificate Warning:** You will see a security warning because the project uses a self-signed SSL certificate. This is expected. Click "Advanced" and "Proceed to site" (or similar, depending on your browser).

### Default Credentials

Check the `secrets/credentials.txt` file for login information:

- **Admin User:** Username and password are defined in your `.env` file
- **Regular User:** Username and password are also defined in your `.env` file

## Managing Credentials

All credentials are stored in:

1. **`srcs/.env`** - Environment variables used by Docker Compose
2. **`secrets/credentials.txt`** - Human-readable reference
3. **`secrets/db_password.txt`** - Database user password
4. **`secrets/db_root_password.txt`** - Database root password

⚠️ **Security Note:** These files are excluded from Git via `.gitignore`. Never commit them to version control!

## Checking Service Status

### View running containers:

```bash
make ps
```

or

```bash
docker-compose -f srcs/docker-compose.yml ps
```

### View container logs:

```bash
make logs
```

This will show real-time logs from all containers. Press `Ctrl+C` to exit.

### Check individual service logs:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Verify services are responding:

1. **NGINX:** Should respond on port 443
   ```bash
   curl -k https://ayasar.42.fr
   ```

2. **WordPress:** Check if the site loads in your browser

3. **MariaDB:** Connect from within the WordPress container
   ```bash
   docker exec -it wordpress mysql -h mariadb -u wpuser -p
   ```

## Troubleshooting

### Containers not starting:

1. Check logs: `make logs`
2. Verify data directories exist:
   ```bash
   ls -la /home/ayasar/data/mysql
   ls -la /home/ayasar/data/wordpress
   ```

### Can't access the website:

1. Verify `/etc/hosts` has the correct entry
2. Check NGINX is running: `docker ps | grep nginx`
3. Ensure port 443 is not used by another service: `sudo netstat -tlnp | grep 443`

### Database connection errors:

1. Verify MariaDB is running: `docker ps | grep mariadb`
2. Check database logs: `docker logs mariadb`
3. Ensure credentials in `.env` are correct

### Permission errors:

1. Ensure data directories have correct permissions:
   ```bash
   sudo chown -R $USER:$USER /home/ayasar/data
   ```

## Data Persistence

Your data is stored in:

- **Database files:** `/home/ayasar/data/mysql`
- **WordPress files:** `/home/ayasar/data/wordpress`

These directories persist even when containers are stopped or removed.

## Cleaning Up

### Remove containers and images:

```bash
make clean
```

### Full cleanup (including volumes and data):

```bash
make fclean
```

⚠️ **Warning:** `make fclean` will delete ALL your data, including WordPress content and database!

## Rebuilding from Scratch

To completely rebuild the project:

```bash
make re
```

This is equivalent to `make fclean` followed by `make all`.
