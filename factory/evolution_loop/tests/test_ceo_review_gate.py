"""Tests for P-EVO-017 — CEO Review Gate.

6 Tests:
  1. Review Brief generieren
  2. Execute ohne Feedback-Datei -> pending
  3. Execute mit GO Feedback
  4. Execute mit NO-GO Feedback + Issues -> Tasks
  5. Review Brief enthält Feedback-Pfad
  6. Austauschbarer Provider (MockAI)
"""

import json
import os
import shutil
import sys
import time
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.gates import (
    CEOReviewGate,
    HumanReviewProvider,
    ReviewResult,
)
from factory.evolution_loop.ldo.schema import (
    Gap,
    LoopDataObject,
    ScoreEntry,
)

_DATA_DIR = Path("factory/evolution_loop/data/ceo_test")


def _make_test_ldo() -> LoopDataObject:
    """Create a test LDO for CEO review."""
    ldo = LoopDataObject.create_initial("ceo_test", "game", "unity")
    ldo.meta.iteration = 5
    ldo.meta.loop_mode = "sprint"
    ldo.meta.accumulated_cost = 0.42
    ldo.scores.bug_score = ScoreEntry(value=92, confidence=95)
    ldo.scores.roadbook_match_score = ScoreEntry(value=88, confidence=90)
    ldo.scores.structural_health_score = ScoreEntry(value=87, confidence=85)
    ldo.scores.performance_score = ScoreEntry(value=75, confidence=50)
    ldo.scores.ux_score = ScoreEntry(value=72, confidence=40)
    ldo.scores.quality_score_aggregate = 82.5
    ldo.gaps = [
        Gap(
            id="GAP-5-001",
            category="ux",
            severity="medium",
            description="Navigation depth too deep",
            affected_component="NavigationView",
        ),
    ]
    return ldo


def _cleanup():
    if _DATA_DIR.exists():
        shutil.rmtree(_DATA_DIR, ignore_errors=True)


# ======================================================================
# Test 1: Review Brief generieren
# ======================================================================

def test_1_review_brief():
    """Review brief is generated with correct content."""
    _cleanup()
    ldo = _make_test_ldo()
    gate = CEOReviewGate(review_provider=HumanReviewProvider(data_dir=str(_DATA_DIR)))

    brief = gate.get_review_brief(ldo)

    assert "CEO Review Brief" in brief, "Missing header"
    assert "ceo_test" in brief, "Missing project_id"
    assert "92" in brief, "Missing bug score"
    assert "88" in brief, "Missing roadbook score"
    assert "82.5" in brief, "Missing aggregate"
    assert "Navigation depth too deep" in brief, "Missing gap"
    assert "$0.4200" in brief, "Missing cost"

    print(f"  Brief length: {len(brief)} chars")
    print(f"  First 10 lines:")
    for line in brief.split("\n")[:10]:
        print(f"    {line}")
    print("  [PASS] Test 1: Review Brief generated")
    _cleanup()


# ======================================================================
# Test 2: Execute ohne Feedback -> pending
# ======================================================================

def test_2_pending():
    """Execute without feedback file returns pending."""
    _cleanup()
    _DATA_DIR.mkdir(parents=True, exist_ok=True)
    ldo = _make_test_ldo()
    gate = CEOReviewGate(review_provider=HumanReviewProvider(data_dir=str(_DATA_DIR)))

    ldo = gate.execute(ldo)
    assert ldo.ceo_feedback.status == "pending", f"Expected pending, got {ldo.ceo_feedback.status}"

    print(f"  Status: {ldo.ceo_feedback.status}")
    print("  [PASS] Test 2: No feedback file -> pending")
    _cleanup()


# ======================================================================
# Test 3: Execute mit GO Feedback
# ======================================================================

def test_3_go():
    """Execute with GO feedback sets status to go."""
    _cleanup()
    _DATA_DIR.mkdir(parents=True, exist_ok=True)
    ldo = _make_test_ldo()

    feedback_path = _DATA_DIR / "ceo_feedback.json"
    feedback_path.write_text(json.dumps({"status": "go", "issues": []}), encoding="utf-8")

    gate = CEOReviewGate(review_provider=HumanReviewProvider(data_dir=str(_DATA_DIR)))
    ldo = gate.execute(ldo)

    assert ldo.ceo_feedback.status == "go", f"Expected go, got {ldo.ceo_feedback.status}"
    assert len(ldo.ceo_feedback.issues) == 0

    print(f"  Status: {ldo.ceo_feedback.status}")
    print("  [PASS] Test 3: GO feedback -> status=go")
    _cleanup()


