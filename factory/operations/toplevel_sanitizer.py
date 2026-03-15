# factory/operations/toplevel_sanitizer.py
# Post-integration sanitizer for top-level statements in Swift files.
#
# Swift source files (non-main) must not contain executable statements
# at the top level. This sanitizer detects and comments out:
# - Usage examples after struct/class/enum definitions
# - Dangling decorators (@MainActor, @Published) without a declaration
# - Loose code fragments outside any type/extension scope
#
# Deterministic, no LLM. Operates on the project directory.

import re
from dataclasses import dataclass, field
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

# ---------------------------------------------------------------------------
# Patterns that are valid at the top level in Swift
# ---------------------------------------------------------------------------

# Lines that are always valid at top level
_VALID_TOP_LEVEL_RE = re.compile(
    r'^(?:'
    r'\s*$|'                          # empty line
    r'\s*//|'                         # comment
    r'\s*/\*|'                        # block comment start
    r'\s*\*|'                         # block comment continuation
    r'\s*\*/|'                        # block comment end
    r'\s*import\s|'                   # import
    r'\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+|open\s+)?'
    r'(?:final\s+)?'
    r'(?:struct|class|enum|protocol|actor|extension)\s|'  # type declarations
    r'\s*@\w+.*(?:struct|class|enum|protocol|actor|extension|func)\s|'  # decorated declarations
    r'\s*typealias\s|'               # typealias
    r'\s*#if\b|'                     # compiler directive
    r'\s*#else|'                     # compiler directive
    r'\s*#elseif|'                   # compiler directive
    r'\s*#endif|'                    # compiler directive
    r'\s*#Preview\b|'               # SwiftUI preview macro
    r'\s*@available|'               # availability attribute (on its own line)
    r'\s*@MainActor\s+(?:struct|class|enum|protocol|actor|func|extension)\s|'  # decorated decl
    r'\s*@objc|'                    # objc attribute
    r'\s*@discardableResult|'       # attribute
    r'\s*\}$'                        # closing brace (part of above)
    r')',
    re.MULTILINE,
)

# Decorators that are only valid when followed by a declaration
_DANGLING_DECORATOR_RE = re.compile(
    r'^(\s*@(?:MainActor|Published|StateObject|ObservedObject|State|Binding|'
    r'Environment|EnvironmentObject|AppStorage|SceneStorage)\s*)$',
    re.MULTILINE,
)


# ---------------------------------------------------------------------------
# Scope tracking — lightweight brace balancer
# ---------------------------------------------------------------------------

