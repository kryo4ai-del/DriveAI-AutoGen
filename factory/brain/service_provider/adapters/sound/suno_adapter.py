"""Suno AI Adapter — Music and ambient audio generation.

Generates music/ambient via POST https://studio-api.suno.ai/api/external/generate
Returns MP3 bytes.
"""

import base64
import logging
import time

import httpx

from factory.brain.service_provider.adapters.base_adapter import BaseServiceAdapter, ServiceResult

logger = logging.getLogger(__name__)

API_BASE = "https://studio-api.suno.ai/api/external/generate"


class SunoAdapter(BaseServiceAdapter):

    def __init__(self, api_key: str):
        super().__init__("suno_ai", api_key)

    def get_capabilities(self) -> list[str]:
        return ["text_to_music", "ambient_generation", "mp3_output", "max_240s", "genre_control"]

    def get_cost_estimate(self, specs: dict) -> float:
        return 0.05

    def health_check(self) -> bool:
        try:
            resp = httpx.get(
                API_BASE,
                headers={"Authorization": f"Bearer {self._api_key}"},
                timeout=10.0,
            )
            return True  # Reachable if any HTTP response
        except Exception:
            return False

    async def generate(self, prompt: str, specs: dict) -> ServiceResult:
        t0 = time.time()
        duration_seconds = specs.get("duration_seconds", 30)
        duration_seconds = max(5, min(240, int(duration_seconds)))
        genre = specs.get("genre")
        instrumental = specs.get("instrumental", True)

        full_prompt = prompt
        if genre:
            full_prompt = f"{genre} style: {prompt}"

        body = {
            "prompt": full_prompt,
            "make_instrumental": instrumental,
            "wait_audio": True,
        }

        try:
            async with httpx.AsyncClient(timeout=120.0) as client:
                resp = await client.post(
                    API_BASE,
                    json=body,
                    headers={
                        "Authorization": f"Bearer {self._api_key}",
                        "Content-Type": "application/json",
                    },
                )
                resp.raise_for_status()

            data = resp.json()
            duration = int((time.time() - t0) * 1000)

            # Extract audio — try audio_url first, then base64
            audio_bytes = None
            if isinstance(data, list) and len(data) > 0:
                item = data[0]
            elif isinstance(data, dict):
                item = data
            else:
                return ServiceResult.failure(self._service_id, "Unexpected response format", duration)

            audio_url = item.get("audio_url")
            audio_b64 = item.get("audio")

            if audio_url:
                async with httpx.AsyncClient(timeout=30.0) as dl:
                    audio_resp = await dl.get(audio_url)
                    audio_resp.raise_for_status()
                    audio_bytes = audio_resp.content
            elif audio_b64:
                audio_bytes = base64.b64decode(audio_b64)

            if not audio_bytes:
                return ServiceResult.failure(self._service_id, "No audio in response", duration)

            return ServiceResult(
                success=True,
                data=audio_bytes,
                format="mp3",
                cost=0.05,
                duration_ms=duration,
                service_id=self._service_id,
                metadata={"genre": genre, "instrumental": instrumental, "duration_target": duration_seconds},
            )

        except httpx.TimeoutException:
            duration = int((time.time() - t0) * 1000)
            logger.error("[SunoAdapter] Timeout after %dms", duration)
            return ServiceResult.failure(self._service_id, "Timeout", duration)
        except httpx.HTTPStatusError as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[SunoAdapter] HTTP %d: %s", e.response.status_code, e.response.text[:200])
            return ServiceResult.failure(self._service_id, f"HTTP {e.response.status_code}", duration)
        except Exception as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[SunoAdapter] Error: %s", e)
            return ServiceResult.failure(self._service_id, str(e), duration)
