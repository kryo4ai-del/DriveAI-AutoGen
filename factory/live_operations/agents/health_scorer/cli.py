"""Health Scorer CLI — manuelles Scoring und Simulation.

Usage:
    python -m factory.live_operations.agents.health_scorer.cli --app <app_id>
    python -m factory.live_operations.agents.health_scorer.cli --all
    python -m factory.live_operations.agents.health_scorer.cli --simulate --profile gaming
"""

import argparse
import json
import sys

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.agents.health_scorer.scorer import AppHealthScorer
from factory.live_operations.agents.health_scorer.profiles import PROFILES, DEFAULT_PROFILE
from factory.live_operations.agents.metrics_collector.collector import MetricsCollector

_PREFIX = "[Health Scorer CLI]"


def _mock_metrics(profile: str) -> dict:
    """Generiert realistische Mock-Metriken fuer Simulation."""
    # Base metrics that vary by profile
    configs = {
        "gaming": {
            "crash_rate": 1.2, "anr_rate": 0.3, "rating_average": 4.2,
            "rating_trend": 0.1, "downloads_period": 5000, "downloads_total": 200000,
            "revenue_period": 15000.0, "revenue_trend": 0.05,
            "dau": 8000, "mau": 25000, "dau_mau_ratio": 0.32,
            "session_count_period": 45000, "avg_session_length_seconds": 420.0,
            "retention_day1": 45.0, "retention_day7": 25.0, "retention_day30": 12.0,
            "arpu": 2.50, "conversion_rate": 5.0,
        },
        "education": {
            "crash_rate": 0.5, "anr_rate": 0.1, "rating_average": 4.5,
            "rating_trend": 0.05, "downloads_period": 2000, "downloads_total": 80000,
            "revenue_period": 3000.0, "revenue_trend": 0.02,
            "dau": 3000, "mau": 15000, "dau_mau_ratio": 0.20,
            "session_count_period": 12000, "avg_session_length_seconds": 300.0,
            "retention_day1": 40.0, "retention_day7": 22.0, "retention_day30": 15.0,
            "arpu": 1.00, "conversion_rate": 3.0,
        },
        "utility": {
            "crash_rate": 0.2, "anr_rate": 0.05, "rating_average": 4.0,
            "rating_trend": -0.1, "downloads_period": 3000, "downloads_total": 150000,
            "revenue_period": 5000.0, "revenue_trend": -0.03,
            "dau": 5000, "mau": 30000, "dau_mau_ratio": 0.167,
            "session_count_period": 20000, "avg_session_length_seconds": 90.0,
            "retention_day1": 35.0, "retention_day7": 20.0, "retention_day30": 10.0,
            "arpu": 0.80, "conversion_rate": 4.0,
        },
        "content": {
            "crash_rate": 0.8, "anr_rate": 0.2, "rating_average": 3.8,
            "rating_trend": -0.05, "downloads_period": 8000, "downloads_total": 100000,
            "revenue_period": 8000.0, "revenue_trend": 0.10,
            "dau": 6000, "mau": 18000, "dau_mau_ratio": 0.33,
            "session_count_period": 30000, "avg_session_length_seconds": 350.0,
            "retention_day1": 38.0, "retention_day7": 18.0, "retention_day30": 8.0,
            "arpu": 1.50, "conversion_rate": 6.0,
        },
        "subscription": {
            "crash_rate": 0.3, "anr_rate": 0.1, "rating_average": 4.3,
            "rating_trend": 0.02, "downloads_period": 1500, "downloads_total": 60000,
            "revenue_period": 20000.0, "revenue_trend": 0.08,
            "dau": 4000, "mau": 20000, "dau_mau_ratio": 0.20,
            "session_count_period": 16000, "avg_session_length_seconds": 200.0,
            "retention_day1": 42.0, "retention_day7": 28.0, "retention_day30": 18.0,
            "arpu": 3.50, "conversion_rate": 8.0,
        },
    }

    cfg = configs.get(profile, configs["utility"])

    return {
        "store_metrics": {
            "downloads_total": cfg["downloads_total"],
            "downloads_period": cfg["downloads_period"],
            "rating_average": cfg["rating_average"],
            "rating_count": 500,
            "rating_trend": cfg["rating_trend"],
            "revenue_period": cfg["revenue_period"],
            "revenue_trend": cfg["revenue_trend"],
            "crash_rate": cfg["crash_rate"],
            "anr_rate": cfg["anr_rate"],
        },
        "firebase_metrics": {
            "dau": cfg["dau"],
            "mau": cfg["mau"],
            "dau_mau_ratio": cfg["dau_mau_ratio"],
            "session_count_period": cfg["session_count_period"],
            "avg_session_length_seconds": cfg["avg_session_length_seconds"],
            "retention_day1": cfg["retention_day1"],
            "retention_day7": cfg["retention_day7"],
            "retention_day30": cfg["retention_day30"],
            "feature_usage": {},
            "funnel_completion": {},
            "arpu": cfg["arpu"],
            "conversion_rate": cfg["conversion_rate"],
            "crash_free_sessions_pct": 100.0 - cfg["crash_rate"],
            "crash_free_users_pct": 100.0 - cfg["crash_rate"] * 0.8,
        },
    }


