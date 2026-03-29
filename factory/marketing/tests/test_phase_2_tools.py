"""Phase 2 Tools Funktionstest.

Testet Template Engine (Pillow) und Video Pipeline (FFmpeg).

Aufruf: python -m factory.marketing.tests.test_phase_2_tools
"""

import os
import shutil
import sys
import tempfile

# Fix Windows cp1252 encoding for Unicode output
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", ".."))

passed = 0
failed = 0
total = 8

# Temp-Verzeichnis fuer Test-Output
test_dir = tempfile.mkdtemp(prefix="mkt_tools_test_")


def report(test_num: int, name: str, ok: bool, detail: str = "") -> None:
    global passed, failed
    if ok:
        passed += 1
        print(f"  \u2713 Test {test_num}: {name} — OK{' (' + detail + ')' if detail else ''}")
    else:
        failed += 1
        print(f"  \u2717 Test {test_num}: {name} — FAILED{' (' + detail + ')' if detail else ''}")


print("\n" + "=" * 60)
print("  Phase 2 Tools — Template Engine + Video Pipeline")
print("=" * 60 + "\n")


# =========================================================
# TEMPLATE ENGINE TESTS (1-4)
# =========================================================

# --- Test 1: text_on_background ---
print("  Running Test 1: Template — text_on_background...")
try:
    from factory.marketing.tools.template_engine import MarketingTemplateEngine

    te = MarketingTemplateEngine(output_dir=os.path.join(test_dir, "templates"))
    path = te.text_on_background(
        "EchoMatch",
        "social_square",
        bg_color="#1a1a2e",
        text_color="#ffffff",
        filename="test_text_bg.png",
    )
    exists = os.path.exists(path)
    size = os.path.getsize(path) if exists else 0

    # Verify it's a valid PNG
    from PIL import Image
    img = Image.open(path)
    w, h = img.size
    ok = exists and size > 1000 and w == 1080 and h == 1080
    report(1, "text_on_background (1080x1080)", ok, f"{size:,} bytes, {w}x{h}")
except Exception as e:
    report(1, "text_on_background", False, str(e))


# --- Test 2: gradient_text ---
print("  Running Test 2: Template — gradient_text...")
try:
    te = MarketingTemplateEngine(output_dir=os.path.join(test_dir, "templates"))
    path = te.gradient_text(
        "DriveAI Factory",
        "youtube_thumbnail",
        color_top="#0f0c29",
        color_bottom="#302b63",
        filename="test_gradient.png",
    )
    exists = os.path.exists(path)
    size = os.path.getsize(path) if exists else 0

    img = Image.open(path)
    w, h = img.size
    ok = exists and size > 1000 and w == 1280 and h == 720
    report(2, "gradient_text (1280x720)", ok, f"{size:,} bytes, {w}x{h}")
except Exception as e:
    report(2, "gradient_text", False, str(e))


# --- Test 3: social_post_template ---
print("  Running Test 3: Template — social_post_template...")
try:
    te = MarketingTemplateEngine(output_dir=os.path.join(test_dir, "templates"))
    path = te.social_post_template(
        "Jetzt verfuegbar!",
        "EchoMatch — Das Sound-Puzzle-Game",
        format_key="social_story",
        filename="test_social.png",
    )
    exists = os.path.exists(path)
    size = os.path.getsize(path) if exists else 0

    img = Image.open(path)
    w, h = img.size
    ok = exists and size > 1000 and w == 1080 and h == 1920
    report(3, "social_post_template (1080x1920)", ok, f"{size:,} bytes, {w}x{h}")
except Exception as e:
    report(3, "social_post_template", False, str(e))


# --- Test 4: batch_create ---
print("  Running Test 4: Template — batch_create (3 Formate)...")
try:
    te = MarketingTemplateEngine(output_dir=os.path.join(test_dir, "templates"))
    results = te.batch_create(
        "EchoMatch Launch",
        ["social_square", "twitter_header", "og_image"],
        style="gradient",
    )
    all_exist = all(os.path.exists(p) for p in results.values())
    ok = len(results) == 3 and all_exist
    sizes = [f"{os.path.getsize(p):,}" for p in results.values()]
    report(4, "batch_create (3 formats)", ok, f"files: {len(results)}, sizes: {', '.join(sizes)}")
except Exception as e:
    report(4, "batch_create", False, str(e))


# =========================================================
# VIDEO PIPELINE TESTS (5-8)
# =========================================================

# Erstelle Test-Bilder fuer Video-Tests
test_img_dir = os.path.join(test_dir, "test_images")
os.makedirs(test_img_dir, exist_ok=True)

