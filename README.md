# ZettaBrain NFS-RAG Platform

<div align="center">
  <img src="frontend/public/zetabrain_logo.png" alt="ZettaBrain Logo" height="80"/>
  <h3>Production-Ready NFS Server Management with Integrated RAG Platform</h3>
</div>

## 🎯 Overview

ZettaBrain is a comprehensive, production-ready platform that combines:
- **NFS Server Management** - Full-featured web interface for managing NFS shares
- **RAG Platform** - Retrieval-Augmented Generation system for document Q&A
- **Flexible Architecture** - Support for both lightweight and production-grade components

### Key Features

✅ **NFS Management**
- Create, update, and delete NFS shares via web UI
- Real-time server monitoring
- Client connection tracking
- System resource monitoring

✅ **RAG Capabilities**
- Document upload and processing (PDF, DOCX, TXT, MD, PPTX, XLSX)
- Semantic search across documents
- Multiple LLM provider support (Local, Claude Sonnet, GPT-4)
- Multiple vector database support (ChromaDB, FAISS, Pinecone, Qdrant, Weaviate)

✅ **Production Ready**
- Docker containerization
- Database persistence (PostgreSQL)
- Redis caching
- Async API with FastAPI
- Professional React UI with Tailwind CSS

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend (React)                         │
│              Professional White UI with Tailwind             │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   Backend (FastAPI)                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ NFS Manager  │  │  RAG Engine  │  │   Database   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────┬──────────────────┬────────────────────┬───────────┘
          │                  │                    │
          ▼                  ▼                    ▼
┌──────────────────┐  ┌──────────────┐  ┌──────────────┐
│   NFS Server     │  │ Vector Store │  │  PostgreSQL  │
│  /mnt/nfs/...    │  │ (Chroma/etc) │  │   + Redis    │
└──────────────────┘  └──────────────┘  └──────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- 4GB+ RAM
- 10GB+ free disk space

### Installation

**Option 1: Quick Start (Fastest)**
```bash
cd zettabrain-nfs-rag
chmod +x quick-start.sh
./quick-start.sh
```

**Option 2: Interactive Setup (Recommended)**
```bash
cd zettabrain-nfs-rag
chmod +x setup.sh
./setup.sh
```

**Option 3: Manual**
```bash
cd zettabrain-nfs-rag
cp .env.example .env
# Edit .env if needed
docker compose up -d
```

### Access the Platform
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

## 📦 Component Options

### Vector Databases

**Lightweight (Default)**
- **ChromaDB** - Fast, local vector store (recommended for development)
- **FAISS** - High-performance similarity search

**Production**
- **Pinecone** - Managed vector database
- **Qdrant** - Open-source vector search engine
- **Weaviate** - ML-first vector database

### LLM Providers

**Lightweight (Default)**
- **Local Models** - sentence-transformers + flan-t5-base
  - No API costs
  - Works offline
  - Lower quality responses

**Production**
- **Anthropic Claude Sonnet** - High-quality responses
- **OpenAI GPT-4** - Excellent reasoning
  - Requires API key
  - Usage-based costs

## 🔧 Configuration

### Basic Configuration

Edit `.env` file:

```bash
# Use lightweight components (free)
VECTOR_DB_TYPE=chroma
LLM_PROVIDER=local

# Or use production components
VECTOR_DB_TYPE=pinecone
LLM_PROVIDER=anthropic
ANTHROPIC_API_KEY=your-key-here
```

### Advanced Configuration

#### NFS Server
```bash
NFS_BASE_PATH=/mnt/nfs
NFS_SERVICE_NAME=nfs-server
```

#### RAG Settings
```bash
RAG_CHUNK_SIZE=512
RAG_CHUNK_OVERLAP=50
RAG_TOP_K=5
```

#### Database
```bash
DATABASE_URL=postgresql+asyncpg://user:pass@host:5432/db
REDIS_URL=redis://localhost:6379/0
```

## 📖 Usage Guide

### 1. NFS Management

**Create a Share:**
1. Navigate to "NFS Management"
2. Click "Create Share"
3. Fill in details:
   - Name: `data-share`
   - Path: `/mnt/nfs/data`
   - Client: `*` (or specific IP)
4. Click "Create"

**Manage Server:**
- Start/Stop/Restart NFS server
- Monitor active connections
- View system resources

### 2. Document Management

**Upload Documents:**
1. Navigate to "Documents"
2. Click "Upload Document"
3. Select file (PDF, DOCX, TXT, etc.)
4. Wait for processing to complete

**Supported Formats:**
- PDF, DOCX, TXT, MD
- PPTX, XLSX, CSV

### 3. RAG Queries

**Ask Questions:**
1. Navigate to "RAG Query"
2. Select LLM provider (Local, Claude, or GPT-4)
3. Type your question
4. Click "Ask Question"

**Example Queries:**
- "What are the main topics discussed in the uploaded documents?"
- "Summarize the financial data from Q3 report"
- "What security measures are mentioned?"

## 🛠️ Development

### Backend Development

```bash
cd backend
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt
python main.py
```

### Frontend Development

```bash
cd frontend
npm install
npm run dev
```

### Running Tests

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
npm test
```

## 📊 API Documentation

Interactive API documentation available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### Key Endpoints

**NFS Management:**
- `GET /api/v1/nfs/shares` - List all shares
- `POST /api/v1/nfs/shares` - Create share
- `DELETE /api/v1/nfs/shares/{id}` - Delete share
- `POST /api/v1/nfs/server/start` - Start NFS server

**Documents:**
- `POST /api/v1/documents/upload` - Upload document
- `GET /api/v1/documents` - List documents
- `DELETE /api/v1/documents/{id}` - Delete document

**RAG:**
- `POST /api/v1/query` - Query documents
- `GET /api/v1/query/history` - Query history

## 🔒 Security

- API authentication (configure in `.env`)
- CORS configuration for allowed origins
- Secure password hashing
- Environment variable configuration
- Docker network isolation

## 📈 Performance

**Lightweight Configuration:**
- ChromaDB vector store
- Local embedding models
- Minimal RAM: ~2GB
- CPU-only inference

**Production Configuration:**
- Pinecone/Qdrant vector store
- Claude Sonnet or GPT-4
- Recommended RAM: 8GB+
- GPU optional but recommended

## 🐛 Troubleshooting

### NFS Server Won't Start
```bash
# Check NFS service
sudo systemctl status nfs-server

# Check permissions
sudo chmod 755 /mnt/nfs
```

### Document Processing Fails
```bash
# Check backend logs
docker compose logs backend

# Verify file format support
# Ensure file size < 100MB
```

### Low Memory Issues
```bash
# Use lightweight components
VECTOR_DB_TYPE=faiss
LLM_PROVIDER=local

# Reduce chunk size
RAG_CHUNK_SIZE=256
```

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- FastAPI for the excellent web framework
- LangChain for RAG utilities
- React and Tailwind CSS for the UI
- ChromaDB, Pinecone, Qdrant, Weaviate for vector storage
- Anthropic and OpenAI for LLM APIs

## 📧 Support

For issues and questions:
- GitHub Issues: [Create an issue]
- Documentation: See `/docs` folder
- Email: support@zettabrain.com

---

<div align="center">
  Made with ❤️ by ZettaBrain Team
</div>
