"""Marketing Video Pipeline — Erzeugt Marketing-Videos mit FFmpeg.

Deterministisches Tool (kein LLM). Erzeugt:
- Slideshow aus Bildern (mit Uebergaengen)
- Video mit Audio-Track
- Video mit Text-Overlay
- Video trimmen
- Einfache Clips aus Einzelbild + Dauer

Alle Outputs als MP4 (H.264 + AAC).
"""

import json
import logging
import os
import shutil
import subprocess
from typing import Optional

logger = logging.getLogger("factory.marketing.tools.video_pipeline")

# --- Format-Definitionen ---

VIDEO_FORMATS = {
    "tiktok": {"width": 1080, "height": 1920, "label": "TikTok / Reels (9:16)"},
    "youtube": {"width": 1920, "height": 1080, "label": "YouTube (16:9)"},
    "square": {"width": 1080, "height": 1080, "label": "Social Square (1:1)"},
    "story": {"width": 1080, "height": 1920, "label": "Story (9:16)"},
    "landscape": {"width": 1280, "height": 720, "label": "Landscape 720p (16:9)"},
}

# --- FFmpeg Finder ---

_FFMPEG_PATH: Optional[str] = None

FFMPEG_SEARCH_PATHS = [
    # WinGet install location
    os.path.expanduser(
        "~/AppData/Local/Microsoft/WinGet/Packages/"
        "Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/"
        "ffmpeg-8.1-full_build/bin/ffmpeg.exe"
    ),
    # Common locations
    "C:/ffmpeg/bin/ffmpeg.exe",
    "/usr/bin/ffmpeg",
    "/usr/local/bin/ffmpeg",
]


def _find_ffmpeg() -> str:
    """Findet den FFmpeg-Binary-Pfad."""
    global _FFMPEG_PATH
    if _FFMPEG_PATH:
        return _FFMPEG_PATH

    # 1. Aus PATH
    ffmpeg_in_path = shutil.which("ffmpeg")
    if ffmpeg_in_path:
        _FFMPEG_PATH = ffmpeg_in_path
        return _FFMPEG_PATH

    # 2. Bekannte Pfade
    for p in FFMPEG_SEARCH_PATHS:
        if os.path.isfile(p):
            _FFMPEG_PATH = p
            return _FFMPEG_PATH

    raise FileNotFoundError(
        "FFmpeg not found. Install via: winget install Gyan.FFmpeg"
    )


def _run_ffmpeg(args: list[str], timeout: int = 120) -> subprocess.CompletedProcess:
    """Fuehrt FFmpeg mit den gegebenen Argumenten aus."""
    ffmpeg = _find_ffmpeg()
    cmd = [ffmpeg] + args
    logger.debug("Running: %s", " ".join(cmd))
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=timeout,
    )
    if result.returncode != 0:
        logger.error("FFmpeg error: %s", result.stderr[:500])
        raise RuntimeError(f"FFmpeg failed (rc={result.returncode}): {result.stderr[:300]}")
    return result


