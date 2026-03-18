# code_generation/extractors/typescript_extractor.py
# TypeScript/React/Next.js code extractor. Mirrors the Kotlin extractor patterns.

import os
import re
import datetime
from pathlib import Path

from code_generation.extractors.base import BaseCodeExtractor

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
GENERATED_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "generated_code")
LOGS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "logs")

MAX_FILES_PER_RUN = 50

# --- TypeScript type/component detection regexes ---

# export default function ComponentName(
_EXPORT_DEFAULT_FUNC_RE = re.compile(
    r'export\s+default\s+function\s+([A-Z][A-Za-z0-9_]*)\s*\(',
    re.MULTILINE
)

# export function functionName( or export async function functionName(
_EXPORT_FUNC_RE = re.compile(
    r'export\s+(?:async\s+)?function\s+([a-zA-Z][A-Za-z0-9_]*)\s*\(',
    re.MULTILINE
)

# export const ComponentName = ( or export const ComponentName: React.FC
_EXPORT_CONST_RE = re.compile(
    r'export\s+const\s+([A-Z][A-Za-z0-9_]*)\s*[=:]',
    re.MULTILINE
)

# export interface InterfaceName
_EXPORT_INTERFACE_RE = re.compile(
    r'export\s+(?:default\s+)?interface\s+([A-Z][A-Za-z0-9_]*)',
    re.MULTILINE
)

# export type TypeName
_EXPORT_TYPE_RE = re.compile(
    r'export\s+(?:default\s+)?type\s+([A-Z][A-Za-z0-9_]*)',
    re.MULTILINE
)

# Top-level export for dedup
_TOP_LEVEL_EXPORT_RE = re.compile(
    r'^export\s+(?:default\s+)?(?:const|function|async\s+function|interface|type|class|enum)\s+'
    r'([A-Za-z][A-Za-z0-9_]*)',
    re.MULTILINE
)

# TypeScript/React indicators for untagged block detection
_TS_INDICATORS = (
    "import React", "from 'react'", 'from "react"',
    "export default", "export const", "export function",
    "interface ", "type ", ": React.FC",
    "useState", "useEffect", "const [",
    "=> {", "import { ", "from '@/", "from '../",
    "className=", "'use client'", "'use server'",
    "import type",
)

# JSX indicators — determines .tsx vs .ts
_JSX_INDICATORS = (
    "<div", "<section", "<main", "<span", "<p ", "<h1", "<h2",
    "<Component", "className=", "React.FC", "JSX.Element",
    "React.ReactNode", "<>", "</>", "React.Fragment",
)

# PascalCase guard
_PASCAL_CASE_RE = re.compile(r'^[A-Z][A-Za-z0-9_]*$')
_CAMEL_CASE_RE = re.compile(r'^[a-z][A-Za-z0-9_]*$')

# Blocked placeholder names
_BLOCKED_NAMES: frozenset[str] = frozenset({
    "App", "Index", "Home", "Main", "Example", "Sample",
    "Test", "Demo", "Placeholder", "Mock", "Temp",
    "GeneratedFile", "GeneratedComponent", "GeneratedModule",
    "Component", "Page", "Layout", "Template",
    "String", "Number", "Boolean", "Object", "Array",
    "Function", "Promise", "Map", "Set", "Error",
})

_GENERATED_FILE_RE = re.compile(r'^Generated(?:Component|Module)[_\d]*$')

# Invalid standalone words
_INVALID_FILENAMES: frozenset[str] = frozenset({
    "for", "that", "this", "the", "and", "but", "with", "from",
    "file", "temp", "test", "data", "item", "list", "type",
    "class", "interface", "enum", "const", "let", "var",
    "import", "export", "return", "function", "if", "else",
    "switch", "case", "break", "continue", "while", "null",
    "true", "false", "undefined", "void", "never", "any",
})

# Architectural patterns
_TS_PATTERNS = {
    "useState": "React State",
    "useEffect": "React Effects",
    "useContext": "React Context",
    "useReducer": "React Reducer",
    "useMemo": "React Memo",
    "useCallback": "React Callback",
    "'use client'": "Next.js Client Component",
    "'use server'": "Next.js Server Action",
    "createContext": "Context Provider",
    "fetch(": "Data Fetching",
    "async function": "Async Logic",
    "Suspense": "React Suspense",
    "loading.tsx": "Next.js Loading",
    "error.tsx": "Next.js Error",
    "zustand": "Zustand State",
    "tanstack": "TanStack Query",
}


