# ios_architect.py
# Responsible for iOS architecture decisions and system design.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class IOSArchitectAgent:
    def __init__(self):
        role = get_agent_role("ios_architect")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="ios_architect",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_ios_architect_agent() -> AssistantAgent:
    return IOSArchitectAgent().agent
