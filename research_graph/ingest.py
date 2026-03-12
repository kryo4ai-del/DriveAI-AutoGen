# ingest.py
# Populates the ResearchMemoryGraph from existing factory stores.
# Reads all stores, creates nodes for every entity, and builds edges
# based on cross-references (project links, source IDs, status transitions).
# Idempotent — safe to run multiple times (skips existing nodes/edges).

import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from research_graph.graph_manager import GraphManager

import json


def _load_store(rel_path: str, key: str) -> list[dict]:
    path = os.path.join(_ROOT, rel_path)
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        result = data.get(key, [])
        return result if isinstance(result, list) else []
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError):
        return []


def ingest_all() -> dict:
    """
    Populate the graph from all factory stores.
    Returns: {"nodes_added": int, "edges_added": int}
    """
    gm = GraphManager()
    nodes_before = len(gm.nodes)
    edges_before = len(gm.edges)

    # ── Load all stores ──────────────────────────────────────────────
    ideas = _load_store("factory/ideas/idea_store.json", "ideas")
    projects = _load_store("factory/projects/project_registry.json", "projects")
    specs = _load_store("factory/specs/spec_store.json", "specs")
    opportunities = _load_store("opportunities/opportunity_store.json", "opportunities")
    trends = _load_store("trends/trend_store.json", "trends")
    radar_hits = _load_store("radar/radar_hits.json", "hits")
    compliance = _load_store("compliance/compliance_reports.json", "reports")
    a11y = _load_store("accessibility/accessibility_reports.json", "reports")
    improvements = _load_store("improvements/improvement_proposals.json", "proposals")
    watch_events = _load_store("watch/watch_events.json", "events")
    strategy_reports = _load_store("strategy/weekly_reports.json", "reports")
    content = _load_store("content/content_store.json", "content")

    # ── Create nodes ─────────────────────────────────────────────────

    for i in ideas:
        gm.add_node(i.get("id", "?"), "idea", i.get("title", "?"),
                     "factory/ideas/idea_store.json",
                     {"status": i.get("status"), "priority": i.get("priority"),
                      "project": i.get("project")})

    for p in projects:
        gm.add_node(p.get("id", "?"), "project", p.get("name", "?"),
                     "factory/projects/project_registry.json",
                     {"status": p.get("status"), "platform": p.get("platform"),
                      "active": p.get("active")})

    for s in specs:
        gm.add_node(s.get("spec_id", "?"), "spec", s.get("title", "?"),
                     "factory/specs/spec_store.json",
                     {"status": s.get("status"), "project": s.get("project")})

    for o in opportunities:
        gm.add_node(o.get("opportunity_id", "?"), "opportunity", o.get("title", "?"),
                     "opportunities/opportunity_store.json",
                     {"status": o.get("status"), "relevance": o.get("market_relevance")})

    for t in trends:
        gm.add_node(t.get("trend_id", "?"), "trend", t.get("title", "?"),
                     "trends/trend_store.json",
                     {"status": t.get("status"), "relevance": t.get("relevance_score"),
                      "category": t.get("category")})

    for h in radar_hits:
        gm.add_node(h.get("hit_id", "?"), "radar_hit", h.get("title", "?"),
                     "radar/radar_hits.json",
                     {"status": h.get("status"), "relevance": h.get("relevance_score"),
                      "category": h.get("category"), "source_id": h.get("source_id")})

    for c in compliance:
        gm.add_node(c.get("report_id", "?"), "compliance", c.get("topic", "?"),
                     "compliance/compliance_reports.json",
                     {"status": c.get("status"), "risk_level": c.get("risk_level"),
                      "project": c.get("project")})

    for a in a11y:
        gm.add_node(a.get("report_id", "?"), "accessibility", a.get("issue_type", "?"),
                     "accessibility/accessibility_reports.json",
                     {"status": a.get("status"), "severity": a.get("severity"),
                      "project": a.get("project")})

    for imp in improvements:
        gm.add_node(imp.get("proposal_id", "?"), "improvement", imp.get("title", "?"),
                     "improvements/improvement_proposals.json",
                     {"status": imp.get("status"), "severity": imp.get("severity"),
                      "category": imp.get("category")})

    for w in watch_events:
        gm.add_node(w.get("event_id", "?"), "watch_event", w.get("title", "?"),
                     "watch/watch_events.json",
                     {"status": w.get("status"), "severity": w.get("severity"),
                      "category": w.get("category")})

    for sr in strategy_reports:
        gm.add_node(sr.get("report_id", "?"), "strategy_report",
                     f"Strategy {sr.get('week', '?')}",
                     "strategy/weekly_reports.json",
                     {"status": sr.get("status"), "week": sr.get("week")})

    for ct in content:
        gm.add_node(ct.get("content_id", "?"), "content", ct.get("title", "?"),
                     "content/content_store.json",
                     {"status": ct.get("status"), "content_type": ct.get("content_type"),
                      "project": ct.get("project")})

    # ── Create edges ─────────────────────────────────────────────────

    # Ideas → Projects (recommended_for)
    for i in ideas:
        project_id = i.get("project")
        if project_id and project_id != "—":
            gm.add_edge_by_entity(i.get("id", "?"), project_id,
                                  "recommended_for", notes="idea assigned to project")

    # Ideas derived from trends (derived_from)
    for i in ideas:
        notes = i.get("notes", "")
        source = i.get("source", "")
        # Auto-generated ideas from trend scanner have trend IDs in notes
        if "[Auto]" in i.get("title", "") or source == "trend_scanner":
            for t in trends:
                tid = t.get("trend_id", "")
                if tid and tid in notes:
                    gm.add_edge_by_entity(i.get("id", "?"), tid,
                                          "derived_from", notes="auto-generated from trend")

    # Specs → Projects (recommended_for) + Specs → Ideas (derived_from)
    for s in specs:
        project_id = s.get("project")
        if project_id and project_id != "—":
            gm.add_edge_by_entity(s.get("spec_id", "?"), project_id,
                                  "recommended_for", notes="spec for project")
        idea_id = s.get("idea_id") or s.get("source_idea")
        if idea_id:
            gm.add_edge_by_entity(s.get("spec_id", "?"), idea_id,
                                  "derived_from", notes="spec from idea")

    # Radar hits → Opportunities (promoted_to)
    for h in radar_hits:
        if h.get("status") == "opportunity_created":
            opp_id = h.get("opportunity_id")
            if opp_id:
                gm.add_edge_by_entity(h.get("hit_id", "?"), opp_id,
                                      "promoted_to", notes="radar hit promoted to opportunity")

    # Trends detected from radar hits (generated_from)
    for t in trends:
        detected = t.get("detected_from", "")
        if "radar" in detected.lower():
            # Try to match radar hit IDs in the summary/notes
            for h in radar_hits:
                hid = h.get("hit_id", "")
                if hid and hid in t.get("summary", ""):
                    gm.add_edge_by_entity(t.get("trend_id", "?"), hid,
                                          "generated_from", notes="trend detected from radar hit")

    # Trends detected from watch events (generated_from)
    for t in trends:
        detected = t.get("detected_from", "")
        if "watch" in detected.lower():
            for w in watch_events:
                wid = w.get("event_id", "")
                if wid and wid in t.get("summary", ""):
                    gm.add_edge_by_entity(t.get("trend_id", "?"), wid,
                                          "generated_from", notes="trend detected from watch event")

    # Compliance → Projects (affects)
    for c in compliance:
        project_id = c.get("project")
        if project_id and project_id != "—":
            gm.add_edge_by_entity(c.get("report_id", "?"), project_id,
                                  "affects", notes="compliance finding for project")

    # Accessibility → Projects (affects)
    for a in a11y:
        project_id = a.get("project")
        if project_id and project_id != "—":
            gm.add_edge_by_entity(a.get("report_id", "?"), project_id,
                                  "affects", notes="accessibility issue in project")

    # Watch events → Projects (affects)
    for w in watch_events:
        project_id = w.get("project") or w.get("affected_project")
        if project_id and project_id != "—":
            gm.add_edge_by_entity(w.get("event_id", "?"), project_id,
                                  "affects", notes="watch event affects project")

    # Improvements → affected systems (addresses)
    for imp in improvements:
        affected = imp.get("affected_systems", [])
        for sys_ref in affected:
            # Try to find a matching node
            target = gm.get_node_by_entity(sys_ref)
            if target:
                gm.add_edge_by_entity(imp.get("proposal_id", "?"), sys_ref,
                                      "addresses", notes="improvement addresses system")

    # Improvements detected from sources (generated_from)
    for imp in improvements:
        detected = imp.get("detected_from", "")
        if detected:
            # detected_from often contains entity IDs
            for w in watch_events:
                wid = w.get("event_id", "")
                if wid and wid in detected:
                    gm.add_edge_by_entity(imp.get("proposal_id", "?"), wid,
                                          "generated_from", notes="improvement from watch event")
            for c in compliance:
                cid = c.get("report_id", "")
                if cid and cid in detected:
                    gm.add_edge_by_entity(imp.get("proposal_id", "?"), cid,
                                          "generated_from", notes="improvement from compliance finding")

    # Content → Projects (recommended_for)
    for ct in content:
        project_id = ct.get("project")
        if project_id and project_id != "—":
            gm.add_edge_by_entity(ct.get("content_id", "?"), project_id,
                                  "recommended_for", notes="content for project")

    # Strategy reports — link to top opportunities/trends mentioned
    for sr in strategy_reports:
        rid = sr.get("report_id", "?")
        for opp in sr.get("top_opportunities", []):
            opp_id = opp.get("id", "")
            if opp_id:
                gm.add_edge_by_entity(rid, opp_id,
                                      "linked_to", notes="featured in strategy report")
        for trend in sr.get("top_trends", []):
            tid = trend.get("id", "")
            if tid:
                gm.add_edge_by_entity(rid, tid,
                                      "linked_to", notes="featured in strategy report")
        for risk in sr.get("risks", []):
            risk_id = risk.get("id", "")
            if risk_id:
                gm.add_edge_by_entity(rid, risk_id,
                                      "linked_to", notes="risk in strategy report")

    # Opportunities → Trends (related_to) — topical overlap via category
    _TREND_OPP_CATEGORY_MAP = {
        "model_release": ["new_product", "tech_stack"],
        "developer_tooling": ["tech_stack", "feature_pattern"],
        "app_category": ["new_product", "market_gap"],
        "ai_capability": ["new_product", "feature_pattern"],
        "market_shift": ["market_gap", "pricing_model"],
    }
    for t in trends:
        t_cat = t.get("category", "")
        related_opp_cats = _TREND_OPP_CATEGORY_MAP.get(t_cat, [])
        if related_opp_cats:
            for o in opportunities:
                if o.get("category") in related_opp_cats:
                    gm.add_edge_by_entity(t.get("trend_id", "?"),
                                          o.get("opportunity_id", "?"),
                                          "related_to", weight=0.6,
                                          notes=f"category overlap: {t_cat} ↔ {o.get('category')}")

    nodes_added = len(gm.nodes) - nodes_before
    edges_added = len(gm.edges) - edges_before

    return {
        "nodes_added": nodes_added,
        "edges_added": edges_added,
        "total_nodes": len(gm.nodes),
        "total_edges": len(gm.edges),
    }


if __name__ == "__main__":
    result = ingest_all()
    print(f"Research Graph Ingestion:")
    print(f"  Nodes added: {result['nodes_added']} (total: {result['total_nodes']})")
    print(f"  Edges added: {result['edges_added']} (total: {result['total_edges']})")

    gm = GraphManager()
    stats = gm.stats()
    if stats["node_types"]:
        print(f"\n  Node types:")
        for t, c in stats["node_types"].items():
            print(f"    {t}: {c}")
    if stats["edge_types"]:
        print(f"\n  Edge types:")
        for t, c in stats["edge_types"].items():
            print(f"    {t}: {c}")
    top = stats.get("most_connected", [])
    if top:
        print(f"\n  Most connected:")
        for n in top[:5]:
            print(f"    {n.get('entity_id', '?')} ({n.get('entity_type', '?')}): {n.get('connection_count', 0)} links")
