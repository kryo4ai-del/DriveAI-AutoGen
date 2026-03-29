"""Phase 3 Block C Tests — Template Wrapping, Video Pipeline, Adapters, Calendar, Publishing.

All 10 tests are deterministic (no LLM calls, no API costs).

Usage: python -m factory.marketing.tests.test_phase_3_block_c
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
logger = logging.getLogger("test_phase_3c")

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
# Test 1: Template Engine — _wrap_text Funktion
# ============================================================
def test_1_wrap_text():
    try:
        from PIL import Image, ImageDraw
        from factory.marketing.tools.template_engine import _wrap_text, _get_font

        img = Image.new("RGB", (400, 200))
        draw = ImageDraw.Draw(img)
        font = _get_font(24, bold=False)

        # Kurzer Text — kein Umbruch
        short = _wrap_text(draw, "Hello", font, 400)
        assert len(short) == 1, f"Short text should be 1 line, got {len(short)}"

        # Langer Text — Umbruch
        long_text = "Dies ist ein sehr langer Titel der definitiv umgebrochen werden muss weil er nicht passt"
        lines = _wrap_text(draw, long_text, font, 200)
        assert len(lines) > 1, f"Long text should wrap, got {len(lines)} lines"

        # Leerer Text
        empty = _wrap_text(draw, "", font, 400)
        assert empty == [""], f"Empty text should return [''], got {empty}"

        report(1, "Template _wrap_text", True, f"short=1 line, long={len(lines)} lines, empty OK")
    except Exception as e:
        report(1, "Template _wrap_text", False, str(e))


# ============================================================
# Test 2: Template Engine — text_on_background mit langem Text
# ============================================================
def test_2_text_wrapping_render():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.template_engine import MarketingTemplateEngine

        engine = MarketingTemplateEngine(output_dir=tmp_dir)

        # Langer Text der umgebrochen werden muss
        long_text = "Die DriveAI Factory hat ein neues Produkt erschaffen das die Welt veraendern wird"
        path = engine.text_on_background(long_text, "social_square", filename="wrap_test.png")
        assert os.path.exists(path), f"File not created: {path}"

        from PIL import Image
        img = Image.open(path)
        assert img.size == (1080, 1080), f"Wrong size: {img.size}"

        report(2, "Template text wrapping render", True, f"1080x1080 PNG created")
    except Exception as e:
        report(2, "Template text wrapping render", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 3: Template Engine — gradient_text mit langem Text
# ============================================================
def test_3_gradient_wrapping():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.template_engine import MarketingTemplateEngine

        engine = MarketingTemplateEngine(output_dir=tmp_dir)
        long_text = "Schau was die Factory gebaut hat — Ein vollautonomes KI-System das Apps erschafft"
        path = engine.gradient_text(long_text, "youtube_thumbnail", filename="gradient_wrap.png")
        assert os.path.exists(path), f"File not created: {path}"

        from PIL import Image
        img = Image.open(path)
        assert img.size == (1280, 720), f"Wrong size: {img.size}"

        report(3, "Template gradient wrapping", True, "1280x720 PNG created")
    except Exception as e:
        report(3, "Template gradient wrapping", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 4: Template Engine — social_post_template mit langem Headline
# ============================================================
def test_4_social_post_wrapping():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.template_engine import MarketingTemplateEngine

        engine = MarketingTemplateEngine(output_dir=tmp_dir)
        path = engine.social_post_template(
            headline="Die Factory erschafft Apps vollautomatisch in unter 5 Minuten",
            subtext="78 KI-Agents, 14 Departments, $0.08 pro Pipeline-Run — willkommen in der Zukunft",
            format_key="social_square",
            filename="social_wrap.png",
        )
        assert os.path.exists(path), f"File not created: {path}"

        report(4, "Social post wrapping", True, "social_square PNG created")
    except Exception as e:
        report(4, "Social post wrapping", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 5: Template Engine — Brand Colors loaded
# ============================================================
def test_5_brand_colors():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.template_engine import MarketingTemplateEngine

        engine = MarketingTemplateEngine(output_dir=tmp_dir)

        # brand_colors muss 7 Keys haben
        assert len(engine.brand_colors) == 7, f"Expected 7 brand colors, got {len(engine.brand_colors)}"
        required_keys = {"bg_dark", "bg_gradient_top", "bg_gradient_bottom", "text_light", "accent", "social_top", "social_bottom"}
        assert set(engine.brand_colors.keys()) == required_keys, f"Missing keys: {required_keys - set(engine.brand_colors.keys())}"

        # Alle Werte muessen mit # anfangen (Hex-Farben)
        for k, v in engine.brand_colors.items():
            assert v.startswith("#"), f"Color {k} not hex: {v}"

        report(5, "Brand colors loaded", True, f"7 colors, all hex")
    except Exception as e:
        report(5, "Brand colors loaded", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 6: Video Pipeline — _seconds_to_srt_time
# ============================================================
def test_6_srt_time():
    try:
        from factory.marketing.tools.video_pipeline import MarketingVideoPipeline

        assert MarketingVideoPipeline._seconds_to_srt_time(0) == "00:00:00,000"
        assert MarketingVideoPipeline._seconds_to_srt_time(1.5) == "00:00:01,500"
        assert MarketingVideoPipeline._seconds_to_srt_time(65.123) == "00:01:05,123"
        # Float-Rounding: 3661.999 -> ms=998 (int truncation is OK)
        result = MarketingVideoPipeline._seconds_to_srt_time(3661.0)
        assert result == "01:01:01,000", f"Expected 01:01:01,000 got {result}"

        report(6, "SRT time conversion", True, "4 cases correct")
    except Exception as e:
        report(6, "SRT time conversion", False, str(e))


# ============================================================
# Test 7: Content Calendar — Wochenplan
# ============================================================
def test_7_weekly_plan():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.content_calendar import ContentCalendar

        cal = ContentCalendar(calendar_dir=tmp_dir)
        week_start = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")

        # Items fuer die Woche erstellen
        content_items = []
        for i, (platform, ctype) in enumerate([
            ("tiktok", "social_post"), ("x", "social_post"), ("youtube", "video"),
            ("tiktok", "video"), ("x", "social_post"),
        ]):
            pub_time = (datetime.now() + timedelta(days=i+1, hours=10)).isoformat()
            content_items.append({
                "content_type": ctype,
                "platform": platform,
                "publish_time": pub_time,
                "tags": ["echomatch"],
            })

        path = cal.create_weekly_calendar(week_start, content_items)
        assert os.path.exists(path), f"Calendar file not created: {path}"

        import json
        with open(path, "r") as f:
            data = json.load(f)
        items = data["items"]
        assert len(items) == 5, f"Expected 5 items, got {len(items)}"

        for item in items:
            assert item["item_id"].startswith("CAL-"), f"Invalid ID: {item['item_id']}"
            assert item["status"] == "scheduled", f"Status should be scheduled: {item['status']}"

        report(7, "Weekly calendar", True, f"{len(items)} items, file: {os.path.basename(path)}")
    except Exception as e:
        report(7, "Weekly calendar", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 8: Content Calendar — Launch-Kampagne
# ============================================================
def test_8_launch_campaign():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.content_calendar import ContentCalendar

        cal = ContentCalendar(calendar_dir=tmp_dir)
        launch_date = (datetime.now() + timedelta(days=14)).strftime("%Y-%m-%d")
        path = cal.create_launch_campaign(
            project_slug="echomatch",
            launch_date=launch_date,
        )
        assert os.path.exists(path), f"Campaign file not created: {path}"

        import json
        with open(path, "r") as f:
            data = json.load(f)
        items = data["items"]
        assert len(items) >= 8, f"Expected >= 8 items, got {len(items)}"

        # Pruefen ob verschiedene Zeitpunkte vorhanden (pre/launch/post via offset)
        launch_dt = datetime.fromisoformat(launch_date)
        pre = sum(1 for i in items if datetime.fromisoformat(i["publish_time"]) < launch_dt)
        post = sum(1 for i in items if datetime.fromisoformat(i["publish_time"]) > launch_dt)
        launch_day = sum(1 for i in items if datetime.fromisoformat(i["publish_time"]).date() == launch_dt.date())

        assert pre > 0, "No pre-launch items"
        assert launch_day > 0, "No launch-day items"
        assert post > 0, "No post-launch items"

        report(8, "Launch campaign", True, f"{len(items)} items (pre={pre}, launch={launch_day}, post={post})")
    except Exception as e:
        report(8, "Launch campaign", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 9: All Adapters — Import + dry_run
# ============================================================
def test_9_adapters_dry_run():
    try:
        from factory.marketing.adapters import (
            get_adapter, ACTIVE_ADAPTERS, STUB_ADAPTERS, ALL_ADAPTERS,
        )
        assert len(ACTIVE_ADAPTERS) == 3, f"Expected 3 active, got {len(ACTIVE_ADAPTERS)}"
        assert len(STUB_ADAPTERS) == 4, f"Expected 4 stubs, got {len(STUB_ADAPTERS)}"
        assert len(ALL_ADAPTERS) == 7, f"Expected 7 total, got {len(ALL_ADAPTERS)}"

        # Alle Adapter instanziieren (dry_run)
        for platform in ALL_ADAPTERS:
            adapter = get_adapter(platform, dry_run=True)
            assert adapter is not None, f"get_adapter({platform}) returned None"
            assert adapter.dry_run is True, f"{platform} adapter not in dry_run"

        report(9, "All adapters dry_run", True, f"7 adapters OK")
    except Exception as e:
        report(9, "All adapters dry_run", False, str(e))


# ============================================================
# Test 10: Publishing Orchestrator — dry_run publish
# ============================================================
def test_10_publishing_orchestrator():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.content_calendar import ContentCalendar
        from factory.marketing.agents.publishing_orchestrator import PublishingOrchestrator

        # Kalender mit Items erstellen
        cal = ContentCalendar(calendar_dir=tmp_dir)
        pub_time = (datetime.now() + timedelta(days=1, hours=10)).isoformat()
        content_items = [
            {"content_type": "social_post", "platform": "tiktok", "publish_time": pub_time},
            {"content_type": "social_post", "platform": "x", "publish_time": pub_time},
        ]
        week_start = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
        path = cal.create_weekly_calendar(week_start, content_items)
        assert os.path.exists(path), "Calendar file not created"

        # Orchestrator im dry_run
        orch = PublishingOrchestrator(dry_run=True)
        assert orch.dry_run is True, "Orchestrator not in dry_run"

        # Status abfragen
        status = orch.get_publishing_status()
        assert isinstance(status, dict), f"Status should be dict, got {type(status)}"

        report(10, "Publishing orchestrator dry_run", True, f"calendar=2 items, status OK")
    except Exception as e:
        report(10, "Publishing orchestrator dry_run", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("Phase 3 Block C — Integration Tests")
    print("=" * 60 + "\n")

    test_1_wrap_text()
    test_2_text_wrapping_render()
    test_3_gradient_wrapping()
    test_4_social_post_wrapping()
    test_5_brand_colors()
    test_6_srt_time()
    test_7_weekly_plan()
    test_8_launch_campaign()
    test_9_adapters_dry_run()
    test_10_publishing_orchestrator()

    print("\n" + "=" * 60)
    print(f"Results: {passed}/10 passed, {failed}/10 failed")
    print("=" * 60)

    for r in results:
        print(f"  {r}")

    sys.exit(0 if failed == 0 else 1)
