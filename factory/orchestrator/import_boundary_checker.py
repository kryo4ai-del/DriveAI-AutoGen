# factory/orchestrator/import_boundary_checker.py
# Checks that layers don't import from layers above them.

import os
import re

# UI framework imports per language — these should NOT appear in Foundation/Domain/Application layers
_UI_IMPORTS = {
    "swift": [
        re.compile(r'^\s*import\s+SwiftUI\b'),
        re.compile(r'^\s*import\s+UIKit\b'),
    ],
    "kotlin": [
        re.compile(r'^\s*import\s+androidx\.compose\b'),
        re.compile(r'^\s*import\s+android\.widget\b'),
        re.compile(r'^\s*import\s+android\.view\b'),
    ],
    "typescript": [
        re.compile(r"""from\s+['"]react['"]"""),
        re.compile(r"""import\s+React\b"""),
        re.compile(r"""['"]use client['"]"""),
        re.compile(r"""from\s+['"]@/components"""),
    ],
}

# Layers where UI imports are forbidden
_NO_UI_LAYERS = frozenset({"foundation", "domain", "application"})


class ImportBoundaryChecker:
    """Checks that layers don't import from layers above them."""

    def check_boundaries(self,
                         layer_name: str,
                         file_paths: list[str],
                         language: str = "swift") -> list[str]:
        """Return list of boundary violations."""
        if layer_name.lower() not in _NO_UI_LAYERS:
            return []

        patterns = _UI_IMPORTS.get(language, [])
        if not patterns:
            return []

        violations = []
        for path in file_paths:
            if not os.path.isfile(path):
                continue
            try:
                with open(path, encoding="utf-8") as f:
                    for line_num, line in enumerate(f, 1):
                        for pattern in patterns:
                            if pattern.search(line):
                                fname = os.path.basename(path)
                                violations.append(
                                    f"{fname}:{line_num}: UI import in {layer_name} layer: {line.strip()}"
                                )
            except (OSError, UnicodeDecodeError):
                continue

        return violations
