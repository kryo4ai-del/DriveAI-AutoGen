# fix_executor.py
# Builds a focused follow-up fix task from bug review and refactor findings.


def _first_agent_text(messages: list, source_name: str, max_chars: int = 600) -> str:
    for msg in messages:
        if getattr(msg, "source", "") == source_name:
            content = getattr(msg, "content", "")
            if isinstance(content, str) and content.strip():
                return content.strip()[:max_chars]
    return ""


class FixExecutor:
    def build_fix_task(
        self,
        user_task: str,
        bug_messages: list,
        refactor_messages: list,
        review_context: str = "",
        impl_summary: str = "",
    ) -> str:
        """
        Builds a concise implementation-oriented fix task combining:
        - Implementation summary (API skeleton)
        - Accumulated review findings (Bug Hunter, CD, UX Psych, Refactor)
        - Direct bug/refactor excerpts from agent messages

        review_context: pre-built structured review context from _build_review_context()
        impl_summary: API skeleton from CodeExtractor.build_implementation_summary()
        """
        bug_excerpt = _first_agent_text(bug_messages, "bug_hunter")
        refactor_excerpt = _first_agent_text(refactor_messages, "refactor_agent")

        parts = []

        # Lead with implementation context so the fix agent knows what it's fixing
        if impl_summary:
            parts.append(impl_summary)

        # Accumulated review findings from all prior passes
        if review_context:
            parts.append(review_context)

        parts.append(
            f"Apply the highest-priority bug fixes and refactor improvements "
            f"for the recently implemented feature: '{user_task}'. "
            "Focus on correctness, edge-case handling, readability, and maintainability "
            "while preserving behavior."
        )

        if bug_excerpt:
            parts.append(f"\nKey bug findings to address:\n{bug_excerpt}")

        if refactor_excerpt:
            parts.append(f"\nKey refactor suggestions to apply:\n{refactor_excerpt}")

        return "\n\n".join(parts)
