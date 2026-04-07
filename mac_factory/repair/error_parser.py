"""Parsed echte xcodebuild Output in strukturierte Errors."""
import re
from dataclasses import dataclass


@dataclass
class XcodeError:
    file: str
    line: int
    column: int
    severity: str
    message: str

    @property
    def error_type(self) -> str:
        msg = self.message.lower()
        if "cannot find type" in msg or "use of undeclared type" in msg:
            return "missing_type"
        elif "cannot find" in msg:
            return "missing_identifier"
        elif "expected declaration" in msg or "expected expression" in msg:
            return "syntax_error"
        elif "no such module" in msg:
            return "missing_import"
        elif "redeclaration" in msg or "duplicate" in msg:
            return "duplicate"
        elif "top-level" in msg or "top level" in msg:
            return "top_level_code"
        return "other"


class XcodeErrorParser:
    def parse(self, output: str) -> list:
        errors = []
        for line in output.split("\n"):
            m = re.match(r'(.+\.swift):(\d+):(\d+):\s+(error|warning):\s+(.+)', line)
            if m:
                errors.append(XcodeError(
                    file=m.group(1),
                    line=int(m.group(2)),
                    column=int(m.group(3)),
                    severity=m.group(4),
                    message=m.group(5),
                ))
        return errors

    def group_by_file(self, errors: list) -> dict:
        grouped = {}
        for e in errors:
            if e.severity == "error":
                grouped.setdefault(e.file, []).append(e)
        return grouped

    def summary(self, errors: list) -> dict:
        error_count = sum(1 for e in errors if e.severity == "error")
        by_type = {}
        for e in errors:
            if e.severity == "error":
                by_type[e.error_type] = by_type.get(e.error_type, 0) + 1
        return {"total": error_count, "by_type": by_type}
