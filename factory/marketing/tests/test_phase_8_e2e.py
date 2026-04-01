"""Phase 8 End-to-End Test — BEWEIS dass die gesamte Marketing-Abteilung funktioniert.

10 Tests: Pipeline, Feedback, Knowledge, KPI, Review, Content, Cost, Hooks, Brand, Survey.
LLM-abhaengige Agents werden gemockt um Haengen/Kosten zu vermeiden.
"""

import os
import sys
import json
import tempfile

# -- Setup: PYTHONPATH + Test-DB ------------------------------------------------

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, ROOT)

# Test-DB statt Produktion
_temp_db = tempfile.NamedTemporaryFile(suffix=".db", delete=False)
os.environ["MARKETING_DB_PATH"] = _temp_db.name
_temp_db.close()

# Test-Alerts-Verzeichnis
_temp_alerts = tempfile.mkdtemp(prefix="mkt_alerts_")

# Patch RankingDatabase um Test-DB zu nutzen
import factory.marketing.tools.ranking_database as rdb_module
_orig_init = rdb_module.RankingDatabase.__init__

def _patched_init(self, db_path=None):
    _orig_init(self, db_path=os.environ.get("MARKETING_DB_PATH", db_path))

rdb_module.RankingDatabase.__init__ = _patched_init

passed = 0
failed = 0


def run_test(name, fn):
    global passed, failed
    try:
        result = fn()
        passed += 1
        detail = result if isinstance(result, str) else "OK"
        print(f"  OK  {name} -- {detail}")
    except Exception as e:
        failed += 1
        import traceback
        print(f"  FAIL  {name}: {e}")
        traceback.print_exc()


# == Tests =====================================================================

def test_01_full_marketing_cycle():
    """Full Marketing Cycle: Pipeline Runner durchlaeuft 12 Steps."""
    from factory.marketing.tools.pipeline_runner import MarketingPipelineRunner

    pr = MarketingPipelineRunner()

    # Mock: simuliert realistische Outputs (8 OK, 4 fail wg. fehlender Daten)
    def _mock_execute(step, project_slug, dry_run):
        sn = step["number"]
        # Steps 5 (ASO braucht SerpAPI), 9 (Brand braucht Brand Book),
        # 11 (Case Study braucht Projekt-Daten), 12 (PR braucht key_facts) fehlschlagen
        if sn in (5, 9, 11, 12):
            raise RuntimeError(f"Mock: Step {sn} ({step['name']}) missing prerequisites")
        return f"/mock/output/{project_slug}/step_{sn}_{step['name']}.md"

    pr._execute_step = _mock_execute
    result = pr.run_full_cycle("echomatch", dry_run=True)

    assert result["steps_total"] == 12
    assert result["steps_completed"] >= 8, f"completed={result['steps_completed']}"
    assert result["steps_completed"] + result["steps_failed"] == 12

    # Output-Pfade fuer completed Steps pruefen
    for d in result["details"]:
        if d["status"] == "completed":
            assert d["output"] is not None, f"Step {d['step']} completed but no output"

    return f"{result['steps_completed']}/12 steps, {result['steps_failed']} failed, {result['duration_seconds']:.1f}s"


