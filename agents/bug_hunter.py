# bug_hunter.py
# Analyzes generated code for bugs, edge cases, and structural weaknesses.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.openai import OpenAIChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class BugHunterAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("bug_hunter")

        model_client = OpenAIChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="bug_hunter",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_bug_hunter_agent() -> AssistantAgent:
    return BugHunterAgent().agent
