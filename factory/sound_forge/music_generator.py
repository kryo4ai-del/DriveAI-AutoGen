"""Music/Ambient Generator — generates longer audio via TheBrain Service Router.

Handles categories: ambient, music.
Ambient: atmospheric loops, typically 10-22s (ElevenLabs limit)
Music: background tracks, potentially longer (needs Suno or manual)

Reuses SFXGenerator internals for routing + API execution.
"""

import asyncio
import logging
import time
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class MusicGenerationResult:
    sound_id: str
    sound_name: str
    category: str
    success: bool
    file_path: str = ""
    service_used: str = ""
    cost: float = 0.0
    duration_ms: int = 0
    file_size_bytes: int = 0
    audio_format: str = ""
    loop_check: str = ""          # "pass", "warn", "skip", ""
    needs_manual: bool = False
    error: str = ""

    def summary(self) -> str:
        if self.needs_manual:
            return f"MANUAL {self.sound_id} ({self.sound_name}): needs manual creation ({self.error})"
        if self.success:
            loop_str = f" loop={self.loop_check}" if self.loop_check else ""
            return (f"OK {self.sound_id} ({self.sound_name}): "
                    f"{self.service_used}, ${self.cost:.3f}, "
                    f"{self.file_size_bytes / 1024:.1f}KB{loop_str}")
        return f"FAIL {self.sound_id} ({self.sound_name}): {self.error}"


@dataclass
class MusicBatchResult:
    total_attempted: int = 0
    succeeded: int = 0
    failed: int = 0
    needs_manual: int = 0
    total_cost: float = 0.0
    results: list = field(default_factory=list)

    def summary(self) -> str:
        lines = [
            f"Music/Ambient Generation: {self.succeeded}/{self.total_attempted} succeeded"
            f" ({self.needs_manual} need manual)",
            f"Total Cost: ${self.total_cost:.3f}",
            "",
        ]
        for r in self.results:
            lines.append(f"  {r.summary()}")
        return "\n".join(lines)


