"""Assembly Manager — coordinates assembly across all lines."""

from factory.assembly.handoff_protocol import ProductionHandoff, create_handoff_from_project
from factory.assembly.lines.base_line import BaseAssemblyLine, AssemblyReport
from factory.assembly.lines.android_line import AndroidAssemblyLine
from factory.assembly.lines.ios_line import iOSAssemblyLine
from factory.assembly.lines.web_line import WebAssemblyLine


class AssemblyManager:
    """Coordinates assembly across all production lines."""

    def __init__(self):
        self.lines: dict[str, BaseAssemblyLine] = {}
        # Auto-register available lines
        self.register_line("android", AndroidAssemblyLine())
        self.register_line("ios", iOSAssemblyLine())
        self.register_line("web", WebAssemblyLine())
        self.register_line("unity", UnityAssemblyLine())

    def register_line(self, platform: str, line: BaseAssemblyLine):
        self.lines[platform] = line

    def create_handoff(self, project_name: str) -> ProductionHandoff:
        return create_handoff_from_project(project_name)

    def start_assembly(self, handoff: ProductionHandoff, dry_run: bool = False) -> AssemblyReport:
        """Route handoff to the correct assembly line and start assembly."""
        platform = handoff.platform
        if platform not in self.lines:
            report = AssemblyReport(project=handoff.project_name, platform=platform)
            report.status = f"no_assembly_line_for_{platform}"
            return report

        if not handoff.is_ready_for_assembly():
            report = AssemblyReport(project=handoff.project_name, platform=platform)
            report.status = "handoff_not_ready"
            print(f"  [Assembly] Handoff not ready: {handoff.blocking_issues} blocking, gate={handoff.quality_gate_status}")
            return report

        line = self.lines[platform]

        if dry_run:
            return self._dry_run(handoff, line)

        return line.assemble(handoff)

    def _dry_run(self, handoff: ProductionHandoff, line: BaseAssemblyLine) -> AssemblyReport:
        """Show what would happen without executing."""
        report = AssemblyReport(project=handoff.project_name, platform=handoff.platform)

        print()
        print("=" * 60)
        print("  Assembly Dry Run")
        print("=" * 60)
        print(f"  Project  : {handoff.project_name}")
        print(f"  Platform : {handoff.platform} / {handoff.language}")
        print(f"  Files    : {handoff.total_files}")
        print(f"  Features : {', '.join(handoff.features_completed)}")
        print(f"  Gate     : {handoff.quality_gate_status}")
        print(f"  Ready    : {'YES' if handoff.is_ready_for_assembly() else 'NO'}")
        print()
        print("  Assembly Steps:")
        for i, task in enumerate(handoff.assembly_tasks, 1):
            print(f"    {i}. {task}")
        print()
        print(f"  Assembly Line: {line.__class__.__name__}")
        print("=" * 60)

        report.status = "dry_run"
        return report

    def get_available_lines(self) -> list[str]:
        return list(self.lines.keys())
