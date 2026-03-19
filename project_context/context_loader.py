# context_loader.py
# Loads project context: per-project context first, global roadbook as fallback.

import os

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROADBOOK_PATH = os.path.join(os.path.dirname(__file__), "driveai_roadbook.md")


def load_project_context(project_name: str | None = None) -> str:
    """Load project context. Checks project-specific file first, falls back to global roadbook."""
    # 1. Try project-specific context
    if project_name:
        project_ctx = os.path.join(_ROOT, "projects", project_name, "project_context.md")
        if os.path.isfile(project_ctx):
            try:
                with open(project_ctx, encoding="utf-8") as f:
                    return f.read()
            except Exception:
                pass

    # 2. Fallback to global roadbook
    try:
        with open(ROADBOOK_PATH, encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return (
            "[Project context not available. "
            "Place the DriveAI roadbook at project_context/driveai_roadbook.md]"
        )
