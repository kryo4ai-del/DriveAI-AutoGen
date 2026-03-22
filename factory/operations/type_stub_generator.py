# factory/operations/type_stub_generator.py
# Post-hygiene FK-014 stub generator.
#
# When CompileHygiene detects FK-014 (type referenced but never declared),
# this generator creates minimal Swift stub files so the project can compile.
#
# Deterministic, no LLM. Stubs are scaffolds — real implementations should
# replace them in a later pass.

import json
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "stubs"


# ---------------------------------------------------------------------------
# Heuristics for stub kind (struct vs enum vs protocol vs class)
# ---------------------------------------------------------------------------

_PROTOCOL_SUFFIXES = (
    "Protocol", "Delegate", "DataSource", "ServiceProtocol",
    "RepositoryProtocol", "Providing", "Configurable",
)

_SERVICE_SUFFIXES = (
    "Service", "Manager", "Controller", "Handler", "Provider",
    "Repository", "Store", "Cache", "Client", "API",
)

_ENUM_SUFFIXES = (
    "Level", "Status", "State", "Type", "Kind", "Mode", "Style",
    "Priority", "Category",
)

_VIEW_SUFFIXES = (
    "View", "Screen", "Page", "Cell", "Row",
)

_VIEWMODEL_SUFFIXES = (
    "ViewModel", "VM",
)


def _infer_kind(type_name: str) -> str:
    """Infer Swift type kind from naming convention."""
    if type_name.endswith(_PROTOCOL_SUFFIXES):
        return "protocol"
    if type_name.endswith(_VIEWMODEL_SUFFIXES):
        return "class"
    if type_name.endswith(_VIEW_SUFFIXES):
        return "view"
    if type_name.endswith(_ENUM_SUFFIXES):
        return "enum"
    if type_name.endswith(_SERVICE_SUFFIXES):
        return "class"
    return "struct"


def _infer_folder(kind: str) -> str:
    """Infer target subfolder from type kind."""
    if kind == "protocol":
        return "Services"
    if kind == "class":
        return "Services"
    if kind == "view":
        return "Views"
    if kind == "enum":
        return "Models"
    return "Models"


def _generate_stub(type_name: str, kind: str, ref_files: list[str]) -> str:
    """Generate a minimal Swift stub for a missing type."""
    refs = "\n".join(f"//   - {f}" for f in ref_files[:5])
    header = (
        f"// {type_name}.swift\n"
        f"// Auto-generated stub — type was referenced but never declared.\n"
        f"// Referenced in:\n"
        f"{refs}\n"
        f"//\n"
        f"// TODO: Replace this stub with a full implementation.\n\n"
        f"import Foundation\n\n"
    )

    if kind == "protocol":
        return header + f"protocol {type_name} {{\n    // Add required members\n}}\n"
    if kind == "enum":
        return header + (
            f"enum {type_name}: String, Sendable {{\n"
            f"    case unknown\n"
            f"    // Add real cases\n"
            f"}}\n"
        )
    if kind == "view":
        return (
            f"// {type_name}.swift\n"
            f"// Auto-generated stub view.\n\n"
            f"import SwiftUI\n\n"
            f"struct {type_name}: View {{\n"
            f"    var body: some View {{\n"
            f"        Text(\"{type_name} — stub\")\n"
            f"    }}\n"
            f"}}\n"
        )
    if kind == "class":
        return header + (
            f"final class {type_name}: @unchecked Sendable {{\n"
            f"    // Add implementation\n"
            f"}}\n"
        )
    # Default: struct
    return header + f"struct {type_name}: Sendable {{\n    // Add properties\n}}\n"


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class StubAction:
    """One stub file created."""
    type_name: str
    kind: str
    file_path: str
    ref_files: list[str] = field(default_factory=list)


