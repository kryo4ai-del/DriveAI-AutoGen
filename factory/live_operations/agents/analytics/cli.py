"""Analytics Agent CLI.

Usage:
    python -m factory.live_operations.agents.analytics.cli --app <app_id> --trends
    python -m factory.live_operations.agents.analytics.cli --all --trends
    python -m factory.live_operations.agents.analytics.cli --simulate --days 30
"""

import argparse
import json
import math
import random

from .analyzer import AnalyticsAgent
from .trend_detector import TrendDetector


def main() -> None:
    parser = argparse.ArgumentParser(description="DAI-Core Analytics Agent CLI")
    parser.add_argument("--app", metavar="APP_ID", help="Analyse fuer eine App")
    parser.add_argument("--all", action="store_true", help="Alle Apps analysieren")
    parser.add_argument("--trends", action="store_true", help="Trend-Analyse anzeigen")
    parser.add_argument("--simulate", action="store_true", help="Simulation mit synthetischen Daten")
    parser.add_argument("--days", type=int, default=30, help="Tage fuer Simulation (default: 30)")
    parser.add_argument("--seed", type=int, default=42, help="Random seed fuer Simulation")

    args = parser.parse_args()

    if args.simulate:
        _cmd_simulate(args.days, args.seed)
    elif args.all:
        agent = AnalyticsAgent()
        results = agent.analyze_all()
        _print_results(results)
    elif args.app:
        agent = AnalyticsAgent()
        history = agent._load_metrics_history(args.app, args.days)
        result = agent.analyze_app(args.app, history)
        _print_single_result(result)
    else:
        parser.print_help()


def _cmd_simulate(days: int, seed: int) -> None:
    """Generiert synthetische Daten und zeigt Trend-Erkennung."""
    print(f"\n=== SIMULATION: {days} Tage, Seed={seed} ===\n")
    rng = random.Random(seed)

    history = _generate_synthetic_history(days, rng)

    detector = TrendDetector()
    result = detector.detect_trends(history)

    print(f"Datenpunkte: {result['data_points']}")
    print(f"Metriken analysiert: {result['metrics_analyzed']}\n")

    trends = result.get("trends", {})
    print(f"{'Metric':<30} {'Direction':<10} {'Strength':>8} {'Current':>10} {'Change%':>8} {'Seasonal':>8} {'Anomalies':>9}")
    print("-" * 93)

    for key in sorted(trends.keys()):
        t = trends[key]
        print(
            f"{t['metric_name']:<30} "
            f"{t['direction']:<10} "
            f"{t['strength']:>7.1%}  "
            f"{t['current_value']:>9.1f} "
            f"{t['change_percent']:>7.1f}% "
            f"{'Yes' if t.get('is_seasonal') else 'No':>8} "
            f"{len(t.get('anomalies', [])):>9}"
        )

    # Anomalie-Details
    all_anomalies = []
    for key, t in trends.items():
        for a in t.get("anomalies", []):
            all_anomalies.append((key, a))

    if all_anomalies:
        print(f"\n--- Anomalien ({len(all_anomalies)}) ---")
        for metric, a in all_anomalies:
            print(f"  [{a['type'].upper()}] {metric} at day {a['index']}: "
                  f"value={a['value']:.1f}, expected={a['expected']:.1f}, "
                  f"deviation={a['deviation_sigma']:.1f} sigma")

    # Empfehlungen
    from .analyzer import AnalyticsAgent
    agent = AnalyticsAgent.__new__(AnalyticsAgent)
    agent.trend_detector = detector
    recs = agent._trend_recommendations(result)
    if recs:
        print(f"\n--- Recommendations ({len(recs)}) ---")
        for r in recs:
            print(f"  [{r['type'].upper()}] {r['category']}: {r['message']}")
            print(f"    -> {r['suggested_action']}")


def _generate_synthetic_history(days: int, rng: random.Random) -> list[dict]:
    """Generiert synthetische Metriken mit eingebauten Mustern."""
    history = []

    for day in range(days):
        # DAU: steigend (Wachstum) + Wochenend-Dip
        base_dau = 3000 + day * 50  # Steigender Trend
        weekend_factor = 0.75 if (day % 7) in (5, 6) else 1.0  # Sa+So Dip
        dau = int(base_dau * weekend_factor + rng.gauss(0, 100))

        # Retention: leicht fallend
        ret_d1 = max(0, min(1, 0.45 - day * 0.003 + rng.gauss(0, 0.02)))
        ret_d7 = max(0, min(1, 0.30 - day * 0.002 + rng.gauss(0, 0.015)))
        ret_d30 = max(0, min(1, 0.15 - day * 0.001 + rng.gauss(0, 0.01)))

        # Crash Rate: stabil, aber Spike an Tag 15
        crash = max(0, 0.5 + rng.gauss(0, 0.1))
        if day == 15:
            crash = 4.5  # Spike!

        # Revenue: leicht steigend
        revenue = max(0, 500 + day * 10 + rng.gauss(0, 50))
        arpu = revenue / max(dau, 1)

        # Session Length: stabil
        session_len = max(10, 180 + rng.gauss(0, 20))

        history.append({
            "collected_at": f"2026-03-{(day % 28) + 1:02d}T12:00:00Z",
            "store_metrics": {
                "downloads_period": max(0, int(200 + day * 5 + rng.gauss(0, 30))),
                "rating_average": max(1, min(5, 4.2 + rng.gauss(0, 0.1))),
                "crash_rate": crash,
                "revenue_period": revenue,
            },
            "firebase_metrics": {
                "dau": max(0, dau),
                "mau": max(0, int(dau * 4.5)),
                "dau_mau_ratio": min(1, max(0, dau / max(dau * 4.5, 1))),
                "avg_session_length_seconds": session_len,
                "retention_day1": ret_d1,
                "retention_day7": ret_d7,
                "retention_day30": ret_d30,
                "arpu": arpu,
                "conversion_rate": max(0, min(1, 0.05 + rng.gauss(0, 0.005))),
            },
        })

    return history


def _print_results(results: dict) -> None:
    for app_id, result in results.items():
        print(f"\n--- App: {app_id} ---")
        _print_single_result(result)


def _print_single_result(result: dict) -> None:
    trends = result.get("trend_analysis", {}).get("trends", {})
    if not trends:
        print("  No trend data.")
        return

    for key in sorted(trends.keys()):
        t = trends[key]
        print(f"  {t['metric_name']}: {t['direction']} (strength: {t['strength']:.0%})")

    recs = result.get("recommendations", [])
    if recs:
        print(f"\n  Recommendations ({len(recs)}):")
        for r in recs:
            print(f"    [{r['type']}] {r['message']}")


if __name__ == "__main__":
    main()
