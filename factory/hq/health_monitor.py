"""Factory Health Monitor — deterministic scan of the entire factory state.

No LLM calls. Pure file I/O, JSON parsing, timestamp comparisons.
"""

import json
import logging
from datetime import datetime, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)

FACTORY_BASE = Path(__file__).parent.parent.parent
PROJECTS_DIR = FACTORY_BASE / "factory" / "projects"
OUTPUT_DIRS = {
    "phase1": FACTORY_BASE / "factory" / "pre_production" / "output",
    "kapitel3": FACTORY_BASE / "factory" / "market_strategy" / "output",
    "kapitel4": FACTORY_BASE / "factory" / "mvp_scope" / "output",
    "kapitel45": FACTORY_BASE / "factory" / "design_vision" / "output",
    "kapitel5": FACTORY_BASE / "factory" / "visual_audit" / "output",
    "kapitel6": FACTORY_BASE / "factory" / "roadbook_assembly" / "output",
}
DOC_SEC_DIR = FACTORY_BASE / "factory" / "document_secretary" / "output"

EXPECTED_REPORTS = {
    "phase1": ["concept_brief.md", "trend_report.md", "competitive_report.md",
               "audience_profile.md", "legal_report.md", "risk_assessment.md"],
    "kapitel3": ["platform_strategy.md", "monetization_report.md", "marketing_strategy.md",
                 "release_plan.md", "cost_calculation.md"],
    "kapitel4": ["feature_list.md", "feature_prioritization.md", "screen_architecture.md"],
    "kapitel45": ["trend_breaker_report.md", "emotion_architect_report.md", "design_vision_document.md"],
    "kapitel5": ["asset_discovery.md", "asset_strategy.md", "visual_consistency.md"],
    "kapitel6": ["ceo_strategic_roadbook.md", "cd_technical_roadbook.md"],
}


def run_health_check() -> dict:
    """Scan the factory and return alerts."""
    now = datetime.now()
    alerts = []

    # Load all projects
    projects = _load_projects()

    # Check 1: Orphaned runs
    alerts.extend(_check_orphaned_runs(projects))

    # Check 2: Broken project.json
    alerts.extend(_check_broken_projects(projects))

    # Check 3: Stuck pipelines
    alerts.extend(_check_stuck_pipelines(projects, now))

    # Check 4: Missing reports
    alerts.extend(_check_missing_reports(projects))

    # Check 5: Missing PDFs
    alerts.extend(_check_missing_pdfs(projects))

    # Check 6: Stale gates
    alerts.extend(_check_stale_gates(projects, now))

    # Check 7: Inconsistent status
    alerts.extend(_check_inconsistent_status(projects))

    # Check 8: Missing mode
    alerts.extend(_check_missing_fields(projects))

    # Summary
    crit = sum(1 for a in alerts if a["severity"] == "critical")
    warn = sum(1 for a in alerts if a["severity"] == "warning")
    info = sum(1 for a in alerts if a["severity"] == "info")
    healthy = sum(1 for p in projects.values() if not any(
        a["project"] == p.get("project_id") for a in alerts if a["severity"] in ("critical", "warning")
    ))

    status = "critical" if crit > 0 else "warnings" if warn > 0 else "healthy"

    return {
        "timestamp": now.isoformat(),
        "status": status,
        "alerts": alerts,
        "summary": {
            "total_projects": len(projects),
            "healthy_projects": healthy,
            "projects_with_issues": len(projects) - healthy,
            "total_alerts": len(alerts),
            "critical": crit,
            "warnings": warn,
            "info": info,
        },
    }


def _load_projects() -> dict:
    if not PROJECTS_DIR.exists():
        return {}
    projects = {}
    for d in PROJECTS_DIR.iterdir():
        pf = d / "project.json"
        if pf.exists():
            try:
                projects[d.name] = json.loads(pf.read_text(encoding="utf-8"))
            except Exception:
                projects[d.name] = {"project_id": d.name, "_broken": True}
    return projects


