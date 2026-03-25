"""Unity-compatible YAML serializer.

Unity YAML is NOT standard YAML. Key differences:
- Header: %YAML 1.1 + %TAG !u! tag:unity3d.com,2011:
- Document separator: --- !u!{classID} &{fileID}
- Flow-style for vectors/quaternions: {x: 0, y: 0, z: 0, w: 1}
- No quotes around string values (usually)
- Specific indentation (2 spaces)

Do NOT use PyYAML -- it produces incompatible output.
"""


def serialize_unity_yaml(documents: list) -> str:
    """Serialize a list of Unity documents into a .unity or .prefab file.

    Each document is a dict with:
    - class_id: int (Unity ClassID)
    - file_id: int (unique within file)
    - type_name: str (e.g. "GameObject", "Transform")
    - data: dict (the serialized properties)

    Returns the complete file content as string.
    """
    lines = ["%YAML 1.1", "%TAG !u! tag:unity3d.com,2011:"]
    for doc in documents:
        lines.append(f"--- !u!{doc['class_id']} &{doc['file_id']}")
        lines.append(f"{doc['type_name']}:")
        lines.extend(_serialize_dict(doc["data"], indent=1))
    return "\n".join(lines) + "\n"


def _serialize_dict(data: dict, indent: int) -> list:
    """Recursively serialize a dict into Unity YAML lines."""
    lines = []
    prefix = "  " * indent
    for key, value in data.items():
        if value is None:
            lines.append(f"{prefix}{key}: ")
        elif isinstance(value, bool):
            lines.append(f"{prefix}{key}: {'1' if value else '0'}")
        elif isinstance(value, (int, float)):
            lines.append(f"{prefix}{key}: {value}")
        elif isinstance(value, str):
            lines.append(f"{prefix}{key}: {value}")
        elif isinstance(value, dict):
            if _is_vector_dict(value):
                lines.append(f"{prefix}{key}: {_format_flow_dict(value)}")
            elif _is_file_ref(value):
                lines.append(f"{prefix}{key}: {_format_flow_dict(value)}")
            elif len(value) == 0:
                lines.append(f"{prefix}{key}: {{}}")
            else:
                lines.append(f"{prefix}{key}:")
                lines.extend(_serialize_dict(value, indent + 1))
        elif isinstance(value, list):
            if len(value) == 0:
                lines.append(f"{prefix}{key}: []")
            else:
                lines.append(f"{prefix}{key}:")
                for item in value:
                    if isinstance(item, dict):
                        if _is_file_ref(item):
                            lines.append(f"{prefix}- {_format_flow_dict(item)}")
                        elif _is_vector_dict(item):
                            lines.append(f"{prefix}- {_format_flow_dict(item)}")
                        else:
                            # First key-value on same line as dash
                            items_list = list(item.items())
                            first_key, first_val = items_list[0]
                            if isinstance(first_val, dict) and not _is_vector_dict(first_val) and not _is_file_ref(first_val):
                                lines.append(f"{prefix}- {first_key}:")
                                lines.extend(_serialize_dict(first_val, indent + 2))
                            else:
                                lines.append(f"{prefix}- {first_key}: {_format_inline_value(first_val)}")
                            for k, v in items_list[1:]:
                                if isinstance(v, dict) and not _is_vector_dict(v) and not _is_file_ref(v):
                                    lines.append(f"{prefix}  {k}:")
                                    lines.extend(_serialize_dict(v, indent + 2))
                                else:
                                    lines.append(f"{prefix}  {k}: {_format_inline_value(v)}")
                    else:
                        lines.append(f"{prefix}- {_format_value(value=item)}")
        else:
            lines.append(f"{prefix}{key}: {value}")
    return lines


def _is_vector_dict(d: dict) -> bool:
    """Check if dict is a vector/quaternion (x,y,z or x,y,z,w or r,g,b,a keys)."""
    keys = set(d.keys())
    return keys in ({"x", "y", "z"}, {"x", "y", "z", "w"}, {"r", "g", "b", "a"})


def _is_file_ref(d: dict) -> bool:
    """Check if dict is a fileID reference."""
    return "fileID" in d and len(d) <= 3


def _format_flow_dict(d: dict) -> str:
    """Format a dict as Unity flow-style: {x: 0, y: 0, z: 0}"""
    pairs = [f"{k}: {_format_value(v)}" for k, v in d.items()]
    return "{" + ", ".join(pairs) + "}"


def _format_value(value) -> str:
    """Format a single value for Unity YAML."""
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, (int, float)):
        return str(value)
    if value is None:
        return ""
    return str(value)


def _format_inline_value(value) -> str:
    """Format a value for inline use in list items."""
    if isinstance(value, dict):
        if _is_vector_dict(value) or _is_file_ref(value):
            return _format_flow_dict(value)
        if len(value) == 0:
            return "{}"
        return _format_flow_dict(value)
    if isinstance(value, list):
        if len(value) == 0:
            return "[]"
        return str(value)
    return _format_value(value)


def make_file_id_ref(file_id: int) -> dict:
    """Create a fileID reference dict."""
    return {"fileID": file_id}


def make_guid_ref(file_id: int, guid: str, type_id: int = 3) -> dict:
    """Create a GUID reference dict for external assets."""
    return {"fileID": file_id, "guid": guid, "type": type_id}
