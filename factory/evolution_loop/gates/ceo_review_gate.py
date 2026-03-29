"""CEO Review Gate -- Last checkpoint before Store Pipeline.

Executes the CEO review via a pluggable ReviewProvider (default: HumanReviewProvider).
On NO-GO, translates CEO issues into tasks via DecisionAgent.
"""

from __future__ import annotations

from factory.evolution_loop.decision_agent import DecisionAgent
from factory.evolution_loop.gates.human_review_provider import HumanReviewProvider
from factory.evolution_loop.gates.review_provider import ReviewProvider
from factory.evolution_loop.ldo.schema import LoopDataObject

_PREFIX = "[EVO-CEO]"


class CEOReviewGate:
    """CEO Review Gate -- last checkpoint before Store."""

    AGENT_ID = "evo_ceo_review_gate"

    def __init__(self, review_provider: ReviewProvider | None = None) -> None:
        self.review_provider = review_provider or HumanReviewProvider()
        self._decision_agent = DecisionAgent()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def execute(self, ldo: LoopDataObject) -> LoopDataObject:
        """Execute CEO Review Gate.

        1. Call review_provider.review(ldo)
        2. Write result into ldo.ceo_feedback
        3. On no_go: translate issues into tasks via DecisionAgent
        """
        result = self.review_provider.review(ldo)

        # Write into LDO
        ldo.ceo_feedback.status = result.status
        ldo.ceo_feedback.issues = result.issues

        if result.status == "go":
            print(f"{_PREFIX} GO -- Ready for Store Pipeline")

        elif result.status == "no_go":
            n_issues = len(result.issues)
            # Translate CEO issues into tasks
            ldo = self._decision_agent.translate_ceo_feedback(ldo)
            ceo_tasks = [t for t in ldo.tasks if t.originated_from == "ceo_feedback"]
            print(f"{_PREFIX} NO-GO: {n_issues} issues -> {len(ceo_tasks)} tasks generated")

        else:
            print(f"{_PREFIX} Pending -- Waiting for CEO feedback")

        return ldo

    def get_review_brief(self, ldo: LoopDataObject) -> str:
        """Generate the review brief without executing the full gate."""
        return self.review_provider.generate_review_brief(ldo)
