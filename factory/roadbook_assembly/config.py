"""Kapitel 6 Roadbook Assembly — Configuration

Uses TheBrain Multi-Provider system for model selection.
Gemini 2.5 Flash (1M context, 65k output) is the preferred model for roadbook assembly
due to the massive input size (200k+ chars from all chapters).
"""

MODEL_SELECTION_CONFIG = {
    "ceo_roadbook": {
        "profile": "dev",
        "expected_output_tokens": 20000,
        "task_description": "Strategic roadbook compilation from 200k+ input",
        "preferred_reason": "Large context window needed (200k+ input), long output (20k tokens)",
    },
    "cd_roadbook": {
        "profile": "dev",
        "expected_output_tokens": 30000,
        "task_description": "Technical roadbook compilation from 200k+ input",
        "preferred_reason": "Largest output needed (30k+ tokens), large context window",
    },
}

def get_fallback_model(profile: str = "standard") -> str:
    """Get the best available model for a profile (TheBrain → .env → default)."""
    import os
    try:
        from factory.brain.model_provider import get_model
        selection = get_model(profile=profile)
        if selection and selection.get("model"):
            return selection["model"]
    except Exception:
        pass
    if profile in ("dev", "lightweight"):
        return os.environ.get("ANTHROPIC_FALLBACK_MODEL_LIGHTWEIGHT", "claude-haiku-4-5")
    return os.environ.get("ANTHROPIC_FALLBACK_MODEL", "claude-sonnet-4-6")


FALLBACK_MODEL = get_fallback_model()
FALLBACK_PROVIDER = "anthropic"

PIPELINE_FLOW = {
    "parallel": ["ceo_roadbook", "cd_roadbook"],
}

OUTPUT_DIR = "factory/roadbook_assembly/output"

CEO_ROADBOOK_TARGET_PAGES = "15-25"
CD_ROADBOOK_TARGET_PAGES = "30-50"


def get_agent_model(agent_name: str) -> dict:
    """Get the optimal model for a roadbook agent via TheBrain.

    Returns dict with 'model', 'provider', etc. or fallback.
    """
    try:
        from factory.brain.model_provider import get_model
        config = MODEL_SELECTION_CONFIG.get(agent_name, {})
        selection = get_model(
            profile=config.get("profile", "dev"),
            expected_output_tokens=config.get("expected_output_tokens", 20000),
        )
        print(f"[Kapitel6] TheBrain selected: {selection['model']} ({selection['provider']}) for {agent_name}")
        return selection
    except Exception as e:
        print(f"[Kapitel6] TheBrain not available ({e}), falling back to {FALLBACK_MODEL}")
        return {
            "model": FALLBACK_MODEL,
            "provider": FALLBACK_PROVIDER,
            "litellm_model_name": f"anthropic/{FALLBACK_MODEL}",
            "max_tokens": 8000,
        }
