"""Stufe 1: Schneller File-Scanner.

Sammelt Basisdaten ueber alle Dateien: Groesse, Alter, Zeilen, Typ.
Findet offensichtliche Probleme ohne Abhaengigkeitsanalyse.
Rein deterministisch, kein LLM, < 5 Sekunden.
"""

import json
import logging
import os
import re
import time
from collections import Counter
from datetime import datetime, timezone, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[3]
BASELINE_FILE = Path(__file__).parent / "_baseline.json"


def _load_project_slugs(config: dict) -> set:
    """Load all project slugs from factory/projects/ for exclusion."""
    slugs = set()
    slug_source = config.get("project_exclusions", {}).get("slug_source", "factory/projects/")
    projects_dir = PROJECT_ROOT / slug_source
    if projects_dir.exists():
        for d in projects_dir.iterdir():
            if d.is_dir() and not d.name.startswith("."):
                slugs.add(d.name)
    return slugs


def _is_project_file(rel_path: str, project_slugs: set, config: dict) -> bool:
    """Check if a file belongs to a project (output/data) and should be skipped.

    Project files are managed by the Dashboard DELETE endpoint, not the Janitor.
    """
    excl = config.get("project_exclusions", {})

    # Check output_dirs: files inside pipeline output directories
    for out_dir in excl.get("output_dirs", []):
        if rel_path.startswith(out_dir):
            return True

    # Check additional_skip_dirs: ideas, reports, generated code, logs
    for skip_dir in excl.get("additional_skip_dirs", []):
        if rel_path.startswith(skip_dir):
            return True

    # Check dynamic slug match in factory/projects/<slug>/
    slug_source = excl.get("slug_source", "factory/projects/")
    if rel_path.startswith(slug_source):
        return True

    return False


