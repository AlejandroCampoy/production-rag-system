# syntax=docker/dockerfile:1
# BuildKit frontend directive: enables modern Dockerfile features, notably the
# `RUN --mount=type=cache,...` cache mount used in the builder stage below.

# ---------------------------------------------------------------------------
# Stage 1 — uv binaries + managed CPython (builder)
#
# uv ships as a distroless image (no shell, nothing else): copying its static
# binaries is the cleanest "install" — no pip (which would require Python
# before uv exists) and no curl scripts. Exact binary as published by Astral.
#
# CPython is installed into /opt/python so the final stage carries only
# uv + the interpreter, not the build tooling.
#
# TODO: pin image versions/digests instead of latest as the project matures.
# ---------------------------------------------------------------------------
FROM ghcr.io/astral-sh/uv:latest AS uv

# Ubuntu base on purpose (instead of python:3.13): the interpreter is NOT
# provided by the OS — uv manages it (same mechanism as the host via
# .python-version). A bare base keeps exactly one Python in the image,
# with no risk of `python` and `uv run` resolving to different interpreters.
FROM ubuntu:24.04 AS python-builder

COPY --from=uv /uv /uvx /usr/local/bin/

# Managed CPython 3.13, isolated in /opt/python and copied to the final stage.
# The cache mount keeps uv's download cache (/root/.cache/uv, its default)
# OUTSIDE the image layers: after install, the tarball is dead weight, but
# it persists across builds, so rebuilding this stage never re-downloads.
RUN --mount=type=cache,target=/root/.cache/uv \
    uv python install 3.13 --install-dir /opt/python

# ---------------------------------------------------------------------------
# Stage 2 — development image (devcontainer base)
#
# Intentionally lean: git / GitHub CLI are added by devcontainer features on
# top of this image; project dependencies are installed per-container by
# `postCreateCommand: uv sync` (reads .python-version and uv.lock).
# ---------------------------------------------------------------------------
FROM ubuntu:24.04 AS development

ARG DEBIAN_FRONTEND=noninteractive

# Devcontainer runtime essentials only. git and gh are installed here on
# purpose: the image is self-contained, usable with or without VS Code
# (devcontainer.json only adds editor-side settings).
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo ca-certificates curl git gh openssh-client \
    && rm -rf /var/lib/apt/lists/*

# ubuntu:24.04 ships a default `ubuntu` user (uid 1000, already in the sudo
# group): reuse it instead of creating one. Grant passwordless sudo for the
# devcontainer tooling.
ARG USERNAME=ubuntu
RUN mkdir -p /etc/sudoers.d \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

# uv + managed CPython from the builder stage.
COPY --from=python-builder /usr/local/bin/uv /usr/local/bin/uv
COPY --from=python-builder /usr/local/bin/uvx /usr/local/bin/uvx
COPY --from=python-builder /opt/python /opt/python

# Resolve interpreters exclusively from the managed install:
#   UV_PYTHON_INSTALL_DIR   — where the copied interpreter lives (builder glue).
#   UV_PYTHON_PREFERENCE    — never fall back to a system Python: deterministic
#                             behavior; mismatches fail instead of silently
#                             picking another interpreter.
#   UV_LINK_MODE            — copy instead of hardlink: cache and workspace live
#                             on different filesystems (image layers vs mounted
#                             volume), which triggers uv warnings on every sync.
#   LANG / LC_ALL           — minimal images have no locale; without UTF-8,
#                             Python hits UnicodeDecodeError on non-ASCII text
#                             (we will be processing documents).
ENV UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PYTHON_PREFERENCE=only-managed \
    UV_LINK_MODE=copy \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Expose the managed interpreter as `python` / `python3` outside venvs
# (/opt/python/... is not on PATH). Venvs are unaffected: uv links them
# straight to the real interpreter. uv resolves the exact path because the
# install dir layout is version/arch specific.
RUN ln -s "$(uv python find 3.13)" /usr/local/bin/python3 \
    && ln -s /usr/local/bin/python3 /usr/local/bin/python

USER ${USERNAME}
