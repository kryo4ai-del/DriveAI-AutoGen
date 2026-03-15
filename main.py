# main.py
# Entry point for the DriveAI-AutoGen multi-agent system.

import asyncio
import json
import os
import shutil
import sys
from datetime import datetime
from tasks.task_manager import TaskManager, setup_logger
from tasks.task_template_manager import TaskTemplateManager
from tasks.task_pack_manager import TaskPackManager
from code_generation.code_extractor import CodeExtractor
from code_generation.project_integrator import ProjectIntegrator
from delivery.delivery_exporter import DeliveryExporter
from delivery.sprint_reporter import SprintReporter
from tasks.fix_executor import FixExecutor
from tasks.task_queue import TaskQueue
from delivery.run_manifest import RunManifest
from analytics.analytics_tracker import AnalyticsTracker
from config.llm_config import set_active_profile, get_llm_config, get_active_profile_name
from config.agent_toggle_config import resolve_agent_toggles, ALL_AGENTS
from planning.backlog_io import BacklogIO
from config.session_preset_manager import SessionPresetManager
from workflows.workflow_recipe_manager import WorkflowRecipeManager
from workflows.phase_gate_manager import PhaseGateManager
from utils.git_auto_commit import GitAutoCommit
from factory_knowledge.knowledge_reader import get_cd_knowledge_block, get_knowledge_block, extract_cd_rating, extract_cd_rating_detailed
from factory_knowledge.proposal_generator import generate_proposals, save_proposals
from autogen_agentchat.conditions import MaxMessageTermination

# Ensure UTF-8 output on Windows
if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

VALID_MODES = ("quick", "standard", "full")
VALID_APPROVALS = ("auto", "ask", "off")
VALID_PROFILES = ("fast", "dev", "safe", "agentic")

PROFILE_DEFAULTS = {
    "fast":    {"mode": "quick",    "approval": "off"},
    "dev":     {"mode": "standard", "approval": "auto"},
    "safe":    {"mode": "standard", "approval": "ask"},
    "agentic": {"mode": "full",     "approval": "auto"},
}


