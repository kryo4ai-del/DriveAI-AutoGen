"""Research Memory Graph — Knowledge graph explorer for the AI App Factory."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Research Graph — Factory Control Center", page_icon="🔗", layout="wide")

st.title("Research Memory Graph")
reader = StoreReader()

nodes = reader.graph_nodes()
edges = reader.graph_edges()

st.caption(f"{len(nodes)} nodes, {len(edges)} edges")

# ═══════════════════════════════════════════════════════════════════════
# EMPTY STATE
# ═══════════════════════════════════════════════════════════════════════
if not nodes:
    st.info(
        "Graph is empty. Populate it from factory stores:\n\n"
        "```python\npython -m research_graph.ingest\n```\n\n"
        "This reads all factory stores and builds nodes + edges automatically."
    )
    st.stop()

# ═══════════════════════════════════════════════════════════════════════
# GRAPH OVERVIEW
# ═══════════════════════════════════════════════════════════════════════
st.subheader("Overview")

# Node type counts
node_types: dict[str, int] = {}
for n in nodes:
    t = n.get("entity_type", "unknown")
    node_types[t] = node_types.get(t, 0) + 1
node_types_sorted = sorted(node_types.items(), key=lambda x: -x[1])

# Edge type counts
edge_types: dict[str, int] = {}
for e in edges:
    t = e.get("edge_type", "unknown")
    edge_types[t] = edge_types.get(t, 0) + 1
edge_types_sorted = sorted(edge_types.items(), key=lambda x: -x[1])

# Connection counts per node
connection_counts: dict[str, int] = {}
for e in edges:
    src = e.get("source_node", "")
    tgt = e.get("target_node", "")
    connection_counts[src] = connection_counts.get(src, 0) + 1
    connection_counts[tgt] = connection_counts.get(tgt, 0) + 1

connected_nodes = set(connection_counts.keys())
isolated = [n for n in nodes if n.get("node_id") not in connected_nodes]

# KPI row
cols = st.columns(5)
cols[0].metric("Nodes", len(nodes))
cols[1].metric("Edges", len(edges))
cols[2].metric("Node Types", len(node_types))
cols[3].metric("Edge Types", len(edge_types))
cols[4].metric("Isolated", len(isolated))

# ═══════════════════════════════════════════════════════════════════════
# NODE TYPE BREAKDOWN
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Nodes by Type")

TYPE_ICONS = {
    "idea": "💡", "project": "📦", "opportunity": "🎯", "trend": "📈",
    "radar_hit": "📡", "spec": "📋", "compliance": "⚖️", "accessibility": "♿",
    "strategy_report": "🎯", "improvement": "🔧", "watch_event": "👁️",
    "briefing": "📋", "content": "📝",
}

type_cols = st.columns(min(len(node_types_sorted), 6))
for i, (ntype, count) in enumerate(node_types_sorted[:6]):
    icon = TYPE_ICONS.get(ntype, "📌")
    type_cols[i % 6].metric(f"{icon} {ntype}", count)

if len(node_types_sorted) > 6:
    extra_cols = st.columns(min(len(node_types_sorted) - 6, 6))
    for i, (ntype, count) in enumerate(node_types_sorted[6:12]):
        icon = TYPE_ICONS.get(ntype, "📌")
        extra_cols[i % 6].metric(f"{icon} {ntype}", count)

# ═══════════════════════════════════════════════════════════════════════
# EDGE TYPE BREAKDOWN
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Relationship Types")

EDGE_ICONS = {
    "derived_from": "↗️", "related_to": "↔️", "promoted_to": "⬆️",
    "blocked_by": "🚫", "recommended_for": "✅", "affects": "⚡",
    "linked_to": "🔗", "generated_from": "⚙️", "addresses": "🔧",
    "depends_on": "📎",
}

for etype, count in edge_types_sorted:
    icon = EDGE_ICONS.get(etype, "—")
    st.text(f"  {icon} {etype:25s} {count:>4} edges")

# ═══════════════════════════════════════════════════════════════════════
# MOST CONNECTED NODES
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Most Connected Entities")

top_connected = sorted(connection_counts.items(), key=lambda x: -x[1])[:10]
if top_connected:
    # Build node lookup
    node_lookup = {n.get("node_id"): n for n in nodes}

    for nid, count in top_connected:
        node = node_lookup.get(nid, {})
        icon = TYPE_ICONS.get(node.get("entity_type", ""), "📌")
        st.text(
            f"  {icon} {node.get('entity_id', '?'):15s} "
            f"{node.get('title', '?')[:45]:45s} "
            f"[{node.get('entity_type', '?')}]  "
            f"{count} connections"
        )

# ═══════════════════════════════════════════════════════════════════════
# ENTITY EXPLORER
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Entity Explorer")

# Build entity list for selectbox
entity_options = ["(select an entity)"]
entity_map: dict[str, dict] = {}
for n in sorted(nodes, key=lambda x: x.get("entity_type", "") + x.get("entity_id", "")):
    icon = TYPE_ICONS.get(n.get("entity_type", ""), "📌")
    label = f"{icon} {n.get('entity_id', '?')} — {n.get('title', '?')[:40]} [{n.get('entity_type', '?')}]"
    entity_options.append(label)
    entity_map[label] = n

selected = st.selectbox("Select entity to explore", entity_options)

if selected != "(select an entity)":
    sel_node = entity_map.get(selected, {})
    sel_nid = sel_node.get("node_id", "")

    # Connected edges
    out_edges = [e for e in edges if e.get("source_node") == sel_nid]
    in_edges = [e for e in edges if e.get("target_node") == sel_nid]

    node_lookup = {n.get("node_id"): n for n in nodes}

    # Entity info
    st.markdown(f"**Entity**: `{sel_node.get('entity_id')}` | **Type**: `{sel_node.get('entity_type')}` | **Connections**: {len(out_edges) + len(in_edges)}")

    meta = sel_node.get("metadata", {})
    if meta:
        meta_parts = [f"{k}: {v}" for k, v in meta.items() if v is not None]
        if meta_parts:
            st.caption(f"Metadata: {' | '.join(meta_parts)}")

    # Outgoing edges
    if out_edges:
        st.markdown(f"**Outgoing** ({len(out_edges)})")
        for e in out_edges:
            target = node_lookup.get(e.get("target_node"), {})
            t_icon = TYPE_ICONS.get(target.get("entity_type", ""), "📌")
            e_icon = EDGE_ICONS.get(e.get("edge_type", ""), "→")
            notes = f" — {e.get('notes')}" if e.get("notes") else ""
            st.text(
                f"  {e_icon} —[{e.get('edge_type', '?')}]→ "
                f"{t_icon} {target.get('entity_id', '?')}: {target.get('title', '?')[:40]}{notes}"
            )

    # Incoming edges
    if in_edges:
        st.markdown(f"**Incoming** ({len(in_edges)})")
        for e in in_edges:
            source = node_lookup.get(e.get("source_node"), {})
            s_icon = TYPE_ICONS.get(source.get("entity_type", ""), "📌")
            e_icon = EDGE_ICONS.get(e.get("edge_type", ""), "→")
            notes = f" — {e.get('notes')}" if e.get("notes") else ""
            st.text(
                f"  {s_icon} {source.get('entity_id', '?')}: {source.get('title', '?')[:40]} "
                f"—[{e.get('edge_type', '?')}]→ {e_icon}{notes}"
            )

    if not out_edges and not in_edges:
        st.caption("This entity has no connections (isolated node).")

# ═══════════════════════════════════════════════════════════════════════
# ISOLATED NODES
# ═══════════════════════════════════════════════════════════════════════
if isolated:
    st.markdown("---")
    with st.expander(f"Isolated Nodes ({len(isolated)})"):
        for n in isolated:
            icon = TYPE_ICONS.get(n.get("entity_type", ""), "📌")
            st.text(f"  {icon} {n.get('entity_id', '?'):15s} {n.get('title', '?')[:50]} [{n.get('entity_type', '?')}]")

# ═══════════════════════════════════════════════════════════════════════
# ALL EDGES (collapsed)
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
with st.expander(f"All Edges ({len(edges)})"):
    node_lookup = {n.get("node_id"): n for n in nodes}
    for e in edges:
        src = node_lookup.get(e.get("source_node"), {})
        tgt = node_lookup.get(e.get("target_node"), {})
        e_icon = EDGE_ICONS.get(e.get("edge_type", ""), "→")
        st.text(
            f"  {e.get('edge_id', '?'):12s} "
            f"{src.get('entity_id', '?'):15s} "
            f"—[{e.get('edge_type', '?')}]→ "
            f"{tgt.get('entity_id', '?'):15s} "
            f"w={e.get('weight', 1.0):.1f}"
        )
