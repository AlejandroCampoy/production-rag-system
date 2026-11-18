# Production RAG System

A production-oriented **Retrieval-Augmented Generation (RAG)** application that
ingests technical documentation (PDF, Markdown, TXT), indexes it, and answers
natural-language questions **with references to the original sources**.

The initial corpus is the documentation of:

- [**Sinergym**](https://github.com/ugr-sail/sinergym) — a simulation
  environment for building energy control using Deep Reinforcement Learning,
  based on EnergyPlus.
- [**EnergyPlus**](https://energyplus.net/) — the building energy simulation
  engine Sinergym is built on.

Everything in this project — documentation, code, and the system's own
answers — is written in **English**.

## What the system does

Given a corpus of technical documentation and a user question, the system:

1. Finds the relevant fragments of the corpus.
2. Retrieves information from the original sources.
3. Builds a context window with those fragments.
4. Queries an LLM with the question plus the context.
5. Answers **with references** back to the original documents (file,
   section, location), so every claim is traceable.

This is not a demo: the goal is an **evolvable, production-grade system** —
evaluated, observable, and deployable — that grows phase by phase.

## Where to go next

| Page | What it covers |
| ---- | -------------- |
| [Architecture](architecture.md) | The ingestion and query pipelines, from documents to referenced answers |
| [Roadmap](roadmap.md) | Evolution by phases, MVP → V5 |
| [Development](development.md) | Tooling and workflow: uv, dev container, testing, docs |
