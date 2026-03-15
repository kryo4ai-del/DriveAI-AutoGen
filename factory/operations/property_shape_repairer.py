# factory/operations/property_shape_repairer.py
# Post-hygiene FK-013 property-shape repair.
#
# When CompileHygiene detects FK-013 (call-site uses init labels that don't
# match any known init), and the struct has no stored properties (shape
# mismatch), this repairer infers the intended properties from call-site
# arguments and adds them to the struct.
#
# Deterministic, no LLM. Infers types from argument values using heuristics.

import json
import re
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "shape_repairs"

# ---------------------------------------------------------------------------
# Type inference heuristics from argument values
# ---------------------------------------------------------------------------

# Regex to extract label: value pairs from a multi-line call site
_ARG_PAIR_RE = re.compile(
    r'(\w+)\s*:\s*(.+?)(?:,\s*$|$)',
    re.MULTILINE,
)

# View call regex for finding the full call site (multi-line)
_CALL_SITE_RE = re.compile(
    r'([A-Z][A-Za-z0-9_]+)\s*\(',
)


def _infer_type(label: str, value: str) -> str:
    """Infer Swift type from a label name and its argument value."""
    value = value.strip().rstrip(",")

    # Explicit type patterns from value
    if value.startswith('"') or value.startswith("\""):
        return "String"
    if value in ("true", "false"):
        return "Bool"
    if value == "Date()":
        return "Date"
    if re.match(r'^\d+\.\d+$', value):
        return "Double"
    if re.match(r'^\d+$', value):
        return "Int"
    if value.startswith("["):
        # Array — try to infer element type from content
        inner = value[1:].strip()
        if inner.startswith("]") or not inner:
            return "[Any]"
        # Look for type name at start of first element
        type_match = re.match(r'([A-Z][A-Za-z0-9_]+)\s*\(', inner)
        if type_match:
            return f"[{type_match.group(1)}]"
        return "[Any]"
    if re.match(r'^[A-Z][A-Za-z0-9_]+\(', value):
        # Constructor call — extract type name
        type_match = re.match(r'([A-Z][A-Za-z0-9_]+)\s*\(', value)
        if type_match:
            return type_match.group(1)

    # Infer from label name conventions
    label_lower = label.lower()
    if label_lower.endswith("date") or label_lower in ("lastUpdated", "createdAt"):
        return "Date"
    if label_lower.endswith("percentage") or label_lower.endswith("score"):
        return "Double"
    if label_lower.endswith("count") or label_lower.endswith("days") or label_lower == "currentStreak":
        return "Int"
    if label_lower.endswith("name") or label_lower.endswith("title") or label_lower.endswith("id"):
        return "String"
    if label_lower.startswith("is") or label_lower.startswith("has") or label_lower.startswith("should"):
        return "Bool"
    if label_lower.endswith("categories") or label_lower.endswith("items") or label_lower.endswith("breakdown"):
        return "[String]"

    return "Any"


def _extract_call_site_args(content: str, type_name: str) -> list[tuple[str, str]]:
    """Extract (label, value) pairs from the first call site of type_name.

    Handles multi-line Swift call sites with balanced parentheses.
    """
    # Find the call site
    pattern = re.compile(rf'{re.escape(type_name)}\s*\(')
    match = pattern.search(content)
    if not match:
        return []

    # Extract balanced parentheses content
    paren_start = match.end() - 1
    depth = 1
    i = paren_start + 1
    while i < len(content) and depth > 0:
        if content[i] == '(':
            depth += 1
        elif content[i] == ')':
            depth -= 1
        i += 1

    if depth != 0:
        return []

    args_str = content[paren_start + 1: i - 1]

    # Parse label: value pairs
    # Split by top-level commas (not inside nested parens/brackets)
    pairs: list[tuple[str, str]] = []
    current_label = ""
    current_value = ""
    paren_depth = 0
    bracket_depth = 0
    in_label = True

    for char in args_str + ",":
        if char == '(':
            paren_depth += 1
        elif char == ')':
            paren_depth -= 1
        elif char == '[':
            bracket_depth += 1
        elif char == ']':
            bracket_depth -= 1

        if char == ':' and in_label and paren_depth == 0 and bracket_depth == 0:
            in_label = False
            continue
        elif char == ',' and paren_depth == 0 and bracket_depth == 0:
            label = current_label.strip()
            value = current_value.strip()
            if label and value:
                pairs.append((label, value))
            current_label = ""
            current_value = ""
            in_label = True
            continue

        if in_label:
            current_label += char
        else:
            current_value += char

    return pairs


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class RepairAction:
    """One property-shape repair applied."""
    type_name: str
    file_path: str
    properties_added: list[tuple[str, str]]  # (name, type)
    source_call_site: str  # file where the call site was found


