"""Phase 7 Integration Tests — 12 Tests.

Campaign Planner, Budget Controller, A/B Test Tool, Survey System, Ad-Platform Stubs.
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

def test_01_campaign_plan():
    """Campaign Planner: Launch-Plan mit Phasen und Budget."""
    from factory.marketing.agents.campaign_planner import CampaignPlanner
    cp = CampaignPlanner()
    # get_campaign_summary ist deterministisch (kein LLM noetig)
    summary = cp.get_campaign_summary("echomatch")
    assert "campaigns" in summary
    assert summary.get("simulation_only") is True
    # Pruefe dass available_channels funktioniert
    channels = cp._get_available_channels()
    assert len(channels) > 0, "No channels available"
    # Pruefe factory facts
    facts = cp._get_factory_facts()
    assert facts["agents_total"] > 0, f"agents_total={facts['agents_total']}"
    assert facts["marketing_agents"] >= 14, f"marketing_agents={facts['marketing_agents']}"
    return f"channels={len(channels)}, agents={facts['agents_total']}, mkt={facts['marketing_agents']}"


def test_02_budget_split_launch():
    """Budget Split: Launch-Kampagne, 4 Kanaele, Summe exakt."""
    from factory.marketing.tools.budget_controller import BudgetController
    bc = BudgetController()
    result = bc.calculate_budget_split(
        10000.0, "launch",
        {"content": 0.35, "paid": 0.35, "pr": 0.20, "community": 0.10},
    )
    amounts = [v for k, v in result.items() if not k.startswith("_")]
    total = sum(amounts)
    assert abs(total - 10000.0) < 0.01, f"Summe {total} != 10000.0"
    assert result["content"] == 3500.0, f"content={result['content']}"
    assert result["paid"] == 3500.0, f"paid={result['paid']}"
    assert result["pr"] == 2000.0, f"pr={result['pr']}"
    assert result["community"] == 1000.0, f"community={result['community']}"
    return f"4 Posten, Summe exakt ${total:.2f}"


def test_03_budget_validate():
    """Budget Validierung: Summe korrekt, Fehler erkannt."""
    from factory.marketing.tools.budget_controller import BudgetController
    bc = BudgetController()
    result = bc.validate_budget([
        {"name": "Content", "amount": 5000},
        {"name": "Paid", "amount": 3000},
        {"name": "PR", "amount": 1500},
        {"name": "Community", "amount": 500},
    ])
    assert result["total"] == 10000.0, f"total={result['total']}"
    assert result["valid"] is True
    assert result["item_count"] == 4
    return f"total=${result['total']:.2f}, valid, {result['item_count']} items"


def test_04_roi_correct():
    """ROI: Mathematisch korrekte Berechnung."""
    from factory.marketing.tools.budget_controller import BudgetController
    bc = BudgetController()
    # compare_campaigns nutzt project_roi intern
    result = bc.compare_campaigns([
        {"name": "YouTube", "budget": 5000, "channel": "youtube"},
        {"name": "TikTok", "budget": 3000, "channel": "tiktok"},
        {"name": "X", "budget": 2000, "channel": "x"},
    ])
    assert result["total_budget"] == 10000.0, f"total_budget={result['total_budget']}"
    assert result["total_projected_installs"] > 0
    assert result["simulation_only"] is True
    # Best channel should be one of the three
    assert result["best_channel"] in ["youtube", "tiktok", "x"]
    return f"total=${result['total_budget']:.2f}, installs={result['total_projected_installs']}, best={result['best_channel']}"


def test_05_roi_projection():
    """ROI Projection: Spezifische Berechnung pruefen."""
    from factory.marketing.tools.budget_controller import BudgetController
    bc = BudgetController()
    result = bc.project_roi(3000.0, "tiktok", cpm=10.0)
    # impressions = (3000/10) * 1000 = 300000
    assert result["projected_impressions"] == 300000, f"impressions={result['projected_impressions']}"
    # clicks = 300000 * 0.02 = 6000
    assert result["projected_clicks"] == 6000, f"clicks={result['projected_clicks']}"
    # installs = 6000 * 0.05 = 300
    assert result["projected_installs"] == 300, f"installs={result['projected_installs']}"
    # cpi = 3000/300 = 10.0
    assert result["cpi"] == 10.0, f"cpi={result['cpi']}"
    assert result["simulation_only"] is True
    return f"impressions={result['projected_impressions']}, installs={result['projected_installs']}, CPI=${result['cpi']}"


def test_06_simulation():
    """Simulation: daily_budget * days = total spend."""
    from factory.marketing.tools.budget_controller import BudgetController
    bc = BudgetController()
    daily_budget = 100.0
    cpi = 2.0
    days = 30
    total_spend = daily_budget * days  # 3000
    installs = int(total_spend / cpi)  # 1500
    assert total_spend == 3000.0
    assert installs == 1500
    # Validate via budget tool
    result = bc.validate_budget([
        {"name": f"Day {i+1}", "amount": daily_budget} for i in range(days)
    ])
    assert result["total"] == 3000.0, f"total={result['total']}"
    assert result["valid"] is True
    return f"spend=${total_spend}, installs={installs}, validated"


def test_07_sample_size():
    """A/B Test: Sample-Size-Berechnung plausibel."""
    from factory.marketing.tools.ab_test_tool import ABTestTool
    abt = ABTestTool()
    result = abt.calculate_sample_size(
        baseline_rate=0.05,
        min_detectable_effect=0.20,
        alpha=0.05,
        power=0.80,
    )
    assert result["valid"] is True
    n = result["sample_size_per_variant"]
    # Plausibel: zwischen 3000 und 15000
    assert 3000 <= n <= 15000, f"n={n} ausserhalb plausibler Range"
    assert result["total_sample_size"] == n * 2
    return f"n={n}/variant, total={result['total_sample_size']}"


def test_08_ab_significant():
    """A/B Test: 600/10000 vs 500/10000 — signifikant."""
    from factory.marketing.tools.ab_test_tool import ABTestTool
    abt = ABTestTool()
    result = abt.evaluate_test(
        "cta_headline",
        n_a=10000, conv_a=600,   # 6.0%
        n_b=10000, conv_b=500,   # 5.0%
        hypothesis="Neue Headline hat hoehere CTR",
        variant_a_desc="Neue Headline",
        variant_b_desc="Alte Headline",
    )
    assert result["valid"] is True
    assert result["significant"] is True, f"p_value={result['p_value']}"
    assert result["winner"] == "A"
    assert result["p_value"] < 0.05
    return f"A wins, p={result['p_value']:.6f}, conf={result['confidence']:.1f}%"


def test_09_ab_not_significant():
    """A/B Test: 505/10000 vs 500/10000 — nicht signifikant."""
    from factory.marketing.tools.ab_test_tool import ABTestTool
    abt = ABTestTool()
    result = abt.evaluate_test(
        "button_color",
        n_a=10000, conv_a=505,   # 5.05%
        n_b=10000, conv_b=500,   # 5.00%
    )
    assert result["valid"] is True
    assert result["significant"] is False, f"Should not be significant, p={result['p_value']}"
    assert result["winner"] is None
    return f"nicht signifikant, p={result['p_value']:.4f}"


def test_10_survey_limits():
    """Survey: 5 Optionen → X max 4, Reddit max 6."""
    from factory.marketing.tools.survey_system import SurveySystem
    ss = SurveySystem()
    result = ss.create_survey(
        title="Feature-Wunsch",
        questions=[{
            "question": "Welches Feature?",
            "options": ["Dark Mode", "Offline", "Sprachen", "Performance", "Widgets"],
        }],
        platforms=["x", "reddit"],
        survey_type="feature_vote",
    )
    # X: max 4 Optionen
    x_opts = result["formatted"]["x"]["questions"][0]["options"]
    assert len(x_opts) <= 4, f"X: {len(x_opts)} Optionen (max 4)"
    # Reddit: max 6 — 5 sollten passen
    reddit_opts = result["formatted"]["reddit"]["questions"][0]["options"]
    assert len(reddit_opts) == 5, f"Reddit: {len(reddit_opts)} Optionen (erwartet 5)"
    # X sollte Validation Error haben (5 > 4)
    x_errors = [e for e in result["validation_errors"] if "[x]" in e]
    assert len(x_errors) > 0, "X sollte Validation Error fuer 5. Option haben"
    return f"X: {len(x_opts)} opts (limit ok), Reddit: {len(reddit_opts)} opts, {len(x_errors)} warnings"


def test_11_survey_templates():
    """Survey: Templates + Platform Limits vorhanden."""
    from factory.marketing.tools.survey_system import SurveySystem
    ss = SurveySystem()
    templates = ss.get_survey_templates()
    assert len(templates) >= 3
    limits = ss.get_platform_limits()
    assert "x" in limits
    assert "reddit" in limits
    assert "youtube" in limits
    assert limits["x"]["max_options"] == 4
    assert limits["reddit"]["max_options"] == 6
    assert limits["youtube"]["max_options"] == 4
    return f"{len(templates)} templates, {len(limits)} platforms"


def test_12_ad_stubs():
    """Ad-Platform Stubs: 4/4 importierbar, stub_phase1, keine Credential-Errors."""
    from factory.marketing.adapters.meta_ads_adapter import MetaAdsAdapter
    from factory.marketing.adapters.google_ads_adapter import GoogleAdsAdapter
    from factory.marketing.adapters.tiktok_ads_adapter import TikTokAdsAdapter
    from factory.marketing.adapters.apple_search_ads_adapter import AppleSearchAdsAdapter
    from factory.marketing.adapters import AD_PLATFORM_STUBS

    assert len(AD_PLATFORM_STUBS) == 4, f"Expected 4 stubs, got {len(AD_PLATFORM_STUBS)}"

    stubs = [MetaAdsAdapter, GoogleAdsAdapter, TikTokAdsAdapter, AppleSearchAdsAdapter]
    platforms = []

    for cls in stubs:
        assert cls.STATUS == "stub_phase1", f"{cls.__name__}.STATUS={cls.STATUS}"
        # Instanz erstellen — darf NICHT fehlschlagen (keine Credential-Checks)
        instance = cls()
        assert instance.dry_run is True, f"{cls.__name__}.dry_run={instance.dry_run}"
        # create_campaign muss stub=True zurueckgeben
        result = instance.create_campaign("test", "installs", 100, {}, [])
        assert result["stub"] is True, f"{cls.__name__}.create_campaign.stub={result.get('stub')}"
        platforms.append(instance.PLATFORM)

    return f"4/4 imported: {', '.join(platforms)}, all stub_phase1"


# == Runner ====================================================================

if __name__ == "__main__":
    print("\n=== Phase 7 Integration Tests ===\n")

    tests = [
        ("Test 1: Campaign Plan", test_01_campaign_plan),
        ("Test 2: Budget Split Launch", test_02_budget_split_launch),
        ("Test 3: Budget Validate", test_03_budget_validate),
        ("Test 4: ROI Compare", test_04_roi_correct),
        ("Test 5: ROI Projection", test_05_roi_projection),
        ("Test 6: Simulation", test_06_simulation),
        ("Test 7: Sample Size", test_07_sample_size),
        ("Test 8: A/B Significant", test_08_ab_significant),
        ("Test 9: A/B Not Significant", test_09_ab_not_significant),
        ("Test 10: Survey Limits", test_10_survey_limits),
        ("Test 11: Survey Templates", test_11_survey_templates),
        ("Test 12: Ad Stubs", test_12_ad_stubs),
    ]

    for name, fn in tests:
        run_test(name, fn)

    print(f"\n=== Phase 7 Integration -- {passed}/{passed + failed} Tests Passed ===")

    # Cleanup temp DB
    try:
        os.unlink(_temp_db.name)
    except OSError:
        pass

    if failed > 0:
        sys.exit(1)
