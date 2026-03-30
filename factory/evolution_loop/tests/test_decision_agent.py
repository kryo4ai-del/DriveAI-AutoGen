"""Tests for Decision Agent — P-EVO-011 Validation.

6 Tests:
  1. Tasks from gaps (5 gaps -> 5 tasks)
  2. Task types correct (2 fix, 1 implement, 2 refactor)
  3. Unique task IDs
  4. CEO Feedback -> tasks appended
  5. Escalation (>5 critical gaps)
  6. Empty gaps -> 0 tasks
"""

import sys
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.decision_agent import DecisionAgent
from factory.evolution_loop.ldo.schema import (
    CEOFeedback,
    CEOIssue,
    Gap,
    LoopDataObject,
)
from factory.evolution_loop.config.config_loader import EvolutionConfig

agent = DecisionAgent()
config = EvolutionConfig()


def _make_ldo_with_gaps():
    """Create a standard LDO with 5 gaps for testing."""
    ldo = LoopDataObject.create_initial("decision_test", "game", "unity")
    ldo.meta.iteration = 3
    ldo.gaps = [
        Gap(id="GAP-3-001", category="bug", severity="critical",
            description="Compile error in GameView", affected_component="GameView.swift"),
        Gap(id="GAP-3-002", category="bug", severity="critical",
            description="Crash on level load", affected_component="LevelManager.swift"),
        Gap(id="GAP-3-003", category="feature", severity="high",
            description="Save system not implemented", affected_component="SaveManager"),
        Gap(id="GAP-3-004", category="performance", severity="medium",
            description="Performance score below target", affected_component=""),
        Gap(id="GAP-3-005", category="ux", severity="medium",
            description="UX score below target", affected_component=""),
    ]
    return agent.generate_tasks(ldo, config)


# ======================================================================
# Test 1: Tasks from gaps
# ======================================================================

def test_1_tasks_from_gaps():
    ldo = _make_ldo_with_gaps()
    assert len(ldo.tasks) == 5, f"Expected 5 tasks, got {len(ldo.tasks)}"
    print(f"  Tasks generated: {len(ldo.tasks)}")
    for t in ldo.tasks:
        print(f"    {t.id}: [{t.priority}] {t.type} - {t.description}")
    print("  [PASS] Test 1: Task generation from gaps")


# ======================================================================
# Test 2: Task types correct
# ======================================================================

def test_2_task_types():
    ldo = _make_ldo_with_gaps()
    types = [t.type for t in ldo.tasks]
    assert types.count("fix") == 2, f"Expected 2 fix, got {types.count('fix')}"
    assert types.count("implement") == 1, f"Expected 1 implement, got {types.count('implement')}"
    assert types.count("refactor") == 2, f"Expected 2 refactor, got {types.count('refactor')}"
    print("  [PASS] Test 2: Task types correct (2 fix, 1 implement, 2 refactor)")


# ======================================================================
# Test 3: Unique task IDs
# ======================================================================

def test_3_unique_ids():
    ldo = _make_ldo_with_gaps()
    task_ids = [t.id for t in ldo.tasks]
    assert len(task_ids) == len(set(task_ids)), f"Duplicate task IDs: {task_ids}"
    for tid in task_ids:
        assert tid.startswith("TASK-3-"), f"Bad task ID format: {tid}"
    print("  [PASS] Test 3: Unique task IDs")


# ======================================================================
# Test 4: CEO Feedback -> tasks
# ======================================================================

def test_4_ceo_feedback():
    ldo = _make_ldo_with_gaps()
    ldo.ceo_feedback = CEOFeedback(
        status="no_go",
        issues=[
            CEOIssue(category="ux", severity="blocker", description="Onboarding flow confusing"),
            CEOIssue(category="feel", severity="major", description="Game feels sluggish"),
        ],
    )
    ldo = agent.translate_ceo_feedback(ldo)
    total_tasks = len(ldo.tasks)
    assert total_tasks == 7, f"Expected 7 tasks (5 + 2 CEO), got {total_tasks}"
    ceo_tasks = [t for t in ldo.tasks if t.originated_from == "ceo_feedback"]
    assert len(ceo_tasks) == 2
    print(f"  CEO feedback tasks: {len(ceo_tasks)} added (total: {total_tasks})")
    print("  [PASS] Test 4: CEO Feedback -> tasks appended")


# ======================================================================
# Test 5: Escalation (>5 critical gaps)
# ======================================================================

def test_5_escalation():
    ldo = LoopDataObject.create_initial("escalate_test", "game", "unity")
    ldo.meta.iteration = 5
    ldo.gaps = [
        Gap(id=f"GAP-5-{i:03d}", category="bug", severity="critical",
            description=f"Critical bug {i}")
        for i in range(1, 8)
    ]
    ldo = agent.generate_tasks(ldo, config)
    assert ldo.regression_data.recommendation == "ceo_review", \
        f"Expected ceo_review, got {ldo.regression_data.recommendation}"
    print("  [PASS] Test 5: Escalation (>5 critical gaps)")


# ======================================================================
# Test 6: Empty gaps -> 0 tasks
# ======================================================================

def test_6_empty_gaps():
    ldo = LoopDataObject.create_initial("empty_test", "game", "unity")
    ldo.meta.iteration = 1
    ldo.gaps = []
    ldo = agent.generate_tasks(ldo, config)
    assert len(ldo.tasks) == 0, f"Expected 0 tasks, got {len(ldo.tasks)}"
    print("  [PASS] Test 6: Empty gaps -> 0 tasks")


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-011 Validation: Decision Agent ===\n")
    passed = 0
    failed = 0

    for name, fn in [
        ("test_1_tasks_from_gaps", test_1_tasks_from_gaps),
        ("test_2_task_types", test_2_task_types),
        ("test_3_unique_ids", test_3_unique_ids),
        ("test_4_ceo_feedback", test_4_ceo_feedback),
        ("test_5_escalation", test_5_escalation),
        ("test_6_empty_gaps", test_6_empty_gaps),
    ]:
        try:
            fn()
            passed += 1
        except Exception as e:
            failed += 1
            print(f"  [FAIL] {name}: {e}")

    total = passed + failed
    print(f"\nResult: {passed}/{total} passed, {failed} failed")
    if failed:
        sys.exit(1)
    print("ALL TESTS PASSED")


if __name__ == "__main__":
    main()
