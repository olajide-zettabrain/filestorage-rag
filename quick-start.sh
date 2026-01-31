#!/bin/bash

# ZettaBrain Quick Start Script
# Use this for quick deployment without the interactive setup

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

echo -e "${ORANGE}"
echo "╔════════════════════════════════════════════╗"
echo "║    ZettaBrain NFS-RAG Quick Start          ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

# Detect docker compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}Error: Docker Compose not found${NC}"
    exit 1
fi

echo -e "${BLUE}Using: $DOCKER_COMPOSE${NC}"

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${ORANGE}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file${NC}"
    echo -e "${ORANGE}Note: Edit .env to add API keys for production LLMs${NC}"
fi

# Start services
echo -e "${BLUE}Starting services...${NC}"
$DOCKER_COMPOSE up -d

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗"
echo -e "║       ZettaBrain is running! 🎉            ║"
echo -e "╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Access Points:${NC}"
echo "  🌐 Frontend:    http://localhost:3000"
echo "  🔌 Backend API: http://localhost:8000"
echo "  📚 API Docs:    http://localhost:8000/docs"
echo ""
echo -e "${BLUE}Useful Commands:${NC}"
echo "  View logs:      $DOCKER_COMPOSE logs -f"
echo "  Stop services:  $DOCKER_COMPOSE down"
echo "  Restart:        $DOCKER_COMPOSE restart"
echo ""
