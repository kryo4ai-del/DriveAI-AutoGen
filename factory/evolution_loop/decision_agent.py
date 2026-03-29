"""Decision Agent — Translates Gaps and CEO Feedback into executable Tasks.

Maps each Gap to a concrete Task with type, priority, and description.
Also translates CEO Feedback issues into additional tasks.
Checks escalation conditions and flags for CEO review if needed.

All logic is deterministic (no LLM).
"""

from __future__ import annotations

from factory.evolution_loop.config.config_loader import EvolutionConfig
from factory.evolution_loop.ldo.schema import Gap, LoopDataObject, Task

_PREFIX = "[EVO-DECISION]"

# Gap category -> Task type
_CATEGORY_TO_TYPE = {
    "bug": "fix",
    "feature": "implement",
    "structural": "refactor",
    "performance": "refactor",
    "ux": "refactor",
}

# CEO issue category -> Task type
_CEO_CATEGORY_TO_TYPE = {
    "bug": "fix",
    "ux": "refactor",
    "performance": "refactor",
    "content": "implement",
    "feel": "refactor",
}

# CEO severity -> Task priority
_CEO_SEVERITY_TO_PRIORITY = {
    "blocker": "critical",
    "major": "high",
    "minor": "medium",
}

# Task type -> description prefix
_TYPE_PREFIX = {
    "fix": "Fix",
    "implement": "Implement",
    "refactor": "Refactor",
}


class DecisionAgent:
    """Translates Gaps and CEO Feedback into executable Factory Tasks."""

    AGENT_ID = "evo_decision"

    def __init__(self) -> None:
        pass

    # ------------------------------------------------------------------
    # Main entry point
    # ------------------------------------------------------------------

    def generate_tasks(
        self, ldo: LoopDataObject, config: EvolutionConfig,
    ) -> LoopDataObject:
        """Generate tasks from gaps.

        1. Map each gap to a task (type, priority, description)
        2. Assign unique task IDs
        3. Check escalation conditions
        4. Write tasks into ldo.tasks
        """
        iteration = ldo.meta.iteration
        tasks: list[Task] = []

        for i, gap in enumerate(ldo.gaps or [], start=1):
            task_type = _CATEGORY_TO_TYPE.get(gap.category, "refactor")
            prefix = _TYPE_PREFIX.get(task_type, "Fix")

            tasks.append(Task(
                id=f"TASK-{iteration}-{i:03d}",
                type=task_type,
                description=f"{prefix}: {gap.description}",
                target_component=gap.affected_component,
                originated_from=gap.id,
                priority=gap.severity or "medium",
            ))

        # Deep mode: convert non-critical "fix" tasks to "refactor"
        if ldo.meta.loop_mode == "deep":
            converted = 0
            for t in tasks:
                if t.type == "fix" and t.priority != "critical":
                    t.type = "refactor"
                    t.description = t.description.replace("Fix:", "Refactor:", 1)
                    converted += 1
            if converted:
                print(f"{_PREFIX} Deep Mode: {converted} tasks converted to refactor")

        ldo.tasks = tasks

        # Escalation check
        should_escalate, reason = self._should_escalate(ldo, config)
        if should_escalate:
            ldo.regression_data.recommendation = "ceo_review"
            print(f"{_PREFIX} ESCALATION: {reason}")

        # Log summary
        type_counts: dict[str, int] = {}
        for t in tasks:
            type_counts[t.type] = type_counts.get(t.type, 0) + 1
        parts = [f"{c} {tp}" for tp, c in sorted(type_counts.items())]
        summary = ", ".join(parts) if parts else "none"
        print(f"{_PREFIX} Generated {len(tasks)} tasks: {summary}")

        return ldo

    # ------------------------------------------------------------------
    # CEO Feedback translation
    # ------------------------------------------------------------------

    def translate_ceo_feedback(self, ldo: LoopDataObject) -> LoopDataObject:
        """Translate CEO feedback issues into tasks (appended to existing)."""
        iteration = ldo.meta.iteration
        issues = ldo.ceo_feedback.issues or []
        unresolved = [iss for iss in issues if not iss.resolved]

        if not unresolved:
            return ldo

        ceo_num = 0
        for iss in unresolved:
            ceo_num += 1
            task_type = _CEO_CATEGORY_TO_TYPE.get(iss.category, "refactor")
            priority = _CEO_SEVERITY_TO_PRIORITY.get(iss.severity, "medium")

            ldo.tasks.append(Task(
                id=f"TASK-{iteration}-CEO-{ceo_num:03d}",
                type=task_type,
                description=f"CEO: {iss.description}",
                target_component="",
                originated_from="ceo_feedback",
                priority=priority,
            ))

        print(f"{_PREFIX} Translated {ceo_num} CEO feedback items into tasks")
        return ldo

    # ------------------------------------------------------------------
    # Escalation logic
    # ------------------------------------------------------------------

    @staticmethod
    def _should_escalate(
        ldo: LoopDataObject, config: EvolutionConfig,
    ) -> tuple[bool, str]:
        """Check if escalation to CEO/CD is needed.

        Conditions (first match wins):
        1. More than 5 critical gaps
        2. A regression gap persisting for 3+ iterations
        3. More than 15 total gaps
        """
        gaps = ldo.gaps or []
        iteration = ldo.meta.iteration

        # 1. Too many critical gaps
        critical_count = sum(1 for g in gaps if g.severity == "critical")
        if critical_count > 5:
            return True, f"Too many critical gaps ({critical_count})"

        # 2. Persistent regression (3+ iterations old)
        for g in gaps:
            if g.is_regression and g.first_seen_iteration > 0:
                age = iteration - g.first_seen_iteration
                if age >= 3:
                    return True, (
                        f"Persistent regression: {g.description} "
                        f"(since iteration {g.first_seen_iteration})"
                    )

        # 3. Too many total gaps
        if len(gaps) > 15:
            return True, f"Too many total gaps ({len(gaps)})"

        return False, ""
