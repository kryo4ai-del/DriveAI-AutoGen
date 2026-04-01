"""Reporting CLI — Entry Point.

Usage:
    python -m factory.live_operations.reporting --simulate
    python -m factory.live_operations.reporting --generate
    python -m factory.live_operations.reporting --list
"""

import argparse
import json
import sys

from factory.live_operations.reporting.cli import run_all as run_simulation


def main() -> None:
    parser = argparse.ArgumentParser(description="CEO Weekly Report")
    parser.add_argument("--simulate", action="store_true", help="Run report simulation")
    parser.add_argument("--generate", action="store_true", help="Generate real weekly report")
    parser.add_argument("--list", action="store_true", help="List archived reports")
    parser.add_argument("--json", action="store_true", help="JSON output")
    args = parser.parse_args()

    if args.simulate:
        result = run_simulation()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        sys.exit(0 if result["ok"] else 1)

    if args.generate:
        from factory.live_operations.reporting.weekly_report import WeeklyReportGenerator
        reporter = WeeklyReportGenerator()
        result = reporter.generate()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        else:
            print(f"\nReport generiert: {result['report_path']}")
            s = result.get("summary", {})
            print(f"  Fleet Status: {s.get('fleet_status', '?')}")
            print(f"  Apps: {s.get('total_apps', 0)} | Avg Score: {s.get('avg_health_score', 0)}")
        sys.exit(0)

    if args.list:
        from factory.live_operations.reporting.weekly_report import WeeklyReportGenerator
        reporter = WeeklyReportGenerator()
        reports = reporter.list_reports()
        if args.json:
            print(json.dumps(reports, indent=2, default=str))
        else:
            print(f"\nArchivierte Reports: {len(reports)}")
            for r in reports[:10]:
                print(f"  {r['filename']} ({r['created'][:10]})")
        sys.exit(0)

    parser.print_help()


if __name__ == "__main__":
    main()
