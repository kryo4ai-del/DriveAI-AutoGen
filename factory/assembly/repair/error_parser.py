"""Parse compiler output from any language into structured errors."""

import re
from dataclasses import dataclass


@dataclass
class CompilerError:
    """Structured representation of a compiler error."""
    file_path: str = ""
    line_number: int = 0
    column: int = 0
    error_code: str = ""
    message: str = ""
    severity: str = "error"
    language: str = ""
    category: str = "unknown"
    raw_line: str = ""


# ── TypeScript ───────────────────────────────────────────────────────────

_TS_ERROR_RE = re.compile(
    r"^(.+?)\((\d+),(\d+)\):\s+(error|warning)\s+(TS\d+):\s+(.+)$"
)

_TS_CATEGORY_MAP = {
    "TS2304": "missing_import",       # Cannot find name
    "TS2305": "missing_import",       # Module has no exported member
    "TS2307": "module_path",          # Cannot find module
    "TS7006": "type_annotation",      # Implicit any
    "TS2300": "duplicate_type",       # Duplicate identifier
    "TS2339": "missing_type",         # Property does not exist
    "TS2353": "missing_type",         # Object literal may only specify known properties
    "TS1005": "syntax",               # Expected token
    "TS1128": "syntax",               # Declaration expected
    "TS1149": "syntax",               # File is a CommonJS module
    "TS2322": "type_mismatch",        # Type not assignable
    "TS2345": "type_mismatch",        # Argument type mismatch
    "TS2694": "missing_type",         # Namespace has no exported member
    "TS18048": "null_check",          # Value is possibly undefined
}

# ── Kotlin ───────────────────────────────────────────────────────────────

_KT_ERROR_RE = re.compile(
    r"^e:\s+(?:file:///?)?((?:[A-Za-z]:)?[^\s:]+\.kt):(\d+):(\d+)\s+(.+)$"
)

_KT_CATEGORY_KEYWORDS = {
    "Unresolved reference": "missing_import",
    "Unresolved supertypes": "missing_type",
    "Type mismatch": "type_mismatch",
    "Overload resolution ambiguity": "complex",
    "Conflicting declarations": "duplicate_type",
}

# ── Swift ────────────────────────────────────────────────────────────────

_SWIFT_ERROR_RE = re.compile(
    r"^(.+?):(\d+):(\d+):\s+(error|warning|note):\s+(.+)$"
)

_SWIFT_CATEGORY_KEYWORDS = {
    "cannot find type": "missing_type",
    "cannot find": "missing_import",
    "ambiguous": "duplicate_type",
    "has no member": "missing_type",
    "missing return": "syntax",
}


class ErrorParser:
    """Parse compiler output from any language into structured errors."""

    def parse(self, compiler_output: str, language: str) -> list[CompilerError]:
        if language == "typescript":
            return self.parse_typescript(compiler_output)
        elif language == "kotlin":
            return self.parse_kotlin(compiler_output)
        elif language == "swift":
            return self.parse_swift(compiler_output)
        return []

    def parse_typescript(self, output: str) -> list[CompilerError]:
        errors = []
        for line in output.splitlines():
            m = _TS_ERROR_RE.match(line.strip())
            if m:
                code = m.group(5)
                errors.append(CompilerError(
                    file_path=m.group(1).replace("\\", "/"),
                    line_number=int(m.group(2)),
                    column=int(m.group(3)),
                    error_code=code,
                    message=m.group(6),
                    severity=m.group(4),
                    language="typescript",
                    category=_TS_CATEGORY_MAP.get(code, "unknown"),
                    raw_line=line.strip(),
                ))
        return errors

    def parse_kotlin(self, output: str) -> list[CompilerError]:
        errors = []
        for line in output.splitlines():
            m = _KT_ERROR_RE.match(line.strip())
            if m:
                msg = m.group(4)
                cat = "unknown"
                for keyword, category in _KT_CATEGORY_KEYWORDS.items():
                    if keyword in msg:
                        cat = category
                        break
                errors.append(CompilerError(
                    file_path=m.group(1).replace("\\", "/"),
                    line_number=int(m.group(2)),
                    column=int(m.group(3)),
                    message=msg,
                    severity="error",
                    language="kotlin",
                    category=cat,
                    raw_line=line.strip(),
                ))
        return errors

    def parse_swift(self, output: str) -> list[CompilerError]:
        errors = []
        for line in output.splitlines():
            m = _SWIFT_ERROR_RE.match(line.strip())
            if m and m.group(4) in ("error", "warning"):
                msg = m.group(5)
                cat = "unknown"
                for keyword, category in _SWIFT_CATEGORY_KEYWORDS.items():
                    if keyword in msg.lower():
                        cat = category
                        break
                errors.append(CompilerError(
                    file_path=m.group(1).replace("\\", "/"),
                    line_number=int(m.group(2)),
                    column=int(m.group(3)),
                    message=msg,
                    severity=m.group(4),
                    language="swift",
                    category=cat,
                    raw_line=line.strip(),
                ))
        return errors
