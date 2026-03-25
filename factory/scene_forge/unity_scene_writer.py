"""Unity Scene Writer -- generates .unity scene files as serialized YAML.

Builds complete Unity scenes from SceneSpecs with proper hierarchy:
- Base settings (OcclusionCulling, RenderSettings, Lightmap, NavMesh)
- Camera + AudioListener
- Light (for game scenes)
- Canvas + EventSystem (for UI scenes)
- Required elements from spec
"""

import logging
from pathlib import Path

from factory.scene_forge.utils.unity_guid import FileIDAllocator
from factory.scene_forge.utils.unity_fileid import get_class_id
from factory.scene_forge.utils.yaml_serializer import (
    serialize_unity_yaml,
    make_file_id_ref,
)

logger = logging.getLogger(__name__)


class UnitySceneWriter:
    """Generates Unity Scene files from SceneSpecs."""

    OUTPUT_DIR = Path(__file__).parent / "generated" / "scenes"

    def __init__(self, output_dir=None):
        if output_dir:
            self.OUTPUT_DIR = Path(output_dir)
        self.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    def generate(self, scene_spec) -> dict:
        """Generate a Unity scene from a SceneSpec.

        Returns: {success, file_path, document_count, file_size}
        """
        allocator = FileIDAllocator()
        documents = []
        child_transform_ids = []

        # 1. Base settings
        documents.extend(self._create_base_settings(allocator))

        # 2. Camera
        is_game = scene_spec.screen_type in ("game", "gameplay")
        cam_docs = self._create_camera(allocator, orthographic=is_game)
        cam_transform_id = cam_docs[1]["file_id"]  # Transform is second doc
        documents.extend(cam_docs)
        child_transform_ids.append(cam_transform_id)

        # 3. Directional Light (game scenes)
        if is_game or scene_spec.screen_type == "loading":
            light_docs = self._create_directional_light(allocator)
            child_transform_ids.append(light_docs[1]["file_id"])
            documents.extend(light_docs)

        # 4. Canvas + EventSystem (UI-based scenes)
        canvas_transform_id = None
        if scene_spec.screen_type in ("ui", "game", "loading", "transition"):
            canvas_docs = self._create_canvas(allocator)
            canvas_transform_id = canvas_docs[1]["file_id"]
            child_transform_ids.append(canvas_transform_id)
            documents.extend(canvas_docs)

            es_docs = self._create_event_system(allocator)
            child_transform_ids.append(es_docs[1]["file_id"])
            documents.extend(es_docs)

        # 5. Required elements from spec
        for elem in (scene_spec.required_elements or []):
            elem_name = elem.get("name", "Element") if isinstance(elem, dict) else str(elem)
            elem_type = elem.get("type", "empty") if isinstance(elem, dict) else "empty"

            components = []
            is_ui = canvas_transform_id is not None
            if elem_type in ("image", "sprite"):
                components.append("SpriteRenderer")
            elif elem_type in ("button", "text", "panel"):
                components.append("CanvasRenderer")
            elif elem_type == "animation":
                components.append("Animator")
            elif elem_type == "audio":
                components.append("AudioSource")
            elif elem_type == "particle":
                components.append("ParticleSystem")

            parent = canvas_transform_id if is_ui else None
            elem_docs = self._create_game_object(
                elem_name, allocator, components=components,
                parent_transform_id=parent, is_ui=is_ui,
            )
            if parent is None:
                child_transform_ids.append(elem_docs[1]["file_id"])
            documents.extend(elem_docs)

        # Serialize
        yaml_content = serialize_unity_yaml(documents)
        file_path = self._save_scene(yaml_content, scene_spec.name)

        result = {
            "success": True,
            "file_path": file_path,
            "document_count": len(documents),
            "file_size": len(yaml_content),
        }
        logger.info("Scene generated: %s (%d docs, %d bytes)", scene_spec.name, len(documents), len(yaml_content))
        return result

    def _create_base_settings(self, allocator: FileIDAllocator) -> list:
        """Create the 4 required scene settings documents."""
        docs = []

        # OcclusionCullingSettings
        docs.append({
            "class_id": get_class_id("OcclusionCullingSettings"),
            "file_id": allocator.next(),
            "type_name": "OcclusionCullingSettings",
            "data": {
                "m_ObjectHideFlags": 0,
                "serializedVersion": 2,
                "m_OcclusionBakeSettings": {
                    "smallestOccluder": 5,
                    "smallestHole": 0.25,
                    "backfaceThreshold": 100,
                },
            },
        })

        # RenderSettings
        docs.append({
            "class_id": get_class_id("RenderSettings"),
            "file_id": allocator.next(),
            "type_name": "RenderSettings",
            "data": {
                "m_ObjectHideFlags": 0,
                "serializedVersion": 9,
                "m_Fog": 0,
                "m_FogColor": {"r": 0.5, "g": 0.5, "b": 0.5, "a": 1},
                "m_FogMode": 3,
                "m_FogDensity": 0.01,
                "m_LinearFogStart": 0,
                "m_LinearFogEnd": 300,
                "m_AmbientSkyColor": {"r": 0.212, "g": 0.227, "b": 0.259, "a": 1},
                "m_AmbientEquatorColor": {"r": 0.114, "g": 0.125, "b": 0.133, "a": 1},
                "m_AmbientGroundColor": {"r": 0.047, "g": 0.043, "b": 0.035, "a": 1},
                "m_AmbientIntensity": 1,
                "m_AmbientMode": 3,
                "m_SubtractiveShadowColor": {"r": 0.42, "g": 0.478, "b": 0.627, "a": 1},
                "m_SkyboxMaterial": {"fileID": 0},
                "m_HaloStrength": 0.5,
                "m_FlareStrength": 1,
                "m_FlareFadeSpeed": 3,
                "m_HaloTexture": {"fileID": 0},
                "m_SpotCookie": {"fileID": 0},
                "m_DefaultReflectionMode": 0,
                "m_DefaultReflectionResolution": 128,
                "m_ReflectionBounces": 1,
                "m_ReflectionIntensity": 1,
                "m_CustomReflection": {"fileID": 0},
                "m_Sun": {"fileID": 0},
                "m_UseRadianceAmbientProbe": 0,
            },
        })

        # LightmapSettings
        docs.append({
            "class_id": get_class_id("LightmapSettings"),
            "file_id": allocator.next(),
            "type_name": "LightmapSettings",
            "data": {
                "m_ObjectHideFlags": 0,
                "serializedVersion": 12,
                "m_GIWorkflowMode": 1,
                "m_GISettings": {
                    "serializedVersion": 2,
                    "m_BounceScale": 1,
                    "m_IndirectOutputScale": 1,
                    "m_AlbedoBoost": 1,
                    "m_EnvironmentLightingMode": 0,
                    "m_EnableBakedLightmaps": 0,
                    "m_EnableRealtimeLightmaps": 0,
                },
                "m_LightmapEditorSettings": {
                    "serializedVersion": 12,
                    "m_Resolution": 2,
                    "m_BakeResolution": 40,
                    "m_AtlasSize": 1024,
                    "m_AO": 0,
                    "m_AOMaxDistance": 1,
                    "m_CompAOExponent": 1,
                    "m_CompAOExponentDirect": 0,
                    "m_ExtractAmbientOcclusion": 0,
                    "m_Padding": 2,
                    "m_LightmapParameters": {"fileID": 0},
                    "m_LightmapsBakeMode": 1,
                    "m_TextureCompression": 1,
                    "m_MixedBakeMode": 2,
                    "m_BakeBackend": 1,
                    "m_PVRSampling": 1,
                    "m_PVRDirectSampleCount": 32,
                    "m_PVRSampleCount": 512,
                    "m_PVRBounces": 2,
                    "m_PVREnvironmentSampleCount": 256,
                    "m_PVREnvironmentReferencePointCount": 2048,
                    "m_PVRFilteringMode": 1,
                    "m_PVRDenoiserTypeDirect": 1,
                    "m_PVRDenoiserTypeIndirect": 1,
                    "m_PVRDenoiserTypeAO": 1,
                    "m_PVRFilterTypeDirect": 0,
                    "m_PVRFilterTypeIndirect": 0,
                    "m_PVRFilterTypeAO": 0,
                    "m_PVREnvironmentMIS": 1,
                    "m_PVRCulling": 1,
                    "m_PVRFilteringGaussRadiusDirect": 1,
                    "m_PVRFilteringGaussRadiusIndirect": 5,
                    "m_PVRFilteringGaussRadiusAO": 2,
                    "m_PVRFilteringAtrousPositionSigmaDirect": 0.5,
                    "m_PVRFilteringAtrousPositionSigmaIndirect": 2,
                    "m_PVRFilteringAtrousPositionSigmaAO": 1,
                    "m_ExportTrainingData": 0,
                    "m_TrainingDataDestination": "TrainingData",
                    "m_LightProbeSampleCountMultiplier": 4,
                },
                "m_LightingDataAsset": {"fileID": 0},
                "m_LightingSettings": {"fileID": 0},
            },
        })

        # NavMeshSettings
        docs.append({
            "class_id": get_class_id("NavMeshSettings"),
            "file_id": allocator.next(),
            "type_name": "NavMeshSettings",
            "data": {
                "serializedVersion": 2,
                "m_ObjectHideFlags": 0,
                "m_BuildSettings": {
                    "serializedVersion": 2,
                    "agentTypeID": 0,
                    "agentRadius": 0.5,
                    "agentHeight": 2,
                    "agentSlope": 45,
                    "agentClimb": 0.4,
                    "ledgeDropHeight": 0,
                    "maxJumpAcrossDistance": 0,
                    "minRegionArea": 2,
                    "manualCellSize": 0,
                    "cellSize": 0.16666667,
                    "manualTileSize": 0,
                    "tileSize": 256,
                    "accuratePlacement": 0,
                    "maxJobWorkers": 0,
                    "preserveTilesOutsideBounds": 0,
                },
                "m_NavMeshData": {"fileID": 0},
            },
        })

        return docs

    def _create_camera(self, allocator: FileIDAllocator, orthographic=True, ortho_size=5) -> list:
        """Create Camera GameObject + Transform + Camera + AudioListener."""
        go_id = allocator.next()
        tr_id = allocator.next()
        cam_id = allocator.next()
        al_id = allocator.next()

        docs = []

        # GameObject
        docs.append({
            "class_id": get_class_id("GameObject"),
            "file_id": go_id,
            "type_name": "GameObject",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "serializedVersion": 6,
                "m_Component": [
                    {"component": {"fileID": tr_id}},
                    {"component": {"fileID": cam_id}},
                    {"component": {"fileID": al_id}},
                ],
                "m_Layer": 0,
                "m_Name": "Main Camera",
                "m_TagString": "MainCamera",
                "m_Icon": {"fileID": 0},
                "m_NavMeshLayer": 0,
                "m_StaticEditorFlags": 0,
                "m_IsActive": 1,
            },
        })

        # Transform
        docs.append({
            "class_id": get_class_id("Transform"),
            "file_id": tr_id,
            "type_name": "Transform",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_LocalRotation": {"x": 0, "y": 0, "z": 0, "w": 1},
                "m_LocalPosition": {"x": 0, "y": 0, "z": -10},
                "m_LocalScale": {"x": 1, "y": 1, "z": 1},
                "m_ConstrainProportionsScale": 0,
                "m_Children": [],
                "m_Father": {"fileID": 0},
                "m_RootOrder": 0,
                "m_LocalEulerAnglesHint": {"x": 0, "y": 0, "z": 0},
            },
        })

        # Camera
        docs.append({
            "class_id": get_class_id("Camera"),
            "file_id": cam_id,
            "type_name": "Camera",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_Enabled": 1,
                "serializedVersion": 2,
                "m_ClearFlags": 2,
                "m_BackGroundColor": {"r": 0.05, "g": 0.06, "b": 0.1, "a": 1},
                "m_projectionMatrixMode": 1 if orthographic else 0,
                "m_GateFitMode": 2,
                "m_FOVAxisMode": 0,
                "m_SensorSize": {"x": 36, "y": 24},
                "m_LensShift": {"x": 0, "y": 0},
                "m_FocalLength": 50,
                "m_NormalizedViewPortRect": {"x": 0, "y": 0, "z": 1, "w": 1},
                "near clip plane": 0.3,
                "far clip plane": 1000,
                "field of view": 60,
                "orthographic": 1 if orthographic else 0,
                "orthographic size": ortho_size,
                "m_Depth": -1,
                "m_CullingMask": {"serializedVersion": 2, "m_Bits": 4294967295},
                "m_RenderingPath": -1,
                "m_TargetTexture": {"fileID": 0},
                "m_TargetDisplay": 0,
                "m_TargetEye": 3,
                "m_HDR": 1,
                "m_AllowMSAA": 1,
                "m_AllowDynamicResolution": 0,
                "m_ForceIntoRenderTexture": 0,
                "m_OcclusionCulling": 1,
                "m_StereoConvergence": 10,
                "m_StereoSeparation": 0.022,
            },
        })

        # AudioListener
        docs.append({
            "class_id": get_class_id("AudioListener"),
            "file_id": al_id,
            "type_name": "AudioListener",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_Enabled": 1,
            },
        })

        return docs

    def _create_directional_light(self, allocator: FileIDAllocator) -> list:
        """Create Directional Light GameObject + Transform + Light."""
        go_id = allocator.next()
        tr_id = allocator.next()
        light_id = allocator.next()

        docs = []

        docs.append({
            "class_id": get_class_id("GameObject"),
            "file_id": go_id,
            "type_name": "GameObject",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "serializedVersion": 6,
                "m_Component": [
                    {"component": {"fileID": tr_id}},
                    {"component": {"fileID": light_id}},
                ],
                "m_Layer": 0,
                "m_Name": "Directional Light",
                "m_TagString": "Untagged",
                "m_Icon": {"fileID": 0},
                "m_NavMeshLayer": 0,
                "m_StaticEditorFlags": 0,
                "m_IsActive": 1,
            },
        })

        docs.append({
            "class_id": get_class_id("Transform"),
            "file_id": tr_id,
            "type_name": "Transform",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_LocalRotation": {"x": 0.40821788, "y": -0.23456968, "z": 0.10938163, "w": 0.8754261},
                "m_LocalPosition": {"x": 0, "y": 3, "z": 0},
                "m_LocalScale": {"x": 1, "y": 1, "z": 1},
                "m_ConstrainProportionsScale": 0,
                "m_Children": [],
                "m_Father": {"fileID": 0},
                "m_RootOrder": 1,
                "m_LocalEulerAnglesHint": {"x": 50, "y": -30, "z": 0},
            },
        })

        docs.append({
            "class_id": get_class_id("Light"),
            "file_id": light_id,
            "type_name": "Light",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_Enabled": 1,
                "serializedVersion": 10,
                "m_Type": 1,
                "m_Shape": 0,
                "m_Color": {"r": 1, "g": 0.956, "b": 0.839, "a": 1},
                "m_Intensity": 1,
                "m_Range": 10,
                "m_SpotAngle": 30,
                "m_InnerSpotAngle": 21.8,
                "m_CookieSize": 10,
                "m_Shadows": {
                    "m_Type": 2,
                    "m_Resolution": -1,
                    "m_CustomResolution": -1,
                    "m_Strength": 1,
                    "m_Bias": 0.05,
                    "m_NormalBias": 0.4,
                    "m_NearPlane": 0.2,
                    "m_CullingMatrixOverride": {
                        "e00": 1, "e01": 0, "e02": 0, "e03": 0,
                        "e10": 0, "e11": 1, "e12": 0, "e13": 0,
                        "e20": 0, "e21": 0, "e22": 1, "e23": 0,
                        "e30": 0, "e31": 0, "e32": 0, "e33": 1,
                    },
                    "m_UseCullingMatrixOverride": 0,
                },
                "m_Cookie": {"fileID": 0},
                "m_DrawHalo": 0,
                "m_Flare": {"fileID": 0},
                "m_RenderMode": 0,
                "m_CullingMask": {"serializedVersion": 2, "m_Bits": 4294967295},
                "m_RenderingLayerMask": 1,
                "m_Lightmapping": 4,
                "m_LightShadowCasterMode": 0,
                "m_AreaSize": {"x": 1, "y": 1},
                "m_BounceIntensity": 1,
                "m_ColorTemperature": 6570,
                "m_UseColorTemperature": 0,
                "m_BoundingSphereOverride": {"x": 0, "y": 0, "z": 0, "w": 0},
                "m_UseBoundingSphereOverride": 0,
                "m_UseViewFrustumForShadowCasterCull": 1,
                "m_ShadowRadius": 0,
                "m_ShadowAngle": 0,
            },
        })

        return docs

    def _create_canvas(self, allocator: FileIDAllocator, render_mode=0) -> list:
        """Create Canvas GameObject + RectTransform + Canvas + CanvasGroup."""
        go_id = allocator.next()
        rt_id = allocator.next()
        canvas_id = allocator.next()
        cg_id = allocator.next()

        docs = []

        docs.append({
            "class_id": get_class_id("GameObject"),
            "file_id": go_id,
            "type_name": "GameObject",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "serializedVersion": 6,
                "m_Component": [
                    {"component": {"fileID": rt_id}},
                    {"component": {"fileID": canvas_id}},
                    {"component": {"fileID": cg_id}},
                ],
                "m_Layer": 5,
                "m_Name": "Canvas",
                "m_TagString": "Untagged",
                "m_Icon": {"fileID": 0},
                "m_NavMeshLayer": 0,
                "m_StaticEditorFlags": 0,
                "m_IsActive": 1,
            },
        })

        docs.append({
            "class_id": get_class_id("RectTransform"),
            "file_id": rt_id,
            "type_name": "RectTransform",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_LocalRotation": {"x": 0, "y": 0, "z": 0, "w": 1},
                "m_LocalPosition": {"x": 0, "y": 0, "z": 0},
                "m_LocalScale": {"x": 0, "y": 0, "z": 0},
                "m_ConstrainProportionsScale": 0,
                "m_Children": [],
                "m_Father": {"fileID": 0},
                "m_RootOrder": 2,
                "m_LocalEulerAnglesHint": {"x": 0, "y": 0, "z": 0},
                "m_AnchorMin": {"x": 0, "y": 0},
                "m_AnchorMax": {"x": 0, "y": 0},
                "m_AnchoredPosition": {"x": 0, "y": 0},
                "m_SizeDelta": {"x": 0, "y": 0},
                "m_Pivot": {"x": 0, "y": 0},
            },
        })

        docs.append({
            "class_id": get_class_id("Canvas"),
            "file_id": canvas_id,
            "type_name": "Canvas",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_Enabled": 1,
                "serializedVersion": 3,
                "m_RenderMode": render_mode,
                "m_Camera": {"fileID": 0},
                "m_PlaneDistance": 100,
                "m_PixelPerfect": 0,
                "m_ReceivesEvents": 1,
                "m_OverrideSorting": 0,
                "m_OverridePixelPerfect": 0,
                "m_SortingBucketNormalizedSize": 0,
                "m_VertexColorAlwaysGammaSpace": 0,
                "m_AdditionalShaderChannelsFlag": 25,
                "m_UpdateRectTransformForStandalone": 0,
                "m_SortingLayerID": 0,
                "m_SortingOrder": 0,
                "m_TargetDisplay": 0,
            },
        })

        docs.append({
            "class_id": get_class_id("CanvasGroup"),
            "file_id": cg_id,
            "type_name": "CanvasGroup",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_Enabled": 1,
                "m_Alpha": 1,
                "m_Interactable": 1,
                "m_BlocksRaycasts": 1,
                "m_IgnoreParentGroups": 0,
            },
        })

        return docs

    def _create_event_system(self, allocator: FileIDAllocator) -> list:
        """Create EventSystem GameObject + Transform + 2 MonoBehaviours."""
        go_id = allocator.next()
        tr_id = allocator.next()
        es_id = allocator.next()
        sim_id = allocator.next()

        docs = []

        docs.append({
            "class_id": get_class_id("GameObject"),
            "file_id": go_id,
            "type_name": "GameObject",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "serializedVersion": 6,
                "m_Component": [
                    {"component": {"fileID": tr_id}},
                    {"component": {"fileID": es_id}},
                    {"component": {"fileID": sim_id}},
                ],
                "m_Layer": 0,
                "m_Name": "EventSystem",
                "m_TagString": "Untagged",
                "m_Icon": {"fileID": 0},
                "m_NavMeshLayer": 0,
                "m_StaticEditorFlags": 0,
                "m_IsActive": 1,
            },
        })

        docs.append({
            "class_id": get_class_id("Transform"),
            "file_id": tr_id,
            "type_name": "Transform",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_LocalRotation": {"x": 0, "y": 0, "z": 0, "w": 1},
                "m_LocalPosition": {"x": 0, "y": 0, "z": 0},
                "m_LocalScale": {"x": 1, "y": 1, "z": 1},
                "m_ConstrainProportionsScale": 0,
                "m_Children": [],
                "m_Father": {"fileID": 0},
                "m_RootOrder": 3,
                "m_LocalEulerAnglesHint": {"x": 0, "y": 0, "z": 0},
            },
        })

        # EventSystem MonoBehaviour
        docs.append({
            "class_id": get_class_id("MonoBehaviour"),
            "file_id": es_id,
            "type_name": "MonoBehaviour",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_Enabled": 1,
                "m_EditorHideFlags": 0,
                "m_Script": {"fileID": 11500000, "guid": "76c392e42b5d94c24012c78e3b39e282", "type": 3},
                "m_Name": "",
                "m_EditorClassIdentifier": "",
                "m_FirstSelected": {"fileID": 0},
                "m_sendNavigationEvents": 1,
                "m_DragThreshold": 10,
            },
        })

        # StandaloneInputModule MonoBehaviour
        docs.append({
            "class_id": get_class_id("MonoBehaviour"),
            "file_id": sim_id,
            "type_name": "MonoBehaviour",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": go_id},
                "m_Enabled": 1,
                "m_EditorHideFlags": 0,
                "m_Script": {"fileID": 11500000, "guid": "4f231c4fb786f3946a6b90b886c48677", "type": 3},
                "m_Name": "",
                "m_EditorClassIdentifier": "",
                "m_HorizontalAxis": "Horizontal",
                "m_VerticalAxis": "Vertical",
                "m_SubmitButton": "Submit",
                "m_CancelButton": "Cancel",
                "m_InputActionsPerSecond": 10,
                "m_RepeatDelay": 0.5,
                "m_ForceModuleActive": 0,
            },
        })

        return docs

    def _create_game_object(self, name, allocator, components=None,
                            parent_transform_id=None, is_ui=False) -> list:
        """Create a generic GameObject with specified components."""
        go_id = allocator.next()
        tr_id = allocator.next()

        tr_type = "RectTransform" if is_ui else "Transform"
        comp_docs = []
        comp_refs = [{"component": {"fileID": tr_id}}]

        for comp_type in (components or []):
            comp_id = allocator.next()
            comp_refs.append({"component": {"fileID": comp_id}})
            comp_docs.append(self._create_component(comp_type, comp_id, go_id))

        docs = []

        docs.append({
            "class_id": get_class_id("GameObject"),
            "file_id": go_id,
            "type_name": "GameObject",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "serializedVersion": 6,
                "m_Component": comp_refs,
                "m_Layer": 5 if is_ui else 0,
                "m_Name": name,
                "m_TagString": "Untagged",
                "m_Icon": {"fileID": 0},
                "m_NavMeshLayer": 0,
                "m_StaticEditorFlags": 0,
                "m_IsActive": 1,
            },
        })

        tr_data = {
            "m_ObjectHideFlags": 0,
            "m_CorrespondingSourceObject": {"fileID": 0},
            "m_PrefabInstance": {"fileID": 0},
            "m_PrefabAsset": {"fileID": 0},
            "m_GameObject": {"fileID": go_id},
            "m_LocalRotation": {"x": 0, "y": 0, "z": 0, "w": 1},
            "m_LocalPosition": {"x": 0, "y": 0, "z": 0},
            "m_LocalScale": {"x": 1, "y": 1, "z": 1},
            "m_ConstrainProportionsScale": 0,
            "m_Children": [],
            "m_Father": {"fileID": parent_transform_id or 0},
            "m_RootOrder": 0,
            "m_LocalEulerAnglesHint": {"x": 0, "y": 0, "z": 0},
        }

        if is_ui:
            tr_data["m_AnchorMin"] = {"x": 0, "y": 0}
            tr_data["m_AnchorMax"] = {"x": 1, "y": 1}
            tr_data["m_AnchoredPosition"] = {"x": 0, "y": 0}
            tr_data["m_SizeDelta"] = {"x": 0, "y": 0}
            tr_data["m_Pivot"] = {"x": 0.5, "y": 0.5}

        docs.append({
            "class_id": get_class_id(tr_type),
            "file_id": tr_id,
            "type_name": tr_type,
            "data": tr_data,
        })

        docs.extend(comp_docs)
        return docs

    def _create_component(self, type_name, comp_id, go_id) -> dict:
        """Create a component document with appropriate defaults."""
        base = {
            "m_ObjectHideFlags": 0,
            "m_CorrespondingSourceObject": {"fileID": 0},
            "m_PrefabInstance": {"fileID": 0},
            "m_PrefabAsset": {"fileID": 0},
            "m_GameObject": {"fileID": go_id},
            "m_Enabled": 1,
        }

        if type_name == "SpriteRenderer":
            base.update({
                "m_CastShadows": 0,
                "m_ReceiveShadows": 0,
                "m_DynamicOccludee": 1,
                "m_StaticShadowCaster": 0,
                "m_MotionVectors": 1,
                "m_LightProbeUsage": 1,
                "m_ReflectionProbeUsage": 1,
                "m_RayTracingMode": 0,
                "m_RenderingLayerMask": 1,
                "m_RendererPriority": 0,
                "m_SortingLayerID": 0,
                "m_SortingLayer": 0,
                "m_SortingOrder": 0,
                "m_Sprite": {"fileID": 0},
                "m_Color": {"r": 1, "g": 1, "b": 1, "a": 1},
                "m_FlipX": 0,
                "m_FlipY": 0,
                "m_DrawMode": 0,
                "m_Size": {"x": 1, "y": 1},
                "m_AdaptiveModeThreshold": 0.5,
                "m_SpriteTileMode": 0,
                "m_WasSpriteAssigned": 0,
                "m_MaskInteraction": 0,
                "m_SpriteSortPoint": 0,
            })
        elif type_name == "BoxCollider2D":
            base.update({
                "m_Density": 1,
                "m_Material": {"fileID": 0},
                "m_IsTrigger": 0,
                "m_UsedByEffector": 0,
                "m_UsedByComposite": 0,
                "m_Offset": {"x": 0, "y": 0},
                "m_SpriteTilingProperty": {
                    "border": {"x": 0, "y": 0, "z": 0, "w": 0},
                    "pivot": {"x": 0.5, "y": 0.5},
                    "oldSize": {"x": 1, "y": 1},
                    "newSize": {"x": 1, "y": 1},
                    "adaptiveTilingThreshold": 0.5,
                    "drawMode": 0,
                    "adaptiveTiling": 0,
                },
                "m_AutoTiling": 0,
                "serializedVersion": 2,
                "m_Size": {"x": 1, "y": 1},
                "m_EdgeRadius": 0,
            })
        elif type_name == "Animator":
            base.update({
                "serializedVersion": 5,
                "m_Controller": {"fileID": 0},
                "m_Avatar": {"fileID": 0},
                "m_ApplyRootMotion": 0,
                "m_LinearVelocityBlending": 0,
                "m_StabilizeFeet": 0,
                "m_HasTransformHierarchy": 1,
                "m_AllowConstantClipSamplingOptimization": 1,
                "m_KeepAnimatorStateOnDisable": 0,
                "m_WriteDefaultValuesOnDisable": 0,
            })
        elif type_name == "AudioSource":
            base.update({
                "serializedVersion": 4,
                "OutputAudioMixerGroup": {"fileID": 0},
                "m_audioClip": {"fileID": 0},
                "m_PlayOnAwake": 0,
                "m_Volume": 1,
                "m_Pitch": 1,
                "Loop": 0,
                "Mute": 0,
                "Spatialize": 0,
                "SpatializePostEffects": 0,
                "Priority": 128,
                "DopplerLevel": 1,
                "MinDistance": 1,
                "MaxDistance": 500,
                "Pan2D": 0,
                "rolloffMode": 0,
                "BypassEffects": 0,
                "BypassListenerEffects": 0,
                "BypassReverbZones": 0,
            })
        elif type_name == "ParticleSystem":
            base.update({
                "serializedVersion": 8,
                "lengthInSec": 5,
                "simulationSpeed": 1,
                "looping": 1,
                "prewarm": 0,
                "playOnAwake": 1,
                "useUnscaledTime": 0,
                "autoRandomSeed": 1,
                "useRigidbodyForVelocity": 1,
                "startDelay": 0,
                "moveWithTransform": 0,
                "moveWithCustomTransform": {"fileID": 0},
                "scalingMode": 1,
                "ringBufferMode": 0,
                "ringBufferLoopRange": {"x": 0, "y": 1},
                "emitterVelocityMode": 0,
            })
        elif type_name == "CanvasRenderer":
            base.update({
                "m_CullTransparentMesh": 1,
            })
        else:
            # MonoBehaviour fallback
            base.update({
                "m_EditorHideFlags": 0,
                "m_Script": {"fileID": 0},
                "m_Name": "",
                "m_EditorClassIdentifier": "",
            })

        return {
            "class_id": get_class_id(type_name),
            "file_id": comp_id,
            "type_name": type_name,
            "data": base,
        }

    def _save_scene(self, yaml_content, scene_name) -> str:
        """Save to .unity file."""
        safe_name = scene_name.replace(" ", "_").replace("/", "_")
        path = self.OUTPUT_DIR / f"{safe_name}.unity"
        path.write_text(yaml_content, encoding="utf-8")
        return str(path)

    def generate_batch(self, specs: list) -> list:
        """Generate all scenes from specs."""
        results = []
        for spec in specs:
            try:
                results.append(self.generate(spec))
            except Exception as e:
                logger.error("Scene generation failed for %s: %s", spec.name, e)
                results.append({"success": False, "error": str(e), "name": spec.name})
        return results
