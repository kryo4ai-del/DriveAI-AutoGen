"""Central Project Registry — single source of truth for all project lifecycle data.

Every pipeline phase calls this module to register, update, and query projects.
The Dashboard reads the resulting project.json files.

No LLM calls, no TheBrain — pure deterministic file I/O + JSON.
"""

import json
import logging
import os
import re
import shutil
from datetime import datetime
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECTS_DIR = Path(__file__).parent / "projects"
IDEAS_DIR = Path(__file__).parent.parent / "ideas"


def _slugify(text: str) -> str:
    """Convert text to a valid slug: lowercase, underscores, no special chars."""
    slug = text.lower().strip()
    slug = re.sub(r'[^a-z0-9]+', '_', slug)
    slug = slug.strip('_')
    return slug[:40]


def _now_iso() -> str:
    return datetime.now().strftime("%Y-%m-%dT%H:%M:%S")


def _read_project(slug: str) -> dict | None:
    pf = PROJECTS_DIR / slug / "project.json"
    if not pf.exists():
        return None
    try:
        return json.loads(pf.read_text(encoding="utf-8"))
    except Exception as e:
        logger.error("Failed to read project.json for %s: %s", slug, e)
        return None


def _write_project(slug: str, data: dict):
    pf = PROJECTS_DIR / slug / "project.json"
    pf.parent.mkdir(parents=True, exist_ok=True)
    pf.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")


def _derive_status(project: dict) -> tuple[str, str]:
    """Derive overall status and current_phase from chapters."""
    ch = project.get("chapters", {})

    if ch.get("kapitel6", {}).get("status") == "complete":
        return "preproduction_done", "Pre-Production abgeschlossen — bereit fuer Production"
    if ch.get("visual_review", {}).get("decision") == "GO":
        return "review_go", "Pre-Production: Review bestanden"
    if ch.get("kapitel5", {}).get("status") == "complete":
        vr = ch.get("visual_review", {})
        if vr.get("status") == "complete" and vr.get("decision") == "GO":
            return "review_go", "Pre-Production: Review bestanden"
        return "review_pending", "Pre-Production: Human Review wartet"
    if ch.get("kapitel45", {}).get("status") == "complete":
        return "design_complete", "Pre-Production: Design Vision fertig"
    if ch.get("kapitel4", {}).get("status") == "complete":
        return "features_complete", "Pre-Production: Features + Screens fertig"
    if ch.get("kapitel3", {}).get("status") == "complete":
        return "strategy_complete", "Pre-Production: Strategie fertig"

    ceo = ch.get("ceo_gate", {})
    if ceo.get("decision") == "KILL":
        return "killed", "Projekt beendet (KILL)"
    if ceo.get("decision") == "GO" or ceo.get("decision") == "GO_MIT_NOTES":
        return "ceo_gate_go", "Pre-Production: CEO GO — bereit fuer Kapitel 3"

    if ch.get("phase1", {}).get("status") == "complete":
        return "ceo_gate_pending", "Pre-Production: CEO-Gate wartet"
    if ch.get("phase1", {}).get("status") == "running":
        return "phase1_running", "Pre-Production: Phase 1 laeuft"

    return "idea_created", "Idee angelegt"


# ── Public API ──────────────────────────────────────────────


def register_project(slug: str, title: str, idea_text: str, mode: str = "vision") -> dict:
    """Register a new project or update an existing one.

    Creates: factory/projects/{slug}/ with project.json + idea.md + subdirs.
    If project already exists: updates idea.md only, does NOT overwrite project.json.
    Also writes ideas/{slug}.md for backward compatibility.
    """
    slug = _slugify(slug) if slug != _slugify(slug) else slug
    project_dir = PROJECTS_DIR / slug
    project_dir.mkdir(parents=True, exist_ok=True)

    # Write idea.md in project dir
    idea_path = project_dir / "idea.md"
    idea_content = f"# {title}\n\n{idea_text}" if not idea_text.startswith("#") else idea_text
    idea_path.write_text(idea_content, encoding="utf-8")

    # Backward compat: also write to ideas/
    IDEAS_DIR.mkdir(parents=True, exist_ok=True)
    ideas_path = IDEAS_DIR / f"{slug}.md"
    ideas_path.write_text(idea_content, encoding="utf-8")

    # Create subdirs
    for sub in ["reports", "pdfs", "roadbooks"]:
        (project_dir / sub).mkdir(exist_ok=True)

    # If project.json already exists, don't overwrite — just add missing fields
    existing = _read_project(slug)
    if existing:
        changed = False
        if "mode" not in existing:
            existing["mode"] = mode
            changed = True
        if "created_at" not in existing:
            existing["created_at"] = _now_iso()
            changed = True
        if "documents" not in existing:
            existing["documents"] = {"idea_file": str(idea_path), "reports": [], "pdfs": [], "roadbooks": []}
            changed = True
        existing["updated_at"] = _now_iso()
        if changed:
            _write_project(slug, existing)
        logger.info("[ProjectRegistry] Updated existing project: %s", slug)
        return existing

    # New project
    project = {
        "project_id": slug,
        "title": title,
        "mode": mode,
        "status": "idea_created",
        "current_phase": "Idee angelegt",
        "project_type": "production",
        "archived": False,
        "created_at": _now_iso(),
        "updated_at": _now_iso(),
        "chapters": {
            "phase1":       {"status": "pending", "output_dir": None, "date": None, "agents": [], "costs": {}},
            "ceo_gate":     {"status": "pending", "decision": None, "date": None, "notes": ""},
            "kapitel3":     {"status": "pending", "output_dir": None, "date": None, "agents": [], "costs": {}},
            "kapitel4":     {"status": "pending", "output_dir": None, "date": None, "agents": [], "costs": {}},
            "kapitel45":    {"status": "pending", "output_dir": None, "date": None, "agents": [], "costs": {}},
            "kapitel5":     {"status": "pending", "output_dir": None, "date": None, "agents": [], "costs": {}},
            "visual_review":{"status": "pending", "decision": None, "date": None, "notes": ""},
            "kapitel6":     {"status": "pending", "output_dir": None, "date": None, "agents": [], "costs": {}},
        },
        "gates": {
            "ceo_gate": {"status": "pending", "date": None, "notes": None},
            "visual_review": {"status": "pending", "date": None, "notes": None},
        },
        "costs": {
            "serpapi_credits_total": 0,
            "llm_cost_usd_total": 0.0,
        },
        "documents": {
            "idea_file": str(idea_path),
            "reports": [],
            "pdfs": [],
            "roadbooks": [],
        },
    }

    _write_project(slug, project)
    logger.info("[ProjectRegistry] Registered new project: %s (%s mode)", slug, mode)
    print(f"[ProjectRegistry] Registered: {slug} ({title}, {mode} mode)")
    return project


