"""QA Forge -- validates Forge outputs (images, audio, animations, scenes).

IMPORTANT: This is factory/qa_forge/ — NOT factory/qa/ (which is the Code-QA system).
"""

from .config import QA_CONFIG
from .visual_diff import VisualDiff
from .audio_check import AudioCheck
from .animation_timing import AnimationTiming
from .scene_integrity import SceneIntegrity
from .design_compliance import DesignCompliance
from .qa_forge_orchestrator import QAForgeOrchestrator

__all__ = [
    "QA_CONFIG",
    "VisualDiff",
    "AudioCheck",
    "AnimationTiming",
    "SceneIntegrity",
    "DesignCompliance",
    "QAForgeOrchestrator",
]