@dataclass
class RepairReport:
    """Summary of property-shape repairs."""
    project: str = ""
    fk013_blocking_count: int = 0
    repairs_applied: int = 0
    repairs_skipped: int = 0
    actions: list[RepairAction] = field(default_factory=list)
    skipped: list[dict] = field(default_factory=list)

    def print_summary(self):
        print()
        print("=" * 60)
        print("  Property Shape Repairer (FK-013)")
        print("=" * 60)
        print(f"  Project:            {self.project}")
        print(f"  FK-013 blockers:    {self.fk013_blocking_count}")
        print(f"  Repairs applied:    {self.repairs_applied}")
        print(f"  Repairs skipped:    {self.repairs_skipped}")
        if self.actions:
            print()
            for a in self.actions:
                print(f"  [REPAIRED] {a.type_name} in {a.file_path}")
                print(f"             Source: {a.source_call_site}")
                for name, typ in a.properties_added:
                    print(f"             + let {name}: {typ}")
        if self.skipped:
            print()
            for s in self.skipped:
                print(f"  [SKIPPED] {s['type_name']}: {s['reason']}")
        print("=" * 60)


# ---------------------------------------------------------------------------
# Struct property detection
# ---------------------------------------------------------------------------

_STORED_PROP_RE = re.compile(
    r'^\s+(?:let|var)\s+(\w+)\s*:', re.MULTILINE,
)

_STRUCT_DECL_RE = re.compile(
    r'^(struct\s+[A-Z][A-Za-z0-9_]+[^\{]*\{)',
    re.MULTILINE,
)


def _count_stored_properties(content: str, type_name: str) -> int:
    """Count stored properties in a struct definition."""
    # Find the struct block
    pattern = re.compile(
        rf'^(?:public\s+|internal\s+)?struct\s+{re.escape(type_name)}\b',
        re.MULTILINE,
    )
    match = pattern.search(content)
    if not match:
        return -1  # struct not found

    # Find opening brace
    brace_pos = content.find('{', match.end())
    if brace_pos == -1:
        return -1

    # Find matching closing brace
    depth = 1
    i = brace_pos + 1
    while i < len(content) and depth > 0:
        if content[i] == '{':
            depth += 1
        elif content[i] == '}':
            depth -= 1
        i += 1

    struct_body = content[brace_pos + 1: i - 1]

    # SwiftUI property wrappers — these are NOT part of memberwise init
    _SWIFTUI_WRAPPERS = {
        "@State", "@Binding", "@Environment", "@EnvironmentObject",
        "@ObservedObject", "@StateObject", "@Published", "@AppStorage",
        "@SceneStorage", "@FocusState", "@GestureState", "@Namespace",
        "@FetchRequest", "@Query",
    }

    # Match first-indentation-level let/var declarations.
    # Also captures the full line prefix to detect property wrappers.
    direct_prop_re = re.compile(
        r'^(    (?:@\w+(?:\(.*?\))?\s+)*)(let|var)\s+(\w+)\s*:(.*?)$',
        re.MULTILINE,
    )
    count = 0
    for prop_match in direct_prop_re.finditer(struct_body):
        prefix = prop_match.group(1).strip()   # e.g. "@State" or "@Binding"
        prop_name = prop_match.group(3)
        type_and_rest = prop_match.group(4)

        # Skip property-wrapper members (not part of memberwise init)
        if any(prefix.startswith(w) for w in _SWIFTUI_WRAPPERS):
            continue

        # Skip computed properties: type annotation followed by { on the
        # SAME LINE. Covers `var body: some View {` and similar.
        # Only check the current line's remainder — never look past newlines
        # to avoid false positives from init/func blocks below.
        same_line_rest = type_and_rest.strip()
        if same_line_rest.endswith("{"):
            # { at end of same line → computed property (e.g. `var body: some View {`)
            eq_pos = same_line_rest.find('=')
            brace_pos_la = same_line_rest.rfind('{')
            if eq_pos == -1 or brace_pos_la < eq_pos:
                continue

        count += 1

    return count


def _insert_properties(content: str, type_name: str,
                       properties: list[tuple[str, str]]) -> str | None:
    """Insert stored properties into a struct definition.

    Returns modified content, or None if the struct cannot be found or
    already has stored properties.
    """
    pattern = re.compile(
        rf'^((?:public\s+|internal\s+)?struct\s+{re.escape(type_name)}[^\{{]*\{{)',
        re.MULTILINE,
    )
    match = pattern.search(content)
    if not match:
        return None

    insert_pos = match.end()

    # Build property block
    prop_lines = ["\n"]
    for name, typ in properties:
        prop_lines.append(f"    let {name}: {typ}\n")

    prop_block = "".join(prop_lines)

    return content[:insert_pos] + prop_block + content[insert_pos:]


# ---------------------------------------------------------------------------
# Main repairer
# ---------------------------------------------------------------------------

