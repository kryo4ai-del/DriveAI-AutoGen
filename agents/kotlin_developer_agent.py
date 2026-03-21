# kotlin_developer_agent.py
# Writes Kotlin and Jetpack Compose code for Android projects.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class KotlinDeveloperAgent:
    def __init__(self):
        role = get_agent_role("kotlin_developer")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="kotlin_developer",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_kotlin_developer_agent() -> AssistantAgent:
    return KotlinDeveloperAgent().agent
