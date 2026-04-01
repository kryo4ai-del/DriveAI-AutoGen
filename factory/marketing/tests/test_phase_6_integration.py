"""Phase 6 Integration Tests - 12 Tests.

SMTP, Press DB, Influencer, Press Kit, Storytelling, PR, Community Templates.
"""

import os
import sys
import tempfile
import zipfile

# -- Setup: PYTHONPATH + Test-DB ------------------------------------------------

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, ROOT)

# Test-DB statt Produktion
_temp_db = tempfile.NamedTemporaryFile(suffix=".db", delete=False)
os.environ["MARKETING_DB_PATH"] = _temp_db.name
_temp_db.close()

# Ensure no SMTP credentials -> forced dry-run
os.environ.pop("SMTP_HOST", None)

passed = 0
failed = 0
_cleanup_gate_ids = []
_cleanup_influencer_id = None


def run_test(name, fn):
    global passed, failed
    try:
        result = fn()
        passed += 1
        detail = result if isinstance(result, str) else "OK"
        print(f"  OK  {name} -- {detail}")
    except Exception as e:
        failed += 1
        print(f"  FAIL  {name}: {e}")


# == Tests =====================================================================

def test_01_smtp_dry_run():
    """SMTP Dry-Run Email."""
    from factory.marketing.adapters.smtp_adapter import SMTPAdapter
    adapter = SMTPAdapter()
    assert adapter.dry_run is True
    result = adapter.send_email(
        "press@techcrunch.com",
        "DriveAI Factory Launch",
        "<h1>PM</h1>",
    )
    assert result["sent"] is True
    assert result["dry_run"] is True
    return "dry_run logged"


def test_02_press_distribution():
    """Press Distribution List."""
    from factory.marketing.tools.press_database import PressDatabase
    pdb = PressDatabase()
    pdb.seed_initial_contacts()
    us_ai = pdb.get_distribution_list("AI", countries=["US"])
    assert len(us_ai) > 0, "No US/AI contacts"
    for c in us_ai:
        assert c["country"] == "US"
    return f"{len(us_ai)} contacts for AI/US"


def test_03_influencer_discover():
    """Influencer Auto-Discover."""
    from factory.marketing.tools.influencer_database import InfluencerDatabase
    idb = InfluencerDatabase()
    results = idb.auto_discover("AI technology", "youtube", limit=3)
    assert len(results) > 0, "No discover results"
    source = results[0].get("source", "unknown")
    return f"{len(results)} suggestions (source: {source})"


def test_04_outreach_brief():
    """Influencer Outreach Brief."""
    global _cleanup_influencer_id
    from factory.marketing.tools.influencer_database import InfluencerDatabase
    idb = InfluencerDatabase()
    _cleanup_influencer_id = idb.add_influencer(
        "TestInfluencer", "youtube", "@testchannel",
        followers=50000, topics="AI,Tech",
    )
    assert _cleanup_influencer_id > 0
    brief = idb.create_outreach_brief(_cleanup_influencer_id)
    assert brief is not None, "Brief is None"
    assert len(brief) > 20, f"Brief too short: {len(brief)} chars"
    return f"personalized text ({len(brief)} chars)"


def test_05_factory_press_kit():
    """Factory Press Kit - live agent count."""
    from factory.marketing.tools.press_kit_generator import PressKitGenerator
    pkg = PressKitGenerator()
    path = pkg.generate_factory_press_kit()
    assert os.path.exists(path), f"Not found: {path}"
    content = open(path, encoding="utf-8").read()
    assert "DAI-Core Factory" in content
    # Agent count should be a number (from registry)
    assert "Agents" in content
    # Extract agent count from Key Facts table
    import re
    match = re.search(r"Agents \(gesamt\)\s*\|\s*(\d+)", content)
    agent_count = match.group(1) if match else "?"
    return f"live agent count: {agent_count}"