def scan_files(config: dict) -> dict:
    """Scan all configured paths for basic file-level issues.

    Returns scan results with total counts and findings list.
    """
    start = time.time()
    exclude = set(config.get("exclude_paths", []))
    exclude_dir_names = {ex.rstrip("/") for ex in exclude}
    thresholds = config.get("thresholds", {})
    scan_paths = config.get("scan_paths", {})
    project_slugs = _load_project_slugs(config)

    all_files = []
    skipped_project_files = 0

    # Collect all scannable paths (no data_dirs — project data is excluded)
    path_lists = []
    for key in ("python", "javascript", "config_files"):
        for p in scan_paths.get(key, []):
            path_lists.append(p)

    # Walk and collect
    for rel_dir in path_lists:
        abs_dir = PROJECT_ROOT / rel_dir
        if not abs_dir.exists():
            continue
        for root, dirs, files in os.walk(abs_dir):
            rel_root = Path(root).relative_to(PROJECT_ROOT).as_posix() + "/"
            # Filter excluded dirs — match by directory name (node_modules etc.) AND by path prefix
            dirs[:] = [d for d in dirs if d not in exclude_dir_names and not any(
                rel_root + d + "/" == ex or (rel_root + d + "/").startswith(ex) for ex in exclude
            )]
            for fname in files:
                fpath = Path(root) / fname
                try:
                    rel = fpath.relative_to(PROJECT_ROOT).as_posix()
                except ValueError:
                    continue
                if any(rel.startswith(ex.rstrip("/")) for ex in exclude):
                    continue
                # Skip project output/data files — managed by Dashboard DELETE
                if _is_project_file(rel, project_slugs, config):
                    skipped_project_files += 1
                    continue
                all_files.append(fpath)

    # Deduplicate
    seen = set()
    unique_files = []
    for f in all_files:
        key = str(f.resolve())
        if key not in seen:
            seen.add(key)
            unique_files.append(f)
    all_files = unique_files

    # Analyze
    total_lines = 0
    total_size = 0
    type_counter = Counter()
    findings = []
    finding_id = 0

    for fpath in all_files:
        try:
            stat = fpath.stat()
        except OSError:
            continue

        size = stat.st_size
        total_size += size
        suffix = fpath.suffix.lower()
        type_counter[suffix] += 1
        rel = fpath.relative_to(PROJECT_ROOT).as_posix()

        # Count lines for text files
        lines = 0
        content = None
        if suffix in (".py", ".js", ".jsx", ".ts", ".tsx", ".json", ".md", ".yaml", ".yml", ".css", ".html", ".shader"):
            try:
                content = fpath.read_text(encoding="utf-8", errors="ignore")
                lines = content.count("\n")
                total_lines += lines
            except Exception:
                pass

        mtime = datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc)
        age_days = (datetime.now(timezone.utc) - mtime).days

        # --- Checks ---

        # 1. Empty files
        if size < thresholds.get("empty_file_min_bytes", 10) and suffix != ".gitkeep":
            finding_id += 1
            findings.append({
                "id": f"F{finding_id:03d}",
                "type": "empty_file",
                "severity": "green",
                "path": rel,
                "details": f"{size} Bytes, vermutlich ueberfluessig",
                "action": "quarantine",
                "auto_fixable": True,
                "affected_files": [rel],
                "affected_count": 1,
            })

        # 2. Large files
        max_lines = thresholds.get("large_file_lines", 500)
        if lines > max_lines and suffix in (".py", ".js", ".jsx", ".ts", ".tsx"):
            finding_id += 1
            findings.append({
                "id": f"F{finding_id:03d}",
                "type": "large_file",
                "severity": "red",
                "path": rel,
                "details": f"{lines} Zeilen -- ueber Schwellenwert von {max_lines}",
                "action": "review_for_splitting",
                "auto_fixable": False,
                "affected_files": [rel],
                "affected_count": 1,
            })

        # 3. Old/stale files (tracked later with graph for import check)
        dead_days = thresholds.get("dead_file_days", 90)
        if age_days > dead_days and suffix in (".py", ".js", ".jsx"):
            finding_id += 1
            findings.append({
                "id": f"F{finding_id:03d}",
                "type": "stale_file",
                "severity": "yellow",
                "path": rel,
                "details": f"Nicht modifiziert seit {age_days} Tagen",
                "action": "check_if_imported",
                "auto_fixable": False,
                "affected_files": [rel],
                "affected_count": 1,
            })

        # 4. Backup/old naming
        fname_lower = fpath.stem.lower()
        if any(tag in fname_lower for tag in ("_old", "_backup", "_bak", "_copy", "_v1", "_deprecated")):
            finding_id += 1
            findings.append({
                "id": f"F{finding_id:03d}",
                "type": "backup_file",
                "severity": "yellow",
                "path": rel,
                "details": f"Name enthaelt Backup/Old-Marker: {fpath.name}",
                "action": "quarantine",
                "auto_fixable": False,
                "affected_files": [rel],
                "affected_count": 1,
            })

        # 8. TODO/FIXME/HACK comments
        if content and suffix in (".py", ".js", ".jsx", ".ts", ".tsx"):
            todos = len(re.findall(r"#\s*(TODO|FIXME|HACK|XXX)\b", content, re.IGNORECASE))
            if todos > 0:
                finding_id += 1
                findings.append({
                    "id": f"F{finding_id:03d}",
                    "type": "tech_debt_comments",
                    "severity": "red",
                    "path": rel,
                    "details": f"{todos} TODO/FIXME/HACK Kommentare",
                    "action": "report_only",
                    "auto_fixable": False,
                    "affected_files": [rel],
                    "affected_count": 1,
                })

        # 9. Large commented-out blocks (10+ consecutive comment lines)
        if content and suffix in (".py", ".js", ".jsx"):
            consecutive = 0
            max_consecutive = 0
            for line in content.splitlines():
                stripped = line.strip()
                if stripped.startswith("#") or stripped.startswith("//"):
                    consecutive += 1
                    max_consecutive = max(max_consecutive, consecutive)
                else:
                    consecutive = 0
            if max_consecutive >= 10:
                finding_id += 1
                findings.append({
                    "id": f"F{finding_id:03d}",
                    "type": "commented_code_block",
                    "severity": "yellow",
                    "path": rel,
                    "details": f"{max_consecutive} aufeinanderfolgende Kommentarzeilen",
                    "action": "review_for_cleanup",
                    "auto_fixable": False,
                    "affected_files": [rel],
                    "affected_count": 1,
                })

    # 5. Duplicate filenames across directories
    name_map = {}
    for fpath in all_files:
        name_map.setdefault(fpath.name, []).append(fpath.relative_to(PROJECT_ROOT).as_posix())
    for name, paths in name_map.items():
        if len(paths) > 1 and name not in ("__init__.py", "README.md", "CLAUDE.md", "MEMORY.md", ".gitkeep", "config.json", "index.js"):
            finding_id += 1
            findings.append({
                "id": f"F{finding_id:03d}",
                "type": "duplicate_filename",
                "severity": "yellow",
                "path": paths[0],
                "details": f"Dateiname '{name}' existiert in {len(paths)} Ordnern: {', '.join(paths[:5])}",
                "action": "check_if_duplicate",
                "auto_fixable": False,
                "affected_files": paths,
                "affected_count": len(paths),
            })

    # 6. __pycache__ directories
    for rel_dir in path_lists:
        abs_dir = PROJECT_ROOT / rel_dir
        if not abs_dir.exists():
            continue
        for root, dirs, files in os.walk(abs_dir):
            dirs[:] = [d for d in dirs if d not in exclude_dir_names]
            for d in dirs:
                if d == "__pycache__":
                    cache_path = (Path(root) / d).relative_to(PROJECT_ROOT).as_posix()
                    finding_id += 1
                    findings.append({
                        "id": f"F{finding_id:03d}",
                        "type": "pycache",
                        "severity": "green",
                        "path": cache_path,
                        "details": "__pycache__ Ordner",
                        "action": "clean_cache",
                        "auto_fixable": True,
                        "affected_files": [cache_path],
                        "affected_count": 1,
                    })

    # 7. Empty directories
    for rel_dir in path_lists:
        abs_dir = PROJECT_ROOT / rel_dir
        if not abs_dir.exists():
            continue
        for root, dirs, files in os.walk(abs_dir, topdown=False):
            if not dirs and not files:
                try:
                    empty_rel = Path(root).relative_to(PROJECT_ROOT).as_posix()
                except ValueError:
                    continue
                # Skip excluded dirs (by name segments and by prefix)
                parts = empty_rel.split("/")
                if any(p in exclude_dir_names for p in parts):
                    continue
                if any(empty_rel.startswith(ex.rstrip("/")) for ex in exclude):
                    continue
                # Skip project output dirs
                if _is_project_file(empty_rel + "/", project_slugs, config):
                    continue
                finding_id += 1
                findings.append({
                    "id": f"F{finding_id:03d}",
                    "type": "empty_dir",
                    "severity": "green",
                    "path": empty_rel,
                    "details": "Leerer Ordner",
                    "action": "remove_empty_dir",
                    "auto_fixable": True,
                    "affected_files": [empty_rel],
                    "affected_count": 1,
                })

    # 10. Missing __init__.py in Python packages
    for rel_dir in scan_paths.get("python", []):
        abs_dir = PROJECT_ROOT / rel_dir
        if not abs_dir.exists():
            continue
        for root, dirs, files in os.walk(abs_dir):
            dirs[:] = [d for d in dirs if d not in exclude_dir_names]
            py_files = [f for f in files if f.endswith(".py") and f != "__init__.py"]
            has_init = "__init__.py" in files
            if py_files and not has_init:
                rel = Path(root).relative_to(PROJECT_ROOT).as_posix()
                if any(rel.startswith(ex.rstrip("/")) for ex in exclude):
                    continue
                if _is_project_file(rel + "/", project_slugs, config):
                    continue
                finding_id += 1
                findings.append({
                    "id": f"F{finding_id:03d}",
                    "type": "missing_init",
                    "severity": "green",
                    "path": rel,
                    "details": f"Python-Package ohne __init__.py ({len(py_files)} .py Dateien)",
                    "action": "create_init",
                    "auto_fixable": True,
                    "affected_files": [rel + "/__init__.py"],
                    "affected_count": 1,
                })

    duration = time.time() - start

    # Growth Alert: compare against baseline
    current_metrics = {
        "total_files": len(all_files),
        "total_lines": total_lines,
        "total_size_mb": round(total_size / (1024 * 1024), 2),
        "by_type": dict(type_counter.most_common()),
    }
    growth_alerts = _check_growth(current_metrics, config)

    # Save current metrics as new baseline
    _save_baseline(current_metrics)

    result = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "duration_sec": round(duration, 2),
        "total_files": len(all_files),
        "skipped_project_files": skipped_project_files,
        "total_lines": total_lines,
        "total_size_mb": round(total_size / (1024 * 1024), 2),
        "by_type": dict(type_counter.most_common()),
        "findings": findings,
        "finding_count": len(findings),
        "growth_alerts": growth_alerts,
    }

    logger.info("File scan complete: %d files (%d project files skipped), %d findings, %d growth alerts in %.1fs",
                len(all_files), skipped_project_files, len(findings), len(growth_alerts), duration)
    return result


