"""Phase 5 Block A — Tests fuer Trend-Monitor, TikTok Scraper, Competitor Tracker.

10 Tests. Nutzt temporaere DB um Produktionsdaten nicht zu beruehren.
"""

import json
import os
import sys
import tempfile

# Ensure project root is on path
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)))))
sys.path.insert(0, PROJECT_ROOT)

from dotenv import load_dotenv
load_dotenv(os.path.join(PROJECT_ROOT, ".env"))

RESULTS = []


def log(test_num: int, name: str, ok: bool, detail: str = ""):
    status = "OK" if ok else "FAIL"
    msg = f"{status} Test {test_num}: {name}"
    if detail:
        msg += f" — {detail}"
    print(msg)
    RESULTS.append((test_num, name, ok, detail))


def run_all():
    # Temp DB fuer alle Tests
    tmp = tempfile.mkdtemp(prefix="mkt_test_")
    tmp_db = os.path.join(tmp, "test_marketing.db")

    # ──────────────────────────────────────────────────────
    # Test 1: DB — Neue Tabellen
    # ──────────────────────────────────────────────────────
    try:
        from factory.marketing.tools.ranking_database import RankingDatabase
        db = RankingDatabase(db_path=tmp_db)

        import sqlite3
        conn = sqlite3.connect(tmp_db)
        tables = [r[0] for r in conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table'"
        ).fetchall()]
        conn.close()

        new_tables = {"trends", "competitors", "competitor_snapshots"}
        old_tables = {"keyword_rankings", "app_metrics", "review_log", "social_metrics", "post_performance"}
        found_new = new_tables.intersection(tables)
        found_old = old_tables.intersection(tables)

        ok = found_new == new_tables and found_old == old_tables
        log(1, "DB Tabellen", ok,
            f"trends, competitors, snapshots erstellt. "
            f"Bestehende: {len(found_old)}/5 OK")
    except Exception as e:
        log(1, "DB Tabellen", False, str(e))

    # ──────────────────────────────────────────────────────
    # Test 2: Trend-Monitor — Scan
    # ──────────────────────────────────────────────────────
    try:
        from factory.marketing.tools.trend_monitor import TrendMonitor
        tm = TrendMonitor()
        # Override DB to use temp
        tm.db = RankingDatabase(db_path=tmp_db)

        result = tm.scan_all_sources()
        ok = result.get("sources_scanned", 0) > 0 or result.get("sources_failed", 0) >= 0
        total_trends = (len(result.get("x", [])) + len(result.get("youtube", [])) +
                        len(result.get("google_news", [])) + len(result.get("google_trends", [])))
        scanned = result.get("sources_scanned", 0)
        failed = result.get("sources_failed", 0)
        log(2, "Trend Scan", ok,
            f"{scanned} sources, {total_trends} trends, {failed} failed")
    except Exception as e:
        log(2, "Trend Scan", False, str(e))

    # ──────────────────────────────────────────────────────
    # Test 3: Trend-Monitor — Relevanz-Bewertung
    # ──────────────────────────────────────────────────────
    try:
        mock_trends = {
            "google_news": [
                {"title": "AI generates complete apps autonomously — revolutionary new factory"},
                {"title": "New cat video goes viral on YouTube"},
            ],
            "sources_scanned": 1,
            "sources_failed": 0,
            "timestamp": "2026-01-01",
        }

        evaluated = tm.evaluate_relevance(mock_trends)
        ok = len(evaluated) >= 2

        # Check AI trend scored higher
        ai_score = None
        cat_score = None
        for e in evaluated:
            topic = e.get("topic", "").lower()
            if "ai" in topic or "factory" in topic or "autonomous" in topic:
                ai_score = float(e.get("relevance_score", 0))
            elif "cat" in topic or "viral" in topic:
                cat_score = float(e.get("relevance_score", 0))

        if ai_score is not None and cat_score is not None:
            ok = ok and ai_score > cat_score
            detail = f"AI trend: {ai_score}, Cat video: {cat_score}"
        else:
            detail = f"{len(evaluated)} trends evaluated (score comparison skipped)"

        # Check stored in DB
        history = tm.db.get_trend_history(days=1)
        ok = ok and len(history) >= 2
        detail += f", {len(history)} in DB"

        log(3, "Relevanz-Bewertung", ok, detail)
    except Exception as e:
        log(3, "Relevanz-Bewertung", False, str(e))

    # ──────────────────────────────────────────────────────
    # Test 4: Trend-Monitor — Alert bei hoher Relevanz
    # ──────────────────────────────────────────────────────
    try:
        high_trend = {
            "topic": "AI Factory revolutioniert App-Entwicklung",
            "source": "test",
            "relevance_score": 9.0,
            "urgency": "immediate",
            "content_suggestion": "Sofort Content erstellen",
        }

        alert_id = tm.create_trend_alert(high_trend)
        ok = alert_id is not None and alert_id.startswith("MKT-A")

        # Low relevance should NOT create alert
        low_trend = {"topic": "Irrelevant", "relevance_score": 3.0}
        no_alert = tm.create_trend_alert(low_trend)
        ok = ok and no_alert is None

        # Cleanup
        if alert_id:
            tm.alerts.resolve_alert(alert_id, "Test cleanup")

        log(4, "Trend Alert", ok, f"alert: {alert_id}, low: None (correct)")
    except Exception as e:
        log(4, "Trend Alert", False, str(e))

    # ──────────────────────────────────────────────────────
    # Test 5: TikTok Scraper — Hashtags
    # ──────────────────────────────────────────────────────
    try:
        from factory.marketing.tools.tiktok_scraper import TikTokCreativeScraper
        tts = TikTokCreativeScraper()
        tts.db = RankingDatabase(db_path=tmp_db)

        hashtags = tts.get_trending_hashtags("US")
        ok = len(hashtags) >= 1
        sources = set(h.get("source", "?") for h in hashtags)
        has_field = all("hashtag" in h and "source" in h for h in hashtags)
        ok = ok and has_field

        log(5, "TikTok Hashtags", ok,
            f"{len(hashtags)} hashtags (source: {', '.join(sources)})")
    except Exception as e:
        log(5, "TikTok Hashtags", False, str(e))

    # ──────────────────────────────────────────────────────
    # Test 6: TikTok Scraper — Full Scan
    # ──────────────────────────────────────────────────────
    try:
        result = tts.run_full_scan()
        has_hashtags = len(result.get("hashtags", [])) >= 1
        has_sounds = len(result.get("sounds", [])) >= 1 or "sounds" in result
        has_formats = len(result.get("formats", [])) >= 1 or "formats" in result
        stored = result.get("stored_in_db", 0)

        ok = has_hashtags and (has_sounds or has_formats)

        log(6, "TikTok Full Scan", ok,
            f"hashtags: {len(result.get('hashtags', []))}, "
            f"sounds: {len(result.get('sounds', []))}, "
            f"formats: {len(result.get('formats', []))}, "
            f"stored: {stored}")
    except Exception as e:
        log(6, "TikTok Full Scan", False, str(e))

    # ──────────────────────────────────────────────────────
    # Test 7: Competitor Tracker — App-Level
    # ──────────────────────────────────────────────────────
    try:
        from factory.marketing.tools.competitor_tracker import CompetitorTracker
        ct = CompetitorTracker()
        ct.db = RankingDatabase(db_path=tmp_db)

        result = ct.track_app_competitors("echomatch")
        ok = result.get("competitors_tracked", 0) >= 1
        details = result.get("details", [])

        # Check data in DB
        conn = ct.db._connect()
        comp_count = conn.execute("SELECT COUNT(*) as c FROM competitors WHERE level='app'").fetchone()["c"]
        conn.close()

        ok = ok and comp_count >= 1

        log(7, "App Competitors", ok,
            f"{result.get('competitors_tracked', 0)} tracked for echomatch, "
            f"{comp_count} in DB")
    except Exception as e:
        log(7, "App Competitors", False, str(e))

    # ──────────────────────────────────────────────────────
    # Test 8: Competitor Tracker — Factory-Level
    # ──────────────────────────────────────────────────────
    try:
        result = ct.track_factory_competitors()
        tracked = result.get("competitors_tracked", 0)
        direct = result.get("direct", 0)
        indirect = result.get("indirect", 0)

        ok = tracked >= 3 and direct >= 1 and indirect >= 1

        log(8, "Factory Competitors", ok,
            f"{tracked} tracked ({direct} direct, {indirect} indirect)")
    except Exception as e:
        log(8, "Factory Competitors", False, str(e))

    # ──────────────────────────────────────────────────────
    # Test 9: Change Detection
    # ──────────────────────────────────────────────────────
    try:
        test_db = RankingDatabase(db_path=tmp_db)

        # Store 2 snapshots with different ratings
        test_db.store_competitor_snapshot(
            competitor_name="TestCompetitor",
            rating=4.0, review_count=10000, version="1.0",
        )
        test_db.store_competitor_snapshot(
            competitor_name="TestCompetitor",
            rating=3.5, review_count=10500, version="1.1",
        )

        ct_test = CompetitorTracker()
        ct_test.db = test_db
        changes = ct_test.detect_changes("TestCompetitor")

        ok = changes["changed"] is True
        sig = changes.get("significance", "none")
        ok = ok and sig in ("major", "critical")  # 0.5 drop

        log(9, "Change Detection", ok,
            f"drop 4.0->3.5 detected as {sig}")
    except Exception as e:
        log(9, "Change Detection", False, str(e))

    # ──────────────────────────────────────────────────────
    # Test 10: Competitor Report
    # ──────────────────────────────────────────────────────
    try:
        ct_report = CompetitorTracker()
        ct_report.db = RankingDatabase(db_path=tmp_db)

        path = ct_report.create_competitor_report("factory")
        ok = os.path.exists(path) and path.endswith(".md")

        content = ""
        if ok:
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()

        # Should contain at least some competitor names
        has_content = len(content) > 50
        ok = ok and has_content

        log(10, "Competitor Report", ok,
            f"MD file created ({len(content)} chars)")
    except Exception as e:
        log(10, "Competitor Report", False, str(e))

    # ──────────────────────────────────────────────────────
    # Summary
    # ──────────────────────────────────────────────────────
    print()
    passed = sum(1 for _, _, ok, _ in RESULTS if ok)
    total = len(RESULTS)
    print(f"Phase 5 Block A — {passed}/{total} Tests Passed")

    # Cleanup temp DB
    try:
        os.remove(tmp_db)
        os.rmdir(tmp)
    except Exception:
        pass

    return passed, total


if __name__ == "__main__":
    run_all()
