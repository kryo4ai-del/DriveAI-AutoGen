"""
DriveAI Mac Factory — Error Analyzer

Analyzes compile errors and chooses the right fix strategy for each.
Not just counting — UNDERSTANDING.
"""

import os
import re
import hashlib
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional
from collections import defaultdict


SKIP_DIRS = {'Tests', 'test', 'build', 'quarantine', '.git', 'DerivedData', '.build', 'Pods'}


@dataclass
class ErrorCluster:
    cluster_id: str = ""
    cluster_type: str = ""
    file_path: str = ""
    error_pattern: str = ""
    error_count: int = 0
    errors: list = field(default_factory=list)
    root_cause: str = ""
    corruption_detected: bool = False
    corruption_type: str = ""
    duplicate_of: str = ""
    recommended_action: str = ""
    confidence: float = 0.0
    reasoning: str = ""


@dataclass
class ErrorAnalysis:
    total_errors: int = 0
    total_warnings: int = 0
    clusters: list = field(default_factory=list)
    single_file_problem: bool = False
    has_corrupted_files: bool = False
    has_duplicates: bool = False
    overall_strategy: str = ""
    estimated_fix_cycles: int = 1

    def to_dict(self) -> dict:
        return {
            "total_errors": self.total_errors,
            "cluster_count": len(self.clusters),
            "single_file_problem": self.single_file_problem,
            "has_corrupted_files": self.has_corrupted_files,
            "has_duplicates": self.has_duplicates,
            "overall_strategy": self.overall_strategy,
            "estimated_fix_cycles": self.estimated_fix_cycles,
            "clusters": [
                {
                    "file": c.file_path,
                    "pattern": c.error_pattern,
                    "count": c.error_count,
                    "action": c.recommended_action,
                    "root_cause": c.root_cause,
                    "reasoning": c.reasoning
                }
                for c in self.clusters
            ]
        }


