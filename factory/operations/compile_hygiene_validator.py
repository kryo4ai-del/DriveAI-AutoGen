# factory/operations/compile_hygiene_validator.py
# Post-generation Compile Hygiene Validator — Round 2+3
#
# Checks generated Swift artifacts for recurring error patterns
# discovered in Error Pattern Seed Round 1.
#
# Round 2: FK-011, FK-012, FK-015
# Round 3: FK-013, FK-014, FK-017
#
# Deterministic only — no LLM, no automatic fixes.
# Reports issues and classifies hygiene status.

import json
import re
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path

# ---------------------------------------------------------------------------
# Project root — two levels up from this file
# ---------------------------------------------------------------------------
_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "hygiene"


# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------

class HygieneStatus(str, Enum):
    CLEAN = "CLEAN"
    WARNINGS = "WARNINGS"
    BLOCKING = "BLOCKING"


class IssueSeverity(str, Enum):
    BLOCKING = "blocking"
    WARNING = "warning"


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class HygieneIssue:
    """A single detected hygiene issue."""
    pattern_id: str
    severity: IssueSeverity
    file: str
    line: int | None = None
    matched_text: str = ""
    type_name: str = ""
    other_files: list[str] = field(default_factory=list)
    message: str = ""

    def to_dict(self) -> dict:
        d = {
            "pattern_id": self.pattern_id,
            "severity": self.severity.value,
            "file": self.file,
            "message": self.message,
        }
        if self.line is not None:
            d["line"] = self.line
        if self.matched_text:
            d["matched_text"] = self.matched_text
        if self.type_name:
            d["type_name"] = self.type_name
        if self.other_files:
            d["other_files"] = self.other_files
        return d


@dataclass
class HygieneReport:
    """Full hygiene validation report."""
    project: str = ""
    scan_dir: str = ""
    files_scanned: int = 0
    checks_run: list[str] = field(default_factory=list)
    status: HygieneStatus = HygieneStatus.CLEAN
    issues: list[HygieneIssue] = field(default_factory=list)

    @property
    def issues_found(self) -> int:
        return len(self.issues)

    @property
    def blocking_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == IssueSeverity.BLOCKING)

    @property
    def warning_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == IssueSeverity.WARNING)

    def to_dict(self) -> dict:
        return {
            "project": self.project,
            "scan_dir": self.scan_dir,
            "files_scanned": self.files_scanned,
            "checks_run": self.checks_run,
            "status": self.status.value,
            "issues_found": self.issues_found,
            "blocking": self.blocking_count,
            "warnings": self.warning_count,
            "issues": [i.to_dict() for i in self.issues],
        }

    def print_summary(self):
        print()
        print("=" * 60)
        print("  Compile Hygiene Validator")
        print("=" * 60)
        print(f"  Project:        {self.project}")
        print(f"  Scan dir:       {self.scan_dir}")
        print(f"  Files scanned:  {self.files_scanned}")
        print(f"  Checks run:     {', '.join(self.checks_run)}")
        print(f"  Status:         {self.status.value}")
        print("-" * 60)
        print(f"  Issues found:   {self.issues_found}")
        print(f"    Blocking:     {self.blocking_count}")
        print(f"    Warnings:     {self.warning_count}")

        if self.issues:
            print()
            for issue in self.issues:
                severity_tag = "BLOCK" if issue.severity == IssueSeverity.BLOCKING else "WARN "
                loc = f":{issue.line}" if issue.line else ""
                print(f"  [{severity_tag}] {issue.pattern_id}  {issue.file}{loc}")
                print(f"          {issue.message}")
                if issue.matched_text:
                    preview = issue.matched_text[:80]
                    print(f"          > {preview}")
                if issue.other_files:
                    for of in issue.other_files:
                        print(f"          also in: {of}")

        print("=" * 60)
        print()


# ---------------------------------------------------------------------------
# FK-011: AI review text embedded inside source files
# ---------------------------------------------------------------------------

