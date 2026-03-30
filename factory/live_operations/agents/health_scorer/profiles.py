"""App-Kategorie-Profile — Gewichtungen pro Profil fuer den Health Score.

5 Profile mit unterschiedlicher Gewichtung der 5 Scoring-Kategorien.
Alle Gewichtungen summieren sich zu 1.0.
"""

PROFILES: dict[str, dict] = {
    "gaming": {
        "weights": {
            "stability": 0.20,
            "satisfaction": 0.15,
            "engagement": 0.35,
            "revenue": 0.25,
            "growth": 0.05,
        },
        "engagement_metrics": ["session_length", "daily_returns", "in_game_progression"],
        "primary_kpis": ["dau", "session_count", "arpu"],
    },
    "education": {
        "weights": {
            "stability": 0.20,
            "satisfaction": 0.30,
            "engagement": 0.25,
            "revenue": 0.10,
            "growth": 0.15,
        },
        "engagement_metrics": ["completion_rate", "return_rate", "learning_progress"],
        "primary_kpis": ["completion_rate", "retention_day30", "rating_average"],
    },
    "utility": {
        "weights": {
            "stability": 0.35,
            "satisfaction": 0.25,
            "engagement": 0.10,
            "revenue": 0.20,
            "growth": 0.10,
        },
        "engagement_metrics": ["task_completion_rate"],
        "primary_kpis": ["crash_rate", "rating_average", "conversion_rate"],
    },
    "content": {
        "weights": {
            "stability": 0.10,
            "satisfaction": 0.15,
            "engagement": 0.30,
            "revenue": 0.20,
            "growth": 0.25,
        },
        "engagement_metrics": ["session_length", "content_consumption", "return_rate"],
        "primary_kpis": ["dau_mau_ratio", "session_count", "downloads_period"],
    },
    "subscription": {
        "weights": {
            "stability": 0.15,
            "satisfaction": 0.25,
            "engagement": 0.20,
            "revenue": 0.30,
            "growth": 0.10,
        },
        "engagement_metrics": ["feature_adoption", "workflow_completion"],
        "primary_kpis": ["conversion_rate", "arpu", "retention_day30"],
    },
}

DEFAULT_PROFILE = "utility"

# Validate all profiles sum to 1.0
for _name, _profile in PROFILES.items():
    _total = sum(_profile["weights"].values())
    assert abs(_total - 1.0) < 0.001, (
        f"Profile '{_name}' weights sum to {_total}, expected 1.0"
    )
