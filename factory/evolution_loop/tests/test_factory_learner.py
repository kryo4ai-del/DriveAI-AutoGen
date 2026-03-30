"""Tests for P-EVO-023 -- Factory Learner: Project Memory.

7 Tests:
  1. list_projects -- findet Test-Projekte
  2. get_project_summary -- korrekte Werte
  3. search_similar_issues -- findet "crash"
  4. get_cross_project_stats -- aggregierte Statistiken
  5. get_lessons_for_project_type -- Erkenntnisse fuer "game"
  6. Nicht-existierendes Projekt -> None
  7. Leere Suche -> []
"""

import shutil
import sys
import time
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.factory_learner import FactoryLearner
from factory.evolution_loop.ldo.schema import (
    Gap,
    LoopDataObject,
    ScoreEntry,
    Task,
)
from factory.evolution_loop.ldo.storage import LDOStorage

_TEST_PROJECTS = ["learner_test_1", "learner_test_2"]


def setup_module(module):
    """Called by pytest before any test in this module."""
    _cleanup()
    _setup_test_data()


def teardown_module(module):
    """Called by pytest after all tests in this module."""
    _cleanup()


def _setup_test_data():
    """Create 2 test projects with 3 iterations each."""
    for pid, ptype, pline in [
        ("learner_test_1", "game", "unity"),
        ("learner_test_2", "business_app", "web"),
    ]:
        storage = LDOStorage(pid)
        for iteration in range(1, 4):
            ldo = LoopDataObject.create_initial(pid, ptype, pline)
            ldo.meta.iteration = iteration
            ldo.meta.loop_mode = "sprint" if iteration <= 2 else "deep"
            ldo.meta.accumulated_cost = iteration * 0.05

            ldo.scores.bug_score = ScoreEntry(
                value=50 + iteration * 10, confidence=95
            )
            ldo.scores.roadbook_match_score = ScoreEntry(
                value=40 + iteration * 15, confidence=90
            )
            ldo.scores.structural_health_score = ScoreEntry(
                value=60 + iteration * 8, confidence=85
            )
            ldo.scores.performance_score = ScoreEntry(value=50, confidence=50)
            ldo.scores.ux_score = ScoreEntry(value=50, confidence=40)
            ldo.scores.quality_score_aggregate = 50 + iteration * 8

            ldo.regression_data.trend = "improving"
            ldo.regression_data.recommendation = (
                "continue" if iteration < 3 else "ceo_review"
            )

            ldo.gaps = [
                Gap(
                    id=f"GAP-{iteration}-001",
                    category="bug",
                    severity="high",
                    description="Crash on startup",
                    affected_component="AppDelegate",
                ),
                Gap(
                    id=f"GAP-{iteration}-002",
                    category="feature",
                    severity="medium",
                    description="Missing save system",
                    affected_component="SaveManager",
                ),
            ]

            ldo.tasks = [
                Task(
                    id=f"TASK-{iteration}-001",
                    type="fix",
                    description="Fix crash",
                    target_component="AppDelegate",
                    originated_from=f"GAP-{iteration}-001",
                    priority="high",
                ),
            ]

            storage.save(ldo)


def _cleanup():
    for pid in _TEST_PROJECTS:
        d = Path("factory/evolution_loop/data") / pid
        if d.exists():
            shutil.rmtree(d, ignore_errors=True)


# ======================================================================
# Test 1: list_projects
# ======================================================================

def test_1_list_projects():
    """list_projects finds test projects."""
    learner = FactoryLearner()
    projects = learner.list_projects()
    test_projects = [
        p for p in projects if p["project_id"].startswith("learner_test_")
    ]

    assert len(test_projects) >= 2, (
        f"Expected >=2 test projects, got {len(test_projects)}"
    )

    for p in test_projects:
        assert p["iterations"] == 3
        assert p["last_aggregate_score"] > 0
        assert p["last_trend"] == "improving"
        assert p["last_recommendation"] == "ceo_review"

    print(f"  Projects found: {len(test_projects)}")
    for p in test_projects:
        print(
            f"    {p['project_id']}: {p['iterations']} iters, "
            f"agg={p['last_aggregate_score']:.1f}"
        )
    print("  [PASS] Test 1: list_projects")


# ======================================================================
# Test 2: get_project_summary
# ======================================================================

def test_2_project_summary():
    """get_project_summary returns correct values."""
    learner = FactoryLearner()
    summary = learner.get_project_summary("learner_test_1")

    assert summary is not None
    assert summary["project_id"] == "learner_test_1"
    assert summary["project_type"] == "game"
    assert summary["production_line"] == "unity"
    assert summary["total_iterations"] == 3
    assert summary["score_improvement"] == 16.0  # 74 - 58
    assert summary["mode_history"] == ["sprint", "sprint", "deep"]
    assert abs(summary["total_cost"] - 0.15) < 0.01  # 3 * 0.05
    assert summary["gaps_found_total"] == 6  # 2 gaps * 3 iterations
    assert summary["gaps_unique"] == 2  # "crash on startup" + "missing save system"
    assert summary["tasks_generated_total"] == 3  # 1 task * 3 iterations
    assert summary["final_recommendation"] == "ceo_review"
    assert summary["final_trend"] == "improving"

    print(f"  Project: {summary['project_id']}")
    print(f"  Iterations: {summary['total_iterations']}")
    print(f"  Score improvement: {summary['score_improvement']}")
    print(f"  Mode history: {summary['mode_history']}")
    print(f"  Total cost: ${summary['total_cost']:.4f}")
    print(f"  Gaps total/unique: {summary['gaps_found_total']}/{summary['gaps_unique']}")
    print(f"  Tasks: {summary['tasks_generated_total']}")
    print("  [PASS] Test 2: get_project_summary")


