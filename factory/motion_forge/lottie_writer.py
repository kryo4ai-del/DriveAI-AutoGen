"""Lottie Writer — generates Lottie JSON animations in 4 modes.

Mode A (Template): Load template, set parameters. $0 cost.
Mode B (Composition): Combine templates. $0 cost.
Mode C (Custom LLM): Claude generates Lottie JSON. ~$0.01-0.03.
Mode D (External): Marked as needs_manual.
"""

import copy
import json
import logging
from dataclasses import dataclass, field
from pathlib import Path
from config.model_router import get_fallback_model

logger = logging.getLogger(__name__)


@dataclass
class LottieResult:
    anim_id: str
    success: bool
    lottie_json: dict = field(default_factory=dict)
    file_path: str = ""
    generation_method: str = ""
    cost: float = 0.0
    file_size_bytes: int = 0
    duration_ms: int = 0
    error: str = ""

    def summary(self) -> str:
        if self.success:
            return (f"OK {self.anim_id}: {self.generation_method}, "
                    f"{self.duration_ms}ms, {self.file_size_bytes / 1024:.1f}KB, ${self.cost:.3f}")
        return f"FAIL {self.anim_id}: {self.error}"


class LottieWriter:
    """Generates Lottie JSON animations."""

    TEMPLATE_DIR = Path(__file__).parent / "templates"
    OUTPUT_DIR = Path(__file__).parent / "generated"
    FRAMERATE = 60
    MAX_FILE_SIZE = 500 * 1024

    TYPE_TO_TEMPLATE = {
        "fade": "fade_in", "fade_in": "fade_in", "fade_out": "fade_out",
        "scale": "scale_in", "scale_in": "scale_in", "scale_bounce": "scale_bounce",
        "pulse": "pulse", "slide": "slide_up", "slide_up": "slide_up",
        "slide_down": "slide_down", "slide_left": "slide_left", "slide_right": "slide_right",
        "rotate": "rotate_in", "rotate_in": "rotate_in",
        "color_shift": "color_shift", "shimmer": "shimmer",
    }

    EASE_CURVES = {
        "linear":      {"i": {"x": [1], "y": [1]}, "o": {"x": [0], "y": [0]}},
        "ease-in":     {"i": {"x": [0.42], "y": [0]}, "o": {"x": [1], "y": [1]}},
        "ease-out":    {"i": {"x": [0], "y": [0]}, "o": {"x": [0.58], "y": [1]}},
        "ease-in-out": {"i": {"x": [0.42], "y": [0]}, "o": {"x": [0.58], "y": [1]}},
        "bounce":      {"i": {"x": [0.175], "y": [0.885]}, "o": {"x": [0.32], "y": [1.275]}},
    }

    def __init__(self, template_dir: str = None, output_dir: str = None):
        if template_dir:
            self.TEMPLATE_DIR = Path(template_dir)
        if output_dir:
            self.OUTPUT_DIR = Path(output_dir)
        self.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        self._templates = self._load_templates()

    def _load_templates(self) -> dict:
        templates = {}
        if not self.TEMPLATE_DIR.exists():
            return templates
        for f in self.TEMPLATE_DIR.glob("*.json"):
            try:
                data = json.loads(f.read_text(encoding="utf-8"))
                name = data.get("__template_meta", {}).get("name", f.stem)
                templates[name] = data
            except Exception as e:
                logger.warning("Failed to load template %s: %s", f.name, e)
        return templates

    def generate(self, anim_spec) -> LottieResult:
        """Route to correct mode based on complexity."""
        complexity = getattr(anim_spec, "complexity", "simple")
        method = getattr(anim_spec, "generation_method", "template")

        if complexity == "external" or method == "external":
            return self._generate_external(anim_spec)
        if complexity == "complex" or method == "custom_llm":
            return self._generate_custom_llm(anim_spec)
        if complexity == "medium" or method == "composition":
            return self._generate_composition(anim_spec)
        return self._generate_from_template(anim_spec)

    def _generate_from_template(self, spec) -> LottieResult:
        """Mode A: Template-based generation."""
        anim_type = getattr(spec, "type", "fade")
        template_name = self.TYPE_TO_TEMPLATE.get(anim_type)

        if not template_name or template_name not in self._templates:
            # Fallback: try fade_in
            template_name = "fade_in"
            if template_name not in self._templates:
                return LottieResult(anim_id=spec.anim_id, success=False,
                                    error=f"No template for type '{anim_type}'")

        lottie = copy.deepcopy(self._templates[template_name])
        lottie = self._apply_parameters(lottie, spec)

        # Remove meta
        lottie.pop("__template_meta", None)

        path = self._save_lottie(lottie, spec.anim_id)
        dur = getattr(spec, "technical_specs", {}).get("duration_ms", 300)

        return LottieResult(
            anim_id=spec.anim_id, success=True, lottie_json=lottie,
            file_path=path, generation_method="template", cost=0.0,
            file_size_bytes=Path(path).stat().st_size if Path(path).exists() else 0,
            duration_ms=int(dur) if dur else 300,
        )

    def _generate_composition(self, spec) -> LottieResult:
        """Mode B: Combine templates via TemplateComposer."""
        try:
            from factory.motion_forge.template_composer import TemplateComposer
            composer = TemplateComposer()
            lottie = composer.compose(spec)

            if lottie:
                path = self._save_lottie(lottie, spec.anim_id)
                dur = getattr(spec, "technical_specs", {}).get("duration_ms", 400)
                try:
                    dur = int(float(str(dur)))
                except (ValueError, TypeError):
                    dur = 400
                return LottieResult(
                    anim_id=spec.anim_id, success=True, lottie_json=lottie,
                    file_path=path, generation_method="composition", cost=0.0,
                    file_size_bytes=Path(path).stat().st_size if Path(path).exists() else 0,
                    duration_ms=dur,
                )
        except ImportError:
            pass

        # Fallback: try as template
        return self._generate_from_template(spec)

    def _generate_custom_llm(self, spec) -> LottieResult:
        """Mode C: LLM generates full Lottie JSON."""
        dur = getattr(spec, "technical_specs", {}).get("duration_ms", 500)
        vis = getattr(spec, "visual_specs", {})
        ease = getattr(spec, "technical_specs", {}).get("ease", "ease-out")

        system = (
            "You generate Lottie animation JSON files. Output ONLY valid JSON, no explanation. "
            "Use Lottie format v5.7.1, 60fps, shape layers only (no images). "
            "The JSON must have: v, fr, ip, op, w, h, nm, ddd, assets, layers. "
            "Use proper Lottie keyframe format with bezier easing."
        )
        user = (
            f"Create a Lottie animation: {spec.description}. "
            f"Duration: {dur}ms ({self._ms_to_frames(int(dur))} frames at 60fps). "
            f"Canvas: 512x512. Ease: {ease}. "
            f"Visual: {json.dumps(vis) if isinstance(vis, dict) else vis}."
        )

        response = self._call_llm(system, user)
        lottie = self._parse_json_response(response)

        if not isinstance(lottie, dict) or not self._validate_basic(lottie):
            return LottieResult(anim_id=spec.anim_id, success=False,
                                generation_method="custom_llm", cost=0.01,
                                error="LLM did not produce valid Lottie JSON")

        path = self._save_lottie(lottie, spec.anim_id)
        return LottieResult(
            anim_id=spec.anim_id, success=True, lottie_json=lottie,
            file_path=path, generation_method="custom_llm", cost=0.01,
            file_size_bytes=Path(path).stat().st_size if Path(path).exists() else 0,
            duration_ms=int(dur) if dur else 500,
        )

    def _generate_external(self, spec) -> LottieResult:
        """Mode D: Too complex — mark as needs_manual."""
        return LottieResult(
            anim_id=spec.anim_id, success=False,
            generation_method="external", cost=0.0,
            error="needs_manual_creation (external: 3D/particles/physics)",
        )

    def _apply_parameters(self, lottie: dict, spec) -> dict:
        """Apply AnimSpec parameters to a Lottie template."""
        tech = getattr(spec, "technical_specs", {})
        if not isinstance(tech, dict):
            tech = {}

        # Duration
        dur_ms = tech.get("duration_ms", 300)
        try:
            dur_ms = int(float(str(dur_ms)))
        except (ValueError, TypeError):
            dur_ms = 300
        op = self._ms_to_frames(dur_ms)
        lottie["op"] = op

        # Name
        lottie["nm"] = getattr(spec, "name", lottie.get("nm", "animation"))

        # Ease
        ease_name = str(tech.get("ease", "ease-out"))
        if lottie.get("layers"):
            for layer in lottie["layers"]:
                ks = layer.get("ks", {})
                for prop_key in ["o", "s", "p", "r"]:
                    prop = ks.get(prop_key, {})
                    if prop.get("a") == 1 and isinstance(prop.get("k"), list):
                        self._set_ease_on_keyframes(prop["k"], ease_name)
                        # Rescale keyframe times to new op
                        self._rescale_keyframes(prop["k"], lottie["op"])

        return lottie

    def _set_ease_on_keyframes(self, keyframes: list, ease_name: str):
        curve = self.EASE_CURVES.get(ease_name, self.EASE_CURVES["ease-out"])
        for kf in keyframes:
            if isinstance(kf, dict):
                kf["i"] = copy.deepcopy(curve["i"])
                kf["o"] = copy.deepcopy(curve["o"])

    def _rescale_keyframes(self, keyframes: list, new_op: int):
        """Rescale keyframe times proportionally to new op."""
        if not keyframes:
            return
        max_t = max((kf.get("t", 0) for kf in keyframes if isinstance(kf, dict)), default=0)
        if max_t <= 0:
            return
        for kf in keyframes:
            if isinstance(kf, dict) and "t" in kf:
                kf["t"] = round(kf["t"] / max_t * new_op)

    def _ms_to_frames(self, ms: int) -> int:
        return max(1, round(ms / 1000 * self.FRAMERATE))

    def _save_lottie(self, lottie: dict, anim_id: str) -> str:
        path = self.OUTPUT_DIR / f"{anim_id}.json"
        path.write_text(json.dumps(lottie, separators=(',', ':')), encoding="utf-8")
        return str(path)

    def _validate_basic(self, lottie: dict) -> bool:
        return all(k in lottie for k in ("v", "fr", "ip", "op", "w", "h", "layers"))

    def _call_llm(self, system: str, user: str, max_tokens: int = 4096) -> str:
        from dotenv import load_dotenv
        load_dotenv()
        try:
            from factory.brain.model_provider import get_model, get_router
            sel = get_model(profile="standard", expected_output_tokens=max_tokens)
            router = get_router()
            msgs = [{"role": "system", "content": system}, {"role": "user", "content": user}]
            resp = router.call(model_id=sel["model"], provider=sel["provider"], messages=msgs, max_tokens=max_tokens)
            if resp.error:
                raise RuntimeError(resp.error)
            return resp.content
        except Exception as e:
            try:
                import anthropic
                client = anthropic.Anthropic()
                resp = client.messages.create(model=get_fallback_model(), max_tokens=max_tokens,
                                              messages=[{"role": "user", "content": f"{system}\n\n{user}"}])
                return resp.content[0].text
            except Exception:
                return "{}"

    def _parse_json_response(self, response: str):
        text = response.strip()
        if text.startswith("```"):
            text = text.split("\n", 1)[1] if "\n" in text else text[3:]
        if text.endswith("```"):
            text = text.rsplit("```", 1)[0]
        text = text.strip()
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            start = text.find("{")
            end = text.rfind("}")
            if start != -1 and end > start:
                try:
                    return json.loads(text[start:end + 1])
                except json.JSONDecodeError:
                    pass
        return {}

    def generate_batch(self, specs: list) -> list:
        results = []
        for spec in specs:
            try:
                r = self.generate(spec)
                results.append(r)
            except Exception as e:
                results.append(LottieResult(anim_id=getattr(spec, "anim_id", "?"),
                                            success=False, error=str(e)))
        return results
