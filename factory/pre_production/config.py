"""Phase 1 Pre-Production Pipeline — Configuration

Reuses existing DriveAI LLM infrastructure.
Defines agent-to-model mapping and pipeline settings.
"""

import os


def get_fallback_model(profile: str = "standard") -> str:
    """Dynamische Modellwahl: TheBrain -> .env -> hartcodierter Default.

    profile: "standard" (Sonnet-Klasse) oder "dev"/"lightweight" (Haiku-Klasse).
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


# Agent LLM Tier Assignments
# Tier 2 (Reasoning/Sonnet) for research + analysis agents
# Tier 3 (Lightweight/Haiku) for memory agent
AGENT_MODEL_MAP = {
    "trend_scout": get_fallback_model(),
    "competitor_scan": get_fallback_model(),
    "audience_analyst": get_fallback_model(),
    "concept_analyst": get_fallback_model(),
    "legal_research": get_fallback_model(),
    "risk_assessment": get_fallback_model(),
    "memory_agent": get_fallback_model("dev"),
}

# Pipeline flow definition
PIPELINE_FLOW = {
    "chapter_1_parallel": ["trend_scout", "competitor_scan", "audience_analyst"],
    "chapter_1_synthesis": ["concept_analyst"],
    "chapter_2_sequential": ["legal_research", "risk_assessment"],
    "memory": ["memory_agent"],
}

# Output directory for generated reports
OUTPUT_DIR = "factory/pre_production/output"
MEMORY_DIR = "factory/pre_production/memory"
RUNS_DIR = "factory/pre_production/memory/runs"

# Web research settings
SERPAPI_RESULTS_PER_QUERY = 5
MAX_QUERIES_PER_AGENT = 8
SEARCH_CACHE_ENABLED = True
