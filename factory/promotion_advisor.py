# factory/promotion_advisor.py
# Run Promotion Advisor — recommends the cheapest sufficient profile
# for the next factory action based on current project state.
#
# Usage:
#   python -m factory.promotion_advisor --project askfin_v1-1
#
# Deterministic, no LLM. Reads existing reports and run history.

import json
import sys
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent
_REPORTS = _PROJECT_ROOT / "factory" / "reports"
_POLICY = _PROJECT_ROOT / "config" / "run_promotion_policy.json"


def _load_hygiene(project_name: str) -> dict | None:
    path = _REPORTS / "hygiene" / f"{project_name}_compile_hygiene.json"
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return None


def _load_completion(project_name: str) -> dict | None:
    path = _REPORTS / "completion" / f"{project_name}_completion.json"
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return None


def _load_run_memory(project_name: str) -> dict | None:
    path = _PROJECT_ROOT / "factory" / "memory" / "run_history.json"
    if path.exists():
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            pass
    return None


def advise(project_name: str) -> dict:
    """Analyze current state and recommend the cheapest sufficient next action.

    Returns a dict with:
        recommendation: str — one of "no_action", "static_validation", "dev", "standard", "premium"
        reason: str
        evidence: dict
    """
    hygiene = _load_hygiene(project_name)
    completion = _load_completion(project_name)

    evidence = {
        "hygiene_blocking": hygiene.get("blocking", -1) if hygiene else -1,
        "hygiene_status": hygiene.get("status", "unknown") if hygiene else "unknown",
        "completion_health": completion.get("health", "unknown") if completion else "unknown",
        "completion_pct": completion.get("completeness_pct", 0) if completion else 0,
    }

    blocking = evidence["hygiene_blocking"]
    health = evidence["completion_health"]

    # Decision tree (cheapest first)

    # 1. If no reports exist, we need at least static validation
    if blocking == -1:
        return {
            "recommendation": "static_validation",
            "reason": "No hygiene report found — run static validation first.",
            "evidence": evidence,
        }

    # 2. If blocking > 0, check if static fixes (StubGen, ShapeRepair) could help
    if blocking > 0:
        return {
            "recommendation": "static_validation",
            "reason": f"{blocking} blocking issue(s) found — run Ops Layer repair passes (StubGen/ShapeRepair/StaleGuard) before spending on a full run.",
            "evidence": evidence,
        }

    # 3. Baseline is clean (0 blocking)
    if health in ("mostly_complete", "complete"):
        # The project is healthy. What question are we trying to answer?
        return {
            "recommendation": "no_action",
            "reason": (
                f"Baseline is clean: {blocking} blocking, {health}. "
                "No open question requires a new LLM run. "
                "Consider: (a) test a different feature template, "
                "(b) run on Mac with swiftc for real compile check, "
                "or (c) wait for a new requirement."
            ),
            "evidence": evidence,
        }

    if health == "incomplete":
        return {
            "recommendation": "dev",
            "reason": f"Project is incomplete ({evidence['completion_pct']}%) — a dev run can test whether the pipeline improves it cheaply.",
            "evidence": evidence,
        }

    if health == "failed":
        return {
            "recommendation": "dev",
            "reason": "Project health is FAILED — use a cheap dev run to diagnose before spending on standard/premium.",
            "evidence": evidence,
        }

    # Fallback
    return {
        "recommendation": "static_validation",
        "reason": f"Uncertain state (health={health}) — run static validation first.",
        "evidence": evidence,
    }


def print_advice(project_name: str):
    """Print formatted advice to stdout."""
    result = advise(project_name)

    print()
    print("=" * 60)
    print("  Run Promotion Advisor")
    print("=" * 60)
    print(f"  Project:          {project_name}")
    print(f"  Hygiene blocking: {result['evidence']['hygiene_blocking']}")
    print(f"  Hygiene status:   {result['evidence']['hygiene_status']}")
    print(f"  Health:           {result['evidence']['completion_health']}")
    print(f"  Completeness:     {result['evidence']['completion_pct']}%")
    print("-" * 60)

    rec = result["recommendation"]
    cost_map = {
        "no_action": "ZERO",
        "static_validation": "ZERO",
        "dev": "LOW (Haiku)",
        "standard": "MEDIUM (Sonnet)",
        "premium": "HIGH (Opus)",
    }

    print(f"  Recommendation:   {rec.upper()}")
    print(f"  Cost:             {cost_map.get(rec, '?')}")
    print(f"  Reason:           {result['reason']}")
    print("=" * 60)
    print()


if __name__ == "__main__":
    project = "askfin_v1-1"
    if len(sys.argv) > 1:
        for i, arg in enumerate(sys.argv[1:]):
            if arg == "--project" and i + 1 < len(sys.argv) - 1:
                project = sys.argv[i + 2]
    print_advice(project)