def _find_top_level_regions(content: str) -> list[tuple[int, int, str]]:
    """Find regions of top-level code that are outside any type scope.

    Strategy:
    1. Find all top-level declaration boundaries (struct/class/enum/extension/protocol
       opening at depth 0 and their matching closing brace).
    2. Any non-comment, non-import, non-directive line OUTSIDE these boundaries
       is a top-level statement problem.
    3. Also detect dangling decorators at file end without a following declaration.

    Returns list of (start_line, end_line, reason) for problematic regions.
    0-indexed line numbers.
    """
    lines = content.splitlines()
    problems: list[tuple[int, int, str]] = []

    # Phase 1: Find all top-level declaration spans
    # A "span" is from the line of a top-level declaration to its closing brace
    decl_spans: list[tuple[int, int]] = []  # (start_line, end_line) inclusive

    depth = 0
    current_decl_start = -1
    in_block_comment = False

    for i, line in enumerate(lines):
        stripped = line.strip()

        # Track block comments
        if not in_block_comment and "/*" in stripped:
            if "*/" not in stripped[stripped.index("/*") + 2:]:
                in_block_comment = True
                continue
        if in_block_comment:
            if "*/" in stripped:
                in_block_comment = False
            continue

        # Count braces
        line_opens = stripped.count('{') - stripped.count('}')

        if depth == 0 and '{' in stripped:
            # Check if this line starts a top-level declaration
            is_decl = bool(re.match(
                r'^(?:@\w+(?:\(.*?\))?\s+)*'
                r'(?:public\s+|internal\s+|private\s+|fileprivate\s+|open\s+)?'
                r'(?:final\s+)?'
                r'(?:struct|class|enum|protocol|actor|extension)\s',
                stripped,
            ))
            if is_decl:
                current_decl_start = i

        old_depth = depth
        depth += line_opens
        if depth < 0:
            depth = 0

        if old_depth > 0 and depth == 0 and current_decl_start >= 0:
            decl_spans.append((current_decl_start, i))
            current_decl_start = -1

    # Also handle #Preview { ... } and #if/#endif blocks
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("#Preview") or stripped.startswith("#if"):
            # Find the end of this block
            d = 0
            for j in range(i, len(lines)):
                s2 = lines[j].strip()
                if s2.startswith("#endif"):
                    decl_spans.append((i, j))
                    break
                d += s2.count('{') - s2.count('}')
                if d == 0 and j > i and '{' in lines[i]:
                    decl_spans.append((i, j))
                    break

    # Build a set of "inside declaration" line numbers
    inside_decl: set[int] = set()
    for start, end in decl_spans:
        for ln in range(start, end + 1):
            inside_decl.add(ln)

    # Phase 2: Flag lines outside declarations that aren't valid top-level
    for i, line in enumerate(lines):
        if i in inside_decl:
            continue

        stripped = line.strip()
        if not stripped:
            continue

        if not _is_valid_top_level(stripped, i, lines):
            problems.append((i, i, _classify_problem(stripped)))

    return problems


def _is_valid_top_level(stripped: str, line_idx: int = 0, all_lines: list[str] | None = None) -> bool:
    """Check if a stripped line is valid at Swift top level."""
    # Empty or comment
    if not stripped or stripped.startswith("//") or stripped.startswith("/*") or stripped.startswith("*"):
        return True
    # Import
    if stripped.startswith("import "):
        return True
    # Compiler directives
    if stripped.startswith("#if") or stripped.startswith("#else") or stripped.startswith("#endif") or stripped.startswith("#Preview"):
        return True
    # Type/extension declarations (with optional access modifiers and decorators)
    decl_re = re.compile(
        r'^(?:@\w+(?:\(.*?\))?\s+)*'
        r'(?:public\s+|internal\s+|private\s+|fileprivate\s+|open\s+)?'
        r'(?:final\s+)?'
        r'(?:struct|class|enum|protocol|actor|extension|typealias)\s'
    )
    if decl_re.match(stripped):
        return True
    # Closing brace alone (part of a top-level declaration)
    if stripped == '}':
        return True
    # Availability/objc attribute — always valid as annotation
    if stripped.startswith("@available") or stripped.startswith("@objc") or stripped.startswith("@discardableResult"):
        return True
    # Decorator on its own line: only valid if next non-empty line is a declaration
    if stripped.startswith("@") and not stripped.endswith("{"):
        if all_lines:
            for j in range(line_idx + 1, min(line_idx + 3, len(all_lines))):
                next_stripped = all_lines[j].strip()
                if not next_stripped or next_stripped.startswith("//"):
                    continue
                # Check if it's a declaration
                if decl_re.match(next_stripped):
                    return True
                break
        # Dangling decorator without following declaration = invalid
        return False

    return False


def _classify_problem(stripped: str) -> str:
    """Classify the type of top-level problem."""
    if stripped.startswith("let ") or stripped.startswith("var "):
        return "top-level variable"
    if stripped.startswith("print(") or stripped.startswith("assert("):
        return "top-level expression"
    if "(" in stripped and not stripped.startswith("func "):
        return "top-level call/expression"
    if stripped.startswith("if ") or stripped.startswith("for ") or stripped.startswith("switch "):
        return "top-level control flow"
    if stripped.startswith("."):
        return "top-level member access"
    if stripped.startswith("catch ") or stripped.startswith("} catch"):
        return "top-level catch"
    return "top-level statement"


# ---------------------------------------------------------------------------
# Sanitizer
# ---------------------------------------------------------------------------

