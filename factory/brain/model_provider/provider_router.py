"""Provider Router — unified multi-provider API gateway via LiteLLM."""
import os
import time
from dataclasses import dataclass
from pathlib import Path

try:
    import litellm
    _LITELLM_AVAILABLE = True
except ImportError:
    _LITELLM_AVAILABLE = False

from .model_registry import ModelRegistry


@dataclass
class ProviderResponse:
    content: str = ""
    model: str = ""
    provider: str = ""
    input_tokens: int = 0
    output_tokens: int = 0
    cost_usd: float = 0.0
    latency_ms: int = 0
    was_fallback: bool = False
    error: str | None = None


class ProviderRouter:
    """Multi-provider API router using LiteLLM."""

    def __init__(self, registry: ModelRegistry | None = None):
        self.registry = registry or ModelRegistry()
        if not _LITELLM_AVAILABLE:
            print("[ProviderRouter] WARNING: litellm not installed. API calls will fail.")

    def call(self,
             model_id: str,
             provider: str,
             messages: list[dict],
             max_tokens: int = 4096,
             temperature: float = 0.0,
             ) -> ProviderResponse:
        """Make an API call through LiteLLM."""
        if not _LITELLM_AVAILABLE:
            return ProviderResponse(error="litellm not installed")

        model_info = self.registry.get_model(model_id)
        if not model_info:
            return ProviderResponse(error=f"Unknown model: {model_id}")

        start = time.time()
        try:
            response = litellm.completion(
                model=model_info.litellm_model_name,
                messages=messages,
                max_tokens=max_tokens,
                temperature=temperature,
            )
            elapsed = int((time.time() - start) * 1000)

            cost = 0.0
            try:
                cost = litellm.completion_cost(response)
            except Exception:
                pass

            return ProviderResponse(
                content=response.choices[0].message.content or "",
                model=model_id,
                provider=provider,
                input_tokens=response.usage.prompt_tokens,
                output_tokens=response.usage.completion_tokens,
                cost_usd=cost,
                latency_ms=elapsed,
            )
        except Exception as e:
            return ProviderResponse(error=str(e), model=model_id, provider=provider)

    def call_with_fallback(self,
                           primary_model: str, primary_provider: str,
                           fallback_model: str, fallback_provider: str,
                           messages: list[dict], **kwargs) -> ProviderResponse:
        """Try primary, fall back to secondary on failure."""
        resp = self.call(primary_model, primary_provider, messages, **kwargs)
        if resp.error:
            print(f"  Primary ({primary_model}) failed: {resp.error}")
            print(f"  Falling back to {fallback_model}...")
            resp = self.call(fallback_model, fallback_provider, messages, **kwargs)
            resp.was_fallback = True
        return resp

    def health_check(self, provider: str) -> dict:
        """Quick health check — tiny API call."""
        models = self.registry.get_models_by_provider(provider)
        if not models:
            return {"provider": provider, "status": "no_models"}
        model = models[0]
        resp = self.call(model.model_id, provider,
                         [{"role": "user", "content": "Say OK"}], max_tokens=5)
        return {
            "provider": provider,
            "status": "ok" if not resp.error else "error",
            "latency_ms": resp.latency_ms,
            "error": resp.error,
        }

    def get_available_providers(self) -> list[str]:
        return self.registry.get_available_providers()
