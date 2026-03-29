"""Tests for QA-to-LDO Adapter — P-EVO-005 Validation.

5 Tests:
  1. transform_qa_forge_results  → valid partial dict
  2. transform_qa_department_results (QAResult format)  → valid partial dict
  3. transform_qa_department_results (QAReport JSON format)  → valid partial dict
  4. merge_results  → correct combined dict
  5. Score calculations  → correct values
"""

import sys
from pathlib import Path

# Ensure project root is on sys.path
_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.adapters.qa_to_ldo_adapter import QAToLDOAdapter


def _make_forge_result() -> dict:
    """Create a realistic QA Forge result dict."""
    return {
        "project": "echomatch",
        "visual_results": [
            {"name": "icon_check", "overall": "pass", "detail": "OK"},
            {"name": "screenshot_check", "overall": "warn", "detail": "Low contrast"},
            {"name": "splash_check", "overall": "fail", "detail": "Missing splash",
             "component": "splash_screen"},
        ],
        "audio_results": [
            {"name": "volume_check", "overall": "pass"},
        ],
        "animation_results": [
            {"name": "fps_check", "overall": "pass"},
            {"name": "jank_check", "overall": "pass"},
        ],
        "scene_results": [
            {"name": "scene_flow", "overall": "pass"},
        ],
        "compliance": {"score": 85},
        "verdict": "warn",
        "duration_s": 12.5,
        "errors": [],
    }


def _make_qa_result() -> dict:
    """Create a realistic QAResult-like dict (from dataclass)."""
    return {
        "status": "PASSED",
        "build_result": {
            "success": True,
            "status": "PASSED",
            "compiler_output": "",
            "error_lines": [],
            "warnings_count": 3,
            "duration_seconds": 8.2,
            "reason": "",
        },
        "ops_result": {
            "blocking_count": 0,
            "warning_count": 2,
            "total_issues": 2,
            "status": "PASSED",
        },
        "test_result": {
            "status": "PASSED",
            "tests_total": 15,
            "tests_passed": 13,
            "tests_failed": 2,
            "tests_skipped": 0,
            "failure_rate": 0.133,
            "coverage_insufficient": False,
            "test_time_seconds": 5.4,
            "failures": [
                {"test_name": "test_login", "error_message": "Timeout after 5s"},
                {"test_name": "test_signup", "error_message": "AssertionError"},
            ],
            "reason": "",
            "has_crashes": False,
        },
        "gate_result": {
            "passed": True,
            "checks": [],
            "summary": "All checks passed",
        },
        "bounce_count": 0,
        "report_path": "factory/qa/reports/echomatch_web_20260328.json",
        "recommendation": "Ship it.",
        "duration_seconds": 25.0,
    }


def _make_qa_report_json() -> dict:
    """Create a realistic QAReport.to_dict() JSON."""
    return {
        "project": "echomatch",
        "platform": "web",
        "timestamp": "2026-03-28T10:00:00Z",
        "status": "FAILED",
        "duration_seconds": 30,
        "bounce_count": 1,
        "phases": {
            "build": {
                "status": "PASSED",
                "duration_seconds": 5.0,
                "details": {"compiler_errors": 0, "repaired": False},
            },
            "operations": {
                "status": "FAILED",
                "duration_seconds": 2.0,
                "details": {"blocking_count": 2, "warning_count": 3, "total_issues": 5},
            },
            "tests": {
                "status": "FAILED",
                "duration_seconds": 10.0,
                "details": {
                    "total": 20,
                    "passed": 16,
                    "failed": 4,
                    "failure_rate": 0.2,
                    "has_crashes": False,
                },
            },
            "quality_gate": {
                "status": "FAILED",
                "duration_seconds": 0.1,
                "details": {
                    "failure_rate": {
                        "passed": False,
                        "required": True,
                        "detail": "Failure rate 20% exceeds max 15%",
                    },
                    "operations_clean": {
                        "passed": False,
                        "required": True,
                        "detail": "2 blocking issues",
                    },
                },
            },
        },
        "warnings": [
            {"title": "slow_tests", "detail": "3 tests took >2s"},
        ],
        "recommendation": "Bounce #1: Fix quality_gate issue",
    }


