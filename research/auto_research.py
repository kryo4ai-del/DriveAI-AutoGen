# auto_research.py
# AutoResearchAgent — analyzes factory signals and generates research reports.
# Reads from: radar hits, trends, opportunities, strategy reports,
# research graph, agent memory. Produces structured research insights.

from __future__ import annotations

import os
import sys
from datetime import datetime

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from research.research_manager import ResearchManager, VALID_CATEGORIES


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
        return {k: v for k, v in data.items() if isinstance(v, list)} if isinstance(data, dict) else {}
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError):
        return {}


# ═══════════════════════════════════════════════════════════════════════
# ANALYSIS FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════

def _analyze_technology_clusters(
    trends: list[dict], radar_hits: list[dict], opportunities: list[dict],
) -> list[dict]:
    """Identify technology clusters that appear across multiple signals."""
    tech_mentions: dict[str, dict] = {}

    for t in trends:
        for tech in t.get("technologies", []):
            tech_mentions.setdefault(tech, {"trends": [], "radar": [], "opportunities": []})
            tech_mentions[tech]["trends"].append(t.get("trend_id", "?"))

    for h in radar_hits:
        for tech in h.get("technologies", []):
            tech_mentions.setdefault(tech, {"trends": [], "radar": [], "opportunities": []})
            tech_mentions[tech]["radar"].append(h.get("hit_id", "?"))
        # Also check title/category
        cat = h.get("category", "")
        if cat and cat not in tech_mentions:
            tech_mentions.setdefault(cat, {"trends": [], "radar": [], "opportunities": []})
            tech_mentions[cat]["radar"].append(h.get("hit_id", "?"))

    for o in opportunities:
        for tech in o.get("technologies", []):
            tech_mentions.setdefault(tech, {"trends": [], "radar": [], "opportunities": []})
            tech_mentions[tech]["opportunities"].append(o.get("opportunity_id", "?"))

    # Only report technologies that appear in 2+ signal types
    reports = []
    for tech, sources in tech_mentions.items():
        signal_types = sum(1 for v in sources.values() if v)
        if signal_types < 2:
            continue
        total_signals = sum(len(v) for v in sources.values())
        reports.append({
            "topic": f"Technology Cluster: {tech}",
            "category": "technology_research",
            "summary": (
                f"{tech} appears across {signal_types} signal types with {total_signals} mentions. "
                f"Trends: {len(sources['trends'])}, Radar: {len(sources['radar'])}, "
                f"Opportunities: {len(sources['opportunities'])}."
            ),
            "source_signals": (
                [f"trend:{tid}" for tid in sources["trends"]]
                + [f"radar:{hid}" for hid in sources["radar"]]
                + [f"opportunity:{oid}" for oid in sources["opportunities"]]
            ),
            "recommendations": [
                f"Evaluate {tech} for factory integration",
                f"Monitor {tech} developments in upcoming radar scans",
            ],
            "technologies": [tech],
            "confidence": min(1.0, 0.3 + signal_types * 0.2 + total_signals * 0.05),
            "related_trends": [tid for tid in sources["trends"]],
            "related_opportunities": [oid for oid in sources["opportunities"]],
            "related_radar": [hid for hid in sources["radar"]],
        })

    # Sort by confidence desc
    reports.sort(key=lambda x: -x["confidence"])
    return reports[:10]


