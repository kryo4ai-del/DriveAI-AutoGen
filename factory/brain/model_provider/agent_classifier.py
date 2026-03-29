"""Agent Classifier -- automatic tier + capability assignment.

Deterministic rule-based classification (no LLM, no API calls).
LLM fallback (Haiku) only for edge cases with low confidence.

100% offline-capable in deterministic mode.
"""

import json
import logging
from dataclasses import dataclass, field

from .capability_tags import ALL_TAGS

logger = logging.getLogger(__name__)


@dataclass
class ClassificationResult:
    """Result of auto-classifying an agent."""
    tier: str = "standard"
    capabilities_required: list[str] = field(default_factory=list)
    confidence: str = "low"       # "high", "medium", "low"
    reasoning: str = ""
    source: str = "deterministic"  # "deterministic" or "llm_fallback"


# ── task_type -> capability direct mapping ────────────────────────
TASK_TYPE_TO_CAPS: dict[str, list[str]] = {
    "code_generation": ["code_generation"],
    "architecture": ["architecture"],
    "code_review": ["code_review"],
    "bug_hunting": ["code_review", "reasoning"],
    "refactoring": ["code_generation", "code_review"],
    "test_generation": ["code_generation"],
    "planning": ["planning"],
    "orchestration": ["planning", "reasoning"],
    "content_generation": ["content_creation"],
    "research": ["research", "reasoning"],
    "classification": ["classification"],
    "summarization": ["summarization"],
    "routing": ["reasoning", "classification"],
    "detection": ["reasoning"],
    "analysis": ["reasoning", "extraction"],
    "extraction": ["extraction"],
    "processing": ["extraction"],
    "memory": [],
    "scoring": ["classification"],
    "labeling": ["classification", "extraction"],
    "trend_analysis": ["research"],
    "briefing": ["summarization"],
}

# ── Lightweight task types ────────────────────────────────────────
LIGHTWEIGHT_TASK_TYPES = frozenset({
    "classification", "summarization", "extraction", "scoring",
    "labeling", "trend_analysis", "briefing",
})

# ── Keyword -> capability tag mapping ─────────────────────────────
KEYWORD_TO_TAG: list[tuple[list[str], str]] = [
    # Code languages
    (["swift", "ios", "swiftui"], "swift_code"),
    (["kotlin", "android", "compose"], "kotlin_code"),
    (["typescript", "react", "web app", "frontend"], "typescript_code"),
    (["python", "backend"], "python_code"),
    (["unity", "c#", "csharp", "gamedev"], "csharp_code"),
    # Task types
    (["developer", "generator", "coder"], "code_generation"),
    (["architect", "architecture"], "architecture"),
    (["review", "bug", "audit"], "code_review"),
    (["plan", "roadmap", "orchestrat", "coordinat"], "planning"),
    (["reason", "strateg", "assess", "detect"], "reasoning"),
    (["creative", "brand", "content", "copy", "visual", "design", "marketing"],
     "content_creation"),
    (["research", "scout", "scan", "trend", "competitor"], "research"),
    (["classif", "categor", "label", "score", "triage"], "classification"),
    (["summar", "brief", "digest"], "summarization"),
    (["extract", "parse", "collect", "discover"], "extraction"),
    (["roadbook", "synthesis", "massive context"], "large_context"),
    (["qa ", "quality assurance", "quality_assurance", "verif"], "quality_assurance"),
]

# ── Keywords for tier=none detection ──────────────────────────────
NONE_KEYWORDS = frozenset({
    "assembly line", "bridge", "registry", "dispatcher",
    "health monitor", "auto-repair", "project registry",
})


