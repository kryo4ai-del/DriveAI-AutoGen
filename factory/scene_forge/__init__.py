"""Scene Forge -- Unity scene/level/shader/prefab generation pipeline.

Extracts specs from CD Roadbook, generates level layouts,
scene configurations, shader parameters, and prefab definitions.
"""

from factory.scene_forge.scene_spec_extractor import (
    LevelSpec,
    SceneSpec,
    ShaderSpec,
    PrefabSpec,
    SceneManifest,
    SceneSpecExtractor,
)
from factory.scene_forge.level_generator import (
    LevelLayout,
    LevelGenerator,
)
from factory.scene_forge.unity_scene_writer import UnitySceneWriter
from factory.scene_forge.shader_generator import ShaderGenerator
from factory.scene_forge.prefab_generator import PrefabGenerator
from factory.scene_forge.scene_validator import SceneValidator, SceneValidationResult
from factory.scene_forge.scene_catalog_manager import SceneCatalogManager, SceneCatalog
from factory.scene_forge.scene_forge_orchestrator import SceneForgeOrchestrator, OrchestratorResult

__all__ = [
    "LevelSpec",
    "SceneSpec",
    "ShaderSpec",
    "PrefabSpec",
    "SceneManifest",
    "SceneSpecExtractor",
    "LevelLayout",
    "LevelGenerator",
    "UnitySceneWriter",
    "ShaderGenerator",
    "PrefabGenerator",
    "SceneValidator",
    "SceneValidationResult",
    "SceneCatalogManager",
    "SceneCatalog",
    "SceneForgeOrchestrator",
    "OrchestratorResult",
]
