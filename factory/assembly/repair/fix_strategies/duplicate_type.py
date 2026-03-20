"""Fix duplicate type declarations."""

from factory.assembly.repair.error_parser import CompilerError
from factory.assembly.repair.fix_strategies.base_strategy import BaseFixStrategy


class DuplicateTypeFixer(BaseFixStrategy):
    def can_fix(self, error: CompilerError) -> bool:
        return error.category == "duplicate_type"

    def apply(self, error: CompilerError, **ctx) -> bool:
        # Complex — needs project-wide analysis. Defer to StaleArtifactGuard.
        return False
