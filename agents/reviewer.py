# reviewer.py
# Reviews generated code for quality, correctness, and best practices.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class ReviewerAgent:
    def __init__(self):
        role = get_agent_role("reviewer")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="reviewer",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_reviewer_agent() -> AssistantAgent:
    return ReviewerAgent().agent
