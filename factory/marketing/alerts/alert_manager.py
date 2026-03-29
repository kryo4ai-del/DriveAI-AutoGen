"""Zentrales Alert-System der Marketing-Abteilung.

Verwaltet den Lifecycle von Alerts (open -> acknowledged -> resolved)
und CEO-Gate-Anfragen (pending -> decided).
Alle Alerts werden als JSON-Dateien im Filesystem gespeichert.
Deterministisch, kein LLM.
"""

import json
import logging
import os
import shutil
from datetime import datetime
from typing import Optional

from factory.marketing.alerts.alert_schema import (
    ALERT_PRIORITIES,
    validate_alert,
    validate_gate,
)

logger = logging.getLogger("factory.marketing.alerts")


class MarketingAlertManager:
    """Zentrales Alert-System der Marketing-Abteilung.

    Verwaltet den Lifecycle von Alerts (open -> acknowledged -> resolved)
    und CEO-Gate-Anfragen (pending -> decided).
    Alle Alerts werden als JSON-Dateien im Filesystem gespeichert.
    Deterministisch, kein LLM.
    """

    def __init__(self, base_path: Optional[str] = None) -> None:
        """Init mit Pfad zur Marketing-Abteilung.

        Args:
            base_path: Pfad zu factory/marketing/. Default: automatisch ermittelt.
        """
        if base_path:
            self._base = base_path
        else:
            self._base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

        self._alerts_dir = os.path.join(self._base, "alerts")
        self._active = os.path.join(self._alerts_dir, "active")
        self._acknowledged = os.path.join(self._alerts_dir, "acknowledged")
        self._resolved = os.path.join(self._alerts_dir, "resolved")
        self._gates = os.path.join(self._alerts_dir, "gates")

        # Verzeichnisse erstellen falls nicht vorhanden
        for d in [self._active, self._acknowledged, self._resolved, self._gates]:
            os.makedirs(d, exist_ok=True)

    # ── Alert Lifecycle ──────────────────────────────────────

    def create_alert(
        self,
        type: str,
        priority: str,
        category: str,
        source_agent: str,
        title: str,
        description: str,
        data: Optional[dict] = None,
        action_taken: Optional[str] = None,
        action_required: Optional[str] = None,
    ) -> str:
        """Erstellt einen neuen Alert.

        Returns:
            alert_id im Format MKT-A{NNN}-{YYYYMMDD}-{HHMMSS}
        """
        now = datetime.now()
        counter = self._count_all_alerts() + 1
        alert_id = f"MKT-A{counter:03d}-{now.strftime('%Y%m%d')}-{now.strftime('%H%M%S')}"

        alert = {
            "alert_id": alert_id,
            "timestamp": now.isoformat(),
            "type": type,
            "priority": priority,
            "category": category,
            "source_agent": source_agent,
            "title": title,
            "description": description,
            "status": "open",
        }
        if data is not None:
            alert["data"] = data
        if action_taken is not None:
            alert["action_taken"] = action_taken
        if action_required is not None:
            alert["action_required"] = action_required

        # Validieren
        valid, errors = validate_alert(alert)
        if not valid:
            raise ValueError(f"Alert-Validierung fehlgeschlagen: {errors}")

        # Schreiben
        path = os.path.join(self._active, f"{alert_id}.json")
        self._write_json(path, alert)
        logger.info("Alert erstellt: %s (%s/%s) — %s", alert_id, priority, category, title)
        return alert_id

    def acknowledge_alert(self, alert_id: str) -> bool:
        """Verschiebt Alert von active/ nach acknowledged/.

        Returns:
            True bei Erfolg, False wenn nicht gefunden.
        """
        src = os.path.join(self._active, f"{alert_id}.json")
        if not os.path.exists(src):
            logger.warning("Alert nicht in active/ gefunden: %s", alert_id)
            return False

        alert = self._read_json(src)
        if alert is None:
            return False

        alert["status"] = "acknowledged"
        dst = os.path.join(self._acknowledged, f"{alert_id}.json")
        self._write_json(dst, alert)
        os.remove(src)
        logger.info("Alert acknowledged: %s", alert_id)
        return True

    def resolve_alert(self, alert_id: str, resolution_note: Optional[str] = None) -> bool:
        """Verschiebt Alert von acknowledged/ (oder active/) nach resolved/.

        Returns:
            True bei Erfolg, False wenn nicht gefunden.
        """
        # Suche in acknowledged zuerst, dann active
        src = os.path.join(self._acknowledged, f"{alert_id}.json")
        if not os.path.exists(src):
            src = os.path.join(self._active, f"{alert_id}.json")
            if not os.path.exists(src):
                logger.warning("Alert nicht gefunden: %s", alert_id)
                return False

        alert = self._read_json(src)
        if alert is None:
            return False

        alert["status"] = "resolved"
        alert["resolved_at"] = datetime.now().isoformat()
        if resolution_note:
            alert["resolution_note"] = resolution_note

        dst = os.path.join(self._resolved, f"{alert_id}.json")
        self._write_json(dst, alert)
        os.remove(src)
        logger.info("Alert resolved: %s", alert_id)
        return True

    # ── Gate Lifecycle ───────────────────────────────────────

    def create_gate_request(
        self,
        source_agent: str,
        title: str,
        description: str,
        options: list[dict],
    ) -> str:
        """Erstellt eine CEO-Gate-Anfrage.

        Args:
            options: Liste von dicts mit mindestens {"label": str, "description": str}

        Returns:
            gate_id im Format MKT-G{NNN}-{YYYYMMDD}-{HHMMSS}
        """
        now = datetime.now()
        counter = self._count_all_gates() + 1
        gate_id = f"MKT-G{counter:03d}-{now.strftime('%Y%m%d')}-{now.strftime('%H%M%S')}"

        gate = {
            "gate_id": gate_id,
            "timestamp": now.isoformat(),
            "source_agent": source_agent,
            "title": title,
            "description": description,
            "options": options,
            "status": "pending",
        }

        # Validieren
        valid, errors = validate_gate(gate)
        if not valid:
            raise ValueError(f"Gate-Validierung fehlgeschlagen: {errors}")

        # Schreiben
        path = os.path.join(self._gates, f"{gate_id}.json")
        self._write_json(path, gate)
        logger.info("Gate-Request erstellt: %s — %s", gate_id, title)
        return gate_id

    def resolve_gate(self, gate_id: str, decision: str, note: Optional[str] = None) -> bool:
        """Speichert CEO-Entscheidung im Gate-File.

        Returns:
            True bei Erfolg, False wenn nicht gefunden.
        """
        path = os.path.join(self._gates, f"{gate_id}.json")
        if not os.path.exists(path):
            logger.warning("Gate nicht gefunden: %s", gate_id)
            return False

        gate = self._read_json(path)
        if gate is None:
            return False

        gate["status"] = "decided"
        gate["decision"] = decision
        gate["decided_at"] = datetime.now().isoformat()
        if note:
            gate["decision_note"] = note

        self._write_json(path, gate)
        logger.info("Gate entschieden: %s → %s", gate_id, decision)
        return True

    # ── Queries ──────────────────────────────────────────────

    def get_active_alerts(
        self,
        priority_filter: Optional[str] = None,
        category_filter: Optional[str] = None,
    ) -> list[dict]:
        """Gibt alle offenen Alerts zurueck, optional gefiltert.

        Sortiert nach Prioritaet (critical > high > medium > low), dann Timestamp.
        """
        alerts = self._read_all_json(self._active)

        if priority_filter:
            alerts = [a for a in alerts if a.get("priority") == priority_filter]
        if category_filter:
            alerts = [a for a in alerts if a.get("category") == category_filter]

        priority_order = {p: i for i, p in enumerate(ALERT_PRIORITIES)}
        alerts.sort(key=lambda a: (
            priority_order.get(a.get("priority", "low"), 99),
            a.get("timestamp", ""),
        ))
        return alerts

    def get_pending_gates(self) -> list[dict]:
        """Gibt alle offenen Gate-Anfragen zurueck (status == 'pending').

        Sortiert nach Timestamp (aelteste zuerst).
        """
        gates = self._read_all_json(self._gates)
        pending = [g for g in gates if g.get("status") == "pending"]
        pending.sort(key=lambda g: g.get("timestamp", ""))
        return pending

    def get_alert_stats(self) -> dict:
        """Gibt Alert-Statistik zurueck."""
        active = self._read_all_json(self._active)
        acknowledged = self._read_all_json(self._acknowledged)
        resolved = self._read_all_json(self._resolved)
        pending_gates = [g for g in self._read_all_json(self._gates) if g.get("status") == "pending"]

        by_priority: dict[str, int] = {}
        by_category: dict[str, int] = {}
        for a in active:
            p = a.get("priority", "unknown")
            by_priority[p] = by_priority.get(p, 0) + 1
            c = a.get("category", "unknown")
            by_category[c] = by_category.get(c, 0) + 1

        return {
            "active": len(active),
            "acknowledged": len(acknowledged),
            "resolved": len(resolved),
            "pending_gates": len(pending_gates),
            "by_priority": by_priority,
            "by_category": by_category,
        }

    # ── Interne Helfer ───────────────────────────────────────

    def _count_all_alerts(self) -> int:
        """Zaehlt alle Alert-Dateien ueber alle Verzeichnisse."""
        count = 0
        for d in [self._active, self._acknowledged, self._resolved]:
            if os.path.exists(d):
                count += sum(1 for f in os.listdir(d) if f.endswith(".json"))
        return count

    def _count_all_gates(self) -> int:
        """Zaehlt alle Gate-Dateien."""
        if os.path.exists(self._gates):
            return sum(1 for f in os.listdir(self._gates) if f.endswith(".json"))
        return 0

    def _read_json(self, path: str) -> Optional[dict]:
        """Liest eine JSON-Datei."""
        try:
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.error("JSON lesen fehlgeschlagen: %s — %s", path, e)
            return None

    def _write_json(self, path: str, data: dict) -> None:
        """Schreibt eine JSON-Datei."""
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False, default=str)

    def _read_all_json(self, directory: str) -> list[dict]:
        """Liest alle JSON-Dateien in einem Verzeichnis."""
        results: list[dict] = []
        if not os.path.exists(directory):
            return results
        for fname in os.listdir(directory):
            if not fname.endswith(".json"):
                continue
            data = self._read_json(os.path.join(directory, fname))
            if data is not None:
                results.append(data)
        return results
