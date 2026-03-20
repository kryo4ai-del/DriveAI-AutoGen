"""Abstract base for platform-specific assembly lines."""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Optional

from factory.assembly.handoff_protocol import ProductionHandoff


@dataclass
class CompileResult:
    success: bool
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    error_count: int = 0
    warning_count: int = 0
    command: str = ""
    skipped: bool = False
    skip_reason: str = ""


@dataclass
class FixAction:
    file_path: str
    action: str  # "add_import", "fix_type", "create_file", "modify", "delete"
    description: str
    content: str = ""


@dataclass
class AssemblyReport:
    project: str
    platform: str
    status: str = "pending"
    build_system: Optional[dict] = None
    file_organization: Optional[dict] = None
    wiring: Optional[dict] = None
    compile_attempts: list[CompileResult] = field(default_factory=list)
    fixes_applied: list[FixAction] = field(default_factory=list)
    test_result: Optional[dict] = None

    def summary(self) -> str:
        lines = [
            "=" * 60,
            "  Assembly Report",
            "=" * 60,
            f"  Project  : {self.project}",
            f"  Platform : {self.platform}",
            f"  Status   : {self.status}",
            f"  Compiles : {len(self.compile_attempts)} attempt(s)",
            f"  Fixes    : {len(self.fixes_applied)} applied",
        ]
        if self.compile_attempts:
            last = self.compile_attempts[-1]
            lines.append(f"  Last compile: {'SUCCESS' if last.success else f'FAILED ({last.error_count} errors)'}")
            if last.skipped:
                lines.append(f"  (skipped: {last.skip_reason})")
        if self.test_result:
            lines.append(f"  Tests    : {self.test_result.get('status', 'unknown')}")
        lines.append("=" * 60)
        return "\n".join(lines)


class BaseAssemblyLine(ABC):
    """Abstract base for platform-specific assembly lines."""

    @abstractmethod
    def receive_handoff(self, handoff: ProductionHandoff) -> bool:
        """Accept production handoff. Returns True if ready to proceed."""
        ...

    @abstractmethod
    def create_build_system(self) -> dict:
        """Create platform-specific build files."""
        ...

    @abstractmethod
    def organize_files(self) -> dict:
        """Move/copy generated files into correct project structure."""
        ...

    @abstractmethod
    def wire_app(self) -> dict:
        """Create entry points, navigation, DI setup."""
        ...

    @abstractmethod
    def compile(self) -> CompileResult:
        """Attempt compilation. Returns structured result."""
        ...

    @abstractmethod
    def diagnose_errors(self, compile_result: CompileResult) -> list[FixAction]:
        """Analyze compile errors and propose fixes."""
        ...

    @abstractmethod
    def apply_fixes(self, fixes: list[FixAction]) -> dict:
        """Apply proposed fixes."""
        ...

    @abstractmethod
    def run_tests(self) -> dict:
        """Run platform-specific tests."""
        ...

    def assemble(self, handoff: ProductionHandoff, max_fix_cycles: int = 5) -> AssemblyReport:
        """Full assembly pipeline: receive → build → organize → wire → compile → fix → test."""
        report = AssemblyReport(project=handoff.project_name, platform=handoff.platform)

        # Step 1: Receive
        if not self.receive_handoff(handoff):
            report.status = "rejected"
            return report

        # Step 2: Build system
        print("\n  [Assembly] Creating build system...")
        report.build_system = self.create_build_system()

        # Step 3: Organize
        print("  [Assembly] Organizing files...")
        report.file_organization = self.organize_files()

        # Step 4: Wire
        print("  [Assembly] Wiring app entry points...")
        report.wiring = self.wire_app()

        # Step 5: Compile-Fix cycle
        for cycle in range(max_fix_cycles):
            print(f"  [Assembly] Compile attempt {cycle + 1}/{max_fix_cycles}...")
            compile_result = self.compile()
            report.compile_attempts.append(compile_result)

            if compile_result.success or compile_result.skipped:
                break

            fixes = self.diagnose_errors(compile_result)
            if not fixes:
                report.status = "compile_failed_no_fixes"
                print(f"  [Assembly] No fixes available for {compile_result.error_count} error(s)")
                break

            applied = self.apply_fixes(fixes)
            report.fixes_applied.extend(fixes)
            print(f"  [Assembly] Applied {len(fixes)} fix(es)")

        # Step 6: Test
        last_compile = report.compile_attempts[-1] if report.compile_attempts else None
        if last_compile and (last_compile.success or last_compile.skipped):
            print("  [Assembly] Running tests...")
            report.test_result = self.run_tests()
            report.status = "complete"
        elif not last_compile or last_compile.skipped:
            report.status = "complete_no_compile"
        else:
            report.status = "compile_failed"

        return report
