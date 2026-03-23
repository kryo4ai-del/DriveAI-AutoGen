"""Runway ML Gen-3 Adapter — Video generation from image or text.

Submits generation task via POST, then polls for completion.
Returns MP4 bytes.
"""

import logging
import time

import httpx

from factory.brain.service_provider.adapters.base_adapter import BaseServiceAdapter, ServiceResult

logger = logging.getLogger(__name__)

API_BASE = "https://api.dev.runwayml.com/v1"
POLL_INTERVAL = 5
MAX_POLL_SECONDS = 120


class RunwayAdapter(BaseServiceAdapter):

    def __init__(self, api_key: str):
        super().__init__("runway_ml", api_key)

    def get_capabilities(self) -> list[str]:
        return ["image_to_video", "text_to_video", "mp4_output", "max_10s"]

    def get_cost_estimate(self, specs: dict) -> float:
        duration = specs.get("duration_seconds", 5)
        return 0.20 if int(duration) >= 10 else 0.10

    def health_check(self) -> bool:
        try:
            resp = httpx.get(
                f"{API_BASE}",
                headers={
                    "Authorization": f"Bearer {self._api_key}",
                    "X-Runway-Version": "2024-11-06",
                },
                timeout=10.0,
            )
            return True  # Reachable if any HTTP response
        except Exception:
            return False

    async def generate(self, prompt: str, specs: dict) -> ServiceResult:
        t0 = time.time()
        duration_s = specs.get("duration_seconds", 5)
        duration_s = 10 if int(duration_s) >= 10 else 5
        aspect_ratio = specs.get("aspect_ratio", "16:9")
        image_base64 = specs.get("image_base64")

        if aspect_ratio not in ("16:9", "9:16"):
            aspect_ratio = "16:9"

        body = {
            "promptText": prompt,
            "duration": duration_s,
            "ratio": aspect_ratio,
            "model": "gen3a_turbo",
        }
        if image_base64:
            body["promptImage"] = image_base64

        headers = {
            "Authorization": f"Bearer {self._api_key}",
            "Content-Type": "application/json",
            "X-Runway-Version": "2024-11-06",
        }

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.post(
                    f"{API_BASE}/image_to_video",
                    json=body,
                    headers=headers,
                )
                resp.raise_for_status()

            task_data = resp.json()
            task_id = task_data.get("id")
            if not task_id:
                duration = int((time.time() - t0) * 1000)
                return ServiceResult.failure(self._service_id, "No task ID in response", duration)

            # Poll for completion
            video_bytes = await self._poll_task(task_id, headers)
            duration = int((time.time() - t0) * 1000)

            if video_bytes is None:
                return ServiceResult.failure(self._service_id, "Polling timeout or failure", duration)

            cost = 0.20 if duration_s >= 10 else 0.10
            return ServiceResult(
                success=True,
                data=video_bytes,
                format="mp4",
                cost=cost,
                duration_ms=duration,
                service_id=self._service_id,
                metadata={"duration_seconds": duration_s, "aspect_ratio": aspect_ratio, "task_id": task_id},
            )

        except httpx.TimeoutException:
            duration = int((time.time() - t0) * 1000)
            logger.error("[RunwayAdapter] Timeout after %dms", duration)
            return ServiceResult.failure(self._service_id, "Timeout", duration)
        except httpx.HTTPStatusError as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[RunwayAdapter] HTTP %d: %s", e.response.status_code, e.response.text[:200])
            return ServiceResult.failure(self._service_id, f"HTTP {e.response.status_code}", duration)
        except Exception as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[RunwayAdapter] Error: %s", e)
            return ServiceResult.failure(self._service_id, str(e), duration)

    async def _poll_task(self, task_id: str, headers: dict) -> bytes | None:
        """Poll task status until SUCCEEDED or timeout."""
        deadline = time.time() + MAX_POLL_SECONDS
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                while time.time() < deadline:
                    resp = await client.get(
                        f"{API_BASE}/tasks/{task_id}",
                        headers=headers,
                    )
                    resp.raise_for_status()
                    data = resp.json()
                    status = data.get("status", "")

                    if status == "SUCCEEDED":
                        output_url = None
                        output = data.get("output", [])
                        if isinstance(output, list) and output:
                            output_url = output[0]
                        elif isinstance(output, str):
                            output_url = output
                        if output_url:
                            vid_resp = await client.get(output_url)
                            vid_resp.raise_for_status()
                            return vid_resp.content
                        return None

                    if status in ("FAILED", "CANCELLED"):
                        failure = data.get("failure", "Unknown failure")
                        logger.error("[RunwayAdapter] Task %s: %s — %s", task_id, status, failure)
                        return None

                    import asyncio
                    await asyncio.sleep(POLL_INTERVAL)

        except Exception as e:
            logger.error("[RunwayAdapter] Polling error: %s", e)
        return None
