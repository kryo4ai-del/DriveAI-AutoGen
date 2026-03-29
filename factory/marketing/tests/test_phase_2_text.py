"""Phase 2 Text-Agents Funktionstest.

Testet Copywriter, Naming, ASO mit echten LLM-Calls.

Aufruf: python -m factory.marketing.tests.test_phase_2_text
"""

import glob
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


print("\n" + "=" * 55)
print("  Phase 2 Text-Agents — Funktionstest")
print("=" * 55 + "\n")


# --- Test 1: Copywriter Social Media Pack ---
print("  Running Test 1: Copywriter Social Media Pack...")
try:
    from factory.marketing.agents.copywriter import Copywriter

    cw = Copywriter()
    result = cw.create_social_media_pack("echomatch", ["tiktok", "x"])
    if result and os.path.exists(result):
        size = os.path.getsize(result)
        with open(result, "r", encoding="utf-8") as f:
            content = f.read()
        has_tiktok = "tiktok" in content.lower() or "TikTok" in content
        has_x = "x" in content.lower().split() or "X/" in content or "X —" in content or "twitter" in content.lower()
        ok = size > 500 and has_tiktok
        report(1, "Copywriter Social Media Pack", ok, f"{size:,} bytes")
    else:
        report(1, "Copywriter Social Media Pack", False, "no output file")
except Exception as e:
    report(1, "Copywriter Social Media Pack", False, str(e))


# --- Test 2: Copywriter Store Listing ---
print("  Running Test 2: Copywriter Store Listing...")
try:
    cw = Copywriter()
    result = cw.create_store_listing("echomatch", "both", "de")
    ios_ok = "ios" in result and os.path.exists(result["ios"])
    android_ok = "android" in result and os.path.exists(result["android"])
    if ios_ok and android_ok:
        ios_size = os.path.getsize(result["ios"])
        android_size = os.path.getsize(result["android"])
        ok = ios_size > 200 and android_size > 200
        report(2, "Copywriter Store Listing", ok, f"iOS: {ios_size:,} bytes, Android: {android_size:,} bytes")
    else:
        report(2, "Copywriter Store Listing", False, f"ios={ios_ok}, android={android_ok}")
except Exception as e:
    report(2, "Copywriter Store Listing", False, str(e))


# --- Test 3: Naming Generate ---
print("  Running Test 3: Naming Generate Names...")
try:
    from factory.marketing.agents.naming_agent import NamingAgent

    na = NamingAgent()
    names = na.generate_names(
        "Ein Casual-Puzzle-Spiel bei dem Spieler durch Soundfrequenz-Matching Levels loesen",
        "game",
        "18-34 Casual Gamer",
    )
    ok = len(names) >= 3 and all("name" in n and "reasoning" in n for n in names)
    name_list = [n["name"] for n in names]
    report(3, "Naming Generate", ok, f"{len(names)} names: {', '.join(name_list[:5])}")
except Exception as e:
    report(3, "Naming Generate", False, str(e))


# --- Test 4: Naming Report + CEO-Gate ---
print("  Running Test 4: Naming Report + CEO-Gate...")
try:
    na = NamingAgent()
    result = na.create_naming_report(
        "Ein Casual-Puzzle-Spiel mit Sound-Matching",
        "game",
        "18-34 Casual Gamer",
        "echomatch_naming_test",
    )
    report_ok = result and os.path.exists(result)

    # Check if gate was created
    from factory.marketing.config import ALERTS_PATH

    gates_dir = os.path.join(ALERTS_PATH, "gates")
    gate_files = glob.glob(os.path.join(gates_dir, "MKT-G*.json"))
    gate_ok = len(gate_files) > 0

    ok = report_ok and gate_ok
    detail_parts = []
    if report_ok:
        detail_parts.append(f"report {os.path.getsize(result):,} bytes")
    if gate_ok:
        detail_parts.append(f"gate created")
    report(4, "Naming Report + Gate", ok, ", ".join(detail_parts))

    # Cleanup: Gate-Dateien loeschen
    for gf in gate_files:
        os.remove(gf)
        print(f"    (cleaned up {os.path.basename(gf)})")
except Exception as e:
    report(4, "Naming Report + Gate", False, str(e))


# --- Test 5: ASO Keyword Research ---
print("  Running Test 5: ASO Keyword Research...")
try:
    from factory.marketing.agents.aso_agent import ASOAgent

    aso = ASOAgent()
    result = aso.keyword_research("echomatch", ["US"])
    if "US" in result and os.path.exists(result["US"]):
        size = os.path.getsize(result["US"])
        ok = size > 500
        report(5, "ASO Keywords", ok, f"{size:,} bytes")
    else:
        report(5, "ASO Keywords", False, "no US output")
except Exception as e:
    report(5, "ASO Keywords", False, str(e))


# --- Summary ---
print()
print("=" * 55)
if failed == 0:
    print(f"  \u2713 Phase 2 Text-Agents — {passed}/{total} Tests Passed")
else:
    print(f"  {passed}/{total} Tests Passed, {failed} Failed")
print("=" * 55)
