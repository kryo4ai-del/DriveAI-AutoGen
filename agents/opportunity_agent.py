# opportunity_agent.py
# Discovery agent for the AI App Factory.
# Analyzes ecosystem changes, trends, and platform capabilities
# to generate structured opportunity reports for new products and features.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class OpportunityAgent:
    def __init__(self):
        role = get_agent_role("opportunity_agent")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="opportunity_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_opportunity_agent() -> AssistantAgent:
    return OpportunityAgent().agent
