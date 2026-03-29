"""HQ Bridge — JSON-Export fuer das HQ Dashboard.

Deterministisch, kein LLM. Sammelt Daten aus allen Marketing-Systemen
und exportiert sie als einheitliches JSON fuer das HQ Dashboard.
Aendert keinen HQ-Code.
"""

import json
import logging
import os
from datetime import datetime
from typing import Optional

logger = logging.getLogger("factory.marketing.tools.hq_bridge")


class HQBridge:
    """Exportiert Marketing-Daten als JSON fuer das HQ Dashboard."""

    def __init__(self, output_dir: str = None) -> None:
        if output_dir:
            self._output_dir = output_dir
        else:
            from factory.marketing.config import OUTPUT_PATH
            self._output_dir = os.path.join(OUTPUT_PATH, "hq_bridge")
        os.makedirs(self._output_dir, exist_ok=True)

    def export_department_status(self) -> dict:
        """Exportiert den aktuellen Status der Marketing-Abteilung.

        Returns: {
            "department": "Marketing",
            "timestamp": str,
            "agents": [...],
            "alerts": {...},
            "kpis": {...},
            "social": {...},
            "export_path": str,
        }
        """
        now = datetime.now()
        status = {
            "department": "Marketing",
            "department_id": "MKT",
            "timestamp": now.isoformat(),
            "version": "0.1.0",
            "agents": self._get_agent_status(),
            "alerts": self._get_alert_summary(),
            "kpis": self._get_kpi_summary(),
            "social": self._get_social_summary(),
        }

        # Speichern
        path = os.path.join(self._output_dir, "department_status.json")
        self._write_json(path, status)
        status["export_path"] = path
        logger.info("Department status exported to %s", path)
        return status

    def export_alert_feed(self) -> dict:
        """Exportiert alle aktiven Alerts und offenen Gates als Feed.

        Returns: {
            "alerts": [...],
            "gates": [...],
            "stats": {...},
            "export_path": str,
        }
        """
        feed = {
            "timestamp": datetime.now().isoformat(),
            "alerts": [],
            "gates": [],
            "stats": {},
        }

        try:
            from factory.marketing.alerts.alert_manager import MarketingAlertManager
            am = MarketingAlertManager()
            feed["alerts"] = am.get_active_alerts()
            feed["gates"] = am.get_pending_gates()
            feed["stats"] = am.get_alert_stats()
        except Exception as e:
            logger.warning("Alert data unavailable: %s", e)

        path = os.path.join(self._output_dir, "alert_feed.json")
        self._write_json(path, feed)
        feed["export_path"] = path
        return feed

    def export_kpi_dashboard(self, app_id: str = "com.driveai.askfin") -> dict:
        """Exportiert KPI-Daten fuers Dashboard.

        Returns: {
            "app_id": str,
            "kpi_check": {...},
            "social_summary": {...},
            "db_stats": {...},
            "export_path": str,
        }
        """
        dashboard = {
            "timestamp": datetime.now().isoformat(),
            "app_id": app_id,
            "kpi_check": {},
            "social_summary": {},
            "db_stats": {},
        }

        try:
            from factory.marketing.tools.kpi_tracker import KPITracker
            tracker = KPITracker()
            dashboard["kpi_check"] = tracker.run_daily_check(app_id)
        except Exception as e:
            logger.warning("KPI data unavailable: %s", e)

        try:
            from factory.marketing.tools.social_analytics_collector import SocialAnalyticsCollector
            collector = SocialAnalyticsCollector()
            dashboard["social_summary"] = collector.get_cross_platform_summary(days=30)
        except Exception as e:
            logger.warning("Social data unavailable: %s", e)

        try:
            from factory.marketing.tools.ranking_database import RankingDatabase
            db = RankingDatabase()
            dashboard["db_stats"] = db.get_db_stats()
        except Exception as e:
            logger.warning("DB stats unavailable: %s", e)

        path = os.path.join(self._output_dir, "kpi_dashboard.json")
        self._write_json(path, dashboard)
        dashboard["export_path"] = path
        return dashboard

    def export_full_snapshot(self, app_id: str = "com.driveai.askfin") -> dict:
        """Exportiert einen kompletten Snapshot aller Marketing-Daten.

        Kombiniert alle einzelnen Exports in einem JSON.

        Returns: {
            "snapshot_id": str,
            "department_status": {...},
            "alert_feed": {...},
            "kpi_dashboard": {...},
            "export_path": str,
        }
        """
        snapshot_id = f"MKT-SNAP-{datetime.now().strftime('%Y%m%d-%H%M%S')}"

        snapshot = {
            "snapshot_id": snapshot_id,
            "timestamp": datetime.now().isoformat(),
            "department_status": self.export_department_status(),
            "alert_feed": self.export_alert_feed(),
            "kpi_dashboard": self.export_kpi_dashboard(app_id),
        }

        # Pfade aus Sub-Exports entfernen (redundant im Gesamt-Export)
        for key in ("department_status", "alert_feed", "kpi_dashboard"):
            snapshot[key].pop("export_path", None)

        path = os.path.join(self._output_dir, f"snapshot_{snapshot_id}.json")
        self._write_json(path, snapshot)
        snapshot["export_path"] = path
        logger.info("Full snapshot exported: %s", snapshot_id)
        return snapshot

    # ── Interne Helfer ────────────────────────────────────────

    def _get_agent_status(self) -> list[dict]:
        """Liest alle Marketing-Agent-Persona-Files."""
        agents = []
        agents_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            "agents",
        )
        try:
            for fname in sorted(os.listdir(agents_dir)):
                if fname.startswith("agent_") and fname.endswith(".json"):
                    path = os.path.join(agents_dir, fname)
                    with open(path, "r", encoding="utf-8") as f:
                        data = json.load(f)
                    agents.append({
                        "id": data.get("id"),
                        "name": data.get("name"),
                        "status": data.get("status", "unknown"),
                        "role": data.get("role"),
                        "model_tier": data.get("model_tier"),
                    })
        except Exception as e:
            logger.warning("Could not read agent files: %s", e)
        return agents

    def _get_alert_summary(self) -> dict:
        """Holt Alert-Statistik."""
        try:
            from factory.marketing.alerts.alert_manager import MarketingAlertManager
            am = MarketingAlertManager()
            return am.get_alert_stats()
        except Exception as e:
            logger.warning("Alert stats unavailable: %s", e)
            return {}

    def _get_kpi_summary(self) -> dict:
        """Holt KPI-Check."""
        try:
            from factory.marketing.tools.kpi_tracker import KPITracker
            tracker = KPITracker()
            result = tracker.run_daily_check()
            return {"overall_status": result.get("overall_status", "unknown")}
        except Exception as e:
            logger.warning("KPI summary unavailable: %s", e)
            return {}

    def _get_social_summary(self) -> dict:
        """Holt Social-Media-Zusammenfassung."""
        try:
            from factory.marketing.tools.social_analytics_collector import SocialAnalyticsCollector
            collector = SocialAnalyticsCollector()
            return collector.get_cross_platform_summary(days=7)
        except Exception as e:
            logger.warning("Social summary unavailable: %s", e)
            return {}

    def _write_json(self, path: str, data: dict) -> None:
        """Schreibt JSON-Datei."""
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False, default=str)
