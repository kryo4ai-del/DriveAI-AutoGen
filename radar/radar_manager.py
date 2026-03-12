# radar_manager.py
# Opportunity Radar — lightweight external signal intake and evaluation layer.
# Manages radar sources and hits, scores/classifies hits, and identifies
# which hits are promising enough for OpportunityAgent / Idea generation.

import json
import os
from datetime import date

_DIR = os.path.dirname(__file__)
_SOURCES_PATH = os.path.join(_DIR, "radar_sources.json")
_HITS_PATH = os.path.join(_DIR, "radar_hits.json")

VALID_SOURCE_CATEGORIES = (
    "product_hunt",
    "app_store",
    "hacker_news",
    "reddit",
    "twitter_x",
    "newsletter",
    "blog",
    "research_paper",
    "github_trending",
    "ai_directory",
    "marketplace",
    "competitor",
    "community",
    "manual",
)

VALID_HIT_CATEGORIES = (
    "new_product",
    "feature_pattern",
    "market_gap",
    "pricing_model",
    "tech_stack",
    "user_pain_point",
    "viral_concept",
    "monetization",
    "platform_shift",
    "regulation",
    "general",
)

VALID_HIT_STATUSES = (
    "new",
    "evaluated",
    "promising",
    "opportunity_created",
    "dismissed",
    "expired",
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


class RadarManager:
    """Manages radar sources and hits — create, score, classify, promote."""

    def __init__(self):
        self._sources_data = _load_json(_SOURCES_PATH)
        self._sources_data.setdefault("sources", [])
        self._hits_data = _load_json(_HITS_PATH)
        self._hits_data.setdefault("hits", [])

    def save(self) -> None:
        _save_json(_SOURCES_PATH, self._sources_data)
        _save_json(_HITS_PATH, self._hits_data)

    # ── Sources ──────────────────────────────────────────────────────────

    @property
    def sources(self) -> list[dict]:
        return self._sources_data["sources"]

    def _next_source_id(self) -> str:
        max_num = 0
        for s in self.sources:
            sid = s.get("source_id", "")
            if sid.startswith("RSRC-"):
                try:
                    max_num = max(max_num, int(sid.split("-")[1]))
                except (IndexError, ValueError):
                    pass
        return f"RSRC-{max_num + 1:03d}"

    def add_source(
        self,
        name: str,
        category: str,
        url: str = "",
        enabled: bool = True,
        notes: str = "",
    ) -> dict:
        if category not in VALID_SOURCE_CATEGORIES:
            raise ValueError(f"Invalid source category: {category}. Valid: {VALID_SOURCE_CATEGORIES}")

        source = {
            "source_id": self._next_source_id(),
            "name": name,
            "category": category,
            "url": url,
            "enabled": enabled,
            "notes": notes,
            "created_at": date.today().isoformat(),
        }
        self.sources.append(source)
        self.save()
        return source

    def get_source(self, source_id: str) -> dict | None:
        for s in self.sources:
            if s.get("source_id") == source_id:
                return s
        return None

    def update_source(self, source_id: str, **fields) -> dict | None:
        s = self.get_source(source_id)
        if not s:
            return None
        for key, value in fields.items():
            if key in s and key != "source_id":
                s[key] = value
        self.save()
        return s

    def toggle_source(self, source_id: str, enabled: bool) -> dict | None:
        return self.update_source(source_id, enabled=enabled)

    def enabled_sources(self) -> list[dict]:
        return [s for s in self.sources if s.get("enabled", True)]

    def by_category(self, category: str) -> list[dict]:
        return [s for s in self.sources if s.get("category") == category]

    # ── Hits ─────────────────────────────────────────────────────────────

    @property
    def hits(self) -> list[dict]:
        return self._hits_data["hits"]

    def _next_hit_id(self) -> str:
        max_num = 0
        for h in self.hits:
            hid = h.get("hit_id", "")
            if hid.startswith("RADAR-"):
                try:
                    max_num = max(max_num, int(hid.split("-")[1]))
                except (IndexError, ValueError):
                    pass
        return f"RADAR-{max_num + 1:03d}"

    def add_hit(
        self,
        title: str,
        category: str,
        source_id: str = "",
        summary: str = "",
        relevance_score: float = 0.5,
        potential_products: list[str] | None = None,
        potential_platforms: list[str] | None = None,
        notes: str = "",
    ) -> dict:
        if category not in VALID_HIT_CATEGORIES:
            raise ValueError(f"Invalid hit category: {category}. Valid: {VALID_HIT_CATEGORIES}")

        hit = {
            "hit_id": self._next_hit_id(),
            "source_id": source_id,
            "title": title,
            "summary": summary,
            "category": category,
            "relevance_score": max(0.0, min(1.0, relevance_score)),
            "potential_products": potential_products or [],
            "potential_platforms": potential_platforms or [],
            "status": "new",
            "detected_at": date.today().isoformat(),
            "notes": notes,
        }
        self.hits.append(hit)
        self.save()
        return hit

    def get_hit(self, hit_id: str) -> dict | None:
        for h in self.hits:
            if h.get("hit_id") == hit_id:
                return h
        return None

    def update_hit(self, hit_id: str, **fields) -> dict | None:
        h = self.get_hit(hit_id)
        if not h:
            return None
        for key, value in fields.items():
            if key in h and key != "hit_id":
                h[key] = value
        self.save()
        return h

    def transition(self, hit_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_HIT_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_HIT_STATUSES}")
        return self.update_hit(hit_id, status=new_status)

    def evaluate(self, hit_id: str) -> dict | None:
        return self.transition(hit_id, "evaluated")

    def mark_promising(self, hit_id: str) -> dict | None:
        return self.transition(hit_id, "promising")

    def dismiss(self, hit_id: str) -> dict | None:
        return self.transition(hit_id, "dismissed")

    def mark_opportunity_created(self, hit_id: str, opp_id: str = "") -> dict | None:
        h = self.get_hit(hit_id)
        if not h:
            return None
        h["status"] = "opportunity_created"
        if opp_id:
            h["notes"] = f"{h.get('notes', '')} -> {opp_id}".strip()
        self.save()
        return h

    # ── Scoring & Classification ─────────────────────────────────────────

    _CATEGORY_WEIGHTS = {
        "new_product": 0.80,
        "market_gap": 0.85,
        "user_pain_point": 0.80,
        "viral_concept": 0.75,
        "monetization": 0.70,
        "feature_pattern": 0.65,
        "pricing_model": 0.60,
        "tech_stack": 0.55,
        "platform_shift": 0.70,
        "regulation": 0.50,
        "general": 0.40,
    }

    def auto_score(self, hit_id: str) -> dict | None:
        """Compute relevance_score from category weight. Returns updated hit."""
        h = self.get_hit(hit_id)
        if not h:
            return None
        base = self._CATEGORY_WEIGHTS.get(h.get("category", "general"), 0.40)
        # Boost if multiple potential products
        products_boost = min(0.10, len(h.get("potential_products", [])) * 0.03)
        # Boost if multiple platforms
        platforms_boost = min(0.05, len(h.get("potential_platforms", [])) * 0.02)
        score = max(0.0, min(1.0, base + products_boost + platforms_boost))
        h["relevance_score"] = round(score, 2)
        self.save()
        return h

    def auto_score_all_new(self) -> list[dict]:
        """Score all new hits that haven't been scored yet."""
        scored = []
        for h in self.hits:
            if h.get("status") == "new" and h.get("relevance_score", 0.5) == 0.5:
                result = self.auto_score(h["hit_id"])
                if result:
                    scored.append(result)
        return scored

    # ── Queries ──────────────────────────────────────────────────────────

    def active_hits(self) -> list[dict]:
        return [h for h in self.hits if h.get("status") not in ("dismissed", "expired")]

    def promising_hits(self) -> list[dict]:
        return [h for h in self.hits if h.get("status") == "promising"]

    def high_relevance_hits(self, threshold: float = 0.70) -> list[dict]:
        return [h for h in self.active_hits() if h.get("relevance_score", 0) >= threshold]

    def hits_by_source(self, source_id: str) -> list[dict]:
        return [h for h in self.hits if h.get("source_id") == source_id]

    def hits_by_category(self, category: str) -> list[dict]:
        return [h for h in self.hits if h.get("category") == category]

    def hits_by_status(self, status: str) -> list[dict]:
        return [h for h in self.hits if h.get("status") == status]

    def actionable(self) -> list[dict]:
        """Hits ready for opportunity creation (evaluated or promising)."""
        return [h for h in self.hits if h.get("status") in ("evaluated", "promising")]

    def promotable(self, threshold: float = 0.70) -> list[dict]:
        """Hits that should become opportunities (promising + high score)."""
        return [
            h for h in self.hits
            if h.get("status") in ("evaluated", "promising")
            and h.get("relevance_score", 0) >= threshold
        ]

    # ── Summary ──────────────────────────────────────────────────────────

    def get_summary(self) -> str:
        total_sources = len(self.sources)
        enabled = len(self.enabled_sources())
        total_hits = len(self.hits)
        if total_hits == 0:
            return f"Radar -- sources: {total_sources} ({enabled} enabled)  hits: 0"

        active = self.active_hits()
        high = self.high_relevance_hits()
        promising = self.promising_hits()
        promotable = self.promotable()

        lines = [
            f"Radar -- sources: {total_sources} ({enabled} enabled)  "
            f"hits: {total_hits}  active: {len(active)}  "
            f"high-relevance: {len(high)}  promising: {len(promising)}"
        ]
        if promotable:
            lines.append(f"  PROMOTABLE: {len(promotable)} hits ready for opportunity creation")
        return "\n".join(lines)
