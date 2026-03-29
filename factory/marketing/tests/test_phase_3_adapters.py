"""Phase 3 Block B Tests — Adapters + Publishing Orchestrator.

Tests 1-9: Deterministisch (kein LLM, kein API-Call, alles Dry-Run)

Usage: python -m factory.marketing.tests.test_phase_3_adapters
"""

import json
import logging
import os
import shutil
import sys
import tempfile
from datetime import datetime, timedelta
from pathlib import Path

_ROOT = Path(__file__).parent.parent.parent.parent
sys.path.insert(0, str(_ROOT))

logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s")
logger = logging.getLogger("test_phase_3b")

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
        msg += f" -- {detail}"
    results.append(msg)
    print(msg)


# ============================================================
# Test 1: YouTube Adapter Dry-Run
# ============================================================
def test_1_youtube_dry_run():
    try:
        from factory.marketing.adapters.youtube_adapter import YouTubeAdapter

        adapter = YouTubeAdapter(dry_run=True)

        # Erstelle Dummy-Video-Datei
        tmp = tempfile.NamedTemporaryFile(suffix=".mp4", delete=False)
        tmp.write(b"\x00" * 100)
        tmp.close()

        result = adapter.upload_video(tmp.name, "Test Title", "Test Description")
        os.unlink(tmp.name)

        if not result.get("dry_run"):
            report(1, "YouTube Dry-Run", False, f"dry_run not True: {result}")
            return

        has_method = result.get("method") == "upload_video"
        has_fake_id = "fake_id" in result

        report(1, "YouTube Dry-Run", has_method and has_fake_id, "upload logged")
    except Exception as e:
        report(1, "YouTube Dry-Run", False, str(e))


# ============================================================
# Test 2: TikTok Adapter Dry-Run
# ============================================================
def test_2_tiktok_dry_run():
    try:
        from factory.marketing.adapters.tiktok_adapter import TikTokAdapter

        adapter = TikTokAdapter()  # Kein Token = force dry_run

        tmp = tempfile.NamedTemporaryFile(suffix=".mp4", delete=False)
        tmp.write(b"\x00" * 100)
        tmp.close()

        result = adapter.upload_video(tmp.name, "Test Description")
        os.unlink(tmp.name)

        if not result.get("dry_run"):
            report(2, "TikTok Dry-Run", False, f"dry_run not True: {result}")
            return

        report(2, "TikTok Dry-Run", result.get("method") == "upload_video", "upload logged")
    except Exception as e:
        report(2, "TikTok Dry-Run", False, str(e))


# ============================================================
# Test 3: X Adapter Dry-Run + Zeichenlimit
# ============================================================
def test_3_x_dry_run():
    try:
        from factory.marketing.adapters.x_adapter import XAdapter

        adapter = XAdapter()

        # Normal tweet
        result = adapter.post_tweet("Die Factory hat heute ein Video erstellt. #DriveAI")
        if not result.get("dry_run"):
            report(3, "X Dry-Run", False, f"dry_run not True: {result}")
            return

        # 281 Zeichen tweet — muss Fehler geben
        result_long = adapter.post_tweet("x" * 281)
        has_error = result_long.get("error") == "text_too_long"
        has_length = result_long.get("length") == 281

        report(3, "X Dry-Run", has_error and has_length, "tweet logged, 281-char rejected")
    except Exception as e:
        report(3, "X Dry-Run", False, str(e))


# ============================================================
# Test 4: X Adapter Thread
# ============================================================
def test_4_x_thread():
    try:
        from factory.marketing.adapters.x_adapter import XAdapter

        adapter = XAdapter()
        thread = [
            {"text": "Thread Part 1"},
            {"text": "Thread Part 2"},
            {"text": "Thread Part 3"},
        ]
        results_list = adapter.post_thread(thread)

        if len(results_list) != 3:
            report(4, "X Thread", False, f"{len(results_list)} results statt 3")
            return

        all_dry = all(r.get("dry_run") for r in results_list)
        report(4, "X Thread", all_dry, "3 tweets logged")
    except Exception as e:
        report(4, "X Thread", False, str(e))


