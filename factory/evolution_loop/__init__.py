"""Evolution Loop — Iterative quality improvement system for the DAI-Core Factory."""

# --- Agents ---------------------------------------------------------------
from .decision_agent import DecisionAgent
from .evaluation_agent import EvaluationAgent
from .gap_detector import GapDetector
from .loop_orchestrator import LoopOrchestrator
from .regression_tracker import RegressionTracker
from .simulation_agent import SimulationAgent

# --- LDO (Loop Data Object) -----------------------------------------------
from .ldo import (
    LoopDataObject, LDOMeta, RoadbookTargets, BuildArtifacts, QAResults,
    SimulationResults, Scores, ScoreEntry, Gap, RegressionData, Task,
    CEOFeedback, CEOIssue,
    LDOValidator, ValidationResult, LDOStorage,
)

# --- Config ----------------------------------------------------------------
from .config.config_loader import EvolutionConfig

# --- Scoring ---------------------------------------------------------------
from .scoring import HardScoreCalculator, SoftScoreCalculator, ScoreAggregator

# --- Gates -----------------------------------------------------------------
from .gates import CEOReviewGate, HumanReviewProvider, ReviewProvider, ReviewResult

# --- Plugins ---------------------------------------------------------------
from .plugins import EvaluationPlugin, PluginLoader

# --- Adapters --------------------------------------------------------------
from .adapters import OrchestratorHandoff, QAToLDOAdapter

# --- Tracking --------------------------------------------------------------
from .tracking import CostTracker, GitTagger

# --- Factory Learner -------------------------------------------------------
from .factory_learner import FactoryLearner

__all__ = [
    # Agents
    "DecisionAgent",
    "EvaluationAgent",
    "GapDetector",
    "LoopOrchestrator",
    "RegressionTracker",
    "SimulationAgent",
    # LDO
    "LoopDataObject", "LDOMeta", "RoadbookTargets", "BuildArtifacts",
    "QAResults", "SimulationResults", "Scores", "ScoreEntry",
    "Gap", "RegressionData", "Task", "CEOFeedback", "CEOIssue",
    "LDOValidator", "ValidationResult", "LDOStorage",
    # Config
    "EvolutionConfig",
    # Scoring
    "HardScoreCalculator", "SoftScoreCalculator", "ScoreAggregator",
    # Gates
    "CEOReviewGate", "HumanReviewProvider", "ReviewProvider", "ReviewResult",
    # Plugins
    "EvaluationPlugin", "PluginLoader",
    # Adapters
    "OrchestratorHandoff", "QAToLDOAdapter",
    # Tracking
    "CostTracker", "GitTagger",
    # Factory Learner
    "FactoryLearner",
]