# Patterns that indicate AI review/commentary leaked into Swift code.
# Each tuple: (compiled regex, description)
_AI_CONTAMINATION_PATTERNS: list[tuple[re.Pattern, str]] = [
    # Markdown headings (not inside string literals)
    (re.compile(r'^#{1,4}\s+\w', re.MULTILINE),
     "Markdown heading in Swift file"),

    # Markdown horizontal rules
    (re.compile(r'^---\s*$', re.MULTILINE),
     "Markdown horizontal rule"),

    # Bold markdown syntax
    (re.compile(r'^\*\*[A-Z][^*]+\*\*', re.MULTILINE),
     "Markdown bold text"),

    # Common AI review phrases at line start
    (re.compile(
        r'^\s*(?:Issue:|Fix:|Review:|Recommendation:|Problem:|Solution:|'
        r'Severity:|Root [Cc]ause:|Analysis:|Summary:|Note:)\s',
        re.MULTILINE),
     "AI review label"),

    # Agent self-reference
    (re.compile(
        r"I'm stopping here|I will stop here|Let me review|"
        r"Here's (?:my|the) (?:review|analysis|assessment)|"
        r"Looking at (?:this|the) code",
        re.IGNORECASE),
     "AI agent self-reference"),

    # Numbered review items (1. Issue: ...)
    (re.compile(
        r'^\s*\d+\.\s+(?:Issue|Bug|Problem|Fix|Error)\s*:', re.MULTILINE),
     "Numbered review item"),

    # Bullet point review items outside of doc comments
    (re.compile(r'^- \*\*\w+\*\*:', re.MULTILINE),
     "Markdown bullet with bold label"),
]

# Lines that are safe even if they match (inside string literals or comments)
_SAFE_CONTEXT_RE = re.compile(r'^\s*(?://|/\*|\*|".*")')


def _check_fk011(file_path: Path, content: str, rel_path: str) -> list[HygieneIssue]:
    """Check for AI review text contamination in a Swift source file."""
    issues: list[HygieneIssue] = []
    lines = content.splitlines()

    for pattern, description in _AI_CONTAMINATION_PATTERNS:
        for match in pattern.finditer(content):
            # Find line number
            line_num = content[:match.start()].count('\n') + 1
            line_text = lines[line_num - 1] if line_num <= len(lines) else ""

            # Skip if inside a comment or string literal
            if _SAFE_CONTEXT_RE.match(line_text):
                continue

            issues.append(HygieneIssue(
                pattern_id="FK-011",
                severity=IssueSeverity.BLOCKING,
                file=rel_path,
                line=line_num,
                matched_text=line_text.strip(),
                message=f"AI contamination: {description}",
            ))
            # One match per pattern per file is enough
            break

    return issues


# ---------------------------------------------------------------------------
# FK-012: Duplicate type definitions across files
# ---------------------------------------------------------------------------

# Matches Swift type declarations: struct/class/enum/protocol Name
# Allows optional leading whitespace to catch nested types
_TYPE_DECL_RE = re.compile(
    r'^\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)?'
    r'(?:final\s+)?'
    r'(struct|class|enum|protocol|actor)\s+'
    r'([A-Z][A-Za-z0-9_]+)',
    re.MULTILINE,
)

# Types from Apple frameworks or Swift patterns that can appear in multiple files legitimately
_FRAMEWORK_TYPES = frozenset({
    "String", "Int", "Double", "Bool", "Float", "Date", "UUID",
    "Array", "Dictionary", "Set", "Optional", "Result", "Error",
    "URL", "Data", "Void", "Never", "Any", "AnyObject",
    "View", "App", "Scene", "PreviewProvider",
    # Codable nested enums — every Codable type defines its own CodingKeys
    "CodingKeys", "TypeValue", "CodingKey",
})


def _collect_type_declarations(
    swift_files: dict[str, tuple[Path, str]],
) -> dict[str, list[tuple[str, str, int]]]:
    """Collect all type declarations across all files.

    Returns: {type_name: [(rel_path, kind, line_num), ...]}
    """
    registry: dict[str, list[tuple[str, str, int]]] = {}

    for rel_path, (_, content) in swift_files.items():
        for match in _TYPE_DECL_RE.finditer(content):
            kind = match.group(1)
            name = match.group(2)

            if name in _FRAMEWORK_TYPES:
                continue

            line_num = content[:match.start()].count('\n') + 1

            if name not in registry:
                registry[name] = []
            registry[name].append((rel_path, kind, line_num))

    return registry


