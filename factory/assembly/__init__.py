"""Assembly department — builds apps from production output."""

from .assembly_manager import AssemblyManager
from .handoff_protocol import ProductionHandoff

__all__ = ["AssemblyManager", "ProductionHandoff"]
