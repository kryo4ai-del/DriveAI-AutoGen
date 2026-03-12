# accessibility_agent.py
# Accessibility review agent for the AI App Factory.
# Analyzes UI code for accessibility issues and produces structured findings.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.anthropic import AnthropicChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class AccessibilityAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("accessibility_agent")

        model_client = AnthropicChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="accessibility_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_accessibility_agent() -> AssistantAgent:
    return AccessibilityAgent().agent
