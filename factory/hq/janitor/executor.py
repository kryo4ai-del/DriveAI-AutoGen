"""Executor: fuehrt Janitor-Aktionen aus basierend auf Sicherheitsstufe.

- Green (auto-fix): sofort ausfuehren
- Yellow (Vorschlag): in proposals/_pending.json speichern + Gate erstellen
- Red (report): nur dokumentieren
"""

import json
import logging
import os
import shutil
from datetime import datetime, timezone, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[3]
JANITOR_DIR = Path(__file__).parent
QUARANTINE_DIR = JANITOR_DIR / "quarantine"
PROPOSALS_DIR = JANITOR_DIR / "proposals"


def execute_findings(findings: list, config: dict, dry_run: bool = False) -> dict:
    """Process all findings based on severity.

    Returns summary of actions taken.
    """
    safety = config.get("safety", {})
    max_auto = safety.get("auto_fix_max_files", 1)

    results = {"auto_fixed": [], "proposed": [], "reported": [], "skipped": []}

    for finding in findings:
        count = finding.get("affected_count", 1)
        severity = finding.get("severity", "red")

        if severity == "green" and count <= max_auto and finding.get("auto_fixable"):
            if dry_run:
                results["auto_fixed"].append({"status": "dry_run", "finding": finding["id"], "action": finding.get("action")})
            else:
                result = _auto_fix(finding, config)
                results["auto_fixed"].append(result)
        elif severity == "yellow":
            if dry_run:
                results["proposed"].append({"status": "dry_run", "finding": finding["id"]})
            else:
                result = _create_proposal(finding)
                results["proposed"].append(result)
        elif severity == "red":
            results["reported"].append({
                "finding_id": finding.get("id"),
                "title": finding.get("title", finding.get("details", "")),
                "type": finding.get("type"),
            })
        else:
            results["skipped"].append(finding.get("id"))

    return results


def _auto_fix(finding: dict, config: dict) -> dict:
    """Execute an auto-fix. Always quarantine before deletion."""
    safety = config.get("safety", {})

    # Protected path check
    for path in finding.get("affected_files", []):
        if _is_protected(path, safety):
            return {"status": "skipped", "finding_id": finding.get("id"), "reason": f"Protected: {path}"}

    action = finding.get("action", "")

    if action in ("quarantine", "delete_or_quarantine"):
        filepath = finding["affected_files"][0]
        return _quarantine_file(filepath, finding)
    elif action == "create_init":
        dirpath = finding["affected_files"][0].replace("/__init__.py", "")
        return _create_init_file(dirpath)
    elif action == "clean_cache":
        return _clean_pycache(finding["affected_files"][0])
    elif action == "remove_empty_dir":
        return _remove_empty_dir(finding["affected_files"][0])

    return {"status": "unknown_action", "finding_id": finding.get("id"), "action": action}


def _quarantine_file(filepath: str, finding: dict) -> dict:
    """Move file to quarantine. Original is deleted after copy."""
    abs_path = PROJECT_ROOT / filepath
    if not abs_path.exists():
        return {"status": "skipped", "finding_id": finding.get("id"), "reason": "File not found"}

    QUARANTINE_DIR.mkdir(parents=True, exist_ok=True)

    # Quarantine path preserves relative structure
    quarantine_path = QUARANTINE_DIR / filepath
    quarantine_path.parent.mkdir(parents=True, exist_ok=True)

    try:
        shutil.copy2(abs_path, quarantine_path)
    except Exception as e:
        return {"status": "error", "finding_id": finding.get("id"), "reason": str(e)}

    # Update manifest
    manifest_file = QUARANTINE_DIR / "_manifest.json"
    manifest = _load_json(manifest_file, {"items": []})

    now = datetime.now(timezone.utc)
    delete_days = 7
    manifest["items"].append({
        "original_path": filepath,
        "quarantine_path": str(quarantine_path.relative_to(JANITOR_DIR)),
        "reason": finding.get("title", finding.get("details", "Unknown")),
        "finding_id": finding.get("id"),
        "quarantined_at": now.isoformat(),
        "auto_delete_after": (now + timedelta(days=delete_days)).isoformat(),
        "restored": False,
    })
    _save_json(manifest_file, manifest)

    # Delete original
    try:
        abs_path.unlink()
        logger.info("Quarantined: %s", filepath)
    except Exception as e:
        return {"status": "error", "finding_id": finding.get("id"), "reason": f"Delete failed: {e}"}

    return {
        "status": "quarantined",
        "finding_id": finding.get("id"),
        "path": filepath,
        "restore_until": manifest["items"][-1]["auto_delete_after"],
    }


