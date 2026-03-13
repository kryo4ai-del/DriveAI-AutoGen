# knowledge_reader.py
# Reads factory knowledge entries and formats compact context blocks for agent passes.
# Also provides shared CD rating parser used by gate logic and proposal generator.

import json
import os
import re

_KNOWLEDGE_PATH = os.path.join(os.path.dirname(__file__), "knowledge.json")

# Entry types relevant for product/UX review (Creative Director).
# technical_pattern is excluded — CD reviews product quality, not pipeline mechanics.
_CD_RELEVANT_TYPES = frozenset({
    "ux_insight",
    "design_insight",
    "motivational_mechanic",
    "failure_case",
    "success_pattern",
})

# Maximum entries injected into a single pass prompt.
MAX_ENTRIES_PER_INJECTION = 5

# Confidence ranking for sort priority (higher = more trusted).
_CONFIDENCE_RANK = {
    "proven": 3,
    "validated": 2,
    "hypothesis": 1,
    "disproven": 0,
}


def load_entries() -> list[dict]:
    """Load all entries from knowledge.json. Returns empty list on error."""
    try:
        with open(_KNOWLEDGE_PATH, encoding="utf-8") as f:
            data = json.load(f)
        return data.get("entries", [])
    except (FileNotFoundError, json.JSONDecodeError):
        return []


def select_for_creative_director(template: str | None = None) -> list[dict]:
    """Select knowledge entries relevant for the Creative Director pass.

    Selection logic (deterministic, no LLM):
    1. Filter by CD-relevant types (exclude technical_pattern)
    2. Exclude disproven entries (they are warnings, not guidance)
    3. Sort by confidence (proven > validated > hypothesis)
    4. Cap at MAX_ENTRIES_PER_INJECTION
    """
    entries = load_entries()

    # Filter: CD-relevant types only, exclude pipeline-specific entries
    relevant = [
        e for e in entries
        if e.get("type") in _CD_RELEVANT_TYPES
        and e.get("product_type") != "ai_pipeline"
    ]

    # Exclude disproven (kept in store as warnings, not injected as guidance)
    relevant = [e for e in relevant if e.get("confidence") != "disproven"]

    # Sort: higher confidence first, then by ID for stability
    relevant.sort(
        key=lambda e: (-_CONFIDENCE_RANK.get(e.get("confidence", ""), 0), e.get("id", ""))
    )

    return relevant[:MAX_ENTRIES_PER_INJECTION]


def format_for_prompt(entries: list[dict]) -> str:
    """Format selected entries as a compact context block for prompt injection.

    Returns empty string if no entries. Format:

    [Factory Knowledge — Prior Learnings]
    - [FK-001] Title. Lesson or description.
    - [FK-002] ...
    Apply these learnings when reviewing the implementation.
    """
    if not entries:
        return ""

    lines = ["[Factory Knowledge — Prior Learnings]"]

    for entry in entries:
        entry_id = entry.get("id", "?")
        title = entry.get("title", "")
        # Use lesson if available (more actionable), otherwise description
        detail = entry.get("lesson") or entry.get("effect") or entry.get("description", "")
        # Truncate detail to keep compact
        if len(detail) > 150:
            detail = detail[:147] + "..."
        lines.append(f"- [{entry_id}] {title}. {detail}")

    lines.append("Apply these learnings when reviewing the implementation.")

    return "\n".join(lines)


def get_cd_knowledge_block(template: str | None = None) -> str:
    """One-call convenience: select + format for Creative Director.

    Returns empty string if no relevant knowledge exists.
    """
    entries = select_for_creative_director(template)
    return format_for_prompt(entries)


# ── CD Rating Parser (shared by gate logic and proposal generator) ────────

# Robust regex that handles all observed CD rating format variations:
# - **Rating: conditional_pass**
# - Rating: **conditional_pass**
# - ## Rating: **conditional_pass**
# - **Rating:** `conditional_pass`
# - **Overall Rating: FAIL**
_CD_RATING_RE = re.compile(
    r"(?:#+\s+)?"                       # optional ## prefix
    r"\*?\*?(?:Overall\s+)?Rating\*?\*?"  # "Rating" with optional bold/Overall
    r"[:\s]*\*?\*?"                      # colon, spaces, optional bold
    r"[`\s]*"                            # optional backtick
    r"(pass|conditional_pass|fail)"      # the actual rating value
    r"[`\s]*\*?\*?",                     # trailing formatting
    re.IGNORECASE,
)


def extract_cd_rating(messages: list) -> str | None:
    """Extract the Creative Director rating from message objects.

    First scans messages from the 'creative_director' agent, then falls back to
    scanning all non-user messages (in case the SelectorGroupChat picked a
    different speaker for the CD review task).

    Returns 'pass', 'conditional_pass', or 'fail'. Returns None if no rating found.

    Designed to be fail-open: if rating cannot be parsed, returns None,
    and callers should treat None as 'pass' (continue pipeline).
    """
    # Pass 1: prefer messages from the actual CD agent
    for msg in messages:
        source = getattr(msg, "source", "")
        content = getattr(msg, "content", "")
        if source != "creative_director" or not isinstance(content, str):
            continue
        match = _CD_RATING_RE.search(content)
        if match:
            return match.group(1).lower()

    # Pass 2: fallback — scan all non-user messages (selector may pick wrong speaker)
    for msg in messages:
        source = getattr(msg, "source", "")
        content = getattr(msg, "content", "")
        if source == "user" or not isinstance(content, str):
            continue
        match = _CD_RATING_RE.search(content)
        if match:
            return match.group(1).lower()

    return None
