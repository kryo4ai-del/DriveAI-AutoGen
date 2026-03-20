"""Fix implicit-any by adding explicit type annotations."""

import os
import re
from pathlib import Path
from factory.assembly.repair.error_parser import CompilerError
from factory.assembly.repair.fix_strategies.base_strategy import BaseFixStrategy


class TypeAnnotationFixer(BaseFixStrategy):
    def can_fix(self, error: CompilerError) -> bool:
        return error.category == "type_annotation" and error.language == "typescript"

    def apply(self, error: CompilerError, project_dir: str = "", **ctx) -> bool:
        # Build absolute path from project_dir + error.file_path
        if project_dir and error.file_path:
            abs_path = os.path.join(project_dir, error.file_path)
        elif error.file_path:
            abs_path = error.file_path
        else:
            return False

        if not os.path.isfile(abs_path):
            return False

        try:
            content = Path(abs_path).read_text(encoding="utf-8")
        except Exception:
            return False

        lines = content.splitlines()
        if error.line_number < 1 or error.line_number > len(lines):
            return False

        line = lines[error.line_number - 1]

        # Extract parameter name: "Parameter 'x' implicitly has an 'any' type"
        m = re.search(r"Parameter '(\w+)' implicitly has an 'any' type", error.message)
        if not m:
            return False
        param = m.group(1)

        # Add : any after the parameter name (but not if it already has a type)
        # Handles: (param) (param, other) (param = default)
        # Also handles arrow: (param) =>
        pattern = rf"\b{re.escape(param)}\b(?!\s*[:,)]|\s*=\s*>)"

        # More precise: find the param and check if followed by :
        # Use column info if available
        idx = line.find(param)
        if idx >= 0:
            after_param = line[idx + len(param):]
            # Already has type annotation?
            if after_param.lstrip().startswith(":"):
                return False
            # Add : any
            new_line = line[:idx + len(param)] + ": any" + line[idx + len(param):]
            lines[error.line_number - 1] = new_line
            Path(abs_path).write_text("\n".join(lines), encoding="utf-8")
            return True

        return False
