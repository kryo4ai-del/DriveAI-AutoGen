"""
DriveAI Mac Factory — Safety Guard

Enforces three limits on every job:
1. Budget limit ($2.00 default) — stops job when cost exceeded
2. Timeout (30min default) — stops job when time exceeded
3. Heartbeat (5min default) — stops job when nobody is polling for status

All costs are persisted to disk — survive server restarts.
Cost log: mac_factory/costs/{date}.json
"""

import os
import json
import time
import threading
from pathlib import Path
from datetime import datetime, timezone


_FILE_LOCK = threading.Lock()


class SafetyGuard:
    def __init__(self, job_id: str, budget_limit: float = 2.00,
                 timeout_minutes: int = 30, heartbeat_timeout_minutes: int = 5):
        self.job_id = job_id
        self.budget_limit = budget_limit
        self.timeout_minutes = timeout_minutes
        self.heartbeat_timeout_minutes = heartbeat_timeout_minutes

        self.total_cost = 0.0
        self.llm_call_count = 0
        self.start_time = time.time()
        self.last_heartbeat = time.time()
        self.stopped = False
        self.stop_reason = ""

        self.cost_log_dir = Path(__file__).parent.parent / "costs"
        self.cost_log_dir.mkdir(parents=True, exist_ok=True)

    def check(self) -> bool:
        """Returns True if safe to continue, False if any limit reached."""
        if self.total_cost >= self.budget_limit:
            self.stopped = True
            self.stop_reason = f"BUDGET: ${self.total_cost:.2f} >= ${self.budget_limit:.2f}"
            print(f"[Safety Guard] {self.stop_reason}")
            return False

        elapsed_minutes = (time.time() - self.start_time) / 60
        if elapsed_minutes >= self.timeout_minutes:
            self.stopped = True
            self.stop_reason = f"TIMEOUT: {elapsed_minutes:.0f}min >= {self.timeout_minutes}min"
            print(f"[Safety Guard] {self.stop_reason}")
            return False

        heartbeat_age_minutes = (time.time() - self.last_heartbeat) / 60
        if heartbeat_age_minutes >= self.heartbeat_timeout_minutes:
            self.stopped = True
            self.stop_reason = f"HEARTBEAT: No poll for {heartbeat_age_minutes:.0f}min >= {self.heartbeat_timeout_minutes}min"
            print(f"[Safety Guard] {self.stop_reason}")
            return False

        return True

    def record_llm_call(self, model: str, tokens_in: int, tokens_out: int, cost: float):
        """Records an LLM call with its cost. Persists to daily cost log file immediately."""
        self.total_cost += cost
        self.llm_call_count += 1
        self._persist_cost(model, tokens_in, tokens_out, cost)
        print(f"[Safety Guard] LLM call #{self.llm_call_count}: ${cost:.4f} (total: ${self.total_cost:.2f}/{self.budget_limit:.2f})")

    def heartbeat(self):
        """Called when Windows polls GET /status/{job_id}."""
        self.last_heartbeat = time.time()

    def get_status(self) -> dict:
        """Returns current safety status."""
        elapsed = (time.time() - self.start_time) / 60
        heartbeat_age = (time.time() - self.last_heartbeat) / 60
        return {
            "budget_used": round(self.total_cost, 2),
            "budget_limit": self.budget_limit,
            "budget_remaining": round(self.budget_limit - self.total_cost, 2),
            "elapsed_minutes": round(elapsed, 1),
            "timeout_minutes": self.timeout_minutes,
            "heartbeat_age_minutes": round(heartbeat_age, 1),
            "llm_calls": self.llm_call_count,
            "stopped": self.stopped,
            "stop_reason": self.stop_reason
        }

    def _persist_cost(self, model: str, tokens_in: int, tokens_out: int, cost: float):
        """Appends cost entry to daily log file. Thread-safe."""
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        log_file = self.cost_log_dir / f"{today}.json"

        entry = {
            "time": datetime.now(timezone.utc).strftime("%H:%M:%S"),
            "job_id": self.job_id,
            "model": model,
            "tokens_in": tokens_in,
            "tokens_out": tokens_out,
            "cost": round(cost, 6)
        }

        with _FILE_LOCK:
            data = {"date": today, "total": 0.0, "calls": []}
            if log_file.exists():
                try:
                    with open(log_file) as f:
                        data = json.load(f)
                except (json.JSONDecodeError, IOError):
                    backup = str(log_file) + ".bak"
                    try:
                        os.rename(log_file, backup)
                    except OSError:
                        pass
                    data = {"date": today, "total": 0.0, "calls": []}

            data["calls"].append(entry)
            data["total"] = round(sum(c.get("cost", 0) for c in data["calls"]), 4)

            with open(log_file, "w") as f:
                json.dump(data, f, indent=2)

    @staticmethod
    def get_daily_total(date_str: str = None) -> float:
        """Returns total cost for a given date (default: today)."""
        if not date_str:
            date_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")

        cost_dir = Path(__file__).parent.parent / "costs"
        log_file = cost_dir / f"{date_str}.json"

        if not log_file.exists():
            return 0.0

        try:
            with open(log_file) as f:
                data = json.load(f)
            return data.get("total", 0.0)
        except Exception:
            return 0.0

    @staticmethod
    def get_monthly_total(year_month: str = None) -> float:
        """Returns total cost for a given month (e.g. '2026-04')."""
        if not year_month:
            year_month = datetime.now(timezone.utc).strftime("%Y-%m")

        cost_dir = Path(__file__).parent.parent / "costs"
        total = 0.0

        for log_file in cost_dir.glob(f"{year_month}-*.json"):
            try:
                with open(log_file) as f:
                    data = json.load(f)
                total += data.get("total", 0.0)
            except Exception:
                continue

        return round(total, 2)

    def print_summary(self):
        """Prints safety summary at end of job."""
        elapsed = (time.time() - self.start_time) / 60
        pct = (self.total_cost / self.budget_limit * 100) if self.budget_limit > 0 else 0

        print(f"[Safety Guard] Job: {self.job_id}")
        print(f"[Safety Guard] Cost: ${self.total_cost:.2f} / ${self.budget_limit:.2f} ({pct:.1f}%)")
        print(f"[Safety Guard] Duration: {elapsed:.1f}min / {self.timeout_minutes}min")
        print(f"[Safety Guard] LLM Calls: {self.llm_call_count}")
        if self.stopped:
            print(f"[Safety Guard] Status: STOPPED — {self.stop_reason}")
        else:
            print(f"[Safety Guard] Status: OK")
