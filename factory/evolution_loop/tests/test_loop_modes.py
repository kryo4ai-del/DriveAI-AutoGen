"""Tests for Loop Modes — P-EVO-015 Validation.

6 Tests:
  1. Sprint stays sprint (improving)
  2. Sprint -> Deep (stagnation)
  3. Deep -> Pivot (declining in deep)
  4. Mode never downgrades
  5. Pivot -> immediate ceo_review in orchestrator
  6. Recurring gaps detection
"""

import shutil
import sys
import time
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.regression_tracker import RegressionTracker
from factory.evolution_loop.ldo.schema import Gap, LoopDataObject, ScoreEntry
from factory.evolution_loop.config.config_loader import EvolutionConfig
from factory.evolution_loop.loop_orchestrator import LoopOrchestrator


def make_ldo(iteration, aggregate, mode="sprint", gaps=None):
    """Create a test LDO with given parameters."""
    ldo = LoopDataObject.create_initial("mode_test", "game", "unity")
    ldo.meta.iteration = iteration
    ldo.meta.loop_mode = mode
    ldo.scores.bug_score = ScoreEntry(value=70, confidence=95)
    ldo.scores.roadbook_match_score = ScoreEntry(value=60, confidence=90)
    ldo.scores.structural_health_score = ScoreEntry(value=70, confidence=85)
    ldo.scores.performance_score = ScoreEntry(value=50, confidence=50)
    ldo.scores.ux_score = ScoreEntry(value=50, confidence=40)
    ldo.scores.quality_score_aggregate = aggregate
    if gaps:
        ldo.gaps = gaps
    return ldo


# ======================================================================
# Test 1: Sprint stays Sprint (improving)
# ======================================================================

def test_1_sprint_stays_sprint():
    """Sprint mode stays sprint when scores are improving."""
    config = EvolutionConfig()
    tracker = RegressionTracker(config)

    history = [make_ldo(1, 50), make_ldo(2, 55), make_ldo(3, 60)]
    ldo = make_ldo(4, 65, "sprint")
    ldo.regression_data.trend = "improving"

    mode = tracker.detect_loop_mode(ldo, history)
    assert mode == "sprint", f"Expected sprint, got {mode}"

    print(f"  Sprint stays sprint (improving): {mode}")
    print("  [PASS] Test 1: Sprint stays Sprint")
    return mode


# ======================================================================
# Test 2: Sprint -> Deep (stagnation)
# ======================================================================

def test_2_sprint_to_deep():
    """Sprint escalates to deep on stagnation."""
    config = EvolutionConfig()
    tracker = RegressionTracker(config)

    history = [
        make_ldo(1, 55, "sprint"),
        make_ldo(2, 55.5, "sprint"),
        make_ldo(3, 55.3, "sprint"),
    ]
    ldo = make_ldo(4, 55.4, "sprint")
    ldo.regression_data.trend = "stagnating"

    mode = tracker.detect_loop_mode(ldo, history)
    assert mode == "deep", f"Expected deep, got {mode}"

    print(f"  Sprint -> Deep (stagnation): {mode}")
    print("  [PASS] Test 2: Sprint -> Deep")
    return mode


# ======================================================================
# Test 3: Deep -> Pivot (declining)
# ======================================================================

def test_3_deep_to_pivot():
    """Deep escalates to pivot on declining trend."""
    config = EvolutionConfig()
    tracker = RegressionTracker(config)

    history = [
        make_ldo(1, 55, "deep"),
        make_ldo(2, 50, "deep"),
        make_ldo(3, 45, "deep"),
    ]
    ldo = make_ldo(4, 40, "deep")
    ldo.regression_data.trend = "declining"

    mode = tracker.detect_loop_mode(ldo, history)
    assert mode == "pivot", f"Expected pivot, got {mode}"

    print(f"  Deep -> Pivot (declining): {mode}")
    print("  [PASS] Test 3: Deep -> Pivot")
    return mode


# ======================================================================
# Test 4: Mode never downgrades
# ======================================================================

