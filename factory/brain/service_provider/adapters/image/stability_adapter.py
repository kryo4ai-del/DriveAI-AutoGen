"""Stability AI SDXL Adapter — Stable Image Generate Core API.

Generates images via POST https://api.stability.ai/v2beta/stable-image/generate/core
Returns raw PNG bytes directly from the response body.
"""

import logging
import time

import httpx

from factory.brain.service_provider.adapters.base_adapter import BaseServiceAdapter, ServiceResult

logger = logging.getLogger(__name__)

API_BASE = "https://api.stability.ai/v2beta/stable-image/generate/core"
HEALTH_URL = "https://api.stability.ai/v1/engines/list"

VALID_PRESETS = {
    "photographic", "digital-art", "comic-book", "fantasy-art",
    "anime", "3d-model", "pixel-art", "neon-punk", "origami",
}

ASPECT_RATIOS = {
    (1, 1): "1:1",
    (16, 9): "16:9",
    (9, 16): "9:16",
    (3, 2): "3:2",
    (2, 3): "2:3",
    (4, 3): "4:3",
    (3, 4): "3:4",
    (21, 9): "21:9",
    (9, 21): "9:21",
}


def _size_to_aspect(size_str: str) -> str:
    """Convert 'WxH' to nearest valid aspect ratio."""
    try:
        w, h = map(int, size_str.lower().split("x"))
    except (ValueError, AttributeError):
        return "1:1"
    from math import gcd
    g = gcd(w, h)
    ratio = (w // g, h // g)
    if ratio in ASPECT_RATIOS:
        return ASPECT_RATIOS[ratio]
    # Find closest
    target = w / h
    best = "1:1"
    best_diff = float("inf")
    for (rw, rh), label in ASPECT_RATIOS.items():
        diff = abs(rw / rh - target)
        if diff < best_diff:
            best_diff = diff
            best = label
    return best


class StabilityAdapter(BaseServiceAdapter):

    def __init__(self, api_key: str):
        super().__init__("stability_sdxl", api_key)

    def get_capabilities(self) -> list[str]:
        return ["text_to_image", "png_output", "transparent_bg", "max_2048x2048", "style_control", "negative_prompt"]

    def get_cost_estimate(self, specs: dict) -> float:
        size = specs.get("size", "1024x1024")
        try:
            w, h = map(int, size.lower().split("x"))
            pixels = w * h
        except (ValueError, AttributeError):
            pixels = 1024 * 1024
        if pixels <= 512 * 512:
            return 0.016
        return 0.03

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
        negative_prompt = specs.get("negative_prompt", "")
        output_format = specs.get("output_format", "png")
        style_preset = specs.get("style_preset")
        aspect_ratio = _size_to_aspect(size)

        if output_format not in ("png", "webp"):
            output_format = "png"
        if style_preset and style_preset not in VALID_PRESETS:
            style_preset = None

        form_data = {
            "prompt": prompt,
            "output_format": output_format,
            "aspect_ratio": aspect_ratio,
        }
        if negative_prompt:
            form_data["negative_prompt"] = negative_prompt
        if style_preset:
            form_data["style_preset"] = style_preset

        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                resp = await client.post(
                    API_BASE,
                    data=form_data,
                    headers={
                        "Authorization": f"Bearer {self._api_key}",
                        "Accept": "image/*",
                    },
                )
                resp.raise_for_status()

            duration = int((time.time() - t0) * 1000)
            return ServiceResult(
                success=True,
                data=resp.content,
                format=output_format,
                cost=0.03,
                duration_ms=duration,
                service_id=self._service_id,
                metadata={"aspect_ratio": aspect_ratio, "style_preset": style_preset or "none"},
            )

        except httpx.TimeoutException:
            duration = int((time.time() - t0) * 1000)
            logger.error("[StabilityAdapter] Timeout after %dms", duration)
            return ServiceResult.failure(self._service_id, "Timeout", duration)
        except httpx.HTTPStatusError as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[StabilityAdapter] HTTP %d: %s", e.response.status_code, e.response.text[:200])
            return ServiceResult.failure(self._service_id, f"HTTP {e.response.status_code}", duration)
        except Exception as e:
            duration = int((time.time() - t0) * 1000)
            logger.error("[StabilityAdapter] Error: %s", e)
            return ServiceResult.failure(self._service_id, str(e), duration)
