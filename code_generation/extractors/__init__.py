# code_generation/extractors — Platform-aware code extraction registry.

from code_generation.extractors.base import BaseCodeExtractor


def get_extractor(language: str) -> BaseCodeExtractor:
    """Get the appropriate code extractor for a language.

    Falls back to Swift for backward compatibility with unknown languages.
    """
    if language == "swift":
        from code_generation.extractors.swift_extractor import SwiftCodeExtractor
        return SwiftCodeExtractor()
    elif language == "kotlin":
        from code_generation.extractors.kotlin_extractor import KotlinCodeExtractor
        return KotlinCodeExtractor()
    elif language == "typescript":
        from code_generation.extractors.typescript_extractor import TypeScriptCodeExtractor
        return TypeScriptCodeExtractor()
    elif language == "python":
        from code_generation.extractors.python_extractor import PythonCodeExtractor
        return PythonCodeExtractor()
    else:
        # Fallback to Swift for backward compatibility
        from code_generation.extractors.swift_extractor import SwiftCodeExtractor
        return SwiftCodeExtractor()


__all__ = ["BaseCodeExtractor", "get_extractor"]
