"""Sound Prompt Builder — transforms SoundSpecs into optimal audio generation prompts.

Builds prompts tailored to each sound category (SFX, ambient, music, etc.)
with negative instructions from roadbook warnings. Output is a ServiceRequest
dict compatible with TheBrain Service Router.

Fully deterministic — no LLM calls, no API calls.
"""

import logging
from dataclasses import dataclass, asdict
from typing import Optional

logger = logging.getLogger(__name__)


@dataclass
class SoundPrompt:
    """Complete prompt package ready for audio generation."""
    sound_id: str
    sound_name: str
    category: str
    prompt_text: str
    negative_prompt: str
    duration_hint_ms: int
    service_request: dict
    estimated_cost: float

    def summary(self) -> str:
        return (f"{self.sound_id} ({self.sound_name}): "
                f"{self.category}, ~{self.duration_hint_ms}ms, "
                f"~${self.estimated_cost:.3f}, "
                f"{len(self.prompt_text)} chars")


class SoundPromptBuilder:
    """Builds optimized prompts from SoundSpecs."""

    TEMPLATES = {
        "sfx": (
            "{description}. {mood}. "
            "{duration_clause}"
            "{frequency_clause}"
            "{decay_clause}"
            "Clean isolated sound effect. "
            "{negative}"
        ),
        "ambient": (
            "{description}. Mood: {mood}. "
            "Atmospheric ambient sound, seamless loop, gradual evolution. "
            "{duration_clause}"
            "{negative}"
        ),
        "music": (
            "{description}. Style: {mood}. "
            "{bpm_clause}"
            "{duration_clause}"
            "Instrumental background music. "
            "{negative}"
        ),
        "ui_sound": (
            "{description}. {mood}. "
            "Ultra-short, clean, responsive UI sound. "
            "{duration_clause}"
            "{negative}"
        ),
        "notification": (
            "{description}. {mood}. "
            "Attention-grabbing but not alarming notification sound. "
            "{duration_clause}"
            "{negative}"
        ),
        "voice": (
            "{description}. Tone: {mood}. "
            "{duration_clause}"
            "{negative}"
        ),
    }

    DEFAULT_NEGATIVES = {
        "sfx": "No music, no voice, no background noise.",
        "ambient": "No sudden sounds, no voice, no percussion, no melody.",
        "music": "No vocals unless specified, no sound effects.",
        "ui_sound": "No reverb, no echo, no music, no voice. Maximum 500ms.",
        "notification": "No music, clean tone. Maximum 2 seconds.",
        "voice": "No background music, no effects, clean recording.",
    }

    DEFAULT_DURATIONS = {
        "sfx": 1500,
        "ambient": 30000,
        "music": 60000,
        "ui_sound": 300,
        "notification": 1000,
        "voice": 3000,
    }

    COST_ESTIMATES = {
        "sfx": 0.01,
        "ambient": 0.05,
        "music": 0.05,
        "ui_sound": 0.01,
        "notification": 0.01,
        "voice": 0.02,
    }

    CATEGORY_CAPABILITIES = {
        "sfx": ["text_to_sfx"],
        "ambient": ["text_to_sfx"],
        "music": ["text_to_music"],
        "ui_sound": ["text_to_sfx"],
        "notification": ["text_to_sfx"],
        "voice": ["text_to_sfx"],
    }

    # ElevenLabs max 22s, Suno max 240s
    MAX_DURATION_SFX = 22000
    MAX_DURATION_MUSIC = 240000

    def __init__(self):
        pass

    def build_prompt(self, spec, budget_limit: float = 0.05) -> SoundPrompt:
        """Build a complete SoundPrompt from a SoundSpec."""
        cat = spec.category if spec.category in self.TEMPLATES else "sfx"
        template = self.TEMPLATES[cat]

        duration_ms = self._get_duration_ms(spec)
        mood = spec.mood or "neutral"
        description = spec.description or spec.name.replace("_", " ")

        # Build clauses
        duration_clause = self._build_duration_clause(spec, duration_ms)
        frequency_clause = self._build_frequency_clause(spec)
        decay_clause = self._build_decay_clause(spec)
        bpm_clause = self._build_bpm_clause(spec)
        negative = self._build_negative_prompt(spec)

        # Fill template
        prompt = template.format(
            description=description,
            mood=mood,
            duration_clause=duration_clause,
            frequency_clause=frequency_clause,
            decay_clause=decay_clause,
            bpm_clause=bpm_clause,
            negative=negative,
        )

        # Clean up double spaces and trim
        prompt = " ".join(prompt.split())
        if len(prompt) > 500:
            prompt = prompt[:497] + "..."

        # Build service request
        service_request = self._build_service_request(prompt, spec, duration_ms, budget_limit)
        cost = self.COST_ESTIMATES.get(cat, 0.01)

        return SoundPrompt(
            sound_id=spec.sound_id,
            sound_name=spec.name,
            category=cat,
            prompt_text=prompt,
            negative_prompt=negative,
            duration_hint_ms=duration_ms,
            service_request=service_request,
            estimated_cost=cost,
        )

    def _build_duration_clause(self, spec, duration_ms: int) -> str:
        if duration_ms < 1000:
            return f"Duration: approximately {duration_ms}ms. "
        else:
            secs = round(duration_ms / 1000, 1)
            return f"Duration: approximately {secs} seconds. "

    def _build_frequency_clause(self, spec) -> str:
        tech = spec.technical_specs if isinstance(spec.technical_specs, dict) else {}
        freq = tech.get("frequency_hz")
        if freq is not None and str(freq).lower() not in ("none", "null", ""):
            freq_str = str(freq)
            # Handle descriptive values like "mid", "low", "high"
            descriptive = {"low": "low-frequency", "mid": "mid-range frequency", "high": "high-frequency"}
            if freq_str.lower() in descriptive:
                return f"{descriptive[freq_str.lower()].capitalize()} range. "
            try:
                f = int(float(freq_str))
                if f > 0:
                    return f"Base frequency around {f}Hz. "
            except (ValueError, TypeError):
                return f"Frequency: {freq_str}. "
        return ""

    def _build_decay_clause(self, spec) -> str:
        tech = spec.technical_specs if isinstance(spec.technical_specs, dict) else {}
        decay = tech.get("decay_type")
        if decay and str(decay).lower() not in ("none", "null", ""):
            return f"Sound should {decay} fade. "
        return ""

    def _build_bpm_clause(self, spec) -> str:
        tech = spec.technical_specs if isinstance(spec.technical_specs, dict) else {}
        bpm = tech.get("bpm")
        if bpm is not None and str(bpm).lower() not in ("none", "null", ""):
            bpm_str = str(bpm)
            # Handle ranges like "60-120"
            if "-" in bpm_str:
                return f"Tempo: {bpm_str} BPM. "
            try:
                b = int(float(bpm_str))
                if b > 0:
                    return f"Tempo: {b} BPM. "
            except (ValueError, TypeError):
                return f"Tempo: {bpm_str}. "
        return ""

    def _build_negative_prompt(self, spec) -> str:
        cat = spec.category if spec.category in self.DEFAULT_NEGATIVES else "sfx"
        parts = [self.DEFAULT_NEGATIVES[cat]]

        # Convert roadbook warnings to negatives
        warnings = spec.roadbook_warnings if isinstance(spec.roadbook_warnings, list) else []
        for w in warnings[:3]:  # Max 3 warnings to stay within limit
            text = str(w).lower()
            if "overdesign" in text or "überladen" in text:
                parts.append("Keep simple, avoid excessive layering.")
            elif "generisch" in text or "stock" in text:
                parts.append("Unique character, avoid generic stock-sound feel.")
            elif "laut" in text or "loud" in text:
                parts.append("Moderate volume, not aggressive.")
            elif "lang" in text or "long" in text:
                parts.append("Keep concise, avoid unnecessary length.")
            else:
                # Generic: extract key instruction
                clean = w.split(":", 1)[-1].strip() if ":" in str(w) else str(w)
                if len(clean) < 60:
                    parts.append(f"Avoid: {clean}")

        result = " ".join(parts)
        if len(result) > 200:
            result = result[:197] + "..."
        return result

    def _get_duration_ms(self, spec) -> int:
        tech = spec.technical_specs if isinstance(spec.technical_specs, dict) else {}
        dur = tech.get("duration_ms")
        if dur is not None:
            try:
                dur_int = int(float(str(dur)))
                if dur_int > 0:
                    return dur_int
            except (ValueError, TypeError):
                pass
        return self.DEFAULT_DURATIONS.get(spec.category, 1500)

    def _build_service_request(self, prompt_text: str, spec,
                                duration_ms: int, budget_limit: float) -> dict:
        cat = spec.category if spec.category in self.CATEGORY_CAPABILITIES else "sfx"
        capabilities = self.CATEGORY_CAPABILITIES[cat]

        # Clamp duration for service limits
        if cat in ("sfx", "ui_sound", "notification"):
            max_dur = self.MAX_DURATION_SFX
            out_format = "wav"
        else:
            max_dur = self.MAX_DURATION_MUSIC
            out_format = "mp3"

        clamped_ms = min(duration_ms, max_dur)
        duration_seconds = round(clamped_ms / 1000, 1)

        return {
            "category": "sound",
            "required_capabilities": capabilities,
            "specs": {
                "prompt": prompt_text,
                "duration_seconds": duration_seconds,
                "format": out_format,
            },
            "budget_limit": budget_limit,
            "preferred_service": None,
            "quality_minimum": 0.0,
        }

    def build_all_prompts(self, manifest, budget_limit: float = 0.05) -> list:
        """Build prompts for all sounds, sorted by priority (high first)."""
        priority_order = {"high": 0, "medium": 1, "low": 2}
        sorted_specs = sorted(manifest.specs,
                              key=lambda s: priority_order.get(s.priority, 1))

        prompts = []
        for spec in sorted_specs:
            try:
                p = self.build_prompt(spec, budget_limit)
                prompts.append(p)
            except Exception as e:
                logger.warning("Failed to build prompt for %s: %s", spec.sound_id, e)

        return prompts

    def dry_run(self, manifest, budget_limit: float = 0.05) -> str:
        """Build all prompts and return human-readable summary."""
        prompts = self.build_all_prompts(manifest, budget_limit)

        lines = []
        total_cost = 0.0
        max_prompt_len = 0

        for p in prompts:
            total_cost += p.estimated_cost
            max_prompt_len = max(max_prompt_len, len(p.prompt_text))

            lines.append("-" * 50)
            lines.append(f"{p.sound_id} {p.sound_name} ({p.category}, "
                         f"{next((s.priority for s in manifest.specs if s.sound_id == p.sound_id), '?')})")
            lines.append(f"  Prompt: {p.prompt_text[:200]}{'...' if len(p.prompt_text) > 200 else ''}")
            lines.append(f"  Negative: {p.negative_prompt[:100]}{'...' if len(p.negative_prompt) > 100 else ''}")
            lines.append(f"  Duration: {p.duration_hint_ms}ms, Format: {p.service_request['specs']['format']}, "
                         f"Est. Cost: ${p.estimated_cost:.3f}")

        lines.append("-" * 50)
        lines.append(f"\nTotal sounds: {len(prompts)}")
        lines.append(f"Estimated total cost: ${total_cost:.2f}")
        lines.append(f"Max prompt length: {max_prompt_len} chars")
        lines.append(f"All within 500 char limit: {'YES' if max_prompt_len <= 500 else 'NO'}")

        return "\n".join(lines)

    def estimate_total_cost(self, manifest) -> float:
        total = 0.0
        for s in manifest.specs:
            total += self.COST_ESTIMATES.get(s.category, 0.01)
        return round(total, 2)
