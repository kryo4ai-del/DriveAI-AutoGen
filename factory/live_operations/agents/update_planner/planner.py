"""UpdatePlanner — converts Decision Engine actions into Factory Briefing Documents.

Deterministic: no LLM calls. Pure template + data assembly.
"""

import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path

from . import config as cfg
from .templates import get_template


class UpdatePlanner:
    """Generates structured Briefing Documents from Decision Engine actions."""

    def __init__(self, data_dir: str | None = None):
        if data_dir:
            self.briefing_dir = Path(data_dir) / cfg.BRIEFING_DIR_NAME
        else:
            self.briefing_dir = (
                Path(__file__).resolve().parent.parent.parent
                / "data" / cfg.BRIEFING_DIR_NAME
            )
        self.briefing_dir.mkdir(parents=True, exist_ok=True)

    # ── Public API ─────────────────────────────────────────────────

    def create_briefing(self, action: dict, app_info: dict | None = None) -> dict:
        """Create a briefing document from a Decision Engine action.

        Args:
            action: Decision Engine output (action_type, severity_scores, etc.)
            app_info: Optional app metadata (name, current_version, repository_path)

        Returns:
            Complete briefing document dict.
        """
        action_type = action.get("action_type", "patch")
        app_id = action.get("app_id", "unknown")
        now = datetime.now(timezone.utc)

        # ── Version Logic ──────────────────────────────────────────
        current_version = (app_info or {}).get("current_version", "1.0.0")
        target_version = self._bump_version(current_version, action_type)

        # ── Scope ──────────────────────────────────────────────────
        severity_scores = action.get("severity_scores", [])
        scope = self._determine_scope(action_type, severity_scores)

        # ── Trigger Details ────────────────────────────────────────
        trigger_details = self._build_trigger_details(severity_scores, scope)

        # ── Briefing ID ────────────────────────────────────────────
        briefing_id = f"BRF-{app_id}-{now.strftime('%Y%m%d%H%M%S')}"

        # ── Assemble Document ──────────────────────────────────────
        briefing = {
            "briefing_id": briefing_id,
            "briefing_type": "live_ops_update",
            "created_at": now.isoformat(),

            # App Context
            "app_context": {
                "app_id": app_id,
                "app_name": (app_info or {}).get("name", app_id),
                "current_version": current_version,
                "target_version": target_version,
                "repository_path": (app_info or {}).get("repository_path", ""),
                "platform": (app_info or {}).get("platform", ""),
            },

            # Update Details
            "update_details": {
                "action_type": action_type,
                "priority": cfg.PRIORITY_MAP.get(action_type, "P2-MEDIUM"),
                "scope": scope,
                "version_bump": cfg.VERSION_BUMP.get(action_type, "patch"),
                "target_version": target_version,
            },

            # Evidence (from Decision Engine)
            "evidence": {
                "health_score": action.get("health_score"),
                "health_zone": action.get("health_zone"),
                "primary_trigger": action.get("primary_trigger"),
                "escalation_level": action.get("escalation_level", 0),
                "data_summary": action.get("data_summary", {}),
                "trigger_details": trigger_details,
            },

            # Factory Instructions
            "factory_instructions": {
                **cfg.FACTORY_INSTRUCTIONS.get(action_type, cfg.FACTORY_INSTRUCTIONS["patch"]),
                "changes_required": self._build_changes_list(trigger_details),
                "files_likely_affected": self._estimate_affected_files(trigger_details),
            },

            # Tracking
            "tracking": {
                "action_id": action.get("action_id"),
                "decision_timestamp": action.get("decided_at"),
                "briefing_status": "created",
                "submitted_to_factory": False,
                "submission_timestamp": None,
                "factory_task_id": None,
            },
        }

        # ── Save ───────────────────────────────────────────────────
        self._save_briefing(briefing)
        return briefing

    def create_from_action_queue(self, action: dict, db=None) -> dict:
        """Create briefing from an action queue entry (includes DB lookup).

        Args:
            action: Action queue row dict.
            db: Optional AppRegistryDB instance for app info lookup.
        """
        app_info = None
        if db:
            app_info = db.get_app(action.get("app_id", ""))

        briefing = self.create_briefing(action, app_info)

        # Update action queue with briefing reference
        if db and action.get("action_id"):
            db.cursor.execute(
                "UPDATE action_queue SET briefing_document = ? WHERE action_id = ?",
                (json.dumps({"briefing_id": briefing["briefing_id"],
                             "path": str(self.briefing_dir / f"{briefing['briefing_id']}.json")}),
                 action["action_id"])
            )
            db.conn.commit()

        return briefing

    def list_briefings(self, app_id: str | None = None) -> list[dict]:
        """List all saved briefings, optionally filtered by app_id."""
        briefings = []
        for f in sorted(self.briefing_dir.glob("BRF-*.json"), reverse=True):
            try:
                data = json.loads(f.read_text(encoding="utf-8"))
                if app_id and data.get("app_context", {}).get("app_id") != app_id:
                    continue
                briefings.append({
                    "briefing_id": data["briefing_id"],
                    "app_id": data["app_context"]["app_id"],
                    "action_type": data["update_details"]["action_type"],
                    "priority": data["update_details"]["priority"],
                    "target_version": data["update_details"]["target_version"],
                    "created_at": data["created_at"],
                    "status": data["tracking"]["briefing_status"],
                })
            except (json.JSONDecodeError, KeyError):
                continue
        return briefings

    def get_briefing(self, briefing_id: str) -> dict | None:
        """Load a specific briefing by ID."""
        path = self.briefing_dir / f"{briefing_id}.json"
        if not path.exists():
            return None
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return None

    # ── Private Helpers ────────────────────────────────────────────

    def _bump_version(self, current: str | None, action_type: str) -> str:
        """Increment version based on action type."""
        if not current:
            current = "1.0.0"
        match = re.match(r"(\d+)\.(\d+)\.(\d+)", current)
        if not match:
            return "1.0.1"
        major, minor, patch = int(match.group(1)), int(match.group(2)), int(match.group(3))

        bump = cfg.VERSION_BUMP.get(action_type, "patch")
        if bump == "minor":
            return f"{major}.{minor + 1}.0"
        else:  # patch
            return f"{major}.{minor}.{patch + 1}"

    def _determine_scope(self, action_type: str, severity_scores: list) -> dict:
        """Determine update scope based on action type and triggers."""
        rule = cfg.SCOPE_RULES.get(action_type, cfg.SCOPE_RULES["patch"])
        triggers_in_scope = severity_scores[:rule["max_triggers"]]

        return {
            "label": rule["label"],
            "description": rule["description"],
            "trigger_count": len(triggers_in_scope),
            "triggers": [t.get("trigger", "unknown") for t in triggers_in_scope],
            "categories_affected": list({t.get("category", "general") for t in triggers_in_scope}),
        }

    def _build_trigger_details(self, severity_scores: list, scope: dict) -> list:
        """Build detailed trigger info with templates."""
        details = []
        for score in severity_scores[:scope.get("trigger_count", 99)]:
            trigger = score.get("trigger", "unknown")
            template = get_template(trigger)
            details.append({
                "trigger": trigger,
                "severity": score.get("severity", 0),
                "category": score.get("category", "general"),
                "detail": score.get("detail", ""),
                "current_value": score.get("current_value"),
                "analysis_focus": template["analysis_focus"],
                "recommended_actions": template["recommended_actions"],
                "affected_areas": template["affected_areas"],
                "metric_to_improve": template["metric_to_improve"],
                "success_criteria": template["success_criteria"],
            })
        return details

    def _build_changes_list(self, trigger_details: list) -> list:
        """Aggregate all recommended actions from trigger details."""
        changes = []
        for td in trigger_details:
            for action in td.get("recommended_actions", []):
                if action not in changes:
                    changes.append(action)
        return changes

    def _estimate_affected_files(self, trigger_details: list) -> list:
        """Estimate which areas/file patterns will be affected."""
        areas = set()
        for td in trigger_details:
            areas.update(td.get("affected_areas", []))
        # Map areas to generic file patterns
        area_to_files = {
            "stability": ["crash_handler.*", "error_reporting.*"],
            "error_handling": ["try_catch blocks", "error_boundaries"],
            "logging": ["logger.*", "analytics.*"],
            "engagement": ["core_loop.*", "gamification.*"],
            "onboarding": ["onboarding/*", "tutorial/*"],
            "notifications": ["push_notifications.*", "notification_scheduler.*"],
            "conversion": ["paywall.*", "checkout.*", "funnel/*"],
            "ui": ["components/*", "screens/*"],
            "performance": ["network/*", "caching/*"],
            "user_satisfaction": ["feedback.*", "rating_prompt.*"],
            "bug_fixes": ["(varies by bug)"],
            "store_presence": ["store_listing.*", "screenshots/*"],
            "support": ["faq.*", "help_center/*"],
            "documentation": ["docs/*", "tooltips.*"],
            "ui_clarity": ["labels.*", "strings.*"],
            "monetization": ["iap.*", "subscription.*", "pricing.*"],
            "retention": ["re_engagement.*", "push_scheduler.*"],
            "general": ["(to be determined)"],
        }
        files = []
        for area in areas:
            files.extend(area_to_files.get(area, [f"{area}/*"]))
        return files

    def _save_briefing(self, briefing: dict) -> Path:
        """Save briefing as JSON file."""
        path = self.briefing_dir / f"{briefing['briefing_id']}.json"
        path.write_text(json.dumps(briefing, indent=2, default=str), encoding="utf-8")
        return path
