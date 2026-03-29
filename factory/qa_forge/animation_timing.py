"""Animation Timing -- validates animation timing, structure, and platform coverage.

Checks: timing range per category, ease curves, file size, Lottie structure,
platform coverage (lottie/css/unity dirs).
"""

import json
import logging
import os
import re
from pathlib import Path

from .config import QA_CONFIG

logger = logging.getLogger(__name__)


class AnimationTiming:
    """Checks animations for timing, ease curves, file size, Lottie structure."""

    def check_animation(self, anim_path: str,
                        anim_spec: dict = None) -> dict:
        """Run all animation checks."""
        spec = anim_spec or {}
        result = {
            "anim_id": spec.get("id", Path(anim_path).stem),
            "file": str(anim_path),
            "checks": {},
            "overall": "pass",
            "warnings": [],
            "errors": [],
        }

        path = Path(anim_path)
        if not path.exists():
            result["overall"] = "fail"
            result["errors"].append(f"File not found: {anim_path}")
            return result

        ext = path.suffix.lower()
        category = spec.get("category", "micro_interaction")

        if ext == ".json":
            # Lottie JSON
            try:
                lottie = json.loads(path.read_text(encoding="utf-8"))
            except Exception as e:
                result["overall"] = "fail"
                result["errors"].append(f"Invalid JSON: {e}")
                return result

            result["checks"]["timing"] = self._check_timing(lottie, category)
            result["checks"]["ease_curves"] = self._check_ease_curves(lottie)
            result["checks"]["lottie_structure"] = self._check_lottie_structure(lottie)
        elif ext == ".css":
            result["checks"]["timing"] = self._check_css_timing(
                path.read_text(encoding="utf-8"), category)
        elif ext == ".cs":
            result["checks"]["timing"] = self._check_cs_timing(
                path.read_text(encoding="utf-8"), category)

        result["checks"]["file_size"] = self._check_file_size(str(path), ext)

        # Platform coverage
        catalog_dir = spec.get("catalog_dir", str(path.parent.parent))
        anim_id = spec.get("id", path.stem)
        result["checks"]["platform_coverage"] = self._check_platform_coverage(
            anim_id, catalog_dir)

        # Aggregate
        for name, check in result["checks"].items():
            if check.get("pass") is False:
                if check.get("severity", "error") == "warning":
                    result["warnings"].append(f"{name}: {check.get('details', '')}")
                else:
                    result["errors"].append(f"{name}: {check.get('details', '')}")
            elif check.get("pass") == "warn":
                result["warnings"].append(f"{name}: {check.get('details', '')}")

        if result["errors"]:
            result["overall"] = "fail"
        elif result["warnings"]:
            result["overall"] = "warn"

        return result

    def _check_timing(self, lottie: dict, category: str) -> dict:
        """Calculate duration from (op-ip)/fr*1000, compare to category range."""
        ip = lottie.get("ip", 0)
        op = lottie.get("op", 0)
        fr = lottie.get("fr", 30)

        if fr <= 0 or op <= ip:
            return {"pass": False, "duration_ms": 0, "range": None,
                    "details": f"Invalid timing: ip={ip}, op={op}, fr={fr}"}

        duration_ms = ((op - ip) / fr) * 1000
        timing_range = QA_CONFIG["timing_ranges"].get(category)

        if not timing_range:
            return {"pass": True, "duration_ms": round(duration_ms),
                    "range": None,
                    "details": f"{duration_ms:.0f}ms (no range for '{category}')"}

        lo, hi = timing_range["min"], timing_range["max"]
        passed = lo <= duration_ms <= hi

        return {
            "pass": passed,
            "duration_ms": round(duration_ms),
            "range": (lo, hi),
            "details": (f"{duration_ms:.0f}ms in [{lo}, {hi}]" if passed else
                        f"{duration_ms:.0f}ms outside [{lo}, {hi}] for {category}"),
        }

    def _check_css_timing(self, css_text: str, category: str) -> dict:
        """Extract duration from CSS animation-duration."""
        match = re.search(r"animation-duration:\s*([\d.]+)(s|ms)", css_text)
        if not match:
            return {"pass": "warn", "duration_ms": None, "range": None,
                    "severity": "warning",
                    "details": "No animation-duration found in CSS"}

        val = float(match.group(1))
        unit = match.group(2)
        duration_ms = val * 1000 if unit == "s" else val

        timing_range = QA_CONFIG["timing_ranges"].get(category)
        if not timing_range:
            return {"pass": True, "duration_ms": round(duration_ms),
                    "range": None, "details": f"{duration_ms:.0f}ms (CSS)"}

        lo, hi = timing_range["min"], timing_range["max"]
        passed = lo <= duration_ms <= hi
        return {
            "pass": passed, "duration_ms": round(duration_ms),
            "range": (lo, hi),
            "details": (f"{duration_ms:.0f}ms in [{lo}, {hi}]" if passed else
                        f"{duration_ms:.0f}ms outside [{lo}, {hi}]"),
        }

    def _check_cs_timing(self, cs_text: str, category: str) -> dict:
        """Extract duration from C# script (duration variable or coroutine)."""
        match = re.search(r"duration\s*=\s*([\d.]+)f?", cs_text)
        if not match:
            return {"pass": "warn", "duration_ms": None, "range": None,
                    "severity": "warning",
                    "details": "No duration found in C# script"}

        duration_s = float(match.group(1))
        duration_ms = duration_s * 1000

        timing_range = QA_CONFIG["timing_ranges"].get(category)
        if not timing_range:
            return {"pass": True, "duration_ms": round(duration_ms),
                    "range": None, "details": f"{duration_ms:.0f}ms (C#)"}

        lo, hi = timing_range["min"], timing_range["max"]
        passed = lo <= duration_ms <= hi
        return {
            "pass": passed, "duration_ms": round(duration_ms),
            "range": (lo, hi),
            "details": (f"{duration_ms:.0f}ms in [{lo}, {hi}]" if passed else
                        f"{duration_ms:.0f}ms outside [{lo}, {hi}]"),
        }

    def _check_ease_curves(self, lottie: dict) -> dict:
        """Check bezier handles, warn for linear ease, validate ranges."""
        layers = lottie.get("layers", [])
        if not layers:
            return {"pass": "warn", "type": "unknown", "severity": "warning",
                    "details": "No layers found"}

        linear_count = 0
        bezier_count = 0
        invalid_count = 0

        for layer in layers:
            self._scan_keyframes(layer, linear_count, bezier_count,
                                 invalid_count)

        # Walk through all keyframes in shapes and transforms
        total = linear_count + bezier_count + invalid_count
        if total == 0:
            return {"pass": True, "type": "static",
                    "linear_warning": False,
                    "details": "No keyframes (static animation)"}

        all_linear = linear_count == total and total > 0

        if invalid_count > 0:
            return {"pass": "warn", "type": "mixed",
                    "linear_warning": all_linear,
                    "severity": "warning",
                    "details": f"{invalid_count} invalid bezier handles"}

        if all_linear:
            return {"pass": "warn", "type": "linear",
                    "linear_warning": True,
                    "severity": "warning",
                    "details": "All keyframes use linear ease (robotic feel)"}

        return {"pass": True, "type": "bezier",
                "linear_warning": False,
                "details": f"{bezier_count} bezier, {linear_count} linear"}

    def _scan_keyframes(self, obj, linear_count, bezier_count,
                        invalid_count):
        """Recursively scan for keyframes in Lottie object."""
        if isinstance(obj, dict):
            # Check for keyframe arrays
            if "k" in obj and isinstance(obj["k"], list):
                for kf in obj["k"]:
                    if isinstance(kf, dict):
                        o = kf.get("o", {})
                        i = kf.get("i", {})
                        if o and i:
                            # Has bezier handles
                            ox = o.get("x", [0])
                            oy = o.get("y", [0])
                            ix = i.get("x", [1])
                            iy = i.get("y", [1])

                            if self._is_linear(ox, oy, ix, iy):
                                linear_count += 1
                            else:
                                bezier_count += 1
                        else:
                            linear_count += 1

            for v in obj.values():
                self._scan_keyframes(v, linear_count, bezier_count,
                                     invalid_count)
        elif isinstance(obj, list):
            for item in obj:
                self._scan_keyframes(item, linear_count, bezier_count,
                                     invalid_count)

    @staticmethod
    def _is_linear(ox, oy, ix, iy) -> bool:
        """Check if bezier handles represent linear interpolation."""
        def flat(v):
            if isinstance(v, list):
                return all(abs(x) < 0.01 for x in v) or all(abs(x - 1) < 0.01 for x in v)
            return abs(v) < 0.01 or abs(v - 1) < 0.01

        return flat(ox) and flat(oy) and flat(ix) and flat(iy)

    def _check_file_size(self, file_path: str, file_type: str) -> dict:
        """Size check per file type."""
        try:
            size_bytes = os.path.getsize(file_path)
        except OSError:
            return {"pass": "warn", "size_kb": 0, "limit_kb": 0,
                    "severity": "warning",
                    "details": "Cannot read file size"}

        size_kb = size_bytes / 1024

        limits = {
            ".json": QA_CONFIG["max_lottie_size_kb"],
            ".css": QA_CONFIG["max_css_size_kb"],
            ".cs": QA_CONFIG["max_unity_cs_size_kb"],
        }
        limit = limits.get(file_type, 500)
        passed = size_kb <= limit

        return {
            "pass": passed,
            "size_kb": round(size_kb, 1),
            "limit_kb": limit,
            "details": (f"{size_kb:.1f}KB <= {limit}KB" if passed else
                        f"{size_kb:.1f}KB exceeds {limit}KB limit"),
        }

    def _check_lottie_structure(self, lottie: dict) -> dict:
        """Required fields: v, fr, ip, op, w, h, layers."""
        required = ["v", "fr", "ip", "op", "w", "h", "layers"]
        missing = [f for f in required if f not in lottie]

        if missing:
            return {"pass": False, "layers": 0, "framerate": 0,
                    "details": f"Missing required fields: {', '.join(missing)}"}

        fr = lottie.get("fr", 0)
        layers = len(lottie.get("layers", []))
        ip = lottie.get("ip", 0)
        op = lottie.get("op", 0)

        issues = []
        if fr not in (24, 25, 30, 60):
            issues.append(f"Unusual framerate: {fr}")
        if op <= ip:
            issues.append(f"op ({op}) must be > ip ({ip})")
        if layers == 0:
            issues.append("No layers")

        if issues:
            return {"pass": False, "layers": layers, "framerate": fr,
                    "details": "; ".join(issues)}

        return {"pass": True, "layers": layers, "framerate": fr,
                "details": f"{layers} layers, {fr}fps, "
                           f"{op - ip} frames"}

    def _check_platform_coverage(self, anim_id: str,
                                 catalog_dir: str) -> dict:
        """Check lottie/, css/, unity/ dirs for this anim_id."""
        base = Path(catalog_dir)
        platforms = {}

        for pdir, exts in [("lottie", [".json"]),
                           ("ios", [".json"]),
                           ("android", [".json"]),
                           ("css", [".css"]),
                           ("web", [".css", ".json"]),
                           ("unity", [".cs"])]:
            ppath = base / pdir
            if not ppath.exists():
                continue
            for ext in exts:
                candidates = list(ppath.glob(f"*{anim_id}*{ext}"))
                if candidates:
                    platforms[pdir] = True
                    break

        present = list(platforms.keys())
        passed = len(present) >= 1  # At least the source format

        return {
            "pass": passed,
            "platforms_present": present,
            "details": (f"Found in: {', '.join(present)}" if present else
                        "Not found in any platform directory"),
        }

    def check_batch(self, manifest_path: str) -> list:
        """Check all animations in a manifest."""
        try:
            data = json.loads(
                Path(manifest_path).read_text(encoding="utf-8"))
        except Exception as e:
            logger.error("Cannot load manifest %s: %s", manifest_path, e)
            return []

        results = []
        base_dir = Path(manifest_path).parent

        for anim in data.get("animations", []):
            anim_id = anim.get("id", "")
            # Find the Lottie file
            lottie_dir = base_dir / "lottie"
            candidates = (list(lottie_dir.glob(f"*{anim_id}*.json"))
                          if lottie_dir.exists() else [])

            if candidates:
                spec = {**anim, "catalog_dir": str(base_dir)}
                results.append(self.check_animation(str(candidates[0]), spec))
            else:
                results.append({
                    "anim_id": anim_id, "file": "",
                    "checks": {}, "overall": "warn",
                    "warnings": [f"No Lottie file found for {anim_id}"],
                    "errors": [],
                })

        return results

    def summary(self, results: list) -> str:
        """Summary string."""
        p = sum(1 for r in results if r["overall"] == "pass")
        w = sum(1 for r in results if r["overall"] == "warn")
        f = sum(1 for r in results if r["overall"] == "fail")
        lines = [f"Animation Timing: {len(results)} animations -- "
                 f"Pass: {p}, Warn: {w}, Fail: {f}"]
        for r in results:
            if r["overall"] != "pass":
                lines.append(f"  [{r['overall'].upper()}] {r['anim_id']}: "
                             f"{'; '.join(r['errors'] + r['warnings'])}")
        return "\n".join(lines)
