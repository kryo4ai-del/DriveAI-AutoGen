"""Kapitel 4.5 Design Vision & UX Innovation — Configuration"""

import os


def get_fallback_model(profile: str = "standard") -> str:
    """Get the best available model for a profile (TheBrain → .env → default)."""
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
    "trend_breaker": get_fallback_model(),
    "emotion_architect": get_fallback_model(),
    "vision_compiler": get_fallback_model(),
}

PIPELINE_FLOW = {
    "step_1": ["trend_breaker"],
    "step_2": ["emotion_architect"],
    "step_3": ["vision_compiler"],
}

OUTPUT_DIR = "factory/design_vision/output"

# Design philosophy
DESIGN_PRINCIPLES = {
    "core_rule": "Wenn du vor der Wahl stehst zwischen Standard und Innovation — waehle IMMER Innovation",
    "anti_average": "Die App darf NICHT aussehen wie die Wettbewerber",
    "wow_minimum": 3,  # Mindestens 3 Wow-Momente
    "anti_rules_minimum": 4,  # Mindestens 4 Anti-Standard-Regeln
    "emotion_required": True,  # Jeder App-Bereich braucht eine definierte Emotion
}
