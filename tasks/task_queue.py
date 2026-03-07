# task_queue.py
# Persistent task queue for DriveAI-AutoGen pipeline runs.

import json
import os
from datetime import datetime

QUEUE_PATH = os.path.join(os.path.dirname(__file__), "task_queue.json")


def _load_queue() -> dict:
    if not os.path.exists(QUEUE_PATH):
        return {"pending": [], "in_progress": [], "completed": [], "failed": []}
    data = json.load(open(QUEUE_PATH, encoding="utf-8"))
    # Migrate older files that don't have a failed section
    data.setdefault("failed", [])
    return data


def _save_queue(data: dict) -> None:
    with open(QUEUE_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


class TaskQueue:
    def __init__(self):
        self.queue = _load_queue()

    def _save(self) -> None:
        _save_queue(self.queue)

    def add_task(self, task_text: str) -> None:
        """Add a new task to the pending queue."""
        entry = {
            "task": task_text,
            "added_at": datetime.now().isoformat(),
        }
        self.queue["pending"].append(entry)
        self._save()

    def get_next_task(self) -> str | None:
        """Return the text of the next pending task, or None if queue is empty."""
        if not self.queue["pending"]:
            return None
        return self.queue["pending"][0]["task"]

    def start_task(self, task_text: str) -> None:
        """Move the first matching pending task to in_progress."""
        for i, entry in enumerate(self.queue["pending"]):
            if entry["task"] == task_text:
                entry["started_at"] = datetime.now().isoformat()
                self.queue["in_progress"].append(entry)
                self.queue["pending"].pop(i)
                self._save()
                return

    def complete_task(self, task_text: str) -> None:
        """Move the first matching in_progress task to completed."""
        for i, entry in enumerate(self.queue["in_progress"]):
            if entry["task"] == task_text:
                entry["completed_at"] = datetime.now().isoformat()
                self.queue["completed"].append(entry)
                self.queue["in_progress"].pop(i)
                self._save()
                return

    def fail_task(self, task_text: str, error_message: str | None = None) -> None:
        """Move a failed in_progress task to the failed list."""
        for i, entry in enumerate(self.queue["in_progress"]):
            if entry["task"] == task_text:
                entry["failed_at"] = datetime.now().isoformat()
                if error_message:
                    entry["error"] = error_message
                self.queue["failed"].append(entry)
                self.queue["in_progress"].pop(i)
                self._save()
                return

    def get_failed_tasks(self) -> list:
        """Return the current list of failed task entries."""
        return self.queue["failed"]

    def retry_failed_task(self, task_text: str) -> bool:
        """Move a specific failed task back to pending. Returns True if found."""
        for i, entry in enumerate(self.queue["failed"]):
            if entry["task"] == task_text:
                entry.pop("failed_at", None)
                entry.pop("error", None)
                entry["retried_at"] = datetime.now().isoformat()
                self.queue["pending"].append(entry)
                self.queue["failed"].pop(i)
                self._save()
                return True
        return False

    def retry_all_failed_tasks(self) -> int:
        """Move all failed tasks back to pending. Returns count of moved tasks."""
        count = len(self.queue["failed"])
        for entry in self.queue["failed"]:
            entry.pop("failed_at", None)
            entry.pop("error", None)
            entry["retried_at"] = datetime.now().isoformat()
            self.queue["pending"].append(entry)
        self.queue["failed"] = []
        self._save()
        return count

    def get_queue_summary(self) -> str:
        """Return a formatted summary of all queue sections."""
        pending = self.queue["pending"]
        in_progress = self.queue["in_progress"]
        completed = self.queue["completed"]
        failed = self.queue["failed"]

        lines = [
            "=== Task Queue Summary ===",
            "",
            f"Pending    : {len(pending)}",
        ]
        for i, e in enumerate(pending, 1):
            lines.append(f"  {i}. {e['task']}")

        lines.append(f"In Progress: {len(in_progress)}")
        for e in in_progress:
            lines.append(f"  - {e['task']}")

        lines.append(f"Completed  : {len(completed)}")
        for e in completed:
            lines.append(f"  ✓ {e['task']}")

        lines.append(f"Failed     : {len(failed)}")
        for e in failed:
            error = f"  ({e['error']})" if e.get("error") else ""
            lines.append(f"  ✗ {e['task']}{error}")

        return "\n".join(lines)

    def get_failed_summary(self) -> str:
        """Return a formatted summary of failed tasks only."""
        failed = self.queue["failed"]
        if not failed:
            return "No failed tasks."
        lines = [f"Failed tasks: {len(failed)}", ""]
        for i, e in enumerate(failed, 1):
            lines.append(f"  {i}. {e['task']}")
            if e.get("failed_at"):
                lines.append(f"     Failed at : {e['failed_at']}")
            if e.get("error"):
                lines.append(f"     Error     : {e['error']}")
        return "\n".join(lines)
