# factory/pipeline/pipeline_runner.py
# Pipeline execution logic extracted from main.py.
# This is a pure structural refactor — zero behavior change.

import asyncio
import json
import os
import shutil
from datetime import datetime

from tasks.task_manager import TaskManager
from code_generation.code_extractor import CodeExtractor
from code_generation.project_integrator import ProjectIntegrator
from code_generation.extractors import get_extractor
from delivery.delivery_exporter import DeliveryExporter
from delivery.sprint_reporter import SprintReporter
from tasks.fix_executor import FixExecutor
from delivery.run_manifest import RunManifest
from analytics.analytics_tracker import AnalyticsTracker
from workflows.phase_gate_manager import PhaseGateManager
from factory_knowledge.knowledge_reader import get_cd_knowledge_block, get_knowledge_block, extract_cd_rating, extract_cd_rating_detailed
from factory_knowledge.proposal_generator import generate_proposals, save_proposals


def _extract_review_digest(messages: list, pass_name: str, max_chars: int = 600) -> str:
    """Extract a compact structured digest from a review pass's messages.

    Scans all non-user messages for the target agent's output and returns
    a trimmed excerpt. Falls back to any non-user message if the target
    agent name is not found (e.g. when SelectorGroupChat routes differently).
    """
    # Map pass names to expected agent source names
    _AGENT_MAP = {
        "bug_review": "bug_hunter",
        "creative_review": "creative_director",
        "ux_psychology": "ux_psychology",
        "refactor": "refactor_agent",
    }
    target = _AGENT_MAP.get(pass_name, pass_name)

    # Try target agent first
    for msg in messages:
        source = getattr(msg, "source", "")
        content = getattr(msg, "content", "")
        if source == target and isinstance(content, str) and content.strip():
            return content.strip()[:max_chars]

    # Fallback: first non-user, non-empty message
    for msg in messages:
        source = getattr(msg, "source", "")
        content = getattr(msg, "content", "")
        if source not in ("user", "") and isinstance(content, str) and content.strip():
            return content.strip()[:max_chars]

    return ""


def _build_review_context(review_digests: dict[str, str]) -> str:
    """Build a compact review context block from accumulated digests.

    Returns a structured text block that downstream passes can consume
    to understand what prior reviewers found.
    """
    if not review_digests:
        return ""

    sections = []
    _LABELS = {
        "bug_review": "Bug Hunter Findings",
        "creative_review": "Creative Director Assessment",
        "ux_psychology": "UX Psychology Findings",
        "refactor": "Refactor Suggestions",
    }

    for key, digest in review_digests.items():
        if digest:
            label = _LABELS.get(key, key)
            sections.append(f"[{label}]\n{digest}")

    if not sections:
        return ""

    return "[Prior Review Findings]\n" + "\n\n".join(sections)


async def _log_pass(logger, label: str, messages: list) -> None:
    logger.info(f"--- {label} ---")
    for msg in messages:
        logger.info(f"[{getattr(msg, 'source', 'system')}]")
        logger.info(getattr(msg, "content", str(msg)))
        logger.info("")


async def _run_with_retry(team, task: str, max_retries: int = 3, base_delay: float = 65.0):
    """Run team.run() with retry on rate limit errors.

    Catches both RuntimeError-wrapped and direct RateLimitError exceptions from AutoGen.
    Waits base_delay seconds between retries (default 65s to clear per-minute rate limits).
    """
    for attempt in range(max_retries + 1):
        try:
            return await team.run(task=task)
        except Exception as e:
            is_rate_limit = (
                "RateLimitError" in type(e).__name__
                or "rate_limit" in str(e).lower()
            )
            if is_rate_limit and attempt < max_retries:
                wait = base_delay * (attempt + 1)
                print(f"  Rate limit hit, waiting {int(wait)}s before retry ({attempt + 1}/{max_retries})...")
                await asyncio.sleep(wait)
            else:
                raise


def _clean_generated_code() -> int:
    """Remove stale files from generated_code/ before a new run. Returns count of removed files."""
    gen_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "generated_code")
    if not os.path.isdir(gen_dir):
        return 0
    removed = 0
    for subfolder in os.listdir(gen_dir):
        sub_path = os.path.join(gen_dir, subfolder)
        if not os.path.isdir(sub_path):
            continue
        for filename in os.listdir(sub_path):
            if filename.endswith(".swift"):
                os.remove(os.path.join(sub_path, filename))
                removed += 1
    if removed:
        print(f"Cleaned {removed} stale file(s) from generated_code/")
    return removed


