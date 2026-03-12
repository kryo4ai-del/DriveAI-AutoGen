# graph_manager.py
# ResearchMemoryGraph — lightweight knowledge graph for the AI App Factory.
# Stores nodes (entities from all factory stores) and edges (relationships)
# in JSON files. No database, no heavy graph library.

import json
import os
from datetime import datetime

_DIR = os.path.dirname(__file__)
_NODES_PATH = os.path.join(_DIR, "graph_nodes.json")
_EDGES_PATH = os.path.join(_DIR, "graph_edges.json")

# ── Valid types ───────────────────────────────────────────────────────

VALID_NODE_TYPES = (
    "idea", "project", "opportunity", "trend", "radar_hit", "spec",
    "compliance", "accessibility", "strategy_report", "improvement",
    "watch_event", "briefing", "content",
)

VALID_EDGE_TYPES = (
    "derived_from",       # B was derived from A (e.g. idea from trend)
    "related_to",         # A and B are topically related
    "promoted_to",        # A was promoted to B (e.g. radar hit → opportunity)
    "blocked_by",         # A is blocked by B
    "recommended_for",    # A is recommended for project B
    "affects",            # A affects B (e.g. compliance finding affects project)
    "linked_to",          # Generic bidirectional link
    "generated_from",     # A was auto-generated from B
    "addresses",          # A addresses/fixes B (e.g. improvement addresses risk)
    "depends_on",         # A depends on B
)


def _load_json(path: str) -> dict:
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def _save_json(path: str, data: dict) -> None:
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


