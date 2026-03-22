# factory/status/factory_status.py
# Aggregates status across all projects, lines, and builds.

import json
import os
from pathlib import Path

_PROJECTS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "projects")

# File extensions per line
_LINE_EXTENSIONS = {
    "ios": [".swift"],
    "android": [".kt"],
    "web": [".ts", ".tsx"],
    "backend": [".py"],
}


class FactoryStatus:
    """Produces a CEO-readable overview of the entire factory."""

    def __init__(self):
        self._brain_stats = None

    def scan(self) -> dict:
        """Scan all projects and return structured status dict."""
        from factory.brain import FactoryBrain
        brain = FactoryBrain()
        self._brain_stats = brain.stats

        projects = []
        if os.path.isdir(_PROJECTS_DIR):
            for name in sorted(os.listdir(_PROJECTS_DIR)):
                proj_dir = os.path.join(_PROJECTS_DIR, name)
                if not os.path.isdir(proj_dir) or name.startswith("."):
                    continue
                projects.append(self._scan_project(name, proj_dir))

        # Aggregate
        total_active = sum(p["active_line_count"] for p in projects)
        total_planned = sum(p["planned_line_count"] for p in projects)
        total_disabled = sum(p["disabled_line_count"] for p in projects)

        return {
            "brain": self._brain_stats,
            "projects": projects,
            "project_count": len(projects),
            "total_active_lines": total_active,
            "total_planned_lines": total_planned,
            "total_disabled_lines": total_disabled,
        }

    def _scan_project(self, name: str, proj_dir: str) -> dict:
        """Scan a single project."""
        # Load config
        config = None
        try:
            from factory.project_config import load_project_config
            config = load_project_config(name)
        except Exception:
            pass

        proj_name = config.name if config else name
        version = config.version if config else "?"
        status = config.metadata.status if config else "unknown"
        total_runs = config.metadata.total_runs if config else 0
        last_run = config.metadata.last_run if config else ""

        # Lines
        lines = []
        active_count = 0
        planned_count = 0
        disabled_count = 0

        if config and config.lines:
            for line_name, line_cfg in config.lines.items():
                line_status = line_cfg.status
                file_count = self._count_files(proj_dir, line_name)
                build_plan_info = self._get_build_plan_info(proj_dir, line_name)

                lines.append({
                    "name": line_name,
                    "status": line_status,
                    "files": file_count,
                    "build_plan": build_plan_info,
                })

                if line_status == "active":
                    active_count += 1
                elif line_status == "planned":
                    planned_count += 1
                else:
                    disabled_count += 1
        else:
            # No config — scan for Swift files (legacy iOS project)
            swift_count = self._count_files(proj_dir, "ios")
            lines.append({
                "name": "ios",
                "status": "active",
                "files": swift_count,
                "build_plan": None,
            })
            active_count = 1

        # Build plan status
        build_plan_status = self._load_build_plan_status(proj_dir)

        return {
            "slug": name,
            "name": proj_name,
            "version": version,
            "status": status,
            "total_runs": total_runs,
            "last_run": last_run,
            "lines": lines,
            "active_line_count": active_count,
            "planned_line_count": planned_count,
            "disabled_line_count": disabled_count,
            "build_plan_status": build_plan_status,
        }

    def _count_files(self, proj_dir: str, line_name: str) -> int:
        """Count source files for a line in the project directory."""
        extensions = _LINE_EXTENSIONS.get(line_name, [])
        if not extensions:
            return 0

        count = 0
        for root, dirs, files in os.walk(proj_dir):
            # Skip quarantine, generated_code, specs, .git
            rel = os.path.relpath(root, proj_dir)
            if any(skip in rel for skip in ("quarantine", "generated_code", ".git", "specs", "node_modules")):
                continue
            for f in files:
                if any(f.endswith(ext) for ext in extensions):
                    count += 1
        return count

    def _get_build_plan_info(self, proj_dir: str, line_name: str) -> str | None:
        """Get build plan feature count if spec exists."""
        spec_path = os.path.join(proj_dir, "specs", "build_spec.yaml")
        if not os.path.isfile(spec_path):
            return None
        try:
            import yaml
            with open(spec_path, encoding="utf-8") as f:
                spec = yaml.safe_load(f) or {}
            features = spec.get("features", [])
            target_lines = spec.get("target_lines", [])
            if line_name in target_lines:
                return f"{len(features)} features"
        except Exception:
            pass
        return None

    def _load_build_plan_status(self, proj_dir: str) -> dict | None:
        """Load build plan JSON if it exists."""
        plan_path = os.path.join(proj_dir, "specs", "build_plan.json")
        if not os.path.isfile(plan_path):
            return None
        try:
            with open(plan_path, encoding="utf-8") as f:
                data = json.load(f)
            steps = data.get("steps", [])
            return {
                "total": len(steps),
                "completed": sum(1 for s in steps if s.get("status") == "completed"),
                "failed": sum(1 for s in steps if s.get("status") == "failed"),
                "pending": sum(1 for s in steps if s.get("status") == "pending"),
                "skipped": sum(1 for s in steps if s.get("status") == "skipped"),
                "plan_status": data.get("status", "unknown"),
            }
        except Exception:
            return None

    def _get_capability_summary(self) -> str:
        try:
            from factory.capability_registry import CapabilityRegistry
            reg = CapabilityRegistry()
            avail = sum(1 for c in reg.capabilities if c.available)
            total = len(reg.capabilities)
            return f"Capabilities  : {avail}/{total} available"
        except Exception:
            return "Capabilities  : unknown"

    def format_console(self, status: dict) -> str:
        """Format status for console output."""
        lines = []
        w = 64  # width

        lines.append("=" * w)
        lines.append("  DriveAI Swarm Factory — Status Dashboard")
        lines.append("=" * w)
        lines.append("")

        # Brain
        brain = status.get("brain", {})
        total_entries = brain.get("total", 0)
        by_type = brain.get("by_type", {})
        type_parts = ", ".join(f"{v} {k}" for k, v in sorted(by_type.items(), key=lambda x: -x[1]))
        lines.append(f"  Factory Brain   : {total_entries} entries ({type_parts})")
        lines.append(f"  Projects        : {status['project_count']}")
        lines.append(f"  Total Lines     : {status['total_active_lines']} active, "
                      f"{status['total_planned_lines']} planned, "
                      f"{status['total_disabled_lines']} disabled")
        lines.append("")

        # Projects
        for proj in status["projects"]:
            lines.append("─" * w)
            lines.append(f"  PROJECT: {proj['name']} ({proj['slug']})")
            lines.append(f"  Status : {proj['status']} | v{proj['version']} | {proj['total_runs']} runs")
            lines.append("─" * w)

            # Line table header
            lines.append(f"  {'Line':<12}{'Status':<12}{'Files':<9}{'Build Plan':<14}{'Last Run':<12}")

            for line in proj["lines"]:
                status_str = line["status"].upper() if line["status"] == "active" else line["status"]
                files_str = str(line["files"]) if line["files"] > 0 else "—"
                plan_str = line["build_plan"] or "—"
                last_str = proj.get("last_run") or "—"
                if line["status"] != "active":
                    last_str = "—"
                lines.append(f"  {line['name']:<12}{status_str:<12}{files_str:<9}{plan_str:<14}{last_str:<12}")

            # Build plan status
            bps = proj.get("build_plan_status")
            if bps:
                mode = "layered" if bps["total"] > 10 else "flat"
                lines.append(f"\n  Build Plan: {bps['total']} steps ({mode}), "
                              f"{bps['completed']} completed, {bps['failed']} failed, "
                              f"{bps['pending']} pending")

            lines.append("")

        # Summary
        lines.append("=" * w)
        next_action = self._suggest_next_action(status)
        lines.append(f"  Summary: {status['project_count']} projects | "
                      f"{status['total_active_lines']} active lines | "
                      f"{total_entries} brain entries")
        if next_action:
            lines.append(f"  Next action: {next_action}")
        lines.append("=" * w)

        return "\n".join(lines)

    def format_summary(self, status: dict) -> str:
        """Format a compact 5-line summary."""
        brain = status.get("brain", {})
        lines = [
            f"Factory: {status['project_count']} projects, "
            f"{status['total_active_lines']} active lines, "
            f"{brain.get('total', 0)} brain entries",
        ]
        for proj in status["projects"]:
            active_lines = [l["name"] for l in proj["lines"] if l["status"] == "active"]
            total_files = sum(l["files"] for l in proj["lines"])
            lines.append(
                f"  {proj['slug']}: {proj['status']} | "
                f"{', '.join(active_lines)} | "
                f"{total_files} files | "
                f"{proj['total_runs']} runs"
            )
        next_action = self._suggest_next_action(status)
        if next_action:
            lines.append(f"Next: {next_action}")
        return "\n".join(lines)

    def _suggest_next_action(self, status: dict) -> str:
        """Suggest the most obvious next action."""
        ready_for_build = []
        for proj in status["projects"]:
            has_active = any(l["status"] == "active" for l in proj["lines"])
            has_files = any(l["files"] > 0 for l in proj["lines"])
            if has_active and not has_files:
                ready_for_build.append(proj["slug"])

        if ready_for_build:
            return f"{' and '.join(ready_for_build)} ready for first build"
        return ""
