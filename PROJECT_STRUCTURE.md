# Project Structure

```
zettabrain-nfs-rag/
│
├── backend/                      # Python FastAPI Backend
│   ├── main.py                  # Main application entry point
│   ├── rag_engine.py            # RAG engine implementation
│   ├── nfs_manager.py           # NFS management functionality
│   ├── requirements.txt         # Python dependencies
│   └── Dockerfile               # Backend Docker configuration
│
├── frontend/                     # React Frontend
│   ├── public/
│   │   ├── index.html          # HTML template
│   │   └── logo.png            # ZettaBrain logo
│   ├── src/
│   │   ├── App.jsx             # Main React application
│   │   ├── App.css             # Application styles
│   │   └── index.js            # React entry point
│   ├── package.json            # Node.js dependencies
│   ├── nginx.conf              # Nginx configuration
│   └── Dockerfile              # Frontend Docker configuration
│
├── docker-compose.yml           # Development Docker Compose
├── docker-compose.prod.yml      # Production Docker Compose
├── .env.example                 # Environment variables template
├── .gitignore                   # Git ignore rules
│
├── start.sh                     # Quick start script
│
├── README.md                    # Main documentation
├── DEPLOYMENT.md                # Production deployment guide
├── API.md                       # API reference
├── LICENSE                      # MIT License
│
└── docs/                        # Additional documentation
    └── ARCHITECTURE.md          # System architecture

```

## Directory Overview

### Backend (`/backend`)

The backend is built with FastAPI and handles:
- NFS server configuration and management
- Document processing and indexing
- Vector embeddings generation
- RAG query processing
- API endpoints

**Key Files:**
- `main.py`: FastAPI application with all API routes
- `rag_engine.py`: Core RAG functionality (embeddings, vector search, LLM integration)
- `nfs_manager.py`: NFS server management (shares, exports, statistics)

### Frontend (`/frontend`)

Professional React application with:
- Clean, modern UI with ZettaBrain branding
- Dashboard with real-time statistics
- NFS management interface
- RAG query interface
- Settings panel

**Key Files:**
- `App.jsx`: Main React component with all UI logic
- `App.css`: Professional styling with orange accent color
- `nginx.conf`: Production web server configuration

### Configuration Files

- `docker-compose.yml`: Development environment setup
- `docker-compose.prod.yml`: Production-ready configuration
- `.env.example`: Template for environment variables

### Scripts

- `start.sh`: Automated setup and deployment script

## Data Storage

### Docker Volumes

- `nfs_storage`: NFS shared directories
- `rag_data`: RAG document storage and ChromaDB data
- `app_data`: Application data and configuration

### File Locations

- NFS shares: `/mnt/nfs/`
- RAG documents: `/mnt/nfs/rag_storage/`
- ChromaDB: `/mnt/nfs/rag_storage/chromadb/`
- Configuration: `/var/lib/zettabrain/`

## Component Interaction

```
┌──────────────┐
│   Browser    │
└──────┬───────┘
       │ HTTP
       ↓
┌──────────────┐
│   Frontend   │ (React on Nginx)
│   Port 80    │
└──────┬───────┘
       │ /api/*
       ↓
┌──────────────┐
│   Backend    │ (FastAPI)
│   Port 8000  │
└──────┬───────┘
       │
       ├─→ NFS Manager ──→ /etc/exports
       │
       └─→ RAG Engine
           │
           ├─→ Document Processing (LangChain)
           ├─→ Embeddings (sentence-transformers)
           ├─→ Vector DB (ChromaDB/Pinecone)
           └─→ LLM (Local/Claude/GPT)
```

## Technology Stack

### Backend
- **Framework**: FastAPI 0.109+
- **NLP**: LangChain, sentence-transformers
- **Vector DB**: ChromaDB (local), Pinecone (cloud)
- **LLMs**: Local, Claude Sonnet 4, GPT-4
- **Server**: Uvicorn with multi-worker support

### Frontend
- **Framework**: React 18
- **UI Library**: Lucide React (icons)
- **Build Tool**: React Scripts
- **Server**: Nginx (production)

### Infrastructure
- **Containerization**: Docker, Docker Compose
- **Reverse Proxy**: Nginx
- **Process Manager**: Systemd (production)

## Development Workflow

### Adding New Features

1. **Backend API Endpoint**:
   - Add route in `main.py`
   - Implement logic in appropriate manager
   - Update API documentation

2. **Frontend Component**:
   - Add component in `App.jsx`
   - Style in `App.css`
   - Connect to backend API

3. **Testing**:
   - Test backend: `pytest tests/`
   - Test frontend: `npm test`
   - Integration test: Manual testing

### Code Organization

- Keep related functionality in dedicated files
- Use clear, descriptive function names
- Add comments for complex logic
- Follow PEP 8 (Python) and Airbnb (JavaScript) style guides

## Configuration Management

### Environment Variables

All sensitive configuration in `.env`:
- API keys
- Database credentials
- Service endpoints

### Application Configuration

RAG configuration stored in:
- File: `/mnt/nfs/rag_storage/config.json`
- Managed via Settings UI or API

## Security Considerations

### Development
- CORS enabled for `localhost`
- No authentication required
- Debug mode enabled

### Production
- Restrict CORS to specific domains
- Implement JWT authentication
- Enable rate limiting
- Use HTTPS only
- Secure API keys in environment

## Monitoring and Logging

### Logs Location
- Backend: Docker logs or `/app/logs/`
- Frontend: Nginx access/error logs
- System: `journalctl -u zettabrain`

### Health Checks
- Backend: `/api/health`
- Frontend: `/` (returns 200)

## Performance Tuning

### Backend
- Adjust workers: `--workers 4`
- Optimize batch processing
- Cache frequently accessed data

### Frontend
- Enable production build
- Use CDN for assets
- Enable gzip compression

### Database
- Tune ChromaDB settings
- Optimize vector search parameters
- Regular maintenance

## Backup Strategy

### What to Backup
1. RAG documents: `/mnt/nfs/rag_storage/`
2. Vector database: ChromaDB data
3. Configuration: `/var/lib/zettabrain/`
4. NFS shares configuration

### Backup Script
See `DEPLOYMENT.md` for automated backup setup.

## Troubleshooting

### Common Issues

1. **Backend not starting**
   - Check logs: `docker-compose logs backend`
   - Verify environment variables
   - Check port availability

2. **Frontend not connecting**
   - Verify backend is running
   - Check CORS configuration
   - Inspect browser console

3. **RAG not working**
   - Check embedding model downloaded
   - Verify storage permissions
   - Check API keys (if using cloud LLMs)

### Debug Mode

Enable debug logging:
```bash
# Backend
export LOG_LEVEL=debug

# Frontend
export REACT_APP_DEBUG=true
```

## Contributing

See `CONTRIBUTING.md` for guidelines on:
- Code style
- Commit messages
- Pull request process
- Testing requirements
