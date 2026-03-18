# code_generation/extractors/kotlin_extractor.py
# Kotlin/Jetpack Compose code extractor. Mirrors the Swift extractor patterns.

import os
import re
import datetime
from pathlib import Path

from code_generation.extractors.base import BaseCodeExtractor

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
GENERATED_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "generated_code")
LOGS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "logs")

MAX_FILES_PER_RUN = 50

# --- Kotlin type detection regexes ---

# @Composable fun ScreenName(
_COMPOSABLE_FUN_RE = re.compile(
    r'@Composable\s+(?:(?:fun|internal\s+fun|private\s+fun)\s+)([A-Z][A-Za-z0-9_]*)\s*\(',
    re.MULTILINE
)

# class / data class / sealed class / enum class / abstract class
_CLASS_RE = re.compile(
    r'^\s*(?:public\s+|internal\s+|private\s+|protected\s+)?'
    r'(?:abstract\s+|open\s+|data\s+|sealed\s+|enum\s+)?'
    r'class\s+([A-Z][A-Za-z0-9_]*)',
    re.MULTILINE
)

# object ObjectName
_OBJECT_RE = re.compile(
    r'^\s*(?:public\s+|internal\s+|private\s+|protected\s+)?'
    r'object\s+([A-Z][A-Za-z0-9_]*)',
    re.MULTILINE
)

# interface InterfaceName
_INTERFACE_RE = re.compile(
    r'^\s*(?:public\s+|internal\s+|private\s+|protected\s+)?'
    r'(?:fun\s+)?interface\s+([A-Z][A-Za-z0-9_]*)',
    re.MULTILINE
)

# Top-level type for dedup (class, data class, sealed class, enum class, object, interface)
_TOP_LEVEL_TYPE_RE = re.compile(
    r'^(?:@\w+(?:\(.*?\))?\s+)*'
    r'(?:public\s+|internal\s+|private\s+|protected\s+)?'
    r'(?:abstract\s+|open\s+|data\s+|sealed\s+|enum\s+)?'
    r'(?:class|object|interface)\s+'
    r'([A-Z][A-Za-z0-9_]*)',
    re.MULTILINE
)

# Kotlin indicators for untagged code block detection
_KOTLIN_INDICATORS = (
    'fun ', 'val ', 'var ', 'class ', 'object ', 'interface ',
    'data class ', 'sealed class ', 'enum class ',
    'package ', 'import android', 'import androidx', 'import kotlinx',
    '@Composable', '@Preview', '@HiltViewModel', '@Inject',
)

# PascalCase guard
_PASCAL_CASE_RE = re.compile(r'^[A-Z][A-Za-z0-9_]*$')

# Blocked placeholder names
_BLOCKED_NAMES: frozenset[str] = frozenset({
    "MainActivity", "MainScreen", "ExampleScreen", "SampleScreen",
    "TestScreen", "PlaceholderScreen", "MockScreen", "DemoScreen",
    "GeneratedFile", "GeneratedKotlin", "GeneratedHelpers",
    "String", "Int", "Double", "Boolean", "Float", "Long",
    "Any", "Unit", "Nothing", "List", "Map", "Set",
})

_GENERATED_FILE_RE = re.compile(r'^GeneratedKotlin[_\d]*$')

# Invalid standalone words
_INVALID_FILENAMES: frozenset[str] = frozenset({
    "for", "that", "this", "the", "and", "but", "with", "from",
    "file", "temp", "test", "data", "item", "list", "type",
    "view", "model", "class", "interface", "object", "enum",
    "import", "return", "fun", "val", "var", "if", "else",
    "when", "while", "null", "true", "false", "super", "this",
})

# Subfolder routing
SUBFOLDER_MAP = {
    "ViewModel": "ViewModels",
    "Screen": "Views",
    "View": "Views",
    "Service": "Services",
    "Repository": "Services",
    "UseCase": "Services",
    "Model": "Models",
}

# Kotlin architectural patterns
_KOTLIN_PATTERNS = {
    "@Composable": "Jetpack Compose",
    "@HiltViewModel": "Hilt DI",
    "@Inject": "Dependency Injection",
    "ViewModel()": "ViewModel pattern",
    "StateFlow": "StateFlow",
    "MutableStateFlow": "MutableStateFlow",
    "LaunchedEffect": "Compose Side Effects",
    "remember": "Compose State",
    "suspend fun": "Coroutines",
    "viewModelScope": "ViewModel Scope",
    "Room": "Room Database",
    "Retrofit": "Retrofit HTTP",
    "NavHost": "Navigation",
}


