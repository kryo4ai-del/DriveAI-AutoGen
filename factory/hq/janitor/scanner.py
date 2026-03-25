"""Stufe 1: Schneller File-Scanner.

Sammelt Basisdaten ueber alle Dateien: Groesse, Alter, Zeilen, Typ.
Findet offensichtliche Probleme ohne Abhaengigkeitsanalyse.
Rein deterministisch, kein LLM, < 5 Sekunden.
"""

import logging
import os
import re
import time
from collections import Counter
from datetime import datetime, timezone, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[3]


def scan_files(config: dict) -> dict:
    """Scan all configured paths for basic file-level issues.

    Returns scan results with total counts and findings list.
    """
    start = time.time()
    exclude = set(config.get("exclude_paths", []))
    thresholds = config.get("thresholds", {})
    scan_paths = config.get("scan_paths", {})

    all_files = []

    # Collect all scannable paths
    path_lists = []
    for key in ("python", "javascript", "config_files", "data_dirs"):
        for p in scan_paths.get(key, []):
            path_lists.append(p)

    # Walk and collect
    for rel_dir in path_lists:
        abs_dir = PROJECT_ROOT / rel_dir
        if not abs_dir.exists():
            continue
        for root, dirs, files in os.walk(abs_dir):
            rel_root = Path(root).relative_to(PROJECT_ROOT).as_posix() + "/"
            # Filter excluded dirs
            dirs[:] = [d for d in dirs if not any(rel_root + d + "/" == ex or (rel_root + d + "/").startswith(ex) for ex in exclude)]
            for fname in files:
                fpath = Path(root) / fname
                try:
                    rel = fpath.relative_to(PROJECT_ROOT).as_posix()
                except ValueError:
                    continue
                if any(rel.startswith(ex.rstrip("/")) for ex in exclude):
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
                if any(empty_rel.startswith(ex.rstrip("/")) for ex in exclude):
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
            py_files = [f for f in files if f.endswith(".py") and f != "__init__.py"]
            has_init = "__init__.py" in files
            if py_files and not has_init:
                rel = Path(root).relative_to(PROJECT_ROOT).as_posix()
                if any(rel.startswith(ex.rstrip("/")) for ex in exclude):
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

    result = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "duration_sec": round(duration, 2),
        "total_files": len(all_files),
        "total_lines": total_lines,
        "total_size_mb": round(total_size / (1024 * 1024), 2),
        "by_type": dict(type_counter.most_common()),
        "findings": findings,
        "finding_count": len(findings),
    }

    logger.info("File scan complete: %d files, %d findings in %.1fs", len(all_files), len(findings), duration)
    return result
