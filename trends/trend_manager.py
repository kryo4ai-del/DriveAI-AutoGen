# trend_manager.py
# Manages AI trend records — CRUD, querying, relevance scoring.

import json
import os
from datetime import date

_DIR = os.path.dirname(__file__)
_STORE_PATH = os.path.join(_DIR, "trend_store.json")

VALID_CATEGORIES = (
    "model_release",
    "developer_tooling",
    "app_category",
    "framework_update",
    "platform_change",
    "ai_capability",
    "market_shift",
    "automation_pattern",
    "general",
)

VALID_STATUSES = (
    "detected",
    "evaluated",
    "idea_generated",
    "dismissed",
    "expired",
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


class TrendManager:
    """Manages AI trend records — create, update, query."""

    def __init__(self):
        self.data = _load_json(_STORE_PATH)
        self.data.setdefault("trends", [])

    def save(self) -> None:
        _save_json(_STORE_PATH, self.data)

    @property
    def trends(self) -> list[dict]:
        return self.data["trends"]

    def _next_id(self) -> str:
        max_num = 0
        for t in self.trends:
            id_str = t.get("trend_id", "")
            if id_str.startswith("TREND-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"TREND-{max_num + 1:03d}"

    def add_trend(
        self,
        title: str,
        category: str,
        summary: str = "",
        relevance_score: float = 0.5,
        potential_app_categories: list[str] | None = None,
        detected_from: str = "",
        notes: str = "",
    ) -> dict:
        if category not in VALID_CATEGORIES:
            raise ValueError(f"Invalid category: {category}. Valid: {VALID_CATEGORIES}")

        trend = {
            "trend_id": self._next_id(),
            "title": title,
            "category": category,
            "summary": summary,
            "relevance_score": max(0.0, min(1.0, relevance_score)),
            "potential_app_categories": potential_app_categories or [],
            "detected_from": detected_from,
            "status": "detected",
            "notes": notes,
            "detected_at": date.today().isoformat(),
        }
        self.trends.append(trend)
        self.save()
        return trend

    def get_trend(self, trend_id: str) -> dict | None:
        for t in self.trends:
            if t.get("trend_id") == trend_id:
                return t
        return None

    def update_trend(self, trend_id: str, **fields) -> dict | None:
        t = self.get_trend(trend_id)
        if not t:
            return None
        for key, value in fields.items():
            if key in t and key != "trend_id":
                t[key] = value
        self.save()
        return t

    def transition(self, trend_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_STATUSES}")
        return self.update_trend(trend_id, status=new_status)

    def mark_idea_generated(self, trend_id: str, idea_id: str) -> dict | None:
        t = self.get_trend(trend_id)
        if not t:
            return None
        t["status"] = "idea_generated"
        t["linked_idea_id"] = idea_id
        self.save()
        return t

    def by_category(self, category: str) -> list[dict]:
        return [t for t in self.trends if t.get("category") == category]

    def by_status(self, status: str) -> list[dict]:
        return [t for t in self.trends if t.get("status") == status]

    def high_relevance(self, threshold: float = 0.7) -> list[dict]:
        return [t for t in self.trends if t.get("relevance_score", 0) >= threshold]

    def active(self) -> list[dict]:
        return [t for t in self.trends if t.get("status") not in ("dismissed", "expired")]

    def actionable(self) -> list[dict]:
        """Trends that are detected/evaluated but haven't generated ideas yet."""
        return [t for t in self.trends if t.get("status") in ("detected", "evaluated")]

    def get_summary(self) -> str:
        total = len(self.trends)
        if total == 0:
            return "Trends — total: 0"
        active = self.active()
        high = self.high_relevance()
        lines = [f"Trends — total: {total}  active: {len(active)}  high-relevance: {len(high)}"]
        actionable = self.actionable()
        if actionable:
            lines.append(f"  Actionable: {len(actionable)} trends awaiting idea generation")
        return "\n".join(lines)
