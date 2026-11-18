# Roadmap

Evolution by phases — each phase delivers something usable and sets up the
next one.

| Phase | Goal |
| ----- | ---- |
| **MVP** | Load documents and answer questions (end-to-end ingestion + query flow) |
| **V2** | Improve chunking, metadata and retrieval |
| **V3** | Hybrid search and reranking |
| **V4** | Automated evaluation (Ragas) |
| **V5** | Observability (Langfuse), costs and deployment |

## MVP

Working ingestion of the Sinergym / EnergyPlus docs, vector index in pgvector,
a FastAPI `/query` endpoint returning answers with basic citations.

## V2

Structure-aware chunking (headings, sections), richer metadata, better
retrieval defaults.

## V3

Hybrid search (vector + keyword/BM25) and a cross-encoder reranking stage
before context assembly.

## V4

Evaluation harness with Ragas: golden question sets, regression tracking of
retrieval and answer quality.

## V5

Langfuse tracing of every step, cost tracking per provider, and production
deployment (Docker Compose).
