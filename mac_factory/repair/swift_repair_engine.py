"""Koordiniert den Build → Repair → Rebuild Loop.

Regression Guard v2: Commits nach jedem erfolgreichen Repair.
Rollback geht zum LETZTEN GUTEN Stand, nicht zum Original.
"""
import os
import subprocess
from .error_parser import XcodeErrorParser
from .deterministic import DeterministicFixer
from .llm_repair import LLMRepairer


class SwiftRepairEngine:
    def __init__(self, project_dir: str, scheme: str, config: dict):
        self.project_dir = project_dir
        self.scheme = scheme
        self.max_iterations = config.get("max_repair_iterations", 3)
        self.build_timeout = config.get("xcodebuild_timeout", 300)
        self.parser = XcodeErrorParser()
        self.deterministic = DeterministicFixer(project_dir)
        self.llm = LLMRepairer(config)

    def build_and_repair(self) -> dict:
        """Build → Fix → Rebuild. Saves progress after each improvement."""
        history = []
        best_errors = float("inf")

        for iteration in range(1, self.max_iterations + 1):
            print(f"\n    === Iteration {iteration}/{self.max_iterations} ===")

            # Build
            output = self._xcodebuild()
            errors = self.parser.parse(output)
            error_count = self.parser.summary(errors)["total"]

            print(f"    Errors: {error_count}")
            history.append({"iteration": iteration, "errors": error_count})

            # Success
            if error_count == 0:
                print(f"    BUILD SUCCEEDED!")
                self._save_progress(iteration, 0)
                return {
                    "build_succeeded": True,
                    "iterations": iteration,
                    "initial_errors": history[0]["errors"],
                    "final_errors": 0,
                    "repair_cost": self.llm.total_cost,
                    "history": history,
                }

            # Regression Guard v2:
            # Errors decreased or first iteration → save progress
            # Errors increased → rollback to last good state, stop
            if error_count < best_errors:
                best_errors = error_count
                self._save_progress(iteration, error_count)
            elif error_count > best_errors:
                print(f"    [Mac Factory] REGRESSION: {best_errors} → {error_count}. Rolling back to last good state.")
                self._rollback_to_last_good()
                self._regenerate_xcode_project()
                history[-1]["regression"] = True
                history[-1]["rolled_back_to"] = best_errors
                break

            # Tier 1: Deterministic
            print(f"    Tier 1: Deterministic...")
            det_fixes = self.deterministic.fix_all(errors)
            print(f"      {det_fixes} fixes applied")

            if det_fixes > 0:
                self._regenerate_xcode_project()
                continue

            # Tier 2: LLM Repair
            print(f"    Tier 2: LLM Repair...")
            grouped = self.parser.group_by_file(errors)
            llm_fixes = 0
            for filepath, file_errors in grouped.items():
                if len(file_errors) <= 8:
                    if self.llm.fix_file(filepath, file_errors, tier=2):
                        llm_fixes += 1

            print(f"      {llm_fixes} files fixed")

            if llm_fixes > 0:
                self._regenerate_xcode_project()
                continue

            # No progress
            print(f"    No fixes applied — stopping.")
            break

        # Final build
        self._regenerate_xcode_project()
        output = self._xcodebuild()
        parsed = self.parser.parse(output)
        final_errors = self.parser.summary(parsed)["total"]

        # Save final state if it's an improvement
        if final_errors < best_errors:
            self._save_progress("final", final_errors)

        error_details = []
        for e in parsed:
            if e.severity == "error":
                error_details.append({
                    "file": e.file,
                    "line": e.line,
                    "column": e.column,
                    "message": e.message,
                    "type": e.error_type,
                })

        return {
            "build_succeeded": final_errors == 0,
            "iterations": len(history),
            "initial_errors": history[0]["errors"] if history else final_errors,
            "final_errors": final_errors,
            "repair_cost": self.llm.total_cost,
            "history": history,
            "error_details": error_details,
        }

    def _save_progress(self, iteration, error_count):
        """Commit current state as new baseline after successful repair."""
        try:
            subprocess.run(["git", "add", "-A"], cwd=self.project_dir,
                          capture_output=True, timeout=120)
            subprocess.run(
                ["git", "commit", "-m",
                 f"[Mac Factory] Repair iter {iteration}: {error_count} errors remaining"],
                cwd=self.project_dir, capture_output=True, timeout=120)
            print(f"    [Mac Factory] Progress saved: iter {iteration}, {error_count} errors")
        except Exception as e:
            print(f"    [Mac Factory] Warning: Could not save progress: {e}")

    def _rollback_to_last_good(self):
        """Rollback to last committed state (which is the last successful repair)."""
        try:
            subprocess.run(["git", "checkout", "--", "."], cwd=self.project_dir,
                          capture_output=True, timeout=30)
            subprocess.run(["git", "clean", "-fd"], cwd=self.project_dir,
                          capture_output=True, timeout=30)
            print(f"    [Mac Factory] Rolled back to last good committed state")
        except Exception as e:
            print(f"    [Mac Factory] Rollback failed: {e}")

    def _xcodebuild(self) -> str:
        xcodeproj = None
        for f in os.listdir(self.project_dir):
            if f.endswith(".xcodeproj"):
                xcodeproj = os.path.join(self.project_dir, f)
                break

        if not xcodeproj:
            return "error: No .xcodeproj found"

        cmd = [
            "xcodebuild",
            "-project", xcodeproj,
            "-scheme", self.scheme,
            "-destination", "platform=iOS Simulator,name=iPhone 17 Pro",
            "-configuration", "Debug",
            "build",
        ]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True,
                                   timeout=self.build_timeout, cwd=self.project_dir)
            return result.stdout + "\n" + result.stderr
        except subprocess.TimeoutExpired:
            return "error: Build timeout"
        except Exception as e:
            return f"error: {e}"

    def _regenerate_xcode_project(self):
        try:
            subprocess.run(["xcodegen", "generate"], cwd=self.project_dir,
                          capture_output=True, timeout=45)
        except Exception:
            pass
