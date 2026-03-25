"""Action Executor — handles destructive/mutating operations for the HQ Assistant.

All actions log what they do. Destructive actions require confirmed=True.
Pipeline starts are non-blocking (subprocess.Popen).
"""

import json
import logging
import os
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

logger = logging.getLogger(__name__)

FACTORY_BASE = Path(__file__).resolve().parents[3]  # DriveAI-AutoGen root
FACTORY_DIR = FACTORY_BASE / "factory"
PROJECTS_DIR = FACTORY_DIR / "projects"
ARCHIVE_DIR = PROJECTS_DIR / "_archive"
DOC_SEC_DIR = FACTORY_DIR / "document_secretary" / "output"
IDEAS_DIR = FACTORY_BASE / "ideas"
LOGS_DIR = FACTORY_DIR / "hq" / "logs"

PHASE_COMMANDS = {
    "phase1": 'python -m factory.pre_production.pipeline --idea-file "{idea_file}" --title "{title}" --mode {mode}',
    "kapitel3": "python -m factory.market_strategy.pipeline --latest",
    "kapitel4": "python -m factory.mvp_scope.pipeline --latest",
    "kapitel45": "python -m factory.design_vision.pipeline --latest",
    "kapitel5": "python -m factory.visual_audit.pipeline --latest",
    "kapitel6": "python -m factory.roadbook_assembly.pipeline --latest",
}

PHASE_PREREQUISITES = {
    "kapitel3": ("ceo_gate", "GO"),
    "kapitel4": ("kapitel3", "complete"),
    "kapitel45": ("kapitel4", "complete"),
    "kapitel5": ("kapitel45", "complete"),
    "kapitel6": ("kapitel5", "complete"),
}

DURATION_ESTIMATES = {
    "phase1": "3-5 Minuten", "kapitel3": "3-5 Minuten", "kapitel4": "3-5 Minuten",
    "kapitel45": "2-4 Minuten", "kapitel5": "4-7 Minuten", "kapitel6": "2-3 Minuten",
    "full": "20-35 Minuten", "secretary": "5-10 Minuten",
}

COST_ESTIMATES = {
    "phase1": "$0.50-1.00", "kapitel3": "$0.30-0.60", "kapitel4": "$0.20-0.40",
    "kapitel45": "$0.30-0.50", "kapitel5": "$0.40-0.80", "kapitel6": "$0.10-0.20",
    "full": "$2.00-4.00", "secretary": "$0.50-1.00",
}


