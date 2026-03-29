"""Geteilte Utility-Funktionen fuer die Marketing-Abteilung."""

import json
import logging
import os
from datetime import datetime
from typing import Optional

logger = logging.getLogger("factory.marketing.shared")


def get_factory_root() -> str:
    """Ermittelt den Factory-Root-Pfad (factory/)."""
    return os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def get_project_root() -> str:
    """Ermittelt den Projekt-Root-Pfad (DriveAI-AutoGen/)."""
    return os.path.dirname(get_factory_root())


def ensure_dir(path: str) -> None:
    """Erstellt Verzeichnis falls nicht vorhanden."""
    os.makedirs(path, exist_ok=True)


def read_json(path: str) -> Optional[dict]:
    """Liest JSON-Datei, gibt None bei Fehler zurueck."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        logger.warning("JSON lesen fehlgeschlagen: %s — %s", path, e)
        return None


def write_json(path: str, data: dict, indent: int = 2) -> bool:
    """Schreibt JSON-Datei.

    Returns:
        True bei Erfolg, False bei Fehler.
    """
    try:
        ensure_dir(os.path.dirname(path))
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=indent, ensure_ascii=False, default=str)
        return True
    except Exception as e:
        logger.error("JSON schreiben fehlgeschlagen: %s — %s", path, e)
        return False


def timestamp_now() -> str:
    """Gibt aktuellen Timestamp als ISO 8601 String zurueck."""
    return datetime.now().isoformat()


def generate_id(prefix: str, counter: int, timestamp: bool = True) -> str:
    """Generiert eine ID im Factory-Format.

    Args:
        prefix: z.B. "MKT-A"
        counter: Laufende Nummer
        timestamp: Wenn True, haengt YYYYMMDD-HHMMSS an

    Returns:
        z.B. "MKT-A001-20260326-143022"
    """
    base = f"{prefix}{counter:03d}"
    if timestamp:
        now = datetime.now()
        base += f"-{now.strftime('%Y%m%d')}-{now.strftime('%H%M%S')}"
    return base