try:
    from PIL import Image as PILImage

    for i, color in enumerate([(255, 50, 50), (50, 255, 50), (50, 50, 255)]):
        img = PILImage.new("RGB", (1920, 1080), color)
        img.save(os.path.join(test_img_dir, f"slide_{i}.png"))
    print("  (Created 3 test images for video tests)")
except Exception as e:
    print(f"  WARNING: Could not create test images: {e}")


# --- Test 5: create_simple_clip ---
print("  Running Test 5: Video — create_simple_clip...")
try:
    from factory.marketing.tools.video_pipeline import MarketingVideoPipeline

    vp = MarketingVideoPipeline(output_dir=os.path.join(test_dir, "videos"))
    path = vp.create_simple_clip(
        os.path.join(test_img_dir, "slide_0.png"),
        duration=2.0,
        format_key="landscape",
        filename="test_clip.mp4",
    )
    exists = os.path.exists(path)
    size = os.path.getsize(path) if exists else 0
    ok = exists and size > 1000
    report(5, "create_simple_clip (2s)", ok, f"{size:,} bytes")
except Exception as e:
    report(5, "create_simple_clip", False, str(e))


# --- Test 6: images_to_video ---
print("  Running Test 6: Video — images_to_video (Slideshow)...")
try:
    vp = MarketingVideoPipeline(output_dir=os.path.join(test_dir, "videos"))
    image_paths = [os.path.join(test_img_dir, f"slide_{i}.png") for i in range(3)]
    path = vp.images_to_video(
        image_paths,
        format_key="landscape",
        duration_per_image=2.0,
        filename="test_slideshow.mp4",
    )
    exists = os.path.exists(path)
    size = os.path.getsize(path) if exists else 0
    ok = exists and size > 1000
    report(6, "images_to_video (3 slides)", ok, f"{size:,} bytes")
except Exception as e:
    report(6, "images_to_video", False, str(e))


# --- Test 7: add_text_overlay ---
print("  Running Test 7: Video — add_text_overlay...")
try:
    vp = MarketingVideoPipeline(output_dir=os.path.join(test_dir, "videos"))
    # Verwende den clip aus Test 5
    source_video = os.path.join(test_dir, "videos", "test_clip.mp4")
    if not os.path.exists(source_video):
        # Erstelle schnell einen neuen Clip falls Test 5 fehlgeschlagen
        source_video = vp.create_simple_clip(
            os.path.join(test_img_dir, "slide_0.png"),
            duration=2.0,
            format_key="landscape",
            filename="test_clip_fallback.mp4",
        )

    path = vp.add_text_overlay(
        source_video,
        "EchoMatch",
        position="center",
        font_size=64,
        filename="test_overlay.mp4",
    )
    exists = os.path.exists(path)
    size = os.path.getsize(path) if exists else 0
    ok = exists and size > 1000
    report(7, "add_text_overlay", ok, f"{size:,} bytes")
except Exception as e:
    report(7, "add_text_overlay", False, str(e))


# --- Test 8: get_video_info ---
print("  Running Test 8: Video — get_video_info...")
try:
    vp = MarketingVideoPipeline(output_dir=os.path.join(test_dir, "videos"))
    # Verwende ein beliebiges Video aus vorherigen Tests
    source_video = os.path.join(test_dir, "videos", "test_clip.mp4")
    if not os.path.exists(source_video):
        source_video = os.path.join(test_dir, "videos", "test_slideshow.mp4")

    info = vp.get_video_info(source_video)
    has_keys = all(k in info for k in ["width", "height", "duration", "codec", "filesize"])
    ok = has_keys and info["width"] > 0 and info["duration"] > 0
    report(
        8,
        "get_video_info",
        ok,
        f"{info.get('width')}x{info.get('height')}, {info.get('duration', 0):.1f}s, {info.get('codec')}, {info.get('filesize', 0):,} bytes",
    )
except Exception as e:
    report(8, "get_video_info", False, str(e))


# --- Cleanup ---
print(f"\n  Cleaning up test directory: {test_dir}")
try:
    shutil.rmtree(test_dir)
    print("  (cleanup done)")
except Exception as e:
    print(f"  WARNING: Cleanup failed: {e}")


# --- Summary ---
print()
print("=" * 60)
if failed == 0:
    print(f"  \u2713 Phase 2 Tools — {passed}/{total} Tests Passed")
else:
    print(f"  {passed}/{total} Tests Passed, {failed} Failed")
print("=" * 60)
