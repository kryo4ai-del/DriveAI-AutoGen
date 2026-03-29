"""QA Forge Orchestrator -- runs all QA checkers + design compliance.

Coordinates: VisualDiff, AudioCheck, AnimationTiming, SceneIntegrity,
DesignCompliance.  Calculates verdict, generates fixes/recommendations.

CLI: python -m factory.qa_forge.qa_forge_orchestrator --project echomatch --synthetic
"""

import argparse
import json
import logging
import os
import struct
import sys
import tempfile
import time
import wave
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

from .audio_check import AudioCheck
from .animation_timing import AnimationTiming
from .config import QA_CONFIG
from .design_compliance import DesignCompliance, ComplianceReport
from .scene_integrity import SceneIntegrity
from .visual_diff import VisualDiff

logger = logging.getLogger(__name__)


@dataclass
class QAForgeResult:
    """Aggregated QA Forge result."""
    project: str
    visual_results: list = field(default_factory=list)
    audio_results: list = field(default_factory=list)
    animation_results: list = field(default_factory=list)
    scene_results: list = field(default_factory=list)
    compliance: Optional[ComplianceReport] = None
    verdict: str = "PENDING"
    duration_s: float = 0.0
    errors: list = field(default_factory=list)

    def summary(self) -> str:
        """Full human-readable summary."""
        lines = [
            "=" * 60,
            f"QA FORGE REPORT: {self.project}",
            "=" * 60,
        ]

        # Per-checker summary
        for label, results, id_key in [
            ("Visual", self.visual_results, "asset_id"),
            ("Audio", self.audio_results, "sound_id"),
            ("Animation", self.animation_results, "anim_id"),
            ("Scene", self.scene_results, None),
        ]:
            if results:
                p = sum(1 for r in results if r.get("overall") == "pass")
                w = sum(1 for r in results if r.get("overall") == "warn")
                f = sum(1 for r in results if r.get("overall") == "fail")
                lines.append(f"  {label}: {len(results)} items -- "
                             f"Pass: {p}, Warn: {w}, Fail: {f}")

        # Compliance
        if self.compliance:
            lines.append("")
            lines.append(self.compliance.summary())

        # Verdict
        lines.append("")
        lines.append(f"VERDICT: {self.verdict}")
        lines.append(f"Duration: {self.duration_s:.1f}s")

        if self.errors:
            lines.append(f"\nOrchestrator Errors ({len(self.errors)}):")
            for e in self.errors:
                lines.append(f"  - {e}")

        lines.append("=" * 60)
        return "\n".join(lines)


