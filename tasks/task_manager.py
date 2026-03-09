# task_manager.py
# Manages task creation, distribution, and tracking across agents.

import os
import logging
from autogen_agentchat.teams import SelectorGroupChat
from autogen_agentchat.conditions import MaxMessageTermination
from autogen_ext.models.openai import OpenAIChatCompletionClient
from agents.lead_agent import create_lead_agent
from agents.product_strategist import create_product_strategist_agent
from agents.roadmap_agent import create_roadmap_agent
from agents.ios_architect import create_ios_architect_agent
from agents.swift_developer import create_swift_developer_agent
from agents.reviewer import create_reviewer_agent
from agents.bug_hunter import create_bug_hunter_agent
from agents.refactor_agent import create_refactor_agent
from agents.test_generator import create_test_generator_agent
from project_context.context_loader import load_project_context
from memory.memory_manager import MemoryManager
from planning.feature_planner import FeaturePlanner

LOGS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "logs")


def setup_logger(run_id: str) -> tuple[logging.Logger, str]:
    os.makedirs(LOGS_DIR, exist_ok=True)
    log_path = os.path.join(LOGS_DIR, f"driveai_run_{run_id}.txt")
    logger = logging.getLogger(f"driveai_{run_id}")
    logger.setLevel(logging.DEBUG)
    handler = logging.FileHandler(log_path, encoding="utf-8")
    handler.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(handler)
    return logger, log_path


class TaskManager:
    def __init__(self, enabled_agents: set[str] | None = None):
        """
        enabled_agents: set of agent names to instantiate.
        None means all agents are enabled.
        Core agents (driveai_lead, swift_developer) are always instantiated.
        """
        def _on(name: str) -> bool:
            return enabled_agents is None or name in enabled_agents

        # Core agents — always created
        self.lead_agent = create_lead_agent()
        self.swift_developer_agent = create_swift_developer_agent()

        # Optional agents — created only if enabled
        self.product_strategist_agent = create_product_strategist_agent() if _on("product_strategist") else None
        self.roadmap_agent = create_roadmap_agent() if _on("roadmap_agent") else None
        self.ios_architect_agent = create_ios_architect_agent() if _on("ios_architect") else None
        self.reviewer_agent = create_reviewer_agent() if _on("reviewer") else None
        self.bug_hunter_agent = create_bug_hunter_agent() if _on("bug_hunter") else None
        self.refactor_agent = create_refactor_agent() if _on("refactor_agent") else None
        self.test_generator_agent = create_test_generator_agent() if _on("test_generator") else None

        self.project_context = load_project_context()
        self.memory_manager = MemoryManager()
        self.feature_planner = FeaturePlanner()

    def get_agents_summary(self) -> dict:
        summary = {
            "lead": self.lead_agent.name,
            "developer": self.swift_developer_agent.name,
        }
        if self.product_strategist_agent:
            summary["product_strategist"] = self.product_strategist_agent.name
        if self.roadmap_agent:
            summary["roadmap_agent"] = self.roadmap_agent.name
        if self.ios_architect_agent:
            summary["architect"] = self.ios_architect_agent.name
        if self.reviewer_agent:
            summary["reviewer"] = self.reviewer_agent.name
        if self.bug_hunter_agent:
            summary["bug_hunter"] = self.bug_hunter_agent.name
        if self.refactor_agent:
            summary["refactor_agent"] = self.refactor_agent.name
        if self.test_generator_agent:
            summary["test_generator"] = self.test_generator_agent.name
        return summary

    def get_project_context_summary(self) -> str:
        return self.project_context[:800] + "..." if len(self.project_context) > 800 else self.project_context

    def get_memory_summary(self) -> str:
        return self.memory_manager.get_memory_summary()

    def build_full_task(self, user_task: str) -> str:
        memory_summary = self.memory_manager.get_memory_summary()
        return (
            f"Project Context:\n{self.project_context}\n\n"
            f"Memory:\n{memory_summary}\n\n"
            f"Task:\n{user_task}"
        )

    def create_team(self) -> SelectorGroupChat:
        from config.llm_config import get_llm_config
        llm_config = get_llm_config()
        cfg = llm_config["config_list"][0]

        selector_client = OpenAIChatCompletionClient(
            model=cfg["model"],
            api_key=cfg["api_key"],
        )

        termination = MaxMessageTermination(max_messages=10)

        # Build participant list from enabled agents only
        participants = [self.lead_agent]
        for agent in [
            self.product_strategist_agent,
            self.roadmap_agent,
            self.ios_architect_agent,
            self.swift_developer_agent,
            self.reviewer_agent,
            self.bug_hunter_agent,
            self.refactor_agent,
            self.test_generator_agent,
        ]:
            if agent is not None:
                participants.append(agent)

        return SelectorGroupChat(
            participants=participants,
            model_client=selector_client,
            termination_condition=termination,
            allow_repeated_speaker=False,
        )

    def get_next_feature_task(self) -> tuple[str, str] | tuple[None, None]:
        """
        Returns (feature_name, task_string) for the next planned feature,
        or (None, None) if the backlog is empty.
        Moves the feature to in_progress immediately.
        """
        feature = self.feature_planner.get_next_feature()
        if not feature:
            return None, None
        self.feature_planner.start_feature(feature)
        task = f"Design and implement the SwiftUI {feature} for DriveAI."
        return feature, task

    def get_sample_task(self) -> str:
        return "Design and implement a SwiftUI multiple-choice question screen for the DriveAI app."
