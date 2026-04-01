"""Phase 8 Block A Integration Tests — 10 Tests.

Feedback-Loop, Knowledge Base, Cost Reporter, Pipeline Runner.
KEIN ECHTES GELD — alles Simulation.
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

def test_01_db_tables():
    """DB: Neue Tabellen feedback_tasks, marketing_knowledge, pipeline_runs."""
    from factory.marketing.tools.ranking_database import RankingDatabase
    db = RankingDatabase()
    stats = db.get_db_stats()
    tables = stats["tables"]
    # Neue 3 Tabellen
    assert "feedback_tasks" in tables, f"feedback_tasks nicht in {list(tables.keys())}"
    assert "marketing_knowledge" in tables, f"marketing_knowledge nicht in {list(tables.keys())}"
    assert "pipeline_runs" in tables, f"pipeline_runs nicht in {list(tables.keys())}"
    # Bestehende 17 noch da
    assert "keyword_rankings" in tables
    assert "post_performance" in tables
    assert "ab_tests" in tables
    assert "surveys" in tables
    total_tables = len(tables)
    assert total_tables == 20, f"Expected 20 tables, got {total_tables}"
    return f"{total_tables} tables OK, 3 new confirmed"


def test_02_feedback_analyze():
    """Feedback-Loop: Analyze and Route mit Test-Daten."""
    from factory.marketing.tools.ranking_database import RankingDatabase
    from factory.marketing.tools.feedback_loop import MarketingFeedbackLoop

    db = RankingDatabase()
    # Fuege Test-Daten hinzu: Posts mit verschiedenen Engagement-Werten
    for i in range(10):
        db.store_post_performance(
            platform="tiktok",
            post_id=f"test_post_{i}",
            content_type="video",
            metrics={
                "impressions": 1000 + i * 500,
                "engagements": 50 + i * 100,  # 50..950
                "likes": 30 + i * 50,
                "shares": 5 + i * 10,
                "comments": 2 + i * 5,
            },
        )

    fl = MarketingFeedbackLoop()
    result = fl.analyze_and_route(period_days=30)

    assert result["period_days"] == 30
    assert result["insights_found"] >= 1, f"No insights found"
    assert result["tasks_created"] >= 1, f"No tasks created"
    assert len(result["tasks"]) >= 1

    # Pruefe dass Tasks korrekte Agents haben
    for task in result["tasks"]:
        assert task["target_agent"].startswith("MKT-"), f"Bad agent: {task['target_agent']}"

    return f"{result['insights_found']} insights, {result['tasks_created']} tasks"


def test_03_feedback_lifecycle():
    """Feedback-Loop: Task Lifecycle open → executed."""
    from factory.marketing.tools.feedback_loop import MarketingFeedbackLoop

    fl = MarketingFeedbackLoop()
    task_id = fl.create_feedback_task(
        "content_underperform",
        "Fakten-Hooks underperformen auf TikTok",
        {"avg_engagement": 50, "platform": "tiktok"},
        priority="medium",
    )
    assert task_id.startswith("FB-"), f"Bad task_id: {task_id}"

    # Pruefe: Task in DB mit status=open
    open_tasks = fl.get_open_tasks()
    found = any(t["task_id"] == task_id for t in open_tasks)
    assert found, f"Task {task_id} not in open tasks"

    # Execute
    success = fl.track_feedback_execution(task_id, "Switched to question hooks")
    assert success is True, "track_feedback_execution failed"

    # Pruefe: nicht mehr in open tasks
    open_tasks_after = fl.get_open_tasks()
    still_open = any(t["task_id"] == task_id for t in open_tasks_after)
    assert not still_open, f"Task {task_id} still open after execution"

    return f"task={task_id}, open → executed"


def test_04_knowledge_auto_promotion():
    """Knowledge Base: Add + Auto-Promotion hypothesis → confirmed → established."""
    from factory.marketing.tools.marketing_knowledge import MarketingKnowledgeBase

    kb = MarketingKnowledgeBase()
    kid = kb.add_knowledge(
        "content_insights",
        "Test-Insight: Frage-Hooks performen 40% besser auf TikTok",
        "Phase 2 Test-Daten",
    )
    assert kid > 0, f"Bad knowledge_id: {kid}"

    # Erste Beobachtung: hypothesis
    entries = kb.db.get_knowledge(limit=100)
    entry = [e for e in entries if e["id"] == kid][0]
    assert entry["confidence"] == "hypothesis", f"Expected hypothesis, got {entry['confidence']}"

    # 2. Beobachtung → confirmed
    r = kb.confirm_knowledge(kid)
    assert r["confidence"] == "confirmed", f"Expected confirmed, got {r['confidence']}"
    assert r["observations_count"] == 2, f"Expected 2, got {r['observations_count']}"

    # 3., 4., 5. Beobachtung → established bei 5
    for _ in range(3):
        r = kb.confirm_knowledge(kid)

    assert r["confidence"] == "established", f"Expected established, got {r['confidence']}"
    assert r["observations_count"] == 5, f"Expected 5, got {r['observations_count']}"

    return f"id={kid}: hypothesis → confirmed → established (count={r['observations_count']})"


def test_05_knowledge_agent_query():
    """Knowledge Base: Agent-Abfrage mit korrekten Kategorien."""
    from factory.marketing.tools.marketing_knowledge import MarketingKnowledgeBase

    kb = MarketingKnowledgeBase()

    # Fuege Wissen in verschiedene Kategorien
    kb.add_knowledge("content_insights", "Video-Format performt besser als Bild", "Test")
    kb.add_knowledge("audience_insights", "Zielgruppe 18-34 bevorzugt Short-Form", "Test")
    kb.add_knowledge("cost_insights", "LLM-Kosten pro Run: $0.08", "Test")
    kb.add_knowledge("competitive_insights", "Konkurrent X hat neue Features", "Test")

    # MKT-03 (Copywriter) bekommt content_insights + audience_insights
    mkt03 = kb.get_knowledge_for_agent("MKT-03")
    categories = set(e["category"] for e in mkt03)
    assert "content_insights" in categories or "audience_insights" in categories, \
        f"MKT-03 wrong categories: {categories}"

    # MKT-14 (Campaign Planner) bekommt cost + audience + competitive
    mkt14 = kb.get_knowledge_for_agent("MKT-14")
    categories14 = set(e["category"] for e in mkt14)
    # Mindestens eine der erwarteten Kategorien
    expected = {"cost_insights", "audience_insights", "competitive_insights"}
    overlap = categories14 & expected
    assert len(overlap) >= 1, f"MKT-14 missing categories: got {categories14}"

    # Agent ohne Mapping bekommt leere Liste
    unknown = kb.get_knowledge_for_agent("MKT-99")
    assert unknown == [], f"Unknown agent should get empty, got {len(unknown)}"

    return f"MKT-03: {len(mkt03)} insights ({categories}), MKT-14: {len(mkt14)} insights ({categories14})"


def test_06_knowledge_seed():
    """Knowledge Base: Seed initiales Wissen."""
    from factory.marketing.tools.marketing_knowledge import MarketingKnowledgeBase

    kb = MarketingKnowledgeBase()
    count = kb.seed_initial_knowledge()
    assert count >= 5, f"Expected >= 5 seeded, got {count}"

    stats = kb.get_knowledge_stats()
    assert stats["total"] >= count, f"total {stats['total']} < seeded {count}"

    # Prüfe Verteilung: mindestens 3 verschiedene Kategorien
    cats = stats.get("by_category", {})
    assert len(cats) >= 3, f"Only {len(cats)} categories seeded: {list(cats.keys())}"

    return f"{count} entries seeded, {len(cats)} categories: {dict(cats)}"


def test_07_cost_calculate():
    """Cost Reporter: Calculate Marketing Costs."""
    from factory.marketing.tools.cost_reporter import MarketingCostReporter

    cr = MarketingCostReporter()
    result = cr.calculate_marketing_costs("echomatch")

    assert result["total"] > 0, f"total={result['total']}"
    assert result["source"] in ("estimated", "live"), f"source={result['source']}"
    assert result["currency"] == "USD"
    assert "llm_costs" in result
    assert "research_costs" in result
    assert result["project_slug"] == "echomatch"

    return f"total=${result['total']:.4f} (source: {result['source']})"


def test_08_factory_vs_market():
    """Cost Reporter: Factory vs. Market — Factory deutlich guenstiger."""
    from factory.marketing.tools.cost_reporter import MarketingCostReporter

    cr = MarketingCostReporter()
    result = cr.compare_factory_vs_market()

    factory_total = result["factory"]["total"]
    market_total = result["market"]["total"]

    assert factory_total < market_total, \
        f"Factory ({factory_total}) >= Market ({market_total})"
    assert result["savings_percent"] > 90, \
        f"savings_percent={result['savings_percent']}% (expected >90%)"
    assert result["savings_absolute"] > 0

    return f"Factory: ${factory_total:.2f} vs Market: ${market_total:,.0f} — savings {result['savings_percent']:.1f}%"


def test_09_pipeline_full_cycle():
    """Pipeline Runner: Full Cycle — graceful failures (mocked agents)."""
    from factory.marketing.tools.pipeline_runner import MarketingPipelineRunner

    pr = MarketingPipelineRunner()

    # Mock _execute_step: simuliert dass einige Steps klappen, einige fehlschlagen
    _call_count = {"n": 0}
    def _mock_execute(step, project_slug, dry_run):
        _call_count["n"] += 1
        sn = step["number"]
        # Simuliere: Steps 1-8 OK, Step 9 failt, Steps 10-12 OK
        if sn == 9:
            raise RuntimeError("Mock: brand check failed (no brand book)")
        return f"/mock/output/{project_slug}/step_{sn}.md"

    pr._execute_step = _mock_execute
    result = pr.run_full_cycle("echomatch", dry_run=True)

    assert result["steps_total"] == 12, f"steps_total={result['steps_total']}"
    assert result["project_slug"] == "echomatch"

    # 11 completed, 1 failed (Step 9)
    assert result["steps_completed"] == 11, f"completed={result['steps_completed']}"
    assert result["steps_failed"] == 1, f"failed={result['steps_failed']}"
    assert result["steps_completed"] + result["steps_failed"] == 12

    # Jeder Step hat ein Detail-Entry
    assert len(result["details"]) == 12, f"details count={len(result['details'])}"

    # Step 9 ist der failed Step
    step9 = [d for d in result["details"] if d["step"] == 9][0]
    assert step9["status"] == "failed"
    assert "Mock" in step9["error"]

    # Duration wurde gemessen
    assert result["duration_seconds"] >= 0

    # Pipeline-Runs in DB gespeichert
    runs = pr.db.get_pipeline_runs("echomatch")
    assert len(runs) >= 12, f"DB runs={len(runs)} (expected >= 12)"

    return f"{result['steps_completed']}/12 completed, {result['steps_failed']} failed, {result['duration_seconds']:.1f}s"


def test_10_pipeline_status_report():
    """Pipeline Runner: Status + Report."""
    from factory.marketing.tools.pipeline_runner import MarketingPipelineRunner

    pr = MarketingPipelineRunner()

    # Status abrufen (basiert auf Test 9 Daten)
    status = pr.get_pipeline_status("echomatch")
    assert status["steps_total"] == 12
    assert len(status["steps"]) == 12

    # Report erstellen
    report_path = pr.create_pipeline_report("echomatch")
    assert os.path.exists(report_path), f"Report not found: {report_path}"

    # Report lesen und pruefen
    with open(report_path, "r", encoding="utf-8") as f:
        content = f.read()
    assert "echomatch" in content
    assert "Pipeline Report" in content

    return f"Status: {status['completed']} completed, Report: {os.path.basename(report_path)}"


# == Runner ====================================================================

if __name__ == "__main__":
    print("\n=== Phase 8 Block A Integration Tests ===\n")

    tests = [
        ("Test 1: DB Tables", test_01_db_tables),
        ("Test 2: Feedback Analyze", test_02_feedback_analyze),
        ("Test 3: Feedback Lifecycle", test_03_feedback_lifecycle),
        ("Test 4: Knowledge Auto-Promotion", test_04_knowledge_auto_promotion),
        ("Test 5: Knowledge Agent Query", test_05_knowledge_agent_query),
        ("Test 6: Knowledge Seed", test_06_knowledge_seed),
        ("Test 7: Cost Calculate", test_07_cost_calculate),
        ("Test 8: Factory vs Market", test_08_factory_vs_market),
        ("Test 9: Pipeline Full Cycle", test_09_pipeline_full_cycle),
        ("Test 10: Pipeline Report", test_10_pipeline_status_report),
    ]

    for name, fn in tests:
        run_test(name, fn)

    print(f"\n=== Phase 8 Block A — {passed}/{passed + failed} Tests Passed ===")

    # Cleanup temp DB
    try:
        os.unlink(_temp_db.name)
    except OSError:
        pass

    if failed > 0:
        sys.exit(1)
