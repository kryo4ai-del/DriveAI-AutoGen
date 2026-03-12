# scanner.py
# AI Trend Scanner — detects emerging AI trends from internal factory signals
# and generates idea candidates for high-relevance trends.
# Read-only analysis of existing stores, writes to trend_store and idea_store.

from __future__ import annotations

import os
import sys
from datetime import date

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from trends.trend_manager import TrendManager
from factory.idea_manager import IdeaManager

# --- Relevance scoring weights ---
# Higher = more relevant for idea generation
_CATEGORY_WEIGHTS = {
    "model_release": 0.85,
    "ai_capability": 0.80,
    "app_category": 0.75,
    "developer_tooling": 0.70,
    "framework_update": 0.65,
    "platform_change": 0.60,
    "automation_pattern": 0.55,
    "market_shift": 0.50,
    "general": 0.40,
}

# Severity boosts relevance
_SEVERITY_BOOST = {
    "critical": 0.15,
    "high": 0.10,
    "medium": 0.0,
    "low": -0.05,
    "info": -0.10,
}

# Threshold for auto-generating an idea from a trend
IDEA_GENERATION_THRESHOLD = 0.70


def _load_store(rel_path: str, key: str) -> list[dict]:
    import json
    path = os.path.join(_ROOT, rel_path)
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        result = data.get(key, [])
        return result if isinstance(result, list) else []
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError):
        return []


def _load_memory() -> dict[str, list[dict]]:
    import json
    path = os.path.join(_ROOT, "memory", "memory_store.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        if not isinstance(data, dict):
            return {}
        return {k: v for k, v in data.items() if isinstance(v, list)}
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError):
        return {}


def _existing_trend_titles(manager: TrendManager) -> set[str]:
    return {t.get("title", "") for t in manager.trends}


def _compute_relevance(category: str, severity: str = "medium") -> float:
    base = _CATEGORY_WEIGHTS.get(category, 0.40)
    boost = _SEVERITY_BOOST.get(severity, 0.0)
    return max(0.0, min(1.0, base + boost))


def _map_watch_category_to_trend(watch_cat: str) -> str | None:
    """Map watch event categories to trend categories."""
    return {
        "model_update": "model_release",
        "sdk_requirement": "framework_update",
        "tooling_update": "developer_tooling",
        "security_change": "platform_change",
        "pricing_change": "market_shift",
        "deprecation": "platform_change",
        "opportunity": "app_category",
    }.get(watch_cat)


def scan_and_detect() -> tuple[list[dict], list[dict]]:
    """
    Run all signal scanners, detect trends, and generate ideas for high-relevance ones.
    Returns (new_trends, new_ideas).
    """
    trend_mgr = TrendManager()
    idea_mgr = IdeaManager()
    existing = _existing_trend_titles(trend_mgr)
    new_trends: list[dict] = []
    new_ideas: list[dict] = []

    def _add_trend(title: str, **kwargs) -> dict | None:
        if title in existing:
            return None
        t = trend_mgr.add_trend(title=title, **kwargs)
        existing.add(title)
        new_trends.append(t)
        return t

    # --- Scan Watch Events ---
    watch_events = _load_store("watch/watch_events.json", "events")
    _scan_watch_events(watch_events, _add_trend)

    # --- Scan Opportunities ---
    opportunities = _load_store("opportunities/opportunity_store.json", "opportunities")
    _scan_opportunities(opportunities, _add_trend)

    # --- Scan Radar Hits ---
    radar_hits = _load_store("radar/radar_hits.json", "hits")
    _scan_radar_hits(radar_hits, _add_trend)

    # --- Scan Memory for Patterns ---
    memory = _load_memory()
    _scan_memory(memory, _add_trend)

    # --- Generate Ideas from high-relevance trends ---
    actionable = trend_mgr.actionable()
    for trend in actionable:
        if trend.get("relevance_score", 0) >= IDEA_GENERATION_THRESHOLD:
            idea = _generate_idea(trend, idea_mgr, trend_mgr)
            if idea:
                new_ideas.append(idea)

    return new_trends, new_ideas


