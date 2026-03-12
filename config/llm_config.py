# llm_config.py
# LLM configuration for AutoGen agents.
# Supports both Anthropic (Claude) and OpenAI models.

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


def load_llm_profiles() -> dict:
    """Load llm_profiles.json. Returns empty dict on failure."""
    try:
        with open(_PROFILES_PATH, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def set_active_profile(name: str) -> None:
    """
    Set the active LLM environment profile globally.
    Falls back to 'dev' if the name is not found in llm_profiles.json.
    Must be called before any agent or team is created.
    """
    global _active_profile
    profiles = load_llm_profiles()
    _active_profile = name if name in profiles else _DEFAULT_PROFILE


def get_active_profile_name() -> str:
    return _active_profile


def get_llm_config(profile_override: str = "") -> dict:
    """
    Return an AutoGen-compatible LLM config dict.
    Uses profile_override if given, else the active profile.
    Raises ValueError if the required API key env var is not set.
    """
    profiles = load_llm_profiles()
    profile_name = profile_override or _active_profile
    profile = profiles.get(profile_name) or _FALLBACK_PROFILE

    api_key_env = profile.get("api_key_env", "ANTHROPIC_API_KEY")
    api_key = os.getenv(api_key_env)
    if not api_key:
        raise ValueError(
            f"API key not set. Environment variable '{api_key_env}' is missing. "
            "Add your Anthropic API key to .env: ANTHROPIC_API_KEY=sk-ant-..."
        )

    provider = profile.get("provider", "anthropic")
    model = profile.get("model", _FALLBACK_PROFILE["model"])

    config_entry = {
        "model": model,
        "api_key": api_key,
    }

    # Anthropic models need base_url for AutoGen compatibility
    if provider == "anthropic":
        config_entry["api_type"] = "anthropic"

    return {
        "config_list": [config_entry],
        "temperature": profile.get("temperature", _FALLBACK_PROFILE["temperature"]),
    }


def get_llm_config_for_model(model: str) -> dict:
    """
    Return an AutoGen-compatible LLM config for a specific model name.
    Detects provider from model name prefix.
    """
    if model.startswith("claude"):
        api_key_env = "ANTHROPIC_API_KEY"
        provider = "anthropic"
    elif model.startswith("gpt") or model.startswith("o3"):
        api_key_env = "OPENAI_API_KEY"
        provider = "openai"
    elif model.startswith("ollama/"):
        # Local models don't need API keys
        return {
            "config_list": [{"model": model}],
            "temperature": 0.2,
        }
    else:
        api_key_env = "ANTHROPIC_API_KEY"
        provider = "anthropic"

    api_key = os.getenv(api_key_env)
    if not api_key:
        raise ValueError(
            f"API key not set for model '{model}'. "
            f"Set environment variable '{api_key_env}'."
        )

    config_entry = {
        "model": model,
        "api_key": api_key,
    }
    if provider == "anthropic":
        config_entry["api_type"] = "anthropic"

    return {
        "config_list": [config_entry],
        "temperature": 0.2,
    }
