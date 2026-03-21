# llm_config.py
# LLM configuration for AutoGen agents.
# TheBrain Integration: Routes to optimal model/provider via Model Registry.
# Fallback: Anthropic-only if TheBrain unavailable.

import json
import os
from dotenv import load_dotenv

load_dotenv()

_PROFILES_PATH = os.path.join(os.path.dirname(__file__), "llm_profiles.json")
_DEFAULT_PROFILE = "dev"
_active_profile: str = _DEFAULT_PROFILE

_FALLBACK_PROFILE = {
    "model": "claude-haiku-4-5",
    "temperature": 0.2,
    "api_key_env": "ANTHROPIC_API_KEY",
    "provider": "anthropic",
}

# TheBrain state
_brain_available = False
_brain_selection = None

try:
    from factory.brain.model_provider import get_model as _brain_get_model
    from factory.brain.model_provider import get_registry as _brain_get_registry
    _brain_available = True
except ImportError:
    _brain_available = False


def load_llm_profiles() -> dict:
    try:
        with open(_PROFILES_PATH, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def set_active_profile(name: str) -> None:
    global _active_profile
    profiles = load_llm_profiles()
    _active_profile = name if name in profiles else _DEFAULT_PROFILE


def get_active_profile_name() -> str:
    return _active_profile


# ── API Key lookup ──────────────────────────────────────────────
_PROVIDER_KEY_MAP = {
    "anthropic": "ANTHROPIC_API_KEY",
    "openai": "OPENAI_API_KEY",
    "google": "GEMINI_API_KEY",
    "mistral": "MISTRAL_API_KEY",
}


def _get_api_key(provider: str) -> str:
    env_key = _PROVIDER_KEY_MAP.get(provider, "ANTHROPIC_API_KEY")
    key = os.getenv(env_key, "")
    if not key:
        raise ValueError(f"API key not set for provider '{provider}'. Set {env_key} in .env")
    return key


# ── TheBrain-aware config ──────────────────────────────────────
def get_llm_config(profile_override: str = "", agent_name: str = "",
                   task_type: str = "", line: str = "") -> dict:
    """Return AutoGen-compatible LLM config.

    With TheBrain: selects optimal model/provider from registry.
    Without TheBrain: uses Anthropic-only profiles (legacy).
    """
    global _brain_selection

    profile_name = profile_override or _active_profile

    if _brain_available:
        try:
            selection = _brain_get_model(
                agent_name=agent_name,
                task_type=task_type,
                profile=profile_name,
                line=line,
            )
            _brain_selection = selection
            provider = selection["provider"]
            api_key = _get_api_key(provider)

            config_entry = {
                "model": selection["litellm_model_name"] if provider != "anthropic" else selection["model"],
                "api_key": api_key,
            }
            if provider == "anthropic":
                config_entry["api_type"] = "anthropic"

            return {
                "config_list": [config_entry],
                "temperature": 0.2,
                "_brain_selection": selection,
            }
        except Exception as e:
            print(f"[WARNING] TheBrain model selection failed ({e}), falling back to legacy")

    # Legacy fallback
    return _legacy_get_llm_config(profile_name)


def _legacy_get_llm_config(profile_name: str = "") -> dict:
    """Original Anthropic-only config."""
    profiles = load_llm_profiles()
    pname = profile_name or _active_profile
    profile = profiles.get(pname) or _FALLBACK_PROFILE

    api_key_env = profile.get("api_key_env", "ANTHROPIC_API_KEY")
    api_key = os.getenv(api_key_env)
    if not api_key:
        raise ValueError(f"API key '{api_key_env}' not set.")

    config_entry = {"model": profile.get("model", "claude-haiku-4-5"), "api_key": api_key}
    if profile.get("provider", "anthropic") == "anthropic":
        config_entry["api_type"] = "anthropic"

    return {
        "config_list": [config_entry],
        "temperature": profile.get("temperature", 0.2),
    }


def get_llm_config_for_model(model: str) -> dict:
    """Config for a specific model name."""
    if model.startswith("ollama/"):
        return {"config_list": [{"model": model}], "temperature": 0.2}

    api_key = os.getenv("ANTHROPIC_API_KEY", "")
    if not api_key:
        raise ValueError(f"API key not set for model '{model}'.")

    config_entry = {"model": model, "api_key": api_key, "api_type": "anthropic"}
    return {"config_list": [config_entry], "temperature": 0.2}


# ── Central model client factory ──────────────────────────────
def create_model_client(agent_name: str = "", task_type: str = "",
                        profile: str = "", line: str = ""):
    """Create AutoGen ChatCompletionClient.

    For pipeline agents: always uses Anthropic client (AutoGen-compatible).
    TheBrain selects the Anthropic model tier (Haiku/Sonnet/Opus).
    Multi-provider (OpenAI/Google/Mistral) is used for Assembly/Repair via ProviderRouter.
    """
    from autogen_ext.models.anthropic import AnthropicChatCompletionClient
    import os

    # TheBrain selects tier, map back to Anthropic model
    profile_name = profile or _active_profile
    tier_to_anthropic = {
        "dev": "claude-haiku-4-5",
        "fast": "claude-haiku-4-5",
        "standard": "claude-sonnet-4-6",
        "premium": "claude-opus-4-6",
    }
    profiles = load_llm_profiles()
    p = profiles.get(profile_name, {})
    model = p.get("model", tier_to_anthropic.get(profile_name, "claude-haiku-4-5"))
    api_key = os.getenv("ANTHROPIC_API_KEY", "")

    if not api_key:
        raise ValueError("ANTHROPIC_API_KEY not set")

    return AnthropicChatCompletionClient(model=model, api_key=api_key)


def get_brain_info() -> dict:
    """Return TheBrain status for console logging."""
    if not _brain_available:
        return {"status": "unavailable", "reason": "import failed"}
    try:
        reg = _brain_get_registry()
        stats = reg.stats
        return {
            "status": "active",
            "total_models": stats["total_models"],
            "available_providers": stats["available_providers"],
            "available_models": stats["available_models"],
            "last_selection": _brain_selection,
        }
    except Exception as e:
        return {"status": "error", "reason": str(e)}
