"""DALL-E 3 Adapter — OpenAI Images API.

Generates images via POST https://api.openai.com/v1/images/generations
Returns base64-decoded PNG bytes.
"""

import base64
import logging
import time

import httpx

from factory.brain.service_provider.adapters.base_adapter import BaseServiceAdapter, ServiceResult

logger = logging.getLogger(__name__)

API_BASE = "https://api.openai.com/v1/images/generations"
HEALTH_URL = "https://api.openai.com/v1/models"

COST_MAP = {
    ("1024x1024", "standard"): 0.04,
    ("1024x1024", "hd"): 0.08,
    ("1024x1792", "standard"): 0.08,
    ("1024x1792", "hd"): 0.12,
    ("1792x1024", "standard"): 0.08,
    ("1792x1024", "hd"): 0.12,
}

VALID_SIZES = {"1024x1024", "1024x1792", "1792x1024"}


class DalleAdapter(BaseServiceAdapter):

    def __init__(self, api_key: str):
        super().__init__("dalle3", api_key)

    def get_capabilities(self) -> list[str]:
        return ["text_to_image", "png_output", "transparent_bg", "max_1024x1024", "text_in_image"]

    def get_cost_estimate(self, specs: dict) -> float:
        size = specs.get("size", "1024x1024")
        quality = specs.get("quality", "standard")
        if size not in VALID_SIZES:
            size = "1024x1024"
        return COST_MAP.get((size, quality), 0.04)

    def health_check(self) -> bool:
        try:
            resp = httpx.get(
                HEALTH_URL,
                headers={"Authorization": f"Bearer {self._api_key}"},
                timeout=10.0,
            )
            return resp.status_code == 200
        except Exception:
            return False

    async def generate(self, prompt: str, specs: dict) -> ServiceResult:
        t0 = time.time()
        size = specs.get("size", "1024x1024")
        quality = specs.get("quality", "standard")
        style = specs.get("style", "natural")

        if size not in VALID_SIZES:
            size = "1024x1024"
        if quality not in ("standard", "hd"):
            quality = "standard"
        if style not in ("natural", "vivid"):
            style = "natural"

        body = {
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": size,
            "quality": quality,
            "style": style,
            "response_format": "b64_json",
        }

        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
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
            b64 = data["data"][0]["b64_json"]
            image_bytes = base64.b64decode(b64)
            revised_prompt = data["data"][0].get("revised_prompt", "")
            duration = int((time.time() - t0) * 1000)
            cost = COST_MAP.get((size, quality), 0.04)

            return ServiceResult(
                success=True,
                data=image_bytes,
                format="png",
                cost=cost,
                duration_ms=duration,
                service_id=self._service_id,
                metadata={"revised_prompt": revised_prompt, "size": size, "quality": quality},
            )

        except httpx.TimeoutException:
            duration = int((time.time() - t0) * 1000)
            logger.error("[DalleAdapter] Timeout after %dms", duration)
            return ServiceResult.failure(self._service_id, "Timeout", duration)
        except httpx.HTTPStatusError as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[DalleAdapter] HTTP %d: %s", e.response.status_code, e.response.text[:200])
            return ServiceResult.failure(self._service_id, f"HTTP {e.response.status_code}", duration)
        except Exception as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[DalleAdapter] Error: %s", e)
            return ServiceResult.failure(self._service_id, str(e), duration)
