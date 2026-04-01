"""Phase 5 Block B — Tests fuer GitHub Adapter, HuggingFace Adapter, Sentiment Analyzer.

10 Tests: GitHub real data, HuggingFace real data, Sentiment-Logik, DB-Tabellen.
"""

import os
import sys
import tempfile

# ── Setup: PYTHONPATH + Test-DB ───────────────────────────────────────────────

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, ROOT)

# Test-DB statt Produktion
_temp_db = tempfile.NamedTemporaryFile(suffix=".db", delete=False)
os.environ["MARKETING_DB_PATH"] = _temp_db.name
_temp_db.close()

passed = 0
failed = 0


def run_test(name, fn):
    global passed, failed
    try:
        fn()
        passed += 1
        print(f"  PASS  {name}")
    except Exception as e:
        failed += 1
        print(f"  FAIL  {name}: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# Tests
# ══════════════════════════════════════════════════════════════════════════════

def test_01_github_adapter_import():
    """Import und Instanziierung."""
    from factory.marketing.adapters.github_adapter import GitHubAdapter
    adapter = GitHubAdapter()
    assert adapter.PLATFORM == "github"
    assert adapter.STATUS == "active"
    assert adapter.API_BASE == "https://api.github.com"
    assert adapter.dry_run is False


def test_02_github_repo_info_real():
    """Echte Daten: microsoft/autogen — muss Stars, Forks, Description haben."""
    from factory.marketing.adapters.github_adapter import GitHubAdapter
    adapter = GitHubAdapter()
    info = adapter.get_repo_info("microsoft", "autogen")
    assert info is not None, "get_repo_info returned None"
    assert info["full_name"] == "microsoft/autogen"
    assert info["stars"] > 1000, f"Expected >1000 stars, got {info['stars']}"
    assert info["forks"] > 0, "Expected forks > 0"
    assert isinstance(info["description"], str)
    assert isinstance(info.get("topics", []), list)


def test_03_github_search_real():
    """Echte Suche: 'multi-agent AI' muss Ergebnisse liefern."""
    from factory.marketing.adapters.github_adapter import GitHubAdapter
    adapter = GitHubAdapter()
    results = adapter.search_repos("multi-agent AI", limit=5)
    assert len(results) > 0, "Search returned no results"
    for r in results:
        assert "full_name" in r
        assert "stars" in r


def test_04_github_trending_real():
    """Trending weekly repos — muss Ergebnisse haben."""
    from factory.marketing.adapters.github_adapter import GitHubAdapter
    adapter = GitHubAdapter()
    trending = adapter.get_trending_repos(since="weekly")
    assert len(trending) > 0, "No trending repos found"
    assert trending[0]["stars"] > 0


def test_05_huggingface_adapter_import():
    """Import und Instanziierung."""
    from factory.marketing.adapters.huggingface_adapter import HuggingFaceAdapter
    adapter = HuggingFaceAdapter()
    assert adapter.PLATFORM == "huggingface"
    assert adapter.STATUS == "active"
    assert adapter.API_BASE == "https://huggingface.co/api"
    assert adapter.dry_run is False


def test_06_huggingface_model_info_real():
    """Echte Daten: meta-llama/Llama-2-7b-hf — Downloads, Likes, Pipeline."""
    from factory.marketing.adapters.huggingface_adapter import HuggingFaceAdapter
    adapter = HuggingFaceAdapter()
    info = adapter.get_model_info("meta-llama/Llama-2-7b-hf")
    assert info is not None, "get_model_info returned None"
    assert "meta-llama" in info["model_id"]
    assert info["downloads"] >= 0
    assert info["likes"] >= 0
    assert isinstance(info["tags"], list)


def test_07_huggingface_search_real():
    """Suche nach text-generation Modellen."""
    from factory.marketing.adapters.huggingface_adapter import HuggingFaceAdapter
    adapter = HuggingFaceAdapter()
    results = adapter.search_models(pipeline_tag="text-generation", limit=5)
    assert len(results) > 0, "Search returned no results"
    for r in results:
        assert "model_id" in r
        assert "downloads" in r


def test_08_sentiment_analyzer_import():
    """Import, Instanziierung, Topics, Labels."""
    from factory.marketing.tools.sentiment_analyzer import SentimentAnalyzer
    sa = SentimentAnalyzer()
    assert "ai_apps" in sa.TOPICS
    assert "autonomous_ai" in sa.TOPICS
    assert "driveai" in sa.TOPICS
    # Label mapping
    assert sa._score_to_label(0.0) == "neutral"
    assert sa._score_to_label(0.8) == "very_positive"
    assert sa._score_to_label(-0.8) == "very_negative"
    assert sa._score_to_label(0.3) == "positive"
    assert sa._score_to_label(-0.3) == "negative"


def test_09_sentiment_no_data():
    """Analyse ohne Daten → neutral, confidence 0."""
    from factory.marketing.tools.sentiment_analyzer import SentimentAnalyzer
    sa = SentimentAnalyzer()
    scan_result = {"topic": "test_topic", "texts": []}
    result = sa.analyze_sentiment(scan_result)
    assert result["sentiment_score"] == 0.0
    assert result["sentiment_label"] == "neutral"
    assert result["confidence"] == 0.0
    assert result["sample_count"] == 0


def test_10_db_tables_exist():
    """DB hat alle 3 neuen Tabellen: github_repos, sentiment_data, factory_mentions."""
    from factory.marketing.tools.ranking_database import RankingDatabase
    db = RankingDatabase()
    conn = db._connect()
    cursor = conn.cursor()

    # Check tables
    for table in ["github_repos", "sentiment_data", "factory_mentions"]:
        cursor.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            (table,),
        )
        assert cursor.fetchone() is not None, f"Table '{table}' missing"

    # Test store + retrieve github_repos
    db.store_github_repo(
        owner="test", repo="repo1", stars=100, forks=10,
        open_issues=5, language="Python", last_push="2026-03-31T12:00:00Z",
        description="Test repo",
    )
    trend = db.get_github_repo_trend("test", "repo1", days=1)
    assert len(trend) >= 1, "github_repos store/retrieve failed"

    # Test store + retrieve sentiment_data
    db.store_sentiment(
        topic="ai_apps", source="combined", sentiment_score=0.5,
        sentiment_label="positive", dominant_narratives=["test"],
        sample_count=10, confidence=0.5, summary="Test summary",
    )
    s_trend = db.get_sentiment_trend("ai_apps", days=1)
    assert len(s_trend) >= 1, "sentiment_data store/retrieve failed"

    # Test store + retrieve factory_mentions
    db.store_factory_mention(
        source="news", url="https://example.com",
        context="Test mention", sentiment="neutral",
    )
    mentions = db.get_factory_mentions(days=1)
    assert len(mentions) >= 1, "factory_mentions store/retrieve failed"

    conn.close()


