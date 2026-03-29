"""Marketing Alert System — Funktionstest.

Testet den kompletten Lifecycle von Alerts und Gates.
Raeumt nach dem Test alle Test-Artefakte auf.

Aufruf: python -m factory.marketing.alerts.test_alerts
"""

import json
import os
import sys

# Factory Root auf sys.path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", ".."))

from factory.marketing.alerts.alert_manager import MarketingAlertManager


def main() -> None:
    passed = 0
    failed = 0
    total = 10

    mgr = MarketingAlertManager()
    alert_ids: list[str] = []
    gate_ids: list[str] = []

    # ── Test 1: Alert erstellen ──────────────────────────────
    try:
        aid = mgr.create_alert(
            type="alert", priority="high", category="system",
            source_agent="MKT-01",
            title="Test Alert — Marketing System Online",
            description="Automatischer Funktionstest des Marketing-Alert-Systems.",
        )
        alert_ids.append(aid)

        path = os.path.join(mgr._active, f"{aid}.json")
        assert os.path.exists(path), f"Datei nicht gefunden: {path}"

        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        assert data["status"] == "open", f"Status: {data['status']}"
        for field in ["alert_id", "timestamp", "type", "priority", "category",
                      "source_agent", "title", "description", "status"]:
            assert field in data, f"Pflichtfeld fehlt: {field}"

        print(f"[OK] Test  1: Alert erstellen — OK (alert_id: {aid})")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test  1: Alert erstellen — FAILED: {e}")
        failed += 1

    # ── Test 2: Zweiter Alert ────────────────────────────────
    try:
        aid2 = mgr.create_alert(
            type="warning", priority="medium", category="budget",
            source_agent="MKT-02",
            title="Test Warning — Budget Check",
            description="Budget-Warnung Testfall.",
        )
        alert_ids.append(aid2)

        path2 = os.path.join(mgr._active, f"{aid2}.json")
        assert os.path.exists(path2), f"Datei nicht gefunden: {path2}"

        active_files = [f for f in os.listdir(mgr._active) if f.endswith(".json")]
        assert len(active_files) == 2, f"Erwartet 2, gefunden {len(active_files)}"

        print(f"[OK] Test  2: Zweiter Alert — OK (alert_id: {aid2})")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test  2: Zweiter Alert — FAILED: {e}")
        failed += 1

    # ── Test 3: Active Alerts abrufen ────────────────────────
    try:
        all_active = mgr.get_active_alerts()
        assert len(all_active) == 2, f"Erwartet 2, gefunden {len(all_active)}"
        assert all_active[0]["priority"] == "high", "Sortierung falsch: high sollte zuerst sein"
        assert all_active[1]["priority"] == "medium", "Sortierung falsch: medium sollte zweiter sein"

        filtered = mgr.get_active_alerts(priority_filter="high")
        assert len(filtered) == 1, f"Filter: erwartet 1, gefunden {len(filtered)}"

        print(f"[OK] Test  3: Active Alerts abrufen — OK (2 total, filter=1)")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test  3: Active Alerts abrufen — FAILED: {e}")
        failed += 1

    # ── Test 4: Alert acknowledge ────────────────────────────
    try:
        ok = mgr.acknowledge_alert(alert_ids[0])
        assert ok, "acknowledge_alert returned False"

        assert not os.path.exists(os.path.join(mgr._active, f"{alert_ids[0]}.json")), "Datei noch in active/"
        ack_path = os.path.join(mgr._acknowledged, f"{alert_ids[0]}.json")
        assert os.path.exists(ack_path), "Datei nicht in acknowledged/"

        with open(ack_path, "r", encoding="utf-8") as f:
            ack_data = json.load(f)
        assert ack_data["status"] == "acknowledged", f"Status: {ack_data['status']}"

        remaining = mgr.get_active_alerts()
        assert len(remaining) == 1, f"Erwartet 1 active, gefunden {len(remaining)}"

        print(f"[OK] Test  4: Alert acknowledge — OK")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test  4: Alert acknowledge — FAILED: {e}")
        failed += 1

    # ── Test 5: Alert resolve ────────────────────────────────
    try:
        ok = mgr.resolve_alert(alert_ids[0], resolution_note="Test erfolgreich abgeschlossen")
        assert ok, "resolve_alert returned False"

        assert not os.path.exists(os.path.join(mgr._acknowledged, f"{alert_ids[0]}.json")), "Datei noch in acknowledged/"
        res_path = os.path.join(mgr._resolved, f"{alert_ids[0]}.json")
        assert os.path.exists(res_path), "Datei nicht in resolved/"

        with open(res_path, "r", encoding="utf-8") as f:
            res_data = json.load(f)
        assert res_data["status"] == "resolved", f"Status: {res_data['status']}"
        assert res_data.get("resolved_at"), "resolved_at fehlt"
        assert res_data.get("resolution_note") == "Test erfolgreich abgeschlossen", "resolution_note falsch"

        print(f"[OK] Test  5: Alert resolve — OK")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test  5: Alert resolve — FAILED: {e}")
        failed += 1

    # ── Test 6: Direktes Resolve (active → resolved) ────────
    try:
        ok = mgr.resolve_alert(alert_ids[1])
        assert ok, "resolve_alert (direkt) returned False"

        res_path2 = os.path.join(mgr._resolved, f"{alert_ids[1]}.json")
        assert os.path.exists(res_path2), "Datei nicht in resolved/"

        active_files = [f for f in os.listdir(mgr._active) if f.endswith(".json")]
        assert len(active_files) == 0, f"active/ nicht leer: {len(active_files)} Dateien"

        print(f"[OK] Test  6: Direktes Resolve — OK")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test  6: Direktes Resolve — FAILED: {e}")
        failed += 1

    # ── Test 7: Gate-Request erstellen ───────────────────────
    try:
        gid = mgr.create_gate_request(
            source_agent="MKT-02",
            title="Test Gate — Brand Direction",
            description="Soll die Factory ein dunkles oder helles Theme verwenden?",
            options=[
                {"label": "Dark Theme", "description": "Dunkel, technisch, Neon-Akzente"},
                {"label": "Light Theme", "description": "Hell, clean, minimalistisch"},
            ],
        )
        gate_ids.append(gid)

        gate_path = os.path.join(mgr._gates, f"{gid}.json")
        assert os.path.exists(gate_path), f"Gate-Datei nicht gefunden: {gate_path}"

        with open(gate_path, "r", encoding="utf-8") as f:
            gate_data = json.load(f)
        assert gate_data["status"] == "pending", f"Status: {gate_data['status']}"

        print(f"[OK] Test  7: Gate-Request erstellen — OK (gate_id: {gid})")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test  7: Gate-Request erstellen — FAILED: {e}")
        failed += 1

    # ── Test 8: Gate-Request resolven ────────────────────────
    try:
        ok = mgr.resolve_gate(
            gate_ids[0],
            decision="Dark Theme",
            note="Passt zur Factory-Identitaet als KI-Wesen",
        )
        assert ok, "resolve_gate returned False"

        gate_path = os.path.join(mgr._gates, f"{gate_ids[0]}.json")
        with open(gate_path, "r", encoding="utf-8") as f:
            gate_data = json.load(f)
        assert gate_data["status"] == "decided", f"Status: {gate_data['status']}"
        assert gate_data["decision"] == "Dark Theme", f"Decision: {gate_data['decision']}"
        assert gate_data.get("decision_note"), "decision_note fehlt"
        assert gate_data.get("decided_at"), "decided_at fehlt"

        print(f"[OK] Test  8: Gate-Request resolven — OK")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test  8: Gate-Request resolven — FAILED: {e}")
        failed += 1

    # ── Test 9: Statistik ────────────────────────────────────
    try:
        stats = mgr.get_alert_stats()
        assert stats["active"] == 0, f"active: {stats['active']}"
        assert stats["acknowledged"] == 0, f"acknowledged: {stats['acknowledged']}"
        assert stats["resolved"] == 2, f"resolved: {stats['resolved']}"
        assert stats["pending_gates"] == 0, f"pending_gates: {stats['pending_gates']}"
        assert isinstance(stats["by_priority"], dict), "by_priority ist kein dict"
        assert isinstance(stats["by_category"], dict), "by_category ist kein dict"

        print(f"[OK] Test  9: Statistik — OK (active=0, resolved=2, gates=0)")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test  9: Statistik — FAILED: {e}")
        failed += 1

    # ── Test 10: Cleanup ─────────────────────────────────────
    try:
        # Alle Test-Dateien loeschen
        for aid in alert_ids:
            for d in [mgr._active, mgr._acknowledged, mgr._resolved]:
                p = os.path.join(d, f"{aid}.json")
                if os.path.exists(p):
                    os.remove(p)

        for gid in gate_ids:
            p = os.path.join(mgr._gates, f"{gid}.json")
            if os.path.exists(p):
                os.remove(p)

        # Pruefen dass alle Verzeichnisse leer sind (nur .gitkeep)
        for d in [mgr._active, mgr._acknowledged, mgr._resolved, mgr._gates]:
            remaining = [f for f in os.listdir(d) if f != ".gitkeep"]
            assert len(remaining) == 0, f"{d} nicht leer: {remaining}"

        print(f"[OK] Test 10: Cleanup — OK")
        passed += 1
    except Exception as e:
        print(f"[FAIL] Test 10: Cleanup — FAILED: {e}")
        failed += 1

    # ── Zusammenfassung ──────────────────────────────────────
    print()
    print("=" * 50)
    if failed == 0:
        print(f"[OK] Marketing Alert System — {passed}/{total} Tests Passed")
    else:
        print(f"[!!] Marketing Alert System — {passed}/{total} Passed, {failed}/{total} Failed")
    print("=" * 50)

    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
