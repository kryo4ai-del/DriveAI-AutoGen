# cost_manager.py
# AICostMonitor — tracks AI usage costs, generates summaries, checks budgets.
# Lightweight JSON-based cost tracking for the AI App Factory.

import json
import os
from datetime import date, datetime

_DIR = os.path.dirname(__file__)
_USAGE_PATH = os.path.join(_DIR, "cost_usage.json")
_SUMMARY_PATH = os.path.join(_DIR, "cost_summary.json")
_BUDGETS_PATH = os.path.join(os.path.dirname(_DIR), "config", "cost_budgets.json")


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


class CostManager:
    """Tracks AI usage costs — log entries, compute summaries, check budgets."""

    def __init__(self):
        self._usage_data = _load_json(_USAGE_PATH)
        self._usage_data.setdefault("usage", [])
        self._summary_data = _load_json(_SUMMARY_PATH)
        self._summary_data.setdefault("summaries", [])

    def save(self) -> None:
        _save_json(_USAGE_PATH, self._usage_data)
        _save_json(_SUMMARY_PATH, self._summary_data)

    # ── Usage Logging ────────────────────────────────────────────────────

    @property
    def usage(self) -> list[dict]:
        return self._usage_data["usage"]

    @property
    def summaries(self) -> list[dict]:
        return self._summary_data["summaries"]

    def _next_usage_id(self) -> str:
        max_num = 0
        for u in self.usage:
            uid = u.get("usage_id", "")
            if uid.startswith("COST-"):
                try:
                    max_num = max(max_num, int(uid.split("-")[1]))
                except (IndexError, ValueError):
                    pass
        return f"COST-{max_num + 1:04d}"

    def log_usage(
        self,
        agent_name: str,
        model_used: str,
        task_type: str,
        prompt_tokens: int,
        completion_tokens: int,
        estimated_cost: float,
        project: str = "factory-core",
        notes: str = "",
    ) -> dict:
        """Log a single AI usage event."""
        entry = {
            "usage_id": self._next_usage_id(),
            "agent_name": agent_name,
            "model_used": model_used,
            "task_type": task_type,
            "prompt_tokens": prompt_tokens,
            "completion_tokens": completion_tokens,
            "total_tokens": prompt_tokens + completion_tokens,
            "estimated_cost": round(estimated_cost, 6),
            "project": project,
            "timestamp": datetime.utcnow().isoformat(timespec="seconds") + "Z",
            "notes": notes,
        }
        self.usage.append(entry)
        _save_json(_USAGE_PATH, self._usage_data)
        return entry

    # ── Queries ──────────────────────────────────────────────────────────

    def usage_today(self) -> list[dict]:
        today = date.today().isoformat()
        return [u for u in self.usage if u.get("timestamp", "").startswith(today)]

    def usage_by_date(self, target_date: str) -> list[dict]:
        return [u for u in self.usage if u.get("timestamp", "").startswith(target_date)]

    def usage_by_agent(self, agent_name: str) -> list[dict]:
        return [u for u in self.usage if u.get("agent_name") == agent_name]

    def usage_by_model(self, model: str) -> list[dict]:
        return [u for u in self.usage if u.get("model_used") == model]

    def usage_by_project(self, project: str) -> list[dict]:
        return [u for u in self.usage if u.get("project") == project]

    # ── Aggregations ─────────────────────────────────────────────────────

    def total_cost(self, entries: list[dict] | None = None) -> float:
        items = entries if entries is not None else self.usage
        return round(sum(u.get("estimated_cost", 0) for u in items), 6)

    def total_tokens(self, entries: list[dict] | None = None) -> int:
        items = entries if entries is not None else self.usage
        return sum(u.get("total_tokens", 0) for u in items)

    def cost_today(self) -> float:
        return self.total_cost(self.usage_today())

    def tokens_today(self) -> int:
        return self.total_tokens(self.usage_today())

    def cost_by_agent(self, entries: list[dict] | None = None) -> dict[str, float]:
        items = entries if entries is not None else self.usage
        result: dict[str, float] = {}
        for u in items:
            agent = u.get("agent_name", "unknown")
            result[agent] = round(result.get(agent, 0) + u.get("estimated_cost", 0), 6)
        return dict(sorted(result.items(), key=lambda x: -x[1]))

    def cost_by_model(self, entries: list[dict] | None = None) -> dict[str, float]:
        items = entries if entries is not None else self.usage
        result: dict[str, float] = {}
        for u in items:
            model = u.get("model_used", "unknown")
            result[model] = round(result.get(model, 0) + u.get("estimated_cost", 0), 6)
        return dict(sorted(result.items(), key=lambda x: -x[1]))

    def cost_by_project(self, entries: list[dict] | None = None) -> dict[str, float]:
        items = entries if entries is not None else self.usage
        result: dict[str, float] = {}
        for u in items:
            proj = u.get("project", "unknown")
            result[proj] = round(result.get(proj, 0) + u.get("estimated_cost", 0), 6)
        return dict(sorted(result.items(), key=lambda x: -x[1]))

    def tokens_by_agent(self, entries: list[dict] | None = None) -> dict[str, int]:
        items = entries if entries is not None else self.usage
        result: dict[str, int] = {}
        for u in items:
            agent = u.get("agent_name", "unknown")
            result[agent] = result.get(agent, 0) + u.get("total_tokens", 0)
        return dict(sorted(result.items(), key=lambda x: -x[1]))

    # ── Budget Checks ────────────────────────────────────────────────────

    def load_budgets(self) -> dict:
        """Load budget configuration."""
        return _load_json(_BUDGETS_PATH)

    def check_budget(self) -> dict:
        """
        Check current spend against budget limits.
        Returns: {"daily": {...}, "monthly": {...}, "alerts": [...]}
        """
        budgets = self.load_budgets()
        daily_budget = budgets.get("daily_budget", 0)
        monthly_budget = budgets.get("monthly_budget", 0)

        today_cost = self.cost_today()
        today_str = date.today().isoformat()
        month_prefix = today_str[:7]  # YYYY-MM
        month_entries = [u for u in self.usage if u.get("timestamp", "").startswith(month_prefix)]
        month_cost = self.total_cost(month_entries)

        alerts = []

        daily_status = {
            "budget": daily_budget,
            "spent": round(today_cost, 4),
            "remaining": round(max(0, daily_budget - today_cost), 4) if daily_budget else None,
            "utilization": round(today_cost / daily_budget * 100, 1) if daily_budget else 0,
            "exceeded": today_cost > daily_budget if daily_budget else False,
        }

        monthly_status = {
            "budget": monthly_budget,
            "spent": round(month_cost, 4),
            "remaining": round(max(0, monthly_budget - month_cost), 4) if monthly_budget else None,
            "utilization": round(month_cost / monthly_budget * 100, 1) if monthly_budget else 0,
            "exceeded": month_cost > monthly_budget if monthly_budget else False,
        }

        if daily_status["exceeded"]:
            alerts.append(f"DAILY BUDGET EXCEEDED: ${today_cost:.4f} / ${daily_budget:.2f}")
        elif daily_budget and daily_status["utilization"] >= 80:
            alerts.append(f"Daily budget 80%+ used: ${today_cost:.4f} / ${daily_budget:.2f}")

        if monthly_status["exceeded"]:
            alerts.append(f"MONTHLY BUDGET EXCEEDED: ${month_cost:.4f} / ${monthly_budget:.2f}")
        elif monthly_budget and monthly_status["utilization"] >= 80:
            alerts.append(f"Monthly budget 80%+ used: ${month_cost:.4f} / ${monthly_budget:.2f}")

        return {
            "daily": daily_status,
            "monthly": monthly_status,
            "alerts": alerts,
        }

    # ── Daily Summary ────────────────────────────────────────────────────

    def generate_daily_summary(self, target_date: str = "") -> dict:
        """Generate a cost summary for a specific date (defaults to today)."""
        if not target_date:
            target_date = date.today().isoformat()

        # Check if already generated
        for s in self.summaries:
            if s.get("date") == target_date:
                return s

        entries = self.usage_by_date(target_date)
        total = self.total_cost(entries)
        tokens = self.total_tokens(entries)
        by_agent = self.cost_by_agent(entries)
        by_model = self.cost_by_model(entries)
        by_project = self.cost_by_project(entries)

        summary = {
            "date": target_date,
            "total_cost": round(total, 4),
            "total_tokens": tokens,
            "total_requests": len(entries),
            "cost_by_agent": by_agent,
            "cost_by_model": by_model,
            "cost_by_project": by_project,
            "top_agent": list(by_agent.keys())[0] if by_agent else None,
            "top_model": list(by_model.keys())[0] if by_model else None,
        }

        self.summaries.append(summary)
        _save_json(_SUMMARY_PATH, self._summary_data)
        return summary

    # ── Summary String ───────────────────────────────────────────────────

    def get_summary(self) -> str:
        total = len(self.usage)
        if total == 0:
            return "AI Costs — no usage recorded"

        all_cost = self.total_cost()
        today_cost = self.cost_today()
        today_tokens = self.tokens_today()
        budget = self.check_budget()

        lines = [
            f"AI Costs — {total} requests | "
            f"today: ${today_cost:.4f} ({today_tokens:,} tokens) | "
            f"total: ${all_cost:.4f}"
        ]

        if budget["alerts"]:
            for alert in budget["alerts"]:
                lines.append(f"  ALERT: {alert}")

        return "\n".join(lines)
