"""ReleaseManager CLI — simulation and management."""

import argparse
import json
import sys
import tempfile

from .manager import ReleaseManager
from . import config as cfg


# ── Simulation Scenarios ───────────────────────────────────────────

def _sim_successful_release(tmp: str) -> dict:
    """Full release lifecycle: QA pass -> upload -> registry -> cooling."""
    mgr = ReleaseManager(data_dir=tmp)

    submission = {
        "submission_id": "SUB-echomatch-20260331-abc123",
        "briefing_id": "BRF-echomatch-20260331120000",
        "app_id": "echomatch",
        "action_type": "hotfix",
        "target_version": "1.4.3",
    }

    context = {
        "health_score": 55.0,
        "active_anomalies": 1,
        "cooling_active": False,
        "has_briefing": True,
        "has_submission": True,
    }

    release = mgr.process_release(submission, context)

    ok = True
    errors = []

    if release["status"] != cfg.STATUS_RELEASED:
        errors.append(f"Status should be 'released', got '{release['status']}'")
        ok = False
    if not release["release_id"].startswith("REL-"):
        errors.append("release_id should start with REL-")
        ok = False
    if not release["qa_result"]["passed"]:
        errors.append("QA should pass")
        ok = False
    if not release["store_upload"]["success"]:
        errors.append("Store upload should succeed")
        ok = False
    if not release["registry_updated"]:
        errors.append("Registry should be updated")
        ok = False
    if not release["cooling_started"]:
        errors.append("Cooling should be started")
        ok = False
    if not release["completed_at"]:
        errors.append("completed_at should be set")
        ok = False

    # Verify saved
    saved = mgr.get_release(release["release_id"])
    if not saved:
        errors.append("Release not saved to disk")
        ok = False

    return {
        "scenario": "successful_release",
        "description": "Hotfix Release: QA pass -> Upload -> Registry -> Cooling -> Released",
        "ok": ok,
        "errors": errors,
        "data": {
            "release_id": release["release_id"],
            "status": release["status"],
            "qa_passed": release["qa_result"]["passed"],
            "history_length": len(release["history"]),
        },
    }


def _sim_qa_failure(tmp: str) -> dict:
    """Release blocked by QA check — low health score + cooling active."""
    mgr = ReleaseManager(data_dir=tmp)

    submission = {
        "submission_id": "SUB-badapp-20260331-def456",
        "briefing_id": "BRF-badapp-20260331130000",
        "app_id": "badapp",
        "action_type": "patch",
        "target_version": "2.0.1",
    }

    context = {
        "health_score": 15.0,       # Below threshold
        "active_anomalies": 5,      # Above threshold
        "cooling_active": True,     # Cooling active
        "has_briefing": True,
        "has_submission": True,
    }

    release = mgr.process_release(submission, context)

    ok = True
    errors = []

    if release["status"] != cfg.STATUS_QA_FAILED:
        errors.append(f"Status should be 'qa_failed', got '{release['status']}'")
        ok = False
    if release["qa_result"]["passed"]:
        errors.append("QA should NOT pass")
        ok = False
    if len(release["qa_result"]["blockers"]) < 3:
        errors.append(f"Expected >= 3 blockers, got {len(release['qa_result']['blockers'])}")
        ok = False
    if release["completed_at"]:
        errors.append("completed_at should NOT be set for failed release")
        ok = False

    return {
        "scenario": "qa_failure",
        "description": "Release blockiert: Health zu niedrig + zu viele Anomalien + Cooling aktiv",
        "ok": ok,
        "errors": errors,
        "data": {
            "release_id": release["release_id"],
            "status": release["status"],
            "blockers": release["qa_result"]["blockers"],
        },
    }


def _sim_feature_release(tmp: str) -> dict:
    """Feature update release with minor version bump and longer cooling."""
    mgr = ReleaseManager(data_dir=tmp)

    submission = {
        "submission_id": "SUB-focusflow-20260331-ghi789",
        "briefing_id": "BRF-focusflow-20260331140000",
        "app_id": "focusflow",
        "action_type": "feature_update",
        "target_version": "3.1.0",
    }

    context = {
        "health_score": 72.0,
        "active_anomalies": 0,
        "cooling_active": False,
        "has_briefing": True,
        "has_submission": True,
    }

    release = mgr.process_release(submission, context)

    ok = True
    errors = []

    if release["status"] != cfg.STATUS_RELEASED:
        errors.append(f"Status should be 'released', got '{release['status']}'")
        ok = False
    if release.get("cooling_hours") != 336:
        errors.append(f"Feature update cooling should be 336h, got {release.get('cooling_hours')}")
        ok = False

    return {
        "scenario": "feature_release",
        "description": "Feature Update Release: 2-Wochen Cooling, QA bestanden",
        "ok": ok,
        "errors": errors,
        "data": {
            "release_id": release["release_id"],
            "status": release["status"],
            "cooling_hours": release.get("cooling_hours"),
        },
    }


