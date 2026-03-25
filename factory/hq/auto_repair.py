"""Factory Auto-Repair — fixes auto-fixable problems found by Health Monitor.

100% deterministic. No LLM calls. Only safe, reversible file operations.
"""

import json
import logging
from datetime import datetime
from pathlib import Path

logger = logging.getLogger(__name__)

FACTORY_BASE = Path(__file__).parent.parent.parent
PROJECTS_DIR = FACTORY_BASE / "factory" / "projects"
DOC_SEC_DIR = FACTORY_BASE / "factory" / "document_secretary" / "output"


def run_auto_repair(alerts: list = None) -> dict:
    """Fix all auto-fixable problems."""
    if alerts is None:
        from factory.hq.health_monitor import run_health_check
        health = run_health_check()
        alerts = health["alerts"]

    fixable = [a for a in alerts if a.get("auto_fixable")]
    repairs = []

    for alert in fixable:
        try:
            result = _dispatch_repair(alert)
            repairs.append(result)
        except Exception as e:
            repairs.append({
                "category": alert["category"],
                "project": alert.get("project", "unknown"),
                "action": f"Repair failed: {e}",
                "success": False,
            })

    return {
        "timestamp": datetime.now().isoformat(),
        "repairs_attempted": len(repairs),
        "repairs_successful": sum(1 for r in repairs if r["success"]),
        "repairs_failed": sum(1 for r in repairs if not r["success"]),
        "repairs": repairs,
    }


def _dispatch_repair(alert: dict) -> dict:
    cat = alert["category"]
    slug = alert.get("project", "unknown")

    if cat == "orphaned_run":
        return _repair_orphaned_run(alert)
    elif cat == "broken_project":
        return _repair_broken_project(alert)
    elif cat == "inconsistent_status":
        return _repair_inconsistent_status(alert)
    elif cat == "missing_field":
        return _repair_missing_field(alert)
    else:
        return {"category": cat, "project": slug, "action": "No repair handler", "success": False}


def _repair_orphaned_run(alert: dict) -> dict:
    """Register an orphaned output directory as a project."""
    details = alert.get("details", {})
    run_path = Path(details.get("path", ""))
    phase = details.get("phase", "phase1")
    slug = alert.get("project", "unknown")

    try:
        from factory.project_registry import register_project, update_project_phase

        # Try to read idea from the output dir
        idea_text = ""
        for f in ["concept_brief.md", "pipeline_summary.md"]:
            fp = run_path / f
            if fp.exists():
                idea_text = fp.read_text(encoding="utf-8")[:500]
                break

        title = slug.replace("_", " ").replace("-", " ").title()
        register_project(slug, title, idea_text or f"Orphaned run from {phase}", "vision")

        # Mark the phase as complete if pipeline_summary exists
        if (run_path / "pipeline_summary.md").exists():
            update_project_phase(slug, phase, "complete", str(run_path))

        return {
            "category": "orphaned_run",
            "project": slug,
            "action": f"project.json erstellt, {phase} als complete markiert",
            "success": True,
        }
    except Exception as e:
        return {"category": "orphaned_run", "project": slug, "action": str(e), "success": False}


def _repair_broken_project(alert: dict) -> dict:
    """Fix missing fields in broken project.json."""
    slug = alert.get("project", "unknown")
    field = alert.get("details", {}).get("missing_field", "")

    pf = PROJECTS_DIR / slug / "project.json"
    if not pf.exists():
        return {"category": "broken_project", "project": slug, "action": "File not found", "success": False}

    try:
        data = json.loads(pf.read_text(encoding="utf-8"))
    except Exception:
        return {"category": "broken_project", "project": slug, "action": "JSON not parseable", "success": False}

    if field == "project_id" and "project_id" not in data:
        data["project_id"] = slug
    if field == "status" and "status" not in data:
        data["status"] = "idea_created"

    pf.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    return {"category": "broken_project", "project": slug, "action": f"Feld '{field}' ergaenzt", "success": True}


def _repair_inconsistent_status(alert: dict) -> dict:
    """Recalculate project status from chapter states."""
    slug = alert.get("project", "unknown")
    expected = alert.get("details", {}).get("expected", "")

    pf = PROJECTS_DIR / slug / "project.json"
    if not pf.exists():
        return {"category": "inconsistent_status", "project": slug, "action": "File not found", "success": False}

    try:
        data = json.loads(pf.read_text(encoding="utf-8"))
        old_status = data.get("status")
        if expected:
            data["status"] = expected
        # Also derive current_phase
        from factory.project_registry import _derive_status
        new_status, new_phase = _derive_status(data)
        data["status"] = new_status
        data["current_phase"] = new_phase
        data["updated_at"] = datetime.now().isoformat()

        pf.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        return {
            "category": "inconsistent_status",
            "project": slug,
            "action": f"Status korrigiert: '{old_status}' -> '{new_status}'",
            "success": True,
        }
    except Exception as e:
        return {"category": "inconsistent_status", "project": slug, "action": str(e), "success": False}


def _repair_missing_field(alert: dict) -> dict:
    """Add missing field with sensible default."""
    slug = alert.get("project", "unknown")
    field = alert.get("details", {}).get("field", "")

    pf = PROJECTS_DIR / slug / "project.json"
    if not pf.exists():
        return {"category": "missing_field", "project": slug, "action": "File not found", "success": False}

    try:
        data = json.loads(pf.read_text(encoding="utf-8"))

        if field == "mode" and "mode" not in data:
            data["mode"] = "vision"
        elif field == "created_at" and "created_at" not in data:
            data["created_at"] = data.get("updated", datetime.now().strftime("%Y-%m-%d")) + "T00:00:00"
        elif field == "documents" and "documents" not in data:
            docs = {"idea_file": "", "reports": [], "pdfs": [], "roadbooks": []}
            # Scan for PDFs
            if DOC_SEC_DIR.exists():
                for f in DOC_SEC_DIR.iterdir():
                    if f.suffix == ".pdf" and slug in f.name.lower():
                        docs["pdfs"].append(str(f))
            data["documents"] = docs
        else:
            return {"category": "missing_field", "project": slug, "action": f"Unknown field: {field}", "success": False}

        data["updated_at"] = datetime.now().isoformat()
        pf.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        return {"category": "missing_field", "project": slug, "action": f"Feld '{field}' ergaenzt", "success": True}
    except Exception as e:
        return {"category": "missing_field", "project": slug, "action": str(e), "success": False}


if __name__ == "__main__":
    result = run_auto_repair()
    print(f"Auto-Repair: {result['repairs_successful']}/{result['repairs_attempted']} erfolgreich")
    for r in result["repairs"]:
        icon = "✅" if r["success"] else "❌"
        print(f"  {icon} {r['project']}: {r['action']}")