def _analyze_opportunity_gaps(
    opportunities: list[dict], trends: list[dict], radar_hits: list[dict],
) -> list[dict]:
    """Find high-relevance trends or radar hits that have no matching opportunity."""
    opp_titles = {o.get("title", "").lower() for o in opportunities}
    opp_techs = set()
    for o in opportunities:
        for t in o.get("technologies", []):
            opp_techs.add(t.lower())

    reports = []

    # High-relevance trends without corresponding opportunities
    for t in trends:
        if t.get("relevance_score", 0) < 0.6:
            continue
        if t.get("status") in ("dismissed", "expired", "idea_generated"):
            continue

        title_lower = t.get("title", "").lower()
        # Check if any opportunity covers this trend
        covered = any(
            title_lower[:20] in ot or ot[:20] in title_lower
            for ot in opp_titles if ot
        )
        if covered:
            continue

        reports.append({
            "topic": f"Opportunity Gap: {t.get('title', '?')}",
            "category": "product_opportunity",
            "summary": (
                f"High-relevance trend '{t.get('title', '?')}' (score: {t.get('relevance_score', 0):.0%}) "
                f"has no corresponding opportunity entry. Category: {t.get('category', '?')}."
            ),
            "source_signals": [f"trend:{t.get('trend_id', '?')}"],
            "recommendations": [
                f"Create opportunity from trend {t.get('trend_id', '?')}",
                "Evaluate market potential and implementation feasibility",
            ],
            "technologies": t.get("technologies", []),
            "confidence": t.get("relevance_score", 0.5),
            "related_trends": [t.get("trend_id", "?")],
        })

    # High-relevance radar hits not yet promoted
    for h in radar_hits:
        if h.get("relevance_score", 0) < 0.7:
            continue
        if h.get("status") in ("dismissed", "expired", "promoted"):
            continue

        reports.append({
            "topic": f"Radar Promotion Candidate: {h.get('title', '?')}",
            "category": "product_opportunity",
            "summary": (
                f"Radar hit '{h.get('title', '?')}' has high relevance ({h.get('relevance_score', 0):.0%}) "
                f"but hasn't been promoted to an opportunity yet."
            ),
            "source_signals": [f"radar:{h.get('hit_id', '?')}"],
            "recommendations": [
                f"Evaluate radar hit {h.get('hit_id', '?')} for promotion",
                "Assess market fit and competitive landscape",
            ],
            "technologies": h.get("technologies", []),
            "confidence": h.get("relevance_score", 0.5),
            "related_radar": [h.get("hit_id", "?")],
        })

    reports.sort(key=lambda x: -x["confidence"])
    return reports[:8]


def _analyze_graph_insights(
    graph_nodes: list[dict], graph_edges: list[dict],
) -> list[dict]:
    """Analyze research graph for structural insights."""
    if not graph_nodes:
        return []

    reports = []

    # Find highly connected entities (potential hub analysis)
    connection_counts: dict[str, int] = {}
    for e in graph_edges:
        src = e.get("source_node", "")
        tgt = e.get("target_node", "")
        connection_counts[src] = connection_counts.get(src, 0) + 1
        connection_counts[tgt] = connection_counts.get(tgt, 0) + 1

    node_lookup = {n.get("node_id"): n for n in graph_nodes}

    # Hub nodes (>= 5 connections)
    hubs = [(nid, count) for nid, count in connection_counts.items() if count >= 5]
    hubs.sort(key=lambda x: -x[1])

    if hubs:
        hub_details = []
        hub_entities = []
        for nid, count in hubs[:5]:
            node = node_lookup.get(nid, {})
            hub_details.append(f"{node.get('entity_id', '?')} ({node.get('entity_type', '?')}, {count} connections)")
            hub_entities.append(node.get("entity_id", "?"))

        reports.append({
            "topic": "Knowledge Graph Hub Analysis",
            "category": "architecture_comparison",
            "summary": (
                f"Graph has {len(hubs)} hub entities (5+ connections). "
                f"Top hubs: {'; '.join(hub_details[:3])}. "
                f"Hub entities represent key integration points across the factory."
            ),
            "source_signals": [f"graph_hub:{eid}" for eid in hub_entities],
            "recommendations": [
                "Review hub entities for architectural significance",
                "Consider hub entities when planning new features",
            ],
            "confidence": 0.7,
        })

    # Isolated node clusters
    connected_nids = set(connection_counts.keys())
    isolated = [n for n in graph_nodes if n.get("node_id") not in connected_nids]

    if len(isolated) > 3:
        isolated_types: dict[str, int] = {}
        for n in isolated:
            t = n.get("entity_type", "unknown")
            isolated_types[t] = isolated_types.get(t, 0) + 1

        type_summary = ", ".join(f"{t}: {c}" for t, c in sorted(isolated_types.items(), key=lambda x: -x[1])[:5])
        reports.append({
            "topic": "Disconnected Entities in Knowledge Graph",
            "category": "architecture_comparison",
            "summary": (
                f"{len(isolated)} entities have no connections in the graph. "
                f"Types: {type_summary}. "
                f"These may need cross-referencing or represent orphaned data."
            ),
            "source_signals": [f"graph_isolated:{n.get('entity_id', '?')}" for n in isolated[:10]],
            "recommendations": [
                "Review isolated entities for missing relationships",
                "Run ingestion to update cross-references",
                "Archive or remove truly orphaned entries",
            ],
            "confidence": 0.6,
        })

    return reports


