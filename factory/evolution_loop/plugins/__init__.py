"""Evolution Loop -- Plugin System."""

from .base_plugin import EvaluationPlugin
from .plugin_loader import PluginLoader

__all__ = [
    "EvaluationPlugin",
    "PluginLoader",
]
