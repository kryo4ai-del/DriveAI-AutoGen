"""
Import Hygiene Safeguard — deterministic, no LLM.

Scans Swift files for known Foundation symbols and adds
`import Foundation` when missing and not covered by SwiftUI.
"""

import os
import re
from pathlib import Path

FOUNDATION_SYMBOLS = {
    # Types
    "Date", "Data", "URL", "UUID", "TimeInterval",
    "Calendar", "DateFormatter", "DateComponents",
    "JSONEncoder", "JSONDecoder",
    "UserDefaults", "FileManager", "Bundle",
    "NotificationCenter", "Timer", "RunLoop",
    "NSObject", "NSError", "NSCoder",
    "Locale", "TimeZone", "IndexSet", "CharacterSet",
    "NumberFormatter", "MeasurementFormatter",
    "ProcessInfo", "OperationQueue",
    # Protocols
    "LocalizedError", "CustomNSError",
    "NSCoding", "NSSecureCoding",
    # Dispatch (Foundation re-exports)
    "DispatchQueue",
}

# Imports that re-export Foundation
FOUNDATION_COVERING_IMPORTS = {
    "import Foundation",
    "import SwiftUI",
    "import UIKit",
    "import AppKit",
    "import CoreData",
    "import MapKit",
}

# Match word boundaries for symbol usage
SYMBOL_PATTERN = re.compile(
    r'\b(' + '|'.join(re.escape(s) for s in FOUNDATION_SYMBOLS) + r')\b'
)


class ImportHygiene:
    def __init__(self, project_name: str = "askfin_v1-1"):
        self.project_root = Path(__file__).resolve().parent.parent.parent / "projects" / project_name
        self.fixed_files = []
        self.skipped_files = []
        self.already_covered = []

    def _has_foundation_coverage(self, content: str) -> bool:
        for line in content.splitlines():
            stripped = line.strip()
            if stripped in FOUNDATION_COVERING_IMPORTS:
                return True
        return False

    def _uses_foundation_symbols(self, content: str) -> set:
        # Skip comments and strings (simple heuristic: skip lines starting with //)
        used = set()
        for line in content.splitlines():
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            matches = SYMBOL_PATTERN.findall(line)
            used.update(matches)
        return used

    def _insert_import(self, content: str) -> str:
        lines = content.splitlines()
        # Find last import line
        last_import_idx = -1
        for i, line in enumerate(lines):
            if line.strip().startswith("import "):
                last_import_idx = i

        if last_import_idx >= 0:
            lines.insert(last_import_idx + 1, "import Foundation")
        else:
            # No imports at all — add at top
            lines.insert(0, "import Foundation")

        return "\n".join(lines) + ("\n" if content.endswith("\n") else "")

    def scan(self) -> list:
        """Scan and return list of files needing import Foundation."""
        needs_fix = []
        for swift_file in sorted(self.project_root.rglob("*.swift")):
            rel = swift_file.relative_to(self.project_root)
            if "quarantine" in str(rel) or "generated" in str(rel):
                continue

            content = swift_file.read_text(encoding="utf-8", errors="replace")

            if self._has_foundation_coverage(content):
                self.already_covered.append(str(rel))
                continue

            used = self._uses_foundation_symbols(content)
            if used:
                needs_fix.append({"file": str(rel), "symbols": sorted(used)})

        return needs_fix

    def fix(self) -> dict:
        """Scan and fix all files needing import Foundation."""
        needs_fix = self.scan()

        for entry in needs_fix:
            filepath = self.project_root / entry["file"]
            content = filepath.read_text(encoding="utf-8", errors="replace")
            new_content = self._insert_import(content)
            filepath.write_text(new_content, encoding="utf-8")
            self.fixed_files.append(entry)

        return {
            "fixed": len(self.fixed_files),
            "already_covered": len(self.already_covered),
            "files": self.fixed_files,
        }


if __name__ == "__main__":
    h = ImportHygiene()
    result = h.fix()
    print(f"Fixed {result['fixed']} files, {result['already_covered']} already covered.")
    for f in result["files"]:
        print(f"  {f['file']}: {', '.join(f['symbols'])}")
