# factory/brain/brain.py
# Cross-project knowledge store. Deterministic filtering and ranking — no LLM, no embeddings.

import json
import os
from datetime import datetime

_DEFAULT_KNOWLEDGE_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
    "factory_knowledge", "knowledge.json",
)

# Confidence ranking (higher = better)
_CONFIDENCE_RANK = {
    "proven": 4,
    "validated": 3,
    "hypothesis": 2,
    "disproven": 0,
}


class FactoryBrain:
    """Cross-project knowledge store. Reads from factory_knowledge/knowledge.json
    and provides filtered, ranked query results for any agent in any project."""

    def __init__(self, knowledge_path: str | None = None):
        self._path = knowledge_path or _DEFAULT_KNOWLEDGE_PATH
        self._entries: list[dict] = []
        self._load()

    def _load(self):
        try:
            with open(self._path, encoding="utf-8") as f:
                data = json.load(f)
            self._entries = data.get("entries", [])
        except (FileNotFoundError, json.JSONDecodeError):
            self._entries = []

    def _save(self):
        try:
            with open(self._path, encoding="utf-8") as f:
                data = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            data = {"version": "1.0", "entries": []}
        data["entries"] = self._entries
        with open(self._path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    def _rank_entry(self, entry: dict, platform: str | None, language: str | None) -> tuple:
        """Return a ranking tuple (higher = better). Used for sorting."""
        # Platform relevance: exact match > applicable_to > global
        e_platform = entry.get("platform")
        e_applicable = entry.get("applicable_to") or []
        if platform and e_platform == platform:
            platform_score = 3
        elif platform and platform in e_applicable:
            platform_score = 2
        elif e_platform is None:
            platform_score = 1
        else:
            platform_score = 0

        # Language relevance
        e_language = entry.get("language")
        if language and e_language == language:
            lang_score = 2
        elif e_language is None:
            lang_score = 1
        else:
            lang_score = 0

        confidence_score = _CONFIDENCE_RANK.get(entry.get("confidence", "hypothesis"), 1)
        validation_count = entry.get("validation_count", 0)

        return (platform_score, lang_score, confidence_score, validation_count)

    def query(self,
              agent_role: str | None = None,
              platform: str | None = None,
              language: str | None = None,
              entry_types: list[str] | None = None,
              tags: list[str] | None = None,
              min_confidence: str = "hypothesis",
              limit: int = 5) -> list[dict]:
        """Query knowledge entries with filters. Returns ranked list."""
        min_rank = _CONFIDENCE_RANK.get(min_confidence, 1)
        results = []

        for entry in self._entries:
            # Confidence filter
            conf = _CONFIDENCE_RANK.get(entry.get("confidence", "hypothesis"), 1)
            if conf < min_rank:
                continue

            # Exclude disproven
            if entry.get("confidence") == "disproven":
                continue

            # Type filter
            if entry_types and entry.get("type") not in entry_types:
                continue

            # Tag filter (any match)
            if tags:
                entry_tags = set(entry.get("tags", []))
                if not entry_tags.intersection(tags):
                    continue

            # Platform filter: include if exact match, in applicable_to, or global
            if platform:
                e_platform = entry.get("platform")
                e_applicable = entry.get("applicable_to") or []
                if e_platform is not None and e_platform != platform and platform not in e_applicable:
                    continue

            # Language filter: include if exact match or global
            if language:
                e_language = entry.get("language")
                if e_language is not None and e_language != language:
                    continue

            results.append(entry)

        # Rank
        results.sort(key=lambda e: self._rank_entry(e, platform, language), reverse=True)
        return results[:limit]

    def query_for_project(self, project_name: str, agent_role: str | None = None, limit: int = 5) -> list[dict]:
        """Query knowledge relevant for a specific project.
        Loads ProjectConfig to determine platform/language."""
        try:
            from factory.project_config import load_project_config
            config = load_project_config(project_name)
            active_lines = config.get_active_lines()
            platform = active_lines[0] if active_lines else None
            language = config.get_extraction_language()
        except Exception:
            platform = None
            language = None

        return self.query(
            agent_role=agent_role,
            platform=platform,
            language=language,
            limit=limit,
        )

    def format_knowledge_block(self, entries: list[dict], max_chars: int = 1500) -> str:
        """Format entries into a compact text block for agent injection."""
        if not entries:
            return ""
        lines = ["[Factory Knowledge]"]
        for entry in entries:
            entry_id = entry.get("id", "?")
            entry_type = entry.get("type", "unknown")
            title = entry.get("title", "")
            content = entry.get("description", entry.get("content", ""))
            lesson = entry.get("lesson", "")
            block = f"- [{entry_id}] ({entry_type}) {title}"
            if content:
                block += f"\n  {content[:200]}"
            if lesson:
                block += f"\n  Lesson: {lesson[:150]}"
            lines.append(block)
        result = "\n".join(lines)
        return result[:max_chars]

    def record_learning(self,
                        entry_type: str,
                        content: str,
                        source: str,
                        project: str | None = None,
                        platform: str | None = None,
                        language: str | None = None,
                        confidence: str = "hypothesis",
                        tags: list[str] | None = None) -> str:
        """Record a new learning. Returns the new entry ID."""
        # Determine next ID
        max_num = 0
        for e in self._entries:
            eid = e.get("id", "")
            if eid.startswith("FK-"):
                try:
                    num = int(eid[3:])
                    max_num = max(max_num, num)
                except ValueError:
                    pass
        new_id = f"FK-{max_num + 1:03d}"
        today = datetime.now().strftime("%Y-%m-%d")

        new_entry = {
            "id": new_id,
            "type": entry_type,
            "title": content[:80],
            "description": content,
            "source": source,
            "confidence": confidence,
            "project": project,
            "platform": platform,
            "language": language,
            "applicable_to": None,
            "tags": tags or [],
            "created": today,
            "last_validated": today,
            "validation_count": 1,
        }
        self._entries.append(new_entry)
        self._save()
        return new_id

    def validate_entry(self, entry_id: str) -> bool:
        """Mark an entry as re-validated."""
        for entry in self._entries:
            if entry.get("id") == entry_id:
                entry["validation_count"] = entry.get("validation_count", 0) + 1
                entry["last_validated"] = datetime.now().strftime("%Y-%m-%d")
                self._save()
                return True
        return False

    @property
    def stats(self) -> dict:
        """Return stats: total entries, by type, by platform, by confidence."""
        by_type: dict[str, int] = {}
        by_platform: dict[str, int] = {}
        by_confidence: dict[str, int] = {}

        for e in self._entries:
            t = e.get("type", "unknown")
            by_type[t] = by_type.get(t, 0) + 1

            p = e.get("platform") or "global"
            by_platform[p] = by_platform.get(p, 0) + 1

            c = e.get("confidence", "unknown")
            by_confidence[c] = by_confidence.get(c, 0) + 1

        return {
            "total": len(self._entries),
            "by_type": by_type,
            "by_platform": by_platform,
            "by_confidence": by_confidence,
        }
