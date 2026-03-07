# task_template_manager.py
# Loads and renders reusable task templates from task_templates.json.

import json
import os

_TEMPLATES_PATH = os.path.join(os.path.dirname(__file__), "task_templates.json")


class TaskTemplateManager:
    def __init__(self):
        self._templates = self.load_templates()

    def load_templates(self) -> dict[str, str]:
        """Load task_templates.json. Returns empty dict on failure."""
        try:
            with open(_TEMPLATES_PATH, encoding="utf-8") as f:
                data = json.load(f)
            if not isinstance(data, dict):
                return {}
            return {k: v for k, v in data.items() if isinstance(k, str) and isinstance(v, str)}
        except (FileNotFoundError, json.JSONDecodeError):
            return {}

    def list_templates(self) -> list[str]:
        """Return sorted list of available template names."""
        return sorted(self._templates.keys())

    def get_template(self, template_name: str) -> str | None:
        """Return the raw template string, or None if not found."""
        return self._templates.get(template_name)

    def render_template(self, template_name: str, name: str) -> str | None:
        """
        Render a template by substituting {name} with the given value.
        Returns None if the template does not exist.
        """
        template = self.get_template(template_name)
        if template is None:
            return None
        return template.replace("{name}", name)