class GraphManager:
    """Lightweight knowledge graph for the AI App Factory."""

    def __init__(self):
        self._nodes_data = _load_json(_NODES_PATH)
        self._nodes_data.setdefault("nodes", [])
        self._edges_data = _load_json(_EDGES_PATH)
        self._edges_data.setdefault("edges", [])

    def save(self) -> None:
        _save_json(_NODES_PATH, self._nodes_data)
        _save_json(_EDGES_PATH, self._edges_data)

    # ── Properties ────────────────────────────────────────────────────

    @property
    def nodes(self) -> list[dict]:
        return self._nodes_data["nodes"]

    @property
    def edges(self) -> list[dict]:
        return self._edges_data["edges"]

    # ── ID generators ─────────────────────────────────────────────────

    def _next_node_id(self) -> str:
        max_num = 0
        for n in self.nodes:
            nid = n.get("node_id", "")
            if nid.startswith("GNODE-"):
                try:
                    max_num = max(max_num, int(nid.split("-")[1]))
                except (IndexError, ValueError):
                    pass
        return f"GNODE-{max_num + 1:04d}"

    def _next_edge_id(self) -> str:
        max_num = 0
        for e in self.edges:
            eid = e.get("edge_id", "")
            if eid.startswith("GEDGE-"):
                try:
                    max_num = max(max_num, int(eid.split("-")[1]))
                except (IndexError, ValueError):
                    pass
        return f"GEDGE-{max_num + 1:04d}"

    # ── Node CRUD ─────────────────────────────────────────────────────

    def add_node(self, entity_id: str, entity_type: str, title: str,
                 store_path: str = "", metadata: dict | None = None) -> dict:
        """
        Add a node to the graph.
        entity_id: the original ID from the source store (e.g. IDEA-001, TREND-003)
        entity_type: one of VALID_NODE_TYPES
        """
        if entity_type not in VALID_NODE_TYPES:
            raise ValueError(f"Invalid node type: {entity_type}. Must be one of {VALID_NODE_TYPES}")

        # Skip if already exists (by entity_id + entity_type)
        existing = self.get_node_by_entity(entity_id, entity_type)
        if existing:
            return existing

        node = {
            "node_id": self._next_node_id(),
            "entity_id": entity_id,
            "entity_type": entity_type,
            "title": title,
            "store_path": store_path,
            "metadata": metadata or {},
            "created_at": datetime.utcnow().isoformat(timespec="seconds") + "Z",
        }
        self.nodes.append(node)
        _save_json(_NODES_PATH, self._nodes_data)
        return node

    def get_node(self, node_id: str) -> dict | None:
        for n in self.nodes:
            if n.get("node_id") == node_id:
                return n
        return None

    def get_node_by_entity(self, entity_id: str, entity_type: str = "") -> dict | None:
        for n in self.nodes:
            if n.get("entity_id") == entity_id:
                if not entity_type or n.get("entity_type") == entity_type:
                    return n
        return None

    def nodes_by_type(self, entity_type: str) -> list[dict]:
        return [n for n in self.nodes if n.get("entity_type") == entity_type]

    def remove_node(self, node_id: str) -> bool:
        """Remove a node and all its edges."""
        node = self.get_node(node_id)
        if not node:
            return False
        self.nodes.remove(node)
        # Remove connected edges
        self._edges_data["edges"] = [
            e for e in self.edges
            if e.get("source_node") != node_id and e.get("target_node") != node_id
        ]
        self.save()
        return True

    # ── Edge CRUD ─────────────────────────────────────────────────────

    def add_edge(self, source_node: str, target_node: str, edge_type: str,
                 weight: float = 1.0, notes: str = "") -> dict:
        """
        Add a directed edge between two nodes.
        source_node / target_node: node_id values (GNODE-NNNN)
        """
        if edge_type not in VALID_EDGE_TYPES:
            raise ValueError(f"Invalid edge type: {edge_type}. Must be one of {VALID_EDGE_TYPES}")

        # Skip duplicate edges
        existing = self.get_edge(source_node, target_node, edge_type)
        if existing:
            return existing

        edge = {
            "edge_id": self._next_edge_id(),
            "source_node": source_node,
            "target_node": target_node,
            "edge_type": edge_type,
            "weight": round(weight, 2),
            "notes": notes,
            "created_at": datetime.utcnow().isoformat(timespec="seconds") + "Z",
        }
        self.edges.append(edge)
        _save_json(_EDGES_PATH, self._edges_data)
        return edge

    def add_edge_by_entity(self, source_entity_id: str, target_entity_id: str,
                           edge_type: str, weight: float = 1.0, notes: str = "") -> dict | None:
        """Add edge using entity IDs instead of node IDs. Returns None if nodes not found."""
        source = self.get_node_by_entity(source_entity_id)
        target = self.get_node_by_entity(target_entity_id)
        if not source or not target:
            return None
        return self.add_edge(source["node_id"], target["node_id"], edge_type, weight, notes)

    def get_edge(self, source_node: str, target_node: str, edge_type: str) -> dict | None:
        for e in self.edges:
            if (e.get("source_node") == source_node
                    and e.get("target_node") == target_node
                    and e.get("edge_type") == edge_type):
                return e
        return None

    def edges_from(self, node_id: str) -> list[dict]:
        return [e for e in self.edges if e.get("source_node") == node_id]

    def edges_to(self, node_id: str) -> list[dict]:
        return [e for e in self.edges if e.get("target_node") == node_id]

    def edges_for(self, node_id: str) -> list[dict]:
        """All edges connected to a node (inbound + outbound)."""
        return [e for e in self.edges
                if e.get("source_node") == node_id or e.get("target_node") == node_id]

    def remove_edge(self, edge_id: str) -> bool:
        edge = None
        for e in self.edges:
            if e.get("edge_id") == edge_id:
                edge = e
                break
        if not edge:
            return False
        self.edges.remove(edge)
        _save_json(_EDGES_PATH, self._edges_data)
        return True

    # ── Queries ───────────────────────────────────────────────────────

    def neighbors(self, node_id: str) -> list[dict]:
        """Return all nodes directly connected to a given node."""
        connected_ids = set()
        for e in self.edges_for(node_id):
            if e["source_node"] == node_id:
                connected_ids.add(e["target_node"])
            else:
                connected_ids.add(e["source_node"])
        return [n for n in self.nodes if n.get("node_id") in connected_ids]

    def neighbors_by_entity(self, entity_id: str) -> list[dict]:
        """Return neighbors using entity_id lookup."""
        node = self.get_node_by_entity(entity_id)
        if not node:
            return []
        return self.neighbors(node["node_id"])

    def connected_context(self, entity_id: str) -> dict:
        """
        Build a structured context summary for a given entity.
        Returns: {entity, edges_out, edges_in, neighbors_by_type}
        """
        node = self.get_node_by_entity(entity_id)
        if not node:
            return {"entity": None, "edges_out": [], "edges_in": [], "neighbors_by_type": {}}

        nid = node["node_id"]
        out_edges = self.edges_from(nid)
        in_edges = self.edges_to(nid)

        # Resolve neighbor nodes and group by type
        neighbor_nodes = self.neighbors(nid)
        by_type: dict[str, list[dict]] = {}
        for nb in neighbor_nodes:
            t = nb.get("entity_type", "unknown")
            by_type.setdefault(t, []).append({
                "entity_id": nb.get("entity_id"),
                "title": nb.get("title"),
                "node_id": nb.get("node_id"),
            })

        # Enrich edges with titles
        def _enrich_edge(e: dict, direction: str) -> dict:
            other_id = e["target_node"] if direction == "out" else e["source_node"]
            other = self.get_node(other_id)
            return {
                "edge_id": e.get("edge_id"),
                "edge_type": e.get("edge_type"),
                "weight": e.get("weight"),
                "other_entity_id": other.get("entity_id", "?") if other else "?",
                "other_title": other.get("title", "?") if other else "?",
                "other_type": other.get("entity_type", "?") if other else "?",
                "notes": e.get("notes", ""),
            }

        return {
            "entity": {
                "entity_id": node.get("entity_id"),
                "entity_type": node.get("entity_type"),
                "title": node.get("title"),
                "node_id": nid,
            },
            "edges_out": [_enrich_edge(e, "out") for e in out_edges],
            "edges_in": [_enrich_edge(e, "in") for e in in_edges],
            "neighbors_by_type": by_type,
            "total_connections": len(out_edges) + len(in_edges),
        }

    def most_connected(self, limit: int = 10) -> list[dict]:
        """Return nodes sorted by connection count (descending)."""
        counts: dict[str, int] = {}
        for e in self.edges:
            src = e.get("source_node", "")
            tgt = e.get("target_node", "")
            counts[src] = counts.get(src, 0) + 1
            counts[tgt] = counts.get(tgt, 0) + 1

        sorted_ids = sorted(counts.items(), key=lambda x: -x[1])[:limit]
        result = []
        for nid, count in sorted_ids:
            node = self.get_node(nid)
            if node:
                result.append({**node, "connection_count": count})
        return result

    def isolated_nodes(self) -> list[dict]:
        """Return nodes with zero connections."""
        connected = set()
        for e in self.edges:
            connected.add(e.get("source_node", ""))
            connected.add(e.get("target_node", ""))
        return [n for n in self.nodes if n.get("node_id") not in connected]

    def edges_by_type(self, edge_type: str) -> list[dict]:
        return [e for e in self.edges if e.get("edge_type") == edge_type]

    # ── Aggregations ──────────────────────────────────────────────────

    def stats(self) -> dict:
        """Return graph-wide statistics."""
        node_types: dict[str, int] = {}
        for n in self.nodes:
            t = n.get("entity_type", "unknown")
            node_types[t] = node_types.get(t, 0) + 1

        edge_types: dict[str, int] = {}
        for e in self.edges:
            t = e.get("edge_type", "unknown")
            edge_types[t] = edge_types.get(t, 0) + 1

        return {
            "total_nodes": len(self.nodes),
            "total_edges": len(self.edges),
            "node_types": dict(sorted(node_types.items(), key=lambda x: -x[1])),
            "edge_types": dict(sorted(edge_types.items(), key=lambda x: -x[1])),
            "isolated_count": len(self.isolated_nodes()),
            "most_connected": self.most_connected(5),
        }

    def get_summary(self) -> str:
        """Return a human-readable graph summary."""
        s = self.stats()
        if s["total_nodes"] == 0:
            return "Research Graph — empty (run ingestion to populate)"

        lines = [
            f"Research Graph — {s['total_nodes']} nodes, {s['total_edges']} edges, "
            f"{s['isolated_count']} isolated"
        ]

        if s["node_types"]:
            type_parts = [f"{t}: {c}" for t, c in list(s["node_types"].items())[:5]]
            lines.append(f"  Nodes: {', '.join(type_parts)}")

        if s["edge_types"]:
            edge_parts = [f"{t}: {c}" for t, c in list(s["edge_types"].items())[:5]]
            lines.append(f"  Edges: {', '.join(edge_parts)}")

        top = s.get("most_connected", [])
        if top:
            lines.append(f"  Most connected: {top[0].get('entity_id', '?')} ({top[0].get('connection_count', 0)} links)")

        return "\n".join(lines)
