"""
DriveAI Mac Factory — Progress Tracker

Tracks cycle-by-cycle progress. Detects trends.
"""

import time
from dataclasses import dataclass, field


@dataclass
class CycleRecord:
    cycle: int = 0
    errors_before: int = 0
    errors_after: int = 0
    actions_taken: list = field(default_factory=list)
    cost: float = 0.0
    duration_seconds: float = 0.0


class ProgressTracker:
    def __init__(self):
        self.cycles = []
        self.current_cycle = None
        self.cycle_start_time = None
        self.best_error_count = float('inf')
        self.best_cycle = -1

    def start_cycle(self, error_count: int):
        self.cycle_start_time = time.time()
        self.current_cycle = CycleRecord(
            cycle=len(self.cycles) + 1,
            errors_before=error_count
        )

    def end_cycle(self, error_count: int, cost: float = 0.0, actions: list = None):
        if not self.current_cycle:
            return
        self.current_cycle.errors_after = error_count
        self.current_cycle.cost = cost
        self.current_cycle.actions_taken = actions or []
        self.current_cycle.duration_seconds = (
            time.time() - self.cycle_start_time if self.cycle_start_time else 0
        )
        self.cycles.append(self.current_cycle)
        if error_count < self.best_error_count:
            self.best_error_count = error_count
            self.best_cycle = self.current_cycle.cycle
        self.current_cycle = None

    def get_trend(self) -> str:
        if len(self.cycles) < 2:
            return "unknown"
        history = [c.errors_after for c in self.cycles]

        # Oscillation: high-low-high pattern in last 4 cycles
        if len(history) >= 4:
            window = history[-4:]
            min_val = min(window)
            max_val = max(window)
            if min_val > 0 and max_val / max(min_val, 1) >= 1.5:
                increases = sum(1 for i in range(1, len(window)) if window[i] > window[i-1])
                decreases = sum(1 for i in range(1, len(window)) if window[i] < window[i-1])
                if increases >= 1 and decreases >= 1:
                    return "oscillating"

        # Plateau: same count for 3+ cycles
        if len(history) >= 3:
            last_3 = history[-3:]
            if max(last_3) - min(last_3) <= 2:
                return "plateau"

        if history[-1] < history[0] * 0.8:
            return "improving"
        if history[-1] > history[0]:
            return "worsening"

        return "plateau"

    def get_no_progress_count(self) -> int:
        count = 0
        for c in reversed(self.cycles):
            if c.errors_after > self.best_error_count:
                count += 1
            else:
                break
        return count

    def error_history(self) -> list:
        return [c.errors_after for c in self.cycles]

    def total_cost(self) -> float:
        return sum(c.cost for c in self.cycles)

    def total_duration(self) -> float:
        return sum(c.duration_seconds for c in self.cycles)

    def print_summary(self):
        trend_str = " -> ".join(str(e) for e in self.error_history())
        print(f"[Progress] {len(self.cycles)} cycles, best: {self.best_error_count} (cycle {self.best_cycle})")
        print(f"[Progress] Trend: {trend_str}")
        print(f"[Progress] Total: ${self.total_cost():.2f}, {self.total_duration():.0f}s")
        print(f"[Progress] Direction: {self.get_trend()}")
