"""Kapitel 5 Visual & Asset Audit — Configuration"""

AGENT_MODEL_MAP = {
    "asset_discovery": "claude-sonnet-4-6",
    "asset_strategy": "claude-sonnet-4-6",
    "visual_consistency": "claude-sonnet-4-6",
    "review_assistant": "claude-sonnet-4-6",
}

PIPELINE_FLOW = {
    "step_1": ["asset_discovery"],
    "step_2": ["asset_strategy"],
    "step_3": ["visual_consistency"],
    "review": ["review_assistant"],  # Only triggered by human feedback
}

OUTPUT_DIR = "factory/visual_audit/output"

# Asset categories for discovery
ASSET_CATEGORIES = [
    "App-Branding",
    "Gameplay-Assets",
    "UI-Elemente",
    "Illustrationen",
    "Animationen & Effekte",
    "Datenvisualisierung",
    "Story/Narrative Assets",
    "Social-Assets",
    "Monetarisierungs-Assets",
    "Marketing-Assets",
    "Legal-UI",
]

# Ampel ratings for consistency check
RATINGS = {
    "red": "\U0001f534 Blocker — App funktioniert nicht ohne dieses Asset",
    "yellow": "\U0001f7e1 Schlechte UX — funktioniert technisch, wirkt unprofessionell",
    "green": "\U0001f7e2 Nice-to-have — Verbesserung, nicht kritisch",
    "warning": "\u26a0\ufe0f KI-Warnung — Entwicklungs-KI wird hier wahrscheinlich Text statt Bild generieren",
    "placeholder": "\U0001f534 Platzhalter — Debug-/Platzhalter-Element das in Production nicht bleiben darf",
}

# Performance constraints for animations
ANIMATION_CONSTRAINTS = {
    "lottie_max_kb": 500,
    "max_particles": 50,
    "no_video_on_interactive": True,
    "static_fallback_required": True,
}

# Accessibility targets
ACCESSIBILITY_TARGETS = {
    "contrast_ratio_text": 4.5,      # WCAG AA for normal text
    "contrast_ratio_large": 3.0,     # WCAG AA for large text/UI
    "touch_target_ios_pt": 44,       # Minimum touch target iOS
    "touch_target_android_dp": 48,   # Minimum touch target Android
    "reduced_motion_required": True,  # Must have static fallback
}