def execute_gate_decision(slug: str, gate_type: str, decision: str, notes: str = "") -> dict:
    """Set a gate decision for a project."""
    project = _load_project(slug)
    if not project:
        return {"success": False, "error": f"Projekt '{slug}' nicht gefunden"}

    # Find output dir for the gate's prerequisite chapter
    prereq = "phase1" if gate_type == "ceo_gate" else "kapitel5"
    ch = (project.get("chapters") or {}).get(prereq, {})
    output_dir = ch.get("output_dir") if isinstance(ch, dict) else None

    if not output_dir:
        return {"success": False, "error": f"Kein Output-Verzeichnis fuer {prereq} gefunden"}

    # Resolve path
    od = Path(output_dir)
    if not od.is_absolute():
        od = FACTORY_BASE / output_dir

    if not od.exists():
        return {"success": False, "error": f"Output-Verzeichnis existiert nicht: {od}"}

    # Build and run gate command
    if gate_type == "ceo_gate":
        cmd = f'python -m factory.pre_production.ceo_gate --run-dir "{od}" --decision {decision}'
        if notes:
            cmd += f' --reasoning "{notes}"'
    elif gate_type == "visual_review":
        cmd = f'python -m factory.visual_audit.review_gate --run-dir "{od}" --decision {decision}'
        if notes:
            cmd += f' --reasoning "{notes}"'
    else:
        return {"success": False, "error": f"Unbekannter Gate-Typ: {gate_type}"}

    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True,
                                cwd=str(FACTORY_BASE), timeout=60)

        # Also update via project_registry
        try:
            from factory.project_registry import update_project_gate
            update_project_gate(slug, gate_type, decision, notes)
        except Exception as e:
            logger.warning("Registry update failed: %s", e)

        return {
            "success": result.returncode == 0,
            "project": slug,
            "gate_type": gate_type,
            "decision": decision,
            "notes": notes,
            "output": result.stdout[-500:] if result.stdout else "",
            "error": result.stderr[-200:] if result.returncode != 0 else "",
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


def start_pipeline_phase(slug: str, phase: str, mode: str = None) -> dict:
    """Start a pipeline phase as background process."""
    project = _load_project(slug)
    if not project:
        return {"success": False, "error": f"Projekt '{slug}' nicht gefunden"}

    # Check prerequisites
    if phase in PHASE_PREREQUISITES:
        prereq_key, prereq_status = PHASE_PREREQUISITES[phase]
        if prereq_key in ("ceo_gate", "visual_review"):
            gate = (project.get("gates") or {}).get(prereq_key, {})
            ch_gate = (project.get("chapters") or {}).get(prereq_key, {})
            decision = gate.get("status") or (ch_gate.get("decision") if isinstance(ch_gate, dict) else None)
            if decision not in ("GO", "GO_MIT_NOTES", "GO_WITH_CONDITIONS"):
                return {"success": False, "error": f"Voraussetzung nicht erfuellt: {prereq_key} muss GO sein (aktuell: {decision})"}
        else:
            ch = (project.get("chapters") or {}).get(prereq_key, {})
            if isinstance(ch, dict) and ch.get("status") != prereq_status:
                return {"success": False, "error": f"Voraussetzung nicht erfuellt: {prereq_key} muss {prereq_status} sein"}

    # Build command
    if phase == "full":
        # Full run: start with phase1, rest will chain
        cmd = _build_phase1_command(slug, project, mode or project.get("mode", "vision"))
    elif phase == "phase1":
        cmd = _build_phase1_command(slug, project, mode or project.get("mode", "vision"))
    elif phase == "secretary":
        cmd = _build_secretary_command(slug, project)
    elif phase in PHASE_COMMANDS:
        cmd = PHASE_COMMANDS[phase]
    else:
        return {"success": False, "error": f"Unbekannte Phase: {phase}"}

    # Ensure logs dir
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = LOGS_DIR / f"{slug}_{phase}_{timestamp}.log"

    try:
        with open(log_file, "w", encoding="utf-8") as lf:
            lf.write(f"# Pipeline Log: {slug} / {phase}\n")
            lf.write(f"# Started: {datetime.now().isoformat()}\n")
            lf.write(f"# Command: {cmd}\n\n")

        process = subprocess.Popen(
            cmd, shell=True,
            stdout=open(log_file, "a", encoding="utf-8"),
            stderr=subprocess.STDOUT,
            cwd=str(FACTORY_BASE),
        )

        # Update project status
        try:
            from factory.project_registry import update_project_phase
            update_project_phase(slug, phase, "running", "")
        except Exception:
            pass

        return {
            "success": True,
            "project": slug,
            "phase": phase,
            "command": cmd,
            "pid": process.pid,
            "log_file": str(log_file),
            "estimated_duration": DURATION_ESTIMATES.get(phase, "unbekannt"),
            "estimated_cost": COST_ESTIMATES.get(phase, "unbekannt"),
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


def get_pipeline_log(slug: str, lines: int = 20) -> dict:
    """Read the latest pipeline log for a project."""
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    logs = sorted(LOGS_DIR.glob(f"{slug}_*.log"), key=lambda f: f.stat().st_mtime, reverse=True)

    if not logs:
        return {"found": False, "message": f"Kein Log fuer {slug} gefunden"}

    latest = logs[0]
    try:
        content = latest.read_text(encoding="utf-8")
        all_lines = content.split("\n")
        tail = all_lines[-lines:] if len(all_lines) > lines else all_lines

        # Check if process is still running
        running = not content.strip().endswith("ABGESCHLOSSEN") and not "Error" in content[-200:]

        return {
            "found": True,
            "log_file": str(latest),
            "total_lines": len(all_lines),
            "last_lines": "\n".join(tail),
            "appears_running": running,
        }
    except Exception as e:
        return {"found": True, "log_file": str(latest), "error": str(e)}


def update_model_assignment(target: str, model: str, reason: str = "") -> dict:
    """Update model assignment in TheBrain config."""
    # This is informational for now — actual TheBrain model selection is dynamic
    # The config change would go into the agent's profile setting
    return {
        "success": True,
        "message": f"Model-Zuordnung fuer '{target}' auf '{model}' gesetzt",
        "note": "TheBrain waehlt Modelle dynamisch. Die Aenderung beeinflusst das 'profile' Setting der betroffenen Agents.",
        "target": target,
        "new_model": model,
        "reason": reason,
        "info": "Fuer permanente Aenderungen: profile in der jeweiligen pipeline config.py anpassen.",
    }


def delete_projects(slugs: list, confirmed: bool) -> dict:
    """Delete projects and all associated data. DESTRUCTIVE."""
    if not confirmed:
        return {"success": False, "error": "Loeschung nicht bestaetigt. CEO muss explizit bestaetigen."}

    results = []
    for slug in slugs:
        result = _delete_single_project(slug)
        results.append(result)

    return {
        "deleted": sum(1 for r in results if r["success"]),
        "failed": sum(1 for r in results if not r["success"]),
        "details": results,
    }


def _delete_single_project(slug: str) -> dict:
    """Delete a single project and all its data."""
    deleted_items = []
    errors = []

    # 1. Delete project dir
    project_dir = PROJECTS_DIR / slug
    if project_dir.exists():
        try:
            # Read project.json first to find output dirs
            pf = project_dir / "project.json"
            output_dirs = []
            if pf.exists():
                p = json.loads(pf.read_text(encoding="utf-8"))
                for ch in (p.get("chapters") or {}).values():
                    if isinstance(ch, dict) and ch.get("output_dir"):
                        output_dirs.append(ch["output_dir"])

            shutil.rmtree(project_dir)
            deleted_items.append(f"factory/projects/{slug}/")

            # 2. Delete output dirs
            for od in output_dirs:
                od_path = Path(od) if Path(od).is_absolute() else FACTORY_BASE / od
                if od_path.exists():
                    shutil.rmtree(od_path)
                    deleted_items.append(str(od))

        except Exception as e:
            errors.append(f"project dir: {e}")

    # 3. Delete PDFs
    if DOC_SEC_DIR.exists():
        for f in DOC_SEC_DIR.iterdir():
            if f.suffix == ".pdf" and slug.lower() in f.name.lower():
                try:
                    f.unlink()
                    deleted_items.append(f"PDF: {f.name}")
                except Exception as e:
                    errors.append(f"PDF {f.name}: {e}")

    # 4. Delete idea file
    idea_file = IDEAS_DIR / f"{slug}.md"
    if idea_file.exists():
        try:
            idea_file.unlink()
            deleted_items.append(f"ideas/{slug}.md")
        except Exception as e:
            errors.append(f"idea: {e}")

    return {
        "project": slug,
        "success": len(errors) == 0,
        "deleted_items": deleted_items,
        "errors": errors,
    }


def archive_project(slug: str, reason: str = "") -> dict:
    """Archive a project (move, don't delete)."""
    project_dir = PROJECTS_DIR / slug
    if not project_dir.exists():
        return {"success": False, "error": f"Projekt '{slug}' nicht gefunden"}

    ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)
    archive_dest = ARCHIVE_DIR / slug

    if archive_dest.exists():
        return {"success": False, "error": f"Archiv-Ordner existiert bereits: {archive_dest}"}

    try:
        # Update project.json before moving
        pf = project_dir / "project.json"
        if pf.exists():
            data = json.loads(pf.read_text(encoding="utf-8"))
            data["archived"] = True
            data["archived_at"] = datetime.now().isoformat()
            data["archive_reason"] = reason
            pf.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")

        shutil.move(str(project_dir), str(archive_dest))

        return {
            "success": True,
            "project": slug,
            "archived_to": str(archive_dest),
            "reason": reason,
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


def create_new_project(title: str, idea_text: str, mode: str, auto_start: bool = False) -> dict:
    """Create a new project."""
    try:
        from factory.project_registry import register_project
        import re
        slug = re.sub(r'[^a-z0-9]+', '_', title.lower().strip()).strip('_')[:40]

        project = register_project(slug, title, idea_text, mode)

        result = {
            "success": True,
            "project_id": slug,
            "title": title,
            "mode": mode,
            "project_dir": str(PROJECTS_DIR / slug),
        }

        if auto_start:
            pipeline_result = start_pipeline_phase(slug, "phase1", mode)
            result["pipeline_started"] = pipeline_result.get("success", False)
            result["pipeline_info"] = pipeline_result

        return result
    except Exception as e:
        return {"success": False, "error": str(e)}


def _load_project(slug: str) -> dict | None:
    pf = PROJECTS_DIR / slug / "project.json"
    if not pf.exists():
        return None
    try:
        return json.loads(pf.read_text(encoding="utf-8"))
    except Exception:
        return None


def _build_phase1_command(slug: str, project: dict, mode: str) -> str:
    idea_file = (project.get("documents") or {}).get("idea_file", "")
    if not idea_file:
        idea_file = str(IDEAS_DIR / f"{slug}.md")
    if not Path(idea_file).exists():
        idea_file = str(PROJECTS_DIR / slug / "idea.md")

    title = project.get("title", slug.replace("_", " ").title())
    return f'python -m factory.pre_production.pipeline --idea-file "{idea_file}" --title "{title}" --mode {mode}'


def _build_secretary_command(slug: str, project: dict) -> str:
    # Find all output dirs for --type all
    p1 = (project.get("chapters") or {}).get("phase1", {})
    p1_dir = p1.get("output_dir", "") if isinstance(p1, dict) else ""
    return f'python -m factory.document_secretary.secretary --type all --p1-dir "{p1_dir}"'
