# content_manager.py
# Manages content records — CRUD for generated content artifacts.

import json
import os
from datetime import date

_CONTENT_DIR = os.path.dirname(__file__)
_CONTENT_PATH = os.path.join(_CONTENT_DIR, "content_store.json")

VALID_CONTENT_TYPES = (
    "video_script",
    "app_store_short",
    "app_store_long",
    "landingpage_copy",
    "social_post",
    "feature_announcement",
    "release_notes",
)

VALID_CONTENT_STATUSES = ("draft", "review", "approved", "published", "archived")


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


class ContentManager:
    """Manages the content store — create, update, query content records."""

    def __init__(self):
        self.data = _load_json(_CONTENT_PATH)
        self.data.setdefault("content", [])

    def save(self) -> None:
        _save_json(_CONTENT_PATH, self.data)

    @property
    def records(self) -> list[dict]:
        return self.data["content"]

    def _next_id(self) -> str:
        max_num = 0
        for rec in self.records:
            id_str = rec.get("content_id", "")
            if id_str.startswith("CONTENT-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"CONTENT-{max_num + 1:03d}"

    def create(
        self,
        title: str,
        content_type: str,
        project: str = "",
        linked_spec_id: str = "",
        audience: str = "",
        tone: str = "",
        summary: str = "",
        draft: str = "",
        notes: str = "",
    ) -> dict:
        if content_type not in VALID_CONTENT_TYPES:
            raise ValueError(f"Invalid content type: {content_type}. Valid: {VALID_CONTENT_TYPES}")
        record = {
            "content_id": self._next_id(),
            "project": project,
            "linked_spec_id": linked_spec_id,
            "type": content_type,
            "title": title,
            "audience": audience,
            "tone": tone,
            "summary": summary,
            "draft": draft,
            "status": "draft",
            "notes": notes,
            "created_at": date.today().isoformat(),
        }
        self.records.append(record)
        self.save()
        return record

    def get(self, content_id: str) -> dict | None:
        for rec in self.records:
            if rec.get("content_id") == content_id:
                return rec
        return None

    def update(self, content_id: str, **fields) -> dict | None:
        rec = self.get(content_id)
        if not rec:
            return None
        for key, value in fields.items():
            if key in rec and key != "content_id":
                rec[key] = value
        self.save()
        return rec

    def transition(self, content_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_CONTENT_STATUSES:
            raise ValueError(f"Invalid content status: {new_status}. Valid: {VALID_CONTENT_STATUSES}")
        return self.update(content_id, status=new_status)

    def by_type(self, content_type: str) -> list[dict]:
        return [r for r in self.records if r.get("type") == content_type]

    def by_project(self, project: str) -> list[dict]:
        return [r for r in self.records if r.get("project") == project]

    def by_status(self, status: str) -> list[dict]:
        return [r for r in self.records if r.get("status") == status]

    def drafts(self) -> list[dict]:
        return self.by_status("draft")

    def get_summary(self) -> str:
        total = len(self.records)
        if total == 0:
            return "Content — total: 0"
        by_status = {}
        for rec in self.records:
            s = rec.get("status", "unknown")
            by_status[s] = by_status.get(s, 0) + 1
        status_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_status.items()))
        lines = [f"Content — total: {total}  ({status_str})"]
        by_type = {}
        for rec in self.records:
            t = rec.get("type", "unknown")
            by_type[t] = by_type.get(t, 0) + 1
        type_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_type.items()))
        lines.append(f"  Types: {type_str}")
        return "\n".join(lines)
