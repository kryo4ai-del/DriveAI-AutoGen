"""Evolution Loop — Adapters Module."""

from .orchestrator_handoff import OrchestratorHandoff
from .qa_to_ldo_adapter import QAToLDOAdapter

__all__ = ["OrchestratorHandoff", "QAToLDOAdapter"]
