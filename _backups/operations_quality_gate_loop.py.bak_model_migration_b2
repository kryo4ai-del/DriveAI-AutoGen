"""Quality Gate Loop — Autonomous pre-assembly repair.

Sits after Steps 1-9 in the Operations Layer. Iterates Tier 1 (deterministic,
free) and Tier 2 (LLM, cost-aware) repairs until 0 BLOCKING or max iterations.
"""

import os
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path


@dataclass
class IterationResult:
    blocking_before: int = 0
    blocking_after: int = 0
    tier1_fixes: int = 0
    tier2_fixes: int = 0
    tier2_cost: float = 0.0


@dataclass
class QualityGateResult:
    status: str = "pass"  # "pass" | "escalation"
    iterations_used: int = 0
    initial_blocking: int = 0
    final_blocking: int = 0
    tier1_fixes: int = 0
    tier2_fixes: int = 0
    iterations: list = field(default_factory=list)
    escalation_report: str | None = None


def _count_blocking(hygiene_report) -> int:
    """Count blocking issues from a CompileHygieneReport."""
    return sum(1 for i in hygiene_report.issues if i.severity.value == "blocking")


def _run_tier1(project_name: str, language: str, hygiene_report) -> tuple[int, object]:
    """Run deterministic repairs (free). Returns (fixes_made, new_hygiene_report)."""
    fixes = 0

    # 1. Import Hygiene on blocking files
    try:
        from factory.operations.import_hygiene import ImportHygiene
        ih = ImportHygiene(project_name=project_name)
        ih_result = ih.fix()
        ih_fixed = ih_result.get("fixed", 0) if isinstance(ih_result, dict) else 0
        fixes += ih_fixed
        if ih_fixed:
            print(f"      Import Hygiene: {ih_fixed} files fixed")
    except Exception:
        pass

    # 2. Pseudocode Sanitizer
    try:
        from factory.operations.toplevel_sanitizer import fix_pseudocode
        ps_fixed = fix_pseudocode(os.path.join("projects", project_name), language=language)
        fixes += ps_fixed
        if ps_fixed:
            print(f"      Pseudocode Sanitizer: {ps_fixed} files fixed")
    except Exception:
        pass

    # 3. Re-run Compile Hygiene to get fresh report
    from factory.operations.compile_hygiene_validator import CompileHygieneValidator
    hygiene = CompileHygieneValidator(project_name=project_name, language=language)
    hygiene_report = hygiene.validate()

    # 4. Stale Artifact Guard (quarantine stale files)
    try:
        from factory.operations.stale_artifact_guard import StaleArtifactGuard
        remaining_blocking = [i for i in hygiene_report.issues if i.severity.value == "blocking"]
        if remaining_blocking:
            guard = StaleArtifactGuard(project_name=project_name)
            stale_report = guard.check_and_quarantine(hygiene_report)
            if stale_report.quarantined > 0:
                fixes += stale_report.quarantined
                print(f"      Stale Artifact Guard: {stale_report.quarantined} quarantined")
                hygiene = CompileHygieneValidator(project_name=project_name, language=language)
                hygiene_report = hygiene.validate()
    except Exception:
        pass

    # 5. Stub Generator for missing types
    try:
        from factory.operations.type_stub_generator import TypeStubGenerator
        fk014 = [i for i in hygiene_report.issues
                 if i.pattern_id == "FK-014" and i.severity.value == "blocking"]
        if fk014:
            stub_gen = TypeStubGenerator(project_name=project_name, language=language)
            stub_report = stub_gen.generate_from_hygiene(hygiene_report)
            if stub_report.stubs_created > 0:
                fixes += stub_report.stubs_created
                print(f"      Stub Generator: {stub_report.stubs_created} stubs created")
                hygiene = CompileHygieneValidator(project_name=project_name, language=language)
                hygiene_report = hygiene.validate()
    except Exception:
        pass

    # 6. Shape Repairer for init mismatches
    try:
        from factory.operations.property_shape_repairer import PropertyShapeRepairer
        fk013 = [i for i in hygiene_report.issues
                 if i.pattern_id == "FK-013" and i.severity.value == "blocking"]
        if fk013:
            shape_repairer = PropertyShapeRepairer(project_name=project_name)
            shape_report = shape_repairer.repair_from_hygiene(hygiene_report)
            if shape_report.repairs_applied > 0:
                fixes += shape_report.repairs_applied
                print(f"      Shape Repairer: {shape_report.repairs_applied} repairs")
                hygiene = CompileHygieneValidator(project_name=project_name, language=language)
                hygiene_report = hygiene.validate()
    except Exception:
        pass

    return fixes, hygiene_report


