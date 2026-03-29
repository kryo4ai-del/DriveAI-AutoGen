"""Tests for Evaluation Agent + Soft Scores — P-EVO-009 Validation.

6 Tests:
  1-2: Soft Score Performance (with data, without data)
  3-4: Soft Score UX (with data, without data)
  5:   EvaluationAgent full pipeline
  6:   Orchestrator evaluation_step delegates to EvaluationAgent
"""

import sys
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.scoring.soft_scores import SoftScoreCalculator
from factory.evolution_loop.evaluation_agent import EvaluationAgent
from factory.evolution_loop.loop_orchestrator import LoopOrchestrator
from factory.evolution_loop.ldo.schema import LoopDataObject
from factory.evolution_loop.config.config_loader import EvolutionConfig

soft = SoftScoreCalculator()


# ======================================================================
# Soft Score: Performance
# ======================================================================

def test_1_performance_with_data():
    """Performance score with build artifacts + static analysis."""
    build = {
        "paths": [f"file_{i}.py" for i in range(30)],
    }
    sim = {
        "static_analysis": {
            "total_files": 30,
            "deep_nesting": 1,
            "hardcoded_values": 2,
            "stubs": 0,
            "todos": 1,
            "error_handling_ratio": 0.6,
        },
    }
    score = soft.calculate_performance_score(build, sim)
    assert 0 <= score.value <= 100, f"Score out of range: {score.value}"
    assert score.confidence >= 45, f"Expected confidence >= 45, got {score.confidence}"
    print(f"  [PASS] Test 1: Performance (with data): {score.value}, confidence: {score.confidence}")


def test_2_performance_no_data():
    """Performance score without any data → neutral 50, low confidence."""
    score = soft.calculate_performance_score(None, None)
    assert score.value == 50.0, f"Expected 50.0, got {score.value}"
    assert score.confidence <= 20, f"Expected confidence <= 20, got {score.confidence}"
    print(f"  [PASS] Test 2: Performance (no data): {score.value}, confidence: {score.confidence}")


# ======================================================================
# Soft Score: UX
# ======================================================================

def test_3_ux_with_data():
    """UX score with roadbook targets + simulation coverage."""
    roadbook = {
        "screens": ["HomeScreen", "LoginScreen", "ProfileScreen", "SettingsScreen", "DashboardScreen"],
        "user_flows": ["login_flow", "settings_flow", "profile_flow"],
    }
    sim = {
        "roadbook_coverage": {
            "screens_covered": ["HomeScreen", "LoginScreen", "ProfileScreen", "DashboardScreen"],
            "flows_covered": ["login_flow", "settings_flow"],
        },
        "synthetic_flows": [],
    }
    score = soft.calculate_ux_score(roadbook, sim)
    assert 0 <= score.value <= 100, f"Score out of range: {score.value}"
    assert score.confidence >= 30, f"Expected confidence >= 30, got {score.confidence}"
    # 4/5 screens (20pts) + 2/3 flows (16.7pts) + 5 screens in sweet spot (25pts) + naming consistent (25pts)
    assert score.value >= 70, f"Expected score >= 70, got {score.value}"
    print(f"  [PASS] Test 3: UX (with data): {score.value}, confidence: {score.confidence}")


def test_4_ux_no_data():
    """UX score without any data → neutral 50, low confidence."""
    score = soft.calculate_ux_score(None, None)
    assert score.value == 50.0, f"Expected 50.0, got {score.value}"
    assert score.confidence <= 20, f"Expected confidence <= 20, got {score.confidence}"
    print(f"  [PASS] Test 4: UX (no data): {score.value}, confidence: {score.confidence}")


# ======================================================================
# EvaluationAgent — Full Pipeline
# ======================================================================