@dataclass
class StubReport:
    """Summary of stub generation."""
    project: str = ""
    fk014_count: int = 0
    stubs_created: int = 0
    stubs_skipped: int = 0
    actions: list[StubAction] = field(default_factory=list)
    skipped: list[dict] = field(default_factory=list)

    def print_summary(self):
        print()
        print("=" * 60)
        print("  Type Stub Generator (FK-014)")
        print("=" * 60)
        print(f"  Project:          {self.project}")
        print(f"  FK-014 findings:  {self.fk014_count}")
        print(f"  Stubs created:    {self.stubs_created}")
        print(f"  Stubs skipped:    {self.stubs_skipped}")
        if self.actions:
            print()
            for a in self.actions:
                print(f"  [CREATED] {a.type_name} ({a.kind}) -> {a.file_path}")
        if self.skipped:
            print()
            for s in self.skipped:
                print(f"  [SKIPPED] {s['type_name']}: {s['reason']}")
        print("=" * 60)


# ---------------------------------------------------------------------------
# Main generator
# ---------------------------------------------------------------------------

def _generate_kotlin_stub(type_name: str, kind: str, ref_files: list[str]) -> str:
    """Generate a minimal Kotlin stub for a missing type."""
    refs = "\n".join(f"//   - {f}" for f in ref_files[:5])
    header = (
        f"// {type_name}.kt\n"
        f"// Auto-generated stub — type was referenced but never declared.\n"
        f"// Referenced in:\n"
        f"{refs}\n"
        f"//\n"
        f"// TODO: Replace this stub with a full implementation.\n\n"
        f"package com.driveai.stub\n\n"
    )
    if kind == "protocol":
        return header + f"interface {type_name} {{\n    // Add required members\n}}\n"
    if kind == "enum":
        return header + f"enum class {type_name} {{\n    UNKNOWN\n    // Add real cases\n}}\n"
    if kind == "view":
        return header + (
            f"import androidx.compose.runtime.Composable\n\n"
            f"@Composable\nfun {type_name}() {{\n    // Stub composable\n}}\n"
        )
    if kind == "class":
        return header + f"class {type_name} {{\n    // Add implementation\n}}\n"
    # Default: data class
    return header + f"data class {type_name}(val id: String = \"\")\n"


def _generate_typescript_stub(type_name: str, kind: str, ref_files: list[str]) -> str:
    """Generate a minimal TypeScript stub for a missing type."""
    refs = "\n".join(f"//   - {f}" for f in ref_files[:5])
    header = (
        f"// {type_name}.ts\n"
        f"// Auto-generated stub — type was referenced but never declared.\n"
        f"// Referenced in:\n"
        f"{refs}\n"
        f"//\n"
        f"// TODO: Replace this stub with a full implementation.\n\n"
    )
    if kind == "protocol":
        return header + f"export interface {type_name} {{\n  // Add required members\n}}\n"
    if kind == "enum":
        return header + f"export enum {type_name} {{\n  Unknown = 'unknown',\n}}\n"
    if kind in ("class", "view"):
        return header + f"export class {type_name} {{\n  // Add implementation\n}}\n"
    # Default: interface
    return header + f"export interface {type_name} {{\n  id?: string;\n}}\n"



def _generate_csharp_stub(type_name: str, kind: str, ref_files: list[str]) -> str:
    """Generate a minimal C# stub for a missing type."""
    refs = "\n".join(f"//   - {f}" for f in ref_files[:5])
    header = (
        f"// {type_name}.cs\n"
        f"// Auto-generated stub.\n"
        f"// Referenced in:\n"
        f"{refs}\n"
        f"// TODO: Replace with real implementation.\n\n"
        f"using UnityEngine;\n\n"
    )
    if kind == "protocol":
        return header + f"public interface {type_name}\n{{\n    // Add members\n}}\n"
    if kind == "enum":
        return header + f"public enum {type_name}\n{{\n    Unknown\n}}\n"
    if kind == "view":
        return header + f"public class {type_name} : MonoBehaviour\n{{\n}}\n"
    if kind == "class":
        return header + f"public class {type_name}\n{{\n}}\n"
    return header + f"public class {type_name}\n{{\n}}\n"

