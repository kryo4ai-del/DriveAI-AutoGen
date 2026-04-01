"""Name Gate Department -- Pre-Pipeline Name Validation (NGO-01).

Validates project names for availability across domains, app stores,
social media, trademark registries, brand fit, and ASO before any
project folders are created or the Swarm Pipeline starts.
"""

from factory.name_gate.orchestrator import NameGateOrchestrator, run_name_gate
from factory.name_gate.models import NameGateReport

__all__ = [
    "NameGateOrchestrator",
    "NameGateReport",
    "run_name_gate",
]