async def run_pipeline(
    user_task: str,
    task_source: str,
    run_mode: str,
    approval_mode: str,
    run_id: str,
    logger,
    log_path: str,
    active_feature: str | None = None,
    profile: str | None = None,
    env_profile: str = "dev",
    model: str = "",
    active_agents: list[str] | None = None,
    disabled_agents: list[str] | None = None,
    template: str | None = None,
    template_name_value: str | None = None,
    pack: str | None = None,
    pack_task_count: int | None = None,
    session_preset: str | None = None,
    workflow_recipe: str | None = None,
    no_cd_gate: bool = False,
    project_name: str | None = None,
) -> dict:
    """Execute the full agent pipeline for a single task. Returns a result dict."""
    # ── Load project config ──────────────────────────────────────────
    from factory.project_config import load_project_config
    project_config = None
    project_config_loaded = False
    if project_name:
        project_config = load_project_config(project_name)
        project_config_loaded = True
        active_lines = project_config.get_active_lines()
        extraction_lang = project_config.get_extraction_language()
        print(f"Project config  : {project_config.name} v{project_config.version}")
        print(f"Active lines    : {', '.join(active_lines) if active_lines else 'none'}")
        print(f"Extraction      : {extraction_lang}")
        logger.info(f"[ProjectConfig] name={project_config.name} slug={project_config.slug}")
        logger.info(f"[ProjectConfig] active_lines={active_lines} extraction={extraction_lang}")
        logger.info(f"[ProjectConfig] status={project_config.metadata.status}")

    # ── Load Factory Brain ────────────────────────────────────────────
    from factory.brain import FactoryBrain
    brain = FactoryBrain()
    _brain_stats = brain.stats
    print(f"Factory Brain   : {_brain_stats['total']} entries"
          f" ({', '.join(f'{v} {k}' for k, v in _brain_stats['by_type'].items())})")
    logger.info(f"[FactoryBrain] stats={_brain_stats}")

    _active = active_agents or []
    _disabled = disabled_agents or []
    enabled_set = set(_active) if active_agents is not None else None

    # Determine platform from project config
    _platform = "ios"
    if project_config:
        _active_lines = project_config.get_active_lines()
        if _active_lines:
            _platform = _active_lines[0]

    manager = TaskManager(enabled_agents=enabled_set, platform=_platform, project_name=project_name)
    if _platform != "ios":
        print(f"Platform roles  : {_platform} (agents receive platform-specific instructions)")
        logger.info(f"[PlatformRoles] platform={_platform}")
    team = manager.create_team()

    full_task = manager.build_full_task(user_task)

    context_loaded = not manager.project_context.startswith("[Project context not available")
    memory_summary = manager.get_memory_summary()
    memory_has_entries = memory_summary != "(no memory entries yet)"

    header = "DriveAI AutoGen — Multi-Agent Conversation"
    print("=" * 60)
    print(header)
    print("=" * 60)
    print(f"Project context : {'loaded' if context_loaded else 'NOT FOUND — using fallback'}")
    print(f"Memory          : {'entries loaded' if memory_has_entries else 'empty (first run)'}")
    if workflow_recipe:
        print(f"Workflow recipe  : {workflow_recipe}")
    if session_preset:
        print(f"Session preset  : {session_preset}")
    if profile:
        print(f"Profile         : {profile}")
    print(f"Env profile     : {env_profile}")
    print(f"Model           : {model or '(unknown)'}")
    print(f"Run mode        : {run_mode}")
    print(f"Approval mode   : {approval_mode}")
    if _active:
        print(f"Active agents   : {', '.join(_active)}")
    if _disabled:
        print(f"Disabled agents : {', '.join(_disabled)}")
    if pack:
        print(f"Pack            : {pack}")
    if template:
        print(f"Template        : {template}")
        if template_name_value:
            print(f"Name            : {template_name_value}")
    if project_name:
        print(f"Project         : {project_name}")
    else:
        print("Project         : NONE — Operations Layer will be skipped!")
    print(f"Task            : {user_task}")
    print("=" * 60)
    print()

    logger.info("=" * 60)
    logger.info(header)
    logger.info(f"Run ID          : {run_id}")
    logger.info(f"Project         : {project_name or 'NONE'}")
    if workflow_recipe:
        logger.info(f"Workflow recipe  : {workflow_recipe}")
    if session_preset:
        logger.info(f"Session preset  : {session_preset}")
    if profile:
        logger.info(f"Profile         : {profile}")
    logger.info(f"Env profile     : {env_profile}")
    logger.info(f"Model           : {model or '(unknown)'}")
    logger.info(f"Run mode        : {run_mode}")
    logger.info(f"Approval mode   : {approval_mode}")
    if _active:
        logger.info(f"Active agents   : {', '.join(_active)}")
    if _disabled:
        logger.info(f"Disabled agents : {', '.join(_disabled)}")
    if pack:
        logger.info(f"Pack            : {pack}")
    if template:
        logger.info(f"Template        : {template}")
        if template_name_value:
            logger.info(f"Name            : {template_name_value}")
    logger.info(f"Started         : {datetime.now().isoformat()}")
    logger.info(f"Project context : {'loaded' if context_loaded else 'not available'}")
    logger.info(f"Task            : {user_task}")
    logger.info("=" * 60)
    logger.info("")
    logger.info("--- Project Context ---")
    logger.info(manager.project_context)
    logger.info("--- End of Project Context ---")
    logger.info("")
    logger.info("--- Memory ---")
    logger.info(memory_summary)
    logger.info("--- End of Memory ---")
    logger.info("")

    # ── Pass 1: Implementation (all modes) ──────────────────────────
    result = await _run_with_retry(team, task=full_task)
    await _log_pass(logger, "Implementation Pass", result.messages)

    # Clean stale generated files before extraction
    _clean_generated_code()

    # ── Code extraction (platform-aware) ────────────────────────────
    _extraction_lang = project_config.get_extraction_language() if project_config else "swift"
    extractor = get_extractor(_extraction_lang)
    print(f"Code extraction : {_extraction_lang} (via {type(extractor).__name__})")
    logger.info(f"[Extraction] language={_extraction_lang} extractor={type(extractor).__name__}")

    # Determine file extensions for this language
    _file_extensions = {
        "swift": [".swift"], "kotlin": [".kt"],
        "typescript": [".ts", ".tsx"], "python": [".py"],
    }.get(_extraction_lang, [".swift"])

    if not project_name:
        print("WARNING: No project context — ProjectIntegrator and CodeExtractor project-awareness inactive.")
    integrator = ProjectIntegrator(
        os.path.join("projects", project_name) if project_name else "generated_code",
        file_extensions=_file_extensions,
    )
    code_counts = extractor.extract_code(result.messages, project_name=project_name)

    # Guard: abort integration if extraction was aborted (too many files)
    if code_counts.get("aborted"):
        print("[ABORT] Integration skipped — extraction was aborted (file limit exceeded).")
        logger.info("Integration skipped — extraction aborted.")
        xcode_counts = {"status": "aborted", "integrated": 0, "unchanged": 0, "skipped_existing": 0}
    else:
        xcode_counts = integrator.integrate_generated_code(approval=approval_mode)

    # Build compact implementation summary for review passes (after team.reset,
    # reviewers lose implementation context — this restores the essentials).
    impl_summary = extractor.build_implementation_summary(user_task, template)
    if impl_summary:
        print(f"  Implementation summary: {len(impl_summary)} chars for review context")

    # Empty placeholders for skipped passes
    empty = []
    bug_result_msgs = empty
    cd_result_msgs = empty
    ux_result_msgs = empty
    refactor_result_msgs = empty
    test_result_msgs = empty
    fix_result_msgs = empty

    # ── Phase gate + review digest setup ────────────────────────────
    gate_mgr = PhaseGateManager()
    skipped_phases: list[str] = []
    review_digests: dict[str, str] = {}  # accumulated review findings across passes
    gate_ctx = {
        "implementation_messages": len(result.messages),
        "bug_review_messages": 0,
        "refactor_messages": 0,
        "test_generation_messages": 0,
    }

    # ── Pass 2–4: standard + full ────────────────────────────────────
    if run_mode in ("standard", "full"):
        # Reset team context between implementation and review passes.
        # Without this, accumulated implementation output (25-35 files of Swift code)
        # causes >50k tokens in subsequent agent calls, hitting Haiku rate limits.
        await team.reset()

        # Bug Hunter
        _gate_ok, _gate_reason = gate_mgr.evaluate_gate("bug_review", gate_ctx)
        if not _gate_ok:
            print(f"\nPhase gate: skipping bug_review ({_gate_reason})")
            logger.info(f"Phase gate: skipping bug_review ({_gate_reason})")
            skipped_phases.append("bug_review")
        else:
            print()
            print("--- Bug Hunter pass ---")
            bug_review_task = (
                f"Review the generated implementation for the task '{user_task}'. "
                "Identify potential bugs, missing edge cases, crash risks, and structural weaknesses. "
                "Propose concrete fixes for each finding."
            )
            if impl_summary:
                bug_review_task = f"{impl_summary}\n\n{bug_review_task}"
            # Inject factory knowledge (error patterns, failure cases)
            _bug_knowledge = get_knowledge_block("bug_hunter")
            if _bug_knowledge:
                bug_review_task = f"{_bug_knowledge}\n\n{bug_review_task}"
                print(f"  Factory knowledge: {len(_bug_knowledge)} chars injected")
            bug_result = await _run_with_retry(team, task=bug_review_task)
            bug_result_msgs = list(bug_result.messages)
            gate_ctx["bug_review_messages"] = len(bug_result_msgs)
            await _log_pass(logger, "Bug Hunter Pass", bug_result_msgs)
            _bug_digest = _extract_review_digest(bug_result_msgs, "bug_review")
            if _bug_digest:
                review_digests["bug_review"] = _bug_digest
                print(f"  Review digest: {len(_bug_digest)} chars captured")

        # Reset between Bug Hunter and CD to clear accumulated context.
        await team.reset()

        # Creative Director (advisory — only for feature/screen templates)
        _cd_skip = template and template not in ("feature", "screen")
        if _cd_skip:
            print(f"\nCreative Director: skipping (template={template})")
            logger.info(f"Creative Director: skipping (template={template})")
            skipped_phases.append("creative_review")
        else:
            print()
            print("--- Creative Director pass (advisory) ---")
            cd_review_task = (
                f"creative_director: Review the generated implementation for '{user_task}' from a product quality perspective. "
                "Evaluate: Does this feel like a premium product or a generic template? "
                "Check for: emotional screen function, micro-copy quality, design consistency, "
                "interaction patterns beyond basic tap, differentiation from generic apps. "
                "Rate: pass / conditional_pass / fail. "
                "For each finding, give a concrete improvement suggestion. Max 5 findings."
            )
            if impl_summary:
                cd_review_task = f"{impl_summary}\n\n{cd_review_task}"
            # Inject prior review findings (Bug Hunter) so CD has upstream context
            _prior_ctx = _build_review_context(review_digests)
            if _prior_ctx:
                cd_review_task = f"{_prior_ctx}\n\n{cd_review_task}"
                print(f"  Prior review context: {len(_prior_ctx)} chars injected")
            # Inject factory knowledge (prior learnings) for grounded review
            _cd_knowledge = get_cd_knowledge_block(template)
            if _cd_knowledge:
                cd_review_task = f"{_cd_knowledge}\n\n{cd_review_task}"
                print(f"  Factory knowledge: {len(_cd_knowledge)} chars injected")
            cd_result = await _run_with_retry(team, task=cd_review_task)
            cd_result_msgs = list(cd_result.messages)
            await _log_pass(logger, "Creative Director Pass", cd_result_msgs)
            _cd_digest = _extract_review_digest(cd_result_msgs, "creative_review")
            if _cd_digest:
                review_digests["creative_review"] = _cd_digest
                print(f"  Review digest: {len(_cd_digest)} chars captured")

            # ── CD Soft Gate ──────────────────────────────────────────
            # Parse CD rating and apply soft-gate logic.
            # fail → stop further passes, mark run as product_quality_fail
            # conditional_pass → continue with warning
            # pass / unparseable → continue normally (fail-open)
            _cd_detail = extract_cd_rating_detailed(cd_result_msgs)
            _cd_rating = _cd_detail.rating

            # Audit trail: log all candidates and selection reason
            if _cd_detail.candidates:
                print(f"  CD rating candidates ({len(_cd_detail.candidates)}):")
                for c in _cd_detail.candidates:
                    marker = " ←" if (c["source"] == _cd_detail.selected_source
                                      and c["rating"] == _cd_rating) else ""
                    print(f"    [{c['source']}] msg #{c['msg_index']}: {c['rating']}{marker}")
                print(f"  Selected: {_cd_rating} from {_cd_detail.selected_source}")
                print(f"  Reason: {_cd_detail.selected_reason}")
                logger.info(f"[CD RATING] candidates={_cd_detail.candidates} "
                            f"selected={_cd_rating} source={_cd_detail.selected_source} "
                            f"reason={_cd_detail.selected_reason}")
            else:
                print("  CD rating: not detected (continuing as pass)")
                logger.info("[CD RATING] no rating lines found, defaulting to pass")
                _cd_rating = "pass"

            # CD gate policy is profile-aware:
            # - dev/fast: CD fail is advisory (non-blocking) — pipeline continues
            # - standard/premium: CD fail stops the pipeline (blocking)
            _cd_blocking = profile in ("standard", "premium")

            if _cd_rating == "fail" and not no_cd_gate and _cd_blocking:
                print(f"\n[CD GATE] Product quality FAIL — stopping further passes.")
                print(f"  Profile: {profile} (blocking mode)")
                print(f"  Source: {_cd_detail.selected_source} ({_cd_detail.selected_reason})")
                print("  Use --no-cd-gate to override this gate.")
                logger.info(f"[CD GATE] FAIL — BLOCKING (profile={profile}). "
                            f"Pipeline stopped. source={_cd_detail.selected_source}")
                skipped_phases.extend(["refactor", "test_generation", "fix_execution"])
                gate_ctx["cd_gate_stop"] = True
            elif _cd_rating == "fail" and not no_cd_gate and not _cd_blocking:
                print(f"\n[CD GATE] Product quality FAIL — advisory only, continuing.")
                print(f"  Profile: {profile} (advisory mode — fail is non-blocking)")
                print(f"  Source: {_cd_detail.selected_source} ({_cd_detail.selected_reason})")
                print("  CD findings remain available for downstream passes.")
                logger.info(f"[CD GATE] FAIL — ADVISORY (profile={profile}). "
                            f"Pipeline continues. source={_cd_detail.selected_source}")
            elif _cd_rating == "conditional_pass":
                print(f"  [CD GATE] Conditional pass — from {_cd_detail.selected_source}, continuing.")
                logger.info("[CD GATE] Conditional pass — continuing with product quality warnings.")

        # UX Psychology (advisory — only for feature/screen templates)
        _uxp_skip = template and template not in ("feature", "screen")
        if _uxp_skip or gate_ctx.get("cd_gate_stop"):
            if not gate_ctx.get("cd_gate_stop"):
                print(f"\nUX Psychology: skipping (template={template})")
                logger.info(f"UX Psychology: skipping (template={template})")
                skipped_phases.append("ux_psychology_review")
        else:
            await team.reset()
            print()
            print("--- UX Psychology pass (advisory) ---")
            ux_review_task = (
                f"ux_psychology: Analyze the generated implementation for '{user_task}' from a behavioral psychology perspective. "
                "Evaluate: motivation architecture, progress feedback, cognitive load, "
                "learning psychology principles, retention mechanics, emotional reinforcement, habit formation. "
                "For each finding, state the psychological principle, the gap, and a specific fix. "
                "Max 5 findings."
            )
            if impl_summary:
                ux_review_task = f"{impl_summary}\n\n{ux_review_task}"
            # Inject prior review findings (Bug Hunter + CD)
            _prior_ctx = _build_review_context(review_digests)
            if _prior_ctx:
                ux_review_task = f"{_prior_ctx}\n\n{ux_review_task}"
                print(f"  Prior review context: {len(_prior_ctx)} chars injected")
            ux_result = await _run_with_retry(team, task=ux_review_task)
            ux_result_msgs = list(ux_result.messages)
            await _log_pass(logger, "UX Psychology Pass", ux_result_msgs)
            _ux_digest = _extract_review_digest(ux_result_msgs, "ux_psychology")
            if _ux_digest:
                review_digests["ux_psychology"] = _ux_digest
                print(f"  Review digest: {len(_ux_digest)} chars captured")

        # Reset before Refactor to clear review message state.
        if not gate_ctx.get("cd_gate_stop"):
            await team.reset()

        # Refactor
        _gate_ok, _gate_reason = gate_mgr.evaluate_gate("refactor", gate_ctx)
        if gate_ctx.get("cd_gate_stop"):
            pass  # CD gate stopped pipeline — skipped_phases already updated
        elif not _gate_ok:
            print(f"\nPhase gate: skipping refactor ({_gate_reason})")
            logger.info(f"Phase gate: skipping refactor ({_gate_reason})")
            skipped_phases.append("refactor")
        else:
            print()
            print("--- Refactor pass ---")
            refactor_task = (
                f"Refactor the generated implementation for the task '{user_task}'. "
                "Improve readability, modularity, and maintainability while preserving behavior. "
                "Reduce duplication, improve naming, and suggest cleaner structure where appropriate."
            )
            if impl_summary:
                refactor_task = f"{impl_summary}\n\n{refactor_task}"
            # Inject prior review findings (Bug Hunter + CD + UX)
            _prior_ctx = _build_review_context(review_digests)
            if _prior_ctx:
                refactor_task = f"{_prior_ctx}\n\n{refactor_task}"
                print(f"  Prior review context: {len(_prior_ctx)} chars injected")
            # Inject factory knowledge (error patterns, technical patterns)
            _refactor_knowledge = get_knowledge_block("refactor_agent")
            if _refactor_knowledge:
                refactor_task = f"{_refactor_knowledge}\n\n{refactor_task}"
                print(f"  Factory knowledge: {len(_refactor_knowledge)} chars injected")
            refactor_result = await _run_with_retry(team, task=refactor_task)
            refactor_result_msgs = list(refactor_result.messages)
            gate_ctx["refactor_messages"] = len(refactor_result_msgs)
            await _log_pass(logger, "Refactor Pass", refactor_result_msgs)
            _refactor_digest = _extract_review_digest(refactor_result_msgs, "refactor")
            if _refactor_digest:
                review_digests["refactor"] = _refactor_digest
                print(f"  Review digest: {len(_refactor_digest)} chars captured")

        # Test generation
        _gate_ok, _gate_reason = gate_mgr.evaluate_gate("test_generation", gate_ctx)
        if gate_ctx.get("cd_gate_stop"):
            pass  # CD gate stopped pipeline
        elif not _gate_ok:
            print(f"\nPhase gate: skipping test_generation ({_gate_reason})")
            logger.info(f"Phase gate: skipping test_generation ({_gate_reason})")
            skipped_phases.append("test_generation")
        else:
            print()
            print("--- Test generation pass ---")
            test_task = (
                f"Generate structured test cases for the implemented feature: '{user_task}'. "
                "Include happy paths, edge cases, invalid input handling, and failure scenarios. "
                "Group tests by component or behavior."
            )
            if impl_summary:
                test_task = f"{impl_summary}\n\n{test_task}"
            test_result = await _run_with_retry(team, task=test_task)
            test_result_msgs = list(test_result.messages)
            gate_ctx["test_generation_messages"] = len(test_result_msgs)
            await _log_pass(logger, "Test Generation Pass", test_result_msgs)

    # ── Pass 5: Fix execution (full only) ────────────────────────────
    if run_mode == "full" and not gate_ctx.get("cd_gate_stop"):
        _gate_ok, _gate_reason = gate_mgr.evaluate_gate("fix_execution", gate_ctx)
        if not _gate_ok:
            print(f"\nPhase gate: skipping fix_execution ({_gate_reason})")
            logger.info(f"Phase gate: skipping fix_execution ({_gate_reason})")
            skipped_phases.append("fix_execution")
        else:
            print()
            print("--- Fix execution pass ---")
            fix_executor = FixExecutor()
            _fix_knowledge = get_knowledge_block("fix_executor")
            if _fix_knowledge:
                print(f"  Factory knowledge: {len(_fix_knowledge)} chars injected")
            fix_task = fix_executor.build_fix_task(
                user_task=user_task,
                bug_messages=bug_result_msgs,
                refactor_messages=refactor_result_msgs,
                review_context=_build_review_context(review_digests),
                impl_summary=impl_summary,
                knowledge_block=_fix_knowledge,
            )
            fix_result = await _run_with_retry(team, task=fix_task)
            fix_result_msgs = list(fix_result.messages)
            await _log_pass(logger, "Fix Execution Pass", fix_result_msgs)

            fix_code_counts = extractor.extract_code(fix_result_msgs, project_name=project_name)
            if fix_code_counts.get("aborted"):
                print("[ABORT] Fix integration skipped — extraction was aborted (file limit exceeded).")
                logger.info("Fix integration skipped — extraction aborted.")
            else:
                integrator.integrate_generated_code(approval=approval_mode)
                if fix_code_counts["saved"] > 0:
                    print(f"  Swift files updated: {fix_code_counts['saved']} new/changed after fix pass")
            print("Fix execution pass completed.")

    # ── Finalize ─────────────────────────────────────────────────────
    if active_feature:
        manager.feature_planner.complete_feature(active_feature)

    all_messages = (
        list(result.messages)
        + bug_result_msgs
        + cd_result_msgs
        + ux_result_msgs
        + refactor_result_msgs
        + test_result_msgs
        + fix_result_msgs
    )
    mm = manager.memory_manager
    mm.add_decision(f"Run completed for task: {user_task}")
    try:
        counts = mm.extract_memory_from_conversation(all_messages)
    except Exception as mem_extract_err:
        print(f"\n[WARNING] Memory extraction failed: {mem_extract_err}")
        logger.warning(f"Memory extraction failed: {mem_extract_err}")
        counts = {"decisions": 0, "architecture_notes": 0, "implementation_notes": 0, "review_notes": 0}

    logger.info("=" * 60)
    logger.info(f"Stop reason      : {result.stop_reason}")
    logger.info(f"Messages exchanged: {len(all_messages)}")
    logger.info(f"Finished : {datetime.now().isoformat()}")
    logger.info("=" * 60)

    # Export delivery package
    exporter = DeliveryExporter()
    export_path = exporter.export_run_package(
        run_id=run_id,
        run_mode=run_mode,
        approval_mode=approval_mode,
        profile=profile,
        env_profile=env_profile,
        model=model,
        active_agents=_active,
        disabled_agents=_disabled,
        template=template,
        template_name_value=template_name_value,
        pack=pack,
        pack_task_count=pack_task_count,
        session_preset=session_preset,
        workflow_recipe=workflow_recipe,
        skipped_phases=skipped_phases,
        user_task=user_task,
        task_source=task_source,
        memory_summary=memory_summary,
        impl_messages=list(result.messages),
        bug_messages=bug_result_msgs,
        refactor_messages=refactor_result_msgs,
        test_messages=test_result_msgs,
        fix_messages=fix_result_msgs,
        code_counts=code_counts,
        xcode_counts=xcode_counts,
    )

    # Generate sprint report
    reporter = SprintReporter()
    report_path = reporter.generate_report(
        export_dir=export_path,
        run_id=run_id,
        run_mode=run_mode,
        approval_mode=approval_mode,
        profile=profile,
        env_profile=env_profile,
        model=model,
        active_agents=_active,
        disabled_agents=_disabled,
        template=template,
        template_name_value=template_name_value,
        pack=pack,
        pack_task_count=pack_task_count,
        session_preset=session_preset,
        workflow_recipe=workflow_recipe,
        skipped_phases=skipped_phases,
        user_task=user_task,
        task_source=task_source,
        active_feature=active_feature,
        impl_messages=list(result.messages),
        bug_messages=bug_result_msgs,
        refactor_messages=refactor_result_msgs,
        test_messages=test_result_msgs,
        fix_messages=fix_result_msgs,
        code_counts=code_counts,
        xcode_counts=xcode_counts,
        memory_counts=counts,
    )

    # Run manifest
    manifest_path = RunManifest().create_manifest(
        export_dir=export_path,
        run_id=run_id,
        run_mode=run_mode,
        approval_mode=approval_mode,
        profile=profile,
        env_profile=env_profile,
        model=model,
        active_agents=_active,
        disabled_agents=_disabled,
        template=template,
        template_name_value=template_name_value,
        pack=pack,
        pack_task_count=pack_task_count,
        session_preset=session_preset,
        workflow_recipe=workflow_recipe,
        skipped_phases=skipped_phases,
        user_task=user_task,
        task_source=task_source,
        project_context_loaded=context_loaded,
        memory_used=memory_has_entries,
        impl_messages=list(result.messages),
        bug_messages=bug_result_msgs,
        refactor_messages=refactor_result_msgs,
        test_messages=test_result_msgs,
        fix_messages=fix_result_msgs,
        xcode_counts=xcode_counts,
        export_path=export_path,
        report_path=report_path,
    )

    # Analytics
    with open(manifest_path, encoding="utf-8") as _f:
        manifest_data = json.load(_f)
    AnalyticsTracker().update_from_manifest(manifest_data)

    # Knowledge proposals (analyze run results, store separately for review)
    try:
        _proposals = generate_proposals(
            run_id=run_id,
            user_task=user_task,
            template=template,
            bug_messages=bug_result_msgs,
            cd_messages=cd_result_msgs,
            refactor_messages=refactor_result_msgs,
        )
        _proposal_path = save_proposals(run_id, _proposals)
        if _proposal_path:
            print(f"\nKnowledge proposals: {len(_proposals)} candidates → {_proposal_path}")
        else:
            print("\nKnowledge proposals: none generated")
    except Exception as _pe:
        print(f"\n[WARNING] Knowledge proposals failed: {_pe}")
        logger.warning(f"Knowledge proposals failed: {_pe}")

    # Console summary
    print()
    print("=" * 60)
    print("Conversation complete.")
    msg_breakdown = f"{len(result.messages)} (impl)"
    if run_mode in ("standard", "full"):
        msg_breakdown += f" + {len(bug_result_msgs)} (bugs) + {len(cd_result_msgs)} (creative) + {len(ux_result_msgs)} (ux_psych) + {len(refactor_result_msgs)} (refactor) + {len(test_result_msgs)} (tests)"
    if run_mode == "full":
        msg_breakdown += f" + {len(fix_result_msgs)} (fix)"
    print(f"Messages exchanged : {msg_breakdown}")
    print(f"Run mode           : {run_mode}")
    print(f"Approval mode      : {approval_mode}")
    print(f"Stop reason        : {result.stop_reason}")
    if gate_ctx.get("cd_gate_stop"):
        print(f"CD Gate            : FAIL — pipeline stopped early")
    if skipped_phases:
        print(f"Phases skipped     : {', '.join(skipped_phases)}")
    print(f"Memory updates:")
    print(f"  decisions          : +{1 + counts['decisions']}")
    print(f"  architecture notes : +{counts['architecture_notes']}")
    print(f"  implementation notes: +{counts['implementation_notes']}")
    print(f"  review notes       : +{counts['review_notes']}")
    if code_counts.get("aborted"):
        print(f"Swift extraction   : ABORTED (file limit exceeded)")
    else:
        _lang_label = _extraction_lang.title()
        print(f"{_lang_label} files saved  : {code_counts['saved']} new, {code_counts['skipped']} unchanged")
    xcode_status = xcode_counts.get("status", "integrated")
    if xcode_status == "aborted":
        print(f"Xcode integration  : ABORTED (extraction failed)")
    elif xcode_status == "skipped":
        print(f"Xcode integration  : skipped (approval={approval_mode})")
    else:
        print(f"Xcode integration  : {xcode_counts['integrated']} copied, {xcode_counts.get('unchanged', 0)} unchanged")
    if active_feature:
        fp = manager.feature_planner
        remaining_features = len(fp.backlog["planned"])
        done = len(fp.backlog["completed"])
        print(f"Feature completed  : {active_feature}  ({done} done, {remaining_features} remaining)")
    print(f"Memory saved to    : memory/memory_store.json")
    print(f"Log saved to       : {log_path}")
    print(f"Delivery package   : {export_path}")
    print(f"Sprint report      : {report_path}")
    print(f"Run manifest       : {manifest_path}")
    print("=" * 60)

    # Determine truthful status
    _pipeline_status = "success"
    if code_counts.get("aborted"):
        _pipeline_status = "extraction_aborted"
    elif gate_ctx.get("cd_gate_stop"):
        _pipeline_status = "cd_gate_fail"

    return {
        "status": _pipeline_status,
        "task": user_task,
        "task_source": task_source,
        "profile": profile,
        "env_profile": env_profile,
        "model": model,
        "active_agents": _active,
        "disabled_agents": _disabled,
        "template": template,
        "template_name_value": template_name_value,
        "pack": pack,
        "pack_task_count": pack_task_count,
        "session_preset": session_preset,
        "workflow_recipe": workflow_recipe,
        "skipped_phases": skipped_phases,
        "run_mode": run_mode,
        "approval_mode": approval_mode,
        "delivery_export_path": export_path,
        "sprint_report_path": report_path,
        "run_manifest_path": manifest_path,
        "generated_files_count": len(manifest_data.get("generated_files", [])),
        "integrated_files_count": len(manifest_data.get("integrated_files", [])),
        "message_counts": manifest_data.get("message_counts", {}),
        "project_config_loaded": project_config_loaded,
    }