# ======================================================================
# Tests
# ======================================================================

def test_1_transform_qa_forge():
    """Test 1: QA Forge → valid partial dict."""
    adapter = QAToLDOAdapter()
    result = adapter.transform_qa_forge_results(_make_forge_result())

    # Required keys
    assert "qa_results" in result, "Missing qa_results"
    assert "scores" in result, "Missing scores"
    assert "gaps" in result, "Missing gaps"

    # qa_results structure
    qa = result["qa_results"]
    assert qa["tests_passed"] == 5, f"Expected 5 passed, got {qa['tests_passed']}"
    assert qa["tests_failed"] == 1, f"Expected 1 failed, got {qa['tests_failed']}"
    assert len(qa["test_details"]) == 7, f"Expected 7 details, got {len(qa['test_details'])}"

    # Scores: ux + performance
    scores = result["scores"]
    assert "ux_score" in scores, "Missing ux_score"
    assert "performance_score" in scores, "Missing performance_score"
    assert 0 <= scores["ux_score"]["value"] <= 100
    assert 0 <= scores["performance_score"]["value"] <= 100
    assert scores["ux_score"]["confidence"] > 0
    assert scores["performance_score"]["confidence"] > 0

    # Gaps: 1 failure → 1 gap
    assert len(result["gaps"]) == 1, f"Expected 1 gap, got {len(result['gaps'])}"
    gap = result["gaps"][0]
    assert gap["category"] == "ux"
    assert gap["severity"] == "high"

    print("  [PASS] Test 1: QA Forge transform")


def test_2_transform_qa_department_result():
    """Test 2: QA Department (QAResult format) → valid partial dict."""
    adapter = QAToLDOAdapter()
    result = adapter.transform_qa_department_results(_make_qa_result())

    assert "build_artifacts" in result
    assert "qa_results" in result
    assert "scores" in result
    assert "gaps" in result

    # Build artifacts
    ba = result["build_artifacts"]
    assert ba["compile_status"] == "success"

    # QA results
    qa = result["qa_results"]
    assert qa["tests_passed"] == 13
    assert qa["tests_failed"] == 2
    assert len(qa["test_details"]) == 2  # 2 failures

    # Scores: bug + structural
    scores = result["scores"]
    assert "bug_score" in scores
    assert "structural_health_score" in scores
    assert 0 <= scores["bug_score"]["value"] <= 100
    assert 0 <= scores["structural_health_score"]["value"] <= 100

    # Gaps: 2 test failures
    assert len(result["gaps"]) == 2
    assert all(g["category"] == "bug" for g in result["gaps"])

    print("  [PASS] Test 2: QA Department (QAResult) transform")


def test_3_transform_qa_department_report_json():
    """Test 3: QA Department (QAReport JSON format) → valid partial dict."""
    adapter = QAToLDOAdapter()
    result = adapter.transform_qa_department_results(_make_qa_report_json())

    assert "build_artifacts" in result
    assert "qa_results" in result
    assert "scores" in result
    assert "gaps" in result

    ba = result["build_artifacts"]
    assert ba["compile_status"] == "success"  # build PASSED

    qa = result["qa_results"]
    assert qa["tests_passed"] == 16
    assert qa["tests_failed"] == 4

    scores = result["scores"]
    assert scores["bug_score"]["value"] == 0.0  # 20% failure rate → 100 - 100 = 0
    assert scores["structural_health_score"]["value"] == 35.0  # 100 - 50 - 15 = 35

    # Gaps: 1 ops blocking + 2 gate failures
    assert len(result["gaps"]) == 3
    categories = {g["category"] for g in result["gaps"]}
    assert "structural" in categories
    assert "bug" in categories

    # _dept_meta
    meta = result.get("_dept_meta", {})
    assert meta["status"] == "FAILED"
    assert meta["bounce_count"] == 1

    print("  [PASS] Test 3: QA Department (QAReport JSON) transform")


