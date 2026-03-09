# roadmap_agent.py
# Planning-level agent for feature prioritization, dependency mapping, and roadmap generation.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.openai import OpenAIChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class RoadmapAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("roadmap_agent")

        model_client = OpenAIChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="roadmap_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_roadmap_agent() -> AssistantAgent:
    return RoadmapAgent().agent
