"""SFX Generator — generates sound effects via TheBrain Service Router.

Handles categories: sfx, ui_sound, notification.
All API calls go through TheBrain — never calls ElevenLabs directly.
"""

import asyncio
import logging
import time
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class GenerationResult:
    """Result of a single sound generation."""
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
    error: str = ""

    def summary(self) -> str:
        if self.success:
            return (f"OK {self.sound_id} ({self.sound_name}): "
                    f"{self.service_used}, ${self.cost:.3f}, "
                    f"{self.file_size_bytes / 1024:.1f}KB, {self.audio_format}")
        return f"FAIL {self.sound_id} ({self.sound_name}): {self.error}"


@dataclass
class BatchResult:
    """Result of a batch generation run."""
    total_attempted: int = 0
    succeeded: int = 0
    failed: int = 0
    total_cost: float = 0.0
    results: list = field(default_factory=list)

    def summary(self) -> str:
        lines = [
            f"SFX Generation: {self.succeeded}/{self.total_attempted} succeeded",
            f"Total Cost: ${self.total_cost:.3f}",
            "",
        ]
        for r in self.results:
            lines.append(f"  {r.summary()}")
        return "\n".join(lines)


class SFXGenerator:
    """Generates sound effects via TheBrain Service Router."""

    SUPPORTED_CATEGORIES = {"sfx", "ui_sound", "notification"}

    def __init__(self, output_dir: str = None, max_cost_per_sound: float = 0.05,
                 max_cost_per_batch: float = 2.0, max_retries: int = 2):
        if output_dir is None:
            output_dir = str(Path(__file__).parent / "raw")
        self._output_dir = Path(output_dir)
        self._output_dir.mkdir(parents=True, exist_ok=True)
        self._max_cost_per_sound = max_cost_per_sound
        self._max_cost_per_batch = max_cost_per_batch
        self._max_retries = max_retries
        self._batch_cost = 0.0

    def generate_batch(self, prompts: list, priority_filter: str = None) -> BatchResult:
        """Generate a batch of SFX from SoundPrompt objects."""
        # Filter to supported categories
        filtered = [p for p in prompts if p.category in self.SUPPORTED_CATEGORIES]

        if priority_filter:
            # Need the original manifest to check priority — prompts don't carry it
            # Use estimated_cost as proxy: high priority prompts come first (sorted in builder)
            pass  # prompts are already sorted by priority from build_all_prompts

        batch = BatchResult()
        self._batch_cost = 0.0

        for prompt in filtered:
            # Budget check
            if self._batch_cost + prompt.estimated_cost > self._max_cost_per_batch:
                print(f"[SFXGen] Batch budget limit reached (${self._batch_cost:.3f}/${self._max_cost_per_batch:.2f}). Stopping.")
                break

            batch.total_attempted += 1
            print(f"[SFXGen] Generating {prompt.sound_id} ({prompt.sound_name})...")

            result = self.generate_single(prompt)
            batch.results.append(result)

            if result.success:
                batch.succeeded += 1
                batch.total_cost += result.cost
                self._batch_cost += result.cost
                print(f"  → {result.summary()}")
            else:
                batch.failed += 1
                print(f"  → {result.summary()}")

        return batch

    def generate_single(self, prompt) -> GenerationResult:
        """Generate a single sound effect via TheBrain Router."""
        sound_id = prompt.sound_id
        sound_name = prompt.sound_name
        category = prompt.category

        start_time = time.time()

        # Try generation with retries
        last_error = ""
        for attempt in range(self._max_retries + 1):
            service_result, error = self._execute_request(
                prompt.service_request, prompt.prompt_text
            )

            if error:
                last_error = error
                if attempt < self._max_retries:
                    print(f"  [SFXGen] Retry {attempt + 1}/{self._max_retries}: {error}")
                continue

            if service_result and service_result.success:
                elapsed = int((time.time() - start_time) * 1000)
                audio_data = service_result.data
                audio_format = service_result.format or "mp3"
                cost = service_result.cost or 0.01

                # Save raw audio
                file_path = self._save_audio(audio_data, sound_id, audio_format)

                # Report to quality scorer + cost tracker
                self._report_to_quality_scorer(
                    service_result.service_id, True, elapsed
                )
                self._report_to_cost_tracker(
                    service_result.service_id, cost, category, elapsed, True
                )

                return GenerationResult(
                    sound_id=sound_id,
                    sound_name=sound_name,
                    category=category,
                    success=True,
                    file_path=file_path,
                    service_used=service_result.service_id,
                    cost=cost,
                    duration_ms=elapsed,
                    file_size_bytes=len(audio_data) if audio_data else 0,
                    audio_format=audio_format,
                )
            else:
                err_msg = ""
                if service_result:
                    err_msg = service_result.error_message or "Unknown error"
                else:
                    err_msg = "No result from router"
                last_error = err_msg
                if attempt < self._max_retries:
                    print(f"  [SFXGen] Retry {attempt + 1}/{self._max_retries}: {err_msg}")

        # All retries exhausted
        elapsed = int((time.time() - start_time) * 1000)
        self._report_to_quality_scorer("unknown", False, elapsed, last_error)

        return GenerationResult(
            sound_id=sound_id,
            sound_name=sound_name,
            category=category,
            success=False,
            error=last_error,
            duration_ms=elapsed,
        )

    def _get_router(self):
        """Get TheBrain Service Router."""
        try:
            from factory.brain.service_provider.service_registry import ServiceRegistry
            from factory.brain.service_provider.service_router import ServiceRouter
            reg = ServiceRegistry()
            return ServiceRouter(reg)
        except Exception as e:
            logger.error("Could not get Service Router: %s", e)
            return None

    def _execute_request(self, service_request: dict, prompt_text: str) -> tuple:
        """Execute a ServiceRequest through TheBrain Router."""
        from dotenv import load_dotenv
        load_dotenv()

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

            # Route
            routing = router.route(req)
            if not routing:
                return None, "No service available for sound generation"

            print(f"  [SFXGen] Routed to: {routing.service_id} (${routing.estimated_cost:.3f})")

            # Execute async generate
            result = self._run_async(
                routing.primary_adapter.generate(prompt_text, req.specs)
            )
            return result, None

        except Exception as e:
            return None, f"Generation failed: {e}"

    def _run_async(self, coro):
        """Run async coroutine from sync context."""
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
        """Save raw audio bytes to file."""
        filename = f"{sound_id}_raw.{audio_format}"
        filepath = self._output_dir / filename
        filepath.write_bytes(audio_data)
        return str(filepath)

    def _report_to_quality_scorer(self, service_id: str, success: bool,
                                    duration_ms: int, error: str = ""):
        """Report to QualityScorer."""
        try:
            from factory.brain.service_provider.quality_scorer import QualityScorer

            class _MockResult:
                def __init__(self, sid, ok, dur, err):
                    self.service_id = sid
                    self.success = ok
                    self.duration_ms = dur
                    self.error_message = err

            scorer = QualityScorer()
            scorer.record_result(_MockResult(service_id, success, duration_ms, error), "sound")
        except Exception:
            pass  # Silent — QualityScorer is optional

    def _report_to_cost_tracker(self, service_id: str, cost: float,
                                  category: str, duration_ms: int, success: bool):
        """Report to CostTracker."""
        try:
            from factory.brain.service_provider.cost_tracker import ServiceCostTracker

            class _MockResult:
                def __init__(self, sid, c, dur, ok, err):
                    self.service_id = sid
                    self.cost = c
                    self.duration_ms = dur
                    self.success = ok
                    self.error_message = ""

            tracker = ServiceCostTracker()
            tracker.start_run(f"sfx_{category}", "sound_forge")
            tracker.record_call(_MockResult(service_id, cost, duration_ms, success, ""), category)
        except Exception:
            pass  # Silent — CostTracker is optional