def _check_fk012(
    type_registry: dict[str, list[tuple[str, str, int]]],
) -> list[HygieneIssue]:
    """Check for duplicate type definitions."""
    issues: list[HygieneIssue] = []

    for type_name, locations in sorted(type_registry.items()):
        if len(locations) <= 1:
            continue

        # First occurrence is treated as primary
        primary_path, primary_kind, primary_line = locations[0]
        other_files = [f"{loc[0]}:{loc[2]}" for loc in locations[1:]]

        issues.append(HygieneIssue(
            pattern_id="FK-012",
            severity=IssueSeverity.BLOCKING,
            file=primary_path,
            line=primary_line,
            type_name=type_name,
            other_files=other_files,
            message=f"Duplicate {primary_kind} '{type_name}' defined in {len(locations)} files",
        ))

    return issues


# ---------------------------------------------------------------------------
# FK-015: Bundle.module used in normal Xcode app targets
# ---------------------------------------------------------------------------

_BUNDLE_MODULE_RE = re.compile(
    r'Bundle\.module|bundle:\s*\.module',
)


def _check_fk015(
    file_path: Path, content: str, rel_path: str,
) -> list[HygieneIssue]:
    """Check for Bundle.module usage (invalid in regular Xcode app targets)."""
    issues: list[HygieneIssue] = []
    lines = content.splitlines()

    for match in _BUNDLE_MODULE_RE.finditer(content):
        line_num = content[:match.start()].count('\n') + 1
        line_text = lines[line_num - 1] if line_num <= len(lines) else ""

        # Skip if inside a comment
        stripped = line_text.strip()
        if stripped.startswith("//") or stripped.startswith("/*"):
            continue

        issues.append(HygieneIssue(
            pattern_id="FK-015",
            severity=IssueSeverity.WARNING,
            file=rel_path,
            line=line_num,
            matched_text=stripped,
            message="Bundle.module is only available in Swift Package targets, not regular Xcode apps",
        ))
        # One match per file is enough
        break

    return issues


# ---------------------------------------------------------------------------
# FK-013: Wrong parameters at call sites
# ---------------------------------------------------------------------------

# Collect init/func signatures: extract parameter labels from declarations
# Note: uses DOTALL-like matching for multi-line init signatures
_INIT_SIGNATURE_RE = re.compile(
    r'(?:init|func\s+\w+)\s*\(([^)]*)\)',
)

# Multi-line init detection is handled procedurally (see _find_init_params)
# because regex can't reliably match balanced parentheses with defaults like UUID()

# Extract individual parameter labels from a signature
_PARAM_LABEL_RE = re.compile(
    r'(\w+)\s*(?:\s+\w+)?\s*:',
)

# Detect View instantiation: TypeName(param: ..., param: ...)
_VIEW_CALL_RE = re.compile(
    r'([A-Z][A-Za-z0-9_]+)\s*\(([^)]{5,})\)',
)


@dataclass
class _InitBlock:
    """Represents a found init declaration."""
    start: int
    params_str: str

    def group(self, n: int) -> str:
        if n == 1:
            return self.params_str
        return ""


# Find init declarations with balanced parentheses
_INIT_KEYWORD_RE = re.compile(r'\binit\s*\(')


def _find_init_blocks(content: str) -> list[_InitBlock]:
    """Find all init(...) blocks, handling nested parens like UUID()."""
    blocks: list[_InitBlock] = []
    for m in _INIT_KEYWORD_RE.finditer(content):
        start = m.start()
        paren_start = m.end() - 1  # position of '('
        depth = 1
        i = paren_start + 1
        while i < len(content) and depth > 0:
            if content[i] == '(':
                depth += 1
            elif content[i] == ')':
                depth -= 1
            i += 1
        if depth == 0:
            params = content[paren_start + 1 : i - 1]
            blocks.append(_InitBlock(start=start, params_str=params))
    return blocks


