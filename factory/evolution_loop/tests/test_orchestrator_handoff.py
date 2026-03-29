"""Tests for Orchestrator Handoff — P-EVO-006 Validation.

5 Tests:
  1. receive_from_orchestrator with mock build + QA data → valid LDO
  2. receive_from_orchestrator with empty dicts → valid LDO
  3. send_tasks_to_orchestrator → correct format
  4. create_handoff_report → both directions
  5. receive_from_orchestrator with None → graceful handling
"""

import sys
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.adapters.orchestrator_handoff import OrchestratorHandoff
from factory.evolution_loop.ldo.schema import LoopDataObject
from factory.evolution_loop.ldo.validator import LDOValidator


def test_1_receive_from_orchestrator():
    """Test 1: receive with mock build + QA data → valid LDO."""
    handoff = OrchestratorHandoff()
    validator = LDOValidator()

    mock_build = {
        "files": ["src/main.swift", "src/GameView.swift", "src/GameModel.swift"],
        "status": "success",
        "platform": "ios",
    }
    mock_qa = {
        "tests_passed": 12,
        "tests_failed": 2,
        "errors": ["Assertion failed in test_game_logic"],
        "warnings": ["Deprecated API usage"],
    }

    ldo = handoff.receive_from_orchestrator(mock_build, mock_qa, "test_game", "game", "ios")
    result = validator.validate(ldo)

    assert result.is_valid, f"LDO invalid: {result.errors}"
    assert ldo.meta.project_id == "test_game"
    assert ldo.meta.project_type == "game"
    assert ldo.meta.production_line == "ios"
    assert ldo.build_artifacts.compile_status == "success"
    assert len(ldo.build_artifacts.paths) == 3
    assert ldo.qa_results.tests_passed == 12
    assert ldo.qa_results.tests_failed == 2
    assert len(ldo.qa_results.compile_errors) == 1
    assert len(ldo.qa_results.warnings) == 1

    print(f"  [PASS] Test 1: Receive from orchestrator — valid={result.is_valid}")


def test_2_receive_empty():
    """Test 2: receive with empty dicts → valid LDO."""
    handoff = OrchestratorHandoff()
    validator = LDOValidator()

    ldo = handoff.receive_from_orchestrator({}, {}, "empty_test", "utility", "web")
    result = validator.validate(ldo)

    assert result.is_valid, f"LDO invalid: {result.errors}"
    assert ldo.meta.project_id == "empty_test"
    assert ldo.build_artifacts.compile_status == "not_built"
    assert ldo.qa_results.tests_passed == 0
    assert ldo.qa_results.tests_failed == 0

    print("  [PASS] Test 2: Receive empty — valid")


def test_3_send_tasks():
    """Test 3: send_tasks_to_orchestrator → correct format."""
    handoff = OrchestratorHandoff()

    mock_tasks = [
        {
            "id": "TASK-1-001",
            "type": "fix",
            "description": "Fix crash in GameView",
            "target_component": "GameView.swift",
            "originated_from": "GAP-1-001",
            "priority": "critical",
        },
        {
            "id": "TASK-1-002",
            "type": "implement",
            "description": "Add save system",
            "target_component": "SaveManager",
            "originated_from": "GAP-1-002",
            "priority": "high",
        },
    ]

    orch_tasks = handoff.send_tasks_to_orchestrator(mock_tasks, iteration=1)

    assert "tasks" in orch_tasks
    assert len(orch_tasks["tasks"]) == 2
    assert orch_tasks["source"] == "evolution_loop"
    assert orch_tasks["iteration"] == 1

    t1 = orch_tasks["tasks"][0]
    assert t1["action"] == "fix"
    assert t1["description"] == "Fix crash in GameView"
    assert t1["target"] == "GameView.swift"
    assert t1["priority"] == "critical"

    t2 = orch_tasks["tasks"][1]
    assert t2["action"] == "implement"
    assert t2["priority"] == "high"

    # Empty tasks
    empty = handoff.send_tasks_to_orchestrator([], iteration=0)
    assert empty["tasks"] == []

    # None tasks
    none_tasks = handoff.send_tasks_to_orchestrator(None, iteration=0)
    assert none_tasks["tasks"] == []

    print(f"  [PASS] Test 3: Send {len(orch_tasks['tasks'])} tasks formatted")


