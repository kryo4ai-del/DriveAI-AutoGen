# code_generation/extractors/python_extractor.py
# Skeleton for Python/FastAPI code extraction.

from code_generation.extractors.base import BaseCodeExtractor


class PythonCodeExtractor(BaseCodeExtractor):
    """Python code extractor — skeleton, not yet implemented."""

    def extract_code(self, messages: list, project_name: str | None = None) -> dict:
        raise NotImplementedError("Python extraction not yet implemented")

    def build_implementation_summary(self, user_task: str, template: str | None = None) -> str:
        raise NotImplementedError("Python extraction not yet implemented")

    @property
    def language(self) -> str:
        return "python"

    @property
    def file_extension(self) -> str:
        return ".py"