class AgentClassifier:
    """Automatically classifies agents with tier + capabilities."""

    def classify(self, agent_entry: dict) -> ClassificationResult:
        """Classify an agent. Deterministic first, LLM fallback if needed."""
        result = self._classify_deterministic(agent_entry)
        if result.confidence != "low":
            return result

        # Try LLM fallback for low-confidence cases
        llm_result = self._classify_with_llm(agent_entry)
        if llm_result is not None:
            return llm_result

        return result  # Return low-confidence deterministic as last resort

    def classify_deterministic(self, agent_entry: dict) -> ClassificationResult:
        """Public access to deterministic-only classification."""
        return self._classify_deterministic(agent_entry)

    def _classify_deterministic(self, agent_entry: dict) -> ClassificationResult:
        """Rule-based classification. No API calls."""
        agent_id = agent_entry.get("id", "?")
        name = agent_entry.get("name", "").lower()
        role = agent_entry.get("role", "").lower()
        department = agent_entry.get("department", "").lower()
        task_type = agent_entry.get("task_type", "").lower()
        description = agent_entry.get("description", "").lower()
        model_tier = agent_entry.get("model_tier", "").lower()
        routing = agent_entry.get("routing", "").lower()

        # Searchable text blob
        text = f"{name} {role} {task_type} {description}"
        reasons = []

        # ── Step 1: Determine tier ────────────────────────────────
        tier = "standard"

        # Priority 1: tier=none detection
        if model_tier == "none" or "no_llm" in routing:
            tier = "none"
            reasons.append("routing=no_llm or model_tier=none")
        elif department in ("infrastruktur", "infrastructure"):
            # Infrastructure agents are none UNLESS they have LLM keywords
            llm_hints = any(kw in text for kw in [
                "assistant", "janitor", "analyz", "review", "generat",
            ])
            if not llm_hints:
                tier = "none"
                reasons.append("infrastructure without LLM hints")
        elif any(kw in name.lower() for kw in NONE_KEYWORDS):
            tier = "none"
            reasons.append(f"name matches none-keyword")

        # Priority 2: lightweight
        if tier == "standard":
            if task_type in LIGHTWEIGHT_TASK_TYPES:
                tier = "lightweight"
                reasons.append(f"task_type={task_type} is lightweight")
            elif any(kw in text for kw in [
                "scanner", "checker", "classifier", "scorer",
                "extractor", "labeler", "signing",
            ]):
                tier = "lightweight"
                reasons.append("lightweight keyword in text")

        # Priority 3: premium
        if tier == "standard":
            if "tier_lock=premium" in routing or model_tier == "premium":
                tier = "premium"
                reasons.append("tier_lock=premium or model_tier=premium")
            elif "hq assistant" in name:
                tier = "premium"
                reasons.append("HQ Assistant -> premium")

        if not reasons:
            reasons.append("default=standard")

        # ── Step 2: Determine capabilities ────────────────────────
        tag_scores: dict[str, int] = {}

        # Fast path: task_type direct mapping
        if task_type in TASK_TYPE_TO_CAPS:
            for tag in TASK_TYPE_TO_CAPS[task_type]:
                tag_scores[tag] = tag_scores.get(tag, 0) + 2
            reasons.append(f"task_type={task_type}")

        # Keyword scan across text blob
        keyword_hits = 0
        for keywords, tag in KEYWORD_TO_TAG:
            for kw in keywords:
                if kw in text:
                    tag_scores[tag] = tag_scores.get(tag, 0) + 1
                    keyword_hits += 1

        # Filter to valid tags, sort by score descending, take top 3
        valid_tags = [(tag, score) for tag, score in tag_scores.items()
                      if tag in ALL_TAGS]
        valid_tags.sort(key=lambda x: -x[1])
        capabilities = [tag for tag, _ in valid_tags[:3]]

        # tier=none gets empty capabilities
        if tier == "none":
            capabilities = []

        # ── Step 3: Determine confidence ──────────────────────────
        total_evidence = keyword_hits + (2 if task_type in TASK_TYPE_TO_CAPS else 0)
        if total_evidence >= 3:
            confidence = "high"
        elif total_evidence >= 1:
            confidence = "medium"
        else:
            confidence = "low"

        return ClassificationResult(
            tier=tier,
            capabilities_required=capabilities,
            confidence=confidence,
            reasoning=", ".join(reasons),
            source="deterministic",
        )

    def _classify_with_llm(self, agent_entry: dict) -> ClassificationResult | None:
        """LLM-based classification for edge cases. Uses Haiku."""
        try:
            import litellm
            from .known_prices import get_litellm_name

            tags_list = ", ".join(sorted(ALL_TAGS))
            prompt = (
                f"Classify this agent. Assign a tier and up to 3 capability tags.\n"
                f"Agent: {agent_entry.get('name', '?')}\n"
                f"Role: {agent_entry.get('role', '?')}\n"
                f"Department: {agent_entry.get('department', '?')}\n"
                f"Description: {agent_entry.get('description', 'N/A')}\n\n"
                f"Tiers: lightweight, standard, premium, none\n"
                f"Tags: {tags_list}\n\n"
                f"Respond ONLY with JSON:\n"
                f'{{"tier": "...", "capabilities_required": ["...", "..."], '
                f'"reasoning": "..."}}'
            )

            litellm_name = get_litellm_name("anthropic", "claude-haiku-4-5")
            resp = litellm.completion(
                model=litellm_name,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=128,
                temperature=0.0,
            )

            content = resp.choices[0].message.content.strip()
            # Strip markdown fencing if present
            if content.startswith("```"):
                content = content.split("\n", 1)[-1].rsplit("```", 1)[0].strip()

            data = json.loads(content)
            tier = data.get("tier", "standard")
            if tier not in {"lightweight", "standard", "premium", "none"}:
                tier = "standard"
            caps = [c for c in data.get("capabilities_required", [])
                    if c in ALL_TAGS][:3]

            return ClassificationResult(
                tier=tier,
                capabilities_required=caps,
                confidence="medium",
                reasoning=data.get("reasoning", "LLM classification"),
                source="llm_fallback",
            )

        except Exception as e:
            logger.warning("LLM classification failed: %s", e)
            return None

    def classify_batch(self, agents: list[dict]) -> list[ClassificationResult]:
        """Classify multiple agents at once."""
        return [self.classify(a) for a in agents]

    # model_tier values in registry -> standard tier mapping
    _MODEL_TIER_MAP = {
        "mid": "standard",
        "standard": "standard",
        "premium": "premium",
        "none": "none",
        "fast": "lightweight",
        "large_context": "premium",
    }

    def validate_against_existing(self, agents: list[dict]) -> dict:
        """Compare auto-classification with existing model_tier.

        Uses model_tier field (the actual registry field) mapped to
        standard tiers for comparison. Caps are only compared if present.
        Returns validation report dict.
        """
        total = 0
        tier_match = 0
        caps_match = 0
        full_match = 0
        mismatches = []

        for agent in agents:
            # Registry uses model_tier, not tier
            raw_tier = agent.get("tier") or agent.get("model_tier", "")
            actual_tier = self._MODEL_TIER_MAP.get(raw_tier, raw_tier)
            actual_caps = set(agent.get("capabilities_required", []))

            if not actual_tier:
                continue  # Skip agents without any tier info

            total += 1
            result = self._classify_deterministic(agent)

            tier_ok = result.tier == actual_tier
            # Caps: if agent has no existing caps, skip comparison (no ground truth)
            auto_caps = set(result.capabilities_required)
            caps_ok = not actual_caps or auto_caps == actual_caps

            if tier_ok:
                tier_match += 1
            if caps_ok:
                caps_match += 1
            if tier_ok and caps_ok:
                full_match += 1
            else:
                mismatch = {"agent_id": agent.get("id", "?")}
                if not tier_ok:
                    mismatch["tier"] = f"auto={result.tier}, actual={actual_tier}"
                if not caps_ok:
                    mismatch["caps"] = (
                        f"auto={sorted(auto_caps)}, actual={sorted(actual_caps)}"
                    )
                mismatch["reasoning"] = result.reasoning
                mismatches.append(mismatch)

        return {
            "total": total,
            "tier_match": tier_match,
            "caps_match": caps_match,
            "full_match": full_match,
            "tier_pct": (tier_match / total * 100) if total else 0,
            "caps_pct": (caps_match / total * 100) if total else 0,
            "full_pct": (full_match / total * 100) if total else 0,
            "mismatches": mismatches,
        }


