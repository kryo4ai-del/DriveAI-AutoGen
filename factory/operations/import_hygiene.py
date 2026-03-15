"""
Import Hygiene Safeguard — deterministic, no LLM.

Scans Swift files for known Foundation and Combine symbols and adds
the appropriate import when missing and not covered by SwiftUI.
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

COMBINE_SYMBOLS = {
    "ObservableObject", "Published", "AnyCancellable",
    "PassthroughSubject", "CurrentValueSubject",
    "AnyPublisher", "Just", "Future",
    "Cancellable", "Subscriber", "Subscription",
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

# Imports that re-export Combine
COMBINE_COVERING_IMPORTS = {
    "import Combine",
    "import SwiftUI",
}

# Match word boundaries for symbol usage
FOUNDATION_PATTERN = re.compile(
    r'\b(' + '|'.join(re.escape(s) for s in FOUNDATION_SYMBOLS) + r')\b'
)

COMBINE_PATTERN = re.compile(
    r'(?:\b|@)(' + '|'.join(re.escape(s) for s in COMBINE_SYMBOLS) + r')\b'
)


class ImportHygiene:
    def __init__(self, project_name: str = "askfin_v1-1"):
        self.project_root = Path(__file__).resolve().parent.parent.parent / "projects" / project_name
        self.fixed_files = []
        self.skipped_files = []
        self.already_covered = []

    def _has_coverage(self, content: str, covering_imports: set) -> bool:
        for line in content.splitlines():
            stripped = line.strip()
            if stripped in covering_imports:
                return True
        return False

    def _find_symbols(self, content: str, pattern: re.Pattern) -> set:
        used = set()
        for line in content.splitlines():
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            matches = pattern.findall(line)
            used.update(matches)
        return used

    def _insert_import(self, content: str, import_statement: str) -> str:
        lines = content.splitlines()
        # Find last import line
        last_import_idx = -1
        for i, line in enumerate(lines):
            if line.strip().startswith("import "):
                last_import_idx = i

        if last_import_idx >= 0:
            lines.insert(last_import_idx + 1, import_statement)
        else:
            lines.insert(0, import_statement)

        return "\n".join(lines) + ("\n" if content.endswith("\n") else "")

    def scan(self) -> list:
        """Scan and return list of files needing imports."""
        needs_fix = []
        for swift_file in sorted(self.project_root.rglob("*.swift")):
            rel = swift_file.relative_to(self.project_root)
            if "quarantine" in str(rel) or "generated" in str(rel):
                continue

            content = swift_file.read_text(encoding="utf-8", errors="replace")

            missing_imports = []

            # Check Foundation
            if not self._has_coverage(content, FOUNDATION_COVERING_IMPORTS):
                found = self._find_symbols(content, FOUNDATION_PATTERN)
                if found:
                    missing_imports.append({"import": "import Foundation", "symbols": sorted(found)})

            # Check Combine
            if not self._has_coverage(content, COMBINE_COVERING_IMPORTS):
                found = self._find_symbols(content, COMBINE_PATTERN)
                if found:
                    missing_imports.append({"import": "import Combine", "symbols": sorted(found)})

            if missing_imports:
                needs_fix.append({"file": str(rel), "missing": missing_imports})

        return needs_fix

    def fix(self) -> dict:
        """Scan and fix all files needing imports."""
        needs_fix = self.scan()

        for entry in needs_fix:
            filepath = self.project_root / entry["file"]
            content = filepath.read_text(encoding="utf-8", errors="replace")

            for missing in entry["missing"]:
                content = self._insert_import(content, missing["import"])

            filepath.write_text(content, encoding="utf-8")
            self.fixed_files.append(entry)

        return {
            "fixed": len(self.fixed_files),
            "files": self.fixed_files,
        }


if __name__ == "__main__":
    h = ImportHygiene()
    result = h.fix()
    print(f"Fixed {result['fixed']} files.")
    for f in result["files"]:
        for m in f["missing"]:
            print(f"  {f['file']}: {m['import']} ({', '.join(m['symbols'])})")
