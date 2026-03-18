# factory/orchestrator/layer_context.py
# Tracks what each layer produced for injection into subsequent layers.

from factory.orchestrator.build_layers import BuildLayer, LAYER_NAMES


class LayerContext:
    """Tracks what each layer produced, for injection into subsequent layers."""

    def __init__(self):
        self.layers: dict[BuildLayer, list[str]] = {}

    def record_layer_output(self, layer: BuildLayer, type_names: list[str]):
        """Record the types produced by a layer."""
        self.layers[layer] = type_names

    def get_context_for_layer(self, target_layer: BuildLayer) -> str:
        """Build context string for a layer, including all prior layers."""
        parts = []
        for layer in BuildLayer:
            if layer.value >= target_layer.value:
                break
            names = self.layers.get(layer, [])
            if names:
                label = LAYER_NAMES[layer]
                parts.append(f"{label}: {', '.join(names)}")
        if not parts:
            return ""
        return "[CONTEXT: " + " | ".join(parts) + "]"

    def get_types_for_layer(self, layer: BuildLayer) -> list[str]:
        """Get type names produced by a specific layer."""
        return self.layers.get(layer, [])

    def get_all_prior_types(self, target_layer: BuildLayer) -> list[str]:
        """Get all type names from layers before the target."""
        result = []
        for layer in BuildLayer:
            if layer.value >= target_layer.value:
                break
            result.extend(self.layers.get(layer, []))
        return result
