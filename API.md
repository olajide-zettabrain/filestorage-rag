# API Reference

Complete API documentation for ZettaBrain NFS-RAG Platform.

Base URL: `http://localhost:8000`

Interactive API docs: `http://localhost:8000/docs`

## Authentication

Currently, the API is open. For production, implement JWT authentication.

## Response Format

All responses follow this structure:

```json
{
  "status": "success|error",
  "data": {},
  "message": "Optional message"
}
```

## Endpoints

### Health Check

#### GET /api/health

Check system health status.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-01-24T10:30:00",
  "services": {
    "nfs": true,
    "rag": true
  }
}
```

---

## NFS Management

### List NFS Shares

#### GET /api/nfs/shares

Get all configured NFS shares.

**Response:**
```json
{
  "shares": [
    {
      "id": "share_20250124_103000",
      "path": "/mnt/data",
      "client": "192.168.1.0/24",
      "options": "rw,sync,no_subtree_check",
      "status": "active",
      "created_at": "2025-01-24T10:30:00"
    }
  ]
}
```

### Create NFS Share

#### POST /api/nfs/shares

Create a new NFS share.

**Request Body:**
```json
{
  "path": "/mnt/data",
  "client": "192.168.1.0/24",
  "options": "rw,sync,no_subtree_check"
}
```

**Response:**
```json
{
  "message": "Share created successfully",
  "share": {
    "id": "share_20250124_103000",
    "path": "/mnt/data",
    "client": "192.168.1.0/24",
    "options": "rw,sync,no_subtree_check",
    "status": "active",
    "created_at": "2025-01-24T10:30:00"
  }
}
```

### Update NFS Share

#### PUT /api/nfs/shares/{share_id}

Update an existing NFS share.

**Request Body:**
```json
{
  "options": "rw,sync,no_subtree_check,no_root_squash",
  "client": "192.168.1.100"
}
```

### Delete NFS Share

#### DELETE /api/nfs/shares/{share_id}

Delete an NFS share.

**Response:**
```json
{
  "message": "Share deleted successfully"
}
```

### Get NFS Statistics

#### GET /api/nfs/stats

Get NFS server statistics.

**Response:**
```json
{
  "total_shares": 5,
  "active_shares": 5,
  "service_status": "running",
  "disk_usage": "50% used",
  "last_updated": "2025-01-24T10:30:00"
}
```

---

## RAG Platform

### Upload Document

#### POST /api/rag/upload

Upload and process a document for RAG.

**Form Data:**
- `file`: Document file (PDF, DOCX, TXT, CSV)

**Response:**
```json
{
  "filename": "document.pdf",
  "status": "success",
  "chunks_created": 25,
  "message": "Document processed and 25 chunks indexed"
}
```

### Query Documents

#### POST /api/rag/query

Query the RAG system.

**Request Body:**
```json
{
  "query": "What are the main features?",
  "model_provider": "local",
  "top_k": 5
}
```

**Parameters:**
- `query` (string, required): Query text
- `model_provider` (string): "local", "claude", or "openai"
- `top_k` (integer): Number of results to retrieve (default: 5)

**Response:**
```json
{
  "query": "What are the main features?",
  "response": "Based on the retrieved information...",
  "sources": [
    {
      "text": "Context snippet...",
      "metadata": {
        "source": "/path/to/document.pdf",
        "chunk_index": 0
      },
      "relevance_score": 0.95
    }
  ],
  "model_provider": "local"
}
```

### List Documents

#### GET /api/rag/documents

List all indexed documents.

**Response:**
```json
{
  "documents": [
    {
      "id": "document1",
      "path": "/mnt/nfs/rag_storage/document1.pdf",
      "chunks": 25,
      "indexed_at": "2025-01-24T10:30:00"
    }
  ]
}
```

### Delete Document

#### DELETE /api/rag/documents/{document_id}

Delete a document from the RAG system.

**Response:**
```json
{
  "message": "Document deleted successfully"
}
```

### Get RAG Configuration

#### GET /api/rag/config

Get current RAG configuration.

**Response:**
```json
{
  "vector_db": "chromadb",
  "embedding_model": "all-MiniLM-L6-v2",
  "llm_provider": "local",
  "anthropic_api_key": "***key",
  "openai_api_key": "***key",
  "pinecone_api_key": "",
  "collection_name": "zettabrain_docs"
}
```

### Update RAG Configuration

#### POST /api/rag/config

Update RAG configuration.

**Request Body:**
```json
{
  "vector_db": "pinecone",
  "llm_provider": "claude",
  "anthropic_api_key": "sk-ant-...",
  "pinecone_api_key": "your-pinecone-key",
  "pinecone_environment": "us-west1-gcp"
}
```

**Response:**
```json
{
  "message": "Configuration updated successfully",
  "config": {
    "vector_db": "pinecone",
    "llm_provider": "claude",
    ...
  }
}
```

### Get RAG Statistics

#### GET /api/rag/stats

Get RAG system statistics.

**Response:**
```json
{
  "total_documents": 10,
  "total_chunks": 250,
  "vector_db": "chromadb",
  "embedding_model": "all-MiniLM-L6-v2",
  "llm_provider": "local"
}
```

---

## System Management

### Restart NFS Service

#### POST /api/system/restart-nfs

Restart the NFS service.

**Response:**
```json
{
  "message": "NFS service restarted successfully",
  "result": true
}
```

### Get System Logs

#### GET /api/system/logs?lines=100

Get system logs.

**Query Parameters:**
- `lines` (integer): Number of log lines to retrieve (default: 100)

**Response:**
```json
{
  "logs": [
    "2025-01-24 10:30:00 - INFO - Service started",
    "2025-01-24 10:30:01 - INFO - RAG engine initialized"
  ]
}
```

---

## Error Responses

All errors follow this format:

```json
{
  "detail": "Error message description"
}
```

### Common HTTP Status Codes

- `200 OK`: Success
- `201 Created`: Resource created
- `400 Bad Request`: Invalid request
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

---

## Rate Limiting

Currently no rate limiting. For production, implement rate limiting:
- 100 requests per minute for general endpoints
- 10 requests per minute for RAG queries

---

## Examples

### cURL Examples

**Upload a document:**
```bash
curl -X POST http://localhost:8000/api/rag/upload \
  -F "file=@document.pdf"