def _parse_args() -> dict:
    """
    Parse sys.argv. Returns a dict of all parsed flags and values.
    Profile defaults are applied first; explicit --mode/--approval override them.
    """
    args = sys.argv[1:]
    result = {
        "task": None,
        "mode": None,           # resolved below after profile processing
        "approval": None,       # resolved below after profile processing
        "profile": None,
        "env_profile": "dev",
        "disable_agents": [],   # agent names to disable for this run
        "enable_agents": [],    # agent names to force-enable for this run
        "template": None,       # task template name
        "name": None,           # name value for template or pack
        "list_templates": False,
        "pack": None,           # task pack name
        "list_packs": False,
        "queue_add_task": None,
        "queue_run": False,
        "queue_run_all": False,
        "queue_summary": False,
        "failed_summary": False,
        "retry_failed": None,
        "retry_all_failed": False,
        "limit": None,
        "analytics_summary": False,
        "json_output": False,
        "task_file": None,
        "export_backlog": None,
        "import_backlog": None,
        "replace_backlog": False,
        "export_queue": None,
        "import_queue": None,
        "replace_queue": False,
        "session_preset": None,
        "list_session_presets": False,
        "workflow_recipe": None,
        "list_workflow_recipes": False,
        "explicit_mode": None,
        "explicit_approval": None,
        "explicit_env_profile": None,
        "no_cd_gate": False,
        "no_ops_layer": False,
        "project": None,
    }
    explicit_mode = None
    explicit_approval = None
    explicit_env_profile = None

    i = 0
    while i < len(args):
        if args[i] == "--mode" and i + 1 < len(args):
            candidate = args[i + 1].lower()
            if candidate in VALID_MODES:
                explicit_mode = candidate
            i += 2
        elif args[i] == "--approval" and i + 1 < len(args):
            candidate = args[i + 1].lower()
            if candidate in VALID_APPROVALS:
                explicit_approval = candidate
            i += 2
        elif args[i] == "--profile" and i + 1 < len(args):
            candidate = args[i + 1].lower()
            if candidate in VALID_PROFILES:
                result["profile"] = candidate
            i += 2
        elif args[i] == "--env-profile" and i + 1 < len(args):
            result["env_profile"] = args[i + 1].lower()
            explicit_env_profile = args[i + 1].lower()
            i += 2
        elif args[i] == "--disable-agent" and i + 1 < len(args):
            name = args[i + 1].lower()
            if name in ALL_AGENTS:
                result["disable_agents"].append(name)
            i += 2
        elif args[i] == "--enable-agent" and i + 1 < len(args):
            name = args[i + 1].lower()
            if name in ALL_AGENTS:
                result["enable_agents"].append(name)
            i += 2
        elif args[i] == "--template" and i + 1 < len(args):
            result["template"] = args[i + 1].lower()
            i += 2
        elif args[i] == "--name" and i + 1 < len(args):
            result["name"] = args[i + 1]
            i += 2
        elif args[i] == "--list-templates":
            result["list_templates"] = True
            i += 1
        elif args[i] == "--pack" and i + 1 < len(args):
            result["pack"] = args[i + 1].lower()
            i += 2
        elif args[i] == "--list-packs":
            result["list_packs"] = True
            i += 1
        elif args[i] == "--queue-add" and i + 1 < len(args):
            result["queue_add_task"] = args[i + 1]
            i += 2
        elif args[i] == "--queue-run":
            result["queue_run"] = True
            i += 1
        elif args[i] == "--queue-run-all":
            result["queue_run_all"] = True
            i += 1
        elif args[i] == "--queue-summary":
            result["queue_summary"] = True
            i += 1
        elif args[i] == "--failed-summary":
            result["failed_summary"] = True
            i += 1
        elif args[i] == "--retry-failed" and i + 1 < len(args):
            result["retry_failed"] = args[i + 1]
            i += 2
        elif args[i] == "--retry-all-failed":
            result["retry_all_failed"] = True
            i += 1
        elif args[i] == "--analytics-summary":
            result["analytics_summary"] = True
            i += 1
        elif args[i] == "--json":
            result["json_output"] = True
            i += 1
        elif args[i] == "--task-file" and i + 1 < len(args):
            result["task_file"] = args[i + 1]
            i += 2
        elif args[i] == "--limit" and i + 1 < len(args):
            try:
                result["limit"] = int(args[i + 1])
            except ValueError:
                pass
            i += 2
        elif args[i] == "--export-backlog" and i + 1 < len(args):
            result["export_backlog"] = args[i + 1]
            i += 2
        elif args[i] == "--import-backlog" and i + 1 < len(args):
            result["import_backlog"] = args[i + 1]
            i += 2
        elif args[i] == "--replace-backlog":
            result["replace_backlog"] = True
            i += 1
        elif args[i] == "--export-queue" and i + 1 < len(args):
            result["export_queue"] = args[i + 1]
            i += 2
        elif args[i] == "--import-queue" and i + 1 < len(args):
            result["import_queue"] = args[i + 1]
            i += 2
        elif args[i] == "--replace-queue":
            result["replace_queue"] = True
            i += 1
        elif args[i] == "--session-preset" and i + 1 < len(args):
            result["session_preset"] = args[i + 1]
            i += 2
        elif args[i] == "--list-session-presets":
            result["list_session_presets"] = True
            i += 1
        elif args[i] == "--workflow-recipe" and i + 1 < len(args):
            result["workflow_recipe"] = args[i + 1]
            i += 2
        elif args[i] == "--list-workflow-recipes":
            result["list_workflow_recipes"] = True
            i += 1
        elif args[i] == "--no-cd-gate":
            result["no_cd_gate"] = True
            i += 1
        elif args[i] == "--no-ops-layer":
            result["no_ops_layer"] = True
            i += 1
        elif args[i] == "--project" and i + 1 < len(args):
            result["project"] = args[i + 1]
            i += 2
        elif not args[i].startswith("--"):
            result["task"] = args[i]
            i += 1
        else:
            i += 1

    # Store raw explicit values for session preset precedence resolution in main()
    result["explicit_mode"] = explicit_mode
    result["explicit_approval"] = explicit_approval
    result["explicit_env_profile"] = explicit_env_profile

    # Resolve mode/approval: profile provides defaults, explicit flags override
    # (may be re-resolved in main() if a session preset is applied)
    profile_defaults = PROFILE_DEFAULTS.get(result["profile"], {})
    result["mode"] = explicit_mode or profile_defaults.get("mode") or "full"
    result["approval"] = explicit_approval or profile_defaults.get("approval") or "auto"

    # ── Project auto-inference ────────────────────────────────────────
    # If --project was not explicitly given, try to infer from projects/ dir.
    # If exactly one project directory exists, use it automatically.
    # This ensures Operations Layer, ProjectIntegrator dedup, and
    # CodeExtractor project-awareness are active without manual flag.
    if not result["project"]:
        _projects_dir = os.path.join(os.path.dirname(__file__), "projects")
        if os.path.isdir(_projects_dir):
            _candidates = [
                d for d in os.listdir(_projects_dir)
                if os.path.isdir(os.path.join(_projects_dir, d))
                and not d.startswith(".")
            ]
            if len(_candidates) == 1:
                result["project"] = _candidates[0]
                result["_project_source"] = "auto-inferred (single project in projects/)"
            elif len(_candidates) > 1:
                result["_project_source"] = (
                    f"ambiguous — {len(_candidates)} projects found: "
                    f"{', '.join(sorted(_candidates))}. Use --project to select."
                )
            else:
                result["_project_source"] = "no projects found in projects/"
        else:
            result["_project_source"] = "projects/ directory not found"
    else:
        result["_project_source"] = "explicit (--project flag)"

    return result


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
    gen_dir = os.path.join(os.path.dirname(__file__), "generated_code")
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