def update_project_phase(slug: str, phase: str, status: str, output_dir: str,
                          agents: list = None, costs: dict = None) -> dict:
    """Update a chapter/phase status after a pipeline run.

    phase: "phase1", "kapitel3", "kapitel4", "kapitel45", "kapitel5", "kapitel6"
    status: "running", "complete", "partial", "error"
    """
    project = _read_project(slug)
    if not project:
        logger.warning("[ProjectRegistry] Project %s not found, creating stub", slug)
        project = register_project(slug, slug.replace("_", " ").title(), "", "vision")

    if "chapters" not in project:
        project["chapters"] = {}

    chapter = project["chapters"].get(phase, {})
    chapter["status"] = status
    chapter["output_dir"] = output_dir
    chapter["date"] = datetime.now().strftime("%Y-%m-%d")
    if agents:
        chapter["agents"] = agents
    if costs:
        chapter["costs"] = costs
        # Accumulate total costs
        if "serpapi" in costs:
            project.setdefault("costs", {})["serpapi_credits_total"] = (
                project.get("costs", {}).get("serpapi_credits_total", 0) + costs.get("serpapi", 0)
            )
        if "llm_usd" in costs:
            project.setdefault("costs", {})["llm_cost_usd_total"] = round(
                project.get("costs", {}).get("llm_cost_usd_total", 0.0) + costs.get("llm_usd", 0.0), 4
            )

    project["chapters"][phase] = chapter
    project["updated_at"] = _now_iso()

    # Derive overall status
    project["status"], project["current_phase"] = _derive_status(project)

    _write_project(slug, project)
    print(f"[ProjectRegistry] {slug}: {phase} → {status}")
    return project


def update_project_gate(slug: str, gate_type: str, decision: str, notes: str = "") -> dict:
    """Update a gate decision (ceo_gate or visual_review)."""
    project = _read_project(slug)
    if not project:
        logger.warning("[ProjectRegistry] Project %s not found for gate update", slug)
        return {}

    # Update in chapters
    if "chapters" not in project:
        project["chapters"] = {}
    project["chapters"].setdefault(gate_type, {})
    project["chapters"][gate_type]["status"] = "complete"
    project["chapters"][gate_type]["decision"] = decision
    project["chapters"][gate_type]["date"] = datetime.now().strftime("%Y-%m-%d")
    project["chapters"][gate_type]["notes"] = notes

    # Also update in gates (legacy compat)
    project.setdefault("gates", {})
    project["gates"][gate_type] = {
        "status": decision,
        "date": datetime.now().strftime("%Y-%m-%d"),
        "notes": notes,
    }

    project["updated_at"] = _now_iso()
    project["status"], project["current_phase"] = _derive_status(project)

    _write_project(slug, project)
    print(f"[ProjectRegistry] {slug}: {gate_type} → {decision}")
    return project


def add_document(slug: str, doc_type: str, path: str):
    """Add a document path to the project. doc_type: 'reports', 'pdfs', 'roadbooks'."""
    project = _read_project(slug)
    if not project:
        return
    project.setdefault("documents", {"idea_file": "", "reports": [], "pdfs": [], "roadbooks": []})
    doc_list = project["documents"].setdefault(doc_type, [])
    if path not in doc_list:
        doc_list.append(path)
    project["updated_at"] = _now_iso()
    _write_project(slug, project)


def get_project(slug: str) -> dict | None:
    """Read and return the project.json for a slug."""
    return _read_project(slug)


def list_projects() -> list[dict]:
    """List all projects from factory/projects/."""
    if not PROJECTS_DIR.exists():
        return []
    projects = []
    for d in sorted(PROJECTS_DIR.iterdir()):
        if d.is_dir():
            p = _read_project(d.name)
            if p:
                projects.append(p)
    return projects