def test_5_evaluation_agent_full():
    """EvaluationAgent fills all 5 scores + aggregate."""
    ldo = LoopDataObject.create_initial("test-proj", "game", "game_line")
    ldo.qa_results.tests_passed = 18
    ldo.qa_results.tests_failed = 2
    ldo.qa_results.compile_errors = []
    ldo.qa_results.warnings = ["warn1"]

    ldo.roadbook_targets.features = ["feat_a", "feat_b", "feat_c"]
    ldo.roadbook_targets.screens = ["HomeScreen", "GameScreen", "MenuScreen"]
    ldo.roadbook_targets.user_flows = ["play_flow"]

    ldo.simulation_results.roadbook_coverage = {
        "features_covered": ["feat_a", "feat_b"],
        "screens_covered": ["HomeScreen", "GameScreen"],
        "flows_covered": ["play_flow"],
    }
    ldo.simulation_results.static_analysis = {
        "total_files": 20,
        "dead_code_ratio": 0.02,
        "dependency_issues": 0,
        "anti_patterns": 1,
        "error_handling_ratio": 0.5,
        "stubs": 1,
        "todos": 0,
    }
    ldo.build_artifacts.paths = [f"file_{i}.py" for i in range(20)]

    config = EvolutionConfig()
    agent = EvaluationAgent()
    result = agent.evaluate(ldo, config)

    # All scores must be filled
    assert result.scores.bug_score.value > 0, "Bug score not calculated"
    assert result.scores.bug_score.confidence > 0, "Bug score confidence is 0"
    assert result.scores.roadbook_match_score.value > 0, "Roadbook score not calculated"
    assert result.scores.structural_health_score.value > 0, "Structural score not calculated"
    assert result.scores.performance_score.value > 0, "Performance score not calculated"
    assert result.scores.performance_score.confidence > 30, "Performance confidence too low"
    assert result.scores.ux_score.value > 0, "UX score not calculated"
    assert result.scores.quality_score_aggregate > 0, "Aggregate not calculated"

    print(f"  [PASS] Test 5: EvaluationAgent full pipeline")
    print(f"         Bug={result.scores.bug_score.value:.0f} "
          f"Roadbook={result.scores.roadbook_match_score.value:.0f} "
          f"Structural={result.scores.structural_health_score.value:.0f} "
          f"Performance={result.scores.performance_score.value:.0f} "
          f"UX={result.scores.ux_score.value:.0f} "
          f"Aggregate={result.scores.quality_score_aggregate:.1f}")


# ======================================================================
# Orchestrator Delegation
# ======================================================================

def test_6_orchestrator_delegates():
    """Orchestrator.evaluation_step delegates to EvaluationAgent."""
    orch = LoopOrchestrator("test-proj", "utility", "utility_line")
    ldo = LoopDataObject.create_initial("test-proj", "utility", "utility_line")

    ldo.qa_results.tests_passed = 10
    ldo.qa_results.tests_failed = 0
    ldo.qa_results.compile_errors = []
    ldo.qa_results.warnings = []

    ldo.roadbook_targets.features = ["feat_x"]
    ldo.simulation_results.roadbook_coverage = {
        "features_covered": ["feat_x"],
    }

    result = orch.evaluation_step(ldo)

    # Scores must be filled (delegated to EvaluationAgent)
    assert result.scores.bug_score.value > 0, "Bug score not set"
    assert result.scores.quality_score_aggregate > 0, "Aggregate not set"

    # Cache must be updated
    assert orch._last_scores.get("bug", 0) > 0, "Last scores not cached"
    assert orch._last_aggregate > 0, "Last aggregate not cached"

    print(f"  [PASS] Test 6: Orchestrator delegates to EvaluationAgent")
    print(f"         Aggregate={result.scores.quality_score_aggregate:.1f} "
          f"Cached Bug={orch._last_scores['bug']:.0f}")


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-009 Validation: Evaluation Agent ===\n")
    tests = [
        test_1_performance_with_data,
        test_2_performance_no_data,
        test_3_ux_with_data,
        test_4_ux_no_data,
        test_5_evaluation_agent_full,
        test_6_orchestrator_delegates,
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
