"""Known Prices -- static fallback table for model tier classification.

Updated manually when major model releases are announced.
The evolution loop uses this when provider APIs don't expose pricing.
API-discovered prices always take priority over this table.

100% deterministisch, kein LLM, keine API-Calls beim Import.
"""

# Tier boundaries based on price_per_1k_output (USD)
TIER_BOUNDARIES = {
    "low":  (0.0,   0.005),   # $0 – $0.005/1k output tokens
    "mid":  (0.005, 0.05),    # $0.005 – $0.05/1k output tokens
    "high": (0.05,  999.0),   # $0.05+/1k output tokens
}

# Known model prices and capabilities.
# Keys: price per 1k tokens (in/out), tier, context window, max output tokens.
# Last updated: 2026-03-26
KNOWN_MODELS: dict[str, dict] = {
    # ── Anthropic ──────────────────────────────────────────────
    "claude-haiku-4-5":        {"in": 0.0008,  "out": 0.004,   "tier": "low",  "ctx": 200000,  "max_out": 8192},
    "claude-sonnet-4-6":       {"in": 0.003,   "out": 0.015,   "tier": "mid",  "ctx": 200000,  "max_out": 16384},
    "claude-opus-4-6":         {"in": 0.015,   "out": 0.075,   "tier": "high", "ctx": 200000,  "max_out": 32000},
    # ── OpenAI ─────────────────────────────────────────────────
    "gpt-4o-mini":             {"in": 0.00015, "out": 0.0006,  "tier": "low",  "ctx": 128000,  "max_out": 16384},
    "gpt-4o":                  {"in": 0.0025,  "out": 0.01,    "tier": "mid",  "ctx": 128000,  "max_out": 16384},
    "o3-mini":                 {"in": 0.0011,  "out": 0.0044,  "tier": "mid",  "ctx": 128000,  "max_out": 65536},
    "gpt-4.1":                 {"in": 0.002,   "out": 0.008,   "tier": "mid",  "ctx": 1048576, "max_out": 32768},
    "gpt-4.1-mini":            {"in": 0.0004,  "out": 0.0016,  "tier": "low",  "ctx": 1048576, "max_out": 32768},
    "gpt-4.1-nano":            {"in": 0.0001,  "out": 0.0004,  "tier": "low",  "ctx": 1048576, "max_out": 32768},
    "o4-mini":                 {"in": 0.0011,  "out": 0.0044,  "tier": "low",  "ctx": 200000,  "max_out": 100000},
    # ── Google ─────────────────────────────────────────────────
    "gemini-2.5-flash":        {"in": 0.00015, "out": 0.0006,  "tier": "low",  "ctx": 1048576, "max_out": 65536},
    "gemini-2.5-pro":          {"in": 0.00125, "out": 0.01,    "tier": "mid",  "ctx": 1048576, "max_out": 65536},
    "gemini-2.0-flash":        {"in": 0.0001,  "out": 0.0004,  "tier": "low",  "ctx": 1048576, "max_out": 8192},
    # ── Mistral ────────────────────────────────────────────────
    "mistral-small-latest":    {"in": 0.0001,  "out": 0.0003,  "tier": "low",  "ctx": 128000,  "max_out": 8192},
    "mistral-large-latest":    {"in": 0.002,   "out": 0.006,   "tier": "mid",  "ctx": 128000,  "max_out": 8192},
}

