# kotlin_developer_agent.py
# Writes Kotlin and Jetpack Compose code for Android projects.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.anthropic import AnthropicChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class KotlinDeveloperAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("kotlin_developer")

        model_client = AnthropicChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="kotlin_developer",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_kotlin_developer_agent() -> AssistantAgent:
    return KotlinDeveloperAgent().agent
