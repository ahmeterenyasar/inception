# Developer Documentation

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Project Structure](#project-structure)
3. [Building and Running](#building-and-running)
4. [Container Management](#container-management)
5. [Volume Management](#volume-management)
6. [Network Configuration](#network-configuration)
7. [Development Workflow](#development-workflow)
8. [Debugging](#debugging)

## Environment Setup

### Prerequisites

Ensure you have the following installed:

- **Docker Engine** (version 20.10+)
- **Docker Compose** (version 1.29+ or Docker Compose V2)
- **Make** (for using the Makefile)
- **Root/sudo access** (for creating data directories)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd inception
   ```

2. **Configure host file:**
   
   Add the domain to `/etc/hosts`:
   ```bash
   echo "127.0.0.1 ayasar.42.fr" | sudo tee -a /etc/hosts
   ```

3. **Create configuration files:**

   a. **Environment variables** - Copy and edit `srcs/.env`:
   ```bash
   # The file should already exist, but if not:
   cat > srcs/.env << 'EOF'
   DOMAIN_NAME=ayasar.42.fr
   MYSQL_ROOT_PASSWORD=your_secure_root_password
   MYSQL_DATABASE=wordpress
   MYSQL_USER=wpuser
   MYSQL_PASSWORD=your_secure_mysql_password
   WP_TITLE=Inception WordPress
   WP_ADMIN_USER=ayasar
   WP_ADMIN_PASSWORD=your_secure_admin_password
   WP_ADMIN_EMAIL=ayasar@student.42.fr
   WP_USER=wpregular
   WP_USER_EMAIL=wpregular@student.42.fr
   WP_USER_PASSWORD=your_secure_user_password
   EOF
   ```

   b. **Secrets directory** - Create credential files:
   ```bash
   mkdir -p secrets
   echo "your_secure_mysql_password" > secrets/db_password.txt
   echo "your_secure_root_password" > secrets/db_root_password.txt
   # Edit secrets/credentials.txt with all credentials
   ```

   ⚠️ **Replace all placeholder passwords with secure values!**

4. **Create data directories:**
   ```bash
   sudo mkdir -p /home/ayasar/data/mysql
   sudo mkdir -p /home/ayasar/data/wordpress
   sudo chown -R $USER:$USER /home/ayasar/data
   ```

## Project Structure

```
inception/
├── Makefile                    # Build automation
├── .gitignore                  # Git ignore rules
├── README.md                   # Project overview
├── USER_DOC.md                 # User documentation
├── DEV_DOC.md                  # This file
├── secrets/                    # Credentials (git-ignored)
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                    # Environment variables (git-ignored)
    ├── docker-compose.yml      # Service orchestration
    └── requirements/
        ├── nginx/              # NGINX service
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── setup.sh
        ├── wordpress/          # WordPress + PHP-FPM service
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   └── tools/
        │       └── setup.sh
        └── mariadb/            # MariaDB database service
            ├── Dockerfile
            ├── .dockerignore
            ├── conf/
            │   └── 50-server.cnf
            └── tools/
                └── setup.sh
```

### Key Files

- **`Makefile`**: Provides convenient commands for building, starting, stopping, and cleaning
- **`srcs/docker-compose.yml`**: Defines services, networks, and volumes
- **`srcs/.env`**: Environment variables for Docker Compose
- **`Dockerfile`s**: Build instructions for each service
- **`tools/setup.sh`**: Initialization scripts run on container startup
- **`conf/*`**: Configuration files copied into containers

## Building and Running

### Using Makefile (Recommended)

The Makefile provides convenient targets:

```bash
# Build and start everything
make

# Or explicitly
make up

# Just build images without starting
make build

# Stop containers
make down

# Remove containers and images
make clean

# Full cleanup including volumes and data
make fclean

# Rebuild everything from scratch
make re
```

### Using Docker Compose Directly

```bash
# Build images
docker-compose -f srcs/docker-compose.yml build

# Start services
docker-compose -f srcs/docker-compose.yml up -d

# Stop services
docker-compose -f srcs/docker-compose.yml down

# View logs
docker-compose -f srcs/docker-compose.yml logs -f

# Check status
docker-compose -f srcs/docker-compose.yml ps
```

### Build Process

1. **Image Building:**
   - Each service builds from Debian Bullseye base image
   - Dockerfiles install required packages
   - Configuration files and scripts are copied
   - No external images are pulled (except base OS)

2. **Container Initialization:**
   - MariaDB: Runs `setup.sh` to initialize database and create users
   - WordPress: Downloads WP-CLI, installs WordPress, creates users
   - NGINX: Generates self-signed SSL certificate on build

3. **Service Dependencies:**
   - WordPress waits for MariaDB to be ready
   - NGINX waits for WordPress to be ready

## Container Management

### Inspecting Containers

```bash
# List running containers
docker ps

# View all containers (including stopped)
docker ps -a

# Inspect a specific container
docker inspect mariadb
docker inspect wordpress
docker inspect nginx

# View resource usage
docker stats
```

### Accessing Containers

```bash
# Execute a bash shell in a container
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

# Run a one-off command
docker exec mariadb mysql -u root -p
docker exec wordpress wp --info --allow-root
```

### Viewing Logs

```bash
# Follow all logs
docker-compose -f srcs/docker-compose.yml logs -f

# View specific service logs
docker logs mariadb
docker logs wordpress
docker logs nginx

# Follow logs with timestamp
docker logs -f --timestamps nginx
```

### Restarting Services

```bash
# Restart a specific service
docker restart nginx
docker restart wordpress
docker restart mariadb

# Restart all services
docker-compose -f srcs/docker-compose.yml restart
```

## Volume Management

### Understanding Volumes

The project uses **bind mounts** to persist data:

```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/ayasar/data/mysql
  wp_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/ayasar/data/wordpress
```

### Data Locations

- **MariaDB data:** `/home/ayasar/data/mysql`
  - Contains database files, tables, and MySQL system data
  
- **WordPress files:** `/home/ayasar/data/wordpress`
  - Contains WordPress core, themes, plugins, and uploads

### Inspecting Volumes

```bash
# List volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_db_data
docker volume inspect srcs_wp_data

# Check volume contents on host
ls -la /home/ayasar/data/mysql
ls -la /home/ayasar/data/wordpress
```

### Backing Up Data

```bash
# Backup database
docker exec mariadb mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --all-databases > backup.sql

# Or backup the data directory
sudo tar -czf mysql-backup.tar.gz /home/ayasar/data/mysql
sudo tar -czf wordpress-backup.tar.gz /home/ayasar/data/wordpress
```

### Cleaning Volumes

```bash
# Remove volumes (data will be lost!)
docker-compose -f srcs/docker-compose.yml down --volumes

# Manually clean data directories
sudo rm -rf /home/ayasar/data/mysql/*
sudo rm -rf /home/ayasar/data/wordpress/*
```

## Network Configuration

### Docker Network

The project uses a custom bridge network named `inception`:

```yaml
networks:
  inception:
    driver: bridge
```

### Network Inspection

```bash
# List networks
docker network ls

# Inspect the inception network
docker network inspect srcs_inception

# See which containers are connected
docker network inspect srcs_inception --format='{{range .Containers}}{{.Name}} {{end}}'
```

### Container Communication

Containers communicate using service names as hostnames:

- **NGINX → WordPress:** `fastcgi_pass wordpress:9000;`
- **WordPress → MariaDB:** `mysql -h mariadb -u wpuser -p`

### Port Mapping

Only NGINX exposes a port to the host:

```yaml
ports:
  - "443:443"
```

- Port 443 (host) → Port 443 (NGINX container)
- All other services are isolated on the internal network

### Testing Connectivity

```bash
# From host
curl -k https://ayasar.42.fr

# From inside WordPress container
docker exec wordpress curl nginx:443

# From inside WordPress to MariaDB
docker exec wordpress mysql -h mariadb -u wpuser -p
```

## Development Workflow

### Making Changes

1. **Modify Dockerfiles or configs:**
   ```bash
   # Edit the file
   vim srcs/requirements/nginx/conf/nginx.conf
   
   # Rebuild the specific service
   docker-compose -f srcs/docker-compose.yml build nginx
   
   # Restart the service
   docker-compose -f srcs/docker-compose.yml up -d nginx
   ```

2. **Update setup scripts:**
   ```bash
   # Edit the script
   vim srcs/requirements/wordpress/tools/setup.sh
   
   # Rebuild and restart
   docker-compose -f srcs/docker-compose.yml build wordpress
   docker-compose -f srcs/docker-compose.yml up -d wordpress
   ```

3. **Change environment variables:**
   ```bash
   # Edit .env
   vim srcs/.env
   
   # Restart services to apply changes
   docker-compose -f srcs/docker-compose.yml down
   docker-compose -f srcs/docker-compose.yml up -d
   ```

### Testing Changes

```bash
# Rebuild specific service
docker-compose -f srcs/docker-compose.yml build mariadb

# Test in isolation
docker run -it --rm mariadb bash

# Check logs for errors
docker logs mariadb -f
```

### Code Style and Best Practices

1. **Dockerfile best practices:**
   - Use multi-line RUN commands with `&&` and `\`
   - Clean up package manager caches
   - Group related commands
   - Use specific package versions when possible

2. **Script best practices:**
   - Use `set -e` to exit on errors
   - Add proper error handling
   - Use meaningful variable names
   - Add comments for complex logic

3. **Security best practices:**
   - Never hardcode passwords in Dockerfiles
   - Use environment variables for all credentials
   - Keep .env and secrets/ out of version control
   - Use least-privilege user accounts when possible

## Debugging

### Common Issues and Solutions

#### 1. Container fails to start

```bash
# Check logs
docker logs mariadb

# Inspect container state
docker inspect mariadb

# Try running manually
docker run -it --rm mariadb bash
```

#### 2. Database connection errors

```bash
# Verify MariaDB is running
docker ps | grep mariadb

# Check if database is ready
docker exec mariadb mysql -u root -p -e "SHOW DATABASES;"

# Test connection from WordPress
docker exec wordpress mysql -h mariadb -u wpuser -p
```

#### 3. WordPress not loading

```bash
# Check NGINX logs
docker logs nginx

# Check WordPress logs
docker logs wordpress

# Verify PHP-FPM is running
docker exec wordpress ps aux | grep php-fpm

# Test NGINX → WordPress connection
docker exec nginx curl wordpress:9000
```

#### 4. SSL certificate issues

```bash
# Check if certificate exists
docker exec nginx ls -la /etc/nginx/ssl/

# Regenerate certificate
docker exec nginx openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=ayasar.42.fr"
```

#### 5. Permission issues

```bash
# Fix data directory permissions
sudo chown -R $USER:$USER /home/ayasar/data

# Check WordPress directory permissions
docker exec wordpress ls -la /var/www/html

# Fix WordPress permissions
docker exec wordpress chown -R www-data:www-data /var/www/html
```

### Advanced Debugging

#### Enable debug mode in WordPress:

```bash
docker exec wordpress wp config set WP_DEBUG true --raw --allow-root
docker exec wordpress wp config set WP_DEBUG_LOG true --raw --allow-root
```

#### Monitor network traffic:

```bash
# Install tcpdump in a container
docker exec -it nginx apt-get update && apt-get install -y tcpdump

# Capture traffic
docker exec nginx tcpdump -i any port 443 -n
```

#### Check resource usage:

```bash
# Real-time stats
docker stats

# Disk usage
docker system df
```

### Useful Commands Reference

```bash
# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Complete system cleanup
docker system prune -a --volumes

# Export container filesystem
docker export mariadb > mariadb.tar

# View container processes
docker top wordpress
```

## Performance Optimization

### Build Optimization

- Use `.dockerignore` to exclude unnecessary files
- Order Dockerfile instructions from least to most frequently changed
- Combine related RUN commands to reduce layers

### Runtime Optimization

- Monitor resource usage with `docker stats`
- Adjust container resources if needed
- Use volume mounts efficiently
- Minimize container restarts

## CI/CD Considerations

If integrating with CI/CD:

1. Use Docker BuildKit for faster builds
2. Implement health checks in docker-compose.yml
3. Add automated testing scripts
4. Use docker-compose profiles for different environments
5. Implement proper secret management

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
