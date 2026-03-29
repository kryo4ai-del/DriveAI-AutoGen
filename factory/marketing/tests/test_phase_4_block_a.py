"""Phase 4 Block A Tests — Store Adapters, Ranking DB, Social Analytics, KPI Tracker.

All 10 tests are deterministic (no LLM calls, no API costs).

Usage: python -m factory.marketing.tests.test_phase_4_block_a
"""

import json
import logging
import os
import shutil
import sys
import tempfile
from datetime import datetime, timedelta
from pathlib import Path

# Setup path
_ROOT = Path(__file__).parent.parent.parent.parent
sys.path.insert(0, str(_ROOT))

logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s")
logger = logging.getLogger("test_phase_4a")

passed = 0
failed = 0
results = []


def report(test_num: int, name: str, ok: bool, detail: str = "") -> None:
    global passed, failed
    status = "OK" if ok else "FAIL"
    if ok:
        passed += 1
    else:
        failed += 1
    msg = f"{status} Test {test_num}: {name}"
    if detail:
        msg += f" — {detail}"
    results.append(msg)
    print(msg)


# ============================================================
# Test 1: App Store Adapter — Mock Reviews
# ============================================================
def test_1_appstore_reviews():
    try:
        from factory.marketing.adapters.appstore_adapter import AppStoreAdapter

        adapter = AppStoreAdapter(dry_run=True)
        assert adapter.dry_run is True
        reviews = adapter.get_reviews("com.driveai.askfin")
        assert len(reviews) >= 5, f"Expected >= 5 reviews, got {len(reviews)}"

        for r in reviews:
            assert "id" in r, f"Missing id in review"
            assert "rating" in r, f"Missing rating in review"
            assert "title" in r, f"Missing title in review"
            assert "body" in r, f"Missing body in review"
            assert 1 <= r["rating"] <= 5, f"Invalid rating: {r['rating']}"

        ratings = [r["rating"] for r in reviews]
        report(1, "App Store Reviews", True, f"{len(reviews)} reviews (ratings {min(ratings)}-{max(ratings)})")
    except Exception as e:
        report(1, "App Store Reviews", False, str(e))


# ============================================================
# Test 2: App Store Adapter — Mock Metrics
# ============================================================
def test_2_appstore_metrics():
    try:
        from factory.marketing.adapters.appstore_adapter import AppStoreAdapter

        adapter = AppStoreAdapter(dry_run=True)
        metrics = adapter.get_app_metrics("com.driveai.askfin")

        assert "downloads" in metrics, "Missing downloads"
        assert "revenue" in metrics, "Missing revenue"
        assert "sessions" in metrics, "Missing sessions"
        assert "crashes" in metrics, "Missing crashes"
        assert "active_devices" in metrics, "Missing active_devices"
        assert "retention" in metrics, "Missing retention"

        dau = metrics["active_devices"]["dau"]
        assert dau == 25000, f"Expected DAU 25000, got {dau}"

        ratings = adapter.get_ratings_summary("com.driveai.askfin")
        assert ratings["average"] == 4.3, f"Expected rating 4.3, got {ratings['average']}"

        report(2, "App Store Metrics", True, f"DAU {dau}, Rating {ratings['average']}")
    except Exception as e:
        report(2, "App Store Metrics", False, str(e))


# ============================================================
# Test 3: Google Play Adapter — Mock Reviews + Metrics
# ============================================================
def test_3_googleplay():
    try:
        from factory.marketing.adapters.googleplay_adapter import GooglePlayAdapter

        adapter = GooglePlayAdapter(dry_run=True)
        assert adapter.dry_run is True

        reviews = adapter.get_reviews("com.driveai.askfin")
        assert len(reviews) >= 5, f"Expected >= 5 reviews, got {len(reviews)}"

        metrics = adapter.get_app_metrics("com.driveai.askfin")
        dau = metrics["active_devices"]["dau"]
        assert dau == 32000, f"Expected DAU 32000 (Android > iOS), got {dau}"

        downloads = metrics["downloads"]["daily_avg"]
        assert downloads > 850, f"Expected Android downloads > iOS (850), got {downloads}"

        report(3, "Google Play", True, f"{len(reviews)} reviews, DAU {dau}")
    except Exception as e:
        report(3, "Google Play", False, str(e))


