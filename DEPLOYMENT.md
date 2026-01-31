# Production Deployment Guide

This guide covers deploying ZettaBrain NFS-RAG Platform in a production environment.

## Table of Contents
1. [Server Requirements](#server-requirements)
2. [Installation](#installation)
3. [SSL/TLS Configuration](#ssltls-configuration)
4. [Reverse Proxy Setup](#reverse-proxy-setup)
5. [Database Backup](#database-backup)
6. [Monitoring](#monitoring)
7. [Scaling](#scaling)

## Server Requirements

### Minimum Requirements
- **CPU**: 4 cores
- **RAM**: 8 GB
- **Storage**: 100 GB SSD
- **OS**: Ubuntu 20.04 LTS or later

### Recommended Requirements
- **CPU**: 8+ cores
- **RAM**: 16+ GB
- **Storage**: 500 GB+ SSD
- **OS**: Ubuntu 22.04 LTS

## Installation

### 1. System Preparation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose-plugin

# Create application user
sudo useradd -r -s /bin/bash -d /opt/zettabrain zettabrain
sudo mkdir -p /opt/zettabrain
sudo chown zettabrain:zettabrain /opt/zettabrain
```

### 2. Application Deployment

```bash
# Switch to application user
sudo su - zettabrain

# Clone repository
cd /opt/zettabrain
git clone https://github.com/yourusername/zettabrain-nfs-rag.git
cd zettabrain-nfs-rag

# Configure environment
cp .env.example .env
nano .env  # Edit with production values

# Build and start services
docker-compose -f docker-compose.prod.yml up -d
```

### 3. Systemd Service Setup

Create `/etc/systemd/system/zettabrain.service`:

```ini
[Unit]
Description=ZettaBrain NFS-RAG Platform
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/zettabrain/zettabrain-nfs-rag
ExecStart=/usr/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/bin/docker-compose -f docker-compose.prod.yml down
User=zettabrain

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable zettabrain
sudo systemctl start zettabrain
```

## SSL/TLS Configuration

### Using Let's Encrypt with Certbot

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal
sudo systemctl enable certbot.timer
```

## Reverse Proxy Setup

### Nginx Configuration

Create `/etc/nginx/sites-available/zettabrain`:

```nginx
upstream backend {
    server localhost:8000;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Frontend
    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API
    location /api {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Increase timeout for RAG operations
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # File upload limits
    client_max_body_size 100M;
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/zettabrain /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Database Backup

### Automated Backup Script

Create `/opt/zettabrain/backup.sh`:

```bash
#!/bin/bash

BACKUP_DIR="/opt/zettabrain/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="zettabrain_backup_${DATE}.tar.gz"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup Docker volumes
docker run --rm \
  -v zettabrain-nfs-rag_rag_data:/data \
  -v zettabrain-nfs-rag_app_data:/app \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/$BACKUP_FILE /data /app

# Remove backups older than 7 days
find $BACKUP_DIR -name "zettabrain_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_FILE"
```

Add to crontab:
```bash
sudo crontab -e
# Add: 0 2 * * * /opt/zettabrain/backup.sh
```

## Monitoring

### Health Check Script

Create `/opt/zettabrain/healthcheck.sh`:

```bash
#!/bin/bash

# Check backend health
if ! curl -f http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "Backend health check failed"
    docker-compose -f /opt/zettabrain/zettabrain-nfs-rag/docker-compose.prod.yml restart backend
    exit 1
fi

# Check frontend
if ! curl -f http://localhost/ > /dev/null 2>&1; then
    echo "Frontend health check failed"
    docker-compose -f /opt/zettabrain/zettabrain-nfs-rag/docker-compose.prod.yml restart frontend
    exit 1
fi

echo "All services healthy"
```

Add to crontab:
```bash
*/5 * * * * /opt/zettabrain/healthcheck.sh
```

### Prometheus Monitoring (Optional)

Add to `docker-compose.prod.yml`:

```yaml
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
```

## Scaling

### Horizontal Scaling

Update `docker-compose.prod.yml`:

```yaml
services:
  backend:
    deploy:
      replicas: 4
    environment:
      - WORKERS=2
```

### Load Balancer Setup

Use Nginx for load balancing:

```nginx
upstream backend_cluster {
    least_conn;
    server backend1:8000;
    server backend2:8000;
    server backend3:8000;
}
```

## Performance Tuning

### Docker Resources

Update daemon.json:
```json
{
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
```

### Database Optimization

For ChromaDB:
```python
# Increase batch size
batch_size = 100

# Enable compression
collection_metadata={"hnsw:space": "cosine", "hnsw:M": 16}
```

## Security Checklist

- [ ] SSL/TLS certificates configured
- [ ] Firewall rules in place
- [ ] API keys stored securely
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] Regular security updates
- [ ] Backup system tested
- [ ] Monitoring alerts configured
- [ ] Access logs enabled
- [ ] DDoS protection (Cloudflare)

## Troubleshooting

### View Logs
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
journalctl -u zettabrain -f
```

### Restart Services
```bash
sudo systemctl restart zettabrain
# Or
docker-compose restart
```

### Database Issues
```bash
# Backup and rebuild
docker-compose down
docker volume ls
docker-compose up -d --build
```

## Support

For production support:
- Email: support@zettabrain.com
- Slack: zettabrain.slack.com
- Documentation: docs.zettabrain.com
