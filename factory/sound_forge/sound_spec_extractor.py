"""Sound Spec Extractor — reads CD Roadbook PDFs and extracts audio requirements.

Reuses PDFReader from Phase 8 for PDF reading.
Uses LLM (Claude Sonnet) to parse free-form text into structured SoundSpecs.
"""

import json
import logging
import re
from dataclasses import dataclass, field, asdict
from pathlib import Path
from datetime import datetime
from config.model_router import get_fallback_model

logger = logging.getLogger(__name__)

SPECS_DIR = Path(__file__).parent / "specs"


@dataclass
class SoundSpec:
    """Specification for a single sound to be generated."""
    sound_id: str
    name: str
    category: str  # sfx, ambient, music, voice, ui_sound, notification
    description: str
    technical_specs: dict = field(default_factory=lambda: {
        "frequency_hz": None, "duration_ms": None, "decay_type": None,
        "layers": 1, "loop_seamless": False, "bpm": None,
    })
    mood: str = ""
    context: str = ""
    priority: str = "medium"
    platform_targets: list = field(default_factory=lambda: ["ios", "android", "unity"])
    source_reference: str = ""
    roadbook_warnings: list = field(default_factory=list)


@dataclass
class SoundManifest:
    """Summary of all sounds extracted from a CD Roadbook."""
    project_name: str
    extraction_date: str
    total_sounds: int
    by_category: dict
    by_priority: dict
    specs: list = field(default_factory=list)

    def to_json(self) -> str:
        data = asdict(self)
        return json.dumps(data, indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "SoundManifest":
        data = json.loads(json_str)
        specs = [SoundSpec(**s) for s in data.pop("specs", [])]
        return cls(**data, specs=specs)

    def get_by_category(self, category: str) -> list:
        return [s for s in self.specs if s.category == category]

    def get_by_priority(self, priority: str) -> list:
        return [s for s in self.specs if s.priority == priority]

    def summary(self) -> str:
        lines = [
            f"Sound Manifest: {self.project_name}",
            f"Date: {self.extraction_date}",
            f"Total Sounds: {self.total_sounds}",
            "", "By Category:",
        ]
        for c, n in sorted(self.by_category.items()):
            lines.append(f"  {c}: {n}")
        lines.append("\nBy Priority:")
        for p, n in sorted(self.by_priority.items()):
            lines.append(f"  {p}: {n}")
        return "\n".join(lines)


# ── Patterns for finding sound content ──

SOUND_KEYWORDS = re.compile(
    r'(?i)(sound|audio|ton|klang|musik|ambient|sfx|hapti[ck]|akustisch|'
    r'kristall|cascade|chime|ping|swoosh|click|beep|jingle|loop|'
    r'frequenz|dezibel|lautst|vibration|feedback.*audio|audio.*feedback)',
)

MI_PATTERN = re.compile(r'MI-?\d+', re.IGNORECASE)


class SoundSpecExtractor:
    """Extracts sound specifications from CD Roadbook PDFs."""

    def __init__(self):
        pass

    def extract(self, roadbook_dir: str, project_name: str) -> SoundManifest:
        """Full pipeline: read PDFs -> find sound sections -> LLM extraction -> manifest."""
        try:
            from factory.asset_forge.pdf_reader import PDFReader
        except ImportError:
            logger.error("PDFReader not available — install Phase 8 first")
            return self._empty_manifest(project_name)

        reader = PDFReader()
        docs = reader.read_roadbook_dir(roadbook_dir)

        if not docs:
            logger.warning("No PDFs found in %s", roadbook_dir)
            return self._empty_manifest(project_name)

        # Collect all text
        cd_text = ""
        design_text = ""
        for key, doc in docs.items():
            if "cd" in key.lower() or "technical" in key.lower():
                cd_text = doc.full_text
            elif "design" in key.lower() or "vision" in key.lower():
                design_text = doc.full_text

        # If no CD roadbook found, use the largest document
        if not cd_text:
            largest = max(docs.values(), key=lambda d: d.total_chars)
            cd_text = largest.full_text

        return self.extract_from_text(cd_text, project_name, design_text)

    def extract_from_text(self, text: str, project_name: str,
                          style_text: str = None) -> SoundManifest:
        """Extract from raw text."""
        # Find sound-related content
        sound_sections = self._find_sound_sections(text)
        if not sound_sections:
            logger.warning("No sound-related content found")
            return self._empty_manifest(project_name)

        print(f"[SoundSpec] Found {len(sound_sections)} chars of sound-related content")

        # LLM extraction
        raw_specs = self._extract_sounds_via_llm(sound_sections, style_text)
        if not raw_specs:
            logger.warning("LLM extraction returned 0 sounds")
            return self._empty_manifest(project_name)

        # Apply warnings
        raw_specs = self._apply_roadbook_warnings(raw_specs, text)

        # Convert to SoundSpec objects
        specs = []
        for d in raw_specs:
            try:
                tech = d.get("technical_specs", {})
                if isinstance(tech, str):
                    tech = {}
                spec = SoundSpec(
                    sound_id=d.get("sound_id", f"SND-{len(specs)+1:03d}"),
                    name=d.get("name", "unknown"),
                    category=d.get("category", "sfx"),
                    description=d.get("description", ""),
                    technical_specs={
                        "frequency_hz": tech.get("frequency_hz"),
                        "duration_ms": tech.get("duration_ms"),
                        "decay_type": tech.get("decay_type"),
                        "layers": tech.get("layers", 1),
                        "loop_seamless": tech.get("loop_seamless", False),
                        "bpm": tech.get("bpm"),
                    },
                    mood=d.get("mood", ""),
                    context=d.get("context", ""),
                    priority=d.get("priority", "medium"),
                    platform_targets=d.get("platform_targets", ["ios", "android", "unity"]),
                    source_reference=d.get("source_reference", ""),
                    roadbook_warnings=d.get("roadbook_warnings", []),
                )
                specs.append(spec)
            except Exception as e:
                logger.warning("Failed to parse sound spec: %s", e)

        manifest = self._build_manifest(specs, project_name)
        print(f"[SoundSpec] Extracted: {manifest.total_sounds} sounds")
        return manifest

    def _find_sound_sections(self, full_text: str) -> str:
        """Find all sound-related content in the full document text."""
        chunks = []
        seen_starts = set()
        lines = full_text.split("\n")

        # Strategy 1: Find paragraphs containing sound keywords
        for i, line in enumerate(lines):
            if SOUND_KEYWORDS.search(line):
                # Extract context: 3 lines before, 10 lines after
                start = max(0, i - 3)
                end = min(len(lines), i + 10)
                chunk_start = start
                if chunk_start not in seen_starts:
                    seen_starts.add(chunk_start)
                    chunk = "\n".join(lines[start:end])
                    chunks.append(chunk)

        # Strategy 2: Find MI-XX tables (micro-interactions often contain audio specs)
        for m in MI_PATTERN.finditer(full_text):
            pos = m.start()
            # Find the line
            line_start = full_text.rfind("\n", 0, pos)
            line_end = full_text.find("\n", pos + 500)
            if line_end == -1:
                line_end = min(pos + 2000, len(full_text))
            context = full_text[max(0, line_start):line_end]
            if context not in chunks:
                chunks.append(context)

        # Strategy 3: Find sections with audio-related headers
        audio_headers = re.finditer(
            r'(?im)^#+\s*(.*(?:audio|sound|hapti[ck]|sensorik|akustisch|sfx|ambient|musik).*)',
            full_text
        )
        for m in audio_headers:
            start = m.start()
            # Take up to 3000 chars after the header
            chunk = full_text[start:start + 3000]
            chunks.append(chunk)

        # Deduplicate and combine
        combined = "\n\n---\n\n".join(chunks)
        # Trim to reasonable size for LLM (max 15000 chars)
        if len(combined) > 15000:
            combined = combined[:15000]

        return combined

    def _extract_sounds_via_llm(self, sound_text: str, style_text: str = None) -> list:
        """LLM call: extract structured sound specs from text."""
        system = (
            "You extract audio/sound specifications from a CD Roadbook. "
            "Find EVERY sound, audio effect, music, or ambient requirement mentioned. "
            "Sources include: micro-interaction tables, feature descriptions, "
            "audio design guidelines, haptic+audio specifications.\n\n"
            "Return ONLY a JSON array. Each element:\n"
            "{\n"
            '  "sound_id": "SFX-001" (SFX for effects, AMB for ambient, MUS for music, UI for UI sounds, NOT for notifications),\n'
            '  "name": "snake_case_name",\n'
            '  "category": "sfx|ambient|music|voice|ui_sound|notification",\n'
            '  "description": "what the sound is",\n'
            '  "technical_specs": {"frequency_hz": null, "duration_ms": 1500, "decay_type": "exponential", "layers": 1, "loop_seamless": false, "bpm": null},\n'
            '  "mood": "emotional quality",\n'
            '  "context": "when this plays",\n'
            '  "priority": "high|medium|low",\n'
            '  "source_reference": "where found"\n'
            "}\n\n"
            "Duration hints: short=500ms, medium=1500ms, long=3000ms. "
            "Priority: high=core gameplay, medium=UI/feedback, low=nice-to-have."
        )

        user = f"Extract ALL audio requirements from this CD Roadbook content:\n\n{sound_text}"

        if style_text:
            # Add first 2000 chars of design vision for audio context
            user += f"\n\nAudio/sensory guidelines from Design Vision:\n{style_text[:2000]}"

        response = self._call_llm(system, user)
        return self._parse_json_response(response)

    def _apply_roadbook_warnings(self, specs: list, full_text: str) -> list:
        """Find and attach relevant roadbook warnings to sound specs."""
        # Find warnings mentioning audio/sound
        warnings = []
        for m in re.finditer(r'W(\d+)[:\s]+([^\n]+)', full_text):
            wid = f"W{m.group(1)}"
            text = m.group(2).strip()
            if SOUND_KEYWORDS.search(text):
                warnings.append((wid, text))

        if warnings:
            for spec in specs:
                # Attach all audio-related warnings to every spec
                spec["roadbook_warnings"] = [f"{wid}: {text}" for wid, text in warnings]

        return specs

    def _build_manifest(self, specs: list, project_name: str) -> SoundManifest:
        by_cat = {}
        by_pri = {}
        for s in specs:
            by_cat[s.category] = by_cat.get(s.category, 0) + 1
            by_pri[s.priority] = by_pri.get(s.priority, 0) + 1

        return SoundManifest(
            project_name=project_name,
            extraction_date=datetime.now().strftime("%Y-%m-%d"),
            total_sounds=len(specs),
            by_category=by_cat,
            by_priority=by_pri,
            specs=specs,
        )

    def _empty_manifest(self, project_name: str) -> SoundManifest:
        return SoundManifest(
            project_name=project_name,
            extraction_date=datetime.now().strftime("%Y-%m-%d"),
            total_sounds=0, by_category={}, by_priority={},
        )

    def _call_llm(self, system_prompt: str, user_prompt: str,
                   max_tokens: int = 4096) -> str:
        """LLM helper. TheBrain first, Anthropic fallback."""
        from dotenv import load_dotenv
        load_dotenv()

        try:
            from factory.brain.model_provider import get_model, get_router
            selection = get_model(profile="dev", expected_output_tokens=max_tokens)
            router = get_router()
            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ]
            response = router.call(
                model_id=selection["model"], provider=selection["provider"],
                messages=messages, max_tokens=max_tokens,
            )
            if response.error:
                raise RuntimeError(response.error)
            cost_str = f" ${response.cost_usd:.4f}" if response.cost_usd else ""
            print(f"[SoundSpec] LLM: {selection['model']}{cost_str}")
            return response.content
        except Exception as e:
            print(f"[SoundSpec] TheBrain failed ({e}), trying Anthropic fallback")
            try:
                import anthropic
                client = anthropic.Anthropic()
                resp = client.messages.create(
                    model=get_fallback_model(), max_tokens=max_tokens,
                    messages=[{"role": "user", "content": f"{system_prompt}\n\n{user_prompt}"}],
                )
                return resp.content[0].text
            except Exception as e2:
                print(f"[SoundSpec] Anthropic fallback failed: {e2}")
                return "[]"

    def _parse_json_response(self, response: str) -> list:
        """Parse JSON from LLM response."""
        text = response.strip()
        # Strip markdown fences
        if text.startswith("```"):
            text = text.split("\n", 1)[1] if "\n" in text else text[3:]
        if text.endswith("```"):
            text = text.rsplit("```", 1)[0]
        text = text.strip()

        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass

        # Find first [ and last ]
        start = text.find("[")
        end = text.rfind("]")
        if start != -1 and end != -1 and end > start:
            try:
                return json.loads(text[start:end + 1])
            except json.JSONDecodeError:
                # Try fixing trailing commas
                fixed = re.sub(r',\s*([}\]])', r'\1', text[start:end + 1])
                try:
                    return json.loads(fixed)
                except json.JSONDecodeError:
                    pass

        logger.error("Failed to parse JSON from LLM response")
        return []

    def save_manifest(self, manifest: SoundManifest, output_dir: str = None):
        out = Path(output_dir) if output_dir else SPECS_DIR
        out.mkdir(parents=True, exist_ok=True)
        path = out / f"{manifest.project_name}_sound_specs.json"
        path.write_text(manifest.to_json(), encoding="utf-8")
        print(f"[SoundSpec] Saved: {path}")
        return str(path)

    def load_manifest(self, path: str) -> SoundManifest:
        return SoundManifest.from_json(Path(path).read_text(encoding="utf-8"))
