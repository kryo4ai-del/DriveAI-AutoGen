"""Shader Generator -- generates URP-compatible HLSL shaders from ShaderSpecs."""

import logging
import re
from pathlib import Path

logger = logging.getLogger(__name__)


class ShaderGenerator:
    """Generates Unity URP shaders from ShaderSpecs."""

    TEMPLATE_DIR = Path(__file__).parent / "shader_templates"
    OUTPUT_DIR = Path(__file__).parent / "generated" / "shaders"

    # Map effect_type to template filename (without .shader)
    EFFECT_TO_TEMPLATE = {
        "unlit": "urp_unlit_color",
        "bloom_emission": "urp_bloom_emission",
        "dissolve": "urp_dissolve",
    }

    # Default parameter values per effect type
    EFFECT_DEFAULTS = {
        "bloom_emission": {
            "EMISSION_COLOR": "0.2, 0.8, 1.0, 1.0",
            "EMISSION_INTENSITY": "2.0",
            "PULSE_SPEED": "2.0",
            "BLOOM_THRESHOLD": "0.8",
        },
        "dissolve": {
            "EDGE_COLOR": "1.0, 0.5, 0.0, 1.0",
            "EDGE_WIDTH": "0.05",
        },
    }

    def __init__(self, output_dir=None):
        if output_dir:
            self.OUTPUT_DIR = Path(output_dir)
        self.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    def generate(self, shader_spec) -> dict:
        """Generate a shader from spec.

        Returns: {success, file_path, mode, cost}
        """
        effect = shader_spec.effect_type or "custom"
        template_key = self.EFFECT_TO_TEMPLATE.get(effect)

        if template_key:
            try:
                content = self._generate_from_template(shader_spec, template_key)
                path = self._save_shader(content, shader_spec.name)
                logger.info("Shader generated (template): %s", shader_spec.name)
                return {"success": True, "file_path": path, "mode": "template", "cost": 0.0}
            except Exception as e:
                logger.error("Template shader failed for %s: %s", shader_spec.name, e)
                return {"success": False, "error": str(e), "mode": "template", "cost": 0.0}
        else:
            # Custom: generate a simple unlit shader with description as comment
            try:
                content = self._generate_custom_fallback(shader_spec)
                path = self._save_shader(content, shader_spec.name)
                logger.info("Shader generated (custom fallback): %s", shader_spec.name)
                return {"success": True, "file_path": path, "mode": "custom_fallback", "cost": 0.0}
            except Exception as e:
                logger.error("Custom shader failed for %s: %s", shader_spec.name, e)
                return {"success": False, "error": str(e), "mode": "custom_fallback", "cost": 0.0}

    def _generate_from_template(self, spec, template_key: str) -> str:
        """Load template .shader file, replace placeholders."""
        template_path = self.TEMPLATE_DIR / f"{template_key}.shader"
        if not template_path.exists():
            raise FileNotFoundError(f"Shader template not found: {template_path}")

        content = template_path.read_text(encoding="utf-8")

        # Replace shader name
        safe_name = re.sub(r"[^a-zA-Z0-9_]", "_", spec.name)
        content = content.replace("{SHADER_NAME}", safe_name)

        # Replace effect-specific parameters
        params = spec.parameters or {}
        defaults = self.EFFECT_DEFAULTS.get(spec.effect_type, {})

        for placeholder, default_val in defaults.items():
            # Try to get from spec params (various key formats)
            param_key_lower = placeholder.lower()
            value = None
            for k, v in params.items():
                if k.lower().replace("-", "_") == param_key_lower:
                    value = str(v)
                    break
            if value is None:
                value = default_val
            content = content.replace(f"{{{placeholder}}}", value)

        return content

    def _generate_custom_fallback(self, spec) -> str:
        """Generate a basic unlit shader for unknown effect types."""
        template_path = self.TEMPLATE_DIR / "urp_unlit_color.shader"
        content = template_path.read_text(encoding="utf-8")

        safe_name = re.sub(r"[^a-zA-Z0-9_]", "_", spec.name)
        content = content.replace("{SHADER_NAME}", safe_name)

        # Add description as comment at the top
        desc = spec.description or spec.effect_type or "Custom shader"
        comment = f"// Custom Effect: {desc}\n// TODO: Implement {spec.effect_type} effect\n\n"
        content = comment + content

        return content

    def _save_shader(self, content, shader_name) -> str:
        """Save shader to .shader file."""
        safe_name = re.sub(r"[^a-zA-Z0-9_]", "_", shader_name)
        path = self.OUTPUT_DIR / f"{safe_name}.shader"
        path.write_text(content, encoding="utf-8")
        return str(path)

    def generate_batch(self, specs: list) -> list:
        """Generate all shaders from specs."""
        results = []
        for spec in specs:
            try:
                results.append(self.generate(spec))
            except Exception as e:
                logger.error("Shader batch failed for %s: %s", spec.name, e)
                results.append({"success": False, "error": str(e), "name": spec.name})
        return results
