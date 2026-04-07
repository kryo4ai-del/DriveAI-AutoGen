"""
DriveAI Mac Factory — Error Auditor

Compares error lists between cycles to detect:
- FIXED errors (were there, now gone — progress)
- NEW errors (weren't there, now appeared — regression)
- PERSISTENT errors (still there — no change)
"""

import hashlib
from dataclasses import dataclass, field


@dataclass
class ErrorDiff:
    fixed_count: int = 0
    new_count: int = 0
    persistent_count: int = 0

    fixed_errors: list = field(default_factory=list)
    new_errors: list = field(default_factory=list)
    persistent_errors: list = field(default_factory=list)

    regression_detected: bool = False
    regression_files: list = field(default_factory=list)
    regression_summary: str = ""

    def to_dict(self) -> dict:
        return {
            "fixed": self.fixed_count,
            "new": self.new_count,
            "persistent": self.persistent_count,
            "regression": self.regression_detected,
            "regression_files": self.regression_files,
            "net_change": self.fixed_count - self.new_count
        }


class ErrorAuditor:
    """
    Compares error lists between cycles.

    Usage:
        auditor = ErrorAuditor()
        auditor.set_baseline(errors_cycle_1)
        diff = auditor.diff(errors_cycle_2)
        if diff.regression_detected:
            print(f"REGRESSION from {diff.regression_files}")
    """

    def __init__(self):
        self.baseline_errors = []
        self.baseline_hashes = set()
        self.history = []

    def set_baseline(self, errors: list):
        self.baseline_errors = errors
        self.baseline_hashes = {self._hash_error(e) for e in errors}

    def diff(self, current_errors: list) -> ErrorDiff:
        current_hashes = {self._hash_error(e) for e in current_errors}
        current_by_hash = {self._hash_error(e): e for e in current_errors}
        baseline_by_hash = {self._hash_error(e): e for e in self.baseline_errors}

        fixed_hashes = self.baseline_hashes - current_hashes
        new_hashes = current_hashes - self.baseline_hashes
        persistent_hashes = self.baseline_hashes & current_hashes

        result = ErrorDiff(
            fixed_count=len(fixed_hashes),
            new_count=len(new_hashes),
            persistent_count=len(persistent_hashes),
            fixed_errors=[baseline_by_hash[h] for h in fixed_hashes if h in baseline_by_hash],
            new_errors=[current_by_hash[h] for h in new_hashes if h in current_by_hash],
            persistent_errors=[current_by_hash[h] for h in persistent_hashes if h in current_by_hash]
        )

        if result.new_count > 0:
            regression_files = {}
            for e in result.new_errors:
                f = e.get("file", "unknown")
                regression_files[f] = regression_files.get(f, 0) + 1

            result.regression_files = sorted(regression_files.keys(),
                                             key=lambda x: -regression_files[x])

            if result.new_count > result.fixed_count:
                result.regression_detected = True
                top_file = result.regression_files[0] if result.regression_files else "unknown"
                result.regression_summary = (
                    f"Regression: {result.new_count} new errors (vs {result.fixed_count} fixed). "
                    f"Main source: {top_file} ({regression_files.get(top_file, 0)} new errors)"
                )

        self.history.append(result)
        return result

    def update_baseline(self, errors: list):
        self.set_baseline(errors)

    def get_regression_files(self) -> list:
        file_counts = {}
        for diff in self.history:
            for f in diff.regression_files:
                file_counts[f] = file_counts.get(f, 0) + 1
        return sorted(file_counts.keys(), key=lambda x: -file_counts[x])

    def get_trend(self) -> list:
        trend = []
        for i, diff in enumerate(self.history):
            total = diff.persistent_count + diff.new_count
            trend.append({
                "cycle": i + 1,
                "total": total,
                "fixed": diff.fixed_count,
                "new": diff.new_count,
                "net_change": diff.fixed_count - diff.new_count
            })
        return trend

    def print_diff(self, diff: ErrorDiff, cycle: int = 0):
        prefix = f"[Auditor Cycle {cycle}] " if cycle else "[Auditor] "
        if diff.regression_detected:
            print(f"{prefix}REGRESSION: {diff.new_count} new errors, {diff.fixed_count} fixed")
            for f in diff.regression_files[:5]:
                print(f"{prefix}  Regression source: {f}")
        else:
            net = diff.fixed_count - diff.new_count
            sign = '+' if net > 0 else ''
            print(f"{prefix}Progress: {diff.fixed_count} fixed, {diff.new_count} new, "
                  f"{diff.persistent_count} persistent (net: {sign}{net})")

    def _hash_error(self, error: dict) -> str:
        """Hash uses file + message only — line numbers shift after fixes."""
        key = f"{error.get('file', '')}::{error.get('message', '')}"
        return hashlib.md5(key.encode()).hexdigest()[:12]
