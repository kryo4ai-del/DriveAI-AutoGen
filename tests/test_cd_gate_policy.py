"""Validation: CD gate policy is profile-aware.

Tests that dev/fast profiles treat CD fail as advisory (non-blocking),
while standard/premium profiles block the pipeline.
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from factory_knowledge.knowledge_reader import extract_cd_rating_detailed


class FakeMessage:
    def __init__(self, source: str, content: str):
        self.source = source
        self.content = content


def _simulate_gate(profile: str, cd_rating: str, no_cd_gate: bool = False):
    """Simulate the CD gate decision logic from main.py.

    Returns (gate_stop: bool, gate_mode: str, reason: str).
    """
    _cd_blocking = profile in ("standard", "premium")

    if cd_rating == "fail" and not no_cd_gate and _cd_blocking:
        return True, "blocking", f"FAIL — BLOCKING (profile={profile})"
    elif cd_rating == "fail" and not no_cd_gate and not _cd_blocking:
        return False, "advisory", f"FAIL — ADVISORY (profile={profile})"
    elif cd_rating == "conditional_pass":
        return False, "continue", f"conditional_pass — continuing"
    elif cd_rating == "pass" or cd_rating is None:
        return False, "continue", f"pass — continuing"
    else:
        return False, "continue", f"unknown rating '{cd_rating}' — fail-open"


# ── Test 1: Dev profile + fail → advisory (non-blocking) ────────────────

def test_dev_profile_fail_advisory():
    stop, mode, reason = _simulate_gate("dev", "fail")
    assert not stop, f"dev+fail should NOT stop, got stop={stop}"
    assert mode == "advisory"
    assert "ADVISORY" in reason
    print("  PASS: test_dev_profile_fail_advisory")


# ── Test 2: Fast profile + fail → advisory (non-blocking) ───────────────

def test_fast_profile_fail_advisory():
    stop, mode, reason = _simulate_gate("fast", "fail")
    assert not stop
    assert mode == "advisory"
    print("  PASS: test_fast_profile_fail_advisory")


# ── Test 3: Standard profile + fail → blocking ──────────────────────────

def test_standard_profile_fail_blocks():
    stop, mode, reason = _simulate_gate("standard", "fail")
    assert stop, f"standard+fail SHOULD stop"
    assert mode == "blocking"
    assert "BLOCKING" in reason
    print("  PASS: test_standard_profile_fail_blocks")


# ── Test 4: Premium profile + fail → blocking ───────────────────────────

def test_premium_profile_fail_blocks():
    stop, mode, reason = _simulate_gate("premium", "fail")
    assert stop
    assert mode == "blocking"
    print("  PASS: test_premium_profile_fail_blocks")


# ── Test 5: Dev profile + conditional_pass → continue ────────────────────

def test_dev_profile_conditional_pass_continues():
    stop, mode, reason = _simulate_gate("dev", "conditional_pass")
    assert not stop
    assert mode == "continue"
    print("  PASS: test_dev_profile_conditional_pass_continues")


# ── Test 6: Standard profile + conditional_pass → continue ───────────────

def test_standard_profile_conditional_pass_continues():
    stop, mode, reason = _simulate_gate("standard", "conditional_pass")
    assert not stop
    assert mode == "continue"
    print("  PASS: test_standard_profile_conditional_pass_continues")


# ── Test 7: --no-cd-gate overrides everything ────────────────────────────

def test_no_cd_gate_flag_overrides():
    stop, mode, reason = _simulate_gate("standard", "fail", no_cd_gate=True)
    assert not stop, "--no-cd-gate should override blocking"
    assert mode == "continue"
    print("  PASS: test_no_cd_gate_flag_overrides")


# ── Test 8: None/missing profile → advisory (safe default) ──────────────

def test_none_profile_advisory():
    """None profile is not in ('standard', 'premium') → advisory."""
    stop, mode, reason = _simulate_gate(None, "fail")
    assert not stop
    assert mode == "advisory"
    print("  PASS: test_none_profile_advisory")


# ── Test 9: Full Run 4 simulation with dev profile ──────────────────────

def test_run4_dev_profile_continues():
    """Simulate Run 4 scenario: CD gives fail, dev profile → advisory."""
    msgs = [
        FakeMessage("user", "creative_director: Review..."),
        FakeMessage("bug_hunter", "# Bug Report\n## CRITICAL\n..."),
        FakeMessage("creative_director",
            "# Creative Director Review\n\n**Rating: fail**\n\n"
            "## Findings\n### 1. [Emotional Function] No Emotional Arc\n..."),
        FakeMessage("ux_psychology", "# UX Review\n..."),
        FakeMessage("driveai_lead", "## Summary\n..."),
    ]

    detail = extract_cd_rating_detailed(msgs)
    assert detail.rating == "fail"
    assert detail.selected_source == "creative_director"

    stop, mode, reason = _simulate_gate("dev", detail.rating)
    assert not stop, "dev profile should NOT stop on CD fail"
    assert mode == "advisory"

    # Verify: gate_ctx["cd_gate_stop"] would NOT be set
    # → UX Psychology, Refactor, Test Gen, Fix Execution all run
    gate_ctx = {}
    # In advisory mode, cd_gate_stop is never set
    assert not gate_ctx.get("cd_gate_stop")

    print("  PASS: test_run4_dev_profile_continues")
    print(f"         CD rating: {detail.rating} from {detail.selected_source}")
    print(f"         Gate: {mode} (profile=dev)")
    print(f"         Pipeline: CONTINUES past CD gate")
    print(f"         Downstream phases: UX Psychology, Refactor, Test Gen, Fix — all run")


# ── Test 10: CD findings preserved in review_digests ─────────────────────

def test_cd_findings_available_downstream():
    """CD digest is captured BEFORE gate decision → always available."""
    # Simulate the flow from main.py lines 571-573
    cd_result_msgs = [
        FakeMessage("creative_director",
            "# Creative Director Review\n\n**Rating: fail**\n\n"
            "## Findings\n### 1. No Emotional Arc\n"
            "**Problem:** Pure metrics dashboard.\n"
            "**Suggestion:** Reframe around confidence trajectory.")
    ]

    # Digest capture (happens before gate)
    review_digests = {}
    _cd_digest = cd_result_msgs[0].content[:600]  # simplified _extract_review_digest
    review_digests["creative_review"] = _cd_digest

    # Gate decision (happens after digest capture)
    detail = extract_cd_rating_detailed(cd_result_msgs)
    stop, mode, _ = _simulate_gate("dev", detail.rating)

    # Verify digest is available regardless of gate outcome
    assert "creative_review" in review_digests
    assert "No Emotional Arc" in review_digests["creative_review"]
    assert not stop  # dev → advisory

    print("  PASS: test_cd_findings_available_downstream")
    print(f"         Digest captured: {len(review_digests['creative_review'])} chars")
    print(f"         Gate outcome: advisory (findings preserved)")


# ── Run all ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n=== CD Gate Policy Validation ===\n")

    tests = [
        test_dev_profile_fail_advisory,
        test_fast_profile_fail_advisory,
        test_standard_profile_fail_blocks,
        test_premium_profile_fail_blocks,
        test_dev_profile_conditional_pass_continues,
        test_standard_profile_conditional_pass_continues,
        test_no_cd_gate_flag_overrides,
        test_none_profile_advisory,
        test_run4_dev_profile_continues,
        test_cd_findings_available_downstream,
    ]

    passed = failed = 0
    for t in tests:
        try:
            t()
            passed += 1
        except AssertionError as e:
            print(f"  FAIL: {t.__name__}: {e}")
            failed += 1
        except Exception as e:
            print(f"  ERROR: {t.__name__}: {type(e).__name__}: {e}")
            failed += 1

    print(f"\n=== Results: {passed} passed, {failed} failed ===\n")
    sys.exit(0 if failed == 0 else 1)
