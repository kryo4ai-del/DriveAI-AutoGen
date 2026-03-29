"""Capability Watcher -- Re-checks parked projects.

When new capabilities are added to the factory, parked projects might
become feasible. This module re-checks all parked projects and creates
gates when a project's status improves.

Not a daemon -- triggered via CLI or Dashboard button.
"""

import json
from datetime import datetime
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent.parent
_GATES_DIR = _ROOT / "factory" / "hq" / "gates"


class CapabilityWatcher:
    """Re-checks parked projects against current capabilities."""

    def check_parked_projects(self) -> list[dict]:
        """Re-check all parked projects.

        Returns list of projects that changed status::

            [{"slug": "memerun2026", "old_status": "parked_blocked",
              "new_status": "feasible", "score": 0.95}]
        """
        from factory.shared.project_registry import get_all_projects
        from factory.hq.capabilities.feasibility_check import FeasibilityChecker

        all_projects = get_all_projects(include_archived=False)
        parked = [
            p for p in all_projects
            if p.get("feasibility", {}).get("status") in ("parked_partially", "parked_blocked")
        ]

        if not parked:
            print("[CapabilityWatcher] Keine geparkten Projekte gefunden.")
            return []

        print(f"[CapabilityWatcher] Pruefe {len(parked)} geparkte(s) Projekt(e)...")
        checker = FeasibilityChecker()
        changes = []

        for project in parked:
            slug = project.get("project_id", "")
            old_status = project.get("feasibility", {}).get("status", "unknown")
            old_score = project.get("feasibility", {}).get("score", 0.0)

            result = checker.check_project(slug)
            new_status_map = {
                "feasible": "feasible",
                "partially_feasible": "parked_partially",
                "not_feasible": "parked_blocked",
            }
            new_status = new_status_map.get(result.get("overall_status", ""), old_status)
            new_score = result.get("score", 0.0)

            if new_status != old_status or new_score > old_score + 0.1:
                print(f"  {slug}: {old_status} -> {new_status} (score: {old_score} -> {new_score})")

                # Update project registry
                try:
                    from factory.shared.project_registry import update_feasibility
                    update_feasibility(slug, result)
                except Exception as e:
                    print(f"  WARNING: Failed to update project registry: {e}")

                changes.append({
                    "slug": slug,
                    "old_status": old_status,
                    "new_status": new_status,
                    "old_score": old_score,
                    "new_score": new_score,
                })

                # Create gate if project became feasible
                if new_status == "feasible" and old_status != "feasible":
                    self._create_resolved_gate(slug, project, result)

            else:
                print(f"  {slug}: keine Aenderung ({old_status}, score={old_score})")

        return changes

    def _create_resolved_gate(self, slug: str, project: dict, result: dict):
        """Create a gate informing CEO that a parked project is now feasible."""
        title = project.get("title", slug)
        gate_id = f"feasibility_resolved_{slug}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

        gate = {
            "gate_id": gate_id,
            "project": slug,
            "gate_type": "feasibility_resolved",
            "category": "production",
            "title": f"Geparkt -> Machbar: {title}",
            "description": (
                f"Alle zuvor fehlenden Capabilities sind jetzt verfuegbar.\n"
                f"Feasibility Score: {result.get('score', 0)}\n"
                f"Produktion kann starten."
            ),
            "severity": "info",
            "status": "pending",
            "created_at": datetime.now().isoformat(),
            "options": [
                {
                    "id": "start_production",
                    "label": "Produktion starten",
                    "color": "green",
                },
                {
                    "id": "keep_parked",
                    "label": "Weiter geparkt lassen",
                    "color": "yellow",
                },
            ],
            "source_department": "factory/hq/capabilities",
            "source_agent": "capability_watcher",
            "context": {
                "score": result.get("score"),
                "overall_status": result.get("overall_status"),
                "report_path": result.get("report_path"),
            },
        }

        _GATES_DIR.mkdir(parents=True, exist_ok=True)
        gate_file = _GATES_DIR / f"{gate_id}.json"
        gate_file.write_text(
            json.dumps(gate, indent=2, ensure_ascii=False, default=str),
            encoding="utf-8",
        )
        print(f"[CapabilityWatcher] Gate erstellt: {gate_id}")