# ============================================================
# Test 4: Ranking-Datenbank — CRUD
# ============================================================
def test_4_ranking_db_crud():
    db_path = os.path.join(tempfile.mkdtemp(prefix="mkt_test_"), "test.db")
    try:
        from factory.marketing.tools.ranking_database import RankingDatabase

        db = RankingDatabase(db_path=db_path)

        # Store keywords
        rankings = [
            {"keyword": "Fuehrerschein App", "position": 3},
            {"keyword": "Fahrschule lernen", "position": 7},
            {"keyword": "Theorie Test", "position": 12},
            {"keyword": "Driving Test", "position": 42},
            {"keyword": "Verkehrsregeln", "position": 9},
        ]
        kw_count = db.store_keyword_rankings("com.driveai.askfin", "app_store", rankings)
        assert kw_count == 5, f"Expected 5 keywords stored, got {kw_count}"

        # Store metrics
        metrics = {"downloads": {"daily_avg": 850, "total_30d": 25500}}
        m_count = db.store_app_metrics("com.driveai.askfin", "app_store", metrics)
        assert m_count == 1, f"Expected 1 metric stored, got {m_count}"

        # Store review
        review = {"id": "r001", "rating": 5, "title": "Super", "body": "Toll!", "author": "Max"}
        r_id = db.store_review("com.driveai.askfin", "app_store", review)
        assert r_id > 0, f"Expected positive row id, got {r_id}"

        # Get keyword trend
        trend = db.get_keyword_trend("com.driveai.askfin", "Fuehrerschein App", days=1)
        assert len(trend) == 1, f"Expected 1 datapoint, got {len(trend)}"

        # DB stats
        stats = db.get_db_stats()
        assert stats["tables"]["keyword_rankings"] == 5
        assert stats["tables"]["app_metrics"] == 1
        assert stats["tables"]["review_log"] == 1

        report(4, "Ranking-DB CRUD", True, f"5 keywords, 1 metric, 1 review stored")
    except Exception as e:
        report(4, "Ranking-DB CRUD", False, str(e))
    finally:
        shutil.rmtree(os.path.dirname(db_path), ignore_errors=True)


# ============================================================
# Test 5: Ranking-DB — Trend-Abfrage
# ============================================================
def test_5_ranking_db_trend():
    db_path = os.path.join(tempfile.mkdtemp(prefix="mkt_test_"), "test.db")
    try:
        from factory.marketing.tools.ranking_database import RankingDatabase
        import sqlite3

        db = RankingDatabase(db_path=db_path)

        # 7 Tage simulieren
        conn = sqlite3.connect(db_path)
        for i in range(7):
            day = (datetime.now() - timedelta(days=6-i)).strftime("%Y-%m-%d")
            dau = 24000 + i * 200
            conn.execute(
                "INSERT INTO app_metrics (date, app_id, store, metric_type, value, metadata_json) "
                "VALUES (?, ?, ?, ?, ?, ?)",
                (day, "com.driveai.askfin", "app_store", "dau", dau, json.dumps({"dau": dau})),
            )
        conn.commit()
        conn.close()

        trend = db.get_metrics_trend("com.driveai.askfin", "dau", days=7)
        assert len(trend) == 7, f"Expected 7 datapoints, got {len(trend)}"

        # Werte sollten aufsteigend sein
        values = [t["value"] for t in trend]
        assert values == sorted(values), f"Expected ascending values: {values}"

        report(5, "Ranking-DB Trend", True, f"{len(trend)} datapoints")
    except Exception as e:
        report(5, "Ranking-DB Trend", False, str(e))
    finally:
        shutil.rmtree(os.path.dirname(db_path), ignore_errors=True)


# ============================================================
# Test 6: Social Analytics Collector — Collect Stats
# ============================================================
def test_6_social_analytics():
    try:
        from factory.marketing.tools.social_analytics_collector import SocialAnalyticsCollector

        collector = SocialAnalyticsCollector()
        stats = collector.collect_all_platform_stats()

        # Mindestens die 3 Social-Media-Adapter (youtube, tiktok, x)
        social_platforms = {"youtube", "tiktok", "x"}
        collected = set(stats.keys()) & social_platforms
        assert len(collected) >= 3, f"Expected 3 social platforms, got {len(collected)}: {collected}"

        report(6, "Social Analytics", True, f"{len(collected)} platforms collected")
    except Exception as e:
        report(6, "Social Analytics", False, str(e))


