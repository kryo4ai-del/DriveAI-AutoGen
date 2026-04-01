"""Name Gate Configuration — Weights, thresholds, agent identity."""

# Score weights (must sum to 100)
WEIGHTS = {
    "domain": 25,
    "app_store": 25,
    "trademark": 25,
    "brand_fit": 10,
    "social_media": 10,
    "aso": 5,
}

# Ampel thresholds
THRESHOLDS = {
    "green": 80,   # >= 80 = GRUEN
    "yellow": 50,  # >= 50 = GELB, < 50 = ROT
}

# Iteration limits
MAX_ITERATIONS = 3
MAX_ALTERNATIVES = 10

# Hard blocker triggers (force ROT regardless of score)
HARD_BLOCKER_TRIGGERS = [
    "trademark_conflict",       # DPMA or EUIPO match
    "both_stores_taken",        # Apple AND Google taken
    "all_major_domains_taken",  # .com AND .de AND .app taken
]

# Agent identity
AGENT_ID = "NGO-01"
AGENT_NAME = "Name Gate Orchestrator"
DEPARTMENT = "name_gate"
MODEL_TIER = "standard"
DEFAULT_MODEL = "claude-sonnet-4-20250514"