def test_4_merge_results():
    """Test 4: Merge QA Forge + Department → combined dict."""
    adapter = QAToLDOAdapter()
    forge_partial = adapter.transform_qa_forge_results(_make_forge_result())
    dept_partial = adapter.transform_qa_department_results(_make_qa_result())
    merged = adapter.merge_results(forge_partial, dept_partial)

    # All keys present
    assert "build_artifacts" in merged
    assert "qa_results" in merged
    assert "scores" in merged
    assert "gaps" in merged

    # qa_results summed
    qa = merged["qa_results"]
    assert qa["tests_passed"] == 13 + 5  # dept + forge
    assert qa["tests_failed"] == 2 + 1

    # scores: 4 distinct scores (bug, structural from dept; ux, performance from forge)
    scores = merged["scores"]
    assert "bug_score" in scores
    assert "structural_health_score" in scores
    assert "ux_score" in scores
    assert "performance_score" in scores

    # gaps concatenated
    assert len(merged["gaps"]) == 2 + 1  # 2 from dept + 1 from forge

    # build_artifacts from dept
    assert merged["build_artifacts"]["compile_status"] == "success"

    # Edge cases
    assert adapter.merge_results(None, None) == {}
    assert adapter.merge_results(forge_partial, None) == forge_partial
    assert adapter.merge_results(None, dept_partial) == dept_partial

    print("  [PASS] Test 4: Merge results")


def test_5_score_calculations():
    """Test 5: Score calculation correctness."""
    adapter = QAToLDOAdapter()

    # Bug score: failure_rate 0.133 → 100 - (0.133 * 500) = 33.5
    dept = adapter.transform_qa_department_results(_make_qa_result())
    assert dept["scores"]["bug_score"]["value"] == 33.5, \
        f"Expected 33.5, got {dept['scores']['bug_score']['value']}"

    # Structural: 0 blocking, 2 warnings → 100 - 0 - 10 = 90
    assert dept["scores"]["structural_health_score"]["value"] == 90.0, \
        f"Expected 90.0, got {dept['scores']['structural_health_score']['value']}"

    # Confidence: 15 tests → 80.0
    assert dept["scores"]["bug_score"]["confidence"] == 80.0

    # Report format: failure_rate 0.2 → 100 - 100 = 0
    report = adapter.transform_qa_department_results(_make_qa_report_json())
    assert report["scores"]["bug_score"]["value"] == 0.0

    # Report structural: 2 blocking, 3 warnings → 100 - 50 - 15 = 35
    assert report["scores"]["structural_health_score"]["value"] == 35.0

    # Forge UX: 2/4 visual+scene passed (icon+scene_flow) → 50.0
    forge = adapter.transform_qa_forge_results(_make_forge_result())
    assert forge["scores"]["ux_score"]["value"] == 50.0, \
        f"Expected 50.0, got {forge['scores']['ux_score']['value']}"

    # Forge performance: 3/3 animation+audio passed → 100.0
    assert forge["scores"]["performance_score"]["value"] == 100.0, \
        f"Expected 100.0, got {forge['scores']['performance_score']['value']}"

    # Forge confidence: compliance_score=85 → min(90, 85) = 85
    assert forge["scores"]["ux_score"]["confidence"] == 85.0

    print("  [PASS] Test 5: Score calculations")


# ======================================================================
# Runner
# ======================================================================

if __name__ == "__main__":
    tests = [
        test_1_transform_qa_forge,
        test_2_transform_qa_department_result,
        test_3_transform_qa_department_report_json,
        test_4_merge_results,
        test_5_score_calculations,
    ]

    passed = 0
    failed = 0
    print(f"\n{'=' * 60}")
    print("P-EVO-005 — QA-to-LDO Adapter Validation")
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