def _collect_signatures(
    swift_files: dict[str, tuple[Path, str]],
    type_registry: dict[str, list[tuple[str, str, int]]],
) -> dict[str, list[set[str]]]:
    """Collect init parameter labels for known types.

    Returns: {TypeName: [set_of_param_labels, ...]}
    Each type may have multiple init overloads.

    Only collects EXPLICIT init declarations. Structs with no explicit init
    have an implicit memberwise init that we cannot reliably validate,
    so they are excluded.
    """
    signatures: dict[str, list[set[str]]] = {}

    # Only look at types we know are declared in this project
    known_types = set(type_registry.keys())

    # Regex for explicit init
    explicit_init_re = re.compile(
        r'^\s+(?:public\s+|internal\s+|private\s+|convenience\s+)*'
        r'init\s*\(([^)]*)\)',
        re.MULTILINE,
    )

    # Regex for type declaration start (to scope init to correct type)
    type_start_re = re.compile(
        r'^(?:public\s+|internal\s+|private\s+|fileprivate\s+)?'
        r'(?:final\s+)?'
        r'(?:struct|class)\s+([A-Z][A-Za-z0-9_]+)',
        re.MULTILINE,
    )

    for rel_path, (_, content) in swift_files.items():
        # Find all type declarations and their positions
        type_positions: list[tuple[str, int]] = []
        for m in type_start_re.finditer(content):
            name = m.group(1)
            if name in known_types:
                type_positions.append((name, m.start()))

        if not type_positions:
            continue

        # Also check for extension TypeName { ... init ...
        ext_re = re.compile(
            r'^extension\s+([A-Z][A-Za-z0-9_]+)\s*(?::\s*\w+\s*)?{',
            re.MULTILINE,
        )
        for m in ext_re.finditer(content):
            name = m.group(1)
            if name in known_types:
                type_positions.append((name, m.start()))

        # Sort by position
        type_positions.sort(key=lambda x: x[1])

        # For each init, find which type scope it belongs to.
        # Use procedural parenthesis balancing to handle defaults like UUID()
        for init_match in _find_init_blocks(content):
            init_pos = init_match.start

            # Find the closest type declaration before this init
            owning_type = None
            for name, pos in reversed(type_positions):
                if pos < init_pos:
                    owning_type = name
                    break

            if not owning_type:
                continue

            params_str = init_match.group(1).strip()
            if not params_str:
                continue

            labels = set()
            for param_match in _PARAM_LABEL_RE.finditer(params_str):
                label = param_match.group(1)
                if label != "_":
                    labels.add(label)

            if labels:
                if owning_type not in signatures:
                    signatures[owning_type] = []
                signatures[owning_type].append(labels)

    return signatures