# ══════════════════════════════════════════════════════════════════════════════
# Runner
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n=== Phase 5 Block B Tests ===\n")

    tests = [
        ("01 - GitHub Adapter Import", test_01_github_adapter_import),
        ("02 - GitHub Repo Info (real: microsoft/autogen)", test_02_github_repo_info_real),
        ("03 - GitHub Search (real: multi-agent AI)", test_03_github_search_real),
        ("04 - GitHub Trending (real: weekly)", test_04_github_trending_real),
        ("05 - HuggingFace Adapter Import", test_05_huggingface_adapter_import),
        ("06 - HuggingFace Model Info (real: Llama-2-7b-hf)", test_06_huggingface_model_info_real),
        ("07 - HuggingFace Search (real: text-generation)", test_07_huggingface_search_real),
        ("08 - Sentiment Analyzer Import + Labels", test_08_sentiment_analyzer_import),
        ("09 - Sentiment No-Data = Neutral", test_09_sentiment_no_data),
        ("10 - DB Tables (github_repos, sentiment_data, factory_mentions)", test_10_db_tables_exist),
    ]

    for name, fn in tests:
        run_test(name, fn)

    print(f"\n=== Phase 5 Block B — {passed}/{passed + failed} Tests Passed ===")

    # Cleanup
    try:
        os.unlink(_temp_db.name)
    except OSError:
        pass

    if failed > 0:
        sys.exit(1)
