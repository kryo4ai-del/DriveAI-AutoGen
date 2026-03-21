# bug_hunter.py
# Analyzes generated code for bugs, edge cases, and structural weaknesses.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class BugHunterAgent:
    def __init__(self):
        role = get_agent_role("bug_hunter")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="bug_hunter",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_bug_hunter_agent() -> AssistantAgent:
    return BugHunterAgent().agent
