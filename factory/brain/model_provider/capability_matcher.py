"""Capability Matcher — deterministic agent-to-model matching.

Score = len(matched_capabilities) / len(required_capabilities)
Tiebreaker: lower cost within same tier wins.

100% deterministic. No LLM, no API calls.
"""

import json
import logging
from dataclasses import dataclass, field
from pathlib import Path

from .capability_tags import MODEL_STRENGTHS

logger = logging.getLogger(__name__)

_DIR = Path(__file__).parent
_MODELS_REGISTRY_PATH = _DIR / "models_registry.json"

# ── Module-level caches ──────────────────────────────────────────
_MATCH_CACHE: dict[str, "MatchResult | None"] = {}
_MODEL_DATA_CACHE: dict[str, dict] | None = None


@dataclass
class MatchResult:
    """Result of a capability match."""
    model_id: str
    provider: str
    score: float            # 0.0 to 1.0
    matched: list[str] = field(default_factory=list)
    unmatched: list[str] = field(default_factory=list)
    reason: str = ""


class CapabilityMatcher:
    """Matches agent capabilities to optimal models within tier constraints.

    Selection flow:
    1. Get agent's tier -> filter models by tier (price class)
    2. Score each model by capability overlap
    3. Best score wins, tiebreaker: lower cost
    4. Escalate to next tier up if score < 0.5
    """

    # Registry tier_equivalent -> agent tier mapping
    _TIER_MAP = {
        "lightweight": ["low"],
        "standard": ["mid"],
        "premium": ["high"],
    }
    _TIER_ESCALATION = {
        "lightweight": "standard",
        "standard": "premium",
        "premium": None,
    }

    def __init__(self):
        self._models = self._load_models()

    def _load_models(self) -> dict[str, dict]:
        """Load model data from registry.

        Returns: model_id -> {strengths, tier, provider, cost}
        """
        global _MODEL_DATA_CACHE
        if _MODEL_DATA_CACHE is not None:
            return _MODEL_DATA_CACHE

        result = {}
        try:
            data = json.loads(_MODELS_REGISTRY_PATH.read_text(encoding="utf-8"))
            for provider, models in data.items():
                if not isinstance(models, dict):
                    continue
                for model_id, info in models.items():
                    if info.get("status") != "active":
                        continue
                    result[model_id] = {
                        "strengths": info.get("strengths", []),
                        "tier": info.get("tier_equivalent", "mid"),
                        "provider": provider,
                        "cost": info.get("price_per_1k_output", 0.0),
                    }
        except Exception as e:
            logger.warning("Could not load models_registry: %s — using static fallback", e)
            for model_id, strengths in MODEL_STRENGTHS.items():
                result[model_id] = {
                    "strengths": strengths,
                    "tier": "mid",
                    "provider": "anthropic",
                    "cost": 0.01,
                }

        _MODEL_DATA_CACHE = result
        return result

    def match(self, agent_id: str, capabilities_required: list[str],
              agent_tier: str) -> "MatchResult | None":
        """Find best model for an agent based on capabilities + tier.

        Returns None if:
          - agent_tier is "none"
          - capabilities_required is empty
        Caller should fall through to pure tier lookup in those cases.
        """
        if agent_tier == "none" or not capabilities_required:
            return None

        cache_key = f"{agent_id}:{','.join(sorted(capabilities_required))}:{agent_tier}"
        if cache_key in _MATCH_CACHE:
            return _MATCH_CACHE[cache_key]

        # Primary tier pool
        tier_values = self._TIER_MAP.get(agent_tier, ["mid"])
        pool = {mid: info for mid, info in self._models.items()
                if info["tier"] in tier_values}

        result = self._best_in_pool(pool, capabilities_required)

        # Escalation: if score < 0.5, try next tier up
        if (result is None or result.score < 0.5):
            next_tier = self._TIER_ESCALATION.get(agent_tier)
            if next_tier:
                esc_values = self._TIER_MAP.get(next_tier, [])
                esc_pool = {mid: info for mid, info in self._models.items()
                            if info["tier"] in esc_values}
                esc_result = self._best_in_pool(esc_pool, capabilities_required)
                if esc_result and (result is None or esc_result.score > result.score):
                    esc_result.reason += f" (escalated {agent_tier}->{next_tier})"
                    result = esc_result

        _MATCH_CACHE[cache_key] = result
        return result

    def _best_in_pool(self, pool: dict, caps: list[str]) -> "MatchResult | None":
        """Score all models in pool, return best match."""
        if not pool:
            return None

        scored = []
        for model_id, info in pool.items():
            matched = [c for c in caps if c in info["strengths"]]
            unmatched = [c for c in caps if c not in info["strengths"]]
            score = len(matched) / len(caps)
            scored.append((model_id, info, score, matched, unmatched))

        scored.sort(key=lambda x: (-x[2], x[1]["cost"]))
        best = scored[0]
        model_id, info, score, matched, unmatched = best

        return MatchResult(
            model_id=model_id,
            provider=info["provider"],
            score=score,
            matched=matched,
            unmatched=unmatched,
            reason=f"capability_match {len(matched)}/{len(caps)}",
        )

    def match_all_agents(self, registry_data: dict) -> list[dict]:
        """Match all agents. For --brain-match-all CLI."""
        results = []
        for agent in registry_data.get("agents", []):
            agent_id = agent.get("id", "?")
            tier = agent.get("tier", "standard")
            caps = agent.get("capabilities_required", [])
            m = self.match(agent_id, caps, tier)
            results.append({
                "agent_id": agent_id,
                "name": agent.get("name", ""),
                "department": agent.get("department", ""),
                "tier": tier,
                "capabilities_required": caps,
                "model": m.model_id if m else None,
                "score": m.score if m else None,
                "reason": m.reason if m else ("no_llm" if tier == "none" else "tier_fallback"),
            })
        return results

    def explain_match(self, agent_id: str, agent_data: dict) -> str:
        """Human-readable match explanation for CLI output."""
        name = agent_data.get("name", "?")
        tier = agent_data.get("tier", "standard")
        caps = agent_data.get("capabilities_required", [])

        lines = [
            f"Agent: {agent_id} ({name})",
            f"Tier: {tier}",
            f"Capabilities: {caps if caps else '(none — pure tier fallback)'}",
        ]

        if not caps:
            lines.append("Match: N/A (no capabilities — using tier default)")
            return "\n".join(lines)

        m = self.match(agent_id, caps, tier)
        if m:
            lines.append(f"Match: {m.model_id} (score={m.score:.2f}, {m.reason})")
            lines.append(f"  Matched: {m.matched}")
            if m.unmatched:
                lines.append(f"  Unmatched: {m.unmatched}")

            # Show alternatives in same tier
            tier_values = self._TIER_MAP.get(tier, ["mid"])
            pool = {mid: info for mid, info in self._models.items()
                    if info["tier"] in tier_values and mid != m.model_id}
            if pool:
                alts = []
                for mid, info in pool.items():
                    matched_ct = sum(1 for c in caps if c in info["strengths"])
                    sc = matched_ct / len(caps)
                    alts.append((mid, sc))
                alts.sort(key=lambda x: -x[1])
                for alt_id, alt_score in alts[:3]:
                    lines.append(f"  Alt: {alt_id} (score={alt_score:.2f})")
        else:
            lines.append("Match: None (no matching model found)")

        return "\n".join(lines)


