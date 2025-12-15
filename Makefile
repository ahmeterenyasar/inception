# Inception Makefile

COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/ayasar/data

.PHONY: all up build down clean fclean re logs ps

all: up

# Create necessary data directories
setup:
	@echo "Creating data directories..."
	@sudo mkdir -p $(DATA_DIR)/mysql
	@sudo mkdir -p $(DATA_DIR)/wordpress
	@echo "Data directories created."

# Build all Docker images
build: setup
	@echo "Building Docker images..."
	@docker-compose -f $(COMPOSE_FILE) build
	@echo "Build complete."

# Start all containers
up: setup
	@echo "Starting containers..."
	@docker-compose -f $(COMPOSE_FILE) up -d
	@echo "Containers are up and running."
	@echo "Access WordPress at: https://ayasar.42.fr"

# Stop all containers
down:
	@echo "Stopping containers..."
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "Containers stopped."

# Stop containers and remove images
clean: down
	@echo "Removing Docker images..."
	@docker-compose -f $(COMPOSE_FILE) down --rmi all
	@echo "Images removed."

# Full clean: remove everything including volumes
fclean: clean
	@echo "Removing volumes and data..."
	@docker-compose -f $(COMPOSE_FILE) down --volumes
	@sudo rm -rf $(DATA_DIR)/mysql/*
	@sudo rm -rf $(DATA_DIR)/wordpress/*
	@echo "Full clean complete."

# Rebuild everything from scratch
re: fclean all

# Show logs
logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

# Show container status
ps:
	@docker-compose -f $(COMPOSE_FILE) ps

# Help
help:
	@echo "Inception Makefile Commands:"
	@echo "  make         - Build and start all containers"
	@echo "  make build   - Build all Docker images"
	@echo "  make up      - Start all containers"
	@echo "  make down    - Stop all containers"
	@echo "  make clean   - Stop containers and remove images"
	@echo "  make fclean  - Full clean (including volumes)"
	@echo "  make re      - Rebuild everything from scratch"
	@echo "  make logs    - Show container logs"
	@echo "  make ps      - Show container status"
