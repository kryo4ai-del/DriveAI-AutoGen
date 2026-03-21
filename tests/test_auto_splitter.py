"""Tests for AutoSplitter."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from factory.brain.model_provider.auto_splitter import AutoSplitter, SplitStrategy
from factory.brain.model_provider.model_registry import ModelRegistry


def _get_splitter():
    return AutoSplitter(ModelRegistry())


def test_output_fits_no_split():
    """Output fits in model limit -> no split."""
    s = _get_splitter()
    result = s.analyze("claude-haiku-4-5", "anthropic", 4000)
    assert not result.should_split
    assert "fits" in result.reason


def test_output_exceeds_switch_model():
    """Output exceeds limit, larger model available -> switch."""
    s = _get_splitter()
    # Haiku has 8k max. Request 20k. Gemini Flash has 65k and is cheap.
    result = s.analyze("claude-haiku-4-5", "anthropic", 20000)
    # If Gemini is available (has API key), it should switch
    if result.alternative_model:
        assert not result.should_split
        assert "switch" in result.reason
    else:
        # No alternative available -> split
        assert result.should_split


def test_output_exceeds_must_split():
    """Output exceeds all available models -> must split."""
    s = _get_splitter()
    # Request 200k tokens — no model has that
    result = s.analyze("claude-haiku-4-5", "anthropic", 200000)
    assert result.should_split
    assert result.call_count > 1


def test_json_merge():
    """JSON merge from 2 responses -> combined array."""
    from factory.brain.model_provider.provider_router import ProviderResponse
    s = _get_splitter()
    r1 = ProviderResponse(content='[{"id": 1}, {"id": 2}]', model="test", provider="test")
    r2 = ProviderResponse(content='[{"id": 3}, {"id": 4}]', model="test", provider="test")
    merged = s._merge_json([r1, r2])
    import json
    data = json.loads(merged)
    assert len(data) == 4
    assert data[0]["id"] == 1
    assert data[3]["id"] == 4


def test_code_merge():
    """Code merge from 2 responses -> concatenated with separator."""
    from factory.brain.model_provider.provider_router import ProviderResponse
    s = _get_splitter()
    r1 = ProviderResponse(content="func a() {}", model="t", provider="t")
    r2 = ProviderResponse(content="func b() {}", model="t", provider="t")
    merged = s._merge([r1, r2], "code_concat")
    assert "func a()" in merged.content
    assert "func b()" in merged.content
    assert "Split boundary" in merged.content


def test_gemini_flash_handles_large():
    """Gemini Flash (65k output) handles large requests without split."""
    s = _get_splitter()
    result = s.analyze("gemini-2.5-flash", "google", 40000)
    assert not result.should_split
    assert "fits" in result.reason


def test_safety_buffer():
    """Safety buffer (90%) applied correctly."""
    s = _get_splitter()
    # Haiku max is 8192. 90% = 7372.
    # Request exactly 7372 -> should fit
    result = s.analyze("claude-haiku-4-5", "anthropic", 7372)
    assert not result.should_split
    # Request 7373 -> may need alternative or split
    result2 = s.analyze("claude-haiku-4-5", "anthropic", 7373)
    # Either switches model or splits
    assert result2.alternative_model is not None or result2.should_split


if __name__ == "__main__":
    tests = [test_output_fits_no_split, test_output_exceeds_switch_model,
             test_output_exceeds_must_split, test_json_merge, test_code_merge,
             test_gemini_flash_handles_large, test_safety_buffer]
    passed = 0
    for t in tests:
        try:
            t()
            print(f"  PASS: {t.__name__}")
            passed += 1
        except Exception as e:
            print(f"  FAIL: {t.__name__}: {e}")
    print(f"\n{passed}/{len(tests)} tests passed")
