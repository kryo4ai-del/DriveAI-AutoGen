"""Marketing Alert Schema — Definiert Struktur und Validierung fuer alle Marketing-Alerts."""

from datetime import datetime

ALERT_TYPES = ("alert", "warning", "info", "gate_request")
ALERT_PRIORITIES = ("critical", "high", "medium", "low")
ALERT_CATEGORIES = ("budget", "app_performance", "ranking", "sentiment", "community", "system")
ALERT_STATUSES = ("open", "acknowledged", "resolved")

REQUIRED_FIELDS = {
    "alert_id",
    "timestamp",
    "type",
    "priority",
    "category",
    "source_agent",
    "title",
    "description",
    "status",
}

OPTIONAL_FIELDS = {
    "source_kernbereich",
    "data",
    "action_taken",
    "action_required",
    "resolved_at",
    "resolution_note",
}

GATE_REQUIRED_FIELDS = {
    "gate_id",
    "timestamp",
    "source_agent",
    "title",
    "description",
    "options",
    "status",
}

GATE_OPTIONAL_FIELDS = {
    "decision",
    "decision_note",
    "decided_at",
}

GATE_STATUSES = ("pending", "decided")


def validate_alert(data: dict) -> tuple[bool, list[str]]:
    """Validiert einen Alert gegen das Schema.

    Returns:
        (True, []) bei Erfolg, (False, [fehler1, ...]) bei Fehlern.
    """
    errors: list[str] = []

    # Pflichtfelder pruefen
    for field in REQUIRED_FIELDS:
        if field not in data:
            errors.append(f"Pflichtfeld fehlt: {field}")

    if errors:
        return False, errors

    # Typ-Validierung
    if data["type"] not in ALERT_TYPES:
        errors.append(f"Ungueltiger type: {data['type']} (erlaubt: {ALERT_TYPES})")

    if data["priority"] not in ALERT_PRIORITIES:
        errors.append(f"Ungueltige priority: {data['priority']} (erlaubt: {ALERT_PRIORITIES})")

    if data["category"] not in ALERT_CATEGORIES:
        errors.append(f"Ungueltige category: {data['category']} (erlaubt: {ALERT_CATEGORIES})")

    if data["status"] not in ALERT_STATUSES:
        errors.append(f"Ungueltiger status: {data['status']} (erlaubt: {ALERT_STATUSES})")

    # Timestamp-Format pruefen
    try:
        datetime.fromisoformat(data["timestamp"])
    except (ValueError, TypeError):
        errors.append(f"Ungueltiges Timestamp-Format: {data.get('timestamp')}")

    # alert_id Format pruefen (MKT-A{NNN}-{YYYYMMDD}-{HHMMSS})
    aid = data.get("alert_id", "")
    if not aid.startswith("MKT-A"):
        errors.append(f"alert_id muss mit 'MKT-A' beginnen: {aid}")

    # Unbekannte Felder pruefen
    known = REQUIRED_FIELDS | OPTIONAL_FIELDS
    for key in data:
        if key not in known:
            errors.append(f"Unbekanntes Feld: {key}")

    return (len(errors) == 0), errors


def validate_gate(data: dict) -> tuple[bool, list[str]]:
    """Validiert eine Gate-Anfrage gegen das Schema.

    Returns:
        (True, []) bei Erfolg, (False, [fehler1, ...]) bei Fehlern.
    """
    errors: list[str] = []

    # Pflichtfelder pruefen
    for field in GATE_REQUIRED_FIELDS:
        if field not in data:
            errors.append(f"Pflichtfeld fehlt: {field}")

    if errors:
        return False, errors

    # Status validieren
    if data["status"] not in GATE_STATUSES:
        errors.append(f"Ungueltiger status: {data['status']} (erlaubt: {GATE_STATUSES})")

    # Timestamp pruefen
    try:
        datetime.fromisoformat(data["timestamp"])
    except (ValueError, TypeError):
        errors.append(f"Ungueltiges Timestamp-Format: {data.get('timestamp')}")

    # gate_id Format pruefen
    gid = data.get("gate_id", "")
    if not gid.startswith("MKT-G"):
        errors.append(f"gate_id muss mit 'MKT-G' beginnen: {gid}")

    # Options validieren
    options = data.get("options", [])
    if not isinstance(options, list) or len(options) == 0:
        errors.append("options muss eine nicht-leere Liste sein")
    else:
        for i, opt in enumerate(options):
            if not isinstance(opt, dict):
                errors.append(f"options[{i}] muss ein dict sein")
            elif "label" not in opt or "description" not in opt:
                errors.append(f"options[{i}] braucht 'label' und 'description'")

    # Unbekannte Felder pruefen
    known = GATE_REQUIRED_FIELDS | GATE_OPTIONAL_FIELDS
    for key in data:
        if key not in known:
            errors.append(f"Unbekanntes Feld: {key}")

    return (len(errors) == 0), errors
