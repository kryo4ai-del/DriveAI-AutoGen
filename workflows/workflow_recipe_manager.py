# workflow_recipe_manager.py
# Loads and provides access to named workflow recipes from workflow_recipes.json.

import json
import os

_RECIPES_PATH = os.path.join(os.path.dirname(__file__), "workflow_recipes.json")


class WorkflowRecipeManager:
    def __init__(self):
        self._recipes = self.load_recipes()

    def load_recipes(self) -> dict:
        """Load workflow_recipes.json. Returns empty dict on failure."""
        try:
            with open(_RECIPES_PATH, encoding="utf-8") as f:
                data = json.load(f)
            if not isinstance(data, dict):
                return {}
            return data
        except (FileNotFoundError, json.JSONDecodeError):
            return {}

    def list_recipes(self) -> list[str]:
        """Return sorted list of available recipe names."""
        return sorted(self._recipes.keys())

    def get_recipe(self, recipe_name: str) -> dict | None:
        """Return the recipe config dict, or None if not found."""
        return self._recipes.get(recipe_name)