class MarketingVideoPipeline:
    """Erzeugt Marketing-Videos deterministisch mit FFmpeg."""

    def __init__(self, output_dir: Optional[str] = None) -> None:
        from factory.marketing.config import OUTPUT_PATH

        self.output_dir = output_dir or os.path.join(OUTPUT_PATH, "videos")
        os.makedirs(self.output_dir, exist_ok=True)
        self.ffmpeg_path = _find_ffmpeg()
        logger.info("VideoPipeline initialized, ffmpeg: %s, output: %s", self.ffmpeg_path, self.output_dir)

    def get_available_formats(self) -> dict:
        """Gibt alle verfuegbaren Video-Formate zurueck."""
        return dict(VIDEO_FORMATS)

    def images_to_video(
        self,
        image_paths: list[str],
        format_key: str = "youtube",
        duration_per_image: float = 3.0,
        fps: int = 30,
        fade_duration: float = 0.0,
        filename: Optional[str] = None,
    ) -> str:
        """Erzeugt ein Slideshow-Video aus Bildern.

        Args:
            image_paths: Liste von Bild-Pfaden (mind. 1)
            duration_per_image: Sekunden pro Bild
            fps: Frames pro Sekunde
            fade_duration: Dauer des Fade-to-Black in Sekunden (0 = kein Fade)

        Returns:
            Pfad zum erzeugten MP4.
        """
        if not image_paths:
            raise ValueError("image_paths must not be empty")

        fmt = VIDEO_FORMATS[format_key]
        w, h = fmt["width"], fmt["height"]

        # Concat-Datei erstellen
        concat_path = os.path.join(self.output_dir, "_concat_list.txt")
        with open(concat_path, "w", encoding="utf-8") as f:
            for img_path in image_paths:
                abs_path = os.path.abspath(img_path).replace("\\", "/")
                f.write(f"file '{abs_path}'\n")
                f.write(f"duration {duration_per_image}\n")
            # Letzes Bild nochmal ohne duration (FFmpeg concat Eigenheit)
            abs_path = os.path.abspath(image_paths[-1]).replace("\\", "/")
            f.write(f"file '{abs_path}'\n")

        fname = filename or f"slideshow_{format_key}.mp4"
        output_path = os.path.join(self.output_dir, fname)

        # Video-Filter: Scale + Pad + optionaler Fade
        scale_filter = f"scale={w}:{h}:force_original_aspect_ratio=decrease,pad={w}:{h}:(ow-iw)/2:(oh-ih)/2:black"
        if fade_duration > 0 and len(image_paths) > 1:
            # Fade-to-black am Ende jedes Segments
            fade_out_start = max(0, duration_per_image - fade_duration)
            vf = f"{scale_filter},fade=t=in:st=0:d={fade_duration},fade=t=out:st={fade_out_start}:d={fade_duration}"
        else:
            vf = scale_filter

        _run_ffmpeg([
            "-y",
            "-f", "concat",
            "-safe", "0",
            "-i", concat_path,
            "-vf", vf,
            "-c:v", "libx264",
            "-pix_fmt", "yuv420p",
            "-r", str(fps),
            "-movflags", "+faststart",
            output_path,
        ])

        # Cleanup
        os.remove(concat_path)

        logger.info("Created slideshow: %s (%dx%d, %d images, fade=%.1fs)", output_path, w, h, len(image_paths), fade_duration)
        return output_path

    def add_audio_to_video(
        self,
        video_path: str,
        audio_path: str,
        filename: Optional[str] = None,
    ) -> str:
        """Fuegt einen Audio-Track zu einem Video hinzu.

        Returns:
            Pfad zum erzeugten MP4.
        """
        fname = filename or "video_with_audio.mp4"
        output_path = os.path.join(self.output_dir, fname)

        _run_ffmpeg([
            "-y",
            "-i", video_path,
            "-i", audio_path,
            "-c:v", "copy",
            "-c:a", "aac",
            "-shortest",
            "-movflags", "+faststart",
            output_path,
        ])

        logger.info("Added audio to video: %s", output_path)
        return output_path

    def add_text_overlay(
        self,
        video_path: str,
        text: str,
        position: str = "center",
        font_size: int = 48,
        font_color: str = "white",
        filename: Optional[str] = None,
    ) -> str:
        """Fuegt ein Text-Overlay zu einem Video hinzu.

        Args:
            position: "center", "top", "bottom"

        Returns:
            Pfad zum erzeugten MP4.
        """
        # Drawtext Position
        if position == "top":
            pos_str = "x=(w-text_w)/2:y=h/10"
        elif position == "bottom":
            pos_str = "x=(w-text_w)/2:y=h-text_h-h/10"
        else:
            pos_str = "x=(w-text_w)/2:y=(h-text_h)/2"

        # Escape text for FFmpeg drawtext (colon and backslash)
        escaped = text.replace("\\", "\\\\").replace("'", "'\\''").replace(":", "\\:")

        # Font path for drawtext — Windows Pfade brauchen spezielle Escaping
        font_path = ""
        if os.path.isfile("C:/Windows/Fonts/arial.ttf"):
            # FFmpeg drawtext: Backslash vor Doppelpunkt, Forward-Slashes
            font_path = "C\\:/Windows/Fonts/arial.ttf"
        elif os.path.isfile("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"):
            font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

        fontfile_str = f":fontfile='{font_path}'" if font_path else ""

        drawtext = (
            f"drawtext=text='{escaped}'"
            f":fontsize={font_size}"
            f":fontcolor={font_color}"
            f"{fontfile_str}"
            f":{pos_str}"
        )

        fname = filename or "video_text_overlay.mp4"
        output_path = os.path.join(self.output_dir, fname)

        _run_ffmpeg([
            "-y",
            "-i", video_path,
            "-vf", drawtext,
            "-c:v", "libx264",
            "-c:a", "copy",
            "-movflags", "+faststart",
            output_path,
        ])

        logger.info("Added text overlay: %s", output_path)
        return output_path

    def trim_video(
        self,
        video_path: str,
        start_seconds: float = 0,
        duration_seconds: float = 5,
        filename: Optional[str] = None,
    ) -> str:
        """Schneidet einen Video-Ausschnitt.

        Returns:
            Pfad zum erzeugten MP4.
        """
        fname = filename or "trimmed.mp4"
        output_path = os.path.join(self.output_dir, fname)

        _run_ffmpeg([
            "-y",
            "-ss", str(start_seconds),
            "-i", video_path,
            "-t", str(duration_seconds),
            "-c:v", "libx264",
            "-c:a", "aac",
            "-movflags", "+faststart",
            output_path,
        ])

        logger.info("Trimmed video: %s (%.1fs from %.1fs)", output_path, duration_seconds, start_seconds)
        return output_path

    def create_simple_clip(
        self,
        image_path: str,
        duration: float = 5.0,
        format_key: str = "youtube",
        filename: Optional[str] = None,
    ) -> str:
        """Erzeugt einen einfachen Clip aus einem Einzelbild.

        Returns:
            Pfad zum erzeugten MP4.
        """
        fmt = VIDEO_FORMATS[format_key]
        w, h = fmt["width"], fmt["height"]

        fname = filename or f"clip_{format_key}.mp4"
        output_path = os.path.join(self.output_dir, fname)

        _run_ffmpeg([
            "-y",
            "-loop", "1",
            "-i", image_path,
            "-vf", f"scale={w}:{h}:force_original_aspect_ratio=decrease,pad={w}:{h}:(ow-iw)/2:(oh-ih)/2:black",
            "-c:v", "libx264",
            "-t", str(duration),
            "-pix_fmt", "yuv420p",
            "-movflags", "+faststart",
            output_path,
        ])

        logger.info("Created simple clip: %s (%dx%d, %.1fs)", output_path, w, h, duration)
        return output_path

    def add_subtitles(
        self,
        video_path: str,
        subtitles: list[dict],
        font_size: int = 32,
        font_color: str = "white",
        bg_opacity: float = 0.5,
        filename: Optional[str] = None,
    ) -> str:
        """Brennt Untertitel in ein Video ein.

        Args:
            subtitles: Liste von dicts:
                [{"start": 0.0, "end": 3.0, "text": "Hallo Welt"}, ...]
            font_size: Schriftgroesse
            font_color: Textfarbe (FFmpeg Name oder Hex)
            bg_opacity: Hintergrund-Opacity (0 = transparent)

        Returns:
            Pfad zum erzeugten MP4.
        """
        if not subtitles:
            raise ValueError("subtitles must not be empty")

        # SRT-Datei generieren
        srt_path = os.path.join(self.output_dir, "_subtitles.srt")
        with open(srt_path, "w", encoding="utf-8") as f:
            for i, sub in enumerate(subtitles, 1):
                start = self._seconds_to_srt_time(sub["start"])
                end = self._seconds_to_srt_time(sub["end"])
                text = sub["text"].replace("\n", "\\N")
                f.write(f"{i}\n{start} --> {end}\n{text}\n\n")

        fname = filename or "video_subtitled.mp4"
        output_path = os.path.join(self.output_dir, fname)

        # Versuche mit subtitles filter (ASS/SRT), Fallback auf drawtext
        srt_escaped = srt_path.replace("\\", "/").replace(":", "\\:")
        vf = f"subtitles='{srt_escaped}':force_style='FontSize={font_size},PrimaryColour=&Hffffff&,BackColour=&H80000000&'"

        try:
            _run_ffmpeg([
                "-y",
                "-i", video_path,
                "-vf", vf,
                "-c:v", "libx264",
                "-c:a", "copy",
                "-movflags", "+faststart",
                output_path,
            ])
        except RuntimeError:
            logger.warning("subtitles filter failed, falling back to drawtext")
            # Drawtext Fallback: Alle Untertitel als enable-Bereiche
            drawtext_parts = []
            for sub in subtitles:
                escaped_text = sub["text"].replace("'", "'\\''").replace(":", "\\:")
                enable_range = f"between(t,{sub['start']},{sub['end']})"
                dt = (
                    f"drawtext=text='{escaped_text}'"
                    f":fontsize={font_size}"
                    f":fontcolor={font_color}"
                    f":x=(w-text_w)/2:y=h-text_h-h/10"
                    f":enable='{enable_range}'"
                )
                drawtext_parts.append(dt)

            vf_fallback = ",".join(drawtext_parts)
            _run_ffmpeg([
                "-y",
                "-i", video_path,
                "-vf", vf_fallback,
                "-c:v", "libx264",
                "-c:a", "copy",
                "-movflags", "+faststart",
                output_path,
            ])

        # Cleanup
        if os.path.exists(srt_path):
            os.remove(srt_path)

        logger.info("Added subtitles: %s (%d segments)", output_path, len(subtitles))
        return output_path

    def concat_videos(
        self,
        video_paths: list[str],
        filename: Optional[str] = None,
    ) -> str:
        """Verbindet mehrere Videos zu einem.

        Alle Videos muessen denselben Codec/Format haben.
        Fuer unterschiedliche Formate werden sie re-encoded.

        Args:
            video_paths: Liste von Video-Pfaden (mind. 2)

        Returns:
            Pfad zum erzeugten MP4.
        """
        if len(video_paths) < 2:
            raise ValueError("concat_videos needs at least 2 videos")

        concat_path = os.path.join(self.output_dir, "_concat_videos.txt")
        with open(concat_path, "w", encoding="utf-8") as f:
            for vp in video_paths:
                abs_path = os.path.abspath(vp).replace("\\", "/")
                f.write(f"file '{abs_path}'\n")

        fname = filename or "concatenated.mp4"
        output_path = os.path.join(self.output_dir, fname)

        try:
            # Schneller Concat ohne Re-Encoding (stream copy)
            _run_ffmpeg([
                "-y",
                "-f", "concat",
                "-safe", "0",
                "-i", concat_path,
                "-c", "copy",
                "-movflags", "+faststart",
                output_path,
            ])
        except RuntimeError:
            logger.warning("Stream-copy concat failed, re-encoding")
            _run_ffmpeg([
                "-y",
                "-f", "concat",
                "-safe", "0",
                "-i", concat_path,
                "-c:v", "libx264",
                "-c:a", "aac",
                "-movflags", "+faststart",
                output_path,
            ])

        # Cleanup
        os.remove(concat_path)

        logger.info("Concatenated %d videos: %s", len(video_paths), output_path)
        return output_path

    @staticmethod
    def _seconds_to_srt_time(seconds: float) -> str:
        """Konvertiert Sekunden zu SRT-Zeitformat (HH:MM:SS,mmm)."""
        h = int(seconds // 3600)
        m = int((seconds % 3600) // 60)
        s = int(seconds % 60)
        ms = int((seconds % 1) * 1000)
        return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

    def get_video_info(self, video_path: str) -> dict:
        """Liest Video-Metadaten via ffprobe.

        Returns:
            Dict mit width, height, duration, codec, filesize.
        """
        # Nur den Dateinamen ersetzen, nicht den Verzeichnispfad
        ffmpeg_dir = os.path.dirname(self.ffmpeg_path)
        ffmpeg_name = os.path.basename(self.ffmpeg_path)
        ffprobe_name = ffmpeg_name.replace("ffmpeg", "ffprobe")
        ffprobe = os.path.join(ffmpeg_dir, ffprobe_name)
        if not os.path.isfile(ffprobe):
            ffprobe = shutil.which("ffprobe") or "ffprobe"

        cmd = [
            ffprobe,
            "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            "-show_streams",
            video_path,
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            raise RuntimeError(f"ffprobe failed: {result.stderr[:200]}")

        data = json.loads(result.stdout)
        info = {
            "filesize": os.path.getsize(video_path),
            "duration": 0.0,
            "width": 0,
            "height": 0,
            "codec": "",
        }

        fmt = data.get("format", {})
        info["duration"] = float(fmt.get("duration", 0))

        for stream in data.get("streams", []):
            if stream.get("codec_type") == "video":
                info["width"] = stream.get("width", 0)
                info["height"] = stream.get("height", 0)
                info["codec"] = stream.get("codec_name", "")
                break

        return info
