# product_strategist.py
# Planning-level agent for idea classification, prioritization, and product guidance.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.openai import OpenAIChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class ProductStrategistAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("product_strategist")

        model_client = OpenAIChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="product_strategist",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_product_strategist_agent() -> AssistantAgent:
    return ProductStrategistAgent().agent
