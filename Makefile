.PHONY: help dev prod build up down logs prune clean clean-all restart ps health

.DEFAULT_GOAL := help

DEV_COMPOSE := docker/compose.development.yaml
PROD_COMPOSE := docker/compose.production.yaml

help:
	@echo "Available commands:"
	@echo ""
	@echo "Development:"
	@echo "  make dev          - Start development environment"
	@echo "  make dev-down     - Stop development environment"
	@echo "  make dev-build    - Build development images"
	@echo "  make dev-logs     - Follow development logs"
	@echo ""
	@echo "Production:"
	@echo "  make prod         - Start production environment"
	@echo "  make prod-down    - Stop production environment"
	@echo "  make prod-build   - Build production images"
	@echo "  make prod-logs    - Follow production logs"
	@echo ""
	@echo "General:"
	@echo "  make build        - Build production images"
	@echo "  make up           - Start services (production)"
	@echo "  make down         - Stop all containers"
	@echo "  make logs         - Follow logs for all services"
	@echo "  make restart      - Restart all services"
	@echo "  make ps           - Show running containers"
	@echo "  make health       - Check service health"
	@echo ""
	@echo "Cleanup:"
	@echo "  make prune        - Clean unused Docker resources"
	@echo "  make clean        - Remove containers and networks"
	@echo "  make clean-all    - Remove everything including volumes"
	@echo ""

dev:
	@echo "Starting development environment..."
	docker-compose -f $(DEV_COMPOSE) up -d
	@echo "Development environment is running!"
	@echo "Gateway: http://localhost:5921"

dev-down:
	@echo "Stopping development environment..."
	docker-compose -f $(DEV_COMPOSE) down

dev-build:
	@echo "Building development images..."
	docker-compose -f $(DEV_COMPOSE) build

dev-logs:
	docker-compose -f $(DEV_COMPOSE) logs -f

dev-restart:
	@echo "Restarting development services..."
	docker-compose -f $(DEV_COMPOSE) restart

prod:
	@echo "Starting production environment..."
	docker-compose -f $(PROD_COMPOSE) up -d
	@echo "Production environment is running!"
	@echo "Gateway: http://localhost:5921"

prod-down:
	@echo "Stopping production environment..."
	docker-compose -f $(PROD_COMPOSE) down

prod-build:
	@echo "Building production images..."
	docker-compose -f $(PROD_COMPOSE) build --no-cache

prod-logs:
	docker-compose -f $(PROD_COMPOSE) logs -f

prod-restart:
	@echo "Restarting production services..."
	docker-compose -f $(PROD_COMPOSE) restart

build: prod-build

up: prod

down:
	@echo "Stopping all containers..."
	docker-compose -f $(DEV_COMPOSE) down 2>/dev/null || true
	docker-compose -f $(PROD_COMPOSE) down 2>/dev/null || true

logs:
	@echo "Following logs (production)..."
	docker-compose -f $(PROD_COMPOSE) logs -f

restart:
	@echo "Restarting production services..."
	docker-compose -f $(PROD_COMPOSE) restart

ps:
	@echo "Development containers:"
	@docker-compose -f $(DEV_COMPOSE) ps 2>/dev/null || echo "  No development containers running"
	@echo ""
	@echo "Production containers:"
	@docker-compose -f $(PROD_COMPOSE) ps 2>/dev/null || echo "  No production containers running"

health:
	@echo "Checking service health..."
	@docker ps --filter "name=dev-" --filter "name=prod-" --format "table {{.Names}}\t{{.Status}}"

prune:
	@echo "Cleaning unused Docker resources..."
	docker system prune -f
	docker volume prune -f
	docker network prune -f
	@echo "Cleanup complete!"

clean:
	@echo "Removing containers and networks..."
	docker-compose -f $(DEV_COMPOSE) down 2>/dev/null || true
	docker-compose -f $(PROD_COMPOSE) down 2>/dev/null || true
	@echo "Cleanup complete!"

clean-all:
	@echo "WARNING: This will remove all containers, networks, volumes, and images!"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	docker-compose -f $(DEV_COMPOSE) down -v --rmi all 2>/dev/null || true
	docker-compose -f $(PROD_COMPOSE) down -v --rmi all 2>/dev/null || true
	@echo "Complete cleanup finished!"
# Utility Commands
# ============================================
backend-shell: ## Open shell in backend container (dev)
	docker-compose -f $(DEV_COMPOSE) exec backend sh

gateway-shell: ## Open shell in gateway container (dev)
	docker-compose -f $(DEV_COMPOSE) exec gateway sh

mongo-shell: ## Open MongoDB shell (dev)
	docker-compose -f $(DEV_COMPOSE) exec mongodb mongosh -u admin -p admin123

db-reset: ## Reset MongoDB database (WARNING: deletes all data)
	@echo "WARNING: This will delete all database data!"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	docker-compose -f $(DEV_COMPOSE) down -v
	docker volume rm dev-mongodb-data 2>/dev/null || true
	@echo "Database reset complete!"

