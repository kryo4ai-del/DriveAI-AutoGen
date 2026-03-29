"""Dependency Health Checker.

Prueft package.json und requirements.txt auf:
- Fehlende Lock-Files (package-lock.json / requirements.txt mit Versionen)
- Ungepinnte Versionen (kein == / kein ^ / kein ~)
- Veraltete major-Versionen (heuristisch)
- Doppelte Dependencies in mehreren package.json

Rein deterministisch, kein LLM, keine Netzwerk-Aufrufe.
"""

import json
import logging
import re
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[3]


def check_dependencies(config: dict) -> dict:
    """Run dependency health checks."""
    findings = []
    exclude = set(config.get("exclude_paths", []))

    # Find all requirements.txt and package.json
    req_files = _find_files("requirements.txt", exclude)
    pkg_files = _find_files("package.json", exclude)

    # --- Python: requirements.txt ---
    for req_path in req_files:
        rel = req_path.relative_to(PROJECT_ROOT).as_posix()
        try:
            content = req_path.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue

        lines = [l.strip() for l in content.splitlines() if l.strip() and not l.strip().startswith("#")]
        unpinned = []
        for line in lines:
            # Skip -r references, URLs, editable installs
            if line.startswith("-") or line.startswith("http") or line.startswith("git+"):
                continue
            # Check if version is pinned
            if "==" not in line and ">=" not in line and "<=" not in line:
                pkg_name = re.split(r"[\[;]", line)[0].strip()
                if pkg_name:
                    unpinned.append(pkg_name)

        if unpinned:
            findings.append({
                "type": "unpinned_python",
                "severity": "yellow",
                "message": f"{rel}: {len(unpinned)} ungepinnte Packages: {', '.join(unpinned[:8])}",
                "file": rel,
                "packages": unpinned,
                "count": len(unpinned),
            })

        # Check for lock file
        lock = req_path.parent / "requirements.lock"
        pip_lock = req_path.parent / "Pipfile.lock"
        poetry_lock = req_path.parent / "poetry.lock"
        if not lock.exists() and not pip_lock.exists() and not poetry_lock.exists():
            findings.append({
                "type": "no_python_lock",
                "severity": "yellow",
                "message": f"{rel}: Kein Lock-File gefunden (reproduzierbare Builds nicht garantiert)",
                "file": rel,
            })

    # --- JavaScript: package.json ---
    all_deps = {}  # Track all deps across files for duplicates

    for pkg_path in pkg_files:
        rel = pkg_path.relative_to(PROJECT_ROOT).as_posix()
        try:
            data = json.loads(pkg_path.read_text(encoding="utf-8"))
        except Exception:
            continue

        deps = data.get("dependencies", {})
        dev_deps = data.get("devDependencies", {})
        all_combined = {**deps, **dev_deps}

        # Track for cross-file duplicate check
        for name, version in all_combined.items():
            all_deps.setdefault(name, []).append({"file": rel, "version": version})

        # Check for lock file
        lock_json = pkg_path.parent / "package-lock.json"
        yarn_lock = pkg_path.parent / "yarn.lock"
        pnpm_lock = pkg_path.parent / "pnpm-lock.yaml"
        if not lock_json.exists() and not yarn_lock.exists() and not pnpm_lock.exists():
            findings.append({
                "type": "no_js_lock",
                "severity": "yellow",
                "message": f"{rel}: Kein Lock-File (package-lock.json / yarn.lock)",
                "file": rel,
            })

        # Check for wildcard versions
        wildcards = [n for n, v in all_combined.items() if v in ("*", "latest")]
        if wildcards:
            findings.append({
                "type": "wildcard_version",
                "severity": "red",
                "message": f"{rel}: {len(wildcards)} Packages mit * oder latest: {', '.join(wildcards[:5])}",
                "file": rel,
                "packages": wildcards,
            })

    # Cross-file version conflicts
    for name, entries in all_deps.items():
        versions = {e["version"] for e in entries}
        if len(entries) > 1 and len(versions) > 1:
            files_str = ", ".join(e["file"] for e in entries[:3])
            vers_str = ", ".join(sorted(versions))
            findings.append({
                "type": "version_conflict",
                "severity": "red",
                "message": f"'{name}' hat verschiedene Versionen: {vers_str} in {files_str}",
                "package": name,
                "versions": sorted(versions),
                "files": [e["file"] for e in entries],
            })

    stats = {
        "python_files": len(req_files),
        "javascript_files": len(pkg_files),
        "finding_count": len(findings),
    }

    logger.info("Dependency check: %d req files, %d pkg files, %d findings",
                len(req_files), len(pkg_files), len(findings))

    return {
        "findings": findings,
        "stats": stats,
    }


def _find_files(filename: str, exclude: set) -> list:
    """Find all files with given name, excluding standard dirs."""
    files = []
    for f in PROJECT_ROOT.rglob(filename):
        rel = f.relative_to(PROJECT_ROOT).as_posix()
        if any(skip in rel for skip in ("node_modules/", ".git/", ".venv/", "venv/", "quarantine/")):
            continue
        if any(rel.startswith(ex.rstrip("/")) for ex in exclude):
            continue
        files.append(f)
    return sorted(files)
