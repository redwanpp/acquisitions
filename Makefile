# Acquisitions Project Makefile
# Provides convenient shortcuts for Docker operations

.PHONY: help dev prod stop clean logs status migrate build test

# Default target
help:
	@echo "Acquisitions Project - Docker Management"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  dev         - Start development environment with Neon Local"
	@echo "  prod        - Start production environment with Neon Cloud"  
	@echo "  stop        - Stop all services"
	@echo "  clean       - Clean up Docker resources"
	@echo "  logs        - Show development logs"
	@echo "  logs-prod   - Show production logs"
	@echo "  status      - Show service status"
	@echo "  migrate-dev - Run migrations in development"
	@echo "  migrate-prod- Run migrations in production"
	@echo "  build       - Build images without starting"
	@echo "  restart-dev - Restart development environment"
	@echo "  restart-prod- Restart production environment"
	@echo "  shell-dev   - Open shell in development app container"
	@echo "  shell-prod  - Open shell in production app container"
	@echo ""
	@echo "Advanced:"
	@echo "  ./setup-docker.sh help  - Show full script options"

# Development environment
dev:
	@./setup-docker.sh dev

dev-detached:
	@./setup-docker.sh dev --detached

# Production environment  
prod:
	@./setup-docker.sh prod

prod-verbose:
	@./setup-docker.sh prod --verbose

# Stop services
stop:
	@./setup-docker.sh stop all

stop-dev:
	@./setup-docker.sh stop dev

stop-prod:
	@./setup-docker.sh stop prod

# Clean up
clean:
	@./setup-docker.sh clean

clean-force:
	@./setup-docker.sh clean --force

# Logs
logs:
	@./setup-docker.sh logs dev

logs-prod:
	@./setup-docker.sh logs prod

logs-app:
	@./setup-docker.sh logs dev app

logs-neon:
	@./setup-docker.sh logs dev neon-local

# Status
status:
	@./setup-docker.sh status

# Migrations
migrate-dev:
	@./setup-docker.sh migrate dev

migrate-prod:
	@./setup-docker.sh migrate prod

# Build only
build-dev:
	@docker compose -f docker-compose.dev.yml build

build-prod:
	@docker compose -f docker-compose.prod.yml build

# Restart services
restart-dev: stop-dev dev

restart-prod: stop-prod prod

# Shell access
shell-dev:
	@docker compose -f docker-compose.dev.yml exec app sh

shell-prod:
	@docker compose -f docker-compose.prod.yml exec app sh

# Database operations
db-studio-dev:
	@docker compose -f docker-compose.dev.yml exec app npm run db:studio

db-generate-dev:
	@docker compose -f docker-compose.dev.yml exec app npm run db:generate

# Test connectivity
test-dev:
	@curl -f http://localhost:3000/health || echo "Development server not responding"

test-prod:
	@curl -f http://localhost:3000/health || echo "Production server not responding"

# Show Docker system info
docker-info:
	@docker system df
	@echo ""
	@docker images | head -10
	@echo ""
	@docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"