# project_bootstrap_agent.py
# Project bootstrapping agent for the AI App Factory.
# Creates new project structures from validated ideas — folders, metadata, initial docs.

from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.openai import OpenAIChatCompletionClient
from config.llm_config import get_llm_config
from config.role_config import get_agent_role


class ProjectBootstrapAgent:
    def __init__(self):
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]
        role = get_agent_role("project_bootstrap_agent")

        model_client = OpenAIChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        self.agent = AssistantAgent(
            name="project_bootstrap_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_project_bootstrap_agent() -> AssistantAgent:
    return ProjectBootstrapAgent().agent