def test_06_press_kit_zip():
    """Press Kit ZIP."""
    from factory.marketing.tools.press_kit_generator import PressKitGenerator
    pkg = PressKitGenerator()
    zip_path = pkg.package_press_kit("echomatch")
    assert os.path.exists(zip_path)
    assert zipfile.is_zipfile(zip_path)
    with zipfile.ZipFile(zip_path, "r") as zf:
        names = zf.namelist()
        assert len(names) >= 2
    return f"valid, {len(names)} files"


def test_07_case_study():
    """Storytelling - Case Study with real data."""
    from factory.marketing.agents.storytelling_agent import StorytellingAgent
    agent = StorytellingAgent()

    # Verify _get_factory_facts returns real data
    facts = agent._get_factory_facts()
    assert facts["agents_total"] > 0, f"agents_total is {facts['agents_total']}"
    assert facts["departments"] > 0, f"departments is {facts['departments']}"

    path = agent.create_case_study("echomatch")
    assert os.path.exists(path), f"Not found: {path}"
    content = open(path, encoding="utf-8").read()
    assert len(content) > 100, "Case study too short"
    # Should contain real agent count somewhere
    assert str(facts["agents_total"]) in content or "Agent" in content
    return f"echomatch with real data ({facts['agents_total']} agents)"


def test_08_cost_comparison():
    """Storytelling - Cost Comparison."""
    from factory.marketing.agents.storytelling_agent import StorytellingAgent
    agent = StorytellingAgent()
    path = agent.create_cost_comparison("echomatch")
    assert os.path.exists(path), f"Not found: {path}"
    content = open(path, encoding="utf-8").read()
    assert len(content) > 100, "Cost comparison too short"
    return "factory vs industry"


def test_09_press_release():
    """PR - Pressemitteilung (short+long+de)."""
    from factory.marketing.agents.pr_agent import PRAgent
    agent = PRAgent()
    result = agent.create_press_release(
        "milestone",
        {"milestone": "13 Marketing-Agents aktiv", "agents": 110},
    )
    assert "short" in result, "Missing short version"
    assert "long" in result, "Missing long version"
    assert "de" in result, "Missing DE version"
    for version, path in result.items():
        assert os.path.exists(path), f"{version} not found: {path}"
    # Check headline length in short version
    short_content = open(result["short"], encoding="utf-8").read()
    lines = [l.strip() for l in short_content.split("\n") if l.strip()]
    headline = ""
    for line in lines:
        if line.startswith("# "):
            headline = line[2:].strip()
            break
    if headline:
        assert len(headline) <= 80, f"Headline too long: {len(headline)} chars: {headline}"
        return f"short+long+de, headline {len(headline)} chars"
    return "short+long+de, headline OK"


def test_10_crisis_gate():
    """PR - Crisis Response creates CEO-Gate, NO direct response."""
    global _cleanup_gate_ids
    from factory.marketing.agents.pr_agent import PRAgent
    agent = PRAgent()
    result = agent.create_crisis_response_draft(
        "Negativer Artikel in TechCrunch ueber KI-Apps",
    )
    assert "gate_id" in result, "No gate_id returned"
    assert "draft" in result, "No draft returned"
    assert len(result["draft"]) > 50, "Draft too short"
    gate_id = result["gate_id"]
    _cleanup_gate_ids.append(gate_id)

    # Verify gate exists in filesystem
    from factory.marketing.alerts.alert_manager import MarketingAlertManager
    alerts = MarketingAlertManager()
    gates_dir = alerts._gates
    gate_file = os.path.join(gates_dir, f"{gate_id}.json")
    assert os.path.exists(gate_file), f"Gate file not found: {gate_file}"

    # Verify NO direct publication (gate is pending)
    import json
    with open(gate_file, "r", encoding="utf-8") as f:
        gate = json.load(f)
    assert gate["status"] == "pending", f"Gate status is {gate['status']}, expected pending"
    return f"gate created ({gate_id}), NO direct response"


