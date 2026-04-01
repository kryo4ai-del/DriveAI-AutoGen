"""Phase 2 Market Strategy Pipeline — Configuration"""

import os


def get_fallback_model(profile: str = "standard") -> str:
    """Dynamische Modellwahl: TheBrain -> .env -> hartcodierter Default.

    Einzige Stelle mit hardcodiertem Modellnamen im gesamten Department.
    """
    try:
        from factory.brain.model_provider import get_model
        selection = get_model(profile=profile)
        if selection and selection.get("model") and selection.get("provider") == "anthropic":
            return selection["model"]
    except Exception:
        pass

    if profile in ("dev", "lightweight"):
        return os.environ.get("ANTHROPIC_FALLBACK_MODEL_LIGHTWEIGHT", "claude-haiku-4-5")
    return os.environ.get("ANTHROPIC_FALLBACK_MODEL", "claude-sonnet-4-6")


AGENT_MODEL_MAP = {
    "platform_strategy": get_fallback_model(),
    "monetization_architect": get_fallback_model(),
    "marketing_strategy": get_fallback_model(),
    "release_planner": get_fallback_model(),
    "cost_calculation": get_fallback_model(),
}

PIPELINE_FLOW = {
    "wave_1_parallel": ["platform_strategy", "monetization_architect"],
    "wave_2_parallel": ["marketing_strategy", "release_planner"],
    "wave_3_final": ["cost_calculation"],
}

OUTPUT_DIR = "factory/market_strategy/output"
