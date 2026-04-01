"""Escalation Manager -- zentrale Eskalationslogik.

3 Stufen:
  1 = Info:     Dashboard-Protokoll, kein Alert
  2 = Warning:  Dashboard prominent, CEO kann lesen
  3 = CEO:      Dashboard + Telegram-Nachricht

Entscheidet NICHT selbst ueber das Level -- bekommt es von
Decision Engine oder Anomaly Detector.
"""

import os
from datetime import datetime, timezone
from typing import Optional

from . import config
from .log import EscalationLog
from .telegram_notifier import TelegramNotifier


class EscalationManager:
    """Verarbeitet Eskalationen basierend auf Level."""

    def __init__(self, data_dir: str = None) -> None:
        if data_dir is None:
            base = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
            data_dir = os.path.join(base, "data", "escalation")
        os.makedirs(data_dir, exist_ok=True)

        self.log = EscalationLog(data_dir)
        self.notifier = TelegramNotifier()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def escalate(self, event: dict) -> dict:
        """Verarbeitet ein Eskalations-Event.

        event muss enthalten:
          - app_id: str
          - escalation_level: int (1-3)
          - source: str (decision_engine / anomaly_detector)
          - action_type: str
          - detail: str
          - recommendation: str (optional)
          - severity: float (optional)
        """
        level = event.get("escalation_level", 0)
        app_id = event.get("app_id", "unknown")
        source = event.get("source", "unknown")
        action_type = event.get("action_type", "unknown")
        detail = event.get("detail", "")

        label = config.LEVEL_LABELS.get(level, "unknown")
        print(f"[Escalation] Level {level} ({label}) for {app_id} from {source}")

        # Build log entry
        entry = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "app_id": app_id,
            "escalation_level": level,
            "level_label": label,
            "source": source,
            "action_type": action_type,
            "detail": detail,
            "recommendation": event.get("recommendation", ""),
            "severity": event.get("severity", 0),
            "telegram_sent": False,
            "telegram_error": None,
        }

        # Level 3: Send Telegram
        if level >= config.LEVEL_CEO:
            telegram_result = self._send_telegram(app_id, action_type, detail, event)
            entry["telegram_sent"] = telegram_result.get("sent", False)
            entry["telegram_error"] = telegram_result.get("error")

        # Log
        self.log.append(entry)

        return entry

    def escalate_from_decision(self, decision: dict) -> Optional[dict]:
        """Convenience: Eskalation aus Decision Engine Ergebnis."""
        level = decision.get("escalation_level", 0)
        if level < 1:
            return None

        event = {
            "app_id": decision.get("app_id", ""),
            "escalation_level": level,
            "source": "decision_engine",
            "action_type": decision.get("action_type", "none"),
            "detail": decision.get("recommendation", ""),
            "recommendation": decision.get("recommendation", ""),
            "severity": decision.get("data_summary", {}).get("max_severity", 0),
        }
        return self.escalate(event)

    def escalate_from_anomaly(self, anomaly: dict, rollback_report: dict = None) -> Optional[dict]:
        """Convenience: Eskalation aus Anomaly Detector Ergebnis."""
        level = anomaly.get("escalation_level", 0)
        if level < 1:
            return None

        detail = anomaly.get("detail", "")
        if rollback_report and rollback_report.get("success"):
            detail += f" | Auto-Rollback: {rollback_report['rolled_back_from']} -> {rollback_report['rolled_back_to']}"

        event = {
            "app_id": anomaly.get("app_id", ""),
            "escalation_level": level,
            "source": "anomaly_detector",
            "action_type": anomaly.get("recommended_action", "escalate"),
            "detail": detail,
            "recommendation": anomaly.get("recommended_action", ""),
            "severity": 100 if anomaly.get("severity") == "critical" else 75,
        }
        return self.escalate(event)

    # ------------------------------------------------------------------
    # Query
    # ------------------------------------------------------------------

    def get_recent(self, limit: int = 20) -> list:
        """Letzte Eskalationen."""
        return self.log.get_recent(limit)

    def get_by_app(self, app_id: str, limit: int = 10) -> list:
        """Eskalationen fuer eine App."""
        return self.log.get_by_app(app_id, limit)

    def get_ceo_pending(self) -> list:
        """Alle Level-3 Eskalationen die noch nicht acknowledged sind."""
        return [e for e in self.log.get_recent(50)
                if e.get("escalation_level", 0) >= 3
                and not e.get("acknowledged")]

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _send_telegram(self, app_id: str, action_type: str,
                       detail: str, event: dict) -> dict:
        """Telegram-Nachricht fuer Level 3."""
        severity = event.get("severity", 0)
        recommendation = event.get("recommendation", "")

        message = self._format_telegram_message(
            app_id, action_type, detail, severity, recommendation
        )

        return self.notifier.send(message)

    def _format_telegram_message(self, app_id: str, action_type: str,
                                 detail: str, severity: float,
                                 recommendation: str) -> str:
        """Formatiert Telegram-Nachricht -- kurz und knapp."""
        lines = [
            f"[DriveAI Live Ops] CEO-Eskalation",
            f"",
            f"App: {app_id}",
            f"Aktion: {action_type}",
            f"Severity: {severity:.0f}/100",
            f"",
            f"{detail}",
        ]
        if recommendation:
            lines.append(f"")
            lines.append(f"Empfehlung: {recommendation}")
        lines.append(f"")
        lines.append(f"Details im Dashboard.")
        return "\n".join(lines)
