"""Kapitel 4.5 Design Vision & UX Innovation — Configuration"""

AGENT_MODEL_MAP = {
    "trend_breaker": "claude-sonnet-4-6",
    "emotion_architect": "claude-sonnet-4-6",
    "vision_compiler": "claude-sonnet-4-6",
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
