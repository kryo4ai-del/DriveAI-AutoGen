"""Self-Healing CLI — Entry Point.

Usage:
    python -m factory.live_operations.self_healing --simulate
    python -m factory.live_operations.self_healing --health-check
    python -m factory.live_operations.self_healing --heal-all
"""

import argparse
import json
import sys

from factory.live_operations.self_healing.cli import run_all as run_simulation


def main() -> None:
    parser = argparse.ArgumentParser(description="Self-Healing System")
    parser.add_argument("--simulate", action="store_true", help="Run self-healing simulation")
    parser.add_argument("--health-check", action="store_true", help="Run health check on real DB")
    parser.add_argument("--heal-all", action="store_true", help="Run all healing actions on real DB")
    parser.add_argument("--json", action="store_true", help="JSON output")
    args = parser.parse_args()

    if args.simulate:
        result = run_simulation()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        sys.exit(0 if result["ok"] else 1)

    if args.health_check:
        from factory.live_operations.app_registry.database import AppRegistryDB
        from factory.live_operations.self_healing.health_monitor import SystemHealthMonitor
        from factory.live_operations.self_healing.utilities import ErrorLog

        db = AppRegistryDB()
        monitor = SystemHealthMonitor(registry_db=db, error_log=ErrorLog())
        result = monitor.run_health_check()

        if args.json:
            print(json.dumps(result, indent=2, default=str))
        else:
            print(f"\nSystem Health: {'ALL OK' if result['all_ok'] else 'ISSUES'}")
            for name, check in result["checks"].items():
                status = "OK" if check["ok"] else "FAIL"
                print(f"  {name}: {status}")
        sys.exit(0 if result["all_ok"] else 1)

    if args.heal_all:
        from factory.live_operations.app_registry.database import AppRegistryDB
        from factory.live_operations.self_healing.healer import SelfHealer
        from factory.live_operations.self_healing.utilities import ErrorLog

        db = AppRegistryDB()
        healer = SelfHealer(registry_db=db, error_log=ErrorLog())
        result = healer.heal_all()

        if args.json:
            print(json.dumps(result, indent=2, default=str))
        else:
            print(f"\nHealing Complete: {result['total_healed']} repariert")
            for name, action in result["actions"].items():
                healed = action.get("healed", 0)
                if healed > 0:
                    print(f"  {name}: {healed}")
        sys.exit(0)

    parser.print_help()


if __name__ == "__main__":
    main()
