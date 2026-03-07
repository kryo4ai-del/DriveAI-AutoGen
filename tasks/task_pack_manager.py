# task_pack_manager.py
# Loads and renders grouped task packs from task_packs.json.

import json
import os

_PACKS_PATH = os.path.join(os.path.dirname(__file__), "task_packs.json")


class TaskPackManager:
    def __init__(self):
        self._packs = self.load_packs()

    def load_packs(self) -> dict:
        """Load task_packs.json. Returns empty dict on failure."""
        try:
            with open(_PACKS_PATH, encoding="utf-8") as f:
                data = json.load(f)
            if not isinstance(data, dict):
                return {}
            return data
        except (FileNotFoundError, json.JSONDecodeError):
            return {}

    def list_packs(self) -> list[str]:
        """Return sorted list of available pack names."""
        return sorted(self._packs.keys())

    def get_pack(self, pack_name: str) -> dict | None:
        """Return the pack config dict, or None if not found."""
        return self._packs.get(pack_name)

    def render_pack_tasks(
        self,
        pack_name: str,
        name: str,
        template_manager,
    ) -> list[dict]:
        """
        Render all tasks in the pack by substituting {name} in each name_pattern,
        then rendering the corresponding template.

        Returns a list of dicts:
          {"task": rendered_task_text, "template": template_name, "rendered_name": rendered_name}

        Entries whose template is missing or unknown are skipped.
        """
        pack = self.get_pack(pack_name)
        if not pack:
            return []

        rendered = []
        for entry in pack.get("tasks", []):
            template_name = entry.get("template", "")
            name_pattern = entry.get("name_pattern", "{name}")
            rendered_name = name_pattern.replace("{name}", name)
            task_text = template_manager.render_template(template_name, rendered_name)
            if task_text:
                rendered.append({
                    "task": task_text,
                    "template": template_name,
                    "rendered_name": rendered_name,
                })

        return rendered
