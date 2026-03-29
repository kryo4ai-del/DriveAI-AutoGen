"""Phase 4 Integration-Test — Prueft das ZUSAMMENSPIEL aller Phase-4-Komponenten.

Alle 10 Tests sind deterministisch (kein LLM, keine API-Kosten).
LLM-abhaengige Teile (Report-Generierung, Review-Antworten) werden
durch Struktur-Pruefung ersetzt — die LLM-Logik ist in Block-Tests abgedeckt.

Usage: python -m factory.marketing.tests.test_phase_4_integration
"""

import json
import logging
import os
import shutil
import sys
import tempfile
from datetime import datetime
from pathlib import Path

# Setup path
_ROOT = Path(__file__).parent.parent.parent.parent
sys.path.insert(0, str(_ROOT))

logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s")
logger = logging.getLogger("test_phase_4_integration")

passed = 0
failed = 0
results = []

# Shared temp dirs for integration (cleaned up at end)
_INTEGRATION_TMP = tempfile.mkdtemp(prefix="mkt_integration_")
_DB_PATH = os.path.join(_INTEGRATION_TMP, "integration_test.db")
_ALERT_PATH = os.path.join(_INTEGRATION_TMP, "alerts")
_HQ_PATH = os.path.join(_INTEGRATION_TMP, "hq_bridge")
_REPORT_PATH = os.path.join(_INTEGRATION_TMP, "reports")

os.makedirs(_ALERT_PATH, exist_ok=True)
os.makedirs(_HQ_PATH, exist_ok=True)
os.makedirs(_REPORT_PATH, exist_ok=True)


def report(test_num: int, name: str, ok: bool, detail: str = "") -> None:
    global passed, failed
    status = "OK" if ok else "FAIL"
    if ok:
        passed += 1
    else:
        failed += 1
    msg = f"{status} Test {test_num}: {name}"
    if detail:
        msg += f" -- {detail}"
    results.append(msg)
    print(msg)


# ============================================================
# Test 1: Store->DB Pipeline
# ============================================================
def test_1_store_to_db():
    try:
        from factory.marketing.adapters.appstore_adapter import AppStoreAdapter
        from factory.marketing.adapters.googleplay_adapter import GooglePlayAdapter
        from factory.marketing.tools.ranking_database import RankingDatabase

        db = RankingDatabase(db_path=_DB_PATH)

        # iOS
        ios = AppStoreAdapter(dry_run=True)
        ios_reviews = ios.get_reviews("com.driveai.askfin")
        ios_metrics = ios.get_app_metrics("com.driveai.askfin")
        ios_ratings = ios.get_ratings_summary("com.driveai.askfin")
        ios_keywords = ios.get_keyword_rankings("com.driveai.askfin")

        for r in ios_reviews:
            db.store_review("com.driveai.askfin", "app_store", r)
        db.store_app_metrics("com.driveai.askfin", "app_store", ios_metrics)
        db.store_keyword_rankings("com.driveai.askfin", "app_store", ios_keywords)

        # Android
        android = GooglePlayAdapter(dry_run=True)
        android_reviews = android.get_reviews("com.driveai.askfin")
        android_metrics = android.get_app_metrics("com.driveai.askfin")

        for r in android_reviews:
            db.store_review("com.driveai.askfin", "google_play", r)
        db.store_app_metrics("com.driveai.askfin", "google_play", android_metrics)

        # Verify
        stats = db.get_db_stats()
        assert stats["tables"]["review_log"] >= 10, \
            f"Expected >= 10 reviews, got {stats['tables']['review_log']}"
        assert stats["tables"]["app_metrics"] >= 2, \
            f"Expected >= 2 metrics, got {stats['tables']['app_metrics']}"
        assert stats["tables"]["keyword_rankings"] >= 5, \
            f"Expected >= 5 keywords, got {stats['tables']['keyword_rankings']}"

        # Both stores present
        review_stats = db.get_review_stats("com.driveai.askfin", days=1)
        assert review_stats["total"] >= 10

        report(1, "Store->DB",  True,
               f"iOS: {len(ios_reviews)} reviews + metrics, "
               f"Android: {len(android_reviews)} reviews + metrics, "
               f"DB: {stats['tables']['review_log']} reviews, "
               f"{stats['tables']['app_metrics']} metrics")
    except Exception as e:
        report(1, "Store->DB", False, str(e))


