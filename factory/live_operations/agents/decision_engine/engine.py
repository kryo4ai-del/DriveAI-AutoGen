"""Decision Engine -- evaluiert Apps und trifft autonome Entscheidungen.

Nimmt Health Scores + Analytics Insights und entscheidet:
hotfix / patch / feature_update / strategic_pivot / none

Die Engine FUEHRT NICHTS AUS -- sie entscheidet nur.
Ausfuehrung kommt in Phase 4 (update_planner).
"""

from datetime import datetime, timezone, timedelta
from typing import Optional

from ...app_registry.database import AppRegistryDB
from . import config


class DecisionEngine:
    """Herzstück des Live Operations Layers."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self.db = registry_db or AppRegistryDB()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def evaluate_app(self, app_id: str) -> dict:
        """Evaluiert eine einzelne App und trifft Entscheidung."""
        print(f"[Decision Engine] Evaluating {app_id}")

        # Cooling check
        if self._check_cooling(app_id):
            cooling = self.db.get_cooling_info(app_id)
            remaining = cooling.get("remaining_human", "?") if cooling else "?"
            print(f"[Decision Engine] {app_id} in cooling ({remaining} remaining) -> skip")
            return self._build_cooling_decision(app_id, cooling)

        # Gather all inputs
        inputs = self._gather_inputs(app_id)

        # Calculate severity for each trigger
        severity_scores = self._calculate_severity_scores(inputs)

        # Determine action type
        action_type = self._determine_action_type(app_id, severity_scores, inputs)

        # Build decision
        decision = self._build_decision(app_id, action_type, severity_scores, inputs)

        action_label = action_type.upper() if action_type != "none" else "none"
        print(f"[Decision Engine] {app_id} -> {action_label} (max severity: {decision['data_summary']['max_severity']:.1f})")

        # Enqueue action if needed
        if action_type != "none":
            try:
                from .action_queue import ActionQueueManager
                queue = ActionQueueManager(self.db)
                action_id = queue.enqueue(decision)
                if action_id:
                    decision["action_id"] = action_id
            except Exception as e:
                print(f"[Decision Engine] Queue enqueue failed: {e}")

        return decision

    def evaluate_all(self) -> dict:
        """Evaluiert alle registrierten Apps."""
        print("[Decision Engine] Evaluating all apps")

        try:
            apps = self.db.get_all_apps()
        except Exception:
            apps = []

        results = {}
        for app in apps:
            app_id = app.get("app_id", "")
            if not app_id:
                continue
            try:
                results[app_id] = self.evaluate_app(app_id)
            except Exception as e:
                print(f"[Decision Engine] Error evaluating {app_id}: {e}")
                results[app_id] = {"app_id": app_id, "error": str(e)}

        total = len(results)
        actions = sum(1 for r in results.values() if r.get("action_type", "none") != "none")
        print(f"[Decision Engine] Done: {total} apps, {actions} actions")
        return {"evaluated_at": datetime.now(timezone.utc).isoformat(), "results": results}

    # ------------------------------------------------------------------
    # Input Gathering
    # ------------------------------------------------------------------

    def _gather_inputs(self, app_id: str) -> dict:
        """Sammelt Health Score, Insights, Reviews, Support-Daten."""
        inputs = {
            "app_id": app_id,
            "health_score": 0.0,
            "health_zone": "red",
            "app_profile": "utility",
            "analytics": {},
            "review_insights": {},
            "support_insights": {},
            "health_history": [],
        }

        # App record from registry
        try:
            app = self.db.get_app(app_id)
            if app:
                inputs["health_score"] = app.get("health_score", 0.0)
                inputs["health_zone"] = app.get("health_zone", "red")
                inputs["app_profile"] = app.get("app_profile", "utility")
        except Exception:
            pass

        # Health history for trend analysis
        try:
            inputs["health_history"] = self.db.get_health_history(app_id, limit=30)
        except Exception:
            pass

        # Analytics insights (from JSON files)
        try:
            from ..analytics.analyzer import AnalyticsAgent
            agent = AnalyticsAgent(self.db)
            inputs["analytics"] = agent.get_insights_summary(app_id)
        except Exception:
            pass

        # Review insights
        try:
            from ..review_manager.manager import ReviewAnalyzer
            analyzer = ReviewAnalyzer(self.db)
            inputs["review_insights"] = analyzer.get_review_summary(app_id)
        except Exception:
            pass

        # Support insights
        try:
            from ..support_agent.agent import SupportAnalyzer
            analyzer = SupportAnalyzer(self.db)
            inputs["support_insights"] = analyzer.get_support_summary(app_id) if hasattr(analyzer, "get_support_summary") else {}
        except Exception:
            pass

        return inputs

    # ------------------------------------------------------------------
    # Severity Scoring
    # ------------------------------------------------------------------

    def _calculate_severity_scores(self, inputs: dict) -> list:
        """Berechnet Severity Scores fuer alle potentiellen Trigger."""
        scores = []

        for trigger_name, trigger_def in config.TRIGGER_DEFINITIONS.items():
            current_value = self._extract_metric_value(inputs, trigger_def)
            if current_value is None:
                continue

            severity_data = self._calculate_single_severity(
                trigger_name, trigger_def, current_value, inputs
            )
            if severity_data and severity_data["severity"] > 0:
                scores.append(severity_data)

        # Sort by severity descending
        scores.sort(key=lambda s: s["severity"], reverse=True)
        return scores

    def _calculate_single_severity(self, trigger_name: str, trigger_def: dict,
                                   current_value, inputs: dict) -> Optional[dict]:
        """Berechnet Severity Score fuer einen einzelnen Trigger.

        3 Dimensionen:
        - deviation: Wie stark weicht der Wert vom Zielwert ab? (0-100)
        - impact: Wie viele Nutzer sind betroffen? (0-100)
        - velocity: Wie schnell verschlechtert sich der Trend? (0-100)
        """
        threshold_w = trigger_def.get("threshold_warning")
        threshold_c = trigger_def.get("threshold_critical")

        # Handle string thresholds (review_pattern)
        if isinstance(threshold_w, str):
            severity_map = {"low": 20, "medium": 50, "high": 80}
            if isinstance(current_value, str):
                deviation = severity_map.get(current_value, 0)
            else:
                deviation = 0
        else:
            # Numeric: calculate deviation percentage between warning and critical
            if threshold_c == threshold_w:
                deviation = 0
            elif threshold_c > threshold_w:
                # Higher is worse (crash_rate, tickets, dropout)
                if current_value < threshold_w:
                    deviation = 0
                elif current_value >= threshold_c:
                    deviation = 100
                else:
                    deviation = ((current_value - threshold_w) / (threshold_c - threshold_w)) * 100
            else:
                # Lower is worse (negative trends: retention, revenue, downloads)
                if current_value > threshold_w:
                    deviation = 0
                elif current_value <= threshold_c:
                    deviation = 100
                else:
                    deviation = ((threshold_w - current_value) / (threshold_w - threshold_c)) * 100

        if deviation <= 0:
            return None

        deviation = min(max(deviation, 0), 100)

        # Impact: estimate from DAU/user count or default
        impact = self._estimate_impact(trigger_name, inputs)

        # Velocity: how fast is it getting worse
        velocity = self._estimate_velocity(trigger_name, inputs)

        severity = (
            deviation * config.DEVIATION_WEIGHT
            + impact * config.IMPACT_WEIGHT
            + velocity * config.VELOCITY_WEIGHT
        )
        severity = min(max(severity, 0), 100)

        detail = self._build_trigger_detail(trigger_name, current_value, trigger_def)

        return {
            "trigger": trigger_name,
            "severity": round(severity, 1),
            "deviation": round(deviation, 1),
            "impact": round(impact, 1),
            "velocity": round(velocity, 1),
            "category": trigger_def.get("category", "unknown"),
            "detail": detail,
            "current_value": current_value,
        }

    def _extract_metric_value(self, inputs: dict, trigger_def: dict):
        """Extrahiert den aktuellen Metrik-Wert aus den Inputs."""
        source = trigger_def.get("source", "")
        metric = trigger_def.get("metric", "")

        # Health score stability -> crash_rate
        if source == "health_score.stability" and metric == "crash_rate":
            # From health history or analytics
            analytics = inputs.get("analytics", {})
            trends = analytics.get("trends", [])
            for t in trends:
                name = t.get("metric", t.get("name", ""))
                if "crash" in name.lower():
                    return t.get("current_value", t.get("latest_value"))
            return None

        # Review insights
        if source == "review_insights.rating_health":
            ri = inputs.get("review_insights", {})
            rh = ri.get("rating_health", {})
            if rh.get("trend") == "declining":
                prev = rh.get("previous_average", 0)
                curr = rh.get("current_average", 0)
                if prev > 0:
                    return curr - prev
            return None

        if source == "review_insights.patterns":
            ri = inputs.get("review_insights", {})
            patterns = ri.get("patterns", [])
            if patterns:
                # Highest severity pattern
                for p in patterns:
                    if p.get("severity") == "high":
                        return "high"
                for p in patterns:
                    if p.get("severity") == "medium":
                        return "medium"
            return None

        # Analytics trends
        if source == "analytics.trends":
            analytics = inputs.get("analytics", {})
            trends = analytics.get("trends", [])
            for t in trends:
                name = t.get("metric", t.get("name", ""))
                if metric in name.lower() or name.lower() in metric:
                    # Return the change rate or slope
                    if t.get("direction") == "falling" or t.get("trend") == "falling":
                        return -(t.get("strength", 0.1))
                    return None
            return None

        # Analytics funnels
        if source == "analytics.funnels":
            analytics = inputs.get("analytics", {})
            funnels = analytics.get("funnels", [])
            worst_dropout = 0
            for f in funnels:
                steps = f.get("steps", [])
                for s in steps:
                    drop = s.get("drop_off_rate", s.get("drop_off", 0))
                    if drop > worst_dropout:
                        worst_dropout = drop
            return worst_dropout if worst_dropout > 0 else None

        # Support insights
        if source == "support_insights":
            si = inputs.get("support_insights", {})
            if metric == "tickets_per_dau":
                return si.get("tickets_per_dau", si.get("ticket_ratio"))
            return None

        if source == "support_insights.recurring_issues":
            si = inputs.get("support_insights", {})
            issues = si.get("recurring_issues", [])
            if issues:
                return max(i.get("severity_score", i.get("severity", 0)) for i in issues)
            return None

        return None

    def _estimate_impact(self, trigger_name: str, inputs: dict) -> float:
        """Schaetzt Impact (0-100) basierend auf Trigger-Typ."""
        # High impact triggers
        if trigger_name == "crash_rate_high":
            return 80.0  # Crashes affect all users
        if trigger_name == "revenue_declining":
            return 75.0
        if trigger_name in ("retention_dropping", "downloads_dropping"):
            return 60.0
        if trigger_name in ("support_spike", "recurring_bug"):
            return 50.0
        if trigger_name in ("rating_declining", "review_pattern"):
            return 40.0
        if trigger_name == "funnel_dropout":
            return 55.0
        return 30.0

    def _estimate_velocity(self, trigger_name: str, inputs: dict) -> float:
        """Schaetzt Velocity (0-100) basierend auf Trend-Daten."""
        analytics = inputs.get("analytics", {})
        trends = analytics.get("trends", [])

        for t in trends:
            name = t.get("metric", t.get("name", ""))
            direction = t.get("direction", t.get("trend", ""))
            strength = t.get("strength", 0)

            if direction == "falling" or direction == "declining":
                # Map strength to velocity
                return min(strength * 100, 100)

        # Default: moderate velocity for active triggers
        if trigger_name == "crash_rate_high":
            return 70.0  # Crashes tend to be fast and accelerating
        if trigger_name == "support_spike":
            return 60.0
        return 30.0

    def _build_trigger_detail(self, trigger_name: str, value, trigger_def: dict) -> str:
        """Generiert menschenlesbares Detail fuer einen Trigger."""
        metric = trigger_def.get("metric", trigger_name)
        category = trigger_def.get("category", "")

        if isinstance(value, float):
            if abs(value) < 1:
                return f"{metric}: {value:.1%} ({category})"
            return f"{metric}: {value:.1f} ({category})"
        return f"{metric}: {value} ({category})"

    # ------------------------------------------------------------------
    # Action Type Determination
    # ------------------------------------------------------------------

    def _determine_action_type(self, app_id: str, severity_scores: list,
                               inputs: dict) -> str:
        """Bestimmt den Aktionstyp basierend auf Severity Scores."""
        if not severity_scores:
            return "none"

        max_severity = severity_scores[0]["severity"] if severity_scores else 0
        max_category = severity_scores[0].get("category", "") if severity_scores else ""

        # 1. No score above threshold -> none
        if max_severity < config.SEVERITY_IGNORE_BELOW:
            return "none"

        # 2. Check for strategic pivot: Health Score under 50 for >2 weeks
        if self._check_strategic_pivot(app_id, inputs):
            return "strategic_pivot"

        # 3. Hotfix: highest severity > 85 AND stability category
        if max_severity > config.SEVERITY_HOTFIX_THRESHOLD and max_category == "stability":
            return "hotfix"

        # 4. Multiple scores in patch range -> patch
        patch_range_count = sum(
            1 for s in severity_scores
            if config.SEVERITY_PATCH_MIN <= s["severity"] <= config.SEVERITY_PATCH_MAX
        )
        if patch_range_count >= 2:
            return "patch"

        # 5. Single high severity -> hotfix if stability, else patch
        if max_severity > config.SEVERITY_HOTFIX_THRESHOLD:
            return "hotfix"

        # 6. Engagement/revenue/growth -> feature_update
        engagement_categories = {"engagement", "revenue", "growth"}
        if max_category in engagement_categories and max_severity >= config.SEVERITY_PATCH_MIN:
            return "feature_update"

        # 7. Default for moderate severity
        if max_severity >= config.SEVERITY_PATCH_MIN:
            return "patch"

        return "none"

    def _check_strategic_pivot(self, app_id: str, inputs: dict) -> bool:
        """Prueft ob App seit >2 Wochen unter Health Score 50 ist."""
        history = inputs.get("health_history", [])
        if not history:
            return False

        weeks_threshold = config.STRATEGIC_PIVOT_WEEKS_BELOW_50
        days_needed = weeks_threshold * 7

        # Check if we have enough history
        if len(history) < 2:
            return False

        # Count consecutive records below 50
        below_count = 0
        for record in history:
            score = record.get("overall_score", record.get("health_score", 100))
            if score < 50:
                below_count += 1
            else:
                break  # First record above 50 breaks the streak

        # Estimate days (assuming ~1 record per cycle = 6h = 4 per day)
        estimated_days = below_count / 4
        return estimated_days >= days_needed

    # ------------------------------------------------------------------
    # Decision Building
    # ------------------------------------------------------------------

    def _build_decision(self, app_id: str, action_type: str,
                        severity_scores: list, inputs: dict) -> dict:
        """Baut das vollstaendige Entscheidungs-Objekt."""
        max_severity = severity_scores[0]["severity"] if severity_scores else 0
        primary_trigger = severity_scores[0]["trigger"] if severity_scores else "none"
        categories = list(set(s["category"] for s in severity_scores))

        # Escalation level
        escalation_level = self._determine_escalation_level(action_type, severity_scores)

        # Recommendation text
        recommendation = self._generate_recommendation(action_type, severity_scores)

        return {
            "app_id": app_id,
            "decided_at": datetime.now(timezone.utc).isoformat(),
            "health_score": inputs.get("health_score", 0),
            "health_zone": inputs.get("health_zone", "red"),
            "cooling_active": False,
            "action_type": action_type,
            "severity_scores": severity_scores,
            "primary_trigger": primary_trigger,
            "escalation_level": escalation_level,
            "recommendation": recommendation,
            "data_summary": {
                "active_triggers": len(severity_scores),
                "max_severity": round(max_severity, 1),
                "categories_affected": categories,
            },
        }

    def _build_cooling_decision(self, app_id: str, cooling: dict) -> dict:
        """Baut Decision fuer App in Cooling Period."""
        return {
            "app_id": app_id,
            "decided_at": datetime.now(timezone.utc).isoformat(),
            "health_score": 0,
            "health_zone": "unknown",
            "cooling_active": True,
            "action_type": "none",
            "severity_scores": [],
            "primary_trigger": "none",
            "escalation_level": 0,
            "recommendation": "App in Cooling Period -- keine Aktion",
            "data_summary": {
                "active_triggers": 0,
                "max_severity": 0,
                "categories_affected": [],
                "cooling_remaining": cooling.get("remaining_human", "?") if cooling else "?",
            },
        }

    def _determine_escalation_level(self, action_type: str, severity_scores: list) -> int:
        """Bestimmt Eskalations-Level: 1=Info, 2=Warning, 3=CEO."""
        if action_type == "strategic_pivot":
            return 3
        if action_type == "hotfix":
            return 2
        if action_type in ("patch", "feature_update"):
            return 1
        return 0

    def _generate_recommendation(self, action_type: str, severity_scores: list) -> str:
        """Generiert Empfehlungstext."""
        if action_type == "none":
            return "Keine Aktion erforderlich -- alle Metriken im gruenen Bereich"

        if not severity_scores:
            return f"{action_type} empfohlen"

        primary = severity_scores[0]
        trigger = primary["trigger"].replace("_", " ").title()
        severity = primary["severity"]

        if action_type == "hotfix":
            return f"Hotfix DRINGEND: {trigger} (Severity {severity:.0f}) -- sofortige Massnahme"
        if action_type == "patch":
            categories = list(set(s["category"] for s in severity_scores[:3]))
            return f"Patch empfohlen: {', '.join(categories)} betroffen (max Severity {severity:.0f})"
        if action_type == "feature_update":
            return f"Feature Update empfohlen: {trigger} (Severity {severity:.0f})"
        if action_type == "strategic_pivot":
            return "Strategic Pivot: Health Score seit >2 Wochen unter 50 -- CEO-Entscheidung erforderlich"
        return f"{action_type}: {trigger}"

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _check_cooling(self, app_id: str) -> bool:
        """Prueft ob App in Cooling Period ist."""
        try:
            return self.db.is_cooling(app_id)
        except Exception:
            return False
