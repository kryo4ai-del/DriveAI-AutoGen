"""Project Registry — generates and maintains project.json files.

Creates factory/projects/{slug}/project.json with complete project status.
Called by each pipeline at the end of its run.
"""

import json
import re
from pathlib import Path
from datetime import datetime

PROJECTS_DIR = Path("factory/projects")


def update_project(slug: str, chapter: str, data: dict) -> dict:
    """Update or create project.json for a project."""
    project_dir = PROJECTS_DIR / slug
    project_dir.mkdir(parents=True, exist_ok=True)
    project_file = project_dir / "project.json"

    if project_file.exists():
        project = json.loads(project_file.read_text(encoding="utf-8"))
    else:
        project = _create_new_project(slug)

    project["chapters"][chapter] = {
        "status": data.get("status", "complete"),
        "run_number": str(data.get("run_number", "001")),
        "output_dir": data.get("output_dir", ""),
        "agents_ok": data.get("agents_ok", 0),
        "agents_total": data.get("agents_total", 0),
        "serpapi_credits": data.get("serpapi_credits", 0),
        "llm_cost_usd": data.get("llm_cost_usd", 0.0),
        "date": datetime.now().strftime("%Y-%m-%d"),
    }

    project["updated"] = datetime.now().strftime("%Y-%m-%d")
    project["status"] = _derive_status(project)
    project["current_phase"] = _derive_current_phase(project)

    project["costs"]["serpapi_credits_total"] = sum(
        ch.get("serpapi_credits", 0) for ch in project["chapters"].values() if isinstance(ch, dict)
    )
    project["costs"]["llm_cost_usd_total"] = round(sum(
        ch.get("llm_cost_usd", 0.0) for ch in project["chapters"].values() if isinstance(ch, dict)
    ), 4)

    if "extra" in data:
        project["key_metrics"].update(data["extra"])

    project_file.write_text(
        json.dumps(project, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )
    print(f"[ProjectRegistry] Updated {project_file}: status={project['status']}")
    return project


def _create_new_project(slug: str, project_type: str = "production",
                        archived: bool = False, parent_project: str = None) -> dict:
    project = {
        "project_id": slug,
        "title": slug.replace("_", " ").replace("-", " ").title(),
        "project_type": project_type,
        "archived": archived,
        "created": datetime.now().strftime("%Y-%m-%d"),
        "updated": datetime.now().strftime("%Y-%m-%d"),
        "status": "idea",
        "current_phase": "Idee wartet",
        "runs": {
            "pre_production": [],
            "active_run": None,
        },
        "gates": {
            "ceo_gate": {"status": "pending", "date": None, "notes": None},
            "visual_review": {"status": "pending", "date": None, "notes": None},
        },
        "chapters": {
            "phase1": {"status": "not_started"},
            "kapitel3": {"status": "not_started"},
            "kapitel4": {"status": "not_started"},
            "kapitel45": {"status": "not_started"},
            "kapitel5": {"status": "not_started"},
            "kapitel6": {"status": "not_started"},
        },
        "production": {
            "ios": {"status": "not_started"},
            "android": {"status": "not_started"},
            "web": {"status": "not_started"},
            "assembly": {"status": "not_started"},
        },
        "feasibility": {
            "status": "not_checked",
            "check_date": None,
            "score": None,
            "gaps": [],
            "report": None,
        },
        "documents": {},
        "costs": {
            "serpapi_credits_total": 0,
            "llm_cost_usd_total": 0.0,
            "pdf_generation_calls": 0,
        },
        "key_metrics": {},
    }
    if parent_project:
        project["parent_project"] = parent_project
    return project


def _derive_status(project: dict) -> str:
    chapters = project["chapters"]
    gates = project["gates"]
    production = project.get("production", {})

    # Feasibility-based parking (after roadbook, before production)
    feasibility = project.get("feasibility", {})
    if feasibility.get("status") == "parked_blocked":
        return "parked_blocked"
    if feasibility.get("status") == "parked_partially":
        return "parked_partially"

    if chapters.get("kapitel6", {}).get("status") == "complete":
        if feasibility.get("status") == "feasible":
            return "feasible"
        if any(p.get("status") not in ("not_started", None) for p in production.values()):
            return "in_production"
        return "preproduction_done"
    if chapters.get("kapitel5", {}).get("status") == "complete":
        if gates.get("visual_review", {}).get("status") == "GO":
            return "review_go"
        return "review_pending"
    if chapters.get("kapitel45", {}).get("status") == "complete":
        return "design_complete"
    if chapters.get("kapitel4", {}).get("status") == "complete":
        return "features_complete"
    if chapters.get("kapitel3", {}).get("status") == "complete":
        return "strategy_complete"
    if gates.get("ceo_gate", {}).get("status") == "GO":
        return "ceo_gate_go"
    if gates.get("ceo_gate", {}).get("status") == "KILL":
        return "killed"
    if chapters.get("phase1", {}).get("status") == "complete":
        return "ceo_gate_pending"
    if chapters.get("phase1", {}).get("status") not in ("not_started", None):
        return "phase1_running"
    return "idea"


def _derive_current_phase(project: dict) -> str:
    status = project["status"]
    mapping = {
        "idea": "Idee wartet",
        "phase1_running": "Pre-Production: Phase 1 laeuft",
        "ceo_gate_pending": "Pre-Production: CEO-Gate wartet",
        "ceo_gate_go": "Pre-Production: Bereit fuer Kapitel 3",
        "killed": "Projekt beendet (KILL)",
        "strategy_complete": "Pre-Production: Kapitel 3 fertig",
        "features_complete": "Pre-Production: Kapitel 4 fertig",
        "design_complete": "Pre-Production: Kapitel 4.5 fertig",
        "review_pending": "Pre-Production: Human Review wartet",
        "review_go": "Pre-Production: Review bestanden",
        "preproduction_done": "Pre-Production abgeschlossen -- bereit fuer Production",
        "feasibility_checking": "Feasibility-Check laeuft",
        "feasible": "Feasibility: Produktionsbereit",
        "parked_partially": "Geparkt: Teilweise machbar",
        "parked_blocked": "Geparkt: Blockiert",
        "in_production": "Production laeuft",
    }
    return mapping.get(status, status)


def update_gate(slug: str, gate_name: str, decision: str, notes: str = None):
    """Update a gate decision in project.json."""
    project_dir = PROJECTS_DIR / slug
    project_file = project_dir / "project.json"

    if not project_file.exists():
        project = _create_new_project(slug)
    else:
        project = json.loads(project_file.read_text(encoding="utf-8"))

    project["gates"][gate_name] = {
        "status": decision,
        "date": datetime.now().strftime("%Y-%m-%d"),
        "notes": notes,
    }
    project["updated"] = datetime.now().strftime("%Y-%m-%d")
    project["status"] = _derive_status(project)
    project["current_phase"] = _derive_current_phase(project)

    project_dir.mkdir(parents=True, exist_ok=True)
    project_file.write_text(
        json.dumps(project, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )
    print(f"[ProjectRegistry] Gate {gate_name}={decision} for {slug}")


def update_feasibility(slug: str, result: dict):
    """Update feasibility data in project.json."""
    project_file = PROJECTS_DIR / slug / "project.json"
    if not project_file.exists():
        return
    project = json.loads(project_file.read_text(encoding="utf-8"))

    overall = result.get("overall_status", "not_checked")
    status_map = {
        "feasible": "feasible",
        "partially_feasible": "parked_partially",
        "not_feasible": "parked_blocked",
    }
    project["feasibility"] = {
        "status": status_map.get(overall, "not_checked"),
        "check_date": result.get("check_date"),
        "score": result.get("score"),
        "gaps": [g.get("capability", "") for g in result.get("capability_gaps", [])],
        "report": result.get("report_path"),
    }
    project["updated"] = datetime.now().strftime("%Y-%m-%d")
    project["status"] = _derive_status(project)
    project["current_phase"] = _derive_current_phase(project)

    project_file.write_text(
        json.dumps(project, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    print(f"[ProjectRegistry] Feasibility {slug}: {overall} (score={result.get('score')})")


def archive_project(slug: str, archived: bool = True):
    """Archive or unarchive a project."""
    project_file = PROJECTS_DIR / slug / "project.json"
    if not project_file.exists():
        return
    project = json.loads(project_file.read_text(encoding="utf-8"))
    project["archived"] = archived
    project["updated"] = datetime.now().strftime("%Y-%m-%d")
    project_file.write_text(json.dumps(project, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"[ProjectRegistry] {slug} archived={archived}")


def set_project_type(slug: str, project_type: str):
    """Set project type (production/test/iteration)."""
    project_file = PROJECTS_DIR / slug / "project.json"
    if not project_file.exists():
        return
    project = json.loads(project_file.read_text(encoding="utf-8"))
    project["project_type"] = project_type
    project["updated"] = datetime.now().strftime("%Y-%m-%d")
    project_file.write_text(json.dumps(project, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"[ProjectRegistry] {slug} type={project_type}")


def get_all_projects(project_type: str = None, include_archived: bool = False) -> list[dict]:
    """Get project.json files with optional filtering."""
    projects = []
    if PROJECTS_DIR.exists():
        for project_dir in sorted(PROJECTS_DIR.iterdir()):
            pf = project_dir / "project.json"
            if pf.exists():
                p = json.loads(pf.read_text(encoding="utf-8"))
                if not include_archived and p.get("archived", False):
                    continue
                if project_type and p.get("project_type", "production") != project_type:
                    continue
                projects.append(p)
    return projects


def _detect_type(slug: str) -> str:
    """Detect if a project is a test or production project."""
    if "test" in slug.lower():
        return "test"
    # Only mark as test if KILLED and has no chapters beyond phase1
    pp_output = Path("factory/pre_production/output")
    for d in pp_output.iterdir() if pp_output.exists() else []:
        if d.is_dir() and slug in d.name:
            gate = d / "ceo_gate_decision.md"
            if gate.exists():
                content = gate.read_text(encoding="utf-8")
                # Look for the decision line: **Entscheidung:** GO or KILL
                for line in content.split("\n"):
                    if line.strip().startswith("**Entscheidung:**"):
                        decision_value = line.split(":**", 1)[1].strip() if ":**" in line else ""
                        if "KILL" in decision_value.upper():
                            return "test"
                        if "GO" in decision_value.upper():
                            return "production"
    return "production"


def _get_base_name(slug: str) -> str:
    """Strip trailing digits: breathflow3 -> breathflow, echomatch -> echomatch."""
    base = re.sub(r'\d+$', '', slug).rstrip('_').rstrip('-')
    return base if base else slug


def _find_runs_for_slug(slug: str, output_dir: Path) -> list[dict]:
    """Find all run directories for a given slug in an output directory."""
    runs = []
    if not output_dir.exists():
        return runs
    for d in sorted(output_dir.iterdir()):
        if d.is_dir() and slug in d.name:
            run_num = d.name.split("_")[0] if "_" in d.name else "001"
            has_summary = (d / "pipeline_summary.md").exists()
            has_content = has_summary or any(d.glob("*.md"))
            runs.append({"number": run_num, "dir": str(d), "complete": has_content})
    return runs


def _find_active_run(slug: str, output_dir: Path) -> dict | None:
    """Find the latest successful run for a slug."""
    runs = _find_runs_for_slug(slug, output_dir)
    if not runs:
        return None
    complete = [r for r in runs if r["complete"]]
    return complete[-1] if complete else runs[-1]


def bootstrap_existing_projects():
    """Scan existing factory output dirs and create project.json with dedup + type detection."""
    pp_output = Path("factory/pre_production/output")
    if not pp_output.exists():
        print("[ProjectRegistry] No pre_production output found")
        return

    # Step 1: Collect all slugs from pre_production
    all_slugs = []
    for run_dir in sorted(pp_output.iterdir()):
        if run_dir.is_dir() and "_" in run_dir.name:
            slug = run_dir.name.split("_", 1)[1]
            if slug not in all_slugs:
                all_slugs.append(slug)

    # Step 2: Group by base name for dedup
    groups = {}
    for slug in all_slugs:
        base = _get_base_name(slug)
        if base not in groups:
            groups[base] = []
        groups[base].append(slug)

    print(f"[ProjectRegistry] Found {len(all_slugs)} slugs in {len(groups)} groups")

    # Step 3: Delete old project.json to rebuild cleanly
    if PROJECTS_DIR.exists():
        for d in PROJECTS_DIR.iterdir():
            pf = d / "project.json"
            if pf.exists():
                pf.unlink()
            if d.is_dir() and not any(d.iterdir()):
                d.rmdir()

    # Step 4: Create project.json per group
    for base_name, slugs in groups.items():
        if len(slugs) == 1:
            # Single project
            slug = slugs[0]
            ptype = _detect_type(slug)
            _bootstrap_single_project(slug, project_type=ptype)
        else:
            # Multiple iterations — main = base name or first without number
            main_slug = base_name if base_name in slugs else slugs[0]
            _bootstrap_single_project(main_slug, project_type="production")

            for slug in slugs:
                if slug != main_slug:
                    _bootstrap_single_project(
                        slug,
                        project_type="iteration",
                        parent_project=main_slug,
                        archived=True,
                    )


def _bootstrap_single_project(slug: str, project_type: str = "production",
                               parent_project: str = None, archived: bool = False):
    """Bootstrap a single project from filesystem."""
    pp_output = Path("factory/pre_production/output")

    project = _create_new_project(slug, project_type=project_type,
                                   archived=archived, parent_project=parent_project)

    # Find all runs for this slug in pre_production
    pp_runs = _find_runs_for_slug(slug, pp_output)
    if pp_runs:
        project["runs"]["pre_production"] = [r["number"] for r in pp_runs]
        active = pp_runs[-1]  # Latest
        project["runs"]["active_run"] = active["number"]
        project["chapters"]["phase1"] = {
            "status": "complete",
            "run_number": active["number"],
            "output_dir": active["dir"],
            "date": datetime.now().strftime("%Y-%m-%d"),
        }

    # CEO gate — check the active run dir
    if pp_runs:
        active_dir = Path(pp_runs[-1]["dir"])
        gate_file = active_dir / "ceo_gate_decision.md"
        if gate_file.exists():
            content = gate_file.read_text(encoding="utf-8")
            if "KILL" in content.upper():
                project["gates"]["ceo_gate"] = {"status": "KILL", "date": datetime.now().strftime("%Y-%m-%d"), "notes": None}
            elif "GO" in content.upper():
                project["gates"]["ceo_gate"] = {"status": "GO", "date": datetime.now().strftime("%Y-%m-%d"), "notes": None}

    # Subsequent chapters
    chapter_dirs = [
        ("kapitel3", Path("factory/market_strategy/output")),
        ("kapitel4", Path("factory/mvp_scope/output")),
        ("kapitel45", Path("factory/design_vision/output")),
        ("kapitel5", Path("factory/visual_audit/output")),
        ("kapitel6", Path("factory/roadbook_assembly/output")),
    ]
    for chapter_key, chapter_dir in chapter_dirs:
        active = _find_active_run(slug, chapter_dir)
        if active:
            project["chapters"][chapter_key] = {
                "status": "complete",
                "run_number": active["number"],
                "output_dir": active["dir"],
                "date": datetime.now().strftime("%Y-%m-%d"),
            }

    # Visual review gate
    k5_output = Path("factory/visual_audit/output")
    if k5_output.exists():
        for d in k5_output.iterdir():
            if d.is_dir() and slug in d.name:
                review = d / "review_decision.md"
                if review.exists():
                    content = review.read_text(encoding="utf-8")
                    if "GO" in content.upper():
                        project["gates"]["visual_review"] = {
                            "status": "GO",
                            "date": datetime.now().strftime("%Y-%m-%d"),
                            "notes": None,
                        }

    project["status"] = _derive_status(project)
    project["current_phase"] = _derive_current_phase(project)

    save_dir = PROJECTS_DIR / slug
    save_dir.mkdir(parents=True, exist_ok=True)
    (save_dir / "project.json").write_text(
        json.dumps(project, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )
    action = "archived iteration" if archived else project_type
    print(f"[ProjectRegistry] {slug}: {action}, status={project['status']}")
