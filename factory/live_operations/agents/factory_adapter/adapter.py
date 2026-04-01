"""FactoryAdapter — bridges Live Ops Briefings to Factory Dispatcher.

STUB Implementation: Tracks submissions and simulates Factory acceptance.
Actual PipelineDispatcher integration will be wired in a future phase.
"""

import json
import uuid
from datetime import datetime, timezone
from pathlib import Path

from . import config as cfg


class FactoryAdapter:
    """Manages the submission of Briefing Documents to the Factory."""

    def __init__(self, data_dir: str | None = None):
        if data_dir:
            self.submissions_dir = Path(data_dir) / cfg.SUBMISSIONS_DIR_NAME
        else:
            self.submissions_dir = (
                Path(__file__).resolve().parent.parent.parent
                / "data" / cfg.SUBMISSIONS_DIR_NAME
            )
        self.submissions_dir.mkdir(parents=True, exist_ok=True)

    # ── Public API ─────────────────────────────────────────────────

    def submit_briefing(self, briefing: dict) -> dict:
        """Submit a briefing to the Factory.

        Creates a submission record and attempts Factory dispatch (STUB).

        Args:
            briefing: Complete briefing document from UpdatePlanner.

        Returns:
            Submission record dict.
        """
        now = datetime.now(timezone.utc)
        briefing_id = briefing.get("briefing_id", "unknown")
        app_id = briefing.get("app_context", {}).get("app_id", "unknown")

        short_uid = uuid.uuid4().hex[:6]
        submission_id = f"SUB-{app_id}-{now.strftime('%Y%m%d%H%M%S')}-{short_uid}"

        submission = {
            "submission_id": submission_id,
            "briefing_id": briefing_id,
            "app_id": app_id,
            "action_type": briefing.get("update_details", {}).get("action_type", "patch"),
            "priority": briefing.get("update_details", {}).get("priority", "P2-MEDIUM"),
            "target_version": briefing.get("update_details", {}).get("target_version", ""),
            "status": cfg.STATUS_CREATED,
            "created_at": now.isoformat(),
            "submitted_at": None,
            "accepted_at": None,
            "completed_at": None,
            "factory_task_id": None,
            "factory_product_id": None,
            "error": None,
            "history": [
                {"status": cfg.STATUS_CREATED, "timestamp": now.isoformat(), "detail": "Submission erstellt"},
            ],
        }

        # Attempt Factory dispatch (STUB)
        dispatch_result = self._dispatch_to_factory(briefing, submission_id)
        if dispatch_result["success"]:
            submission["status"] = cfg.STATUS_SUBMITTED
            submission["submitted_at"] = now.isoformat()
            submission["factory_task_id"] = dispatch_result.get("task_id")
            submission["factory_product_id"] = dispatch_result.get("product_id")
            submission["history"].append({
                "status": cfg.STATUS_SUBMITTED,
                "timestamp": now.isoformat(),
                "detail": dispatch_result.get("message", "An Factory uebergeben"),
            })
        else:
            submission["error"] = dispatch_result.get("error", "Dispatch fehlgeschlagen")
            submission["history"].append({
                "status": "dispatch_failed",
                "timestamp": now.isoformat(),
                "detail": submission["error"],
            })

        # Save
        self._save_submission(submission)
        return submission

    def update_status(self, submission_id: str, new_status: str, detail: str = "") -> dict | None:
        """Update submission status (for Factory callbacks or manual updates)."""
        submission = self.get_submission(submission_id)
        if not submission:
            return None

        current = submission["status"]
        valid_next = cfg.VALID_TRANSITIONS.get(current, [])
        if new_status not in valid_next:
            submission["history"].append({
                "status": "invalid_transition",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "detail": f"Cannot transition {current} -> {new_status}",
            })
            self._save_submission(submission)
            return submission

        now = datetime.now(timezone.utc).isoformat()
        submission["status"] = new_status
        if new_status == cfg.STATUS_ACCEPTED:
            submission["accepted_at"] = now
        elif new_status in (cfg.STATUS_COMPLETED, cfg.STATUS_FAILED):
            submission["completed_at"] = now
        submission["history"].append({
            "status": new_status,
            "timestamp": now,
            "detail": detail or f"Status -> {new_status}",
        })

        self._save_submission(submission)
        return submission

    def get_submission(self, submission_id: str) -> dict | None:
        """Load a specific submission."""
        path = self.submissions_dir / f"{submission_id}.json"
        if not path.exists():
            return None
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return None

    def list_submissions(self, app_id: str | None = None, status: str | None = None) -> list[dict]:
        """List all submissions with optional filters."""
        submissions = []
        for f in sorted(self.submissions_dir.glob("SUB-*.json"), reverse=True):
            try:
                data = json.loads(f.read_text(encoding="utf-8"))
                if app_id and data.get("app_id") != app_id:
                    continue
                if status and data.get("status") != status:
                    continue
                submissions.append({
                    "submission_id": data["submission_id"],
                    "briefing_id": data["briefing_id"],
                    "app_id": data["app_id"],
                    "action_type": data["action_type"],
                    "priority": data["priority"],
                    "status": data["status"],
                    "created_at": data["created_at"],
                    "target_version": data.get("target_version", ""),
                })
            except (json.JSONDecodeError, KeyError):
                continue
        return submissions

    def get_active_submissions(self) -> list[dict]:
        """Get all non-terminal submissions (created, submitted, accepted, in_progress)."""
        terminal = {cfg.STATUS_COMPLETED, cfg.STATUS_FAILED}
        return [s for s in self.list_submissions() if s["status"] not in terminal]

    # ── STUB: Factory Dispatch ─────────────────────────────────────

    def _dispatch_to_factory(self, briefing: dict, submission_id: str) -> dict:
        """STUB — simulate Factory dispatch.

        In production, this would:
        1. Call PipelineDispatcher.submit_idea() with briefing data
        2. Or create a project via project_registry.register_project()
        3. Return the factory's task/product ID

        For now: always succeeds with a simulated product_id.
        """
        app_id = briefing.get("app_context", {}).get("app_id", "unknown")
        action_type = briefing.get("update_details", {}).get("action_type", "patch")
        target_version = briefing.get("update_details", {}).get("target_version", "")

        # Simulate success
        simulated_product_id = f"PROD-{app_id}-{action_type}-{target_version}"

        return {
            "success": True,
            "task_id": f"TASK-{submission_id}",
            "product_id": simulated_product_id,
            "message": f"STUB: Briefing an Factory uebergeben als {simulated_product_id}",
        }

    # ── Private Helpers ────────────────────────────────────────────

    def _save_submission(self, submission: dict) -> Path:
        """Save submission as JSON file."""
        path = self.submissions_dir / f"{submission['submission_id']}.json"
        path.write_text(json.dumps(submission, indent=2, default=str), encoding="utf-8")
        return path
