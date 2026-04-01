"""Test Harness CLI — Entry Point.

Usage:
    python -m factory.live_operations.test_harness --generate [--count N]
    python -m factory.live_operations.test_harness --populate [--count N]
    python -m factory.live_operations.test_harness --inject --app APP_ID --scenario SCENARIO
    python -m factory.live_operations.test_harness --clear
    python -m factory.live_operations.test_harness --status
    python -m factory.live_operations.test_harness --scenarios
    python -m factory.live_operations.test_harness --simulate
    python -m factory.live_operations.test_harness --stress [--count N] [--iterations N]
    python -m factory.live_operations.test_harness --self-heal
    python -m factory.live_operations.test_harness --weekly-report
"""

import argparse
import json
import sys

from factory.live_operations.test_harness.fleet_generator import SyntheticFleetGenerator
from factory.live_operations.test_harness.scenarios import list_scenarios, SCENARIOS
from factory.live_operations.test_harness.cli import run_all as run_simulation


def main() -> None:
    parser = argparse.ArgumentParser(description="Test Harness — Synthetic Fleet Generator")
    parser.add_argument("--generate", action="store_true", help="Generate synthetic fleet")
    parser.add_argument("--populate", action="store_true", help="Populate all: fleet + metrics + reviews + tickets")
    parser.add_argument("--inject", action="store_true", help="Inject scenario into app")
    parser.add_argument("--clear", action="store_true", help="Clear all synthetic data")
    parser.add_argument("--status", action="store_true", help="Show fleet status")
    parser.add_argument("--scenarios", action="store_true", help="List available scenarios")
    parser.add_argument("--simulate", action="store_true", help="Run simulation (temp DB)")
    parser.add_argument("--stress", action="store_true", help="Run stress-test suite (temp DB)")
    parser.add_argument("--self-heal", action="store_true", help="Run self-healing simulation (temp DB)")
    parser.add_argument("--weekly-report", action="store_true", help="Run weekly report simulation (temp DB)")
    parser.add_argument("--count", type=int, default=15, help="Number of apps to generate (default: 15)")
    parser.add_argument("--iterations", type=int, default=3, help="Stress-test iterations (default: 3)")
    parser.add_argument("--app", type=str, help="Target app ID for injection")
    parser.add_argument("--scenario", type=str, help="Scenario name for injection")
    parser.add_argument("--json", action="store_true", help="JSON output")
    parser.add_argument("--seed", type=int, default=42, help="Random seed (default: 42)")

    args = parser.parse_args()

    if args.simulate:
        result = run_simulation()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        sys.exit(0 if result["ok"] else 1)

    if args.self_heal:
        from factory.live_operations.self_healing.cli import run_all as run_self_heal
        result = run_self_heal()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        sys.exit(0 if result["ok"] else 1)

    if args.weekly_report:
        from factory.live_operations.reporting.cli import run_all as run_report
        result = run_report()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        sys.exit(0 if result["ok"] else 1)

    if args.stress:
        from factory.live_operations.test_harness.stress_runner import StressTestRunner
        from factory.live_operations.test_harness.benchmark_reporter import BenchmarkReporter

        runner = StressTestRunner(
            fleet_size=args.count,
            iterations=args.iterations,
            seed=args.seed,
        )
        result = runner.run_all()

        # Generate report
        reporter = BenchmarkReporter()
        report_path = reporter.generate_report(result)
        print(f"\nReport: {report_path}")

        if args.json:
            print(json.dumps(result, indent=2, default=str))
        sys.exit(0 if result["ok"] else 1)

    if args.scenarios:
        print("\nVerfuegbare Szenarien:")
        print("-" * 60)
        for name in list_scenarios():
            s = SCENARIOS[name]
            print(f"  {name:20s} | {s['severity']:8s} | {s['expected_action']:8s} | {s['description']}")
        return

    # Real DB operations
    gen = SyntheticFleetGenerator(seed=args.seed)

    if args.generate:
        result = gen.generate_fleet(args.count)
        if args.json:
            print(json.dumps(result, indent=2, default=str))

    elif args.populate:
        result = gen.populate_all(args.count)
        if args.json:
            print(json.dumps(result, indent=2, default=str))

    elif args.inject:
        if not args.app or not args.scenario:
            print("Fehler: --inject braucht --app APP_ID und --scenario SCENARIO")
            sys.exit(1)
        result = gen.inject_scenario(args.app, args.scenario)
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        if not result.get("ok"):
            sys.exit(1)

    elif args.clear:
        result = gen.clear_all()
        if args.json:
            print(json.dumps(result, indent=2, default=str))

    elif args.status:
        result = gen.get_status()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        else:
            print(f"\nSynthetic Fleet Status")
            print(f"-" * 40)
            print(f"  Synthetische Apps: {result['total_synthetic_apps']}")
            print(f"  Echte Apps:        {result['total_real_apps']}")
            print(f"  Zonen:             {result['by_zone']}")
            print(f"  Profile:           {result['by_profile']}")
            print(f"  Injections:        {result['active_injections']}")
            if result["apps"]:
                print(f"\n  Apps:")
                for a in result["apps"]:
                    print(f"    {a['name']:20s} | {a['profile']:12s} | Score={a['score']:5.1f} | {a['zone']}")

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