def _check_fk013(
    swift_files: dict[str, tuple[Path, str]],
    type_registry: dict[str, list[tuple[str, str, int]]],
) -> list[HygieneIssue]:
    """Check for call-site parameter mismatches.

    Compares parameter labels used at call sites against known init signatures.
    Only flags when ALL labels at a call site are unknown to ALL known signatures.
    """
    issues: list[HygieneIssue] = []
    signatures = _collect_signatures(swift_files, type_registry)

    if not signatures:
        return issues

    for rel_path, (_, content) in swift_files.items():
        lines = content.splitlines()

        for call_match in _VIEW_CALL_RE.finditer(content):
            type_name = call_match.group(1)
            args_str = call_match.group(2)

            # Only check types we have EXPLICIT init signatures for.
            # Types without explicit init use implicit memberwise init
            # which we can't validate without full Swift parsing.
            if type_name not in signatures:
                continue

            # Skip if this looks like a function call context
            call_start = call_match.start()
            prefix = content[max(0, call_start - 50):call_start]
            # Skip: func definition, await/try context with lowercase func name
            if re.search(r'(?:func\s+|\.)\s*$', prefix):
                continue
            # Skip if preceded by lowercase word (e.g. "startTrainingSession(")
            if re.search(r'[a-z]\s*$', prefix):
                continue

            # Extract labels used at the call site
            call_labels = set()
            for param_match in _PARAM_LABEL_RE.finditer(args_str):
                call_labels.add(param_match.group(1))

            if not call_labels:
                continue

            # Check against all known signatures for this type
            known_sigs = signatures[type_name]
            best_match_ratio = 0.0

            for sig_labels in known_sigs:
                if not sig_labels:
                    continue
                # How many call labels are in this signature?
                matched = call_labels & sig_labels
                ratio = len(matched) / len(call_labels) if call_labels else 0
                best_match_ratio = max(best_match_ratio, ratio)

            # Flag if less than 50% of call labels match any known signature
            if best_match_ratio < 0.5 and len(call_labels) >= 2:
                line_num = content[:call_match.start()].count('\n') + 1
                line_text = lines[line_num - 1] if line_num <= len(lines) else ""

                # Skip if inside a comment
                stripped = line_text.strip()
                if stripped.startswith("//") or stripped.startswith("/*"):
                    continue

                # High confidence if 0% match, warning if partial
                severity = (
                    IssueSeverity.BLOCKING
                    if best_match_ratio == 0
                    else IssueSeverity.WARNING
                )

                issues.append(HygieneIssue(
                    pattern_id="FK-013",
                    severity=severity,
                    file=rel_path,
                    line=line_num,
                    type_name=type_name,
                    matched_text=stripped[:100],
                    message=(
                        f"Call to {type_name}() uses labels {sorted(call_labels)} — "
                        f"no known init matches ({int(best_match_ratio*100)}% match)"
                    ),
                ))

    return issues


# ---------------------------------------------------------------------------
# FK-014: Referenced types never generated
# ---------------------------------------------------------------------------

# Type references: used as type annotation, generic parameter, or conformance
_TYPE_REFERENCE_RE = re.compile(
    r'(?<![A-Za-z0-9_])'  # not preceded by word char
    r'([A-Z][A-Za-z0-9_]{3,})'  # PascalCase name, min 4 chars
    r'(?![A-Za-z0-9_(])'  # not followed by word char or opening paren (to skip func calls mostly)
)

# Extended framework/stdlib types to exclude from missing-type detection
_KNOWN_FRAMEWORK_TYPES = _FRAMEWORK_TYPES | frozenset({
    # SwiftUI
    "AnyView", "EmptyView", "Text", "Image", "Button", "NavigationView",
    "NavigationStack", "NavigationLink", "TabView", "List", "ForEach",
    "VStack", "HStack", "ZStack", "ScrollView", "LazyVStack", "LazyHStack",
    "LazyVGrid", "LazyHGrid", "GridItem", "Spacer", "Divider", "Group",
    "Section", "Form", "Label", "Toggle", "Picker", "Slider", "Stepper",
    "TextField", "TextEditor", "SecureField", "DatePicker", "ColorPicker",
    "ProgressView", "Gauge", "Link", "Menu", "ContextMenu", "Alert",
    "Sheet", "ActionSheet", "Popover", "GeometryReader", "Color",
    "Font", "EdgeInsets", "Alignment", "Axis", "ContentView",
    "StateObject", "ObservedObject", "EnvironmentObject", "Binding",
    "Published", "ObservableObject", "State", "Environment",
    "ViewModifier", "ViewBuilder", "PreviewProvider", "Previews",
    "Animation", "AnyTransition", "Shape", "Path", "Circle",
    "Rectangle", "RoundedRectangle", "Capsule", "Ellipse",
    "LinearGradient", "RadialGradient", "AngularGradient",
    "CGFloat", "CGPoint", "CGSize", "CGRect",
    # Foundation
    "JSONEncoder", "JSONDecoder", "FileManager", "UserDefaults",
    "NotificationCenter", "DispatchQueue", "Task", "MainActor",
    "Cancellable", "AnyCancellable", "PassthroughSubject",
    "CurrentValueSubject", "Just", "AnyPublisher", "Timer",
    "Calendar", "DateFormatter", "NumberFormatter",
    "NSObject", "Bundle", "Locale", "TimeInterval", "IndexSet",
    # Combine
    "Combine", "ObservableObject", "Published",
    # Common protocols
    "Identifiable", "Codable", "Decodable", "Encodable",
    "Hashable", "Equatable", "Comparable", "CustomStringConvertible",
    "CaseIterable", "RawRepresentable", "Sendable",
    "LocalizedError", "Error",
    # Common types in iOS
    "UIImage", "UIColor", "UIFont", "UIApplication",
    "WKWebView", "AVPlayer", "CLLocation",
    "LocalizedStringKey",
    # Swift keywords that look like types
    "Self", "Type", "Protocol", "AnyType",
    # Swift Codable protocol types
    "CodingKey", "CodingKeys", "Decoder", "Encoder",
    "KeyedDecodingContainer", "KeyedEncodingContainer",
    "SingleValueDecodingContainer", "SingleValueEncodingContainer",
    "UnkeyedDecodingContainer", "UnkeyedEncodingContainer",
    # Framework module names (appear in import statements)
    "SwiftUI", "Foundation", "Combine", "UIKit", "CoreData",
    "MapKit", "CoreLocation", "AVFoundation", "WebKit",
    "StoreKit", "GameKit", "CloudKit", "HealthKit",
    # SwiftUI preview
    "Preview", "Previews", "PreviewProvider",
    # UIKit types
    "UIAccessibility", "UIScreen", "UIDevice", "UIWindow",
    "UIViewController", "UINavigationController", "UITabBarController",
    # Compiler directives and debug
    "DEBUG", "RELEASE", "SWIFT_PACKAGE",
    # Common patterns that aren't user types
    "TODO", "FIXME", "MARK", "NOTE",
    "TypeValue", "TypeName", "ClassName",
})

