# delivery_exporter.py
# Creates a structured delivery package after each full pipeline run.

import os
from datetime import datetime

PROJECT_ROOT = os.path.dirname(os.path.dirname(__file__))
EXPORTS_DIR = os.path.join(os.path.dirname(__file__), "exports")
GENERATED_DIR = os.path.join(PROJECT_ROOT, "generated_code")
XCODE_DIR = os.path.join(PROJECT_ROOT, "DriveAI")


def _collect_swift_files(root: str) -> list[str]:
    found = []
    if not os.path.isdir(root):
        return found
    for subfolder in sorted(os.listdir(root)):
        subfolder_path = os.path.join(root, subfolder)
        if not os.path.isdir(subfolder_path):
            continue
        for filename in sorted(os.listdir(subfolder_path)):
            if filename.endswith(".swift"):
                found.append(f"{subfolder}/{filename}")
    return found


def _first_agent_text(messages: list, source_name: str) -> str:
    for msg in messages:
        if getattr(msg, "source", "") == source_name:
            content = getattr(msg, "content", "")
            if isinstance(content, str) and content.strip():
                return content.strip()[:600]
    return "(no output)"


class DeliveryExporter:
    def export_run_package(
        self,
        run_id: str,
        run_mode: str,
        approval_mode: str,
        user_task: str,
        task_source: str,
        memory_summary: str,
        profile: str | None = None,
        env_profile: str = "dev",
        model: str = "",
        active_agents: list | None = None,
        disabled_agents: list | None = None,
        template: str | None = None,
        template_name_value: str | None = None,
        pack: str | None = None,
        pack_task_count: int | None = None,
        session_preset: str | None = None,
        workflow_recipe: str | None = None,
        skipped_phases: list | None = None,
        *,
        impl_messages: list,
        bug_messages: list,
        refactor_messages: list,
        test_messages: list,
        fix_messages: list,
        code_counts: dict,
        xcode_counts: dict,
    ) -> str:
        """
        Creates delivery/exports/run_<run_id>/ with task.txt, summary.md,
        generated_files.txt, and memory_snapshot.txt.
        Returns the export folder path.
        """
        export_dir = os.path.join(EXPORTS_DIR, f"run_{run_id}")
        os.makedirs(export_dir, exist_ok=True)

        timestamp = datetime.now().isoformat()

        # --- task.txt ---
        with open(os.path.join(export_dir, "task.txt"), "w", encoding="utf-8") as f:
            f.write(f"Task: {user_task}\n")
            f.write(f"Timestamp: {timestamp}\n")
            f.write(f"Source: {task_source}\n")
            f.write(f"Run mode: {run_mode}\n")
            f.write(f"Approval mode: {approval_mode}\n")
            if profile:
                f.write(f"Profile: {profile}\n")
            f.write(f"Env profile: {env_profile}\n")
            if model:
                f.write(f"Model: {model}\n")
            if active_agents:
                f.write(f"Active agents: {', '.join(active_agents)}\n")
            if disabled_agents:
                f.write(f"Disabled agents: {', '.join(disabled_agents)}\n")
            if template:
                f.write(f"Template: {template}\n")
            if template_name_value:
                f.write(f"Template name: {template_name_value}\n")
            if pack:
                f.write(f"Pack: {pack}\n")
            if pack_task_count is not None:
                f.write(f"Pack task count: {pack_task_count}\n")
            if session_preset:
                f.write(f"Session preset: {session_preset}\n")
            if workflow_recipe:
                f.write(f"Workflow recipe: {workflow_recipe}\n")
            if skipped_phases:
                f.write(f"Skipped phases: {', '.join(skipped_phases)}\n")

        # --- summary.md ---
        impl_snippet = _first_agent_text(impl_messages, "swift_developer")
        bug_snippet = _first_agent_text(bug_messages, "bug_hunter")
        refactor_snippet = _first_agent_text(refactor_messages, "refactor_agent")
        test_snippet = _first_agent_text(test_messages, "test_generator")
        fix_snippet = _first_agent_text(fix_messages, "swift_developer") or _first_agent_text(fix_messages, "driveai_lead")

        with open(os.path.join(export_dir, "summary.md"), "w", encoding="utf-8") as f:
            f.write(f"# Delivery Summary — {run_id}\n\n")
            f.write(f"**Task:** {user_task}  \n")
            f.write(f"**Timestamp:** {timestamp}  \n")
            f.write(f"**Source:** {task_source}  \n")
            if profile:
                f.write(f"**Profile:** {profile}  \n")
            f.write(f"**Env profile:** {env_profile}  \n")
            if model:
                f.write(f"**Model:** {model}  \n")
            if active_agents:
                f.write(f"**Active agents:** {', '.join(active_agents)}  \n")
            if disabled_agents:
                f.write(f"**Disabled agents:** {', '.join(disabled_agents)}  \n")
            if template:
                f.write(f"**Template:** {template}  \n")
            if template_name_value:
                f.write(f"**Template name:** {template_name_value}  \n")
            if pack:
                f.write(f"**Pack:** {pack}  \n")
            if pack_task_count is not None:
                f.write(f"**Pack task count:** {pack_task_count}  \n")
            if session_preset:
                f.write(f"**Session preset:** {session_preset}  \n")
            if workflow_recipe:
                f.write(f"**Workflow recipe:** {workflow_recipe}  \n")
            if skipped_phases:
                f.write(f"**Skipped phases:** {', '.join(skipped_phases)}  \n")
            f.write(f"**Run mode:** {run_mode}  \n")
            f.write(f"**Approval mode:** {approval_mode}  \n\n")
            f.write("## Implementation\n\n")
            f.write(impl_snippet + "\n\n")
            f.write("## Bug Review\n\n")
            f.write(bug_snippet + "\n\n")
            f.write("## Refactor\n\n")
            f.write(refactor_snippet + "\n\n")
            f.write("## Test Cases\n\n")
            f.write(test_snippet + "\n\n")
            f.write("## Fix Execution\n\n")
            f.write((fix_snippet or "(no output)") + "\n\n")
            f.write("## File Counts\n\n")
            f.write(f"- Swift files generated : {code_counts['saved']} new, {code_counts['skipped']} unchanged\n")
            if xcode_counts.get("status") == "skipped":
                f.write(f"- Xcode integration     : skipped (approval={approval_mode})\n")
            else:
                f.write(f"- Xcode files integrated: {xcode_counts['integrated']} copied, {xcode_counts.get('unchanged', 0)} unchanged\n")

        # --- generated_files.txt ---
        generated = _collect_swift_files(GENERATED_DIR)
        integrated = _collect_swift_files(XCODE_DIR)

        with open(os.path.join(export_dir, "generated_files.txt"), "w", encoding="utf-8") as f:
            f.write("=== generated_code/ ===\n")
            if generated:
                for p in generated:
                    f.write(f"  {p}\n")
            else:
                f.write("  (none)\n")
            f.write("\n=== DriveAI/ (Xcode project) ===\n")
            if integrated:
                for p in integrated:
                    f.write(f"  {p}\n")
            else:
                f.write("  (none)\n")

        # --- memory_snapshot.txt ---
        with open(os.path.join(export_dir, "memory_snapshot.txt"), "w", encoding="utf-8") as f:
            f.write(memory_summary if memory_summary else "(no memory entries)")

        return export_dir
