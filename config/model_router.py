# model_router.py
# ModelRouter — intelligent model selection based on task type.
# Prefers local models (Ollama) for lightweight tasks to reduce API costs.
# Falls back to GPT for tasks requiring advanced reasoning.

import json
import os

_DIR = os.path.dirname(__file__)
_ROUTING_PATH = os.path.join(_DIR, "model_routing.json")

# Default routing rules — used if model_routing.json doesn't exist
_DEFAULT_ROUTES = {
    # Tier 1 — Claude Sonnet: Code-critical tasks (architecture, generation, review)
    "code_generation": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires advanced reasoning"},
    "architecture": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires deep reasoning"},
    "code_review": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires code understanding"},
    "bug_hunting": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires code analysis"},
    "refactoring": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires code understanding"},
    "test_generation": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires code understanding"},
    # Tier 2 — Claude Sonnet: Planning & creative tasks
    "planning": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires reasoning"},
    "orchestration": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires multi-step planning"},
    "content_generation": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires creativity"},
    "compliance_review": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires legal reasoning"},
    "accessibility_review": {"model": "claude-sonnet-4-6", "provider": "anthropic", "reason": "requires UI understanding"},
    # Tier 3 — Claude Haiku: Lightweight tasks (fast & cheap)
    "classification": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "lightweight task"},
    "summarization": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "lightweight task"},
    "trend_analysis": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "pattern matching"},
    "scoring": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "numerical evaluation"},
    "labeling": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "simple classification"},
    "extraction": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "structured extraction"},
    "briefing": {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "summarization task"},
}

# Known providers and their cost characteristics
PROVIDERS = {
    "ollama": {"cost_per_1k_input": 0.0, "cost_per_1k_output": 0.0, "local": True},
    "anthropic": {"cost_per_1k_input": 0.003, "cost_per_1k_output": 0.015, "local": False},
    "openai": {"cost_per_1k_input": 0.00015, "cost_per_1k_output": 0.0006, "local": False},
}

# Per-model cost overrides (OpenAI pricing as of early 2026)
MODEL_COSTS = {
    # Anthropic Claude models (primary)
    "claude-opus-4-6": {"cost_per_1k_input": 0.015, "cost_per_1k_output": 0.075},
    "claude-sonnet-4-6": {"cost_per_1k_input": 0.003, "cost_per_1k_output": 0.015},
    "claude-haiku-4-5": {"cost_per_1k_input": 0.0008, "cost_per_1k_output": 0.004},
    # OpenAI models (legacy fallback)
    "gpt-4o": {"cost_per_1k_input": 0.0025, "cost_per_1k_output": 0.01},
    "gpt-4o-mini": {"cost_per_1k_input": 0.00015, "cost_per_1k_output": 0.0006},
    # Local models — zero cost
    "ollama/mistral": {"cost_per_1k_input": 0.0, "cost_per_1k_output": 0.0},
    "ollama/llama3": {"cost_per_1k_input": 0.0, "cost_per_1k_output": 0.0},
}

# Agent → default task type mapping
AGENT_TASK_MAP = {
    "driveai_lead": "planning",
    "ios_architect": "architecture",
    "swift_developer": "code_generation",
    "reviewer": "code_review",
    "bug_hunter": "bug_hunting",
    "refactor_agent": "refactoring",
    "test_generator": "test_generation",
    "product_strategist": "classification",
    "roadmap_agent": "planning",
    "content_script_agent": "content_generation",
    "change_watch_agent": "trend_analysis",
    "accessibility_agent": "accessibility_review",
    "opportunity_agent": "trend_analysis",
    "legal_risk_agent": "compliance_review",
    "project_bootstrap_agent": "planning",
    "android_architect": "architecture",
    "kotlin_developer": "code_generation",
    "web_architect": "architecture",
    "webapp_developer": "code_generation",
    "autonomous_project_orchestrator": "orchestration",
}


def _load_routes() -> dict:
    """Load custom routing rules from JSON, fall back to defaults."""
    try:
        with open(_ROUTING_PATH, encoding="utf-8") as f:
            data = json.load(f)
        return data.get("routes", _DEFAULT_ROUTES)
    except (FileNotFoundError, json.JSONDecodeError):
        return _DEFAULT_ROUTES


def save_routes(routes: dict) -> None:
    """Save routing rules to JSON for persistence."""
    os.makedirs(os.path.dirname(os.path.abspath(_ROUTING_PATH)), exist_ok=True)
    with open(_ROUTING_PATH, "w", encoding="utf-8") as f:
        json.dump({"routes": routes}, f, indent=2, ensure_ascii=False)


class ModelRouter:
    """Selects the optimal model for a given task type or agent."""

    def __init__(self):
        self.routes = _load_routes()

    def reload(self) -> None:
        self.routes = _load_routes()

    def route(self, task_type: str) -> dict:
        """
        Get routing decision for a task type.
        Returns: {"model": str, "provider": str, "reason": str}
        """
        if task_type in self.routes:
            return self.routes[task_type]
        # Default fallback: Haiku for unknown tasks
        return {"model": "claude-haiku-4-5", "provider": "anthropic", "reason": "unknown task type — fallback"}

    def route_for_agent(self, agent_name: str, task_type_override: str = "") -> dict:
        """
        Get routing decision for a specific agent.
        task_type_override takes precedence over the agent's default task mapping.
        """
        task_type = task_type_override or AGENT_TASK_MAP.get(agent_name, "planning")
        return self.route(task_type)

    def get_model(self, task_type: str) -> str:
        """Shorthand: get just the model name for a task type."""
        return self.route(task_type)["model"]

    def get_model_for_agent(self, agent_name: str, task_type_override: str = "") -> str:
        """Shorthand: get just the model name for an agent."""
        return self.route_for_agent(agent_name, task_type_override)["model"]

    def is_local(self, task_type: str) -> bool:
        """Check if a task type routes to a local model."""
        r = self.route(task_type)
        provider_info = PROVIDERS.get(r["provider"], {})
        return provider_info.get("local", False)

    def estimate_cost(self, model: str, prompt_tokens: int, completion_tokens: int) -> float:
        """Estimate cost for a specific model and token usage."""
        costs = MODEL_COSTS.get(model)
        if not costs:
            # Unknown model — assume zero (could be local)
            return 0.0
        input_cost = (prompt_tokens / 1000) * costs["cost_per_1k_input"]
        output_cost = (completion_tokens / 1000) * costs["cost_per_1k_output"]
        return round(input_cost + output_cost, 6)

    def get_all_routes(self) -> dict:
        """Return all routing rules."""
        return dict(self.routes)

    def update_route(self, task_type: str, model: str, provider: str, reason: str = "") -> None:
        """Update or add a routing rule."""
        self.routes[task_type] = {
            "model": model,
            "provider": provider,
            "reason": reason or f"custom route for {task_type}",
        }
        save_routes(self.routes)

    def get_summary(self) -> str:
        """Summary of routing configuration."""
        local_tasks = [t for t, r in self.routes.items() if PROVIDERS.get(r.get("provider", ""), {}).get("local")]
        api_tasks = [t for t, r in self.routes.items() if not PROVIDERS.get(r.get("provider", ""), {}).get("local")]
        models_used = sorted({r["model"] for r in self.routes.values()})
        return (
            f"ModelRouter — {len(self.routes)} routes | "
            f"{len(local_tasks)} local, {len(api_tasks)} API | "
            f"Models: {', '.join(models_used)}"
        )
