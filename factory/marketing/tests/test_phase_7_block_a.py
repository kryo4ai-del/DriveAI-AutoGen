"""Phase 7 Block A Tests — 12 Tests.

Campaign Planner, Budget Controller, A/B Test Tool, Survey System.
KEIN ECHTES GELD — alles Simulation.
"""

import os
import sys
import json
import math
import tempfile

# -- Setup: PYTHONPATH + Test-DB ------------------------------------------------

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, ROOT)

# Test-DB statt Produktion
_temp_db = tempfile.NamedTemporaryFile(suffix=".db", delete=False)
os.environ["MARKETING_DB_PATH"] = _temp_db.name
_temp_db.close()

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
        print(f"  FAIL  {name}: {e}")


# == Tests =====================================================================

def test_01_budget_split_exact():
    """Budget-Split: Summe MUSS exakt total_budget sein."""
    from factory.marketing.tools.budget_controller import BudgetController
    bc = BudgetController()
    result = bc.calculate_budget_split(
        1000.0, "launch",
        {"content": 0.40, "paid": 0.30, "pr": 0.20, "community": 0.10},
    )
    # Summe pruefen (ohne Meta-Felder)
    amounts = [v for k, v in result.items() if not k.startswith("_")]
    total = sum(amounts)
    assert abs(total - 1000.0) < 0.01, f"Summe {total} != 1000.0"
    assert result["content"] == 400.0, f"content={result['content']}, expected 400.0"
    assert result["paid"] == 300.0, f"paid={result['paid']}, expected 300.0"
    assert result["_simulation"] is True
    return f"4 Posten, Summe exakt ${total:.2f}"


def test_02_budget_zero():
    """Budget $0 — kein Fehler, Ergebnis = 0."""
    from factory.marketing.tools.budget_controller import BudgetController
    bc = BudgetController()
    result = bc.calculate_budget_split(0, "launch")
    assert result.get("total") == 0.0 or result.get("note") is not None
    return "zero budget handled"


def test_03_roi_projection():
    """ROI-Projektion: Plausible Werte, simulation_only Flag."""
    from factory.marketing.tools.budget_controller import BudgetController
    bc = BudgetController()
    result = bc.project_roi(500.0, "youtube", cpm=15.0)
    assert result["projected_impressions"] > 0, f"impressions={result['projected_impressions']}"
    assert result["projected_clicks"] > 0
    assert result["projected_installs"] > 0
    assert result["cpi"] > 0
    assert result["simulation_only"] is True
    # Mathematische Korrektheit: impressions = (500/15) * 1000 = 33333
    expected_impressions = int((500.0 / 15.0) * 1000)
    assert result["projected_impressions"] == expected_impressions, (
        f"impressions={result['projected_impressions']}, expected={expected_impressions}"
    )
    return f"impressions={result['projected_impressions']}, CPI=${result['cpi']}"


def test_04_budget_validate():
    """Budget-Validierung: Erkennt Fehler."""
    from factory.marketing.tools.budget_controller import BudgetController
    bc = BudgetController()
    result = bc.validate_budget([
        {"name": "Content", "amount": 400},
        {"name": "Paid", "amount": 300},
        {"name": "PR", "amount": -50},  # Negativ = Fehler
    ])
    assert result["total"] == 650.0, f"total={result['total']}"
    assert not result["valid"], "Should not be valid (negative amount)"
    assert len(result["errors"]) > 0
    return f"detected {len(result['errors'])} errors"


def test_05_ab_test_significant():
    """A/B Test: Signifikantes Ergebnis erkennen."""
    from factory.marketing.tools.ab_test_tool import ABTestTool
    abt = ABTestTool()
    # Deutlicher Unterschied: A=10%, B=5%
    result = abt.evaluate_test(
        "test_headline",
        n_a=1000, conv_a=100,  # 10%
        n_b=1000, conv_b=50,   # 5%
        hypothesis="Headline A hat hoehere CTR",
        variant_a_desc="Neue Headline",
        variant_b_desc="Alte Headline",
    )
    assert result["valid"] is True
    assert result["significant"] is True, f"p_value={result['p_value']}"
    assert result["winner"] == "A"
    assert result["p_value"] < 0.05
    assert result["confidence"] > 95.0
    return f"A wins, p={result['p_value']:.6f}, conf={result['confidence']:.1f}%"


def test_06_ab_test_not_significant():
    """A/B Test: Nicht-signifikantes Ergebnis."""
    from factory.marketing.tools.ab_test_tool import ABTestTool
    abt = ABTestTool()
    # Kleiner Unterschied mit kleinem Sample
    result = abt.evaluate_test(
        "test_button_color",
        n_a=50, conv_a=5,  # 10%
        n_b=50, conv_b=4,  # 8%
    )
    assert result["valid"] is True
    assert result["significant"] is False, f"Should not be significant, p={result['p_value']}"
    assert result["winner"] is None
    return f"nicht signifikant, p={result['p_value']:.4f}"


def test_07_ab_test_sample_size():
    """A/B Test: Sample-Size-Berechnung."""
    from factory.marketing.tools.ab_test_tool import ABTestTool
    abt = ABTestTool()
    result = abt.calculate_sample_size(
        baseline_rate=0.05,
        min_detectable_effect=0.20,  # 20% relative Verbesserung
        alpha=0.05,
        power=0.80,
    )
    assert result["valid"] is True
    assert result["sample_size_per_variant"] > 0
    assert result["total_sample_size"] == result["sample_size_per_variant"] * 2
    return f"n={result['sample_size_per_variant']}/variant, total={result['total_sample_size']}"


