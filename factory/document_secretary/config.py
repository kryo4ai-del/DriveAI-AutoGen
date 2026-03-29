"""Document Secretary — Configuration.

Zentrale Modell-Auswahl fuer alle Template-Renderer.
"""

import os


def get_fallback_model(profile: str = "standard") -> str:
    """Dynamische Modellwahl: TheBrain -> .env -> hartcodierter Default.

    Einzige Stelle mit hardcodiertem Modellnamen im gesamten Department.
    """
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
