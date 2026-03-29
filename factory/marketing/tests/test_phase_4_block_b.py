"""Phase 4 Block B Tests — Report Agent, Review Manager, Community Agent, HQ Bridge.

All 12 tests are deterministic (no LLM calls, no API costs).
LLM-dependent methods are tested for structure only (data gathering, classification).
The Two-Tier classification is HARD logic and fully testable.

Usage: python -m factory.marketing.tests.test_phase_4_block_b
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
logger = logging.getLogger("test_phase_4b")

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
# Test 1: Report Agent — Daten-Sammlung (deterministisch)
# ============================================================
def test_1_report_data_gathering():
    try:
        from factory.marketing.agents.report_agent import ReportAgent

        agent = ReportAgent()
        assert agent.agent_info["id"] == "MKT-09"

        data = agent._gather_data(days=7)
        assert "kpi_check" in data, "Missing kpi_check"
        assert "alert_stats" in data, "Missing alert_stats"
        assert "social_stats" in data, "Missing social_stats"
        assert "timestamp" in data, "Missing timestamp"
        assert data["period_days"] == 7, f"Expected period_days=7, got {data['period_days']}"

        report(1, "Report Data Gathering", True,
               f"keys: {list(data.keys())}")
    except Exception as e:
        report(1, "Report Data Gathering", False, str(e))


# ============================================================
# Test 2: Report Agent — Persona-Laden
# ============================================================
def test_2_report_persona():
    try:
        from factory.marketing.agents.report_agent import ReportAgent

        agent = ReportAgent()
        assert agent.agent_info["id"] == "MKT-09"
        assert agent.agent_info["name"] == "Report Agent"
        assert agent.agent_info["status"] == "active"
        assert agent.agent_info["model_tier"] == "mid"

        report(2, "Report Persona", True, f"id={agent.agent_info['id']}")
    except Exception as e:
        report(2, "Report Persona", False, str(e))


# ============================================================
# Test 3: Review Manager — Stufe 1 Klassifizierung (Rating 5)
# ============================================================
def test_3_review_tier1_positive():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.agents.review_manager import ReviewManager

        mgr = ReviewManager(alert_base_path=tmp_dir)
        review = {
            "id": "r001",
            "rating": 5,
            "title": "Super App!",
            "body": "Tolles Design, funktioniert einwandfrei. Danke!",
            "author": "Max",
        }
        result = mgr.classify_review(review)

        assert result["tier"] == 1, f"Expected tier 1, got {result['tier']}"
        assert len(result["triggers"]) == 0, f"Expected no triggers, got {result['triggers']}"

        report(3, "Review Tier 1 (Rating 5)", True,
               f"tier={result['tier']}, reason={result['reason']}")
    except Exception as e:
        report(3, "Review Tier 1 (Rating 5)", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 4: Review Manager — Stufe 2 Klassifizierung (Rating 1)
# ============================================================
def test_4_review_tier2_negative():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.agents.review_manager import ReviewManager

        mgr = ReviewManager(alert_base_path=tmp_dir)
        review = {
            "id": "r002",
            "rating": 1,
            "title": "Scam!",
            "body": "Funktioniert nicht, Abzocke. Geld zurueck!",
            "author": "Hans",
        }
        result = mgr.classify_review(review)

        assert result["tier"] == 2, f"Expected tier 2, got {result['tier']}"
        assert len(result["triggers"]) > 0, "Expected triggers"
        assert any("rating=1" in t for t in result["triggers"]), "Expected rating trigger"
        assert any("keyword:" in t for t in result["triggers"]), "Expected keyword trigger"

        report(4, "Review Tier 2 (Rating 1 + Keywords)", True,
               f"tier={result['tier']}, triggers={result['triggers'][:3]}")
    except Exception as e:
        report(4, "Review Tier 2 (Rating 1 + Keywords)", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 5: Review Manager — Stufe 2 durch Keywords (Rating 4)
# ============================================================
def test_5_review_tier2_keywords():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.agents.review_manager import ReviewManager

        mgr = ReviewManager(alert_base_path=tmp_dir)
        review = {
            "id": "r003",
            "rating": 4,
            "title": "Gut aber Datenschutz?",
            "body": "App ist gut, aber was macht ihr mit meinen Daten? Datenschutz ist mir wichtig.",
            "author": "Lisa",
        }
        result = mgr.classify_review(review)

        assert result["tier"] == 2, f"Expected tier 2, got {result['tier']}"
        assert any("datenschutz" in t for t in result["triggers"]), "Expected datenschutz trigger"

        report(5, "Review Tier 2 (Keywords bei Rating 4)", True,
               f"tier={result['tier']}, triggers={result['triggers']}")
    except Exception as e:
        report(5, "Review Tier 2 (Keywords bei Rating 4)", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 6: Review Manager — Gate-Erstellung (Stufe 2)
# ============================================================
def test_6_review_gate_creation():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.agents.review_manager import ReviewManager

        mgr = ReviewManager(alert_base_path=tmp_dir)
        review = {
            "id": "r004",
            "rating": 1,
            "title": "Betrug!",
            "body": "Diese App ist Betrug. Ich will mein Geld zurueck!",
            "author": "Karl",
        }
        # process_review without LLM (tier 2 doesn't call LLM)
        result = mgr.process_review(review, store="app_store")

        assert result["tier"] == 2, f"Expected tier 2, got {result['tier']}"
        assert result["action"] == "gate_created", f"Expected gate_created, got {result['action']}"
        assert result["gate_id"], "Expected gate_id to be set"
        assert result["gate_id"].startswith("MKT-G"), f"Invalid gate_id format: {result['gate_id']}"
        assert result["response"] is None, "Tier 2 should NOT have a response"

        report(6, "Review Gate Creation", True,
               f"gate_id={result['gate_id']}")
    except Exception as e:
        report(6, "Review Gate Creation", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 7: Review Manager — Batch-Verarbeitung
# ============================================================
def test_7_review_batch():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.agents.review_manager import ReviewManager

        mgr = ReviewManager(alert_base_path=tmp_dir)
        reviews = [
            {"id": "r010", "rating": 5, "title": "Top!", "body": "Beste App!", "author": "A"},
            {"id": "r011", "rating": 4, "title": "Gut", "body": "Macht Spass", "author": "B"},
            {"id": "r012", "rating": 3, "title": "OK", "body": "Geht so", "author": "C"},
            {"id": "r013", "rating": 1, "title": "Scam", "body": "Betrug und Abzocke", "author": "D"},
            {"id": "r014", "rating": 2, "title": "Schlecht", "body": "Crashes staendig", "author": "E"},
        ]
        # Note: Tier 1 reviews would need LLM for response, but classification is deterministic
        # We only test classification counts here
        tier1_count = 0
        tier2_count = 0
        for review in reviews:
            c = mgr.classify_review(review)
            if c["tier"] == 1:
                tier1_count += 1
            else:
                tier2_count += 1

        # r010 (5, no kw) = tier 1
        # r011 (4, no kw) = tier 1
        # r012 (3, no kw) = tier 1
        # r013 (1 + betrug/abzocke) = tier 2
        # r014 (2 + crashes) = tier 2
        assert tier1_count == 3, f"Expected 3 tier1, got {tier1_count}"
        assert tier2_count == 2, f"Expected 2 tier2, got {tier2_count}"

        report(7, "Review Batch Classification", True,
               f"tier1={tier1_count}, tier2={tier2_count}")
    except Exception as e:
        report(7, "Review Batch Classification", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 8: Community Agent — Stufe 1 (positiver Kommentar)
# ============================================================
def test_8_community_tier1():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.agents.community_agent import CommunityAgent

        agent = CommunityAgent(alert_base_path=tmp_dir)
        comment = {
            "id": "c001",
            "text": "Mega cooles Video! Wann kommt das naechste?",
            "author": "Anna",
            "platform": "youtube",
        }
        result = agent.classify_comment(comment)

        assert result["tier"] == 1, f"Expected tier 1, got {result['tier']}"
        assert len(result["triggers"]) == 0, f"Expected no triggers, got {result['triggers']}"

        report(8, "Community Tier 1 (positive)", True,
               f"tier={result['tier']}")
    except Exception as e:
        report(8, "Community Tier 1 (positive)", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 9: Community Agent — Stufe 2 (negativer Kommentar)
# ============================================================
def test_9_community_tier2():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.agents.community_agent import CommunityAgent

        agent = CommunityAgent(alert_base_path=tmp_dir)
        comment = {
            "id": "c002",
            "text": "Das ist doch alles fake und scam! Bullshit!",
            "author": "Troll123",
            "platform": "tiktok",
        }
        result = agent.classify_comment(comment)

        assert result["tier"] == 2, f"Expected tier 2, got {result['tier']}"
        assert len(result["triggers"]) > 0, "Expected triggers"
        assert any("fake" in t for t in result["triggers"]), "Expected 'fake' trigger"

        report(9, "Community Tier 2 (negative)", True,
               f"tier={result['tier']}, triggers={result['triggers'][:3]}")
    except Exception as e:
        report(9, "Community Tier 2 (negative)", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 10: Community Agent — Gate-Erstellung
# ============================================================
def test_10_community_gate():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.agents.community_agent import CommunityAgent

        agent = CommunityAgent(alert_base_path=tmp_dir)
        comment = {
            "id": "c003",
            "text": "Ihr seid alle Idioten, ich melde euch!",
            "author": "Hater",
            "platform": "x",
            "post_id": "post_123",
        }
        result = agent.process_comment(comment)

        assert result["tier"] == 2, f"Expected tier 2, got {result['tier']}"
        assert result["action"] == "gate_created", f"Expected gate_created, got {result['action']}"
        assert result["gate_id"], "Expected gate_id"
        assert result["gate_id"].startswith("MKT-G"), f"Invalid gate_id: {result['gate_id']}"
        assert result["response"] is None, "Tier 2 should NOT have a response"
        assert result["platform"] == "x"

        report(10, "Community Gate Creation", True,
               f"gate_id={result['gate_id']}")
    except Exception as e:
        report(10, "Community Gate Creation", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 11: HQ Bridge — Department Status Export
# ============================================================
def test_11_hq_bridge_status():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.hq_bridge import HQBridge

        bridge = HQBridge(output_dir=tmp_dir)
        status = bridge.export_department_status()

        assert status["department"] == "Marketing"
        assert status["department_id"] == "MKT"
        assert "agents" in status, "Missing agents"
        assert "alerts" in status, "Missing alerts"
        assert "kpis" in status, "Missing kpis"
        assert "social" in status, "Missing social"
        assert "export_path" in status, "Missing export_path"
        assert os.path.exists(status["export_path"]), "Export file not found"

        # Check agents list
        agents = status["agents"]
        assert len(agents) >= 11, f"Expected >= 11 agents, got {len(agents)}"
        agent_ids = [a["id"] for a in agents]
        assert "MKT-09" in agent_ids, "MKT-09 missing from agents"
        assert "MKT-10" in agent_ids, "MKT-10 missing from agents"
        assert "MKT-11" in agent_ids, "MKT-11 missing from agents"

        report(11, "HQ Bridge Status", True,
               f"{len(agents)} agents, file exists")
    except Exception as e:
        report(11, "HQ Bridge Status", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Test 12: HQ Bridge — Full Snapshot Export
# ============================================================
def test_12_hq_bridge_snapshot():
    tmp_dir = tempfile.mkdtemp(prefix="mkt_test_")
    try:
        from factory.marketing.tools.hq_bridge import HQBridge

        bridge = HQBridge(output_dir=tmp_dir)
        snapshot = bridge.export_full_snapshot()

        assert snapshot["snapshot_id"].startswith("MKT-SNAP-"), \
            f"Invalid snapshot_id: {snapshot['snapshot_id']}"
        assert "department_status" in snapshot, "Missing department_status"
        assert "alert_feed" in snapshot, "Missing alert_feed"
        assert "kpi_dashboard" in snapshot, "Missing kpi_dashboard"
        assert "export_path" in snapshot, "Missing export_path"
        assert os.path.exists(snapshot["export_path"]), "Snapshot file not found"

        # Verify JSON file is valid
        with open(snapshot["export_path"], "r", encoding="utf-8") as f:
            loaded = json.load(f)
        assert loaded["snapshot_id"] == snapshot["snapshot_id"]

        report(12, "HQ Bridge Snapshot", True,
               f"snapshot_id={snapshot['snapshot_id']}")
    except Exception as e:
        report(12, "HQ Bridge Snapshot", False, str(e))
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("Phase 4 Block B — Integration Tests")
    print("=" * 60 + "\n")

    test_1_report_data_gathering()
    test_2_report_persona()
    test_3_review_tier1_positive()
    test_4_review_tier2_negative()
    test_5_review_tier2_keywords()
    test_6_review_gate_creation()
    test_7_review_batch()
    test_8_community_tier1()
    test_9_community_tier2()
    test_10_community_gate()
    test_11_hq_bridge_status()
    test_12_hq_bridge_snapshot()

    print("\n" + "=" * 60)
    print(f"Phase 4 Block B — {passed}/12 Tests Passed")
    print("=" * 60)

    for r in results:
        print(f"  {r}")

    sys.exit(0 if failed == 0 else 1)
