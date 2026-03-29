"""Phase 3 Block A Tests — expected_output_tokens, Brand Guardian, Content Calendar.

Tests 1-4: LLM-Calls (API-Kosten!)
Tests 5-8: Deterministisch (kein LLM)

Usage: python -m factory.marketing.tests.test_phase_3_block_a
"""

import json
import logging
import os
import shutil
import sys
from datetime import datetime, timedelta
from pathlib import Path

# Setup path
_ROOT = Path(__file__).parent.parent.parent.parent
sys.path.insert(0, str(_ROOT))

logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s")
logger = logging.getLogger("test_phase_3a")

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
# Test 1: Copywriter Store Listing (LLM)
# ============================================================
def test_1_store_listing():
    try:
        from factory.marketing.agents.copywriter import Copywriter
        cw = Copywriter()
        result = cw.create_store_listing("echomatch", store="ios", language="de")

        if not result:
            report(1, "Copywriter Store Listing", False, "Leeres Ergebnis")
            return

        # Pruefe ob mindestens ein Store-Listing existiert
        for store, path in result.items():
            if not os.path.exists(path):
                report(1, "Copywriter Store Listing", False, f"Datei nicht gefunden: {path}")
                return
            size = os.path.getsize(path)
            if size < 500:
                report(1, "Copywriter Store Listing", False, f"Datei zu klein: {size} bytes")
                return
            report(1, "Copywriter Store Listing", True, f"nicht-leer ({size} bytes)")
            return

        report(1, "Copywriter Store Listing", False, "Kein Store-Ergebnis")
    except Exception as e:
        report(1, "Copywriter Store Listing", False, str(e))


# ============================================================
# Test 2: Brand Book (LLM)
# ============================================================
def test_2_brand_book():
    try:
        from factory.marketing.agents.brand_guardian import BrandGuardian
        bg = BrandGuardian()
        md_path = bg.create_brand_book()

        if not md_path or not os.path.exists(md_path):
            report(2, "Brand Book", False, "MD-Datei nicht erstellt")
            return

        md_size = os.path.getsize(md_path)
        json_path = md_path.replace("brand_book.md", "brand_book.json")

        if not os.path.exists(json_path):
            report(2, "Brand Book", False, "JSON-Datei nicht erstellt")
            return

        json_size = os.path.getsize(json_path)
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        has_colors = "colors" in data
        has_fonts = "fonts" in data
        has_tone = "tone" in data
        n_colors = len(data.get("colors", {}))

        if not has_colors or not has_fonts or not has_tone:
            missing = [k for k, v in [("colors", has_colors), ("fonts", has_fonts), ("tone", has_tone)] if not v]
            report(2, "Brand Book", False, f"JSON fehlt: {', '.join(missing)}")
            return

        report(2, "Brand Book", True,
               f"MD ({md_size // 1024} KB) + JSON ({json_size // 1024} KB, {n_colors} Farben)")
    except Exception as e:
        report(2, "Brand Book", False, str(e))


# ============================================================
# Test 3: App Style Sheet (LLM)
# ============================================================
def test_3_app_style_sheet():
    try:
        from factory.marketing.agents.brand_guardian import BrandGuardian
        bg = BrandGuardian()
        path = bg.create_app_style_sheet("echomatch")

        if not path or not os.path.exists(path):
            report(3, "App Style Sheet", False, "Datei nicht erstellt")
            return

        size = os.path.getsize(path)
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)

        has_colors = "colors" in data
        has_slug = data.get("project_slug") == "echomatch"

        if not has_colors or not has_slug:
            report(3, "App Style Sheet", False, f"JSON unvollstaendig (colors={has_colors}, slug={has_slug})")
            return

        report(3, "App Style Sheet", True, f"echomatch_style.json ({size} bytes)")
    except Exception as e:
        report(3, "App Style Sheet", False, str(e))


