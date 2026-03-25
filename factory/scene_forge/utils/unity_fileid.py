"""Unity ClassID mapping for YAML serialization."""

# Unity ClassID -> Type Name mapping (most common types)
UNITY_CLASS_IDS = {
    "GameObject": 1,
    "Transform": 4,
    "Camera": 20,
    "Rigidbody2D": 50,
    "CircleCollider2D": 58,
    "BoxCollider2D": 61,
    "AudioListener": 81,
    "AudioSource": 82,
    "Animator": 95,
    "RenderSettings": 104,
    "Light": 108,
    "MonoBehaviour": 114,
    "LightmapSettings": 157,
    "NavMeshSettings": 196,
    "ParticleSystem": 198,
    "SpriteRenderer": 212,
    "CanvasRenderer": 222,
    "Canvas": 223,
    "RectTransform": 224,
    "CanvasGroup": 225,
    "OcclusionCullingSettings": 29,
}


def get_class_id(type_name: str) -> int:
    """Get Unity ClassID for a type. Returns 114 (MonoBehaviour) for unknown custom types."""
    return UNITY_CLASS_IDS.get(type_name, 114)


def is_builtin_type(type_name: str) -> bool:
    """Check if type is a built-in Unity type (vs custom MonoBehaviour)."""
    return type_name in UNITY_CLASS_IDS
