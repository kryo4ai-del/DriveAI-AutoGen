"""Audio Check -- validates generated sounds for technical quality.

Checks: loudness (peak dBFS), duration, format, loop quality.
Uses pydub when available, graceful degradation when not.
"""

import json
import logging
import struct
import wave
from pathlib import Path

from .config import QA_CONFIG

logger = logging.getLogger(__name__)

try:
    from pydub import AudioSegment
    _HAS_PYDUB = True
except ImportError:
    _HAS_PYDUB = False


class AudioCheck:
    """Checks audio for loudness, duration, format, loop quality."""

    # Category to config key mapping
    _DURATION_KEYS = {
        "sfx": "sfx_duration_range",
        "ui_sound": "ui_sound_duration_range",
        "ambient": "ambient_duration_range",
        "music": "music_duration_range",
        "notification": "notification_duration_range",
    }

    def check_sound(self, audio_path: str, sound_spec: dict = None) -> dict:
        """Run all audio checks on one file."""
        spec = sound_spec or {}
        result = {
            "sound_id": spec.get("id", Path(audio_path).stem),
            "file": str(audio_path),
            "checks": {},
            "overall": "pass",
            "warnings": [],
            "errors": [],
        }

        path = Path(audio_path)
        if not path.exists():
            result["overall"] = "fail"
            result["errors"].append(f"File not found: {audio_path}")
            return result

        category = spec.get("category", self._guess_category(path.name))
        expected_ms = spec.get("duration_ms")
        should_loop = spec.get("loop", category in ("ambient", "music"))
        platform = spec.get("platform")

        result["checks"]["loudness"] = self._check_loudness(str(path))
        result["checks"]["duration"] = self._check_duration(
            str(path), category, expected_ms)
        result["checks"]["format"] = self._check_format(str(path), platform)
        result["checks"]["loop_quality"] = self._check_loop_quality(
            str(path), should_loop)

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

    def _check_loudness(self, audio_path: str) -> dict:
        """Peak dBFS check + clipping detection."""
        if not _HAS_PYDUB:
            return {"pass": True, "peak_dbfs": None, "clipping": False,
                    "details": "pydub not installed -- skipped",
                    "severity": "warning"}

        try:
            audio = AudioSegment.from_file(audio_path)
        except Exception as e:
            return {"pass": "warn", "peak_dbfs": None, "clipping": False,
                    "severity": "warning",
                    "details": f"Cannot decode audio: {e}"}

        peak = audio.max_dBFS
        target = QA_CONFIG["peak_target_dbfs"]
        tol = QA_CONFIG["peak_tolerance_db"]
        clipping = peak >= 0.0

        if clipping:
            return {"pass": False, "peak_dbfs": round(peak, 2),
                    "clipping": True,
                    "details": f"Audio clips at {peak:.1f} dBFS"}

        within_range = abs(peak - target) <= tol
        if not within_range:
            return {"pass": "warn", "peak_dbfs": round(peak, 2),
                    "clipping": False, "severity": "warning",
                    "details": (f"Peak {peak:.1f} dBFS outside target "
                                f"{target} +/- {tol} dB")}

        return {"pass": True, "peak_dbfs": round(peak, 2),
                "clipping": False,
                "details": f"Peak {peak:.1f} dBFS OK"}

    def _check_duration(self, audio_path: str, category: str,
                        expected_ms: int = None) -> dict:
        """Duration range check per category."""
        actual_ms = self._get_duration_ms(audio_path)
        if actual_ms is None:
            return {"pass": "warn", "actual_ms": None,
                    "expected_range": None, "severity": "warning",
                    "details": "Cannot determine duration"}

        # Expected from spec or category defaults
        if expected_ms:
            tol = QA_CONFIG["duration_tolerance_percent"] / 100
            lo = expected_ms * (1 - tol)
            hi = expected_ms * (1 + tol)
            expected_range = (lo, hi)
        else:
            key = self._DURATION_KEYS.get(category, "sfx_duration_range")
            expected_range = QA_CONFIG.get(key, (100, 3000))

        lo, hi = expected_range
        passed = lo <= actual_ms <= hi

        return {
            "pass": passed,
            "actual_ms": round(actual_ms),
            "expected_range": (round(lo), round(hi)),
            "details": (f"{actual_ms:.0f}ms in [{lo:.0f}, {hi:.0f}]" if passed
                        else f"{actual_ms:.0f}ms outside [{lo:.0f}, {hi:.0f}]"),
        }

    def _check_format(self, audio_path: str,
                      expected_platform: str = None) -> dict:
        """File extension + basic header validation."""
        path = Path(audio_path)
        ext = path.suffix.lower()
        valid_exts = {".wav", ".mp3", ".ogg", ".m4a", ".aac", ".flac"}
        actual_format = ext.lstrip(".")

        if ext not in valid_exts:
            return {"pass": False, "actual_format": actual_format,
                    "sample_rate": None,
                    "details": f"Unsupported format: {ext}"}

        sample_rate = self._get_sample_rate(audio_path)

        # Platform-specific format preferences
        preferred = {
            "ios": {".m4a", ".wav", ".aac"},
            "android": {".ogg", ".wav", ".mp3"},
            "web": {".mp3", ".ogg", ".wav"},
            "unity": {".wav", ".ogg", ".mp3"},
        }
        if expected_platform and ext not in preferred.get(expected_platform, valid_exts):
            return {"pass": "warn", "actual_format": actual_format,
                    "sample_rate": sample_rate, "severity": "warning",
                    "details": f"{ext} not preferred for {expected_platform}"}

        return {"pass": True, "actual_format": actual_format,
                "sample_rate": sample_rate,
                "details": f"Format {actual_format} OK"
                           + (f", {sample_rate}Hz" if sample_rate else "")}

    def _check_loop_quality(self, audio_path: str, should_loop: bool) -> dict:
        """Compare first/last 100ms amplitude for loop sounds."""
        if not should_loop:
            return {"pass": True, "details": "N/A (not a loop sound)"}

        if not _HAS_PYDUB:
            return {"pass": True, "severity": "warning",
                    "details": "pydub not installed -- loop check skipped"}

        try:
            audio = AudioSegment.from_file(audio_path)
        except Exception:
            return {"pass": "warn", "severity": "warning",
                    "details": "Cannot decode for loop check"}

        if len(audio) < 200:
            return {"pass": "warn", "severity": "warning",
                    "details": "Audio too short for loop analysis"}

        first_100 = audio[:100]
        last_100 = audio[-100:]

        first_rms = first_100.rms
        last_rms = last_100.rms

        if first_rms == 0 and last_rms == 0:
            return {"pass": True,
                    "details": "Both ends silent (good for loop)"}

        max_rms = max(first_rms, last_rms, 1)
        diff_ratio = abs(first_rms - last_rms) / max_rms

        if diff_ratio > 0.5:
            return {"pass": "warn", "severity": "warning",
                    "details": (f"Loop amplitude mismatch: "
                                f"start={first_rms}, end={last_rms}, "
                                f"ratio={diff_ratio:.2f}")}

        return {"pass": True,
                "details": f"Loop OK (diff ratio {diff_ratio:.2f})"}

    def check_batch(self, manifest_path: str) -> list:
        """Check all sounds in a manifest."""
        try:
            data = json.loads(
                Path(manifest_path).read_text(encoding="utf-8"))
        except Exception as e:
            logger.error("Cannot load manifest %s: %s", manifest_path, e)
            return []

        results = []
        base_dir = Path(manifest_path).parent

        for sound in data.get("sounds", []):
            # Sound manifest has per-platform files
            files = sound.get("files", {})
            sound_id = sound.get("id", "")

            # Check primary file (unity/ios/any available)
            checked = False
            for platform in ["unity", "ios", "android", "web"]:
                fpath = files.get(platform, "")
                if fpath:
                    full = base_dir / fpath
                    if full.exists():
                        spec = {**sound, "platform": platform}
                        results.append(self.check_sound(str(full), spec))
                        checked = True
                        break

            if not checked and sound_id:
                results.append({
                    "sound_id": sound_id, "file": "",
                    "checks": {}, "overall": "warn",
                    "warnings": ["No accessible file found"],
                    "errors": [],
                })

        return results

    def summary(self, results: list) -> str:
        """Pass: N, Warn: N, Fail: N."""
        p = sum(1 for r in results if r["overall"] == "pass")
        w = sum(1 for r in results if r["overall"] == "warn")
        f = sum(1 for r in results if r["overall"] == "fail")
        lines = [f"Audio Check: {len(results)} sounds -- Pass: {p}, Warn: {w}, Fail: {f}"]
        for r in results:
            if r["overall"] != "pass":
                lines.append(f"  [{r['overall'].upper()}] {r['sound_id']}: "
                             f"{'; '.join(r['errors'] + r['warnings'])}")
        return "\n".join(lines)

    # -- Helpers --

    def _get_duration_ms(self, audio_path: str) -> float:
        """Get duration in ms. Try pydub first, then wave module."""
        if _HAS_PYDUB:
            try:
                audio = AudioSegment.from_file(audio_path)
                return len(audio)
            except Exception:
                pass

        # Fallback: wave module for .wav
        if audio_path.lower().endswith(".wav"):
            try:
                with wave.open(audio_path, "rb") as wf:
                    frames = wf.getnframes()
                    rate = wf.getframerate()
                    return (frames / rate) * 1000
            except Exception:
                pass

        return None

    def _get_sample_rate(self, audio_path: str) -> int:
        """Get sample rate. Try wave module for .wav."""
        if audio_path.lower().endswith(".wav"):
            try:
                with wave.open(audio_path, "rb") as wf:
                    return wf.getframerate()
            except Exception:
                pass

        if _HAS_PYDUB:
            try:
                audio = AudioSegment.from_file(audio_path)
                return audio.frame_rate
            except Exception:
                pass

        return None

    @staticmethod
    def _guess_category(filename: str) -> str:
        """Guess sound category from filename."""
        name = filename.lower()
        if "ambient" in name or "bg_" in name:
            return "ambient"
        if "music" in name or "bgm" in name:
            return "music"
        if "ui" in name or "click" in name or "tap" in name:
            return "ui_sound"
        if "notif" in name or "alert" in name:
            return "notification"
        return "sfx"