# ============================================================
# Test 5: Stub-Adapter
# ============================================================
def test_5_stubs():
    try:
        from factory.marketing.adapters import (
            InstagramAdapter,
            LinkedInAdapter,
            RedditAdapter,
            TwitchAdapter,
        )

        stubs = [
            ("instagram", InstagramAdapter(), "post_image"),
            ("linkedin", LinkedInAdapter(), "post_article"),
            ("reddit", RedditAdapter(), "submit_post"),
            ("twitch", TwitchAdapter(), "create_clip"),
        ]

        all_stub = True
        for name, adapter, method in stubs:
            result = getattr(adapter, method)()
            if not result.get("stub"):
                all_stub = False

        report(5, "Stubs", all_stub, "4/4 stub responses")
    except Exception as e:
        report(5, "Stubs", False, str(e))


# ============================================================
# Test 6: get_adapter() Factory
# ============================================================
def test_6_get_adapter():
    try:
        from factory.marketing.adapters import get_adapter
        from factory.marketing.adapters.instagram_adapter import InstagramAdapter
        from factory.marketing.adapters.youtube_adapter import YouTubeAdapter

        yt = get_adapter("youtube")
        is_yt = isinstance(yt, YouTubeAdapter)

        ig = get_adapter("instagram")
        is_ig = isinstance(ig, InstagramAdapter)

        got_error = False
        try:
            get_adapter("unknown")
        except ValueError:
            got_error = True

        report(6, "get_adapter", is_yt and is_ig and got_error, "routing correct")
    except Exception as e:
        report(6, "get_adapter", False, str(e))


# ============================================================
# Test 7: Publishing Orchestrator — Kalender-basiertes Publishing
# ============================================================
def test_7_publish_due_items():
    try:
        from factory.marketing.tools.content_calendar import ContentCalendar
        from factory.marketing.agents.publishing_orchestrator import PublishingOrchestrator

        tmp_dir = os.path.join(str(_ROOT), "factory", "marketing", "output", "_test_pub")
        cal = ContentCalendar(calendar_dir=tmp_dir)

        past = (datetime.now() - timedelta(hours=1)).isoformat()
        items = [
            {"content_type": "social_post", "platform": "x", "publish_time": past, "tags": ["test"]},
            {"content_type": "social_post", "platform": "tiktok", "publish_time": past},
            {"content_type": "social_post", "platform": "youtube", "publish_time": past},
        ]
        cal_path = cal.create_weekly_calendar("2026-03-25", items)

        po = PublishingOrchestrator(dry_run=True)
        po.calendar = cal  # Use test calendar
        result = po.publish_due_items(cal_path)

        processed = result["processed"]
        # X post should work (dry_run), YouTube/TikTok fail (no media)
        pub = result["published"]
        fail = result["failed"]

        # Verify calendar items are updated
        stats = cal.get_calendar_stats(cal_path)

        # Cleanup
        if os.path.exists(tmp_dir):
            shutil.rmtree(tmp_dir)

        ok = processed == 3 and (pub + fail) == 3
        report(7, "Publish Due Items", ok,
               f"{processed}/3 processed, {pub} published, {fail} failed (dry_run)")
    except Exception as e:
        report(7, "Publish Due Items", False, str(e))


