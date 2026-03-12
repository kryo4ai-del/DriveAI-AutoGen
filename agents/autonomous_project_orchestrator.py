# autonomous_project_orchestrator.py
# High-level orchestration agent that coordinates project execution across the factory.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.anthropic import AnthropicChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class AutonomousProjectOrchestrator:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("autonomous_project_orchestrator")

        model_client = AnthropicChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="autonomous_project_orchestrator",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_autonomous_project_orchestrator() -> AssistantAgent:
    return AutonomousProjectOrchestrator().agent
