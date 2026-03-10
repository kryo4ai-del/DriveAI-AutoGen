# orchestration_manager.py
# Manages execution plans for autonomous project orchestration.
# Evaluates readiness, selects agents, produces structured delivery plans.

import json
import os
from datetime import date

_ORCH_DIR = os.path.dirname(__file__)
_STORE_PATH = os.path.join(_ORCH_DIR, "orchestration_plan_store.json")

VALID_READINESS = (
    "not_ready",
    "blocked",
    "needs_spec",
    "needs_review",
    "ready",
    "in_progress",
    "done",
)

VALID_PHASES = (
    "planning",
    "spec_creation",
    "compliance_review",
    "implementation",
    "review",
    "testing",
    "content",
    "release",
)

VALID_RUN_TYPES = (
    "planning",
    "feature",
    "screen",
    "service",
    "viewmodel",
    "review",
    "content",
    "accessibility",
    "compliance",
    "monitoring",
    "bootstrap",
)

VALID_STATUSES = (
    "draft",
    "approved",
    "executing",
    "completed",
    "cancelled",
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


class OrchestrationManager:
    """Creates and manages autonomous execution plans."""

    def __init__(self):
        self.data = _load_json(_STORE_PATH)
        self.data.setdefault("plans", [])

    def save(self) -> None:
        _save_json(_STORE_PATH, self.data)

    @property
    def plans(self) -> list[dict]:
        return self.data["plans"]

    def _next_id(self) -> str:
        max_num = 0
        for plan in self.plans:
            id_str = plan.get("plan_id", "")
            if id_str.startswith("PLAN-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"PLAN-{max_num + 1:03d}"

    def create_plan(
        self,
        project: str,
        linked_spec_ids: list[str] | None = None,
        readiness_status: str = "not_ready",
        recommended_phase: str = "planning",
        selected_agents: list[str] | None = None,
        execution_steps: list[str] | None = None,
        blockers: list[str] | None = None,
        risks: list[str] | None = None,
        suggested_next_run_type: str = "planning",
        notes: str = "",
    ) -> dict:
        if readiness_status not in VALID_READINESS:
            raise ValueError(f"Invalid readiness: {readiness_status}. Valid: {VALID_READINESS}")
        if recommended_phase not in VALID_PHASES:
            raise ValueError(f"Invalid phase: {recommended_phase}. Valid: {VALID_PHASES}")
        if suggested_next_run_type not in VALID_RUN_TYPES:
            raise ValueError(f"Invalid run type: {suggested_next_run_type}. Valid: {VALID_RUN_TYPES}")

        plan = {
            "plan_id": self._next_id(),
            "project": project,
            "linked_spec_ids": linked_spec_ids or [],
            "readiness_status": readiness_status,
            "recommended_phase": recommended_phase,
            "selected_agents": selected_agents or [],
            "execution_steps": execution_steps or [],
            "blockers": blockers or [],
            "risks": risks or [],
            "suggested_next_run_type": suggested_next_run_type,
            "status": "draft",
            "notes": notes,
            "created_at": date.today().isoformat(),
        }
        self.plans.append(plan)
        self.save()
        return plan

    def get_plan(self, plan_id: str) -> dict | None:
        for plan in self.plans:
            if plan.get("plan_id") == plan_id:
                return plan
        return None

    def get_by_project(self, project: str) -> list[dict]:
        return [p for p in self.plans if p.get("project") == project]

    def approve(self, plan_id: str) -> dict | None:
        return self._transition(plan_id, "approved")

    def start_execution(self, plan_id: str) -> dict | None:
        return self._transition(plan_id, "executing")

    def complete(self, plan_id: str) -> dict | None:
        return self._transition(plan_id, "completed")

    def cancel(self, plan_id: str) -> dict | None:
        return self._transition(plan_id, "cancelled")

    def _transition(self, plan_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_STATUSES}")
        plan = self.get_plan(plan_id)
        if not plan:
            return None
        plan["status"] = new_status
        self.save()
        return plan

    def update_plan(self, plan_id: str, **fields) -> dict | None:
        plan = self.get_plan(plan_id)
        if not plan:
            return None
        for key, value in fields.items():
            if key in plan and key != "plan_id":
                plan[key] = value
        self.save()
        return plan

    def active(self) -> list[dict]:
        return [p for p in self.plans if p.get("status") not in ("completed", "cancelled")]

    def by_status(self, status: str) -> list[dict]:
        return [p for p in self.plans if p.get("status") == status]

    def by_readiness(self, readiness: str) -> list[dict]:
        return [p for p in self.plans if p.get("readiness_status") == readiness]

    def ready_plans(self) -> list[dict]:
        return [p for p in self.plans if p.get("readiness_status") == "ready" and p.get("status") in ("draft", "approved")]

    def blocked_plans(self) -> list[dict]:
        return [p for p in self.plans if p.get("readiness_status") == "blocked"]

    def get_summary(self) -> str:
        total = len(self.plans)
        if total == 0:
            return "Orchestration -- total: 0 plans"
        active = self.active()
        ready = self.ready_plans()
        blocked = self.blocked_plans()
        return (
            f"Orchestration -- total: {total}  "
            f"active: {len(active)}  "
            f"ready: {len(ready)}  "
            f"blocked: {len(blocked)}"
        )
