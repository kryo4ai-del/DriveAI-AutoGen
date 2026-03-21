# product_strategist.py
# Planning-level agent for idea classification, prioritization, and product guidance.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class ProductStrategistAgent:
    def __init__(self):
        role = get_agent_role("product_strategist")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="product_strategist",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_product_strategist_agent() -> AssistantAgent:
    return ProductStrategistAgent().agent