# ============================================================
# Test 4: Compliance Check (LLM)
# ============================================================
def test_4_compliance_check():
    try:
        from factory.marketing.agents.brand_guardian import BrandGuardian
        bg = BrandGuardian()

        # Finde einen bestehenden Copywriter-Output oder verwende Test-Content
        test_content = (
            "Die DriveAI Factory hat EchoMatch erschaffen — eine Sound-Matching App "
            "die zeigt was unsere KI-Architektur kann. Kein menschlicher Entwickler, "
            "nur die Factory und ihre Agents. Download jetzt im App Store!"
        )

        result = bg.check_brand_compliance(test_content, "social_post")

        if not isinstance(result, dict):
            report(4, "Compliance Check", False, f"Kein dict: {type(result)}")
            return

        score = result.get("score", -1)
        issues = result.get("issues", [])
        suggestions = result.get("suggestions", [])
        has_keys = all(k in result for k in ["score", "issues", "suggestions", "compliant"])

        if not has_keys:
            report(4, "Compliance Check", False, f"Fehlende Keys: {list(result.keys())}")
            return

        if score <= 0:
            report(4, "Compliance Check", False, f"Score = {score}")
            return

        report(4, "Compliance Check", True,
               f"Score: {score}/100, {len(issues)} Issues")
    except Exception as e:
        report(4, "Compliance Check", False, str(e))


# ============================================================
# Test 5: Template-Engine Brand Colors (deterministisch)
# ============================================================
def test_5_template_brand_colors():
    try:
        from factory.marketing.tools.template_engine import MarketingTemplateEngine

        # Capture log output
        import io
        handler = logging.StreamHandler(io.StringIO())
        handler.setLevel(logging.INFO)
        te_logger = logging.getLogger("factory.marketing.tools.template_engine")
        te_logger.addHandler(handler)

        tmp_dir = os.path.join(str(_ROOT), "factory", "marketing", "output", "_test_templates")
        engine = MarketingTemplateEngine(output_dir=tmp_dir)

        log_output = handler.stream.getvalue()
        has_brand = "brand_book.json" in log_output
        source = "brand_book.json" if has_brand else "defaults"

        # Erstelle ein Test-Bild
        path = engine.text_on_background("Test Brand Colors", "social_square",
                                          filename="test_brand_colors.png")
        exists = os.path.exists(path)

        te_logger.removeHandler(handler)

        # Cleanup
        if os.path.exists(tmp_dir):
            shutil.rmtree(tmp_dir)

        report(5, "Template-Engine Brand Colors", exists,
               f"Loaded from {source}")
    except Exception as e:
        report(5, "Template-Engine Brand Colors", False, str(e))


# ============================================================
# Test 6: Content-Kalender Wochenplan (deterministisch)
# ============================================================
def test_6_weekly_calendar():
    try:
        from factory.marketing.tools.content_calendar import ContentCalendar

        tmp_dir = os.path.join(str(_ROOT), "factory", "marketing", "output", "_test_calendar")
        cal = ContentCalendar(calendar_dir=tmp_dir)

        items = [
            {"content_type": "social_post", "platform": "x",
             "publish_time": "2026-04-01T10:00:00", "tags": ["test"]},
            {"content_type": "video", "platform": "youtube",
             "publish_time": "2026-04-01T14:00:00"},
            {"content_type": "social_post", "platform": "instagram",
             "publish_time": "2026-04-02T10:00:00"},
            {"content_type": "blog", "platform": "x",
             "publish_time": "2026-04-03T12:00:00"},
            {"content_type": "social_post", "platform": "tiktok",
             "publish_time": "2026-04-04T10:00:00"},
        ]

        path = cal.create_weekly_calendar("2026-04-01", items)
        if not os.path.exists(path):
            report(6, "Wochenplan", False, "Datei nicht erstellt")
            return

        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)

        n_items = len(data.get("items", []))
        all_scheduled = all(i["status"] == "scheduled" for i in data["items"])

        # Cleanup
        shutil.rmtree(tmp_dir)

        if n_items != 5:
            report(6, "Wochenplan", False, f"{n_items} Items statt 5")
            return

        report(6, "Wochenplan", all_scheduled,
               f"{n_items} Items, alle scheduled" if all_scheduled else "Nicht alle scheduled")
    except Exception as e:
        report(6, "Wochenplan", False, str(e))


