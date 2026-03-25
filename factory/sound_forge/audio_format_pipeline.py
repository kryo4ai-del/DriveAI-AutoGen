"""Audio Format Pipeline — converts and normalizes raw audio for all platforms.

Converts raw audio (typically MP3 from ElevenLabs) into:
- iOS: AAC (.m4a), 44100Hz
- Android: OGG (.ogg), 44100Hz
- Web: MP3 (.mp3), 44100Hz, 128kbps
- Unity: WAV (.wav), 44100Hz, 16bit

Also performs peak normalization and clipping detection.
"""

import hashlib
import logging
import os
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)


def _find_ffmpeg() -> str | None:
    """Find ffmpeg binary path."""
    # 1. Try imageio-ffmpeg (bundled binary)
    try:
        import imageio_ffmpeg
        path = imageio_ffmpeg.get_ffmpeg_exe()
        if path and os.path.exists(path):
            return path
    except ImportError:
        pass

    # 2. Try system PATH
    import shutil
    path = shutil.which("ffmpeg")
    if path:
        return path

    return None


def _configure_pydub(ffmpeg_path: str):
    """Configure pydub to use the found ffmpeg."""
    if not ffmpeg_path:
        return
    try:
        from pydub import AudioSegment
        AudioSegment.converter = ffmpeg_path
        AudioSegment.ffmpeg = ffmpeg_path
        AudioSegment.ffprobe = ffmpeg_path
    except ImportError:
        pass


FFMPEG_PATH = _find_ffmpeg()
if FFMPEG_PATH:
    # Set PATH BEFORE any pydub import so subprocess finds ffmpeg
    ffmpeg_dir = os.path.dirname(FFMPEG_PATH)
    if ffmpeg_dir not in os.environ.get("PATH", ""):
        os.environ["PATH"] = ffmpeg_dir + os.pathsep + os.environ.get("PATH", "")
    _configure_pydub(FFMPEG_PATH)


@dataclass
class ConvertedAudio:
    success: bool
    input_path: str
    output_path: str
    platform: str
    format: str
    file_size_bytes: int = 0
    checksum_md5: str = ""
    error: str = ""


@dataclass
class ProcessedSound:
    sound_id: str
    source_path: str
    normalized: bool = False
    clipping_detected: bool = False
    peak_db: float = 0.0
    conversions: list = field(default_factory=list)

    def all_succeeded(self) -> bool:
        return len(self.conversions) > 0 and all(c.success for c in self.conversions)

    def summary(self) -> str:
        ok = sum(1 for c in self.conversions if c.success)
        total_kb = sum(c.file_size_bytes for c in self.conversions if c.success) / 1024
        clip = " CLIP!" if self.clipping_detected else ""
        return (f"{'OK' if self.all_succeeded() else 'WARN'} {self.sound_id}: "
                f"{ok}/{len(self.conversions)} formats, {total_kb:.1f}KB, "
                f"peak={self.peak_db:.1f}dB{clip}")


@dataclass
class PipelineResult:
    total_input: int = 0
    total_processed: int = 0
    total_failed: int = 0
    total_conversions: int = 0
    total_size_bytes: int = 0
    sounds: list = field(default_factory=list)
    ffmpeg_available: bool = False

    def summary(self) -> str:
        lines = [
            "Audio Format Pipeline Results:",
            f"  ffmpeg: {'available' if self.ffmpeg_available else 'MISSING'}",
            f"  Input: {self.total_input}, Processed: {self.total_processed}, Failed: {self.total_failed}",
            f"  Conversions: {self.total_conversions}, Size: {self.total_size_bytes / 1024:.1f}KB",
            "",
        ]
        for s in self.sounds:
            lines.append(f"  {s.summary()}")
        return "\n".join(lines)