class QAForgeOrchestrator:
    """Runs all QA Forge checkers and produces a unified report."""

    def __init__(self):
        self.visual = VisualDiff()
        self.audio = AudioCheck()
        self.animation = AnimationTiming()
        self.scene = SceneIntegrity()
        self.compliance = DesignCompliance()

    def run(self, project: str, catalog_dir: str,
            only: Optional[list] = None) -> QAForgeResult:
        """Run QA Forge on real catalog directory.

        Args:
            project: Project name.
            catalog_dir: Path to Forge catalog root.
            only: Optional list of checkers to run ("visual", "audio",
                  "animation", "scene").
        """
        start = time.time()
        result = QAForgeResult(project=project)
        checkers = only or ["visual", "audio", "animation", "scene"]
        base = Path(catalog_dir)

        # Visual: scan for images
        if "visual" in checkers:
            img_dir = base / "images"
            if img_dir.exists():
                for img in img_dir.glob("*"):
                    if img.suffix.lower() in (".png", ".jpg", ".jpeg", ".webp"):
                        try:
                            r = self.visual.check_asset(str(img))
                            result.visual_results.append(r)
                        except Exception as e:
                            result.errors.append(f"Visual {img.name}: {e}")

        # Audio: scan for sounds
        if "audio" in checkers:
            snd_dir = base / "sounds"
            if snd_dir.exists():
                for snd in snd_dir.glob("*"):
                    if snd.suffix.lower() in (".wav", ".mp3", ".ogg", ".m4a"):
                        try:
                            r = self.audio.check_sound(str(snd))
                            result.audio_results.append(r)
                        except Exception as e:
                            result.errors.append(f"Audio {snd.name}: {e}")

        # Animation: scan for Lottie/CSS/CS
        if "animation" in checkers:
            anim_dir = base / "animations"
            if anim_dir.exists():
                for anim in anim_dir.glob("*"):
                    if anim.suffix.lower() in (".json", ".css", ".cs"):
                        try:
                            r = self.animation.check_animation(str(anim))
                            result.animation_results.append(r)
                        except Exception as e:
                            result.errors.append(f"Anim {anim.name}: {e}")

        # Scene: scan for levels/scenes
        if "scene" in checkers:
            level_dir = base / "levels"
            if level_dir.exists():
                for lvl in level_dir.glob("*.json"):
                    try:
                        r = self.scene.check_level(str(lvl))
                        result.scene_results.append(r)
                    except Exception as e:
                        result.errors.append(f"Level {lvl.name}: {e}")

        # Design compliance
        qa_results = {
            "visual": result.visual_results,
            "audio": result.audio_results,
            "animation": result.animation_results,
            "scene": result.scene_results,
        }
        report = self.compliance.run_compliance(qa_results, project)
        result.compliance = report
        result.verdict = report.verdict
        result.duration_s = time.time() - start

        return result

    def run_synthetic_test(self, project: str = "echomatch") -> QAForgeResult:
        """Run QA Forge with synthetic test data.

        Creates realistic test files that exercise all checkers:
        - 5 images (1 intentional resolution FAIL → DC-003)
        - 4 audio (1 loudness WARN, all durations OK)
        - 3 animations (all PASS — Lottie + CSS, platform dirs present)
        - 3 levels + curve (all PASS — reachable, monotonic)

        Expected: CONDITIONAL_PASS (1 DC error, score ~91.7%).
        """
        start = time.time()
        result = QAForgeResult(project=project)
        tmpdir = tempfile.mkdtemp(prefix="qa_forge_synthetic_")

        try:
            # --- Visual: synthetic images ---
            result.visual_results = self._synth_visual(tmpdir)

            # --- Audio: synthetic WAV files ---
            result.audio_results = self._synth_audio(tmpdir)

            # --- Animation: synthetic Lottie/CSS ---
            result.animation_results = self._synth_animation(tmpdir)

            # --- Scene: synthetic levels ---
            result.scene_results = self._synth_scene(tmpdir)

        except Exception as e:
            result.errors.append(f"Synthetic setup error: {e}")

        # Design compliance
        qa_results = {
            "visual": result.visual_results,
            "audio": result.audio_results,
            "animation": result.animation_results,
            "scene": result.scene_results,
        }
        report = self.compliance.run_compliance(qa_results, project)
        result.compliance = report
        result.verdict = report.verdict
        result.duration_s = time.time() - start

        return result

    # --- Synthetic data generators ---

    def _synth_visual(self, tmpdir: str) -> list:
        """Create synthetic images and check them.

        1 intentional FAIL (small icon → DC-003), rest PASS.
        """
        results = []

        try:
            from PIL import Image
        except ImportError:
            logger.warning("Pillow not installed -- visual checks skipped")
            return results

        img_dir = Path(tmpdir) / "images"
        img_dir.mkdir()

        # 1. Good dark icon 512x512 RGBA (PASS)
        img = Image.new("RGBA", (512, 512), (20, 25, 40, 255))
        path = img_dir / "icon_menu.png"
        img.save(str(path))
        results.append(self.visual.check_asset(str(path), {"type": "icon"}))

        # 2. Small icon 64x64 — intentional FAIL (DC-003: resolution)
        img = Image.new("RGBA", (64, 64), (30, 30, 50, 255))
        path = img_dir / "icon_settings.png"
        img.save(str(path))
        results.append(self.visual.check_asset(str(path), {"type": "icon"}))

        # 3. Dark background (PASS)
        img = Image.new("RGB", (1920, 1080), (20, 22, 30))
        path = img_dir / "bg_main.png"
        img.save(str(path))
        results.append(self.visual.check_asset(str(path),
                                               {"type": "background"}))

        # 4. Good sprite with alpha (PASS)
        img = Image.new("RGBA", (256, 256), (50, 60, 80, 200))
        path = img_dir / "sprite_player.png"
        img.save(str(path))
        results.append(self.visual.check_asset(str(path), {"type": "sprite"}))

        # 5. Good sprite (PASS)
        img = Image.new("RGBA", (256, 256), (40, 50, 70, 180))
        path = img_dir / "sprite_enemy.png"
        img.save(str(path))
        results.append(self.visual.check_asset(str(path), {"type": "sprite"}))

        return results

    def _synth_audio(self, tmpdir: str) -> list:
        """Create synthetic WAV files and check them.

        All durations in range. One with low amplitude → loudness WARN.
        """
        results = []
        snd_dir = Path(tmpdir) / "sounds"
        snd_dir.mkdir()

        # 1. SFX (PASS) — 500ms, amplitude near target
        path = snd_dir / "sfx_click.wav"
        self._make_wav(str(path), duration_s=0.5, freq=440, amplitude=0.85)
        results.append(self.audio.check_sound(str(path), {
            "id": "sfx_click", "category": "sfx",
        }))

        # 2. UI sound (PASS) — 200ms
        path = snd_dir / "ui_tap.wav"
        self._make_wav(str(path), duration_s=0.2, freq=880, amplitude=0.85)
        results.append(self.audio.check_sound(str(path), {
            "id": "ui_tap", "category": "ui_sound",
        }))

        # 3. Ambient (WARN — loudness outside target, duration OK)
        path = snd_dir / "ambient_wind.wav"
        self._make_wav(str(path), duration_s=10.0, freq=220, amplitude=0.4)
        results.append(self.audio.check_sound(str(path), {
            "id": "ambient_wind", "category": "ambient",
        }))

        # 4. Notification (PASS) — 800ms
        path = snd_dir / "notif_alert.wav"
        self._make_wav(str(path), duration_s=0.8, freq=660, amplitude=0.85)
        results.append(self.audio.check_sound(str(path), {
            "id": "notif_alert", "category": "notification",
        }))

        return results

    def _synth_animation(self, tmpdir: str) -> list:
        """Create synthetic Lottie JSON + CSS and check them.

        All valid timing. Files in lottie/css dirs for platform_coverage.
        """
        results = []

        # Create platform dirs so platform_coverage finds files
        lottie_dir = Path(tmpdir) / "lottie"
        css_dir = Path(tmpdir) / "css"
        lottie_dir.mkdir()
        css_dir.mkdir()

        # 1. Valid micro-interaction (PASS) — 300ms, 30fps
        lottie = {
            "v": "5.7.4", "fr": 30, "ip": 0, "op": 9,
            "w": 100, "h": 100,
            "layers": [{"ty": 1, "ks": {"o": {"a": 0, "k": 100}}}],
        }
        path = lottie_dir / "btn_press.json"
        path.write_text(json.dumps(lottie), encoding="utf-8")
        results.append(self.animation.check_animation(str(path), {
            "id": "btn_press", "category": "micro_interaction",
            "catalog_dir": tmpdir,
        }))

        # 2. Valid screen transition (PASS) — 500ms, 30fps
        lottie = {
            "v": "5.7.4", "fr": 30, "ip": 0, "op": 15,
            "w": 200, "h": 200,
            "layers": [{"ty": 1}],
        }
        path = lottie_dir / "screen_fade.json"
        path.write_text(json.dumps(lottie), encoding="utf-8")
        results.append(self.animation.check_animation(str(path), {
            "id": "screen_fade", "category": "screen_transition",
            "catalog_dir": tmpdir,
        }))

        # 3. CSS animation (PASS) — 400ms
        css = (".fade-in {\n"
               "  animation-duration: 0.4s;\n"
               "  animation-timing-function: ease-out;\n"
               "}\n")
        path = css_dir / "fade_in.css"
        path.write_text(css, encoding="utf-8")
        results.append(self.animation.check_animation(str(path), {
            "id": "fade_in", "category": "screen_transition",
            "catalog_dir": tmpdir,
        }))

        return results

    def _synth_scene(self, tmpdir: str) -> list:
        """Create synthetic level JSON and check them.

        All levels reachable with 3+ stone types. Monotonic difficulty.
        """
        results = []
        level_dir = Path(tmpdir) / "levels"
        level_dir.mkdir()

        grids = [
            [[1, 2, 3, 1, 2], [3, 1, 2, 3, 1], [2, 3, 1, 2, 3],
             [1, 2, 3, 1, 2], [3, 1, 2, 3, 1]],
            [[2, 3, 1, 2, 3], [1, 2, 3, 1, 2], [3, 1, 2, 3, 1],
             [2, 3, 1, 2, 3], [1, 2, 3, 1, 2]],
            [[1, 3, 2, 1, 3], [2, 1, 3, 2, 1], [3, 2, 1, 3, 2],
             [1, 3, 2, 1, 3], [2, 1, 3, 2, 1]],
        ]

        # 3 valid levels with increasing difficulty (all PASS)
        for i, (diff, grid) in enumerate(
                zip([0.10, 0.20, 0.30], grids), 1):
            level = {
                "level_id": f"level_{i:03d}",
                "grid": grid,
                "difficulty": diff,
                "objectives": [{"type": "clear_stones", "count": 10}],
                "stone_types": [1, 2, 3],
            }
            path = level_dir / f"level_{i:03d}.json"
            path.write_text(json.dumps(level), encoding="utf-8")
            results.append(self.scene.check_level(str(path)))

        # Difficulty curve across all 3 levels (PASS — monotonic)
        curve_paths = sorted(str(p) for p in level_dir.glob("level_*.json"))
        curve_result = self.scene.check_difficulty_curve(curve_paths)
        results.append(curve_result)

        return results

    @staticmethod
    def _make_wav(path: str, duration_s: float = 1.0,
                  freq: int = 440, amplitude: float = 0.5,
                  sample_rate: int = 44100):
        """Generate a simple sine-wave WAV file."""
        import math
        n_frames = int(sample_rate * duration_s)
        max_amp = int(32767 * amplitude)

        with wave.open(path, "wb") as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)
            wf.setframerate(sample_rate)

            frames = bytearray()
            for i in range(n_frames):
                val = int(max_amp * math.sin(2 * math.pi * freq * i
                                             / sample_rate))
                frames.extend(struct.pack("<h", val))
            wf.writeframes(bytes(frames))

    def save_result(self, result: QAForgeResult,
                    output_dir: str = None) -> str:
        """Save full QA Forge result as JSON."""
        if output_dir is None:
            output_dir = str(Path(__file__).parent / "reports")

        Path(output_dir).mkdir(parents=True, exist_ok=True)
        path = Path(output_dir) / f"{result.project}_qa_forge.json"

        data = {
            "project": result.project,
            "verdict": result.verdict,
            "duration_s": round(result.duration_s, 2),
            "visual_count": len(result.visual_results),
            "audio_count": len(result.audio_results),
            "animation_count": len(result.animation_results),
            "scene_count": len(result.scene_results),
            "compliance_score": (result.compliance.score_percent
                                 if result.compliance else 0),
            "errors": result.errors,
        }

        path.write_text(json.dumps(data, indent=2, ensure_ascii=False),
                        encoding="utf-8")
        return str(path)