def _scan_watch_events(events: list[dict], add_trend) -> None:
    """Detect trends from watch events."""
    active = [e for e in events if e.get("status") not in ("resolved", "dismissed")]

    for evt in active:
        watch_cat = evt.get("category", "")
        trend_cat = _map_watch_category_to_trend(watch_cat)
        if not trend_cat:
            continue

        severity = evt.get("severity", "medium")
        relevance = _compute_relevance(trend_cat, severity)
        title = evt.get("title", "")

        # Determine potential app categories from affected projects/platforms
        app_cats = evt.get("affected_platforms", []) or []
        if not app_cats:
            app_cats = ["ios", "web"]  # default assumption

        add_trend(
            title=f"{trend_cat.replace('_', ' ').title()}: {title}",
            category=trend_cat,
            summary=evt.get("summary", title),
            relevance_score=relevance,
            potential_app_categories=app_cats,
            detected_from=f"watch_events/{evt.get('event_id', '?')}",
        )


def _scan_opportunities(opportunities: list[dict], add_trend) -> None:
    """Detect trends from opportunity records."""
    for opp in opportunities:
        status = opp.get("status", "")
        if status in ("rejected", "deferred"):
            continue

        relevance_map = {"critical": 0.90, "high": 0.80, "medium": 0.60, "low": 0.40}
        relevance = relevance_map.get(opp.get("market_relevance", "medium"), 0.50)

        products = opp.get("potential_products", [])
        app_cats = []
        for p in products:
            p_lower = p.lower()
            if "ios" in p_lower or "swift" in p_lower:
                app_cats.append("ios")
            if "web" in p_lower or "react" in p_lower:
                app_cats.append("web")
            if "android" in p_lower or "kotlin" in p_lower:
                app_cats.append("android")
        if not app_cats:
            app_cats = ["ios", "web"]

        add_trend(
            title=f"Opportunity: {opp.get('title', '?')}",
            category="app_category",
            summary=opp.get("description", opp.get("title", "")),
            relevance_score=relevance,
            potential_app_categories=app_cats,
            detected_from=f"opportunities/{opp.get('opportunity_id', '?')}",
        )


# Radar hit category → trend category mapping
_RADAR_CAT_TO_TREND = {
    "new_product": "app_category",
    "feature_pattern": "app_category",
    "market_gap": "market_shift",
    "pricing_model": "market_shift",
    "tech_stack": "developer_tooling",
    "user_pain_point": "app_category",
    "viral_concept": "app_category",
    "monetization": "market_shift",
    "platform_shift": "platform_change",
    "regulation": "platform_change",
    "general": "general",
}


def _scan_radar_hits(hits: list[dict], add_trend) -> None:
    """Detect trends from radar hits (external signal intake)."""
    active = [h for h in hits if h.get("status") not in ("dismissed", "expired")]

    for hit in active:
        radar_cat = hit.get("category", "general")
        trend_cat = _RADAR_CAT_TO_TREND.get(radar_cat, "general")
        relevance = hit.get("relevance_score", 0.5)

        platforms = hit.get("potential_platforms", [])
        if not platforms:
            platforms = ["ios", "web"]

        add_trend(
            title=f"Radar: {hit.get('title', '?')}",
            category=trend_cat,
            summary=hit.get("summary", hit.get("title", "")),
            relevance_score=relevance,
            potential_app_categories=platforms,
            detected_from=f"radar/{hit.get('hit_id', '?')}",
        )


