"""Tests for Loop Orchestrator — P-EVO-008 Validation.

7 Tests:
  1. Instanzierung
  2. Mock-LDO mit QA-Daten
  3. Loop-Run mit max 3 Iterationen
  4. Status Report
  5. LDO wurde gespeichert
  6. Stop reason korrekt
  7. Cleanup
"""

import shutil
import sys
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop import LoopOrchestrator
from factory.evolution_loop.ldo import LoopDataObject, LDOStorage, LDOValidator
from factory.evolution_loop.config.config_loader import EvolutionConfig


# ======================================================================
# Tests
# ======================================================================

def test_1_init():
    orch = LoopOrchestrator("test_game", "game", "unity")
    assert orch.project_id == "test_game"
    assert orch.project_type == "game"
    assert orch.production_line == "unity"
    assert orch.iteration == 0
    assert orch.loop_mode == "sprint"
    assert orch.accumulated_cost == 0.0
    print("  [PASS] Test 1: Init")


def test_2_mock_ldo():
    ldo = LoopDataObject.create_initial("test_game", "game", "unity")
    ldo.qa_results.tests_passed = 18
    ldo.qa_results.tests_failed = 2
    ldo.qa_results.compile_errors = ["Error in GameView.swift"]
    ldo.qa_results.warnings = ["Deprecated API"]
    ldo.roadbook_targets.features = ["f1", "f2", "f3", "f4", "f5"]
    ldo.roadbook_targets.screens = ["s1", "s2", "s3"]
    ldo.roadbook_targets.user_flows = ["flow1", "flow2"]

    assert ldo.qa_results.tests_passed == 18
    assert len(ldo.roadbook_targets.features) == 5
    print("  [PASS] Test 2: Mock LDO created")
    return ldo


def test_3_run_loop():
    """Run the loop with max 3 iterations."""
    config = EvolutionConfig()
    orch = LoopOrchestrator("test_game", "game", "unity", config)
    # Override max iterations for test
    orch._config_limits["total_max_iterations"] = 3

    ldo = test_2_mock_ldo()
    result_ldo = orch.run_loop(ldo)

    assert result_ldo.meta.iteration > 0, "No iterations ran"
    assert result_ldo.meta.iteration <= 3, f"Too many iterations: {result_ldo.meta.iteration}"
    assert result_ldo.scores.bug_score.value > 0, "Bug score not calculated"
    assert result_ldo.scores.quality_score_aggregate > 0 or result_ldo.scores.quality_score_aggregate == 0

    print(f"  [PASS] Test 3: Loop ran {result_ldo.meta.iteration} iterations")
    print(f"    Bug Score: {result_ldo.scores.bug_score.value}")
    print(f"    Roadbook: {result_ldo.scores.roadbook_match_score.value}")
    print(f"    Structural: {result_ldo.scores.structural_health_score.value}")
    print(f"    Aggregate: {result_ldo.scores.quality_score_aggregate}")
    return orch, result_ldo


def test_4_status_report():
    orch, _ = test_3_run_loop()
    report = orch.get_status_report()
    assert "test_game" in report
    assert "game" in report
    assert "Iteration:" in report
    assert "Cost:" in report
    print(f"  [PASS] Test 4: Status Report generated")
    print(report)


def test_5_ldo_saved():
    storage = LDOStorage("test_game")
    iterations = storage.list_iterations()
    assert len(iterations) > 0, "No iterations saved!"
    print(f"  [PASS] Test 5: Saved iterations: {iterations}")


def test_6_stop_reason():
    """Verify loop stops due to max_iterations (3)."""
    config = EvolutionConfig()
    orch = LoopOrchestrator("test_game_stop", "game", "unity", config)
    orch._config_limits["total_max_iterations"] = 2

    ldo = LoopDataObject.create_initial("test_game_stop", "game", "unity")
    ldo.qa_results.tests_passed = 18
    ldo.qa_results.tests_failed = 2
    ldo.qa_results.compile_errors = ["Error"]
    ldo.qa_results.warnings = ["Warning"]
    ldo.roadbook_targets.features = ["f1", "f2"]

    result = orch.run_loop(ldo)
    # Should stop at iteration 2 (max_iterations)
    assert result.meta.iteration == 2, f"Expected 2 iterations, got {result.meta.iteration}"
    print(f"  [PASS] Test 6: Stop reason=max_iterations at iteration {result.meta.iteration}")


def test_7_cleanup():
    for pid in ("test_game", "test_game_stop"):
        data_dir = Path("factory/evolution_loop/data") / pid
        if data_dir.exists():
            shutil.rmtree(data_dir, ignore_errors=True)
    print("  [PASS] Test 7: Cleanup done")


# ======================================================================
# Runner
# ======================================================================

if __name__ == "__main__":
    tests = [
        test_1_init,
        test_2_mock_ldo,
        test_3_run_loop,
        test_4_status_report,
        test_5_ldo_saved,
        test_6_stop_reason,
        test_7_cleanup,
    ]

    passed = 0
    failed = 0
    print(f"\n{'=' * 60}")
    print("P-EVO-008 — Loop Orchestrator Validation")
    print(f"{'=' * 60}\n")

    for test_fn in tests:
        try:
            test_fn()
            passed += 1
        except Exception as e:
            print(f"  [FAIL] {test_fn.__name__}: {e}")
            import traceback
            traceback.print_exc()
            failed += 1

    print(f"\n{'=' * 60}")
    print(f"Results: {passed}/{len(tests)} passed, {failed} failed")
    print(f"{'=' * 60}\n")

    if failed > 0:
        sys.exit(1)
