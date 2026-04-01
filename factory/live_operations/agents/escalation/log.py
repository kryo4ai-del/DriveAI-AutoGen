"""Escalation Log -- persistentes JSONL-Log aller Eskalationen."""

import os
import json
from datetime import datetime, timezone


class EscalationLog:
    """Append-only JSONL Log fuer Eskalationen."""

    def __init__(self, data_dir: str) -> None:
        self.log_path = os.path.join(data_dir, "escalation_log.jsonl")

    def append(self, entry: dict) -> None:
        """Fuegt Eintrag zum Log hinzu."""
        try:
            with open(self.log_path, "a", encoding="utf-8") as f:
                f.write(json.dumps(entry, default=str) + "\n")
        except Exception as e:
            print(f"[Escalation Log] Write error: {e}")

    def get_recent(self, limit: int = 20) -> list:
        """Letzte N Eintraege (neueste zuerst)."""
        entries = self._read_all()
        entries.reverse()
        return entries[:limit]

    def get_by_app(self, app_id: str, limit: int = 10) -> list:
        """Eintraege fuer eine bestimmte App."""
        entries = self._read_all()
        filtered = [e for e in entries if e.get("app_id") == app_id]
        filtered.reverse()
        return filtered[:limit]

    def get_stats(self) -> dict:
        """Statistiken ueber alle Eskalationen."""
        entries = self._read_all()
        total = len(entries)
        by_level = {}
        by_source = {}

        for e in entries:
            level = e.get("escalation_level", 0)
            source = e.get("source", "unknown")
            by_level[level] = by_level.get(level, 0) + 1
            by_source[source] = by_source.get(source, 0) + 1

        return {
            "total_escalations": total,
            "by_level": by_level,
            "by_source": by_source,
            "telegram_sent": sum(1 for e in entries if e.get("telegram_sent")),
        }

    def _read_all(self) -> list:
        """Liest alle Eintraege."""
        if not os.path.exists(self.log_path):
            return []
        entries = []
        try:
            with open(self.log_path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line:
                        try:
                            entries.append(json.loads(line))
                        except json.JSONDecodeError:
                            continue
        except Exception:
            pass
        return entries
