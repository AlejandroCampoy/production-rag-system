# production-rag-system

A production-oriented **Retrieval-Augmented Generation (RAG)** application that ingests technical documentation (PDF, Markdown, TXT), indexes it, and answers natural-language questions **with references to the original sources**.

The initial corpus will be the documentation of:

- [**Sinergym**](https://github.com/ugr-sail/sinergym) — a simulation environment for building energy control using Deep Reinforcement Learning, based on EnergyPlus.
- [**EnergyPlus**](https://energyplus.net/) — the building energy simulation engine Sinergym is built on.

All documentation, code comments and answers produced by the system are in **English**.

---

## 1. What this project does

Given a corpus of technical documentation and a user question, the system:

1. Finds the relevant fragments of the corpus.
2. Retrieves information from the original sources.
3. Builds a context window with those fragments.
4. Queries an LLM with the question plus the context.
5. Answers **with references** back to the original documents (file, section, location), so every claim is traceable.

This is not a demo: the goal is an **evolvable, production-grade system** — evaluated, observable, and deployable — that can grow phase by phase.

## 2. Technology stack

| Component        | Technology                            |
| ---------------- | ------------------------------------- |
| API              | FastAPI                               |
| Orchestration    | LangChain                             |
| Database         | PostgreSQL                            |
| Vector search    | pgvector                              |
| Embeddings       | Local model or API (configurable)     |
| LLM              | Interchangeable provider API          |
| Reranking        | Cross-encoder                         |
| Evaluation       | Ragas                                 |
| Observability    | Langfuse                              |
| Infrastructure   | Docker Compose                        |

**No vendor lock-in.** The system must not depend on a single LLM (or embedding) provider. From the start, model calls go through an abstraction layer — provider, model, and endpoint are configuration, not code. A concrete provider is chosen at implementation time; switching (or running a local model) must be a config change, never a refactor.

## 3. Pipeline / architecture

The system is split into two flows: an **offline ingestion flow** (run whenever documents change) and an **online query flow** (per user request). Conceptual diagrams of both flows will be added to this section (see [Planned diagrams](#6-planned-diagrams)).

### Ingestion pipeline (offline)

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

- **Extraction** normalizes heterogeneous formats (PDF, MD, TXT) into plain text with structural hints.
- **Chunking** balances fragment size against semantic coherence; metadata travels with every chunk so answers can cite their origin.
- The same document re-ingested updates rather than duplicates its chunks.

### Query pipeline (online)

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

- Retrieval quality decides answer quality, which is why the roadmap invests early in chunking/metadata (V2) and later in hybrid search + reranking (V3).
- References are a first-class output, not an afterthought: every answer must be traceable to its source.

## 4. Project layout

```
production-rag-system/
├── src/production_rag_system/   # the package: everything that ships
│   ├── config.py                # settings (provider, model, endpoint) — anti-lock-in lives here
│   ├── ingest/                  # extraction, chunking, embedding        (MVP)
│   ├── query/                   # retrieval, context building, LLM       (MVP)
│   ├── db/                      # PostgreSQL/pgvector access layer       (MVP)
│   ├── api/                     # FastAPI app                            (MVP)
│   └── eval/                    # Ragas evaluation harness               (V4)
├── tests/                       # tests mirror the package layout
├── pyproject.toml               # uv project; dependencies arrive per phase
├── uv.lock
├── Dockerfile                   # devcontainer image (multi-stage)
└── .devcontainer/               # editor-side adapter for the image
```

- `src/` contains only the package folder: what is in there is exactly what
  is built and installed — tests are imported against the installed artifact.
- Subpackages are created when their phase begins, not before.

## 5. Roadmap — evolution by phases

| Phase | Goal |
| ----- | ---- |
| **MVP** | Load documents and answer questions (end-to-end ingestion + query flow) |
| **V2** | Improve chunking, metadata and retrieval |
| **V3** | Hybrid search and reranking |
| **V4** | Automated evaluation (Ragas) |
| **V5** | Observability (Langfuse), costs and deployment |

Details:

- **MVP** — working ingestion of the Sinergym / EnergyPlus docs, vector index in pgvector, a FastAPI `/query` endpoint returning answers with basic citations.
- **V2** — structure-aware chunking (headings, sections), richer metadata, better retrieval defaults.
- **V3** — hybrid search (vector + keyword/BM25) and a cross-encoder reranking stage before context assembly.
- **V4** — evaluation harness with Ragas: golden question sets, regression tracking of retrieval and answer quality.
- **V5** — Langfuse tracing of every step, cost tracking per provider, and production deployment (Docker Compose).

## 6. Planned diagrams

Conceptual diagrams to be added to Section 3 (architecture/pipeline):

- [ ] Ingestion pipeline diagram (offline flow).
- [ ] Query pipeline diagram (online flow).
- [ ] System architecture: services (API, PostgreSQL/pgvector, LLM/embeddings providers, Langfuse) and how they communicate in Docker Compose.
