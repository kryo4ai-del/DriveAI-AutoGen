"""CD Forge Interface -- maps CD Roadbook features to Forge requirements.

Reads the CD Roadbook and determines which Forges are needed for each feature,
what assets/sounds/animations/scenes each feature requires, and the correct
execution order (assets before code).
"""

import json
import logging
import os
import re
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from config.model_router import get_fallback_model

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[2]
BUILD_PLANS_DIR = Path(__file__).parent / "build_plans"


@dataclass
class ForgeRequirement:
    """What a single Forge needs to produce for a feature."""
    forge: str          # "asset_forge", "sound_forge", "motion_forge", "scene_forge"
    needed: bool
    items: list = field(default_factory=list)  # [{ref, type, description}]


@dataclass
class FeatureForgeMap:
    """Complete Forge requirement map for one feature."""
    feature_id: str
    feature_name: str
    description: str
    source_reference: str
    code_requirements: dict = field(default_factory=dict)
    forge_requirements: dict = field(default_factory=dict)
    dependencies: dict = field(default_factory=dict)


@dataclass
class ProjectForgeMap:
    """All features and their Forge requirements for a project."""
    project_name: str
    generated_at: str = ""
    total_features: int = 0
    features: list = field(default_factory=list)
    forge_summary: dict = field(default_factory=dict)

    def __post_init__(self):
        if not self.generated_at:
            self.generated_at = datetime.now(timezone.utc).isoformat()

    def to_json(self) -> str:
        data = {
            "project_name": self.project_name,
            "generated_at": self.generated_at,
            "total_features": self.total_features,
            "features": [asdict(f) if hasattr(f, "__dataclass_fields__") else f
                         for f in self.features],
            "forge_summary": self.forge_summary,
        }
        return json.dumps(data, indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "ProjectForgeMap":
        data = json.loads(json_str)
        raw_features = data.pop("features", [])
        features = []
        for f in raw_features:
            if isinstance(f, dict):
                features.append(FeatureForgeMap(**f))
            else:
                features.append(f)
        return cls(**data, features=features)

    def summary(self) -> str:
        lines = [
            f"Project Forge Map: {self.project_name}",
            f"Features: {self.total_features}",
            "",
            "Forge Requirements:",
        ]
        for forge, stats in self.forge_summary.items():
            lines.append(f"  {forge}: {stats.get('total_items', 0)} items")
        lines.append("")
        lines.append("Features:")
        for f in self.features:
            fr = f.forge_requirements if hasattr(f, "forge_requirements") else f.get("forge_requirements", {})
            forges_needed = [k for k, v in fr.items()
                            if (isinstance(v, dict) and v.get("needed"))
                            or (hasattr(v, "needed") and v.needed)]
            name = f.feature_name if hasattr(f, "feature_name") else f.get("feature_name", "?")
            fid = f.feature_id if hasattr(f, "feature_id") else f.get("feature_id", "?")
            lines.append(f"  {fid}: {name} -> {', '.join(forges_needed) or 'code only'}")
        return "\n".join(lines)


class CDForgeInterface:
    """Maps CD Roadbook features to Forge requirements."""

    def analyze(self, roadbook_dir: str, project_name: str) -> ProjectForgeMap:
        """Full analysis: read PDFs -> extract features -> map to Forges."""
        from factory.asset_forge.pdf_reader import PDFReader

        reader = PDFReader()
        pdf_dir = Path(roadbook_dir)
        if not pdf_dir.exists():
            raise FileNotFoundError(f"Roadbook dir not found: {roadbook_dir}")

        # Read all PDFs
        pdf_files = sorted(pdf_dir.glob("*.pdf"))
        if not pdf_files:
            raise ValueError(f"No PDFs found in {roadbook_dir}")

        all_text = []
        for pdf in pdf_files:
            try:
                doc = reader.read_pdf(str(pdf))
                text = doc.full_text if hasattr(doc, "full_text") else str(doc)
                all_text.append(f"--- {pdf.name} ---\n{text}")
            except Exception as e:
                logger.warning("PDF read error %s: %s", pdf.name, e)

        combined_text = "\n\n".join(all_text)
        logger.info("Read %d PDFs, %d chars total", len(pdf_files), len(combined_text))

        return self.analyze_from_text(combined_text, project_name)

    def analyze_from_text(self, roadbook_text: str, project_name: str) -> ProjectForgeMap:
        """Analyze from raw text."""
        # Truncate to fit context
        max_chars = 15000
        if len(roadbook_text) > max_chars:
            roadbook_text = roadbook_text[:max_chars] + "\n... (truncated)"

        raw_features = self._extract_features_via_llm(roadbook_text)

        features = []
        for rf in raw_features:
            feature = FeatureForgeMap(
                feature_id=rf.get("feature_id", f"F-{len(features)+1:03d}"),
                feature_name=rf.get("feature_name", "Unknown"),
                description=rf.get("description", ""),
                source_reference=rf.get("source_reference", ""),
                code_requirements=rf.get("code_requirements", {}),
                forge_requirements=rf.get("forge_requirements", {}),
                dependencies={},
            )
            feature.dependencies = self._set_dependencies(feature)
            features.append(feature)

        forge_summary = self._build_forge_summary(features)

        forge_map = ProjectForgeMap(
            project_name=project_name,
            total_features=len(features),
            features=features,
            forge_summary=forge_summary,
        )

        # Auto-save
        self.save(forge_map)

        logger.info("CD Forge Interface: %d features extracted for %s", len(features), project_name)
        return forge_map

    def _extract_features_via_llm(self, roadbook_text: str) -> list:
        """LLM call: Extract features and their Forge needs."""
        system = """You analyze CD Roadbooks and map each feature to its creative asset requirements.
For each feature, determine which Forges are needed:
- asset_forge: visual assets (sprites, icons, backgrounds, illustrations)
- sound_forge: audio (SFX, ambient, music, UI sounds)
- motion_forge: animations (transitions, micro-interactions, feedback)
- scene_forge: Unity scenes, levels, shaders, prefabs (only for Unity/game projects)

Return ONLY a JSON array. Each element:
{
  "feature_id": "F-001",
  "feature_name": "string",
  "description": "short description",
  "source_reference": "which PDF/section mentioned this",
  "code_requirements": {
    "lines_needed": ["ios", "android", "web"],
    "estimated_files": 5,
    "complexity": "low" | "medium" | "high"
  },
  "forge_requirements": {
    "asset_forge": {"needed": true/false, "items": [{"ref": "A-001", "type": "icon", "description": "..."}]},
    "sound_forge": {"needed": true/false, "items": [{"ref": "SFX-001", "type": "sfx", "description": "..."}]},
    "motion_forge": {"needed": true/false, "items": [{"ref": "MI-001", "type": "transition", "description": "..."}]},
    "scene_forge": {"needed": true/false, "items": [{"ref": "SCN-001", "type": "scene", "description": "..."}]}
  }
}

Keep descriptions SHORT (max 15 words each). Extract 5-15 features. For items arrays, include only the most important ones (max 5 per forge per feature)."""

        user = f"Analyze this CD Roadbook and extract all features with their Forge requirements:\n\n{roadbook_text}"

        response = self._call_llm(system, user, max_tokens=8192)
        return self._parse_json_response(response)

    def _build_forge_summary(self, features: list) -> dict:
        """Count total items per Forge across all features."""
        summary = {}
        for forge_name in ("asset_forge", "sound_forge", "motion_forge", "scene_forge"):
            total = 0
            features_needing = 0
            for f in features:
                fr = f.forge_requirements if hasattr(f, "forge_requirements") else {}
                forge_req = fr.get(forge_name, {})
                if isinstance(forge_req, dict) and forge_req.get("needed"):
                    features_needing += 1
                    total += len(forge_req.get("items", []))
            summary[forge_name] = {
                "total_items": total,
                "features_needing": features_needing,
            }
        return summary

    def _set_dependencies(self, feature: FeatureForgeMap) -> dict:
        """Determine execution order for this feature.

        Standard order:
        Group A: asset_forge + sound_forge + motion_forge (parallel)
        Group B: scene_forge (depends on A -- may need asset refs)
        Group C: integration (depends on B or A)
        Group D: code_generation (depends on C)
        """
        fr = feature.forge_requirements
        needs_a = any(
            isinstance(fr.get(f), dict) and fr[f].get("needed")
            for f in ("asset_forge", "sound_forge", "motion_forge")
        )
        needs_b = isinstance(fr.get("scene_forge"), dict) and fr["scene_forge"].get("needed")

        order = []
        if needs_a:
            order.append("A: asset_forge + sound_forge + motion_forge (parallel)")
        if needs_b:
            order.append("B: scene_forge" + (" (after A)" if needs_a else ""))
        if needs_a or needs_b:
            order.append("C: integration (copy forge outputs to project)")
        order.append("D: code_generation")

        reason = "standard forge-before-code pipeline"
        if not needs_a and not needs_b:
            reason = "code-only feature, no forges needed"

        return {"order": order, "reason": reason}

    def _call_llm(self, system: str, user: str, max_tokens: int = 8192) -> str:
        """TheBrain/Anthropic fallback."""
        try:
            from dotenv import load_dotenv
            load_dotenv(PROJECT_ROOT / ".env")
        except ImportError:
            pass

        # Try TheBrain first
        try:
            from factory.the_brain.brain import TheBrain
            brain = TheBrain()
            result = brain.call(
                agent_id="cd_forge_interface",
                task_type="code_generation",
                prompt=f"{system}\n\n{user}",
                max_tokens=max_tokens,
            )
            text = result.get("text", "")
            if text:
                return text
        except Exception as e:
            logger.debug("TheBrain fallback: %s", e)

        # Direct Anthropic
        import anthropic
        client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
        resp = client.messages.create(
            model=get_fallback_model(),
            max_tokens=max_tokens,
            system=system,
            messages=[{"role": "user", "content": user}],
        )
        return resp.content[0].text

    def _parse_json_response(self, raw: str) -> list:
        """Robust JSON parsing with repair."""
        text = raw.strip()

        # Remove markdown fences
        text = re.sub(r"```json\s*", "", text)
        text = re.sub(r"```\s*$", "", text)
        text = text.strip()

        # Try direct parse
        try:
            result = json.loads(text)
            return result if isinstance(result, list) else [result]
        except json.JSONDecodeError:
            pass

        # Find JSON array
        start = text.find("[")
        end = text.rfind("]")
        if start != -1 and end != -1 and end > start:
            try:
                result = json.loads(text[start:end + 1])
                return result if isinstance(result, list) else [result]
            except json.JSONDecodeError:
                pass

        # Repair truncated JSON
        if start != -1:
            fragment = text[start:]
            # Find last complete object
            last_complete = max(fragment.rfind("},"), fragment.rfind("}]"))
            if last_complete > 0:
                fragment = fragment[:last_complete + 1]
            # Close open brackets
            open_brackets = fragment.count("[") - fragment.count("]")
            open_braces = fragment.count("{") - fragment.count("}")
            fragment += "}" * max(0, open_braces)
            fragment += "]" * max(0, open_brackets)
            try:
                result = json.loads(fragment)
                return result if isinstance(result, list) else [result]
            except json.JSONDecodeError:
                pass

        logger.error("Failed to parse LLM response (%d chars)", len(raw))
        return []

    def save(self, forge_map: ProjectForgeMap, output_dir: str = None):
        """Save to factory/integration/build_plans/"""
        out = Path(output_dir) if output_dir else BUILD_PLANS_DIR
        out.mkdir(parents=True, exist_ok=True)
        path = out / f"{forge_map.project_name}_forge_requirements.json"
        path.write_text(forge_map.to_json(), encoding="utf-8")
        logger.info("Forge map saved: %s", path)
        return str(path)

    def load(self, path: str) -> ProjectForgeMap:
        """Load from JSON."""
        return ProjectForgeMap.from_json(Path(path).read_text(encoding="utf-8"))
