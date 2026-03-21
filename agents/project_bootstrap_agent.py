# project_bootstrap_agent.py
# Project bootstrapping agent for the AI App Factory.
# Creates new project structures from validated ideas — folders, metadata, initial docs.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class ProjectBootstrapAgent:
    def __init__(self):
        role = get_agent_role("project_bootstrap_agent")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="project_bootstrap_agent",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_project_bootstrap_agent() -> AssistantAgent:
    return ProjectBootstrapAgent().agent
