"""LDO Storage — Persistence layer for Loop Data Objects."""

from __future__ import annotations

import json
from pathlib import Path

from .schema import LoopDataObject


DATA_ROOT = Path("factory/evolution_loop/data")


class LDOStorage:
    """Saves and loads LDO iterations as JSON files.

    Directory layout::

        factory/evolution_loop/data/{project_id}/
            iteration_0.json
            iteration_1.json
            ...
    """

    def __init__(self, project_id: str) -> None:
        self.project_id = project_id
        self.base_dir = DATA_ROOT / project_id
        self.base_dir.mkdir(parents=True, exist_ok=True)

    def save(self, ldo: LoopDataObject) -> str:
        """Save an LDO as iteration_{N}.json. Returns the file path."""
        iteration = ldo.meta.iteration
        filename = f"iteration_{iteration}.json"
        filepath = self.base_dir / filename
        filepath.write_text(
            json.dumps(ldo.to_dict(), indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
        return str(filepath)

    def load(self, iteration: int) -> LoopDataObject:
        """Load a specific iteration. Raises FileNotFoundError if missing."""
        filepath = self.base_dir / f"iteration_{iteration}.json"
        data = json.loads(filepath.read_text(encoding="utf-8"))
        return LoopDataObject.from_dict(data)

    def load_latest(self) -> LoopDataObject | None:
        """Load the latest iteration, or None if no iterations exist."""
        iterations = self.list_iterations()
        if not iterations:
            return None
        return self.load(iterations[-1])

    def list_iterations(self) -> list[int]:
        """Return sorted list of all stored iteration numbers."""
        iterations = []
        for f in self.base_dir.glob("iteration_*.json"):
            try:
                num = int(f.stem.split("_", 1)[1])
                iterations.append(num)
            except (ValueError, IndexError):
                continue
        return sorted(iterations)

    def get_history(self) -> list[LoopDataObject]:
        """Load all LDOs as a list sorted by iteration (for Regression Tracker)."""
        return [self.load(i) for i in self.list_iterations()]