# Models to skip during discovery (non-chat models, internal, preview)
SKIP_PATTERNS = [
    # ── Non-chat model types ──
    "embedding", "embed", "tts", "whisper", "dall-e", "moderation",
    "text-embedding", "babbage", "davinci", "instruct",
    "transcribe", "transcription", "realtime", "audio",
    "image", "imagen", "sora",
    "aqa", "attribution",
    # ── Code-specialized / non-general ──
    "codex", "codestral", "devstral",
    # ── Vision-only ──
    "pixtral", "ocr",
    # ── Search-augmented (not standard chat) ──
    "search",
    # ── Experimental / preview / labs ──
    "-preview", "-exp", "labs-",
    # ── Speech models ──
    "voxtral",
    # ── Reasoning models (specialized, handled separately if needed) ──
    "magistral",
    # ── Small/niche Mistral variants ──
    "ministral", "leanstral", "nemo",
    "mistral-tiny", "open-mi",
    # ── Deprecated families ──
    "gpt-3.5", "gpt-4-",  # gpt-4- but NOT gpt-4o or gpt-4.1
    "o1-",                 # all o1 variants (superseded by o3/o4)
    # ── ChatGPT-specific / fine-tuned / internal ──
    "chatgpt-", "ft:", "ft-",
    "vibe-cli",
]

# Skip versioned duplicates (e.g., gpt-4o-2024-08-06 when gpt-4o is already known)
# Match: date suffix (-YYYY-MM-DD, -YYMM), snapshot suffix (-NNN), or alias suffix (-chat-latest)
import re
_VERSION_SUFFIX = re.compile(
    r"(-\d{4}-\d{2}-\d{2}"       # -2024-08-06
    r"|-\d{3,4}"                  # -001, -2411
    r"|-chat-latest"              # gpt-5-chat-latest → gpt-5
    r")$"
)

# Exact model IDs to always skip (deprecated/legacy that don't match patterns above)
SKIP_EXACT = {
    "gpt-4",       # old GPT-4 (not gpt-4o or gpt-4.1)
    "o1",          # old reasoning model (superseded by o3/o4)
}

# LiteLLM provider prefix mapping
LITELLM_PREFIX = {
    "anthropic": "anthropic/",
    "openai": "",
    "google": "gemini/",
    "mistral": "mistral/",
}


def classify_tier(price_per_1k_output: float) -> str:
    """Classify a model into low/mid/high based on output price."""
    for tier, (lo, hi) in TIER_BOUNDARIES.items():
        if lo <= price_per_1k_output < hi:
            return tier
    return "mid"


def lookup_model(model_id: str) -> dict | None:
    """Lookup model in known prices table.

    Tries exact match first, then prefix/substring match for versioned IDs
    like 'gpt-4o-2024-08-06'.
    """
    if model_id in KNOWN_MODELS:
        return KNOWN_MODELS[model_id]
    for known_id, info in KNOWN_MODELS.items():
        if model_id.startswith(known_id) or known_id in model_id:
            return info
    return None


def get_litellm_name(provider: str, model_id: str) -> str:
    """Build the LiteLLM model name for a provider/model combination."""
    prefix = LITELLM_PREFIX.get(provider, f"{provider}/")
    return f"{prefix}{model_id}"


def is_interesting_model(provider: str, model_id: str) -> bool:
    """Filter out non-chat models (embeddings, TTS, etc.)."""
    model_lower = model_id.lower()
    if model_lower in SKIP_EXACT:
        return False
    if any(p in model_lower for p in SKIP_PATTERNS):
        return False
    return True


def _get_base(model_id: str) -> str:
    """Strip version/snapshot suffix to get the base model name."""
    base = _VERSION_SUFFIX.sub("", model_id)
    if base.endswith("-latest"):
        base = base[:-7]
    return base


def is_versioned_duplicate(model_id: str, known_ids: set) -> bool:
    """Check if model_id is a date-versioned duplicate of a known model.

    E.g., 'gpt-4o-2024-08-06' is a duplicate of 'gpt-4o'.
    Also catches '-chat-latest', '-001', '-2411', '-latest' variants.
    Cross-checks bases so 'mistral-large-2512' is a dup of 'mistral-large-2411'.
    """
    my_base = _get_base(model_id)
    if my_base == model_id:
        return False  # no suffix stripped → not a versioned model

    # Direct match
    if my_base in known_ids:
        return True
    if f"{my_base}-latest" in known_ids:
        return True

    # Cross-check: any known_id has the same base?
    for kid in known_ids:
        if _get_base(kid) == my_base:
            return True

    return False