```

**Query documents:**
```bash
curl -X POST http://localhost:8000/api/rag/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is NFS?",
    "model_provider": "local",
    "top_k": 5
  }'
```

**Create NFS share:**
```bash
curl -X POST http://localhost:8000/api/nfs/shares \
  -H "Content-Type: application/json" \
  -d '{
    "path": "/mnt/data",
    "client": "192.168.1.0/24",
    "options": "rw,sync,no_subtree_check"
  }'
```

### Python Examples

```python
import requests

# Upload document
with open('document.pdf', 'rb') as f:
    response = requests.post(
        'http://localhost:8000/api/rag/upload',
        files={'file': f}
    )
print(response.json())

# Query documents
response = requests.post(
    'http://localhost:8000/api/rag/query',
    json={
        'query': 'What is NFS?',
        'model_provider': 'local',
        'top_k': 5
    }
)
print(response.json())
```

### JavaScript Examples

```javascript
// Upload document
const formData = new FormData();
formData.append('file', fileInput.files[0]);

fetch('http://localhost:8000/api/rag/upload', {
  method: 'POST',
  body: formData
})
.then(res => res.json())
.then(data => console.log(data));

// Query documents
fetch('http://localhost:8000/api/rag/query', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    query: 'What is NFS?',
    model_provider: 'local',
    top_k: 5
  })
})
.then(res => res.json())
.then(data => console.log(data));
```
