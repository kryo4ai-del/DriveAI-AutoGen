"""Phase 1 Pre-Production Pipeline — Configuration

Reuses existing DriveAI LLM infrastructure.
Defines agent-to-model mapping and pipeline settings.
"""

# Agent LLM Tier Assignments
# Tier 2 (Reasoning/Sonnet) for research + analysis agents
# Tier 3 (Lightweight/Haiku) for memory agent
AGENT_MODEL_MAP = {
    "trend_scout": "claude-sonnet-4-6",
    "competitor_scan": "claude-sonnet-4-6",
    "audience_analyst": "claude-sonnet-4-6",
    "concept_analyst": "claude-sonnet-4-6",
    "legal_research": "claude-sonnet-4-6",
    "risk_assessment": "claude-sonnet-4-6",
    "memory_agent": "claude-haiku-4-5",
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
