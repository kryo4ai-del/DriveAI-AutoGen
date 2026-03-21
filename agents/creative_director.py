# creative_director.py
# Reviews generated code and specs for product quality, differentiation,
# and emotional engagement. Advisory only — does not generate code.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class CreativeDirectorAgent:
    def __init__(self):
        role = get_agent_role("creative_director")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="creative_director",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_creative_director_agent() -> AssistantAgent:
    return CreativeDirectorAgent().agent
