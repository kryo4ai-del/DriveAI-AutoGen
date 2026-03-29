# model_router.py
# ModelRouter — intelligent model selection based on task type.
# Provider: Anthropic (Claude) + Ollama (local).
# Supports tier_lock: minimum tier guarantee per agent.

import json
import logging
import os

logger = logging.getLogger(__name__)

_DIR = os.path.dirname(__file__)
_ROUTING_PATH = os.path.join(_DIR, "model_routing.json")

# Default routing rules — used if model_routing.json doesn't exist
_DEFAULT_ROUTES = {
    # Tier 1 — Claude Sonnet: Code-critical tasks (architecture, generation, review)
    "code_generation": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires advanced reasoning"},
    "architecture": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires deep reasoning"},
    "code_review": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires code understanding"},
    "bug_hunting": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires code analysis"},
    "refactoring": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires code understanding"},
    "test_generation": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires code understanding"},
    # Tier 2 — Claude Sonnet: Planning & creative tasks
    "planning": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires reasoning"},
    "orchestration": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires multi-step planning"},
    "content_generation": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires creativity"},
    "compliance_review": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires legal reasoning"},
    "accessibility_review": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires UI understanding"},
    "creative_direction": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires product and design reasoning"},
    "ux_psychology_review": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires behavioral science reasoning"},
    # Tier 3 — Claude Haiku: Lightweight tasks (fast & cheap)
    "classification": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "lightweight task"},
    "summarization": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "lightweight task"},
    "trend_analysis": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "pattern matching"},
    "scoring": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "numerical evaluation"},
    "labeling": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "simple classification"},
    "extraction": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "structured extraction"},
    "briefing": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "summarization task"},
}

# ── Tier Lock System ─────────────────────────────────────────────
# Numeric tier levels: higher = more capable. tier_lock enforces minimum.
_TIER_LEVEL = {
    "dev": 0, "low": 0,
    "standard": 1, "mid": 1,
    "premium": 2, "high": 2,
}

# Model → tier level (single source of truth, mirrors models_registry.json tier_equivalent)
_MODEL_TIER = {
    "claude-haiku-4-5": 0,
    "gpt-4o-mini": 0,
    "gemini-2.5-flash": 0,
    "mistral-small-latest": 0,
    "claude-sonnet-4-6": 1,
    "gpt-4o": 1,
    "o3-mini": 1,
    "gemini-2.5-pro": 1,
    "claude-opus-4-6": 2,
}

# Default upgrade targets when tier_lock forces an upgrade (Anthropic preferred)
_TIER_UPGRADE_MODEL = {
    1: {"model": "claude-sonnet-4-6", "provider": "anthropic"},  # standard
    2: {"model": "claude-opus-4-6", "provider": "anthropic"},    # premium
}

# ── Tier Config Override (Cascade Support) ─────────────────────
# If tier_config.json exists, it overrides the hardcoded dicts above.
# Written by ModelEvolution._execute_cascade(), read on import.
_TIER_CONFIG_PATH = os.path.join(_DIR, "tier_config.json")


def _load_tier_config():
    """Load tier_config.json and override hardcoded dicts. No-op if file doesn't exist."""
    global _TIER_DEFAULT_MODEL, _MODEL_TIER, _TIER_UPGRADE_MODEL
    try:
        with open(_TIER_CONFIG_PATH, encoding="utf-8") as f:
            cfg = json.load(f)
        if "tier_default_model" in cfg:
            _TIER_DEFAULT_MODEL.update(cfg["tier_default_model"])
        if "model_tier" in cfg:
            _MODEL_TIER.update({k: int(v) for k, v in cfg["model_tier"].items()})
        if "tier_upgrade_model" in cfg:
            for k, v in cfg["tier_upgrade_model"].items():
                _TIER_UPGRADE_MODEL[int(k)] = v
        logger.info("Loaded tier_config.json (cascade overrides active)")
    except FileNotFoundError:
        pass  # No cascade override — use hardcoded defaults
    except Exception as e:
        logger.warning("Failed to load tier_config.json: %s", e)


