"""Central repair coordinator — parse errors, select strategies, apply fixes."""

import subprocess
from dataclasses import dataclass, field
from pathlib import Path

from factory.assembly.repair.error_parser import ErrorParser, CompilerError
from factory.assembly.repair.fix_strategies.missing_import import MissingImportFixer
from factory.assembly.repair.fix_strategies.missing_type import MissingTypeFixer
from factory.assembly.repair.fix_strategies.type_annotation import TypeAnnotationFixer
from factory.assembly.repair.fix_strategies.duplicate_type import DuplicateTypeFixer
from factory.assembly.repair.fix_strategies.module_path import ModulePathFixer


@dataclass
class RepairReport:
    cycles: int = 0
    fixes_applied: int = 0
    errors_per_cycle: list[int] = field(default_factory=list)
    remaining_errors: int = 0
    status: str = "pending"
    fix_log: list[str] = field(default_factory=list)

    def summary(self) -> str:
        lines = [
            "  Repair Engine Report",
            f"    Cycles:          {self.cycles}",
            f"    Fixes applied:   {self.fixes_applied}",
            f"    Errors trend:    {' -> '.join(str(e) for e in self.errors_per_cycle)}",
            f"    Remaining:       {self.remaining_errors}",
            f"    Status:          {self.status}",
        ]
        return "\n".join(lines)


class RepairEngine:
    """Central repair coordinator."""

    def __init__(self, project_dir: str, language: str):
        self.project_dir = project_dir
        self.language = language
        self.parser = ErrorParser()
        self.fixers = [
            ("missing_import", MissingImportFixer()),
            ("module_path", ModulePathFixer()),
            ("type_annotation", TypeAnnotationFixer()),
            ("missing_type", MissingTypeFixer()),
            ("duplicate_type", DuplicateTypeFixer()),
        ]

    def repair_cycle(self, compiler_output: str, max_cycles: int = 5) -> RepairReport:
        """Run parse -> diagnose -> fix -> recompile cycle."""
        report = RepairReport()
        current_output = compiler_output

        for cycle in range(max_cycles):
            errors = self.parser.parse(current_output, self.language)
            report.errors_per_cycle.append(len(errors))

            if not errors:
                report.status = "clean"
                break

            # Try to fix errors
            fixes_this_cycle = 0
            fixed_files = set()

            for error in errors:
                # Skip if we already fixed something in this file this cycle
                if error.file_path in fixed_files:
                    continue

                for cat_name, fixer in self.fixers:
                    if fixer.can_fix(error):
                        success = fixer.apply(
                            error,
                            project_dir=self.project_dir,
                        )
                        if success:
                            fixes_this_cycle += 1
                            report.fixes_applied += 1
                            fixed_files.add(error.file_path)
                            report.fix_log.append(
                                f"  Cycle {cycle+1}: [{cat_name}] {error.file_path}:{error.line_number} — {error.message[:60]}"
                            )
                            break

            report.cycles = cycle + 1

            if fixes_this_cycle == 0:
                report.status = "no_fixable_errors"
                break

            print(f"  [Repair] Cycle {cycle+1}: {fixes_this_cycle} fixes applied, recompiling...")

            # Recompile
            current_output = self._recompile()

        # Final error count
        final_errors = self.parser.parse(current_output, self.language)
        report.remaining_errors = len(final_errors)
        if not final_errors:
            report.status = "clean"
        elif report.status == "pending":
            report.status = "max_cycles"

        return report

    def _recompile(self) -> str:
        """Run the appropriate compiler."""
        try:
            if self.language == "typescript":
                result = subprocess.run(
                    "npx tsc --noEmit",
                    cwd=self.project_dir,
                    capture_output=True, text=True, timeout=120,
                    shell=True,
                )
                return result.stdout + result.stderr
            elif self.language == "kotlin":
                import os as _os
                java_home = _os.environ.get("JAVA_HOME", "C:/Program Files/Android/Android Studio/jbr")
                android_home = _os.environ.get("ANDROID_HOME", "C:/Users/Admin/AppData/Local/Android/Sdk")
                env = _os.environ.copy()
                env["JAVA_HOME"] = java_home
                env["ANDROID_HOME"] = android_home
                # Use cmd /c to properly capture Gradle output on Windows
                bat_path = _os.path.join(self.project_dir, "_kt_compile.bat")
                with open(bat_path, "w") as bf:
                    bf.write("@echo off\r\n")
                    bf.write("set JAVA_HOME=" + java_home + "\r\n")
                    bf.write("set ANDROID_HOME=" + android_home + "\r\n")
                    bf.write("call /tmp/gradle-8.4/bin/gradle compileDebugKotlin --no-daemon 2>&1\r\n")
                result = subprocess.run(
                    ["cmd", "/c", bat_path],
                    cwd=self.project_dir,
                    capture_output=True, text=True, timeout=300,
                )
                try:
                    _os.remove(bat_path)
                except Exception:
                    pass
                return result.stdout
        except (FileNotFoundError, subprocess.TimeoutExpired) as e:
            return f"Recompile failed: {e}"
        return ""