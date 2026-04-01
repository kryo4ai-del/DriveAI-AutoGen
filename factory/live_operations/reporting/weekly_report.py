"""CEO Weekly Report Generator — deterministisch, kein LLM.

Sammelt Daten aus allen Live Operations Komponenten und generiert
einen strukturierten Markdown-Report fuer CEO-Uebersicht.

Sektionen:
1. Executive Summary (Score, Zone-Verteilung, KPIs)
2. Fleet Health Overview (alle Apps mit Score + Trend)
3. Critical Alerts (CEO-Eskalationen der Woche)
4. Action Queue Status (Pending, Completed, Stale)
5. Release Pipeline (Releases der Woche)
6. Anomaly Report (Anomalien + Rollbacks)
7. Health Trends (Score-Veraenderungen)
8. System Health (Self-Healing Status)
9. Recommendations (automatisch generiert)
"""

import json
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Optional

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.agents.decision_engine.action_queue import ActionQueueManager
from factory.live_operations.agents.escalation.manager import EscalationManager
from factory.live_operations.agents.release_manager.manager import ReleaseManager
from factory.live_operations.self_healing.health_monitor import SystemHealthMonitor
from factory.live_operations.self_healing.healer import SelfHealer
from factory.live_operations.self_healing.utilities import ErrorLog

_PREFIX = "[Weekly Report]"


