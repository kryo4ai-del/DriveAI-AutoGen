# main.py
# Entry point for the DriveAI-AutoGen multi-agent system.

import asyncio
import json
import os
import sys
from datetime import datetime
from tasks.task_manager import TaskManager, setup_logger
from tasks.task_template_manager import TaskTemplateManager
from tasks.task_pack_manager import TaskPackManager
from tasks.task_queue import TaskQueue
from analytics.analytics_tracker import AnalyticsTracker
from config.llm_config import set_active_profile, get_llm_config, get_active_profile_name
from config.agent_toggle_config import resolve_agent_toggles, ALL_AGENTS
from planning.backlog_io import BacklogIO
from config.session_preset_manager import SessionPresetManager
from workflows.workflow_recipe_manager import WorkflowRecipeManager
from utils.git_auto_commit import GitAutoCommit
from factory.pipeline.pipeline_runner import run_pipeline as _run_pipeline, run_operations_layer as _run_operations_layer

# Ensure UTF-8 output on Windows
if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

VALID_MODES = ("quick", "standard", "full")
VALID_APPROVALS = ("auto", "ask", "off")
VALID_PROFILES = ("fast", "dev", "standard", "premium", "safe", "agentic")

PROFILE_DEFAULTS = {
    "fast":     {"mode": "quick",    "approval": "off"},
    "dev":      {"mode": "standard", "approval": "auto"},
    "standard": {"mode": "full",     "approval": "auto"},
    "premium":  {"mode": "full",     "approval": "auto"},
    "safe":     {"mode": "standard", "approval": "ask"},
    "agentic":  {"mode": "full",     "approval": "auto"},
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
        "hybrid_pipeline": True,
        "brain_benchmark": False,
        "brain_benchmark_agent": None,
        "brain_chain": None,
        "brain_optimize": False,
        "brain_stats": False,
        "brain_health": False,
        "brain_models": False,
        "brain_models_provider": None,
        "brain_models_tier": None,
        "brain_costs": False,
        "brain_costs_last": 10,
        "brain_summary": False,
        "brain_evolution": False,
        "brain_evolution_force": False,
        "brain_evolution_dry": False,
        "brain_match": None,
        "brain_match_all": False,
        "brain_classify": None,
        "brain_classify_validate": False,
        "legacy_pipeline": False,
        "orchestrate": None,
        "orchestrate_dry": None,
        "orchestrate_layered": None,
        "orchestrate_layered_dry": None,
        "show_plan": None,
        "factory_status": False,
        "factory_summary": False,
        "assemble": None,
        "assemble_dry": None,
        "no_llm_repair": False,
        "repair_model": "claude-haiku-4-5",
        "create_handoff": None,
        # Signing & Packaging
        "sign": None,
        "check_credentials": None,
        "show_version": None,
        "bump_version": None,
        "version_type": "patch",
        "list_artifacts": None,
        "platform": None,
        # Feasibility Check
        "feasibility_check": None,
        "capability_sheet": False,
        "recheck_parked": False,
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
        elif args[i] == "--brain-benchmark":
            result["brain_benchmark"] = True
            i += 1
        elif args[i] == "--brain-chain" and i + 1 < len(args):
            result["brain_chain"] = args[i + 1]
            i += 2
        elif args[i] == "--brain-optimize":
            result["brain_optimize"] = True
            i += 1
        elif args[i] == "--brain-health":
            result["brain_health"] = True
            i += 1
        elif args[i] == "--brain-models":
            result["brain_models"] = True
            i += 1
        elif args[i] == "--brain-costs":
            result["brain_costs"] = True
            i += 1
        elif args[i] == "--brain-summary":
            result["brain_summary"] = True
            i += 1
        elif args[i] == "--provider" and i + 1 < len(args):
            result["brain_models_provider"] = args[i + 1]
            i += 2
        elif args[i] == "--tier" and i + 1 < len(args):
            result["brain_models_tier"] = args[i + 1]
            i += 2
        elif args[i] == "--last" and i + 1 < len(args):
            result["brain_costs_last"] = int(args[i + 1])
            i += 2
        elif args[i] == "--brain-evolution":
            result["brain_evolution"] = True
            i += 1
        elif args[i] == "--brain-evolution-force":
            result["brain_evolution"] = True
            result["brain_evolution_force"] = True
            i += 1
        elif args[i] == "--brain-evolution-dry":
            result["brain_evolution"] = True
            result["brain_evolution_dry"] = True
            i += 1
        elif args[i] == "--brain-match" and i + 1 < len(args):
            result["brain_match"] = args[i + 1]
            i += 2
        elif args[i] == "--brain-match-all":
            result["brain_match_all"] = True
            i += 1
        elif args[i] == "--brain-classify" and i + 1 < len(args):
            result["brain_classify"] = args[i + 1]
            i += 2
        elif args[i] == "--brain-classify-validate":
            result["brain_classify_validate"] = True
            i += 1
        elif args[i] == "--brain-stats":
            result["brain_stats"] = True
            i += 1
        elif args[i] == "--agent" and i + 1 < len(args):
            result["brain_benchmark_agent"] = args[i + 1]
            i += 2
        elif args[i] == "--hybrid-pipeline":
            result["hybrid_pipeline"] = True
            i += 1
        elif args[i] == "--legacy-pipeline":
            result["hybrid_pipeline"] = False
            result["legacy_pipeline"] = True
            i += 1
        elif args[i] == "--project" and i + 1 < len(args):
            result["project"] = args[i + 1]
            i += 2
        elif args[i] == "--orchestrate" and i + 1 < len(args):
            result["orchestrate"] = args[i + 1]
            i += 2
        elif args[i] == "--orchestrate-dry" and i + 1 < len(args):
            result["orchestrate_dry"] = args[i + 1]
            i += 2
        elif args[i] == "--orchestrate-layered" and i + 1 < len(args):
            result["orchestrate_layered"] = args[i + 1]
            i += 2
        elif args[i] == "--orchestrate-layered-dry" and i + 1 < len(args):
            result["orchestrate_layered_dry"] = args[i + 1]
            i += 2
        elif args[i] == "--show-plan" and i + 1 < len(args):
            result["show_plan"] = args[i + 1]
            i += 2
        elif args[i] == "--factory-status":
            result["factory_status"] = True
            i += 1
        elif args[i] == "--factory-summary":
            result["factory_summary"] = True
        elif args[i] == "--assemble" and i + 1 < len(args):
            result["assemble"] = args[i + 1]
            i += 2
        elif args[i] == "--assemble-dry" and i + 1 < len(args):
            result["assemble_dry"] = args[i + 1]
        elif args[i] == "--no-llm-repair":
            result["no_llm_repair"] = True
            i += 1
            continue
        elif args[i] == "--repair-model" and i + 1 < len(args):
            result["repair_model"] = args[i + 1]
            i += 2
            continue
            i += 2
        elif args[i] == "--create-handoff" and i + 1 < len(args):
            result["create_handoff"] = args[i + 1]
            i += 2
            i += 1
        elif args[i] == "--factory-submit":
            result["factory_submit"] = True
            i += 1
        elif args[i] == "--factory-queue":
            result["factory_queue"] = True
            i += 1
        elif args[i] == "--factory-next":
            result["factory_next"] = True
            i += 1
        elif args[i] == "--factory-execute":
            result["factory_execute"] = True
            i += 1
        elif args[i] == "--factory-run" and i + 1 < len(args):
            result["factory_run"] = args[i + 1]
            i += 2
        elif args[i] == "--factory-advance" and i + 1 < len(args):
            result["factory_advance"] = args[i + 1]
            i += 2
        elif args[i] == "--auto-ceo-go":
            result["auto_ceo_go"] = True
            i += 1
        elif args[i] == "--phase" and i + 1 < len(args):
            result["factory_advance_phase"] = args[i + 1]
            i += 2
        elif args[i] == "--sign" and i + 1 < len(args):
            result["sign"] = args[i + 1]
            i += 2
        elif args[i] == "--check-credentials" and i + 1 < len(args):
            result["check_credentials"] = args[i + 1]
            i += 2
        elif args[i] == "--show-version" and i + 1 < len(args):
            result["show_version"] = args[i + 1]
            i += 2
        elif args[i] == "--bump-version" and i + 1 < len(args):
            result["bump_version"] = args[i + 1]
            i += 2
        elif args[i] == "--version-type" and i + 1 < len(args):
            result["version_type"] = args[i + 1].lower()
            i += 2
        elif args[i] == "--list-artifacts" and i + 1 < len(args):
            result["list_artifacts"] = args[i + 1]
            i += 2
        elif args[i] == "--platform" and i + 1 < len(args):
            result["platform"] = args[i + 1]
            i += 2
        elif args[i] == "--feasibility-check" and i + 1 < len(args):
            result["feasibility_check"] = args[i + 1]
            i += 2
        elif args[i] == "--capability-sheet":
            result["capability_sheet"] = True
            i += 1
        elif args[i] == "--recheck-parked":
            result["recheck_parked"] = True
            i += 1
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



async def main():
    run_id = datetime.now().strftime("%Y%m%d_%H%M%S")
    logger, log_path = setup_logger(run_id)

    a = _parse_args()
    json_output = a["json_output"]

    # ── Load workflow recipe (if specified) ──────────────────────────
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

    # If --profile matches an LLM profile name (dev/standard/premium) and no
    # explicit --env-profile was given, use --profile as the env_profile too.
    # This ensures `--profile standard` activates claude-sonnet-4-6 as intended.
    _llm_profile_names = {"dev", "standard", "premium"}
    _profile_as_env = profile if (profile and profile in _llm_profile_names) else None

    env_profile_raw = (
        a["explicit_env_profile"]
        or recipe_cfg.get("env_profile")
        or preset_cfg.get("env_profile")
        or _profile_as_env
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

    # ── Factory status (no pipeline run) ────────────────────────────
    if a["factory_status"]:
        from factory.status import FactoryStatus
        fs = FactoryStatus()
        status_data = fs.scan()
        if json_output:
            print(json.dumps(status_data, indent=2, default=str))
        else:
            print(fs.format_console(status_data))
        return

    if a["factory_summary"]:
        from factory.status import FactoryStatus
        fs = FactoryStatus()
        status_data = fs.scan()
        if json_output:
            print(json.dumps(status_data, indent=2, default=str))
        else:
            print(fs.format_summary(status_data))
        return

    # ── Dispatcher commands ──────────────────────────────────────
    if a.get("factory_queue"):
        from factory.dispatcher import PipelineDispatcher
        print(PipelineDispatcher().get_queue_status())
        return
    if a.get("factory_next"):
        from factory.dispatcher import PipelineDispatcher
        action = PipelineDispatcher().get_next_action()
        if action:
            print(f"Next: {action['description']}")
            print(f"  Auto-executable: {action['auto']}")
        else:
            print("No pending actions.")
        return
    if a.get("factory_execute"):
        from factory.dispatcher import PipelineDispatcher
        PipelineDispatcher().execute_next(auto_ceo_go=a.get("auto_ceo_go", False))
        return
    if a.get("factory_run"):
        from factory.dispatcher import PipelineDispatcher
        PipelineDispatcher().run_full_pipeline(a["factory_run"], auto_ceo_go=a.get("auto_ceo_go", False))
        return
    if a.get("factory_submit") and a.get("task"):
        from factory.dispatcher import PipelineDispatcher
        title = a.get("name", "Untitled")
        PipelineDispatcher().submit_idea(a["task"], title)
        return
    if a.get("factory_advance") and a.get("factory_advance_phase"):
        from factory.dispatcher import PipelineDispatcher
        from factory.dispatcher.product_state import ProductPhase
        d = PipelineDispatcher()
        p = d._get_by_title(a["factory_advance"])
        if p:
            d.advance_phase(p.id, ProductPhase(a["factory_advance_phase"]))
        else:
            print(f"Product not found: {a['factory_advance']}")
        return

    # ── Signing & Packaging commands ──────────────────────────────────
    if a["sign"]:
        from factory.signing.signing_coordinator import SigningCoordinator

        project = a["sign"]
        platform_arg = a["platform"]

        if not platform_arg:
            print("[Signing] ERROR: --platform required (android, web, ios, or comma-separated, or 'all')")
            return

        if platform_arg == "all":
            platforms = ["ios", "android", "web"]
        else:
            platforms = [p.strip() for p in platform_arg.split(",")]

        coordinator = SigningCoordinator(project_name=project, platforms=platforms)
        result = coordinator.run()

        print(f"\n[Signing] Overall: {result['status']}")
        return

    if a["check_credentials"]:
        from factory.signing.credential_checker import CredentialChecker

        project = a["check_credentials"]
        platform_arg = a["platform"]

        if not platform_arg or platform_arg == "all":
            platforms = ["ios", "android", "web"]
        else:
            platforms = [p.strip() for p in platform_arg.split(",")]

        checker = CredentialChecker()
        for plat in platforms:
            status = checker.check(plat, project)
            icon = "READY" if status.ready else "NOT READY"
            print(f"\n[Credentials] {plat}: {icon}")
            if status.found:
                for f_item in status.found:
                    print(f"  + {f_item}")
            if status.missing:
                for m in status.missing:
                    print(f"  - MISSING: {m}")
            if status.instructions:
                print(f"  Instructions: {status.instructions[:200]}")
        return

    if a["show_version"]:
        from factory.signing.version_manager import VersionManager

        project = a["show_version"]
        vm = VersionManager(project)

        print(f"\n[Version] Project: {project}")
        for plat in ["ios", "android", "web"]:
            v = vm.get_current(plat)
            print(f"  {plat:10s} -- {v.full_version}")
        return

    if a["bump_version"]:
        from factory.signing.version_manager import VersionManager

        project = a["bump_version"]
        bump_type = a["version_type"]
        if bump_type not in ("patch", "minor", "major"):
            bump_type = "patch"
        vm = VersionManager(project)

        old = vm.get_current("ios")
        new = vm.bump_version(bump_type)
        print(f"[Version] {project}: {old.marketing_version} -> {new.marketing_version} ({bump_type})")
        return

    if a["list_artifacts"]:
        from factory.signing.artifact_registry import ArtifactRegistry

        project = a["list_artifacts"]
        registry = ArtifactRegistry()

        print(f"\n[Artifacts] Project: {project}")
        for plat in ["ios", "android", "web"]:
            versions = registry.list_versions(project, plat)
            if versions:
                print(f"\n  {plat}:")
                for entry in versions[:10]:
                    size_mb = round(entry.artifact_size_bytes / 1024 / 1024, 1) if entry.artifact_size_bytes else 0
                    print(f"    {entry.version} build {entry.build_number} -- {entry.artifact_type} ({size_mb} MB) -- {entry.timestamp}")
            else:
                print(f"\n  {plat}: No artifacts")

        total = registry.get_total_size(project)
        total_mb = round(total / 1024 / 1024, 1) if total else 0
        print(f"\n  Total size: {total_mb} MB")
        return

    # ── Feasibility Check commands ───────────────────────────────────
    if a.get("capability_sheet"):
        from factory.hq.capabilities.capability_sheet import generate_capability_sheet
        sheet = generate_capability_sheet()
        if json_output:
            print(json.dumps(sheet, indent=2, default=str))
        else:
            print("Factory Capability Sheet")
            print("=" * 50)
            for line_name, info in sheet.get("production_lines", {}).items():
                status = "OK" if info.get("available") else "--"
                print(f"  [{status}] {line_name:10s} {info.get('framework', '')} ({info.get('status', '')})")
            print(f"\n  External Services: {sum(len(v) for v in sheet.get('external_services', {}).values())} registered")
            print(f"  Factory Systems: {sum(1 for v in sheet.get('factory_systems', {}).values() if v)} active")
            print(f"\n  Cannot do:")
            for item in sheet.get("cannot_do", []):
                print(f"    - {item}")
        return

    if a.get("feasibility_check"):
        from factory.hq.capabilities.feasibility_check import FeasibilityChecker
        checker = FeasibilityChecker()
        result = checker.check_project(a["feasibility_check"])
        if json_output:
            print(json.dumps(result, indent=2, default=str))
        else:
            overall = result.get("overall_status", "unknown")
            icon = {"feasible": "OK", "partially_feasible": "PARTIAL", "not_feasible": "BLOCKED"}.get(overall, "?")
            print(f"Feasibility Check: {a['feasibility_check']}")
            print("=" * 50)
            print(f"  Status: [{icon}] {overall} (score={result.get('score', 0)})")
            print(f"  {result.get('summary', '')}")
            gaps = result.get("capability_gaps", [])
            if gaps:
                print(f"\n  Capability Gaps ({len(gaps)}):")
                for g in gaps:
                    print(f"    - {g.get('capability', '?')} [{g.get('severity', '?')}]")
            for rec in result.get("recommendations", []):
                print(f"  {rec}")
            if result.get("report_path"):
                print(f"\n  Report: {result['report_path']}")
        return

    if a.get("recheck_parked"):
        from factory.hq.capabilities.capability_watcher import CapabilityWatcher
        watcher = CapabilityWatcher()
        changes = watcher.check_parked_projects()
        if json_output:
            print(json.dumps(changes, indent=2, default=str))
        else:
            if changes:
                print(f"Re-Check: {len(changes)} Aenderung(en):")
                for c in changes:
                    print(f"  {c['slug']}: {c['old_status']} -> {c['new_status']} (score: {c.get('new_score', '?')})")
            else:
                print("Re-Check: Keine Aenderungen bei geparkten Projekten.")
        return

    # ── Orchestrator commands (no direct pipeline run) ──────────────
    if a["show_plan"]:
        from factory.orchestrator import FactoryOrchestrator
        orch = FactoryOrchestrator(a["show_plan"])
        plan_status = orch.get_status()
        if plan_status["plan_status"] == "no_plan":
            print(f"No build plan found for '{a['show_plan']}'. Run --orchestrate-dry first.")
        else:
            import os as _os
            plan_path = _os.path.join("projects", a["show_plan"], "specs", "build_plan.json")
            from factory.orchestrator.build_plan import BuildPlan
            plan = BuildPlan.load(plan_path)
            print(plan.summary())
        return

    if a["orchestrate_dry"]:
        from factory.orchestrator import FactoryOrchestrator
        orch = FactoryOrchestrator(a["orchestrate_dry"])
        plan = orch.create_build_plan()
        if not plan.steps:
            print(f"No build spec found for '{a['orchestrate_dry']}'. "
                  f"Create projects/{a['orchestrate_dry']}/specs/build_spec.yaml first.")
            return
        orch.execute_plan(plan, dry_run=True, profile=profile or "standard",
                          approval=approval_mode or "auto")
        return

    if a["orchestrate"]:
        from factory.orchestrator import FactoryOrchestrator
        orch = FactoryOrchestrator(a["orchestrate"])
        plan = orch.create_build_plan()
        if not plan.steps:
            print(f"No build spec found for '{a['orchestrate']}'. "
                  f"Create projects/{a['orchestrate']}/specs/build_spec.yaml first.")
            return
        orch.execute_plan(plan, dry_run=False, profile=profile or "standard",
                          approval=approval_mode or "auto")
        return

    if a["orchestrate_layered_dry"]:
        from factory.orchestrator import FactoryOrchestrator
        orch = FactoryOrchestrator(a["orchestrate_layered_dry"])
        plan = orch.create_layered_build_plan()
        if not plan.steps:
            print(f"No build spec found for '{a['orchestrate_layered_dry']}'. "
                  f"Create projects/{a['orchestrate_layered_dry']}/specs/build_spec.yaml first.")
            return
        orch.execute_plan(plan, dry_run=True, profile=profile or "standard",
                          approval=approval_mode or "auto")
        return

    if a["orchestrate_layered"]:
        from factory.orchestrator import FactoryOrchestrator
        orch = FactoryOrchestrator(a["orchestrate_layered"])
        plan = orch.create_layered_build_plan()
        if not plan.steps:
            print(f"No build spec found for '{a['orchestrate_layered']}'. "
                  f"Create projects/{a['orchestrate_layered']}/specs/build_spec.yaml first.")
            return
        orch.execute_plan(plan, dry_run=False, profile=profile or "standard",
                          approval=approval_mode or "auto")
        return

    # ── Assembly commands ───────────────────────────────────────
    if a["create_handoff"]:
        from factory.assembly import AssemblyManager
        mgr = AssemblyManager()
        handoff = mgr.create_handoff(a["create_handoff"])
        print(handoff.summary())
        handoff_path = os.path.join("projects", a["create_handoff"], "specs", "production_handoff.json")
        handoff.save(handoff_path)
        print(f"  Handoff saved to: {handoff_path}")
        return

    if a["assemble_dry"]:
        from factory.assembly import AssemblyManager
        mgr = AssemblyManager()
        handoff = mgr.create_handoff(a["assemble_dry"])
        mgr.start_assembly(handoff, dry_run=True)
        return

    if a["assemble"]:
        from factory.assembly import AssemblyManager
        mgr = AssemblyManager()
        handoff = mgr.create_handoff(a["assemble"])
        if not handoff.is_ready_for_assembly():
            print(handoff.summary())
            print("  Assembly blocked: production output not ready.")
            return
        report = mgr.start_assembly(handoff, dry_run=False)
        print(report.summary())
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

    # ── Log project config (informational only) ──────────────────────
    if _proj:
        try:
            from factory.project_config import load_project_config
            _pcfg = load_project_config(_proj)
            _active_lines = _pcfg.get_active_lines()
            _lines_display = ", ".join(
                f"{name} ({line.status})" for name, line in _pcfg.lines.items()
            )
            print(f"Project config  : {_pcfg.name} v{_pcfg.version} [{_pcfg.metadata.status}]")
            print(f"Project lines   : {_lines_display}")
        except Exception as _pcfg_err:
            print(f"Project config  : failed to load ({_pcfg_err})")

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
            hybrid_pipeline=a.get("hybrid_pipeline", True),
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
            hybrid_pipeline=a.get("hybrid_pipeline", True),
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


    # ── TheBrain commands ─────────────────────────────────────────────

    if a.get("brain_health"):
        from factory.brain.model_provider.price_monitor import PriceMonitor
        monitor = PriceMonitor()
        report = monitor.check_all_providers()
        print(report.format_console())
        return

    if a.get("brain_models"):
        from factory.brain.model_provider import get_registry
        reg = get_registry()
        provider_filter = a.get("brain_models_provider")
        tier_filter = a.get("brain_models_tier")
        models = reg._models
        if provider_filter:
            models = [m for m in models if m.provider == provider_filter]
        if tier_filter:
            models = [m for m in models if m.tier_equivalent == tier_filter]
        print(f"\n{'Provider':<12} {'Model':<28} {'Tier':<6} {'In $/1k':>9} {'Out $/1k':>10} {'Max Out':>8} {'Status':<8}")
        print("-" * 85)
        for m in sorted(models, key=lambda x: x.price_per_1k_output):
            print(f"{m.provider:<12} {m.model_id:<28} {m.tier_equivalent:<6} "
                  f"${m.price_per_1k_input:<8.4f} ${m.price_per_1k_output:<9.4f} "
                  f"{m.max_output_tokens:>7} {m.status:<8}")
        print(f"\nTotal: {len(models)} models")
        return

    if a.get("brain_costs"):
        from factory.brain.model_provider.chain_tracker import ChainTracker
        tracker = ChainTracker()
        project = a.get("project") or "askfin_android"
        last_n = a.get("brain_costs_last", 10)
        runs = tracker.get_runs(project, limit=last_n)
        if not runs:
            print(f"No runs recorded for {project}")
        else:
            print(f"\nLast {len(runs)} runs for {project}:")
            print(f"{'Run ID':<20} {'Profile':<10} {'Cost':>10} {'Errors':>8} {'Status':<10}")
            print("-" * 60)
            for r in runs:
                print(f"{r.get('run_id','?')[:18]:<20} {r.get('profile','?'):<10} "
                      f"${r.get('total_cost',0):>9.4f} {r.get('final_errors',0):>7} "
                      f"{r.get('outcome','?'):<10}")
            costs = [r.get('total_cost', 0) for r in runs]
            print(f"\nAvg cost: ${sum(costs)/len(costs):.4f}  Total: ${sum(costs):.4f}")
        return

    if a.get("brain_summary"):
        from factory.brain.model_provider import get_registry
        from factory.brain.model_provider.chain_optimizer import ChainProfile
        reg = get_registry()
        stats = reg.stats
        chains = []
        for line in ["android", "ios", "web"]:
            for profile in ["dev", "standard"]:
                cp = ChainProfile.load_for(line, profile)
                if cp:
                    chains.append(f"{line}/{profile} (${cp.expected_cost:.3f})")
        print(f"TheBrain: {stats['total_models']} models, {len(stats['available_providers'])} providers")
        print(f"Available: {', '.join(stats['available_providers'])}")
        print(f"Chains: {', '.join(chains) if chains else 'none'}")
        return

    if a.get("brain_benchmark"):
        from factory.brain.model_provider.benchmark_runner import BenchmarkRunner
        runner = BenchmarkRunner(a.get("project", ""))
        agent = a.get("brain_benchmark_agent")
        line = a.get("project", "android")
        if agent:
            pass_map = {"bug_hunter": "bug_review", "creative_director": "creative_review",
                        "ux_psychology": "ux_psychology", "refactor_agent": "refactor",
                        "test_generator": "test_generation"}
            pass_name = pass_map.get(agent, "bug_review")
            print(f"\nBenchmarking {agent} ({pass_name})...")
            report = runner.benchmark_agent(agent, pass_name)
            print()
            print(report.summary())
        else:
            for agent, pass_name in [("bug_hunter", "bug_review"), ("creative_director", "creative_review"),
                                      ("refactor_agent", "refactor"), ("test_generator", "test_generation")]:
                print(f"\nBenchmarking {agent} ({pass_name})...")
                report = runner.benchmark_agent(agent, pass_name)
                print()
                print(report.summary())
        return

    if a.get("brain_chain"):
        from factory.brain.model_provider.chain_optimizer import ChainProfile
        line = a["brain_chain"]
        profile = a.get("profile") or "dev"
        cp = ChainProfile.load_for(line, profile)
        if cp:
            print(cp.summary())
        else:
            print(f"No chain profile for {line}/{profile}. Run --brain-optimize first.")
        return

    if a.get("brain_optimize"):
        from factory.brain.model_provider.chain_optimizer import ChainOptimizer
        line = a.get("project") or "android"
        profile = a.get("profile") or "dev"
        print(f"\nOptimizing chain for {line} ({profile})...")
        optimizer = ChainOptimizer()
        cp = optimizer.optimize(line, profile)
        print()
        print(cp.summary())
        return

    if a.get("brain_stats"):
        from factory.brain.model_provider import get_registry
        from factory.brain.model_provider.chain_tracker import ChainTracker
        reg = get_registry()
        tracker = ChainTracker()
        print("\n=== TheBrain Stats ===")
        print(f"Models: {reg.stats}")
        print(f"Available: {reg.get_available_providers()}")
        return

    if a.get("brain_match"):
        from config.model_router import get_model_for_agent, _load_registry
        from factory.brain.model_provider.capability_matcher import CapabilityMatcher
        agent_id = a["brain_match"]
        registry = _load_registry()
        agent_data = None
        for ag in registry.get("agents", []):
            if ag.get("id") == agent_id:
                agent_data = ag
                break
        if not agent_data:
            print(f"Agent '{agent_id}' not found in registry.")
            return
        matcher = CapabilityMatcher()
        print(matcher.explain_match(agent_id, agent_data))
        final = get_model_for_agent(agent_id)
        print(f"Final model: {final}")
        return

    if a.get("brain_match_all"):
        from config.model_router import _load_registry
        from factory.brain.model_provider.capability_matcher import CapabilityMatcher
        registry = _load_registry()
        matcher = CapabilityMatcher()
        results = matcher.match_all_agents(registry)
        print(f"\n{'ID':<8} {'Name':<28} {'Tier':<12} {'Capabilities':<42} {'Model':<24} {'Score':>5}  Reason")
        print("-" * 135)
        for r in results:
            caps_str = ", ".join(r["capabilities_required"]) if r["capabilities_required"] else "(none)"
            if len(caps_str) > 40:
                caps_str = caps_str[:37] + "..."
            model = r["model"] or "-"
            score = f"{r['score']:.2f}" if r["score"] is not None else "  -"
            print(f"{r['agent_id']:<8} {r['name']:<28} {r['tier']:<12} {caps_str:<42} {model:<24} {score:>5}  {r['reason']}")
        # Summary
        total = len(results)
        matched = sum(1 for r in results if r["model"] is not None)
        no_llm = sum(1 for r in results if r["tier"] == "none")
        fallback = sum(1 for r in results if r["reason"] == "tier_fallback")
        print(f"\nTotal: {total} | Capability-matched: {matched - fallback - no_llm} | Tier-fallback: {fallback} | No-LLM: {no_llm}")
        return

    if a.get("brain_classify"):
        from config.model_router import _load_registry
        from factory.brain.model_provider.agent_classifier import AgentClassifier
        agent_id = a["brain_classify"]
        registry = _load_registry()
        agent_data = None
        for ag in registry.get("agents", []):
            if ag.get("id") == agent_id:
                agent_data = ag
                break
        if not agent_data:
            print(f"Agent '{agent_id}' not found in registry.")
            return
        classifier = AgentClassifier()
        result = classifier.classify_deterministic(agent_data)
        print(f"Agent: {agent_id} ({agent_data.get('name', '?')})")
        print(f"Auto-Classification:")
        print(f"  Tier: {result.tier} (confidence: {result.confidence})")
        print(f"  Capabilities: {result.capabilities_required}")
        print(f"  Reasoning: {result.reasoning}")
        print(f"  Source: {result.source}")
        actual_tier = agent_data.get("tier")
        actual_caps = agent_data.get("capabilities_required", [])
        if actual_tier:
            tier_ok = result.tier == actual_tier
            caps_ok = sorted(result.capabilities_required) == sorted(actual_caps)
            print(f"Actual:")
            print(f"  Tier: {actual_tier}")
            print(f"  Capabilities: {actual_caps}")
            print(f"  Match: {'YES' if (tier_ok and caps_ok) else 'NO'}")
            if not tier_ok:
                print(f"    Tier mismatch: auto={result.tier}, actual={actual_tier}")
            if not caps_ok:
                print(f"    Caps mismatch: auto={sorted(result.capabilities_required)}, actual={sorted(actual_caps)}")
        return

    if a.get("brain_classify_validate"):
        from config.model_router import _load_registry
        from factory.brain.model_provider.agent_classifier import AgentClassifier
        registry = _load_registry()
        agents = registry.get("agents", [])
        classifier = AgentClassifier()
        report = classifier.validate_against_existing(agents)
        total = report["total"]
        print(f"\n=== Auto-Classification Validation ({total} agents) ===\n")
        print(f"Tier accuracy:   {report['tier_match']}/{total} ({report['tier_pct']:.1f}%)")
        print(f"Caps accuracy:   {report['caps_match']}/{total} ({report['caps_pct']:.1f}%)")
        print(f"Full match:      {report['full_match']}/{total} ({report['full_pct']:.1f}%)")
        if report["mismatches"]:
            print(f"\nMismatches:")
            for m in report["mismatches"]:
                parts = [f"  {m['agent_id']}"]
                if "tier" in m:
                    parts.append(f"tier: {m['tier']}")
                if "caps" in m:
                    parts.append(f"caps: {m['caps']}")
                print(" | ".join(parts))
        target_met = report["full_pct"] >= 80
        print(f"\nSummary: {report['full_pct']:.1f}% full match (target: >80%) {'OK' if target_met else 'MISSED'}")
        return

    if a.get("brain_evolution"):
        from factory.brain.model_provider.model_evolution import ModelEvolution
        evo = ModelEvolution()
        if a.get("brain_evolution_dry"):
            status = evo.get_status()
            print(json.dumps(status, indent=2, ensure_ascii=False, default=str))
        else:
            force = a.get("brain_evolution_force", False)
            print(f"\nRunning Model Evolution Cycle" + (" (forced)" if force else "") + "...")
            report = evo.run_cycle(force=force)
            print(report.summary())
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
            hybrid_pipeline=a.get("hybrid_pipeline", True),
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
                # Determine language for operations layer
                _ops_language = "swift"
                try:
                    from factory.project_config import load_project_config as _lpc
                    _ops_cfg = _lpc(a["project"])
                    _ops_language = _ops_cfg.get_extraction_language()
                except Exception:
                    pass
                ops_result = _run_operations_layer(
                    project_name=a["project"],
                    env_profile=env_profile,
                    run_id=run_id,
                    language=_ops_language,
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
