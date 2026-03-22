"""C# / Unity code extractor."""
import os
import re
from pathlib import Path
from .base import BaseCodeExtractor

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
GENERATED_DIR = str(_PROJECT_ROOT / "generated_code")

# C# code block indicators
_CSHARP_INDICATORS = [
    "using UnityEngine;", "using System;", "using System.Collections",
    "MonoBehaviour", "ScriptableObject", "public class ", "private void ",
    "[SerializeField]", "[Header(", "void Start()", "void Update()", "void Awake(",
    "IEnumerator", "async Task", "namespace ", "GetComponent<", "transform.",
    "gameObject.", "Instantiate(", "Destroy(", "StartCoroutine",
    "[RequireComponent", "using TMPro;", "using UnityEngine.UI;",
]

# Type declaration regex for C#
_CS_TYPE_RE = re.compile(
    r"^\s*(?:public\s+|private\s+|protected\s+|internal\s+)?"
    r"(?:abstract\s+|sealed\s+|static\s+|partial\s+)*"
    r"(class|struct|interface|enum)\s+"
    r"([A-Z][A-Za-z0-9_]+)",
    re.MULTILINE,
)

# Code fence patterns
_FENCE_RE = re.compile(r"```(?:csharp|cs|c#)?\s*\n(.*?)```", re.DOTALL)


class CSharpCodeExtractor(BaseCodeExtractor):
    """Extract C# code from agent messages."""

    @property
    def language(self) -> str:
        return "csharp"

    @property
    def file_extension(self) -> str:
        return ".cs"

    def extract_code(self, messages: list, project_name: str | None = None) -> dict:
        """Extract C# code blocks from messages, save as .cs files."""
        os.makedirs(GENERATED_DIR, exist_ok=True)

        # Collect code blocks
        blocks: list[tuple[str, str]] = []  # (code, detected_name)
        for msg in messages:
            content = getattr(msg, "content", None) or str(msg)
            if not isinstance(content, str):
                continue
            for match in _FENCE_RE.finditer(content):
                code = match.group(1).strip()
                if not code or len(code) < 20:
                    continue
                # Check if it's actually C#
                if not self._is_csharp(code, match.group(0)):
                    continue
                name = self._extract_name(code)
                blocks.append((code, name))

            # Also check untagged blocks that look like C#
            for match in re.finditer(r"```\s*\n(.*?)```", content, re.DOTALL):
                code = match.group(1).strip()
                if code in [b[0] for b in blocks]:
                    continue
                if self._is_csharp_content(code):
                    name = self._extract_name(code)
                    blocks.append((code, name))

        if not blocks:
            return {"saved": 0, "skipped": 0, "aborted": False}

        # Build project file index for dedup
        project_stems: set[str] = set()
        if project_name:
            proj_dir = _PROJECT_ROOT / "projects" / project_name
            if proj_dir.is_dir():
                for cs in proj_dir.rglob("*.cs"):
                    if "quarantine" not in str(cs) and "generated" not in str(cs):
                        project_stems.add(cs.stem)

        # Dedup: collect all names from this run
        seen_names: dict[str, str] = {}  # name -> code
        fallback_counter = 0
        saved = 0
        skipped = 0
        log_entries = []

        for code, name in blocks:
            if not name:
                fallback_counter += 1
                name = f"GeneratedScript_{fallback_counter}"

            if name in seen_names or name in project_stems:
                skipped += 1
                continue

            seen_names[name] = code
            subfolder = self._detect_subfolder(code, name)
            target_dir = os.path.join(GENERATED_DIR, subfolder)
            os.makedirs(target_dir, exist_ok=True)

            filepath = os.path.join(target_dir, f"{name}.cs")
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(code)
            saved += 1
            log_entries.append(f"  - {name}.cs")

        # Categorize for summary
        categories = {"Scripts": 0, "ScriptableObjects": 0, "Interfaces": 0,
                       "Enums": 0, "Models": 0, "Editor": 0, "Tests": 0, "Helpers": 0}
        for name, code in seen_names.items():
            sf = self._detect_subfolder(code, name)
            if "ScriptableObjects" in sf:
                categories["ScriptableObjects"] += 1
            elif "Interfaces" in sf:
                categories["Interfaces"] += 1
            elif "Enums" in sf:
                categories["Enums"] += 1
            elif "Editor" in sf:
                categories["Editor"] += 1
            elif "Tests" in sf:
                categories["Tests"] += 1
            elif "Models" in sf or "Data" in sf:
                categories["Models"] += 1
            else:
                categories["Scripts"] += 1

        # Print summary
        parts = [f"{v} {k}" for k, v in categories.items() if v > 0]
        if parts:
            print(f"C# files extracted:")
            for p in parts:
                print(f"  - {p}")

        return {"saved": saved, "skipped": skipped, "aborted": False}

    def build_implementation_summary(self, user_task: str, template: str | None = None) -> str:
        """Build compact summary of extracted C# code."""
        gen = Path(GENERATED_DIR)
        if not gen.exists():
            return ""
        files = list(gen.rglob("*.cs"))
        if not files:
            return ""
        lines = [f"Implementation for: {user_task}", f"Generated {len(files)} C# files:"]
        for f in sorted(files)[:30]:
            rel = f.relative_to(gen)
            size = f.stat().st_size
            lines.append(f"  {rel} ({size} bytes)")
        return "\n".join(lines)

    def _is_csharp(self, code: str, fence_line: str) -> bool:
        """Check if a code block is C# based on fence tag."""
        tag = fence_line.split("\n")[0].strip("`").strip().lower()
        if tag in ("csharp", "cs", "c#"):
            return True
        if not tag:
            return self._is_csharp_content(code)
        return False

    def _is_csharp_content(self, code: str) -> bool:
        """Check if untagged code block contains C# patterns."""
        score = sum(1 for ind in _CSHARP_INDICATORS if ind in code)
        return score >= 2

    def _extract_name(self, code: str) -> str:
        """Extract primary type name from C# code."""
        for m in _CS_TYPE_RE.finditer(code):
            name = m.group(2)
            if name[0].isupper() and len(name) > 1:
                return name
        return ""

    def _detect_subfolder(self, code: str, filename: str) -> str:
        """Route C# file to correct subfolder."""
        if "using UnityEditor" in code:
            return "Editor"
        if "using NUnit" in code or "[Test]" in code or "[UnityTest]" in code:
            return "Tests"
        if "[CreateAssetMenu" in code or ": ScriptableObject" in code:
            return "Scripts/ScriptableObjects"
        if filename.startswith("I") and filename[1].isupper() and "interface " in code:
            return "Scripts/Interfaces"
        if "enum " in code and "class " not in code:
            return "Scripts/Enums"
        if ": MonoBehaviour" in code:
            return "Scripts"
        if "static class" in code or "Utility" in filename or "Helper" in filename:
            return "Scripts/Utilities"
        # POCO / data model
        if "class " in code and ": MonoBehaviour" not in code:
            return "Scripts/Models"
        return "Scripts"
