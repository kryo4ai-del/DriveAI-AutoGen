"""Stufe 2: Abhaengigkeits-Graph Builder.

Baut den kompletten Import/Abhaengigkeits-Graphen der Factory.
Python: ast-basiertes Import-Parsing.
JavaScript: require/import-Parsing.
Rein deterministisch, kein LLM.
"""

import ast
import logging
import os
import re
import time
from collections import Counter
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[3]


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


def _is_project_file(rel_path: str, config: dict) -> bool:
    """Check if a file belongs to a project and should be skipped."""
    excl = config.get("project_exclusions", {})
    for out_dir in excl.get("output_dirs", []):
        if rel_path.startswith(out_dir):
            return True
    for skip_dir in excl.get("additional_skip_dirs", []):
        if rel_path.startswith(skip_dir):
            return True
    slug_source = excl.get("slug_source", "factory/projects/")
    if rel_path.startswith(slug_source):
        return True
    return False


def build_dependency_graph(config: dict) -> dict:
    """Build complete import/dependency graph.

    Returns graph with nodes, edges, and stats.
    """
    start = time.time()
    exclude = set(config.get("exclude_paths", []))
    scan_paths = config.get("scan_paths", {})

    nodes = {}
    edges = []

    # Collect all files (project files excluded)
    py_files = _collect_files(scan_paths.get("python", []), [".py"], exclude, config)
    js_files = _collect_files(scan_paths.get("javascript", []), [".js", ".jsx", ".ts", ".tsx"], exclude, config)

    # Parse Python files
    for fpath in py_files:
        rel = fpath.relative_to(PROJECT_ROOT).as_posix()
        imports = _parse_python_imports(fpath)
        functions, classes = _parse_python_definitions(fpath)

        # Check if entry point
        try:
            content = fpath.read_text(encoding="utf-8", errors="ignore")
            is_entry = 'if __name__' in content or 'argparse' in content
        except Exception:
            is_entry = False
            content = ""

        lines = content.count("\n") if content else 0

        nodes[rel] = {
            "type": "python",
            "lines": lines,
            "imports": imports,
            "imported_by": [],
            "functions": functions,
            "classes": classes,
            "is_entry_point": is_entry,
        }

    # Parse JavaScript files
    for fpath in js_files:
        rel = fpath.relative_to(PROJECT_ROOT).as_posix()
        imports = _parse_js_imports(fpath)
        try:
            content = fpath.read_text(encoding="utf-8", errors="ignore")
            lines = content.count("\n")
            is_entry = "module.exports" in content or "export default" in content
        except Exception:
            lines = 0
            is_entry = False

        nodes[rel] = {
            "type": "javascript",
            "lines": lines,
            "imports": imports,
            "imported_by": [],
            "functions": [],
            "classes": [],
            "is_entry_point": is_entry,
        }

    # Build edges: resolve imports to actual files
    module_map = _build_module_map(nodes)

    for src_path, node in nodes.items():
        for imp in node["imports"]:
            resolved = _resolve_import(imp, src_path, module_map, node["type"])
            if resolved and resolved in nodes:
                edges.append({"from": src_path, "to": resolved, "type": "import"})
                nodes[resolved]["imported_by"].append(src_path)

    # Compute stats
    orphans = [p for p, n in nodes.items()
               if not n["imports"] and not n["imported_by"]
               and not n["is_entry_point"]
               and not p.endswith("__init__.py")]

    circular = _find_circular_deps(edges)
    max_depth = _compute_max_depth(nodes, edges)

    # Most imported
    import_counts = Counter()
    for e in edges:
        import_counts[e["to"]] += 1
    most_imported = import_counts.most_common(1)

    # Add counts to nodes
    for path, node in nodes.items():
        node["import_count"] = len(node["imports"])
        node["imported_by_count"] = len(node["imported_by"])

    duration = time.time() - start

    result = {
        "timestamp": nodes and list(nodes.keys())[0] or "",
        "duration_sec": round(duration, 2),
        "nodes": nodes,
        "edges": edges,
        "stats": {
            "total_nodes": len(nodes),
            "total_edges": len(edges),
            "orphan_nodes": len(orphans),
            "orphan_list": orphans[:20],
            "circular_dependencies": len(circular),
            "circular_list": circular[:10],
            "max_depth": max_depth,
            "most_imported": f"{most_imported[0][0]} ({most_imported[0][1]} imports)" if most_imported else "none",
        },
    }

    logger.info("Graph built: %d nodes, %d edges, %d orphans in %.1fs",
                len(nodes), len(edges), len(orphans), duration)
    return result


