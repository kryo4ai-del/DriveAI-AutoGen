"""Fix missing type references by creating stub files or adding imports."""

import os
import re
from pathlib import Path
from factory.assembly.repair.error_parser import CompilerError
from factory.assembly.repair.fix_strategies.base_strategy import BaseFixStrategy


class MissingTypeFixer(BaseFixStrategy):
    """Fix missing types by creating stubs in a central stubs.ts file."""

    _collected_stubs: set = set()  # Class-level collection across errors

    def can_fix(self, error: CompilerError) -> bool:
        if error.language != "typescript":
            return False
        return error.category in ("missing_type", "missing_import") and "Cannot find name" in error.message

    def apply(self, error: CompilerError, project_dir: str = "", **ctx) -> bool:
        m = re.search(r"Cannot find name '(\w+)'", error.message)
        if not m or not project_dir:
            return False

        symbol = m.group(1)

        # Skip lowercase (likely variable, not type)
        if symbol[0].islower():
            return False

        # Skip known globals
        if symbol in ("React", "JSX", "Promise", "Array", "Map", "Set", "Error",
                       "Date", "JSON", "Math", "Object", "Number", "String", "Boolean",
                       "console", "window", "document", "localStorage", "setTimeout",
                       "clearTimeout", "setInterval", "clearInterval", "fetch"):
            return False

        # Check if symbol already exists somewhere in the project
        src_dir = os.path.join(project_dir, "src")
        for root, _, files in os.walk(src_dir):
            for fname in files:
                if not fname.endswith((".ts", ".tsx")):
                    continue
                fpath = os.path.join(root, fname)
                try:
                    content = Path(fpath).read_text(encoding="utf-8", errors="ignore")
                    if re.search(rf"export\s+(?:interface|type|class|enum|const|function)\s+{re.escape(symbol)}\b", content):
                        return False  # Exists — MissingImportFixer should handle it
                except Exception:
                    continue

        # Create or append to stubs.ts
        stubs_dir = os.path.join(project_dir, "src", "types")
        os.makedirs(stubs_dir, exist_ok=True)
        stubs_path = os.path.join(stubs_dir, "stubs.ts")

        existing = ""
        if os.path.isfile(stubs_path):
            existing = Path(stubs_path).read_text(encoding="utf-8")

        # Check if already stubbed
        if f"export interface {symbol}" in existing or f"export type {symbol}" in existing:
            # Stub exists, just need import in the error file
            return self._add_stub_import(error, symbol, project_dir)

        # Add stub
        stub = f"\nexport interface {symbol} {{\n  [key: string]: any;\n}}\n"
        Path(stubs_path).write_text(existing + stub, encoding="utf-8")

        # Add import in the error file
        return self._add_stub_import(error, symbol, project_dir)

    def _add_stub_import(self, error: CompilerError, symbol: str, project_dir: str) -> bool:
        abs_path = os.path.join(project_dir, error.file_path) if project_dir else error.file_path
        if not os.path.isfile(abs_path):
            return False

        try:
            content = Path(abs_path).read_text(encoding="utf-8")
        except Exception:
            return False

        # Already imported?
        if f"import" in content and symbol in content and "stubs" in content:
            return False

        # Build relative import path to stubs.ts
        from_dir = os.path.dirname(abs_path)
        stubs_file = os.path.join(project_dir, "src", "types", "stubs.ts")
        rel = os.path.relpath(stubs_file, from_dir).replace("\\", "/").replace(".ts", "")
        if not rel.startswith("."):
            rel = "./" + rel

        import_line = f"import {{ {symbol} }} from '{rel}';"

        lines = content.splitlines()
        # Find insert point (after last import or 'use client')
        insert_idx = 0
        for i, line in enumerate(lines):
            if line.strip().startswith("import "):
                insert_idx = i + 1
            elif "'use client'" in line or '"use client"' in line:
                insert_idx = i + 1

        lines.insert(insert_idx, import_line)
        Path(abs_path).write_text("\n".join(lines), encoding="utf-8")
        return True