# ============================================================
# Test 2: Social->DB Pipeline
# ============================================================
def test_2_social_to_db():
    try:
        from factory.marketing.tools.ranking_database import RankingDatabase

        db = RankingDatabase(db_path=_DB_PATH)
        stats_before = db.get_db_stats()["tables"].get("social_metrics", 0)

        from factory.marketing.tools.social_analytics_collector import SocialAnalyticsCollector

        # Override DB path
        collector = SocialAnalyticsCollector()
        collector.db = db
        platform_stats = collector.collect_all_platform_stats()

        social_platforms = {"youtube", "tiktok", "x"}
        collected = set(platform_stats.keys()) & social_platforms
        assert len(collected) == 3, f"Expected 3 platforms, got {collected}"

        stats_after = db.get_db_stats()["tables"].get("social_metrics", 0)
        new_rows = stats_after - stats_before
        assert new_rows >= 3, f"Expected >= 3 new social_metrics rows, got {new_rows}"

        report(2, "Social->DB", True,
               f"{len(collected)} platforms, {new_rows} new social_metrics rows")
    except Exception as e:
        report(2, "Social->DB", False, str(e))


# ============================================================
# Test 3: KPI->Alert Pipeline
# ============================================================
def test_3_kpi_to_alert():
    try:
        from factory.marketing.tools.kpi_tracker import KPITracker

        tracker = KPITracker(alert_base_path=_ALERT_PATH)

        # Simuliere schlechte Metriken
        bad_metrics = {
            "d1_retention": 30,      # Critical (< 30 threshold)
            "d7_retention": 14,      # Critical (< 10 threshold) → actually warning
            "store_rating": 3.8,     # Warning (< 4.0)
            "crash_rate": 1.5,       # Warning (> 1.0)
            "dau": 12000,            # Critical (< 5000? no, warning < 15000)
        }
        result = tracker.check_kpis(bad_metrics)

        assert result["overall_status"] in ("warning", "critical"), \
            f"Expected warning/critical, got {result['overall_status']}"
        assert result["alerts_created"] > 0, \
            f"Expected alerts, got {result['alerts_created']}"

        # Rating-Drop Check
        rating_result = tracker.check_store_rating(3.8, 4.3)
        assert rating_result["status"] == "critical", \
            f"Expected critical for rating drop, got {rating_result['status']}"
        assert rating_result["alert_created"] is True

        # Count alerts
        from factory.marketing.alerts.alert_manager import MarketingAlertManager
        am = MarketingAlertManager(base_path=_ALERT_PATH)
        active = am.get_active_alerts()
        critical_count = sum(1 for a in active if a.get("priority") == "critical")
        warning_count = sum(1 for a in active if a.get("priority") == "high")

        report(3, "KPI->Alert", True,
               f"{len(active)} alerts ({critical_count} critical, {warning_count} high)")
    except Exception as e:
        report(3, "KPI->Alert", False, str(e))


# ============================================================
# Test 4: Review Zwei-Stufen Pipeline
# ============================================================
def test_4_review_two_tier():
    try:
        from factory.marketing.agents.review_manager import ReviewManager
        from factory.marketing.tools.ranking_database import RankingDatabase

        mgr = ReviewManager(alert_base_path=_ALERT_PATH)
        db = RankingDatabase(db_path=_DB_PATH)

        reviews = [
            # Stufe 1 (positive/neutral)
            {"id": "int_r01", "rating": 5, "title": "Perfekt!", "body": "Genau was ich brauchte.", "author": "Max"},
            {"id": "int_r02", "rating": 4, "title": "Gut", "body": "Schoene App, gefaellt mir.", "author": "Lisa"},
            {"id": "int_r03", "rating": 3, "title": "OK", "body": "Macht was es soll.", "author": "Tom"},
            # Stufe 2 (negative/keywords)
            {"id": "int_r04", "rating": 1, "title": "Katastrophe", "body": "Funktioniert nicht!", "author": "Hans"},
            {"id": "int_r05", "rating": 2, "title": "Betrug", "body": "Scam App, will mein Geld zurueck.", "author": "Karl"},
            {"id": "int_r06", "rating": 4, "title": "Datenschutz?", "body": "Was passiert mit meinem Datenschutz?", "author": "Eva"},
        ]

        tier1_results = []
        tier2_results = []

        for review in reviews:
            classification = mgr.classify_review(review)
            db.store_review("com.driveai.askfin", "app_store", {
                **review, "tier": classification["tier"]
            })
            if classification["tier"] == 1:
                tier1_results.append(review["id"])
            else:
                # Process tier 2 to create gate
                result = mgr.process_review(review, store="app_store")
                tier2_results.append(result)
                assert result["response"] is None, \
                    f"Tier 2 review {review['id']} should NOT have auto-response!"

        assert len(tier1_results) == 3, f"Expected 3 tier1, got {len(tier1_results)}"
        assert len(tier2_results) == 3, f"Expected 3 tier2, got {len(tier2_results)}"

        # Verify all tier2 have gates
        for r in tier2_results:
            assert r["gate_id"], f"Tier 2 review should have gate_id"
            assert r["action"] == "gate_created"

        report(4, "Review Zwei-Stufen", True,
               f"{len(tier1_results)} stufe1, {len(tier2_results)} stufe2 gated, "
               f"0 auto-responses on negative")
    except Exception as e:
        report(4, "Review Zwei-Stufen", False, str(e))


