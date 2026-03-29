"""Tests for Hard Scores + Aggregator — P-EVO-007 Validation.

11 Tests:
  1-3:  Bug Score (perfect, bad, empty)
  4-6:  Roadbook Match (full, half, empty)
  7-8:  Structural Health (good, bad)
  9-10: Aggregator (no veto, with veto)
  11:   Targets check
"""

import sys
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.scoring import HardScoreCalculator, ScoreAggregator
from factory.evolution_loop.config.config_loader import EvolutionConfig

calc = HardScoreCalculator()
agg = ScoreAggregator()
config = EvolutionConfig()


# ======================================================================
# Bug Score Tests
# ======================================================================

def test_1_bug_score_perfect():
    score = calc.calculate_bug_score({
        "tests_passed": 20, "tests_failed": 0,
        "compile_errors": [], "warnings": [],
    })
    assert score.value == 100, f"Expected 100, got {score.value}"
    assert score.confidence >= 90
    print(f"  [PASS] Test 1: Bug Score (perfect): {score.value}, confidence: {score.confidence}")


def test_2_bug_score_bad():
    score = calc.calculate_bug_score({
        "tests_passed": 10, "tests_failed": 5,
        "compile_errors": ["e1", "e2"], "warnings": ["w1", "w2", "w3"],
    })
    expected = 100 - (5 * 5) - (2 * 15) - (3 * 1)  # = 42
    assert score.value == expected, f"Expected {expected}, got {score.value}"
    print(f"  [PASS] Test 2: Bug Score (bad): {score.value}")


def test_3_bug_score_empty():
    score = calc.calculate_bug_score({})
    assert score.confidence < 20, f"Expected confidence < 20, got {score.confidence}"
    print(f"  [PASS] Test 3: Bug Score (empty): {score.value}, confidence: {score.confidence}")


# ======================================================================
# Roadbook Match Tests
# ======================================================================

def test_4_roadbook_full():
    targets = {
        "features": ["f1", "f2", "f3"],
        "screens": ["s1", "s2"],
        "user_flows": ["flow1"],
    }
    sim = {
        "roadbook_coverage": {
            "features_covered": ["f1", "f2", "f3"],
            "screens_covered": ["s1", "s2"],
        },
        "synthetic_flows": [{"flow_name": "flow1", "is_complete": True}],
    }
    score = calc.calculate_roadbook_match(targets, sim)
    assert score.value >= 95, f"Expected ~100, got {score.value}"
    print(f"  [PASS] Test 4: Roadbook Match (full): {score.value}")


def test_5_roadbook_half():
    targets = {
        "features": ["f1", "f2", "f3"],
        "screens": ["s1", "s2"],
        "user_flows": ["flow1"],
    }
    sim = {
        "roadbook_coverage": {
            "features_covered": ["f1"],
            "screens_covered": ["s1"],
        },
        "synthetic_flows": [{"flow_name": "flow1", "is_complete": False}],
    }
    score = calc.calculate_roadbook_match(targets, sim)
    assert 20 < score.value < 40, f"Expected ~28, got {score.value}"
    print(f"  [PASS] Test 5: Roadbook Match (half): {score.value}")


def test_6_roadbook_empty():
    score = calc.calculate_roadbook_match({"features": [], "screens": [], "user_flows": []})
    assert score.value == 0
    print(f"  [PASS] Test 6: Roadbook Match (empty): {score.value}")


# ======================================================================
# Structural Health Tests
# ======================================================================

def test_7_structural_good():
    sim = {
        "static_analysis": {
            "dead_code_ratio": 0.02,
            "hardcoded_values": 0,
            "deep_nesting": 0,
            "error_handling_ratio": 0.9,
        },
    }
    score = calc.calculate_structural_health(sim)
    assert score.value >= 85, f"Expected >= 85, got {score.value}"
    print(f"  [PASS] Test 7: Structural Health (good): {score.value}")


def test_8_structural_bad():
    sim = {
        "static_analysis": {
            "dead_code_ratio": 0.3,
            "hardcoded_values": 10,
            "deep_nesting": 8,
            "error_handling_ratio": 0.1,
        },
    }
    score = calc.calculate_structural_health(sim)
    assert score.value < 40, f"Expected < 40, got {score.value}"
    print(f"  [PASS] Test 8: Structural Health (bad): {score.value}")


# ======================================================================
# Aggregator Tests
# ======================================================================

def test_9_aggregate_no_veto():
    scores = {
        "bug_score": {"value": 95, "confidence": 95},
        "roadbook_match": {"value": 96, "confidence": 90},
        "structural_health": {"value": 90, "confidence": 85},
        "performance_score": {"value": 75, "confidence": 50},
        "ux_score": {"value": 70, "confidence": 40},
    }
    weights = config.get_score_weights("game")
    targets = config.get_quality_targets()
    result = agg.aggregate(scores, weights, targets)
    assert not result["veto_active"], f"Unexpected veto: {result['veto_reason']}"
    assert result["quality_score_aggregate"] > 70
    print(f"  [PASS] Test 9: Aggregate (no veto): {result['quality_score_aggregate']:.1f}")


def test_10_aggregate_with_veto():
    scores = {
        "bug_score": {"value": 40, "confidence": 95},
        "roadbook_match": {"value": 90, "confidence": 90},
        "structural_health": {"value": 85, "confidence": 85},
        "performance_score": {"value": 75, "confidence": 50},
        "ux_score": {"value": 70, "confidence": 40},
    }
    weights = config.get_score_weights("game")
    targets = config.get_quality_targets()
    result = agg.aggregate(scores, weights, targets)
    assert result["veto_active"], "Expected veto but none active"
    assert result["quality_score_aggregate"] <= 50, \
        f"Expected <= 50 with bug veto, got {result['quality_score_aggregate']}"
    assert "bug_score" in result["veto_reason"]
    print(f"  [PASS] Test 10: Aggregate (veto): {result['quality_score_aggregate']:.1f}, "
          f"reason={result['veto_reason']}")


def test_11_targets_check():
    scores = {
        "bug_score": {"value": 95, "confidence": 95},
        "roadbook_match": {"value": 90, "confidence": 90},
        "structural_health": {"value": 85, "confidence": 85},
        "performance_score": {"value": 75, "confidence": 50},
        "ux_score": {"value": 70, "confidence": 40},
    }
    targets = config.get_quality_targets()
    check = agg.check_targets_met(scores, targets)

    assert isinstance(check["all_met"], bool)
    assert isinstance(check["met"], list)
    assert isinstance(check["not_met"], list)
    assert len(check["details"]) > 0

    print(f"  [PASS] Test 11: Targets met={check['all_met']}, "
          f"met={check['met']}, not_met={check['not_met']}")


# ======================================================================
# Runner
# ======================================================================

if __name__ == "__main__":
    tests = [
        test_1_bug_score_perfect,
        test_2_bug_score_bad,
        test_3_bug_score_empty,
        test_4_roadbook_full,
        test_5_roadbook_half,
        test_6_roadbook_empty,
        test_7_structural_good,
        test_8_structural_bad,
        test_9_aggregate_no_veto,
        test_10_aggregate_with_veto,
        test_11_targets_check,
    ]

    passed = 0
    failed = 0
    print(f"\n{'=' * 60}")
    print("P-EVO-007 — Hard Scores + Aggregator Validation")
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