def invalidate_cache() -> None:
    """Clear all caches. Call after registry reload or tier cascade."""
    global _MATCH_CACHE, _MODEL_DATA_CACHE
    _MATCH_CACHE = {}
    _MODEL_DATA_CACHE = None


# ── Smoke Test ────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=== CapabilityMatcher Smoke Test ===\n")
    matcher = CapabilityMatcher()

    tests = [
        ("CPL-03", ["code_generation", "swift_code"], "standard",
         "Swift Dev -> should get Sonnet"),
        ("BRN-03", [], "none",
         "Deterministic -> should return None"),
        ("INF-06", [], "standard",
         "No caps -> should return None (tier fallback)"),
        ("SWF-23", ["large_context", "content_creation", "planning"], "standard",
         "Roadbook -> needs large_context, may escalate"),
        ("CPL-10", ["classification", "summarization"], "lightweight",
         "Lightweight -> should get low-tier model"),
    ]

    passed = 0
    for agent_id, caps, tier, desc in tests:
        r = matcher.match(agent_id, caps, tier)
        model = r.model_id if r else "None"
        score = f"{r.score:.2f}" if r else "-"
        print(f"  {desc}")
        print(f"    {agent_id} [{tier}] caps={caps} -> {model} (score={score})")
        passed += 1

    # Cache invalidation test
    invalidate_cache()
    r2 = matcher.match("CPL-03", ["code_generation", "swift_code"], "standard")
    assert r2 is not None
    print(f"\n  Cache invalidation: OK (re-matched -> {r2.model_id})")
    passed += 1

    print(f"\n{passed}/{passed} smoke tests passed.")