def _create_init_file(dirpath: str) -> dict:
    """Create empty __init__.py in a package directory."""
    abs_dir = PROJECT_ROOT / dirpath
    init_path = abs_dir / "__init__.py"
    if init_path.exists():
        return {"status": "skipped", "reason": "__init__.py already exists", "path": dirpath}

    try:
        init_path.write_text('"""Auto-generated by Factory Janitor."""\n', encoding="utf-8")
        logger.info("Created __init__.py: %s", dirpath)
        return {"status": "created", "path": str(init_path.relative_to(PROJECT_ROOT))}
    except Exception as e:
        return {"status": "error", "reason": str(e), "path": dirpath}


def _clean_pycache(cache_path: str) -> dict:
    """Remove __pycache__ directory."""
    abs_path = PROJECT_ROOT / cache_path
    if not abs_path.exists():
        return {"status": "skipped", "reason": "Not found", "path": cache_path}

    try:
        shutil.rmtree(abs_path)
        logger.info("Cleaned: %s", cache_path)
        return {"status": "cleaned", "path": cache_path}
    except Exception as e:
        return {"status": "error", "reason": str(e), "path": cache_path}


def _remove_empty_dir(dirpath: str) -> dict:
    """Remove empty directory."""
    abs_path = PROJECT_ROOT / dirpath
    if not abs_path.exists():
        return {"status": "skipped", "reason": "Not found", "path": dirpath}

    # Safety: verify truly empty
    if any(abs_path.iterdir()):
        return {"status": "skipped", "reason": "Not empty", "path": dirpath}

    try:
        abs_path.rmdir()
        logger.info("Removed empty dir: %s", dirpath)
        return {"status": "removed", "path": dirpath}
    except Exception as e:
        return {"status": "error", "reason": str(e), "path": dirpath}


def _create_proposal(finding: dict) -> dict:
    """Create a proposal pending CEO decision."""
    PROPOSALS_DIR.mkdir(parents=True, exist_ok=True)

    pending_file = PROPOSALS_DIR / "_pending.json"
    pending = _load_json(pending_file, {"proposals": []})

    proposal_id = f"JP-{len(pending['proposals']) + 1:03d}"
    proposal = {
        "proposal_id": proposal_id,
        "finding_id": finding.get("id"),
        "title": finding.get("title", finding.get("details", "")),
        "description": finding.get("description", finding.get("details", "")),
        "affected_files": finding.get("affected_files", []),
        "affected_count": finding.get("affected_count", 0),
        "action": finding.get("action"),
        "impact_analysis": finding.get("impact_analysis", ""),
        "created_at": datetime.now(timezone.utc).isoformat(),
        "status": "pending",
        "decision": None,
        "decision_notes": None,
        "decided_at": None,
    }

    pending["proposals"].append(proposal)
    _save_json(pending_file, pending)

    # Create gate for CEO decision
    try:
        from factory.hq.gate_api import create_gate
        create_gate(
            project="_factory",
            gate_type="janitor_proposal",
            category="maintenance",
            title=f"Janitor: {finding.get('title', 'Cleanup-Vorschlag')}",
            description=finding.get("description", finding.get("details", "")),
            severity="info",
            options=[
                {"id": "approve", "label": "Genehmigen", "color": "green", "description": "Janitor darf die Aenderung durchfuehren"},
                {"id": "reject", "label": "Ablehnen", "color": "red", "description": "Nicht anfassen"},
                {"id": "later", "label": "Spaeter", "color": "yellow", "description": "Vorschlag merken, jetzt nicht umsetzen"},
            ],
            source_department="factory/hq/janitor",
            source_agent="factory_janitor",
            context={
                "proposal_id": proposal_id,
                "affected_files": finding.get("affected_files", []),
                "impact_analysis": finding.get("impact_analysis", ""),
            },
            recommendation={"option_id": "approve", "reasoning": finding.get("impact_analysis", "Sicherer Cleanup.")},
        )
    except Exception as e:
        logger.debug("Gate creation optional, skipped: %s", e)

    return {"status": "proposed", "proposal_id": proposal_id, "finding_id": finding.get("id")}