def _load_baseline() -> dict | None:
    """Load previous scan baseline."""
    if BASELINE_FILE.exists():
        try:
            return json.loads(BASELINE_FILE.read_text(encoding="utf-8"))
        except Exception:
            pass
    return None


def _save_baseline(metrics: dict):
    """Save current scan metrics as baseline for next comparison."""
    data = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        **metrics,
    }
    try:
        BASELINE_FILE.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    except Exception as e:
        logger.warning("Could not save baseline: %s", e)


def _check_growth(current: dict, config: dict) -> list:
    """Compare current metrics against baseline and generate alerts."""
    baseline = _load_baseline()
    if not baseline:
        return []

    alerts = []
    growth_cfg = config.get("growth_alert", {})
    file_threshold_pct = growth_cfg.get("file_change_threshold_pct", 15)
    line_threshold_pct = growth_cfg.get("line_change_threshold_pct", 20)
    size_threshold_pct = growth_cfg.get("size_change_threshold_pct", 25)

    # File count change
    prev_files = baseline.get("total_files", 0)
    cur_files = current.get("total_files", 0)
    if prev_files > 0:
        file_delta = cur_files - prev_files
        file_pct = abs(file_delta) / prev_files * 100
        if file_pct >= file_threshold_pct:
            direction = "gewachsen" if file_delta > 0 else "geschrumpft"
            alerts.append({
                "type": "file_count",
                "severity": "red" if file_pct >= file_threshold_pct * 2 else "yellow",
                "message": f"Dateianzahl {direction}: {prev_files} -> {cur_files} ({file_delta:+d}, {file_pct:.0f}%)",
                "previous": prev_files,
                "current": cur_files,
                "delta": file_delta,
                "delta_pct": round(file_pct, 1),
            })

    # Line count change
    prev_lines = baseline.get("total_lines", 0)
    cur_lines = current.get("total_lines", 0)
    if prev_lines > 0:
        line_delta = cur_lines - prev_lines
        line_pct = abs(line_delta) / prev_lines * 100
        if line_pct >= line_threshold_pct:
            direction = "gewachsen" if line_delta > 0 else "geschrumpft"
            alerts.append({
                "type": "line_count",
                "severity": "red" if line_pct >= line_threshold_pct * 2 else "yellow",
                "message": f"Code-Zeilen {direction}: {prev_lines:,} -> {cur_lines:,} ({line_delta:+,}, {line_pct:.0f}%)",
                "previous": prev_lines,
                "current": cur_lines,
                "delta": line_delta,
                "delta_pct": round(line_pct, 1),
            })

    # Size change
    prev_size = baseline.get("total_size_mb", 0)
    cur_size = current.get("total_size_mb", 0)
    if prev_size > 0:
        size_delta = cur_size - prev_size
        size_pct = abs(size_delta) / prev_size * 100
        if size_pct >= size_threshold_pct:
            direction = "gewachsen" if size_delta > 0 else "geschrumpft"
            alerts.append({
                "type": "size",
                "severity": "red" if size_pct >= size_threshold_pct * 2 else "yellow",
                "message": f"Projektgroesse {direction}: {prev_size:.1f} MB -> {cur_size:.1f} MB ({size_delta:+.1f} MB, {size_pct:.0f}%)",
                "previous": prev_size,
                "current": cur_size,
                "delta": round(size_delta, 2),
                "delta_pct": round(size_pct, 1),
            })

    # New file types appearing
    prev_types = set(baseline.get("by_type", {}).keys())
    cur_types = set(current.get("by_type", {}).keys())
    new_types = cur_types - prev_types
    if new_types:
        alerts.append({
            "type": "new_file_types",
            "severity": "yellow",
            "message": f"Neue Dateitypen: {', '.join(sorted(new_types))}",
            "new_types": sorted(new_types),
        })

    if alerts:
        logger.info("Growth alerts: %d alerts generated", len(alerts))

    return alerts