async def _run_pipeline(
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
    _active = active_agents or []
    _disabled = disabled_agents or []
    enabled_set = set(_active) if active_agents is not None else None

    manager = TaskManager(enabled_agents=enabled_set)
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

    extractor = CodeExtractor()
    if not project_name:
        print("WARNING: No project context — ProjectIntegrator and CodeExtractor project-awareness inactive.")
    integrator = ProjectIntegrator(os.path.join("projects", project_name) if project_name else "generated_code")
    code_counts = extractor.extract_swift_code(result.messages, project_name=project_name)

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

            fix_code_counts = extractor.extract_swift_code(fix_result_msgs, project_name=project_name)
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
        print(f"Swift files saved  : {code_counts['saved']} new, {code_counts['skipped']} unchanged")
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
    }


def _run_operations_layer(
    project_name: str,
    env_profile: str = "standard",
    run_id: str | None = None,
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

    print()
    print("=" * 60)
    print("  Operations Layer")
    print("=" * 60)

    # --- Pass 1: Integrate + Verify ---
    print("\n[OpsLayer] Pass 1: Output Integrator")
    integrator = OutputIntegrator(
        project_name=project_name,
        log_filter=run_id,
        clean_before_integrate=True,
    )
    integrator.run()

    print("\n[OpsLayer] Pass 1: Completion Verifier")
    verifier = CompletionVerifier(project_name=project_name)
    report = verifier.verify()

    # --- Compile Hygiene Check (FK-011, FK-012, FK-015) ---
    print("\n[OpsLayer] Compile Hygiene Validator")
    hygiene = CompileHygieneValidator(project_name=project_name)
    hygiene_report = hygiene.validate()
    hygiene_status = hygiene_report.status.value

    # --- FK-014 Type Stub Generator ---
    stub_report = None
    fk014_blocking = [i for i in hygiene_report.issues
                      if i.pattern_id == "FK-014" and i.severity.value == "blocking"]
    if fk014_blocking:
        print(f"\n[OpsLayer] Type Stub Generator — {len(fk014_blocking)} FK-014 blocker(s)")
        stub_gen = TypeStubGenerator(project_name=project_name)
        stub_report = stub_gen.generate_from_hygiene(hygiene_report)
        stub_report.print_summary()

        # Re-run hygiene after stubs to update status
        if stub_report.stubs_created > 0:
            print("\n[OpsLayer] Re-running Compile Hygiene after stub generation...")
            hygiene = CompileHygieneValidator(project_name=project_name)
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
            hygiene = CompileHygieneValidator(project_name=project_name)
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
            hygiene = CompileHygieneValidator(project_name=project_name)
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
            )
            integrator_r.run()

            print(f"\n[OpsLayer] Pass {attempt + 1}: Re-verifying after recovery")
            verifier_r = CompletionVerifier(project_name=project_name)
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
        logger.warning(f"Knowledge writeback failed: {wb_err}")

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