# Additional patterns to skip: generic type parameters, closure params
_GENERIC_PARAM_CONTEXT_RE = re.compile(r'<[^>]*>')


def _collect_type_references(
    swift_files: dict[str, tuple[Path, str]],
) -> dict[str, list[str]]:
    """Collect all PascalCase type references across files.

    Returns: {TypeName: [file1, file2, ...]}
    """
    references: dict[str, list[str]] = {}

    for rel_path, (_, content) in swift_files.items():
        # Remove string literals to avoid false positives
        cleaned = re.sub(r'"[^"]*"', '""', content)
        # Remove comments
        cleaned = re.sub(r'//[^\n]*', '', cleaned)
        cleaned = re.sub(r'/\*.*?\*/', '', cleaned, flags=re.DOTALL)

        seen_in_file: set[str] = set()
        for match in _TYPE_REFERENCE_RE.finditer(cleaned):
            name = match.group(1)
            if name not in seen_in_file:
                seen_in_file.add(name)
                if name not in references:
                    references[name] = []
                references[name].append(rel_path)

    return references


def _check_fk014(
    swift_files: dict[str, tuple[Path, str]],
    type_registry: dict[str, list[tuple[str, str, int]]],
) -> list[HygieneIssue]:
    """Check for referenced types that have no declaration in the project.

    Only flags types that:
    - Are referenced in 2+ files (reduces noise from local aliases)
    - Are not in the known framework/stdlib set
    - Have no declaration in the type registry
    """
    issues: list[HygieneIssue] = []

    references = _collect_type_references(swift_files)
    declared_types = set(type_registry.keys())

    for type_name, ref_files in sorted(references.items()):
        # Skip framework types
        if type_name in _KNOWN_FRAMEWORK_TYPES:
            continue

        # Skip if declared in the project
        if type_name in declared_types:
            continue

        # Skip single-file references (likely local/contextual)
        unique_files = sorted(set(ref_files))
        if len(unique_files) < 2:
            continue

        # Skip common suffixes that are often protocol conformances or annotations
        if type_name.endswith("Delegate") or type_name.endswith("DataSource"):
            continue

        issues.append(HygieneIssue(
            pattern_id="FK-014",
            severity=IssueSeverity.BLOCKING,
            file=unique_files[0],
            type_name=type_name,
            other_files=unique_files[1:],
            message=(
                f"Type '{type_name}' referenced in {len(unique_files)} files "
                f"but never declared in project"
            ),
        ))

    return issues


