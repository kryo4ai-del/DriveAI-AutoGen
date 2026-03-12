# android_architect_agent.py
# Responsible for Android architecture decisions and system design.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.anthropic import AnthropicChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class AndroidArchitectAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("android_architect")

        model_client = AnthropicChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="android_architect",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_android_architect_agent() -> AssistantAgent:
    return AndroidArchitectAgent().agent
