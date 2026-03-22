"""Input Loader — Reads from Phase 1 + Kapitel 3 + Kapitel 4 for Design Vision.

Reuses visual_audit input_loader (same 14 reports needed, minus K5).
"""

from factory.visual_audit.input_loader import load_all_reports, find_latest_runs

__all__ = ["load_all_reports", "find_latest_runs"]