class MusicGenerator:
    """Generates ambient and music audio via TheBrain Service Router."""

    SUPPORTED_CATEGORIES = {"ambient", "music"}
    ELEVENLABS_MAX_DURATION_S = 22.0

    def __init__(self, output_dir: str = None, max_cost_per_sound: float = 0.10,
                 max_cost_per_batch: float = 2.0, max_retries: int = 2):
        if output_dir is None:
            output_dir = str(Path(__file__).parent / "raw" / "music")
        self._output_dir = Path(output_dir)
        self._output_dir.mkdir(parents=True, exist_ok=True)
        self._max_cost_per_sound = max_cost_per_sound
        self._max_cost_per_batch = max_cost_per_batch
        self._max_retries = max_retries
        self._batch_cost = 0.0

    def generate_batch(self, prompts: list, priority_filter: str = None) -> MusicBatchResult:
        """Generate a batch of ambient/music from SoundPrompt objects."""
        filtered = [p for p in prompts if p.category in self.SUPPORTED_CATEGORIES]

        batch = MusicBatchResult()
        self._batch_cost = 0.0
        caps = self._check_service_capabilities()

        for prompt in filtered:
            if self._batch_cost + prompt.estimated_cost > self._max_cost_per_batch:
                print(f"[MusicGen] Batch budget limit reached (${self._batch_cost:.3f}/${self._max_cost_per_batch:.2f})")
                break

            batch.total_attempted += 1
            print(f"[MusicGen] Generating {prompt.sound_id} ({prompt.sound_name}, {prompt.category})...")

            result = self.generate_single(prompt, caps)
            batch.results.append(result)

            if result.needs_manual:
                batch.needs_manual += 1
                print(f"  -> {result.summary()}")
            elif result.success:
                batch.succeeded += 1
                batch.total_cost += result.cost
                self._batch_cost += result.cost
                print(f"  -> {result.summary()}")
            else:
                batch.failed += 1
                print(f"  -> {result.summary()}")

        return batch

    def generate_single(self, prompt, caps: dict = None) -> MusicGenerationResult:
        """Generate a single ambient/music track."""
        if caps is None:
            caps = self._check_service_capabilities()

        sound_id = prompt.sound_id
        sound_name = prompt.sound_name
        category = prompt.category
        requested_duration = prompt.duration_hint_ms / 1000.0

        # Check if music category needs text_to_music (Suno)
        if category == "music" and not caps["has_music"]:
            # No music service — can we use SFX service for short music?
            if requested_duration <= self.ELEVENLABS_MAX_DURATION_S and caps["has_sfx"]:
                print(f"  [MusicGen] Music routed to SFX service (duration {requested_duration}s <= {self.ELEVENLABS_MAX_DURATION_S}s)")
            else:
                return MusicGenerationResult(
                    sound_id=sound_id, sound_name=sound_name, category=category,
                    success=False, needs_manual=True,
                    error=f"No music service available, duration {requested_duration}s > ElevenLabs limit {self.ELEVENLABS_MAX_DURATION_S}s",
                )

        # Clamp duration for ElevenLabs
        actual_duration = requested_duration
        clamped = False
        if not caps["has_music"] and actual_duration > self.ELEVENLABS_MAX_DURATION_S:
            actual_duration = self.ELEVENLABS_MAX_DURATION_S
            clamped = True
            print(f"  [MusicGen] Duration clamped: {requested_duration}s -> {actual_duration}s (ElevenLabs limit)")

        # Update service request with clamped duration
        modified_request = dict(prompt.service_request)
        modified_specs = dict(modified_request.get("specs", {}))
        modified_specs["duration_seconds"] = actual_duration
        # For ambient via ElevenLabs: use text_to_sfx capability
        if category == "ambient" and not caps["has_music"]:
            modified_request["required_capabilities"] = ["text_to_sfx"]
        modified_request["specs"] = modified_specs

        start_time = time.time()
        last_error = ""

        for attempt in range(self._max_retries + 1):
            service_result, error = self._execute_request(modified_request, prompt.prompt_text)

            if error:
                last_error = error
                if attempt < self._max_retries:
                    print(f"  [MusicGen] Retry {attempt + 1}/{self._max_retries}: {error}")
                continue

            if service_result and service_result.success:
                elapsed = int((time.time() - start_time) * 1000)
                audio_data = service_result.data
                audio_format = service_result.format or "mp3"
                cost = service_result.cost or 0.01

                file_path = self._save_audio(audio_data, sound_id, audio_format)

                # Loop check for ambient/looping sounds
                loop_status = ""
                tech = getattr(prompt, 'service_request', {}).get('specs', {})
                # Check original spec for loop_seamless via the prompt
                if category == "ambient":
                    loop_ok = self._check_loop_seamless(file_path)
                    loop_status = "pass" if loop_ok else "warn"
                    if not loop_ok:
                        print(f"  [MusicGen] Loop check: WARN — may not loop seamlessly")

                self._report_to_quality_scorer(service_result.service_id, True, elapsed)
                self._report_to_cost_tracker(service_result.service_id, cost, category, elapsed, True)

                return MusicGenerationResult(
                    sound_id=sound_id, sound_name=sound_name, category=category,
                    success=True, file_path=file_path, service_used=service_result.service_id,
                    cost=cost, duration_ms=elapsed,
                    file_size_bytes=len(audio_data) if audio_data else 0,
                    audio_format=audio_format, loop_check=loop_status,
                )
            else:
                err = service_result.error_message if service_result else "No result"
                last_error = err
                if attempt < self._max_retries:
                    print(f"  [MusicGen] Retry {attempt + 1}/{self._max_retries}: {err}")

        elapsed = int((time.time() - start_time) * 1000)
        return MusicGenerationResult(
            sound_id=sound_id, sound_name=sound_name, category=category,
            success=False, error=last_error, duration_ms=elapsed,
        )

    def _check_loop_seamless(self, audio_path: str) -> bool:
        """Basic loop seamlessness heuristic using pydub."""
        try:
            from pydub import AudioSegment
            audio = AudioSegment.from_file(audio_path)
            if len(audio) < 200:
                return True  # Too short to check

            first_100ms = audio[:100]
            last_100ms = audio[-100:]

            rms_first = first_100ms.rms
            rms_last = last_100ms.rms

            if rms_first == 0 and rms_last == 0:
                return True  # Both silent — perfect loop

            if rms_first == 0 or rms_last == 0:
                return False  # One silent, one not — bad loop

            ratio = max(rms_first, rms_last) / max(min(rms_first, rms_last), 1)
            return ratio < 2.0  # Within 2x RMS = likely loopable

        except ImportError:
            logger.warning("pydub not available — skipping loop check")
            return True
        except Exception as e:
            logger.warning("Loop check failed: %s", e)
            return True  # Assume OK on error

    def _check_service_capabilities(self) -> dict:
        """Check what sound services are available."""
        from dotenv import load_dotenv
        load_dotenv()

        result = {
            "has_sfx": False,
            "has_music": False,
            "max_sfx_duration_s": 22,
            "max_music_duration_s": 240,
        }

        try:
            from factory.brain.service_provider.service_registry import ServiceRegistry
            reg = ServiceRegistry()
            active = reg.get_active_services("sound")
            for s in active:
                caps = set(s.capabilities)
                if "text_to_sfx" in caps:
                    result["has_sfx"] = True
                if "text_to_music" in caps:
                    result["has_music"] = True
        except Exception as e:
            logger.warning("Could not check service capabilities: %s", e)

        return result

    def _get_router(self):
        from dotenv import load_dotenv
        load_dotenv()
        try:
            from factory.brain.service_provider.service_registry import ServiceRegistry
            from factory.brain.service_provider.service_router import ServiceRouter
            return ServiceRouter(ServiceRegistry())
        except Exception as e:
            logger.error("Could not get Service Router: %s", e)
            return None

    def _execute_request(self, service_request: dict, prompt_text: str) -> tuple:
        router = self._get_router()
        if not router:
            return None, "TheBrain Service Router not available"

        try:
            from factory.brain.service_provider.service_router import ServiceRequest
            req = ServiceRequest(
                category=service_request.get("category", "sound"),
                required_capabilities=service_request.get("required_capabilities", ["text_to_sfx"]),
                specs=service_request.get("specs", {}),
                budget_limit=service_request.get("budget_limit", self._max_cost_per_sound),
                preferred_service=service_request.get("preferred_service"),
                quality_minimum=service_request.get("quality_minimum", 0.0),
            )

            routing = router.route(req)
            if not routing:
                return None, "No service available for sound generation"

            print(f"  [MusicGen] Routed to: {routing.service_id} (${routing.estimated_cost:.3f})")
            result = self._run_async(routing.primary_adapter.generate(prompt_text, req.specs))
            return result, None

        except Exception as e:
            return None, f"Generation failed: {e}"

    def _run_async(self, coro):
        try:
            loop = asyncio.get_event_loop()
            if loop.is_running():
                import concurrent.futures
                with concurrent.futures.ThreadPoolExecutor() as pool:
                    return pool.submit(asyncio.run, coro).result()
            else:
                return loop.run_until_complete(coro)
        except RuntimeError:
            return asyncio.run(coro)

    def _save_audio(self, audio_data: bytes, sound_id: str, audio_format: str) -> str:
        filename = f"{sound_id}_raw.{audio_format}"
        filepath = self._output_dir / filename
        filepath.write_bytes(audio_data)
        return str(filepath)

    def _report_to_quality_scorer(self, service_id, success, duration_ms, error=""):
        try:
            from factory.brain.service_provider.quality_scorer import QualityScorer

            class _R:
                def __init__(self, sid, ok, dur, err):
                    self.service_id, self.success, self.duration_ms, self.error_message = sid, ok, dur, err

            QualityScorer().record_result(_R(service_id, success, duration_ms, error), "sound")
        except Exception:
            pass

    def _report_to_cost_tracker(self, service_id, cost, category, duration_ms, success):
        try:
            from factory.brain.service_provider.cost_tracker import ServiceCostTracker

            class _R:
                def __init__(self, sid, c, dur, ok):
                    self.service_id, self.cost, self.duration_ms, self.success, self.error_message = sid, c, dur, ok, ""

            t = ServiceCostTracker()
            t.start_run(f"music_{category}", "sound_forge")
            t.record_call(_R(service_id, cost, duration_ms, success), category)
        except Exception:
            pass
