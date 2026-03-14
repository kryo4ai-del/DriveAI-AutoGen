"""Validation: CD rating parser selects the correct rating from representative run data.

Tests the extract_cd_rating_detailed() function against message patterns
observed in actual factory runs (Run 3 + Run 4).
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from factory_knowledge.knowledge_reader import (
    extract_cd_rating,
    extract_cd_rating_detailed,
    CDRatingResult,
)


class FakeMessage:
    """Minimal message object mimicking AutoGen ChatMessage."""
    def __init__(self, source: str, content: str):
        self.source = source
        self.content = content


# ── Test 1: CD agent present with clear rating (Run 4 pattern) ──────────

def test_cd_agent_with_fail():
    """Run 4: bug_hunter speaks first, then creative_director gives fail."""
    msgs = [
        FakeMessage("user", "creative_director: Review the generated implementation..."),
        FakeMessage("bug_hunter", "# Bug Hunter Report\n## CRITICAL FINDINGS\n### 1. File Duplication..."),
        FakeMessage("creative_director", "# Creative Director Review\n\n**Rating: fail**\n\n## Findings\n..."),
        FakeMessage("ux_psychology", "# UX Psychology Review\n## Findings\n..."),
        FakeMessage("driveai_lead", "## Summary\nBased on all reviews..."),
    ]
    result = extract_cd_rating_detailed(msgs)
    assert result.rating == "fail", f"Expected 'fail', got '{result.rating}'"
    assert result.selected_source == "creative_director"
    assert len(result.candidates) == 1  # only CD has a rating line
    assert "creative_director" in result.selected_reason
    print("  PASS: test_cd_agent_with_fail")


# ── Test 2: CD gives conditional_pass (Run 3 Implementation Pass pattern) ──

def test_cd_agent_conditional_pass():
    """CD gives conditional_pass in structured review."""
    msgs = [
        FakeMessage("user", "Review task..."),
        FakeMessage("creative_director", "# CD Review\n\nRating: **conditional_pass**\n\n## Findings\n..."),
    ]
    result = extract_cd_rating_detailed(msgs)
    assert result.rating == "conditional_pass"
    assert result.selected_source == "creative_director"
    print("  PASS: test_cd_agent_conditional_pass")


# ── Test 3: Multiple CD messages — last one wins ─────────────────────────

def test_multiple_cd_messages_last_wins():
    """If CD speaks twice, the LAST rating is the final verdict."""
    msgs = [
        FakeMessage("user", "Review task..."),
        FakeMessage("creative_director", "# Initial Assessment\n\n**Rating: conditional_pass**\n..."),
        FakeMessage("bug_hunter", "I agree with CD but want to add..."),
        FakeMessage("creative_director", "# Revised Assessment\n\n**Rating: fail**\nAfter reviewing bug findings, revised down."),
    ]
    result = extract_cd_rating_detailed(msgs)
    assert result.rating == "fail", f"Expected 'fail' (last CD msg), got '{result.rating}'"
    assert result.selected_source == "creative_director"
    assert len(result.candidates) == 2  # both CD messages
    assert "2 CD rating(s)" in result.selected_reason
    print("  PASS: test_multiple_cd_messages_last_wins")


# ── Test 4: CD absent — fallback to first non-user rating ────────────────

def test_fallback_to_non_cd_agent():
    """If SelectorGroupChat never picks creative_director, fall back to first match."""
    msgs = [
        FakeMessage("user", "creative_director: Review..."),
        FakeMessage("bug_hunter", "# Review\n\n**Rating: conditional_pass**\n..."),
        FakeMessage("reviewer", "I also think **Rating: fail**"),
    ]
    result = extract_cd_rating_detailed(msgs)
    assert result.rating == "conditional_pass", f"Expected 'conditional_pass' (first fallback), got '{result.rating}'"
    assert result.selected_source == "bug_hunter"
    assert "fallback" in result.selected_reason
    assert len(result.candidates) == 2
    print("  PASS: test_fallback_to_non_cd_agent")


# ── Test 5: No rating lines at all → None ────────────────────────────────

def test_no_rating_found():
    """No agent produces a Rating: line."""
    msgs = [
        FakeMessage("user", "Review task..."),
        FakeMessage("bug_hunter", "# Bug Report\n## 1. Memory leak\n..."),
        FakeMessage("creative_director", "# CD Review\nGreat implementation with minor issues."),
    ]
    result = extract_cd_rating_detailed(msgs)
    assert result.rating is None
    assert len(result.candidates) == 0
    assert "no rating lines" in result.selected_reason
    print("  PASS: test_no_rating_found")


# ── Test 6: Non-CD agent has rating but CD also present → CD wins ────────

def test_cd_overrides_non_cd():
    """bug_hunter says fail, creative_director says conditional_pass → CD wins."""
    msgs = [
        FakeMessage("user", "Review..."),
        FakeMessage("bug_hunter", "# Bug Review\n\n**Rating: fail**\nCritical bugs found."),
        FakeMessage("creative_director", "# CD Review\n\n**Rating: conditional_pass**\nMostly good."),
        FakeMessage("reviewer", "I concur with **Rating: fail** assessment."),
    ]
    result = extract_cd_rating_detailed(msgs)
    assert result.rating == "conditional_pass", f"Expected CD's 'conditional_pass', got '{result.rating}'"
    assert result.selected_source == "creative_director"
    assert len(result.candidates) == 3  # bug_hunter + CD + reviewer
    print("  PASS: test_cd_overrides_non_cd")


# ── Test 7: Rating format variations ─────────────────────────────────────

def test_rating_format_variations():
    """Test all observed format variations."""
    formats = [
        ("Rating: **conditional_pass**", "conditional_pass"),
        ("**Rating: fail**", "fail"),
        ("## Rating: **pass**", "pass"),
        ("**Rating:** `conditional_pass`", "conditional_pass"),
        ("**Overall Rating: FAIL**", "fail"),
        ("Rating: pass", "pass"),
    ]
    for text, expected in formats:
        msgs = [FakeMessage("creative_director", f"# Review\n\n{text}\n\nFindings...")]
        result = extract_cd_rating_detailed(msgs)
        assert result.rating == expected, f"Format '{text}': expected '{expected}', got '{result.rating}'"
    print("  PASS: test_rating_format_variations (6 formats)")


# ── Test 8: Backward compatibility — extract_cd_rating() still works ─────

def test_backward_compat():
    """extract_cd_rating() returns just the rating string."""
    msgs = [
        FakeMessage("user", "Review..."),
        FakeMessage("creative_director", "# CD Review\n\n**Rating: fail**\n..."),
    ]
    rating = extract_cd_rating(msgs)
    assert rating == "fail"
    assert isinstance(rating, str)
    print("  PASS: test_backward_compat")


# ── Test 9: Simulate Run 4 CD Pass messages ──────────────────────────────

def test_run4_simulation():
    """Full simulation of Run 4 CD Pass message sequence."""
    msgs = [
        FakeMessage("user",
            "[Factory Knowledge]\n- FK-018 File duplication...\n\n"
            "[Bug Hunter Findings]\n# Bug Hunter Report...\n\n"
            "creative_director: Review the generated implementation for "
            "'ExamReadiness' from a product quality perspective. "
            "Rate: pass / conditional_pass / fail."),
        FakeMessage("bug_hunter",
            "# Bug Hunter Report: ExamReadiness Feature\n"
            "**Severity: 4 Critical, 6 High**\n"
            "## CRITICAL FINDINGS\n"
            "### 1. File Duplication (FK-018)..."),
        FakeMessage("creative_director",
            "# Creative Director Review: ExamReadiness Feature\n\n"
            "**Rating: fail**\n\n---\n\n"
            "## Findings\n\n"
            "### 1. [Emotional Function] No Emotional Arc\n"
            "**Problem:** The ExamReadiness screens function as pure metrics dashboards...\n"
            "**Suggestion:** Reframe around exam confidence trajectory...\n\n"
            "## Summary\nThe feature is well-structured technically but lacks emotional core."),
        FakeMessage("ux_psychology",
            "# UX Psychology Review\n## Findings\n"
            "### 1. Anxiety Reinforcement\n..."),
        FakeMessage("driveai_lead",
            "## Engineering Summary\nBased on all reviews, recommendation: fix-forward plan."),
        FakeMessage("accessibility_agent",
            "## Accessibility Audit\n### 1. Missing VoiceOver labels..."),
        FakeMessage("test_generator",
            "## Test Cases\n### Unit Tests\n..."),
        FakeMessage("refactor_agent",
            "## Refactor Report\nRecommendation: Do not merge."),
        FakeMessage("project_bootstrap_agent",
            "## Project Status\nPhase: review"),
        FakeMessage("autonomous_project_orchestrator",
            "## Orchestrator Summary\nRecommended: fix-forward."),
    ]

    result = extract_cd_rating_detailed(msgs)
    assert result.rating == "fail"
    assert result.selected_source == "creative_director"
    assert len(result.candidates) == 1
    assert "1 CD rating(s)" in result.selected_reason
    assert "1 total candidate(s)" in result.selected_reason

    print("  PASS: test_run4_simulation")
    print(f"         Rating: {result.rating}")
    print(f"         Source: {result.selected_source}")
    print(f"         Candidates: {result.candidates}")
    print(f"         Reason: {result.selected_reason}")


# ── Run all tests ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n=== CD Rating Parser Validation ===\n")

    tests = [
        test_cd_agent_with_fail,
        test_cd_agent_conditional_pass,
        test_multiple_cd_messages_last_wins,
        test_fallback_to_non_cd_agent,
        test_no_rating_found,
        test_cd_overrides_non_cd,
        test_rating_format_variations,
        test_backward_compat,
        test_run4_simulation,
    ]

    passed = 0
    failed = 0
    for test_fn in tests:
        try:
            test_fn()
            passed += 1
        except AssertionError as e:
            print(f"  FAIL: {test_fn.__name__}: {e}")
            failed += 1
        except Exception as e:
            print(f"  ERROR: {test_fn.__name__}: {type(e).__name__}: {e}")
            failed += 1

    print(f"\n=== Results: {passed} passed, {failed} failed ===\n")
    sys.exit(0 if failed == 0 else 1)