# ── Smoke Test ────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=== AgentClassifier Smoke Test ===\n")
    c = AgentClassifier()

    tests = [
        ({"id": "TEST-01", "name": "Swift Developer", "role": "iOS Code Generator",
          "department": "Code-Pipeline", "task_type": "code_generation",
          "status": "active"},
         "standard", ["code_generation", "swift_code"]),
        ({"id": "TEST-02", "name": "Health Monitor", "role": "System Monitor",
          "department": "Infrastruktur", "task_type": "detection",
          "status": "active", "routing": "no_llm"},
         "none", []),
        ({"id": "TEST-03", "name": "Scoring Agent", "role": "Score Calculator",
          "department": "QA", "task_type": "scoring",
          "status": "active"},
         "lightweight", ["classification"]),
        ({"id": "TEST-04", "name": "Werbedesign Agent", "role": "Visual Ad Creator",
          "department": "Marketing", "status": "active"},
         "standard", None),  # None = don't check caps, just check it classifies
    ]

    passed = 0
    for agent, exp_tier, exp_caps in tests:
        r = c.classify_deterministic(agent)
        tier_ok = r.tier == exp_tier
        caps_ok = exp_caps is None or sorted(r.capabilities_required) == sorted(exp_caps)
        status = "OK" if (tier_ok and caps_ok) else "FAIL"
        print(f"  [{status}] {agent['id']} ({agent['name']})")
        print(f"    tier={r.tier} (exp={exp_tier}), caps={r.capabilities_required}")
        print(f"    confidence={r.confidence}, reasoning={r.reasoning}")
        if tier_ok and caps_ok:
            passed += 1

    print(f"\n{passed}/{len(tests)} smoke tests passed.")