# ---------------------------------------------------------------------------
# FK-017: Namespace collisions between feature layers
# ---------------------------------------------------------------------------

# Generic type names that are high-risk for cross-layer collision
_COLLISION_RISK_NAMES = frozenset({
    "Question", "Answer", "Category", "Session", "Result",
    "Item", "Card", "Cell", "Row", "Section", "Header",
    "Detail", "Summary", "Stats", "Status", "State",
    "Config", "Settings", "Preferences", "Options",
    "Manager", "Handler", "Controller", "Coordinator",
    "Response", "Request", "Model", "Entity",
})

# Detect feature layer from path: e.g. "Premium/Models/..." -> "Premium"
_LAYER_PATH_RE = re.compile(
    r'^(?:.*?/)?([A-Z][A-Za-z0-9]+)/'
    r'(?:Models|Views|ViewModels|Services|App|Components)/',
)


def _check_fk017(
    type_registry: dict[str, list[tuple[str, str, int]]],
) -> list[HygieneIssue]:
    """Check for namespace collisions between feature layers.

    Detects:
    1. Generic high-risk type names used without a layer prefix
    2. Same type name appearing in files from different feature layers
    """
    issues: list[HygieneIssue] = []

    for type_name, locations in sorted(type_registry.items()):
        if len(locations) <= 1:
            continue  # Already covered by FK-012 for single declarations

        # Check if locations span different feature layers
        layers: dict[str, list[str]] = {}
        for rel_path, kind, line_num in locations:
            layer_match = _LAYER_PATH_RE.match(rel_path)
            layer = layer_match.group(1) if layer_match else "_root"
            if layer not in layers:
                layers[layer] = []
            layers[layer].append(f"{rel_path}:{line_num}")

        # If same type exists in multiple layers -> collision
        if len(layers) > 1:
            all_files = []
            for layer_files in layers.values():
                all_files.extend(layer_files)

            issues.append(HygieneIssue(
                pattern_id="FK-017",
                severity=IssueSeverity.BLOCKING,
                file=all_files[0].split(":")[0],
                type_name=type_name,
                other_files=all_files[1:],
                message=(
                    f"Type '{type_name}' defined across {len(layers)} feature layers: "
                    f"{', '.join(sorted(layers.keys()))}. "
                    f"Risk of namespace collision — consider prefixing."
                ),
            ))
            continue

        # For single-layer types: warn if using a generic high-risk name
        # without a layer/feature prefix
        if type_name in _COLLISION_RISK_NAMES:
            primary_path = locations[0][0]
            issues.append(HygieneIssue(
                pattern_id="FK-017",
                severity=IssueSeverity.WARNING,
                file=primary_path,
                type_name=type_name,
                message=(
                    f"Generic type name '{type_name}' has high collision risk. "
                    f"Consider prefixing with feature/domain name."
                ),
            ))

    return issues


# ---------------------------------------------------------------------------
# Status classification
# ---------------------------------------------------------------------------

def classify_status(issues: list[HygieneIssue]) -> HygieneStatus:
    """Classify hygiene status based on issues found.

    - CLEAN: no issues
    - WARNINGS: only warning-level findings (FK-015, low-confidence FK-013, FK-017 warnings)
    - BLOCKING: any blocking finding (FK-011, FK-012, FK-014, FK-017 cross-layer,
                or high-confidence FK-013)
    """
    if not issues:
        return HygieneStatus.CLEAN

    has_blocking = any(i.severity == IssueSeverity.BLOCKING for i in issues)
    if has_blocking:
        return HygieneStatus.BLOCKING

    return HygieneStatus.WARNINGS


# ---------------------------------------------------------------------------
# Main validator
# ---------------------------------------------------------------------------

