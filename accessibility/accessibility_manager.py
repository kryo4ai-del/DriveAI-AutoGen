# accessibility_manager.py
# Manages accessibility reports — CRUD for accessibility findings.

import json
import os
from datetime import date

_ACC_DIR = os.path.dirname(__file__)
_REPORTS_PATH = os.path.join(_ACC_DIR, "accessibility_reports.json")

VALID_ISSUE_TYPES = (
    "missing_label",
    "poor_contrast",
    "small_touch_target",
    "voiceover_issue",
    "dynamic_text_issue",
    "missing_hint",
    "focus_order",
    "semantic_structure",
    "animation_safety",
    "general",
)

VALID_SEVERITIES = ("info", "low", "medium", "high", "critical")

VALID_REPORT_STATUSES = ("new", "acknowledged", "fixed", "wont_fix", "false_positive")


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


class AccessibilityManager:
    """Manages accessibility reports — create, update, query findings."""

    def __init__(self):
        self.data = _load_json(_REPORTS_PATH)
        self.data.setdefault("reports", [])

    def save(self) -> None:
        _save_json(_REPORTS_PATH, self.data)

    @property
    def reports(self) -> list[dict]:
        return self.data["reports"]

    def _next_id(self) -> str:
        max_num = 0
        for rep in self.reports:
            id_str = rep.get("report_id", "")
            if id_str.startswith("A11Y-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"A11Y-{max_num + 1:03d}"

    def add_report(
        self,
        project: str,
        file: str,
        issue_type: str,
        severity: str = "medium",
        description: str = "",
        recommendation: str = "",
        notes: str = "",
    ) -> dict:
        if issue_type not in VALID_ISSUE_TYPES:
            raise ValueError(f"Invalid issue type: {issue_type}. Valid: {VALID_ISSUE_TYPES}")
        if severity not in VALID_SEVERITIES:
            raise ValueError(f"Invalid severity: {severity}. Valid: {VALID_SEVERITIES}")
        report = {
            "report_id": self._next_id(),
            "project": project,
            "file": file,
            "issue_type": issue_type,
            "severity": severity,
            "description": description,
            "recommendation": recommendation,
            "status": "new",
            "detected_at": date.today().isoformat(),
            "notes": notes,
        }
        self.reports.append(report)
        self.save()
        return report

    def get_report(self, report_id: str) -> dict | None:
        for rep in self.reports:
            if rep.get("report_id") == report_id:
                return rep
        return None

    def update_report(self, report_id: str, **fields) -> dict | None:
        rep = self.get_report(report_id)
        if not rep:
            return None
        for key, value in fields.items():
            if key in rep and key != "report_id":
                rep[key] = value
        self.save()
        return rep

    def transition(self, report_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_REPORT_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_REPORT_STATUSES}")
        return self.update_report(report_id, status=new_status)

    def mark_fixed(self, report_id: str) -> dict | None:
        return self.transition(report_id, "fixed")

    def by_project(self, project: str) -> list[dict]:
        return [r for r in self.reports if r.get("project") == project]

    def by_type(self, issue_type: str) -> list[dict]:
        return [r for r in self.reports if r.get("issue_type") == issue_type]

    def by_severity(self, severity: str) -> list[dict]:
        return [r for r in self.reports if r.get("severity") == severity]

    def by_status(self, status: str) -> list[dict]:
        return [r for r in self.reports if r.get("status") == status]

    def open_issues(self) -> list[dict]:
        return [r for r in self.reports if r.get("status") in ("new", "acknowledged")]

    def get_summary(self) -> str:
        total = len(self.reports)
        if total == 0:
            return "Accessibility — total: 0 reports"
        open_reports = self.open_issues()
        by_sev = {}
        for rep in open_reports:
            s = rep.get("severity", "info")
            by_sev[s] = by_sev.get(s, 0) + 1
        sev_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_sev.items()))
        lines = [f"Accessibility — total: {total}  open: {len(open_reports)}  ({sev_str})"]
        critical = by_sev.get("critical", 0)
        high = by_sev.get("high", 0)
        if critical > 0:
            lines.append(f"  CRITICAL: {critical} accessibility issues require immediate fix")
        if high > 0:
            lines.append(f"  HIGH: {high} accessibility issues need attention")
        return "\n".join(lines)
