# refactor_agent.py
# Improves generated code structure, readability, and modularity.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class RefactorAgent:
    def __init__(self):
        role = get_agent_role("refactor_agent")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="refactor_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_refactor_agent() -> AssistantAgent:
    return RefactorAgent().agent
