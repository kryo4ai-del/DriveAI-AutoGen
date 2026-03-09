# watch_manager.py
# Manages ecosystem watch events — CRUD, impact assessment, dashboard generation.

import json
import os
from datetime import date

_WATCH_DIR = os.path.dirname(__file__)
_EVENTS_PATH = os.path.join(_WATCH_DIR, "watch_events.json")
_SOURCES_PATH = os.path.join(_WATCH_DIR, "watch_sources.json")
_DASHBOARD_PATH = os.path.join(_WATCH_DIR, "watch_dashboard.md")

VALID_CATEGORIES = (
    "sdk_requirement",
    "tooling_update",
    "model_update",
    "security_change",
    "pricing_change",
    "deprecation",
    "opportunity",
)

VALID_SEVERITIES = ("info", "low", "medium", "high", "critical")

VALID_EVENT_STATUSES = ("new", "acknowledged", "in-progress", "resolved", "dismissed")


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


class WatchManager:
    """Manages ecosystem watch events — create, update, query, and generate dashboard."""

    def __init__(self):
        self.data = _load_json(_EVENTS_PATH)
        self.data.setdefault("events", [])

    def save(self) -> None:
        _save_json(_EVENTS_PATH, self.data)

    @property
    def events(self) -> list[dict]:
        return self.data["events"]

    def _next_id(self) -> str:
        max_num = 0
        for evt in self.events:
            id_str = evt.get("event_id", "")
            if id_str.startswith("WATCH-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"WATCH-{max_num + 1:03d}"

    def add_event(
        self,
        title: str,
        category: str,
        source: str = "",
        summary: str = "",
        affected_projects: list[str] | None = None,
        affected_platforms: list[str] | None = None,
        severity: str = "info",
        recommended_action: str = "",
        deadline: str = "",
        notes: str = "",
    ) -> dict:
        if category not in VALID_CATEGORIES:
            raise ValueError(f"Invalid category: {category}. Valid: {VALID_CATEGORIES}")
        if severity not in VALID_SEVERITIES:
            raise ValueError(f"Invalid severity: {severity}. Valid: {VALID_SEVERITIES}")
        event = {
            "event_id": self._next_id(),
            "source": source,
            "category": category,
            "title": title,
            "summary": summary,
            "affected_projects": affected_projects or [],
            "affected_platforms": affected_platforms or [],
            "severity": severity,
            "recommended_action": recommended_action,
            "deadline": deadline,
            "status": "new",
            "detected_at": date.today().isoformat(),
            "notes": notes,
        }
        self.events.append(event)
        self.save()
        return event

    def get_event(self, event_id: str) -> dict | None:
        for evt in self.events:
            if evt.get("event_id") == event_id:
                return evt
        return None

    def update_event(self, event_id: str, **fields) -> dict | None:
        evt = self.get_event(event_id)
        if not evt:
            return None
        for key, value in fields.items():
            if key in evt and key != "event_id":
                evt[key] = value
        self.save()
        return evt

    def transition(self, event_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_EVENT_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_EVENT_STATUSES}")
        return self.update_event(event_id, status=new_status)

    def acknowledge(self, event_id: str) -> dict | None:
        return self.transition(event_id, "acknowledged")

    def resolve(self, event_id: str) -> dict | None:
        return self.transition(event_id, "resolved")

    def dismiss(self, event_id: str) -> dict | None:
        return self.transition(event_id, "dismissed")

    def by_category(self, category: str) -> list[dict]:
        return [e for e in self.events if e.get("category") == category]

    def by_severity(self, severity: str) -> list[dict]:
        return [e for e in self.events if e.get("severity") == severity]

    def by_status(self, status: str) -> list[dict]:
        return [e for e in self.events if e.get("status") == status]

    def by_project(self, project: str) -> list[dict]:
        return [e for e in self.events if project in e.get("affected_projects", [])]

    def active(self) -> list[dict]:
        """Return events that are not resolved or dismissed."""
        return [e for e in self.events if e.get("status") not in ("resolved", "dismissed")]

    def get_summary(self) -> str:
        total = len(self.events)
        if total == 0:
            return "Watch — total: 0 events"
        active = self.active()
        by_sev = {}
        for evt in active:
            s = evt.get("severity", "info")
            by_sev[s] = by_sev.get(s, 0) + 1
        sev_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_sev.items()))
        lines = [f"Watch — total: {total}  active: {len(active)}  ({sev_str})"]
        critical = by_sev.get("critical", 0)
        high = by_sev.get("high", 0)
        if critical > 0:
            lines.append(f"  CRITICAL: {critical} events require immediate attention")
        if high > 0:
            lines.append(f"  HIGH: {high} events need action soon")
        return "\n".join(lines)

    def generate_dashboard(self) -> str:
        """Generate a markdown dashboard grouped by urgency."""
        active = self.active()
        if not active:
            return "# Watch Dashboard\n\nNo active events.\n"

        # Group by urgency: Now (critical/high), Soon (medium), Later (low), Info
        groups = {
            "Now": [e for e in active if e.get("severity") in ("critical", "high")],
            "Soon": [e for e in active if e.get("severity") == "medium"],
            "Later": [e for e in active if e.get("severity") == "low"],
            "Info": [e for e in active if e.get("severity") == "info"],
        }

        lines = [
            "# Watch Dashboard",
            "",
            f"Generated: {date.today().isoformat()}",
            f"Active events: {len(active)}",
            "",
        ]

        for group_name, events in groups.items():
            if not events:
                continue
            lines.append(f"## {group_name}")
            lines.append("")
            for evt in events:
                eid = evt.get("event_id", "?")
                title = evt.get("title", "?")
                cat = evt.get("category", "?")
                sev = evt.get("severity", "?")
                status = evt.get("status", "?")
                projects = ", ".join(evt.get("affected_projects", [])) or "all"
                action = evt.get("recommended_action", "")
                deadline = evt.get("deadline", "")

                lines.append(f"### {eid}: {title}")
                lines.append(f"- Category: {cat}")
                lines.append(f"- Severity: {sev}")
                lines.append(f"- Status: {status}")
                lines.append(f"- Projects: {projects}")
                if deadline:
                    lines.append(f"- Deadline: {deadline}")
                if action:
                    lines.append(f"- Action: {action}")
                lines.append("")

        lines.append("---")
        lines.append("")

        return "\n".join(lines)

    def save_dashboard(self) -> str:
        """Generate and save dashboard to watch/watch_dashboard.md."""
        content = self.generate_dashboard()
        os.makedirs(os.path.dirname(os.path.abspath(_DASHBOARD_PATH)), exist_ok=True)
        with open(_DASHBOARD_PATH, "w", encoding="utf-8") as f:
            f.write(content)
        return _DASHBOARD_PATH
