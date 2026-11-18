"""production-rag-system: RAG over technical documentation (Sinergym / EnergyPlus) with source references."""

from importlib.metadata import version

# Single source of truth: the version lives in pyproject.toml only.
# (Run `uv sync` after bumping it so the installed metadata is refreshed.)
__version__ = version("production-rag-system")
