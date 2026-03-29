"""Factory State Collector.

Sammelt den Gesamtzustand der Factory aus 8 bestehenden Subsystemen.
Liest nur, veraendert nichts. Jedes Subsystem wird einzeln abgefragt
mit eigenem try/except — ein Fehler in einem System blockiert nicht
die anderen.

Rein deterministisch, kein LLM, keine Schreiboperationen.
"""

import json
import logging
import os
from datetime import datetime, timezone, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)

# Factory root: 2 Ebenen hoch von factory/brain/
_DEFAULT_ROOT = Path(__file__).resolve().parents[2]


class FactoryStateCollector:
    """Sammelt den Gesamtzustand der Factory aus bestehenden Systemen."""

    def __init__(self, factory_root: str = None):
        self.root = Path(factory_root) if factory_root else _DEFAULT_ROOT

    def collect_full_state(self) -> dict:
        """Hauptmethode. Gibt Dictionary mit allen 8 Subsystem-States zurueck."""
        state = {
            "collected_at": datetime.now(timezone.utc).isoformat(),
            "factory_root": str(self.root),
            "health_monitor": self._collect_health_monitor(),
            "janitor": self._collect_janitor_status(),
            "pipeline_queue": self._collect_pipeline_queue(),
            "project_registry": self._collect_project_registry(),
            "service_provider": self._collect_service_status(),
            "model_provider": self._collect_model_status(),
            "command_queue": self._collect_command_queue(),
            "auto_repair": self._collect_auto_repair(),
        }

        # Compute overall status
        statuses = [v.get("status", "unavailable") for k, v in state.items() if isinstance(v, dict) and "status" in v]
        if "error" in statuses or "critical" in statuses:
            state["overall_status"] = "critical"
        elif "warning" in statuses:
            state["overall_status"] = "warning"
        elif all(s in ("ok", "unavailable") for s in statuses):
            available = sum(1 for s in statuses if s == "ok")
            state["overall_status"] = "ok" if available >= 4 else "degraded"
        else:
            state["overall_status"] = "unknown"

        state["subsystems_available"] = sum(1 for s in statuses if s != "unavailable")
        state["subsystems_total"] = len(statuses)

        return state

    # ------------------------------------------------------------------
    # Subsystem 1: Health Monitor
    # ------------------------------------------------------------------
    def _collect_health_monitor(self) -> dict:
        try:
            from factory.hq.health_monitor import run_health_check
            result = run_health_check()

            summary = result.get("summary", {})
            checks_total = summary.get("total_alerts", 0)
            critical = summary.get("critical", 0)
            warnings = summary.get("warnings", 0)

            status = "ok"
            if critical > 0:
                status = "critical"
            elif warnings > 0:
                status = "warning"

            return {
                "status": status,
                "overall": result.get("status", "unknown"),
                "total_projects": summary.get("total_projects", 0),
                "healthy_projects": summary.get("healthy_projects", 0),
                "projects_with_issues": summary.get("projects_with_issues", 0),
                "total_alerts": checks_total,
                "critical": critical,
                "warnings": warnings,
                "info": summary.get("info", 0),
                "alerts": [
                    {
                        "severity": a.get("severity"),
                        "category": a.get("category"),
                        "project": a.get("project"),
                        "message": a.get("message"),
                        "auto_fixable": a.get("auto_fixable", False),
                    }
                    for a in result.get("alerts", [])[:20]
                ],
            }
        except Exception as e:
            logger.warning("Health Monitor unavailable: %s", e)
            return {"status": "unavailable", "error": str(e)}

    # ------------------------------------------------------------------
    # Subsystem 2: Janitor Status
    # ------------------------------------------------------------------
    def _collect_janitor_status(self) -> dict:
        try:
            reports_dir = self.root / "factory" / "hq" / "janitor" / "reports"
            if not reports_dir.exists():
                return {"status": "ok", "last_scan": None, "issues_found": 0, "note": "Noch keine Scans"}

            # Find latest report across all cycles
            latest = None
            latest_ts = ""
            for cycle in ("daily", "weekly", "monthly"):
                cycle_dir = reports_dir / cycle
                if not cycle_dir.exists():
                    continue
                reports = sorted(cycle_dir.glob("report_*.json"), reverse=True)
                if reports:
                    try:
                        data = json.loads(reports[0].read_text(encoding="utf-8"))
                        ts = data.get("timestamp", "")
                        if ts > latest_ts:
                            latest_ts = ts
                            latest = data
                    except Exception:
                        pass

            if not latest:
                return {"status": "ok", "last_scan": None, "issues_found": 0}

            summary = latest.get("summary", {})
            issues = summary.get("total_findings", 0)
            health = summary.get("health_score", None)
            growth_alerts = latest.get("scan", {}).get("growth_alerts", [])

            status = "ok"
            if health is not None and health < 50:
                status = "warning"
            if len(growth_alerts) > 0:
                status = "warning"

            return {
                "status": status,
                "last_scan": latest_ts or None,
                "cycle": latest.get("cycle"),
                "issues_found": issues,
                "health_score": health,
                "green": summary.get("green_auto_fixable", 0),
                "yellow": summary.get("yellow_proposals", 0),
                "red": summary.get("red_report_only", 0),
                "growth_alerts": len(growth_alerts),
                "scanned_files": latest.get("scan", {}).get("total_files", 0),
            }
        except Exception as e:
            logger.warning("Janitor unavailable: %s", e)
            return {"status": "unavailable", "error": str(e)}

    # ------------------------------------------------------------------
    # Subsystem 3: Dispatcher / Pipeline Queue
    # ------------------------------------------------------------------
    def _collect_pipeline_queue(self) -> dict:
        try:
            queue_file = self.root / "factory" / "dispatcher" / "queue_store.json"
            if not queue_file.exists():
                return {"status": "ok", "total_projects": 0, "projects": [], "stuck_projects": []}

            data = json.loads(queue_file.read_text(encoding="utf-8"))
            products = data.get("products", [])
            now = datetime.now(timezone.utc)

            projects = []
            stuck = []
            for p in products:
                entry = {
                    "id": p.get("id", ""),
                    "name": p.get("title", ""),
                    "phase": p.get("phase", "unknown"),
                    "priority": p.get("priority", 5),
                    "updated_at": p.get("updated_at"),
                }
                projects.append(entry)

                # Check for stuck (same phase > 48h)
                updated = p.get("updated_at")
                if updated:
                    try:
                        updated_dt = datetime.fromisoformat(updated.replace("Z", "+00:00"))
                        age_hours = (now - updated_dt).total_seconds() / 3600
                        if age_hours > 48 and p.get("phase") not in ("failed", "completed", "archived"):
                            stuck.append({
                                "name": p.get("title", ""),
                                "phase": p.get("phase", ""),
                                "stuck_hours": round(age_hours),
                            })
                    except (ValueError, TypeError):
                        pass

            status = "ok"
            if stuck:
                status = "warning"

            return {
                "status": status,
                "total_projects": len(products),
                "projects": projects,
                "stuck_projects": stuck,
                "queue_updated": data.get("updated"),
            }
        except Exception as e:
            logger.warning("Pipeline Queue unavailable: %s", e)
            return {"status": "unavailable", "error": str(e)}

    # ------------------------------------------------------------------
    # Subsystem 4: Project Registry
    # ------------------------------------------------------------------
    def _collect_project_registry(self) -> dict:
        try:
            projects_dir = self.root / "factory" / "projects"
            if not projects_dir.exists():
                return {"status": "ok", "total": 0, "active": 0, "completed": 0, "archived": 0}

            total = 0
            active = 0
            completed = 0
            archived = 0
            by_status = {}

            for project_dir in sorted(projects_dir.iterdir()):
                pf = project_dir / "project.json"
                if not pf.exists():
                    continue
                try:
                    p = json.loads(pf.read_text(encoding="utf-8"))
                except Exception:
                    continue

                total += 1
                status = p.get("status", "unknown")
                by_status[status] = by_status.get(status, 0) + 1

                if p.get("archived"):
                    archived += 1
                elif status in ("completed", "store_ready", "launched"):
                    completed += 1
                else:
                    active += 1

            return {
                "status": "ok",
                "total": total,
                "active": active,
                "completed": completed,
                "archived": archived,
                "by_status": by_status,
            }
        except Exception as e:
            logger.warning("Project Registry unavailable: %s", e)
            return {"status": "unavailable", "error": str(e)}

    # ------------------------------------------------------------------
    # Subsystem 5: Service Provider
    # ------------------------------------------------------------------
    def _collect_service_status(self) -> dict:
        try:
            # Try both known locations
            registry_file = self.root / "factory" / "brain" / "service_provider" / "service_registry.json"
            if not registry_file.exists():
                registry_file = self.root / "factory" / "brain" / "service_registry.json"
            if not registry_file.exists():
                return {"status": "unavailable", "error": "service_registry.json not found"}

            data = json.loads(registry_file.read_text(encoding="utf-8"))
            services = data.get("services", {})
            categories = data.get("categories", {})

            active = []
            inactive = []
            draft = []

            for sid, svc in services.items():
                name = svc.get("name", sid)
                status = svc.get("status", "inactive")
                if status == "active":
                    active.append(name)
                elif status == "draft":
                    draft.append(name)
                else:
                    inactive.append(name)

            return {
                "status": "ok",
                "total_services": len(services),
                "active_services": active,
                "inactive_services": inactive,
                "draft_adapters": draft,
                "categories": list(categories.keys()) if isinstance(categories, dict) else [],
            }
        except Exception as e:
            logger.warning("Service Provider unavailable: %s", e)
            return {"status": "unavailable", "error": str(e)}

    # ------------------------------------------------------------------
    # Subsystem 6: Model Provider
    # ------------------------------------------------------------------
    def _collect_model_status(self) -> dict:
        try:
            from factory.brain.model_provider import get_registry
            registry = get_registry()
            stats = registry.stats

            # Check for latest health report
            reports_dir = self.root / "factory" / "brain" / "model_provider" / "health_reports"
            latest_report = None
            if reports_dir.exists():
                report_files = sorted(reports_dir.glob("health_*.json"), reverse=True)
                if report_files:
                    try:
                        rdata = json.loads(report_files[0].read_text(encoding="utf-8"))
                        latest_report = {
                            "timestamp": rdata.get("timestamp"),
                            "providers_checked": len(rdata.get("providers", {})),
                            "all_healthy": all(
                                p.get("status") == "healthy"
                                for p in rdata.get("providers", {}).values()
                            ),
                        }
                    except Exception:
                        latest_report = {"file": report_files[0].name}

            return {
                "status": "ok",
                "registered_models": stats.get("total_models", 0),
                "available_models": stats.get("available_models", 0),
                "by_provider": stats.get("by_provider", {}),
                "by_tier": stats.get("by_tier", {}),
                "available_providers": stats.get("available_providers", []),
                "latest_health_report": latest_report,
            }
        except Exception as e:
            logger.warning("Model Provider unavailable: %s", e)
            return {"status": "unavailable", "error": str(e)}

    # ------------------------------------------------------------------
    # Subsystem 7: Command Queue
    # ------------------------------------------------------------------
    def _collect_command_queue(self) -> dict:
        try:
            commands_dir = self.root / "_commands"
            if not commands_dir.exists():
                return {"status": "ok", "total_commands": 0, "oldest": None, "newest": None}

            md_files = sorted(commands_dir.glob("*.md"))
            if not md_files:
                return {"status": "ok", "total_commands": 0, "oldest": None, "newest": None}

            # Use file modification times for oldest/newest
            oldest_file = min(md_files, key=lambda f: f.stat().st_mtime)
            newest_file = max(md_files, key=lambda f: f.stat().st_mtime)

            oldest_dt = datetime.fromtimestamp(oldest_file.stat().st_mtime, tz=timezone.utc)
            newest_dt = datetime.fromtimestamp(newest_file.stat().st_mtime, tz=timezone.utc)
            age_days = (datetime.now(timezone.utc) - oldest_dt).days

            status = "ok"
            if len(md_files) > 100:
                status = "warning"

            return {
                "status": status,
                "total_commands": len(md_files),
                "oldest": oldest_dt.strftime("%Y-%m-%d"),
                "oldest_file": oldest_file.name,
                "newest": newest_dt.strftime("%Y-%m-%d"),
                "newest_file": newest_file.name,
                "oldest_age_days": age_days,
            }
        except Exception as e:
            logger.warning("Command Queue unavailable: %s", e)
            return {"status": "unavailable", "error": str(e)}

    # ------------------------------------------------------------------
    # Subsystem 8: Auto-Repair
    # ------------------------------------------------------------------
    def _collect_auto_repair(self) -> dict:
        try:
            from factory.hq.auto_repair import run_auto_repair

            # Don't actually run repairs — just check if module is available
            # and look for recent repair logs
            repair_logs_dir = self.root / "factory" / "hq" / "janitor" / "reports"
            recent_repairs = []

            # Check weekly/monthly reports for repair actions
            for cycle in ("weekly", "monthly"):
                cycle_dir = repair_logs_dir / cycle
                if not cycle_dir.exists():
                    continue
                reports = sorted(cycle_dir.glob("report_*.json"), reverse=True)
                for report_file in reports[:3]:
                    try:
                        data = json.loads(report_file.read_text(encoding="utf-8"))
                        actions = data.get("actions", {})
                        auto_fixed = actions.get("auto_fixed", [])
                        if auto_fixed:
                            recent_repairs.append({
                                "cycle": cycle,
                                "timestamp": data.get("timestamp"),
                                "repairs": len(auto_fixed),
                            })
                    except Exception:
                        pass

            return {
                "status": "ok",
                "module_available": True,
                "active_repairs": 0,
                "recent_repairs": recent_repairs[:5],
            }
        except ImportError:
            return {
                "status": "ok",
                "module_available": False,
                "active_repairs": 0,
                "recent_repairs": [],
            }
        except Exception as e:
            logger.warning("Auto-Repair unavailable: %s", e)
            return {"status": "unavailable", "error": str(e)}