def test_4_handoff_reports():
    """Test 4: create_handoff_report → both directions."""
    handoff = OrchestratorHandoff()

    mock_build = {
        "files": ["src/main.swift", "src/GameView.swift", "src/GameModel.swift"],
        "status": "success",
        "platform": "ios",
    }
    mock_qa = {
        "tests_passed": 12,
        "tests_failed": 2,
        "errors": ["Assertion failed"],
        "warnings": ["Deprecated"],
    }

    ldo = handoff.receive_from_orchestrator(mock_build, mock_qa, "test_game", "game", "ios")

    # to_loop report
    report_to = handoff.create_handoff_report(ldo, "to_loop")
    assert "test_game" in report_to
    assert "compile=success" in report_to
    assert "3 build files" in report_to
    print(f"  Report to_loop: {report_to}")

    # to_orchestrator report (needs tasks)
    from factory.evolution_loop.ldo.schema import Task
    ldo.tasks = [
        Task(id="T1", type="fix", priority="critical", description="Fix crash"),
        Task(id="T2", type="implement", priority="high", description="Add feature"),
        Task(id="T3", type="refactor", priority="medium", description="Cleanup"),
    ]
    report_from = handoff.create_handoff_report(ldo, "to_orchestrator")
    assert "3 tasks" in report_from
    assert "critical" in report_from
    print(f"  Report to_orch: {report_from}")

    print("  [PASS] Test 4: Handoff reports")


def test_5_none_handling():
    """Test 5: receive with None → graceful handling."""
    handoff = OrchestratorHandoff()
    validator = LDOValidator()

    ldo = handoff.receive_from_orchestrator(None, None, "null_test", "game", "unity")

    result = validator.validate(ldo)
    assert result.is_valid, f"LDO invalid: {result.errors}"
    assert ldo.meta.project_id == "null_test"
    assert ldo.meta.project_type == "game"
    assert ldo.meta.production_line == "unity"
    assert ldo.build_artifacts.compile_status == "not_built"
    assert ldo.qa_results.tests_passed == 0

    # Also test with full BuildReport format
    full_build = {
        "plan": {
            "project_name": "test_proj",
            "status": "completed",
            "steps": [
                {
                    "id": "step_001",
                    "name": "Feature A",
                    "line": "ios",
                    "language": "swift",
                    "status": "completed",
                    "result": {"files": ["a.swift", "b.swift"]},
                },
                {
                    "id": "step_002",
                    "name": "Feature B",
                    "line": "ios",
                    "language": "swift",
                    "status": "failed",
                    "result": {"error": "compile error"},
                },
            ],
        },
        "started": "2026-03-28T10:00:00",
        "finished": "2026-03-28T10:05:00",
        "step_results": [
            {"step_id": "step_001", "name": "Feature A", "status": "completed"},
            {"step_id": "step_002", "name": "Feature B", "status": "failed"},
        ],
    }
    ldo2 = handoff.receive_from_orchestrator(full_build, {}, "full_test", "business_app", "ios")
    r2 = validator.validate(ldo2)
    assert r2.is_valid, f"Full BuildReport LDO invalid: {r2.errors}"
    # Plan had "completed" status but has failed steps — overall still "success" because plan.status says so
    # Actually let's check: plan status is "completed" → compile_status = "success"
    # But it has failed steps — the plan overall was still "completed" by orchestrator logic
    assert ldo2.build_artifacts.compile_status == "success"
    assert len(ldo2.build_artifacts.paths) == 2  # from step_001 result.files
    assert ldo2.build_artifacts.platform_details["steps_completed"] == 1
    assert ldo2.build_artifacts.platform_details["steps_failed"] == 1

    print("  [PASS] Test 5: None + full BuildReport handling")


# ======================================================================
# Runner
# ======================================================================

if __name__ == "__main__":
    tests = [
        test_1_receive_from_orchestrator,
        test_2_receive_empty,
        test_3_send_tasks,
        test_4_handoff_reports,
        test_5_none_handling,
    ]

    passed = 0
    failed = 0
    print(f"\n{'=' * 60}")
    print("P-EVO-006 — Orchestrator Handoff Validation")
    print(f"{'=' * 60}\n")

    for test_fn in tests:
        try:
            test_fn()
            passed += 1
        except Exception as e:
            print(f"  [FAIL] {test_fn.__name__}: {e}")
            failed += 1

    print(f"\n{'=' * 60}")
    print(f"Results: {passed}/{len(tests)} passed, {failed} failed")
    print(f"{'=' * 60}\n")

    if failed > 0:
        sys.exit(1)
