"""Cost Tracker — Tracks costs per agent call and iteration.

In-memory tracker; accumulated cost is persisted via LDO.meta.accumulated_cost.
"""

from __future__ import annotations

from datetime import datetime, timezone


class CostTracker:
    """Tracks costs per agent call and iteration."""

    def __init__(self) -> None:
        self.accumulated_cost: float = 0.0
        self.cost_log: list[dict] = []

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def add_cost(self, agent_id: str, cost: float, iteration: int) -> None:
        """Log cost of an agent call."""
        self.accumulated_cost += cost
        self.cost_log.append({
            "iteration": iteration,
            "agent_id": agent_id,
            "cost": cost,
            "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        })

    def get_total(self) -> float:
        """Return accumulated total cost."""
        return self.accumulated_cost

    def get_cost_per_iteration(self) -> dict[int, float]:
        """Return cost per iteration: {iteration: total_cost}."""
        result: dict[int, float] = {}
        for entry in self.cost_log:
            it = entry["iteration"]
            result[it] = result.get(it, 0.0) + entry["cost"]
        return result

    def check_budget(self, threshold: float) -> dict:
        """Check budget status.

        Returns dict with over_budget, total, threshold, remaining,
        cost_per_iteration_avg.
        """
        per_iter = self.get_cost_per_iteration()
        n_iters = len(per_iter)
        avg = self.accumulated_cost / n_iters if n_iters > 0 else 0.0

        return {
            "over_budget": self.accumulated_cost >= threshold,
            "total": self.accumulated_cost,
            "threshold": threshold,
            "remaining": max(0.0, threshold - self.accumulated_cost),
            "cost_per_iteration_avg": avg,
        }

    def get_cost_report(self) -> str:
        """Return a textual cost summary."""
        per_iter = self.get_cost_per_iteration()
        n_iters = len(per_iter)
        avg = self.accumulated_cost / n_iters if n_iters > 0 else 0.0

        lines = [
            "=== Cost Report ===",
            f"Total: ${self.accumulated_cost:.4f}",
            f"Iterations: {n_iters}",
            f"Avg per iteration: ${avg:.4f}",
        ]

        if per_iter:
            lines.append("")
            lines.append("Per iteration:")
            for it in sorted(per_iter.keys()):
                agents = [
                    e["agent_id"] for e in self.cost_log if e["iteration"] == it
                ]
                agent_str = ", ".join(sorted(set(agents)))
                lines.append(f"  Iteration {it}: ${per_iter[it]:.4f} ({agent_str})")

        return "\n".join(lines)

    def reset(self) -> None:
        """Reset tracker (for tests)."""
        self.accumulated_cost = 0.0
        self.cost_log.clear()
