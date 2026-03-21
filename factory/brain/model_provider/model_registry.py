"""Model Registry — central database of all available models across providers."""
import json
import os
from dataclasses import dataclass, field
from pathlib import Path

_DIR = Path(__file__).parent
_DEFAULT_REGISTRY = _DIR / "models_registry.json"

_API_KEY_MAP = {
    "anthropic": "ANTHROPIC_API_KEY",
    "openai": "OPENAI_API_KEY",
    "google": "GEMINI_API_KEY",
    "mistral": "MISTRAL_API_KEY",
}


@dataclass
class ModelInfo:
    model_id: str
    provider: str
    display_name: str = ""
    max_output_tokens: int = 4096
    max_context_window: int = 128000
    price_per_1k_input: float = 0.0
    price_per_1k_output: float = 0.0
    strengths: list[str] = field(default_factory=list)
    weaknesses: list[str] = field(default_factory=list)
    status: str = "active"
    tier_equivalent: str = "mid"
    litellm_model_name: str = ""


class ModelRegistry:
    """Central database of all available models across all providers."""

    def __init__(self, registry_path: str | None = None):
        path = Path(registry_path) if registry_path else _DEFAULT_REGISTRY
        self._data: dict[str, dict] = {}
        self._models: list[ModelInfo] = []
        if path.is_file():
            self._data = json.loads(path.read_text(encoding="utf-8"))
            self._build_index()

    def _build_index(self):
        self._models = []
        for provider, models in self._data.items():
            for model_id, info in models.items():
                self._models.append(ModelInfo(
                    model_id=model_id,
                    provider=provider,
                    display_name=info.get("display_name", model_id),
                    max_output_tokens=info.get("max_output_tokens", 4096),
                    max_context_window=info.get("max_context_window", 128000),
                    price_per_1k_input=info.get("price_per_1k_input", 0.0),
                    price_per_1k_output=info.get("price_per_1k_output", 0.0),
                    strengths=info.get("strengths", []),
                    weaknesses=info.get("weaknesses", []),
                    status=info.get("status", "active"),
                    tier_equivalent=info.get("tier_equivalent", "mid"),
                    litellm_model_name=info.get("litellm_model_name", f"{provider}/{model_id}"),
                ))

    def get_model(self, model_id: str) -> ModelInfo | None:
        for m in self._models:
            if m.model_id == model_id:
                return m
        return None

    def get_models_by_provider(self, provider: str) -> list[ModelInfo]:
        return [m for m in self._models if m.provider == provider]

    def get_models_by_tier(self, tier: str) -> list[ModelInfo]:
        return [m for m in self._models if m.tier_equivalent == tier and m.status == "active"]

    def get_models_by_strength(self, *tags: str) -> list[ModelInfo]:
        return [m for m in self._models if all(t in m.strengths for t in tags) and m.status == "active"]

    def get_cheapest_for_task(self, task_type: str, min_output_tokens: int = 4096) -> list[ModelInfo]:
        candidates = [m for m in self._models
                      if m.status == "active"
                      and m.max_output_tokens >= min_output_tokens
                      and task_type in m.strengths]
        return sorted(candidates, key=lambda m: m.price_per_1k_output)

    def get_available_models(self) -> list[ModelInfo]:
        available_providers = self.get_available_providers()
        return [m for m in self._models if m.provider in available_providers and m.status == "active"]

    def get_available_providers(self) -> list[str]:
        return [p for p, env_key in _API_KEY_MAP.items() if os.environ.get(env_key)]

    @property
    def stats(self) -> dict:
        by_provider = {}
        by_tier = {}
        for m in self._models:
            by_provider[m.provider] = by_provider.get(m.provider, 0) + 1
            by_tier[m.tier_equivalent] = by_tier.get(m.tier_equivalent, 0) + 1
        available = self.get_available_providers()
        return {
            "total_models": len(self._models),
            "by_provider": by_provider,
            "by_tier": by_tier,
            "available_providers": available,
            "available_models": sum(1 for m in self._models if m.provider in available and m.status == "active"),
        }