class CompileHygieneValidator:
    """Post-generation validator for Swift compile hygiene.

    Checks:
    - FK-011: AI review text in source files
    - FK-012: Duplicate type definitions
    - FK-013: Wrong parameters at call sites
    - FK-014: Referenced types never generated
    - FK-015: Bundle.module in regular Xcode targets
    - FK-017: Namespace collisions between feature layers
    """

    def __init__(
        self,
        project_name: str,
        scan_dir: str | None = None,
    ):
        self.project_name = project_name

        if scan_dir:
            self.scan_dir = Path(scan_dir)
        else:
            # Default: projects/<name>/ (scan all .swift recursively)
            self.scan_dir = _PROJECT_ROOT / "projects" / project_name

        self.report = HygieneReport(
            project=project_name,
            scan_dir=str(self.scan_dir),
            checks_run=["FK-011", "FK-012", "FK-013", "FK-014", "FK-015", "FK-017"],
        )

    def validate(self) -> HygieneReport:
        """Run all hygiene checks and produce report."""
        print(f"\n[CompileHygiene] Validating project: {self.project_name}")
        print(f"[CompileHygiene] Scan dir: {self.scan_dir}")

        # Step 1: Discover and read all Swift files
        swift_files = self._discover_swift_files()
        self.report.files_scanned = len(swift_files)
        print(f"[CompileHygiene] Swift files found: {len(swift_files)}")

        if not swift_files:
            print("[CompileHygiene] No Swift files found — nothing to validate.")
            self.report.status = HygieneStatus.CLEAN
            self._print_and_save()
            return self.report

        # Step 2: Run per-file checks (FK-011, FK-015)
        for rel_path, (file_path, content) in swift_files.items():
            self.report.issues.extend(_check_fk011(file_path, content, rel_path))
            self.report.issues.extend(_check_fk015(file_path, content, rel_path))

        # Step 3: Build type registry (shared by FK-012, FK-013, FK-014, FK-017)
        type_registry = _collect_type_declarations(swift_files)

        # Step 4: Run cross-file checks
        self.report.issues.extend(_check_fk012(type_registry))
        self.report.issues.extend(_check_fk013(swift_files, type_registry))
        self.report.issues.extend(_check_fk014(swift_files, type_registry))
        self.report.issues.extend(_check_fk017(type_registry))

        # Step 5: Classify status
        self.report.status = classify_status(self.report.issues)

        # Step 6: Report
        self._print_and_save()

        return self.report

    def _discover_swift_files(self) -> dict[str, tuple[Path, str]]:
        """Discover all .swift files in scan_dir.

        Returns: {relative_path: (absolute_path, content)}
        """
        files: dict[str, tuple[Path, str]] = {}

        if not self.scan_dir.exists():
            print(f"[CompileHygiene] Directory not found: {self.scan_dir}")
            return files

        for swift_file in sorted(self.scan_dir.rglob("*.swift")):
            try:
                content = swift_file.read_text(encoding="utf-8", errors="replace")
            except (OSError, IOError):
                continue

            rel_path = str(swift_file.relative_to(self.scan_dir))
            # Normalize path separators
            rel_path = rel_path.replace("\\", "/")
            files[rel_path] = (swift_file, content)

        return files

    def _print_and_save(self):
        """Print summary and write JSON report."""
        self.report.print_summary()
        self._write_report_json()

    def _write_report_json(self):
        """Write report as JSON to factory/reports/hygiene/."""
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        report_path = REPORTS_DIR / f"{self.project_name}_compile_hygiene.json"

        try:
            report_path.write_text(
                json.dumps(self.report.to_dict(), indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print(f"[CompileHygiene] Report written to: {report_path}")
        except (OSError, IOError) as e:
            print(f"[CompileHygiene] Error writing report: {e}")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    """Run the compile hygiene validator from the command line."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Factory Compile Hygiene Validator — checks FK-011, FK-012, FK-013, FK-014, FK-015, FK-017"
    )
    parser.add_argument(
        "--project", default="askfin_v1-1",
        help="Project name (default: askfin_v1-1)"
    )
    parser.add_argument(
        "--scan-dir", default=None,
        help="Override scan directory (default: projects/<project>/)"
    )
    args = parser.parse_args()

    validator = CompileHygieneValidator(
        project_name=args.project,
        scan_dir=args.scan_dir,
    )
    report = validator.validate()

    # Exit code: 0 = clean/warnings, 1 = blocking
    exit(1 if report.status == HygieneStatus.BLOCKING else 0)


if __name__ == "__main__":
    main()
