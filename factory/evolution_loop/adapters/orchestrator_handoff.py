"""Orchestrator Handoff — Bridge between Factory Orchestrator and Evolution Loop.

The Factory Orchestrator (factory/orchestrator/) produces BuildReport dicts.
QA (factory/qa/) produces QAResult / QAReport dicts.

This module converts both into a LoopDataObject for the Evolution Loop,
and formats Evolution Loop tasks back into Orchestrator-compatible dicts.

IMPORTANT: No changes to factory/orchestrator/ — all logic lives here.
"""

from __future__ import annotations

import logging
from pathlib import Path

from factory.evolution_loop.ldo.schema import (
    BuildArtifacts,
    LoopDataObject,
    QAResults,
)
from factory.evolution_loop.adapters.qa_to_ldo_adapter import QAToLDOAdapter

logger = logging.getLogger(__name__)

_QA_ADAPTER = QAToLDOAdapter()


class OrchestratorHandoff:
    """Handoff logic between the existing Factory Orchestrator and the Evolution Loop.

    Directions:
      - **to_loop**: ``receive_from_orchestrator()`` — build + QA results → LDO
      - **to_orchestrator**: ``send_tasks_to_orchestrator()`` — LDO tasks → task list
    """

    # ------------------------------------------------------------------
    # Orchestrator → Evolution Loop
    # ------------------------------------------------------------------

    def receive_from_orchestrator(
        self,
        build_result: dict | None,
        qa_result: dict | None,
        project_id: str,
        project_type: str,
        production_line: str,
    ) -> LoopDataObject:
        """Create an initial LDO from Orchestrator build + QA results.

        Handles three build_result flavours:
          1. Full ``BuildReport.to_dict()`` (has ``"plan"`` key)
          2. Simplified dict (``"files"``, ``"status"``, ``"platform"``)
          3. ``None`` / empty dict

        QA results are delegated to :class:`QAToLDOAdapter` when they match
        a known format, otherwise mapped directly from simple keys.
        """
        build = build_result or {}
        qa = qa_result or {}

        # 1. Create initial LDO
        ldo = LoopDataObject.create_initial(project_id, project_type, production_line)

        # 2. Populate build_artifacts
        ldo.build_artifacts = self._extract_build_artifacts(build)

        # 3. Populate qa_results + scores + gaps via QAToLDOAdapter
        self._apply_qa_data(ldo, qa)

        return ldo

    # ------------------------------------------------------------------
    # Evolution Loop → Orchestrator
    # ------------------------------------------------------------------

    def send_tasks_to_orchestrator(self, tasks: list, iteration: int = 0) -> dict:
        """Format Evolution Loop tasks for the Factory Orchestrator.

        The Orchestrator works with ``BuildStep`` objects, but external task
        injection uses a generic dict format.  Each LDO task is mapped to::

            {
                "action": str,        # fix | implement | refactor | remove
                "description": str,
                "target": str,        # file or component
                "priority": str       # critical | high | medium | low
            }

        Returns a dict ready for the Orchestrator to consume.
        """
        formatted: list[dict] = []
        for task in (tasks or []):
            if isinstance(task, dict):
                formatted.append({
                    "action": task.get("type", task.get("action", "fix")),
                    "description": task.get("description", ""),
                    "target": task.get("target_component", task.get("target", "")),
                    "priority": task.get("priority", "medium"),
                })
            elif hasattr(task, "type"):
                # Dataclass Task object
                formatted.append({
                    "action": getattr(task, "type", "fix"),
                    "description": getattr(task, "description", ""),
                    "target": getattr(task, "target_component", ""),
                    "priority": getattr(task, "priority", "medium"),
                })

        return {
            "tasks": formatted,
            "source": "evolution_loop",
            "iteration": iteration,
        }

    # ------------------------------------------------------------------
    # Report
    # ------------------------------------------------------------------

    def create_handoff_report(self, ldo: LoopDataObject, direction: str) -> str:
        """Create a short log-friendly report string.

        Args:
            ldo: The LoopDataObject involved in the handoff.
            direction: ``"to_loop"`` or ``"to_orchestrator"``.
        """
        if direction == "to_loop":
            n_files = len(ldo.build_artifacts.paths)
            n_passed = ldo.qa_results.tests_passed
            n_failed = ldo.qa_results.tests_failed
            compile = ldo.build_artifacts.compile_status
            return (
                f"Handoff to Evolution Loop: Project {ldo.meta.project_id}, "
                f"compile={compile}, {n_files} build files, "
                f"{n_passed + n_failed} test results ({n_failed} failed)"
            )

        if direction == "to_orchestrator":
            tasks = ldo.tasks
            total = len(tasks)
            counts: dict[str, int] = {}
            for t in tasks:
                prio = t.priority if hasattr(t, "priority") else (
                    t.get("priority", "medium") if isinstance(t, dict) else "medium")
                counts[prio] = counts.get(prio, 0) + 1

            parts = [f"{v} {k}" for k, v in sorted(counts.items(),
                     key=lambda x: ["critical", "high", "medium", "low"].index(x[0])
                     if x[0] in ("critical", "high", "medium", "low") else 99)]
            return (
                f"Handoff to Orchestrator: {total} tasks "
                f"({', '.join(parts) if parts else 'none'})"
            )

        return f"Handoff: unknown direction '{direction}'"

    # ------------------------------------------------------------------
    # Internal: build artifacts extraction
    # ------------------------------------------------------------------

    def _extract_build_artifacts(self, build: dict) -> BuildArtifacts:
        """Extract BuildArtifacts from various build_result formats."""

        # Format 1: Full BuildReport.to_dict() — has "plan" key
        if "plan" in build:
            return self._from_build_report(build)

        # Format 2: Simplified dict — "files", "status", "platform"
        if "files" in build or "status" in build:
            return self._from_simple_build(build)

        # Format 3: Empty / unknown
        return BuildArtifacts()

    def _from_build_report(self, report: dict) -> BuildArtifacts:
        """Extract from full BuildReport.to_dict()."""
        plan = report.get("plan", {})
        steps = plan.get("steps", [])

        # Collect file paths from completed steps
        paths: list[str] = []
        for step in steps:
            result = step.get("result")
            if isinstance(result, dict):
                # Pipeline result may contain generated file paths
                paths.extend(result.get("files", []))
                paths.extend(result.get("generated_files", []))

        # Determine compile status from plan status
        plan_status = plan.get("status", "draft")
        if plan_status == "completed":
            compile_status = "success"
        elif plan_status == "failed":
            compile_status = "failed"
        else:
            compile_status = "not_built"

        # Collect platform details
        lines = sorted(set(s.get("line", "") for s in steps if s.get("line")))
        languages = sorted(set(s.get("language", "") for s in steps if s.get("language")))

        step_results = report.get("step_results", [])
        completed = sum(1 for sr in step_results if sr.get("status") == "completed")
        failed = sum(1 for sr in step_results if sr.get("status") == "failed")

        return BuildArtifacts(
            paths=paths,
            compile_status=compile_status,
            platform_details={
                "lines": lines,
                "languages": languages,
                "steps_completed": completed,
                "steps_failed": failed,
                "started": report.get("started", ""),
                "finished": report.get("finished", ""),
            },
        )

    @staticmethod
    def _from_simple_build(build: dict) -> BuildArtifacts:
        """Extract from simplified dict {files, status, platform}."""
        files = build.get("files", [])
        raw_status = build.get("status", "not_built")

        # Normalize status to LDO enum
        status_map = {
            "success": "success",
            "completed": "success",
            "passed": "success",
            "failed": "failed",
            "error": "failed",
        }
        compile_status = status_map.get(raw_status, "not_built")

        platform = build.get("platform", "")
        return BuildArtifacts(
            paths=files,
            compile_status=compile_status,
            platform_details={"platform": platform} if platform else {},
        )

    # ------------------------------------------------------------------
    # Internal: QA data application
    # ------------------------------------------------------------------

    def _apply_qa_data(self, ldo: LoopDataObject, qa: dict) -> None:
        """Apply QA data to an LDO, using QAToLDOAdapter when possible."""
        if not qa:
            return

        # Try QAToLDOAdapter for known formats (has "phases" or "build_result")
        if "phases" in qa or "build_result" in qa or "test_result" in qa:
            try:
                partial = _QA_ADAPTER.transform_qa_department_results(qa)
                self._apply_partial(ldo, partial)
                return
            except Exception as e:
                logger.warning("QAToLDOAdapter failed, falling back to simple: %s", e)

        # Simple QA dict: {tests_passed, tests_failed, errors, warnings}
        ldo.qa_results = QAResults(
            tests_passed=qa.get("tests_passed", 0),
            tests_failed=qa.get("tests_failed", 0),
            test_details=[],
            compile_errors=qa.get("errors", []),
            warnings=qa.get("warnings", []),
        )

    @staticmethod
    def _apply_partial(ldo: LoopDataObject, partial: dict) -> None:
        """Apply a QAToLDOAdapter partial dict to an LDO."""
        # build_artifacts (only if partial has it and LDO hasn't been set)
        ba = partial.get("build_artifacts")
        if ba and ldo.build_artifacts.compile_status == "not_built":
            ldo.build_artifacts.compile_status = ba.get("compile_status", "not_built")
            ldo.build_artifacts.platform_details.update(ba.get("platform_details", {}))

        # qa_results
        qa = partial.get("qa_results")
        if qa:
            ldo.qa_results.tests_passed = qa.get("tests_passed", 0)
            ldo.qa_results.tests_failed = qa.get("tests_failed", 0)
            ldo.qa_results.test_details = qa.get("test_details", [])
            ldo.qa_results.compile_errors = qa.get("compile_errors", [])
            ldo.qa_results.warnings = qa.get("warnings", [])

        # scores
        scores = partial.get("scores", {})
        for score_name, score_data in scores.items():
            if isinstance(score_data, dict) and hasattr(ldo.scores, score_name):
                entry = getattr(ldo.scores, score_name)
                if hasattr(entry, "value"):
                    entry.value = score_data.get("value", 0.0)
                    entry.confidence = score_data.get("confidence", 0.0)

        # gaps
        from factory.evolution_loop.ldo.schema import Gap
        for gap_dict in partial.get("gaps", []):
            ldo.gaps.append(Gap(
                id=gap_dict.get("id", ""),
                category=gap_dict.get("category", ""),
                severity=gap_dict.get("severity", ""),
                description=gap_dict.get("description", ""),
                affected_component=gap_dict.get("affected_component", ""),
                is_regression=gap_dict.get("is_regression", False),
                first_seen_iteration=gap_dict.get("first_seen_iteration", 0),
            ))