# ============================================================
# Test 7: Launch-Kampagne (deterministisch)
# ============================================================
def test_7_launch_campaign():
    try:
        from factory.marketing.tools.content_calendar import ContentCalendar

        tmp_dir = os.path.join(str(_ROOT), "factory", "marketing", "output", "_test_campaign")
        cal = ContentCalendar(calendar_dir=tmp_dir)

        path = cal.create_launch_campaign("echomatch", "2026-05-01", ["youtube", "tiktok", "x"])
        if not os.path.exists(path):
            report(7, "Launch-Kampagne", False, "Datei nicht erstellt")
            return

        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)

        n_items = len(data.get("items", []))
        # Mindestens 8 Items (8 Zeitpunkte, einige auf mehreren Plattformen)
        if n_items < 8:
            report(7, "Launch-Kampagne", False, f"Nur {n_items} Items (min 8)")
            shutil.rmtree(tmp_dir)
            return

        # Chronologisch sortiert?
        times = [i["publish_time"] for i in data["items"]]
        is_sorted = times == sorted(times)

        # Date range
        first = times[0][:10] if times else "?"
        last = times[-1][:10] if times else "?"

        # Cleanup
        shutil.rmtree(tmp_dir)

        report(7, "Launch-Kampagne", is_sorted,
               f"{n_items} Items ueber {first} bis {last}")
    except Exception as e:
        report(7, "Launch-Kampagne", False, str(e))


# ============================================================
# Test 8: Kalender Lifecycle (deterministisch)
# ============================================================
def test_8_calendar_lifecycle():
    try:
        from factory.marketing.tools.content_calendar import ContentCalendar

        tmp_dir = os.path.join(str(_ROOT), "factory", "marketing", "output", "_test_lifecycle")
        cal = ContentCalendar(calendar_dir=tmp_dir)

        # Erstelle Kalender mit Items in der Vergangenheit
        past = (datetime.now() - timedelta(hours=2)).isoformat()
        future = (datetime.now() + timedelta(days=1)).isoformat()

        items = [
            {"content_type": "social_post", "platform": "x", "publish_time": past},
            {"content_type": "video", "platform": "youtube", "publish_time": past},
            {"content_type": "social_post", "platform": "tiktok", "publish_time": future},
        ]
        path = cal.create_weekly_calendar("2026-03-25", items)

        # get_due_items findet Vergangenheits-Items
        due = cal.get_due_items(path)
        if len(due) != 2:
            report(8, "Kalender Lifecycle", False, f"due={len(due)} statt 2")
            shutil.rmtree(tmp_dir)
            return

        # mark_published
        pub_ok = cal.mark_published(path, due[0]["item_id"],
                                     metadata={"post_id": "123", "url": "https://x.com/123"})
        if not pub_ok:
            report(8, "Kalender Lifecycle", False, "mark_published fehlgeschlagen")
            shutil.rmtree(tmp_dir)
            return

        # mark_failed
        fail_ok = cal.mark_failed(path, due[1]["item_id"], "API timeout")
        if not fail_ok:
            report(8, "Kalender Lifecycle", False, "mark_failed fehlgeschlagen")
            shutil.rmtree(tmp_dir)
            return

        # Stats
        stats = cal.get_calendar_stats(path)
        ok = (
            stats["total"] == 3
            and stats["published"] == 1
            and stats["failed"] == 1
            and stats["scheduled"] == 1
        )

        # Cleanup
        shutil.rmtree(tmp_dir)

        report(8, "Kalender Lifecycle", ok,
               f"due/published/failed/stats OK" if ok
               else f"Stats falsch: {stats}")
    except Exception as e:
        report(8, "Kalender Lifecycle", False, str(e))


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Phase 3 Block A — Tests")
    print("=" * 60)
    print()

    # Deterministisch zuerst (kein API-Kosten-Risiko)
    print("--- Deterministische Tests (5-8) ---")
    test_5_template_brand_colors()
    test_6_weekly_calendar()
    test_7_launch_campaign()
    test_8_calendar_lifecycle()

    print()
    print("--- LLM Tests (1-4) — API-Kosten! ---")
    test_1_store_listing()
    test_2_brand_book()
    test_3_app_style_sheet()
    test_4_compliance_check()

    print()
    print("=" * 60)
    for r in sorted(results):
        print(r)
    print(f"\nPhase 3 Block A — {passed}/{passed + failed} Tests Passed")
    print("=" * 60)

    sys.exit(0 if failed == 0 else 1)