def _sim_list_releases(tmp: str) -> dict:
    """Multiple releases with listing and filtering."""
    mgr = ReleaseManager(data_dir=tmp)

    good_context = {
        "health_score": 60.0, "active_anomalies": 0,
        "cooling_active": False, "has_briefing": True, "has_submission": True,
    }
    bad_context = {
        "health_score": 10.0, "active_anomalies": 5,
        "cooling_active": True, "has_briefing": True, "has_submission": True,
    }

    subs = [
        {"submission_id": "SUB-a-1", "briefing_id": "BRF-a-1", "app_id": "app_a",
         "action_type": "hotfix", "target_version": "1.0.1"},
        {"submission_id": "SUB-a-2", "briefing_id": "BRF-a-2", "app_id": "app_a",
         "action_type": "patch", "target_version": "1.0.2"},
        {"submission_id": "SUB-b-1", "briefing_id": "BRF-b-1", "app_id": "app_b",
         "action_type": "feature_update", "target_version": "2.1.0"},
    ]

    # 2 successful, 1 failed
    mgr.process_release(subs[0], good_context)
    mgr.process_release(subs[1], bad_context)  # will fail QA
    mgr.process_release(subs[2], good_context)

    ok = True
    errors = []

    all_releases = mgr.list_releases()
    if len(all_releases) != 3:
        errors.append(f"Expected 3 releases, got {len(all_releases)}")
        ok = False

    app_a = mgr.list_releases(app_id="app_a")
    if len(app_a) != 2:
        errors.append(f"Expected 2 for app_a, got {len(app_a)}")
        ok = False

    released = mgr.list_releases(status="released")
    if len(released) != 2:
        errors.append(f"Expected 2 released, got {len(released)}")
        ok = False

    failed = mgr.list_releases(status="qa_failed")
    if len(failed) != 1:
        errors.append(f"Expected 1 qa_failed, got {len(failed)}")
        ok = False

    return {
        "scenario": "list_releases",
        "description": "3 Releases (2 ok, 1 QA-Fail), Filter nach App + Status korrekt",
        "ok": ok,
        "errors": errors,
        "data": {"total": len(all_releases), "released": len(released), "failed": len(failed)},
    }


# ── Runner ─────────────────────────────────────────────────────────

SCENARIOS = {
    "successful_release": _sim_successful_release,
    "qa_failure": _sim_qa_failure,
    "feature_release": _sim_feature_release,
    "list_releases": _sim_list_releases,
}


def main():
    parser = argparse.ArgumentParser(description="ReleaseManager CLI")
    parser.add_argument("--simulate", action="store_true", help="Run simulations")
    parser.add_argument("--scenario", choices=list(SCENARIOS.keys()), help="Specific scenario")
    parser.add_argument("--list", action="store_true", help="List releases")
    parser.add_argument("--app", help="Filter by app_id")
    parser.add_argument("--status", help="Filter by status")
    parser.add_argument("--json", action="store_true", help="JSON output")
    args = parser.parse_args()

    if args.list:
        _run_list(args)
    elif args.simulate or args.scenario:
        _run_simulations(args)
    else:
        sys.argv.append("--simulate")
        main()


def _run_simulations(args):
    scenarios = [args.scenario] if args.scenario else list(SCENARIOS.keys())

    print("=" * 60)
    print(" ReleaseManager Simulation")
    print("=" * 60)

    all_ok = True
    for name in scenarios:
        tmp = tempfile.mkdtemp(prefix=f"release_{name}_")
        try:
            result = SCENARIOS[name](tmp)
            icon = "[+]" if result["ok"] else "[-]"
            status = "PASS" if result["ok"] else "FAIL"
            if not result["ok"]:
                all_ok = False

            print(f"\n  {icon} {name}: {status}")
            print(f"      {result['description']}")

            if args.json:
                print(f"      Data: {json.dumps(result['data'], default=str)}")

            for e in result.get("errors", []):
                print(f"      ERROR: {e}")

        except Exception as e:
            print(f"\n  [!] {name}: EXCEPTION")
            print(f"      {type(e).__name__}: {e}")
            all_ok = False

    print(f"\n{'=' * 60}")
    print(f"  Ergebnis: {'ALLE BESTANDEN' if all_ok else 'FEHLER AUFGETRETEN'}")
    print(f"{'=' * 60}")


def _run_list(args):
    mgr = ReleaseManager()
    releases = mgr.list_releases(app_id=args.app, status=args.status)
    if args.json:
        print(json.dumps(releases, indent=2, default=str))
    else:
        if not releases:
            print("Keine Releases vorhanden.")
        else:
            for r in releases:
                print(f"  {r['release_id']}  {r['app_id']}  {r['action_type']}  "
                      f"v{r['target_version']}  [{r['status']}]")


if __name__ == "__main__":
    main()
