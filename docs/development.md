# Development

## Prerequisites

Nothing on the host except Docker and an editor: development is fully
**container-based**. Open the repository in the [dev
container](https://containers.dev/) (VS Code: *Dev Containers: Reopen in
Container*) and you have the exact same environment as everyone else.

The image is built from the multi-stage `Dockerfile` at the repository root
and is self-contained — usable with or without VS Code. Git, GitHub CLI and
SSH access to GitHub work out of the box; your SSH keys never leave the host.

## Python tooling

The project is managed with [uv](https://docs.astral.sh/uv/) and
`pyproject.toml` (src layout):

| Command | What it does |
| ------- | ------------ |
| `uv sync` | Installs dependencies from `uv.lock` (runs automatically on container creation) |
| `uv add <pkg>` | Adds a runtime dependency |
| `uv add --group dev <pkg>` | Adds a development-only dependency |
| `uv run <cmd>` | Runs a command inside the project environment |
| `uv run pytest` | Runs the tests |

Python is pinned in `.python-version` (3.13). If you ever bump it, update the
`Dockerfile` (two references) and re-sync in the same commit.

## Project layout

```
production-rag-system/
├── src/production_rag_system/   # the package: everything that ships
├── tests/                       # tests mirror the package layout
├── docs/                        # this documentation (MkDocs)
├── pyproject.toml               # uv project; dependencies arrive per phase
├── uv.lock
├── mkdocs.yml                   # documentation site configuration
├── Dockerfile                   # devcontainer image (multi-stage)
└── .devcontainer/               # editor-side adapter for the image
```

- `src/` contains only the package folder: what is in there is exactly what
  is built and installed. Tests are imported against the installed artifact.
- Subpackages are created when their phase begins, not before.

## Versioning

The project version has a **single source of truth**: `pyproject.toml`. It is
read at runtime via `importlib.metadata`. After bumping it, run `uv sync` so
the installed metadata is refreshed.

## Tests

Tests live in `tests/` at the repository root (outside the package) and run
with `uv run pytest`.

## Documentation

Docs are plain Markdown in `docs/`, built with
[MkDocs](https://www.mkdocs.org/) and the Material theme:

| Command | What it does |
| ------- | ------------ |
| `uv run mkdocs serve` | Live preview at http://127.0.0.1:8000 |
| `uv run mkdocs build` | Builds the static site into `site/` (git-ignored) |

Mermaid diagrams render natively in fenced `mermaid` blocks. Deployment
(GitHub Pages) is planned for a later phase; until then the site is previewed
locally.

## Conventions

- All documentation, code comments, commit messages and PRs are written in
  **English**.
- Pull requests are merged with **squash and merge**; the PR title and body
  become the squashed commit message.
