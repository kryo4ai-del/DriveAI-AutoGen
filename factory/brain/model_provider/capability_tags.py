"""Capability Tags — standardized tags for agent-model matching.

Tags describe WHAT a model or agent needs — not HOW GOOD it is (that's the tier).
Used in:
  - agent_registry.json → capabilities_required (max 3 per agent)
  - models_registry.json → strengths (per model)

100% deterministic. No LLM, no API calls.
"""

# ── Code Language Tags ─────────────────────────────────────────────
SWIFT_CODE = "swift_code"
KOTLIN_CODE = "kotlin_code"
TYPESCRIPT_CODE = "typescript_code"
PYTHON_CODE = "python_code"
CSHARP_CODE = "csharp_code"

# ── Task Capability Tags ──────────────────────────────────────────
CODE_GENERATION = "code_generation"
ARCHITECTURE = "architecture"
CODE_REVIEW = "code_review"
PLANNING = "planning"
REASONING = "reasoning"
CONTENT_CREATION = "content_creation"
RESEARCH = "research"
CLASSIFICATION = "classification"
SUMMARIZATION = "summarization"
EXTRACTION = "extraction"

# ── Technical Capability Tags ─────────────────────────────────────
LARGE_CONTEXT = "large_context"
QUALITY_ASSURANCE = "quality_assurance"

# ── All Valid Tags (for validation) ───────────────────────────────
ALL_TAGS: frozenset[str] = frozenset({
    SWIFT_CODE, KOTLIN_CODE, TYPESCRIPT_CODE, PYTHON_CODE, CSHARP_CODE,
    CODE_GENERATION, ARCHITECTURE, CODE_REVIEW, PLANNING, REASONING,
    CONTENT_CREATION, RESEARCH, CLASSIFICATION, SUMMARIZATION,
    EXTRACTION, LARGE_CONTEXT, QUALITY_ASSURANCE,
})

# ── Known Model Strengths (static fallback) ──────────────────────
# Mirrors models_registry.json strengths. Used when registry unavailable.
MODEL_STRENGTHS: dict[str, list[str]] = {
    # Anthropic
    "claude-opus-4-6": [
        REASONING, ARCHITECTURE, PLANNING, CODE_REVIEW,
        QUALITY_ASSURANCE, CODE_GENERATION, SWIFT_CODE,
    ],
    "claude-sonnet-4-6": [
        CODE_GENERATION, ARCHITECTURE, CODE_REVIEW, SWIFT_CODE,
        KOTLIN_CODE, TYPESCRIPT_CODE, REASONING, CONTENT_CREATION,
        PLANNING,
    ],
    "claude-haiku-4-5": [
        CLASSIFICATION, SUMMARIZATION, EXTRACTION, RESEARCH,
    ],
    # OpenAI
    "gpt-4o": [
        CODE_GENERATION, CODE_REVIEW, TYPESCRIPT_CODE, PYTHON_CODE,
        REASONING,
    ],
    "gpt-4o-mini": [
        CLASSIFICATION, EXTRACTION,
    ],
    "o3-mini": [
        REASONING, CODE_REVIEW, PLANNING,
    ],
    # Google
    "gemini-2.5-flash": [
        LARGE_CONTEXT, EXTRACTION, SUMMARIZATION, CLASSIFICATION,
    ],
    "gemini-2.5-pro": [
        CODE_GENERATION, LARGE_CONTEXT, REASONING, TYPESCRIPT_CODE,
    ],
    # Mistral
    "mistral-small-latest": [
        CLASSIFICATION, EXTRACTION,
    ],
    "mistral-large-latest": [
        REASONING, CODE_GENERATION, PLANNING,
    ],
}


def validate_tags(tags: list[str]) -> list[str]:
    """Return list of invalid tags. Empty list = all valid."""
    return [t for t in tags if t not in ALL_TAGS]
