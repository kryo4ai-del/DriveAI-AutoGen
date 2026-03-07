# sprint_reporter.py
# Generates a readable sprint-style markdown report for each pipeline run.

import os
from datetime import datetime

PROJECT_ROOT = os.path.dirname(os.path.dirname(__file__))
GENERATED_DIR = os.path.join(PROJECT_ROOT, "generated_code")
XCODE_DIR = os.path.join(PROJECT_ROOT, "DriveAI")


def _collect_swift_files(root: str) -> list[str]:
    found = []
    if not os.path.isdir(root):
        return found
    for subfolder in sorted(os.listdir(root)):
        path = os.path.join(root, subfolder)
        if not os.path.isdir(path):
            continue
        for filename in sorted(os.listdir(path)):
            if filename.endswith(".swift"):
                found.append(f"{subfolder}/{filename}")
    return found


def _extract_pass_summary(messages: list, agent_name: str, max_chars: int = 800) -> str:
    for msg in messages:
        if getattr(msg, "source", "") == agent_name:
            content = getattr(msg, "content", "")
            if isinstance(content, str) and content.strip():
                text = content.strip()
                return text[:max_chars] + (" ..." if len(text) > max_chars else "")
    return "_No output from this agent in this pass._"


def _list_agents(messages: list) -> list[str]:
    seen = []
    for msg in messages:
        source = getattr(msg, "source", "")
        if source and source not in ("user", "") and source not in seen:
            seen.append(source)
    return seen


def _suggest_next_task(user_task: str, active_feature: str | None) -> str:
    if active_feature:
        return f"Integrate the {active_feature} into the main app navigation and run the test suite."
    return "Review the generated Swift files, run XCTests, and integrate the next planned feature."


class SprintReporter:
    def generate_report(
        self,
        export_dir: str,
        run_id: str,
        run_mode: str,
        approval_mode: str,
        user_task: str,
        task_source: str,
        active_feature: str | None,
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
        memory_counts: dict,
    ) -> str:
        """
        Writes sprint_report.md into export_dir.
        Returns the path to the created file.
        """
        timestamp = datetime.now().isoformat()
        generated_files = _collect_swift_files(GENERATED_DIR)
        integrated_files = _collect_swift_files(XCODE_DIR)

        impl_agents = _list_agents(impl_messages)
        impl_summary = _extract_pass_summary(impl_messages, "swift_developer")
        bug_summary = _extract_pass_summary(bug_messages, "bug_hunter")
        refactor_summary = _extract_pass_summary(refactor_messages, "refactor_agent")
        test_summary = _extract_pass_summary(test_messages, "test_generator")
        fix_summary = (
            _extract_pass_summary(fix_messages, "swift_developer")
            or _extract_pass_summary(fix_messages, "driveai_lead")
            or "_No output from fix pass._"
        )
        next_step = _suggest_next_task(user_task, active_feature)

        lines = [
            "# DriveAI Sprint Report",
            "",
            "## Run Metadata",
            "",
            f"- **Run ID:** {run_id}",
            f"- **Timestamp:** {timestamp}",
            *([ f"- **Profile:** {profile}"] if profile else []),
            f"- **Env profile:** {env_profile}",
            *([ f"- **Model:** {model}"] if model else []),
            *([ f"- **Active agents:** {', '.join(active_agents)}"] if active_agents else []),
            *([ f"- **Disabled agents:** {', '.join(disabled_agents)}"] if disabled_agents else []),
            *([ f"- **Template:** {template}"] if template else []),
            *([ f"- **Template name:** {template_name_value}"] if template_name_value else []),
            *([ f"- **Pack:** {pack}"] if pack else []),
            *([ f"- **Pack task count:** {pack_task_count}"] if pack_task_count is not None else []),
            *([ f"- **Session preset:** {session_preset}"] if session_preset else []),
            *([ f"- **Workflow recipe:** {workflow_recipe}"] if workflow_recipe else []),
            *([ f"- **Skipped phases:** {', '.join(skipped_phases)}"] if skipped_phases else []),
            f"- **Run mode:** {run_mode}",
            f"- **Approval mode:** {approval_mode}",
            f"- **Task source:** {task_source}",
            f"- **Original task:** {user_task}",
            "",
            "## Implementation Summary",
            "",
            f"**Participating agents:** {', '.join(impl_agents) if impl_agents else 'n/a'}",
            "",
            impl_summary,
            "",
            "## Bug Review Summary",
            "",
            bug_summary,
            "",
            "## Refactor Summary",
            "",
            refactor_summary,
            "",
            "## Test Summary",
            "",
            test_summary,
            "",
            "## Fix Execution Summary",
            "",
            fix_summary,
            "",
            "## Generated Code",
            "",
            f"- Swift files generated: **{code_counts['saved']} new**, {code_counts['skipped']} unchanged",
            "",
        ]
        if generated_files:
            for f in generated_files:
                lines.append(f"  - `{f}`")
        else:
            lines.append("  _(none)_")

        if xcode_counts.get("status") == "skipped":
            xcode_line = f"- Xcode integration: **skipped** (approval={approval_mode})"
        else:
            xcode_line = f"- Swift files integrated into Xcode project: **{xcode_counts['integrated']} copied**, {xcode_counts.get('unchanged', 0)} unchanged"

        lines += [
            "",
            "## Integrated Code",
            "",
            xcode_line,
            "",
        ]
        if integrated_files:
            for f in integrated_files:
                lines.append(f"  - `{f}`")
        else:
            lines.append("  _(none)_")

        lines += [
            "",
            "## Memory Updates",
            "",
            f"- Decisions added       : +{1 + memory_counts['decisions']}",
            f"- Architecture notes    : +{memory_counts['architecture_notes']}",
            f"- Implementation notes  : +{memory_counts['implementation_notes']}",
            f"- Review notes          : +{memory_counts['review_notes']}",
            "",
            "## Recommended Next Step",
            "",
            next_step,
            "",
        ]

        report_path = os.path.join(export_dir, "sprint_report.md")
        with open(report_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))

        return report_path
