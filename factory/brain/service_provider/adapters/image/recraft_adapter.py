"""Recraft v3 Adapter — SVG + PNG image generation.

Generates images/vectors via POST https://external.api.recraft.ai/v1/images/generations
Returns base64-decoded PNG or SVG bytes.
"""

import base64
import logging
import time

import httpx

from factory.brain.service_provider.adapters.base_adapter import BaseServiceAdapter, ServiceResult

logger = logging.getLogger(__name__)

API_BASE = "https://external.api.recraft.ai/v1/images/generations"

VALID_STYLES = {"realistic_image", "digital_illustration", "vector_illustration", "icon"}


class RecraftAdapter(BaseServiceAdapter):

    def __init__(self, api_key: str):
        super().__init__("recraft_v3", api_key)

    def get_capabilities(self) -> list[str]:
        return ["text_to_image", "svg_output", "png_output", "vector_icons", "style_control"]

    def get_cost_estimate(self, specs: dict) -> float:
        return 0.02

    def health_check(self) -> bool:
        try:
            resp = httpx.get(
                API_BASE,
                headers={"Authorization": f"Bearer {self._api_key}"},
                timeout=10.0,
            )
            # Reachable if we get any HTTP response (even 401/403)
            return True
        except Exception:
            return False

    async def generate(self, prompt: str, specs: dict) -> ServiceResult:
        t0 = time.time()
        output_format = specs.get("output_format", "png")
        style = specs.get("style", "realistic_image")
        size = specs.get("size", "1024x1024")

        if output_format not in ("svg", "png"):
            output_format = "png"
        if style not in VALID_STYLES:
            style = "realistic_image"

        body = {
            "prompt": prompt,
            "style": style,
            "model": "recraftv3",
            "size": size,
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
            decoded = base64.b64decode(b64)
            duration = int((time.time() - t0) * 1000)

            return ServiceResult(
                success=True,
                data=decoded,
                format=output_format,
                cost=0.02,
                duration_ms=duration,
                service_id=self._service_id,
                metadata={"style": style, "size": size, "output_format": output_format},
            )

        except httpx.TimeoutException:
            duration = int((time.time() - t0) * 1000)
            logger.error("[RecraftAdapter] Timeout after %dms", duration)
            return ServiceResult.failure(self._service_id, "Timeout", duration)
        except httpx.HTTPStatusError as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[RecraftAdapter] HTTP %d: %s", e.response.status_code, e.response.text[:200])
            return ServiceResult.failure(self._service_id, f"HTTP {e.response.status_code}", duration)
        except Exception as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[RecraftAdapter] Error: %s", e)
            return ServiceResult.failure(self._service_id, str(e), duration)
