# swift_developer.py
# Generates and implements Swift/SwiftUI code based on architect specs.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class SwiftDeveloperAgent:
    def __init__(self):
        role = get_agent_role("swift_developer")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="swift_developer",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_swift_developer_agent() -> AssistantAgent:
    return SwiftDeveloperAgent().agent
