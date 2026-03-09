# spec_manager.py
# Manages the Factory Spec Pipeline — transforms prioritized ideas into implementation-ready specs.

import json
import os
from datetime import date

_FACTORY_DIR = os.path.dirname(__file__)
_SPECS_PATH = os.path.join(_FACTORY_DIR, "specs", "spec_store.json")

VALID_SPEC_STATUSES = ("draft", "review", "approved", "in-progress", "done", "rejected")


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


class SpecManager:
    """Manages the spec store — create, update, query, and link specs to ideas."""

    def __init__(self):
        self.data = _load_json(_SPECS_PATH)
        self.data.setdefault("specs", [])

    def save(self) -> None:
        _save_json(_SPECS_PATH, self.data)

    @property
    def specs(self) -> list[dict]:
        return self.data["specs"]

    def _next_id(self) -> str:
        max_num = 0
        for spec in self.specs:
            id_str = spec.get("spec_id", "")
            if id_str.startswith("SPEC-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"SPEC-{max_num + 1:03d}"

    def create_spec(
        self,
        title: str,
        linked_idea_id: str = "",
        project: str = "",
        spec_type: str = "feature",
        scope: str = "app-level",
        priority: str = "next",
        summary: str = "",
        goal: str = "",
        in_scope: list[str] | None = None,
        out_of_scope: list[str] | None = None,
        dependencies: list[str] | None = None,
        affected_systems: list[str] | None = None,
        acceptance_criteria: list[str] | None = None,
        risks: list[str] | None = None,
        suggested_template: str = "",
        suggested_agents: list[str] | None = None,
        notes: str = "",
    ) -> dict:
        spec = {
            "spec_id": self._next_id(),
            "linked_idea_id": linked_idea_id,
            "title": title,
            "project": project,
            "type": spec_type,
            "scope": scope,
            "priority": priority,
            "status": "draft",
            "summary": summary,
            "goal": goal,
            "in_scope": in_scope or [],
            "out_of_scope": out_of_scope or [],
            "dependencies": dependencies or [],
            "affected_systems": affected_systems or [],
            "acceptance_criteria": acceptance_criteria or [],
            "risks": risks or [],
            "suggested_template": suggested_template,
            "suggested_agents": suggested_agents or [],
            "notes": notes,
            "created_at": date.today().isoformat(),
        }
        self.specs.append(spec)
        self.save()
        return spec

    def create_from_idea(self, idea: dict, **overrides) -> dict:
        """Create a spec directly from an idea dict (from IdeaManager)."""
        defaults = {
            "title": idea.get("title", ""),
            "linked_idea_id": idea.get("id", ""),
            "project": idea.get("project", ""),
            "spec_type": idea.get("type", "feature"),
            "scope": idea.get("scope", "app-level"),
            "priority": idea.get("priority", "next"),
            "summary": idea.get("raw_idea", ""),
            "notes": idea.get("notes", ""),
        }
        defaults.update(overrides)
        return self.create_spec(**defaults)

    def get_spec(self, spec_id: str) -> dict | None:
        for spec in self.specs:
            if spec.get("spec_id") == spec_id:
                return spec
        return None

    def get_by_idea(self, idea_id: str) -> dict | None:
        for spec in self.specs:
            if spec.get("linked_idea_id") == idea_id:
                return spec
        return None

    def update_spec(self, spec_id: str, **fields) -> dict | None:
        spec = self.get_spec(spec_id)
        if not spec:
            return None
        for key, value in fields.items():
            if key in spec and key != "spec_id":
                spec[key] = value
        self.save()
        return spec

    def transition(self, spec_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_SPEC_STATUSES:
            raise ValueError(f"Invalid spec status: {new_status}. Valid: {VALID_SPEC_STATUSES}")
        return self.update_spec(spec_id, status=new_status)

    def approve(self, spec_id: str) -> dict | None:
        return self.transition(spec_id, "approved")

    def by_status(self, status: str) -> list[dict]:
        return [s for s in self.specs if s.get("status") == status]

    def by_project(self, project: str) -> list[dict]:
        return [s for s in self.specs if s.get("project") == project]

    def by_priority(self, priority: str) -> list[dict]:
        return [s for s in self.specs if s.get("priority") == priority]

    def approved(self) -> list[dict]:
        return self.by_status("approved")

    def drafts(self) -> list[dict]:
        return self.by_status("draft")

    def get_summary(self) -> str:
        total = len(self.specs)
        if total == 0:
            return "Specs — total: 0"
        by_status = {}
        for spec in self.specs:
            s = spec.get("status", "unknown")
            by_status[s] = by_status.get(s, 0) + 1
        status_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_status.items()))
        lines = [f"Specs — total: {total}  ({status_str})"]
        approved_count = by_status.get("approved", 0)
        if approved_count > 0:
            lines.append(f"  Approved: {approved_count} specs ready for implementation")
        draft_count = by_status.get("draft", 0)
        if draft_count > 0:
            lines.append(f"  Drafts: {draft_count} specs awaiting review")
        return "\n".join(lines)
