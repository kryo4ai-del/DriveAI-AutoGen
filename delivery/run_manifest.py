# run_manifest.py
# Creates a machine-readable JSON manifest for each pipeline run.

import json
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


class RunManifest:
    def create_manifest(
        self,
        export_dir: str,
        run_id: str,
        run_mode: str,
        approval_mode: str,
        user_task: str,
        task_source: str,
        project_context_loaded: bool,
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
        memory_used: bool,
        impl_messages: list,
        bug_messages: list,
        refactor_messages: list,
        test_messages: list,
        fix_messages: list,
        xcode_counts: dict,
        export_path: str,
        report_path: str,
        status: str = "success",
    ) -> str:
        """
        Writes run_manifest.json into export_dir.
        Returns the path to the created file.
        """
        impl_count = len(impl_messages)
        bug_count = len(bug_messages)
        refactor_count = len(refactor_messages)
        test_count = len(test_messages)
        fix_count = len(fix_messages)

        passes_run = run_mode in ("standard", "full")
        fix_run = run_mode == "full"
        _skipped = set(skipped_phases or [])

        xcode_integrated = xcode_counts.get("status") != "skipped"

        manifest = {
            "run_id": run_id,
            "timestamp": datetime.now().isoformat(),
            "task": user_task,
            "task_source": task_source,
            "profile": profile,
            "env_profile": env_profile,
            "model": model,
            "active_agents": active_agents or [],
            "disabled_agents": disabled_agents or [],
            "template": template,
            "template_name_value": template_name_value,
            "pack": pack,
            "pack_task_count": pack_task_count,
            "session_preset": session_preset,
            "workflow_recipe": workflow_recipe,
            "run_mode": run_mode,
            "approval_mode": approval_mode,
            "project_context_loaded": project_context_loaded,
            "memory_used": memory_used,
            "skipped_phases": sorted(_skipped),
            "passes": {
                "implementation": True,
                "bug_review": passes_run and "bug_review" not in _skipped,
                "refactor": passes_run and "refactor" not in _skipped,
                "test_generation": passes_run and "test_generation" not in _skipped,
                "fix_execution": fix_run and "fix_execution" not in _skipped,
            },
            "message_counts": {
                "implementation": impl_count,
                "bug_review": bug_count,
                "refactor": refactor_count,
                "test_generation": test_count,
                "fix_execution": fix_count,
                "total": impl_count + bug_count + refactor_count + test_count + fix_count,
            },
            "generated_files": _collect_swift_files(GENERATED_DIR),
            "integrated_files": _collect_swift_files(XCODE_DIR) if xcode_integrated else [],
            "xcode_integration": {
                "status": xcode_counts.get("status", "integrated"),
                "files_copied": xcode_counts.get("integrated", 0),
                "files_unchanged": xcode_counts.get("unchanged", 0),
            },
            "delivery_export_path": export_path,
            "sprint_report_path": report_path,
            "status": status,
        }

        manifest_path = os.path.join(export_dir, "run_manifest.json")
        with open(manifest_path, "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=2, ensure_ascii=False)

        return manifest_path