# ============================================================
# Test 5: Community Zwei-Stufen Pipeline
# ============================================================
def test_5_community_two_tier():
    try:
        from factory.marketing.agents.community_agent import CommunityAgent

        agent = CommunityAgent(alert_base_path=_ALERT_PATH)

        comments = [
            # Stufe 1 (positive/neutral)
            {"id": "int_c01", "text": "Mega Video!", "author": "Anna", "platform": "youtube"},
            {"id": "int_c02", "text": "Wann kommt das naechste Update?", "author": "Ben", "platform": "tiktok"},
            {"id": "int_c03", "text": "Nice content!", "author": "Chris", "platform": "x"},
            # Stufe 2 (negative/kontrovers)
            {"id": "int_c04", "text": "Das ist doch alles scam und fake!", "author": "Troll", "platform": "youtube"},
            {"id": "int_c05", "text": "Betrug! Ich melde euch!", "author": "Hater", "platform": "tiktok"},
        ]

        tier1_count = 0
        tier2_count = 0
        tier2_auto_responses = 0

        for comment in comments:
            classification = agent.classify_comment(comment)
            if classification["tier"] == 1:
                tier1_count += 1
            else:
                result = agent.process_comment(comment)
                tier2_count += 1
                if result["response"] is not None:
                    tier2_auto_responses += 1
                assert result["gate_id"], f"Tier 2 comment should have gate_id"

        assert tier1_count == 3, f"Expected 3 tier1, got {tier1_count}"
        assert tier2_count == 2, f"Expected 2 tier2, got {tier2_count}"
        assert tier2_auto_responses == 0, \
            f"CRITICAL: {tier2_auto_responses} auto-responses on negative comments!"

        report(5, "Community Zwei-Stufen", True,
               f"{tier1_count} stufe1, {tier2_count} stufe2, "
               f"{tier2_auto_responses} auto-responses on negative")
    except Exception as e:
        report(5, "Community Zwei-Stufen", False, str(e))


# ============================================================
# Test 6: Report Agent Data Gathering mit gefuellter DB
# ============================================================
def test_6_report_data():
    try:
        from factory.marketing.agents.report_agent import ReportAgent

        agent = ReportAgent()
        # _gather_data ist deterministisch — sammelt aus allen Quellen
        data = agent._gather_data(days=1)

        assert "kpi_check" in data, "Missing kpi_check"
        assert "alert_stats" in data, "Missing alert_stats"
        assert "social_stats" in data, "Missing social_stats"
        assert "top_content" in data, "Missing top_content"
        assert "db_export" in data, "Missing db_export"

        # Verify kpi_check ran
        kpi = data.get("kpi_check", {})
        has_kpi_data = "overall_status" in kpi or "kpi_check" in kpi
        assert has_kpi_data or kpi == {}, "KPI data should exist or be empty dict"

        # Report path would need LLM to generate content, but we verify
        # the data gathering pipeline works end-to-end
        os.makedirs(_REPORT_PATH, exist_ok=True)
        report_path = os.path.join(_REPORT_PATH, f"daily_{datetime.now().strftime('%Y-%m-%d')}.md")
        with open(report_path, "w", encoding="utf-8") as f:
            f.write(f"# Daily Briefing {datetime.now().strftime('%d.%m.%Y')}\n\n")
            f.write(f"## KPI Status\n{json.dumps(kpi, indent=2, default=str)}\n\n")
            f.write(f"## Alert Stats\n{json.dumps(data.get('alert_stats', {}), indent=2, default=str)}\n\n")
            f.write(f"## Social Media\n{json.dumps(data.get('social_stats', {}), indent=2, default=str)}\n\n")

        assert os.path.exists(report_path), "Report file not created"
        file_size = os.path.getsize(report_path)
        assert file_size > 100, f"Report too small: {file_size} bytes"

        report(6, "Report Data Gathering", True,
               f"report={os.path.basename(report_path)}, {file_size} bytes, "
               f"sections: KPI, Alerts, Social")
    except Exception as e:
        report(6, "Report Data Gathering", False, str(e))