# ======================================================================
# Test 3: search_similar_issues
# ======================================================================

def test_3_search_similar_issues():
    """search_similar_issues finds 'crash' matches."""
    learner = FactoryLearner()
    results = learner.search_similar_issues("crash")

    assert len(results) > 0, "Expected matches for 'crash'"

    for r in results:
        assert "project_id" in r
        assert "gap" in r
        assert "was_resolved" in r
        desc = r["gap"]["description"].lower()
        assert "crash" in desc, f"Expected 'crash' in description: {desc}"

    print(f"  Similar issues for 'crash': {len(results)} found")
    for r in results[:3]:
        print(
            f"    [{r['project_id']}] iter {r['iteration']}: "
            f"{r['gap']['description']} (resolved={r['was_resolved']})"
        )
    print("  [PASS] Test 3: search_similar_issues")


# ======================================================================
# Test 4: get_cross_project_stats
# ======================================================================

def test_4_cross_project_stats():
    """get_cross_project_stats returns aggregated data."""
    learner = FactoryLearner()
    stats = learner.get_cross_project_stats()

    assert stats["total_projects"] >= 2
    assert stats["total_iterations_all"] >= 6  # 3 + 3
    assert stats["avg_iterations_per_project"] > 0
    assert stats["avg_final_aggregate"] > 0
    assert len(stats["most_common_gap_categories"]) > 0
    assert len(stats["most_common_gap_descriptions"]) > 0
    assert len(stats["project_type_distribution"]) >= 2

    print(f"  Total projects: {stats['total_projects']}")
    print(f"  Total iterations: {stats['total_iterations_all']}")
    print(f"  Avg iterations: {stats['avg_iterations_per_project']}")
    print(f"  Avg final aggregate: {stats['avg_final_aggregate']}")
    print(f"  Avg cost/project: ${stats['avg_cost_per_project']:.4f}")
    print(f"  Gap categories: {stats['most_common_gap_categories']}")
    print(f"  Top gap descriptions: {stats['most_common_gap_descriptions']}")
    print(f"  Type distribution: {stats['project_type_distribution']}")
    print(f"  Avg score improvement: {stats['avg_score_improvement']}")
    print("  [PASS] Test 4: get_cross_project_stats")


# ======================================================================
# Test 5: get_lessons_for_project_type
# ======================================================================

def test_5_lessons_for_type():
    """get_lessons_for_project_type returns insights for 'game'."""
    learner = FactoryLearner()
    lessons = learner.get_lessons_for_project_type("game")

    assert lessons["project_type"] == "game"
    assert lessons["projects_analyzed"] >= 1
    assert lessons["avg_iterations"] > 0
    assert len(lessons["common_gaps"]) > 0
    assert lessons["avg_final_score"] > 0
    assert len(lessons["typical_mode_progression"]) > 0

    print(f"  Type: {lessons['project_type']}")
    print(f"  Projects analyzed: {lessons['projects_analyzed']}")
    print(f"  Avg iterations: {lessons['avg_iterations']}")
    print(f"  Common gaps: {lessons['common_gaps']}")
    print(f"  Avg final score: {lessons['avg_final_score']}")
    print(f"  Typical progression: {lessons['typical_mode_progression']}")
    print("  [PASS] Test 5: get_lessons_for_project_type")


# ======================================================================
# Test 6: Nicht-existierendes Projekt -> None
# ======================================================================

def test_6_nonexistent_project():
    """get_project_summary returns None for unknown project."""
    learner = FactoryLearner()
    result = learner.get_project_summary("nonexistent_xyz_999")

    assert result is None, f"Expected None, got {result}"

    print("  Non-existent project -> None")
    print("  [PASS] Test 6: Non-existent project -> None")


# ======================================================================
# Test 7: Leere Suche -> []
# ======================================================================

def test_7_empty_search():
    """search_similar_issues returns [] for non-matching query."""
    learner = FactoryLearner()
    results = learner.search_similar_issues("xyznonexistent123absolutely")

    assert len(results) == 0, f"Expected [], got {len(results)} results"

    print("  No matching issues -> empty list")
    print("  [PASS] Test 7: Empty search -> []")


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-023 Validation: Factory Learner ===\n")

    # Setup
    print("--- Setup: Creating test data ---")
    _cleanup()
    _setup_test_data()
    print("  2 test projects with 3 iterations each created\n")

    tests = [
        ("Test 1: list_projects", test_1_list_projects),
        ("Test 2: get_project_summary", test_2_project_summary),
        ("Test 3: search_similar_issues", test_3_search_similar_issues),
        ("Test 4: get_cross_project_stats", test_4_cross_project_stats),
        ("Test 5: get_lessons_for_project_type", test_5_lessons_for_type),
        ("Test 6: Non-existent project", test_6_nonexistent_project),
        ("Test 7: Empty search", test_7_empty_search),
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
    print("\n--- Cleanup ---")
    _cleanup()
    print("  Test data removed")

    print(f"\n{'='*50}")
    print(f"Result: {passed}/{len(tests)} passed, {failed} failed")
    print(f"Duration: {elapsed:.2f}s")
    print(f"{'='*50}")

    if failed:
        sys.exit(1)
    print("ALL FACTORY LEARNER TESTS PASSED")


if __name__ == "__main__":
    main()
