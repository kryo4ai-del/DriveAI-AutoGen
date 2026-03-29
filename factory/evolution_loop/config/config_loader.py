"""Evolution Loop Config Loader — loads and merges YAML configuration."""

from __future__ import annotations

from pathlib import Path

import yaml


_CONFIG_DIR = Path(__file__).parent
_DEFAULT_CONFIG = _CONFIG_DIR / "default_config.yaml"
_SCORE_WEIGHTS = _CONFIG_DIR / "score_weights.yaml"
_FALLBACK_PROJECT_TYPE = "utility"


def _deep_merge(base: dict, override: dict) -> dict:
    """Recursively merge *override* into *base* (returns new dict)."""
    merged = dict(base)
    for key, val in override.items():
        if key in merged and isinstance(merged[key], dict) and isinstance(val, dict):
            merged[key] = _deep_merge(merged[key], val)
        else:
            merged[key] = val
    return merged


class EvolutionConfig:
    """Loads and manages Evolution Loop configuration.

    Parameters
    ----------
    project_config_path : str | None
        Optional path to a project-specific YAML that overrides defaults.
        Missing keys in the project config keep their default values.
    """

    def __init__(self, project_config_path: str | None = None) -> None:
        # -- Load defaults --------------------------------------------------
        self._config = yaml.safe_load(_DEFAULT_CONFIG.read_text(encoding="utf-8"))
        self._weights = yaml.safe_load(_SCORE_WEIGHTS.read_text(encoding="utf-8"))

        # -- Merge project overrides ----------------------------------------
        if project_config_path:
            path = Path(project_config_path)
            if path.exists():
                override = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
                self._config = _deep_merge(self._config, override)
                # Project config may also override score_weights
                if "score_weights" in override:
                    self._weights = _deep_merge(self._weights, override["score_weights"])

    # -- Public API ---------------------------------------------------------

    def get_loop_limits(self) -> dict:
        """Return loop limits from the ``evolution_loop`` section."""
        return dict(self._config.get("evolution_loop", {}))

    def get_quality_targets(self) -> dict:
        """Return quality target thresholds."""
        return dict(self._config.get("quality_targets", {}))

    def get_score_weights(self, project_type: str) -> dict:
        """Return score weights for *project_type*.

        Falls back to ``utility`` if the type is unknown.
        """
        if project_type in self._weights:
            return dict(self._weights[project_type])
        return dict(self._weights.get(_FALLBACK_PROJECT_TYPE, {}))

    def get_confidence_thresholds(self) -> dict:
        """Return confidence thresholds."""
        return dict(self._config.get("confidence", {}))
