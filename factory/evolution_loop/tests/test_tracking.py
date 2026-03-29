"""Tests for P-EVO-016 — Git Tagger + Cost Tracker.

8 Tests:
  1. CostTracker: add_cost accumulates correctly
  2. CostTracker: get_cost_per_iteration groups by iteration
  3. CostTracker: check_budget detects over-budget
  4. CostTracker: get_cost_report returns readable text
  5. CostTracker: reset clears all data
  6. GitTagger: tag_iteration returns False when no git repo
  7. GitTagger: get_last_stable_iteration finds correct iteration
  8. Orchestrator: CostTracker + GitTagger integrated and accessible
"""

import sys
import time
from pathlib import Path
from unittest.mock import MagicMock, patch

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.tracking.cost_tracker import CostTracker
from factory.evolution_loop.tracking.git_tagger import GitTagger
from factory.evolution_loop.ldo.schema import LoopDataObject, ScoreEntry


# ======================================================================
# Test 1: CostTracker — add_cost accumulates
# ======================================================================

def test_1_cost_add():
    """add_cost accumulates cost correctly."""
    ct = CostTracker()
    ct.add_cost("agent_a", 0.02, iteration=1)
    ct.add_cost("agent_b", 0.03, iteration=1)
    ct.add_cost("agent_a", 0.01, iteration=2)

    total = ct.get_total()
    assert abs(total - 0.06) < 1e-9, f"Expected 0.06, got {total}"
    assert len(ct.cost_log) == 3, f"Expected 3 entries, got {len(ct.cost_log)}"

    print(f"  Total: ${total:.4f}, entries: {len(ct.cost_log)}")
    print("  [PASS] Test 1: add_cost accumulates")


# ======================================================================
# Test 2: CostTracker — cost per iteration
# ======================================================================

def test_2_cost_per_iteration():
    """get_cost_per_iteration groups costs by iteration."""
    ct = CostTracker()
    ct.add_cost("a", 0.01, iteration=1)
    ct.add_cost("b", 0.02, iteration=1)
    ct.add_cost("a", 0.05, iteration=2)

    per_iter = ct.get_cost_per_iteration()
    assert abs(per_iter[1] - 0.03) < 1e-9, f"Iter 1: expected 0.03, got {per_iter[1]}"
    assert abs(per_iter[2] - 0.05) < 1e-9, f"Iter 2: expected 0.05, got {per_iter[2]}"

    print(f"  Per iteration: {per_iter}")
    print("  [PASS] Test 2: cost per iteration")


# ======================================================================
# Test 3: CostTracker — budget check
# ======================================================================

def test_3_budget_check():
    """check_budget detects over-budget."""
    ct = CostTracker()
    ct.add_cost("a", 3.0, iteration=1)
    ct.add_cost("b", 2.5, iteration=2)

    check = ct.check_budget(threshold=5.0)
    assert check["over_budget"] is True, f"Expected over_budget=True, got {check}"
    assert check["remaining"] == 0.0, f"Expected remaining=0, got {check['remaining']}"

    # Under budget
    ct2 = CostTracker()
    ct2.add_cost("a", 1.0, iteration=1)
    check2 = ct2.check_budget(threshold=5.0)
    assert check2["over_budget"] is False, f"Expected over_budget=False"
    assert abs(check2["remaining"] - 4.0) < 1e-9, f"Expected remaining=4.0"

    print(f"  Over-budget: {check['total']}/{check['threshold']}")
    print(f"  Under-budget: {check2['total']}/{check2['threshold']}, remaining={check2['remaining']}")
    print("  [PASS] Test 3: budget check")


# ======================================================================
# Test 4: CostTracker — cost report
# ======================================================================

def test_4_cost_report():
    """get_cost_report returns readable text."""
    ct = CostTracker()
    ct.add_cost("eval_agent", 0.01, iteration=1)
    ct.add_cost("decision_agent", 0.02, iteration=1)
    ct.add_cost("eval_agent", 0.03, iteration=2)

    report = ct.get_cost_report()
    assert "Cost Report" in report, "Missing header"
    assert "$0.0600" in report, f"Missing total in report"
    assert "Iteration 1" in report, "Missing iteration 1"
    assert "Iteration 2" in report, "Missing iteration 2"

    print(f"  Report:\n{report}")
    print("  [PASS] Test 4: cost report")


# ======================================================================
# Test 5: CostTracker — reset
# ======================================================================

def test_5_reset():
    """reset clears all data."""
    ct = CostTracker()
    ct.add_cost("a", 1.0, iteration=1)
    ct.add_cost("b", 2.0, iteration=2)
    assert ct.get_total() == 3.0

    ct.reset()
    assert ct.get_total() == 0.0, "Total not reset"
    assert len(ct.cost_log) == 0, "Log not cleared"

    print("  After reset: total=0, log empty")
    print("  [PASS] Test 5: reset")


# ======================================================================
# Test 6: GitTagger — no git repo fallback
# ======================================================================