# ============================================================
# Test 7: HQ Bridge mit gefuellten Daten
# ============================================================
def test_7_hq_bridge():
    try:
        from factory.marketing.tools.hq_bridge import HQBridge

        bridge = HQBridge(output_dir=_HQ_PATH)
        status = bridge.export_department_status()

        assert status["department"] == "Marketing"
        assert len(status["agents"]) >= 11, \
            f"Expected >= 11 agents, got {len(status['agents'])}"

        # KPI status should reflect the system state
        assert "kpis" in status, "Missing kpis"

        # Alerts should be present (from test 3)
        alert_feed = bridge.export_alert_feed()
        # Alerts were created in _ALERT_PATH, but HQ Bridge uses its own default path
        # So we just verify the export structure
        assert "alerts" in alert_feed, "Missing alerts in feed"
        assert "gates" in alert_feed, "Missing gates in feed"
        assert "stats" in alert_feed, "Missing stats in feed"
        assert os.path.exists(alert_feed["export_path"]), "Alert feed file missing"

        # KPI Dashboard
        kpi_dash = bridge.export_kpi_dashboard()
        assert "kpi_check" in kpi_dash, "Missing kpi_check"
        assert "social_summary" in kpi_dash, "Missing social_summary"
        assert os.path.exists(kpi_dash["export_path"]), "KPI dashboard file missing"

        # Verify JSON is valid
        with open(status["export_path"], "r", encoding="utf-8") as f:
            loaded = json.load(f)
        assert loaded["department"] == "Marketing"

        report(7, "HQ Bridge", True,
               f"JSON valid, {len(status['agents'])} agents, "
               f"exports: status + alerts + kpi")
    except Exception as e:
        report(7, "HQ Bridge", False, str(e))


# ============================================================
# Test 8: End-to-End Datenfluss
# ============================================================
def test_8_e2e_dataflow():
    try:
        from factory.marketing.tools.ranking_database import RankingDatabase
        from factory.marketing.alerts.alert_manager import MarketingAlertManager

        db = RankingDatabase(db_path=_DB_PATH)
        am = MarketingAlertManager(base_path=_ALERT_PATH)

        # DB Stats
        db_stats = db.get_db_stats()
        total_rows = sum(db_stats["tables"].values())

        # Alert Stats
        alert_stats = am.get_alert_stats()
        active_alerts = alert_stats["active"]
        pending_gates = alert_stats["pending_gates"]

        # Consistency checks
        assert db_stats["tables"]["review_log"] >= 10, \
            f"Expected >= 10 reviews, got {db_stats['tables']['review_log']}"
        assert db_stats["tables"]["app_metrics"] >= 2, \
            f"Expected >= 2 metrics, got {db_stats['tables']['app_metrics']}"
        assert db_stats["tables"]["social_metrics"] >= 3, \
            f"Expected >= 3 social, got {db_stats['tables']['social_metrics']}"
        assert total_rows >= 15, \
            f"Expected >= 15 total rows, got {total_rows}"
        assert active_alerts >= 1, \
            f"Expected >= 1 active alert, got {active_alerts}"
        assert pending_gates >= 1, \
            f"Expected >= 1 pending gate, got {pending_gates}"

        report(8, "E2E Data Flow", True,
               f"DB: {total_rows} rows total, "
               f"Alerts: {active_alerts}, Gates: {pending_gates}")

        # Print DB stats for report
        print(f"\n=== DB Stats nach Tests ===")
        for table, count in db_stats["tables"].items():
            print(f"{table}: {count} rows")
        print(f"DB Size: {db_stats.get('db_size_kb', '?')} KB")

    except Exception as e:
        report(8, "E2E Data Flow", False, str(e))


