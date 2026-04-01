"""Decision Engine Configuration."""

# Cycle timing
CYCLE_INTERVAL_HOURS = 6

# Severity thresholds for action type determination
SEVERITY_HOTFIX_THRESHOLD = 85
SEVERITY_PATCH_MIN = 40
SEVERITY_PATCH_MAX = 70
SEVERITY_IGNORE_BELOW = 30
STRATEGIC_PIVOT_WEEKS_BELOW_50 = 2  # Weeks with Health Score <50 for pivot

# Severity dimension weights
DEVIATION_WEIGHT = 0.40
IMPACT_WEIGHT = 0.35
VELOCITY_WEIGHT = 0.25

# Cooling Periods (hours)
COOLING_HOTFIX_HOURS = 48
COOLING_PATCH_HOURS = 168       # 1 week
COOLING_FEATURE_HOURS = 336     # 2 weeks

COOLING_DURATIONS = {
    "hotfix": COOLING_HOTFIX_HOURS,
    "patch": COOLING_PATCH_HOURS,
    "feature_update": COOLING_FEATURE_HOURS,
    "strategic_pivot": 0,       # CEO defines manually
}

# Trigger definitions
TRIGGER_DEFINITIONS = {
    "crash_rate_high": {
        "source": "health_score.stability",
        "metric": "crash_rate",
        "threshold_warning": 0.02,
        "threshold_critical": 0.05,
        "category": "stability",
    },
    "rating_declining": {
        "source": "review_insights.rating_health",
        "metric": "rating_trend",
        "threshold_warning": -0.1,
        "threshold_critical": -0.3,
        "category": "satisfaction",
    },
    "retention_dropping": {
        "source": "analytics.trends",
        "metric": "retention_day7",
        "threshold_warning": -0.05,
        "threshold_critical": -0.15,
        "category": "engagement",
    },
    "revenue_declining": {
        "source": "analytics.trends",
        "metric": "revenue_period",
        "threshold_warning": -0.10,
        "threshold_critical": -0.25,
        "category": "revenue",
    },
    "downloads_dropping": {
        "source": "analytics.trends",
        "metric": "downloads_period",
        "threshold_warning": -0.15,
        "threshold_critical": -0.30,
        "category": "growth",
    },
    "support_spike": {
        "source": "support_insights",
        "metric": "tickets_per_dau",
        "threshold_warning": 0.008,
        "threshold_critical": 0.015,
        "category": "satisfaction",
    },
    "funnel_dropout": {
        "source": "analytics.funnels",
        "metric": "weakest_point_dropout",
        "threshold_warning": 0.40,
        "threshold_critical": 0.60,
        "category": "engagement",
    },
    "recurring_bug": {
        "source": "support_insights.recurring_issues",
        "metric": "severity_score",
        "threshold_warning": 60,
        "threshold_critical": 80,
        "category": "stability",
    },
    "review_pattern": {
        "source": "review_insights.patterns",
        "metric": "pattern_severity",
        "threshold_warning": "medium",
        "threshold_critical": "high",
        "category": "satisfaction",
    },
}
