#!/bin/bash

# ZettaBrain NFS-RAG Platform - Quick Start Script
# This script automates the initial setup and deployment

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║       ZettaBrain NFS-RAG Platform - Quick Start           ║"
echo "║                                                            ║"
echo "║  Production-Ready NFS Server with AI-Powered RAG          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}ERROR: Please do not run this script as root${NC}"
    exit 1
fi

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check prerequisites
echo "Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    echo "Please install Docker: curl -fsSL https://get.docker.com | sh"
    exit 1
fi
print_success "Docker is installed"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed"
    echo "Please install Docker Compose: sudo apt install docker-compose-plugin"
    exit 1
fi
print_success "Docker Compose is installed"

# Ask for deployment mode
echo ""
echo "Select deployment mode:"
echo "1) Development (with hot reload)"
echo "2) Production (optimized)"
read -p "Enter choice [1-2]: " deploy_mode

case $deploy_mode in
    1)
        COMPOSE_FILE="docker-compose.yml"
        MODE="development"
        ;;
    2)
        COMPOSE_FILE="docker-compose.prod.yml"
        MODE="production"
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

print_success "Selected $MODE mode"

# Check for .env file
echo ""
if [ ! -f .env ]; then
    print_warning ".env file not found. Creating from template..."
    cp .env.example .env
    print_success "Created .env file"
    echo ""
    print_warning "IMPORTANT: Edit .env file with your API keys before production use!"
    echo "API keys needed (optional):"
    echo "  - ANTHROPIC_API_KEY (for Claude)"
    echo "  - OPENAI_API_KEY (for GPT)"
    echo "  - PINECONE_API_KEY (for Pinecone vector DB)"
    echo ""
    read -p "Do you want to edit .env now? [y/N]: " edit_env
    if [[ $edit_env =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} .env
    fi
else
    print_success ".env file found"
fi

# Create necessary directories for production
if [ "$MODE" = "production" ]; then
    echo ""
    echo "Creating production directories..."
    sudo mkdir -p /mnt/zettabrain/{nfs,rag}
    sudo mkdir -p /var/lib/zettabrain
    sudo chown -R $USER:$USER /mnt/zettabrain /var/lib/zettabrain
    print_success "Production directories created"
fi

# Pull/Build images
echo ""
echo "Building Docker images..."
docker-compose -f $COMPOSE_FILE build
print_success "Docker images built successfully"

# Start services
echo ""
echo "Starting services..."
docker-compose -f $COMPOSE_FILE up -d
print_success "Services started"

# Wait for services to be healthy
echo ""
echo "Waiting for services to be ready..."
sleep 10

# Check backend health
MAX_RETRIES=30
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:8000/api/health > /dev/null 2>&1; then
        print_success "Backend is healthy"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "Waiting for backend... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    print_error "Backend failed to start. Check logs: docker-compose logs backend"
    exit 1
fi

# Check frontend
if curl -f http://localhost > /dev/null 2>&1; then
    print_success "Frontend is healthy"
else
    print_warning "Frontend may not be ready yet. Wait a few seconds and try again."
fi

# Display access information
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                 🎉 Setup Complete! 🎉                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Access your ZettaBrain platform at:"
echo ""
echo "  📱 Frontend:      http://localhost"
echo "  🔧 Backend API:   http://localhost:8000"
echo "  📚 API Docs:      http://localhost:8000/docs"
echo ""
echo "Default features:"
echo "  ✓ NFS Server Management"
echo "  ✓ Document Upload & Processing"
echo "  ✓ Local RAG (no API key needed)"
echo "  ✓ ChromaDB Vector Store"
echo ""
echo "Optional features (configure in Settings):"
echo "  • Claude Sonnet 4 (requires Anthropic API key)"
echo "  • GPT-4 (requires OpenAI API key)"
echo "  • Pinecone Vector DB (requires Pinecone API key)"
echo ""
echo "Useful commands:"
echo "  • View logs:         docker-compose logs -f"
echo "  • Stop services:     docker-compose down"
echo "  • Restart services:  docker-compose restart"
echo "  • Update code:       git pull && docker-compose up -d --build"
echo ""

if [ "$MODE" = "production" ]; then
    echo "Production deployment tips:"
    echo "  1. Configure SSL/TLS (see DEPLOYMENT.md)"
    echo "  2. Set up reverse proxy (nginx)"
    echo "  3. Configure backups (see DEPLOYMENT.md)"
    echo "  4. Enable monitoring"
    echo "  5. Review security checklist in DEPLOYMENT.md"
    echo ""
fi

print_success "Setup completed successfully!"