def _has_jsx(code: str) -> bool:
    """Check if code contains JSX syntax."""
    return any(ind in code for ind in _JSX_INDICATORS)


def _is_valid_filename(name: str) -> bool:
    """Validate filename suitability."""
    if not name or len(name) < 3:
        return False
    if name.lower() in _INVALID_FILENAMES:
        return False
    if " " in name:
        return False
    base = name.split(".")[0]
    if not (_PASCAL_CASE_RE.match(base) or _CAMEL_CASE_RE.match(base)):
        return False
    if _GENERATED_FILE_RE.match(base):
        return False
    return True


def _detect_name_and_folder(code: str) -> tuple[str | None, str | None]:
    """Determine (filename_without_ext, subfolder) from a TypeScript code block."""
    # 1. Next.js App Router markers
    if "'use client'" in code or "'use server'" in code:
        m = _EXPORT_DEFAULT_FUNC_RE.search(code) or _EXPORT_CONST_RE.search(code)
        if m:
            return m.group(1), "app"

    # 2. Hook (useXxx)
    m = _EXPORT_FUNC_RE.search(code)
    if m:
        name = m.group(1)
        if name.startswith("use") and len(name) > 3 and name[3].isupper():
            return name, "hooks"

    # 3. React component (export default function ComponentName)
    m = _EXPORT_DEFAULT_FUNC_RE.search(code)
    if m and _has_jsx(code):
        return m.group(1), "components"

    # 4. React component (export const ComponentName)
    m = _EXPORT_CONST_RE.search(code)
    if m:
        name = m.group(1)
        if _has_jsx(code) and _PASCAL_CASE_RE.match(name):
            return name, "components"

    # 5. Context provider
    if "createContext" in code:
        m = _EXPORT_CONST_RE.search(code) or _EXPORT_DEFAULT_FUNC_RE.search(code)
        if m:
            return m.group(1), "contexts"

    # 6. Service / API call patterns
    if "fetch(" in code or "axios" in code or "api" in code.lower():
        m = _EXPORT_FUNC_RE.search(code) or _EXPORT_CONST_RE.search(code)
        if m:
            name = m.group(1)
            if _PASCAL_CASE_RE.match(name) or name.endswith("Service") or name.endswith("Api"):
                return name, "services"

    # 7. Pure interface file
    m = _EXPORT_INTERFACE_RE.search(code)
    if m:
        # Check if file is primarily types (no functions with bodies)
        has_function_body = bool(re.search(r'(?:export\s+)?(?:async\s+)?function\s+\w+\s*\([^)]*\)\s*{', code))
        if not has_function_body:
            return m.group(1), "types"
        return m.group(1), "types"

    # 8. Pure type file
    m = _EXPORT_TYPE_RE.search(code)
    if m:
        return m.group(1), "types"

    # 9. Named export function (non-hook, non-component)
    m = _EXPORT_FUNC_RE.search(code)
    if m:
        name = m.group(1)
        if _PASCAL_CASE_RE.match(name) and _has_jsx(code):
            return name, "components"
        return name, "utils" if not _PASCAL_CASE_RE.match(name) else "services"

    # 10. export const with PascalCase (likely component or service)
    m = _EXPORT_CONST_RE.search(code)
    if m:
        return m.group(1), "components" if _has_jsx(code) else "utils"

    return None, None


def _file_unchanged(path: str, content: str) -> bool:
    try:
        with open(path, encoding="utf-8") as f:
            return f.read() == content
    except FileNotFoundError:
        return False


def _log_extraction(entries: list[str]):
    os.makedirs(LOGS_DIR, exist_ok=True)
    log_path = os.path.join(LOGS_DIR, "typescript_extraction.log")
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(f"\n--- TypeScript Extraction Run {timestamp} ---\n")
        for entry in entries:
            f.write(f"{entry}\n")
        f.write(f"--- End ({len(entries)} entries) ---\n")


