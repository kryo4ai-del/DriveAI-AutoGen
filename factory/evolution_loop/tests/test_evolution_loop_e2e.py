"""End-to-End Tests for the Evolution Loop — P-EVO-013 Validation.

5 Scenarios:
  1. Happy Path: medium build → stagnation after ~3 iterations
  2. Perfect Build: all targets met → CEO review after 1 iteration
  3. Max Iterations: forced stop at limit
  4. Score Tracking: regression data populated across iterations
  5. Status Report: get_status_report() contains all fields
"""

import shutil
import sys
import time
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.loop_orchestrator import LoopOrchestrator
from factory.evolution_loop.ldo.schema import LoopDataObject
from factory.evolution_loop.ldo.storage import LDOStorage

_DATA_DIR = Path("factory/evolution_loop/data")


def _cleanup(project_id: str) -> None:
    """Remove test data directory."""
    path = _DATA_DIR / project_id
    if path.exists():
        shutil.rmtree(path, ignore_errors=True)


def _make_medium_ldo(project_id: str) -> LoopDataObject:
    """Create a medium-quality LDO for testing."""
    ldo = LoopDataObject.create_initial(project_id, "game", "unity")

    # QA results: some failures
    ldo.qa_results.tests_passed = 20
    ldo.qa_results.tests_failed = 2
    ldo.qa_results.compile_errors = ["Error: undefined variable 'x'"]
    ldo.qa_results.warnings = ["Deprecated API call"]

    # Roadbook targets
    ldo.roadbook_targets.features = [
        "save_system", "inventory", "combat", "crafting", "tutorial",
        "settings", "leaderboard", "achievements", "shop", "profile",
    ]
    ldo.roadbook_targets.screens = [
        "MainMenuScreen", "GameScreen", "SettingsScreen",
        "InventoryScreen", "ShopScreen",
    ]
    ldo.roadbook_targets.user_flows = ["start_game", "buy_item", "save_progress"]

    # Simulation: partial coverage (stub won't change this)
    ldo.simulation_results.roadbook_coverage = {
        "features_covered": ["save_system", "combat", "settings", "profile",
                              "inventory", "shop", "tutorial"],
        "screens_covered": ["MainMenuScreen", "GameScreen", "SettingsScreen"],
        "flows_covered": ["start_game"],
    }
    ldo.simulation_results.static_analysis = {
        "total_files": 40,
        "dead_code_ratio": 0.08,
        "dependency_issues": 2,
        "anti_patterns": 3,
        "error_handling_ratio": 0.5,
        "stubs": 2,
        "todos": 3,
        "deep_nesting": 2,
        "hardcoded_values": 1,
    }

    # Build artifacts
    ldo.build_artifacts.paths = [f"src/file_{i}.swift" for i in range(40)]

    return ldo


def _make_perfect_ldo(project_id: str) -> LoopDataObject:
    """Create a perfect LDO where all targets should be met."""
    ldo = LoopDataObject.create_initial(project_id, "utility", "ios")

    # Perfect QA
    ldo.qa_results.tests_passed = 30
    ldo.qa_results.tests_failed = 0
    ldo.qa_results.compile_errors = []
    ldo.qa_results.warnings = []

    # Roadbook targets
    ldo.roadbook_targets.features = ["export", "import", "settings"]
    ldo.roadbook_targets.screens = ["HomeScreen", "ExportScreen", "SettingsScreen"]
    ldo.roadbook_targets.user_flows = ["export_flow", "settings_flow"]

    # Full simulation coverage
    ldo.simulation_results.roadbook_coverage = {
        "features_covered": ["export", "import", "settings"],
        "screens_covered": ["HomeScreen", "ExportScreen", "SettingsScreen"],
        "flows_covered": ["export_flow", "settings_flow"],
    }
    ldo.simulation_results.static_analysis = {
        "total_files": 20,
        "dead_code_ratio": 0.01,
        "dependency_issues": 0,
        "anti_patterns": 0,
        "error_handling_ratio": 0.9,
        "stubs": 0,
        "todos": 0,
        "deep_nesting": 0,
        "hardcoded_values": 0,
    }

    # Build artifacts
    ldo.build_artifacts.paths = [f"src/file_{i}.swift" for i in range(20)]

    return ldo


# ======================================================================
# Scenario 1: Happy Path (medium build)
# ======================================================================

