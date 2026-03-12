# research_manager.py
# AutoResearchAgent — manages research reports for the AI App Factory.
# Stores structured research insights about technologies, tools, architectures,
# product opportunities, and AI model evaluations.

import json
import os
from datetime import datetime

_DIR = os.path.dirname(__file__)
_REPORTS_PATH = os.path.join(_DIR, "research_reports.json")

VALID_STATUSES = ("draft", "review", "published", "archived", "superseded")

VALID_CATEGORIES = (
    "technology_research",
    "tool_discovery",
    "architecture_comparison",
    "product_opportunity",
    "ai_model_evaluation",
    "market_analysis",
    "general",
)


def _load_json(path: str) -> dict:
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def _save_json(path: str, data: dict) -> None:
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


class ResearchManager:
    """Manages research reports for the AI App Factory."""

    def __init__(self):
        self._data = _load_json(_REPORTS_PATH)
        self._data.setdefault("reports", [])

    def save(self) -> None:
        _save_json(_REPORTS_PATH, self._data)

    @property
    def reports(self) -> list[dict]:
        return self._data["reports"]

    def _next_id(self) -> str:
        max_num = 0
        for r in self.reports:
            rid = r.get("research_id", "")
            if rid.startswith("RES-"):
                try:
                    max_num = max(max_num, int(rid.split("-")[1]))
                except (IndexError, ValueError):
                    pass
        return f"RES-{max_num + 1:03d}"

    # ── CRUD ──────────────────────────────────────────────────────────

    def add_report(self, topic: str, category: str, summary: str,
                   source_signals: list[str], recommendations: list[str],
                   related_trends: list[str] | None = None,
                   related_opportunities: list[str] | None = None,
                   related_radar: list[str] | None = None,
                   technologies: list[str] | None = None,
                   confidence: float = 0.5,
                   notes: str = "") -> dict:
        """Create and persist a new research report."""
        if category not in VALID_CATEGORIES:
            category = "general"

        report = {
            "research_id": self._next_id(),
            "topic": topic,
            "category": category,
            "summary": summary,
            "source_signals": source_signals,
            "recommendations": recommendations,
            "related_trends": related_trends or [],
            "related_opportunities": related_opportunities or [],
            "related_radar": related_radar or [],
            "technologies": technologies or [],
            "confidence": round(min(1.0, max(0.0, confidence)), 2),
            "status": "published",
            "notes": notes,
            "generated_at": datetime.utcnow().isoformat(timespec="seconds") + "Z",
        }
        self.reports.append(report)
        self.save()
        return report

    def get_report(self, research_id: str) -> dict | None:
        for r in self.reports:
            if r.get("research_id") == research_id:
                return r
        return None

    def latest(self, limit: int = 5) -> list[dict]:
        return list(reversed(self.reports[-limit:]))

    def by_category(self, category: str) -> list[dict]:
        return [r for r in self.reports if r.get("category") == category]

    def by_status(self, status: str) -> list[dict]:
        return [r for r in self.reports if r.get("status") == status]

    def search(self, keyword: str) -> list[dict]:
        """Search reports by keyword in topic, summary, or technologies."""
        kw = keyword.lower()
        return [
            r for r in self.reports
            if kw in r.get("topic", "").lower()
            or kw in r.get("summary", "").lower()
            or any(kw in t.lower() for t in r.get("technologies", []))
        ]

    def transition(self, research_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Must be one of {VALID_STATUSES}")
        r = self.get_report(research_id)
        if not r:
            return None
        r["status"] = new_status
        self.save()
        return r

    # ── Aggregations ──────────────────────────────────────────────────

    def category_counts(self) -> dict[str, int]:
        result: dict[str, int] = {}
        for r in self.reports:
            c = r.get("category", "general")
            result[c] = result.get(c, 0) + 1
        return dict(sorted(result.items(), key=lambda x: -x[1]))

    def all_technologies(self) -> dict[str, int]:
        """Return all mentioned technologies with frequency counts."""
        result: dict[str, int] = {}
        for r in self.reports:
            for tech in r.get("technologies", []):
                result[tech] = result.get(tech, 0) + 1
        return dict(sorted(result.items(), key=lambda x: -x[1]))

    def high_confidence(self, threshold: float = 0.7) -> list[dict]:
        return [r for r in self.reports
                if r.get("confidence", 0) >= threshold
                and r.get("status") not in ("archived", "superseded")]

    def get_summary(self) -> str:
        total = len(self.reports)
        if total == 0:
            return "Research — no reports generated yet"

        published = sum(1 for r in self.reports if r.get("status") == "published")
        high_conf = len(self.high_confidence())
        cats = self.category_counts()
        top_cat = list(cats.keys())[0] if cats else "—"

        return (
            f"Research — {total} reports ({published} published, {high_conf} high-confidence) | "
            f"Top category: {top_cat}"
        )