def _strip_duplicate_exports(code: str, primary_name: str, other_file_names: set[str]) -> str:
    """Remove inline export definitions that have their own dedicated files."""
    if not other_file_names:
        return code

    types_to_strip: set[str] = set()
    for match in _TOP_LEVEL_EXPORT_RE.finditer(code):
        name = match.group(1)
        if name == primary_name:
            continue
        if name in other_file_names:
            types_to_strip.add(name)

    if not types_to_strip:
        return code

    lines = code.split("\n")
    result_lines: list[str] = []
    skip_depth = 0
    skipping = False

    for line in lines:
        if not skipping:
            stripped = line.strip()
            should_skip = False
            for name in types_to_strip:
                pattern = (
                    rf'^export\s+(?:default\s+)?'
                    rf'(?:const|function|async\s+function|interface|type|class|enum)\s+'
                    rf'{re.escape(name)}\b'
                )
                if re.match(pattern, stripped):
                    should_skip = True
                    skipping = True
                    skip_depth = 0
                    break

            if should_skip:
                skip_depth += line.count("{") - line.count("}")
                # Single-line export (no braces or balanced)
                if skip_depth <= 0:
                    skipping = False
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


def _is_typescript_code(block: str) -> bool:
    """Heuristic: does this untagged code block look like TypeScript/React?"""
    indicators_found = sum(1 for ind in _TS_INDICATORS if ind in block)
    return indicators_found >= 2


