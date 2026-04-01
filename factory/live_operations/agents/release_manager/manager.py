"""ReleaseManager — coordinates the release lifecycle.

Flow: QA Check -> Store Upload (STUB) -> Registry Update -> Cooling Period
Deterministic: no LLM calls.
"""

import json
import uuid
from datetime import datetime, timezone
from pathlib import Path

from . import config as cfg
from .qa_checker import QAChecker


class ReleaseManager:
    """Coordinates releases from Factory completion to Store deployment."""

    def __init__(self, data_dir: str | None = None, db=None):
        """
        Args:
            data_dir: Override for release data storage.
            db: AppRegistryDB instance (optional, for real DB operations).
        """
        if data_dir:
            self.releases_dir = Path(data_dir) / cfg.RELEASES_DIR_NAME
        else:
            self.releases_dir = (
                Path(__file__).resolve().parent.parent.parent
                / "data" / cfg.RELEASES_DIR_NAME
            )
        self.releases_dir.mkdir(parents=True, exist_ok=True)
        self.db = db
        self.qa = QAChecker()

    # ── Public API ─────────────────────────────────────────────────

    def process_release(self, submission: dict, release_context: dict) -> dict:
        """Process a completed Factory submission into a release.

        Args:
            submission: FactoryAdapter submission record.
            release_context: Context for QA checks:
                - health_score, active_anomalies, cooling_active,
                - has_briefing, has_submission

        Returns:
            Release record dict.
        """
        now = datetime.now(timezone.utc)
        short_uid = uuid.uuid4().hex[:6]
        app_id = submission.get("app_id", "unknown")
        action_type = submission.get("action_type", "patch")
        target_version = submission.get("target_version", "1.0.1")

        release_id = f"REL-{app_id}-{now.strftime('%Y%m%d%H%M%S')}-{short_uid}"

        release = {
            "release_id": release_id,
            "app_id": app_id,
            "action_type": action_type,
            "target_version": target_version,
            "submission_id": submission.get("submission_id"),
            "briefing_id": submission.get("briefing_id"),
            "status": cfg.STATUS_PENDING,
            "created_at": now.isoformat(),
            "qa_result": None,
            "store_upload": None,
            "registry_updated": False,
            "cooling_started": False,
            "completed_at": None,
            "error": None,
            "history": [
                {"status": cfg.STATUS_PENDING, "timestamp": now.isoformat(), "detail": "Release erstellt"},
            ],
        }

        # ── Step 1: QA Check ──────────────────────────────────────
        release["status"] = cfg.STATUS_QA_CHECK
        release["history"].append({
            "status": cfg.STATUS_QA_CHECK,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "detail": "QA Check gestartet",
        })

        qa_result = self.qa.check(release_context)
        release["qa_result"] = qa_result

        if not qa_result["passed"]:
            release["status"] = cfg.STATUS_QA_FAILED
            release["error"] = "; ".join(qa_result["blockers"])
            release["history"].append({
                "status": cfg.STATUS_QA_FAILED,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "detail": f"QA fehlgeschlagen: {release['error']}",
            })
            self._save_release(release)
            return release

        release["status"] = cfg.STATUS_QA_PASSED
        release["history"].append({
            "status": cfg.STATUS_QA_PASSED,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "detail": f"QA bestanden ({qa_result['passed_checks']}/{qa_result['total_checks']})",
        })

        # ── Step 2: Store Upload (STUB) ───────────────────────────
        release["status"] = cfg.STATUS_UPLOADING
        release["history"].append({
            "status": cfg.STATUS_UPLOADING,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "detail": "Store Upload gestartet (STUB)",
        })

        upload_result = self._upload_to_store(app_id, target_version, action_type)
        release["store_upload"] = upload_result

        if not upload_result["success"]:
            release["status"] = cfg.STATUS_FAILED
            release["error"] = upload_result.get("error", "Upload fehlgeschlagen")
            release["history"].append({
                "status": cfg.STATUS_FAILED,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "detail": release["error"],
            })
            self._save_release(release)
            return release

        release["status"] = cfg.STATUS_UPLOADED
        release["history"].append({
            "status": cfg.STATUS_UPLOADED,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "detail": "Store Upload erfolgreich (STUB)",
        })

        # ── Step 3: Registry Update ───────────────────────────────
        self._update_registry(app_id, target_version, action_type, release)

        # ── Step 4: Cooling Period ────────────────────────────────
        self._start_cooling(app_id, action_type, release)

        # ── Done ──────────────────────────────────────────────────
        release["status"] = cfg.STATUS_RELEASED
        release["completed_at"] = datetime.now(timezone.utc).isoformat()
        release["history"].append({
            "status": cfg.STATUS_RELEASED,
            "timestamp": release["completed_at"],
            "detail": f"Release v{target_version} erfolgreich abgeschlossen",
        })

        self._save_release(release)
        return release

    def get_release(self, release_id: str) -> dict | None:
        """Load a specific release by ID."""
        path = self.releases_dir / f"{release_id}.json"
        if not path.exists():
            return None
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return None

    def list_releases(self, app_id: str | None = None, status: str | None = None) -> list[dict]:
        """List all releases with optional filters."""
        releases = []
        for f in sorted(self.releases_dir.glob("REL-*.json"), reverse=True):
            try:
                data = json.loads(f.read_text(encoding="utf-8"))
                if app_id and data.get("app_id") != app_id:
                    continue
                if status and data.get("status") != status:
                    continue
                releases.append({
                    "release_id": data["release_id"],
                    "app_id": data["app_id"],
                    "action_type": data["action_type"],
                    "target_version": data["target_version"],
                    "status": data["status"],
                    "created_at": data["created_at"],
                    "completed_at": data.get("completed_at"),
                    "qa_passed": data.get("qa_result", {}).get("passed") if data.get("qa_result") else None,
                })
            except (json.JSONDecodeError, KeyError):
                continue
        return releases

    # ── Private Helpers ────────────────────────────────────────────

    def _upload_to_store(self, app_id: str, version: str, action_type: str) -> dict:
        """STUB — simulate store upload.

        In production: upload APK/IPA to App Store / Play Store.
        """
        return {
            "success": True,
            "stub": True,
            "store": "simulated",
            "message": f"STUB: {app_id} v{version} ({action_type}) an Store uebergeben",
        }

    def _update_registry(self, app_id: str, version: str, action_type: str, release: dict):
        """Update app registry with new version and add release record."""
        release["registry_updated"] = True

        if self.db:
            try:
                # Update current version
                self.db.update_app(app_id, {
                    "current_version": version,
                    "last_stable_version": version,
                })
                # Add release record
                self.db.add_release(app_id, {
                    "version": version,
                    "update_type": action_type,
                    "triggered_by": "release_manager",
                    "changes_summary": f"Release v{version} via Live Ops ({action_type})",
                    "health_score_before": release.get("qa_result", {})
                        .get("checks", [{}])[0].get("detail", ""),
                })
            except Exception as e:
                release["registry_updated"] = False
                release["history"].append({
                    "status": "registry_error",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "detail": f"Registry Update Fehler: {e}",
                })
        else:
            release["history"].append({
                "status": "registry_stub",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "detail": "Registry Update (kein DB-Zugang, nur lokal gespeichert)",
            })

    def _start_cooling(self, app_id: str, action_type: str, release: dict):
        """Start cooling period after release."""
        hours = cfg.COOLING_AFTER_RELEASE.get(action_type, 168)
        release["cooling_started"] = True
        release["cooling_hours"] = hours

        if self.db:
            try:
                self.db.set_cooling(app_id, action_type, hours)
            except Exception as e:
                release["cooling_started"] = False
                release["history"].append({
                    "status": "cooling_error",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "detail": f"Cooling Fehler: {e}",
                })
        else:
            release["history"].append({
                "status": "cooling_stub",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "detail": f"Cooling {hours}h gestartet (kein DB-Zugang, nur lokal)",
            })

    def _save_release(self, release: dict) -> Path:
        """Save release record as JSON file."""
        path = self.releases_dir / f"{release['release_id']}.json"
        path.write_text(json.dumps(release, indent=2, default=str), encoding="utf-8")
        return path
