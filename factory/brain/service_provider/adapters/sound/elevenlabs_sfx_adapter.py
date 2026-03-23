"""ElevenLabs Sound Effects Adapter.

Generates sound effects via POST https://api.elevenlabs.io/v1/sound-generation
Returns raw MP3 bytes.
"""

import logging
import time

import httpx

from factory.brain.service_provider.adapters.base_adapter import BaseServiceAdapter, ServiceResult

logger = logging.getLogger(__name__)

API_BASE = "https://api.elevenlabs.io/v1/sound-generation"
HEALTH_URL = "https://api.elevenlabs.io/v1/user"


class ElevenLabsSfxAdapter(BaseServiceAdapter):

    def __init__(self, api_key: str):
        super().__init__("elevenlabs_sfx", api_key)

    def get_capabilities(self) -> list[str]:
        return ["text_to_sfx", "mp3_output", "wav_output", "max_22s"]

    def get_cost_estimate(self, specs: dict) -> float:
        return 0.01

    def health_check(self) -> bool:
        try:
            resp = httpx.get(
                HEALTH_URL,
                headers={"xi-api-key": self._api_key},
                timeout=10.0,
            )
            return resp.status_code == 200
        except Exception:
            return False

    async def generate(self, prompt: str, specs: dict) -> ServiceResult:
        t0 = time.time()
        duration_seconds = specs.get("duration_seconds")
        prompt_influence = specs.get("prompt_influence", 0.3)

        if duration_seconds is not None:
            duration_seconds = max(0.5, min(22.0, float(duration_seconds)))
        prompt_influence = max(0.0, min(1.0, float(prompt_influence)))

        body = {
            "text": prompt,
            "prompt_influence": prompt_influence,
        }
        if duration_seconds is not None:
            body["duration_seconds"] = duration_seconds

        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                resp = await client.post(
                    API_BASE,
                    json=body,
                    headers={
                        "xi-api-key": self._api_key,
                        "Content-Type": "application/json",
                    },
                )
                resp.raise_for_status()

            duration = int((time.time() - t0) * 1000)
            return ServiceResult(
                success=True,
                data=resp.content,
                format="mp3",
                cost=0.01,
                duration_ms=duration,
                service_id=self._service_id,
                metadata={"duration_seconds": duration_seconds, "prompt_influence": prompt_influence},
            )

        except httpx.TimeoutException:
            duration = int((time.time() - t0) * 1000)
            logger.error("[ElevenLabsSfx] Timeout after %dms", duration)
            return ServiceResult.failure(self._service_id, "Timeout", duration)
        except httpx.HTTPStatusError as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[ElevenLabsSfx] HTTP %d: %s", e.response.status_code, e.response.text[:200])
            return ServiceResult.failure(self._service_id, f"HTTP {e.response.status_code}", duration)
        except Exception as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[ElevenLabsSfx] Error: %s", e)
            return ServiceResult.failure(self._service_id, str(e), duration)
