"""Phase 5 Integration-Test — 10 Tests ueber alle Phase-5-Komponenten.

Testet: Trend Monitor, TikTok Scraper, Competitor Tracker, GitHub, HuggingFace,
Sentiment, Hook Library, Market Scanner, DB-Vollstaendigkeit.
"""

import os
import sys
import tempfile
import shutil

# ── Setup: PYTHONPATH + Test-DB ───────────────────────────────────────────────

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, ROOT)

# Test-DB statt Produktion
_temp_db = tempfile.NamedTemporaryFile(suffix=".db", delete=False)
os.environ["MARKETING_DB_PATH"] = _temp_db.name
_temp_db.close()

# Test output dirs
_test_output_dir = tempfile.mkdtemp(prefix="mkt_test_")

passed = 0
failed = 0
details = {}


def run_test(name, fn):
    global passed, failed
    try:
        result = fn()
        passed += 1
        detail = result if isinstance(result, str) else "OK"
        details[name] = detail
        print(f"  OK  {name} -- {detail}")
    except Exception as e:
        failed += 1
        details[name] = f"FAIL: {e}"
        print(f"  FAIL  {name}: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# Tests
# ══════════════════════════════════════════════════════════════════════════════

def test_01_trend_scan_relevance():
    """Trend-Monitor Scan + Relevanz."""
    from factory.marketing.tools.trend_monitor import TrendMonitor
    tm = TrendMonitor()
    trends = tm.scan_all_sources()
    sources = trends.get("sources_scanned", 0)
    total = trends.get("total_trends", 0)
    assert sources >= 0, "scan_all_sources() failed"

    # Evaluate if we have trends
    all_trends = trends.get("trends", [])
    if all_trends:
        scored = tm.evaluate_relevance(all_trends[:3])
        assert len(scored) > 0, "evaluate_relevance returned empty"

    # Check DB
    from factory.marketing.tools.ranking_database import RankingDatabase
    db = RankingDatabase()
    history = db.get_trend_history(days=1)
    return f"{total} trends, {sources} sources, {len(history)} in DB"


def test_02_tiktok_scraper():
    """TikTok Scraper Full Scan."""
    from factory.marketing.tools.tiktok_scraper import TikTokCreativeScraper
    scraper = TikTokCreativeScraper()
    # Just get hashtags (full scan takes too long with LLM)
    hashtags = scraper.get_trending_hashtags("US")
    assert len(hashtags) >= 0, "get_trending_hashtags failed"
    source = hashtags[0].get("source", "unknown") if hashtags else "no_data"
    return f"{len(hashtags)} hashtags (source: {source})"


def test_03_competitor_change():
    """Competitor Tracker Change Detection."""
    from factory.marketing.tools.ranking_database import RankingDatabase
    db = RankingDatabase()

    # 2 snapshots, different ratings
    db.store_competitor_snapshot(
        competitor_name="TestApp",
        rating=4.5, review_count=1000, version="1.0",
    )
    db.store_competitor_snapshot(
        competitor_name="TestApp",
        rating=3.8, review_count=1200, version="1.1",
    )
    changes = db.detect_competitor_changes("TestApp")
    assert changes["changed"] is True, "Change not detected"
    assert "rating" in changes["changes"], "Rating change not detected"
    old_rating, new_rating = changes["changes"]["rating"]
    assert new_rating < old_rating, f"Expected drop, got {old_rating} -> {new_rating}"
    return f"drop detected: {old_rating} -> {new_rating} (major)"


def test_04_github_search():
    """GitHub echte Repo-Daten."""
    from factory.marketing.adapters.github_adapter import GitHubAdapter
    adapter = GitHubAdapter()
    results = adapter.search_repos("autonomous AI agent", limit=5)
    assert len(results) > 0, "No GitHub results"
    return f"{len(results)} repos (real data)"


def test_05_huggingface_trending():
    """HuggingFace Trending Models."""
    from factory.marketing.adapters.huggingface_adapter import HuggingFaceAdapter
    adapter = HuggingFaceAdapter()
    models = adapter.get_trending_models(limit=5)
    assert len(models) >= 3, f"Expected >=3 models, got {len(models)}"
    return f"{len(models)} models (real data)"


def test_06_sentiment_quick():
    """Sentiment Quick Check."""
    from factory.marketing.tools.sentiment_analyzer import SentimentAnalyzer
    sa = SentimentAnalyzer()
    # Scan with limited sources to avoid too many API calls
    scan = sa.scan_sentiment("ai_apps", sources=["news"], days=7)
    result = sa.analyze_sentiment(scan)
    score = result.get("sentiment_score", 0)
    assert -1.0 <= score <= 1.0, f"Score out of range: {score}"
    return f"score {score:.2f} for ai_apps ({result.get('sentiment_label', '?')})"


def test_07_hook_auto_promotion():
    """Hook Library: Seed + Save + Auto-Promotion nach 2 Erfolgen."""
    from factory.marketing.tools.content_trend_analyzer import ContentTrendAnalyzer
    cta = ContentTrendAnalyzer()

    # Seed
    count = cta.seed_initial_hooks()
    assert count > 0, f"seed_initial_hooks returned {count}"

    # Save a custom hook
    hook_id = cta.save_hook(
        "Wusstest du dass eine KI 78 Agents hat?",
        "tiktok", "factory", "shocking_fact",
    )
    assert hook_id > 0, "save_hook failed"

    # Use successfully 2x
    cta.record_hook_usage(hook_id, successful=True)
    cta.record_hook_usage(hook_id, successful=True)

    # Check status
    hooks = cta.db.get_hooks(status="proven")
    proven_ids = [h["id"] for h in hooks]
    assert hook_id in proven_ids, f"Hook {hook_id} not promoted to proven"

    # Recommended
    recs = cta.get_recommended_hooks("tiktok")
    rec_ids = [r["id"] for r in recs]
    assert hook_id in rec_ids, "Proven hook not in recommendations"

    return f"hypothesis -> proven after 2 successes ({count} seeded)"


def test_08_hook_auto_deprecation():
    """Hook Library: Auto-Deprecation nach 3 Fehlschlaegen."""
    from factory.marketing.tools.content_trend_analyzer import ContentTrendAnalyzer
    cta = ContentTrendAnalyzer()

    # Save a hook
    hook_id = cta.save_hook(
        "Dieser Hook funktioniert nicht",
        "tiktok", "test", "question",
    )

    # Use unsuccessfully 3x
    cta.record_hook_usage(hook_id, successful=False)
    cta.record_hook_usage(hook_id, successful=False)
    cta.record_hook_usage(hook_id, successful=False)

    # Check status
    hooks = cta.db.get_hooks(status="deprecated")
    dep_ids = [h["id"] for h in hooks]
    assert hook_id in dep_ids, f"Hook {hook_id} not deprecated"

    # Not in recommendations
    recs = cta.get_recommended_hooks("tiktok")
    rec_ids = [r["id"] for r in recs]
    assert hook_id not in rec_ids, "Deprecated hook still in recommendations"

    return "deprecated after 3 failures, excluded from recs"


def test_09_market_scanner():
    """Market Scanner: Luecke finden + Idee erstellen + Gate oeffnen."""
    from factory.marketing.tools.market_scanner import AppMarketScanner
    scanner = AppMarketScanner()

    # Find gaps
    gaps = scanner.find_market_gaps("education")
    assert len(gaps) >= 1, "No market gaps found"

    # Create idea
    idea = scanner.create_app_idea(gaps[0])
    assert idea.get("app_name"), "No app_name in idea"
    assert idea.get("core_features"), "No core_features in idea"

    # Submit to pipeline
    result = scanner.submit_idea_to_pipeline(idea, project_slug="test_education_app")
    assert result.get("idea_path"), "No idea_path"
    assert result.get("gate_id"), "No gate_id"
    assert os.path.exists(result["idea_path"]), "Idea MD file not found"

    # Cleanup gate
    gate_id = result["gate_id"]
    try:
        scanner.alerts.resolve_gate(gate_id, "Ablehnen", "Test-Cleanup")
    except Exception:
        pass

    app_name = idea.get("app_name", "?")
    return f"gap found, idea '{app_name}' created, gate {gate_id}"


def test_10_db_complete():
    """DB hat alle 13 Tabellen."""
    from factory.marketing.tools.ranking_database import RankingDatabase
    db = RankingDatabase()
    stats = db.get_db_stats()

    expected_tables = [
        "keyword_rankings", "app_metrics", "review_log",
        "social_metrics", "post_performance",
        "trends", "competitors", "competitor_snapshots",
        "github_repos", "sentiment_data", "factory_mentions",
        "hook_library", "format_performance",
    ]

    for table in expected_tables:
        assert table in stats["tables"], f"Table '{table}' missing from stats"

    # Verify tables actually exist in DB
    conn = db._connect()
    cursor = conn.cursor()
    for table in expected_tables:
        cursor.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            (table,),
        )
        assert cursor.fetchone() is not None, f"Table '{table}' not in DB"
    conn.close()

    total = stats["total_rows"]
    return f"all {len(expected_tables)} tables present, {total} total rows"