def _scan_memory(memory: dict[str, list[dict]], add_trend) -> None:
    """Detect trends from agent memory patterns."""
    if not memory:
        return

    # Look for AI model mentions in decisions/architecture notes
    _AI_KEYWORDS = {
        "gpt-4": ("model_release", 0.80),
        "gpt-5": ("model_release", 0.90),
        "claude": ("model_release", 0.80),
        "gemini": ("model_release", 0.75),
        "llama": ("model_release", 0.70),
        "mistral": ("model_release", 0.70),
        "multimodal": ("ai_capability", 0.80),
        "vision model": ("ai_capability", 0.75),
        "voice model": ("ai_capability", 0.75),
        "agent framework": ("developer_tooling", 0.70),
        "autogen": ("developer_tooling", 0.65),
        "langchain": ("developer_tooling", 0.65),
        "function calling": ("ai_capability", 0.70),
        "tool use": ("ai_capability", 0.70),
        "on-device": ("ai_capability", 0.80),
        "edge ai": ("ai_capability", 0.75),
        "rag": ("ai_capability", 0.65),
        "fine-tuning": ("ai_capability", 0.65),
    }

    # Scan decisions and architecture notes for trend signals
    notes_to_scan = []
    for cat in ("decisions", "architecture_notes"):
        notes_to_scan.extend(memory.get(cat, []))

    keyword_hits: dict[str, int] = {}
    for note in notes_to_scan:
        text = note.get("note", "").lower()
        for keyword in _AI_KEYWORDS:
            if keyword in text:
                keyword_hits[keyword] = keyword_hits.get(keyword, 0) + 1

    # Only create trends for keywords mentioned multiple times
    for keyword, count in keyword_hits.items():
        if count >= 3:
            trend_cat, base_relevance = _AI_KEYWORDS[keyword]
            # Boost slightly for higher mention count
            relevance = min(1.0, base_relevance + (count - 3) * 0.02)

            add_trend(
                title=f"AI pattern: {keyword} ({count} mentions)",
                category=trend_cat,
                summary=f"The keyword '{keyword}' appeared in {count} agent decisions/architecture notes, "
                        f"indicating an emerging pattern worth exploring as an app concept.",
                relevance_score=relevance,
                potential_app_categories=["ios", "web"],
                detected_from="memory",
            )

    # Detect recurring feature patterns in implementation notes
    impl_notes = memory.get("implementation_notes", [])
    feature_keywords = {
        "notification": "app_category",
        "dashboard": "app_category",
        "analytics": "app_category",
        "onboarding": "app_category",
        "subscription": "market_shift",
        "monetization": "market_shift",
        "offline": "ai_capability",
        "real-time": "ai_capability",
        "chat": "app_category",
        "search": "ai_capability",
    }

    feature_hits: dict[str, int] = {}
    for note in impl_notes:
        text = note.get("note", "").lower()
        for keyword in feature_keywords:
            if keyword in text:
                feature_hits[keyword] = feature_hits.get(keyword, 0) + 1

    for keyword, count in feature_hits.items():
        if count >= 5:
            trend_cat = feature_keywords[keyword]
            add_trend(
                title=f"Feature pattern: {keyword} ({count} mentions)",
                category=trend_cat,
                summary=f"'{keyword}' mentioned {count} times in implementation notes — "
                        f"signals demand for this feature type across products.",
                relevance_score=0.60,
                potential_app_categories=["ios", "web"],
                detected_from="memory/implementation_notes",
            )


def _generate_idea(trend: dict, idea_mgr: IdeaManager, trend_mgr: TrendManager) -> dict | None:
    """Generate an idea from a high-relevance trend."""
    trend_id = trend.get("trend_id", "?")
    title = trend.get("title", "Untitled Trend")
    summary = trend.get("summary", "")
    category = trend.get("category", "general")
    platforms = trend.get("potential_app_categories", ["ios", "web"])
    relevance = trend.get("relevance_score", 0)

    # Build idea title
    idea_title = f"[Auto] {title}"

    # Check if idea with this title already exists
    for existing in idea_mgr.ideas:
        if existing.get("title") == idea_title:
            # Already generated, just mark trend
            trend_mgr.mark_idea_generated(trend_id, existing.get("id", "?"))
            return None

    # Determine complexity from category
    complexity_map = {
        "model_release": "medium",
        "ai_capability": "high",
        "app_category": "medium",
        "developer_tooling": "low",
        "framework_update": "low",
        "platform_change": "medium",
        "market_shift": "high",
        "automation_pattern": "low",
        "general": "medium",
    }
    complexity = complexity_map.get(category, "medium")

    # Build raw idea text
    raw_idea = (
        f"Auto-generated from trend {trend_id} (relevance: {relevance:.0%}).\n"
        f"Category: {category}\n"
        f"Platforms: {', '.join(platforms)}\n"
        f"Complexity: {complexity}\n\n"
        f"{summary}"
    )

    idea = idea_mgr.add_idea(
        title=idea_title,
        raw_idea=raw_idea,
        source="trend_scanner",
        scope="future-product",
        idea_type="feature",
        priority="later",
        notes=f"linked_trend_id: {trend_id} | opportunity_score: {relevance:.2f} | "
              f"platforms: {', '.join(platforms)} | complexity: {complexity}",
    )

    # Mark trend as idea_generated
    trend_mgr.mark_idea_generated(trend_id, idea.get("id", "?"))

    return idea


if __name__ == "__main__":
    trends, ideas = scan_and_detect()
    print(f"Detected {len(trends)} new trends:")
    for t in trends:
        print(f"  {t['trend_id']}: [{t['relevance_score']:.0%}] {t['title']}")
    print(f"\nGenerated {len(ideas)} new ideas:")
    for i in ideas:
        print(f"  {i['id']}: {i['title']}")
    if not trends and not ideas:
        print("No new trends or ideas detected.")
