# memory_manager.py
# Persistent memory store for decisions and notes across agent runs.

import json
import os
from datetime import datetime

STORE_PATH = os.path.join(os.path.dirname(__file__), "memory_store.json")

DEFAULT_STRUCTURE = {
    "decisions": [],
    "architecture_notes": [],
    "implementation_notes": [],
    "review_notes": [],
}


class MemoryManager:
    def __init__(self):
        self.memory = self.load_memory()

    def load_memory(self) -> dict:
        try:
            with open(STORE_PATH, encoding="utf-8") as f:
                data = json.load(f)
            # Ensure all expected keys exist
            for key in DEFAULT_STRUCTURE:
                data.setdefault(key, [])
            return data
        except (FileNotFoundError, json.JSONDecodeError):
            return dict(DEFAULT_STRUCTURE)

    def save_memory(self, memory_data: dict | None = None) -> None:
        data = memory_data if memory_data is not None else self.memory
        with open(STORE_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    def _entry(self, note: str) -> dict:
        return {"timestamp": datetime.now().isoformat(), "note": note}

    def add_decision(self, note: str) -> None:
        self.memory["decisions"].append(self._entry(note))
        self.save_memory()

    def add_architecture_note(self, note: str) -> None:
        self.memory["architecture_notes"].append(self._entry(note))
        self.save_memory()

    def add_implementation_note(self, note: str) -> None:
        self.memory["implementation_notes"].append(self._entry(note))
        self.save_memory()

    def add_review_note(self, note: str) -> None:
        self.memory["review_notes"].append(self._entry(note))
        self.save_memory()

    def _is_duplicate(self, section: str, note: str) -> bool:
        existing = {e["note"] for e in self.memory.get(section, [])}
        return note in existing

    def _truncate(self, text: str, max_len: int = 200) -> str:
        return text[:max_len].rstrip() + "..." if len(text) > max_len else text

    def extract_memory_from_conversation(self, messages: list) -> dict[str, int]:
        """
        Scan agent messages and store heuristic-extracted notes.
        Returns count of entries added per section.
        """
        RULES = {
            "architecture_notes": ["architecture", "pattern", "structure", "mvvm", "folder", "module"],
            "implementation_notes": ["implemented", "code", "component", "view", "swift", "swiftui",
                                     "refactor", "simplify", "modular", "reusable", "rename",
                                     "extract", "clean up", "reduce duplication", "maintainability"],
            "review_notes": ["review", "improve", "issue", "problem", "feedback", "suggest",
                             "bug", "edge case", "failure", "weakness", "risk", "null", "crash",
                             "invalid", "fix", "test", "testcase", "scenario", "validation",
                             "expected result", "assertion", "failure case"],
            "decisions": ["decision", "choose", "approach", "decided", "recommend"],
        }

        counts = {k: 0 for k in RULES}

        for msg in messages:
            source = getattr(msg, "source", "")
            content = getattr(msg, "content", "")
            if not isinstance(content, str) or source in ("user", ""):
                continue

            content_lower = content.lower()

            for section, keywords in RULES.items():
                if not any(kw in content_lower for kw in keywords):
                    continue

                # Extract one summary sentence: first line with a matching keyword
                for line in content.splitlines():
                    line = line.strip().lstrip("- #*")
                    if len(line) < 20:
                        continue
                    if any(kw in line.lower() for kw in keywords):
                        note = self._truncate(f"[{source}] {line}")
                        if not self._is_duplicate(section, note):
                            self.memory[section].append(self._entry(note))
                            counts[section] += 1
                        break  # one note per message per section

        if any(counts.values()):
            self.save_memory()

        return counts

    def get_memory_summary(self, max_items_per_section: int = 5) -> str:
        sections = {
            "Decisions": self.memory.get("decisions", []),
            "Architecture Notes": self.memory.get("architecture_notes", []),
            "Implementation Notes": self.memory.get("implementation_notes", []),
            "Review Notes": self.memory.get("review_notes", []),
        }

        lines = []
        for section, entries in sections.items():
            latest = entries[-max_items_per_section:] if entries else []
            if latest:
                lines.append(f"### {section}")
                for e in latest:
                    ts = e.get("timestamp", "")[:10]
                    lines.append(f"- [{ts}] {e.get('note', '')}")
                lines.append("")

        return "\n".join(lines).strip() if lines else "(no memory entries yet)"