# ============================================================
# Test 7: KPI Tracker — Alle Checks bestanden
# ============================================================
def test_7_kpi_good():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.kpi_tracker import KPITracker

        tracker = KPITracker(alert_base_path=tmp_dir)
        good_metrics = {
            "d1_retention": 42,
            "d7_retention": 22,
            "d30_retention": 11,
            "store_rating": 4.3,
            "crash_rate": 0.08,
            "arpu": 0.15,
            "dau": 25000,
        }
        result = tracker.check_kpis(good_metrics)

        assert result["overall_status"] == "ok", f"Expected ok, got {result['overall_status']}"
        assert result["alerts_created"] == 0, f"Expected 0 alerts, got {result['alerts_created']}"

        report(7, "KPI Good", True, f"status=ok, 0 alerts")
    except Exception as e:
        report(7, "KPI Good", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 8: KPI Tracker — Warning erkennen
# ============================================================
def test_8_kpi_bad():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.kpi_tracker import KPITracker

        tracker = KPITracker(alert_base_path=tmp_dir)
        bad_metrics = {
            "d1_retention": 33,
            "d7_retention": 14,
            "store_rating": 3.9,
            "crash_rate": 1.5,
            "dau": 12000,
        }
        result = tracker.check_kpis(bad_metrics)

        assert result["overall_status"] in ("warning", "critical"), \
            f"Expected warning/critical, got {result['overall_status']}"
        assert result["alerts_created"] > 0, f"Expected alerts, got {result['alerts_created']}"

        report(8, "KPI Bad", True,
               f"status={result['overall_status']}, {result['alerts_created']} alerts")
    except Exception as e:
        report(8, "KPI Bad", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 9: KPI Tracker — Rating-Einbruch
# ============================================================
def test_9_rating_drop():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.kpi_tracker import KPITracker

        tracker = KPITracker(alert_base_path=tmp_dir)
        result = tracker.check_store_rating(3.8, 4.3)

        assert result["status"] == "critical", f"Expected critical, got {result['status']}"
        assert result["drop"] == 0.5, f"Expected drop 0.5, got {result['drop']}"
        assert result["alert_created"] is True, "Expected alert to be created"

        report(9, "Rating Drop", True, f"critical alert, drop={result['drop']}")
    except Exception as e:
        report(9, "Rating Drop", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 10: Export fuer Report
# ============================================================
def test_10_export():
    db_path = os.path.join(tempfile.mkdtemp(prefix="mkt_test_"), "test.db")
    try:
        from factory.marketing.tools.ranking_database import RankingDatabase

        db = RankingDatabase(db_path=db_path)

        # Daten einfuegen
        db.store_keyword_rankings("com.driveai.askfin", "app_store", [
            {"keyword": "Fuehrerschein App", "position": 3},
        ])
        db.store_app_metrics("com.driveai.askfin", "app_store", {
            "downloads": {"daily_avg": 850},
        })
        db.store_review("com.driveai.askfin", "app_store", {
            "id": "r001", "rating": 5, "title": "Super", "body": "Toll!", "author": "Max",
        })

        export = db.export_for_report("com.driveai.askfin", 30)

        assert "db_stats" in export, "Missing db_stats"
        assert "keyword_trends" in export, "Missing keyword_trends"
        assert "metric_trends" in export, "Missing metric_trends"
        assert "review_stats" in export, "Missing review_stats"
        assert "top_posts" in export, "Missing top_posts"

        report(10, "Export", True, f"all sections present, {export['db_stats']['total_rows']} rows")
    except Exception as e:
        report(10, "Export", False, str(e))
    finally:
        shutil.rmtree(os.path.dirname(db_path), ignore_errors=True)


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("Phase 4 Block A — Integration Tests")
    print("=" * 60 + "\n")

    test_1_appstore_reviews()
    test_2_appstore_metrics()
    test_3_googleplay()
    test_4_ranking_db_crud()
    test_5_ranking_db_trend()
    test_6_social_analytics()
    test_7_kpi_good()
    test_8_kpi_bad()
    test_9_rating_drop()
    test_10_export()

    print("\n" + "=" * 60)
    print(f"Phase 4 Block A — {passed}/10 Tests Passed")
    print("=" * 60)

    for r in results:
        print(f"  {r}")

    sys.exit(0 if failed == 0 else 1)