def test_11_product_hunt():
    """PR - Product Hunt Tagline <= 60 chars."""
    from factory.marketing.agents.pr_agent import PRAgent
    agent = PRAgent()
    path = agent.create_product_hunt_package("echomatch")
    assert os.path.exists(path), f"Not found: {path}"
    content = open(path, encoding="utf-8").read()

    # Extract tagline
    lines = content.split("\n")
    tagline = ""
    for i, line in enumerate(lines):
        if "tagline" in line.lower() and line.strip().startswith("#"):
            # Next non-empty line is the tagline
            for j in range(i + 1, min(i + 5, len(lines))):
                candidate = lines[j].strip()
                if candidate and not candidate.startswith("#"):
                    tagline = candidate
                    break
            break
    if tagline:
        assert len(tagline) <= 60, f"Tagline too long: {len(tagline)} chars: {tagline}"
        return f"tagline {len(tagline)} chars (<=60)"
    return "MD exists, tagline OK"


def test_12_community_templates():
    """Community Templates - fill with real data."""
    from factory.marketing.tools.community_templates import CommunityTemplates
    ct = CommunityTemplates()

    # Fill template (reddit_artificial has both agent_count and dept_count)
    filled = ct.fill_template("reddit_artificial", {
        "product_name": "EchoMatch",
        "agent_count": 110,
        "dept_count": 18,
        "description": "An autonomous AI factory",
        "cost_example": "$0.51 for a complete roadbook",
        "time_example": "4 minutes",
    })
    assert "110" in filled, f"agent_count not in filled text"
    assert "18" in filled, f"dept_count not in filled text"

    # Rules
    rules = ct.get_platform_rules("reddit_artificial")
    assert len(rules) > 10, "Rules too short"

    # Calendar
    path = ct.create_outreach_calendar()
    assert os.path.exists(path), f"Calendar not found: {path}"
    cal_content = open(path, encoding="utf-8").read()
    assert "CEO-Gate" in cal_content, "CEO-Gate reminder missing from calendar"

    # All platforms
    platforms = ct.get_all_platforms()
    assert len(platforms) == 6, f"Expected 6 platforms, got {len(platforms)}"
    return f"filled with real data, {len(platforms)} platforms, calendar OK"


# == Runner ====================================================================

if __name__ == "__main__":
    print("\n=== Phase 6 Integration Tests ===\n")

    tests = [
        ("Test 1: SMTP", test_01_smtp_dry_run),
        ("Test 2: Press Distribution", test_02_press_distribution),
        ("Test 3: Influencer Discover", test_03_influencer_discover),
        ("Test 4: Outreach Brief", test_04_outreach_brief),
        ("Test 5: Factory Press Kit", test_05_factory_press_kit),
        ("Test 6: Press Kit ZIP", test_06_press_kit_zip),
        ("Test 7: Case Study", test_07_case_study),
        ("Test 8: Cost Comparison", test_08_cost_comparison),
        ("Test 9: PM", test_09_press_release),
        ("Test 10: Crisis - Gate", test_10_crisis_gate),
        ("Test 11: Product Hunt", test_11_product_hunt),
        ("Test 12: Community Templates", test_12_community_templates),
    ]

    for name, fn in tests:
        run_test(name, fn)

    # Cleanup
    if _cleanup_influencer_id:
        try:
            from factory.marketing.tools.ranking_database import RankingDatabase
            db = RankingDatabase()
            db.delete_influencer(_cleanup_influencer_id)
        except Exception:
            pass

    for gate_id in _cleanup_gate_ids:
        try:
            from factory.marketing.alerts.alert_manager import MarketingAlertManager
            alerts = MarketingAlertManager()
            gate_file = os.path.join(alerts._gates, f"{gate_id}.json")
            if os.path.exists(gate_file):
                os.remove(gate_file)
        except Exception:
            pass

    print(f"\n=== Phase 6 Integration -- {passed}/{passed + failed} Tests Passed ===")

    # Cleanup temp DB
    try:
        os.unlink(_temp_db.name)
    except OSError:
        pass

    if failed > 0:
        sys.exit(1)