def _collect_files(dirs: list, extensions: list, exclude: set, config: dict = None) -> list:
    """Collect files with given extensions from directories."""
    files = []
    seen = set()
    for rel_dir in dirs:
        abs_dir = PROJECT_ROOT / rel_dir
        if not abs_dir.exists():
            continue
        for root, dirnames, fnames in os.walk(abs_dir):
            rel_root = Path(root).relative_to(PROJECT_ROOT).as_posix() + "/"
            exclude_dir_names = {ex.rstrip("/") for ex in exclude}
            dirnames[:] = [d for d in dirnames if d not in exclude_dir_names and not any(
                (rel_root + d + "/").startswith(ex) for ex in exclude
            )]
            for fname in fnames:
                if any(fname.endswith(ext) for ext in extensions):
                    fpath = Path(root) / fname
                    key = str(fpath.resolve())
                    if key not in seen:
                        # Skip project output files
                        if config:
                            rel = fpath.relative_to(PROJECT_ROOT).as_posix()
                            if _is_project_file(rel, config):
                                continue
                        seen.add(key)
                        files.append(fpath)
    return files


def _parse_python_imports(filepath: Path) -> list:
    """Parse Python imports using AST."""
    try:
        content = filepath.read_text(encoding="utf-8", errors="ignore")
        tree = ast.parse(content)
    except (SyntaxError, ValueError):
        return []

    imports = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imports.append(alias.name)
        elif isinstance(node, ast.ImportFrom):
            if node.module:
                imports.append(node.module)
    return imports


def _parse_python_definitions(filepath: Path) -> tuple:
    """Parse function and class definitions."""
    try:
        content = filepath.read_text(encoding="utf-8", errors="ignore")
        tree = ast.parse(content)
    except (SyntaxError, ValueError):
        return [], []

    functions = []
    classes = []
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef) or isinstance(node, ast.AsyncFunctionDef):
            if not node.name.startswith("_"):
                functions.append(node.name)
        elif isinstance(node, ast.ClassDef):
            classes.append(node.name)
    return functions[:20], classes[:10]


def _parse_js_imports(filepath: Path) -> list:
    """Parse JavaScript/TypeScript imports."""
    try:
        content = filepath.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return []

    imports = []
    # require("...")
    imports.extend(re.findall(r'require\(["\'](.+?)["\']\)', content))
    # import ... from "..."
    imports.extend(re.findall(r'from\s+["\'](.+?)["\']', content))
    return imports


def _build_module_map(nodes: dict) -> dict:
    """Build mapping from module names to file paths."""
    module_map = {}
    for path in nodes:
        if path.endswith(".py"):
            # factory/hq/janitor/scanner.py -> factory.hq.janitor.scanner
            module = path.replace("/", ".").replace("\\", ".").removesuffix(".py")
            module_map[module] = path
            # Also without __init__
            if path.endswith("/__init__.py"):
                pkg = module.removesuffix(".__init__")
                module_map[pkg] = path
    return module_map


def _resolve_import(imp: str, src_path: str, module_map: dict, file_type: str) -> str:
    """Resolve an import string to a file path in our graph."""
    if file_type == "python":
        # Direct match
        if imp in module_map:
            return module_map[imp]
        # Try parent prefixes
        parts = imp.split(".")
        for i in range(len(parts), 0, -1):
            prefix = ".".join(parts[:i])
            if prefix in module_map:
                return module_map[prefix]
    elif file_type == "javascript":
        # Relative imports
        if imp.startswith("."):
            src_dir = str(Path(src_path).parent)
            resolved = os.path.normpath(os.path.join(src_dir, imp)).replace("\\", "/")
            # Try with extensions
            for ext in ("", ".js", ".jsx", ".ts", ".tsx", "/index.js", "/index.jsx"):
                candidate = resolved + ext
                if candidate in module_map or candidate in {p for p in module_map}:
                    return candidate
    return ""


def _find_circular_deps(edges: list) -> list:
    """Find circular dependencies using DFS."""
    adj = {}
    for e in edges:
        adj.setdefault(e["from"], []).append(e["to"])

    circular = []
    visited = set()
    path_set = set()
    path_list = []

    def dfs(node):
        if node in path_set:
            # Found cycle
            idx = path_list.index(node)
            cycle = path_list[idx:] + [node]
            circular.append(" -> ".join(cycle))
            return
        if node in visited:
            return
        visited.add(node)
        path_set.add(node)
        path_list.append(node)
        for neighbor in adj.get(node, []):
            if len(circular) < 10:  # Limit
                dfs(neighbor)
        path_set.discard(node)
        path_list.pop()

    for node in adj:
        if len(circular) < 10:
            dfs(node)

    return circular


def _compute_max_depth(nodes: dict, edges: list) -> int:
    """Compute maximum import chain depth."""
    adj = {}
    for e in edges:
        adj.setdefault(e["from"], []).append(e["to"])

    max_d = 0
    cache = {}

    def depth(node, seen=None):
        if seen is None:
            seen = set()
        if node in cache:
            return cache[node]
        if node in seen:
            return 0
        seen.add(node)
        d = 0
        for neighbor in adj.get(node, []):
            d = max(d, 1 + depth(neighbor, seen))
            if d > 20:  # Safety limit
                break
        cache[node] = d
        return d

    for node in adj:
        max_d = max(max_d, depth(node))
        if max_d > 20:
            break

    return max_d