@dataclass
class SanitizeAction:
    """One file sanitized."""
    file: str
    lines_commented: int
    problems: list[str] = field(default_factory=list)


@dataclass
class SanitizeReport:
    """Summary of sanitization."""
    project: str = ""
    files_scanned: int = 0
    files_sanitized: int = 0
    files_clean: int = 0
    total_lines_commented: int = 0
    actions: list[SanitizeAction] = field(default_factory=list)

    def print_summary(self):
        print()
        print("=" * 60)
        print("  Top-Level Statement Sanitizer (FK-019)")
        print("=" * 60)
        print(f"  Project:            {self.project}")
        print(f"  Files scanned:      {self.files_scanned}")
        print(f"  Files sanitized:    {self.files_sanitized}")
        print(f"  Files clean:        {self.files_clean}")
        print(f"  Lines commented:    {self.total_lines_commented}")
        if self.actions:
            print()
            for a in self.actions:
                print(f"  [SANITIZED] {a.file} ({a.lines_commented} lines)")
                for p in a.problems[:3]:
                    print(f"              {p}")
        print("=" * 60)


class TopLevelSanitizer:
    """Detect and comment out top-level statements in Swift files."""

    def __init__(self, project_name: str, project_dir: Path | None = None):
        self.project_name = project_name
        self.project_dir = project_dir or (_PROJECT_ROOT / "projects" / project_name)
        self.report = SanitizeReport(project=project_name)

    def sanitize(self) -> SanitizeReport:
        """Scan all Swift files and comment out top-level statements."""
        skip_dirs = {"quarantine", "generated", ".git"}

        swift_files = []
        for sf in sorted(self.project_dir.rglob("*.swift")):
            rel_parts = sf.relative_to(self.project_dir).parts
            if rel_parts and rel_parts[0] in skip_dirs:
                continue
            swift_files.append(sf)

        self.report.files_scanned = len(swift_files)
        print(f"[Sanitizer] Scanning {len(swift_files)} Swift files...")

        for sf in swift_files:
            try:
                content = sf.read_text(encoding="utf-8")
            except (OSError, UnicodeDecodeError):
                continue

            problems = _find_top_level_regions(content)
            if not problems:
                self.report.files_clean += 1
                continue

            # Comment out problematic lines AND their brace-balanced blocks
            lines = content.splitlines()
            commented_count = 0
            problem_descs = []
            already_commented: set[int] = set()

            for line_num, _, reason in problems:
                if line_num in already_commented or line_num >= len(lines):
                    continue

                original = lines[line_num]
                if original.strip().startswith("//"):
                    continue

                # Comment out this line
                lines[line_num] = f"// [FK-019 sanitized] {original}"
                already_commented.add(line_num)
                commented_count += 1
                problem_descs.append(f"L{line_num + 1}: {reason}")

                # If this line opens a brace block, comment out everything
                # until the matching closing brace
                open_braces = original.count('{') - original.count('}')
                if open_braces > 0:
                    depth = open_braces
                    for k in range(line_num + 1, len(lines)):
                        if k in already_commented:
                            continue
                        block_line = lines[k]
                        if not block_line.strip().startswith("//"):
                            lines[k] = f"// [FK-019 sanitized] {block_line}"
                            already_commented.add(k)
                            commented_count += 1
                        depth += block_line.count('{') - block_line.count('}')
                        if depth <= 0:
                            break

            if commented_count > 0:
                # Write back
                new_content = "\n".join(lines)
                if content.endswith("\n"):
                    new_content += "\n"
                sf.write_text(new_content, encoding="utf-8")

                rel_path = str(sf.relative_to(self.project_dir))
                self.report.actions.append(SanitizeAction(
                    file=rel_path,
                    lines_commented=commented_count,
                    problems=problem_descs,
                ))
                self.report.files_sanitized += 1
                self.report.total_lines_commented += commented_count
                print(f"  [FK-019] {rel_path}: {commented_count} line(s) commented")
            else:
                self.report.files_clean += 1

        return self.report
