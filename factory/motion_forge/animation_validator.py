"""Animation Validator — deterministic quality checks for generated animations.

No LLM calls. Validates Lottie structure, timing, file size, ease curves, platform compat.
"""

import json
import logging
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)


# ── Timing Ranges per Category (ms) ──

TIMING_RANGES = {
    "micro_interaction": (100, 900),
    "screen_transition": (300, 1000),
    "feedback":          (200, 800),
    "loading":           (800, 3000),
    "ambient":           (2000, 10000),
    "branding":          (500, 3000),
}

# ── File Size Limits ──

SIZE_LIMITS = {
    "lottie": {"warn": 500 * 1024, "error": 1024 * 1024},
    "css":    {"warn": 20 * 1024, "error": 100 * 1024},
    "csharp": {"warn": 50 * 1024, "error": 200 * 1024},
}

# ── Lottie Required Fields ──

LOTTIE_REQUIRED = ("v", "fr", "ip", "op", "w", "h", "layers")
VALID_FRAMERATES = (24, 30, 60)

# ── CSS-incompatible types ──

CSS_INCOMPATIBLE = {"shimmer", "custom", "external"}

# ── UI animation types that shouldn't use linear ease ──

UI_ANIM_TYPES = {"fade", "fade_in", "fade_out", "scale", "scale_in", "scale_bounce",
                 "slide_up", "slide_down", "slide_left", "slide_right", "rotate", "rotate_in"}


@dataclass
class CheckResult:
    name: str
    status: str   # pass, warn, fail
    details: str = ""


@dataclass
class ValidationResult:
    anim_id: str
    overall_status: str = "pass"  # pass, warn, fail
    checks: list = field(default_factory=list)
    warnings: list = field(default_factory=list)
    errors: list = field(default_factory=list)

    def add_check(self, name: str, status: str, details: str = ""):
        self.checks.append(CheckResult(name=name, status=status, details=details))
        if status == "fail":
            self.errors.append(f"{name}: {details}")
            self.overall_status = "fail"
        elif status == "warn" and self.overall_status != "fail":
            self.warnings.append(f"{name}: {details}")
            self.overall_status = "warn"

    def summary(self) -> str:
        status_icon = {"pass": "OK", "warn": "WARN", "fail": "FAIL"}[self.overall_status]
        parts = [f"[{status_icon}] {self.anim_id}"]
        for w in self.warnings:
            parts.append(f"  WARN: {w}")
        for e in self.errors:
            parts.append(f"  FAIL: {e}")
        return "\n".join(parts)

    def to_dict(self) -> dict:
        return {
            "anim_id": self.anim_id,
            "overall_status": self.overall_status,
            "checks": [{"name": c.name, "status": c.status, "details": c.details} for c in self.checks],
            "warnings": self.warnings,
            "errors": self.errors,
        }


