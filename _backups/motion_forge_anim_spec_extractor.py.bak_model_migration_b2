"""Animation Spec Extractor — reads CD Roadbook PDFs and extracts animation requirements.

Reuses PDFReader from Phase 8. Uses LLM for structured extraction.
"""

import json
import logging
import re
from dataclasses import dataclass, field, asdict
from pathlib import Path
from datetime import datetime

logger = logging.getLogger(__name__)

SPECS_DIR = Path(__file__).parent / "specs"


@dataclass
class AnimSpec:
    """Specification for a single animation."""
    anim_id: str
    name: str
    category: str       # micro_interaction, screen_transition, feedback, loading, ambient, branding
    type: str           # fade, scale, slide, pulse, rotate, color_shift, shimmer, custom
    description: str
    technical_specs: dict = field(default_factory=lambda: {
        "duration_ms": 300, "delay_ms": 0, "ease": "ease-out",
        "iterations": 1, "direction": "normal", "fill_mode": "forwards",
    })
    visual_specs: dict = field(default_factory=lambda: {
        "scale_from": 1.0, "scale_to": 1.0, "opacity_from": 1.0, "opacity_to": 1.0,
        "rotation_deg": 0, "translate_x": 0, "translate_y": 0, "color_shift": None,
    })
    complexity: str = "simple"          # simple, medium, complex, external
    generation_method: str = "template" # template, composition, custom_llm, external
    mood: str = ""
    context: str = ""
    priority: str = "medium"
    platform_targets: list = field(default_factory=lambda: ["ios", "android", "web", "unity"])
    source_reference: str = ""
    roadbook_warnings: list = field(default_factory=list)


@dataclass
class AnimManifest:
    """Summary of all animations extracted from a CD Roadbook."""
    project_name: str
    extraction_date: str
    total_animations: int
    by_category: dict = field(default_factory=dict)
    by_complexity: dict = field(default_factory=dict)
    by_priority: dict = field(default_factory=dict)
    specs: list = field(default_factory=list)

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "AnimManifest":
        data = json.loads(json_str)
        specs = [AnimSpec(**s) for s in data.pop("specs", [])]
        return cls(**data, specs=specs)

    def get_by_category(self, category: str) -> list:
        return [s for s in self.specs if s.category == category]

    def get_by_complexity(self, complexity: str) -> list:
        return [s for s in self.specs if s.complexity == complexity]

    def get_by_priority(self, priority: str) -> list:
        return [s for s in self.specs if s.priority == priority]

    def summary(self) -> str:
        lines = [
            f"Animation Manifest: {self.project_name}",
            f"Date: {self.extraction_date}",
            f"Total: {self.total_animations}",
            "", "By Category:",
        ]
        for c, n in sorted(self.by_category.items()):
            lines.append(f"  {c}: {n}")
        lines.append("\nBy Complexity:")
        for c, n in sorted(self.by_complexity.items()):
            lines.append(f"  {c}: {n}")
        lines.append("\nBy Priority:")
        for p, n in sorted(self.by_priority.items()):
            lines.append(f"  {p}: {n}")
        return "\n".join(lines)


# ── Patterns ──

ANIM_KEYWORDS = re.compile(
    r'(?i)(animation|transition|micro-interaction|MI-?\d+|fade|scale|pulse|slide|'
    r'rotate|shimmer|glow|bounce|ease|easing|keyframe|duration|timing|'
    r'parallax|transform|opacity|loading|spinner|skeleton|breathe|atmen|'
    r'partikel|particle|screen.?wechsel|uebergang|hover|press)',
)

MI_PATTERN = re.compile(r'MI-?\d+', re.IGNORECASE)

# Default timings per category
DEFAULT_TIMINGS = {
    "micro_interaction": {"duration_ms": 300, "ease": "ease-out"},
    "screen_transition": {"duration_ms": 600, "ease": "ease-in-out"},
    "feedback":          {"duration_ms": 400, "ease": "ease-out"},
    "loading":           {"duration_ms": 1500, "ease": "linear", "iterations": -1},
    "ambient":           {"duration_ms": 5000, "ease": "ease-in-out", "iterations": -1},
    "branding":          {"duration_ms": 800, "ease": "ease-out"},
}


