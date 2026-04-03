"""Production Logger — writes structured JSONL for the Live Dashboard.

Log entries are consumed by:
  - /api/production/status/:slug (aggregator)
  - /api/production/status/:slug/stream (SSE)
  - ProductionDashboard.jsx + CostTracker + ScreenGrid + AgentFeed
"""

import json
import os
from datetime import datetime
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent  # DriveAI-AutoGen/


class ProductionLogger:
    """Append-only JSONL logger for production runs."""

    def __init__(self, slug: str, base_dir: str | None = None):
        self.slug = slug
        root = Path(base_dir) if base_dir else _ROOT
        self.log_path = root / "factory" / "projects" / slug / "production_log.jsonl"
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        self._start = datetime.now()

    def _write(self, entry: dict):
        entry.setdefault("timestamp", datetime.now().isoformat())
        entry["elapsed_s"] = round((datetime.now() - self._start).total_seconds(), 2)
        with open(self.log_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")

    # ── Step-level logging ──────────────────────────────────────

    def log_step_start(self, phase: str, screen: str, agent: str = "", message: str = ""):
        """Log the start of a build step (screen/feature)."""
        self._write({
            "type": "step_start",
            "phase": phase,
            "screen": screen,
            "agent": agent,
            "message": message or f"{screen} gestartet",
        })

    def log_step_complete(self, phase: str, screen: str, agent: str = "",
                          loc: int = 0, cost: float = 0.0, duration: float = 0.0,
                          files: int = 0, tokens: int = 0, model: str = "",
                          subtype: str = ""):
        """Log successful completion of a build step."""
        entry = {
            "type": "step_complete",
            "phase": phase,
            "screen": screen,
            "agent": agent,
        }
        if loc: entry["loc"] = loc
        if cost: entry["cost"] = cost
        if duration: entry["duration"] = round(duration, 2)
        if files: entry["files"] = files
        if tokens: entry["tokens"] = tokens
        if model: entry["model"] = model
        if subtype: entry["subtype"] = subtype
        self._write(entry)

    def log_error(self, phase: str, screen: str = "", agent: str = "",
                  message: str = "", cost: float = 0.0):
        """Log a step error."""
        self._write({
            "type": "error",
            "phase": phase,
            "screen": screen,
            "agent": agent,
            "message": message,
            **({"cost": cost} if cost else {}),
        })

    # ── Phase-level logging ─────────────────────────────────────

    def log_phase_start(self, phase: str, total_steps: int = 0):
        """Log the start of a production phase."""
        self._write({
            "type": "phase_start",
            "phase": phase,
            "total_steps": total_steps,
            "message": f"Phase {phase} gestartet",
        })

    def log_phase_complete(self, phase: str, steps_done: int = 0, cost: float = 0.0):
        """Log the completion of a production phase."""
        self._write({
            "type": "phase_complete",
            "phase": phase,
            "message": f"Phase {phase} abgeschlossen ({steps_done} Steps)",
            **({"cost": cost} if cost else {}),
        })

    # ── Production-level logging ────────────────────────────────

    def log_production_start(self, total_steps: int, slug: str = ""):
        """Log overall production start."""
        self._write({
            "type": "production_start",
            "phase": "production",
            "total_steps": total_steps,
            "message": f"Production gestartet fuer {slug or self.slug}",
        })

    def log_production_complete(self, total_screens: int = 0, total_files: int = 0,
                                total_loc: int = 0, total_cost: float = 0.0):
        """Log overall production completion."""
        self._write({
            "type": "production_complete",
            "phase": "production",
            "total_screens": total_screens,
            "total_files": total_files,
            "total_loc": total_loc,
            "cost": total_cost,
            "message": "Production abgeschlossen",
        })

    def log_production_resumed(self, completed: int = 0, remaining: int = 0):
        """Log production resume after failure."""
        self._write({
            "type": "production_resumed",
            "phase": "production",
            "completed_before": completed,
            "remaining": remaining,
            "message": f"Production fortgesetzt — {completed} fertig, {remaining} verbleibend",
        })

    def log_production_failed(self, error: str):
        """Log production failure."""
        self._write({
            "type": "production_failed",
            "phase": "production",
            "message": f"Production fehlgeschlagen: {error}",
        })