def _check_orphaned_runs(projects: dict) -> list:
    alerts = []
    known_dirs = set()
    for p in projects.values():
        for ch in (p.get("chapters") or {}).values():
            od = ch.get("output_dir") if isinstance(ch, dict) else None
            if od:
                known_dirs.add(Path(od).name if not Path(od).is_absolute() else Path(od).name)

    for phase, base_dir in OUTPUT_DIRS.items():
        if not base_dir.exists():
            continue
        for d in base_dir.iterdir():
            if d.is_dir() and d.name not in known_dirs:
                # Check if slug is in any project
                slug = d.name.split("_", 1)[1] if "_" in d.name else d.name
                if slug not in projects:
                    alerts.append({
                        "severity": "warning",
                        "category": "orphaned_run",
                        "project": slug,
                        "message": f"Output-Verzeichnis {d.name} in {phase} hat keine project.json",
                        "auto_fixable": True,
                        "details": {"path": str(d), "phase": phase},
                    })
    return alerts


def _check_broken_projects(projects: dict) -> list:
    alerts = []
    for slug, p in projects.items():
        if p.get("_broken"):
            alerts.append({
                "severity": "critical",
                "category": "broken_project",
                "project": slug,
                "message": f"project.json fuer {slug} ist nicht parsebar",
                "auto_fixable": False,
                "details": {},
            })
            continue
        for field in ["project_id", "status"]:
            if field not in p:
                alerts.append({
                    "severity": "critical",
                    "category": "broken_project",
                    "project": slug,
                    "message": f"Pflichtfeld '{field}' fehlt in project.json",
                    "auto_fixable": True,
                    "details": {"missing_field": field},
                })
    return alerts


def _check_stuck_pipelines(projects: dict, now: datetime) -> list:
    alerts = []
    for slug, p in projects.items():
        for ch_key, ch in (p.get("chapters") or {}).items():
            if not isinstance(ch, dict):
                continue
            if ch.get("status") == "running":
                od = ch.get("output_dir")
                if od:
                    summary = Path(od) / "pipeline_summary.md"
                    if not summary.exists():
                        alerts.append({
                            "severity": "warning",
                            "category": "stuck_pipeline",
                            "project": slug,
                            "message": f"{ch_key} hat Status 'running' aber keine pipeline_summary.md",
                            "auto_fixable": False,
                            "details": {"chapter": ch_key},
                        })
    return alerts


def _check_missing_reports(projects: dict) -> list:
    alerts = []
    for slug, p in projects.items():
        for ch_key, expected in EXPECTED_REPORTS.items():
            ch = (p.get("chapters") or {}).get(ch_key)
            if not isinstance(ch, dict) or ch.get("status") != "complete":
                continue
            od = ch.get("output_dir")
            if not od or not Path(od).exists():
                continue
            missing = [f for f in expected if not (Path(od) / f).exists()]
            if missing:
                alerts.append({
                    "severity": "warning",
                    "category": "missing_reports",
                    "project": slug,
                    "message": f"{ch_key}: {len(missing)} erwartete Reports fehlen ({', '.join(missing[:3])})",
                    "auto_fixable": False,
                    "details": {"chapter": ch_key, "missing": missing},
                })
    return alerts


def _check_missing_pdfs(projects: dict) -> list:
    alerts = []
    if not DOC_SEC_DIR.exists():
        return alerts
    all_pdfs = {f.name.lower(): str(f) for f in DOC_SEC_DIR.iterdir() if f.suffix == ".pdf"}

    for slug, p in projects.items():
        # Only check projects with kapitel4+ complete
        chapters = p.get("chapters") or {}
        has_advanced = any(
            isinstance(chapters.get(k), dict) and chapters[k].get("status") == "complete"
            for k in ["kapitel4", "kapitel45", "kapitel5", "kapitel6"]
        )
        if not has_advanced:
            continue

        project_pdfs = [v for k, v in all_pdfs.items() if slug in k]
        existing_doc_pdfs = p.get("documents", {}).get("pdfs", [])

        if not project_pdfs and not existing_doc_pdfs:
            alerts.append({
                "severity": "info",
                "category": "missing_pdfs",
                "project": slug,
                "message": f"Keine PDFs fuer {slug} gefunden (Kapitel 4+ fertig)",
                "auto_fixable": False,
                "details": {},
            })
    return alerts


