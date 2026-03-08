# code_extractor.py
# Scans agent messages for Swift code blocks and saves them as .swift files.

import os
import re

GENERATED_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "generated_code")

SUBFOLDER_MAP = {
    "ViewModel": "ViewModels",
    "View":      "Views",
    "Service":   "Services",
    "Model":     "Models",
}

# SwiftUI View: struct SomeName: View (or : some View)
_SWIFTUI_VIEW_RE = re.compile(r'\bstruct\s+(\w+)\s*:\s*(?:some\s+)?View\b')

# Named types: struct/class/enum/protocol — name must start with uppercase (PascalCase)
_TYPE_RE = re.compile(r'\b(?:struct|class|enum|protocol)\s+([A-Z]\w+)')

# Extension: extension SomeType — name must start with uppercase
_EXTENSION_RE = re.compile(r'\bextension\s+([A-Z]\w+)')

# Blocklist: generic placeholder names that should never get standalone files
_BLOCKED_NAMES: frozenset[str] = frozenset({
    "SomeView", "ContentView", "ExampleView", "DemoView",
    "SampleView", "TestView", "PlaceholderView", "MockView",
    "MyView", "MainView", "RootView", "BasicView",
})


def _detect_name_and_folder(code: str) -> tuple[str, str]:
    """
    Determine (filename_without_ext, subfolder) from a Swift code block.
    Priority: SwiftUI View → ViewModel → generic type → extension → None
    Returns (None, None) when no name is detectable.
    """
    # 1. SwiftUI View  →  Views/
    m = _SWIFTUI_VIEW_RE.search(code)
    if m:
        return m.group(1), "Views"

    # 2. Named type (struct/class/enum/protocol)
    m = _TYPE_RE.search(code)
    if m:
        name = m.group(1)
        folder = _folder_for_name(name)
        return name, folder

    # 3. Extension  →  keep folder by type name, append +Extension
    m = _EXTENSION_RE.search(code)
    if m:
        base = m.group(1)
        folder = _folder_for_name(base)
        return f"{base}+Extension", folder

    return None, None


def _folder_for_name(name: str) -> str:
    """Route a type name to the correct subfolder."""
    for suffix, folder in SUBFOLDER_MAP.items():
        if name.endswith(suffix):
            return folder
    return "Models"


def _file_unchanged(path: str, content: str) -> bool:
    try:
        with open(path, encoding="utf-8") as f:
            return f.read() == content
    except FileNotFoundError:
        return False


class CodeExtractor:
    def extract_swift_code(self, messages: list) -> dict[str, int]:
        """
        Scan agent messages, extract Swift code blocks, save as .swift files.
        Orphan blocks (no detectable name) are appended to GeneratedHelpers.swift.
        Returns {"saved": n, "skipped": n} with a console summary of categories.
        """
        saved = 0
        skipped = 0
        orphan_snippets: list[str] = []
        blocked_names_found: list[str] = []
        category_counts: dict[str, int] = {}

        for msg in messages:
            source = getattr(msg, "source", "")
            content = getattr(msg, "content", "")
            if not isinstance(content, str) or source in ("user", ""):
                continue

            blocks = re.findall(r"```swift\s*\n(.*?)```", content, re.DOTALL)
            for block in blocks:
                block = block.strip()
                if not block:
                    continue

                name, subfolder = _detect_name_and_folder(block)

                if name is None:
                    # Collect orphans for grouping
                    orphan_snippets.append(block)
                    continue

                # Blocklist check — route placeholder names to GeneratedHelpers.swift
                if name in _BLOCKED_NAMES or name.split("+")[0] in _BLOCKED_NAMES:
                    blocked_names_found.append(name)
                    orphan_snippets.append(block)
                    continue

                filename = f"{name}.swift"
                dest_dir = os.path.join(GENERATED_DIR, subfolder)
                os.makedirs(dest_dir, exist_ok=True)
                dest_path = os.path.join(dest_dir, filename)

                if _file_unchanged(dest_path, block):
                    skipped += 1
                    continue

                with open(dest_path, "w", encoding="utf-8") as f:
                    f.write(block)
                saved += 1
                category_counts[subfolder] = category_counts.get(subfolder, 0) + 1

        # Console note for blocked placeholder names
        if blocked_names_found:
            print("Blocked placeholder types routed to GeneratedHelpers.swift:")
            for bn in blocked_names_found:
                print(f"  - {bn}")

        # Write all orphan snippets into one helper file
        if orphan_snippets:
            helpers_dir = os.path.join(GENERATED_DIR, "Models")
            os.makedirs(helpers_dir, exist_ok=True)
            helpers_path = os.path.join(helpers_dir, "GeneratedHelpers.swift")
            combined = "\n\n// ---\n\n".join(orphan_snippets)
            if _file_unchanged(helpers_path, combined):
                skipped += 1
            else:
                with open(helpers_path, "w", encoding="utf-8") as f:
                    f.write(combined)
                saved += 1
                category_counts["Helpers"] = 1

        # Console summary
        if category_counts:
            print("Swift files extracted:")
            label_map = {
                "Views":      "Views",
                "ViewModels": "ViewModels",
                "Services":   "Services",
                "Models":     "Models",
                "Helpers":    "Helper file",
            }
            for folder in ("Views", "ViewModels", "Services", "Models", "Helpers"):
                count = category_counts.get(folder, 0)
                if count:
                    print(f"  - {count} {label_map[folder]}")

        return {"saved": saved, "skipped": skipped}