class AnimSpecExtractor:
    """Extracts animation specifications from CD Roadbook PDFs."""

    def __init__(self):
        pass

    def extract(self, roadbook_dir: str, project_name: str) -> AnimManifest:
        """Full pipeline: PDFs → sections → LLM → manifest."""
        try:
            from factory.asset_forge.pdf_reader import PDFReader
        except ImportError:
            logger.error("PDFReader not available")
            return self._empty_manifest(project_name)

        reader = PDFReader()
        docs = reader.read_roadbook_dir(roadbook_dir)
        if not docs:
            return self._empty_manifest(project_name)

        cd_text = ""
        design_text = ""
        for key, doc in docs.items():
            if "cd" in key.lower() or "technical" in key.lower():
                cd_text = doc.full_text
            elif "design" in key.lower() or "vision" in key.lower():
                design_text = doc.full_text

        if not cd_text:
            largest = max(docs.values(), key=lambda d: d.total_chars)
            cd_text = largest.full_text

        return self.extract_from_text(cd_text, project_name, design_text)

    def extract_from_text(self, text: str, project_name: str,
                          style_text: str = None) -> AnimManifest:
        """Extract from raw text."""
        anim_sections = self._find_animation_sections(text)
        if not anim_sections:
            return self._empty_manifest(project_name)

        print(f"[AnimSpec] Found {len(anim_sections)} chars of animation content")

        raw = self._extract_anims_via_llm(anim_sections, style_text)
        if not raw:
            return self._empty_manifest(project_name)

        specs = []
        for d in raw:
            try:
                tech = d.get("technical_specs", {})
                if not isinstance(tech, dict):
                    tech = {}
                vis = d.get("visual_specs", {})
                if not isinstance(vis, dict):
                    vis = {}

                complexity = self._determine_complexity(d)
                method = {"simple": "template", "medium": "composition",
                          "complex": "custom_llm", "external": "external"}.get(complexity, "template")

                spec = AnimSpec(
                    anim_id=d.get("anim_id", f"AN-{len(specs)+1:03d}"),
                    name=d.get("name", "unknown"),
                    category=d.get("category", "micro_interaction"),
                    type=d.get("type", "custom"),
                    description=d.get("description", ""),
                    technical_specs={
                        "duration_ms": _safe_int(tech.get("duration_ms"), 300),
                        "delay_ms": _safe_int(tech.get("delay_ms"), 0),
                        "ease": str(tech.get("ease", "ease-out")),
                        "iterations": _safe_int(tech.get("iterations"), 1),
                        "direction": str(tech.get("direction", "normal")),
                        "fill_mode": str(tech.get("fill_mode", "forwards")),
                    },
                    visual_specs={
                        "scale_from": _safe_float(vis.get("scale_from"), 1.0),
                        "scale_to": _safe_float(vis.get("scale_to"), 1.0),
                        "opacity_from": _safe_float(vis.get("opacity_from"), 1.0),
                        "opacity_to": _safe_float(vis.get("opacity_to"), 1.0),
                        "rotation_deg": _safe_float(vis.get("rotation_deg"), 0),
                        "translate_x": _safe_int(vis.get("translate_x"), 0),
                        "translate_y": _safe_int(vis.get("translate_y"), 0),
                        "color_shift": vis.get("color_shift"),
                    },
                    complexity=complexity,
                    generation_method=method,
                    mood=d.get("mood", ""),
                    context=d.get("context", ""),
                    priority=d.get("priority", "medium"),
                    source_reference=d.get("source_reference", ""),
                )
                specs.append(spec)
            except Exception as e:
                logger.warning("Failed to parse anim spec: %s", e)

        # Apply default timings where missing
        specs = self._apply_default_timings(specs)

        manifest = self._build_manifest(specs, project_name)
        print(f"[AnimSpec] Extracted: {manifest.total_animations} animations")
        return manifest

    def _find_animation_sections(self, full_text: str) -> str:
        """Find all animation-related content."""
        chunks = []
        seen = set()
        lines = full_text.split("\n")

        # Strategy 1: Lines with animation keywords
        for i, line in enumerate(lines):
            if ANIM_KEYWORDS.search(line):
                start = max(0, i - 2)
                if start not in seen:
                    seen.add(start)
                    chunk = "\n".join(lines[max(0, i - 2):min(len(lines), i + 8)])
                    chunks.append(chunk)

        # Strategy 2: MI-XX tables
        for m in MI_PATTERN.finditer(full_text):
            pos = m.start()
            line_start = full_text.rfind("\n", 0, pos)
            line_end = full_text.find("\n", pos + 500)
            if line_end == -1:
                line_end = min(pos + 2000, len(full_text))
            chunks.append(full_text[max(0, line_start):line_end])

        # Strategy 3: Section headers about animations/transitions
        for m in re.finditer(r'(?im)^#+\s*(.*(?:animation|transition|micro|interaction|timing|motion|hapti).*)', full_text):
            chunks.append(full_text[m.start():m.start() + 3000])

        combined = "\n\n---\n\n".join(chunks)
        return combined[:15000] if len(combined) > 15000 else combined

    def _extract_anims_via_llm(self, text: str, style_text: str = None) -> list:
        """LLM call to extract structured animation specs."""
        system = (
            "You extract animation specifications from a CD Roadbook. "
            "Find EVERY animation, transition, micro-interaction, loading animation, "
            "feedback effect, and ambient motion mentioned.\n\n"
            "Return ONLY a JSON array. Each element:\n"
            "{\n"
            '  "anim_id": "MI-001" (MI for micro-interactions, ST for screen transitions, '
            'FB for feedback, LD for loading, AB for ambient, BR for branding),\n'
            '  "name": "snake_case_name",\n'
            '  "category": "micro_interaction|screen_transition|feedback|loading|ambient|branding",\n'
            '  "type": "fade|scale|slide|pulse|rotate|color_shift|shimmer|custom",\n'
            '  "description": "what the animation does",\n'
            '  "technical_specs": {"duration_ms": 300, "delay_ms": 0, "ease": "ease-out", '
            '"iterations": 1, "direction": "normal", "fill_mode": "forwards"},\n'
            '  "visual_specs": {"scale_from": 1.0, "scale_to": 1.2, "opacity_from": 0, '
            '"opacity_to": 1.0, "rotation_deg": 0, "translate_x": 0, "translate_y": 0, '
            '"color_shift": null},\n'
            '  "complexity": "simple|medium|complex|external",\n'
            '  "mood": "emotional quality",\n'
            '  "context": "when/where this plays",\n'
            '  "priority": "high|medium|low",\n'
            '  "source_reference": "where found"\n'
            "}"
        )

        user = f"Extract ALL animation specs from this CD Roadbook content:\n\n{text}"
        if style_text:
            user += f"\n\nAnimation guidelines from Design Vision:\n{style_text[:2000]}"

        response = self._call_llm(system, user)
        return self._parse_json_response(response)

    def _determine_complexity(self, d: dict) -> str:
        """Auto-classify complexity."""
        explicit = d.get("complexity", "")
        if explicit in ("simple", "medium", "complex", "external"):
            return explicit

        # Count animated properties
        vis = d.get("visual_specs", {})
        if not isinstance(vis, dict):
            return "simple"

        props_animated = 0
        if vis.get("scale_from", 1.0) != vis.get("scale_to", 1.0):
            props_animated += 1
        if vis.get("opacity_from", 1.0) != vis.get("opacity_to", 1.0):
            props_animated += 1
        if vis.get("rotation_deg", 0) != 0:
            props_animated += 1
        if vis.get("translate_x", 0) != 0 or vis.get("translate_y", 0) != 0:
            props_animated += 1
        if vis.get("color_shift"):
            props_animated += 1

        anim_type = d.get("type", "")
        if anim_type in ("custom", "shimmer"):
            return "complex"
        if props_animated <= 1:
            return "simple"
        if props_animated <= 3:
            return "medium"
        return "complex"

    def _apply_default_timings(self, specs: list) -> list:
        """Fill in missing timing defaults per category."""
        for spec in specs:
            defaults = DEFAULT_TIMINGS.get(spec.category, DEFAULT_TIMINGS["micro_interaction"])
            tech = spec.technical_specs
            if not tech.get("duration_ms") or tech["duration_ms"] <= 0:
                tech["duration_ms"] = defaults["duration_ms"]
            if not tech.get("ease"):
                tech["ease"] = defaults.get("ease", "ease-out")
            if spec.category in ("loading", "ambient") and tech.get("iterations", 1) == 1:
                tech["iterations"] = defaults.get("iterations", -1)
        return specs

    def _build_manifest(self, specs: list, project_name: str) -> AnimManifest:
        by_cat, by_comp, by_pri = {}, {}, {}
        for s in specs:
            by_cat[s.category] = by_cat.get(s.category, 0) + 1
            by_comp[s.complexity] = by_comp.get(s.complexity, 0) + 1
            by_pri[s.priority] = by_pri.get(s.priority, 0) + 1

        return AnimManifest(
            project_name=project_name,
            extraction_date=datetime.now().strftime("%Y-%m-%d"),
            total_animations=len(specs),
            by_category=by_cat, by_complexity=by_comp, by_priority=by_pri,
            specs=specs,
        )

    def _empty_manifest(self, project_name: str) -> AnimManifest:
        return AnimManifest(project_name=project_name, extraction_date=datetime.now().strftime("%Y-%m-%d"),
                            total_animations=0)

    def _call_llm(self, system_prompt: str, user_prompt: str, max_tokens: int = 4096) -> str:
        from dotenv import load_dotenv
        load_dotenv()
        try:
            from factory.brain.model_provider import get_model, get_router
            selection = get_model(profile="standard", expected_output_tokens=max_tokens)
            router = get_router()
            messages = [{"role": "system", "content": system_prompt}, {"role": "user", "content": user_prompt}]
            response = router.call(model_id=selection["model"], provider=selection["provider"],
                                   messages=messages, max_tokens=max_tokens)
            if response.error:
                raise RuntimeError(response.error)
            cost_str = f" ${response.cost_usd:.4f}" if response.cost_usd else ""
            print(f"[AnimSpec] LLM: {selection['model']}{cost_str}")
            return response.content
        except Exception as e:
            print(f"[AnimSpec] TheBrain failed ({e}), trying Anthropic")
            try:
                import anthropic
                client = anthropic.Anthropic()
                resp = client.messages.create(model="claude-sonnet-4-6", max_tokens=max_tokens,
                                              messages=[{"role": "user", "content": f"{system_prompt}\n\n{user_prompt}"}])
                return resp.content[0].text
            except Exception as e2:
                print(f"[AnimSpec] Fallback failed: {e2}")
                return "[]"

    def _parse_json_response(self, response: str) -> list:
        text = response.strip()
        if text.startswith("```"):
            text = text.split("\n", 1)[1] if "\n" in text else text[3:]
        if text.endswith("```"):
            text = text.rsplit("```", 1)[0]
        text = text.strip()
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass
        start = text.find("[")
        end = text.rfind("]")
        if start != -1 and end > start:
            try:
                return json.loads(text[start:end + 1])
            except json.JSONDecodeError:
                fixed = re.sub(r',\s*([}\]])', r'\1', text[start:end + 1])
                try:
                    return json.loads(fixed)
                except json.JSONDecodeError:
                    pass
        logger.error("Failed to parse JSON from LLM response")
        return []

    def save_manifest(self, manifest: AnimManifest, output_dir: str = None):
        out = Path(output_dir) if output_dir else SPECS_DIR
        out.mkdir(parents=True, exist_ok=True)
        path = out / f"{manifest.project_name}_anim_specs.json"
        path.write_text(manifest.to_json(), encoding="utf-8")
        print(f"[AnimSpec] Saved: {path}")

    def load_manifest(self, path: str) -> AnimManifest:
        return AnimManifest.from_json(Path(path).read_text(encoding="utf-8"))


def _safe_int(val, default: int = 0) -> int:
    if val is None:
        return default
    try:
        return int(float(str(val)))
    except (ValueError, TypeError):
        return default


def _safe_float(val, default: float = 0.0) -> float:
    if val is None:
        return default
    try:
        return float(str(val))
    except (ValueError, TypeError):
        return default
