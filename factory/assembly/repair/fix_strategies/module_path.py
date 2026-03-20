"""Fix incorrect import/module paths, including @/ alias resolution."""

import json
import os
import re
from pathlib import Path
from factory.assembly.repair.error_parser import CompilerError
from factory.assembly.repair.fix_strategies.base_strategy import BaseFixStrategy


class ModulePathFixer(BaseFixStrategy):
    """Fix module path issues including @/ alias resolution."""

    def can_fix(self, error: CompilerError) -> bool:
        if error.language != "typescript":
            return False
        return error.category == "module_path" and "Cannot find module" in error.message

    def apply(self, error: CompilerError, project_dir: str = "", **ctx) -> bool:
        if not project_dir:
            return False

        # First, ensure tsconfig has @/* path mapping
        tsconfig_path = os.path.join(project_dir, "tsconfig.json")
        if os.path.isfile(tsconfig_path):
            self._ensure_path_alias(tsconfig_path)

        # Extract the wrong module path
        m = re.search(r"Cannot find module '([^']+)'", error.message)
        if not m:
            return False
        wrong_path = m.group(1)

        # If it's a @/ path, convert to relative
        if wrong_path.startswith("@/"):
            return self._fix_at_alias(error, wrong_path, project_dir)

        # If it's a relative path, search for the correct file
        return self._fix_relative_path(error, wrong_path, project_dir)

    def _ensure_path_alias(self, tsconfig_path: str):
        """Ensure tsconfig.json has baseUrl and @/* path mapping."""
        try:
            tc = json.loads(Path(tsconfig_path).read_text(encoding="utf-8"))
            opts = tc.get("compilerOptions", {})
            changed = False
            if "baseUrl" not in opts:
                opts["baseUrl"] = "."
                changed = True
            if "paths" not in opts:
                opts["paths"] = {"@/*": ["./src/*"]}
                changed = True
            elif "@/*" not in opts.get("paths", {}):
                opts["paths"]["@/*"] = ["./src/*"]
                changed = True
            if changed:
                tc["compilerOptions"] = opts
                Path(tsconfig_path).write_text(json.dumps(tc, indent=2), encoding="utf-8")
        except Exception:
            pass

    def _fix_at_alias(self, error: CompilerError, wrong_path: str, project_dir: str) -> bool:
        """Convert @/path/module to relative path if the file exists."""
        # @/types/question -> src/types/question.ts or .tsx
        rel_from_src = wrong_path.replace("@/", "")

        for ext in ("", ".ts", ".tsx", "/index.ts", "/index.tsx"):
            candidate = os.path.join(project_dir, "src", rel_from_src + ext)
            if os.path.isfile(candidate):
                return False  # File exists, tsconfig paths should resolve it now

        # File doesn't exist — search for it
        module_name = wrong_path.split("/")[-1]
        for root, _, files in os.walk(os.path.join(project_dir, "src")):
            for fname in files:
                stem = Path(fname).stem
                if stem.lower() == module_name.lower():
                    # Found it — update the import
                    abs_error = os.path.join(project_dir, error.file_path)
                    found = os.path.join(root, fname)
                    from_dir = os.path.dirname(abs_error)
                    rel = os.path.relpath(found, from_dir).replace("\\", "/")
                    for e in (".tsx", ".ts"):
                        if rel.endswith(e):
                            rel = rel[:-len(e)]
                    if not rel.startswith("."):
                        rel = "./" + rel

                    try:
                        content = Path(abs_error).read_text(encoding="utf-8")
                        new_content = content.replace(f"'{wrong_path}'", f"'{rel}'")
                        new_content = new_content.replace(f'"{wrong_path}"', f'"{rel}"')
                        if new_content != content:
                            Path(abs_error).write_text(new_content, encoding="utf-8")
                            return True
                    except Exception:
                        pass
        return False

    def _fix_relative_path(self, error: CompilerError, wrong_path: str, project_dir: str) -> bool:
        """Search for the correct file when a relative import is wrong."""
        module_name = wrong_path.split("/")[-1]
        abs_error = os.path.join(project_dir, error.file_path)

        for root, _, files in os.walk(os.path.join(project_dir, "src")):
            if "node_modules" in root:
                continue
            for fname in files:
                stem = Path(fname).stem
                if stem == module_name:
                    found = os.path.join(root, fname)
                    from_dir = os.path.dirname(abs_error)
                    rel = os.path.relpath(found, from_dir).replace("\\", "/")
                    for ext in (".tsx", ".ts"):
                        if rel.endswith(ext):
                            rel = rel[:-len(ext)]
                    if not rel.startswith("."):
                        rel = "./" + rel

                    try:
                        content = Path(abs_error).read_text(encoding="utf-8")
                        new_content = content.replace(f"'{wrong_path}'", f"'{rel}'")
                        new_content = new_content.replace(f'"{wrong_path}"', f'"{rel}"')
                        if new_content != content:
                            Path(abs_error).write_text(new_content, encoding="utf-8")
                            return True
                    except Exception:
                        pass
        return False