def _check_stale_gates(projects: dict, now: datetime) -> list:
    alerts = []
    threshold = timedelta(hours=48)

    for slug, p in projects.items():
        for gate_key in ["ceo_gate", "visual_review"]:
            gate = (p.get("gates") or {}).get(gate_key, {})
            ch_gate = (p.get("chapters") or {}).get(gate_key, {})

            # Is gate pending?
            gate_status = gate.get("status", "pending")
            ch_decision = ch_gate.get("decision") if isinstance(ch_gate, dict) else None

            if gate_status == "pending" and not ch_decision:
                # Check if the preceding chapter is complete
                prereq = "phase1" if gate_key == "ceo_gate" else "kapitel5"
                prereq_ch = (p.get("chapters") or {}).get(prereq, {})
                if isinstance(prereq_ch, dict) and prereq_ch.get("status") == "complete":
                    date_str = prereq_ch.get("date")
                    if date_str:
                        try:
                            ch_date = datetime.strptime(date_str, "%Y-%m-%d")
                            if now - ch_date > threshold:
                                days = (now - ch_date).days
                                alerts.append({
                                    "severity": "warning",
                                    "category": "stale_gate",
                                    "project": slug,
                                    "message": f"{gate_key} wartet seit {days} Tagen auf Entscheidung",
                                    "auto_fixable": False,
                                    "details": {"gate": gate_key, "waiting_since": date_str, "days": days},
                                })
                        except ValueError:
                            pass
    return alerts


def _check_inconsistent_status(projects: dict) -> list:
    alerts = []
    for slug, p in projects.items():
        if p.get("_broken"):
            continue
        expected = _derive_expected_status(p)
        actual = p.get("status", "unknown")
        if expected and actual != expected and actual != "unknown":
            alerts.append({
                "severity": "warning",
                "category": "inconsistent_status",
                "project": slug,
                "message": f"Status '{actual}' passt nicht zu Kapitel-Status (erwartet: '{expected}')",
                "auto_fixable": True,
                "details": {"current": actual, "expected": expected},
            })
    return alerts


def _check_missing_fields(projects: dict) -> list:
    alerts = []
    for slug, p in projects.items():
        if p.get("_broken"):
            continue
        for field in ["mode", "created_at", "documents"]:
            if field not in p:
                alerts.append({
                    "severity": "info",
                    "category": "missing_field",
                    "project": slug,
                    "message": f"Feld '{field}' fehlt in project.json",
                    "auto_fixable": True,
                    "details": {"field": field},
                })
    return alerts


def _derive_expected_status(p: dict) -> str:
    ch = p.get("chapters") or {}
    gates = p.get("gates") or {}

    if isinstance(ch.get("kapitel6"), dict) and ch["kapitel6"].get("status") == "complete":
        return "preproduction_done"
    if isinstance(ch.get("kapitel5"), dict) and ch["kapitel5"].get("status") == "complete":
        vr = gates.get("visual_review", {})
        if vr.get("status") in ("GO", "GO_MIT_NOTES"):
            return "review_go"
        return "review_pending"
    if isinstance(ch.get("kapitel45"), dict) and ch["kapitel45"].get("status") == "complete":
        return "design_complete"
    if isinstance(ch.get("kapitel4"), dict) and ch["kapitel4"].get("status") == "complete":
        return "features_complete"
    if isinstance(ch.get("kapitel3"), dict) and ch["kapitel3"].get("status") == "complete":
        return "strategy_complete"

    ceo = gates.get("ceo_gate", {})
    if ceo.get("status") == "KILL":
        return "killed"
    if ceo.get("status") in ("GO", "GO_MIT_NOTES"):
        return "ceo_gate_go"

    if isinstance(ch.get("phase1"), dict) and ch["phase1"].get("status") == "complete":
        return "ceo_gate_pending"

    return None  # Can't determine


if __name__ == "__main__":
    result = run_health_check()
    print(f"Factory Health: {result['status'].upper()}")
    print(f"Projects: {result['summary']['total_projects']}, "
          f"Alerts: {result['summary']['total_alerts']} "
          f"({result['summary']['critical']}C/{result['summary']['warnings']}W/{result['summary']['info']}I)")
    for a in result["alerts"]:
        icon = {"critical": "🔴", "warning": "🟡", "info": "ℹ️"}.get(a["severity"], "?")
        fix = " [auto-fix]" if a["auto_fixable"] else ""
        print(f"  {icon} {a['project']}: {a['message']}{fix}")
