"""
DriveAI Mac Factory — Pre-Build Cleanup v2

Runs BEFORE the first compile. All rules are deterministic ($0, no LLM calls).
Eliminates ~95% of typical compile errors from Windows-generated Swift code.

Rules (in order):
1. Nested Directory Detection
2. LLM Garbage Detection
3. Duplicate Type Deduplication (including System Type Shadows)
4. Mock/Test File Relocation
5. @main Deduplication

Post-compile (separate call):
6. Import Mapping (error message -> import statement)
"""

import os
import re
import json
import shutil
from pathlib import Path
from dataclasses import dataclass, field

SKIP_DIRS = {'Tests', 'test', 'tests', 'build', 'DerivedData', '.build',
             'Pods', 'quarantine', '.git'}

SWIFT_TOKENS = (
    'import ', '//', '/*', '@', 'struct ', 'class ', 'enum ',
    'protocol ', 'extension ', 'public ', 'private ', 'internal ',
    'final ', 'open ', '#if', '#import', 'func ', 'let ', 'var ',
    'actor ', 'typealias ', 'precedencegroup', 'infix ', 'prefix ',
    'postfix ', 'operator ', 'macro ', 'fileprivate ', 'indirect '
)


@dataclass
class CleanupReport:
    nested_dirs_fixed: int = 0
    garbage_files_found: int = 0
    garbage_files_emptied: int = 0
    duplicate_types_found: int = 0
    duplicate_files_stubbed: int = 0
    system_type_shadows: int = 0
    mock_files_moved: int = 0
    main_duplicates_fixed: int = 0
    imports_added: int = 0
    total_fixes: int = 0
    details: list = field(default_factory=list)

    def add(self, rule: str, detail: str):
        self.details.append(f"[{rule}] {detail}")

    def summary(self):
        self.total_fixes = (self.nested_dirs_fixed + self.garbage_files_emptied +
                            self.duplicate_files_stubbed + self.system_type_shadows +
                            self.mock_files_moved + self.main_duplicates_fixed +
                            self.imports_added)
        return self


