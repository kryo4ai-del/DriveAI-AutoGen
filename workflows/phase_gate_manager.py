# phase_gate_manager.py
# Evaluates go/no-go conditions for each pipeline phase based on phase_gates.json.

import json
import os

_GATES_PATH = os.path.join(os.path.dirname(__file__), "phase_gates.json")

_DEFAULT_GATES = {
    "bug_review":     {"enabled": True, "min_messages": 1},
    "refactor":       {"enabled": True, "requires_bug_review_messages": 1},
    "test_generation":{"enabled": True, "requires_implementation_messages": 1},
    "fix_execution":  {"enabled": True, "requires_bug_or_refactor_messages": 1},
}


class PhaseGateManager:
    def __init__(self):
        self._gates = self.load_gates()

    def load_gates(self) -> dict:
        """Load phase_gates.json. Falls back to permissive defaults on failure."""
        try:
            with open(_GATES_PATH, encoding="utf-8") as f:
                data = json.load(f)
            if not isinstance(data, dict):
                return dict(_DEFAULT_GATES)
            # Merge with defaults so missing keys don't break evaluation
            merged = dict(_DEFAULT_GATES)
            merged.update(data)
            return merged
        except (FileNotFoundError, json.JSONDecodeError):
            return dict(_DEFAULT_GATES)

    def evaluate_gate(self, phase_name: str, context: dict) -> tuple[bool, str]:
        """
        Evaluate whether a phase should run.

        context keys:
          implementation_messages   : int
          bug_review_messages       : int
          refactor_messages         : int
          test_generation_messages  : int

        Returns (should_run: bool, reason: str).
        reason is empty when should_run is True.
        """
        gate = self._gates.get(phase_name, {})

        if not gate.get("enabled", True):
            return False, f"{phase_name} disabled in phase_gates.json"

        impl_msgs = context.get("implementation_messages", 0)
        bug_msgs = context.get("bug_review_messages", 0)
        refactor_msgs = context.get("refactor_messages", 0)

        if phase_name == "bug_review":
            min_msgs = gate.get("min_messages", 0)
            if impl_msgs < min_msgs:
                return False, f"implementation produced fewer than {min_msgs} message(s)"

        elif phase_name == "refactor":
            req = gate.get("requires_bug_review_messages", 0)
            if bug_msgs < req:
                return False, f"bug review produced fewer than {req} message(s)"

        elif phase_name == "test_generation":
            req = gate.get("requires_implementation_messages", 0)
            if impl_msgs < req:
                return False, f"implementation produced fewer than {req} message(s)"

        elif phase_name == "fix_execution":
            req = gate.get("requires_bug_or_refactor_messages", 0)
            combined = bug_msgs + refactor_msgs
            if combined < req:
                return False, "no review/refactor findings available"

        return True, ""

    def get_gate_summary(self, context: dict) -> str:
        """Return a human-readable summary of gate decisions for all phases."""
        phases = ["bug_review", "refactor", "test_generation", "fix_execution"]
        lines = []
        for phase in phases:
            should_run, reason = self.evaluate_gate(phase, context)
            status = "run" if should_run else f"skipped ({reason})"
            lines.append(f"  {phase}: {status}")
        return "\n".join(lines)
