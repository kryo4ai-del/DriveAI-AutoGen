"""QA Report — structured JSON reports for each QA run.

Generates a complete report of a QA pass including all phases,
warnings, bounce info, and final recommendation. Reports are
saved as JSON files in the configured report directory.
"""

import json
from datetime import datetime, timezone
from pathlib import Path

from factory.qa.config import QAConfig


class QAReport:
    """Structured report for a single QA run."""

    def __init__(self, project_name: str, platform: str) -> None:
        self._project = project_name
        self._platform = platform
        self._timestamp = datetime.now(timezone.utc)
        self._status = "RUNNING"
        self._phases: dict[str, dict] = {}
        self._warnings: list[dict] = []
        self._bounce_count: int = 0
        self._recommendation: str = ""
        self._finalized_at: datetime | None = None
        self._saved_path: str | None = None

    def add_phase(self, phase_name: str, status: str,
                  duration_seconds: float, details: dict | None = None) -> None:
        """Record the result of a QA phase."""
        self._phases[phase_name] = {
            "status": status,
            "duration_seconds": round(duration_seconds, 1),
            "details": details or {},
        }

    def add_warning(self, title: str, detail: str = "") -> None:
        """Add a warning to the report."""
        self._warnings.append({"title": title, "detail": detail})

    def set_bounce_count(self, count: int) -> None:
        """Set the current bounce count for this product."""
        self._bounce_count = count

    def set_recommendation(self, text: str) -> None:
        """Set the final recommendation text."""
        self._recommendation = text

    def finalize(self, status: str, phase: str | None = None,
                 reason: str | None = None) -> None:
        """Finalize the report with a status and optional failure info."""
        self._status = status
        self._finalized_at = datetime.now(timezone.utc)
        if phase:
            self._phases.setdefault(phase, {})["failure_reason"] = reason or ""

    def to_dict(self) -> dict:
        """Return the full report as a dict."""
        end = self._finalized_at or datetime.now(timezone.utc)
        duration = (end - self._timestamp).total_seconds()
        return {
            "project": self._project,
            "platform": self._platform,
            "timestamp": self._timestamp.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "status": self._status,
            "duration_seconds": round(duration),
            "bounce_count": self._bounce_count,
            "phases": self._phases,
            "warnings": self._warnings,
            "recommendation": self._recommendation,
        }

    def save(self, config: QAConfig | None = None) -> str:
        """Save the report as JSON. Returns the file path."""
        cfg = config or QAConfig()
        report_dir = Path(cfg.report_dir)
        report_dir.mkdir(parents=True, exist_ok=True)

        ts = self._timestamp.strftime("%Y%m%d_%H%M%S")
        filename = f"{self._project}_{self._platform}_qa_{ts}.json"
        filepath = report_dir / filename

        filepath.write_text(
            json.dumps(self.to_dict(), indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
        self._saved_path = str(filepath)
        return self._saved_path

    @property
    def path(self) -> str | None:
        """Return the last saved file path, or None if not yet saved."""
        return self._saved_path