def restore_file(original_path: str) -> dict:
    """Restore a file from quarantine."""
    manifest_file = QUARANTINE_DIR / "_manifest.json"
    manifest = _load_json(manifest_file, {"items": []})

    # Find the quarantined item
    item = None
    for i, entry in enumerate(manifest["items"]):
        if entry["original_path"] == original_path and not entry.get("restored"):
            item = entry
            break

    if not item:
        return {"status": "error", "reason": f"Nicht in Quarantaene gefunden: {original_path}"}

    # Restore
    quarantine_path = JANITOR_DIR / item["quarantine_path"]
    restore_path = PROJECT_ROOT / original_path

    if not quarantine_path.exists():
        return {"status": "error", "reason": f"Quarantaene-Datei nicht gefunden: {quarantine_path}"}

    restore_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        shutil.copy2(quarantine_path, restore_path)
        item["restored"] = True
        item["restored_at"] = datetime.now(timezone.utc).isoformat()
        _save_json(manifest_file, manifest)
        logger.info("Restored from quarantine: %s", original_path)
        return {"status": "restored", "path": original_path}
    except Exception as e:
        return {"status": "error", "reason": str(e)}


def cleanup_quarantine(config: dict) -> dict:
    """Delete quarantine items older than configured days."""
    manifest_file = QUARANTINE_DIR / "_manifest.json"
    manifest = _load_json(manifest_file, {"items": []})

    now = datetime.now(timezone.utc)
    deleted = []
    kept = []

    for item in manifest["items"]:
        if item.get("restored"):
            kept.append(item)
            continue

        auto_delete = item.get("auto_delete_after", "")
        try:
            delete_date = datetime.fromisoformat(auto_delete)
        except (ValueError, TypeError):
            kept.append(item)
            continue

        if now >= delete_date:
            qpath = JANITOR_DIR / item["quarantine_path"]
            if qpath.exists():
                try:
                    qpath.unlink()
                    deleted.append(item["original_path"])
                    logger.info("Permanently deleted: %s", item["original_path"])
                except Exception:
                    kept.append(item)
            else:
                deleted.append(item["original_path"])
        else:
            kept.append(item)

    manifest["items"] = kept
    _save_json(manifest_file, manifest)

    return {"deleted_count": len(deleted), "deleted": deleted, "remaining": len(kept)}


def decide_proposal(proposal_id: str, decision: str, notes: str = "") -> dict:
    """Process a CEO decision on a janitor proposal."""
    pending_file = PROPOSALS_DIR / "_pending.json"
    pending = _load_json(pending_file, {"proposals": []})

    for prop in pending["proposals"]:
        if prop["proposal_id"] == proposal_id:
            prop["status"] = decision  # approved, rejected, later
            prop["decision"] = decision
            prop["decision_notes"] = notes
            prop["decided_at"] = datetime.now(timezone.utc).isoformat()
            _save_json(pending_file, pending)

            if decision == "approved":
                logger.info("Proposal %s approved. Note: manual execution required.", proposal_id)
                return {"status": "approved", "proposal_id": proposal_id,
                        "note": "Genehmigt. Manuelle Ausfuehrung noetig."}
            elif decision == "rejected":
                logger.info("Proposal %s rejected.", proposal_id)
                return {"status": "rejected", "proposal_id": proposal_id}
            else:
                return {"status": "deferred", "proposal_id": proposal_id}

    return {"status": "error", "reason": f"Proposal {proposal_id} nicht gefunden."}


def get_quarantine_status() -> dict:
    """Get current quarantine contents."""
    manifest_file = QUARANTINE_DIR / "_manifest.json"
    manifest = _load_json(manifest_file, {"items": []})

    active = [i for i in manifest["items"] if not i.get("restored")]
    return {
        "total": len(active),
        "items": active,
    }


def get_pending_proposals() -> dict:
    """Get pending proposals."""
    pending_file = PROPOSALS_DIR / "_pending.json"
    pending = _load_json(pending_file, {"proposals": []})

    open_props = [p for p in pending["proposals"] if p["status"] == "pending"]
    return {
        "total": len(open_props),
        "proposals": open_props,
    }


def _is_protected(path: str, safety: dict) -> bool:
    """Check if path is protected."""
    for pp in safety.get("protected_paths", []):
        if path.startswith(pp) or path == pp:
            return True
    for pattern in safety.get("protected_patterns", []):
        if Path(path).name == pattern or Path(path).match(pattern):
            return True
    return False


def _load_json(path: Path, default: dict) -> dict:
    """Load JSON file with default fallback."""
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return default


def _save_json(path: Path, data: dict):
    """Save dict as JSON."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
