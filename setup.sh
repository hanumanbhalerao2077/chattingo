#!/bin/bash

# ============================================
# Chattingo - Quick Setup Script
# ============================================
# This script automates the Docker setup for local development
# Usage: bash setup.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing=0
    
    # Check Docker
    if command -v docker &> /dev/null; then
        docker_version=$(docker --version)
        print_success "Docker installed: $docker_version"
    else
        print_error "Docker is not installed"
        echo "Install from: https://www.docker.com/products/docker-desktop"
        missing=1
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        compose_version=$(docker-compose --version)
        print_success "Docker Compose installed: $compose_version"
    else
        print_error "Docker Compose is not installed"
        echo "Install from: https://docs.docker.com/compose/install/"
        missing=1
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        git_version=$(git --version)
        print_success "Git installed: $git_version"
    else
        print_error "Git is not installed"
        echo "Install from: https://git-scm.com/downloads"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "Please install missing prerequisites and run again"
        exit 1
    fi
    
    echo ""
}

# Create environment files
setup_environment() {
    print_header "Setting Up Environment Files"
    
    # Backend .env
    if [ ! -f backend/.env ]; then
        cp backend/.env.example backend/.env
        print_success "Created backend/.env"
    else
        print_warning "backend/.env already exists, skipping"
    fi
    
    # Frontend .env
    if [ ! -f frontend/.env.development.local ]; then
        cp frontend/.env.example frontend/.env.development.local
        print_success "Created frontend/.env.development.local"
    else
        print_warning "frontend/.env.development.local already exists, skipping"
    fi
    
    echo ""
}

# Build Docker images
build_images() {
    print_header "Building Docker Images"
    
    print_info "This may take several minutes..."
    print_info "Building backend image..."
    docker-compose build backend
    print_success "Backend image built"
    
    print_info "Building frontend image..."
    docker-compose build frontend
    print_success "Frontend image built"
    
    print_info "Building MySQL image..."
    docker-compose build mysql || print_warning "MySQL image may be pre-built"
    
    echo ""
}

# Start services
start_services() {
    print_header "Starting Services"
    
    print_info "Starting Docker containers..."
    docker-compose up -d
    
    print_success "Docker services started"
    print_info "Waiting for services to initialize..."
    sleep 20
    
    echo ""
}

# Verify services
verify_services() {
    print_header "Verifying Services"
    
    # Check status
    print_info "Container status:"
    docker-compose ps
    
    echo ""
    
    # Check backend
    print_info "Testing backend connection..."
    if curl -s http://localhost:8080/auth > /dev/null 2>&1; then
        print_success "Backend is responding"
    else
        print_warning "Backend may still be initializing, wait a few more seconds"
    fi
    
    # Check frontend
    print_info "Testing frontend connection..."
    if curl -s http://localhost/health > /dev/null 2>&1; then
        print_success "Frontend is responding"
    else
        print_warning "Frontend may still be initializing, wait a few more seconds"
    fi
    
    # Check database
    print_info "Testing database connection..."
    if docker-compose exec -T mysql mysqladmin ping -u root -p"${MYSQL_ROOT_PASSWORD:-root}" &> /dev/null; then
        print_success "Database is responding"
    else
        print_warning "Database may still be initializing"
    fi
    
    echo ""
}

# Display access information
show_access_info() {
    print_header "Access Information"
    
    echo ""
    echo -e "${GREEN}Application is ready!${NC}"
    echo ""
    echo "Access URLs:"
    echo -e "  Frontend:     ${BLUE}http://localhost${NC}"
    echo -e "  Backend API:  ${BLUE}http://localhost:8080${NC}"
    echo -e "  Database:     ${BLUE}localhost:3306${NC}"
    echo ""
    echo "Default Credentials:"
    echo "  Database Root Password: root"
    echo "  Database User: chattingo_user"
    echo "  Database Name: chattingo_db"
    echo ""
    echo "Next Steps:"
    echo "  1. Open http://localhost in your browser"
    echo "  2. Sign up for a new account"
    echo "  3. Create another account and test messaging"
    echo ""
    echo "Useful Commands:"
    echo "  View logs:        docker-compose logs -f"
    echo "  Stop services:    docker-compose stop"
    echo "  Stop & remove:    docker-compose down"
    echo "  Remove volumes:   docker-compose down -v"
    echo ""
}

# Troubleshoot issues
show_troubleshooting() {
    print_header "Troubleshooting"
    
    echo "If services don't start properly:"
    echo ""
    echo "1. Check logs:"
    echo "   docker-compose logs -f backend"
    echo "   docker-compose logs -f mysql"
    echo ""
    echo "2. Verify ports are not in use:"
    echo "   lsof -i :8080  (backend)"
    echo "   lsof -i :3306  (database)"
    echo "   lsof -i :80    (frontend)"
    echo ""
    echo "3. Rebuild images:"
    echo "   docker-compose build --no-cache"
    echo "   docker-compose up -d"
    echo ""
    echo "4. Reset everything:"
    echo "   docker-compose down -v"
    echo "   docker system prune -a"
    echo ""
}

# Main setup flow
main() {
    clear
    
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Chattingo - Docker Setup Script    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Run setup steps
    check_prerequisites
    setup_environment
    
    # Ask before building
    echo -e "${YELLOW}Ready to build Docker images and start services?${NC}"
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        build_images
        start_services
        
        # Wait and verify
        echo -e "${YELLOW}Waiting for all services to be ready...${NC}"
        sleep 10
        verify_services
        
        show_access_info
    else
        print_info "Setup cancelled. Run this script again when ready."
        exit 0
    fi
}

# Run main function
main
