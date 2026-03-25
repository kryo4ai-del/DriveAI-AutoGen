"""Template Composer — merges multiple Lottie templates into combined animations.

Rules:
- Same property = CONFLICT (can't merge two scale animations)
- Different properties = MERGEABLE
- Max 3 templates per composition
"""

import copy
import json
import logging
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class CompositionPlan:
    templates: list = field(default_factory=list)
    properties: list = field(default_factory=list)
    conflicts: list = field(default_factory=list)
    feasible: bool = True
    reason: str = ""


class TemplateComposer:
    """Composes multiple Lottie templates into combined animations."""

    TEMPLATE_DIR = Path(__file__).parent / "templates"

    TEMPLATE_PROPERTIES = {
        "fade_in": ["opacity"], "fade_out": ["opacity"],
        "scale_in": ["scale"], "scale_bounce": ["scale"], "pulse": ["scale"],
        "slide_up": ["position"], "slide_down": ["position"],
        "slide_left": ["position"], "slide_right": ["position"],
        "rotate_in": ["rotation", "scale"],
        "color_shift": ["fill_color"],
        "shimmer": ["opacity_layer2"],
    }

    PROP_TO_KS = {
        "opacity": "o", "scale": "s", "position": "p", "rotation": "r",
    }

    def __init__(self, template_dir: str = None):
        if template_dir:
            self.TEMPLATE_DIR = Path(template_dir)
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
            except Exception:
                pass
        return templates

    def plan_composition(self, anim_spec) -> CompositionPlan:
        """Analyze spec and determine which templates to combine."""
        vis = getattr(anim_spec, "visual_specs", {})
        if not isinstance(vis, dict):
            vis = {}

        needed = []  # (property_name, template_name)

        # Opacity change?
        of = float(vis.get("opacity_from", 1.0) or 1.0)
        ot = float(vis.get("opacity_to", 1.0) or 1.0)
        if abs(of - ot) > 0.01:
            tpl = "fade_in" if ot > of else "fade_out"
            needed.append(("opacity", tpl))

        # Scale change?
        sf = float(vis.get("scale_from", 1.0) or 1.0)
        st = float(vis.get("scale_to", 1.0) or 1.0)
        if abs(sf - st) > 0.01:
            needed.append(("scale", "scale_in"))

        # Position change?
        tx = int(vis.get("translate_x", 0) or 0)
        ty = int(vis.get("translate_y", 0) or 0)
        if tx != 0 or ty != 0:
            if abs(ty) >= abs(tx):
                tpl = "slide_up" if ty > 0 else "slide_down"
            else:
                tpl = "slide_left" if tx > 0 else "slide_right"
            needed.append(("position", tpl))

        # Rotation?
        rot = float(vis.get("rotation_deg", 0) or 0)
        if abs(rot) > 0.1:
            needed.append(("rotation", "rotate_in"))

        # Color shift?
        cs = vis.get("color_shift")
        if cs:
            needed.append(("fill_color", "color_shift"))

        if not needed:
            # Fallback based on anim type
            atype = getattr(anim_spec, "type", "fade")
            from factory.motion_forge.lottie_writer import LottieWriter
            tpl_name = LottieWriter.TYPE_TO_TEMPLATE.get(atype, "fade_in")
            props = self.TEMPLATE_PROPERTIES.get(tpl_name, ["opacity"])
            needed = [(props[0], tpl_name)]

        # Conflict detection
        prop_names = [p for p, _ in needed]
        conflicts = [p for p in prop_names if prop_names.count(p) > 1]

        # Feasibility
        if len(needed) > 3:
            return CompositionPlan(
                templates=[t for _, t in needed], properties=prop_names,
                conflicts=conflicts, feasible=False,
                reason=f"Too many templates needed ({len(needed)} > 3)"
            )
        if conflicts:
            return CompositionPlan(
                templates=[t for _, t in needed], properties=prop_names,
                conflicts=conflicts, feasible=False,
                reason=f"Property conflict: {conflicts}"
            )

        # Check templates exist
        templates = [t for _, t in needed]
        missing = [t for t in templates if t not in self._templates]
        if missing:
            return CompositionPlan(
                templates=templates, properties=prop_names,
                conflicts=[], feasible=False,
                reason=f"Missing templates: {missing}"
            )

        return CompositionPlan(
            templates=templates, properties=prop_names,
            conflicts=[], feasible=True,
        )

    def compose(self, anim_spec) -> dict | None:
        """Execute composition. Returns Lottie dict or None if not feasible."""
        plan = self.plan_composition(anim_spec)
        if not plan.feasible:
            logger.info("Composition not feasible for %s: %s",
                        getattr(anim_spec, "anim_id", "?"), plan.reason)
            return None

        if not plan.templates:
            return None

        # Start with first template as base
        base = copy.deepcopy(self._templates[plan.templates[0]])

        # Merge additional templates
        for extra_name in plan.templates[1:]:
            extra = self._templates.get(extra_name)
            if not extra:
                continue
            self._merge_template(base, extra)

        # Apply timing
        tech = getattr(anim_spec, "technical_specs", {})
        if not isinstance(tech, dict):
            tech = {}
        dur_ms = tech.get("duration_ms", 400)
        try:
            dur_ms = int(float(str(dur_ms)))
        except (ValueError, TypeError):
            dur_ms = 400

        self._align_timing(base, dur_ms)

        # Apply visual values
        vis = getattr(anim_spec, "visual_specs", {})
        if isinstance(vis, dict):
            self._apply_visual_values(base, vis)

        # Apply ease
        ease = str(tech.get("ease", "ease-out"))
        self._apply_ease(base, ease)

        # Clean up
        base.pop("__template_meta", None)
        base["nm"] = getattr(anim_spec, "name", "composed")

        return base

    def _merge_template(self, base: dict, source: dict):
        """Merge source template's animated properties into base."""
        if not base.get("layers") or not source.get("layers"):
            return

        base_layer = base["layers"][0]
        source_layer = source["layers"][0]
        base_ks = base_layer.setdefault("ks", {})
        source_ks = source_layer.get("ks", {})

        for prop_key in ["o", "s", "p", "r"]:
            src_prop = source_ks.get(prop_key, {})
            base_prop = base_ks.get(prop_key, {})

            # Only merge if source is animated and base is NOT already animated for this
            if src_prop.get("a") == 1:
                if base_prop.get("a") != 1:
                    base_ks[prop_key] = copy.deepcopy(src_prop)

        # Special: merge fill color keyframes from shapes
        if source_layer.get("shapes"):
            for shape in source_layer["shapes"]:
                if shape.get("ty") == "fl" and isinstance(shape.get("c", {}).get("k"), list):
                    # Source has animated fill — inject into base shapes
                    for bshape in base_layer.get("shapes", []):
                        if bshape.get("ty") == "fl":
                            bshape["c"] = copy.deepcopy(shape["c"])

    def _align_timing(self, lottie: dict, target_ms: int, fr: int = 60):
        """Align all keyframes to target duration."""
        target_frames = max(1, round(target_ms / 1000 * fr))
        old_op = lottie.get("op", 24)
        lottie["op"] = target_frames

        if old_op <= 0:
            return

        scale = target_frames / old_op

        for layer in lottie.get("layers", []):
            ks = layer.get("ks", {})
            for prop_key in ["o", "s", "p", "r"]:
                prop = ks.get(prop_key, {})
                if prop.get("a") == 1 and isinstance(prop.get("k"), list):
                    for kf in prop["k"]:
                        if isinstance(kf, dict) and "t" in kf:
                            kf["t"] = round(kf["t"] * scale)

    def _apply_visual_values(self, lottie: dict, vis: dict):
        """Apply actual from/to values from visual_specs."""
        if not lottie.get("layers"):
            return
        layer = lottie["layers"][0]
        ks = layer.get("ks", {})

        # Opacity
        of = vis.get("opacity_from")
        ot = vis.get("opacity_to")
        if of is not None and ot is not None:
            prop = ks.get("o", {})
            if prop.get("a") == 1 and isinstance(prop.get("k"), list) and len(prop["k"]) >= 2:
                try:
                    prop["k"][0]["s"] = [float(of) * 100]
                    prop["k"][-1]["s"] = [float(ot) * 100]
                except (KeyError, TypeError, IndexError):
                    pass

        # Scale
        sf = vis.get("scale_from")
        st = vis.get("scale_to")
        if sf is not None and st is not None:
            prop = ks.get("s", {})
            if prop.get("a") == 1 and isinstance(prop.get("k"), list) and len(prop["k"]) >= 2:
                try:
                    s_from = float(sf) * 100
                    s_to = float(st) * 100
                    prop["k"][0]["s"] = [s_from, s_from, 100]
                    prop["k"][-1]["s"] = [s_to, s_to, 100]
                except (KeyError, TypeError, IndexError):
                    pass

        # Position (translate)
        tx = vis.get("translate_x", 0)
        ty = vis.get("translate_y", 0)
        if tx or ty:
            prop = ks.get("p", {})
            if prop.get("a") == 1 and isinstance(prop.get("k"), list) and len(prop["k"]) >= 2:
                cx, cy = 256, 256  # Canvas center
                try:
                    prop["k"][0]["s"] = [cx + int(tx), cy + int(ty), 0]
                    prop["k"][-1]["s"] = [cx, cy, 0]
                except (KeyError, TypeError, IndexError):
                    pass

    def _apply_ease(self, lottie: dict, ease_name: str):
        """Apply ease curve to all keyframes."""
        from factory.motion_forge.lottie_writer import LottieWriter
        curve = LottieWriter.EASE_CURVES.get(ease_name, LottieWriter.EASE_CURVES["ease-out"])

        for layer in lottie.get("layers", []):
            ks = layer.get("ks", {})
            for prop_key in ["o", "s", "p", "r"]:
                prop = ks.get(prop_key, {})
                if prop.get("a") == 1 and isinstance(prop.get("k"), list):
                    for kf in prop["k"]:
                        if isinstance(kf, dict):
                            kf["i"] = copy.deepcopy(curve["i"])
                            kf["o"] = copy.deepcopy(curve["o"])

    def get_composable_count(self, specs: list) -> dict:
        """Count composable vs too-complex specs."""
        composable = 0
        too_complex = 0
        conflicts = 0
        for spec in specs:
            plan = self.plan_composition(spec)
            if plan.feasible:
                composable += 1
            elif plan.conflicts:
                conflicts += 1
            else:
                too_complex += 1
        return {"composable": composable, "too_complex": too_complex, "conflicts": conflicts}
