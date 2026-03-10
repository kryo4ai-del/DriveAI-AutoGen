# briefing_manager.py
# Manages daily briefing records — CRUD, querying, archival.

import json
import os
from datetime import date

_DIR = os.path.dirname(__file__)
_STORE_PATH = os.path.join(_DIR, "briefing_store.json")

VALID_STATUSES = ("generated", "delivered", "archived")


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


class BriefingManager:
    """Manages daily briefing records."""

    def __init__(self):
        self.data = _load_json(_STORE_PATH)
        self.data.setdefault("briefings", [])

    def save(self) -> None:
        _save_json(_STORE_PATH, self.data)

    @property
    def briefings(self) -> list[dict]:
        return self.data["briefings"]

    def _next_id(self) -> str:
        max_num = 0
        for b in self.briefings:
            id_str = b.get("briefing_id", "")
            if id_str.startswith("BRIEF-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"BRIEF-{max_num + 1:03d}"

    def add_briefing(self, briefing_date: str, sections: dict, kpis: dict,
                     actions: list[str], html_path: str = "") -> dict:
        briefing = {
            "briefing_id": self._next_id(),
            "briefing_date": briefing_date,
            "sections": sections,
            "kpis": kpis,
            "actions": actions,
            "html_path": html_path,
            "status": "generated",
            "created_at": date.today().isoformat(),
        }
        self.briefings.append(briefing)
        self.save()
        return briefing

    def get_briefing(self, briefing_id: str) -> dict | None:
        for b in self.briefings:
            if b.get("briefing_id") == briefing_id:
                return b
        return None

    def latest(self) -> dict | None:
        if not self.briefings:
            return None
        return self.briefings[-1]

    def by_date(self, briefing_date: str) -> dict | None:
        for b in self.briefings:
            if b.get("briefing_date") == briefing_date:
                return b
        return None

    def transition(self, briefing_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_STATUSES}")
        b = self.get_briefing(briefing_id)
        if not b:
            return None
        b["status"] = new_status
        self.save()
        return b

    def recent(self, count: int = 7) -> list[dict]:
        return list(reversed(self.briefings[-count:]))