def test_6_git_no_repo():
    """tag_iteration returns False when no git repo."""
    with patch.object(GitTagger, '_check_git', return_value=False):
        tagger = GitTagger("test_project")
        assert tagger.git_available is False

        result = tagger.tag_iteration(1, "test")
        assert result is False, f"Expected False, got {result}"

        tags = tagger.list_tags()
        assert tags == [], f"Expected empty list, got {tags}"

        rollback = tagger.rollback_to(1)
        assert rollback is False

    print("  No git: tag=False, list=[], rollback=False")
    print("  [PASS] Test 6: git no repo fallback")


# ======================================================================
# Test 7: GitTagger — get_last_stable_iteration
# ======================================================================

def test_7_last_stable():
    """get_last_stable_iteration finds the right iteration."""

    def _make_ldo(iteration, bug, roadbook, structural):
        ldo = LoopDataObject.create_initial("test", "game", "unity")
        ldo.meta.iteration = iteration
        ldo.scores.bug_score = ScoreEntry(value=bug, confidence=95)
        ldo.scores.roadbook_match_score = ScoreEntry(value=roadbook, confidence=90)
        ldo.scores.structural_health_score = ScoreEntry(value=structural, confidence=85)
        return ldo

    mock_storage = MagicMock()
    mock_storage.get_history.return_value = [
        _make_ldo(1, 90, 95, 85),    # stable
        _make_ldo(2, 80, 95, 85),    # not stable (bug < 90)
        _make_ldo(3, 95, 98, 90),    # stable
        _make_ldo(4, 70, 60, 50),    # not stable
    ]

    with patch.object(GitTagger, '_check_git', return_value=False):
        tagger = GitTagger("test")
        last = tagger.get_last_stable_iteration(mock_storage)

    assert last == 3, f"Expected iteration 3, got {last}"

    print(f"  Last stable iteration: {last}")
    print("  [PASS] Test 7: last stable iteration")


# ======================================================================
# Test 8: Orchestrator integration
# ======================================================================

def test_8_orchestrator_integration():
    """Orchestrator has CostTracker and GitTagger attributes."""
    from factory.evolution_loop.loop_orchestrator import LoopOrchestrator

    orch = LoopOrchestrator("int_test", "game", "unity")

    # CostTracker accessible
    assert hasattr(orch, '_cost_tracker'), "Missing _cost_tracker"
    assert isinstance(orch._cost_tracker, CostTracker)

    # GitTagger accessible
    assert hasattr(orch, '_git_tagger'), "Missing _git_tagger"
    assert isinstance(orch._git_tagger, GitTagger)

    # accumulated_cost property works
    assert orch.accumulated_cost == 0.0
    orch._cost_tracker.add_cost("test", 0.05, 1)
    assert abs(orch.accumulated_cost - 0.05) < 1e-9, f"Expected 0.05, got {orch.accumulated_cost}"

    # Budget check in stop conditions uses CostTracker
    ldo = LoopDataObject.create_initial("int_test", "game", "unity")
    ldo.scores.bug_score = ScoreEntry(value=50, confidence=95)
    ldo.scores.roadbook_match_score = ScoreEntry(value=50, confidence=90)
    ldo.scores.structural_health_score = ScoreEntry(value=50, confidence=85)
    ldo.scores.performance_score = ScoreEntry(value=50, confidence=50)
    ldo.scores.ux_score = ScoreEntry(value=50, confidence=40)
    ldo.scores.quality_score_aggregate = 50

    # Under budget → should continue
    result = orch.check_stop_conditions(ldo)
    assert result == "continue", f"Expected continue, got {result}"

    # Add cost over budget (default 5.0)
    orch._cost_tracker.add_cost("big_run", 5.0, 2)
    result = orch.check_stop_conditions(ldo)
    assert result == "ceo_review", f"Expected ceo_review for over-budget, got {result}"

    print(f"  CostTracker + GitTagger integrated")
    print(f"  Budget check via CostTracker works")
    print("  [PASS] Test 8: orchestrator integration")


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-016 Validation: Git Tagger + Cost Tracker ===\n")

    tests = [
        ("Test 1: CostTracker add_cost", test_1_cost_add),
        ("Test 2: Cost per iteration", test_2_cost_per_iteration),
        ("Test 3: Budget check", test_3_budget_check),
        ("Test 4: Cost report", test_4_cost_report),
        ("Test 5: Reset", test_5_reset),
        ("Test 6: Git no repo fallback", test_6_git_no_repo),
        ("Test 7: Last stable iteration", test_7_last_stable),
        ("Test 8: Orchestrator integration", test_8_orchestrator_integration),
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

    print(f"\n{'='*50}")
    print(f"Result: {passed}/{len(tests)} passed, {failed} failed")
    print(f"Duration: {elapsed:.2f}s")
    print(f"{'='*50}")

    if failed:
        sys.exit(1)
    print("ALL TRACKING TESTS PASSED")


if __name__ == "__main__":
    main()