def test_4_no_downgrade():
    """Mode never downgrades: deep stays deep even if improving."""
    config = EvolutionConfig()
    tracker = RegressionTracker(config)

    ldo = make_ldo(5, 70, "deep")
    ldo.regression_data.trend = "improving"
    history = [make_ldo(4, 65, "deep")]

    mode = tracker.detect_loop_mode(ldo, history)
    assert mode == "deep", f"Expected deep (no downgrade), got {mode}"

    print(f"  Mode no downgrade: deep stays {mode}")
    print("  [PASS] Test 4: No downgrade")
    return mode


# ======================================================================
# Test 5: Pivot -> immediate ceo_review
# ======================================================================

def test_5_pivot_stops():
    """Pivot mode triggers immediate ceo_review in orchestrator."""
    _cleanup("pivot_test")

    orch = LoopOrchestrator("pivot_test", "game", "unity")
    ldo = LoopDataObject.create_initial("pivot_test", "game", "unity")
    ldo.meta.loop_mode = "pivot"

    result = orch.check_stop_conditions(ldo)
    assert result == "ceo_review", f"Expected ceo_review for pivot, got {result}"

    print(f"  Pivot -> ceo_review: {result}")
    print("  [PASS] Test 5: Pivot -> ceo_review")

    _cleanup("pivot_test")
    return result


# ======================================================================
# Test 6: Recurring gaps detection
# ======================================================================

def test_6_recurring_gaps():
    """Recurring gaps are detected across 3+ iterations."""
    config = EvolutionConfig()
    tracker = RegressionTracker(config)

    recurring_gap = Gap(
        id="G1", category="bug", severity="high",
        description="Crash in GameView", affected_component="GameView",
    )
    other_gap = Gap(
        id="G2", category="feature", severity="medium",
        description="Missing settings", affected_component="SettingsView",
    )

    history = [
        make_ldo(1, 55, gaps=[recurring_gap, other_gap]),
        make_ldo(2, 55, gaps=[recurring_gap]),
        make_ldo(3, 55, gaps=[recurring_gap, other_gap]),
    ]

    recurring = tracker._count_recurring_gaps(history)
    assert len(recurring) >= 1, f"Expected >= 1 recurring gap, got {len(recurring)}"

    print(f"  Recurring gaps (3 iterations): {len(recurring)} found")
    for r in recurring:
        print(f"    - {r}")
    print("  [PASS] Test 6: Recurring gaps")
    return recurring


# ======================================================================
# Helpers
# ======================================================================

def _cleanup(project_id):
    path = Path("factory/evolution_loop/data") / project_id
    if path.exists():
        shutil.rmtree(path, ignore_errors=True)


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-015 Validation: Loop Modes ===\n")

    tests = [
        ("Test 1: Sprint stays Sprint", test_1_sprint_stays_sprint),
        ("Test 2: Sprint -> Deep", test_2_sprint_to_deep),
        ("Test 3: Deep -> Pivot", test_3_deep_to_pivot),
        ("Test 4: No downgrade", test_4_no_downgrade),
        ("Test 5: Pivot -> ceo_review", test_5_pivot_stops),
        ("Test 6: Recurring gaps", test_6_recurring_gaps),
    ]

    start = time.time()
    passed = 0
    failed = 0

    for name, fn in tests:
        print(f"\n--- {name} ---")
        try:
            fn()
            passed += 1
        except Exception as e:
            failed += 1
            print(f"  [FAIL] {name}: {e}")
            import traceback
            traceback.print_exc()

    elapsed = time.time() - start

    # Cleanup
    _cleanup("mode_test")
    _cleanup("pivot_test")

    print(f"\n{'='*50}")
    print(f"Result: {passed}/{len(tests)} passed, {failed} failed")
    print(f"Duration: {elapsed:.2f}s")
    print(f"{'='*50}")

    if failed:
        sys.exit(1)
    print("ALL MODE TESTS PASSED")


if __name__ == "__main__":
    main()
