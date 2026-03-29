"""Scene Spec Extractor -- extracts level/scene/shader/prefab specs from CD Roadbook.

Reads PDFs from the roadbook directory, finds scene-relevant sections,
and uses a single LLM call to extract all 4 spec types.
"""

import json
import logging
import re
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from config.model_router import get_fallback_model

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Dataclasses
# ---------------------------------------------------------------------------

@dataclass
class LevelSpec:
    spec_id: str
    name: str
    game_type: str  # match3, puzzle, platformer
    grid: dict  # {width, height, cell_size}
    stone_types: int
    obstacles: list = field(default_factory=list)
    special_mechanics: list = field(default_factory=list)
    difficulty: float = 0.5
    move_limit: int = 30
    target: dict = field(default_factory=lambda: {"type": "score", "value": 1000})
    context: str = ""
    source_reference: str = ""
    priority: int = 1


@dataclass
class SceneSpec:
    spec_id: str
    name: str
    screen_type: str  # ui, game, loading, transition
    required_elements: list = field(default_factory=list)
    background: str = ""
    animations_needed: list = field(default_factory=list)
    sounds_needed: list = field(default_factory=list)
    source_reference: str = ""
    priority: int = 1


@dataclass
class ShaderSpec:
    spec_id: str
    name: str
    pipeline: str = "URP"
    effect_type: str = "custom"  # bloom_emission, dissolve, unlit, custom
    description: str = ""
    parameters: dict = field(default_factory=dict)
    performance_budget: dict = field(default_factory=dict)
    source_reference: str = ""
    priority: int = 1


@dataclass
class PrefabSpec:
    spec_id: str
    name: str
    root_type: str = "GameObject"
    components: list = field(default_factory=list)  # [{type, config}]
    children: list = field(default_factory=list)  # [{name, components}]
    source_reference: str = ""
    priority: int = 1


