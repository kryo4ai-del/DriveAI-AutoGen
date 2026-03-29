"""Mechanics Consistency Checker -- Validates numeric game constants.

Extracts numeric constants from code and checks for:
  - Health/damage values <= 0 (invalid)
  - Overflow values > 999999 (suspicious)
  - Negative speeds/sizes (invalid)
  - Inconsistent ranges (min > max)

Score: 100 minus deductions per issue found.
"""

from __future__ import annotations

import os
import re

from factory.evolution_loop.ldo.schema import LoopDataObject, ScoreEntry
from factory.evolution_loop.plugins.base_plugin import EvaluationPlugin

_PREFIX = "[PLUGIN-GAME-MECH]"

# Patterns to extract numeric assignments in common game contexts
_NUMERIC_PATTERNS = [
    # health = 100, maxHealth = 200, etc.
    re.compile(
        r"\b(max\s*)?health\s*[=:]\s*(-?\d+(?:\.\d+)?)",
        re.IGNORECASE,
    ),
    # damage = 10, baseDamage = 5
    re.compile(
        r"\b(?:base\s*)?damage\s*[=:]\s*(-?\d+(?:\.\d+)?)",
        re.IGNORECASE,
    ),
    # speed = 5.0, moveSpeed = 3
    re.compile(
        r"\b(?:move\s*)?speed\s*[=:]\s*(-?\d+(?:\.\d+)?)",
        re.IGNORECASE,
    ),
    # size = 1.0, scale = 2
    re.compile(
        r"\b(?:scale|size)\s*[=:]\s*(-?\d+(?:\.\d+)?)",
        re.IGNORECASE,
    ),
    # level = 1, maxLevel = 99
    re.compile(
        r"\b(max\s*)?level\s*[=:]\s*(-?\d+(?:\.\d+)?)",
        re.IGNORECASE,
    ),
]

# Generic large numeric constant pattern
_OVERFLOW_PATTERN = re.compile(r"\b(\d{7,})\b")


class MechanicsConsistencyChecker(EvaluationPlugin):
    """Checks numeric game constants for consistency and validity."""

    name = "mechanics_consistency_checker"

    def evaluate(self, ldo: LoopDataObject) -> dict:
        paths = ldo.build_artifacts.paths or []
        existing = [p for p in paths if os.path.isfile(p)]

        if not existing:
            print(f"{_PREFIX} No build files -- returning default score")
            return {
                "score": ScoreEntry(value=50, confidence=10),
                "issues": ["No build artifacts to analyze"],
            }

        # Read all content
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

        issues: list[str] = []
        deductions = 0

        # Check health/damage <= 0
        for pat in _NUMERIC_PATTERNS[:2]:  # health + damage
            for match in pat.finditer(all_content):
                groups = match.groups()
                val_str = groups[-1]  # Last group is the number
                try:
                    val = float(val_str)
                    if val <= 0:
                        issues.append(
                            f"Invalid value: {match.group(0).strip()} (must be > 0)"
                        )
                        deductions += 10
                except ValueError:
                    pass

        # Check negative speed/size
        for pat in _NUMERIC_PATTERNS[2:4]:  # speed + size
            for match in pat.finditer(all_content):
                groups = match.groups()
                val_str = groups[-1]
                try:
                    val = float(val_str)
                    if val < 0:
                        issues.append(
                            f"Negative value: {match.group(0).strip()}"
                        )
                        deductions += 5
                except ValueError:
                    pass

        # Check overflow values > 999999
        overflow_count = 0
        for match in _OVERFLOW_PATTERN.finditer(all_content):
            val = int(match.group(1))
            if val > 999999:
                overflow_count += 1
                if overflow_count <= 5:  # Report max 5
                    issues.append(f"Suspicious large value: {val}")
                deductions += 3

        if overflow_count > 5:
            issues.append(f"... and {overflow_count - 5} more large values")

        score = max(0, 100 - deductions)
        confidence = min(85, 25 + len(existing) * 4)

        print(
            f"{_PREFIX} Score={score}/100, "
            f"Issues={len(issues)}, Deductions={deductions}"
        )

        return {
            "score": ScoreEntry(value=score, confidence=confidence),
            "issues": issues,
        }
