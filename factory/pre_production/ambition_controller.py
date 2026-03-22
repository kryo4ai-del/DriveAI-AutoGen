"""Ambition Controller — constrains roadbooks to factory capabilities."""
from factory.capability_registry import CapabilityRegistry


class AmbitionController:
    """Controls ambition level: realistic vs visionary."""

    def __init__(self, ambition: str = "realistic"):
        self.ambition = ambition
        self.registry = CapabilityRegistry()

    def get_system_prompt_modifier(self) -> str:
        if self.ambition == "visionary":
            return (
                "\n[AMBITION MODE: VISIONARY]\n"
                "Plan the ideal product without constraints. Include features that may "
                "require capabilities the factory doesn't have yet. Mark such features with [FUTURE].\n"
            )

        c = self.registry.get_realistic_constraints()
        platforms = ", ".join(k for k, v in c["platforms"].items() if v)
        storage = ", ".join(c["backend"]["allowed_storage"])
        design = ", ".join(c["design"]["allowed_design"])
        forbidden = ", ".join(c["features"]["no_features_requiring"])

        return (
            "\n[AMBITION MODE: REALISTIC]\n"
            "Constrain ALL plans to what the DriveAI Factory can build TODAY.\n"
            "The factory will autonomously build this — no human developer.\n\n"
            f"PLATFORMS: {platforms}\n\n"
            "DESIGN CONSTRAINTS (STRICT):\n"
            "- NO custom graphics, illustrations, or artwork\n"
            "- NO custom app icons (placeholder used)\n"
            "- NO custom sound or music\n"
            f"- Use ONLY: {design}\n\n"
            "BACKEND CONSTRAINTS (STRICT):\n"
            "- NO server-side API or backend\n"
            "- ALL data local-only\n"
            f"- Allowed storage: {storage}\n"
            "- App must work 100% offline\n\n"
            f"FEATURE CONSTRAINTS:\n"
            f"- Maximum {c['features']['max_recommended']} features\n"
            f"- Maximum {c['features']['max_screens']} screens\n"
            f"- NO features requiring: {forbidden}\n"
            "- Keep complexity simple to medium\n\n"
            f"COST: {c['timeline']['estimated_cost_per_run']} per pipeline run\n"
            f"TIMELINE: {c['timeline']['estimated_total_simple_app']} for a simple app\n\n"
            "GOAL: A real, working, store-submittable app built entirely by the factory.\n"
        )

    def validate_roadbook(self, features: list[dict]) -> list[str]:
        warnings = []
        c = self.registry.get_realistic_constraints()
        if len(features) > c["features"]["max_recommended"]:
            warnings.append(f"Too many features: {len(features)} > {c['features']['max_recommended']}")
        for f in features:
            desc = f.get("description", "").lower()
            for forbidden in c["features"]["no_features_requiring"]:
                if forbidden.replace("_", " ") in desc:
                    warnings.append(f"Feature '{f.get('name', '?')}' may require '{forbidden}'")
        return warnings
