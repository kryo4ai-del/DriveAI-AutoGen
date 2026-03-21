"""Chain Run Tracker — records per-run model assignments + results for Chain Optimizer."""
import json
import os
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path

_DIR = Path(__file__).parent
_RUNS_DIR = _DIR / "chain_runs"


@dataclass
class AgentRunRecord:
    agent_name: str = ""
    model: str = ""
    provider: str = ""
    tokens_in: int = 0
    tokens_out: int = 0
    cost_usd: float = 0.0
    pass_name: str = ""


@dataclass
class ChainRunRecord:
    run_id: str = ""
    project: str = ""
    line: str = ""
    profile: str = ""
    agents: list[AgentRunRecord] = field(default_factory=list)
    total_cost: float = 0.0
    blocking_errors: int = 0
    total_errors: int = 0
    repair_cost: float = 0.0
    final_errors: int = 0
    outcome: str = "pending"
    timestamp: str = ""


class ChainTracker:
    """Records per-run chain data for the Chain Cost Optimizer."""

    def __init__(self):
        self.current_run: ChainRunRecord | None = None
        _RUNS_DIR.mkdir(parents=True, exist_ok=True)

    def start_run(self, run_id: str, project: str, line: str, profile: str):
        self.current_run = ChainRunRecord(
            run_id=run_id, project=project, line=line, profile=profile,
            timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        )

    def record_agent(self, agent_name: str, model: str, provider: str,
                     tokens_in: int, tokens_out: int, cost: float, pass_name: str):
        if not self.current_run:
            return
        self.current_run.agents.append(AgentRunRecord(
            agent_name=agent_name, model=model, provider=provider,
            tokens_in=tokens_in, tokens_out=tokens_out, cost_usd=cost,
            pass_name=pass_name,
        ))

    def finish_run(self, blocking_errors: int = 0, total_errors: int = 0,
                   repair_cost: float = 0.0, final_errors: int = 0):
        if not self.current_run:
            return
        run = self.current_run
        run.blocking_errors = blocking_errors
        run.total_errors = total_errors
        run.repair_cost = repair_cost
        run.final_errors = final_errors
        run.total_cost = sum(a.cost_usd for a in run.agents) + repair_cost
        run.outcome = "clean" if final_errors == 0 else ("partial" if final_errors < blocking_errors else "failed")
        self._save(run)
        self.current_run = None

    def _save(self, run: ChainRunRecord):
        path = _RUNS_DIR / f"{run.project}_runs.json"
        runs = []
        if path.is_file():
            try:
                runs = json.loads(path.read_text(encoding="utf-8"))
            except Exception:
                runs = []
        runs.append(asdict(run))
        # Keep last 100 runs
        if len(runs) > 100:
            runs = runs[-100:]
        path.write_text(json.dumps(runs, indent=2), encoding="utf-8")

    def get_runs(self, project: str, limit: int = 20) -> list[dict]:
        path = _RUNS_DIR / f"{project}_runs.json"
        if not path.is_file():
            return []
        try:
            runs = json.loads(path.read_text(encoding="utf-8"))
            return runs[-limit:]
        except Exception:
            return []

    def get_chain_stats(self, project: str) -> dict:
        runs = self.get_runs(project, limit=50)
        if not runs:
            return {"runs": 0}
        costs = [r.get("total_cost", 0) for r in runs]
        errors = [r.get("final_errors", 0) for r in runs]
        return {
            "runs": len(runs),
            "avg_cost": sum(costs) / len(costs),
            "avg_final_errors": sum(errors) / len(errors),
            "total_cost": sum(costs),
            "outcomes": {r.get("outcome", "?"): 0 for r in runs},
        }