def _run_tier2(project_name: str, language: str, hygiene_report) -> tuple[int, object]:
    """Run LLM-powered repair on remaining blocking files. Returns (fixes_made, new_hygiene_report)."""
    blocking = [i for i in hygiene_report.issues if i.severity.value == "blocking"]
    if not blocking:
        return 0, hygiene_report

    # Group blocking issues by file
    file_errors: dict[str, list] = {}
    for issue in blocking:
        from factory.assembly.repair.error_parser import CompilerError
        ce = CompilerError(
            file_path=issue.file,
            line_number=issue.line if hasattr(issue, "line") else 0,
            message=issue.message,
            severity="error",
            error_code=issue.pattern_id,
            language=language,
            category=issue.pattern_id.lower().replace("-", "_"),
        )
        file_errors.setdefault(issue.file, []).append(ce)

    # Use LLM repair agent
    try:
        from factory.assembly.repair.llm_repair_agent import LLMRepairAgent
        # Use TheBrain to select model if available
        model = "claude-haiku-4-5"
        try:
            from factory.brain.model_provider import get_model
            selection = get_model(
                agent_name="llm_repair",
                task_type="code_generation",
                profile="dev",
                line=language,
                project_name=project_name,
            )
            model = selection.get("model", model)
        except Exception:
            pass

        agent = LLMRepairAgent(model=model)
        project_dir = os.path.join("projects", project_name)
        batch_result = agent.fix_batch(file_errors, project_dir, language, max_files=10)

        if batch_result.files_fixed > 0:
            print(f"      LLM Repair: {batch_result.files_fixed} files fixed "
                  f"({batch_result.total_errors_addressed} errors, "
                  f"~${batch_result.estimated_cost():.4f})")

            # Re-run hygiene after LLM fixes
            from factory.operations.compile_hygiene_validator import CompileHygieneValidator
            hygiene = CompileHygieneValidator(project_name=project_name, language=language)
            hygiene_report = hygiene.validate()

        return batch_result.files_fixed, hygiene_report
    except Exception as e:
        print(f"      LLM Repair: skipped ({e})")
        return 0, hygiene_report