# File extension per language
_LANG_EXTENSION = {"swift": ".swift", "kotlin": ".kt", "typescript": ".ts", "python": ".py", "csharp": ".cs"}

# Stub generator per language
_STUB_GENERATORS = {
    "swift": _generate_stub,
    "kotlin": _generate_kotlin_stub,
    "typescript": _generate_typescript_stub,
    "csharp": _generate_csharp_stub,
}


class TypeStubGenerator:
    """Generate stubs for FK-014 missing type declarations."""

    def __init__(self, project_name: str, project_dir: Path | None = None,
                 language: str = "swift"):
        self.project_name = project_name
        self.project_dir = project_dir or (_PROJECT_ROOT / "projects" / project_name)
        self._language = language
        self._extension = _LANG_EXTENSION.get(language, ".swift")
        self._generator = _STUB_GENERATORS.get(language, _generate_stub)
        self.report = StubReport(project=project_name)

    def generate_from_hygiene(self, hygiene_report) -> StubReport:
        """Extract FK-014 issues from a HygieneReport and generate stubs.

        Args:
            hygiene_report: HygieneReport dataclass from compile_hygiene_validator
        """
        # Extract FK-014 issues
        fk014_issues = [
            issue for issue in hygiene_report.issues
            if issue.pattern_id == "FK-014"
        ]
        self.report.fk014_count = len(fk014_issues)

        if not fk014_issues:
            print("[StubGen] No FK-014 findings — nothing to stub.")
            return self.report

        print(f"[StubGen] Processing {len(fk014_issues)} FK-014 finding(s)...")

        for issue in fk014_issues:
            type_name = issue.type_name
            ref_files = [issue.file] + (issue.other_files or [])

            # Skip framework/stdlib types that should never be stubbed
            from factory.operations.compile_hygiene_validator import _KNOWN_FRAMEWORK_TYPES
            if type_name in _KNOWN_FRAMEWORK_TYPES:
                self.report.skipped.append({
                    "type_name": type_name,
                    "reason": "framework/stdlib type — should not be stubbed",
                })
                self.report.stubs_skipped += 1
                continue

            # Skip if a file with this name already exists in the project
            existing = list(self.project_dir.rglob(f"{type_name}{self._extension}"))
            if existing:
                self.report.skipped.append({
                    "type_name": type_name,
                    "reason": f"file already exists: {existing[0].relative_to(self.project_dir)}",
                })
                self.report.stubs_skipped += 1
                continue

            # Infer kind and folder
            kind = _infer_kind(type_name)
            folder = _infer_folder(kind)
            target_dir = self.project_dir / folder
            target_dir.mkdir(parents=True, exist_ok=True)
            target_file = target_dir / f"{type_name}{self._extension}"

            # Generate and write stub
            stub_content = self._generator(type_name, kind, ref_files)
            target_file.write_text(stub_content, encoding="utf-8")

            rel_path = str(target_file.relative_to(self.project_dir))
            self.report.actions.append(StubAction(
                type_name=type_name,
                kind=kind,
                file_path=rel_path,
                ref_files=ref_files,
            ))
            self.report.stubs_created += 1
            print(f"  [STUB] {type_name} ({kind}) -> {rel_path}")

        # Save report
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        report_path = REPORTS_DIR / f"{self.project_name}_stubs.json"
        report_dict = {
            "project": self.report.project,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "fk014_count": self.report.fk014_count,
            "stubs_created": self.report.stubs_created,
            "stubs_skipped": self.report.stubs_skipped,
            "actions": [
                {"type_name": a.type_name, "kind": a.kind,
                 "file_path": a.file_path, "ref_files": a.ref_files}
                for a in self.report.actions
            ],
            "skipped": self.report.skipped,
        }
        report_path.write_text(json.dumps(report_dict, indent=2), encoding="utf-8")
        print(f"\n[StubGen] Report written to: {report_path}")

        return self.report
