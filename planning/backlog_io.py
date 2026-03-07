# backlog_io.py
# Export and import feature backlog and task queue in JSON format.

import json
import os

BACKLOG_PATH = os.path.join(os.path.dirname(__file__), "feature_backlog.json")
QUEUE_PATH = os.path.join(os.path.dirname(__file__), "..", "tasks", "task_queue.json")

_BACKLOG_SECTIONS = ("planned", "in_progress", "completed")
_QUEUE_SECTIONS = ("pending", "in_progress", "completed", "failed")


def _load_json(path: str) -> dict:
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def _save_json(path: str, data: dict) -> None:
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


class BacklogIO:

    # ── Feature Backlog ──────────────────────────────────────────────

    def export_backlog(self, export_path: str) -> None:
        """Write the current feature backlog to export_path as JSON."""
        data = _load_json(BACKLOG_PATH)
        for section in _BACKLOG_SECTIONS:
            data.setdefault(section, [])
        _save_json(export_path, data)

    def import_backlog(self, import_path: str, merge: bool = True) -> dict:
        """
        Import feature backlog from import_path.
        merge=True  — add new entries to each section without duplicating.
        merge=False — replace the existing backlog completely.
        Returns a dict with counts of items added per section (merge) or total items (replace).
        """
        imported = _load_json(import_path)
        if not isinstance(imported, dict):
            raise ValueError(f"Invalid backlog file: expected a JSON object in {import_path}")

        if not merge:
            normalized = {s: list(imported.get(s, [])) for s in _BACKLOG_SECTIONS}
            _save_json(BACKLOG_PATH, normalized)
            return {s: len(normalized[s]) for s in _BACKLOG_SECTIONS}

        current = _load_json(BACKLOG_PATH)
        for section in _BACKLOG_SECTIONS:
            current.setdefault(section, [])

        added = {s: 0 for s in _BACKLOG_SECTIONS}
        for section in _BACKLOG_SECTIONS:
            existing = set(current[section])
            for item in imported.get(section, []):
                if isinstance(item, str) and item not in existing:
                    current[section].append(item)
                    existing.add(item)
                    added[section] += 1

        _save_json(BACKLOG_PATH, current)
        return added

    # ── Task Queue ───────────────────────────────────────────────────

    def export_queue(self, export_path: str) -> None:
        """Write the current task queue to export_path as JSON."""
        data = _load_json(QUEUE_PATH)
        for section in _QUEUE_SECTIONS:
            data.setdefault(section, [])
        _save_json(export_path, data)

    def import_queue(self, import_path: str, merge: bool = True) -> dict:
        """
        Import task queue from import_path.
        merge=True  — add new entries (by task text) to each section without duplicating.
        merge=False — replace the existing queue completely.
        Returns a dict with counts of items added per section (merge) or total items (replace).
        """
        imported = _load_json(import_path)
        if not isinstance(imported, dict):
            raise ValueError(f"Invalid queue file: expected a JSON object in {import_path}")

        if not merge:
            normalized = {s: list(imported.get(s, [])) for s in _QUEUE_SECTIONS}
            _save_json(QUEUE_PATH, normalized)
            return {s: len(normalized[s]) for s in _QUEUE_SECTIONS}

        current = _load_json(QUEUE_PATH)
        for section in _QUEUE_SECTIONS:
            current.setdefault(section, [])

        added = {s: 0 for s in _QUEUE_SECTIONS}
        for section in _QUEUE_SECTIONS:
            existing_tasks = {e["task"] for e in current[section] if isinstance(e, dict) and "task" in e}
            for entry in imported.get(section, []):
                if isinstance(entry, dict) and "task" in entry and entry["task"] not in existing_tasks:
                    current[section].append(entry)
                    existing_tasks.add(entry["task"])
                    added[section] += 1

        _save_json(QUEUE_PATH, current)
        return added