class AudioFormatPipeline:
    """Converts and normalizes audio files for all target platforms."""

    PLATFORM_FORMATS = {
        "ios":     {"ext": "m4a", "format_name": "ipod", "codec": "aac", "sample_rate": 44100, "bitrate": "128k"},
        "android": {"ext": "ogg", "format_name": "ogg", "codec": "libvorbis", "sample_rate": 44100, "bitrate": "128k"},
        "web":     {"ext": "mp3", "format_name": "mp3", "codec": "libmp3lame", "sample_rate": 44100, "bitrate": "128k"},
        "unity":   {"ext": "wav", "format_name": "wav", "codec": "pcm_s16le", "sample_rate": 44100, "bitrate": None},
    }

    SFX_TARGET_PEAK_DB = -1.0
    MAX_SFX_SIZE_KB = 500
    MAX_MUSIC_SIZE_KB = 5000

    def __init__(self, input_dir: str = None, output_dir: str = None):
        if input_dir is None:
            input_dir = str(Path(__file__).parent / "raw")
        if output_dir is None:
            output_dir = str(Path(__file__).parent / "processed")
        self._input_dir = Path(input_dir)
        self._output_dir = Path(output_dir)
        self._ffmpeg_available = FFMPEG_PATH is not None
        self._pydub_available = self._check_pydub()

    def _check_pydub(self) -> bool:
        try:
            from pydub import AudioSegment
            return True
        except ImportError:
            return False

    def process_all(self, sound_specs: list = None,
                     platforms: list = None) -> PipelineResult:
        """Process all raw audio files."""
        if platforms is None:
            platforms = list(self.PLATFORM_FORMATS.keys())

        result = PipelineResult(ffmpeg_available=self._ffmpeg_available)
        raw_files = self._find_raw_files()
        result.total_input = len(raw_files)

        if not raw_files:
            logger.warning("No raw audio files found in %s", self._input_dir)
            return result

        if not self._pydub_available:
            logger.error("pydub not available — copying raw files only")
            for path, sid in raw_files:
                ps = self._copy_raw_fallback(path, sid, platforms)
                result.sounds.append(ps)
                result.total_processed += 1
            return result

        for path, sid in raw_files:
            category = self._get_category_for_sound(sid, sound_specs)
            try:
                ps = self.process_single(path, sid, category, platforms)
                result.sounds.append(ps)
                result.total_processed += 1
                for c in ps.conversions:
                    if c.success:
                        result.total_conversions += 1
                        result.total_size_bytes += c.file_size_bytes
                    else:
                        result.total_failed += 1
            except Exception as e:
                logger.error("Failed to process %s: %s", sid, e)
                result.total_failed += 1

        return result

    def process_single(self, audio_path: str, sound_id: str,
                        category: str = "sfx",
                        platforms: list = None) -> ProcessedSound:
        """Process a single audio file."""
        if platforms is None:
            platforms = list(self.PLATFORM_FORMATS.keys())

        ps = ProcessedSound(sound_id=sound_id, source_path=audio_path)
        audio = self._load_audio(audio_path)

        if audio is None:
            ps.conversions = [ConvertedAudio(
                success=False, input_path=audio_path, output_path="",
                platform="all", format="", error="Could not load audio"
            )]
            return ps

        # Normalization
        ps.peak_db = audio.max_dBFS
        ps.clipping_detected = self._detect_clipping(audio)

        if ps.clipping_detected:
            logger.warning("%s: Clipping detected (peak=%.1f dBFS)", sound_id, ps.peak_db)

        audio = self._normalize_peak(audio, self.SFX_TARGET_PEAK_DB)
        ps.normalized = True
        ps.peak_db = audio.max_dBFS

        # Convert to each platform
        for platform in platforms:
            conv = self._convert_format(audio, sound_id, platform)
            ps.conversions.append(conv)

            # Size warnings
            if conv.success:
                size_kb = conv.file_size_bytes / 1024
                limit = self.MAX_MUSIC_SIZE_KB if category in ("ambient", "music") else self.MAX_SFX_SIZE_KB
                if size_kb > limit:
                    logger.warning("%s/%s: %s file size %.0fKB > %dKB limit",
                                   sound_id, platform, conv.format, size_kb, limit)

        return ps

    def _load_audio(self, path: str):
        """Load audio with pydub, using explicit ffmpeg path."""
        try:
            from pydub import AudioSegment
            if FFMPEG_PATH:
                AudioSegment.converter = FFMPEG_PATH
                AudioSegment.ffmpeg = FFMPEG_PATH
                AudioSegment.ffprobe = FFMPEG_PATH
            return AudioSegment.from_file(path, format=Path(path).suffix.lstrip('.'))
        except Exception as e:
            logger.error("Could not load %s: %s", path, e)
            # Fallback: try raw ffmpeg conversion to wav first
            if FFMPEG_PATH:
                return self._load_via_ffmpeg_subprocess(path)
            return None

    def _load_via_ffmpeg_subprocess(self, path: str):
        """Load audio by converting to WAV via ffmpeg subprocess, then loading."""
        import subprocess
        import tempfile
        try:
            from pydub import AudioSegment
            tmp = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
            tmp.close()
            subprocess.run(
                [FFMPEG_PATH, "-y", "-i", path, "-ar", "44100", "-ac", "1", tmp.name],
                capture_output=True, timeout=30
            )
            audio = AudioSegment.from_wav(tmp.name)
            os.unlink(tmp.name)
            return audio
        except Exception as e:
            logger.error("ffmpeg subprocess fallback failed for %s: %s", path, e)
            return None

    def _normalize_peak(self, audio, target_db: float = -1.0):
        """Peak-normalize audio."""
        try:
            if audio.max_dBFS == float('-inf'):
                return audio  # Silent audio
            change = target_db - audio.max_dBFS
            return audio.apply_gain(change)
        except Exception as e:
            logger.warning("Normalization failed: %s", e)
            return audio

    def _detect_clipping(self, audio) -> bool:
        """Check for clipping."""
        try:
            return audio.max_dBFS >= -0.1
        except Exception:
            return False

    def _convert_format(self, audio, sound_id: str, platform: str) -> ConvertedAudio:
        """Convert audio to a specific platform format."""
        spec = self.PLATFORM_FORMATS.get(platform)
        if not spec:
            return ConvertedAudio(
                success=False, input_path="", output_path="",
                platform=platform, format="", error=f"Unknown platform: {platform}"
            )

        # Create output directory
        out_dir = self._output_dir / platform
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / f"{sound_id}.{spec['ext']}"

        try:
            from pydub import AudioSegment

            export_params = {
                "format": spec["format_name"],
            }

            # Add codec and bitrate where applicable
            params = ["-ar", str(spec["sample_rate"])]
            if spec["codec"]:
                params.extend(["-acodec", spec["codec"]])
            if spec["bitrate"]:
                params.extend(["-b:a", spec["bitrate"]])

            export_params["parameters"] = params

            audio.export(str(out_path), **export_params)

            file_size = out_path.stat().st_size
            checksum = self._calculate_checksum(str(out_path))

            return ConvertedAudio(
                success=True, input_path="", output_path=str(out_path),
                platform=platform, format=spec["ext"],
                file_size_bytes=file_size, checksum_md5=checksum,
            )

        except Exception as e:
            # Fallback: try simpler export without codec params
            try:
                if spec["format_name"] == "wav":
                    audio.export(str(out_path), format="wav")
                elif spec["format_name"] == "mp3":
                    audio.export(str(out_path), format="mp3")
                else:
                    raise e

                file_size = out_path.stat().st_size
                checksum = self._calculate_checksum(str(out_path))
                return ConvertedAudio(
                    success=True, input_path="", output_path=str(out_path),
                    platform=platform, format=spec["ext"],
                    file_size_bytes=file_size, checksum_md5=checksum,
                )
            except Exception as e2:
                return ConvertedAudio(
                    success=False, input_path="", output_path=str(out_path),
                    platform=platform, format=spec["ext"],
                    error=f"{e} / fallback: {e2}",
                )

    def _calculate_checksum(self, file_path: str) -> str:
        md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(8192), b""):
                md5.update(chunk)
        return md5.hexdigest()

    def _find_raw_files(self) -> list:
        """Find all audio files in raw/ directory."""
        files = []
        extensions = {".mp3", ".wav", ".m4a", ".ogg", ".flac"}

        for path in sorted(self._input_dir.rglob("*")):
            if path.suffix.lower() in extensions and path.is_file():
                # Extract sound_id: SFX-001_raw.mp3 → SFX-001
                name = path.stem
                if name.endswith("_raw"):
                    name = name[:-4]
                files.append((str(path), name))

        return files

    def _get_category_for_sound(self, sound_id: str, specs: list = None) -> str:
        """Determine category from sound_id prefix."""
        if specs:
            for s in specs:
                sid = getattr(s, 'sound_id', '') if not isinstance(s, dict) else s.get('sound_id', '')
                if sid == sound_id:
                    return getattr(s, 'category', 'sfx') if not isinstance(s, dict) else s.get('category', 'sfx')

        sid_upper = sound_id.upper()
        if sid_upper.startswith("SFX"):
            return "sfx"
        if sid_upper.startswith("AMB"):
            return "ambient"
        if sid_upper.startswith("MUS"):
            return "music"
        if sid_upper.startswith("UI"):
            return "ui_sound"
        if sid_upper.startswith("NOT"):
            return "notification"
        return "sfx"

    def _copy_raw_fallback(self, path: str, sound_id: str, platforms: list) -> ProcessedSound:
        """Fallback: copy raw file to each platform dir without conversion."""
        import shutil
        ps = ProcessedSound(sound_id=sound_id, source_path=path)
        src = Path(path)

        for platform in platforms:
            out_dir = self._output_dir / platform
            out_dir.mkdir(parents=True, exist_ok=True)
            dest = out_dir / f"{sound_id}{src.suffix}"
            try:
                shutil.copy2(str(src), str(dest))
                ps.conversions.append(ConvertedAudio(
                    success=True, input_path=path, output_path=str(dest),
                    platform=platform, format=src.suffix.lstrip('.'),
                    file_size_bytes=dest.stat().st_size,
                    checksum_md5=self._calculate_checksum(str(dest)),
                ))
            except Exception as e:
                ps.conversions.append(ConvertedAudio(
                    success=False, input_path=path, output_path=str(dest),
                    platform=platform, format=src.suffix.lstrip('.'),
                    error=str(e),
                ))

        return ps
