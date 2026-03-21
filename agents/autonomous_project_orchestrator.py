# autonomous_project_orchestrator.py
# High-level orchestration agent that coordinates project execution across the factory.

from autogen_agentchat.agents import AssistantAgent
from config.llm_config import create_model_client
from config.role_config import get_agent_role


class AutonomousProjectOrchestrator:
    def __init__(self):
        role = get_agent_role("autonomous_project_orchestrator")

        model_client = create_model_client()

        self.agent = AssistantAgent(
            name="autonomous_project_orchestrator",
            model_client=model_client,
            system_message=role["system_message"],
            description=role["description"],
        )


def create_autonomous_project_orchestrator() -> AssistantAgent:
    return AutonomousProjectOrchestrator().agent
