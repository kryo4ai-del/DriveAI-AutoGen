"""Trigger-specific templates for briefing details.

Each template maps a trigger type to structured remediation instructions
that the Factory can execute without LLM interpretation.
"""

# ── Trigger Templates ──────────────────────────────────────────────
# Key = trigger name from Decision Engine
# Value = dict with analysis_focus, recommended_actions, affected_areas

TRIGGER_TEMPLATES = {
    "crash_rate_high": {
        "analysis_focus": "Crash-Logs analysieren, Stack Traces gruppieren",
        "recommended_actions": [
            "Top-3 Crash-Ursachen identifizieren",
            "Null-Pointer / Index-Fehler in betroffenen Modulen fixen",
            "Defensive Guards an kritischen Stellen einfuegen",
            "Crash-Reporting Threshold senken fuer Monitoring",
        ],
        "affected_areas": ["stability", "error_handling", "logging"],
        "metric_to_improve": "crash_rate",
        "success_criteria": "Crash-Rate unter Baseline-Wert",
    },

    "retention_dropping": {
        "analysis_focus": "Retention-Funnel pruefen, Day-1/7/30 Kohortenanalyse",
        "recommended_actions": [
            "Onboarding-Flow optimieren (Drop-Off-Punkte)",
            "Push-Notification Timing anpassen",
            "Core-Loop Engagement verbessern",
            "Re-Engagement Trigger nach 24h Inaktivitaet",
        ],
        "affected_areas": ["engagement", "onboarding", "notifications"],
        "metric_to_improve": "retention_rate",
        "success_criteria": "Retention ueber Baseline-Wert",
    },

    "funnel_dropout": {
        "analysis_focus": "Conversion-Funnel Step-by-Step analysieren",
        "recommended_actions": [
            "UI-Bottleneck an Drop-Off-Step identifizieren",
            "Formular-Validierung / UX vereinfachen",
            "Loading-Zeiten am Bottleneck reduzieren",
            "A/B-Test fuer alternativen Flow vorbereiten",
        ],
        "affected_areas": ["conversion", "ui", "performance"],
        "metric_to_improve": "funnel_conversion",
        "success_criteria": "Conversion-Rate ueber Baseline-Wert",
    },

    "review_pattern": {
        "analysis_focus": "Negative Reviews kategorisieren, Keyword-Clustering",
        "recommended_actions": [
            "Top-3 Beschwerden addressieren",
            "Bekannte Bugs aus Reviews priorisieren",
            "App-Store-Antworten fuer kritische Reviews",
            "Feature-Requests aus Reviews extrahieren",
        ],
        "affected_areas": ["user_satisfaction", "bug_fixes", "store_presence"],
        "metric_to_improve": "average_rating",
        "success_criteria": "Rating-Trend steigend, neue negative Reviews sinken",
    },

    "support_spike": {
        "analysis_focus": "Support-Tickets kategorisieren, Haeufigste Themen",
        "recommended_actions": [
            "FAQ / In-App-Help fuer Top-Themen aktualisieren",
            "Automatische Antworten fuer bekannte Issues",
            "Root-Cause der Ticket-Spike identifizieren und fixen",
            "Self-Service Optionen erweitern",
        ],
        "affected_areas": ["support", "documentation", "ui_clarity"],
        "metric_to_improve": "support_tickets",
        "success_criteria": "Ticket-Volumen unter Baseline",
    },

    "revenue_declining": {
        "analysis_focus": "Revenue pro User (ARPU), Conversion-Rate, Churn-Rate",
        "recommended_actions": [
            "Monetarisierungs-Funnel analysieren",
            "Pricing / Paywall Placement ueberpruefen",
            "Premium-Feature Sichtbarkeit erhoehen",
            "Churn-Praevention Massnahmen einleiten",
        ],
        "affected_areas": ["monetization", "conversion", "retention"],
        "metric_to_improve": "revenue",
        "success_criteria": "Revenue-Trend steigend oder stabil",
    },

    # ── Fallback fuer unbekannte Trigger ──────────────────────────
    "_default": {
        "analysis_focus": "Metriken-Abweichung analysieren",
        "recommended_actions": [
            "Root-Cause Analyse durchfuehren",
            "Betroffene Module identifizieren",
            "Fix implementieren und testen",
        ],
        "affected_areas": ["general"],
        "metric_to_improve": "health_score",
        "success_criteria": "Health Score ueber vorherigem Wert",
    },
}


def get_template(trigger: str) -> dict:
    """Return template for trigger, fallback to _default."""
    return TRIGGER_TEMPLATES.get(trigger, TRIGGER_TEMPLATES["_default"])
