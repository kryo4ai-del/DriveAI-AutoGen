"""Phase 2 Visual/Video Agents Funktionstest.

Testet Visual Designer (MKT-06) und Video Script (MKT-07) mit echten LLM-Calls.

Aufruf: python -m factory.marketing.tests.test_phase_2_visual_video
"""

import os
import sys

# Fix Windows cp1252 encoding for Unicode output
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", ".."))

from pathlib import Path
from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

passed = 0
failed = 0
total = 5


def report(test_num: int, name: str, ok: bool, detail: str = "") -> None:
    global passed, failed
    if ok:
        passed += 1
        print(f"  \u2713 Test {test_num}: {name} — OK{' (' + detail + ')' if detail else ''}")
    else:
        failed += 1
        print(f"  \u2717 Test {test_num}: {name} — FAILED{' (' + detail + ')' if detail else ''}")


print("\n" + "=" * 60)
print("  Phase 2 Visual/Video — Funktionstest")
print("=" * 60 + "\n")


# --- Test 1: Visual Designer — Social Media Grafiken ---
print("  Running Test 1: Visual Designer — Social Media Grafiken...")
try:
    from factory.marketing.agents.visual_designer import VisualDesigner

    vd = VisualDesigner()
    results = vd.create_social_media_graphics("echomatch", ["x"])

    if "x" in results and len(results["x"]) >= 1:
        all_exist = all(os.path.exists(p) for p in results["x"])
        # Validate images with Pillow
        from PIL import Image

        sizes = []
        for p in results["x"]:
            img = Image.open(p)
            sizes.append(f"{img.size[0]}x{img.size[1]}")
        ok = all_exist and len(results["x"]) >= 1
        file_sizes = [f"{os.path.getsize(p):,}B" for p in results["x"]]
        report(1, "Social Media Grafiken", ok, f"{len(results['x'])} PNGs, sizes: {', '.join(sizes)}, {', '.join(file_sizes)}")
    else:
        report(1, "Social Media Grafiken", False, f"no x results: {results}")
except Exception as e:
    report(1, "Social Media Grafiken", False, str(e))


# --- Test 2: Visual Designer — YouTube Thumbnail ---
print("  Running Test 2: Visual Designer — YouTube Thumbnail...")
try:
    vd = VisualDesigner()
    path = vd.create_youtube_thumbnail("echomatch")

    if path and os.path.exists(path):
        img = Image.open(path)
        w, h = img.size
        size = os.path.getsize(path)
        ok = w == 1280 and h == 720 and size > 1000
        report(2, "YouTube Thumbnail", ok, f"{w}x{h}, {size:,} bytes")
    else:
        report(2, "YouTube Thumbnail", False, "no output file")
except Exception as e:
    report(2, "YouTube Thumbnail", False, str(e))


# --- Test 3: Video Script — TikTok Showcase ---
print("  Running Test 3: Video Script — TikTok Showcase...")
try:
    from factory.marketing.agents.video_script_agent import VideoScriptAgent

    vs = VideoScriptAgent()
    path = vs.create_video_script("echomatch", "tiktok", "showcase")

    if path and os.path.exists(path):
        size = os.path.getsize(path)
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        has_structure = any(
            kw in content.lower()
            for kw in ["hook", "szene", "scene", "cta"]
        )
        ok = size > 500 and has_structure
        report(3, "Video Script TikTok", ok, f"{size:,} bytes, structure={'yes' if has_structure else 'no'}")
    else:
        report(3, "Video Script TikTok", False, "no output file")
except Exception as e:
    report(3, "Video Script TikTok", False, str(e))


# --- Test 4: Video Script — Daily Factory Content ---
print("  Running Test 4: Video Script — Daily Factory Content...")
try:
    vs = VideoScriptAgent()
    path = vs.create_daily_factory_content("Die Factory hat heute 7 Marketing-Agents")

    if path and os.path.exists(path):
        size = os.path.getsize(path)
        ok = size > 100
        report(4, "Daily Factory Content", ok, f"{size:,} bytes")
    else:
        report(4, "Daily Factory Content", False, "no output file")
except Exception as e:
    report(4, "Daily Factory Content", False, str(e))


# --- Test 5: Video Script — Video aus Skript erstellen ---
print("  Running Test 5: Video from Script (MP4)...")
try:
    vs = VideoScriptAgent()
    # Verwende das Skript aus Test 3
    script_dir = os.path.join(
        vs.output_base, "echomatch", "scripts"
    )
    script_path = os.path.join(script_dir, "video_tiktok_showcase.md")

    if not os.path.exists(script_path):
        # Fallback: erstelle ein neues Skript
        script_path = vs.create_video_script("echomatch", "tiktok", "showcase")

    video_path = vs.create_video_from_script(script_path, "tiktok")

    if video_path and os.path.exists(video_path):
        size = os.path.getsize(video_path)
        # Video-Info pruefen
        info = vs.video_pipeline.get_video_info(video_path)
        duration = info.get("duration", 0)
        w = info.get("width", 0)
        h = info.get("height", 0)
        ok = size > 1000 and duration > 0
        report(5, "Video from Script", ok, f"MP4, {duration:.1f}s, {w}x{h}, {size:,} bytes")
    else:
        report(5, "Video from Script", False, "no output file")
except Exception as e:
    report(5, "Video from Script", False, str(e))


# --- Summary ---
print()
print("=" * 60)
if failed == 0:
    print(f"  \u2713 Phase 2 Visual/Video — {passed}/{total} Tests Passed")
else:
    print(f"  {passed}/{total} Tests Passed, {failed} Failed")
print("=" * 60)
