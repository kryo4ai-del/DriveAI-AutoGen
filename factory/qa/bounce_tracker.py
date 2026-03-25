"""QA Bounce Tracker — persists bounce counts per project+platform.

Tracks how many times a product has been bounced back from QA to Assembly
for repairs. When the bounce limit is reached, the product is escalated
to the CEO instead of being sent back again.

Storage: factory/qa/bounce_state.json
Key format: "{project}_{platform}" (e.g. "brainpuzzle_ios")
"""

import json
from pathlib import Path


_STATE_FILE = Path(__file__).resolve().parent / "bounce_state.json"


class BounceTracker:
    """Track bounce counts for a specific project+platform combination."""

    def __init__(self, project: str, platform: str) -> None:
        self._project = project
        self._platform = platform
        self._key = f"{project}_{platform}"

    def get_count(self) -> int:
        """Return current bounce count. Returns 0 if no record exists."""
        state = self._load()
        return state.get(self._key, 0)

    def increment(self) -> int:
        """Increment bounce count by 1. Returns the new count."""
        state = self._load()
        state[self._key] = state.get(self._key, 0) + 1
        self._save(state)
        return state[self._key]

    def reset(self) -> None:
        """Reset bounce count to 0."""
        state = self._load()
        state.pop(self._key, None)
        self._save(state)

    def is_limit_reached(self, max_bounces: int) -> bool:
        """Check if the bounce limit has been reached."""
        return self.get_count() >= max_bounces

    def _load(self) -> dict:
        """Load state from JSON file. Returns empty dict on any error."""
        try:
            return json.loads(_STATE_FILE.read_text(encoding="utf-8"))
        except (FileNotFoundError, json.JSONDecodeError):
            return {}

    def _save(self, state: dict) -> None:
        """Save state to JSON file. Creates parent dirs if needed."""
        _STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
        _STATE_FILE.write_text(json.dumps(state, indent=2), encoding="utf-8")
