# llm_config.py
# LLM configuration for AutoGen agents (model, API keys, parameters).

import json
import os
from dotenv import load_dotenv

load_dotenv()

_PROFILES_PATH = os.path.join(os.path.dirname(__file__), "llm_profiles.json")
_DEFAULT_PROFILE = "dev"
_active_profile: str = _DEFAULT_PROFILE

_FALLBACK_PROFILE = {
    "model": "gpt-4o-mini",
    "temperature": 0.2,
    "api_key_env": "OPENAI_API_KEY",
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


def get_llm_config() -> dict:
    """
    Return an AutoGen-compatible LLM config dict for the active profile.
    Raises ValueError if the required API key env var is not set.
    """
    profiles = load_llm_profiles()
    profile = profiles.get(_active_profile) or _FALLBACK_PROFILE

    api_key_env = profile.get("api_key_env", "OPENAI_API_KEY")
    api_key = os.getenv(api_key_env)
    if not api_key:
        raise ValueError(
            f"API key not set. Environment variable '{api_key_env}' is missing. "
            "Copy .env.example to .env and add your key."
        )

    return {
        "config_list": [
            {
                "model": profile.get("model", _FALLBACK_PROFILE["model"]),
                "api_key": api_key,
            }
        ],
        "temperature": profile.get("temperature", _FALLBACK_PROFILE["temperature"]),
    }
