"""App Registry Database — SQLite-basiertes Gedächtnis für alle DAI-Core Apps.

Tabellen:
  - apps: Core + Live Operations Felder
  - release_history: Alle Releases pro App
  - action_queue: Priorisierte Aktionen
  - health_score_history: Health Score Verlauf
"""

import os
import sqlite3
import uuid
from datetime import datetime, timedelta, timezone
from typing import Optional


def _new_id() -> str:
    return uuid.uuid4().hex[:12]


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


class AppRegistryDB:
    """SQLite-Manager für die App Registry."""

    def __init__(self, db_path: Optional[str] = None) -> None:
        if db_path is None:
            db_path = os.path.join(
                os.path.dirname(__file__), "registry.db"
            )
        self.db_path = db_path
        self._init_db()

    # ------------------------------------------------------------------
    # Initialisation
    # ------------------------------------------------------------------

    def _get_conn(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON")
        return conn

    def _init_db(self) -> None:
        print(f"[App Registry] DB path: {self.db_path}")
        conn = self._get_conn()
        cur = conn.cursor()

        cur.execute("""
            CREATE TABLE IF NOT EXISTS apps (
                app_id              TEXT PRIMARY KEY,
                app_name            TEXT NOT NULL,
                bundle_id           TEXT,
                package_name        TEXT,
                apple_app_id        TEXT,
                google_package      TEXT,
                current_version     TEXT,
                last_upload_timestamp TEXT,
                store_status        TEXT DEFAULT 'unknown',
                app_profile         TEXT DEFAULT 'utility',
                health_score        REAL DEFAULT 0.0,
                health_zone         TEXT DEFAULT 'red',
                last_stable_version TEXT,
                cooling_until       TEXT,
                cooling_type        TEXT,
                monetization_model  TEXT DEFAULT 'unknown',
                firebase_project_id TEXT,
                total_releases      INTEGER DEFAULT 0,
                first_release_date  TEXT,
                repository_path     TEXT,
                created_at          TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at          TEXT DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cur.execute("""
            CREATE TABLE IF NOT EXISTS release_history (
                release_id          TEXT PRIMARY KEY,
                app_id              TEXT NOT NULL,
                version             TEXT NOT NULL,
                release_date        TEXT NOT NULL,
                update_type         TEXT NOT NULL,
                triggered_by        TEXT NOT NULL,
                changes_summary     TEXT,
                health_score_before REAL,
                health_score_after  REAL,
                created_at          TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (app_id) REFERENCES apps(app_id)
            )
        """)

        cur.execute("""
            CREATE TABLE IF NOT EXISTS action_queue (
                action_id           TEXT PRIMARY KEY,
                app_id              TEXT NOT NULL,
                action_type         TEXT NOT NULL,
                severity_score      REAL DEFAULT 0.0,
                status              TEXT DEFAULT 'pending',
                created_at          TEXT DEFAULT CURRENT_TIMESTAMP,
                started_at          TEXT,
                completed_at        TEXT,
                briefing_document   TEXT,
                FOREIGN KEY (app_id) REFERENCES apps(app_id)
            )
        """)

        cur.execute("""
            CREATE TABLE IF NOT EXISTS health_score_history (
                record_id           TEXT PRIMARY KEY,
                app_id              TEXT NOT NULL,
                timestamp           TEXT DEFAULT CURRENT_TIMESTAMP,
                overall_score       REAL,
                stability_score     REAL,
                satisfaction_score  REAL,
                engagement_score    REAL,
                revenue_score       REAL,
                growth_score        REAL,
                FOREIGN KEY (app_id) REFERENCES apps(app_id)
            )
        """)

        conn.commit()
        conn.close()
        print("[App Registry] Tabellen initialisiert.")

    # ------------------------------------------------------------------
    # Apps — CRUD
    # ------------------------------------------------------------------

    def add_app(self, app_data: dict) -> str:
        app_id = app_data.get("app_id", _new_id())
        now = _now_iso()

        conn = self._get_conn()
        conn.execute(
            """INSERT INTO apps (
                app_id, app_name, bundle_id, package_name,
                apple_app_id, google_package, current_version,
                last_upload_timestamp, store_status, app_profile,
                health_score, health_zone, last_stable_version,
                cooling_until, cooling_type, monetization_model,
                firebase_project_id, total_releases, first_release_date,
                repository_path, created_at, updated_at
            ) VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
            )""",
            (
                app_id,
                app_data.get("app_name", "Unnamed App"),
                app_data.get("bundle_id"),
                app_data.get("package_name"),
                app_data.get("apple_app_id"),
                app_data.get("google_package"),
                app_data.get("current_version"),
                app_data.get("last_upload_timestamp"),
                app_data.get("store_status", "unknown"),
                app_data.get("app_profile", "utility"),
                app_data.get("health_score", 0.0),
                app_data.get("health_zone", "red"),
                app_data.get("last_stable_version"),
                app_data.get("cooling_until"),
                app_data.get("cooling_type"),
                app_data.get("monetization_model", "unknown"),
                app_data.get("firebase_project_id"),
                app_data.get("total_releases", 0),
                app_data.get("first_release_date"),
                app_data.get("repository_path"),
                now,
                now,
            ),
        )
        conn.commit()
        conn.close()
        print(f"[App Registry] App registriert: {app_id} ({app_data.get('app_name', '?')})")
        return app_id

    def update_app(self, app_id: str, updates: dict) -> None:
        if not updates:
            return
        updates["updated_at"] = _now_iso()
        set_clause = ", ".join(f"{k} = ?" for k in updates)
        values = list(updates.values()) + [app_id]

        conn = self._get_conn()
        conn.execute(f"UPDATE apps SET {set_clause} WHERE app_id = ?", values)
        conn.commit()
        conn.close()
        print(f"[App Registry] App aktualisiert: {app_id}")

    def get_app(self, app_id: str) -> Optional[dict]:
        conn = self._get_conn()
        row = conn.execute("SELECT * FROM apps WHERE app_id = ?", (app_id,)).fetchone()
        conn.close()
        return dict(row) if row else None

    def get_all_apps(self) -> list[dict]:
        conn = self._get_conn()
        rows = conn.execute("SELECT * FROM apps ORDER BY health_score ASC").fetchall()
        conn.close()
        return [dict(r) for r in rows]

    def get_apps_by_zone(self, zone: str) -> list[dict]:
        conn = self._get_conn()
        rows = conn.execute(
            "SELECT * FROM apps WHERE health_zone = ? ORDER BY health_score ASC",
            (zone,),
        ).fetchall()
        conn.close()
        return [dict(r) for r in rows]

    # ------------------------------------------------------------------
    # Release History
    # ------------------------------------------------------------------

    def add_release(self, app_id: str, release_data: dict) -> str:
        release_id = release_data.get("release_id", _new_id())
        conn = self._get_conn()
        conn.execute(
            """INSERT INTO release_history (
                release_id, app_id, version, release_date,
                update_type, triggered_by, changes_summary,
                health_score_before, health_score_after
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                release_id,
                app_id,
                release_data["version"],
                release_data.get("release_date", _now_iso()),
                release_data["update_type"],
                release_data["triggered_by"],
                release_data.get("changes_summary"),
                release_data.get("health_score_before"),
                release_data.get("health_score_after"),
            ),
        )
        # Update total_releases counter
        conn.execute(
            "UPDATE apps SET total_releases = total_releases + 1, updated_at = ? WHERE app_id = ?",
            (_now_iso(), app_id),
        )
        conn.commit()
        conn.close()
        print(f"[App Registry] Release added: {release_id} for app {app_id}")
        return release_id

    def get_release_history(self, app_id: str) -> list[dict]:
        conn = self._get_conn()
        rows = conn.execute(
            "SELECT * FROM release_history WHERE app_id = ? ORDER BY release_date DESC",
            (app_id,),
        ).fetchall()
        conn.close()
        return [dict(r) for r in rows]

    # ------------------------------------------------------------------
    # Action Queue
    # ------------------------------------------------------------------

    def add_action(self, app_id: str, action_data: dict) -> str:
        action_id = action_data.get("action_id", _new_id())
        conn = self._get_conn()
        conn.execute(
            """INSERT INTO action_queue (
                action_id, app_id, action_type, severity_score,
                status, started_at, completed_at, briefing_document
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                action_id,
                app_id,
                action_data["action_type"],
                action_data.get("severity_score", 0.0),
                action_data.get("status", "pending"),
                action_data.get("started_at"),
                action_data.get("completed_at"),
                action_data.get("briefing_document"),
            ),
        )
        conn.commit()
        conn.close()
        print(f"[App Registry] Action added: {action_id} ({action_data['action_type']})")
        return action_id

    def get_pending_actions(self, app_id: Optional[str] = None) -> list[dict]:
        conn = self._get_conn()
        if app_id:
            rows = conn.execute(
                "SELECT * FROM action_queue WHERE app_id = ? AND status = 'pending' ORDER BY severity_score DESC",
                (app_id,),
            ).fetchall()
        else:
            rows = conn.execute(
                "SELECT * FROM action_queue WHERE status = 'pending' ORDER BY severity_score DESC"
            ).fetchall()
        conn.close()
        return [dict(r) for r in rows]

    def update_action_status(self, action_id: str, status: str) -> None:
        now = _now_iso()
        conn = self._get_conn()
        if status == "in_progress":
            conn.execute(
                "UPDATE action_queue SET status = ?, started_at = ? WHERE action_id = ?",
                (status, now, action_id),
            )
        elif status in ("completed", "cancelled"):
            conn.execute(
                "UPDATE action_queue SET status = ?, completed_at = ? WHERE action_id = ?",
                (status, now, action_id),
            )
        else:
            conn.execute(
                "UPDATE action_queue SET status = ? WHERE action_id = ?",
                (status, action_id),
            )
        conn.commit()
        conn.close()
        print(f"[App Registry] Action {action_id} -> {status}")

    # ------------------------------------------------------------------
    # Health Score History
    # ------------------------------------------------------------------

    def add_health_record(self, app_id: str, health_data: dict) -> str:
        record_id = health_data.get("record_id", _new_id())
        conn = self._get_conn()
        conn.execute(
            """INSERT INTO health_score_history (
                record_id, app_id, timestamp,
                overall_score, stability_score, satisfaction_score,
                engagement_score, revenue_score, growth_score
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                record_id,
                app_id,
                health_data.get("timestamp", _now_iso()),
                health_data.get("overall_score"),
                health_data.get("stability_score"),
                health_data.get("satisfaction_score"),
                health_data.get("engagement_score"),
                health_data.get("revenue_score"),
                health_data.get("growth_score"),
            ),
        )
        conn.commit()
        conn.close()
        return record_id

    def get_health_history(self, app_id: str, limit: int = 100) -> list[dict]:
        conn = self._get_conn()
        rows = conn.execute(
            "SELECT * FROM health_score_history WHERE app_id = ? ORDER BY timestamp DESC LIMIT ?",
            (app_id, limit),
        ).fetchall()
        conn.close()
        return [dict(r) for r in rows]

    # ------------------------------------------------------------------
    # Cooling Period
    # ------------------------------------------------------------------

    def set_cooling(self, app_id: str, cooling_type: str, duration_hours: int) -> None:
        cooling_until = (
            datetime.now(timezone.utc) + timedelta(hours=duration_hours)
        ).isoformat()
        self.update_app(app_id, {
            "cooling_until": cooling_until,
            "cooling_type": cooling_type,
        })
        print(f"[App Registry] Cooling gesetzt: {app_id} -> {cooling_type} fuer {duration_hours}h")

    def is_cooling(self, app_id: str) -> bool:
        info = self.get_cooling_info(app_id)
        return info is not None

    def get_cooling_info(self, app_id: str) -> Optional[dict]:
        app = self.get_app(app_id)
        if not app or not app.get("cooling_until"):
            return None

        cooling_until = datetime.fromisoformat(app["cooling_until"])
        now = datetime.now(timezone.utc)

        if now >= cooling_until:
            # Cooling abgelaufen - aufraeumen
            self.update_app(app_id, {"cooling_until": None, "cooling_type": None})
            return None

        remaining = cooling_until - now
        return {
            "cooling_type": app["cooling_type"],
            "cooling_until": app["cooling_until"],
            "remaining_seconds": int(remaining.total_seconds()),
            "remaining_human": str(remaining).split(".")[0],
        }
