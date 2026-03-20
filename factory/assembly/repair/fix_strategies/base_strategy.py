"""Base class for fix strategies."""
from abc import ABC, abstractmethod
from factory.assembly.repair.error_parser import CompilerError


class BaseFixStrategy(ABC):
    @abstractmethod
    def can_fix(self, error: CompilerError) -> bool: ...

    @abstractmethod
    def apply(self, error: CompilerError, **ctx) -> bool: ...
