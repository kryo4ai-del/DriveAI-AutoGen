"""Benchmark Runner — controlled experiments across models for Chain Optimizer."""
import json
import os
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path

from .model_registry import ModelRegistry
from .provider_router import ProviderRouter

_BENCHMARKS_DIR = Path(__file__).parent / "benchmarks"


@dataclass
class BenchmarkResult:
    model: str = ""
    provider: str = ""
    input_tokens: int = 0
    output_tokens: int = 0
    cost_usd: float = 0.0
    latency_ms: int = 0
    quality_score: float = 0.0
    output_length: int = 0
    truncated: bool = False
    error: str | None = None

    @property
    def value_score(self) -> float:
        if self.cost_usd <= 0 or self.error:
            return 0.0
        return self.quality_score / self.cost_usd


@dataclass
class BenchmarkReport:
    agent_name: str = ""
    pass_name: str = ""
    results: list[BenchmarkResult] = field(default_factory=list)
    best_value: BenchmarkResult | None = None
    best_quality: BenchmarkResult | None = None
    cheapest: BenchmarkResult | None = None
    timestamp: str = ""

    def summary(self) -> str:
        lines = [f"Benchmark: {self.agent_name} ({self.pass_name})",
                 f"  Tested: {len(self.results)} models", ""]
        header = f"  {'Provider/Model':<35} {'Quality':>8} {'Cost':>12} {'Value':>8} {'Tokens':>10}"
        lines.append(header)
        lines.append("  " + "-" * 75)
        for r in sorted(self.results, key=lambda x: x.value_score, reverse=True):
            if r.error:
                lines.append(f"  {r.provider}/{r.model:<30} ERROR: {r.error[:40]}")
            else:
                tok = f"{r.input_tokens // 1000}k+{r.output_tokens // 1000}k"
                lines.append(f"  {r.provider}/{r.model:<30} {r.quality_score:>8.2f} "
                           f"${r.cost_usd:>10.6f} {r.value_score:>7.0f} {tok:>10}")
        if self.best_value:
            lines.append(f"\n  -> Best value: {self.best_value.provider}/{self.best_value.model}")
        if self.best_quality:
            lines.append(f"  -> Best quality: {self.best_quality.provider}/{self.best_quality.model}")
        if self.cheapest:
            lines.append(f"  -> Cheapest: {self.cheapest.provider}/{self.cheapest.model}")
        return "\n".join(lines)

    def save(self, path: str):
        p = Path(path)
        p.parent.mkdir(parents=True, exist_ok=True)
        data = {
            "agent_name": self.agent_name, "pass_name": self.pass_name,
            "timestamp": self.timestamp or datetime.now().isoformat(),
            "results": [asdict(r) for r in self.results],
            "best_value": asdict(self.best_value) if self.best_value else None,
            "best_quality": asdict(self.best_quality) if self.best_quality else None,
            "cheapest": asdict(self.cheapest) if self.cheapest else None,
        }
        p.write_text(json.dumps(data, indent=2), encoding="utf-8")

    @classmethod
    def load(cls, path: str) -> "BenchmarkReport":
        data = json.loads(Path(path).read_text(encoding="utf-8"))
        results = [BenchmarkResult(**r) for r in data.get("results", [])]
        bv = BenchmarkResult(**data["best_value"]) if data.get("best_value") else None
        bq = BenchmarkResult(**data["best_quality"]) if data.get("best_quality") else None
        ch = BenchmarkResult(**data["cheapest"]) if data.get("cheapest") else None
        return cls(agent_name=data["agent_name"], pass_name=data["pass_name"],
                   results=results, best_value=bv, best_quality=bq, cheapest=ch,
                   timestamp=data.get("timestamp", ""))


# Sample prompts for benchmarking (short, representative)
_BENCHMARK_PROMPTS = {
    "bug_review": {
        "system": "You are a senior code reviewer specializing in finding bugs.",
        "user": "Review this Kotlin code for bugs:\n```kotlin\ndata class Question(val id: String, val text: String, val answers: List<String>, val correctIndex: Int)\nfun validateQuestion(q: Question): Boolean { return q.answers.size > 0 && q.correctIndex >= 0 }\n```\nList any bugs, edge cases, or improvements.",
    },
    "creative_review": {
        "system": "You are a Creative Director evaluating product quality.",
        "user": "Evaluate this feature description for a driving exam app:\nTraining mode with adaptive question selection based on user weakness areas.\nRating (pass/conditional_pass/fail) and brief assessment.",
    },
    "refactor": {
        "system": "You are a code quality expert.",
        "user": "Suggest refactoring for:\n```kotlin\nfun getScore(answers: List<Boolean>): Int { var s = 0; for (a in answers) { if (a) s++ }; return s }\n```",
    },
    "test_generation": {
        "system": "You are a test engineer.",
        "user": "Generate 3 unit tests for:\n```kotlin\nfun calculateScore(correct: Int, total: Int): Float = if (total == 0) 0f else correct.toFloat() / total\n```",
    },
}


