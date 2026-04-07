"""
DriveAI Mac Factory — Persistent Learning Database

Pre-seeded with GrowMeldAI data. Learns across all projects and runs.
"""

import json
import os
from pathlib import Path


class LearningDB:
    DEFAULT_PATH = Path(__file__).parent / "knowledge" / "learning_db.json"

    def __init__(self, db_path=None):
        self.db_path = Path(db_path) if db_path else self.DEFAULT_PATH
        self.data = self._load()

    def _load(self) -> dict:
        if self.db_path.exists():
            try:
                with open(self.db_path) as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                backup = str(self.db_path) + ".bak"
                try:
                    os.rename(self.db_path, backup)
                except OSError:
                    pass
        return self._get_seed_data()

    def _save(self):
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.db_path, "w") as f:
            json.dump(self.data, f, indent=2)

    def _get_seed_data(self) -> dict:
        return {
            "version": "1.0",
            "seed_source": "GrowMeldAI Fix Protocol (2026-04-07)",
            "patterns": {
                "invalid_redeclaration": {
                    "occurrences": 460,
                    "fixes": {
                        "deduplicate": {"attempts": 279, "successes": 275},
                        "empty_file": {"attempts": 163, "successes": 160},
                        "repair_tier1": {"attempts": 18, "successes": 18}
                    },
                    "best_fix": "deduplicate",
                    "success_rate": 0.986
                },
                "cannot_find_in_scope": {
                    "occurrences": 300,
                    "fixes": {
                        "repair_tier1": {"attempts": 280, "successes": 275},
                        "repair_tier2": {"attempts": 20, "successes": 15}
                    },
                    "best_fix": "repair_tier1",
                    "success_rate": 0.982
                },
                "cannot_find_type": {
                    "occurrences": 200,
                    "fixes": {
                        "repair_tier1": {"attempts": 180, "successes": 175},
                        "iterative_stub": {"attempts": 20, "successes": 18}
                    },
                    "best_fix": "repair_tier1",
                    "success_rate": 0.972
                },
                "unknown_attribute": {
                    "occurrences": 100,
                    "fixes": {
                        "repair_tier1": {"attempts": 95, "successes": 93}
                    },
                    "best_fix": "repair_tier1",
                    "success_rate": 0.979
                },
                "llm_garbage": {
                    "occurrences": 4,
                    "fixes": {
                        "empty_file": {"attempts": 4, "successes": 4}
                    },
                    "best_fix": "empty_file",
                    "success_rate": 1.0
                },
                "duplicate_type": {
                    "occurrences": 3,
                    "fixes": {
                        "deduplicate": {"attempts": 2, "successes": 2},
                        "empty_file": {"attempts": 1, "successes": 1}
                    },
                    "best_fix": "deduplicate",
                    "success_rate": 1.0
                },
                "top_level_expression": {
                    "occurrences": 120,
                    "fixes": {
                        "empty_file": {"attempts": 100, "successes": 98},
                        "quarantine": {"attempts": 20, "successes": 20}
                    },
                    "best_fix": "empty_file",
                    "success_rate": 0.983
                },
                "consecutive_statements": {
                    "occurrences": 80,
                    "fixes": {
                        "empty_file": {"attempts": 70, "successes": 68},
                        "quarantine": {"attempts": 10, "successes": 10}
                    },
                    "best_fix": "empty_file",
                    "success_rate": 0.975
                },
                "multiple_main": {
                    "occurrences": 18,
                    "fixes": {
                        "repair_tier1": {"attempts": 18, "successes": 18}
                    },
                    "best_fix": "repair_tier1",
                    "success_rate": 1.0
                },
                "type_check_timeout": {
                    "occurrences": 1,
                    "fixes": {
                        "iterative_stub": {"attempts": 1, "successes": 1}
                    },
                    "best_fix": "iterative_stub",
                    "success_rate": 1.0
                }
            },
            "global_stats": {
                "total_runs": 1,
                "total_errors_seen": 1800,
                "total_errors_fixed": 1710,
                "overall_fix_rate": 0.95
            }
        }

    def record(self, error_pattern: str, fix_action: str, success: bool):
        patterns = self.data.setdefault("patterns", {})
        if error_pattern not in patterns:
            patterns[error_pattern] = {
                "occurrences": 0, "fixes": {}, "best_fix": "", "success_rate": 0.0
            }

        entry = patterns[error_pattern]
        entry["occurrences"] += 1
        if fix_action not in entry["fixes"]:
            entry["fixes"][fix_action] = {"attempts": 0, "successes": 0}
        entry["fixes"][fix_action]["attempts"] += 1
        if success:
            entry["fixes"][fix_action]["successes"] += 1

        best_fix = ""
        best_rate = 0.0
        for action, stats in entry["fixes"].items():
            if stats["attempts"] >= 1:
                rate = stats["successes"] / stats["attempts"]
                if rate > best_rate:
                    best_rate = rate
                    best_fix = action
        entry["best_fix"] = best_fix
        entry["success_rate"] = round(best_rate, 3)

        gs = self.data.setdefault("global_stats", {})
        gs["total_errors_seen"] = gs.get("total_errors_seen", 0) + 1
        if success:
            gs["total_errors_fixed"] = gs.get("total_errors_fixed", 0) + 1
        total = gs.get("total_errors_seen", 1)
        gs["overall_fix_rate"] = round(gs.get("total_errors_fixed", 0) / total, 3)

        self._save()

    def record_run(self):
        gs = self.data.setdefault("global_stats", {})
        gs["total_runs"] = gs.get("total_runs", 0) + 1
        self._save()

    def get_best_fix(self, error_pattern: str, min_occurrences: int = 3) -> str:
        entry = self.data.get("patterns", {}).get(error_pattern)
        if entry and entry.get("occurrences", 0) >= min_occurrences:
            return entry.get("best_fix", "")
        return ""

    def get_confidence(self, error_pattern: str) -> float:
        entry = self.data.get("patterns", {}).get(error_pattern)
        if entry and entry.get("occurrences", 0) >= 3:
            return entry.get("success_rate", 0.0)
        return 0.0

    def get_stats(self) -> dict:
        gs = self.data.get("global_stats", {})
        patterns = self.data.get("patterns", {})
        top = sorted(
            [(k, v.get("occurrences", 0), v.get("best_fix", ""), v.get("success_rate", 0))
             for k, v in patterns.items()],
            key=lambda x: -x[1]
        )[:10]
        return {
            "total_runs": gs.get("total_runs", 0),
            "total_errors_seen": gs.get("total_errors_seen", 0),
            "total_errors_fixed": gs.get("total_errors_fixed", 0),
            "overall_fix_rate": gs.get("overall_fix_rate", 0),
            "known_patterns": len(patterns),
            "top_patterns": [
                {"pattern": p[0], "occurrences": p[1], "best_fix": p[2], "rate": p[3]}
                for p in top
            ]
        }

    def print_report(self):
        s = self.get_stats()
        print(f"[Learning] {s['total_runs']} runs, {s['total_errors_seen']} errors, "
              f"{s['total_errors_fixed']} fixed ({s['overall_fix_rate']:.0%})")
        print(f"[Learning] {s['known_patterns']} known patterns")
        for p in s['top_patterns'][:5]:
            print(f"[Learning]   {p['pattern']}: {p['occurrences']}x -> {p['best_fix']} ({p['rate']:.0%})")