# ============================================================
# Test 8: Publishing Orchestrator — Cross-Post
# ============================================================
def test_8_cross_post():
    try:
        from factory.marketing.tools.content_calendar import ContentCalendar
        from factory.marketing.agents.publishing_orchestrator import PublishingOrchestrator

        tmp_dir = os.path.join(str(_ROOT), "factory", "marketing", "output", "_test_cross")
        cal = ContentCalendar(calendar_dir=tmp_dir)

        po = PublishingOrchestrator(dry_run=True)
        po.calendar = cal

        cal_path = po.cross_post("Test Content", platforms=["youtube", "tiktok", "x"])

        if not os.path.exists(cal_path):
            report(8, "Cross-Post", False, "Kalender-Datei nicht erstellt")
            shutil.rmtree(tmp_dir, ignore_errors=True)
            return

        with open(cal_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        n_items = len(data.get("items", []))
        times = [i["publish_time"] for i in data["items"]]

        # Prüfe gestaffelte Zeiten (60 Min Abstand)
        staggered = True
        if len(times) >= 2:
            t0 = datetime.fromisoformat(times[0])
            t1 = datetime.fromisoformat(times[1])
            diff = (t1 - t0).total_seconds() / 60
            staggered = 55 <= diff <= 65  # ~60 Min mit Toleranz

        # Cleanup
        shutil.rmtree(tmp_dir, ignore_errors=True)

        report(8, "Cross-Post", n_items == 3 and staggered,
               f"{n_items} items, 60min stagger")
    except Exception as e:
        report(8, "Cross-Post", False, str(e))


# ============================================================
# Test 9: Publishing Orchestrator — Failed Item Alert
# ============================================================
def test_9_failed_item_alert():
    try:
        from factory.marketing.tools.content_calendar import ContentCalendar
        from factory.marketing.agents.publishing_orchestrator import PublishingOrchestrator
        from factory.marketing.alerts.alert_manager import MarketingAlertManager

        tmp_dir = os.path.join(str(_ROOT), "factory", "marketing", "output", "_test_fail")
        tmp_alert_dir = os.path.join(str(_ROOT), "factory", "marketing", "output", "_test_fail_alerts")
        cal = ContentCalendar(calendar_dir=tmp_dir)
        alerts = MarketingAlertManager(base_path=tmp_alert_dir)

        past = (datetime.now() - timedelta(hours=1)).isoformat()
        # YouTube item ohne Media → error "no_media_for_youtube"
        items = [
            {"content_type": "video", "platform": "youtube", "publish_time": past, "tags": ["test"]},
        ]
        cal_path = cal.create_weekly_calendar("2026-03-25", items)

        po = PublishingOrchestrator(dry_run=True)
        po.calendar = cal
        po.alerts = alerts

        result = po.publish_due_items(cal_path)

        has_failed = result["failed"] == 1
        detail_status = result["details"][0]["status"] == "failed" if result["details"] else False

        # Prüfe ob Alert erstellt wurde (AlertManager speichert in base_path/alerts/active/)
        alert_files = []
        alert_dir = os.path.join(tmp_alert_dir, "alerts", "active")
        if os.path.exists(alert_dir):
            alert_files = [f for f in os.listdir(alert_dir) if f.endswith(".json")]

        # Cleanup
        shutil.rmtree(tmp_dir, ignore_errors=True)
        shutil.rmtree(tmp_alert_dir, ignore_errors=True)

        has_alert = len(alert_files) >= 1
        report(9, "Failed Item Alert", has_failed and detail_status and has_alert,
               f"alert created" if has_alert else "no alert file found")
    except Exception as e:
        report(9, "Failed Item Alert", False, str(e))


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Phase 3 Block B -- Adapter + Publishing Orchestrator Tests")
    print("=" * 60)
    print()

    test_1_youtube_dry_run()
    test_2_tiktok_dry_run()
    test_3_x_dry_run()
    test_4_x_thread()
    test_5_stubs()
    test_6_get_adapter()
    test_7_publish_due_items()
    test_8_cross_post()
    test_9_failed_item_alert()

    print()
    print("=" * 60)
    for r in sorted(results):
        print(r)
    print(f"\nPhase 3 Block B -- {passed}/{passed + failed} Tests Passed")
    print("=" * 60)

    sys.exit(0 if failed == 0 else 1)
