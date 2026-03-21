# legal_risk_agent.py
# Legal and regulatory risk assessment agent for the AI App Factory.
# Identifies potential legal risk areas in ideas, specs, and projects.
# Does NOT provide legal advice — only flags risks for further review.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class LegalRiskAgent:
    def __init__(self):
        role = get_agent_role("legal_risk_agent")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="legal_risk_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_legal_risk_agent() -> AssistantAgent:
    return LegalRiskAgent().agent
