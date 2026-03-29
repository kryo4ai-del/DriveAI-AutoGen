"""Review Provider -- Abstract interface for CEO Review providers.

Austauschbar: HumanReviewProvider (file-based) -> AIReviewProvider (LLM).
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field

from factory.evolution_loop.ldo.schema import CEOIssue


@dataclass
class ReviewResult:
    """Ergebnis eines CEO Reviews."""

    status: str = "pending"  # "go", "no_go", "pending"
    issues: list[CEOIssue] = field(default_factory=list)


class ReviewProvider(ABC):
    """Abstract interface for review providers.  Swap Human -> AI later."""

    @abstractmethod
    def review(self, ldo) -> ReviewResult:
        """Execute review and return result."""
        ...

    @abstractmethod
    def generate_review_brief(self, ldo) -> str:
        """Generate a Markdown review brief for the CEO."""
        ...
