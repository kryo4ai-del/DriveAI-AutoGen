# feature_planner.py
# Tracks planned, in-progress, and completed features for the DriveAI app.

import json
import os

BACKLOG_PATH = os.path.join(os.path.dirname(__file__), "feature_backlog.json")

DEFAULT_BACKLOG = {
    "planned": [],
    "in_progress": [],
    "completed": [],
}


class FeaturePlanner:
    def __init__(self):
        self.backlog = self.load_backlog()

    def load_backlog(self) -> dict:
        try:
            with open(BACKLOG_PATH, encoding="utf-8") as f:
                data = json.load(f)
            for key in DEFAULT_BACKLOG:
                data.setdefault(key, [])
            return data
        except (FileNotFoundError, json.JSONDecodeError):
            return dict(DEFAULT_BACKLOG)

    def save_backlog(self) -> None:
        with open(BACKLOG_PATH, "w", encoding="utf-8") as f:
            json.dump(self.backlog, f, indent=2, ensure_ascii=False)

    def add_feature(self, feature_name: str) -> None:
        if feature_name not in self.backlog["planned"] \
                and feature_name not in self.backlog["in_progress"] \
                and feature_name not in self.backlog["completed"]:
            self.backlog["planned"].append(feature_name)
            self.save_backlog()

    def start_feature(self, feature_name: str) -> None:
        if feature_name in self.backlog["planned"]:
            self.backlog["planned"].remove(feature_name)
            self.backlog["in_progress"].append(feature_name)
            self.save_backlog()

    def complete_feature(self, feature_name: str) -> None:
        for section in ("in_progress", "planned"):
            if feature_name in self.backlog[section]:
                self.backlog[section].remove(feature_name)
                self.backlog["completed"].append(feature_name)
                self.save_backlog()
                return

    def get_next_feature(self) -> str | None:
        if self.backlog["planned"]:
            return self.backlog["planned"][0]
        return None

    def get_summary(self) -> str:
        p = len(self.backlog["planned"])
        i = len(self.backlog["in_progress"])
        c = len(self.backlog["completed"])
        lines = [f"Features — planned: {p}  in_progress: {i}  completed: {c}"]
        if self.backlog["planned"]:
            lines.append(f"  Next: {self.backlog['planned'][0]}")
        return "\n".join(lines)
