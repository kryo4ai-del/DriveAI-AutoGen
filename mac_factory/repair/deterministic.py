"""Tier 1: Kostenlose deterministische Fixes."""
import os
import re
import shutil


class DeterministicFixer:
    def __init__(self, project_dir: str):
        self.project_dir = project_dir
        self.fixes_applied = 0

    def fix_all(self, errors: list) -> int:
        """Wende alle deterministischen Fixes an. Returns Anzahl Fixes."""
        self.fixes_applied = 0

        grouped = {}
        for e in errors:
            if e.severity == "error":
                grouped.setdefault(e.file, []).append(e)

        for filepath, file_errors in grouped.items():
            if not os.path.exists(filepath):
                continue

            # Quarantine check
            if self._should_quarantine(filepath, file_errors):
                self._quarantine(filepath)
                continue

            content = open(filepath, encoding="utf-8").read()
            original = content

            content = self._fix_imports(content, file_errors)
            content = self._fix_pseudocode(content)
            content = self._fix_enum_syntax(content)

            if content != original:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(content)
                self.fixes_applied += 1

        return self.fixes_applied

    def _should_quarantine(self, filepath: str, errors: list) -> bool:
        name = os.path.splitext(os.path.basename(filepath))[0]
        if name in ["GeneratedHelpers", "GeneratedCode"]:
            return True
        if len(errors) > 10:
            return True
        if all(e.error_type == "top_level_code" for e in errors):
            return True
        return False

    def _quarantine(self, filepath: str):
        q = os.path.join(self.project_dir, "quarantine")
        os.makedirs(q, exist_ok=True)
        shutil.move(filepath, os.path.join(q, os.path.basename(filepath)))
        self.fixes_applied += 1
        print(f"      Quarantined: {os.path.basename(filepath)}")

    def _fix_imports(self, content: str, errors: list) -> str:
        needs_swiftui = any("View" in e.message or "Color" in e.message or
                           "Text" in e.message or "HStack" in e.message
                           for e in errors if e.error_type == "missing_type")
        needs_foundation = any(t in e.message for e in errors for t in
                              ["Data", "URL", "UUID", "Date", "Calendar", "Timer"]
                              if e.error_type == "missing_type")

        lines = content.split("\n")
        existing = [l for l in lines if l.startswith("import ")]

        adds = []
        if needs_swiftui and "import SwiftUI" not in existing:
            adds.append("import SwiftUI")
        if needs_foundation and "import Foundation" not in existing:
            adds.append("import Foundation")

        if adds:
            insert = 0
            for i, l in enumerate(lines):
                if l.startswith("import "):
                    insert = i + 1
            lines = lines[:insert] + adds + lines[insert:]
            return "\n".join(lines)
        return content

    def _fix_pseudocode(self, content: str) -> str:
        return content.replace("\n    ...\n", '\n    fatalError("Not implemented")\n')

    def _fix_enum_syntax(self, content: str) -> str:
        if re.search(r'enum\s+\w+\s*:\s*String\s*\{', content) and re.search(r'case\s+\w+\s*\(', content):
            content = re.sub(r'(enum\s+\w+)\s*:\s*(String|Int)\s*(\{)', r'\1 \3', content)
        return content
