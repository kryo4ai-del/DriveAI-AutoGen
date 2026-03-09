# opportunity_manager.py
# Manages opportunity records — CRUD, querying, and idea intake integration.

import json
import os
from datetime import date

_OPP_DIR = os.path.dirname(__file__)
_STORE_PATH = os.path.join(_OPP_DIR, "opportunity_store.json")

VALID_CATEGORIES = (
    "new_api",
    "ai_capability",
    "platform_feature",
    "developer_trend",
    "market_gap",
    "ecosystem_shift",
    "monetization",
)

VALID_COMPLEXITIES = ("low", "medium", "high", "very_high")

VALID_RELEVANCES = ("low", "medium", "high", "critical")

VALID_STATUSES = (
    "new",
    "evaluated",
    "accepted",
    "idea_created",
    "rejected",
    "deferred",
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


class OpportunityManager:
    """Manages opportunity records — create, update, query, and convert to ideas."""

    def __init__(self):
        self.data = _load_json(_STORE_PATH)
        self.data.setdefault("opportunities", [])

    def save(self) -> None:
        _save_json(_STORE_PATH, self.data)

    @property
    def opportunities(self) -> list[dict]:
        return self.data["opportunities"]

    def _next_id(self) -> str:
        max_num = 0
        for opp in self.opportunities:
            id_str = opp.get("opportunity_id", "")
            if id_str.startswith("OPP-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"OPP-{max_num + 1:03d}"

    def add_opportunity(
        self,
        title: str,
        category: str,
        summary: str = "",
        potential_products: list[str] | None = None,
        market_relevance: str = "medium",
        complexity: str = "medium",
        suggested_next_step: str = "",
        linked_watch_event: str = "",
        notes: str = "",
    ) -> dict:
        if category not in VALID_CATEGORIES:
            raise ValueError(f"Invalid category: {category}. Valid: {VALID_CATEGORIES}")
        if market_relevance not in VALID_RELEVANCES:
            raise ValueError(f"Invalid relevance: {market_relevance}. Valid: {VALID_RELEVANCES}")
        if complexity not in VALID_COMPLEXITIES:
            raise ValueError(f"Invalid complexity: {complexity}. Valid: {VALID_COMPLEXITIES}")

        opp = {
            "opportunity_id": self._next_id(),
            "title": title,
            "category": category,
            "summary": summary,
            "potential_products": potential_products or [],
            "market_relevance": market_relevance,
            "complexity": complexity,
            "suggested_next_step": suggested_next_step,
            "linked_watch_event": linked_watch_event,
            "status": "new",
            "detected_at": date.today().isoformat(),
            "notes": notes,
        }
        self.opportunities.append(opp)
        self.save()
        return opp

    def get_opportunity(self, opp_id: str) -> dict | None:
        for opp in self.opportunities:
            if opp.get("opportunity_id") == opp_id:
                return opp
        return None

    def update_opportunity(self, opp_id: str, **fields) -> dict | None:
        opp = self.get_opportunity(opp_id)
        if not opp:
            return None
        for key, value in fields.items():
            if key in opp and key != "opportunity_id":
                opp[key] = value
        self.save()
        return opp

    def transition(self, opp_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_STATUSES}")
        return self.update_opportunity(opp_id, status=new_status)

    def evaluate(self, opp_id: str) -> dict | None:
        return self.transition(opp_id, "evaluated")

    def accept(self, opp_id: str) -> dict | None:
        return self.transition(opp_id, "accepted")

    def reject(self, opp_id: str) -> dict | None:
        return self.transition(opp_id, "rejected")

    def defer(self, opp_id: str) -> dict | None:
        return self.transition(opp_id, "deferred")

    def mark_idea_created(self, opp_id: str, idea_id: str = "") -> dict | None:
        opp = self.get_opportunity(opp_id)
        if not opp:
            return None
        opp["status"] = "idea_created"
        if idea_id:
            opp["notes"] = f"{opp.get('notes', '')} → {idea_id}".strip()
        self.save()
        return opp

    def by_category(self, category: str) -> list[dict]:
        return [o for o in self.opportunities if o.get("category") == category]

    def by_status(self, status: str) -> list[dict]:
        return [o for o in self.opportunities if o.get("status") == status]

    def by_relevance(self, relevance: str) -> list[dict]:
        return [o for o in self.opportunities if o.get("market_relevance") == relevance]

    def active(self) -> list[dict]:
        """Return opportunities not yet rejected or deferred."""
        return [o for o in self.opportunities if o.get("status") not in ("rejected", "deferred")]

    def actionable(self) -> list[dict]:
        """Return opportunities ready for idea creation (evaluated or accepted)."""
        return [o for o in self.opportunities if o.get("status") in ("evaluated", "accepted")]

    def get_summary(self) -> str:
        total = len(self.opportunities)
        if total == 0:
            return "Opportunities -- total: 0"
        active = self.active()
        by_cat = {}
        for opp in active:
            c = opp.get("category", "?")
            by_cat[c] = by_cat.get(c, 0) + 1
        cat_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_cat.items()))
        actionable = len(self.actionable())
        lines = [f"Opportunities -- total: {total}  active: {len(active)}  actionable: {actionable}  ({cat_str})"]
        high = [o for o in active if o.get("market_relevance") in ("high", "critical")]
        if high:
            lines.append(f"  HIGH RELEVANCE: {len(high)} opportunities worth evaluating")
        return "\n".join(lines)
