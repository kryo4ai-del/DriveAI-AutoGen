"""Kapitel 4 MVP & Feature Scope — Configuration"""

AGENT_MODEL_MAP = {
    "feature_extraction": "claude-sonnet-4-6",
    "feature_prioritization": "claude-sonnet-4-6",
    "screen_architect": "claude-sonnet-4-6",
}

PIPELINE_FLOW = {
    "step_1": ["feature_extraction"],
    "step_2": ["feature_prioritization"],
    "step_3": ["screen_architect"],
}

OUTPUT_DIR = "factory/mvp_scope/output"

# Budget constraints from Kapitel 3 Cost Calculation
PHASE_A_BUDGET = 252500  # EUR — Soft-Launch MVP
PHASE_B_BUDGET = 230000  # EUR — Full Production

# KPI targets from CEO Briefings / Release Plan
KPI_TARGETS = {
    "d1_retention": 0.40,
    "d7_retention": 0.20,
    "d30_retention": 0.10,
    "rewarded_ad_ecpm": 10.0,
    "app_store_rating": 4.2,
    "ki_level_latency_sec": 2.0,
    "crash_rate": 0.02,
    "sessions_per_day": 2.0,
    "session_duration_min": (6, 10),
}
