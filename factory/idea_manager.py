# idea_manager.py
# Manages the Factory Idea Intake system — CRUD for ideas and project registry.

import json
import os
from datetime import date

_FACTORY_DIR = os.path.dirname(__file__)
_IDEAS_PATH = os.path.join(_FACTORY_DIR, "ideas", "idea_store.json")
_PROJECTS_PATH = os.path.join(_FACTORY_DIR, "projects", "project_registry.json")

VALID_SCOPES = ("app-level", "factory-level", "future-product")
VALID_TYPES = ("feature", "agent", "infrastructure", "marketing", "content", "monetization", "experiment")
VALID_STATUSES = ("inbox", "classified", "prioritized", "spec-ready", "blocked", "done", "parked")
VALID_PRIORITIES = ("now", "next", "later", "blocked")


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


class IdeaManager:
    """Manages the idea store — add, update, query, and transition ideas."""

    def __init__(self):
        self.data = _load_json(_IDEAS_PATH)
        self.data.setdefault("ideas", [])

    def save(self) -> None:
        _save_json(_IDEAS_PATH, self.data)

    @property
    def ideas(self) -> list[dict]:
        return self.data["ideas"]

    def _next_id(self) -> str:
        max_num = 0
        for idea in self.ideas:
            id_str = idea.get("id", "")
            if id_str.startswith("IDEA-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"IDEA-{max_num + 1:03d}"

    def add_idea(
        self,
        title: str,
        raw_idea: str = "",
        source: str = "session",
        project: str = "",
        scope: str = "app-level",
        idea_type: str = "feature",
        priority: str = "later",
        notes: str = "",
    ) -> dict:
        idea = {
            "id": self._next_id(),
            "title": title,
            "raw_idea": raw_idea or title,
            "source": source,
            "project": project,
            "scope": scope,
            "type": idea_type,
            "priority": priority,
            "status": "inbox",
            "notes": notes,
            "created_at": date.today().isoformat(),
        }
        self.ideas.append(idea)
        self.save()
        return idea

    def get_idea(self, idea_id: str) -> dict | None:
        for idea in self.ideas:
            if idea.get("id") == idea_id:
                return idea
        return None

    def update_idea(self, idea_id: str, **fields) -> dict | None:
        idea = self.get_idea(idea_id)
        if not idea:
            return None
        for key, value in fields.items():
            if key in idea and key != "id":
                idea[key] = value
        self.save()
        return idea

    def transition(self, idea_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_STATUSES}")
        return self.update_idea(idea_id, status=new_status)

    def classify(self, idea_id: str, scope: str, idea_type: str, priority: str, project: str = "") -> dict | None:
        idea = self.get_idea(idea_id)
        if not idea:
            return None
        idea["scope"] = scope
        idea["type"] = idea_type
        idea["priority"] = priority
        if project:
            idea["project"] = project
        idea["status"] = "classified"
        self.save()
        return idea

    def by_status(self, status: str) -> list[dict]:
        return [i for i in self.ideas if i.get("status") == status]

    def by_project(self, project: str) -> list[dict]:
        return [i for i in self.ideas if i.get("project") == project]

    def by_priority(self, priority: str) -> list[dict]:
        return [i for i in self.ideas if i.get("priority") == priority]

    def inbox(self) -> list[dict]:
        return self.by_status("inbox")

    def get_summary(self) -> str:
        total = len(self.ideas)
        by_status = {}
        for idea in self.ideas:
            s = idea.get("status", "unknown")
            by_status[s] = by_status.get(s, 0) + 1
        status_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_status.items()))
        inbox_count = by_status.get("inbox", 0)
        lines = [f"Ideas — total: {total}  ({status_str})"]
        if inbox_count > 0:
            lines.append(f"  Inbox: {inbox_count} ideas awaiting classification")
        return "\n".join(lines)


class ProjectRegistry:
    """Manages the project registry — list, add, query projects."""

    def __init__(self):
        self.data = _load_json(_PROJECTS_PATH)
        self.data.setdefault("projects", [])

    def save(self) -> None:
        _save_json(_PROJECTS_PATH, self.data)

    @property
    def projects(self) -> list[dict]:
        return self.data["projects"]

    def get_project(self, project_id: str) -> dict | None:
        for p in self.projects:
            if p.get("id") == project_id:
                return p
        return None

    def add_project(
        self,
        project_id: str,
        name: str,
        description: str = "",
        platform: str = "",
        status: str = "planning",
        notes: str = "",
    ) -> dict:
        if self.get_project(project_id):
            raise ValueError(f"Project '{project_id}' already exists")
        project = {
            "id": project_id,
            "name": name,
            "description": description,
            "platform": platform,
            "status": status,
            "active": True,
            "notes": notes,
        }
        self.projects.append(project)
        self.save()
        return project

    def active_projects(self) -> list[dict]:
        return [p for p in self.projects if p.get("active")]

    def get_summary(self) -> str:
        active = [p for p in self.projects if p.get("active")]
        lines = [f"Projects — total: {len(self.projects)}  active: {len(active)}"]
        for p in active:
            lines.append(f"  {p['id']}: {p['name']} ({p.get('platform', '?')}) — {p.get('status', '?')}")
        return "\n".join(lines)
