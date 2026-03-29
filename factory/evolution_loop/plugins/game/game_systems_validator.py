"""Game Systems Validator -- Checks for essential game system patterns.

Scans build artifacts for 5 core game systems (20 points each):
  1. Game Loop (update, tick, frame, delta)
  2. State Management (state machine, FSM, game state)
  3. Save/Load (save, load, serialize, persist)
  4. Level/Scene (level, scene, stage, world)
  5. Input Handling (input, controller, keypress, touch)
"""

from __future__ import annotations

import os
import re

from factory.evolution_loop.ldo.schema import LoopDataObject, ScoreEntry
from factory.evolution_loop.plugins.base_plugin import EvaluationPlugin

_PREFIX = "[PLUGIN-GAME-SYS]"


# Each system: (name, weight, patterns)
_GAME_SYSTEMS: list[tuple[str, int, list[re.Pattern]]] = [
    (
        "Game Loop",
        20,
        [
            re.compile(r"\bupdate\b", re.IGNORECASE),
            re.compile(r"\btick\b", re.IGNORECASE),
            re.compile(r"\bframe\b", re.IGNORECASE),
            re.compile(r"\bdelta\s*time\b", re.IGNORECASE),
            re.compile(r"\bfixed\s*update\b", re.IGNORECASE),
            re.compile(r"\bgame\s*loop\b", re.IGNORECASE),
        ],
    ),
    (
        "State Management",
        20,
        [
            re.compile(r"\bstate\s*machine\b", re.IGNORECASE),
            re.compile(r"\bfsm\b", re.IGNORECASE),
            re.compile(r"\bgame\s*state\b", re.IGNORECASE),
            re.compile(r"\bstate\s*manager\b", re.IGNORECASE),
            re.compile(r"\benum\s+.*state\b", re.IGNORECASE),
        ],
    ),
    (
        "Save/Load",
        20,
        [
            re.compile(r"\bsave\s*(game|data|state)\b", re.IGNORECASE),
            re.compile(r"\bload\s*(game|data|state)\b", re.IGNORECASE),
            re.compile(r"\bserialize\b", re.IGNORECASE),
            re.compile(r"\bpersist\b", re.IGNORECASE),
            re.compile(r"\bplayerprefs\b", re.IGNORECASE),
        ],
    ),
    (
        "Level/Scene",
        20,
        [
            re.compile(r"\blevel\b", re.IGNORECASE),
            re.compile(r"\bscene\b", re.IGNORECASE),
            re.compile(r"\bstage\b", re.IGNORECASE),
            re.compile(r"\bworld\b", re.IGNORECASE),
            re.compile(r"\bload\s*scene\b", re.IGNORECASE),
        ],
    ),
    (
        "Input Handling",
        20,
        [
            re.compile(r"\binput\b", re.IGNORECASE),
            re.compile(r"\bcontroller\b", re.IGNORECASE),
            re.compile(r"\bkey\s*(press|down|up)\b", re.IGNORECASE),
            re.compile(r"\btouch\b", re.IGNORECASE),
            re.compile(r"\bmouse\b", re.IGNORECASE),
            re.compile(r"\bgamepad\b", re.IGNORECASE),
        ],
    ),
]


class GameSystemsValidator(EvaluationPlugin):
    """Validates presence of essential game systems in build artifacts."""

    name = "game_systems_validator"

    def evaluate(self, ldo: LoopDataObject) -> dict:
        paths = ldo.build_artifacts.paths or []
        existing = [p for p in paths if os.path.isfile(p)]

        if not existing:
            print(f"{_PREFIX} No build files -- returning default score")
            return {
                "score": ScoreEntry(value=50, confidence=10),
                "issues": ["No build artifacts to analyze"],
            }

        # Read all text file contents into one blob
        all_content = ""
        for p in existing[:500]:
            try:
                with open(p, "r", encoding="utf-8") as f:
                    all_content += f.read() + "\n"
            except (UnicodeDecodeError, OSError):
                try:
                    with open(p, "r", encoding="latin-1") as f:
                        all_content += f.read() + "\n"
                except (OSError, IOError):
                    pass

        score = 0
        issues: list[str] = []
        systems_found: list[str] = []

        for sys_name, weight, patterns in _GAME_SYSTEMS:
            found = any(pat.search(all_content) for pat in patterns)
            if found:
                score += weight
                systems_found.append(sys_name)
            else:
                issues.append(f"Missing game system: {sys_name}")

        # Confidence: higher when we have more files to analyze
        confidence = min(90, 30 + len(existing) * 5)

        print(
            f"{_PREFIX} Score={score}/100, "
            f"Systems={len(systems_found)}/5: {systems_found}"
        )

        return {
            "score": ScoreEntry(value=score, confidence=confidence),
            "issues": issues,
        }