class WeeklyReportGenerator:
    """Generiert den woechentlichen CEO-Report."""

    def __init__(
        self,
        registry_db: Optional[AppRegistryDB] = None,
        output_dir: Optional[str] = None,
    ) -> None:
        self._db = registry_db or AppRegistryDB()
        self._output_dir = Path(
            output_dir
            or Path(__file__).resolve().parent.parent / "data" / "reports"
        )
        self._output_dir.mkdir(parents=True, exist_ok=True)

        # Agents
        self._action_queue = ActionQueueManager(self._db)
        self._escalation_mgr = EscalationManager()
        self._release_mgr = ReleaseManager(db=self._db)
        self._error_log = ErrorLog()
        self._health_monitor = SystemHealthMonitor(
            registry_db=self._db, error_log=self._error_log
        )
        self._self_healer = SelfHealer(
            registry_db=self._db, error_log=self._error_log
        )

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def generate(self) -> dict:
        """Generiert den vollstaendigen Weekly Report.

        Returns:
            { "report_path": str, "json_path": str, "summary": dict }
        """
        now = datetime.now(timezone.utc)
        week_ago = now - timedelta(days=7)
        print(f"{_PREFIX} Generating report for week ending {now.strftime('%Y-%m-%d')}")

        # Collect data
        data = self._collect_data(now, week_ago)

        # Generate Markdown
        md = self._render_markdown(data, now)

        # Save
        timestamp = now.strftime("%Y%m%d_%H%M%S")
        week_str = now.strftime("KW%W_%Y")

        md_path = self._output_dir / f"weekly_{week_str}_{timestamp}.md"
        md_path.write_text(md, encoding="utf-8")

        json_path = self._output_dir / f"weekly_{week_str}_{timestamp}.json"
        json_path.write_text(
            json.dumps(data, indent=2, default=str, ensure_ascii=False),
            encoding="utf-8",
        )

        print(f"{_PREFIX} Report: {md_path}")
        print(f"{_PREFIX} JSON: {json_path}")

        return {
            "report_path": str(md_path),
            "json_path": str(json_path),
            "summary": data.get("executive_summary", {}),
        }

    def generate_data_only(self) -> dict:
        """Nur Daten sammeln, kein File-Output (fuer API/Dashboard)."""
        now = datetime.now(timezone.utc)
        week_ago = now - timedelta(days=7)
        return self._collect_data(now, week_ago)

    def list_reports(self) -> list[dict]:
        """Listet alle gespeicherten Reports."""
        reports = []
        for f in sorted(self._output_dir.glob("weekly_*.md"), reverse=True):
            json_f = f.with_suffix(".json")
            reports.append({
                "filename": f.name,
                "path": str(f),
                "json_path": str(json_f) if json_f.exists() else None,
                "created": datetime.fromtimestamp(
                    f.stat().st_mtime, tz=timezone.utc
                ).isoformat(),
            })
        return reports

    # ------------------------------------------------------------------
    # Data Collection
    # ------------------------------------------------------------------

    def _collect_data(self, now: datetime, week_ago: datetime) -> dict:
        """Sammelt alle Daten fuer den Report."""
        apps = self._db.get_all_apps()

        # Zone counts
        zones = {"green": 0, "yellow": 0, "red": 0}
        for app in apps:
            zone = app.get("health_zone", "yellow")
            zones[zone] = zones.get(zone, 0) + 1

        # Health trends per app
        fleet_health = []
        for app in apps:
            history = self._db.get_health_history(app["app_id"], limit=14)
            trend = self._calc_trend(history)
            fleet_health.append({
                "app_id": app["app_id"],
                "app_name": app.get("app_name", app["app_id"]),
                "health_score": app.get("health_score", 0),
                "health_zone": app.get("health_zone", "yellow"),
                "trend": trend,
                "current_version": app.get("current_version", "0.0.0"),
            })

        # Sort: red first, then by score ascending
        zone_order = {"red": 0, "yellow": 1, "green": 2}
        fleet_health.sort(key=lambda x: (zone_order.get(x["health_zone"], 1), x["health_score"]))

        # Actions
        pending = self._action_queue.get_queue(status="pending")
        completed = self._action_queue.get_queue(status="completed")
        in_progress = self._action_queue.get_queue(status="in_progress")

        # Escalations
        escalations = self._escalation_mgr.get_recent(limit=50)
        ceo_alerts = [e for e in escalations if e.get("escalation_level", 0) >= 3]
        week_escalations = self._filter_by_date(escalations, week_ago)

        # Releases
        all_releases = self._release_mgr.list_releases()
        week_releases = self._filter_by_date(all_releases, week_ago, date_field="created_at")
        released = [r for r in week_releases if r.get("status") == "released"]
        failed = [r for r in week_releases if r.get("status") == "failed"]

        # System Health
        health_check = self._health_monitor.run_health_check()
        healer_status = self._self_healer.get_status()

        # Average health score
        scores = [a.get("health_score", 0) for a in apps if a.get("health_score") is not None]
        avg_score = round(sum(scores) / len(scores), 1) if scores else 0

        # Executive summary
        exec_summary = {
            "total_apps": len(apps),
            "avg_health_score": avg_score,
            "zones": zones,
            "fleet_status": self._fleet_status(zones, avg_score),
            "pending_actions": len(pending),
            "completed_actions_week": len([a for a in completed if self._in_week(a, week_ago)]),
            "ceo_alerts_week": len([e for e in ceo_alerts if self._in_week(e, week_ago)]),
            "releases_week": len(released),
            "failed_releases_week": len(failed),
            "system_healthy": health_check.get("all_ok", False),
            "healed_total": healer_status.get("cumulative_healed", 0),
        }

        return {
            "generated_at": now.isoformat(),
            "period_start": week_ago.isoformat(),
            "period_end": now.isoformat(),
            "executive_summary": exec_summary,
            "fleet_health": fleet_health,
            "escalations": {
                "total_week": len(week_escalations),
                "ceo_alerts": ceo_alerts[:10],
                "by_source": self._group_by(week_escalations, "source"),
            },
            "action_queue": {
                "pending": len(pending),
                "in_progress": len(in_progress),
                "completed_week": exec_summary["completed_actions_week"],
                "top_pending": pending[:5],
            },
            "releases": {
                "released_week": len(released),
                "failed_week": len(failed),
                "recent": all_releases[:10],
            },
            "system_health": {
                "check": health_check,
                "healer": healer_status,
            },
            "recommendations": self._generate_recommendations(
                exec_summary, fleet_health, ceo_alerts, pending
            ),
        }

    # ------------------------------------------------------------------
    # Markdown Rendering
    # ------------------------------------------------------------------

    def _render_markdown(self, data: dict, now: datetime) -> str:
        """Rendert den Report als Markdown."""
        lines = []
        es = data["executive_summary"]

        # Header
        lines.append(f"# CEO Weekly Report — Live Operations")
        lines.append(f"")
        lines.append(f"**Zeitraum:** {data['period_start'][:10]} bis {data['period_end'][:10]}")
        lines.append(f"**Generiert:** {now.strftime('%Y-%m-%d %H:%M UTC')}")
        lines.append(f"")

        # 1. Executive Summary
        lines.append("## 1. Executive Summary")
        lines.append("")
        lines.append(f"| KPI | Wert |")
        lines.append(f"|-----|------|")
        lines.append(f"| Fleet Status | **{es['fleet_status']}** |")
        lines.append(f"| Gesamt Apps | {es['total_apps']} |")
        lines.append(f"| Avg Health Score | {es['avg_health_score']} |")
        lines.append(f"| Zonen | {es['zones']['green']} Green / {es['zones']['yellow']} Yellow / {es['zones']['red']} Red |")
        lines.append(f"| Pending Actions | {es['pending_actions']} |")
        lines.append(f"| Completed (Woche) | {es['completed_actions_week']} |")
        lines.append(f"| CEO Alerts (Woche) | {es['ceo_alerts_week']} |")
        lines.append(f"| Releases (Woche) | {es['releases_week']} |")
        lines.append(f"| Failed Releases | {es['failed_releases_week']} |")
        lines.append(f"| System Health | {'OK' if es['system_healthy'] else 'ISSUES'} |")
        lines.append("")

        # 2. Fleet Health
        lines.append("## 2. Fleet Health Overview")
        lines.append("")
        lines.append("| App | Score | Zone | Trend | Version |")
        lines.append("|-----|-------|------|-------|---------|")
        for app in data["fleet_health"]:
            trend_icon = self._trend_icon(app["trend"])
            lines.append(
                f"| {app['app_name']} | {app['health_score']:.1f} | "
                f"{app['health_zone']} | {trend_icon} {app['trend']:+.1f} | "
                f"v{app['current_version']} |"
            )
        lines.append("")

        # 3. Critical Alerts
        ceo_alerts = data["escalations"]["ceo_alerts"]
        lines.append("## 3. Critical Alerts (CEO)")
        lines.append("")
        if ceo_alerts:
            lines.append("| Zeit | App | Quelle | Detail |")
            lines.append("|------|-----|--------|--------|")
            for e in ceo_alerts[:10]:
                ts = e.get("timestamp", "")[:16]
                lines.append(
                    f"| {ts} | {e.get('app_id', '?')[:12]} | "
                    f"{e.get('source', '?')} | {e.get('detail', '')[:60]} |"
                )
        else:
            lines.append("*Keine CEO-Eskalationen diese Woche.*")
        lines.append("")

        # 4. Action Queue
        aq = data["action_queue"]
        lines.append("## 4. Action Queue")
        lines.append("")
        lines.append(f"- **Pending:** {aq['pending']}")
        lines.append(f"- **In Progress:** {aq['in_progress']}")
        lines.append(f"- **Completed (Woche):** {aq['completed_week']}")
        lines.append("")
        if aq["top_pending"]:
            lines.append("**Top Pending Actions:**")
            lines.append("")
            for a in aq["top_pending"]:
                lines.append(
                    f"- [{a.get('app_id', '?')[:12]}] {a.get('action_type', '?')} "
                    f"(Severity: {a.get('severity_score', 0):.1f})"
                )
            lines.append("")

        # 5. Release Pipeline
        rel = data["releases"]
        lines.append("## 5. Release Pipeline")
        lines.append("")
        lines.append(f"- **Released (Woche):** {rel['released_week']}")
        lines.append(f"- **Failed (Woche):** {rel['failed_week']}")
        lines.append("")
        if rel["recent"]:
            lines.append("**Letzte Releases:**")
            lines.append("")
            lines.append("| App | Version | Status | Datum |")
            lines.append("|-----|---------|--------|-------|")
            for r in rel["recent"][:5]:
                lines.append(
                    f"| {r.get('app_id', '?')[:12]} | v{r.get('target_version', '?')} | "
                    f"{r.get('status', '?')} | {str(r.get('created_at', ''))[:10]} |"
                )
            lines.append("")

        # 6. System Health
        sh = data["system_health"]
        lines.append("## 6. System Health")
        lines.append("")
        check = sh.get("check", {})
        lines.append(f"- **Status:** {'ALL OK' if check.get('all_ok') else 'ISSUES'}")
        for name, c in check.get("checks", {}).items():
            status = "OK" if c.get("ok") else "FAIL"
            lines.append(f"  - {name}: {status}")
        healer = sh.get("healer", {})
        lines.append(f"- **Cumulative Healed:** {healer.get('cumulative_healed', 0)}")
        lines.append(f"- **Unresolved Errors:** {healer.get('unresolved', 0)}")
        lines.append("")

        # 7. Recommendations
        recs = data.get("recommendations", [])
        lines.append("## 7. Empfehlungen")
        lines.append("")
        if recs:
            for r in recs:
                lines.append(f"- {r}")
        else:
            lines.append("*Keine Empfehlungen — alles laeuft gut.*")
        lines.append("")

        # Footer
        lines.append("---")
        lines.append("*Generiert von WeeklyReportGenerator (Phase 6, LOP-14) — deterministisch, kein LLM*")

        return "\n".join(lines)

    # ------------------------------------------------------------------
    # Recommendations Engine
    # ------------------------------------------------------------------

    def _generate_recommendations(
        self,
        summary: dict,
        fleet: list,
        ceo_alerts: list,
        pending: list,
    ) -> list[str]:
        """Generiert automatische Empfehlungen basierend auf Daten."""
        recs = []

        # Red zone apps
        red_count = summary["zones"].get("red", 0)
        if red_count > 0:
            red_apps = [a["app_name"] for a in fleet if a["health_zone"] == "red"]
            recs.append(
                f"KRITISCH: {red_count} App(s) in roter Zone ({', '.join(red_apps[:3])}). "
                f"Sofortige Aufmerksamkeit empfohlen."
            )

        # High pending count
        if summary["pending_actions"] > 5:
            recs.append(
                f"WARNUNG: {summary['pending_actions']} offene Actions in der Queue. "
                f"Execution Path pruefen."
            )

        # Declining apps
        declining = [a for a in fleet if a["trend"] < -5.0]
        if declining:
            names = ", ".join(a["app_name"] for a in declining[:3])
            recs.append(
                f"TREND: {len(declining)} App(s) mit fallendem Health Score ({names}). "
                f"Ursachenanalyse empfohlen."
            )

        # CEO alerts
        if summary["ceo_alerts_week"] > 3:
            recs.append(
                f"ESKALATION: {summary['ceo_alerts_week']} CEO-Alerts diese Woche. "
                f"Moeglicherweise systemisches Problem."
            )

        # Failed releases
        if summary["failed_releases_week"] > 0:
            recs.append(
                f"RELEASE: {summary['failed_releases_week']} fehlgeschlagene Releases. "
                f"QA-Pipeline pruefen."
            )

        # System health
        if not summary["system_healthy"]:
            recs.append(
                "SYSTEM: Self-Healing hat Probleme erkannt. "
                "System Health Dashboard pruefen."
            )

        # All green
        if not recs:
            recs.append("Alle Systeme operieren normal. Keine Massnahmen erforderlich.")

        return recs

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _calc_trend(self, history: list) -> float:
        """Berechnet Score-Trend aus History (letzte 7 vs vorherige 7 Eintraege)."""
        if len(history) < 2:
            return 0.0
        scores = [h.get("overall_score", 0) or 0 for h in history]
        mid = min(len(scores) // 2, 7)
        if mid == 0:
            return 0.0
        recent = sum(scores[:mid]) / mid
        older = sum(scores[mid:mid * 2]) / min(mid, len(scores) - mid)
        return round(recent - older, 1)

    def _fleet_status(self, zones: dict, avg_score: float) -> str:
        """Bestimmt Fleet-Gesamtstatus."""
        if zones.get("red", 0) > 2 or avg_score < 40:
            return "KRITISCH"
        if zones.get("red", 0) > 0 or avg_score < 60:
            return "WARNUNG"
        if avg_score >= 80:
            return "EXZELLENT"
        return "STABIL"

    def _trend_icon(self, trend: float) -> str:
        """Trend als ASCII-Icon."""
        if trend > 3:
            return "^^"
        if trend > 0:
            return "^"
        if trend < -3:
            return "vv"
        if trend < 0:
            return "v"
        return "="

    def _filter_by_date(
        self, items: list, after: datetime, date_field: str = "timestamp"
    ) -> list:
        """Filtert Items nach Datum."""
        result = []
        after_str = after.isoformat()
        for item in items:
            ts = item.get(date_field, "")
            if ts and ts >= after_str:
                result.append(item)
        return result

    def _in_week(self, item: dict, week_ago: datetime) -> bool:
        """Prueft ob Item innerhalb der letzten Woche liegt."""
        for field in ("completed_at", "created_at", "timestamp"):
            ts = item.get(field)
            if ts and ts >= week_ago.isoformat():
                return True
        return False

    def _group_by(self, items: list, key: str) -> dict:
        """Gruppiert Items nach einem Key."""
        groups = {}
        for item in items:
            val = item.get(key, "unknown")
            groups[val] = groups.get(val, 0) + 1
        return groups
