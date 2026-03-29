"""Phase 2 Integration-Test: EchoMatch Content-Paket.

Testet das Zusammenspiel aller 7 Marketing-Agents + Tools.

Aufruf: python -m factory.marketing.tests.test_phase_2_integration
"""

import glob
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", ".."))

from pathlib import Path
from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

passed = 0
failed = 0
total = 6

all_outputs: dict[str, list[str]] = {
    "texts": [],
    "graphics": [],
    "videos": [],
    "scripts": [],
}


def report(test_num: int, name: str, ok: bool, detail: str = "") -> None:
    global passed, failed
    if ok:
        passed += 1
        print(f"  \u2713 Test {test_num}: {name} — OK{' (' + detail + ')' if detail else ''}")
    else:
        failed += 1
        print(f"  \u2717 Test {test_num}: {name} — FAILED{' (' + detail + ')' if detail else ''}")


print("\n" + "=" * 60)
print("  Phase 2 Integration-Test: EchoMatch Content-Paket")
print("=" * 60 + "\n")


# --- Test 1: Strategy Outputs vorhanden ---
print("  Running Test 1: Strategy — Story Brief + Direktive vorhanden...")
try:
    from factory.marketing.config import BRAND_PATH

    brief_path = os.path.join(BRAND_PATH, "app_stories", "echomatch", "story_brief.md")
    directive_path = os.path.join(BRAND_PATH, "directives", "echomatch_directive.md")

    brief_ok = os.path.exists(brief_path) and os.path.getsize(brief_path) > 500
    dir_ok = os.path.exists(directive_path) and os.path.getsize(directive_path) > 500

    ok = brief_ok and dir_ok
    detail_parts = []
    if brief_ok:
        size = os.path.getsize(brief_path)
        detail_parts.append(f"Brief {size / 1024:.1f} KB")
        all_outputs["texts"].append(brief_path)
    if dir_ok:
        size = os.path.getsize(directive_path)
        detail_parts.append(f"Direktive {size / 1024:.1f} KB")
        all_outputs["texts"].append(directive_path)
    report(1, "Strategy Outputs", ok, " + ".join(detail_parts))
except Exception as e:
    report(1, "Strategy Outputs", False, str(e))


# --- Test 2: Copywriter Social Media Pack EN ---
print("  Running Test 2: Copywriter — Social Media Pack EN...")
try:
    from factory.marketing.agents.copywriter import Copywriter

    cw = Copywriter()
    result = cw.create_social_media_pack("echomatch", ["tiktok", "x"], "en")

    if result and os.path.exists(result):
        size = os.path.getsize(result)
        with open(result, "r", encoding="utf-8") as f:
            content = f.read()
        has_tiktok = "tiktok" in content.lower() or "TikTok" in content
        ok = size > 500 and has_tiktok
        all_outputs["texts"].append(result)
        report(2, "Copywriter Social Media EN", ok, f"{size / 1024:.1f} KB")
    else:
        report(2, "Copywriter Social Media EN", False, "no output")
except Exception as e:
    report(2, "Copywriter Social Media EN", False, str(e))


# --- Test 3: ASO Lokalisiertes Store Listing ---
print("  Running Test 3: ASO — Lokalisiertes Store Listing US...")
try:
    from factory.marketing.agents.aso_agent import ASOAgent

    aso = ASOAgent()
    result = aso.create_localized_listing("echomatch", "en", "US")

    if result and os.path.exists(result):
        size = os.path.getsize(result)
        ok = size > 200
        all_outputs["texts"].append(result)
        report(3, "ASO Localized Listing US", ok, f"{size / 1024:.1f} KB")
    else:
        report(3, "ASO Localized Listing US", False, "no output")
except Exception as e:
    report(3, "ASO Localized Listing US", False, str(e))


# --- Test 4: Visual Designer Ad Creative ---
print("  Running Test 4: Visual Designer — Ad Creative...")
try:
    from factory.marketing.agents.visual_designer import VisualDesigner

    vd = VisualDesigner()
    results = vd.create_ad_creatives("echomatch", ["meta_ad_feed"])

    if "meta_ad_feed" in results and len(results["meta_ad_feed"]) >= 1:
        all_exist = all(os.path.exists(p) for p in results["meta_ad_feed"])
        from PIL import Image

        for p in results["meta_ad_feed"]:
            img = Image.open(p)
            all_outputs["graphics"].append(p)
        ok = all_exist
        sizes = [f"{os.path.getsize(p):,}B" for p in results["meta_ad_feed"]]
        report(4, "Visual Designer Ad Creative", ok, f"{len(results['meta_ad_feed'])} PNGs, {', '.join(sizes)}")
    else:
        report(4, "Visual Designer Ad Creative", False, f"no meta_ad_feed: {results}")