class BenchmarkRunner:
    """Runs controlled experiments across models for Chain Optimizer."""

    def __init__(self, project_name: str = ""):
        self.project_name = project_name
        self.registry = ModelRegistry()
        self.router = ProviderRouter(self.registry)

    def benchmark_agent(self, agent_name: str, pass_name: str,
                        models: list[str] | None = None) -> BenchmarkReport:
        """Run same prompt through multiple models and compare."""
        prompts = _BENCHMARK_PROMPTS.get(pass_name, _BENCHMARK_PROMPTS["bug_review"])

        if models is None:
            models = self._get_candidates()

        results = []
        for model_id in models:
            model_info = self.registry.get_model(model_id)
            if not model_info:
                continue

            print(f"  Testing {model_info.provider}/{model_id}...", end=" ", flush=True)
            response = self.router.call(
                model_id=model_info.model_id,
                provider=model_info.provider,
                messages=[
                    {"role": "system", "content": prompts["system"]},
                    {"role": "user", "content": prompts["user"]},
                ],
                max_tokens=1024,
                temperature=0.0,
            )

            if response.error:
                results.append(BenchmarkResult(model=model_id, provider=model_info.provider,
                                               error=response.error))
                print(f"ERROR")
            else:
                quality = self._measure_quality(response.content, pass_name)
                r = BenchmarkResult(
                    model=model_id, provider=model_info.provider,
                    input_tokens=response.input_tokens, output_tokens=response.output_tokens,
                    cost_usd=response.cost_usd, latency_ms=response.latency_ms,
                    quality_score=quality, output_length=len(response.content),
                    truncated=response.output_tokens >= model_info.max_output_tokens * 0.95,
                )
                results.append(r)
                print(f"quality={quality:.2f}, cost=${response.cost_usd:.6f}, {response.latency_ms}ms")

        valid = [r for r in results if r.error is None]
        valid_sorted = sorted(valid, key=lambda r: r.value_score, reverse=True)

        report = BenchmarkReport(
            agent_name=agent_name, pass_name=pass_name, results=results,
            best_value=valid_sorted[0] if valid_sorted else None,
            best_quality=max(valid, key=lambda r: r.quality_score) if valid else None,
            cheapest=min(valid, key=lambda r: r.cost_usd) if valid else None,
            timestamp=datetime.now().isoformat(),
        )

        save_path = str(_BENCHMARKS_DIR / f"{agent_name}_{pass_name}.json")
        report.save(save_path)
        print(f"  Saved to {save_path}")

        return report

    def _get_candidates(self) -> list[str]:
        available = self.registry.get_available_models()
        available.sort(key=lambda m: m.price_per_1k_output)
        return [m.model_id for m in available[:6]]

    def _measure_quality(self, content: str, pass_name: str) -> float:
        if not content or len(content) < 30:
            return 0.0
        score = 0.4
        content_lower = content.lower()

        if pass_name in ("implementation", "fix_execution", "refactor"):
            if content.count("```") >= 2:
                score += 0.2
            if any(kw in content for kw in ["class ", "fun ", "function ", "const "]):
                score += 0.2
            if not content.rstrip().endswith("..."):
                score += 0.1
            if len(content) > 200:
                score += 0.1
        elif pass_name in ("bug_review", "creative_review", "ux_psychology"):
            if any(kw in content_lower for kw in ["finding", "issue", "bug", "risk", "suggest"]):
                score += 0.2
            if any(f"{n}." in content or f"{n})" in content for n in range(1, 6)):
                score += 0.2
            if "rating" in content_lower or "pass" in content_lower or "fail" in content_lower:
                score += 0.1
        elif pass_name == "test_generation":
            if any(kw in content for kw in ["@Test", "test(", "fun test", "assert"]):
                score += 0.3
            if content.count("assert") >= 2 or content.count("expect") >= 2:
                score += 0.2

        return min(score, 1.0)
