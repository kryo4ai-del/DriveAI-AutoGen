# factory/orchestrator/build_plan.py
# BuildPlan and BuildStep data structures.

import json
from dataclasses import dataclass, field, asdict
from datetime import datetime
from typing import Optional


@dataclass
class BuildStep:
    """A single step in a build plan."""
    id: str                           # e.g., "step_001"
    name: str                         # e.g., "TrainingMode Feature"
    step_type: str                    # "feature" | "screen" | "service" | "viewmodel" | "custom"
    template: str                     # template name for pipeline
    template_name: str                # --name value for pipeline
    line: str                         # production line: "ios" | "android" | "web" | "backend"
    language: str                     # "swift" | "kotlin" | "typescript" | "python"
    depends_on: list[str] = field(default_factory=list)  # step IDs this depends on
    status: str = "pending"           # "pending" | "running" | "completed" | "failed" | "skipped"
    result: Optional[dict] = None     # pipeline result after execution
    priority: int = 0                 # higher = build first (0 = normal)
    description: str = ""             # human-readable description


@dataclass
class BuildPlan:
    """Ordered list of build steps for a project."""
    project_name: str
    steps: list[BuildStep] = field(default_factory=list)
    created: str = ""
    status: str = "draft"             # "draft" | "approved" | "in_progress" | "completed" | "failed"

    def get_next_step(self) -> Optional[BuildStep]:
        """Get the next pending step whose dependencies are all completed."""
        completed_ids = {s.id for s in self.steps if s.status == "completed"}
        for step in self.steps:
            if step.status == "pending":
                if all(dep in completed_ids for dep in step.depends_on):
                    return step
        return None

    def get_steps_for_line(self, line: str) -> list[BuildStep]:
        """Get all steps for a specific production line."""
        return [s for s in self.steps if s.line == line]

    def summary(self) -> str:
        """Human-readable plan summary."""
        lines_used = sorted(set(s.line for s in self.steps))
        by_status = {}
        for s in self.steps:
            by_status[s.status] = by_status.get(s.status, 0) + 1

        parts = [
            f"BuildPlan: {self.project_name}",
            f"  Steps: {len(self.steps)} ({', '.join(f'{v} {k}' for k, v in by_status.items())})",
            f"  Lines: {', '.join(lines_used) if lines_used else 'none'}",
            f"  Status: {self.status}",
        ]
        for step in self.steps:
            deps = f" (depends: {', '.join(step.depends_on)})" if step.depends_on else ""
            parts.append(f"  - [{step.line}] {step.name} ({step.template}) — {step.status.upper()}{deps}")
        return "\n".join(parts)

    def to_dict(self) -> dict:
        """Serialize for JSON storage."""
        return {
            "project_name": self.project_name,
            "created": self.created,
            "status": self.status,
            "steps": [
                {
                    "id": s.id,
                    "name": s.name,
                    "step_type": s.step_type,
                    "template": s.template,
                    "template_name": s.template_name,
                    "line": s.line,
                    "language": s.language,
                    "depends_on": s.depends_on,
                    "status": s.status,
                    "result": s.result,
                    "priority": s.priority,
                    "description": s.description,
                }
                for s in self.steps
            ],
        }

    @classmethod
    def from_dict(cls, data: dict) -> 'BuildPlan':
        """Deserialize from JSON."""
        steps = [
            BuildStep(
                id=s["id"],
                name=s["name"],
                step_type=s["step_type"],
                template=s["template"],
                template_name=s["template_name"],
                line=s["line"],
                language=s["language"],
                depends_on=s.get("depends_on", []),
                status=s.get("status", "pending"),
                result=s.get("result"),
                priority=s.get("priority", 0),
                description=s.get("description", ""),
            )
            for s in data.get("steps", [])
        ]
        return cls(
            project_name=data["project_name"],
            steps=steps,
            created=data.get("created", ""),
            status=data.get("status", "draft"),
        )

    def save(self, path: str) -> None:
        """Save plan to JSON file."""
        with open(path, "w", encoding="utf-8") as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)

    @classmethod
    def load(cls, path: str) -> 'BuildPlan':
        """Load plan from JSON file."""
        with open(path, encoding="utf-8") as f:
            return cls.from_dict(json.load(f))
