# code_generation/extractors/swift_extractor.py
# Wraps the existing CodeExtractor as a platform-aware extractor plugin.
# The battle-tested Swift extraction logic stays exactly as-is.

from code_generation.code_extractor import CodeExtractor
from code_generation.extractors.base import BaseCodeExtractor


class SwiftCodeExtractor(BaseCodeExtractor):
    """Swift code extractor — wraps the existing CodeExtractor."""

    def __init__(self):
        self._extractor = CodeExtractor()

    def extract_code(self, messages: list, project_name: str | None = None) -> dict:
        """Extract Swift code from agent messages."""
        return self._extractor.extract_swift_code(messages, project_name=project_name)

    def build_implementation_summary(self, user_task: str, template: str | None = None) -> str:
        """Build compact summary of extracted Swift code."""
        return self._extractor.build_implementation_summary(user_task, template)

    @property
    def language(self) -> str:
        return "swift"

    @property
    def file_extension(self) -> str:
        return ".swift"
