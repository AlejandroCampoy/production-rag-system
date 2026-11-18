# Architecture

The system is split into two flows: an **offline ingestion flow** (run whenever
documents change) and an **online query flow** (per user request).

## Ingestion pipeline (offline)

```
Source documents (PDF / Markdown / TXT)
        │
        ▼
  Extraction ───────► parse text + structure (headings, pages, sections)
        │
        ▼
  Chunking ─────────► split into fragments respecting structure,
        │              attach metadata (source file, section, page)
        ▼
  Embedding ────────► embed each chunk (local model or API)
        │
        ▼
  Indexing ─────────► store vectors + metadata in PostgreSQL (pgvector)
```

- **Extraction** normalizes heterogeneous formats (PDF, MD, TXT) into plain
  text with structural hints.
- **Chunking** balances fragment size against semantic coherence; metadata
  travels with every chunk so answers can cite their origin.
- Re-ingesting the same document updates rather than duplicates its chunks.

## Query pipeline (online)

```
User question (API)
        │
        ▼
  Retrieve relevant fragments ──► pgvector similarity search
        │
        ▼
  Build context ──► rank/assemble top fragments within the token budget
        │
        ▼
  Query LLM ──► question + context + instructions (interchangeable provider)
        │
        ▼
  Response with references ──► answer + citations pointing to the
                               original documents (file, section, page)
```

- Retrieval quality decides answer quality, which is why the roadmap invests
  early in chunking/metadata (V2) and later in hybrid search + reranking (V3).
- References are a first-class output, not an afterthought: every answer must
  be traceable to its source.

## Technology stack

| Component      | Technology                        |
| -------------- | --------------------------------- |
| API            | FastAPI                           |
| Orchestration  | LangChain                         |
| Database       | PostgreSQL                        |
| Vector search  | pgvector                          |
| Embeddings     | Local model or API (configurable) |
| LLM            | Interchangeable provider API      |
| Reranking      | Cross-encoder                     |
| Evaluation     | Ragas                             |
| Observability  | Langfuse                          |
| Infrastructure | Docker Compose                    |

## Design decisions

!!! quote "No vendor lock-in"
    The system must not depend on a single LLM (or embedding) provider. Model
    calls go through an abstraction layer — provider, model, and endpoint are
    configuration, not code. Switching providers (or running a local model)
    must be a config change, never a refactor.

## Planned diagrams

Conceptual diagrams to be added to this page:

- [ ] Ingestion pipeline diagram (offline flow).
- [ ] Query pipeline diagram (online flow).
- [ ] System architecture: services (API, PostgreSQL/pgvector, LLM/embeddings
      providers, Langfuse) and how they communicate in Docker Compose.

Diagrams are written in Mermaid and render natively in this site.
