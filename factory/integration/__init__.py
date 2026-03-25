"""Integration Package -- connects CD Roadbook features to Forge pipelines.

Phase 12: CD Forge Interface + Build Plan Schema + Forge Orchestrator + Asset Integrator.
"""

from factory.integration.cd_forge_interface import (
    CDForgeInterface,
    ForgeRequirement,
    FeatureForgeMap,
    ProjectForgeMap,
)
from factory.integration.build_plan_schema import (
    BuildStep,
    BuildPhase,
    FeatureBuildPlan,
    BuildPlan,
    BuildPlanGenerator,
    validate_build_plan,
    is_legacy_plan,
)
from factory.integration.platform_asset_mapper import (
    PlatformAssetMapper,
    PLATFORM_MAPPINGS,
)
from factory.integration.forge_orchestrator import (
    ForgeOrchestrator,
    ForgeRunResult,
    ForgeOrchestratorResult,
)
from factory.integration.asset_integrator import (
    AssetIntegrator,
    IntegrationMap,
    IntegrationEntry,
)
