# session_preset_manager.py
# Loads and provides access to named session presets from session_presets.json.

import json
import os

_PRESETS_PATH = os.path.join(os.path.dirname(__file__), "session_presets.json")


class SessionPresetManager:
    def __init__(self):
        self._presets = self.load_presets()

    def load_presets(self) -> dict:
        """Load session_presets.json. Returns empty dict on failure."""
        try:
            with open(_PRESETS_PATH, encoding="utf-8") as f:
                data = json.load(f)
            if not isinstance(data, dict):
                return {}
            return data
        except (FileNotFoundError, json.JSONDecodeError):
            return {}

    def list_presets(self) -> list[str]:
        """Return sorted list of available preset names."""
        return sorted(self._presets.keys())

    def get_preset(self, preset_name: str) -> dict | None:
        """Return the preset config dict, or None if not found."""
        return self._presets.get(preset_name)
