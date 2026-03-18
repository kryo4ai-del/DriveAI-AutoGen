# code_generation/extractors/base.py
# Abstract base class for language-specific code extractors.

from abc import ABC, abstractmethod


class BaseCodeExtractor(ABC):
    """Base class for language-specific code extractors."""

    @abstractmethod
    def extract_code(self, messages: list, project_name: str | None = None) -> dict:
        """Extract code from agent messages. Returns counts dict."""
        ...

    @abstractmethod
    def build_implementation_summary(self, user_task: str, template: str | None = None) -> str:
        """Build compact summary of extracted code for review passes."""
        ...

    @property
    @abstractmethod
    def language(self) -> str:
        """Return language identifier (e.g., 'swift', 'kotlin', 'typescript', 'python')."""
        ...

    @property
    @abstractmethod
    def file_extension(self) -> str:
        """Return file extension (e.g., '.swift', '.kt', '.tsx', '.py')."""
        ...
