# webapp_developer_agent.py
# Writes TypeScript/React/Next.js code for web application projects.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class WebAppDeveloperAgent:
    def __init__(self):
        role = get_agent_role("webapp_developer")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="webapp_developer",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_webapp_developer_agent() -> AssistantAgent:
    return WebAppDeveloperAgent().agent
