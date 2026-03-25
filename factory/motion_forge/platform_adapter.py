"""Platform Animation Adapter — converts Lottie JSON to platform-specific formats.

iOS/Android: Copy Lottie JSON (native lottie-ios / lottie-android rendering).
Web:         Convert to CSS @keyframes (with compatibility detection).
Unity:       Convert to C# MonoBehaviour Coroutine scripts.
"""

import copy
import json
import logging
import math
import re
import shutil
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)


# ── CSS-compatible Lottie property types ──

CSS_COMPATIBLE_TYPES = {
    "fade", "fade_in", "fade_out",
    "scale", "scale_in", "scale_bounce",
    "slide", "slide_up", "slide_down", "slide_left", "slide_right",
    "rotate", "rotate_in",
    "pulse", "color_shift",
}

CSS_INCOMPATIBLE_REASONS = {
    "shimmer": "gradient masking not supported in CSS",
    "custom": "complex multi-property animation",
    "external": "3D/particle/physics animation",
}


@dataclass
class AdaptResult:
    """Result of adapting one animation for one platform."""
    anim_id: str
    platform: str
    success: bool
    output_path: str = ""
    format: str = ""      # lottie_json, css, csharp
    fallback: str = ""    # e.g. "lottie-web" if CSS can't handle it
    file_size_bytes: int = 0
    error: str = ""

    def summary(self) -> str:
        if self.success:
            fb = f" (fallback={self.fallback})" if self.fallback else ""
            return f"OK {self.anim_id}/{self.platform}: {self.format}, {self.file_size_bytes}B{fb}"
        return f"FAIL {self.anim_id}/{self.platform}: {self.error}"


@dataclass
class BatchAdaptResult:
    """Result of adapting all animations for all platforms."""
    total: int = 0
    success: int = 0
    failed: int = 0
    by_platform: dict = field(default_factory=dict)
    results: list = field(default_factory=list)
    css_fallback_count: int = 0

    def summary(self) -> str:
        lines = [
            f"Platform Adapter: {self.success}/{self.total} OK, {self.failed} failed",
            f"  CSS fallbacks: {self.css_fallback_count}",
        ]
        for plat, counts in sorted(self.by_platform.items()):
            lines.append(f"  {plat}: {counts['ok']}/{counts['total']}")
        return "\n".join(lines)


# ── Easing Helpers ──

EASE_MAP_CSS = {
    "linear":      "linear",
    "ease-in":     "ease-in",
    "ease-out":    "ease-out",
    "ease-in-out": "ease-in-out",
    "bounce":      "cubic-bezier(0.175, 0.885, 0.32, 1.275)",
}

EASE_MAP_UNITY = {
    "linear":      "t",
    "ease-in":     "t * t",
    "ease-out":    "t * (2f - t)",
    "ease-in-out": "t < 0.5f ? 2f * t * t : -1f + (4f - 2f * t) * t",
    "bounce":      "t < 0.5f ? 4f * t * t * t : (t - 1f) * (2f * t - 2f) * (2f * t - 2f) + 1f",
}


