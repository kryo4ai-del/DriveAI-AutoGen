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

# ---------------------------------------------------------------------------
# Role-based knowledge profiles
# ---------------------------------------------------------------------------
# Each role gets a different subset of knowledge types and a tailored CTA.
# Entries per role are capped independently for token discipline.

_ROLE_PROFILES: dict[str, dict] = {
    "creative_director": {
        "types": _CD_RELEVANT_TYPES,
        "exclude_product_types": {"ai_pipeline"},
        "max_entries": 5,
        "cta": "Apply these learnings when reviewing the implementation.",
    },
    "bug_hunter": {
        "types": frozenset({"error_pattern", "failure_case", "technical_pattern"}),
        "exclude_product_types": set(),
        "max_entries": 4,
        "cta": "Watch for these known patterns when hunting bugs.",
    },
    "refactor_agent": {
        "types": frozenset({"error_pattern", "technical_pattern", "failure_case", "success_pattern"}),
        "exclude_product_types": set(),
        "max_entries": 4,
        "cta": "Consider these known patterns when refactoring.",
    },
    "fix_executor": {
        "types": frozenset({"error_pattern", "failure_case", "technical_pattern", "success_pattern"}),
        "exclude_product_types": set(),
        "max_entries": 5,
        "cta": "Apply these known patterns when fixing the code.",
    },
    "reviewer": {
        "types": frozenset({"error_pattern", "failure_case", "technical_pattern"}),
        "exclude_product_types": set(),
        "max_entries": 3,
        "cta": "Check for these known patterns during review.",
    },
}

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


# ---------------------------------------------------------------------------
# Generic role-based selection (used by all technical passes)
# ---------------------------------------------------------------------------

def select_for_role(role: str) -> list[dict]:
    """Select knowledge entries relevant for a given agent role.

    Uses _ROLE_PROFILES to determine which entry types and how many
    entries are appropriate for each role. Falls back to empty list
    for unknown roles (safe default — no injection).

    Selection logic (deterministic, no LLM):
    1. Filter by role-relevant types
    2. Exclude product types not relevant to role
    3. Exclude disproven entries
    4. Require minimum confidence: validated or higher for technical passes
    5. Sort by confidence (proven > validated > hypothesis)
    6. Cap at role-specific max_entries
    """
    profile = _ROLE_PROFILES.get(role)
    if not profile:
        return []

    entries = load_entries()

    relevant = [
        e for e in entries
        if e.get("type") in profile["types"]
        and e.get("product_type", "") not in profile["exclude_product_types"]
    ]

    # Exclude disproven
    relevant = [e for e in relevant if e.get("confidence") != "disproven"]

    # For technical passes: only inject validated+ knowledge (no hypotheses)
    # CD keeps hypotheses because it's an advisory pass that benefits from exploration
    if role != "creative_director":
        relevant = [
            e for e in relevant
            if _CONFIDENCE_RANK.get(e.get("confidence", ""), 0) >= 2  # validated+
        ]

    # Sort: higher confidence first, then by ID for stability
    relevant.sort(
        key=lambda e: (-_CONFIDENCE_RANK.get(e.get("confidence", ""), 0), e.get("id", ""))
    )

    return relevant[:profile["max_entries"]]


def format_for_role(role: str, entries: list[dict]) -> str:
    """Format selected entries with a role-appropriate header and CTA.

    Returns empty string if no entries.
    """
    if not entries:
        return ""

    profile = _ROLE_PROFILES.get(role, {})
    cta = profile.get("cta", "Apply these learnings.")

    lines = ["[Factory Knowledge -- Known Patterns]"]

    for entry in entries:
        entry_id = entry.get("id", "?")
        title = entry.get("title", "")
        confidence = entry.get("confidence", "?")
        detail = entry.get("lesson") or entry.get("effect") or entry.get("description", "")
        if len(detail) > 150:
            detail = detail[:147] + "..."
        lines.append(f"- [{entry_id}] ({confidence}) {title}. {detail}")

    lines.append(cta)
    return "\n".join(lines)


def get_knowledge_block(role: str) -> str:
    """One-call convenience: select + format for any role.

    Returns empty string if no relevant knowledge exists or role is unknown.
    """
    entries = select_for_role(role)
    return format_for_role(role, entries)


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
