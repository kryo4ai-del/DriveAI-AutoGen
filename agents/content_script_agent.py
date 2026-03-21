# content_script_agent.py
# Content-generation planning agent for the AI App Factory.
# Generates structured content drafts from project docs, specs, and product identity.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class ContentScriptAgent:
    def __init__(self):
        role = get_agent_role("content_script_agent")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="content_script_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_content_script_agent() -> AssistantAgent:
    return ContentScriptAgent().agent