class PlatformAdapter:
    """Converts Lottie JSON animations to platform-specific formats."""

    PLATFORMS = ["ios", "android", "web", "unity"]

    def __init__(self, output_base: str = None):
        base = Path(output_base) if output_base else Path(__file__).parent / "platform_output"
        self.output_base = base
        base.mkdir(parents=True, exist_ok=True)

    def adapt(self, lottie_path: str, anim_id: str, anim_type: str = "fade",
              platforms: list = None, tech_specs: dict = None,
              visual_specs: dict = None) -> list[AdaptResult]:
        """Adapt a single Lottie JSON to target platforms."""
        platforms = platforms or self.PLATFORMS
        tech = tech_specs or {}
        vis = visual_specs or {}
        results = []

        lottie_data = self._load_lottie(lottie_path)
        if lottie_data is None:
            for plat in platforms:
                results.append(AdaptResult(anim_id=anim_id, platform=plat, success=False,
                                           error=f"Failed to load {lottie_path}"))
            return results

        for plat in platforms:
            try:
                if plat in ("ios", "android"):
                    r = self._adapt_native(lottie_data, anim_id, plat, lottie_path)
                elif plat == "web":
                    r = self._adapt_web(lottie_data, anim_id, anim_type, tech, vis)
                elif plat == "unity":
                    r = self._adapt_unity(lottie_data, anim_id, anim_type, tech, vis)
                else:
                    r = AdaptResult(anim_id=anim_id, platform=plat, success=False,
                                    error=f"Unknown platform: {plat}")
                results.append(r)
            except Exception as e:
                logger.error("Adapt %s/%s failed: %s", anim_id, plat, e)
                results.append(AdaptResult(anim_id=anim_id, platform=plat, success=False,
                                           error=str(e)))

        return results

    def adapt_batch(self, lotties: list, platforms: list = None) -> BatchAdaptResult:
        """Adapt multiple Lottie animations.

        lotties: list of dicts with keys:
            lottie_path, anim_id, anim_type, tech_specs, visual_specs, platform_targets
        """
        platforms = platforms or self.PLATFORMS
        batch = BatchAdaptResult()
        platform_counts = {p: {"ok": 0, "total": 0} for p in platforms}

        for item in lotties:
            targets = item.get("platform_targets", platforms)
            results = self.adapt(
                lottie_path=item["lottie_path"],
                anim_id=item["anim_id"],
                anim_type=item.get("anim_type", "fade"),
                platforms=targets,
                tech_specs=item.get("tech_specs"),
                visual_specs=item.get("visual_specs"),
            )

            for r in results:
                batch.total += 1
                batch.results.append(r)

                plat = r.platform
                if plat not in platform_counts:
                    platform_counts[plat] = {"ok": 0, "total": 0}
                platform_counts[plat]["total"] += 1

                if r.success:
                    batch.success += 1
                    platform_counts[plat]["ok"] += 1
                    if r.fallback:
                        batch.css_fallback_count += 1
                else:
                    batch.failed += 1

        batch.by_platform = platform_counts
        return batch

    # ── iOS / Android: native Lottie copy ──

    def _adapt_native(self, lottie_data: dict, anim_id: str,
                      platform: str, source_path: str) -> AdaptResult:
        """iOS/Android: copy Lottie JSON (native rendering)."""
        out_dir = self.output_base / platform / "animations"
        out_dir.mkdir(parents=True, exist_ok=True)

        out_path = out_dir / f"{anim_id}.json"
        data = copy.deepcopy(lottie_data)
        data.pop("__template_meta", None)

        content = json.dumps(data, separators=(',', ':'))
        out_path.write_text(content, encoding="utf-8")

        return AdaptResult(
            anim_id=anim_id, platform=platform, success=True,
            output_path=str(out_path), format="lottie_json",
            file_size_bytes=out_path.stat().st_size,
        )

    # ── Web: CSS @keyframes ──

    def _adapt_web(self, lottie_data: dict, anim_id: str,
                   anim_type: str, tech: dict, vis: dict) -> AdaptResult:
        """Web: convert to CSS @keyframes. Fallback to lottie-web if incompatible."""
        out_dir = self.output_base / "web" / "animations"
        out_dir.mkdir(parents=True, exist_ok=True)

        # Check CSS compatibility
        if anim_type not in CSS_COMPATIBLE_TYPES:
            reason = CSS_INCOMPATIBLE_REASONS.get(anim_type, "not mappable to CSS")
            # Save lottie + fallback marker
            json_path = out_dir / f"{anim_id}.json"
            data = copy.deepcopy(lottie_data)
            data.pop("__template_meta", None)
            json_path.write_text(json.dumps(data, separators=(',', ':')), encoding="utf-8")

            return AdaptResult(
                anim_id=anim_id, platform="web", success=True,
                output_path=str(json_path), format="lottie_json",
                fallback="lottie-web",
                file_size_bytes=json_path.stat().st_size,
            )

        # Generate CSS
        css = self._lottie_to_css(lottie_data, anim_id, anim_type, tech, vis)
        css_path = out_dir / f"{anim_id}.css"
        css_path.write_text(css, encoding="utf-8")

        return AdaptResult(
            anim_id=anim_id, platform="web", success=True,
            output_path=str(css_path), format="css",
            file_size_bytes=css_path.stat().st_size,
        )

    def _lottie_to_css(self, lottie: dict, anim_id: str,
                       anim_type: str, tech: dict, vis: dict) -> str:
        """Convert a Lottie animation to CSS @keyframes + class."""
        dur_ms = tech.get("duration_ms", 300)
        delay_ms = tech.get("delay_ms", 0)
        ease = tech.get("ease", "ease-out")
        iterations = tech.get("iterations", 1)
        direction = tech.get("direction", "normal")
        fill_mode = tech.get("fill_mode", "forwards")

        css_ease = EASE_MAP_CSS.get(ease, "ease-out")
        iter_str = "infinite" if iterations == -1 else str(iterations)

        # Build keyframes based on type
        keyframes = self._build_css_keyframes(anim_type, vis, lottie)

        css_name = _to_css_name(anim_id)

        lines = [
            f"/* Generated by DriveAI Motion Forge — Platform Adapter */",
            f"/* Source: {anim_id} ({anim_type}) */",
            f"",
            f"@keyframes {css_name} {{",
        ]
        for pct, props in keyframes:
            prop_str = "; ".join(f"{k}: {v}" for k, v in props.items())
            lines.append(f"  {pct}% {{ {prop_str}; }}")
        lines.append("}")
        lines.append("")
        lines.append(f".anim-{css_name} {{")
        lines.append(f"  animation-name: {css_name};")
        lines.append(f"  animation-duration: {dur_ms}ms;")
        if delay_ms:
            lines.append(f"  animation-delay: {delay_ms}ms;")
        lines.append(f"  animation-timing-function: {css_ease};")
        lines.append(f"  animation-iteration-count: {iter_str};")
        lines.append(f"  animation-direction: {direction};")
        lines.append(f"  animation-fill-mode: {fill_mode};")
        lines.append("}")

        return "\n".join(lines) + "\n"

    def _build_css_keyframes(self, anim_type: str, vis: dict,
                             lottie: dict) -> list[tuple[int, dict]]:
        """Build list of (percentage, {prop: value}) tuples."""
        o_from = vis.get("opacity_from", 1.0)
        o_to = vis.get("opacity_to", 1.0)
        s_from = vis.get("scale_from", 1.0)
        s_to = vis.get("scale_to", 1.0)
        rot = vis.get("rotation_deg", 0)
        tx = vis.get("translate_x", 0)
        ty = vis.get("translate_y", 0)

        if anim_type in ("fade", "fade_in"):
            return [
                (0, {"opacity": "0"}),
                (100, {"opacity": "1"}),
            ]

        if anim_type == "fade_out":
            return [
                (0, {"opacity": "1"}),
                (100, {"opacity": "0"}),
            ]

        if anim_type in ("scale", "scale_in"):
            return [
                (0, {"transform": f"scale({s_from})", "opacity": str(o_from)}),
                (100, {"transform": f"scale({s_to})", "opacity": str(o_to)}),
            ]

        if anim_type == "scale_bounce":
            overshoot = s_to * 1.15
            return [
                (0, {"transform": f"scale({s_from})"}),
                (60, {"transform": f"scale({overshoot:.2f})"}),
                (80, {"transform": f"scale({s_to * 0.95:.2f})"}),
                (100, {"transform": f"scale({s_to})"}),
            ]

        if anim_type == "pulse":
            return [
                (0, {"transform": "scale(1)"}),
                (50, {"transform": f"scale({s_to if s_to != 1.0 else 1.15})"}),
                (100, {"transform": "scale(1)"}),
            ]

        if anim_type == "slide_up":
            dist = ty if ty else 100
            return [
                (0, {"transform": f"translateY({dist}px)", "opacity": str(o_from)}),
                (100, {"transform": "translateY(0)", "opacity": str(o_to)}),
            ]

        if anim_type == "slide_down":
            dist = ty if ty else -100
            return [
                (0, {"transform": f"translateY({dist}px)", "opacity": str(o_from)}),
                (100, {"transform": "translateY(0)", "opacity": str(o_to)}),
            ]

        if anim_type == "slide_left":
            dist = tx if tx else 100
            return [
                (0, {"transform": f"translateX({dist}px)", "opacity": str(o_from)}),
                (100, {"transform": "translateX(0)", "opacity": str(o_to)}),
            ]

        if anim_type == "slide_right":
            dist = tx if tx else -100
            return [
                (0, {"transform": f"translateX({dist}px)", "opacity": str(o_from)}),
                (100, {"transform": "translateX(0)", "opacity": str(o_to)}),
            ]

        if anim_type in ("rotate", "rotate_in"):
            deg = rot if rot else 360
            return [
                (0, {"transform": f"rotate(0deg)", "opacity": str(o_from)}),
                (100, {"transform": f"rotate({deg}deg)", "opacity": str(o_to)}),
            ]

        if anim_type == "color_shift":
            shift = vis.get("color_shift")
            if shift and isinstance(shift, dict):
                c_from = shift.get("from", "#666")
                c_to = shift.get("to", "#0f0")
            else:
                c_from = "#666666"
                c_to = "#00e5a0"
            return [
                (0, {"color": c_from}),
                (100, {"color": c_to}),
            ]

        # Generic fallback: extract from Lottie keyframes
        return self._extract_css_from_lottie(lottie)

    def _extract_css_from_lottie(self, lottie: dict) -> list[tuple[int, dict]]:
        """Best-effort extraction of keyframes from Lottie layers."""
        layers = lottie.get("layers", [])
        if not layers:
            return [(0, {"opacity": "0"}), (100, {"opacity": "1"})]

        op = lottie.get("op", 24)
        ks = layers[0].get("ks", {})
        keyframes = []

        # Opacity
        o = ks.get("o", {})
        if o.get("a") == 1 and isinstance(o.get("k"), list):
            for kf in o["k"]:
                if isinstance(kf, dict) and "t" in kf:
                    pct = round(kf["t"] / op * 100) if op else 0
                    val = kf.get("s", [100])[0] / 100
                    keyframes.append((pct, {"opacity": f"{val:.2f}"}))

        if not keyframes:
            keyframes = [(0, {"opacity": "0"}), (100, {"opacity": "1"})]

        return keyframes

    # ── Unity: C# MonoBehaviour Coroutine ──

    def _adapt_unity(self, lottie_data: dict, anim_id: str,
                     anim_type: str, tech: dict, vis: dict) -> AdaptResult:
        """Unity: convert to C# MonoBehaviour coroutine script."""
        out_dir = self.output_base / "unity" / "Scripts" / "Animations"
        out_dir.mkdir(parents=True, exist_ok=True)

        class_name = _to_csharp_class(anim_id)
        csharp = self._generate_csharp(class_name, anim_id, anim_type, tech, vis)

        cs_path = out_dir / f"{class_name}.cs"
        cs_path.write_text(csharp, encoding="utf-8")

        return AdaptResult(
            anim_id=anim_id, platform="unity", success=True,
            output_path=str(cs_path), format="csharp",
            file_size_bytes=cs_path.stat().st_size,
        )

    def _generate_csharp(self, class_name: str, anim_id: str,
                         anim_type: str, tech: dict, vis: dict) -> str:
        """Generate a C# MonoBehaviour with Coroutine for the animation."""
        dur = tech.get("duration_ms", 300) / 1000.0
        delay = tech.get("delay_ms", 0) / 1000.0
        ease = tech.get("ease", "ease-out")
        iterations = tech.get("iterations", 1)
        loop = iterations == -1

        o_from = vis.get("opacity_from", 1.0)
        o_to = vis.get("opacity_to", 1.0)
        s_from = vis.get("scale_from", 1.0)
        s_to = vis.get("scale_to", 1.0)
        rot = vis.get("rotation_deg", 0)
        tx = vis.get("translate_x", 0)
        ty = vis.get("translate_y", 0)

        ease_expr = EASE_MAP_UNITY.get(ease, "t * (2f - t)")

        # Build the coroutine body based on type
        body = self._build_unity_body(anim_type, o_from, o_to, s_from, s_to, rot, tx, ty)

        loop_start = "do {" if loop else "{"
        loop_end = "} while (true);" if loop else "}"

        return f"""// Generated by DriveAI Motion Forge — Platform Adapter
// Animation: {anim_id} ({anim_type})
// Duration: {dur}s, Ease: {ease}

using System.Collections;
using UnityEngine;

public class {class_name} : MonoBehaviour
{{
    [Header("Animation Settings")]
    public float duration = {dur}f;
    public float delay = {delay}f;
    public bool playOnStart = true;

    private CanvasGroup _canvasGroup;
    private Vector3 _startPos;
    private Vector3 _startScale;

    void Awake()
    {{
        _canvasGroup = GetComponent<CanvasGroup>();
        _startPos = transform.localPosition;
        _startScale = transform.localScale;
    }}

    void Start()
    {{
        if (playOnStart) Play();
    }}

    public void Play()
    {{
        StopAllCoroutines();
        StartCoroutine(Animate());
    }}

    private float Ease(float t)
    {{
        return {ease_expr};
    }}

    private IEnumerator Animate()
    {{
        if (delay > 0f) yield return new WaitForSeconds(delay);

        {loop_start}
            float elapsed = 0f;
            while (elapsed < duration)
            {{
                elapsed += Time.deltaTime;
                float t = Mathf.Clamp01(elapsed / duration);
                float eased = Ease(t);

{body}

                yield return null;
            }}

            // Snap to final values
            ApplyFinal();
        {loop_end}
    }}

    private void ApplyFinal()
    {{
{self._build_unity_final(anim_type, o_to, s_to, rot, tx, ty)}
    }}
}}
"""

    def _build_unity_body(self, anim_type: str, o_from: float, o_to: float,
                          s_from: float, s_to: float, rot: float,
                          tx: int, ty: int) -> str:
        """Build the per-frame animation code inside the Coroutine."""
        indent = "                "

        if anim_type in ("fade", "fade_in"):
            return (f"{indent}if (_canvasGroup != null)\n"
                    f"{indent}    _canvasGroup.alpha = Mathf.Lerp(0f, 1f, eased);")

        if anim_type == "fade_out":
            return (f"{indent}if (_canvasGroup != null)\n"
                    f"{indent}    _canvasGroup.alpha = Mathf.Lerp(1f, 0f, eased);")

        if anim_type in ("scale", "scale_in"):
            return (f"{indent}float s = Mathf.Lerp({s_from}f, {s_to}f, eased);\n"
                    f"{indent}transform.localScale = _startScale * s;\n"
                    f"{indent}if (_canvasGroup != null)\n"
                    f"{indent}    _canvasGroup.alpha = Mathf.Lerp({o_from}f, {o_to}f, eased);")

        if anim_type == "scale_bounce":
            overshoot = s_to * 1.15
            return (f"{indent}float s;\n"
                    f"{indent}if (eased < 0.6f)\n"
                    f"{indent}    s = Mathf.Lerp({s_from}f, {overshoot:.2f}f, eased / 0.6f);\n"
                    f"{indent}else if (eased < 0.8f)\n"
                    f"{indent}    s = Mathf.Lerp({overshoot:.2f}f, {s_to * 0.95:.2f}f, (eased - 0.6f) / 0.2f);\n"
                    f"{indent}else\n"
                    f"{indent}    s = Mathf.Lerp({s_to * 0.95:.2f}f, {s_to}f, (eased - 0.8f) / 0.2f);\n"
                    f"{indent}transform.localScale = _startScale * s;")

        if anim_type == "pulse":
            peak = s_to if s_to != 1.0 else 1.15
            return (f"{indent}float s = eased < 0.5f\n"
                    f"{indent}    ? Mathf.Lerp(1f, {peak}f, eased * 2f)\n"
                    f"{indent}    : Mathf.Lerp({peak}f, 1f, (eased - 0.5f) * 2f);\n"
                    f"{indent}transform.localScale = _startScale * s;")

        if anim_type == "slide_up":
            dist = ty if ty else 100
            return (f"{indent}float y = Mathf.Lerp({dist}f, 0f, eased);\n"
                    f"{indent}transform.localPosition = _startPos + new Vector3(0f, -y, 0f);\n"
                    f"{indent}if (_canvasGroup != null)\n"
                    f"{indent}    _canvasGroup.alpha = Mathf.Lerp({o_from}f, {o_to}f, eased);")

        if anim_type == "slide_down":
            dist = abs(ty) if ty else 100
            return (f"{indent}float y = Mathf.Lerp(-{dist}f, 0f, eased);\n"
                    f"{indent}transform.localPosition = _startPos + new Vector3(0f, -y, 0f);\n"
                    f"{indent}if (_canvasGroup != null)\n"
                    f"{indent}    _canvasGroup.alpha = Mathf.Lerp({o_from}f, {o_to}f, eased);")

        if anim_type == "slide_left":
            dist = tx if tx else 100
            return (f"{indent}float x = Mathf.Lerp({dist}f, 0f, eased);\n"
                    f"{indent}transform.localPosition = _startPos + new Vector3(x, 0f, 0f);\n"
                    f"{indent}if (_canvasGroup != null)\n"
                    f"{indent}    _canvasGroup.alpha = Mathf.Lerp({o_from}f, {o_to}f, eased);")

        if anim_type == "slide_right":
            dist = abs(tx) if tx else 100
            return (f"{indent}float x = Mathf.Lerp(-{dist}f, 0f, eased);\n"
                    f"{indent}transform.localPosition = _startPos + new Vector3(x, 0f, 0f);\n"
                    f"{indent}if (_canvasGroup != null)\n"
                    f"{indent}    _canvasGroup.alpha = Mathf.Lerp({o_from}f, {o_to}f, eased);")

        if anim_type in ("rotate", "rotate_in"):
            deg = rot if rot else 360
            return (f"{indent}float angle = Mathf.Lerp(0f, {deg}f, eased);\n"
                    f"{indent}transform.localRotation = Quaternion.Euler(0f, 0f, angle);\n"
                    f"{indent}if (_canvasGroup != null)\n"
                    f"{indent}    _canvasGroup.alpha = Mathf.Lerp({o_from}f, {o_to}f, eased);")

        if anim_type == "color_shift":
            return (f"{indent}// Color shift — requires SpriteRenderer or Image\n"
                    f"{indent}var renderer = GetComponent<UnityEngine.UI.Image>();\n"
                    f"{indent}if (renderer != null)\n"
                    f"{indent}    renderer.color = Color.Lerp(Color.gray, Color.green, eased);")

        # Generic fallback: fade + scale
        return (f"{indent}if (_canvasGroup != null)\n"
                f"{indent}    _canvasGroup.alpha = Mathf.Lerp({o_from}f, {o_to}f, eased);\n"
                f"{indent}float s = Mathf.Lerp({s_from}f, {s_to}f, eased);\n"
                f"{indent}transform.localScale = _startScale * s;")

    def _build_unity_final(self, anim_type: str, o_to: float, s_to: float,
                           rot: float, tx: int, ty: int) -> str:
        """Final state snap in Unity."""
        indent = "        "
        lines = []

        if anim_type in ("fade", "fade_in"):
            lines.append(f"{indent}if (_canvasGroup != null) _canvasGroup.alpha = 1f;")
        elif anim_type == "fade_out":
            lines.append(f"{indent}if (_canvasGroup != null) _canvasGroup.alpha = 0f;")
        elif anim_type in ("scale", "scale_in", "scale_bounce"):
            lines.append(f"{indent}transform.localScale = _startScale * {s_to}f;")
        elif anim_type == "pulse":
            lines.append(f"{indent}transform.localScale = _startScale;")
        elif anim_type.startswith("slide"):
            lines.append(f"{indent}transform.localPosition = _startPos;")
            lines.append(f"{indent}if (_canvasGroup != null) _canvasGroup.alpha = {o_to}f;")
        elif anim_type in ("rotate", "rotate_in"):
            deg = rot if rot else 360
            lines.append(f"{indent}transform.localRotation = Quaternion.Euler(0f, 0f, {deg}f);")
        else:
            lines.append(f"{indent}if (_canvasGroup != null) _canvasGroup.alpha = {o_to}f;")
            lines.append(f"{indent}transform.localScale = _startScale * {s_to}f;")

        return "\n".join(lines)

    # ── Helpers ──

    def _load_lottie(self, path: str) -> Optional[dict]:
        try:
            return json.loads(Path(path).read_text(encoding="utf-8"))
        except Exception as e:
            logger.error("Failed to load Lottie %s: %s", path, e)
            return None