class TypeScriptCodeExtractor(BaseCodeExtractor):
    """TypeScript/React/Next.js code extractor."""

    def __init__(self):
        self._last_extraction_files: list[tuple[str, str, str, str]] = []
        self._last_extraction_patterns: set[str] = set()

    def extract_code(self, messages: list, project_name: str | None = None) -> dict:
        """Extract TypeScript code from agent messages."""
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

            # Detect fenced blocks: ```typescript, ```tsx, ```ts, ```jsx
            blocks = re.findall(r"```(?:typescript|tsx|ts|jsx)\s*\n(.*?)```", content, re.DOTALL)

            # Also check untagged blocks for TS/React indicators
            untagged = re.findall(r"```\s*\n(.*?)```", content, re.DOTALL)
            for block in untagged:
                if _is_typescript_code(block):
                    blocks.append(block)

            for block in blocks:
                block = block.strip()
                if not block:
                    continue

                name, subfolder = _detect_name_and_folder(block)

                if name is None:
                    orphan_snippets.append(block)
                    ext = ".tsx" if _has_jsx(block) else ".ts"
                    log_entries.append(f"[ORPHAN] undetectable → GeneratedHelpers{ext}")
                    continue

                base_name = name.split(".")[0]
                if base_name in _BLOCKED_NAMES or _GENERATED_FILE_RE.match(base_name):
                    blocked_names_found.append(name)
                    orphan_snippets.append(block)
                    log_entries.append(f"[BLOCKED] {name} → routed to helpers")
                    continue

                if not _is_valid_filename(name):
                    invalid_names_found.append(name)
                    orphan_snippets.append(block)
                    log_entries.append(f"[INVALID] {name} → rejected")
                    continue

                # Determine file extension
                ext = ".tsx" if _has_jsx(block) else ".ts"
                filename = f"{name}{ext}"
                dest_dir = os.path.join(GENERATED_DIR, subfolder)
                os.makedirs(dest_dir, exist_ok=True)
                dest_path = os.path.join(dest_dir, filename)

                type_kw = self._detect_type_keyword(block)
                files_to_write.append((name, subfolder, dest_path, block))
                log_entries.append(f"[TYPE] {type_kw} {name} → {subfolder}/{filename}")

        # Store metadata
        self._last_extraction_files = [
            (name, subfolder, self._detect_type_keyword(content), content)
            for name, subfolder, _, content in files_to_write
        ]
        self._last_extraction_patterns = self._detect_patterns(files_to_write)

        # Guard: max files
        if len(files_to_write) > MAX_FILES_PER_RUN:
            print(f"\n[ABORT] EXTRACTION ABORTED: {len(files_to_write)} files (max {MAX_FILES_PER_RUN}).")
            log_entries.append(f"[ABORT] {len(files_to_write)} files exceed limit")
            _log_extraction(log_entries)
            return {"saved": 0, "skipped": 0, "aborted": True}

        # Dedup
        all_file_names = {name for name, _, _, _ in files_to_write}
        project_file_stems: set[str] = set()
        if project_name:
            project_dir = _PROJECT_ROOT / "projects" / project_name
            if project_dir.is_dir():
                gen_resolved = Path(GENERATED_DIR).resolve()
                for tf in project_dir.rglob("*.ts"):
                    try:
                        tf.resolve().relative_to(gen_resolved)
                        continue
                    except ValueError:
                        pass
                    project_file_stems.add(tf.stem)
                for tf in project_dir.rglob("*.tsx"):
                    try:
                        tf.resolve().relative_to(gen_resolved)
                        continue
                    except ValueError:
                        pass
                    project_file_stems.add(tf.stem)
                if project_file_stems:
                    log_entries.append(
                        f"[DEDUP] Project-aware: {len(project_file_stems)} existing "
                        f"file stems from {project_name}"
                    )

        all_known_names = all_file_names | project_file_stems

        dedup_count = 0
        for i, (name, subfolder, dest_path, block) in enumerate(files_to_write):
            other_names = all_known_names - {name}
            cleaned = _strip_duplicate_exports(block, name, other_names)
            if cleaned != block:
                files_to_write[i] = (name, subfolder, dest_path, cleaned)
                dedup_count += 1
        if dedup_count:
            print(f"Inline export dedup: {dedup_count} file(s) cleaned")

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
            print("Blocked placeholder names:")
            for bn in blocked_names_found:
                print(f"  - {bn}")

        if invalid_names_found:
            print("Invalid filenames rejected:")
            for inv in invalid_names_found:
                print(f"  - {inv}")

        # Write orphans
        if orphan_snippets:
            has_jsx = any(_has_jsx(s) for s in orphan_snippets)
            ext = ".tsx" if has_jsx else ".ts"
            helpers_dir = os.path.join(GENERATED_DIR, "components")
            os.makedirs(helpers_dir, exist_ok=True)
            helpers_path = os.path.join(helpers_dir, f"GeneratedHelpers{ext}")
            combined = "\n\n// ---\n\n".join(orphan_snippets)
            if _file_unchanged(helpers_path, combined):
                skipped += 1
            else:
                with open(helpers_path, "w", encoding="utf-8") as f:
                    f.write(combined)
                saved += 1
                category_counts["Helpers"] = 1

        if category_counts:
            print("TypeScript files extracted:")
            for folder in ("app", "components", "hooks", "services", "types",
                           "contexts", "utils", "Helpers"):
                count = category_counts.get(folder, 0)
                if count:
                    print(f"  - {count} {folder}")

        _log_extraction(log_entries)
        return {"saved": saved, "skipped": skipped}

    @staticmethod
    def _detect_type_keyword(code: str) -> str:
        if "export default function" in code and _has_jsx(code):
            return "component"
        if "export const" in code and _has_jsx(code):
            return "component"
        if re.search(r'export\s+(?:async\s+)?function\s+use[A-Z]', code):
            return "hook"
        if "export interface" in code:
            return "interface"
        if "export type" in code:
            return "type"
        if "export class" in code:
            return "class"
        if "export enum" in code:
            return "enum"
        if "export function" in code or "export async function" in code:
            return "function"
        if "export const" in code:
            return "const"
        return "module"

    @staticmethod
    def _detect_patterns(files_to_write: list[tuple]) -> set[str]:
        patterns: set[str] = set()
        for _, _, _, content in files_to_write:
            for marker, label in _TS_PATTERNS.items():
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
        lines.append(f"Generated {len(self._last_extraction_files)} TypeScript file(s):")

        for name, subfolder, type_kw, code in self._last_extraction_files:
            ext = ".tsx" if _has_jsx(code) else ".ts"
            skeleton = self._extract_api_skeleton(code)
            lines.append(f"  - {subfolder}/{name}{ext} ({type_kw})")
            if skeleton:
                lines.append(f"    {skeleton}")

        if self._last_extraction_patterns:
            lines.append(f"Patterns: {', '.join(sorted(self._last_extraction_patterns))}")

        return "\n".join(lines)

    @staticmethod
    def _extract_api_skeleton(code: str, max_chars: int = 800) -> str:
        """Extract a compact skeleton of public API from TypeScript code."""
        signatures: list[str] = []
        for line in code.split("\n"):
            stripped = line.strip()
            if re.match(r'^export\s+(?:default\s+)?(?:async\s+)?function\s+', stripped):
                sig = stripped.split("{")[0].strip()
                if len(sig) > 10:
                    signatures.append(sig)
            elif re.match(r'^export\s+const\s+', stripped):
                sig = stripped.split("=")[0].strip()
                if len(sig) > 10:
                    signatures.append(sig)
            elif re.match(r'^export\s+(?:interface|type|class|enum)\s+', stripped):
                sig = stripped.split("{")[0].strip()
                if sig:
                    signatures.append(sig)

        result = " | ".join(signatures[:10])
        return result[:max_chars]

    @property
    def language(self) -> str:
        return "typescript"

    @property
    def file_extension(self) -> str:
        return ".tsx"
