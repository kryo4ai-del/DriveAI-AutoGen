"""App Registry CLI — Manuelle Interaktion mit der App Registry.

Usage:
    python -m factory.live_operations.app_registry.cli --list
    python -m factory.live_operations.app_registry.cli --show <app_id>
    python -m factory.live_operations.app_registry.cli --migrate
    python -m factory.live_operations.app_registry.cli --health <app_id>
    python -m factory.live_operations.app_registry.cli --zones
"""

import argparse
import json
import sys

from .database import AppRegistryDB
from .migrator import RegistryMigrator


def main() -> None:
    parser = argparse.ArgumentParser(
        description="DAI-Core App Registry CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--list", action="store_true", help="Alle registrierten Apps anzeigen")
    parser.add_argument("--show", metavar="APP_ID", help="Einzelne App anzeigen")
    parser.add_argument("--migrate", action="store_true", help="JSON -> SQLite Migration ausfuehren")
    parser.add_argument("--health", metavar="APP_ID", help="Health History einer App anzeigen")
    parser.add_argument("--zones", action="store_true", help="Apps nach Health Zone gruppiert anzeigen")
    parser.add_argument("--db", metavar="PATH", help="Alternativer DB-Pfad")

    args = parser.parse_args()
    db = AppRegistryDB(db_path=args.db) if args.db else AppRegistryDB()

    if args.list:
        _cmd_list(db)
    elif args.show:
        _cmd_show(db, args.show)
    elif args.migrate:
        _cmd_migrate(db)
    elif args.health:
        _cmd_health(db, args.health)
    elif args.zones:
        _cmd_zones(db)
    else:
        parser.print_help()


def _cmd_list(db: AppRegistryDB) -> None:
    apps = db.get_all_apps()
    if not apps:
        print("[App Registry] Keine Apps registriert.")
        return

    print(f"\n{'ID':<14} {'Name':<30} {'Score':>6} {'Zone':<8} {'Version':<10} {'Profile':<14} {'Status'}")
    print("-" * 100)
    for app in apps:
        print(
            f"{app['app_id']:<14} "
            f"{(app['app_name'] or '?')[:28]:<30} "
            f"{app['health_score']:>5.1f}  "
            f"{app['health_zone']:<8} "
            f"{(app['current_version'] or '-'):<10} "
            f"{(app['app_profile'] or '-'):<14} "
            f"{app['store_status']}"
        )
    print(f"\nGesamt: {len(apps)} Apps")


def _cmd_show(db: AppRegistryDB, app_id: str) -> None:
    app = db.get_app(app_id)
    if not app:
        print(f"[App Registry] App nicht gefunden: {app_id}")
        return

    print(f"\n{'='*60}")
    print(f"  App: {app['app_name']}")
    print(f"{'='*60}")
    for key, value in app.items():
        if value is not None:
            print(f"  {key:<24} {value}")

    # Cooling Info
    cooling = db.get_cooling_info(app_id)
    if cooling:
        print(f"\n  COOLING AKTIV:")
        print(f"    Typ:        {cooling['cooling_type']}")
        print(f"    Bis:        {cooling['cooling_until']}")
        print(f"    Verbleibend: {cooling['remaining_human']}")

    # Pending Actions
    actions = db.get_pending_actions(app_id)
    if actions:
        print(f"\n  PENDING ACTIONS ({len(actions)}):")
        for a in actions:
            print(f"    [{a['severity_score']:.0f}] {a['action_type']} — {a['status']}")

    # Release History (letzte 5)
    releases = db.get_release_history(app_id)[:5]
    if releases:
        print(f"\n  LETZTE RELEASES ({len(releases)}):")
        for r in releases:
            print(f"    v{r['version']} — {r['update_type']} ({r['triggered_by']}) — {r['release_date'][:10]}")

    print()


def _cmd_migrate(db: AppRegistryDB) -> None:
    migrator = RegistryMigrator(db=db)
    summary = migrator.migrate()
    print(f"\n[Migration] Ergebnis: {json.dumps(summary, indent=2, ensure_ascii=False)}")


def _cmd_health(db: AppRegistryDB, app_id: str) -> None:
    app = db.get_app(app_id)
    if not app:
        print(f"[App Registry] App nicht gefunden: {app_id}")
        return

    history = db.get_health_history(app_id, limit=20)
    if not history:
        print(f"[App Registry] No health history for {app_id}")
        return

    print(f"\nHealth History: {app['app_name']} (aktuell: {app['health_score']:.1f} / {app['health_zone']})")
    print(f"\n{'Timestamp':<26} {'Overall':>8} {'Stabil':>8} {'Satisf':>8} {'Engage':>8} {'Revenue':>8} {'Growth':>8}")
    print("-" * 90)
    for h in history:
        print(
            f"{(h['timestamp'] or '-')[:24]:<26} "
            f"{h['overall_score'] or 0:>7.1f}  "
            f"{h['stability_score'] or 0:>7.1f}  "
            f"{h['satisfaction_score'] or 0:>7.1f}  "
            f"{h['engagement_score'] or 0:>7.1f}  "
            f"{h['revenue_score'] or 0:>7.1f}  "
            f"{h['growth_score'] or 0:>7.1f}"
        )


def _cmd_zones(db: AppRegistryDB) -> None:
    for zone in ("red", "yellow", "green"):
        apps = db.get_apps_by_zone(zone)
        label = {"red": "RED (0-49)", "yellow": "YELLOW (50-79)", "green": "GREEN (80-100)"}[zone]
        print(f"\n{label} — {len(apps)} Apps")
        if apps:
            for app in apps:
                print(f"  [{app['health_score']:.0f}] {app['app_name']} (v{app['current_version'] or '?'})")


if __name__ == "__main__":
    main()
