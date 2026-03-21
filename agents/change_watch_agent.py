# change_watch_agent.py
# Ecosystem monitoring agent for the AI App Factory.
# Tracks external changes (SDK, tooling, models, security, pricing, deprecations)
# and assesses impact on factory projects.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class ChangeWatchAgent:
    def __init__(self):
        role = get_agent_role("change_watch_agent")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="change_watch_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_change_watch_agent() -> AssistantAgent:
    return ChangeWatchAgent().agent
