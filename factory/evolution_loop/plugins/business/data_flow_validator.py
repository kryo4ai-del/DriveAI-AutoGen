"""Data Flow Validator -- Checks business app data handling patterns.

Evaluates 3 categories:
  1. API Error Handling  (40 pts) -- try/catch around HTTP calls
  2. Input Validation    (30 pts) -- form/field validation patterns
  3. Data Sanitization   (30 pts) -- escaping, encoding, XSS prevention
"""

from __future__ import annotations

import os
import re

from factory.evolution_loop.ldo.schema import LoopDataObject, ScoreEntry
from factory.evolution_loop.plugins.base_plugin import EvaluationPlugin

_PREFIX = "[PLUGIN-BIZ-DATA]"

# --- API Error Handling patterns ---
_API_CALL_PATTERNS = [
    re.compile(r"\bfetch\s*\(", re.IGNORECASE),
    re.compile(r"\baxios\b", re.IGNORECASE),
    re.compile(r"\brequests?\.(get|post|put|delete)\b", re.IGNORECASE),
    re.compile(r"\bhttp\s*client\b", re.IGNORECASE),
    re.compile(r"\bURLSession\b"),
    re.compile(r"\bretrofit\b", re.IGNORECASE),
    re.compile(r"\bHttpClient\b"),
]

_ERROR_HANDLING_PATTERNS = [
    re.compile(r"\btry\b"),
    re.compile(r"\bcatch\b"),
    re.compile(r"\b\.catch\s*\("),
    re.compile(r"\bexcept\b"),
    re.compile(r"\bon\s*error\b", re.IGNORECASE),
    re.compile(r"\berror\s*handler\b", re.IGNORECASE),
    re.compile(r"\b\.then\b.*\.\bcatch\b"),
]

# --- Input Validation patterns ---
_VALIDATION_PATTERNS = [
    re.compile(r"\bvalidat(e|ion|or)\b", re.IGNORECASE),
    re.compile(r"\brequired\b", re.IGNORECASE),
    re.compile(r"\bmin\s*length\b", re.IGNORECASE),
    re.compile(r"\bmax\s*length\b", re.IGNORECASE),
    re.compile(r"\bpattern\b.*\bregex\b", re.IGNORECASE),
    re.compile(r"\bform\s*data\b", re.IGNORECASE),
    re.compile(r"\bisValid\b"),
    re.compile(r"\bschema\b", re.IGNORECASE),
]

# --- Data Sanitization patterns ---
_SANITIZE_PATTERNS = [
    re.compile(r"\bsanitiz(e|er|ation)\b", re.IGNORECASE),
    re.compile(r"\bescape\s*html\b", re.IGNORECASE),
    re.compile(r"\bencode\s*(uri|url|html)\b", re.IGNORECASE),
    re.compile(r"\bxss\b", re.IGNORECASE),
    re.compile(r"\bcsrf\b", re.IGNORECASE),
    re.compile(r"\bprepared\s*statement\b", re.IGNORECASE),
    re.compile(r"\bparameterized\b", re.IGNORECASE),
    re.compile(r"\bdompurify\b", re.IGNORECASE),
]


class DataFlowValidator(EvaluationPlugin):
    """Validates data handling in business applications."""

    name = "data_flow_validator"

    def evaluate(self, ldo: LoopDataObject) -> dict:
        paths = ldo.build_artifacts.paths or []
        existing = [p for p in paths if os.path.isfile(p)]

        if not existing:
            print(f"{_PREFIX} No build files -- returning default score")
            return {
                "score": ScoreEntry(value=50, confidence=10),
                "issues": ["No build artifacts to analyze"],
            }

        # Read all text content
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

        # 1. API Error Handling (40 pts)
        has_api_calls = any(p.search(all_content) for p in _API_CALL_PATTERNS)
        has_error_handling = any(
            p.search(all_content) for p in _ERROR_HANDLING_PATTERNS
        )

        if has_api_calls and has_error_handling:
            score += 40
        elif has_api_calls and not has_error_handling:
            score += 10
            issues.append("API calls found without error handling patterns")
        elif not has_api_calls:
            # No API calls -- neutral, give partial credit
            score += 20
            issues.append("No API call patterns detected")

        # 2. Input Validation (30 pts)
        validation_hits = sum(
            1 for p in _VALIDATION_PATTERNS if p.search(all_content)
        )
        if validation_hits >= 3:
            score += 30
        elif validation_hits >= 1:
            score += 15
            issues.append(
                f"Limited input validation ({validation_hits} patterns found)"
            )
        else:
            issues.append("No input validation patterns found")

        # 3. Data Sanitization (30 pts)
        sanitize_hits = sum(
            1 for p in _SANITIZE_PATTERNS if p.search(all_content)
        )
        if sanitize_hits >= 2:
            score += 30
        elif sanitize_hits >= 1:
            score += 15
            issues.append(
                f"Limited data sanitization ({sanitize_hits} patterns found)"
            )
        else:
            issues.append("No data sanitization patterns found")

        confidence = min(80, 20 + len(existing) * 3)

        print(
            f"{_PREFIX} Score={score}/100, "
            f"API={'Y' if has_api_calls else 'N'}, "
            f"Validation={validation_hits}, "
            f"Sanitize={sanitize_hits}"
        )

        return {
            "score": ScoreEntry(value=score, confidence=confidence),
            "issues": issues,
        }
