"""Scenario Definitions — 8 injizierbare Szenarien fuer Stress-Tests.

Jedes Szenario modifiziert Metriken einer App um einen bestimmten Effekt
zu simulieren. Wird vom FleetGenerator.inject_scenario() verwendet.
"""

from typing import Any

# ---------------------------------------------------------------
# Scenario Registry
# ---------------------------------------------------------------

SCENARIOS: dict[str, dict[str, Any]] = {
    "crash_spike": {
        "description": "Ploetzlicher Anstieg der Crash Rate (z.B. nach fehlerhaftem Update)",
        "metric_overrides": {
            "crash_rate": (6.0, 12.0),
            "rating": (-0.8, -1.2),          # Delta: Rating sinkt
            "anr_rate": (1.5, 3.0),
        },
        "expected_action": "hotfix",
        "severity": "critical",
        "duration_days": 2,
    },
    "retention_drop": {
        "description": "Retention faellt ueber 7 Tage ab (Nutzer kommen nicht zurueck)",
        "metric_overrides": {
            "retention_d7": (3.0, 8.0),       # Absolut: sehr niedrig
            "retention_d1": (15.0, 25.0),
            "dau_mau": (0.05, 0.10),
        },
        "expected_action": "patch",
        "severity": "high",
        "duration_days": 7,
    },
    "revenue_decline": {
        "description": "Revenue/ARPU sinkt stetig (Monetarisierungs-Problem)",
        "metric_overrides": {
            "arpu": (0.1, 0.5),
            "conversion": (0.3, 1.0),
            "revenue_trend": -1,              # Negativ-Trend
        },
        "expected_action": "patch",
        "severity": "high",
        "duration_days": 14,
    },
    "review_bomb": {
        "description": "Welle negativer Reviews (1-2 Sterne) in kurzer Zeit",
        "metric_overrides": {
            "rating": (1.5, 2.5),
            "negative_review_count": (15, 40),
        },
        "expected_action": "patch",
        "severity": "medium",
        "duration_days": 3,
    },
    "growth_stall": {
        "description": "Downloads und Wachstum stoppen komplett",
        "metric_overrides": {
            "downloads_period": (0, 10),
            "dau_mau": (-0.05, -0.10),       # Delta: sinkt
            "growth_velocity": 0.0,
        },
        "expected_action": "patch",
        "severity": "medium",
        "duration_days": 14,
    },
    "recovery": {
        "description": "App erholt sich von kritischem Zustand (positive Entwicklung)",
        "metric_overrides": {
            "crash_rate": (0.2, 0.5),
            "rating": (3.8, 4.5),
            "retention_d7": (20.0, 35.0),
            "arpu": (1.5, 3.0),
        },
        "expected_action": "none",
        "severity": "low",
        "duration_days": 14,
    },
    "seasonal_peak": {
        "description": "Saisonaler Anstieg (Feiertage, Ferien etc.)",
        "metric_overrides": {
            "downloads_period": (3000, 10000),
            "dau_mau": (0.35, 0.50),
            "session_length": (200, 500),
            "arpu": (3.0, 6.0),
        },
        "expected_action": "none",
        "severity": "low",
        "duration_days": 7,
    },
    "gradual_decay": {
        "description": "Langsamer Verfall ueber alle Metriken (App wird irrelevant)",
        "metric_overrides": {
            "crash_rate": (2.0, 4.0),
            "rating": (2.5, 3.2),
            "retention_d7": (5.0, 12.0),
            "dau_mau": (0.06, 0.12),
            "arpu": (0.3, 0.8),
            "downloads_period": (20, 80),
        },
        "expected_action": "patch",
        "severity": "high",
        "duration_days": 30,
    },
}


def get_scenario(name: str) -> dict | None:
    """Gibt Szenario-Definition zurueck oder None."""
    return SCENARIOS.get(name)


def list_scenarios() -> list[str]:
    """Gibt alle verfuegbaren Szenario-Namen zurueck."""
    return list(SCENARIOS.keys())