def main():
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="QA Forge Orchestrator -- validate Forge outputs")
    parser.add_argument("--project", default="echomatch",
                        help="Project name")
    parser.add_argument("--catalog-dir",
                        help="Path to Forge catalog directory")
    parser.add_argument("--synthetic", action="store_true",
                        help="Run with synthetic test data")
    parser.add_argument("--only", nargs="+",
                        choices=["visual", "audio", "animation", "scene"],
                        help="Run only specific checkers")
    parser.add_argument("--save", action="store_true",
                        help="Save report JSON to reports/")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO,
                        format="%(levelname)s %(name)s: %(message)s")

    orchestrator = QAForgeOrchestrator()

    if args.synthetic:
        print(f"\n>> Running SYNTHETIC QA Forge for '{args.project}'...\n")
        result = orchestrator.run_synthetic_test(args.project)
    elif args.catalog_dir:
        print(f"\n>> Running QA Forge on '{args.catalog_dir}' "
              f"for '{args.project}'...\n")
        result = orchestrator.run(args.project, args.catalog_dir,
                                  only=args.only)
    else:
        print("ERROR: Specify --synthetic or --catalog-dir")
        sys.exit(1)

    print(result.summary())

    if args.save:
        path = orchestrator.save_result(result)
        print(f"\nReport saved: {path}")

        if result.compliance:
            comp_path = orchestrator.compliance.save_report(result.compliance)
            print(f"Compliance report saved: {comp_path}")

    sys.exit(0 if result.verdict != "FAIL" else 1)


if __name__ == "__main__":
    main()