class ErrorAnalyzer:
    SWIFT_TOKENS = (
        'import ', '//', '/*', '@', 'struct ', 'class ', 'enum ',
        'protocol ', 'extension ', 'public ', 'private ', 'internal ',
        'final ', 'open ', '#if', '#import', 'func ', 'let ', 'var ',
        'actor ', 'typealias ', 'precedencegroup', 'infix ', 'prefix ',
        'postfix ', 'operator ', 'macro ', 'fileprivate ', 'indirect '
    )

    NON_CRITICAL_PATTERNS = (
        'Mock', 'Stub', 'Fake', 'Dummy', 'Test', 'Fixture',
        'Helper', 'Generated', 'Preview', 'Sample', 'Example'
    )

    NON_CRITICAL_DIRS = (
        'Tests', 'Test', 'Mocks', 'Stubs', 'Fixtures',
        'Preview Content', 'Previews', 'Generated'
    )

    PATTERN_MAP = [
        (r"cannot find type '.*' in scope", "cannot_find_type"),
        (r"cannot find '.*' in scope", "cannot_find_in_scope"),
        (r"value of type '.*' has no member '.*'", "value_no_member"),
        (r"type '.*' has no member '.*'", "no_member"),
        (r"expected declaration", "expected_declaration"),
        (r"use of undeclared type '.*'", "undeclared_type"),
        (r"use of unresolved identifier '.*'", "unresolved_identifier"),
        (r"missing argument for parameter", "missing_argument"),
        (r"cannot convert value of type", "type_mismatch"),
        (r"ambiguous use of '.*'", "ambiguous"),
        (r"invalid redeclaration of '.*'", "invalid_redeclaration"),
        (r"cannot assign to property", "cannot_assign"),
        (r"protocol '.*' requires", "protocol_conformance"),
        (r"missing return in", "missing_return"),
        (r"consecutive statements", "consecutive_statements"),
        (r"expressions are not allowed at the top level", "top_level_expression"),
        (r"unknown attribute '.*'", "unknown_attribute"),
        (r"unable to type-check this expression", "type_check_timeout"),
        (r"multiple @main", "multiple_main"),
    ]

    def __init__(self, project_dir: str, learning_db=None):
        self.project_dir = project_dir
        self.learning_db = learning_db
        self._file_cycle_tracker = {}

    def analyze(self, errors: list) -> ErrorAnalysis:
        analysis = ErrorAnalysis()
        analysis.total_errors = len(errors)

        if not errors:
            analysis.overall_strategy = "none"
            return analysis

        file_clusters = self._cluster_by_file(errors)

        for cluster in file_clusters:
            if cluster.file_path:
                corruption = self._check_corruption(cluster.file_path)
                if corruption:
                    cluster.corruption_detected = True
                    cluster.corruption_type = corruption
                    cluster.root_cause = corruption
                    analysis.has_corrupted_files = True

            if cluster.file_path and (cluster.corruption_detected or cluster.error_count >= 5):
                dup = self._check_duplicate_type(cluster.file_path)
                if dup:
                    cluster.root_cause = "duplicate_type"
                    cluster.duplicate_of = dup
                    analysis.has_duplicates = True

            cluster.recommended_action = self._pick_strategy(cluster)
            cluster.reasoning = self._explain_strategy(cluster)

            if cluster.file_path:
                self._file_cycle_tracker[cluster.file_path] = \
                    self._file_cycle_tracker.get(cluster.file_path, 0) + 1

        if file_clusters and file_clusters[0].error_count / max(analysis.total_errors, 1) >= 0.5:
            analysis.single_file_problem = True

        analysis.clusters = file_clusters
        analysis.overall_strategy = self._determine_overall_strategy(analysis)
        analysis.estimated_fix_cycles = self._estimate_cycles(analysis)

        return analysis

    def _cluster_by_file(self, errors: list) -> list:
        by_file = defaultdict(list)
        for e in errors:
            filepath = e.get("file", "unknown")
            by_file[filepath].append(e)

        clusters = []
        for filepath, file_errors in sorted(by_file.items(), key=lambda x: -len(x[1])):
            cluster = ErrorCluster(
                cluster_id=hashlib.md5(filepath.encode()).hexdigest()[:8],
                cluster_type="single_file",
                file_path=filepath,
                error_count=len(file_errors),
                errors=file_errors,
                error_pattern=self._extract_dominant_pattern(file_errors)
            )
            clusters.append(cluster)
        return clusters

    def _extract_dominant_pattern(self, errors: list) -> str:
        patterns = {}
        for e in errors:
            p = self._normalize_error_pattern(e.get("message", ""))
            patterns[p] = patterns.get(p, 0) + 1
        if patterns:
            return max(patterns, key=patterns.get)
        return "unknown"

    def _normalize_error_pattern(self, message: str) -> str:
        msg = message.lower().strip()
        for regex, name in self.PATTERN_MAP:
            if re.search(regex, msg):
                return name
        return "unknown"

    def _check_corruption(self, file_path: str) -> Optional[str]:
        full_path = self._resolve_path(file_path)
        if not full_path or not os.path.exists(full_path):
            return None

        try:
            with open(full_path, 'r', errors='ignore') as f:
                content = f.read()
        except Exception:
            return None

        first_line = ""
        for line in content.split('\n'):
            stripped = line.strip()
            if stripped:
                first_line = stripped
                break

        if first_line and not any(first_line.startswith(t) for t in self.SWIFT_TOKENS):
            return "llm_garbage"

        if '```' in content:
            return "markdown_fence"

        return None

    def _check_duplicate_type(self, file_path: str) -> Optional[str]:
        type_name = Path(file_path).stem
        full_path = self._resolve_path(file_path)
        if not full_path:
            return None

        exclude_abs = os.path.abspath(full_path)
        pattern = re.compile(
            rf'^[ \t]*(?:public\s+|private\s+|internal\s+|open\s+|final\s+|fileprivate\s+)*'
            rf'(?:class|struct|enum|protocol|actor)\s+{re.escape(type_name)}\b',
            re.MULTILINE
        )

        for swift_file in Path(self.project_dir).rglob("*.swift"):
            if os.path.abspath(str(swift_file)) == exclude_abs:
                continue
            if any(part in SKIP_DIRS for part in swift_file.parts):
                continue
            try:
                content = swift_file.read_text(errors='ignore')
                if pattern.search(content):
                    return str(swift_file)
            except Exception:
                continue
        return None

    def _is_build_critical(self, file_path: str) -> bool:
        filename = os.path.basename(file_path)
        for pattern in self.NON_CRITICAL_PATTERNS:
            if pattern in filename:
                return False
        for dir_pattern in self.NON_CRITICAL_DIRS:
            if dir_pattern in file_path:
                return False
        return True

    def _count_external_references(self, file_path: str) -> int:
        type_name = Path(file_path).stem
        resolved = self._resolve_path(file_path)
        exclude_abs = os.path.abspath(resolved) if resolved else None
        count = 0
        word = re.compile(rf'\b{re.escape(type_name)}\b')

        for swift_file in Path(self.project_dir).rglob("*.swift"):
            if exclude_abs and os.path.abspath(str(swift_file)) == exclude_abs:
                continue
            if any(part in {'build', 'quarantine', '.git', 'DerivedData'} for part in swift_file.parts):
                continue
            try:
                content = swift_file.read_text(errors='ignore')
                if word.search(content):
                    count += 1
            except Exception:
                continue
        return count

    def _pick_strategy(self, cluster: ErrorCluster) -> str:
        # 0. Duplicate
        if cluster.root_cause == "duplicate_type":
            return "deduplicate"

        # 1. Garbage + unreferenced
        if cluster.corruption_detected:
            ref_count = self._count_external_references(cluster.file_path) if cluster.file_path else 1
            if ref_count == 0:
                cluster.root_cause = "llm_garbage_unreferenced"
                return "empty_file"

            # 2. Garbage + non-critical
            if not self._is_build_critical(cluster.file_path):
                return "quarantine"

        # 3. Stuck non-critical file
        if cluster.file_path:
            stuck_count = self._file_cycle_tracker.get(cluster.file_path, 0)
            if stuck_count >= 3 and not self._is_build_critical(cluster.file_path):
                return "quarantine"

        # 4. Corrupted critical
        if cluster.corruption_detected:
            return "deep_repair"

        # 5. Import errors
        import_patterns = {"cannot_find_in_scope", "cannot_find_type", "undeclared_type",
                           "unresolved_identifier", "unknown_attribute"}
        if cluster.error_pattern in import_patterns:
            return "repair_tier1"

        # 6. Many errors in one file
        if cluster.error_count > 10:
            return "iterative_stub"

        # 7/8. Few or default
        return "repair_tier2"

    def _explain_strategy(self, cluster: ErrorCluster) -> str:
        action = cluster.recommended_action
        explanations = {
            "deduplicate": f"Type already defined in {cluster.duplicate_of}",
            "empty_file": f"{cluster.file_path} is garbage and unreferenced",
            "quarantine": f"{cluster.file_path} is non-critical or stuck — quarantining",
            "deep_repair": f"{cluster.file_path} is corrupted but critical — full rewrite",
            "repair_tier1": f"{cluster.error_count}x {cluster.error_pattern} — deterministic fix ($0)",
            "repair_tier2": f"{cluster.error_count} errors — LLM repair needed",
            "iterative_stub": f"{cluster.error_count} errors in {cluster.file_path} — stub to compile",
        }
        return explanations.get(action, f"{cluster.error_count} errors -> {action}")

    def _determine_overall_strategy(self, analysis: ErrorAnalysis) -> str:
        if analysis.has_corrupted_files:
            return "fix_corruption_first"
        if analysis.has_duplicates:
            return "dedup_first"
        if analysis.total_errors <= 10:
            return "targeted_fix"
        if analysis.total_errors <= 50:
            return "bulk_repair"
        return "staged_repair"

    def _estimate_cycles(self, analysis: ErrorAnalysis) -> int:
        if analysis.total_errors == 0:
            return 0
        if analysis.total_errors <= 5:
            return 1
        if analysis.total_errors <= 20:
            return 2
        if analysis.total_errors <= 100:
            return 3
        return 5

    def _resolve_path(self, file_path: str) -> Optional[str]:
        if os.path.isabs(file_path) and os.path.exists(file_path):
            return file_path
        candidate = os.path.join(self.project_dir, file_path)
        if os.path.exists(candidate):
            return candidate
        filename = os.path.basename(file_path)
        for f in Path(self.project_dir).rglob(filename):
            if f.is_file():
                return str(f)
        return None

    def reset_stuck_tracker(self):
        self._file_cycle_tracker = {}
