# roadmap_agent.py
# Planning-level agent for feature prioritization, dependency mapping, and roadmap generation.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class RoadmapAgent:
    def __init__(self):
        role = get_agent_role("roadmap_agent")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="roadmap_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_roadmap_agent() -> AssistantAgent:
    return RoadmapAgent().agent
