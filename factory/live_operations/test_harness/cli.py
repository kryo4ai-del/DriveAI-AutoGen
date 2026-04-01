"""Fleet Generator CLI — Simulation und Validierung.

3 Szenarien:
1. generate_and_verify: Fleet generieren + Status pruefen
2. inject_and_validate: Szenario injizieren + erwartetes Ergebnis pruefen
3. full_lifecycle: populate_all + inject + clear + verify cleanup
"""

import sys
import tempfile
from pathlib import Path

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.test_harness.fleet_generator import SyntheticFleetGenerator
from factory.live_operations.test_harness.config import SYNTHETIC_MARKER

_PREFIX = "[Fleet Generator CLI]"


def _make_temp_db() -> AppRegistryDB:
    """Erstellt temporaere DB fuer Tests."""
    tmp = tempfile.mktemp(suffix=".db")
    return AppRegistryDB(tmp)


def run_generate_and_verify() -> dict:
    """Szenario 1: Fleet generieren und verifizieren."""
    print(f"\n{'='*60}")
    print(f"{_PREFIX} Szenario 1: Generate & Verify")
    print(f"{'='*60}")

    db = _make_temp_db()
    gen = SyntheticFleetGenerator(registry_db=db, seed=42)

    # Generate fleet
    fleet = gen.generate_fleet(15)
    assert fleet["total"] == 15, f"Erwartet 15 Apps, bekam {fleet['total']}"

    # Verify all apps in DB
    all_apps = db.get_all_apps()
    synthetic = [a for a in all_apps if a.get("repository_path") == SYNTHETIC_MARKER]
    assert len(synthetic) == 15, f"Erwartet 15 synthetische Apps in DB, bekam {len(synthetic)}"

    # Verify distribution
    dist = fleet["distribution"]
    assert dist["healthy"] == 6, f"Erwartet 6 healthy, bekam {dist['healthy']}"
    assert dist["warning"] == 4, f"Erwartet 4 warning, bekam {dist['warning']}"
    assert dist["critical"] == 3, f"Erwartet 3 critical, bekam {dist['critical']}"
    assert dist["new_app"] == 2, f"Erwartet 2 new_app, bekam {dist['new_app']}"

    # Verify status
    status = gen.get_status()
    assert status["total_synthetic_apps"] == 15
    assert len(status["apps"]) == 15

    # Verify zones plausibel
    green = status["by_zone"].get("green", 0)
    yellow = status["by_zone"].get("yellow", 0)
    red = status["by_zone"].get("red", 0)
    assert green + yellow + red == 15, f"Zone-Summe stimmt nicht: {green}+{yellow}+{red}"

    print(f"\n{_PREFIX} PASS - 15 Apps generiert, Verteilung korrekt, alle in DB")
    return {"ok": True, "scenario": "generate_and_verify", "apps": fleet["total"]}


def run_inject_and_validate() -> dict:
    """Szenario 2: Szenario injizieren und Ergebnis pruefen."""
    print(f"\n{'='*60}")
    print(f"{_PREFIX} Szenario 2: Inject & Validate")
    print(f"{'='*60}")

    db = _make_temp_db()
    gen = SyntheticFleetGenerator(registry_db=db, seed=42)

    # Generate small fleet
    fleet = gen.generate_fleet(5)
    first_app = fleet["apps"][0]
    app_id = first_app["app_id"]

    # Inject crash_spike
    result = gen.inject_scenario(app_id, "crash_spike")
    assert result["ok"], f"Injection fehlgeschlagen: {result.get('error')}"
    assert result["scenario"] == "crash_spike"
    assert result["expected_action"] == "hotfix"
    assert result["new_zone"] == "red", f"Erwartet red zone bei crash_spike, bekam {result['new_zone']}"

    # Verify app in DB updated
    app = db.get_app(app_id)
    assert app["health_zone"] == "red"
    assert app["health_score"] < 30, f"Score sollte < 30 sein bei crash_spike, ist {app['health_score']}"

    # Inject recovery in another app
    second_app = fleet["apps"][1]
    result2 = gen.inject_scenario(second_app["app_id"], "recovery")
    assert result2["ok"]
    assert result2["new_score"] >= 65, f"Recovery Score sollte >= 65 sein, ist {result2['new_score']}"

    # Test unknown scenario
    result3 = gen.inject_scenario(app_id, "nonexistent_scenario")
    assert not result3["ok"]
    assert "Unbekanntes Szenario" in result3["error"]

    print(f"\n{_PREFIX} PASS - crash_spike + recovery injiziert, Validierung korrekt")
    return {"ok": True, "scenario": "inject_and_validate"}


def run_full_lifecycle() -> dict:
    """Szenario 3: Kompletter Lifecycle: populate -> inject -> clear."""
    print(f"\n{'='*60}")
    print(f"{_PREFIX} Szenario 3: Full Lifecycle")
    print(f"{'='*60}")

    db = _make_temp_db()
    gen = SyntheticFleetGenerator(registry_db=db, seed=42)

    # 1. Populate everything
    pop = gen.populate_all(10)
    assert pop["fleet"]["total"] == 10, f"Erwartet 10 Apps, bekam {pop['fleet']['total']}"
    assert pop["metrics"]["total_records"] > 0, "Keine Metriken generiert"
    assert pop["reviews"]["total_reviews"] > 0, "Keine Reviews generiert"
    assert pop["tickets"]["total_tickets"] > 0, "Keine Tickets generiert"

    # 2. Verify populated state
    status = gen.get_status()
    assert status["total_synthetic_apps"] == 10

    # 3. Inject scenario
    first_id = pop["fleet"]["apps"][0]["app_id"]
    inject = gen.inject_scenario(first_id, "gradual_decay")
    assert inject["ok"]

    # 4. Clear everything
    cleared = gen.clear_all()
    assert cleared["removed_apps"] == 10, f"Erwartet 10 entfernte Apps, bekam {cleared['removed_apps']}"

    # 5. Verify clean state
    status_after = gen.get_status()
    assert status_after["total_synthetic_apps"] == 0, "Noch synthetische Apps vorhanden nach clear"

    print(f"\n{_PREFIX} PASS - Lifecycle komplett: populate(10) -> inject(gradual_decay) -> clear -> 0 Apps")
    return {"ok": True, "scenario": "full_lifecycle", "populated": 10, "cleared": cleared["removed_apps"]}


def run_all() -> dict:
    """Fuehrt alle 3 Szenarien aus."""
    results = {}
    all_ok = True

    for name, fn in [
        ("generate_and_verify", run_generate_and_verify),
        ("inject_and_validate", run_inject_and_validate),
        ("full_lifecycle", run_full_lifecycle),
    ]:
        try:
            results[name] = fn()
        except Exception as e:
            results[name] = {"ok": False, "error": str(e)}
            all_ok = False
            print(f"\n{_PREFIX} FAIL - {name}: {e}")

    print(f"\n{'='*60}")
    passed = sum(1 for r in results.values() if r.get("ok"))
    total = len(results)
    status = "ALL PASS" if all_ok else f"{passed}/{total} PASS"
    print(f"{_PREFIX} Ergebnis: {status}")
    print(f"{'='*60}")

    return {"ok": all_ok, "passed": passed, "total": total, "results": results}


if __name__ == "__main__":
    result = run_all()
    sys.exit(0 if result["ok"] else 1)
