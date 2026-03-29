"""Base Plugin -- Abstract base class for all Evaluation Plugins.

All plugins must inherit from EvaluationPlugin and implement evaluate().
"""

from __future__ import annotations

from abc import ABC, abstractmethod

from factory.evolution_loop.ldo.schema import LoopDataObject


class EvaluationPlugin(ABC):
    """Base class for all Evaluation Plugins."""

    name: str = "base_plugin"

    @abstractmethod
    def evaluate(self, ldo: LoopDataObject) -> dict:
        """Evaluate the LDO from a plugin-specific perspective.

        Returns:
            {
                "score": ScoreEntry(value=..., confidence=...),
                "issues": list[str]
            }
        """
        ...
