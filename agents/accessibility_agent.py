# accessibility_agent.py
# Accessibility review agent for the AI App Factory.
# Analyzes UI code for accessibility issues and produces structured findings.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class AccessibilityAgent:
    def __init__(self):
        role = get_agent_role("accessibility_agent")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="accessibility_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_accessibility_agent() -> AssistantAgent:
    return AccessibilityAgent().agent
