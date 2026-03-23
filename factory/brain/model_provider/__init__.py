"""Model Provider — registry + multi-provider routing via LiteLLM."""
from .model_registry import ModelRegistry, ModelInfo
from .provider_router import ProviderRouter, ProviderResponse
from .auto_splitter import AutoSplitter, SplitStrategy
from .chain_optimizer import ChainOptimizer, ChainProfile

_registry = None
_router = None


def get_registry() -> ModelRegistry:
    global _registry
    if _registry is None:
        _registry = ModelRegistry()
    return _registry


def get_router() -> ProviderRouter:
    global _router
    if _router is None:
        _router = ProviderRouter(get_registry())
    return _router


def _get_quality_score(line: str, project_name: str) -> float:
    """Load quality priority score for a line from project config.
    Returns 0.5 (neutral) if unavailable — fail-open."""
    if not line or not project_name:
        return 0.5
    try:
        from factory.project_config import load_project_config
        pc = load_project_config(project_name)
        if line in pc.lines:
            return pc.lines[line].get_quality_score()
    except Exception:
        pass
    return 0.5


# Task types where quality priority applies (code-generating tasks)
_QUALITY_SENSITIVE_TASKS = frozenset({
    "code_generation", "architecture", "refactoring",
    "bug_hunting", "test_generation",
})


def get_model(
    agent_name: str = "",
    task_type: str = "code_generation",
    profile: str = "dev",
    expected_output_tokens: int = 4096,
    line: str = "",
    project_name: str = "",
) -> dict:
    """Central model selection — TheBrain decides.

    Phase A: Simple tier-based selection from registry.
    Phase B: Will use Chain Optimizer benchmarks.
    Phase C: Will use autonomous optimization.
    Quality Priority: Higher-quality models for high-priority lines.
    """
    registry = get_registry()

    # Load quality score (only for code-generating tasks)
    quality_score = 0.5
    if task_type in _QUALITY_SENSITIVE_TASKS:
        quality_score = _get_quality_score(line, project_name)

    # Phase B: Check Chain Optimizer profile first
    try:
        cp = ChainProfile.load_for(line, profile)
        if cp and agent_name in cp.chain:
            ac = cp.chain[agent_name]
            mi = registry.get_model(ac["model"])
            if quality_score != 0.5:
                print(f"  [TheBrain] Line: {line}, Quality Score: {quality_score}, Selected: {ac['model']} (chain profile)")
            return {
                "model": ac["model"],
                "provider": ac["provider"],
                "litellm_model_name": mi.litellm_model_name if mi else f"{ac['provider']}/{ac['model']}",
                "fallback_model": None,
                "fallback_provider": None,
                "source": f"chain_optimizer ({cp.confidence})",
                "quality_score": quality_score,
                "split_strategy": {"should_split": False, "call_count": 1,
                                   "alternative_model": None, "reason": "chain profile"},
            }
    except Exception:
        pass  # No chain profile — fall through to tier-based

    tier_map = {"dev": "low", "fast": "low", "standard": "mid", "premium": "high"}
    tier = tier_map.get(profile, "mid")

    candidates = [m for m in registry.get_models_by_tier(tier)
                  if m.max_output_tokens >= expected_output_tokens
                  and m.status == "active"]

    available = set(registry.get_available_providers())
    candidates = [m for m in candidates if m.provider in available]

    if not candidates:
        candidates = list(registry.get_available_models())

    if not candidates:
        return {
            "model": "claude-haiku-4-5",
            "provider": "anthropic",
            "litellm_model_name": "anthropic/claude-haiku-4-5",
            "fallback_model": None,
            "fallback_provider": None,
            "source": "hardcoded_fallback",
            "quality_score": quality_score,
        }

    # Quality-weighted sort: multiply price by (1.0 - quality_score)
    # High quality_score → cheap models appear more expensive → better model selected
    # Neutral (0.5) → factor is 0.5 for all → same relative order as pure cost sort
    candidates.sort(key=lambda m: m.price_per_1k_output * (1.0 - quality_score))
    selected = candidates[0]

    fallback = None
    for c in candidates[1:]:
        if c.provider != selected.provider:
            fallback = c
            break

    # Check if splitting may be needed
    splitter = AutoSplitter(registry)
    strategy = splitter.analyze(selected.model_id, selected.provider, expected_output_tokens)

    if quality_score != 0.5:
        final_model = strategy.alternative_model or selected.model_id
        print(f"  [TheBrain] Line: {line}, Quality Score: {quality_score}, Selected: {final_model}")

    result = {
        "model": strategy.alternative_model or selected.model_id,
        "provider": strategy.alternative_provider or selected.provider,
        "litellm_model_name": selected.litellm_model_name,
        "fallback_model": fallback.model_id if fallback else None,
        "fallback_provider": fallback.provider if fallback else None,
        "source": f"registry_tier_{tier}",
        "quality_score": quality_score,
        "split_strategy": {
            "should_split": strategy.should_split,
            "call_count": strategy.call_count,
            "alternative_model": strategy.alternative_model,
            "reason": strategy.reason,
        },
    }
    # Update litellm_model_name if model switched
    if strategy.alternative_model:
        alt_info = registry.get_model(strategy.alternative_model)
        if alt_info:
            result["litellm_model_name"] = alt_info.litellm_model_name
    return result
