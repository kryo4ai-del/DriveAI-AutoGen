"""Cost tracking for external service calls.

Complements the existing ChainTracker (LLM costs) with tracking for
image/sound/video/animation service calls. Logs per-run, per-project,
per-category costs to JSON files.
"""

import json
import logging
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Optional
from datetime import datetime, date

logger = logging.getLogger(__name__)


@dataclass
class ServiceCallLog:
    """Single service call record."""
    timestamp: str
    service_id: str
    category: str
    cost: float
    duration_ms: int
    success: bool
    specs: dict = field(default_factory=dict)
    error: str = ""


@dataclass
class BudgetConfig:
    """Budget limits for cost control."""
    per_run: float = 5.0
    per_project_daily: float = 20.0
    per_category: dict = field(default_factory=lambda: {
        "image": 10.0,
        "sound": 5.0,
        "video": 10.0,
        "animation": 2.0,
    })
    alert_threshold: float = 0.8


class ServiceCostTracker:
    """Tracks and persists costs for all external service calls."""

    def __init__(self, log_dir: str = None, budget: BudgetConfig = None):
        if log_dir is None:
            log_dir = str(Path(__file__).parent.parent / "service_costs")
        self._log_dir = Path(log_dir)
        self._log_dir.mkdir(parents=True, exist_ok=True)
        self._budget = budget or BudgetConfig()

        self._current_run_id: Optional[str] = None
        self._current_project: Optional[str] = None
        self._started: Optional[str] = None
        self._calls: list[ServiceCallLog] = []
        self._alerts: list[str] = []

    # ------------------------------------------------------------------
    # Run lifecycle
    # ------------------------------------------------------------------

    def start_run(self, run_id: str, project: str = "unknown"):
        self._current_run_id = run_id
        self._current_project = project
        self._started = datetime.now().isoformat(timespec="seconds")
        self._calls = []
        self._alerts = []

    def record_call(self, result, category: str, specs: dict = None) -> bool:
        entry = ServiceCallLog(
            timestamp=datetime.now().isoformat(timespec="seconds"),
            service_id=result.service_id,
            category=category,
            cost=result.cost if result.success else 0.0,
            duration_ms=result.duration_ms,
            success=result.success,
            specs=specs or {},
            error=result.error_message if not result.success else "",
        )
        self._calls.append(entry)

        # Budget checks
        run_cost = self.get_run_cost()
        run_pct = run_cost / self._budget.per_run if self._budget.per_run > 0 else 0
        if run_pct >= 1.0:
            msg = f"RUN BUDGET EXCEEDED: ${run_cost:.2f}/${self._budget.per_run:.2f}"
            logger.warning(msg)
            self._alerts.append(msg)
            return False
        elif run_pct >= self._budget.alert_threshold:
            msg = f"Run budget warning: ${run_cost:.2f}/${self._budget.per_run:.2f} ({run_pct:.0%})"
            logger.warning(msg)
            self._alerts.append(msg)

        cat_cost = self.get_category_cost(category)
        cat_limit = self._budget.per_category.get(category, 999)
        cat_pct = cat_cost / cat_limit if cat_limit > 0 else 0
        if cat_pct >= 1.0:
            msg = f"CATEGORY BUDGET EXCEEDED [{category}]: ${cat_cost:.2f}/${cat_limit:.2f}"
            logger.warning(msg)
            self._alerts.append(msg)
        elif cat_pct >= self._budget.alert_threshold:
            msg = f"Category budget warning [{category}]: ${cat_cost:.2f}/${cat_limit:.2f} ({cat_pct:.0%})"
            logger.warning(msg)
            self._alerts.append(msg)

        return True

    def check_budget(self, category: str, estimated_cost: float) -> tuple[bool, str]:
        run_cost = self.get_run_cost()
        new_run = run_cost + estimated_cost
        if new_run > self._budget.per_run:
            return False, f"run budget exceeded: ${run_cost:.2f}+${estimated_cost:.2f} > ${self._budget.per_run:.2f}"

        cat_cost = self.get_category_cost(category)
        cat_limit = self._budget.per_category.get(category, 999)
        new_cat = cat_cost + estimated_cost
        if new_cat > cat_limit:
            return False, f"category '{category}' budget exceeded: ${cat_cost:.2f}+${estimated_cost:.2f} > ${cat_limit:.2f}"

        run_pct = new_run / self._budget.per_run if self._budget.per_run > 0 else 0
        if run_pct >= self._budget.alert_threshold:
            return True, f"warning: approaching run budget limit ({run_pct:.0%})"

        return True, "within budget"

    def end_run(self) -> dict:
        summary = self._build_summary()
        log = {
            "run_id": self._current_run_id,
            "project": self._current_project,
            "started": self._started,
            "ended": datetime.now().isoformat(timespec="seconds"),
            "calls": [asdict(c) for c in self._calls],
            "summary": summary,
        }
        if self._current_run_id:
            path = self._log_dir / f"{self._current_run_id}_service_costs.json"
            try:
                path.write_text(json.dumps(log, indent=2, ensure_ascii=False), encoding="utf-8")
            except OSError as e:
                logger.error("Failed to save cost log: %s", e)
        return summary

    # ------------------------------------------------------------------
    # Queries
    # ------------------------------------------------------------------

    def get_run_cost(self) -> float:
        return sum(c.cost for c in self._calls)

    def get_category_cost(self, category: str) -> float:
        return sum(c.cost for c in self._calls if c.category == category)

    def get_project_daily_cost(self, project: str = None) -> float:
        project = project or self._current_project or "unknown"
        today = date.today().isoformat()
        total = 0.0
        for path in self._log_dir.glob("*_service_costs.json"):
            try:
                log = json.loads(path.read_text(encoding="utf-8"))
                if log.get("project") == project and log.get("started", "")[:10] == today:
                    total += log.get("summary", {}).get("total_cost", 0.0)
            except (json.JSONDecodeError, OSError):
                continue
        # Add current run if same project
        if self._current_project == project:
            total += self.get_run_cost()
        return total

    def get_alerts(self) -> list[str]:
        return list(self._alerts)

    # ------------------------------------------------------------------
    # Display
    # ------------------------------------------------------------------

    def get_summary(self, run_id: str = None) -> str:
        if run_id:
            path = self._log_dir / f"{run_id}_service_costs.json"
            if path.exists():
                log = json.loads(path.read_text(encoding="utf-8"))
                return self._format_summary(log.get("summary", {}), run_id, log.get("project", "?"))
            return f"Log not found: {path}"

        summary = self._build_summary()
        return self._format_summary(summary, self._current_run_id or "?", self._current_project or "?")

    def _format_summary(self, summary: dict, run_id: str, project: str) -> str:
        cats = summary.get("costs_by_category", {})
        total = summary.get("total_cost", 0.0)
        total_calls = summary.get("total_calls", 0)
        alerts = summary.get("alerts", [])
        budget = self._budget

        lines = [
            "=" * 47,
            f"SERVICE COST SUMMARY - Run: {run_id}",
            f"Project: {project}",
            "-" * 47,
            f"{'Category':<12} {'Calls':>6} {'Cost':>10} {'Budget':>10} {'Used':>8}",
        ]
        for cat in ["image", "sound", "video", "animation"]:
            cost = cats.get(cat, 0.0)
            calls = sum(1 for c in self._calls if c.category == cat) if not run_id else 0
            cat_budget = budget.per_category.get(cat, 0)
            pct = (cost / cat_budget * 100) if cat_budget > 0 else 0
            lines.append(f"{cat:<12} {calls:>6} ${cost:>8.2f} ${cat_budget:>8.2f} {pct:>6.1f}%")
        lines.append("-" * 47)
        run_pct = (total / budget.per_run * 100) if budget.per_run > 0 else 0
        lines.append(f"{'TOTAL':<12} {total_calls:>6} ${total:>8.2f} ${budget.per_run:>8.2f} {run_pct:>6.1f}%")
        lines.append("-" * 47)
        lines.append(f"Alerts: {', '.join(alerts) if alerts else 'None'}")
        lines.append("=" * 47)
        return "\n".join(lines)

    # ------------------------------------------------------------------
    # Log file access
    # ------------------------------------------------------------------

    @staticmethod
    def load_log(log_path: str) -> dict:
        try:
            return json.loads(Path(log_path).read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError) as e:
            logger.error("Failed to load log: %s", e)
            return {}

    def get_all_logs(self) -> list[dict]:
        logs = []
        for path in sorted(self._log_dir.glob("*_service_costs.json"), reverse=True):
            try:
                logs.append(json.loads(path.read_text(encoding="utf-8")))
            except (json.JSONDecodeError, OSError):
                continue
        return logs

    def get_total_spend(self) -> dict:
        totals: dict[str, float] = {}
        for log in self.get_all_logs():
            for cat, cost in log.get("summary", {}).get("costs_by_category", {}).items():
                totals[cat] = totals.get(cat, 0.0) + cost
        totals["grand_total"] = sum(totals.values())
        return totals

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _build_summary(self) -> dict:
        costs_by_cat: dict[str, float] = {}
        ok = 0
        fail = 0
        for c in self._calls:
            costs_by_cat[c.category] = costs_by_cat.get(c.category, 0.0) + c.cost
            if c.success:
                ok += 1
            else:
                fail += 1
        return {
            "total_calls": len(self._calls),
            "successful_calls": ok,
            "failed_calls": fail,
            "costs_by_category": costs_by_cat,
            "total_cost": sum(costs_by_cat.values()),
            "alerts": list(self._alerts),
        }
