"""Team Enrichment — enrich agent registry with classification + matching data.

Called by the dashboard server via execSync. Outputs JSON to stdout.
Deterministic only (no LLM calls). Safe for automated use.
"""

import json
import sys
from pathlib import Path

_DIR = Path(__file__).parent
_ROOT = _DIR.parent.parent.parent
sys.path.insert(0, str(_ROOT))

from factory.brain.model_provider.agent_classifier import AgentClassifier
from factory.brain.model_provider.capability_matcher import CapabilityMatcher

REGISTRY_PATH = _ROOT / "factory" / "agent_registry.json"


def enrich_all() -> dict:
    """Run classifier + matcher on all agents. Returns enriched data dict."""
    data = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    agents = data.get("agents", [])

    classifier = AgentClassifier()
    matcher = CapabilityMatcher()

    enriched = []
    stats = {
        "total": len(agents),
        "by_tier": {},
        "by_match_quality": {"perfect": 0, "good": 0, "partial": 0, "none": 0, "no_llm": 0},
        "by_provider_match": {},
    }

    for agent in agents:
        cr = classifier.classify_deterministic(agent)
        m = None
        if cr.tier != "none" and cr.capabilities_required:
            m = matcher.match(agent["id"], cr.capabilities_required, cr.tier)

        # Match quality bucket
        if cr.tier == "none":
            quality = "no_llm"
        elif m is None:
            quality = "none"
        elif m.score >= 1.0:
            quality = "perfect"
        elif m.score >= 0.67:
            quality = "good"
        else:
            quality = "partial"

        enrichment = {
            "auto_tier": cr.tier,
            "capabilities_required": cr.capabilities_required,
            "classification_confidence": cr.confidence,
            "classification_reasoning": cr.reasoning,
            "matched_model": m.model_id if m else None,
            "matched_provider": m.provider if m else None,
            "match_score": round(m.score, 2) if m else None,
            "match_reason": m.reason if m else ("no_llm" if cr.tier == "none" else "tier_fallback"),
            "matched_caps": m.matched if m else [],
            "unmatched_caps": m.unmatched if m else [],
            "match_quality": quality,
        }

        enriched.append({**agent, **enrichment})

        # Stats
        stats["by_tier"][cr.tier] = stats["by_tier"].get(cr.tier, 0) + 1
        stats["by_match_quality"][quality] += 1
        if m:
            stats["by_provider_match"][m.provider] = stats["by_provider_match"].get(m.provider, 0) + 1

    return {
        "agents": enriched,
        "summary": data.get("summary", {}),
        "enrichment_stats": stats,
    }


if __name__ == "__main__":
    result = enrich_all()
    json.dump(result, sys.stdout, ensure_ascii=False)
