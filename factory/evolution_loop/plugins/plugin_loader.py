"""Plugin Loader -- Dynamically loads Evaluation Plugins by project type.

Scans plugin directories, imports modules, and instantiates EvaluationPlugin subclasses.
"""

from __future__ import annotations

import importlib
import inspect
from pathlib import Path

from factory.evolution_loop.plugins.base_plugin import EvaluationPlugin

_PREFIX = "[EVO-PLUGIN]"

# Map project_type to plugin directory name when they differ
_TYPE_TO_DIR = {
    "business_app": "business",
}


class PluginLoader:
    """Loads Evaluation Plugins based on project type."""

    def __init__(self) -> None:
        self._plugins_root = Path(__file__).parent

    def load_plugins(self, project_type: str) -> list[EvaluationPlugin]:
        """Load all plugins for a project type.

        1. Determine plugin directory
        2. Scan for .py files (not __init__.py)
        3. Import each module dynamically
        4. Find classes inheriting EvaluationPlugin
        5. Instantiate and return

        Returns empty list if directory does not exist.
        """
        dir_name = _TYPE_TO_DIR.get(project_type, project_type)
        plugin_dir = self._plugins_root / dir_name

        if not plugin_dir.is_dir():
            return []

        plugins: list[EvaluationPlugin] = []

        for py_file in sorted(plugin_dir.glob("*.py")):
            if py_file.name.startswith("__"):
                continue

            module_name = (
                f"factory.evolution_loop.plugins.{dir_name}.{py_file.stem}"
            )

            try:
                module = importlib.import_module(module_name)
            except Exception as e:
                print(f"{_PREFIX} WARNING: Failed to import {module_name}: {e}")
                continue

            for _, cls in inspect.getmembers(module, inspect.isclass):
                if (
                    issubclass(cls, EvaluationPlugin)
                    and cls is not EvaluationPlugin
                ):
                    try:
                        plugins.append(cls())
                    except Exception as e:
                        print(f"{_PREFIX} WARNING: Failed to instantiate {cls.__name__}: {e}")

        names = [p.name for p in plugins]
        if plugins:
            print(f"{_PREFIX} Loaded {len(plugins)} plugins for type '{project_type}': {names}")

        return plugins

    def list_available_types(self) -> list[str]:
        """List all available plugin types (existing directories with .py files)."""
        types: list[str] = []
        for d in sorted(self._plugins_root.iterdir()):
            if not d.is_dir() or d.name.startswith("__"):
                continue
            py_files = [f for f in d.glob("*.py") if not f.name.startswith("__")]
            if py_files:
                types.append(d.name)
        return types