async def main():
    run_id = datetime.now().strftime("%Y%m%d_%H%M%S")
    logger, log_path = setup_logger(run_id)

    a = _parse_args()
    json_output = a["json_output"]

    # ── Load workflow recipe (if specified) ──────────────────────────
    recipe_cfg = {}
    workflow_recipe_name = a["workflow_recipe"]
    if workflow_recipe_name:
        wrm = WorkflowRecipeManager()
        recipe_cfg = wrm.get_recipe(workflow_recipe_name) or {}
        if not recipe_cfg:
            available = ", ".join(wrm.list_recipes()) or "(none)"
            if json_output:
                print(json.dumps({"status": "error", "error": f"Unknown workflow recipe '{workflow_recipe_name}'. Available: {available}"}))
            else:
                print(f"[ERROR] Unknown workflow recipe '{workflow_recipe_name}'. Available: {available}")
            return
        # Apply recipe task defaults (CLI explicit values already take priority via a[])
        if not a["pack"] and recipe_cfg.get("task_pack"):
            a["pack"] = recipe_cfg["task_pack"]
        if not a["template"] and recipe_cfg.get("task_template"):
            a["template"] = recipe_cfg["task_template"]
        if not a["queue_run_all"] and recipe_cfg.get("queue_run_all"):
            a["queue_run_all"] = True

    # ── Load session preset (from CLI or recipe) ─────────────────────
    preset_cfg = {}
    session_preset_name = a["session_preset"] or recipe_cfg.get("session_preset")
    if session_preset_name:
        spm = SessionPresetManager()
        preset_cfg = spm.get_preset(session_preset_name) or {}
        if not preset_cfg:
            available = ", ".join(spm.list_presets()) or "(none)"
            if json_output:
                print(json.dumps({"status": "error", "error": f"Unknown session preset '{session_preset_name}'. Available: {available}"}))
            else:
                print(f"[ERROR] Unknown session preset '{session_preset_name}'. Available: {available}")
            return

    # ── Resolve final config: CLI explicit > recipe direct > preset > profile defaults > system defaults
    profile = a["profile"] or preset_cfg.get("profile")
    env_profile_raw = (
        a["explicit_env_profile"]
        or recipe_cfg.get("env_profile")
        or preset_cfg.get("env_profile")
        or "dev"
    )
    profile_defaults = PROFILE_DEFAULTS.get(profile, {})
    run_mode = (
        a["explicit_mode"]
        or recipe_cfg.get("run_mode")
        or preset_cfg.get("run_mode")
        or profile_defaults.get("mode")
        or "full"
    )
    approval_mode = (
        a["explicit_approval"]
        or recipe_cfg.get("approval_mode")
        or preset_cfg.get("approval_mode")
        or profile_defaults.get("approval")
        or "auto"
    )

    # Set LLM environment profile globally before any agent is created
    set_active_profile(env_profile_raw)
    env_profile = get_active_profile_name()
    try:
        _llm_cfg = get_llm_config()
        active_model = _llm_cfg["config_list"][0]["model"]
    except ValueError:
        active_model = "(api key missing)"

    # Resolve agent toggles: preset < recipe < CLI disable < CLI enable
    cli_overrides = {}
    for name in preset_cfg.get("disable_agents", []):
        if name in ALL_AGENTS:
            cli_overrides[name] = False
    for name in recipe_cfg.get("disable_agents", []):
        if name in ALL_AGENTS:
            cli_overrides[name] = False
    for name in a["disable_agents"]:
        cli_overrides[name] = False
    for name in a["enable_agents"]:
        cli_overrides[name] = True
    active_agents, disabled_agents = resolve_agent_toggles(cli_overrides or None)

    # ── List templates (no pipeline run) ─────────────────────────────
    if a["list_templates"]:
        tmgr = TaskTemplateManager()
        names = tmgr.list_templates()
        if names:
            print("Available task templates:")
            for name in names:
                raw = tmgr.get_template(name)
                preview = raw[:80] + "..." if raw and len(raw) > 80 else raw
                print(f"  {name:<14} {preview}")
        else:
            print("No templates found. Add entries to tasks/task_templates.json.")
        return

    # ── List packs (no pipeline run) ─────────────────────────────────
    if a["list_packs"]:
        pmgr = TaskPackManager()
        names = pmgr.list_packs()
        if names:
            print("Available task packs:")
            for name in names:
                pack_cfg = pmgr.get_pack(name)
                desc = pack_cfg.get("description", "") if pack_cfg else ""
                task_count = len(pack_cfg.get("tasks", [])) if pack_cfg else 0
                print(f"  {name:<28} {desc}  ({task_count} tasks)")
        else:
            print("No packs found. Add entries to tasks/task_packs.json.")
        return

    # ── List session presets (no pipeline run) ────────────────────────
    if a["list_session_presets"]:
        spm = SessionPresetManager()
        names = spm.list_presets()
        if names:
            print("Available session presets:")
            for name in names:
                cfg = spm.get_preset(name)
                desc = cfg.get("description", "") if cfg else ""
                mode = cfg.get("run_mode", "?") if cfg else "?"
                approval = cfg.get("approval_mode", "?") if cfg else "?"
                env = cfg.get("env_profile", "?") if cfg else "?"
                disabled = cfg.get("disable_agents", []) if cfg else []
                disabled_str = f"  disabled=[{', '.join(disabled)}]" if disabled else ""
                print(f"  {name:<18} {desc}")
                print(f"    mode={mode}  approval={approval}  env={env}{disabled_str}")
        else:
            print("No session presets found. Add entries to config/session_presets.json.")
        return

    # ── List workflow recipes (no pipeline run) ───────────────────────
    if a["list_workflow_recipes"]:
        wrm = WorkflowRecipeManager()
        names = wrm.list_recipes()
        if names:
            print("Available workflow recipes:")
            for name in names:
                cfg = wrm.get_recipe(name)
                desc = cfg.get("description", "") if cfg else ""
                details = []
                if cfg:
                    if cfg.get("session_preset"):
                        details.append(f"preset={cfg['session_preset']}")
                    if cfg.get("task_pack"):
                        details.append(f"pack={cfg['task_pack']}")
                    if cfg.get("task_template"):
                        details.append(f"template={cfg['task_template']}")
                    if cfg.get("queue_run_all"):
                        details.append("queue_run_all")
                    if cfg.get("run_mode"):
                        details.append(f"mode={cfg['run_mode']}")
                print(f"  {name:<22} {desc}")
                if details:
                    print(f"    [{', '.join(details)}]")
        else:
            print("No workflow recipes found. Add entries to workflows/workflow_recipes.json.")
        return

    # Resolve task from file if provided (highest priority)
    cli_task = a["task"]
    template_used = None
    template_name_value = None

    if a["task_file"]:
        try:
            with open(a["task_file"], encoding="utf-8") as _tf:
                cli_task = _tf.read().strip()
        except OSError as e:
            if json_output:
                print(json.dumps({"status": "error", "error": f"Could not read task file: {e}"}))
            else:
                print(f"[ERROR] Could not read task file: {e}")
            return

    # Validate --name when recipe injects a task source that requires it
    if workflow_recipe_name and not cli_task and not a["queue_run_all"]:
        if (a["pack"] or a["template"]) and not a["name"]:
            print(f"[ERROR] Recipe '{workflow_recipe_name}' requires --name to specify the target name.")
            return

    # Render single template if no higher-priority task is set
    if not cli_task and a["template"] and a["name"]:
        tmgr = TaskTemplateManager()
        rendered = tmgr.render_template(a["template"], a["name"])
        if rendered is None:
            available = ", ".join(tmgr.list_templates()) or "(none)"
            if json_output:
                print(json.dumps({"status": "error", "error": f"Unknown template '{a['template']}'. Available: {available}"}))
            else:
                print(f"[ERROR] Unknown template '{a['template']}'. Available: {available}")
            return
        cli_task = rendered
        template_used = a["template"]
        template_name_value = a["name"]
        print(f"Template        : {template_used}")
        print(f"Name            : {template_name_value}")
        print(f"Rendered task   : {cli_task}")
        print()

    # ── Project resolution logging ────────────────────────────────────
    _proj = a.get("project")
    _proj_src = a.get("_project_source", "unknown")
    if _proj:
        print(f"Project         : {_proj} ({_proj_src})")
    else:
        print(f"Project         : NONE — {_proj_src}")
        print("  WARNING: Operations Layer, ProjectIntegrator dedup, and")
        print("  CodeExtractor project-awareness will be inactive.")
        print("  Use --project <name> to enable full validation pipeline.")

    # ── Queue-only commands (no pipeline run) ────────────────────────
    task_queue = TaskQueue()

    if a["queue_add_task"]:
        task_queue.add_task(a["queue_add_task"])
        print(f"Task added to queue: {a['queue_add_task']}")
        print(f"Queue now has {len(task_queue.queue['pending'])} pending task(s).")
        return

    if a["queue_summary"]:
        print(task_queue.get_queue_summary())
        return

    if a["failed_summary"]:
        print(task_queue.get_failed_summary())
        return

    if a["retry_failed"]:
        task_text = a["retry_failed"]
        if task_queue.retry_failed_task(task_text):
            print(f"Task moved back to pending: {task_text}")
        else:
            print(f"Task not found in failed list: {task_text}")
        return

    if a["retry_all_failed"]:
        count = task_queue.retry_all_failed_tasks()
        if count:
            print(f"{count} failed task(s) moved back to pending.")
        else:
            print("No failed tasks to retry.")
        return

    if a["analytics_summary"]:
        print(AnalyticsTracker().get_summary_text())
        return

    # ── Backlog / queue export-import (no pipeline run) ──────────────
    bio = BacklogIO()

    if a["export_backlog"]:
        bio.export_backlog(a["export_backlog"])
        print(f"Backlog exported to:\n  {a['export_backlog']}")
        return

    if a["import_backlog"]:
        merge = not a["replace_backlog"]
        counts = bio.import_backlog(a["import_backlog"], merge=merge)
        print(f"Backlog imported from:\n  {a['import_backlog']}")
        print(f"Mode:\n  {'merge' if merge else 'replace'}")
        if merge:
            total_added = sum(counts.values())
            print(f"Entries added:\n  planned={counts['planned']}  in_progress={counts['in_progress']}  completed={counts['completed']}  (total {total_added})")
        else:
            print(f"Entries written:\n  planned={counts['planned']}  in_progress={counts['in_progress']}  completed={counts['completed']}")
        return

    if a["export_queue"]:
        bio.export_queue(a["export_queue"])
        print(f"Queue exported to:\n  {a['export_queue']}")
        return

    if a["import_queue"]:
        merge = not a["replace_queue"]
        counts = bio.import_queue(a["import_queue"], merge=merge)
        print(f"Queue imported from:\n  {a['import_queue']}")
        print(f"Mode:\n  {'merge' if merge else 'replace'}")
        if merge:
            total_added = sum(counts.values())
            print(f"Entries added:\n  pending={counts['pending']}  in_progress={counts['in_progress']}  completed={counts['completed']}  failed={counts['failed']}  (total {total_added})")
        else:
            print(f"Entries written:\n  pending={counts['pending']}  in_progress={counts['in_progress']}  completed={counts['completed']}  failed={counts['failed']}")
        return

    # ── Task pack run ────────────────────────────────────────────────
    if not cli_task and a["pack"] and a["name"]:
        pmgr = TaskPackManager()
        tmgr = TaskTemplateManager()

        pack_name = a["pack"]
        pack_name_value = a["name"]

        if pmgr.get_pack(pack_name) is None:
            available = ", ".join(pmgr.list_packs()) or "(none)"
            if json_output:
                print(json.dumps({"status": "error", "error": f"Unknown pack '{pack_name}'. Available: {available}"}))
            else:
                print(f"[ERROR] Unknown pack '{pack_name}'. Available: {available}")
            return

        pack_tasks = pmgr.render_pack_tasks(pack_name, pack_name_value, tmgr)
        if not pack_tasks:
            print(f"[ERROR] Pack '{pack_name}' rendered no tasks. Check task_packs.json and task_templates.json.")
            return

        total = len(pack_tasks)
        print(f"Task pack       : {pack_name}")
        print(f"Name            : {pack_name_value}")
        print(f"Tasks           : {total}")
        print()

        pack_results = []
        failed_count = 0

        for idx, pt in enumerate(pack_tasks):
            task_run_id = datetime.now().strftime("%Y%m%d_%H%M%S")
            print(f"Running task {idx + 1}/{total}:")
            print(pt["task"])
            print()

            try:
                task_result = await _run_pipeline(
                    user_task=pt["task"],
                    task_source=f"task pack ({pack_name}) {idx + 1}/{total}",
                    run_mode=run_mode,
                    approval_mode=approval_mode,
                    run_id=task_run_id,
                    logger=logger,
                    log_path=log_path,
                    profile=profile,
                    env_profile=env_profile,
                    model=active_model,
                    active_agents=active_agents,
                    disabled_agents=disabled_agents,
                    template=pt["template"],
                    template_name_value=pt["rendered_name"],
                    pack=pack_name,
                    pack_task_count=total,
                    session_preset=session_preset_name,
                    workflow_recipe=workflow_recipe_name,
                    no_cd_gate=a["no_cd_gate"],
                    project_name=a.get("project"),
                )
                pack_results.append(task_result)
                GitAutoCommit().run_auto_commit(
                    task=pt["task"],
                    run_manifest_path=task_result.get("run_manifest_path", ""),
                )
            except Exception as e:
                error_msg = str(e)
                print(f"[ERROR] Task {idx + 1}/{total} failed: {error_msg}")
                pack_results.append({"status": "error", "error": error_msg, "task": pt["task"]})
                failed_count += 1

        if json_output:
            print(json.dumps({
                "status": "success" if failed_count == 0 else "partial",
                "pack": pack_name,
                "pack_task_count": total,
                "processed": total - failed_count,
                "failed": failed_count,
                "results": pack_results,
            }, indent=2))
        else:
            print()
            print("=" * 60)
            print(f"Task pack '{pack_name}' completed.")
            print(f"Processed : {total - failed_count}/{total}")
            if failed_count:
                print(f"Failed    : {failed_count}")
            print("=" * 60)
        return

    # ── Batch queue run ──────────────────────────────────────────────
    if a["queue_run_all"]:
        total = len(task_queue.queue["pending"])
        if a["limit"] is not None:
            total = min(total, a["limit"])

        if total == 0:
            print("Task queue is empty. Nothing to run.")
            return

        print(f"Starting batch queue run: {total} task(s) to process.")
        processed = 0
        failed_count = 0

        while processed < total:
            next_task = task_queue.get_next_task()
            if not next_task:
                break

            task_queue.start_task(next_task)
            print()
            print(f"Running queued task {processed + 1}/{total}:")
            print(next_task)
            print()

            task_run_id = datetime.now().strftime("%Y%m%d_%H%M%S")
            try:
                queue_result = await _run_pipeline(
                    user_task=next_task,
                    task_source="task queue (batch)",
                    run_mode=run_mode,
                    approval_mode=approval_mode,
                    run_id=task_run_id,
                    logger=logger,
                    log_path=log_path,
                    profile=profile,
                    env_profile=env_profile,
                    model=active_model,
                    active_agents=active_agents,
                    disabled_agents=disabled_agents,
                    session_preset=session_preset_name,
                    workflow_recipe=workflow_recipe_name,
                    no_cd_gate=a["no_cd_gate"],
                    project_name=a.get("project"),
                )
                task_queue.complete_task(next_task)
                GitAutoCommit().run_auto_commit(
                    task=next_task,
                    run_manifest_path=queue_result.get("run_manifest_path", ""),
                )
            except Exception as e:
                error_msg = str(e)
                print(f"[ERROR] Task failed: {error_msg}")
                print(f"Moving to failed list: {next_task}")
                task_queue.fail_task(next_task, error_message=error_msg)
                failed_count += 1

            processed += 1

        if json_output:
            print(json.dumps({
                "status": "success",
                "batch": True,
                "processed": processed - failed_count,
                "failed": failed_count,
                "remaining": len(task_queue.queue["pending"]),
            }, indent=2))
        else:
            print()
            print("=" * 60)
            print("Batch queue run completed.")
            print(f"Processed : {processed - failed_count}")
            if failed_count:
                print(f"Failed    : {failed_count}  (use --failed-summary to review, --retry-all-failed to retry)")
            print(f"Remaining : {len(task_queue.queue['pending'])} task(s) still in queue")
            print("=" * 60)
        return

    # ── Single run ───────────────────────────────────────────────────
    active_feature = None
    queue_run = a["queue_run"]

    if queue_run:
        next_task = task_queue.get_next_task()
        if not next_task:
            print("Task queue is empty. Nothing to run.")
            return
        task_queue.start_task(next_task)
        cli_task = next_task
        print(f"Running next queued task: {cli_task}")

    if cli_task:
        user_task = cli_task
        if queue_run:
            task_source = "task queue"
        elif template_used:
            task_source = f"template ({template_used})"
        else:
            task_source = "CLI argument"
    else:
        _manager = TaskManager(enabled_agents=set(active_agents))
        active_feature, feature_task = _manager.get_next_feature_task()
        if active_feature:
            user_task = feature_task
            task_source = f"feature backlog ({active_feature})"
        else:
            user_task = _manager.get_sample_task()
            task_source = "sample task (backlog empty)"

    try:
        pipeline_result = await _run_pipeline(
            user_task=user_task,
            task_source=task_source,
            run_mode=run_mode,
            approval_mode=approval_mode,
            run_id=run_id,
            logger=logger,
            log_path=log_path,
            active_feature=active_feature,
            profile=profile,
            env_profile=env_profile,
            model=active_model,
            active_agents=active_agents,
            disabled_agents=disabled_agents,
            template=template_used,
            template_name_value=template_name_value,
            session_preset=session_preset_name,
            workflow_recipe=workflow_recipe_name,
            no_cd_gate=a["no_cd_gate"],
            project_name=a.get("project"),
        )
        if queue_run and cli_task:
            task_queue.complete_task(cli_task)
            print(f"Queued task completed. {len(task_queue.queue['pending'])} task(s) remaining in queue.")
        if json_output:
            print(json.dumps(pipeline_result, indent=2))
        GitAutoCommit().run_auto_commit(
            task=user_task,
            run_manifest_path=pipeline_result.get("run_manifest_path", ""),
        )

        # ── Operations Layer (post-run) ──────────────────────────────
        if not a["no_ops_layer"] and a["project"]:
            try:
                ops_result = _run_operations_layer(
                    project_name=a["project"],
                    env_profile=env_profile,
                    run_id=run_id,
                )
                if json_output:
                    pipeline_result["operations_layer"] = ops_result
            except Exception as ops_err:
                print(f"\n[WARNING] Operations layer failed: {ops_err}")
                logger.warning(f"Operations layer failed: {ops_err}")
                if json_output:
                    pipeline_result["operations_layer"] = {"status": "error", "error": str(ops_err)}

    except Exception as e:
        error_msg = str(e)
        if queue_run and cli_task:
            print(f"[ERROR] Task failed: {error_msg}")
            task_queue.fail_task(cli_task, error_message=error_msg)
            print("Task moved to failed list. Use --retry-failed to requeue it.")
        if json_output:
            print(json.dumps({"status": "error", "error": error_msg}))
        if not queue_run and not json_output:
            raise


if __name__ == "__main__":
    asyncio.run(main())
