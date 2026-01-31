# ZettaBrain NFS-RAG Troubleshooting Guide

## Common Setup Issues

### 1. Docker Compose Version Issues

**Error:** "Docker Compose is not installed" even though it is

**Cause:** You have the newer Docker Compose plugin (`docker compose`) instead of the standalone version (`docker-compose`)

**Solution:** The setup script now automatically detects both versions. If you still have issues:

```bash
# Check which version you have
docker compose version    # Plugin version (newer)
docker-compose version    # Standalone version (older)

# If you have the plugin version, use:
docker compose up -d

# If you have the standalone version, use:
docker-compose up -d
```

### 2. "version is obsolete" Warning

**Error:** `WARN: the attribute 'version' is obsolete`

**Solution:** This has been fixed. The docker-compose.yml files no longer include the version attribute. If you still see this:

```bash
# Make sure you have the latest files
git pull

# Or manually remove the version line from docker-compose.yml
sed -i '1,2d' docker-compose.yml
```

### 3. Permission Denied Errors

**Error:** Permission denied when running setup.sh

**Solution:**
```bash
chmod +x setup.sh
./setup.sh

# If you still get errors with docker commands:
sudo usermod -aG docker $USER
newgrp docker
```

### 4. Port Already in Use

**Error:** Port 8000 or 3000 already in use

**Solution:**
```bash
# Check what's using the ports
sudo lsof -i :8000
sudo lsof -i :3000

# Stop the conflicting service or change ports in .env:
PORT=8001  # For backend
# And update frontend/vite.config.js for frontend port
```

### 5. Database Connection Errors

**Error:** Can't connect to PostgreSQL

**Solution:**
```bash
# Check if PostgreSQL container is running
docker compose ps

# Check PostgreSQL logs
docker compose logs postgres

# Restart PostgreSQL
docker compose restart postgres

# If persistent, rebuild:
docker compose down -v
docker compose up -d
```

### 6. Out of Memory Errors

**Error:** Container killed or OOM (Out of Memory)

**Solution:**
```bash
# Use lightweight configuration in .env:
VECTOR_DB_TYPE=faiss  # Instead of chroma
LLM_PROVIDER=local
RAG_CHUNK_SIZE=256    # Smaller chunks

# Or increase Docker memory:
# Docker Desktop -> Settings -> Resources -> Memory -> 4GB+
```

### 7. NFS Server Won't Start

**Error:** NFS server fails to start in container

**Solution:**
```bash
# NFS requires privileged mode, update docker-compose.yml:
backend:
  privileged: true
  cap_add:
    - SYS_ADMIN

# Or run NFS on host system instead of container
sudo apt install nfs-kernel-server
sudo systemctl start nfs-server
```

### 8. Document Upload Fails

**Error:** Document upload returns 500 error

**Solution:**
```bash
# Check if directory exists and has permissions
docker compose exec backend ls -la /mnt/nfs/rag_documents

# Check backend logs
docker compose logs backend | grep -i error

# Verify file format is supported
# Supported: .pdf, .docx, .txt, .md, .pptx, .xlsx, .csv

# Check file size (must be < 100MB by default)
```

### 9. RAG Query Returns No Results

**Error:** Query returns 0 documents even though documents are uploaded

**Solution:**
```bash
# Check if documents are indexed
docker compose exec backend python -c "from models import Document; import asyncio; from sqlalchemy import select; from models import AsyncSessionLocal; async def check(): async with AsyncSessionLocal() as db: result = await db.execute(select(Document)); docs = result.scalars().all(); print(f'Total docs: {len(docs)}'); print(f'Indexed: {sum(1 for d in docs if d.is_indexed)}'); asyncio.run(check())"

# Check vector database
docker compose exec backend ls -la /mnt/nfs/vector_db/chroma

# Reprocess documents if needed (delete and re-upload)
```

### 10. API Keys Not Working

**Error:** Anthropic or OpenAI API returns 401/403

**Solution:**
```bash
# Verify API keys in .env
cat .env | grep API_KEY

# Make sure there are no quotes around the keys
ANTHROPIC_API_KEY=sk-ant-xxx  # Correct
ANTHROPIC_API_KEY="sk-ant-xxx"  # Wrong

# Restart services after changing .env
docker compose restart backend
```

## Quick Diagnostic Commands

```bash
# Check all containers are running
docker compose ps

# View logs for all services
docker compose logs -f

# View logs for specific service
docker compose logs -f backend

# Check backend health
curl http://localhost:8000/health

# Check API status
curl http://localhost:8000/api/v1/status

# Restart everything
docker compose restart

# Complete reset (WARNING: deletes all data)
docker compose down -v
rm -rf /mnt/nfs/vector_db/*
docker compose up -d
```

## Performance Issues

### Slow Document Processing
```bash
# Reduce chunk size in .env
RAG_CHUNK_SIZE=256
RAG_CHUNK_OVERLAP=25

# Use FAISS instead of ChromaDB
VECTOR_DB_TYPE=faiss
```

### High CPU Usage
```bash
# Reduce worker count in .env
WORKERS=2

# Use production LLM instead of local
LLM_PROVIDER=anthropic  # Offload to API
```

### High Memory Usage
```bash
# Monitor memory
docker stats

# Limit container memory in docker-compose.yml:
backend:
  mem_limit: 4g
```

## Still Having Issues?

1. **Check logs:** `docker compose logs -f backend`
2. **Verify configuration:** `cat .env`
3. **Check Docker resources:** Docker Desktop -> Settings -> Resources
4. **Restart services:** `docker compose restart`
5. **Fresh start:** `docker compose down -v && docker compose up -d`

## Getting Help

- **Documentation:** See README.md and docs/PRODUCTION.md
- **API Docs:** http://localhost:8000/docs
- **Logs:** `docker compose logs -f`
- **GitHub Issues:** Create an issue with logs and .env (remove API keys)

## System Requirements

**Minimum:**
- 4GB RAM
- 2 CPU cores
- 10GB free disk space
- Docker 20.10+
- Docker Compose v2.0+

**Recommended:**
- 8GB+ RAM
- 4+ CPU cores
- 50GB+ free disk space
- SSD storage
- Ubuntu 20.04+ or similar

---

Last Updated: 2025-01-25
