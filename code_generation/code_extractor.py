# code_extractor.py
# Scans agent messages for Swift code blocks and saves them as .swift files.

import os
import re
import datetime

GENERATED_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "generated_code")
LOGS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "logs")

SUBFOLDER_MAP = {
    "ViewModel": "ViewModels",
    "View":      "Views",
    "Service":   "Services",
    "Model":     "Models",
}

# --- Guard 1: Strict Swift declaration regex ---
# Only match actual Swift declarations at the start of a line (with optional access modifiers)
_SWIFTUI_VIEW_RE = re.compile(
    r'^\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)?'
    r'(?:final\s+)?struct\s+(\w+)\s*:\s*(?:some\s+)?View\b',
    re.MULTILINE
)

_TYPE_RE = re.compile(
    r'^\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)?'
    r'(?:final\s+)?(?:class|struct|enum|protocol)\s+([A-Z][A-Za-z0-9_]*)',
    re.MULTILINE
)

_EXTENSION_RE = re.compile(
    r'^\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)?'
    r'extension\s+([A-Z][A-Za-z0-9_]*)',
    re.MULTILINE
)

# --- Guard 3: Expanded blocklist ---
_BLOCKED_NAMES: frozenset[str] = frozenset({
    # Placeholder views
    "SomeView", "ContentView", "ExampleView", "DemoView",
    "SampleView", "TestView", "PlaceholderView", "MockView",
    "MyView", "MainView", "RootView", "BasicView",
    "TempView", "GeneratedView",
    # Generated file patterns
    "GeneratedFile", "GeneratedHelpers",
    # Common false positives from markdown/comments
    "String", "Int", "Double", "Bool", "Array", "Dictionary",
    "Optional", "Result", "Error", "URL", "Data", "Date",
    "Set", "Any", "AnyObject", "Void", "Never",
})

# Regex for GeneratedFile_N pattern
_GENERATED_FILE_RE = re.compile(r'^GeneratedFile[_\d]*$')

# --- Guard 2: Filename validation ---
_PASCAL_CASE_RE = re.compile(r'^[A-Z][A-Za-z0-9_]*$')

# Invalid standalone words that should never become filenames
_INVALID_FILENAMES: frozenset[str] = frozenset({
    "for", "that", "this", "the", "and", "but", "with", "from",
    "file", "temp", "test", "data", "item", "list", "type",
    "view", "model", "class", "struct", "enum", "protocol",
    "import", "return", "func", "var", "let", "if", "else",
    "switch", "case", "break", "continue", "while", "guard",
    "self", "super", "nil", "true", "false",
})

# --- Guard 5: Max files per run ---
# Raised from 10 to 50: AskFin Premium generates 75 files per feature run.
# 10 caused silent abort on any non-trivial project.
MAX_FILES_PER_RUN = 50


def _is_valid_filename(name: str) -> bool:
    """Validate that a detected type name is suitable as a Swift filename."""
    if not name or len(name) < 3:
        return False
    if name.lower() in _INVALID_FILENAMES:
        return False
    if " " in name:
        return False
    # Must be PascalCase (start uppercase, alphanumeric + underscore only)
    base = name.split("+")[0]  # Handle Extension names like "Color+Extension"
    if not _PASCAL_CASE_RE.match(base):
        return False
    # Block GeneratedFile_N patterns
    if _GENERATED_FILE_RE.match(base):
        return False
    return True


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


def _log_extraction(entries: list[str]):
    """Write extraction log to logs/code_extraction.log."""
    os.makedirs(LOGS_DIR, exist_ok=True)
    log_path = os.path.join(LOGS_DIR, "code_extraction.log")
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(f"\n--- Extraction Run {timestamp} ---\n")
        for entry in entries:
            f.write(f"{entry}\n")
        f.write(f"--- End ({len(entries)} entries) ---\n")


_SWIFT_PATTERNS = {
    "@Observable": "Observable pattern",
    "ObservableObject": "ObservableObject pattern",
    "@Published": "Published properties",
    "async ": "async/await",
    "await ": "async/await",
    "import Combine": "Combine framework",
    "@Environment": "SwiftUI Environment",
    "@StateObject": "StateObject",
    "@State ": "SwiftUI State",
    "NavigationStack": "NavigationStack",
    "NavigationView": "NavigationView",
    "@EnvironmentObject": "EnvironmentObject",
}


