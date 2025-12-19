# Inception Project

*This project has been created as part of the 42 curriculum by ayasar.*

## Description

Inception is a system administration project that involves setting up a small infrastructure composed of different services using Docker and Docker Compose. The goal is to virtualize several Docker images by creating them in a personal virtual machine, implementing a complete web infrastructure with NGINX, WordPress, and MariaDB, each running in dedicated containers.

### Key Features:
- **NGINX** web server with TLSv1.2/1.3 support
- **WordPress** CMS with PHP-FPM
- **MariaDB** database
- Custom Docker images built from scratch (no pre-built images from DockerHub)
- Secure configuration with environment variables and secrets
- Persistent data storage using Docker volumes
- Isolated network communication between containers

### Project Goals:
- Understand Docker containerization and orchestration
- Learn about microservices architecture
- Practice secure credential management
- Implement proper service isolation and networking
- Gain experience with infrastructure as code

## Important Security Notice
⚠️ **NEVER commit the following files to git:**
- `srcs/.env`
- `secrets/*`

These files contain sensitive credentials and passwords.

## Instructions

## Instructions

### Setup

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
   Also update the files in the `secrets/` directory.

4. **Build and run:**
   ```bash
   make
   ```

5. **Access WordPress:**
   Open your browser and navigate to: `https://ayasar.42.fr`
   
   Accept the self-signed certificate warning.

### Makefile Commands

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

## Project Description

### Docker in This Project

This project demonstrates the power of Docker containerization for creating isolated, reproducible, and scalable services. Each service (NGINX, WordPress, MariaDB) runs in its own container, ensuring:

1. **Isolation**: Services are separated and cannot interfere with each other
2. **Portability**: The entire stack can be deployed anywhere Docker runs
3. **Reproducibility**: Containers are built from Dockerfiles, ensuring consistent environments
4. **Resource Efficiency**: Containers share the host OS kernel, using fewer resources than VMs

### Sources and Design Choices

#### Base Images
- **Debian Bullseye**: Chosen as the base OS for stability and extensive package support
- All images are built from official Debian base, no pre-made application images

#### Service Architecture
- **NGINX**: Acts as reverse proxy and sole entry point (port 443 only)
- **WordPress + PHP-FPM**: Separates PHP processing from web serving
- **MariaDB**: Dedicated database container for data persistence

#### Key Design Decisions:

1. **Service Separation**: Each service in its own container follows microservices best practices
2. **Network Isolation**: Custom bridge network allows inter-container communication while isolating from host
3. **Volume Strategy**: Bind mounts to host filesystem for easy backup and data access
4. **No Latest Tags**: All images use specific tags or builds for reproducibility
5. **Environment Variables**: Externalized configuration for flexibility and security

### Technical Comparisons

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|------------------|-------------------|
| **Isolation** | Complete OS isolation | Process-level isolation |
| **Size** | GBs (full OS) | MBs (app + dependencies) |
| **Startup Time** | Minutes | Seconds |
| **Performance** | Overhead from hypervisor | Near-native performance |
| **Resource Usage** | Heavy (full OS per VM) | Light (shared kernel) |
| **Portability** | Limited (hypervisor-specific) | High (runs anywhere Docker runs) |
| **Use Case** | Complete isolation, multiple OS types | Microservices, quick deployment |

**Why Docker for Inception**: Containers provide sufficient isolation for this web stack while being more lightweight and faster to deploy than VMs.

#### Secrets vs Environment Variables

| Method | Security | Use Case | Visibility |
|--------|----------|----------|------------|
| **Environment Variables** | Lower - visible in process list, logs | Non-sensitive config (domain, DB names) | Easily inspectable |
| **Docker Secrets** | Higher - encrypted at rest and in transit | Sensitive data (passwords, keys) | Limited access, not in process env |
| **File-based (our approach)** | Medium - filesystem permissions | Development, local deployment | Controlled by file permissions + .gitignore |

**Our Implementation**: 
- Uses `.env` file for environment variables (convenient for docker-compose)
- Stores sensitive credentials in `secrets/` directory
- Both excluded from Git via `.gitignore`
- For production, Docker Secrets would provide better security

#### Docker Network vs Host Network

| Network Mode | Isolation | Performance | Port Conflicts | Security |
|--------------|-----------|-------------|----------------|----------|
| **Bridge (default)** | Containers isolated from host | Slight overhead | No conflicts | High - isolated network |
| **Host** | No isolation | Native performance | Possible conflicts | Low - direct host access |
| **Custom Bridge** | Isolated with DNS | Slight overhead | No conflicts | High - controlled access |

**Our Implementation**: Custom bridge network `inception` provides:
- Service discovery by name (nginx → wordpress → mariadb)
- Network isolation from host and other containers
- Controlled exposure (only NGINX on port 443)

#### Docker Volumes vs Bind Mounts

| Method | Location | Portability | Management | Performance |
|--------|----------|-------------|------------|-------------|
| **Docker Volumes** | Docker-managed | High | Docker CLI | Optimized |
| **Bind Mounts** | User-specified path | Lower | Manual | Direct filesystem |

**Our Implementation**: Bind mounts to `/home/ayasar/data/` because:
- Easy access for backup and inspection
- Simple file management
- Project requirement (explicit host path)
- Direct filesystem access for development

For production, Docker volumes would offer better portability and management.

### Configuration Files

The project includes several critical configuration files:

1. **docker-compose.yml**: Orchestrates all services, defines networks and volumes
2. **Dockerfiles**: Build instructions for each service image
3. **nginx.conf**: NGINX server configuration with SSL and FastCGI settings
4. **50-server.cnf**: MariaDB server configuration for network binding
5. **setup.sh scripts**: Initialization scripts for each service
6. **.env**: Environment variables for all services
7. **secrets/**: Directory containing credential files

## Resources

### Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [Debian Package Documentation](https://www.debian.org/doc/)

### Tutorials and Articles
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [NGINX Reverse Proxy Setup](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [SSL/TLS Configuration](https://ssl-config.mozilla.org/)

### 42 Project Resources
- Inception subject PDF
- 42 Network discussions and forums
- Peer evaluations and feedback

### AI Usage

AI assistance was used in this project for:

1. **Documentation Writing**: 
   - Generating comprehensive README, USER_DOC, and DEV_DOC
   - Structuring markdown files with proper sections
   - Creating comparison tables and explanations

2. **Configuration Review**:
   - Reviewing docker-compose.yml for best practices
   - Checking Dockerfile optimization opportunities
   - Validating NGINX and MariaDB configurations

3. **Script Debugging**:
   - Identifying potential issues in shell scripts
   - Suggesting error handling improvements
   - Optimizing initialization sequences

4. **Security Recommendations**:
   - Best practices for credential management
   - .gitignore patterns for sensitive files
   - Environment variable usage patterns

**Note**: All code was reviewed, tested, and understood before implementation. AI was used as a learning and documentation tool, not as a replacement for understanding.

