#!/bin/bash

# ZettaBrain NFS-RAG Platform Setup Script
# This script helps you get started quickly

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${ORANGE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║     ZettaBrain NFS-RAG Platform Setup       ║"
    echo "╔══════════════════════════════════════════════╗"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}➜ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

check_requirements() {
    print_step "Checking requirements..."
    
    # Check for Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker found"
    
    # Check for Docker Compose (both old and new versions)
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
        print_success "Docker Compose found (standalone)"
    elif docker compose version &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker compose"
        print_success "Docker Compose found (plugin)"
    else
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
}

setup_environment() {
    print_step "Setting up environment..."
    
    if [ ! -f .env ]; then
        cp .env.example .env
        print_success "Created .env file from template"
        
        echo -e "${ORANGE}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "IMPORTANT: Please edit .env file with your configuration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "${NC}"
        
        read -p "Would you like to configure API keys now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            configure_apis
        fi
    else
        print_success ".env file already exists"
    fi
}

configure_apis() {
    echo -e "${BLUE}API Configuration${NC}"
    echo "Leave blank to skip"
    echo
    
    read -p "Anthropic API Key (for Claude Sonnet): " anthropic_key
    if [ ! -z "$anthropic_key" ]; then
        sed -i "s/# ANTHROPIC_API_KEY=.*/ANTHROPIC_API_KEY=$anthropic_key/" .env
        sed -i "s/LLM_PROVIDER=local/LLM_PROVIDER=anthropic/" .env
        print_success "Anthropic API key configured"
    fi
    
    read -p "OpenAI API Key (for GPT-4): " openai_key
    if [ ! -z "$openai_key" ]; then
        sed -i "s/# OPENAI_API_KEY=.*/OPENAI_API_KEY=$openai_key/" .env
        print_success "OpenAI API key configured"
    fi
    
    read -p "Pinecone API Key (for production vector DB): " pinecone_key
    if [ ! -z "$pinecone_key" ]; then
        sed -i "s/# PINECONE_API_KEY=.*/PINECONE_API_KEY=$pinecone_key/" .env
        sed -i "s/VECTOR_DB_TYPE=chroma/VECTOR_DB_TYPE=pinecone/" .env
        print_success "Pinecone API key configured"
    fi
}

create_directories() {
    print_step "Creating necessary directories..."
    
    mkdir -p backend/logs
    mkdir -p config
    
    print_success "Directories created"
}

build_containers() {
    print_step "Building Docker containers..."
    echo "This may take a few minutes..."
    
    $DOCKER_COMPOSE_CMD build
    print_success "Containers built successfully"
}

start_services() {
    print_step "Starting services..."
    
    $DOCKER_COMPOSE_CMD up -d
    print_success "Services started"
    
    echo
    echo -e "${GREEN}Waiting for services to be ready...${NC}"
    sleep 10
}

show_status() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════╗"
    echo -e "║       ZettaBrain is now running! 🎉          ║"
    echo -e "╚══════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}Access Points:${NC}"
    echo "  🌐 Frontend:    http://localhost:3000"
    echo "  🔌 Backend API: http://localhost:8000"
    echo "  📚 API Docs:    http://localhost:8000/docs"
    echo
    echo -e "${BLUE}Useful Commands:${NC}"
    echo "  View logs:      $DOCKER_COMPOSE_CMD logs -f"
    echo "  Stop services:  $DOCKER_COMPOSE_CMD down"
    echo "  Restart:        $DOCKER_COMPOSE_CMD restart"
    echo
    echo -e "${ORANGE}Next Steps:${NC}"
    echo "  1. Visit http://localhost:3000"
    echo "  2. Create an NFS share"
    echo "  3. Upload some documents"
    echo "  4. Try a RAG query!"
    echo
}

main() {
    print_header
    
    check_requirements
    setup_environment
    create_directories
    build_containers
    start_services
    show_status
}

# Run main function
main
