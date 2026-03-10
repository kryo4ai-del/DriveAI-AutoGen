# web_architect_agent.py
# Responsible for web application architecture and frontend system design.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.openai import OpenAIChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class WebArchitectAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("web_architect")

        model_client = OpenAIChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="web_architect",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_web_architect_agent() -> AssistantAgent:
    return WebArchitectAgent().agent