def run_operations_layer(
    project_name: str,
    env_profile: str = "standard",
    run_id: str | None = None,
    language: str = "swift",
) -> dict:
    """Run the Operations Layer: Output Integrator -> Completion Verifier -> Recovery Runner.

    Returns a dict with the final health status and whether recovery was attempted.
    Recovery is stateful: each attempt receives prior failure context, fingerprint
    comparison detects repeated identical failures, and MAX_RECOVERY_ATTEMPTS is enforced.

    Args:
        run_id: Current run ID (timestamp). When set, the OutputIntegrator will
                only process logs from this run and clean generated/ before writing.
    """
    from factory.operations.output_integrator import OutputIntegrator
    from factory.operations.completion_verifier import CompletionVerifier
    from factory.operations.compile_hygiene_validator import CompileHygieneValidator
    from factory.operations.swift_compile_check import SwiftCompileCheck
    from factory.operations.type_stub_generator import TypeStubGenerator
    from factory.operations.property_shape_repairer import PropertyShapeRepairer
    from factory.operations.stale_artifact_guard import StaleArtifactGuard
    from factory.operations.recovery_runner import (
        RecoveryRunner, RecoveryState, MAX_RECOVERY_ATTEMPTS,
        load_recovery_state, clear_recovery_state,
    )
    from factory.operations.run_memory import record_run, print_summary as print_memory_summary

    # Resolve file extensions for this language
    _file_extensions = {
        "swift": [".swift"], "kotlin": [".kt"],
        "typescript": [".ts", ".tsx"], "python": [".py"],
    }.get(language, [".swift"])

    print()
    print("=" * 60)
    print(f"  Operations Layer ({language})")
    print("=" * 60)

    # --- Pass 1: Integrate + Verify ---
    print("\n[OpsLayer] Pass 1: Output Integrator")
    integrator = OutputIntegrator(
        project_name=project_name,
        log_filter=run_id,
        clean_before_integrate=True,
        file_extensions=_file_extensions,
    )
    integrator.run()

    print("\n[OpsLayer] Pass 1: Completion Verifier")
    verifier = CompletionVerifier(project_name=project_name, language=language)
    report = verifier.verify()

    # --- Compile Hygiene Check (FK-011, FK-012, FK-015) ---
    print("\n[OpsLayer] Compile Hygiene Validator")
    hygiene = CompileHygieneValidator(project_name=project_name, language=language)
    hygiene_report = hygiene.validate()
    hygiene_status = hygiene_report.status.value

    # --- FK-014 Type Stub Generator ---
    stub_report = None
    fk014_blocking = [i for i in hygiene_report.issues
                      if i.pattern_id == "FK-014" and i.severity.value == "blocking"]
    if fk014_blocking:
        print(f"\n[OpsLayer] Type Stub Generator — {len(fk014_blocking)} FK-014 blocker(s)")
        stub_gen = TypeStubGenerator(project_name=project_name, language=language)
        stub_report = stub_gen.generate_from_hygiene(hygiene_report)
        stub_report.print_summary()

        # Re-run hygiene after stubs to update status
        if stub_report.stubs_created > 0:
            print("\n[OpsLayer] Re-running Compile Hygiene after stub generation...")
            hygiene = CompileHygieneValidator(project_name=project_name, language=language)
            hygiene_report = hygiene.validate()
            hygiene_status = hygiene_report.status.value
    else:
        print("\n[OpsLayer] Type Stub Generator — no FK-014 blockers, skipping.")

    # --- FK-013 Property Shape Repairer ---
    shape_report = None
    fk013_blocking = [i for i in hygiene_report.issues
                      if i.pattern_id == "FK-013" and i.severity.value == "blocking"]
    if fk013_blocking:
        print(f"\n[OpsLayer] Property Shape Repairer — {len(fk013_blocking)} FK-013 blocker(s)")
        shape_repairer = PropertyShapeRepairer(project_name=project_name)
        shape_report = shape_repairer.repair_from_hygiene(hygiene_report)
        shape_report.print_summary()

        # Re-run hygiene after repairs to update status
        if shape_report.repairs_applied > 0:
            print("\n[OpsLayer] Re-running Compile Hygiene after shape repair...")
            hygiene = CompileHygieneValidator(project_name=project_name, language=language)
            hygiene_report = hygiene.validate()
            hygiene_status = hygiene_report.status.value
    else:
        print("\n[OpsLayer] Property Shape Repairer — no FK-013 blockers, skipping.")

    # --- Stale Artifact Guard ---
    stale_report = None
    remaining_blocking = [i for i in hygiene_report.issues
                          if i.severity.value == "blocking"]
    if remaining_blocking:
        print(f"\n[OpsLayer] Stale Artifact Guard — {len(remaining_blocking)} blocking issue(s) remain")
        stale_guard = StaleArtifactGuard(project_name=project_name)
        stale_report = stale_guard.check_and_quarantine(hygiene_report)
        stale_report.print_summary()

        # Re-run hygiene after quarantine to update status
        if stale_report.quarantined > 0:
            print("\n[OpsLayer] Re-running Compile Hygiene after quarantine...")
            hygiene = CompileHygieneValidator(project_name=project_name, language=language)
            hygiene_report = hygiene.validate()
            hygiene_status = hygiene_report.status.value
    else:
        print("\n[OpsLayer] Stale Artifact Guard — no blocking issues, skipping.")

    # --- Swift Compile Check (swiftc -parse) ---
    print("\n[OpsLayer] Swift Compile Check")
    swift_checker = SwiftCompileCheck(project_name=project_name)
    swift_report = swift_checker.check()
    swift_compile_status = swift_report.status.value

    initial_health = report.health.value
    final_health = initial_health
    recovery_attempts = 0
    recovery_outcome = "none"

    # --- Recovery loop (stateful, max MAX_RECOVERY_ATTEMPTS) ---
    if initial_health in ("complete", "mostly_complete"):
        print(f"\n[OpsLayer] Health: {initial_health.upper()} -- no recovery needed.")
        clear_recovery_state()
    elif initial_health == "incomplete":
        # Load any prior recovery state (from a previous ops-layer run)
        prior_state = load_recovery_state(project_name)

        for attempt in range(1, MAX_RECOVERY_ATTEMPTS + 1):
            recovery_attempts = attempt
            print(f"\n[OpsLayer] Health: INCOMPLETE -- recovery attempt {attempt}/{MAX_RECOVERY_ATTEMPTS}")

            # Build failure context for this attempt
            missing_list = report.to_dict().get("missing_files", [])
            incomplete_list = report.to_dict().get("incomplete_files", [])
            failure_summary = (
                f"{len(missing_list)} missing, {len(incomplete_list)} incomplete "
                f"(health: {initial_health})"
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
                timestamp=report.to_dict().get("timestamp", ""),
            )

            runner = RecoveryRunner(
                project_name=project_name,
                env_profile=env_profile,
                dry_run=False,
                failure_context=failure_ctx,
            )
            recovery_summary = runner.run()
            recovery_outcome = recovery_summary.outcome

            # If repeated failure or terminal stop, don't retry
            if recovery_outcome in ("repeated_failure", "terminal_stop", "skipped"):
                print(f"\n[OpsLayer] Recovery stopped: {recovery_outcome}")
                break

            # Re-integrate + re-verify after recovery
            print(f"\n[OpsLayer] Pass {attempt + 1}: Re-integrating after recovery")
            integrator_r = OutputIntegrator(
                project_name=project_name,
                log_filter=run_id,
                clean_before_integrate=True,
                file_extensions=_file_extensions,
            )
            integrator_r.run()

            print(f"\n[OpsLayer] Pass {attempt + 1}: Re-verifying after recovery")
            verifier_r = CompletionVerifier(project_name=project_name, language=language)
            report = verifier_r.verify()
            final_health = report.health.value

            if final_health in ("complete", "mostly_complete"):
                print(f"\n[OpsLayer] Recovery successful: {final_health.upper()}")
                clear_recovery_state()
                break

            # Prepare prior_state for next iteration
            prior_state = RecoveryState(
                project_name=project_name,
                attempt_number=attempt,
                failed_stage="completion_verifier",
                failure_status=final_health,
                failure_summary=failure_summary,
                failure_fingerprint=recovery_summary.failure_fingerprint,
                prior_fingerprints=(
                    failure_ctx.prior_fingerprints +
                    ([failure_ctx.failure_fingerprint] if failure_ctx.failure_fingerprint else [])
                ),
            )
        else:
            # Exhausted all attempts
            print(f"\n[OpsLayer] Recovery exhausted ({MAX_RECOVERY_ATTEMPTS} attempts). "
                  f"Final health: {final_health.upper()}")
    elif initial_health == "insufficient_evidence":
        print(f"\n[OpsLayer] Health: INSUFFICIENT_EVIDENCE -- no specs available, "
              f"project-evidence mode used. Recovery not triggered.")
    else:
        # FAILED
        print(f"\n[OpsLayer] Health: FAILED -- too little output for recovery.")

    # --- Summary ---
    print()
    print("=" * 60)
    print("  Operations Layer Summary")
    print("=" * 60)
    print(f"  Project:            {project_name}")
    print(f"  Initial status:     {initial_health.upper()}")
    print(f"  Recovery attempts:  {recovery_attempts}")
    print(f"  Recovery outcome:   {recovery_outcome}")
    print(f"  Final status:       {final_health.upper()}")
    print(f"  Compile hygiene:    {hygiene_status}")
    if stub_report and stub_report.stubs_created > 0:
        print(f"  FK-014 stubs:       {stub_report.stubs_created} created")
    if shape_report and shape_report.repairs_applied > 0:
        print(f"  FK-013 repairs:     {shape_report.repairs_applied} applied")
    if stale_report and stale_report.quarantined > 0:
        print(f"  Stale quarantined:  {stale_report.quarantined} file(s)")
    print(f"  Swift compile:      {swift_compile_status}")
    print("=" * 60)
    print()

    # --- Run Memory: record outcome ---
    try:
        run_record = record_run(
            project_name, report.to_dict(),
            recovery_attempts=recovery_attempts,
            recovery_outcome=recovery_outcome,
        )
        print_memory_summary(project_name)
    except Exception as mem_err:
        print(f"\n[RunMemory] Error: {mem_err}")

    # --- Knowledge Writeback: close the learning loop ---
    writeback_result = {}
    try:
        from factory_knowledge.knowledge_writeback import run_writeback
        writeback_result = run_writeback(dry_run=False)
    except Exception as wb_err:
        print(f"\n[KnowledgeWriteback] Error: {wb_err}")

    return {
        "project": project_name,
        "initial_health": initial_health,
        "recovery_attempts": recovery_attempts,
        "recovery_outcome": recovery_outcome,
        "final_health": final_health,
        "compile_hygiene": hygiene_status,
        "swift_compile": swift_compile_status,
        "knowledge_writeback": writeback_result,
    }