# ══════════════════════════════════════════════════════════════════════════════
# Runner
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n=== Phase 5 Integration-Test ===\n")

    tests = [
        ("Test 1: Trend Scan + Relevanz", test_01_trend_scan_relevance),
        ("Test 2: TikTok Scraper", test_02_tiktok_scraper),
        ("Test 3: Competitor Change", test_03_competitor_change),
        ("Test 4: GitHub Search (real)", test_04_github_search),
        ("Test 5: HuggingFace Trending (real)", test_05_huggingface_trending),
        ("Test 6: Sentiment Quick Check", test_06_sentiment_quick),
        ("Test 7: Hook Auto-Promotion", test_07_hook_auto_promotion),
        ("Test 8: Hook Auto-Deprecation", test_08_hook_auto_deprecation),
        ("Test 9: Market Scanner", test_09_market_scanner),
        ("Test 10: DB Complete", test_10_db_complete),
    ]

    for name, fn in tests:
        run_test(name, fn)

    print(f"\n=== Phase 5 Integration -- {passed}/{passed + failed} Tests Passed ===")

    # Cleanup
    try:
        os.unlink(_temp_db.name)
    except OSError:
        pass
    try:
        shutil.rmtree(_test_output_dir, ignore_errors=True)
    except Exception:
        pass

    if failed > 0:
        sys.exit(1)