def test_scenario_1_happy_path():
    """Medium build: loop runs multiple iterations, stops via stagnation."""
    pid = "e2e_test_happy"
    _cleanup(pid)

    orch = LoopOrchestrator(pid, "game", "unity")
    orch._config_limits["total_max_iterations"] = 5

    ldo = _make_medium_ldo(pid)
    result = orch.run_loop(ldo)

    storage = LDOStorage(pid)
    saved = storage.list_iterations()

    # Assertions
    assert len(saved) >= 2, f"Expected at least 2 saved iterations, got {len(saved)}"
    assert result.scores.bug_score.value > 0, "Bug score not calculated"
    assert result.scores.roadbook_match_score.value > 0, "Roadbook score not calculated"
    assert result.scores.structural_health_score.value > 0, "Structural score not calculated"
    assert result.scores.performance_score.value > 0, "Performance score not calculated"
    assert result.scores.ux_score.value > 0, "UX score not calculated"
    assert result.scores.quality_score_aggregate > 0, "Aggregate not calculated"
    assert len(result.gaps) >= 3, f"Expected at least 3 gaps, got {len(result.gaps)}"
    assert len(result.tasks) >= 3, f"Expected at least 3 tasks, got {len(result.tasks)}"
    assert result.regression_data.trend != "", "Trend not set"

    print(f"  Iterations: {orch.iteration}, Saved: {len(saved)}")
    print(f"  Aggregate: {result.scores.quality_score_aggregate:.1f}")
    print(f"  Gaps: {len(result.gaps)}, Tasks: {len(result.tasks)}")
    print(f"  Trend: {result.regression_data.trend}, Rec: {result.regression_data.recommendation}")
    print("  [PASS] Scenario 1: Happy Path")

    _cleanup(pid)
    return {
        "iterations": orch.iteration,
        "aggregate": result.scores.quality_score_aggregate,
        "gaps": len(result.gaps),
        "tasks": len(result.tasks),
        "recommendation": orch._last_recommendation,
    }


# ======================================================================
# Scenario 2: Perfect Build → CEO Review after 1 iteration
# ======================================================================

def test_scenario_2_perfect_build():
    """Perfect build: all targets met → CEO review on first iteration."""
    pid = "e2e_test_perfect"
    _cleanup(pid)

    orch = LoopOrchestrator(pid, "utility", "ios")
    orch._config_limits["total_max_iterations"] = 5

    ldo = _make_perfect_ldo(pid)
    result = orch.run_loop(ldo)

    storage = LDOStorage(pid)
    saved = storage.list_iterations()

    # Should stop after 1 iteration with ceo_review (targets met)
    assert orch.iteration == 1, f"Expected 1 iteration, got {orch.iteration}"
    assert len(saved) == 1, f"Expected 1 saved, got {len(saved)}"
    assert orch._last_recommendation == "ceo_review", \
        f"Expected ceo_review, got {orch._last_recommendation}"
    assert len(result.gaps) == 0, f"Expected 0 gaps, got {len(result.gaps)}"

    print(f"  Iterations: {orch.iteration}")
    print(f"  Aggregate: {result.scores.quality_score_aggregate:.1f}")
    print(f"  Gaps: {len(result.gaps)}, Tasks: {len(result.tasks)}")
    print(f"  Recommendation: {orch._last_recommendation}")
    print("  [PASS] Scenario 2: Perfect Build -> CEO Review")

    _cleanup(pid)
    return {
        "iterations": orch.iteration,
        "aggregate": result.scores.quality_score_aggregate,
        "gaps": len(result.gaps),
        "recommendation": orch._last_recommendation,
    }


# ======================================================================
# Scenario 3: Max Iterations Limit
# ======================================================================

def test_scenario_3_max_iterations():
    """Loop stops at exactly max_iterations."""
    pid = "e2e_test_maxiter"
    _cleanup(pid)

    max_iter = 3
    orch = LoopOrchestrator(pid, "game", "unity")
    orch._config_limits["total_max_iterations"] = max_iter

    ldo = _make_medium_ldo(pid)
    result = orch.run_loop(ldo)

    storage = LDOStorage(pid)
    saved = storage.list_iterations()

    # Should stop at exactly max_iter (stagnation may kick in at same point)
    assert orch.iteration <= max_iter, \
        f"Ran more than {max_iter} iterations: {orch.iteration}"
    assert len(saved) == orch.iteration

    print(f"  Iterations: {orch.iteration} (max: {max_iter})")
    print(f"  Recommendation: {orch._last_recommendation}")
    print("  [PASS] Scenario 3: Max Iterations Limit")

    _cleanup(pid)
    return {
        "iterations": orch.iteration,
        "recommendation": orch._last_recommendation,
    }