# ======================================================================
# Test 4: Execute mit NO-GO Feedback + Tasks
# ======================================================================

def test_4_no_go_with_tasks():
    """Execute with NO-GO feedback generates tasks via DecisionAgent."""
    _cleanup()
    _DATA_DIR.mkdir(parents=True, exist_ok=True)
    ldo = _make_test_ldo()

    feedback = {
        "status": "no_go",
        "issues": [
            {"category": "ux", "severity": "blocker", "description": "Onboarding is confusing"},
            {"category": "feel", "severity": "major", "description": "Game feels sluggish"},
        ],
    }
    feedback_path = _DATA_DIR / "ceo_feedback.json"
    feedback_path.write_text(json.dumps(feedback), encoding="utf-8")

    gate = CEOReviewGate(review_provider=HumanReviewProvider(data_dir=str(_DATA_DIR)))
    ldo = gate.execute(ldo)

    assert ldo.ceo_feedback.status == "no_go"
    assert len(ldo.ceo_feedback.issues) == 2

    # Check tasks generated from CEO feedback
    ceo_tasks = [t for t in ldo.tasks if t.originated_from == "ceo_feedback"]
    assert len(ceo_tasks) == 2, f"Expected 2 CEO tasks, got {len(ceo_tasks)}"

    print(f"  Status: {ldo.ceo_feedback.status}")
    print(f"  Issues: {len(ldo.ceo_feedback.issues)}")
    print(f"  CEO Tasks: {len(ceo_tasks)}")
    for t in ceo_tasks:
        print(f"    {t.id}: [{t.priority}] {t.description}")
    print("  [PASS] Test 4: NO-GO -> 2 tasks generated")
    _cleanup()


# ======================================================================
# Test 5: Brief enthält Feedback-Pfad
# ======================================================================

def test_5_brief_has_feedback_path():
    """Review brief contains the feedback file path."""
    _cleanup()
    ldo = _make_test_ldo()
    gate = CEOReviewGate(review_provider=HumanReviewProvider(data_dir=str(_DATA_DIR)))

    brief = gate.get_review_brief(ldo)
    assert "ceo_feedback.json" in brief, "Brief missing feedback path"

    print("  Brief contains ceo_feedback.json path")
    print("  [PASS] Test 5: Brief contains feedback path")
    _cleanup()


# ======================================================================
# Test 6: Austauschbarer Provider
# ======================================================================

def test_6_swappable_provider():
    """Provider is swappable (MockAI)."""
    _cleanup()

    class MockAIProvider(HumanReviewProvider):
        def review(self, ldo):
            return ReviewResult(status="go", issues=[])

    ldo = _make_test_ldo()
    ai_gate = CEOReviewGate(review_provider=MockAIProvider())
    ldo = ai_gate.execute(ldo)

    assert ldo.ceo_feedback.status == "go"

    print("  MockAI provider -> status=go")
    print("  [PASS] Test 6: Swappable provider (MockAI)")
    _cleanup()


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-017 Validation: CEO Review Gate ===\n")

    tests = [
        ("Test 1: Review Brief", test_1_review_brief),
        ("Test 2: Pending (no file)", test_2_pending),
        ("Test 3: GO feedback", test_3_go),
        ("Test 4: NO-GO + Tasks", test_4_no_go_with_tasks),
        ("Test 5: Brief has path", test_5_brief_has_feedback_path),
        ("Test 6: Swappable provider", test_6_swappable_provider),
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
    _cleanup()

    print(f"\n{'='*50}")
    print(f"Result: {passed}/{len(tests)} passed, {failed} failed")
    print(f"Duration: {elapsed:.2f}s")
    print(f"{'='*50}")

    if failed:
        sys.exit(1)
    print("ALL CEO GATE TESTS PASSED")


if __name__ == "__main__":
    main()