def _is_valid_filename(name: str) -> bool:
    """Validate that a detected type name is suitable as a Kotlin filename."""
    if not name or len(name) < 3:
        return False
    if name.lower() in _INVALID_FILENAMES:
        return False
    if " " in name:
        return False
    if not _PASCAL_CASE_RE.match(name):
        return False
    if _GENERATED_FILE_RE.match(name):
        return False
    return True


def _detect_name_and_folder(code: str) -> tuple[str | None, str | None]:
    """Determine (filename_without_ext, subfolder) from a Kotlin code block."""
    # 1. @Composable function → Views/
    m = _COMPOSABLE_FUN_RE.search(code)
    if m:
        name = m.group(1)
        # Check if it looks like a screen vs a component
        if name.endswith("Screen") or name.endswith("View"):
            return name, "Views"
        return name, "Views"

    # 2. @HiltViewModel class → ViewModels/
    if "@HiltViewModel" in code:
        m = _CLASS_RE.search(code)
        if m:
            return m.group(1), "ViewModels"

    # 3. Class/data class/sealed class/enum class
    m = _CLASS_RE.search(code)
    if m:
        name = m.group(1)
        return name, _folder_for_name(name, code)

    # 4. Object
    m = _OBJECT_RE.search(code)
    if m:
        name = m.group(1)
        return name, _folder_for_name(name, code)

    # 5. Interface
    m = _INTERFACE_RE.search(code)
    if m:
        name = m.group(1)
        return name, _folder_for_name(name, code)

    return None, None


def _folder_for_name(name: str, code: str = "") -> str:
    """Route a type name to the correct subfolder."""
    # Check ViewModel inheritance
    if ": ViewModel()" in code or "ViewModel()" in code:
        return "ViewModels"
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
    os.makedirs(LOGS_DIR, exist_ok=True)
    log_path = os.path.join(LOGS_DIR, "kotlin_extraction.log")
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(f"\n--- Kotlin Extraction Run {timestamp} ---\n")
        for entry in entries:
            f.write(f"{entry}\n")
        f.write(f"--- End ({len(entries)} entries) ---\n")


def _strip_duplicate_types(code: str, primary_name: str, other_file_names: set[str]) -> str:
    """Remove inline type definitions that have their own dedicated files."""
    if not other_file_names:
        return code

    lines = code.split("\n")
    types_to_strip: set[str] = set()

    for match in _TOP_LEVEL_TYPE_RE.finditer(code):
        type_name = match.group(1)
        if type_name == primary_name:
            continue
        if type_name in other_file_names:
            types_to_strip.add(type_name)

    if not types_to_strip:
        return code

    result_lines: list[str] = []
    skip_depth = 0
    skipping = False

    for line in lines:
        if not skipping:
            if line and not line[0].isspace():
                stripped = line.strip()
                should_skip = False
                for type_name in types_to_strip:
                    pattern = (
                        rf'^(?:@\w+(?:\(.*?\))?\s+)*'
                        rf'(?:public\s+|internal\s+|private\s+|protected\s+)?'
                        rf'(?:abstract\s+|open\s+|data\s+|sealed\s+|enum\s+)?'
                        rf'(?:class|object|interface)\s+{re.escape(type_name)}\b'
                    )
                    if re.match(pattern, stripped):
                        should_skip = True
                        skipping = True
                        skip_depth = 0
                        break

                if should_skip:
                    skip_depth += line.count("{") - line.count("}")
                    continue

            result_lines.append(line)
        else:
            skip_depth += line.count("{") - line.count("}")
            if skip_depth <= 0:
                skipping = False
                continue

    # Clean up excessive blank lines
    cleaned: list[str] = []
    prev_blank = False
    for line in result_lines:
        is_blank = line.strip() == ""
        if is_blank and prev_blank:
            continue
        cleaned.append(line)
        prev_blank = is_blank

    return "\n".join(cleaned)


