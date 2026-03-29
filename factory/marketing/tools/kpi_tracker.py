"""KPI Tracker — Prueft App-KPIs gegen Roadbook-Zielwerte und loest Alerts aus.

Deterministisch, kein LLM.
"""

import json
import logging
import os
from typing import Optional

logger = logging.getLogger("factory.marketing.tools.kpi_tracker")


class KPITracker:
    """Prueft App-Metriken gegen definierte Zielwerte."""

    # Default-KPIs aus EchoMatch Roadbook
    DEFAULT_KPIS = {
        "d1_retention": {"target": 40, "warning": 35, "critical": 30, "unit": "%", "direction": "higher_is_better"},
        "d7_retention": {"target": 20, "warning": 15, "critical": 10, "unit": "%", "direction": "higher_is_better"},
        "d30_retention": {"target": 10, "warning": 7, "critical": 5, "unit": "%", "direction": "higher_is_better"},
        "store_rating": {"target": 4.2, "warning": 4.0, "critical": 3.5, "unit": "stars", "direction": "higher_is_better"},
        "crash_rate": {"target": 0.5, "warning": 1.0, "critical": 2.0, "unit": "%", "direction": "lower_is_better"},
        "arpu": {"target": 0.15, "warning": 0.10, "critical": 0.05, "unit": "$/DAU/day", "direction": "higher_is_better"},
        "dau": {"target": 25000, "warning": 15000, "critical": 5000, "unit": "users", "direction": "higher_is_better"},
    }

    def __init__(self, project_slug: str = None, alert_base_path: str = None):
        self.kpis = dict(self.DEFAULT_KPIS)
        self.project_slug = project_slug
        self._alert_base_path = alert_base_path

        if project_slug:
            self._load_project_kpis(project_slug)

        self._alerts = None

    @property
    def alerts(self):
        """Lazy-load AlertManager."""
        if self._alerts is None:
            from factory.marketing.alerts.alert_manager import MarketingAlertManager
            self._alerts = MarketingAlertManager(base_path=self._alert_base_path)
        return self._alerts

    def _load_project_kpis(self, project_slug: str) -> None:
        """Laedt projekt-spezifische KPI-Config aus marketing/config/kpi_{slug}.json."""
        try:
            from factory.marketing.config import MARKETING_ROOT
            config_path = os.path.join(MARKETING_ROOT, "config", f"kpi_{project_slug}.json")
        except ImportError:
            config_path = os.path.join(
                os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                "config", f"kpi_{project_slug}.json"
            )

        if os.path.exists(config_path):
            with open(config_path, "r", encoding="utf-8") as f:
                custom = json.load(f)
            self.kpis.update(custom)
            logger.info("Loaded project KPIs from %s", config_path)

    def check_kpis(self, current_metrics: dict) -> dict:
        """Prueft aktuelle Metriken gegen Zielwerte.

        Args:
            current_metrics: {"d1_retention": 38, "store_rating": 4.1, ...}

        Returns: {
            "overall_status": "ok" | "warning" | "critical",
            "checks": [...],
            "alerts_created": int
        }
        """
        checks = []
        alerts_created = 0
        worst_status = "ok"

        for kpi_name, threshold in self.kpis.items():
            if kpi_name not in current_metrics:
                continue

            value = current_metrics[kpi_name]
            status = self._evaluate_kpi(value, threshold)

            check = {
                "kpi": kpi_name,
                "value": value,
                "target": threshold["target"],
                "warning_threshold": threshold["warning"],
                "critical_threshold": threshold["critical"],
                "status": status,
                "unit": threshold["unit"],
                "message": self._build_message(kpi_name, value, threshold, status),
            }
            checks.append(check)

            # Update worst status
            if status == "critical":
                worst_status = "critical"
            elif status == "warning" and worst_status != "critical":
                worst_status = "warning"

            # Alert erstellen bei Warning/Critical
            if status in ("warning", "critical"):
                try:
                    priority = "critical" if status == "critical" else "high"
                    self.alerts.create_alert(
                        type="warning",
                        priority=priority,
                        category="app_performance",
                        source_agent="KPI-TRACKER",
                        title=f"KPI {kpi_name}: {status.upper()}",
                        description=check["message"],
                        data={"kpi": kpi_name, "value": value, "target": threshold["target"]},
                    )
                    alerts_created += 1
                except Exception as e:
                    logger.warning("Failed to create alert for %s: %s", kpi_name, e)

        return {
            "overall_status": worst_status,
            "checks": checks,
            "alerts_created": alerts_created,
        }

    def _evaluate_kpi(self, value: float, threshold: dict) -> str:
        """Bewertet einen KPI-Wert gegen Schwellwerte."""
        if threshold["direction"] == "higher_is_better":
            if value >= threshold["target"]:
                return "ok"
            elif value >= threshold["warning"]:
                return "warning"
            else:
                return "critical"
        else:  # lower_is_better
            if value <= threshold["target"]:
                return "ok"
            elif value <= threshold["warning"]:
                return "warning"
            else:
                return "critical"

    def _build_message(self, kpi_name: str, value: float,
                       threshold: dict, status: str) -> str:
        """Erstellt eine lesbare Nachricht fuer den Check."""
        name_map = {
            "d1_retention": "D1 Retention",
            "d7_retention": "D7 Retention",
            "d30_retention": "D30 Retention",
            "store_rating": "Store Rating",
            "crash_rate": "Crash Rate",
            "arpu": "ARPU",
            "dau": "DAU",
        }
        name = name_map.get(kpi_name, kpi_name)
        unit = threshold["unit"]

        if status == "ok":
            return f"{name} {value}{unit} erreicht Ziel {threshold['target']}{unit}"
        elif status == "warning":
            return f"{name} {value}{unit} unter Ziel {threshold['target']}{unit} (Warning bei {threshold['warning']}{unit})"
        else:
            return f"{name} {value}{unit} KRITISCH unter Ziel {threshold['target']}{unit} (Critical bei {threshold['critical']}{unit})"

    def check_store_rating(self, current_rating: float,
                           previous_rating: float = None) -> dict:
        """Spezial-Check: Rating-Einbruch erkennen."""
        result = {
            "current": current_rating,
            "previous": previous_rating,
            "drop": 0.0,
            "status": "ok",
            "alert_created": False,
        }

        if previous_rating is not None:
            drop = previous_rating - current_rating
            result["drop"] = round(drop, 2)

            if drop > 0.3:
                result["status"] = "critical"
                try:
                    self.alerts.create_alert(
                        type="alert",
                        priority="critical",
                        category="app_performance",
                        source_agent="KPI-TRACKER",
                        title=f"Rating-Einbruch: {previous_rating} → {current_rating}",
                        description=f"Store Rating ist um {drop:.1f} Punkte gefallen (von {previous_rating} auf {current_rating}). Schwellwert: 0.3",
                        data={"current": current_rating, "previous": previous_rating, "drop": drop},
                    )
                    result["alert_created"] = True
                except Exception as e:
                    logger.warning("Failed to create rating drop alert: %s", e)
            elif drop > 0.1:
                result["status"] = "warning"

        # Auch absoluten Wert pruefen
        abs_check = self._evaluate_kpi(current_rating, self.kpis.get("store_rating", self.DEFAULT_KPIS["store_rating"]))
        if abs_check in ("warning", "critical") and result["status"] == "ok":
            result["status"] = abs_check

        return result

    def check_ranking_changes(self, current_rankings: list[dict],
                              previous_rankings: list[dict] = None) -> dict:
        """Prueft Keyword-Ranking-Aenderungen."""
        result = {
            "changes": [],
            "status": "ok",
            "alerts_created": 0,
        }

        if not previous_rankings:
            result["changes"] = [{"keyword": r["keyword"], "position": r["position"], "change": 0}
                                 for r in current_rankings]
            return result

        prev_map = {r["keyword"]: r["position"] for r in previous_rankings}

        for current in current_rankings:
            kw = current["keyword"]
            pos = current["position"]
            prev_pos = prev_map.get(kw)

            if prev_pos is None:
                change = 0
            else:
                change = prev_pos - pos  # Positive = verbessert

            entry = {"keyword": kw, "position": pos, "previous": prev_pos, "change": change}
            result["changes"].append(entry)

            # Top-Keyword verliert >5 Plaetze
            if change < -5:
                result["status"] = "warning"
                try:
                    self.alerts.create_alert(
                        type="alert",
                        priority="high",
                        category="app_performance",
                        source_agent="KPI-TRACKER",
                        title=f"Ranking-Verlust: '{kw}' -{abs(change)} Plaetze",
                        description=f"Keyword '{kw}' von Position {prev_pos} auf {pos} gefallen ({abs(change)} Plaetze).",
                        data=entry,
                    )
                    result["alerts_created"] += 1
                except Exception as e:
                    logger.warning("Failed to create ranking alert: %s", e)

            # Top-Keyword faellt aus Top 10
            if prev_pos and prev_pos <= 10 and pos > 10:
                result["status"] = "critical"
                try:
                    self.alerts.create_alert(
                        type="alert",
                        priority="critical",
                        category="app_performance",
                        source_agent="KPI-TRACKER",
                        title=f"Ranking: '{kw}' aus Top 10 gefallen!",
                        description=f"Keyword '{kw}' von Position {prev_pos} auf {pos} — nicht mehr in Top 10.",
                        data=entry,
                    )
                    result["alerts_created"] += 1
                except Exception as e:
                    logger.warning("Failed to create ranking alert: %s", e)

        return result

    def run_daily_check(self, app_id: str = None) -> dict:
        """Fuehrt alle Checks durch.

        1. Holt aktuelle Metriken aus Ranking-DB (oder Mock)
        2. check_kpis()
        3. check_store_rating()
        4. check_ranking_changes()
        5. Returns: Zusammenfassung aller Checks
        """
        results = {
            "app_id": app_id,
            "kpi_check": {},
            "rating_check": {},
            "ranking_check": {},
            "overall_status": "ok",
        }

        # Metriken sammeln
        try:
            from factory.marketing.adapters.appstore_adapter import AppStoreAdapter
            adapter = AppStoreAdapter(dry_run=True)
            metrics = adapter.get_app_metrics(app_id or "com.driveai.askfin")
            ratings = adapter.get_ratings_summary(app_id or "com.driveai.askfin")
            rankings = adapter.get_keyword_rankings(app_id or "com.driveai.askfin")
        except Exception as e:
            logger.warning("Could not get metrics: %s", e)
            return results

        # KPI-Check
        kpi_input = {}
        if "retention" in metrics:
            ret = metrics["retention"]
            kpi_input["d1_retention"] = ret.get("d1", 0)
            kpi_input["d7_retention"] = ret.get("d7", 0)
            kpi_input["d30_retention"] = ret.get("d30", 0)
        if "active_devices" in metrics:
            kpi_input["dau"] = metrics["active_devices"].get("dau", 0)
        if "crashes" in metrics:
            kpi_input["crash_rate"] = metrics["crashes"].get("crash_rate", 0)
        kpi_input["store_rating"] = ratings.get("average", 0)

        results["kpi_check"] = self.check_kpis(kpi_input)
        results["rating_check"] = self.check_store_rating(ratings.get("average", 0))
        results["ranking_check"] = self.check_ranking_changes(rankings)

        # Overall Status
        statuses = [
            results["kpi_check"].get("overall_status", "ok"),
            results["rating_check"].get("status", "ok"),
            results["ranking_check"].get("status", "ok"),
        ]
        if "critical" in statuses:
            results["overall_status"] = "critical"
        elif "warning" in statuses:
            results["overall_status"] = "warning"

        return results