def test_02_feedback_loop():
    """Feedback-Loop: Insights erkennen und korrekt routen."""
    from factory.marketing.tools.ranking_database import RankingDatabase
    from factory.marketing.tools.feedback_loop import MarketingFeedbackLoop

    db = RankingDatabase()

    # Test-Performance-Daten: 1 Top-Performer, 1 Underperformer
    for i in range(8):
        engagement = 500 if i == 0 else (10 if i == 1 else 100)
        db.store_post_performance(
            platform="tiktok", post_id=f"e2e_post_{i}", content_type="video",
            metrics={"impressions": 5000, "engagements": engagement,
                     "likes": engagement // 2, "shares": 5, "comments": 3},
        )

    fl = MarketingFeedbackLoop()
    result = fl.analyze_and_route(period_days=30)

    assert result["insights_found"] >= 1, f"No insights found"
    assert result["tasks_created"] >= 1, f"No tasks created"

    # Pruefe Routing: jeder Task hat einen gueltigen target_agent
    for task in result["tasks"]:
        assert task["target_agent"].startswith("MKT-"), f"Bad agent: {task['target_agent']}"
        assert task["insight_type"] in fl.ROUTING, f"Unknown type: {task['insight_type']}"

    return f"{result['insights_found']} insights, {result['tasks_created']} tasks routed"


def test_03_knowledge_base():
    """Knowledge Base: Add, Confirm, Agent-Query."""
    from factory.marketing.tools.marketing_knowledge import MarketingKnowledgeBase

    kb = MarketingKnowledgeBase()
    kid = kb.add_knowledge("content_insights", "E2E Test Insight: Short-form beats long-form",
                           "E2E Test Evidence")
    assert kid > 0

    # Confirm: hypothesis -> confirmed
    r = kb.confirm_knowledge(kid)
    assert r["confidence"] == "confirmed", f"Expected confirmed, got {r['confidence']}"

    # Agent-Query: MKT-03 (Copywriter) bekommt content_insights
    insights = kb.get_knowledge_for_agent("MKT-03")
    found = any(e["id"] == kid for e in insights)
    assert found, f"Knowledge {kid} not in MKT-03 insights"

    return f"id={kid}, hypothesis -> confirmed, MKT-03 query OK"


def test_04_kpi_alert():
    """KPI Alert: Critical Alert bei schlechtem Store-Rating."""
    from factory.marketing.tools.kpi_tracker import KPITracker

    kt = KPITracker(alert_base_path=_temp_alerts)
    result = kt.check_kpis({"d1_retention": 28, "store_rating": 3.5})

    assert result["overall_status"] in ("warning", "critical"), \
        f"Expected warning/critical, got {result['overall_status']}"

    # Store Rating 3.5 sollte critical sein (threshold = 3.5)
    rating_check = None
    for check in result.get("checks", []):
        if check.get("kpi") == "store_rating":
            rating_check = check
            break
    assert rating_check is not None, "store_rating check not found"
    assert rating_check["status"] in ("warning", "critical"), \
        f"store_rating status={rating_check['status']}"

    # D1 Retention 28 sollte critical sein (threshold = 30)
    d1_check = None
    for check in result.get("checks", []):
        if check.get("kpi") == "d1_retention":
            d1_check = check
            break
    assert d1_check is not None, "d1_retention check not found"
    assert d1_check["status"] in ("warning", "critical"), \
        f"d1_retention status={d1_check['status']}"

    return f"overall={result['overall_status']}, rating={rating_check['status']}, d1={d1_check['status']}, alerts={result.get('alerts_created', 0)}"


def test_05_zwei_stufen_review():
    """Zwei-Stufen-System: Negativer Review -> Stufe 2, Gate, KEIN Auto-Response."""
    from factory.marketing.agents.review_manager import ReviewManager

    rm = ReviewManager(alert_base_path=_temp_alerts)
    review = {
        "id": "e2e_review_001",
        "rating": 1,
        "title": "Scam App",
        "body": "App stuerzt ab, Geld zurueck! Das ist Betrug.",
        "author": "angry_user",
    }

    # classify_review: sollte Tier 2 sein (Rating 1 + Tier2-Keywords)
    classification = rm.classify_review(review)
    assert classification["tier"] == 2, f"Expected tier 2, got {classification['tier']}"
    assert len(classification["triggers"]) > 0, "No triggers found"

    # process_review: sollte Gate erstellen, KEINE Auto-Response
    result = rm.process_review(review, store="app_store")
    assert result["tier"] == 2
    assert result["action"] == "gate_created", f"action={result['action']}"
    assert result["gate_id"] is not None, "No gate_id for Tier 2"
    assert result["response"] is None, f"Tier 2 should NOT auto-respond, got: {result['response']}"

    return f"tier=2, triggers={classification['triggers'][:3]}, gate={result['gate_id']}, NO auto-response"


def test_06_cross_platform_content():
    """Cross-Platform Content: Copywriter erstellt Plattform-spezifischen Content."""
    from factory.marketing.agents.copywriter import Copywriter

    cw = Copywriter()

    # Mock _call_llm: gibt plausiblen Multi-Platform Content zurueck
    def _mock_llm(prompt, system_msg=None, max_tokens=4096):
        return """# Social Media Pack: EchoMatch

## TikTok
Hook: "Was wenn deine Musik dein Match waere?"
Caption: Stell dir vor, du matchst mit Leuten die GENAU deinen Musikgeschmack teilen.
Hashtags: #EchoMatch #MusicApp #Dating

## X (Twitter)
Tweet 1: EchoMatch ist live! Match mit deinem Sound-Zwilling.
Tweet 2: Spotify wrapped war gestern. EchoMatch ist die Zukunft.

## YouTube
Title: EchoMatch - Die App die dein Leben veraendert
Description: In diesem Video zeigen wir euch EchoMatch...
"""

    cw._call_llm = _mock_llm
    output = cw.create_social_media_pack("echomatch", platforms=["tiktok", "x", "youtube"])

    assert output is not None, "No output from create_social_media_pack"
    # Output ist ein Pfad oder String — pruefe dass Content existiert
    if os.path.exists(str(output)):
        with open(str(output), "r", encoding="utf-8") as f:
            content = f.read()
    else:
        content = str(output)

    assert len(content) > 50, f"Content too short: {len(content)} chars"

    return f"Content generated, {len(content)} chars"


def test_07_cost_tracking():
    """Cost Tracking: Factory vs Market Comparison."""
    from factory.marketing.tools.cost_reporter import MarketingCostReporter

    cr = MarketingCostReporter()
    result = cr.compare_factory_vs_market()

    factory_total = result["factory"]["total"]
    market_total = result["market"]["total"]

    assert factory_total < market_total, f"Factory >= Market"
    assert result["savings_percent"] > 90, f"savings={result['savings_percent']}%"
    assert factory_total > 0, "Factory cost should be > 0"
    assert market_total == 163000, f"Market benchmark changed: {market_total}"

    return f"Factory: ${factory_total:.2f} vs Market: ${market_total:,.0f}, savings {result['savings_percent']:.1f}%"


def test_08_hook_library():
    """Hook-Bibliothek: Save, Use, Promote to Proven, Recommend."""
    from factory.marketing.tools.content_trend_analyzer import ContentTrendAnalyzer

    cta = ContentTrendAnalyzer()

    # Save hook
    hook_id = cta.save_hook("Wusstest du dass KI Apps baut?", "tiktok", "factory", "question")
    assert hook_id > 0, f"Bad hook_id: {hook_id}"

    # 2x successful usage -> proven
    cta.record_hook_usage(hook_id, successful=True)
    cta.record_hook_usage(hook_id, successful=True)

    # Check status
    from factory.marketing.tools.ranking_database import RankingDatabase
    db = RankingDatabase()
    hooks = db.get_hooks(platform="tiktok", limit=20)
    our_hook = [h for h in hooks if h["id"] == hook_id]
    assert len(our_hook) == 1, f"Hook {hook_id} not found"
    assert our_hook[0]["status"] == "proven", f"status={our_hook[0]['status']}, expected proven"

    # Recommended hooks should include ours
    recommended = cta.get_recommended_hooks("tiktok")
    found = any(h["id"] == hook_id for h in recommended)
    assert found, f"Hook {hook_id} not in recommended"

    return f"hook_id={hook_id}, status=proven, in recommendations"


def test_09_brand_compliance():
    """Brand Compliance: Score und Issues fuer Content."""
    from factory.marketing.agents.brand_guardian import BrandGuardian

    bg = BrandGuardian()

    # Mock _call_llm: gibt plausible Compliance-Antwort
    def _mock_llm(prompt, max_tokens=4096):
        return json.dumps({
            "score": 78,
            "issues": [
                {"severity": "warning", "description": "Tone etwas zu casual fuer Brand Voice"},
                {"severity": "info", "description": "Keine CTA vorhanden"}
            ],
            "recommendations": ["CTA hinzufuegen", "Formelleren Ton verwenden"],
            "compliant": True,
        })

    bg._call_llm = _mock_llm
    result = bg.check_brand_compliance(
        "Hey Leute! EchoMatch ist mega! Probiert es aus!!!",
        "social_post",
    )

    assert isinstance(result, dict), f"Expected dict, got {type(result)}"
    # Score sollte in result sein (aus gemocktem JSON)
    score = result.get("score", result.get("compliance_score", 0))
    assert isinstance(score, (int, float)), f"score not numeric: {score}"

    issues = result.get("issues", [])
    assert isinstance(issues, list), f"issues not list: {type(issues)}"

    return f"score={score}, {len(issues)} issues"


def test_10_survey_to_idea():
    """Survey -> Analyse -> Market Gap -> Idea -> CEO-Gate Pipeline."""
    from factory.marketing.tools.survey_system import SurveySystem
    from factory.marketing.tools.market_scanner import AppMarketScanner

    # 1. Survey erstellen
    ss = SurveySystem()
    survey = ss.create_survey(
        title="Was soll die Factory bauen?",
        questions=[{"question": "Welche App?", "options": ["Puzzle", "Fitness", "Finanzen"]}],
        platforms=["x", "reddit"],
        survey_type="feature_vote",
    )
    assert survey.get("valid", survey.get("survey_id") is not None), \
        f"Survey invalid: {survey.get('validation_errors', [])}"
    survey_id = survey.get("survey_id")

    # 2. Mock-Ergebnisse eintragen
    if survey_id:
        ss.record_results(survey_id, {"Puzzle": 45, "Fitness": 30, "Finanzen": 25})

    # 3. Market Gap finden (gemockt)
    ams = AppMarketScanner()

    def _mock_llm(prompt, system_msg=None, max_tokens=4096):
        return json.dumps([{
            "gap_description": "Casual puzzle games mit AI-generated levels fehlen im Markt",
            "category": "games",
            "target_audience": "18-34 casual gamers",
            "estimated_potential": "high",
            "factory_feasibility": "high",
            "reasoning": "Survey zeigt Puzzle als Top-Wunsch",
        }])

    ams._call_llm = _mock_llm
    gaps = ams.find_market_gaps("games")
    assert len(gaps) >= 1, f"No gaps found"

    # 4. Idea erstellen und an Pipeline submitten
    def _mock_idea_llm(prompt, system_msg=None, max_tokens=4096):
        return json.dumps({
            "app_name": "PuzzleForge",
            "one_liner": "AI-generierte Puzzle mit unendlichen Levels",
            "target_audience": "18-34 casual gamers",
            "core_features": ["AI Level Generation", "Daily Challenges", "Leaderboards"],
            "monetization": "Freemium + Ads",
            "estimated_potential": "high",
            "why_factory_should_build": "Survey-Daten + Marktluecke",
        })

    ams._call_llm = _mock_idea_llm
    idea = ams.create_app_idea(gaps[0])
    assert idea.get("app_name"), f"No app_name in idea"

    # 5. Submit to pipeline (CEO-Gate)
    result = ams.submit_idea_to_pipeline(idea, project_slug="puzzleforge")
    assert result.get("gate_id"), f"No gate_id: {result}"

    return f"survey -> gap '{gaps[0].get('gap_description', '?')[:40]}' -> idea '{idea.get('app_name')}' -> gate={result['gate_id']}"


# == Runner ====================================================================

if __name__ == "__main__":
    print("\n=== Marketing End-to-End Test ===\n")

    tests = [
        ("Test 1: Full Cycle", test_01_full_marketing_cycle),
        ("Test 2: Feedback Loop", test_02_feedback_loop),
        ("Test 3: Knowledge Base", test_03_knowledge_base),
        ("Test 4: KPI Alert", test_04_kpi_alert),
        ("Test 5: Zwei-Stufen Review", test_05_zwei_stufen_review),
        ("Test 6: Cross-Platform Content", test_06_cross_platform_content),
        ("Test 7: Cost Tracking", test_07_cost_tracking),
        ("Test 8: Hook Library", test_08_hook_library),
        ("Test 9: Brand Compliance", test_09_brand_compliance),
        ("Test 10: Survey -> Idea -> Gate", test_10_survey_to_idea),
    ]

    for name, fn in tests:
        run_test(name, fn)

    print(f"\n=== E2E -- {passed}/{passed + failed} Tests Passed ===")

    # Cleanup temp DB + alerts
    import shutil
    try:
        os.unlink(_temp_db.name)
    except OSError:
        pass
    try:
        shutil.rmtree(_temp_alerts, ignore_errors=True)
    except OSError:
        pass

    if failed > 0:
        sys.exit(1)
