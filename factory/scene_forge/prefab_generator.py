"""Prefab Generator -- generates Unity .prefab files as serialized YAML."""

import logging
from pathlib import Path

from factory.scene_forge.utils.unity_guid import generate_guid, FileIDAllocator
from factory.scene_forge.utils.unity_fileid import get_class_id
from factory.scene_forge.utils.yaml_serializer import (
    serialize_unity_yaml,
    make_file_id_ref,
)

logger = logging.getLogger(__name__)


class PrefabGenerator:
    """Generates Unity Prefab files from PrefabSpecs."""

    OUTPUT_DIR = Path(__file__).parent / "generated" / "prefabs"

    def __init__(self, output_dir=None):
        if output_dir:
            self.OUTPUT_DIR = Path(output_dir)
        self.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    def generate(self, prefab_spec) -> dict:
        """Generate a prefab from spec.

        Returns: {success, file_path, meta_path, component_count}
        """
        allocator = FileIDAllocator()
        documents = []

        # 1. Root GameObject + Transform
        root_go_id = allocator.next()
        root_tr_id = allocator.next()

        # Collect component docs and refs for root
        root_comp_docs = []
        root_comp_refs = [{"component": {"fileID": root_tr_id}}]

        for comp in (prefab_spec.components or []):
            comp_type = comp.get("type", "MonoBehaviour") if isinstance(comp, dict) else str(comp)
            comp_id = allocator.next()
            root_comp_refs.append({"component": {"fileID": comp_id}})
            root_comp_docs.append(self._create_component(comp_type, comp_id, root_go_id, comp))

        # 2. Create children
        child_transform_ids = []
        child_docs = []

        for child_def in (prefab_spec.children or []):
            child_name = child_def.get("name", "Child") if isinstance(child_def, dict) else str(child_def)
            child_components = child_def.get("components", []) if isinstance(child_def, dict) else []

            child_go_id = allocator.next()
            child_tr_id = allocator.next()
            child_transform_ids.append(child_tr_id)

            child_comp_refs = [{"component": {"fileID": child_tr_id}}]
            child_comp_docs = []

            for cc in child_components:
                cc_type = cc.get("type", "MonoBehaviour") if isinstance(cc, dict) else str(cc)
                cc_id = allocator.next()
                child_comp_refs.append({"component": {"fileID": cc_id}})
                child_comp_docs.append(self._create_component(cc_type, cc_id, child_go_id, cc))

            # Child GameObject
            child_docs.append({
                "class_id": get_class_id("GameObject"),
                "file_id": child_go_id,
                "type_name": "GameObject",
                "data": {
                    "m_ObjectHideFlags": 0,
                    "m_CorrespondingSourceObject": {"fileID": 0},
                    "m_PrefabInstance": {"fileID": 0},
                    "m_PrefabAsset": {"fileID": 0},
                    "serializedVersion": 6,
                    "m_Component": child_comp_refs,
                    "m_Layer": 0,
                    "m_Name": child_name,
                    "m_TagString": "Untagged",
                    "m_Icon": {"fileID": 0},
                    "m_NavMeshLayer": 0,
                    "m_StaticEditorFlags": 0,
                    "m_IsActive": 1,
                },
            })

            # Child Transform (parent = root)
            child_docs.append({
                "class_id": get_class_id("Transform"),
                "file_id": child_tr_id,
                "type_name": "Transform",
                "data": {
                    "m_ObjectHideFlags": 0,
                    "m_CorrespondingSourceObject": {"fileID": 0},
                    "m_PrefabInstance": {"fileID": 0},
                    "m_PrefabAsset": {"fileID": 0},
                    "m_GameObject": {"fileID": child_go_id},
                    "m_LocalRotation": {"x": 0, "y": 0, "z": 0, "w": 1},
                    "m_LocalPosition": {"x": 0, "y": 0, "z": 0},
                    "m_LocalScale": {"x": 1, "y": 1, "z": 1},
                    "m_ConstrainProportionsScale": 0,
                    "m_Children": [],
                    "m_Father": {"fileID": root_tr_id},
                    "m_RootOrder": len(child_transform_ids) - 1,
                    "m_LocalEulerAnglesHint": {"x": 0, "y": 0, "z": 0},
                },
            })

            child_docs.extend(child_comp_docs)

        # 3. Root GameObject
        documents.append({
            "class_id": get_class_id("GameObject"),
            "file_id": root_go_id,
            "type_name": "GameObject",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "serializedVersion": 6,
                "m_Component": root_comp_refs,
                "m_Layer": 0,
                "m_Name": prefab_spec.name,
                "m_TagString": "Untagged",
                "m_Icon": {"fileID": 0},
                "m_NavMeshLayer": 0,
                "m_StaticEditorFlags": 0,
                "m_IsActive": 1,
            },
        })

        # 4. Root Transform (with children refs)
        documents.append({
            "class_id": get_class_id("Transform"),
            "file_id": root_tr_id,
            "type_name": "Transform",
            "data": {
                "m_ObjectHideFlags": 0,
                "m_CorrespondingSourceObject": {"fileID": 0},
                "m_PrefabInstance": {"fileID": 0},
                "m_PrefabAsset": {"fileID": 0},
                "m_GameObject": {"fileID": root_go_id},
                "m_LocalRotation": {"x": 0, "y": 0, "z": 0, "w": 1},
                "m_LocalPosition": {"x": 0, "y": 0, "z": 0},
                "m_LocalScale": {"x": 1, "y": 1, "z": 1},
                "m_ConstrainProportionsScale": 0,
                "m_Children": [{"fileID": tid} for tid in child_transform_ids],
                "m_Father": {"fileID": 0},
                "m_RootOrder": 0,
                "m_LocalEulerAnglesHint": {"x": 0, "y": 0, "z": 0},
            },
        })

        # 5. Root components
        documents.extend(root_comp_docs)

        # 6. Children
        documents.extend(child_docs)

        # 7. Serialize + save
        yaml_content = serialize_unity_yaml(documents)
        file_path = self._save_prefab(yaml_content, prefab_spec.name)

        # 8. Meta file
        guid = generate_guid(prefab_spec.name, namespace="prefab")
        meta_path = self._create_meta_file(file_path, guid)

        total_components = len(root_comp_docs) + sum(
            1 for doc in child_docs if doc["type_name"] not in ("GameObject", "Transform")
        )

        result = {
            "success": True,
            "file_path": file_path,
            "meta_path": meta_path,
            "component_count": total_components,
            "document_count": len(documents),
            "guid": guid,
        }
        logger.info("Prefab generated: %s (%d docs, %d components)",
                     prefab_spec.name, len(documents), total_components)
        return result

    def _create_component(self, type_name, comp_id, go_id, comp_def=None) -> dict:
        """Create a component document with appropriate defaults."""
        config = {}
        if isinstance(comp_def, dict):
            config = comp_def.get("config", {}) or {}

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
                "m_RenderingLayerMask": 1,
                "m_RendererPriority": 0,
                "m_SortingLayerID": 0,
                "m_SortingOrder": config.get("sorting_order", 0),
                "m_Sprite": {"fileID": 0},
                "m_Color": {"r": 1, "g": 1, "b": 1, "a": 1},
                "m_FlipX": 0,
                "m_FlipY": 0,
                "m_DrawMode": 0,
                "m_Size": {"x": 1, "y": 1},
                "m_SpriteTileMode": 0,
                "m_MaskInteraction": 0,
            })
        elif type_name == "BoxCollider2D":
            base.update({
                "m_Density": 1,
                "m_Material": {"fileID": 0},
                "m_IsTrigger": 1 if config.get("is_trigger") else 0,
                "m_UsedByEffector": 0,
                "m_UsedByComposite": 0,
                "m_Offset": {"x": 0, "y": 0},
                "m_AutoTiling": 0,
                "serializedVersion": 2,
                "m_Size": {"x": config.get("width", 1), "y": config.get("height", 1)},
                "m_EdgeRadius": 0,
            })
        elif type_name == "CircleCollider2D":
            base.update({
                "m_Density": 1,
                "m_Material": {"fileID": 0},
                "m_IsTrigger": 1 if config.get("is_trigger") else 0,
                "m_UsedByEffector": 0,
                "m_UsedByComposite": 0,
                "m_Offset": {"x": 0, "y": 0},
                "serializedVersion": 2,
                "m_Radius": config.get("radius", 0.5),
            })
        elif type_name == "Rigidbody2D":
            base.update({
                "serializedVersion": 4,
                "m_BodyType": config.get("body_type", 0),
                "m_Simulated": 1,
                "m_UseFullKinematicContacts": 0,
                "m_UseAutoMass": 0,
                "m_Mass": config.get("mass", 1),
                "m_LinearDrag": 0,
                "m_AngularDrag": 0.05,
                "m_GravityScale": config.get("gravity_scale", 1),
                "m_Material": {"fileID": 0},
                "m_Interpolate": 0,
                "m_SleepingMode": 1,
                "m_CollisionDetection": 0,
                "m_Constraints": 0,
            })
        elif type_name == "Animator":
            base.update({
                "serializedVersion": 5,
                "m_Controller": {"fileID": 0},
                "m_Avatar": {"fileID": 0},
                "m_ApplyRootMotion": 0,
                "m_LinearVelocityBlending": 0,
                "m_HasTransformHierarchy": 1,
                "m_AllowConstantClipSamplingOptimization": 1,
                "m_KeepAnimatorStateOnDisable": 0,
            })
        elif type_name == "AudioSource":
            base.update({
                "serializedVersion": 4,
                "OutputAudioMixerGroup": {"fileID": 0},
                "m_audioClip": {"fileID": 0},
                "m_PlayOnAwake": 1 if config.get("play_on_awake") else 0,
                "m_Volume": config.get("volume", 1),
                "m_Pitch": 1,
                "Loop": 1 if config.get("loop") else 0,
                "Mute": 0,
                "Priority": 128,
                "MinDistance": 1,
                "MaxDistance": 500,
            })
        elif type_name == "ParticleSystem":
            base.update({
                "serializedVersion": 8,
                "lengthInSec": config.get("duration", 5),
                "simulationSpeed": 1,
                "looping": 1 if config.get("looping", True) else 0,
                "prewarm": 0,
                "playOnAwake": 1,
                "useUnscaledTime": 0,
                "autoRandomSeed": 1,
                "scalingMode": 1,
            })
        elif type_name == "CanvasRenderer":
            base.update({
                "m_CullTransparentMesh": 1,
            })
        elif type_name == "Canvas":
            base.update({
                "serializedVersion": 3,
                "m_RenderMode": config.get("render_mode", 0),
                "m_Camera": {"fileID": 0},
                "m_PlaneDistance": 100,
                "m_PixelPerfect": 0,
                "m_ReceivesEvents": 1,
                "m_SortingLayerID": 0,
                "m_SortingOrder": 0,
                "m_TargetDisplay": 0,
            })
        else:
            # MonoBehaviour (custom script)
            base.update({
                "m_EditorHideFlags": 0,
                "m_Script": {"fileID": 0},
                "m_Name": "",
                "m_EditorClassIdentifier": "",
            })
            # Add any custom config fields
            for k, v in config.items():
                base[k] = v

        return {
            "class_id": get_class_id(type_name),
            "file_id": comp_id,
            "type_name": type_name,
            "data": base,
        }

    def _save_prefab(self, yaml_content, prefab_name) -> str:
        """Save prefab to .prefab file."""
        safe_name = prefab_name.replace(" ", "_").replace("/", "_")
        path = self.OUTPUT_DIR / f"{safe_name}.prefab"
        path.write_text(yaml_content, encoding="utf-8")
        return str(path)

    def _create_meta_file(self, prefab_path: str, guid: str) -> str:
        """Create a Unity .meta file for the prefab."""
        meta_content = f"""fileFormatVersion: 2
guid: {guid}
PrefabImporter:
  externalObjects: {{}}
  userData:
  assetBundleName:
  assetBundleVariant:
"""
        meta_path = prefab_path + ".meta"
        Path(meta_path).write_text(meta_content, encoding="utf-8")
        return meta_path

    def generate_batch(self, specs: list) -> list:
        """Generate all prefabs from specs."""
        results = []
        for spec in specs:
            try:
                results.append(self.generate(spec))
            except Exception as e:
                logger.error("Prefab generation failed for %s: %s", spec.name, e)
                results.append({"success": False, "error": str(e), "name": spec.name})
        return results