class PropertyShapeRepairer:
    """Repair struct property shapes based on FK-013 call-site evidence."""

    def __init__(self, project_name: str, project_dir: Path | None = None):
        self.project_name = project_name
        self.project_dir = project_dir or (_PROJECT_ROOT / "projects" / project_name)
        self.report = RepairReport(project=project_name)

    def repair_from_hygiene(self, hygiene_report) -> RepairReport:
        """Process FK-013 BLOCKING issues and attempt property-shape repairs.

        Only repairs structs that have 0 stored properties (clear shape
        mismatch). Structs with existing properties are skipped to avoid
        destructive changes.
        """
        # Extract FK-013 BLOCKING issues
        fk013_blocking = [
            issue for issue in hygiene_report.issues
            if issue.pattern_id == "FK-013"
            and issue.severity.value == "blocking"
        ]
        self.report.fk013_blocking_count = len(fk013_blocking)

        if not fk013_blocking:
            print("[ShapeRepair] No FK-013 blocking issues -- nothing to repair.")
            return self.report

        print(f"[ShapeRepair] Processing {len(fk013_blocking)} FK-013 blocker(s)...")

        for issue in fk013_blocking:
            type_name = issue.type_name
            call_site_file = issue.file

            # Find the struct definition file
            struct_files = list(self.project_dir.rglob("*.swift"))
            struct_file = None
            struct_content = None

            type_decl_re = re.compile(
                rf'^(?:public\s+|internal\s+)?struct\s+{re.escape(type_name)}\b',
                re.MULTILINE,
            )

            for sf in struct_files:
                try:
                    c = sf.read_text(encoding="utf-8")
                except (OSError, UnicodeDecodeError):
                    continue
                if type_decl_re.search(c):
                    struct_file = sf
                    struct_content = c
                    break

            if not struct_file or not struct_content:
                self.report.skipped.append({
                    "type_name": type_name,
                    "reason": f"struct {type_name} not found in project",
                })
                self.report.repairs_skipped += 1
                continue

            # Check if struct already has stored properties
            prop_count = _count_stored_properties(struct_content, type_name)
            if prop_count > 0:
                self.report.skipped.append({
                    "type_name": type_name,
                    "reason": f"struct already has {prop_count} stored properties",
                })
                self.report.repairs_skipped += 1
                continue

            if prop_count == -1:
                self.report.skipped.append({
                    "type_name": type_name,
                    "reason": "could not parse struct body",
                })
                self.report.repairs_skipped += 1
                continue

            # Find the call site to extract argument shapes
            call_site_path = self.project_dir / call_site_file
            if not call_site_path.exists():
                self.report.skipped.append({
                    "type_name": type_name,
                    "reason": f"call site file not found: {call_site_file}",
                })
                self.report.repairs_skipped += 1
                continue

            call_content = call_site_path.read_text(encoding="utf-8")
            arg_pairs = _extract_call_site_args(call_content, type_name)

            if not arg_pairs:
                self.report.skipped.append({
                    "type_name": type_name,
                    "reason": "could not parse call-site arguments",
                })
                self.report.repairs_skipped += 1
                continue

            # Infer property types from argument values
            properties: list[tuple[str, str]] = []
            for label, value in arg_pairs:
                inferred_type = _infer_type(label, value)
                properties.append((label, inferred_type))

            # Insert properties into the struct
            modified = _insert_properties(struct_content, type_name, properties)
            if modified is None:
                self.report.skipped.append({
                    "type_name": type_name,
                    "reason": "could not insert properties into struct",
                })
                self.report.repairs_skipped += 1
                continue

            # Write back
            struct_file.write_text(modified, encoding="utf-8")
            rel_path = str(struct_file.relative_to(self.project_dir))

            self.report.actions.append(RepairAction(
                type_name=type_name,
                file_path=rel_path,
                properties_added=properties,
                source_call_site=call_site_file,
            ))
            self.report.repairs_applied += 1
            print(f"  [REPAIR] {type_name} in {rel_path}")
            for name, typ in properties:
                print(f"           + let {name}: {typ}")

        # Save report
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        report_path = REPORTS_DIR / f"{self.project_name}_shape_repairs.json"
        report_dict = {
            "project": self.report.project,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "fk013_blocking_count": self.report.fk013_blocking_count,
            "repairs_applied": self.report.repairs_applied,
            "repairs_skipped": self.report.repairs_skipped,
            "actions": [
                {
                    "type_name": a.type_name,
                    "file_path": a.file_path,
                    "properties_added": [
                        {"name": n, "type": t} for n, t in a.properties_added
                    ],
                    "source_call_site": a.source_call_site,
                }
                for a in self.report.actions
            ],
            "skipped": self.report.skipped,
        }
        report_path.write_text(json.dumps(report_dict, indent=2), encoding="utf-8")
        print(f"\n[ShapeRepair] Report written to: {report_path}")

        return self.report
