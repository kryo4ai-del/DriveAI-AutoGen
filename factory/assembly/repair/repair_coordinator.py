"""3-tier repair coordinator.

Tier 1: Deterministic RepairEngine (free, fast)
Tier 2: LLM Repair Agent (costs money, smart)
Tier 3: CEO Escalation (human decision needed)
"""

import os
from dataclasses import dataclass, field
from factory.assembly.repair.repair_engine import RepairEngine
from factory.assembly.repair.llm_repair_agent import LLMRepairAgent, BatchRepairResult
from factory.assembly.repair.error_parser import ErrorParser
from config.model_router import get_fallback_model


@dataclass
class CoordinatorReport:
    status: str = "pending"
    tier1_errors_start: int = 0
    tier1_errors_end: int = 0
    tier1_fixes: int = 0
    tier2_result: BatchRepairResult | None = None
    final_errors: int = 0
    escalation: str = ""

    def summary(self) -> str:
        lines = [
            "  Repair Coordinator Report",
            f"    Tier 1 (deterministic): {self.tier1_errors_start} -> {self.tier1_errors_end} "
            f"({self.tier1_fixes} fixes)",
        ]
        if self.tier2_result:
            lines.append(f"    Tier 2 (LLM): {self.tier2_result.files_fixed}/{self.tier2_result.files_attempted} files fixed")
            lines.append(f"    {self.tier2_result.summary()}")
        lines.extend([
            f"    Final errors: {self.final_errors}",
            f"    Status: {self.status}",
        ])
        return "\n".join(lines)


class RepairCoordinator:
    """Coordinates 3-tier repair strategy."""

    def __init__(self, project_dir: str, language: str,
                 llm_model: str = None,
                 enable_llm: bool = True,
                 max_llm_files: int = 20,
                 max_deterministic_cycles: int = 10):
        self.project_dir = project_dir
        self.language = language
        self.engine = RepairEngine(project_dir, language)
        self.parser = ErrorParser()
        self.enable_llm = enable_llm and bool(os.environ.get("ANTHROPIC_API_KEY", ""))
        self.llm_agent = LLMRepairAgent(model=llm_model or get_fallback_model("dev")) if self.enable_llm else None
        self.max_llm_files = max_llm_files
        self.max_det_cycles = max_deterministic_cycles

    def full_repair(self, compiler_output: str) -> CoordinatorReport:
        """Run full 3-tier repair."""
        report = CoordinatorReport()

        # ── Tier 1: Deterministic ────────────────────────────────────
        print("\n[RepairCoordinator] Tier 1: Deterministic RepairEngine")
        initial_errors = self.parser.parse(compiler_output, self.language)
        report.tier1_errors_start = len(initial_errors)

        tier1 = self.engine.repair_cycle(compiler_output, max_cycles=self.max_det_cycles)
        report.tier1_fixes = tier1.fixes_applied
        report.tier1_errors_end = tier1.remaining_errors

        print(f"  Tier 1: {report.tier1_errors_start} -> {tier1.remaining_errors} "
              f"({tier1.fixes_applied} fixes in {tier1.cycles} cycles)")

        if tier1.remaining_errors == 0:
            report.status = "clean"
            report.final_errors = 0
            return report

        # ── Tier 2: LLM Repair ──────────────────────────────────────
        if self.llm_agent:
            print(f"\n[RepairCoordinator] Tier 2: LLM Repair ({self.llm_agent.model})")

            # Recompile to get fresh errors after Tier 1
            fresh_output = self.engine._recompile()
            fresh_errors = self.parser.parse(fresh_output, self.language)

            if not fresh_errors:
                report.status = "clean"
                report.final_errors = 0
                return report

            # Group by file
            file_errors: dict[str, list] = {}
            for error in fresh_errors:
                fp = error.file_path
                if fp not in file_errors:
                    file_errors[fp] = []
                file_errors[fp].append(error)

            print(f"  {len(file_errors)} files with errors, processing top {self.max_llm_files}")

            tier2 = self.llm_agent.fix_batch(
                file_errors=file_errors,
                project_dir=self.project_dir,
                language=self.language,
                max_files=self.max_llm_files,
            )
            report.tier2_result = tier2
            print(f"\n{tier2.summary()}")

            # Recompile after LLM fixes
            print("\n  Recompiling after LLM fixes...")
            final_output = self.engine._recompile()
            final_errors = self.parser.parse(final_output, self.language)
            report.final_errors = len(final_errors)

            if len(final_errors) == 0:
                report.status = "clean"
            elif len(final_errors) < tier1.remaining_errors:
                report.status = "improved"
            else:
                report.status = "stuck"
        else:
            reason = "no API key" if not os.environ.get("ANTHROPIC_API_KEY") else "LLM disabled"
            print(f"\n[RepairCoordinator] Tier 2: SKIPPED ({reason})")
            report.final_errors = tier1.remaining_errors
            report.status = "tier1_only"

        # ── Tier 3: Escalation ──────────────────────────────────────
        if report.final_errors > 0:
            print(f"\n[RepairCoordinator] Tier 3: {report.final_errors} errors remain — escalation needed")
            report.escalation = f"{report.final_errors} compile errors remain after Tier 1 + Tier 2 repair."

        return report
