# android_architect_agent.py
# Responsible for Android architecture decisions and system design.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class AndroidArchitectAgent:
    def __init__(self):
        role = get_agent_role("android_architect")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="android_architect",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_android_architect_agent() -> AssistantAgent:
    return AndroidArchitectAgent().agent