@dataclass
class SceneManifest:
    project_name: str
    extraction_date: str = ""
    levels: list = field(default_factory=list)
    scenes: list = field(default_factory=list)
    shaders: list = field(default_factory=list)
    prefabs: list = field(default_factory=list)

    def __post_init__(self):
        if not self.extraction_date:
            self.extraction_date = datetime.now(timezone.utc).isoformat()

    def to_json(self) -> str:
        data = {
            "project_name": self.project_name,
            "extraction_date": self.extraction_date,
            "levels": [asdict(s) if hasattr(s, "__dataclass_fields__") else s for s in self.levels],
            "scenes": [asdict(s) if hasattr(s, "__dataclass_fields__") else s for s in self.scenes],
            "shaders": [asdict(s) if hasattr(s, "__dataclass_fields__") else s for s in self.shaders],
            "prefabs": [asdict(s) if hasattr(s, "__dataclass_fields__") else s for s in self.prefabs],
        }
        return json.dumps(data, indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "SceneManifest":
        data = json.loads(json_str)
        manifest = cls(
            project_name=data["project_name"],
            extraction_date=data.get("extraction_date", ""),
        )
        manifest.levels = [LevelSpec(**s) for s in data.get("levels", [])]
        manifest.scenes = [SceneSpec(**s) for s in data.get("scenes", [])]
        manifest.shaders = [ShaderSpec(**s) for s in data.get("shaders", [])]
        manifest.prefabs = [PrefabSpec(**s) for s in data.get("prefabs", [])]
        return manifest

    def summary(self) -> str:
        lines = [
            f"Scene Manifest: {self.project_name}",
            f"  Extracted: {self.extraction_date}",
            f"  Levels:  {len(self.levels)}",
            f"  Scenes:  {len(self.scenes)}",
            f"  Shaders: {len(self.shaders)}",
            f"  Prefabs: {len(self.prefabs)}",
            f"  Total:   {len(self.levels) + len(self.scenes) + len(self.shaders) + len(self.prefabs)} specs",
        ]
        return "\n".join(lines)


# ---------------------------------------------------------------------------
# Scene keywords for section detection
# ---------------------------------------------------------------------------

SCENE_KEYWORDS = [
    "gameplay mechanics", "screen architecture", "visual effects",
    "level design", "performance budget", "grid specification",
    "stone type", "gem type", "obstacle", "post-processing",
    "match-3", "match3", "puzzle", "board", "game board",
    "shader", "bloom", "emission", "dissolve", "glow",
    "prefab", "component", "game object", "scene",
    "splash", "main menu", "settings", "reward",
    "difficulty", "move limit", "time limit", "tutorial",
    "URP", "universal render pipeline", "camera", "lighting",
]


# ---------------------------------------------------------------------------
# Extractor
# ---------------------------------------------------------------------------

class SceneSpecExtractor:
    """Extracts scene/level/shader/prefab specs from CD Roadbook PDFs."""

    SPECS_DIR = Path(__file__).parent / "specs"

    def __init__(self):
        self.SPECS_DIR.mkdir(parents=True, exist_ok=True)

    def extract(self, roadbook_dir: str, project_name: str = "project") -> SceneManifest:
        """Main extraction pipeline: read PDFs -> find sections -> LLM extract."""
        from factory.asset_forge.pdf_reader import PDFReader

        roadbook_path = Path(roadbook_dir)
        reader = PDFReader()

        # Read all PDFs
        all_text = ""
        style_text = ""
        pdf_files = sorted(roadbook_path.glob("*.pdf"))
        logger.info("Found %d PDFs in %s", len(pdf_files), roadbook_dir)

        for pdf in pdf_files:
            doc = reader.read_pdf(str(pdf))
            text = doc.full_text if hasattr(doc, "full_text") else str(doc)
            fname = pdf.name.lower()
            if "design" in fname or "visual" in fname or "style" in fname:
                style_text += text + "\n\n"
            all_text += f"\n\n=== {pdf.name} ===\n\n{text}"

        if not all_text.strip():
            logger.warning("No text extracted from PDFs")
            return SceneManifest(project_name=project_name)

        # Find scene-relevant sections
        scene_text = self._find_scene_sections(all_text)
        logger.info("Scene-relevant text: %d chars (from %d total)", len(scene_text), len(all_text))

        # LLM extraction
        raw = self._extract_specs_via_llm(scene_text, style_text or None)

        # Build manifest
        manifest = SceneManifest(project_name=project_name)
        manifest.levels = [LevelSpec(**s) for s in raw.get("levels", [])]
        manifest.scenes = [SceneSpec(**s) for s in raw.get("scenes", [])]
        manifest.shaders = [ShaderSpec(**s) for s in raw.get("shaders", [])]
        manifest.prefabs = [PrefabSpec(**s) for s in raw.get("prefabs", [])]

        logger.info("Extraction complete: %s", manifest.summary())
        return manifest

    def _find_scene_sections(self, full_text: str) -> str:
        """Extract paragraphs containing scene-relevant keywords."""
        paragraphs = re.split(r"\n\s*\n", full_text)
        relevant = []
        for para in paragraphs:
            lower = para.lower()
            if any(kw in lower for kw in SCENE_KEYWORDS):
                relevant.append(para.strip())

        result = "\n\n".join(relevant)
        # Cap at ~15000 chars for LLM context
        if len(result) > 15000:
            result = result[:15000]
        return result

    def _extract_specs_via_llm(self, text: str, style_text: str = None) -> dict:
        """Single LLM call to extract all 4 spec types."""
        style_block = ""
        if style_text:
            style_block = f"\n\nDESIGN/STYLE CONTEXT:\n{style_text[:2000]}"

        prompt = f"""Extract Unity game specs from this document. Return COMPACT JSON.

DOCUMENT:
{text[:10000]}
{style_block}

Return JSON: {{"levels": [...], "scenes": [...], "shaders": [...], "prefabs": [...]}}

LEVEL format: {{"spec_id": "LVL-001", "name": "...", "game_type": "match3", "grid": {{"width": 7, "height": 9, "cell_size": 1.0}}, "stone_types": 4, "obstacles": [], "special_mechanics": [], "difficulty": 0.5, "move_limit": 30, "target": {{"type": "score", "value": 1000}}, "context": "...", "source_reference": "...", "priority": 1}}
SCENE format: {{"spec_id": "SCN-001", "name": "...", "screen_type": "ui|game|loading", "required_elements": [], "background": "...", "animations_needed": [], "sounds_needed": [], "source_reference": "...", "priority": 1}}
SHADER format: {{"spec_id": "SHD-001", "name": "...", "pipeline": "URP", "effect_type": "bloom_emission|dissolve|custom", "description": "...", "parameters": {{}}, "performance_budget": {{}}, "source_reference": "...", "priority": 1}}
PREFAB format: {{"spec_id": "PFB-001", "name": "...", "root_type": "GameObject", "components": [], "children": [], "source_reference": "...", "priority": 1}}

Keep descriptions SHORT (max 20 words each). Extract 3-5 levels, 4-6 scenes, 2-4 shaders, 3-5 prefabs.
Return ONLY the JSON object. No markdown, no explanation."""

        raw_json = self._call_llm(prompt)
        return self._parse_json_response(raw_json)

    def _call_llm(self, prompt: str) -> str:
        """Call LLM via TheBrain or direct Anthropic."""
        try:
            from factory.the_brain.brain import TheBrain
            brain = TheBrain()
            result = brain.call(
                agent_id="scene_spec_extractor",
                task_type="code_generation",
                prompt=prompt,
                max_tokens=8192,
            )
            return result.get("text", "")
        except Exception:
            import os
            from dotenv import load_dotenv
            load_dotenv(Path(__file__).resolve().parents[2] / ".env")
            import anthropic
            client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
            resp = client.messages.create(
                model=get_fallback_model(),
                max_tokens=8192,
                messages=[{"role": "user", "content": prompt}],
            )
            return resp.content[0].text

    def _parse_json_response(self, raw: str) -> dict:
        """Parse JSON from LLM response, handling markdown fences and truncation."""
        text = raw.strip()
        if text.startswith("```"):
            text = re.sub(r"^```\w*\n?", "", text)
            text = re.sub(r"\n?```$", "", text)

        try:
            return json.loads(text)
        except json.JSONDecodeError:
            # Try to find JSON object
            match = re.search(r"\{[\s\S]*\}", text)
            if match:
                try:
                    return json.loads(match.group())
                except json.JSONDecodeError:
                    pass

            # Try to repair truncated JSON by closing open brackets
            repaired = text
            open_braces = repaired.count("{") - repaired.count("}")
            open_brackets = repaired.count("[") - repaired.count("]")

            if open_braces > 0 or open_brackets > 0:
                # Truncate at last complete array element
                last_complete = max(repaired.rfind("},"), repaired.rfind("}]"))
                if last_complete > 0:
                    repaired = repaired[:last_complete + 1]
                # Close remaining open brackets/braces
                repaired += "]" * max(0, open_brackets)
                repaired += "}" * max(0, open_braces)
                # Recount after truncation
                open_braces = repaired.count("{") - repaired.count("}")
                open_brackets = repaired.count("[") - repaired.count("]")
                repaired += "]" * max(0, open_brackets)
                repaired += "}" * max(0, open_braces)
                try:
                    result = json.loads(repaired)
                    logger.info("Repaired truncated JSON successfully")
                    return result
                except json.JSONDecodeError:
                    pass

            logger.error("Failed to parse LLM JSON response")
            return {"levels": [], "scenes": [], "shaders": [], "prefabs": []}

    def save_manifest(self, manifest: SceneManifest, filename: str = None) -> str:
        """Save manifest to specs directory."""
        if not filename:
            filename = f"{manifest.project_name}_scene_specs.json"
        path = self.SPECS_DIR / filename
        path.write_text(manifest.to_json(), encoding="utf-8")
        logger.info("Manifest saved: %s", path)
        return str(path)

    def load_manifest(self, filename: str) -> SceneManifest:
        """Load manifest from specs directory."""
        path = self.SPECS_DIR / filename
        return SceneManifest.from_json(path.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import argparse
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    parser = argparse.ArgumentParser(description="Scene Spec Extractor")
    parser.add_argument("--roadbook-dir", required=True, help="Path to roadbook PDFs")
    parser.add_argument("--project", default="project", help="Project name")
    parser.add_argument("--output", help="Output filename")
    args = parser.parse_args()

    extractor = SceneSpecExtractor()
    manifest = extractor.extract(args.roadbook_dir, args.project)
    path = extractor.save_manifest(manifest, args.output)
    print(manifest.summary())
    print(f"\nSaved to: {path}")