def _analyze_market_signals(
    trends: list[dict], radar_hits: list[dict], strategy_reports: list[dict],
) -> list[dict]:
    """Analyze market signals from trends, radar, and strategy reports."""
    reports = []

    # Category concentration analysis
    trend_categories: dict[str, int] = {}
    for t in trends:
        if t.get("status") in ("dismissed", "expired"):
            continue
        cat = t.get("category", "general")
        trend_categories[cat] = trend_categories.get(cat, 0) + 1

    radar_categories: dict[str, int] = {}
    for h in radar_hits:
        if h.get("status") in ("dismissed", "expired"):
            continue
        cat = h.get("category", "general")
        radar_categories[cat] = radar_categories.get(cat, 0) + 1

    # Find categories with high activity
    all_categories = set(list(trend_categories.keys()) + list(radar_categories.keys()))
    hot_categories = []
    for cat in all_categories:
        trend_count = trend_categories.get(cat, 0)
        radar_count = radar_categories.get(cat, 0)
        total = trend_count + radar_count
        if total >= 3:
            hot_categories.append((cat, trend_count, radar_count, total))

    hot_categories.sort(key=lambda x: -x[3])

    if hot_categories:
        cat_details = [f"{cat} (trends: {tc}, radar: {rc})" for cat, tc, rc, _ in hot_categories[:5]]
        reports.append({
            "topic": "Hot Market Categories",
            "category": "market_analysis",
            "summary": (
                f"{len(hot_categories)} categories show high signal activity. "
                f"Top: {'; '.join(cat_details[:3])}."
            ),
            "source_signals": [f"category:{cat}" for cat, _, _, _ in hot_categories[:5]],
            "recommendations": [
                f"Focus research on top category: {hot_categories[0][0]}",
                "Align opportunity pipeline with trending categories",
            ],
            "confidence": min(1.0, 0.5 + len(hot_categories) * 0.1),
        })

    # Strategy report risk tracking
    if strategy_reports:
        latest = strategy_reports[-1]
        risks = latest.get("risks", [])
        high_risks = [r for r in risks if isinstance(r, dict) and r.get("severity") in ("critical", "high")]
        if not high_risks:
            high_risks = [r for r in risks if isinstance(r, str)][:3]

        if high_risks:
            risk_summary = []
            for r in high_risks[:3]:
                if isinstance(r, dict):
                    risk_summary.append(r.get("title", str(r))[:60])
                else:
                    risk_summary.append(str(r)[:60])

            reports.append({
                "topic": "Strategy Risk Follow-Up",
                "category": "market_analysis",
                "summary": (
                    f"Latest strategy report ({latest.get('week', '?')}) flagged {len(risks)} risks. "
                    f"Key risks: {'; '.join(risk_summary)}."
                ),
                "source_signals": [f"strategy:{latest.get('report_id', '?')}"],
                "recommendations": [
                    "Review flagged risks and update mitigation plans",
                    "Cross-reference risks with current trends and radar",
                ],
                "confidence": 0.65,
                "related_trends": [],
            })

    return reports