except Exception as e:
    report(4, "Visual Designer Ad Creative", False, str(e))


# --- Test 5: Video Script BTS ---
print("  Running Test 5: Video Script — Behind the Scenes...")
try:
    from factory.marketing.agents.video_script_agent import VideoScriptAgent

    vs = VideoScriptAgent()
    script_path = vs.create_video_script("echomatch", "youtube_short", "behind_the_scenes")

    if script_path and os.path.exists(script_path):
        size = os.path.getsize(script_path)
        with open(script_path, "r", encoding="utf-8") as f:
            content = f.read()
        has_structure = any(kw in content.lower() for kw in ["hook", "szene", "scene", "cta"])
        ok = size > 300 and has_structure
        all_outputs["scripts"].append(script_path)
        report(5, "Video Script BTS", ok, f"{size / 1024:.1f} KB, structure={'yes' if has_structure else 'no'}")
    else:
        report(5, "Video Script BTS", False, "no output")
except Exception as e:
    report(5, "Video Script BTS", False, str(e))


# --- Test 6: Video from Script ---
print("  Running Test 6: Video from Script (MP4)...")
try:
    vs = VideoScriptAgent()
    # Script aus Test 5
    script_dir = os.path.join(vs.output_base, "echomatch", "scripts")
    script_path = os.path.join(script_dir, "video_youtube_short_behind_the_scenes.md")

    if not os.path.exists(script_path):
        script_path = vs.create_video_script("echomatch", "youtube_short", "behind_the_scenes")

    video_path = vs.create_video_from_script(script_path, "youtube_short")

    if video_path and os.path.exists(video_path):
        info = vs.video_pipeline.get_video_info(video_path)
        duration = info.get("duration", 0)
        w = info.get("width", 0)
        h = info.get("height", 0)
        size = os.path.getsize(video_path)
        ok = size > 1000 and duration > 0
        all_outputs["videos"].append(video_path)
        report(6, "Video from Script", ok, f"MP4, {duration:.1f}s, {w}x{h}, {size:,} bytes")
    else:
        report(6, "Video from Script", False, "no output")
except Exception as e:
    report(6, "Video from Script", False, str(e))


# --- Content-Paket Zusammenfassung ---
print()
print("=" * 60)
print("  Content-Paket Zusammenfassung:")
print("=" * 60)

for category, paths in all_outputs.items():
    if paths:
        print(f"\n  {category.title()} ({len(paths)}):")
        for p in paths:
            size = os.path.getsize(p) if os.path.exists(p) else 0
            rel = os.path.relpath(p, os.path.join(os.path.dirname(__file__), "..", ".."))
            print(f"    - {rel} ({size:,} bytes)")

# Zaehle ALLE Dateien in output/ rekursiv
from factory.marketing.config import OUTPUT_PATH, BRAND_PATH

print(f"\n  --- Gesamtuebersicht output/ ---")
total_files = 0
total_size = 0
by_ext: dict[str, int] = {}

for root, dirs, files in os.walk(OUTPUT_PATH):
    for f in files:
        fpath = os.path.join(root, f)
        fsize = os.path.getsize(fpath)
        total_files += 1
        total_size += fsize
        ext = os.path.splitext(f)[1].lower()
        by_ext[ext] = by_ext.get(ext, 0) + 1

print(f"  Dateien in output/: {total_files}")
print(f"  Gesamtgroesse: {total_size / 1024:.1f} KB")
for ext, count in sorted(by_ext.items()):
    print(f"    {ext or '(none)'}: {count}")

# brand/ Dateien
print(f"\n  --- Gesamtuebersicht brand/ ---")
brand_files = 0
brand_size = 0
for root, dirs, files in os.walk(BRAND_PATH):
    for f in files:
        fpath = os.path.join(root, f)
        brand_files += 1
        brand_size += os.path.getsize(fpath)

print(f"  Dateien in brand/: {brand_files}")
print(f"  Gesamtgroesse: {brand_size / 1024:.1f} KB")

# --- Summary ---
print()
print("=" * 60)
if failed == 0:
    print(f"  \u2713 Phase 2 Integration — {passed}/{total} Tests Passed")
else:
    print(f"  {passed}/{total} Tests Passed, {failed} Failed")
print("=" * 60)