def _is_kotlin_code(block: str) -> bool:
    """Heuristic: does this untagged code block look like Kotlin?"""
    indicators_found = sum(1 for ind in _KOTLIN_INDICATORS if ind in block)
    return indicators_found >= 2


class KotlinCodeExtractor(BaseCodeExtractor):
    """Kotlin/Jetpack Compose code extractor."""

    def __init__(self):
        self._last_extraction_files: list[tuple[str, str, str, str]] = []
        self._last_extraction_patterns: set[str] = set()

    def extract_code(self, messages: list, project_name: str | None = None) -> dict:
        """Extract Kotlin code from agent messages."""
        saved = 0
        skipped = 0
        orphan_snippets: list[str] = []
        blocked_names_found: list[str] = []
        invalid_names_found: list[str] = []
        category_counts: dict[str, int] = {}
        log_entries: list[str] = []
        files_to_write: list[tuple[str, str, str, str]] = []

        for msg in messages:
            source = getattr(msg, "source", "")
            content = getattr(msg, "content", "")
            if not isinstance(content, str) or source in ("user", ""):
                continue

            # Detect ```kotlin and ```kt fenced blocks
            blocks = re.findall(r"```(?:kotlin|kt)\s*\n(.*?)```", content, re.DOTALL)

            # Also check untagged code blocks for Kotlin indicators
            untagged = re.findall(r"```\s*\n(.*?)```", content, re.DOTALL)
            for block in untagged:
                if _is_kotlin_code(block):
                    blocks.append(block)

            for block in blocks:
                block = block.strip()
                if not block:
                    continue

                name, subfolder = _detect_name_and_folder(block)

                if name is None:
                    orphan_snippets.append(block)
                    log_entries.append("[ORPHAN] undetectable type → GeneratedHelpers.kt")
                    continue

                if name in _BLOCKED_NAMES or _GENERATED_FILE_RE.match(name):
                    blocked_names_found.append(name)
                    orphan_snippets.append(block)
                    log_entries.append(f"[BLOCKED] {name} → routed to GeneratedHelpers.kt")
                    continue

                if not _is_valid_filename(name):
                    invalid_names_found.append(name)
                    orphan_snippets.append(block)
                    log_entries.append(f"[INVALID] {name} → rejected, routed to GeneratedHelpers.kt")
                    continue

                filename = f"{name}.kt"
                dest_dir = os.path.join(GENERATED_DIR, subfolder)
                os.makedirs(dest_dir, exist_ok=True)
                dest_path = os.path.join(dest_dir, filename)

                type_kw = self._detect_type_keyword(block)
                files_to_write.append((name, subfolder, dest_path, block))
                log_entries.append(f"[TYPE] {type_kw} {name} → {subfolder}/{filename}")

        # Store metadata for summary
        self._last_extraction_files = [
            (name, subfolder, self._detect_type_keyword(content), content)
            for name, subfolder, _, content in files_to_write
        ]
        self._last_extraction_patterns = self._detect_patterns(files_to_write)

        # Guard: max files
        if len(files_to_write) > MAX_FILES_PER_RUN:
            print(f"\n[ABORT] EXTRACTION ABORTED: {len(files_to_write)} files detected (max {MAX_FILES_PER_RUN}).")
            log_entries.append(f"[ABORT] {len(files_to_write)} files exceed limit")
            _log_extraction(log_entries)
            return {"saved": 0, "skipped": 0, "aborted": True}

        # Dedup: strip inline types that have their own files
        all_file_names = {name for name, _, _, _ in files_to_write}
        project_file_stems: set[str] = set()
        if project_name:
            project_dir = _PROJECT_ROOT / "projects" / project_name
            if project_dir.is_dir():
                gen_resolved = Path(GENERATED_DIR).resolve()
                for kf in project_dir.rglob("*.kt"):
                    try:
                        kf.resolve().relative_to(gen_resolved)
                        continue
                    except ValueError:
                        pass
                    project_file_stems.add(kf.stem)
                if project_file_stems:
                    log_entries.append(
                        f"[DEDUP] Project-aware: {len(project_file_stems)} existing "
                        f"file stems loaded from {project_name}"
                    )

        all_known_names = all_file_names | project_file_stems

        dedup_count = 0
        for i, (name, subfolder, dest_path, block) in enumerate(files_to_write):
            other_names = all_known_names - {name}
            cleaned = _strip_duplicate_types(block, name, other_names)
            if cleaned != block:
                files_to_write[i] = (name, subfolder, dest_path, cleaned)
                dedup_count += 1
        if dedup_count:
            print(f"Inline type dedup: {dedup_count} file(s) cleaned")

        # Write files
        for name, subfolder, dest_path, block in files_to_write:
            if _file_unchanged(dest_path, block):
                skipped += 1
                continue
            with open(dest_path, "w", encoding="utf-8") as f:
                f.write(block)
            saved += 1
            category_counts[subfolder] = category_counts.get(subfolder, 0) + 1

        if blocked_names_found:
            print("Blocked placeholder types:")
            for bn in blocked_names_found:
                print(f"  - {bn}")

        if invalid_names_found:
            print("Invalid filenames rejected:")
            for inv in invalid_names_found:
                print(f"  - {inv}")

        # Write orphans
        if orphan_snippets:
            helpers_dir = os.path.join(GENERATED_DIR, "Models")
            os.makedirs(helpers_dir, exist_ok=True)
            helpers_path = os.path.join(helpers_dir, "GeneratedHelpers.kt")
            combined = "\n\n// ---\n\n".join(orphan_snippets)
            if _file_unchanged(helpers_path, combined):
                skipped += 1
            else:
                with open(helpers_path, "w", encoding="utf-8") as f:
                    f.write(combined)
                saved += 1
                category_counts["Helpers"] = 1

        if category_counts:
            print("Kotlin files extracted:")
            for folder in ("Views", "ViewModels", "Services", "Models", "Helpers"):
                count = category_counts.get(folder, 0)
                if count:
                    print(f"  - {count} {folder}")

        _log_extraction(log_entries)
        return {"saved": saved, "skipped": skipped}

    @staticmethod
    def _detect_type_keyword(code: str) -> str:
        for kw in ("data class", "sealed class", "enum class", "class", "object", "interface"):
            if re.search(rf'^\s*(?:\w+\s+)*{re.escape(kw)}\s+', code, re.MULTILINE):
                return kw
        if "@Composable" in code:
            return "composable"
        return "type"

    @staticmethod
    def _detect_patterns(files_to_write: list[tuple]) -> set[str]:
        patterns: set[str] = set()
        for _, _, _, content in files_to_write:
            for marker, label in _KOTLIN_PATTERNS.items():
                if marker in content:
                    patterns.add(label)
        return patterns

    def build_implementation_summary(self, user_task: str, template: str | None = None) -> str:
        """Build a structured summary of the last extraction."""
        if not self._last_extraction_files:
            return ""

        lines = [f"[Implementation Summary for: {user_task}]"]
        if template:
            lines.append(f"Template: {template}")
        lines.append(f"Generated {len(self._last_extraction_files)} Kotlin file(s):")

        for name, subfolder, type_kw, code in self._last_extraction_files:
            skeleton = self._extract_api_skeleton(code)
            lines.append(f"  - {subfolder}/{name}.kt ({type_kw})")
            if skeleton:
                lines.append(f"    {skeleton}")

        if self._last_extraction_patterns:
            lines.append(f"Patterns: {', '.join(sorted(self._last_extraction_patterns))}")

        return "\n".join(lines)

    @staticmethod
    def _extract_api_skeleton(code: str, max_chars: int = 800) -> str:
        """Extract a compact skeleton of public API from Kotlin code."""
        signatures: list[str] = []
        for line in code.split("\n"):
            stripped = line.strip()
            if re.match(r'^(?:public\s+|internal\s+)?(?:fun|val|var|suspend fun)\s+', stripped):
                sig = stripped.split("{")[0].strip().rstrip("=").strip()
                if len(sig) > 10:
                    signatures.append(sig)
            elif re.match(r'^(?:data\s+|sealed\s+|enum\s+)?class\s+', stripped):
                sig = stripped.split("{")[0].strip()
                if sig:
                    signatures.append(sig)
            elif re.match(r'^(?:object|interface)\s+', stripped):
                sig = stripped.split("{")[0].strip()
                if sig:
                    signatures.append(sig)

        result = " | ".join(signatures[:10])
        return result[:max_chars]

    @property
    def language(self) -> str:
        return "kotlin"

    @property
    def file_extension(self) -> str:
        return ".kt"
