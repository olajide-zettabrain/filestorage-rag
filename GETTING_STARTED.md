# Getting Started with ZettaBrain NFS-RAG Platform

Welcome! This guide will help you get ZettaBrain up and running in minutes.

## 📋 Before You Start

### System Requirements

**Minimum:**
- Docker & Docker Compose installed
- 4GB RAM
- 10GB free disk space

**Check Your Docker:**
```bash
docker --version          # Should be 20.10+
docker compose version    # Should be v2.0+ (plugin)
# OR
docker-compose --version  # Should be 1.29+ (standalone)
```

## 🚀 Three Ways to Start

### Method 1: Quick Start ⚡ (2 minutes)

```bash
cd zettabrain-nfs-rag
chmod +x quick-start.sh
./quick-start.sh
```

Then open http://localhost:3000

**This uses default settings:**
- Local models (free, no API keys needed)
- ChromaDB vector storage
- Works offline

### Method 2: Interactive Setup 🎯 (5 minutes)

```bash
cd zettabrain-nfs-rag
chmod +x setup.sh
./setup.sh
```

Follow prompts to configure API keys and providers.

### Method 3: Manual 🔧 (For advanced users)

```bash
cd zettabrain-nfs-rag
cp .env.example .env
# Edit .env if needed
docker compose up -d
```

## ✅ Verify It's Working

```bash
# Check services
docker compose ps

# Test backend
curl http://localhost:8000/health

# Open frontend
open http://localhost:3000  # macOS
xdg-open http://localhost:3000  # Linux
```

You should see the ZettaBrain dashboard!

## 🎯 Your First Steps

### 1. Upload a Document

1. Click **"Documents"** in sidebar
2. Click **"Upload Document"**
3. Select a PDF, DOCX, or TXT file
4. Wait for it to process

### 2. Ask a Question

1. Click **"RAG Query"** in sidebar
2. Type: "What is this document about?"
3. Click **"Ask Question"**
4. See AI-generated answer with sources

### 3. Create NFS Share (Optional)

1. Click **"NFS Management"**
2. Click **"Create Share"**
3. Fill in details
4. Done!

## ⚙️ Configuration

### Default (Free, Offline)
```
Vector DB: ChromaDB (local)
LLM: Local models (free)
```
No API keys needed!

### Production (Better Quality)
Edit `.env`:
```bash
LLM_PROVIDER=anthropic
ANTHROPIC_API_KEY=sk-ant-your-key

VECTOR_DB_TYPE=pinecone
PINECONE_API_KEY=your-key
```

Restart: `docker compose restart`

## 🛠️ Common Commands

```bash
# Start
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f

# Restart
docker compose restart
```

## 🐛 Problems?

```bash
# View logs
docker compose logs -f backend

# Clean restart
docker compose down -v
docker compose up -d
```

See **TROUBLESHOOTING.md** for more help.

## 📚 Learn More

- **README.md** - Full documentation
- **TROUBLESHOOTING.md** - Fix common issues
- **docs/PRODUCTION.md** - Deploy to production
- **API Docs** - http://localhost:8000/docs

## 🎉 You're Ready!

Start uploading documents and asking questions!

**Questions?** See TROUBLESHOOTING.md or check the logs.

---

Made with ❤️ for ZettaBrain