# ── Naming Helpers ──

def _to_css_name(anim_id: str) -> str:
    """Convert anim_id to valid CSS identifier."""
    name = re.sub(r'[^a-zA-Z0-9_-]', '-', anim_id.lower())
    if name[0].isdigit():
        name = "a-" + name
    return name


def _to_csharp_class(anim_id: str) -> str:
    """Convert anim_id to valid C# PascalCase class name."""
    parts = re.split(r'[-_\s]+', anim_id)
    name = "Anim" + "".join(p.capitalize() for p in parts)
    name = re.sub(r'[^a-zA-Z0-9]', '', name)
    return name


# ── CLI ──

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Motion Forge — Platform Adapter")
    parser.add_argument("--lottie-dir", required=True, help="Directory with generated Lottie JSONs")
    parser.add_argument("--manifest", help="AnimManifest JSON for metadata")
    parser.add_argument("--output", help="Output base directory")
    parser.add_argument("--platforms", nargs="+", default=["ios", "android", "web", "unity"])
    parser.add_argument("--anim-id", help="Adapt single animation by ID")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO)
    adapter = PlatformAdapter(output_base=args.output)

    lottie_dir = Path(args.lottie_dir)
    if not lottie_dir.exists():
        print(f"ERROR: {lottie_dir} not found")
        exit(1)

    # Load manifest for metadata if available
    specs_map = {}
    if args.manifest:
        from factory.motion_forge.anim_spec_extractor import AnimManifest
        manifest = AnimManifest.from_json(Path(args.manifest).read_text(encoding="utf-8"))
        for s in manifest.specs:
            specs_map[s.anim_id] = s

    # Collect Lotties
    items = []
    for f in sorted(lottie_dir.glob("*.json")):
        aid = f.stem
        if args.anim_id and aid != args.anim_id:
            continue

        spec = specs_map.get(aid)
        items.append({
            "lottie_path": str(f),
            "anim_id": aid,
            "anim_type": getattr(spec, "type", "fade") if spec else "fade",
            "tech_specs": getattr(spec, "technical_specs", {}) if spec else {},
            "visual_specs": getattr(spec, "visual_specs", {}) if spec else {},
            "platform_targets": args.platforms,
        })

    if not items:
        print("No Lottie files found")
        exit(0)

    print(f"\n{'='*60}")
    print(f"  DriveAI Motion Forge — Platform Adapter")
    print(f"  Lotties: {len(items)}")
    print(f"  Platforms: {', '.join(args.platforms)}")
    print(f"{'='*60}\n")

    result = adapter.adapt_batch(items, platforms=args.platforms)

    for r in result.results:
        status = "OK" if r.success else "FAIL"
        fb = f" [fallback={r.fallback}]" if r.fallback else ""
        print(f"  [{status}] {r.anim_id}/{r.platform}: {r.format}{fb}")

    print(f"\n{result.summary()}")
    print(f"\nOutput: {adapter.output_base}")