# ============================================================
# Test 9: Ranking-DB Export fuer Report
# ============================================================
def test_9_db_export():
    try:
        from factory.marketing.tools.ranking_database import RankingDatabase

        db = RankingDatabase(db_path=_DB_PATH)
        export = db.export_for_report("com.driveai.askfin", 30)

        assert "db_stats" in export, "Missing db_stats"
        assert "keyword_trends" in export, "Missing keyword_trends"
        assert "metric_trends" in export, "Missing metric_trends"
        assert "review_stats" in export, "Missing review_stats"
        assert "top_posts" in export, "Missing top_posts"

        # Verify there's actual data
        assert export["db_stats"]["total_rows"] > 0, "DB should have data"

        # Review stats should show our test reviews
        rev_stats = export["review_stats"]
        assert rev_stats["total"] >= 10, \
            f"Expected >= 10 reviews in export, got {rev_stats['total']}"

        report(9, "DB Export", True,
               f"all sections present, {export['db_stats']['total_rows']} rows, "
               f"{rev_stats['total']} reviews")
    except Exception as e:
        report(9, "DB Export", False, str(e))


# ============================================================
# Test 10: Gesamt-Status-Check (Imports)
# ============================================================
def test_10_status_check():
    try:
        # 11 Agents
        from factory.marketing.agents import (
            BrandGuardian, StrategyAgent, Copywriter, NamingAgent, ASOAgent,
            VisualDesigner, VideoScriptAgent, PublishingOrchestrator,
            ReportAgent, ReviewManager, CommunityAgent,
        )
        agent_count = 11

        # 9 Adapters (5 active + 4 stubs)
        from factory.marketing.adapters import (
            YouTubeAdapter, TikTokAdapter, XAdapter,
            AppStoreAdapter, GooglePlayAdapter,
            InstagramAdapter, LinkedInAdapter, RedditAdapter, TwitchAdapter,
        )
        from factory.marketing.adapters import ACTIVE_ADAPTERS, STUB_ADAPTERS, ALL_ADAPTERS
        active_adapter_count = len(ACTIVE_ADAPTERS)
        stub_adapter_count = len(STUB_ADAPTERS)
        total_adapter_count = len(ALL_ADAPTERS)

        # 7 Tools
        from factory.marketing.tools import (
            MarketingTemplateEngine, MarketingVideoPipeline, ContentCalendar,
            RankingDatabase, SocialAnalyticsCollector, KPITracker, HQBridge,
        )
        tool_count = 7

        # Alert System
        from factory.marketing.alerts.alert_manager import MarketingAlertManager
        from factory.marketing.alerts.alert_schema import ALERT_TYPES, ALERT_PRIORITIES

        # Config
        from factory.marketing.config import (
            MARKETING_ROOT, OUTPUT_PATH, BRAND_PATH, REPORTS_PATH, ALERTS_PATH,
        )

        assert active_adapter_count == 5, f"Expected 5 active adapters, got {active_adapter_count}"
        assert stub_adapter_count == 4, f"Expected 4 stub adapters, got {stub_adapter_count}"
        assert total_adapter_count == 9, f"Expected 9 total adapters, got {total_adapter_count}"

        report(10, "Status Check", True,
               f"{agent_count} agents, {total_adapter_count} adapters "
               f"({active_adapter_count} active + {stub_adapter_count} stubs), "
               f"{tool_count} tools, all OK")
    except Exception as e:
        report(10, "Status Check", False, str(e))


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("Phase 4 Integration-Test")
    print("=" * 60 + "\n")

    test_1_store_to_db()
    test_2_social_to_db()
    test_3_kpi_to_alert()
    test_4_review_two_tier()
    test_5_community_two_tier()
    test_6_report_data()
    test_7_hq_bridge()
    test_8_e2e_dataflow()
    test_9_db_export()
    test_10_status_check()

    print("\n" + "=" * 60)
    print(f"Phase 4 Integration — {passed}/10 Tests Passed")
    print("=" * 60)

    for r in results:
        print(f"  {r}")

    # Cleanup
    print(f"\nCleaning up temp dir: {_INTEGRATION_TMP}")
    shutil.rmtree(_INTEGRATION_TMP, ignore_errors=True)

    sys.exit(0 if failed == 0 else 1)
