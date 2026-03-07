# analytics_tracker.py
# Tracks and summarizes key metrics across pipeline runs.

import json
import os

ANALYTICS_PATH = os.path.join(os.path.dirname(__file__), "analytics_summary.json")

_DEFAULT = {
    "total_runs": 0,
    "successful_runs": 0,
    "failed_runs": 0,
    "task_sources": {"cli": 0, "backlog": 0, "sample": 0, "queue": 0},
    "run_modes": {"quick": 0, "standard": 0, "full": 0},
    "approval_modes": {"auto": 0, "ask": 0, "off": 0},
    "generated_files_total": 0,
    "integrated_files_total": 0,
    "message_totals": {
        "implementation": 0,
        "bug_review": 0,
        "refactor": 0,
        "test_generation": 0,
        "fix_execution": 0,
        "overall": 0,
    },
}


def _deep_merge(base: dict, override: dict) -> dict:
    """Return base with any missing keys filled in from override."""
    result = dict(override)
    for k, v in base.items():
        if k not in result:
            result[k] = v
        elif isinstance(v, dict) and isinstance(result[k], dict):
            result[k] = _deep_merge(v, result[k])
    return result


class AnalyticsTracker:
    def load_analytics(self) -> dict:
        if not os.path.exists(ANALYTICS_PATH):
            return json.loads(json.dumps(_DEFAULT))
        with open(ANALYTICS_PATH, encoding="utf-8") as f:
            data = json.load(f)
        # Ensure all expected keys exist (migration-safe)
        return _deep_merge(_DEFAULT, data)

    def save_analytics(self, data: dict) -> None:
        with open(ANALYTICS_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    def update_from_manifest(self, manifest_data: dict) -> None:
        """Load analytics, apply manifest metrics, and persist."""
        data = self.load_analytics()

        data["total_runs"] += 1
        if manifest_data.get("status") == "success":
            data["successful_runs"] += 1
        else:
            data["failed_runs"] += 1

        # Task source
        task_source: str = manifest_data.get("task_source", "")
        if "queue" in task_source:
            data["task_sources"]["queue"] += 1
        elif "backlog" in task_source:
            data["task_sources"]["backlog"] += 1
        elif "sample" in task_source:
            data["task_sources"]["sample"] += 1
        else:
            data["task_sources"]["cli"] += 1

        # Run mode
        run_mode = manifest_data.get("run_mode", "")
        if run_mode in data["run_modes"]:
            data["run_modes"][run_mode] += 1

        # Approval mode
        approval_mode = manifest_data.get("approval_mode", "")
        if approval_mode in data["approval_modes"]:
            data["approval_modes"][approval_mode] += 1

        # File counts
        data["generated_files_total"] += len(manifest_data.get("generated_files", []))
        data["integrated_files_total"] += len(manifest_data.get("integrated_files", []))

        # Message counts
        counts = manifest_data.get("message_counts", {})
        mt = data["message_totals"]
        mt["implementation"] += counts.get("implementation", 0)
        mt["bug_review"] += counts.get("bug_review", 0)
        mt["refactor"] += counts.get("refactor", 0)
        mt["test_generation"] += counts.get("test_generation", 0)
        mt["fix_execution"] += counts.get("fix_execution", 0)
        mt["overall"] += counts.get("total", 0)

        self.save_analytics(data)

    def get_summary_text(self) -> str:
        data = self.load_analytics()
        ts = data["task_sources"]
        rm = data["run_modes"]
        am = data["approval_modes"]
        mt = data["message_totals"]

        lines = [
            "Analytics Summary",
            "-" * 40,
            f"Total runs      : {data['total_runs']}",
            f"Successful runs : {data['successful_runs']}",
            f"Failed runs     : {data['failed_runs']}",
            "",
            "Task sources:",
            f"  cli     : {ts['cli']}",
            f"  backlog : {ts['backlog']}",
            f"  queue   : {ts['queue']}",
            f"  sample  : {ts['sample']}",
            "",
            "Run modes:",
            f"  quick    : {rm['quick']}",
            f"  standard : {rm['standard']}",
            f"  full     : {rm['full']}",
            "",
            "Approval modes:",
            f"  auto : {am['auto']}",
            f"  ask  : {am['ask']}",
            f"  off  : {am['off']}",
            "",
            f"Generated files total  : {data['generated_files_total']}",
            f"Integrated files total : {data['integrated_files_total']}",
            "",
            "Messages exchanged:",
            f"  implementation : {mt['implementation']}",
            f"  bug review     : {mt['bug_review']}",
            f"  refactor       : {mt['refactor']}",
            f"  test generation: {mt['test_generation']}",
            f"  fix execution  : {mt['fix_execution']}",
            f"  overall        : {mt['overall']}",
        ]
        return "\n".join(lines)
