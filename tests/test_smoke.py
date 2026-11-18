"""Smoke tests: the package skeleton must stay importable and versioned."""

from production_rag_system import __version__


def test_package_is_importable() -> None:
    assert __version__
