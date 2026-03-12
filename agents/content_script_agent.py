# content_script_agent.py
# Content-generation planning agent for the AI App Factory.
# Generates structured content drafts from project docs, specs, and product identity.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.anthropic import AnthropicChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class ContentScriptAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("content_script_agent")

        model_client = AnthropicChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="content_script_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_content_script_agent() -> AssistantAgent:
    return ContentScriptAgent().agent
