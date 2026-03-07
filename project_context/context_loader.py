# context_loader.py
# Loads the DriveAI project roadbook and provides it as shared context for agents.

import os

ROADBOOK_PATH = os.path.join(os.path.dirname(__file__), "driveai_roadbook.md")


def load_project_context() -> str:
    try:
        with open(ROADBOOK_PATH, encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return (
            "[Project context not available. "
            "Place the DriveAI roadbook at project_context/driveai_roadbook.md]"
        )