class PreBuildCleanup:
    """
    Pre-Build Cleanup v2 — runs all 5 rules on a project directory.

    Usage:
        cleanup = PreBuildCleanup(project_dir="/path/to/projects/GrowMeldAI")
        report = cleanup.run_all()
        print(f"Fixed {report.total_fixes} issues")
    """

    _DECL_PATTERN = re.compile(
        r'^[ \t]*(?:public\s+|private\s+|internal\s+|open\s+|final\s+|fileprivate\s+)*'
        r'(class|struct|enum|protocol|actor)\s+(\w+)',
        re.MULTILINE
    )

    def __init__(self, project_dir: str):
        self.project_dir = project_dir
        self.report = CleanupReport()
        self._stubbed_files = set()  # Track files already stubbed by Rule 2
        self._load_knowledge()

    def _load_knowledge(self):
        """Load system_types.json and import_mapping.json."""
        knowledge_dir = Path(__file__).parent / "knowledge"

        sys_types_file = knowledge_dir / "system_types.json"
        if sys_types_file.exists():
            try:
                with open(sys_types_file) as f:
                    self.system_types = set(json.load(f))
            except Exception:
                self.system_types = set()
        else:
            self.system_types = set()

        import_map_file = knowledge_dir / "import_mapping.json"
        if import_map_file.exists():
            try:
                with open(import_map_file) as f:
                    self.import_map = json.load(f)
            except Exception:
                self.import_map = {}
        else:
            self.import_map = {}

    def run_all(self) -> CleanupReport:
        """Runs all 5 pre-build rules in order."""
        print(f"[Pre-Build] Starting cleanup on {self.project_dir}")

        self._rule1_nested_directory()
        self._rule2_llm_garbage()
        self._rule3_dedup_types()
        self._rule4_mock_relocation()
        self._rule5_main_dedup()

        self.report.summary()
        print(f"[Pre-Build] Done: {self.report.total_fixes} fixes applied")
        return self.report

    def run_import_mapping(self, errors: list) -> int:
        """
        Post-compile: adds missing imports based on error messages.
        Returns number of imports added.
        """
        files_to_fix = {}

        for error in errors:
            msg = error.get("message", "")
            filepath = error.get("file", "")
            if not filepath:
                continue

            for pattern, import_stmt in self.import_map.items():
                if pattern.lower() in msg.lower():
                    files_to_fix.setdefault(filepath, set()).add(import_stmt)
                    break

        added = 0
        for filepath, imports in files_to_fix.items():
            full_path = filepath if os.path.isabs(filepath) else os.path.join(self.project_dir, filepath)
            if not os.path.exists(full_path):
                continue

            try:
                with open(full_path, 'r', errors='ignore') as f:
                    content = f.read()

                existing_imports = set(m.group(0) for m in re.finditer(r'^import \w+(?:\.\w+)*', content, re.MULTILINE))
                new_imports = {imp for imp in imports if imp not in existing_imports}

                if not new_imports:
                    continue

                import_block = '\n'.join(sorted(new_imports))

                if re.search(r'^import ', content, re.MULTILINE):
                    lines = content.split('\n')
                    insert_idx = 0
                    for i, line in enumerate(lines):
                        if line.strip().startswith('import '):
                            insert_idx = i + 1
                        elif line.strip() and not line.strip().startswith('//'):
                            break
                    for imp in sorted(new_imports):
                        lines.insert(insert_idx, imp)
                        insert_idx += 1
                    content = '\n'.join(lines)
                else:
                    content = import_block + '\n\n' + content

                with open(full_path, 'w') as f:
                    f.write(content)

                added += len(new_imports)
                self.report.imports_added += len(new_imports)
            except Exception as e:
                print(f"[Pre-Build] Import fix failed for {filepath}: {e}")

        return added

    # ── Rule 1: Nested Directory ──────────────────────────

    def _rule1_nested_directory(self):
        project_name = os.path.basename(self.project_dir)
        nested = os.path.join(self.project_dir, project_name)

        if not os.path.isdir(nested):
            return

        nested_swift = list(Path(nested).rglob("*.swift"))
        if not nested_swift:
            return

        print(f"[Pre-Build] Rule 1: Nested directory found: {nested} ({len(nested_swift)} Swift files)")
        shutil.rmtree(nested)
        self.report.nested_dirs_fixed = 1
        self.report.add("Rule1", f"Deleted nested {project_name}/ ({len(nested_swift)} files)")

    # ── Rule 2: LLM Garbage Detection ─────────────────────

    def _rule2_llm_garbage(self):
        for swift_file in Path(self.project_dir).rglob("*.swift"):
            if any(part in SKIP_DIRS for part in swift_file.parts):
                continue

            try:
                content = swift_file.read_text(errors='ignore')
            except Exception:
                continue

            first_line = ""
            for line in content.split('\n'):
                stripped = line.strip()
                if stripped:
                    first_line = stripped
                    break

            if not first_line:
                continue

            if any(first_line.startswith(token) for token in SWIFT_TOKENS):
                continue

            self.report.garbage_files_found += 1
            type_name = swift_file.stem

            type_exists_elsewhere = self._type_exists_elsewhere(type_name, str(swift_file))
            ref_count = self._count_references(type_name, str(swift_file))

            if type_exists_elsewhere or ref_count == 0:
                swift_file.write_text("import Foundation\n")
                self._stubbed_files.add(str(swift_file))
                self.report.garbage_files_emptied += 1
                reason = "duplicate" if type_exists_elsewhere else "unreferenced"
                self.report.add("Rule2", f"Emptied garbage: {swift_file.name} ({reason})")
            else:
                self.report.add("Rule2", f"Garbage detected but referenced: {swift_file.name} ({ref_count} refs)")

    # ── Rule 3: Duplicate Type Deduplication ──────────────

    def _rule3_dedup_types(self):
        declarations = {}

        for swift_file in Path(self.project_dir).rglob("*.swift"):
            if any(part in SKIP_DIRS for part in swift_file.parts):
                continue
            # Skip files Rule 2 already stubbed
            if str(swift_file) in self._stubbed_files:
                continue

            try:
                content = swift_file.read_text(errors='ignore')
            except Exception:
                continue

            for match in self._DECL_PATTERN.finditer(content):
                type_name = match.group(2)
                if type_name in ('_', 'self', 'Self', 'Type', 'some'):
                    continue

                declarations.setdefault(type_name, []).append({
                    "path": str(swift_file),
                    "size": len(content)
                })

        for type_name, locations in declarations.items():
            if type_name in self.system_types:
                for loc in locations:
                    self._stub_file(loc["path"])
                    self.report.system_type_shadows += 1
                self.report.add("Rule3", f"System type shadow: {type_name} ({len(locations)} files stubbed)")
                continue

            if len(locations) <= 1:
                continue

            locations.sort(key=lambda x: -x["size"])
            self.report.duplicate_types_found += 1

            for loc in locations[1:]:
                self._stub_file(loc["path"])
                self.report.duplicate_files_stubbed += 1

            if len(locations) > 2:
                self.report.add("Rule3", f"Dedup: {type_name} ({len(locations)} files)")

    # ── Rule 4: Mock/Test File Relocation ─────────────────

    def _rule4_mock_relocation(self):
        tests_dir = os.path.join(self.project_dir, "Tests")

        for swift_file in Path(self.project_dir).rglob("*.swift"):
            if any(part in SKIP_DIRS for part in swift_file.parts):
                continue

            filename = swift_file.name
            should_move = (
                filename.startswith("Mock") or
                filename.endswith("Tests.swift") or
                filename.endswith("Test.swift") or
                filename.startswith("Stub") or
                filename.startswith("Fake") or
                filename.startswith("Dummy")
            )

            if not should_move:
                continue

            os.makedirs(tests_dir, exist_ok=True)
            dest = os.path.join(tests_dir, filename)
            if os.path.exists(dest):
                os.remove(str(swift_file))
            else:
                shutil.move(str(swift_file), dest)
            self.report.mock_files_moved += 1

        if self.report.mock_files_moved > 0:
            self.report.add("Rule4", f"Moved {self.report.mock_files_moved} mock/test files to Tests/")

    # ── Rule 5: @main Deduplication ───────────────────────

    def _rule5_main_dedup(self):
        main_files = []

        for swift_file in Path(self.project_dir).rglob("*.swift"):
            if any(part in SKIP_DIRS for part in swift_file.parts):
                continue

            try:
                content = swift_file.read_text(errors='ignore')
            except Exception:
                continue

            if re.search(r'^\s*@main\b', content, re.MULTILINE):
                main_files.append(str(swift_file))

        if len(main_files) <= 1:
            return

        app_file = None
        for f in main_files:
            if Path(f).stem.endswith("App"):
                app_file = f
                break

        if not app_file:
            app_file = main_files[0]

        for f in main_files:
            if f == app_file:
                continue
            try:
                content = Path(f).read_text(errors='ignore')
                content = re.sub(r'^\s*@main\s*\n', '', content, flags=re.MULTILINE)
                content = re.sub(r'@main\s+', '', content)
                Path(f).write_text(content)
                self.report.main_duplicates_fixed += 1
            except Exception:
                pass

        if self.report.main_duplicates_fixed > 0:
            self.report.add("Rule5", f"@main dedup: kept {Path(app_file).name}, removed from {self.report.main_duplicates_fixed} files")

    # ── Helpers ───────────────────────────────────────────

    def _stub_file(self, filepath: str):
        try:
            with open(filepath, 'w') as f:
                f.write("import Foundation\n")
            self._stubbed_files.add(filepath)
        except Exception:
            pass

    def _type_exists_elsewhere(self, type_name: str, exclude_path: str) -> bool:
        pattern = re.compile(
            rf'^[ \t]*(?:public\s+|private\s+|internal\s+|open\s+|final\s+|fileprivate\s+)*'
            rf'(?:class|struct|enum|protocol|actor)\s+{re.escape(type_name)}\b',
            re.MULTILINE
        )

        exclude_abs = os.path.abspath(exclude_path)

        for swift_file in Path(self.project_dir).rglob("*.swift"):
            if os.path.abspath(str(swift_file)) == exclude_abs:
                continue
            if any(part in SKIP_DIRS for part in swift_file.parts):
                continue

            try:
                content = swift_file.read_text(errors='ignore')
                if pattern.search(content):
                    return True
            except Exception:
                continue

        return False

    def _count_references(self, type_name: str, exclude_path: str) -> int:
        count = 0
        exclude_abs = os.path.abspath(exclude_path)
        word_pattern = re.compile(rf'\b{re.escape(type_name)}\b')

        for swift_file in Path(self.project_dir).rglob("*.swift"):
            if os.path.abspath(str(swift_file)) == exclude_abs:
                continue
            if any(part in SKIP_DIRS for part in swift_file.parts):
                continue

            try:
                content = swift_file.read_text(errors='ignore')
                if word_pattern.search(content):
                    count += 1
            except Exception:
                continue

        return count
