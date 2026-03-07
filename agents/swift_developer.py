# swift_developer.py
# Generates and implements Swift/SwiftUI code based on architect specs.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.openai import OpenAIChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class SwiftDeveloperAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("swift_developer")

        model_client = OpenAIChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="swift_developer",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_swift_developer_agent() -> AssistantAgent:
    return SwiftDeveloperAgent().agent
