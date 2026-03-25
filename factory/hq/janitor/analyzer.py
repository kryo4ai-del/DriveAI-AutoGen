"""Problem-Analyzer: kombiniert Scanner + Graph-Daten zu konkreten Findings.

Analysiert den Abhaengigkeits-Graphen und File-Scan um Probleme zu finden.
Rein deterministisch, kein LLM.
"""

import logging
import re
from collections import Counter
from pathlib import Path

logger = logging.getLogger(__name__)


def analyze(scan_data: dict, graph: dict, config: dict) -> dict:
    """Analyze scan + graph data to produce actionable findings.

    Returns findings list with severity, affected files, and actions.
    """
    findings = []
    finding_id = _max_finding_id(scan_data.get("findings", []))

    thresholds = config.get("thresholds", {})
    safety = config.get("safety", {})
    max_auto = safety.get("auto_fix_max_files", 1)
    max_proposal = safety.get("proposal_max_files", 5)

    nodes = graph.get("nodes", {})
    stats = graph.get("stats", {})

    # 1. Dead code: files not imported by anyone and not entry points
    orphans = stats.get("orphan_list", [])
    for orphan_path in orphans:
        node = nodes.get(orphan_path, {})
        # Skip __init__.py, config files, templates
        if _is_skip_for_dead_code(orphan_path):
            continue
        finding_id += 1
        findings.append({
            "id": f"F{finding_id:03d}",
            "type": "dead_code",
            "severity": "green" if node.get("lines", 0) < 50 else "yellow",
            "title": f"Tote Datei: {orphan_path}",
            "description": f"Wird von keiner Datei importiert und ist kein Entry-Point. {node.get('lines', 0)} Zeilen.",
            "affected_files": [orphan_path],
            "affected_count": 1,
            "action": "quarantine",
            "auto_fixable": node.get("lines", 0) < 50,
            "impact_analysis": "Keine anderen Dateien betroffen. Sicheres Entfernen.",
        })

    # 2. Circular dependencies
    circular = stats.get("circular_list", [])
    for cycle in circular:
        files_in_cycle = [p for p in cycle.split(" -> ") if p]
        finding_id += 1
        findings.append({
            "id": f"F{finding_id:03d}",
            "type": "circular_dependency",
            "severity": "red",
            "title": f"Zirkulaere Abhaengigkeit: {len(files_in_cycle)} Dateien",
            "description": cycle,
            "affected_files": files_in_cycle,
            "affected_count": len(files_in_cycle),
            "action": "report_only",
            "auto_fixable": False,
            "impact_analysis": "Zirkulaere Imports koennen zu Laufzeitfehlern fuehren.",
        })

    # 3. Duplicate function names across files
    func_map = {}
    for path, node in nodes.items():
        if node.get("type") != "python":
            continue
        for func in node.get("functions", []):
            func_map.setdefault(func, []).append(path)

    for func_name, paths in func_map.items():
        if len(paths) >= 3 and func_name not in ("__init__", "main", "run", "setup", "teardown"):
            finding_id += 1
            count = len(paths)
            sev = "yellow" if count <= max_proposal else "red"
            findings.append({
                "id": f"F{finding_id:03d}",
                "type": "duplicate_logic",
                "severity": sev,
                "title": f"Doppelte Funktion: {func_name}() in {count} Dateien",
                "description": f"Die Funktion {func_name}() existiert in {count} Dateien. Koennte in ein shared Modul extrahiert werden.",
                "affected_files": paths[:10],
                "affected_count": count,
                "action": "refactor_proposal" if sev == "yellow" else "report_only",
                "auto_fixable": False,
                "impact_analysis": f"{count} Dateien muessten geaendert werden.",
            })

    # 4. Stale imports: imports that don't resolve to any file
    for path, node in nodes.items():
        if node.get("type") != "python":
            continue
        unresolved = []
        for imp in node.get("imports", []):
            # Only flag factory.* imports that don't resolve
            if imp.startswith("factory.") or imp.startswith("agents.") or imp.startswith("config."):
                resolved = _check_import_resolved(imp, path, graph.get("edges", []))
                if not resolved:
                    unresolved.append(imp)
        if unresolved:
            finding_id += 1
            findings.append({
                "id": f"F{finding_id:03d}",
                "type": "stale_import",
                "severity": "yellow",
                "title": f"Tote Imports in {path}",
                "description": f"{len(unresolved)} Imports die zu keinem existierenden Modul fuehren: {', '.join(unresolved[:5])}",
                "affected_files": [path],
                "affected_count": 1,
                "action": "fix_imports",
                "auto_fixable": False,
                "impact_analysis": "Import-Fehler koennen Laufzeitfehler verursachen.",
            })

    # 5. Upgrade stale_file findings from scanner with import data
    for sf in scan_data.get("findings", []):
        if sf["type"] == "stale_file":
            node = nodes.get(sf["path"], {})
            imported_by = node.get("imported_by", [])
            if not imported_by and not node.get("is_entry_point"):
                sf["severity"] = "green"
                sf["auto_fixable"] = True
                sf["action"] = "quarantine"
                sf["title"] = f"Tote + Alte Datei: {sf['path']}"
                sf["description"] = sf["details"] + " UND wird nirgends importiert."
                sf["impact_analysis"] = "Sicher entfernbar."
            else:
                sf["severity"] = "red"
                sf["description"] = sf["details"] + f" ABER wird noch importiert von {len(imported_by)} Dateien."
                sf["action"] = "report_only"

    # Merge scanner findings + new findings
    all_findings = list(scan_data.get("findings", [])) + findings

    # Assign safety levels based on affected_count
    for f in all_findings:
        count = f.get("affected_count", 1)
        if f["severity"] == "green" and count <= max_auto and f.get("auto_fixable"):
            pass  # Keep green
        elif count > safety.get("report_only_above", 6):
            f["severity"] = "red"
            f["auto_fixable"] = False
        elif count > max_auto and f["severity"] == "green":
            f["severity"] = "yellow"
            f["auto_fixable"] = False

    # Health score
    green_count = sum(1 for f in all_findings if f["severity"] == "green")
    yellow_count = sum(1 for f in all_findings if f["severity"] == "yellow")
    red_count = sum(1 for f in all_findings if f["severity"] == "red")
    total_files = scan_data.get("total_files", 1) or 1

    # Score: 100 - penalty (green=0.5, yellow=2, red=5 per finding, scaled by file count)
    penalty = (green_count * 0.5 + yellow_count * 2 + red_count * 5) / total_files * 100
    health_score = max(0, min(100, round(100 - penalty)))

    summary = {
        "total_findings": len(all_findings),
        "green_auto_fixable": green_count,
        "yellow_proposals": yellow_count,
        "red_report_only": red_count,
        "health_score": health_score,
    }

    logger.info("Analysis complete: %d findings (G:%d Y:%d R:%d), Health Score: %d",
                len(all_findings), green_count, yellow_count, red_count, health_score)

    return {
        "findings": all_findings,
        "summary": summary,
    }


def _max_finding_id(findings: list) -> int:
    """Get highest finding ID number."""
    max_id = 0
    for f in findings:
        fid = f.get("id", "F000")
        try:
            max_id = max(max_id, int(fid[1:]))
        except (ValueError, IndexError):
            pass
    return max_id


def _is_skip_for_dead_code(path: str) -> bool:
    """Skip certain files from dead-code detection."""
    skip_patterns = (
        "__init__.py", "README.md", "CLAUDE.md", "MEMORY.md",
        "__main__.py", "conftest.py", "setup.py",
    )
    basename = Path(path).name
    if basename in skip_patterns:
        return True
    # Skip template/config/data directories
    skip_dirs = ("templates/", "shader_templates/", "level_templates/", "specs/",
                 "generated/", "output/", "catalog/", "ideas/", "DeveloperReports/",
                 "factory_knowledge/", "quarantine/", "reports/", "proposals/")
    return any(d in path for d in skip_dirs)


def _check_import_resolved(imp: str, src_path: str, edges: list) -> bool:
    """Check if an import from src_path resolves via any edge."""
    for e in edges:
        if e["from"] == src_path and imp in e.get("to", ""):
            return True
    return False
