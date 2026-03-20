"""Phase 2 Market Strategy Pipeline — Configuration"""

AGENT_MODEL_MAP = {
    "platform_strategy": "claude-sonnet-4-6",
    "monetization_architect": "claude-sonnet-4-6",
    "marketing_strategy": "claude-sonnet-4-6",
    "release_planner": "claude-sonnet-4-6",
    "cost_calculation": "claude-sonnet-4-6",
}

PIPELINE_FLOW = {
    "wave_1_parallel": ["platform_strategy", "monetization_architect"],
    "wave_2_parallel": ["marketing_strategy", "release_planner"],
    "wave_3_final": ["cost_calculation"],
}

OUTPUT_DIR = "factory/market_strategy/output"