def save_tier_config(config: dict) -> None:
    """Save cascade tier config to JSON (called by ModelEvolution)."""
    os.makedirs(os.path.dirname(os.path.abspath(_TIER_CONFIG_PATH)), exist_ok=True)
    with open(_TIER_CONFIG_PATH, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    _load_tier_config()  # Reload immediately


def reload_tier_config() -> None:
    """Force reload tier_config.json (cache invalidation after cascade)."""
    _load_tier_config()


# Known providers and their cost characteristics
PROVIDERS = {
    "ollama": {"cost_per_1k_input": 0.0, "cost_per_1k_output": 0.0, "local": True},
    "anthropic": {"cost_per_1k_input": 0.003, "cost_per_1k_output": 0.015, "local": False},
}

# Per-model cost overrides (Anthropic pricing)
MODEL_COSTS = {
    "claude-opus-4-6": {"cost_per_1k_input": 0.015, "cost_per_1k_output": 0.075},
    "claude-sonnet-4-6": {"cost_per_1k_input": 0.003, "cost_per_1k_output": 0.015},
    "claude-haiku-4-5": {"cost_per_1k_input": 0.0008, "cost_per_1k_output": 0.004},
    # Local models — zero cost
    "ollama/mistral": {"cost_per_1k_input": 0.0, "cost_per_1k_output": 0.0},
    "ollama/llama3": {"cost_per_1k_input": 0.0, "cost_per_1k_output": 0.0},
}

# Agent → default task type mapping
AGENT_TASK_MAP = {
    "driveai_lead": "planning",
    "ios_architect": "architecture",
    "swift_developer": "code_generation",
    "reviewer": "code_review",
    "bug_hunter": "bug_hunting",
    "refactor_agent": "refactoring",
    "test_generator": "test_generation",
    "product_strategist": "classification",
    "roadmap_agent": "planning",
    "content_script_agent": "content_generation",
    "change_watch_agent": "trend_analysis",
    "accessibility_agent": "accessibility_review",
    "opportunity_agent": "trend_analysis",
    "legal_risk_agent": "compliance_review",
    "project_bootstrap_agent": "planning",
    "android_architect": "architecture",
    "kotlin_developer": "code_generation",
    "web_architect": "architecture",
    "webapp_developer": "code_generation",
    "autonomous_project_orchestrator": "orchestration",
    "creative_director": "creative_direction",
    "ux_psychology": "ux_psychology_review",
}


def _load_routes() -> dict:
    """Load custom routing rules from JSON, fall back to defaults."""
    try:
        with open(_ROUTING_PATH, encoding="utf-8") as f:
            data = json.load(f)
        return data.get("routes", _DEFAULT_ROUTES)
    except (FileNotFoundError, json.JSONDecodeError):
        return _DEFAULT_ROUTES


def save_routes(routes: dict) -> None:
    """Save routing rules to JSON for persistence."""
    os.makedirs(os.path.dirname(os.path.abspath(_ROUTING_PATH)), exist_ok=True)
    with open(_ROUTING_PATH, "w", encoding="utf-8") as f:
        json.dump({"routes": routes}, f, indent=2, ensure_ascii=False)


class ModelRouter:
    """Selects the optimal model for a given task type or agent."""

    def __init__(self):
        self.routes = _load_routes()

    def reload(self) -> None:
        self.routes = _load_routes()

    def route(self, task_type: str, tier_lock: str = None) -> dict:
        """
        Get routing decision for a task type.
        Returns: {"model": str, "provider": str, "reason": str}

        If tier_lock is set, the returned model will be at least the requested tier.
        tier_lock values: "dev", "standard", "premium" (or None for no lock).
        """
        if task_type in self.routes:
            result = dict(self.routes[task_type])
        else:
            result = {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "unknown task type — fallback"}

        if tier_lock:
            result = self._enforce_tier_lock(result, tier_lock)

        return result

    def route_for_agent(self, agent_name: str, task_type_override: str = "", tier_lock: str = None) -> dict:
        """
        Get routing decision for a specific agent.
        task_type_override takes precedence over the agent's default task mapping.
        tier_lock enforces a minimum model tier (dev/standard/premium).
        """
        task_type = task_type_override or AGENT_TASK_MAP.get(agent_name, "planning")
        return self.route(task_type, tier_lock=tier_lock)

    def get_model(self, task_type: str, tier_lock: str = None) -> str:
        """Shorthand: get just the model name for a task type."""
        return self.route(task_type, tier_lock=tier_lock)["model"]

    def get_model_for_agent(self, agent_name: str, task_type_override: str = "", tier_lock: str = None) -> str:
        """Shorthand: get just the model name for an agent."""
        return self.route_for_agent(agent_name, task_type_override, tier_lock=tier_lock)["model"]

    def _enforce_tier_lock(self, route_result: dict, tier_lock: str) -> dict:
        """Enforce minimum tier. Upgrades model if current tier is too low."""
        required_level = _TIER_LEVEL.get(tier_lock)
        if required_level is None:
            return route_result

        current_model = route_result.get("model", "")
        current_level = _MODEL_TIER.get(current_model, 1)

        if current_level >= required_level:
            return route_result

        # Upgrade needed
        upgrade = _TIER_UPGRADE_MODEL.get(required_level)
        if not upgrade:
            return route_result

        original_model = route_result["model"]
        route_result["model"] = upgrade["model"]
        route_result["provider"] = upgrade["provider"]
        route_result["reason"] = f"tier_lock={tier_lock} upgrade from {original_model}"
        logger.info("tier_lock=%s: %s -> %s", tier_lock, original_model, upgrade["model"])
        return route_result

    def is_local(self, task_type: str) -> bool:
        """Check if a task type routes to a local model."""
        r = self.route(task_type)
        provider_info = PROVIDERS.get(r["provider"], {})
        return provider_info.get("local", False)

    def estimate_cost(self, model: str, prompt_tokens: int, completion_tokens: int) -> float:
        """Estimate cost for a specific model and token usage."""
        costs = MODEL_COSTS.get(model)
        if not costs:
            # Unknown model — assume zero (could be local)
            return 0.0
        input_cost = (prompt_tokens / 1000) * costs["cost_per_1k_input"]
        output_cost = (completion_tokens / 1000) * costs["cost_per_1k_output"]
        return round(input_cost + output_cost, 6)

    def get_all_routes(self) -> dict:
        """Return all routing rules."""
        return dict(self.routes)

    def update_route(self, task_type: str, model: str, provider: str, reason: str = "") -> None:
        """Update or add a routing rule."""
        self.routes[task_type] = {
            "model": model,
            "provider": provider,
            "reason": reason or f"custom route for {task_type}",
        }
        save_routes(self.routes)

    def get_summary(self) -> str:
        """Summary of routing configuration."""
        local_tasks = [t for t, r in self.routes.items() if PROVIDERS.get(r.get("provider", ""), {}).get("local")]
        api_tasks = [t for t, r in self.routes.items() if not PROVIDERS.get(r.get("provider", ""), {}).get("local")]
        models_used = sorted({r["model"] for r in self.routes.values()})
        return (
            f"ModelRouter — {len(self.routes)} routes | "
            f"{len(local_tasks)} local, {len(api_tasks)} API | "
            f"Models: {', '.join(models_used)}"
        )


# ── Central Fallback Model Getter ────────────────────────────────
# For non-department files that need a model without agent context.

def get_fallback_model(profile: str = "standard") -> str:
    """Get the best available model for a profile.

    Resolution order: TheBrain → .env variable → hardcoded default.
    Use this in except blocks where TheBrain/ProviderRouter failed.
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
    if profile in ("premium",):
        return os.environ.get("ANTHROPIC_FALLBACK_MODEL_PREMIUM", "claude-opus-4-6")
    return os.environ.get("ANTHROPIC_FALLBACK_MODEL", "claude-sonnet-4-6")


# ── Agent-Based Model Selection ─────────────────────────────────
# THE ONLY WAY to get a model for an agent.
# Reads tier from agent_registry.json, resolves to current best model.

_REGISTRY_CACHE: dict | None = None
_REGISTRY_PATH = os.path.join(os.path.dirname(_DIR), "factory", "agent_registry.json")

# Tier → default model mapping (single source of truth)
_TIER_DEFAULT_MODEL = {
    "lightweight": "claude-haiku-4-5",
    "standard": "claude-sonnet-4-6",
    "premium": "claude-opus-4-6",
    "none": None,
}

# Apply cascade overrides (if tier_config.json exists)
_load_tier_config()


def _load_registry() -> dict:
    """Load and cache agent_registry.json."""
    global _REGISTRY_CACHE
    if _REGISTRY_CACHE is not None:
        return _REGISTRY_CACHE
    try:
        with open(_REGISTRY_PATH, encoding="utf-8") as f:
            _REGISTRY_CACHE = json.load(f)
    except Exception:
        logger.warning("Could not load agent_registry.json from %s", _REGISTRY_PATH)
        _REGISTRY_CACHE = {"agents": []}
    return _REGISTRY_CACHE


def reload_registry() -> None:
    """Force reload of agent registry cache + capability matcher."""
    global _REGISTRY_CACHE, _CAPABILITY_MATCHER
    _REGISTRY_CACHE = None
    _CAPABILITY_MATCHER = None
    try:
        from factory.brain.model_provider.capability_matcher import invalidate_cache
        invalidate_cache()
    except ImportError:
        pass
    _load_registry()


# ── Capability Matching ──────────────────────────────────────────
_CAPABILITY_MATCHER = None


def _get_capability_matcher():
    """Lazy-init capability matcher singleton."""
    global _CAPABILITY_MATCHER
    if _CAPABILITY_MATCHER is None:
        from factory.brain.model_provider.capability_matcher import CapabilityMatcher
        _CAPABILITY_MATCHER = CapabilityMatcher()
    return _CAPABILITY_MATCHER


def get_model_for_agent(agent_id: str) -> str | None:
    """THE ONLY WAY to get a model for an agent.

    Flow:
    1. Read agent's tier and capabilities_required from registry
    2. tier=none → None (deterministic agent)
    3. If capabilities_required → CapabilityMatcher (best model within tier)
    4. Else → TheBrain dynamic resolution
    5. Fallback → tier default

    Returns None if tier is "none" (deterministic agent, no LLM).
    Returns standard model with WARNING if agent not found.
    """
    registry = _load_registry()
    agent = None
    for a in registry.get("agents", []):
        if a.get("id") == agent_id:
            agent = a
            break

    if agent is None:
        logger.warning("Agent '%s' not found in registry — using standard tier", agent_id)
        return _TIER_DEFAULT_MODEL["standard"]

    # Resolve tier: auto_tier (enriched) > model_tier (raw) > "standard"
    tier = agent.get("auto_tier")
    capabilities = agent.get("capabilities_required", [])

    if not tier or not capabilities:
        # Compute tier + capabilities on-the-fly via AgentClassifier
        try:
            from factory.brain.model_provider.agent_classifier import AgentClassifier
            _cr = AgentClassifier().classify_deterministic(agent)
            tier = tier or _cr.tier
            capabilities = capabilities or _cr.capabilities_required
        except Exception:
            # Manual fallback: normalize model_tier
            raw = agent.get("model_tier", "standard")
            _NORM = {"mid": "standard", "fast": "lightweight", "large_context": "standard"}
            tier = tier or _NORM.get(raw, raw)

    if tier == "none":
        return None

    # Capability-based matching (primary path)
    if capabilities:
        try:
            matcher = _get_capability_matcher()
            match = matcher.match(agent_id, capabilities, tier)
            if match and match.score > 0:
                return match.model_id
        except Exception as e:
            logger.warning("Capability match failed for '%s': %s", agent_id, e)

    # TheBrain dynamic resolution (fallback)
    profile_map = {"lightweight": "dev", "standard": "standard", "premium": "premium"}
    profile = profile_map.get(tier, "standard")
    try:
        from factory.brain.model_provider import get_model
        selection = get_model(profile=profile)
        if selection and selection.get("model"):
            return selection["model"]
    except Exception:
        pass

    # Tier default (last resort)
    return _TIER_DEFAULT_MODEL.get(tier, _TIER_DEFAULT_MODEL["standard"])


def validate_agent_tier(agent_data: dict) -> None:
    """Validate/auto-assign tier and capabilities for an agent.

    If tier is missing or invalid: auto-classifies instead of raising.
    If tier is valid but capabilities_required is empty: auto-fills capabilities.
    Existing valid tier + capabilities are NEVER overwritten.
    """
    valid_tiers = {"lightweight", "standard", "premium", "none"}
    tier = agent_data.get("tier")

    if not tier or tier not in valid_tiers:
        # Auto-classify instead of raising ValueError
        from factory.brain.model_provider.agent_classifier import AgentClassifier
        classifier = AgentClassifier()
        result = classifier.classify_deterministic(agent_data)
        agent_data["tier"] = result.tier
        if not agent_data.get("capabilities_required"):
            agent_data["capabilities_required"] = result.capabilities_required
        logger.info("Auto-classified '%s' as tier=%s, caps=%s (%s)",
                    agent_data.get("id", "?"), result.tier,
                    result.capabilities_required, result.confidence)
        return

    # Tier valid — check capabilities
    if not agent_data.get("capabilities_required"):
        from factory.brain.model_provider.agent_classifier import AgentClassifier
        classifier = AgentClassifier()
        result = classifier.classify_deterministic(agent_data)
        agent_data["capabilities_required"] = result.capabilities_required
        logger.info("Auto-filled capabilities for '%s': %s",
                    agent_data.get("id", "?"), result.capabilities_required)
