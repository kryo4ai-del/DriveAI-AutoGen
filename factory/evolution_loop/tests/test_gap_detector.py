"""Tests for Gap Detector — P-EVO-010 Validation.

5 Tests:
  1. LDO with problems -> at least 5 gaps
  2. Perfect LDO -> 0 gaps
  3. Gap IDs are unique
  4. Severity sorting correct
  5. Cleanup
"""

import shutil
import sys
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.gap_detector import GapDetector
from factory.evolution_loop.ldo.schema import LoopDataObject
from factory.evolution_loop.config.config_loader import EvolutionConfig

detector = GapDetector()
config = EvolutionConfig()


# ======================================================================
# Test 1: LDO with problems -> gaps found
# ======================================================================

def test_1_gaps_with_problems():
    """LDO with low scores, compile errors, test failures, missing features."""
    ldo = LoopDataObject.create_initial("gap_test", "game", "unity")
    ldo.meta.iteration = 1
    ldo.qa_results.tests_passed = 15
    ldo.qa_results.tests_failed = 3
    ldo.qa_results.compile_errors = ["Error: missing semicolon", "Error: undefined variable"]
    ldo.qa_results.warnings = ["Deprecated API"]
    ldo.roadbook_targets.features = ["save_system", "inventory", "combat", "crafting", "tutorial"]
    ldo.roadbook_targets.screens = ["main_menu", "game_view", "settings"]
    ldo.roadbook_targets.user_flows = ["flow_start_game"]
    ldo.scores.bug_score.value = 42.0
    ldo.scores.bug_score.confidence = 95.0
    ldo.scores.roadbook_match_score.value = 60.0
    ldo.scores.roadbook_match_score.confidence = 90.0
    ldo.scores.structural_health_score.value = 80.0
    ldo.scores.structural_health_score.confidence = 85.0
    ldo.scores.performance_score.value = 75.0
    ldo.scores.ux_score.value = 70.0
    ldo.simulation_results.roadbook_coverage = {
        "features_covered": ["save_system", "combat"],
        "screens_covered": ["main_menu", "game_view"],
    }

    ldo = detector.detect_gaps(ldo, config)
    print(f"  Gaps found: {len(ldo.gaps)}")
    for gap in ldo.gaps:
        print(f"    {gap.id}: [{gap.severity}] {gap.category} - {gap.description}")
    assert len(ldo.gaps) >= 5, f"Expected at least 5 gaps, got {len(ldo.gaps)}"
    print("  [PASS] Test 1: Gap detection with problems")
    return ldo


# ======================================================================
# Test 2: Perfect LDO -> no gaps
# ======================================================================

def test_2_perfect_build():
    """Perfect scores, no compile errors, no test failures."""
    ldo = LoopDataObject.create_initial("gap_test_perfect", "game", "unity")
    ldo.meta.iteration = 1
    ldo.scores.bug_score.value = 100.0
    ldo.scores.bug_score.confidence = 95.0
    ldo.scores.roadbook_match_score.value = 100.0
    ldo.scores.roadbook_match_score.confidence = 90.0
    ldo.scores.structural_health_score.value = 95.0
    ldo.scores.structural_health_score.confidence = 85.0
    ldo.scores.performance_score.value = 80.0
    ldo.scores.ux_score.value = 80.0
    ldo.qa_results.tests_failed = 0
    ldo.qa_results.compile_errors = []

    ldo = detector.detect_gaps(ldo, config)
    print(f"  Perfect LDO gaps: {len(ldo.gaps)}")
    assert len(ldo.gaps) == 0, f"Expected 0 gaps for perfect build, got {len(ldo.gaps)}"
    print("  [PASS] Test 2: Perfect build -> 0 gaps")


# ======================================================================
# Test 3: Unique gap IDs
# ======================================================================

def test_3_unique_ids(ldo_with_gaps):
    """All gap IDs must be unique."""
    gap_ids = [g.id for g in ldo_with_gaps.gaps]
    assert len(gap_ids) == len(set(gap_ids)), f"Duplicate gap IDs: {gap_ids}"
    # Check format
    for gid in gap_ids:
        assert gid.startswith("GAP-1-"), f"Bad gap ID format: {gid}"
    print("  [PASS] Test 3: Unique gap IDs")


# ======================================================================
# Test 4: Severity sorting
# ======================================================================

def test_4_severity_sorting(ldo_with_gaps):
    """Gaps must be sorted: critical > high > medium > low."""
    severity_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
    severities = [g.severity for g in ldo_with_gaps.gaps]
    for i in range(len(severities) - 1):
        assert severity_order[severities[i]] <= severity_order[severities[i + 1]], \
            f"Gaps not sorted! {severities[i]} before {severities[i+1]}"
    print("  [PASS] Test 4: Severity sorting correct")


# ======================================================================
# Test 5: Cleanup
# ======================================================================

def test_5_cleanup():
    """Remove test data directories."""
    shutil.rmtree("factory/evolution_loop/data/gap_test", ignore_errors=True)
    shutil.rmtree("factory/evolution_loop/data/gap_test_perfect", ignore_errors=True)
    print("  [PASS] Test 5: Cleanup done")


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-010 Validation: Gap Detector ===\n")
    passed = 0
    failed = 0

    # Test 1 returns the LDO for reuse in tests 3+4
    ldo_with_gaps = None

    tests_simple = [
        ("test_1_gaps_with_problems", test_1_gaps_with_problems, False),
        ("test_2_perfect_build", test_2_perfect_build, False),
    ]

    for name, fn, _ in tests_simple:
        try:
            result = fn()
            if name == "test_1_gaps_with_problems":
                ldo_with_gaps = result
            passed += 1
        except Exception as e:
            failed += 1
            print(f"  [FAIL] {name}: {e}")

    # Tests that need the LDO from test 1
    if ldo_with_gaps is not None:
        for name, fn in [("test_3_unique_ids", test_3_unique_ids),
                         ("test_4_severity_sorting", test_4_severity_sorting)]:
            try:
                fn(ldo_with_gaps)
                passed += 1
            except Exception as e:
                failed += 1
                print(f"  [FAIL] {name}: {e}")
    else:
        failed += 2
        print("  [FAIL] test_3 + test_4: skipped (test_1 failed)")

    # Cleanup
    try:
        test_5_cleanup()
        passed += 1
    except Exception as e:
        failed += 1
        print(f"  [FAIL] test_5_cleanup: {e}")

    total = passed + failed
    print(f"\nResult: {passed}/{total} passed, {failed} failed")
    if failed:
        sys.exit(1)
    print("ALL TESTS PASSED")


if __name__ == "__main__":
    main()
