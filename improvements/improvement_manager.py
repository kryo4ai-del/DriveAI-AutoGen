# improvement_manager.py
# Manages factory self-improvement proposals — CRUD, querying, dashboard.

import json
import os
from datetime import date

_DIR = os.path.dirname(__file__)
_STORE_PATH = os.path.join(_DIR, "improvement_proposals.json")

VALID_CATEGORIES = (
    "security",
    "performance",
    "tooling",
    "automation",
    "model_update",
    "architecture",
    "sdk_update",
    "compliance",
    "accessibility",
    "general",
)

VALID_SEVERITIES = ("info", "low", "medium", "high", "critical")

VALID_STATUSES = (
    "new",
    "evaluated",
    "accepted",
    "in_progress",
    "completed",
    "rejected",
    "deferred",
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


class ImprovementManager:
    """Manages factory improvement proposals — create, update, query."""

    def __init__(self):
        self.data = _load_json(_STORE_PATH)
        self.data.setdefault("proposals", [])

    def save(self) -> None:
        _save_json(_STORE_PATH, self.data)

    @property
    def proposals(self) -> list[dict]:
        return self.data["proposals"]

    def _next_id(self) -> str:
        max_num = 0
        for p in self.proposals:
            id_str = p.get("proposal_id", "")
            if id_str.startswith("IMP-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"IMP-{max_num + 1:03d}"

    def add_proposal(
        self,
        title: str,
        summary: str,
        category: str,
        severity: str = "medium",
        affected_systems: list[str] | None = None,
        recommended_action: str = "",
        detected_from: str = "",
        notes: str = "",
    ) -> dict:
        if category not in VALID_CATEGORIES:
            raise ValueError(f"Invalid category: {category}. Valid: {VALID_CATEGORIES}")
        if severity not in VALID_SEVERITIES:
            raise ValueError(f"Invalid severity: {severity}. Valid: {VALID_SEVERITIES}")

        proposal = {
            "proposal_id": self._next_id(),
            "title": title,
            "summary": summary,
            "category": category,
            "severity": severity,
            "affected_systems": affected_systems or [],
            "recommended_action": recommended_action,
            "detected_from": detected_from,
            "status": "new",
            "notes": notes,
            "created_at": date.today().isoformat(),
        }
        self.proposals.append(proposal)
        self.save()
        return proposal

    def get_proposal(self, proposal_id: str) -> dict | None:
        for p in self.proposals:
            if p.get("proposal_id") == proposal_id:
                return p
        return None

    def update_proposal(self, proposal_id: str, **fields) -> dict | None:
        p = self.get_proposal(proposal_id)
        if not p:
            return None
        for key, value in fields.items():
            if key in p and key != "proposal_id":
                p[key] = value
        self.save()
        return p

    def transition(self, proposal_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_STATUSES}")
        return self.update_proposal(proposal_id, status=new_status)

    def evaluate(self, proposal_id: str) -> dict | None:
        return self.transition(proposal_id, "evaluated")

    def accept(self, proposal_id: str) -> dict | None:
        return self.transition(proposal_id, "accepted")

    def reject(self, proposal_id: str) -> dict | None:
        return self.transition(proposal_id, "rejected")

    def defer(self, proposal_id: str) -> dict | None:
        return self.transition(proposal_id, "deferred")

    def complete(self, proposal_id: str) -> dict | None:
        return self.transition(proposal_id, "completed")

    def by_category(self, category: str) -> list[dict]:
        return [p for p in self.proposals if p.get("category") == category]

    def by_severity(self, severity: str) -> list[dict]:
        return [p for p in self.proposals if p.get("severity") == severity]

    def by_status(self, status: str) -> list[dict]:
        return [p for p in self.proposals if p.get("status") == status]

    def active(self) -> list[dict]:
        return [p for p in self.proposals if p.get("status") not in ("completed", "rejected", "deferred")]

    def actionable(self) -> list[dict]:
        return [p for p in self.proposals if p.get("status") in ("new", "evaluated", "accepted")]

    def get_summary(self) -> str:
        total = len(self.proposals)
        if total == 0:
            return "Improvements — total: 0 proposals"
        active = self.active()
        by_sev = {}
        for p in active:
            s = p.get("severity", "info")
            by_sev[s] = by_sev.get(s, 0) + 1
        sev_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_sev.items()))
        lines = [f"Improvements — total: {total}  active: {len(active)}  ({sev_str})"]
        critical = by_sev.get("critical", 0)
        high = by_sev.get("high", 0)
        if critical > 0:
            lines.append(f"  CRITICAL: {critical} proposals require immediate action")
        if high > 0:
            lines.append(f"  HIGH: {high} proposals need attention soon")
        return "\n".join(lines)