def _analyze_ai_model_landscape(
    trends: list[dict], radar_hits: list[dict],
) -> list[dict]:
    """Extract AI model evaluation insights from signals."""
    ai_keywords = {"llm", "gpt", "claude", "gemini", "mistral", "llama", "model", "fine-tune",
                   "rag", "embedding", "multimodal", "vision", "agent", "reasoning"}
    reports = []

    ai_signals = []
    for t in trends:
        if t.get("status") in ("dismissed", "expired"):
            continue
        title = t.get("title", "").lower()
        summary = t.get("summary", "").lower()
        if any(kw in title or kw in summary for kw in ai_keywords):
            ai_signals.append({
                "type": "trend", "id": t.get("trend_id", "?"),
                "title": t.get("title", "?"),
                "relevance": t.get("relevance_score", 0),
            })

    for h in radar_hits:
        if h.get("status") in ("dismissed", "expired"):
            continue
        title = h.get("title", "").lower()
        summary = h.get("summary", "").lower()
        if any(kw in title or kw in summary for kw in ai_keywords):
            ai_signals.append({
                "type": "radar", "id": h.get("hit_id", "?"),
                "title": h.get("title", "?"),
                "relevance": h.get("relevance_score", 0),
            })

    if ai_signals:
        ai_signals.sort(key=lambda x: -x["relevance"])
        signal_summaries = [f"{s['title']} ({s['relevance']:.0%})" for s in ai_signals[:5]]

        reports.append({
            "topic": "AI Model & Tool Landscape",
            "category": "ai_model_evaluation",
            "summary": (
                f"{len(ai_signals)} AI-related signals detected across trends and radar. "
                f"Top signals: {'; '.join(signal_summaries[:3])}."
            ),
            "source_signals": [f"{s['type']}:{s['id']}" for s in ai_signals],
            "recommendations": [
                "Evaluate new AI tools for factory integration",
                "Benchmark emerging models against current stack",
            ],
            "technologies": list({s["title"].split()[0] for s in ai_signals[:5]}),
            "confidence": min(1.0, 0.4 + len(ai_signals) * 0.1),
            "related_trends": [s["id"] for s in ai_signals if s["type"] == "trend"],
            "related_radar": [s["id"] for s in ai_signals if s["type"] == "radar"],
        })

    return reports


# ═══════════════════════════════════════════════════════════════════════
# MAIN GENERATOR
# ═══════════════════════════════════════════════════════════════════════

def generate_research(force: bool = False) -> list[dict]:
    """
    Analyze all factory signals and generate research reports.
    Returns list of newly created reports.

    By default, skips topics that already have a published report with
    the same topic (idempotent). Use force=True to regenerate.
    """
    manager = ResearchManager()

    # --- Load all signal sources ---
    trends = _load_store("trends/trend_store.json", "trends")
    radar_hits = _load_store("radar/radar_hits.json", "hits")
    opportunities = _load_store("opportunities/opportunity_store.json", "opportunities")
    strategy_reports = _load_store("strategy/weekly_reports.json", "reports")
    graph_nodes = _load_store("research_graph/graph_nodes.json", "nodes")
    graph_edges = _load_store("research_graph/graph_edges.json", "edges")

    # --- Run analyses ---
    candidates: list[dict] = []
    candidates.extend(_analyze_technology_clusters(trends, radar_hits, opportunities))
    candidates.extend(_analyze_opportunity_gaps(opportunities, trends, radar_hits))
    candidates.extend(_analyze_graph_insights(graph_nodes, graph_edges))
    candidates.extend(_analyze_market_signals(trends, radar_hits, strategy_reports))
    candidates.extend(_analyze_ai_model_landscape(trends, radar_hits))

    if not candidates:
        return []

    # --- Deduplicate against existing reports ---
    existing_topics = {r.get("topic", "").lower() for r in manager.reports}
    new_reports = []

    for c in candidates:
        topic = c.get("topic", "")
        if not force and topic.lower() in existing_topics:
            continue

        report = manager.add_report(
            topic=topic,
            category=c.get("category", "general"),
            summary=c.get("summary", ""),
            source_signals=c.get("source_signals", []),
            recommendations=c.get("recommendations", []),
            related_trends=c.get("related_trends"),
            related_opportunities=c.get("related_opportunities"),
            related_radar=c.get("related_radar"),
            technologies=c.get("technologies"),
            confidence=c.get("confidence", 0.5),
        )
        new_reports.append(report)
        existing_topics.add(topic.lower())

    return new_reports


if __name__ == "__main__":
    reports = generate_research()
    if reports:
        print(f"AutoResearch: Generated {len(reports)} new reports")
        for r in reports:
            print(f"  {r['research_id']}: {r['topic']} [{r['category']}] conf={r['confidence']}")
    else:
        print("AutoResearch: No new reports generated (no signals or all topics already covered)")
