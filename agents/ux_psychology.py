# ux_psychology.py
# Reviews generated features for behavioral engagement, learning psychology,
# and motivation design. Advisory only — does not generate code.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class UxPsychologyAgent:
    def __init__(self):
        role = get_agent_role("ux_psychology")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="ux_psychology",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_ux_psychology_agent() -> AssistantAgent:
    return UxPsychologyAgent().agent
