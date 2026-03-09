# compliance_manager.py
# Manages legal/regulatory risk assessment reports — CRUD and querying.
# Does NOT provide legal advice — only structures risk findings for review.

import json
import os
from datetime import date

_COMPLIANCE_DIR = os.path.dirname(__file__)
_REPORTS_PATH = os.path.join(_COMPLIANCE_DIR, "compliance_reports.json")

VALID_TOPICS = (
    "copyright",
    "licensing",
    "trademark",
    "platform_policy",
    "privacy_gdpr",
    "regulated_domain",
    "ai_content_risk",
    "terms_of_service",
    "data_retention",
    "general",
)

VALID_RISK_LEVELS = ("low", "medium", "high", "critical")

VALID_STATUSES = (
    "new",
    "reviewed",
    "mitigated",
    "accepted",
    "blocked",
    "dismissed",
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


class ComplianceManager:
    """Manages compliance/legal risk reports — create, update, query."""

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
        for rpt in self.reports:
            id_str = rpt.get("report_id", "")
            if id_str.startswith("LEGAL-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"LEGAL-{max_num + 1:03d}"

    def add_report(
        self,
        project: str,
        topic: str,
        summary: str = "",
        linked_idea_id: str = "",
        linked_spec_id: str = "",
        risk_level: str = "medium",
        possible_blockers: list[str] | None = None,
        estimated_complexity: str = "",
        external_review_needed: bool = False,
        recommended_next_step: str = "",
        notes: str = "",
    ) -> dict:
        if topic not in VALID_TOPICS:
            raise ValueError(f"Invalid topic: {topic}. Valid: {VALID_TOPICS}")
        if risk_level not in VALID_RISK_LEVELS:
            raise ValueError(f"Invalid risk_level: {risk_level}. Valid: {VALID_RISK_LEVELS}")

        report = {
            "report_id": self._next_id(),
            "project": project,
            "linked_idea_id": linked_idea_id,
            "linked_spec_id": linked_spec_id,
            "topic": topic,
            "risk_level": risk_level,
            "summary": summary,
            "possible_blockers": possible_blockers or [],
            "estimated_complexity": estimated_complexity,
            "external_review_needed": external_review_needed,
            "recommended_next_step": recommended_next_step,
            "status": "new",
            "notes": notes,
            "created_at": date.today().isoformat(),
        }
        self.reports.append(report)
        self.save()
        return report

    def get_report(self, report_id: str) -> dict | None:
        for rpt in self.reports:
            if rpt.get("report_id") == report_id:
                return rpt
        return None

    def update_report(self, report_id: str, **fields) -> dict | None:
        rpt = self.get_report(report_id)
        if not rpt:
            return None
        for key, value in fields.items():
            if key in rpt and key != "report_id":
                rpt[key] = value
        self.save()
        return rpt

    def transition(self, report_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_STATUSES}")
        return self.update_report(report_id, status=new_status)

    def review(self, report_id: str) -> dict | None:
        return self.transition(report_id, "reviewed")

    def mitigate(self, report_id: str) -> dict | None:
        return self.transition(report_id, "mitigated")

    def accept_risk(self, report_id: str) -> dict | None:
        return self.transition(report_id, "accepted")

    def block(self, report_id: str) -> dict | None:
        return self.transition(report_id, "blocked")

    def dismiss(self, report_id: str) -> dict | None:
        return self.transition(report_id, "dismissed")

    def by_topic(self, topic: str) -> list[dict]:
        return [r for r in self.reports if r.get("topic") == topic]

    def by_risk_level(self, level: str) -> list[dict]:
        return [r for r in self.reports if r.get("risk_level") == level]

    def by_status(self, status: str) -> list[dict]:
        return [r for r in self.reports if r.get("status") == status]

    def by_project(self, project: str) -> list[dict]:
        return [r for r in self.reports if r.get("project") == project]

    def by_idea(self, idea_id: str) -> list[dict]:
        return [r for r in self.reports if r.get("linked_idea_id") == idea_id]

    def by_spec(self, spec_id: str) -> list[dict]:
        return [r for r in self.reports if r.get("linked_spec_id") == spec_id]

    def active(self) -> list[dict]:
        """Return reports not yet dismissed or accepted."""
        return [r for r in self.reports if r.get("status") not in ("dismissed", "accepted")]

    def blockers(self) -> list[dict]:
        """Return reports with status 'blocked'."""
        return [r for r in self.reports if r.get("status") == "blocked"]

    def needs_external_review(self) -> list[dict]:
        """Return reports flagged for external legal review."""
        return [r for r in self.reports if r.get("external_review_needed") is True]

    def get_summary(self) -> str:
        total = len(self.reports)
        if total == 0:
            return "Compliance -- total: 0 reports"
        active = self.active()
        by_risk = {}
        for rpt in active:
            lvl = rpt.get("risk_level", "?")
            by_risk[lvl] = by_risk.get(lvl, 0) + 1
        risk_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_risk.items()))
        blocked = len(self.blockers())
        ext_review = len(self.needs_external_review())
        lines = [f"Compliance -- total: {total}  active: {len(active)}  ({risk_str})"]
        if blocked > 0:
            lines.append(f"  BLOCKED: {blocked} reports blocking progress")
        if ext_review > 0:
            lines.append(f"  EXTERNAL REVIEW: {ext_review} reports need legal counsel")
        return "\n".join(lines)
