# test_generator.py
# Generates structured test cases for implemented SwiftUI components and business logic.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class TestGeneratorAgent:
    def __init__(self):
        role = get_agent_role("test_generator")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="test_generator",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_test_generator_agent() -> AssistantAgent:
    return TestGeneratorAgent().agent
