"""Funnel Analysis -- erkennt wo Nutzer abspringen."""

from datetime import datetime, timezone


class FunnelAnalyzer:
    """Analysiert Conversion Funnels und findet den schwachsten Punkt."""

    # Standard-Funnels die jede DAI-Core App hat
    STANDARD_FUNNELS = {
        "onboarding": [
            "app_open", "onboarding_start", "onboarding_complete", "first_feature",
        ],
        "conversion": [
            "app_open", "feature_discovered", "feature_used", "purchase_start", "purchase_complete",
        ],
        "retention": [
            "install", "return_day1", "return_day7", "return_day30",
        ],
    }

    def __init__(self) -> None:
        pass

    def analyze_funnels(self, metrics_history: list[dict]) -> dict:
        """Analysiert alle Funnels basierend auf Metriken-History."""
        if not metrics_history:
            return {"funnels": {}, "critical_findings": []}

        current = metrics_history[-1] if metrics_history else {}
        previous = metrics_history[-2] if len(metrics_history) >= 2 else None

        funnels = {}
        critical_findings = []

        # Onboarding Funnel
        onboarding = self._build_onboarding_funnel(current)
        if onboarding:
            funnels["onboarding"] = self._analyze_single_funnel("onboarding", onboarding, previous)
            critical_findings.extend(self._evaluate_funnel("onboarding", funnels["onboarding"]))

        # Conversion Funnel
        conversion = self._build_conversion_funnel(current)
        if conversion:
            funnels["conversion"] = self._analyze_single_funnel("conversion", conversion, previous)
            critical_findings.extend(self._evaluate_funnel("conversion", funnels["conversion"]))

        # Retention Funnel
        retention = self._build_retention_funnel(current)
        if retention:
            funnels["retention"] = self._analyze_single_funnel("retention", retention, previous)
            critical_findings.extend(self._evaluate_funnel("retention", funnels["retention"]))

        return {"funnels": funnels, "critical_findings": critical_findings}

    def analyze_single_funnel(self, funnel_name: str, steps_data: list[dict],
                              previous_data: list[dict] = None) -> dict:
        """Analysiert einen einzelnen Funnel."""
        return self._analyze_single_funnel(funnel_name, steps_data, previous_data)

    # ------------------------------------------------------------------
    # Funnel Building (from metrics)
    # ------------------------------------------------------------------

    def _build_onboarding_funnel(self, metrics: dict) -> list[dict]:
        """Baut Onboarding Funnel aus Metriken."""
        firebase = metrics.get("firebase_metrics", {})
        funnel_data = firebase.get("funnel_completion", {}).get("onboarding", {})

        if not funnel_data and not firebase.get("dau"):
            return []

        dau = firebase.get("dau", 1000)
        steps = funnel_data.get("steps", {})

        return [
            {"step": 1, "name": "App Open", "users": steps.get("app_open", dau)},
            {"step": 2, "name": "Onboarding Start", "users": steps.get("onboarding_start", int(dau * 0.85))},
            {"step": 3, "name": "Onboarding Complete", "users": steps.get("onboarding_complete", int(dau * 0.55))},
            {"step": 4, "name": "First Feature", "users": steps.get("first_feature", int(dau * 0.45))},
        ]

    def _build_conversion_funnel(self, metrics: dict) -> list[dict]:
        """Baut Conversion Funnel aus Metriken."""
        firebase = metrics.get("firebase_metrics", {})
        funnel_data = firebase.get("funnel_completion", {}).get("conversion", {})

        if not funnel_data and not firebase.get("dau"):
            return []

        dau = firebase.get("dau", 1000)
        conv_rate = firebase.get("conversion_rate", 0.05)
        steps = funnel_data.get("steps", {})

        return [
            {"step": 1, "name": "App Open", "users": steps.get("app_open", dau)},
            {"step": 2, "name": "Feature Discovered", "users": steps.get("feature_discovered", int(dau * 0.60))},
            {"step": 3, "name": "Feature Used", "users": steps.get("feature_used", int(dau * 0.40))},
            {"step": 4, "name": "Purchase Start", "users": steps.get("purchase_start", int(dau * 0.08))},
            {"step": 5, "name": "Purchase Complete", "users": steps.get("purchase_complete", int(dau * conv_rate))},
        ]

    def _build_retention_funnel(self, metrics: dict) -> list[dict]:
        """Baut Retention Funnel aus Metriken."""
        firebase = metrics.get("firebase_metrics", {})
        store = metrics.get("store_metrics", {})

        downloads = store.get("downloads_period", 0)
        if downloads == 0:
            downloads = firebase.get("dau", 1000)

        ret_d1 = firebase.get("retention_day1", 0.4)
        ret_d7 = firebase.get("retention_day7", 0.25)
        ret_d30 = firebase.get("retention_day30", 0.10)

        return [
            {"step": 1, "name": "Install", "users": downloads},
            {"step": 2, "name": "Day 1 Return", "users": int(downloads * ret_d1)},
            {"step": 3, "name": "Day 7 Return", "users": int(downloads * ret_d7)},
            {"step": 4, "name": "Day 30 Return", "users": int(downloads * ret_d30)},
        ]

    # ------------------------------------------------------------------
    # Core Analysis
    # ------------------------------------------------------------------

    def _analyze_single_funnel(self, name: str, steps: list[dict],
                               previous_metrics: dict = None) -> dict:
        """Vollstaendige Analyse eines Funnels."""
        if not steps:
            return {}

        # Conversion Rates berechnen
        for i, step in enumerate(steps):
            if i == 0:
                step["rate"] = 1.0
            else:
                prev_users = steps[i - 1]["users"]
                step["rate"] = round(step["users"] / prev_users, 3) if prev_users > 0 else 0.0

        overall_conversion = self._calculate_overall_conversion(steps)
        weakest = self._find_weakest_point(steps)

        result = {
            "steps": steps,
            "overall_conversion": overall_conversion,
            "weakest_point": weakest,
            "trend_vs_previous": None,
        }

        # Vergleich mit vorheriger Periode
        if previous_metrics:
            prev_funnel = self._build_funnel_for_name(name, previous_metrics)
            if prev_funnel:
                result["trend_vs_previous"] = self._compare_with_previous(steps, prev_funnel)

        return result

    def _build_funnel_for_name(self, name: str, metrics: dict) -> list[dict]:
        """Baut den passenden Funnel fuer einen Namen."""
        builders = {
            "onboarding": self._build_onboarding_funnel,
            "conversion": self._build_conversion_funnel,
            "retention": self._build_retention_funnel,
        }
        builder = builders.get(name)
        return builder(metrics) if builder else []

    def _calculate_overall_conversion(self, steps: list[dict]) -> float:
        """Gesamt-Conversion (erster Step -> letzter Step)."""
        if not steps or steps[0]["users"] == 0:
            return 0.0
        return round(steps[-1]["users"] / steps[0]["users"], 3)

    def _find_weakest_point(self, steps: list[dict]) -> dict:
        """Step mit dem hoechsten Drop-off."""
        if len(steps) < 2:
            return {}

        worst_drop = 0.0
        worst_from = 0
        worst_to = 0

        for i in range(1, len(steps)):
            prev_users = steps[i - 1]["users"]
            if prev_users == 0:
                continue
            drop_off = 1.0 - (steps[i]["users"] / prev_users)
            if drop_off > worst_drop:
                worst_drop = drop_off
                worst_from = i - 1
                worst_to = i

        return {
            "from_step": worst_from + 1,
            "from_name": steps[worst_from]["name"],
            "to_step": worst_to + 1,
            "to_name": steps[worst_to]["name"],
            "drop_off_rate": round(worst_drop, 3),
            "message": f"{worst_drop:.0%} drop-off from '{steps[worst_from]['name']}' to '{steps[worst_to]['name']}'",
        }

    def _compare_with_previous(self, current: list[dict], previous: list[dict]) -> dict:
        """Vergleich aktuelle vs. vorherige Periode."""
        curr_conv = self._calculate_overall_conversion(current)
        prev_conv = self._calculate_overall_conversion(previous)

        change = curr_conv - prev_conv
        direction = "improving" if change > 0.01 else ("declining" if change < -0.01 else "stable")

        worst_step_change = {"step": 0, "change": 0.0}
        min_steps = min(len(current), len(previous))
        for i in range(1, min_steps):
            curr_rate = current[i]["rate"]
            prev_rate = previous[i]["rate"]
            step_change = curr_rate - prev_rate
            if abs(step_change) > abs(worst_step_change["change"]):
                worst_step_change = {"step": i + 1, "name": current[i]["name"], "change": round(step_change, 3)}

        return {
            "overall_change": round(change, 3),
            "direction": direction,
            "worst_step_change": worst_step_change,
        }

    def _calculate_step_conversion(self, step_from: int, step_to: int, steps: list[dict]) -> float:
        """Conversion zwischen zwei Steps."""
        if step_from >= len(steps) or step_to >= len(steps):
            return 0.0
        from_users = steps[step_from]["users"]
        return steps[step_to]["users"] / from_users if from_users > 0 else 0.0

    # ------------------------------------------------------------------
    # Evaluation
    # ------------------------------------------------------------------

    def _evaluate_funnel(self, funnel_name: str, funnel_data: dict) -> list[dict]:
        """Generiert Critical Findings fuer einen Funnel."""
        findings = []
        if not funnel_data:
            return findings

        overall = funnel_data.get("overall_conversion", 0)
        weakest = funnel_data.get("weakest_point", {})
        trend = funnel_data.get("trend_vs_previous")

        # Overall Conversion < 20% -> critical
        if overall < 0.20:
            findings.append({
                "funnel": funnel_name,
                "severity": "critical",
                "message": f"{funnel_name} overall conversion is only {overall:.0%} -- critically low",
                "suggested_action": f"Major overhaul of {funnel_name} funnel needed",
            })

        # Drop-off > 40% at single step -> high
        drop_off = weakest.get("drop_off_rate", 0)
        if drop_off > 0.40:
            findings.append({
                "funnel": funnel_name,
                "severity": "high",
                "message": f"{drop_off:.0%} drop-off at {weakest.get('to_name', '?')} in {funnel_name}",
                "suggested_action": f"Investigate and improve {weakest.get('to_name', '?')} step",
            })
        elif drop_off > 0.25:
            findings.append({
                "funnel": funnel_name,
                "severity": "medium",
                "message": f"{drop_off:.0%} drop-off at {weakest.get('to_name', '?')} in {funnel_name}",
                "suggested_action": f"Consider optimizing {weakest.get('to_name', '?')} step",
            })

        # Verschlechterung > 10%
        if trend and trend.get("overall_change", 0) < -0.10:
            findings.append({
                "funnel": funnel_name,
                "severity": "high",
                "message": f"{funnel_name} conversion dropped by {abs(trend['overall_change']):.0%} vs previous period",
                "suggested_action": "Investigate recent changes that may have affected the funnel",
            })

        return findings
