"""Chain Cost Optimizer — finds optimal model combination across pipeline."""
import json
import os
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path

from .model_registry import ModelRegistry
from .chain_tracker import ChainTracker
from .benchmark_runner import BenchmarkReport

_PROFILES_DIR = Path(__file__).parent / "chain_profiles"
_BENCHMARKS_DIR = Path(__file__).parent / "benchmarks"

# Pipeline agents by pass
_PIPELINE_PASSES = [
    ("swift_developer", "implementation"),
    ("bug_hunter", "bug_review"),
    ("creative_director", "creative_review"),
    ("ux_psychology", "ux_psychology"),
    ("refactor_agent", "refactor"),
    ("test_generator", "test_generation"),
]

# Default model per tier
_TIER_DEFAULTS = {
    "dev": {"model": "claude-haiku-4-5", "provider": "anthropic"},
    "standard": {"model": "claude-sonnet-4-6", "provider": "anthropic"},
    "premium": {"model": "claude-opus-4-6", "provider": "anthropic"},
}


@dataclass
class ChainProfile:
    line: str = ""
    profile: str = ""
    chain: dict = field(default_factory=dict)
    expected_cost: float = 0.0
    target_errors: int = 0
    data_points: int = 0
    confidence: str = "low"
    last_optimized: str = ""

    def summary(self) -> str:
        lines = [
            f"Chain Profile: {self.line} ({self.profile})",
            f"  Confidence: {self.confidence} ({self.data_points} data points)",
            f"  Expected cost: ${self.expected_cost:.4f}",
            f"  Target errors: {self.target_errors}",
            "",
            f"  {'Agent':<25} {'Model':<30} {'Reason'}",
            "  " + "-" * 80,
        ]
        for agent, config in self.chain.items():
            lines.append(f"  {agent:<25} {config['provider']}/{config['model']:<25} {config.get('reason', '')}")
        return "\n".join(lines)

    def save(self, path: str | None = None):
        p = Path(path) if path else _PROFILES_DIR / f"{self.line}_{self.profile}.json"
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(json.dumps(asdict(self), indent=2), encoding="utf-8")

    @classmethod
    def load(cls, path: str) -> "ChainProfile":
        data = json.loads(Path(path).read_text(encoding="utf-8"))
        return cls(**data)

    @classmethod
    def load_for(cls, line: str, profile: str) -> "ChainProfile | None":
        p = _PROFILES_DIR / f"{line}_{profile}.json"
        if p.is_file():
            return cls.load(str(p))
        return None


class ChainOptimizer:
    """Finds optimal model combination across the pipeline chain."""

    def __init__(self, project_name: str = ""):
        self.registry = ModelRegistry()
        self.tracker = ChainTracker()

    def optimize(self, line: str, profile: str = "dev",
                 target_errors: int = 0) -> ChainProfile:
        """Find cheapest model combination achieving target_errors."""
        benchmarks = self._load_benchmarks()
        runs = self.tracker.get_runs(line, limit=20)

        if not benchmarks:
            return self._default_chain(line, profile)

        chain = {}
        total_cost = 0.0

        for agent_name, pass_name in _PIPELINE_PASSES:
            key = f"{agent_name}_{pass_name}"
            bm = benchmarks.get(key)

            if bm:
                # Use best value model (quality/cost ratio)
                viable = [r for r in bm.results if r.quality_score >= 0.3 and not r.error]
                if viable:
                    best = max(viable, key=lambda r: r.value_score)
                    chain[agent_name] = {
                        "model": best.model,
                        "provider": best.provider,
                        "reason": f"Best value (q={best.quality_score:.2f}, v={best.value_score:.0f})",
                        "expected_cost": best.cost_usd,
                    }
                    total_cost += best.cost_usd
                    continue

            # Fallback to tier default
            default = _TIER_DEFAULTS.get(profile, _TIER_DEFAULTS["dev"])
            chain[agent_name] = {
                "model": default["model"],
                "provider": default["provider"],
                "reason": "Tier default (no benchmark)",
                "expected_cost": 0.01,
            }
            total_cost += 0.01

        cp = ChainProfile(
            line=line, profile=profile, chain=chain,
            expected_cost=total_cost, target_errors=target_errors,
            data_points=len(runs),
            confidence="high" if len(benchmarks) >= 4 else "medium" if len(benchmarks) >= 2 else "low",
            last_optimized=datetime.now().isoformat(),
        )
        cp.save()
        return cp

    def _default_chain(self, line: str, profile: str) -> ChainProfile:
        default = _TIER_DEFAULTS.get(profile, _TIER_DEFAULTS["dev"])
        chain = {}
        for agent_name, _ in _PIPELINE_PASSES:
            chain[agent_name] = {
                "model": default["model"],
                "provider": default["provider"],
                "reason": "Default (no data)",
                "expected_cost": 0.01,
            }
        return ChainProfile(
            line=line, profile=profile, chain=chain,
            expected_cost=0.06, target_errors=0, data_points=0,
            confidence="low",
            last_optimized=datetime.now().isoformat(),
        )

    def _load_benchmarks(self) -> dict[str, BenchmarkReport]:
        result = {}
        if not _BENCHMARKS_DIR.is_dir():
            return result
        for f in _BENCHMARKS_DIR.glob("*.json"):
            try:
                bm = BenchmarkReport.load(str(f))
                key = f"{bm.agent_name}_{bm.pass_name}"
                result[key] = bm
            except Exception:
                pass
        return result

    def should_rebenchmark(self, line: str) -> bool:
        runs = self.tracker.get_runs(line, limit=5)
        if not runs:
            return True
        recent_errors = [r.get("blocking_errors", 0) for r in runs[-3:]]
        if any(e > 0 for e in recent_errors):
            return True
        if not list(_BENCHMARKS_DIR.glob("*.json")):
            return True
        return False
