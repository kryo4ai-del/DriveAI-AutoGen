"""Parse xcodebuild output into structured errors."""
import re
import os
from dataclasses import dataclass, field


@dataclass
class XcodeError:
    file: str = ""
    line: int = 0
    column: int = 0
    severity: str = "error"
    message: str = ""
    error_code: str = "unknown"
    context: str = ""


class XcodeErrorParser:
    """Parse real xcodebuild stderr/stdout into structured XcodeError list."""

    _ERROR_RE = re.compile(
        r"(.+\.swift):(\d+):(\d+):\s+(error|warning):\s+(.+)"
    )

    _CLASSIFICATION = [
        ("cannot find type", "missing_type"),
        ("cannot find", "missing_identifier"),
        ("use of undeclared type", "missing_type"),
        ("no such module", "missing_import"),
        ("expected declaration", "top_level_code"),
        ("expressions are not allowed at the top level", "top_level_code"),
        ("redeclaration of", "duplicate_declaration"),
        ("invalid redeclaration", "duplicate_declaration"),
        ("is ambiguous", "ambiguous_reference"),
        ("raw type cannot have cases with arguments", "invalid_enum"),
        ("expected", "syntax_error"),
    ]

    def parse(self, output: str) -> list[XcodeError]:
        errors = []
        for line in output.splitlines():
            m = self._ERROR_RE.match(line.strip())
            if m:
                filepath, line_no, col, severity, message = m.groups()
                errors.append(XcodeError(
                    file=filepath,
                    line=int(line_no),
                    column=int(col),
                    severity=severity,
                    message=message,
                    error_code=self._classify(message),
                ))
        return errors

    def _classify(self, message: str) -> str:
        msg = message.lower()
        for pattern, code in self._CLASSIFICATION:
            if pattern in msg:
                return code
        return "unknown"

    def group_by_file(self, errors: list[XcodeError]) -> dict[str, list[XcodeError]]:
        grouped: dict[str, list[XcodeError]] = {}
        for e in errors:
            grouped.setdefault(e.file, []).append(e)
        return grouped

    def get_error_summary(self, errors: list[XcodeError]) -> dict:
        by_type: dict[str, int] = {}
        by_file: dict[str, int] = {}
        for e in errors:
            if e.severity == "error":
                by_type[e.error_code] = by_type.get(e.error_code, 0) + 1
                by_file[e.file] = by_file.get(e.file, 0) + 1
        return {
            "total_errors": sum(1 for e in errors if e.severity == "error"),
            "total_warnings": sum(1 for e in errors if e.severity == "warning"),
            "by_type": dict(sorted(by_type.items(), key=lambda x: -x[1])),
            "worst_files": dict(sorted(by_file.items(), key=lambda x: -x[1])[:10]),
        }