class AnimationValidator:
    """Deterministic validator for generated animations."""

    def validate(self, lottie_path: str, anim_spec=None,
                 adapted_files: dict = None) -> ValidationResult:
        """Validate a single animation.

        Args:
            lottie_path: Path to the generated Lottie JSON
            anim_spec: AnimSpec object (optional, for timing/category checks)
            adapted_files: dict of {platform: file_path} for adapted files
        """
        anim_id = Path(lottie_path).stem
        if anim_spec:
            anim_id = getattr(anim_spec, "anim_id", anim_id)

        result = ValidationResult(anim_id=anim_id)

        # 1. Lottie validity
        lottie = self._check_lottie_validity(lottie_path, result)

        # 2. Timing validation (needs spec)
        if anim_spec and lottie:
            self._check_timing(lottie, anim_spec, result)

        # 3. File size checks
        self._check_file_size(lottie_path, "lottie", result)
        if adapted_files:
            for plat, fpath in adapted_files.items():
                if not fpath or not Path(fpath).exists():
                    continue
                if fpath.endswith(".css"):
                    self._check_file_size(fpath, "css", result)
                elif fpath.endswith(".cs"):
                    self._check_file_size(fpath, "csharp", result)

        # 4. Ease curve validation
        if lottie and anim_spec:
            self._check_ease_curves(lottie, anim_spec, result)

        # 5. Platform compatibility
        if anim_spec:
            self._check_platform_compatibility(anim_spec, adapted_files, result)

        return result

    def validate_batch(self, lottie_dir: str, specs: list = None,
                       adapted_dir: str = None) -> list:
        """Validate all animations in a directory."""
        results = []
        lottie_path = Path(lottie_dir)

        specs_map = {}
        if specs:
            for s in specs:
                specs_map[getattr(s, "anim_id", "")] = s

        for f in sorted(lottie_path.glob("*.json")):
            anim_id = f.stem
            spec = specs_map.get(anim_id)

            # Find adapted files
            adapted = {}
            if adapted_dir:
                ad = Path(adapted_dir)
                for plat in ("ios", "android", "web", "unity"):
                    candidates = [
                        ad / plat / "animations" / f"{anim_id}.json",
                        ad / plat / "animations" / f"{anim_id}.css",
                        ad / "unity" / "Scripts" / "Animations" / f"Anim{self._pascal(anim_id)}.cs",
                    ]
                    for c in candidates:
                        if c.exists():
                            adapted[plat] = str(c)
                            break

            r = self.validate(str(f), spec, adapted)
            results.append(r)

        return results

    def summary(self, results: list) -> str:
        """Summary string for batch validation."""
        total = len(results)
        passed = sum(1 for r in results if r.overall_status == "pass")
        warned = sum(1 for r in results if r.overall_status == "warn")
        failed = sum(1 for r in results if r.overall_status == "fail")

        lines = [f"Validation: Pass={passed}, Warn={warned}, Fail={failed} (Total={total})"]

        for r in results:
            if r.overall_status != "pass":
                lines.append(r.summary())

        return "\n".join(lines)

    # ── Individual Checks ──

    def _check_lottie_validity(self, path: str, result: ValidationResult) -> dict:
        """Check Lottie JSON structure."""
        p = Path(path)
        if not p.exists():
            result.add_check("lottie_exists", "fail", f"File not found: {path}")
            return None

        try:
            data = json.loads(p.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError) as e:
            result.add_check("lottie_parse", "fail", f"JSON parse error: {e}")
            return None

        if not isinstance(data, dict):
            result.add_check("lottie_structure", "fail", "Root is not a JSON object")
            return None

        # Required fields
        missing = [k for k in LOTTIE_REQUIRED if k not in data]
        if missing:
            result.add_check("lottie_fields", "fail", f"Missing: {', '.join(missing)}")
            return data

        # op > ip
        if data.get("op", 0) <= data.get("ip", 0):
            result.add_check("lottie_frames", "fail",
                             f"op ({data['op']}) must be > ip ({data['ip']})")
        else:
            result.add_check("lottie_frames", "pass")

        # Framerate
        fr = data.get("fr", 0)
        if fr not in VALID_FRAMERATES:
            result.add_check("lottie_framerate", "warn",
                             f"Framerate {fr} not in {VALID_FRAMERATES}")
        else:
            result.add_check("lottie_framerate", "pass")

        # At least 1 layer
        layers = data.get("layers", [])
        if not layers:
            result.add_check("lottie_layers", "fail", "No layers found")
        else:
            result.add_check("lottie_layers", "pass", f"{len(layers)} layer(s)")

        return data

    def _check_timing(self, lottie: dict, spec, result: ValidationResult):
        """Check animation duration against category ranges."""
        category = getattr(spec, "category", "micro_interaction")
        tech = getattr(spec, "technical_specs", {})
        if not isinstance(tech, dict):
            tech = {}

        # Calculate actual duration from Lottie
        fr = lottie.get("fr", 60)
        op = lottie.get("op", 24)
        ip = lottie.get("ip", 0)
        actual_ms = round((op - ip) / fr * 1000) if fr > 0 else 0

        # Spec duration
        spec_ms = tech.get("duration_ms", actual_ms)

        # Range check
        rng = TIMING_RANGES.get(category)
        if rng:
            lo, hi = rng
            if actual_ms < lo:
                result.add_check("timing_range", "warn",
                                 f"{category}: {actual_ms}ms < min {lo}ms")
            elif actual_ms > hi:
                result.add_check("timing_range", "warn",
                                 f"{category}: {actual_ms}ms > max {hi}ms")
            else:
                result.add_check("timing_range", "pass",
                                 f"{category}: {actual_ms}ms (range {lo}-{hi})")
        else:
            result.add_check("timing_range", "pass", f"No range for '{category}'")

        # Loop check for loading/ambient
        iterations = tech.get("iterations", 1)
        if category in ("loading", "ambient") and iterations != -1:
            result.add_check("timing_loop", "warn",
                             f"{category} should loop (iterations=-1), got {iterations}")

    def _check_file_size(self, path: str, file_type: str, result: ValidationResult):
        """Check file size against limits."""
        p = Path(path)
        if not p.exists():
            return

        size = p.stat().st_size
        limits = SIZE_LIMITS.get(file_type, SIZE_LIMITS["lottie"])
        name = f"size_{file_type}_{p.stem}"

        if size > limits["error"]:
            result.add_check(name, "fail",
                             f"{p.name}: {size / 1024:.1f}KB > {limits['error'] / 1024:.0f}KB limit")
        elif size > limits["warn"]:
            result.add_check(name, "warn",
                             f"{p.name}: {size / 1024:.1f}KB > {limits['warn'] / 1024:.0f}KB soft limit")
        else:
            result.add_check(name, "pass", f"{p.name}: {size / 1024:.1f}KB")

    def _check_ease_curves(self, lottie: dict, spec, result: ValidationResult):
        """Check ease curve validity."""
        tech = getattr(spec, "technical_specs", {})
        if not isinstance(tech, dict):
            tech = {}
        ease = tech.get("ease", "ease-out")
        anim_type = getattr(spec, "type", "fade")

        # Warn if linear ease on UI animation
        if ease == "linear" and anim_type in UI_ANIM_TYPES:
            result.add_check("ease_curve", "warn",
                             f"Linear ease on '{anim_type}' — may feel mechanical")
        else:
            result.add_check("ease_curve", "pass", f"Ease: {ease}")

        # Validate bezier handles in Lottie keyframes
        for layer in lottie.get("layers", []):
            ks = layer.get("ks", {})
            for prop_key in ("o", "s", "p", "r"):
                prop = ks.get(prop_key, {})
                if prop.get("a") == 1 and isinstance(prop.get("k"), list):
                    for kf in prop["k"]:
                        if not isinstance(kf, dict):
                            continue
                        for handle_key in ("i", "o"):
                            h = kf.get(handle_key, {})
                            if isinstance(h, dict):
                                for axis in ("x", "y"):
                                    vals = h.get(axis, [])
                                    if isinstance(vals, list):
                                        for v in vals:
                                            if isinstance(v, (int, float)) and (v < -2 or v > 3):
                                                result.add_check("ease_bezier", "warn",
                                                                 f"Extreme bezier handle: {handle_key}.{axis}={v}")
                                                return
        # If we get here, all handles are fine
        if not any(c.name == "ease_bezier" for c in result.checks):
            result.add_check("ease_bezier", "pass")

    def _check_platform_compatibility(self, spec, adapted_files: dict,
                                      result: ValidationResult):
        """Check platform compatibility flags."""
        anim_type = getattr(spec, "type", "fade")
        targets = getattr(spec, "platform_targets", ["ios", "android", "web", "unity"])

        if "web" in targets and anim_type in CSS_INCOMPATIBLE:
            result.add_check("platform_web", "warn",
                             f"'{anim_type}' needs lottie-web fallback for CSS")
        else:
            result.add_check("platform_web", "pass")

        # Check if adapted files exist for all targets
        if adapted_files:
            for plat in targets:
                if plat not in adapted_files:
                    result.add_check(f"platform_{plat}_file", "warn",
                                     f"No adapted file for {plat}")

    # ── Helpers ──

    def _pascal(self, s: str) -> str:
        import re
        parts = re.split(r'[-_\s]+', s)
        return "".join(p.capitalize() for p in parts)