class CodeExtractor:
    def __init__(self):
        self._last_extraction_files: list[tuple[str, str, str]] = []  # (name, subfolder, type_kw)
        self._last_extraction_patterns: set[str] = set()

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
        invalid_names_found: list[str] = []
        category_counts: dict[str, int] = {}
        log_entries: list[str] = []
        files_to_write: list[tuple[str, str, str, str]] = []  # (name, subfolder, dest_path, content)

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
                    orphan_snippets.append(block)
                    log_entries.append(f"[ORPHAN] undetectable type → GeneratedHelpers.swift")
                    continue

                # Guard 3: Blocklist check
                base_name = name.split("+")[0]
                if base_name in _BLOCKED_NAMES or _GENERATED_FILE_RE.match(base_name):
                    blocked_names_found.append(name)
                    orphan_snippets.append(block)
                    log_entries.append(f"[BLOCKED] {name} → routed to GeneratedHelpers.swift")
                    continue

                # Guard 2: Filename validation
                if not _is_valid_filename(name):
                    invalid_names_found.append(name)
                    orphan_snippets.append(block)
                    log_entries.append(f"[INVALID] {name} → rejected (bad filename), routed to GeneratedHelpers.swift")
                    continue

                filename = f"{name}.swift"
                dest_dir = os.path.join(GENERATED_DIR, subfolder)
                os.makedirs(dest_dir, exist_ok=True)
                dest_path = os.path.join(dest_dir, filename)

                # Detect Swift type keyword for log
                type_kw = "type"
                for kw in ("struct", "class", "enum", "protocol", "extension"):
                    if re.search(rf'^\s*(?:\w+\s+)*{kw}\s+', block, re.MULTILINE):
                        type_kw = kw
                        break

                files_to_write.append((name, subfolder, dest_path, block))
                log_entries.append(f"[TYPE] {type_kw} {name} → {subfolder}/{filename}")

        # Store extraction metadata for implementation summary
        self._last_extraction_files = [
            (name, subfolder, self._detect_type_keyword(content))
            for name, subfolder, _, content in files_to_write
        ]
        self._last_extraction_patterns = self._detect_patterns(files_to_write)

        # --- Guard 5: Abort if too many files ---
        if len(files_to_write) > MAX_FILES_PER_RUN:
            print(f"\n[ABORT] EXTRACTION ABORTED: {len(files_to_write)} files detected (max {MAX_FILES_PER_RUN}).")
            print("  This usually indicates the LLM generated placeholder/boilerplate code.")
            print("  No files were written. Review the agent output manually.\n")
            log_entries.append(f"[ABORT] {len(files_to_write)} files exceed limit of {MAX_FILES_PER_RUN} — extraction aborted")
            _log_extraction(log_entries)
            return {"saved": 0, "skipped": 0, "aborted": True}

        # Write validated files
        for name, subfolder, dest_path, block in files_to_write:
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

        # Console note for invalid filenames
        if invalid_names_found:
            print("Invalid filenames rejected:")
            for inv in invalid_names_found:
                print(f"  - {inv}")

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

        # --- Guard 6: Write extraction log ---
        _log_extraction(log_entries)

        return {"saved": saved, "skipped": skipped}

    @staticmethod
    def _detect_type_keyword(code: str) -> str:
        """Detect the Swift type keyword from a code block."""
        for kw in ("struct", "class", "enum", "protocol", "extension"):
            if re.search(rf'^\s*(?:\w+\s+)*{kw}\s+', code, re.MULTILINE):
                return kw
        return "type"

    @staticmethod
    def _detect_patterns(files_to_write: list[tuple]) -> set[str]:
        """Detect architectural patterns from generated code blocks."""
        patterns: set[str] = set()
        for _, _, _, content in files_to_write:
            for marker, label in _SWIFT_PATTERNS.items():
                if marker in content:
                    patterns.add(label)
        return patterns

    def build_implementation_summary(self, user_task: str, template: str | None = None) -> str:
        """Build a compact summary of the last extraction for review passes.

        Returns a short text block (~300-500 tokens) describing what was generated,
        suitable for prepending to review task prompts after team.reset().
        """
        files = self._last_extraction_files
        patterns = self._last_extraction_patterns

        if not files:
            return ""

        lines = ["[Implementation Summary]"]
        lines.append(f"Feature: {user_task}")
        if template:
            lines.append(f"Template: {template}")
        lines.append(f"Files generated: {len(files)}")
        lines.append("")

        # Group files by subfolder
        by_folder: dict[str, list[tuple[str, str]]] = {}
        for name, subfolder, type_kw in files:
            by_folder.setdefault(subfolder, []).append((name, type_kw))

        lines.append("Generated files:")
        for folder in ("Views", "ViewModels", "Services", "Models"):
            if folder not in by_folder:
                continue
            for name, type_kw in by_folder[folder]:
                lines.append(f"  - {folder}/{name}.swift ({type_kw})")

        if patterns:
            lines.append("")
            lines.append(f"Architecture: {', '.join(sorted(patterns))}")

        lines.append("")
        lines.append("Use this summary to ground your review in the actual implementation.")

        return "\n".join(lines)