def _print_score_detail(result: dict) -> None:
    """Detaillierte Score-Anzeige."""
    if not result or "error" in result:
        print(f"  Fehler: {result.get('error', 'unbekannt')}")
        return

    zone_icon = {"green": "🟢", "yellow": "🟡", "red": "🔴"}.get(result["zone"], "⚪")

    print(f"\n  App:     {result.get('app_name', result['app_id'])}")
    print(f"  Profil:  {result['profile']}")
    print(f"  Score:   {result['overall_score']} {zone_icon} ({result['zone']})")
    print(f"  Zeit:    {result['scored_at']}")
    print()
    print("  Kategorie-Breakdown:")
    print("  " + "-" * 55)
    for cat, data in result["category_scores"].items():
        bar_len = int(data["score"] / 5)
        bar = "█" * bar_len + "░" * (20 - bar_len)
        print(f"  {cat:15s} {data['score']:6.1f}  x{data['weight']:.2f}  = {data['weighted']:6.2f}  {bar}")
    print("  " + "-" * 55)
    print(f"  {'GESAMT':15s} {result['overall_score']:6.1f}")

    if result.get("alerts"):
        print(f"\n  ⚠ Alerts ({len(result['alerts'])}):")
        for alert in result["alerts"]:
            print(f"    - [{alert['category']}] {alert['message']}")


def cmd_simulate(profile: str) -> None:
    """Simulation mit Mock-Metriken."""
    print(f"{_PREFIX} Simulation mit Profil '{profile}'")

    if profile not in PROFILES:
        print(f"{_PREFIX} Unbekanntes Profil: {profile}. Verfuegbar: {', '.join(PROFILES.keys())}")
        return

    # Create temp app in DB for simulation
    import tempfile
    import os
    db_path = os.path.join(tempfile.gettempdir(), "health_scorer_sim.db")
    db = AppRegistryDB(db_path=db_path)

    app_id = db.add_app({
        "app_name": f"Simulation ({profile})",
        "app_profile": profile,
        "bundle_id": f"com.dai.sim.{profile}",
    })

    scorer = AppHealthScorer(registry_db=db)
    metrics = _mock_metrics(profile)

    print(f"\n  Mock-Metriken:")
    print(f"  Store:    crash={metrics['store_metrics']['crash_rate']}%, "
          f"rating={metrics['store_metrics']['rating_average']}, "
          f"downloads={metrics['store_metrics']['downloads_period']}/7d")
    print(f"  Firebase: DAU={metrics['firebase_metrics']['dau']}, "
          f"DAU/MAU={metrics['firebase_metrics']['dau_mau_ratio']}, "
          f"ARPU=${metrics['firebase_metrics']['arpu']}")

    result = scorer.score_app(app_id, metrics)
    _print_score_detail(result)

    # Cleanup
    os.unlink(db_path)


def cmd_score_app(app_id: str) -> None:
    """Score fuer eine einzelne App."""
    db = AppRegistryDB()
    app = db.get_app(app_id)
    if not app:
        print(f"{_PREFIX} App '{app_id}' nicht gefunden.")
        return

    collector = MetricsCollector(registry_db=db)
    metrics = collector.collect_for_app(app_id)

    scorer = AppHealthScorer(registry_db=db)
    result = scorer.score_app(app_id, metrics)
    _print_score_detail(result)


def cmd_score_all() -> None:
    """Score fuer alle Apps."""
    db = AppRegistryDB()
    apps = db.get_all_apps()
    if not apps:
        print(f"{_PREFIX} Keine Apps in der Registry.")
        return

    collector = MetricsCollector(registry_db=db)
    all_metrics = collector.collect_all()

    scorer = AppHealthScorer(registry_db=db)
    results = scorer.score_all(all_metrics)

    print(f"\n{_PREFIX} Ergebnisse fuer {results['total']} Apps:")
    for app_id, result in results["results"].items():
        _print_score_detail(result)


def main() -> None:
    parser = argparse.ArgumentParser(description="DAI-Core Health Scorer CLI")
    parser.add_argument("--app", type=str, help="Score a specific app by ID")
    parser.add_argument("--all", action="store_true", help="Score all apps")
    parser.add_argument("--simulate", action="store_true", help="Run simulation with mock metrics")
    parser.add_argument("--profile", type=str, default=DEFAULT_PROFILE,
                        help=f"Profile for simulation (default: {DEFAULT_PROFILE})")

    args = parser.parse_args()

    if args.simulate:
        cmd_simulate(args.profile)
    elif args.app:
        cmd_score_app(args.app)
    elif args.all:
        cmd_score_all()
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
