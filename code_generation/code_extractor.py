# code_extractor.py
# Scans agent messages for Swift code blocks and saves them as .swift files.

import os
import re

GENERATED_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "generated_code")

SUBFOLDERS = {
    "View": "Views",
    "ViewModel": "ViewModels",
    "Service": "Services",
    "Model": "Models",
}

# Patterns to extract type name from Swift code
NAME_PATTERNS = [
    re.compile(r'\bstruct\s+(\w+)'),
    re.compile(r'\bclass\s+(\w+)'),
    re.compile(r'\benum\s+(\w+)'),
    re.compile(r'\bprotocol\s+(\w+)'),
]


def _detect_subfolder(name: str) -> str:
    for suffix, folder in SUBFOLDERS.items():
        if name.endswith(suffix):
            return folder
    return "Models"


def _extract_type_name(code: str) -> str | None:
    for pattern in NAME_PATTERNS:
        match = pattern.search(code)
        if match:
            return match.group(1)
    return None


def _file_unchanged(path: str, content: str) -> bool:
    try:
        with open(path, encoding="utf-8") as f:
            return f.read() == content
    except FileNotFoundError:
        return False


class CodeExtractor:
    def __init__(self):
        self._counter = 1

    def extract_swift_code(self, messages: list) -> dict[str, int]:
        """
        Scan agent messages, extract Swift code blocks, save as .swift files.
        Returns {"saved": n, "skipped": n} counts.
        """
        saved = 0
        skipped = 0

        for msg in messages:
            source = getattr(msg, "source", "")
            content = getattr(msg, "content", "")
            if not isinstance(content, str) or source in ("user", ""):
                continue

            blocks = re.findall(r"```swift\s*\n(.*?)```", content, re.DOTALL)
            for block in blocks:
                block = block.strip()
                if not block:
                    continue

                name = _extract_type_name(block)
                if name:
                    filename = f"{name}.swift"
                else:
                    filename = f"GeneratedFile_{self._counter}.swift"
                    self._counter += 1

                subfolder = _detect_subfolder(filename.replace(".swift", ""))
                dest_dir = os.path.join(GENERATED_DIR, subfolder)
                os.makedirs(dest_dir, exist_ok=True)
                dest_path = os.path.join(dest_dir, filename)

                if _file_unchanged(dest_path, block):
                    skipped += 1
                    continue

                with open(dest_path, "w", encoding="utf-8") as f:
                    f.write(block)
                saved += 1

        return {"saved": saved, "skipped": skipped}
