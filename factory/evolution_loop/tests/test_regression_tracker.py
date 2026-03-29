"""Tests for Regression Tracker — P-EVO-012 Validation.

7 Tests:
  1. First iteration (no history)
  2. Improving trend (+10 aggregate)
  3. Stagnating trend (multiple flat iterations)
  4. Declining trend (-19 aggregate)
  5. find_regressions (individual score regression)
  6. Loop mode detection (stagnating in sprint -> deep)
  7. Trend summary text
"""

import sys
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.regression_tracker import RegressionTracker
from factory.evolution_loop.ldo.schema import LoopDataObject, ScoreEntry
from factory.evolution_loop.config.config_loader import EvolutionConfig

config = EvolutionConfig()


def make_ldo(iteration, bug, roadbook, structural, perf, ux, aggregate):
    """Helper: create LDO with preset scores."""
    ldo = LoopDataObject.create_initial("regression_test", "game", "unity")
    ldo.meta.iteration = iteration
    ldo.scores.bug_score = ScoreEntry(value=bug, confidence=95)
    ldo.scores.roadbook_match_score = ScoreEntry(value=roadbook, confidence=90)
    ldo.scores.structural_health_score = ScoreEntry(value=structural, confidence=85)
    ldo.scores.performance_score = ScoreEntry(value=perf, confidence=50)
    ldo.scores.ux_score = ScoreEntry(value=ux, confidence=40)
    ldo.scores.quality_score_aggregate = aggregate
    return ldo


# ======================================================================
# Test 1: First iteration (no history)
# ======================================================================

def test_1_first_iteration():
    tracker = RegressionTracker(config)
    ldo = make_ldo(1, 60, 50, 70, 50, 50, 55)
    ldo = tracker.analyze(ldo, [])
    assert ldo.regression_data.trend == "improving"
    assert ldo.regression_data.recommendation == "continue"
    assert ldo.regression_data.iterations_without_improvement == 0
    print("  [PASS] Test 1: First iteration (no history)")


# ======================================================================
# Test 2: Improving trend
# ======================================================================

def test_2_improving():
    tracker = RegressionTracker(config)
    history = [make_ldo(1, 60, 50, 70, 50, 50, 55)]
    ldo = make_ldo(2, 70, 60, 75, 55, 55, 65)
    ldo = tracker.analyze(ldo, history)
    assert ldo.regression_data.trend == "improving", \
        f"Expected improving, got {ldo.regression_data.trend}"
    assert ldo.regression_data.recommendation == "continue"
    print(f"  [PASS] Test 2: Improving (+10): trend={ldo.regression_data.trend}")


# ======================================================================
# Test 3: Stagnating trend
# ======================================================================

def test_3_stagnating():
    tracker = RegressionTracker(config)
    # Build up stagnation: iterate through flat history
    history_1 = [make_ldo(1, 60, 50, 70, 50, 50, 55)]
    ldo2 = make_ldo(2, 61, 50, 70, 50, 50, 55.5)
    ldo2 = tracker.analyze(ldo2, history_1)
    # First flat iteration: should still be "improving" (giving a chance)

    history_2 = history_1 + [ldo2]
    ldo3 = make_ldo(3, 61, 50, 70, 50, 50, 55.8)
    ldo3 = tracker.analyze(ldo3, history_2)
    # Second flat iteration: stagnation_iterations=2, should now be "stagnating"
    assert ldo3.regression_data.trend == "stagnating", \
        f"Expected stagnating, got {ldo3.regression_data.trend}"
    assert ldo3.regression_data.recommendation == "ceo_review"
    print(f"  [PASS] Test 3: Stagnating: trend={ldo3.regression_data.trend}, "
          f"without_improvement={ldo3.regression_data.iterations_without_improvement}")


# ======================================================================
# Test 4: Declining trend
# ======================================================================

def test_4_declining():
    tracker = RegressionTracker(config)
    history = [make_ldo(1, 80, 70, 80, 60, 60, 72)]
    ldo = make_ldo(2, 60, 50, 65, 45, 45, 53)
    ldo = tracker.analyze(ldo, history)
    assert ldo.regression_data.trend == "declining", \
        f"Expected declining, got {ldo.regression_data.trend}"
    assert ldo.regression_data.recommendation == "stop"
    regressions = ldo.regression_data.regressions_detected
    assert len(regressions) > 0, "Expected regressions detected"
    print(f"  [PASS] Test 4: Declining (-19): trend={ldo.regression_data.trend}, "
          f"regressions={len(regressions)}")


# ======================================================================
# Test 5: find_regressions
# ======================================================================

def test_5_find_regressions():
    tracker = RegressionTracker(config)
    regs = tracker.find_regressions(
        {"bug_score": 60, "roadbook_match": 70},
        {"bug_score": 80, "roadbook_match": 65},
    )
    # Only bug_score regressed (60 < 80), roadbook improved (70 > 65)
    assert len(regs) == 1, f"Expected 1 regression, got {len(regs)}"
    assert regs[0]["score_name"] == "bug_score"
    assert regs[0]["delta"] == -20
    print(f"  [PASS] Test 5: find_regressions: {len(regs)} found (bug_score -20)")


# ======================================================================
# Test 6: Loop mode detection
# ======================================================================

def test_6_mode_detection():
    tracker = RegressionTracker(config)
    history = [
        make_ldo(1, 60, 50, 70, 50, 50, 55),
        make_ldo(2, 61, 50, 70, 50, 50, 55.5),
        make_ldo(3, 61, 50, 70, 50, 50, 55.5),
    ]
    ldo = make_ldo(4, 61, 50, 70, 50, 50, 55.8)
    ldo.regression_data.trend = "stagnating"
    ldo.meta.loop_mode = "sprint"
    mode = tracker.detect_loop_mode(ldo, history)
    assert mode == "deep", f"Expected deep, got {mode}"
    print(f"  [PASS] Test 6: Mode detection (stagnating in sprint): {mode}")


# ======================================================================
# Test 7: Trend summary
# ======================================================================

def test_7_trend_summary():
    tracker = RegressionTracker(config)
    summary = tracker.get_trend_summary([
        make_ldo(1, 60, 50, 70, 50, 50, 55),
        make_ldo(2, 65, 55, 72, 52, 52, 60),
        make_ldo(3, 70, 60, 75, 55, 55, 65),
    ])
    assert "55.0" in summary
    assert "65.0" in summary
    assert "improving" in summary
    print(f"  [PASS] Test 7: Trend summary: {summary}")


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-012 Validation: Regression Tracker ===\n")
    tests = [
        test_1_first_iteration,
        test_2_improving,
        test_3_stagnating,
        test_4_declining,
        test_5_find_regressions,
        test_6_mode_detection,
        test_7_trend_summary,
    ]
    passed = 0
    failed = 0
    for t in tests:
        try:
            t()
            passed += 1
        except Exception as e:
            failed += 1
            print(f"  [FAIL] {t.__name__}: {e}")

    print(f"\nResult: {passed}/{len(tests)} passed, {failed} failed")
    if failed:
        sys.exit(1)
    print("ALL TESTS PASSED")


if __name__ == "__main__":
    main()