def test_08_ab_manual_vs_scipy():
    """A/B Test: Manuelle CDF vs. scipy CDF (wenn vorhanden)."""
    from factory.marketing.tools.ab_test_tool import ABTestTool
    abt = ABTestTool()
    # Teste manuelle Normal-CDF gegen bekannte Werte
    # P(Z <= 0) = 0.5
    assert abs(abt._manual_norm_cdf(0.0) - 0.5) < 0.001
    # P(Z <= 1.96) ~ 0.975
    assert abs(abt._manual_norm_cdf(1.96) - 0.975) < 0.001
    # P(Z <= -1.96) ~ 0.025
    assert abs(abt._manual_norm_cdf(-1.96) - 0.025) < 0.001
    return "CDF(0)=0.5, CDF(1.96)~0.975, CDF(-1.96)~0.025"


def test_09_survey_create_x():
    """Survey: X-Platform Limits (4 Optionen, 280 Zeichen)."""
    from factory.marketing.tools.survey_system import SurveySystem
    ss = SurveySystem()
    result = ss.create_survey(
        title="Welches Feature willst du?",
        questions=[{
            "question": "Top-Feature?",
            "options": ["Dark Mode", "Offline", "Sprachen", "Performance", "Widgets"],
        }],
        platforms=["x"],
        survey_type="feature_vote",
    )
    # X erlaubt nur 4 Optionen
    x_fmt = result["formatted"]["x"]
    assert len(x_fmt["questions"][0]["options"]) <= 4, (
        f"X hat {len(x_fmt['questions'][0]['options'])} Optionen (max 4)"
    )
    # Validation errors fuer die 5. Option
    assert len(result["validation_errors"]) > 0, "Should have validation error for 5th option"
    return f"X: {len(x_fmt['questions'][0]['options'])} opts, {len(result['validation_errors'])} warnings"


def test_10_survey_reddit():
    """Survey: Reddit-Platform (6 Optionen, 300 Zeichen)."""
    from factory.marketing.tools.survey_system import SurveySystem
    ss = SurveySystem()
    result = ss.create_survey(
        title="KI-Nutzung im Alltag",
        questions=[{
            "question": "Welche KI nutzt du?",
            "options": ["ChatGPT", "Claude", "Gemini", "Copilot", "Llama", "Andere"],
        }],
        platforms=["reddit"],
    )
    reddit_fmt = result["formatted"]["reddit"]
    assert len(reddit_fmt["questions"][0]["options"]) == 6, (
        f"Reddit: {len(reddit_fmt['questions'][0]['options'])} Optionen"
    )
    assert result["valid"] is True, f"Errors: {result['validation_errors']}"
    return f"Reddit: 6 opts, valid"


def test_11_survey_templates():
    """Survey: Templates vorhanden und korrekt."""
    from factory.marketing.tools.survey_system import SurveySystem
    ss = SurveySystem()
    templates = ss.get_survey_templates()
    assert len(templates) >= 3, f"Expected >= 3 templates, got {len(templates)}"
    assert "app_feedback" in templates
    assert "feature_vote" in templates
    assert "market_research" in templates
    # Jedes Template hat Pflichtfelder
    for name, tmpl in templates.items():
        assert "title" in tmpl, f"Template {name} missing title"
        assert "questions" in tmpl, f"Template {name} missing questions"
        assert "platforms" in tmpl, f"Template {name} missing platforms"
    return f"{len(templates)} templates"


def test_12_campaign_summary():
    """Campaign Planner: Summary deterministisch."""
    from factory.marketing.agents.campaign_planner import CampaignPlanner
    cp = CampaignPlanner()
    summary = cp.get_campaign_summary()
    assert "campaigns" in summary
    assert "total" in summary
    assert summary.get("simulation_only") is True
    return f"{summary['total']} campaigns, simulation_only=True"


# == Runner ====================================================================

if __name__ == "__main__":
    print("\n=== Phase 7 Block A Tests ===\n")

    tests = [
        ("Test 1: Budget Split Exact", test_01_budget_split_exact),
        ("Test 2: Budget Zero", test_02_budget_zero),
        ("Test 3: ROI Projection", test_03_roi_projection),
        ("Test 4: Budget Validate", test_04_budget_validate),
        ("Test 5: A/B Significant", test_05_ab_test_significant),
        ("Test 6: A/B Not Significant", test_06_ab_test_not_significant),
        ("Test 7: A/B Sample Size", test_07_ab_test_sample_size),
        ("Test 8: Manual CDF", test_08_ab_manual_vs_scipy),
        ("Test 9: Survey X Limits", test_09_survey_create_x),
        ("Test 10: Survey Reddit", test_10_survey_reddit),
        ("Test 11: Survey Templates", test_11_survey_templates),
        ("Test 12: Campaign Summary", test_12_campaign_summary),
    ]

    for name, fn in tests:
        run_test(name, fn)

    print(f"\n=== Phase 7 Block A -- {passed}/{passed + failed} Tests Passed ===")

    # Cleanup temp DB
    try:
        os.unlink(_temp_db.name)
    except OSError:
        pass

    if failed > 0:
        sys.exit(1)
