# lead_agent.py
# Orchestrates the multi-agent workflow for DriveAI-AutoGen.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class LeadAgent:
    def __init__(self):
        role = get_agent_role("driveai_lead")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="driveai_lead",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_lead_agent() -> AssistantAgent:
    return LeadAgent().agent