# ======================================================================
# Scenario 4: Score Tracking over iterations
# ======================================================================

def test_scenario_4_score_tracking():
    """Regression data is populated correctly across iterations."""
    pid = "e2e_test_tracking"
    _cleanup(pid)

    orch = LoopOrchestrator(pid, "game", "unity")
    orch._config_limits["total_max_iterations"] = 5

    ldo = _make_medium_ldo(pid)
    result = orch.run_loop(ldo)

    # Check regression data
    rd = result.regression_data
    assert rd.trend in ("improving", "stagnating", "declining"), \
        f"Unexpected trend: {rd.trend}"
    assert rd.recommendation in ("continue", "ceo_review", "stop"), \
        f"Unexpected recommendation: {rd.recommendation}"

    # If more than 1 iteration, comparison should be populated
    if orch.iteration > 1:
        assert len(rd.comparison_to_previous) > 0, "comparison_to_previous empty"

    # Stagnation expected (stub doesn't improve scores)
    if orch.iteration >= 3:
        assert rd.iterations_without_improvement >= 1, \
            f"Expected stagnation tracking, got {rd.iterations_without_improvement}"

    print(f"  Iterations: {orch.iteration}")
    print(f"  Trend: {rd.trend}")
    print(f"  Without improvement: {rd.iterations_without_improvement}")
    print(f"  Regressions detected: {len(rd.regressions_detected)}")
    print(f"  Comparison keys: {list(rd.comparison_to_previous.keys())}")
    print("  [PASS] Scenario 4: Score Tracking")

    _cleanup(pid)
    return {
        "iterations": orch.iteration,
        "trend": rd.trend,
        "without_improvement": rd.iterations_without_improvement,
    }


# ======================================================================
# Scenario 5: Status Report
# ======================================================================

def test_scenario_5_status_report():
    """get_status_report() contains all relevant information."""
    pid = "e2e_test_report"
    _cleanup(pid)

    orch = LoopOrchestrator(pid, "game", "unity")
    orch._config_limits["total_max_iterations"] = 3

    ldo = _make_medium_ldo(pid)
    orch.run_loop(ldo)

    report = orch.get_status_report()

    assert pid in report, "Project ID missing from report"
    assert "Iteration" in report, "Iteration missing from report"
    assert "Mode" in report, "Mode missing from report"
    assert "Cost" in report, "Cost missing from report"
    assert "Scores" in report or "Bug" in report, "Scores missing from report"
    assert "Recommendation" in report, "Recommendation missing from report"

    print(f"  Report:\n{report}")
    print("  [PASS] Scenario 5: Status Report")

    _cleanup(pid)
    return {"report_length": len(report)}


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-013 Validation: End-to-End Loop Test ===\n")

    scenarios = [
        ("Scenario 1: Happy Path", test_scenario_1_happy_path),
        ("Scenario 2: Perfect Build", test_scenario_2_perfect_build),
        ("Scenario 3: Max Iterations", test_scenario_3_max_iterations),
        ("Scenario 4: Score Tracking", test_scenario_4_score_tracking),
        ("Scenario 5: Status Report", test_scenario_5_status_report),
    ]

    start = time.time()
    passed = 0
    failed = 0
    results = {}

    for name, fn in scenarios:
        print(f"\n--- {name} ---")
        try:
            result = fn()
            results[name] = result
            passed += 1
        except Exception as e:
            failed += 1
            print(f"  [FAIL] {name}: {e}")
            import traceback
            traceback.print_exc()

    elapsed = time.time() - start

    # Final cleanup (belt and suspenders)
    for pid in ["e2e_test_happy", "e2e_test_perfect", "e2e_test_maxiter",
                "e2e_test_tracking", "e2e_test_report"]:
        _cleanup(pid)

    # Summary
    print(f"\n{'='*50}")
    print(f"Result: {passed}/{len(scenarios)} passed, {failed} failed")
    print(f"Duration: {elapsed:.2f}s")
    if results:
        print("\nSummary:")
        for name, r in results.items():
            print(f"  {name}: {r}")
    print(f"{'='*50}")

    if failed:
        sys.exit(1)
    print("ALL SCENARIOS PASSED")


if __name__ == "__main__":
    main()