def _generate_escalation_report(
    project_name: str, line: str, run_id: str,
    result: QualityGateResult, hygiene_report,
) -> str:
    """Generate CEO Escalation Report markdown."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    blocking = [i for i in hygiene_report.issues if i.severity.value == "blocking"]

    lines = [
        "# Quality Gate Escalation Report",
        f"- **Project**: {project_name}",
        f"- **Line**: {line}",
        f"- **Run**: {run_id or 'unknown'}",
        f"- **Timestamp**: {timestamp}",
        f"- **Iterations**: {result.iterations_used} (max reached)",
        f"- **Initial Blocking**: {result.initial_blocking}",
        f"- **Final Blocking**: {result.final_blocking}",
        "",
        "## Remaining Issues",
        "| File | FK-Type | Description |",
        "|------|---------|-------------|",
    ]
    for issue in blocking:
        desc = issue.message[:80].replace("|", "/")
        lines.append(f"| {issue.file} | {issue.pattern_id} | {desc} |")

    lines.append("")
    lines.append("## Repair History")
    for i, it in enumerate(result.iterations, 1):
        lines.append(f"### Iteration {i}")
        lines.append(f"- Blocking before: {it.blocking_before}")
        lines.append(f"- Tier 1 fixes: {it.tier1_fixes}")
        lines.append(f"- Tier 2 fixes: {it.tier2_fixes}")
        lines.append(f"- Blocking after: {it.blocking_after}")
        lines.append("")

    lines.extend([
        "## Recommendation",
        "CEO intervention required. The above issues could not be auto-repaired.",
        "Possible actions: manual fix, regenerate affected files, or skip for this run.",
    ])

    return "\n".join(lines)


def run_quality_gate_loop(
    project_name: str,
    language: str = "swift",
    line: str = "ios",
    run_id: str = "",
    max_iterations: int = 3,
    hygiene_report=None,
    env_profile: str = "dev",
    initial_health: str = "",
    completion_report=None,
) -> QualityGateResult:
    """Autonomous repair loop. Runs Tier 1 (deterministic) then Tier 2 (LLM).

    Returns QualityGateResult with status "pass" or "escalation".
    """
    result = QualityGateResult()

    # --- Preserve existing Recovery Loop (for initial_health == "incomplete") ---
    if initial_health == "incomplete" and completion_report is not None:
        try:
            from factory.operations.recovery_runner import (
                RecoveryRunner, RecoveryState, MAX_RECOVERY_ATTEMPTS,
                load_recovery_state, clear_recovery_state,
            )
            from factory.operations.output_integrator import OutputIntegrator
            from factory.operations.completion_verifier import CompletionVerifier

            _file_extensions = {
                "swift": [".swift"], "kotlin": [".kt"],
                "typescript": [".ts", ".tsx"], "python": [".py"],
            }.get(language, [".swift"])

            prior_state = load_recovery_state(project_name)

            for attempt in range(1, MAX_RECOVERY_ATTEMPTS + 1):
                print(f"\n  [QualityGate] Recovery attempt {attempt}/{MAX_RECOVERY_ATTEMPTS} "
                      f"(health: INCOMPLETE)")

                missing_list = completion_report.to_dict().get("missing_files", [])
                incomplete_list = completion_report.to_dict().get("incomplete_files", [])
                failure_summary = (
                    f"{len(missing_list)} missing, {len(incomplete_list)} incomplete"
                )
                error_excerpt = ""
                if missing_list:
                    error_excerpt = "Missing: " + ", ".join(missing_list[:10])
                if incomplete_list:
                    excerpt_add = "Incomplete: " + ", ".join(incomplete_list[:5])
                    error_excerpt = f"{error_excerpt}; {excerpt_add}" if error_excerpt else excerpt_add

                failure_ctx = RecoveryState(
                    project_name=project_name,
                    attempt_number=attempt,
                    failed_stage="completion_verifier",
                    failure_status=initial_health,
                    failure_summary=failure_summary,
                    error_excerpt=error_excerpt[:400],
                    failure_fingerprint=prior_state.failure_fingerprint if prior_state else "",
                    prior_fingerprints=prior_state.prior_fingerprints if prior_state else [],
                    timestamp=completion_report.to_dict().get("timestamp", ""),
                )

                runner = RecoveryRunner(
                    project_name=project_name,
                    env_profile=env_profile,
                    dry_run=False,
                    failure_context=failure_ctx,
                )
                recovery_summary = runner.run()
                recovery_outcome = recovery_summary.outcome

                if recovery_outcome in ("repeated_failure", "terminal_stop", "skipped"):
                    print(f"  [QualityGate] Recovery stopped: {recovery_outcome}")
                    break

                # Re-integrate + re-verify
                integrator_r = OutputIntegrator(
                    project_name=project_name,
                    log_filter=run_id,
                    clean_before_integrate=True,
                    file_extensions=_file_extensions,
                )
                integrator_r.run()

                verifier_r = CompletionVerifier(project_name=project_name, language=language)
                completion_report = verifier_r.verify()
                new_health = completion_report.health.value

                if new_health in ("complete", "mostly_complete"):
                    print(f"  [QualityGate] Recovery successful: {new_health.upper()}")
                    clear_recovery_state()
                    break

                prior_state = RecoveryState(
                    project_name=project_name,
                    attempt_number=attempt,
                    failed_stage="completion_verifier",
                    failure_status=new_health,
                    failure_summary=failure_summary,
                    failure_fingerprint=recovery_summary.failure_fingerprint,
                    prior_fingerprints=(
                        failure_ctx.prior_fingerprints +
                        ([failure_ctx.failure_fingerprint] if failure_ctx.failure_fingerprint else [])
                    ),
                )
        except Exception as e:
            print(f"  [QualityGate] Recovery error: {e}")

    # --- Quality Gate: CompileHygiene repair loop ---
    if hygiene_report is None:
        from factory.operations.compile_hygiene_validator import CompileHygieneValidator
        hygiene = CompileHygieneValidator(project_name=project_name, language=language)
        hygiene_report = hygiene.validate()

    result.initial_blocking = _count_blocking(hygiene_report)

    # Fast path: no blocking issues
    if result.initial_blocking == 0:
        result.status = "pass"
        result.final_blocking = 0
        print("\n[QualityGate] PASS — 0 blocking issues.")
        return result

    print(f"\n[QualityGate] {result.initial_blocking} blocking issues — entering repair loop (max {max_iterations} iterations)")

    for iteration in range(1, max_iterations + 1):
        it = IterationResult(blocking_before=_count_blocking(hygiene_report))

        print(f"\n  [QualityGate] Iteration {iteration}/{max_iterations}: "
              f"{it.blocking_before} blocking")

        # Tier 1: Deterministic (free)
        print(f"    Tier 1 (deterministic):")
        tier1_fixes, hygiene_report = _run_tier1(project_name, language, hygiene_report)
        it.tier1_fixes = tier1_fixes
        blocking_after_t1 = _count_blocking(hygiene_report)

        if blocking_after_t1 == 0:
            it.blocking_after = 0
            result.iterations.append(it)
            result.tier1_fixes += tier1_fixes
            print(f"    → 0 blocking after Tier 1. PASS.")
            break

        # Tier 2: LLM (cost-aware)
        print(f"    Tier 2 (LLM repair): {blocking_after_t1} remaining")
        tier2_fixes, hygiene_report = _run_tier2(project_name, language, hygiene_report)
        it.tier2_fixes = tier2_fixes
        it.blocking_after = _count_blocking(hygiene_report)

        result.iterations.append(it)
        result.tier1_fixes += tier1_fixes
        result.tier2_fixes += tier2_fixes

        print(f"    → {it.blocking_after} blocking remaining "
              f"(Tier 1: -{tier1_fixes}, Tier 2: -{tier2_fixes})")

        if it.blocking_after == 0:
            print(f"    → 0 blocking after Tier 2. PASS.")
            break
    else:
        # Exhausted all iterations
        result.status = "escalation"

    result.iterations_used = len(result.iterations)
    result.final_blocking = _count_blocking(hygiene_report)

    if result.final_blocking == 0:
        result.status = "pass"
        print(f"\n[QualityGate] PASS — 0 blocking after {result.iterations_used} iteration(s). "
              f"(Tier 1: {result.tier1_fixes}, Tier 2: {result.tier2_fixes})")
    else:
        result.status = "escalation"
        # Generate escalation report
        report_md = _generate_escalation_report(
            project_name, line, run_id, result, hygiene_report)
        result.escalation_report = report_md

        # Save to disk
        esc_dir = os.path.join("factory", "reports", "escalations")
        os.makedirs(esc_dir, exist_ok=True)
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        esc_path = os.path.join(esc_dir, f"{project_name}_quality_gate_{ts}.md")
        try:
            Path(esc_path).write_text(report_md, encoding="utf-8")
            print(f"\n[QualityGate] ESCALATION: {result.final_blocking} blocking after "
                  f"{result.iterations_used} iterations. Report: {esc_path}")
        except Exception:
            print(f"\n[QualityGate] ESCALATION: {result.final_blocking} blocking after "
                  f"{result.iterations_used} iterations.")

    return result
