# factory/orchestrator/layer_decomposer.py
# Decomposes a feature into 5 layered build steps. Deterministic — no LLM calls.

from factory.orchestrator.build_layers import BuildLayer, LayerSpec, LAYER_NAMES


# Platform-specific terminology
_PLATFORM_TERMS = {
    "ios": {
        "model": "structs",
        "protocol": "protocols",
        "enum": "enums",
        "service_pattern": "classes conforming to protocols, async/await",
        "viewmodel_pattern": "@Observable ViewModels, NavigationStack",
        "view_pattern": "SwiftUI Views, .modifier chains",
        "polish_pattern": ".animation(), .accessibilityLabel()",
        "test_pattern": "XCTest, XCUITest",
    },
    "android": {
        "model": "data classes",
        "protocol": "interfaces",
        "enum": "sealed classes and enums",
        "service_pattern": "classes with @Inject, suspend functions, Flows",
        "viewmodel_pattern": "@HiltViewModel ViewModels, StateFlow, Navigation",
        "view_pattern": "@Composable functions, Material3 components",
        "polish_pattern": "animateContentSize(), Modifier.semantics()",
        "test_pattern": "JUnit 5, ComposeTestRule, Mockk",
    },
    "web": {
        "model": "interfaces and types",
        "protocol": "type definitions",
        "enum": "enums and union types",
        "service_pattern": "service functions, API client, data transformers",
        "viewmodel_pattern": "custom hooks (useState, useReducer), context providers",
        "view_pattern": "React components (.tsx), Tailwind CSS classes",
        "polish_pattern": "framer-motion animations, aria-* attributes",
        "test_pattern": "Jest, React Testing Library, MSW",
    },
}


class LayerDecomposer:
    """Decomposes a feature into 5 layered build steps."""

    def decompose(self,
                  feature_name: str,
                  feature_description: str,
                  platform: str = "ios",
                  language: str = "swift",
                  framework: str = "swiftui") -> list[LayerSpec]:
        """Break a feature into 5 layered build specs."""
        terms = _PLATFORM_TERMS.get(platform, _PLATFORM_TERMS["ios"])

        specs = [
            self._foundation(feature_name, feature_description, platform, language, framework, terms),
            self._domain(feature_name, feature_description, platform, language, framework, terms),
            self._application(feature_name, feature_description, platform, language, framework, terms),
            self._presentation(feature_name, feature_description, platform, language, framework, terms),
            self._polish(feature_name, feature_description, platform, language, framework, terms),
        ]
        return specs

    def _foundation(self, name, desc, platform, language, framework, terms) -> LayerSpec:
        prompt = (
            f"[LAYER: Foundation — {name}]\n"
            f"Feature: {desc}\n\n"
            f"Generate ONLY the foundational types for {name}:\n"
            f"- Data models ({terms['model']} that hold data)\n"
            f"- {terms['protocol'].capitalize()} that define contracts\n"
            f"- {terms['enum'].capitalize()} for states and categories\n"
            f"- Type aliases and constants\n"
            f"- Error types\n\n"
            f"Do NOT generate any UI, ViewModels, Services, or business logic.\n"
            f"Do NOT reference any types that you don't define in this layer.\n"
            f"Every type must be self-contained and compilable on its own.\n\n"
            f"Platform: {platform} / {language} / {framework}"
        )
        return LayerSpec(
            layer=BuildLayer.FOUNDATION,
            feature_name=name,
            platform=platform,
            language=language,
            framework=framework,
            description=f"Core types, {terms['protocol']}, {terms['enum']} for {name}",
            task_prompt=prompt,
            depends_on_layers=[],
            validation_criteria=["All types compile independently", "No UI imports", "No service logic"],
        )

    def _domain(self, name, desc, platform, language, framework, terms) -> LayerSpec:
        prompt = (
            f"[LAYER: Domain — {name}]\n"
            f"Feature: {desc}\n\n"
            f"{{LAYER_CONTEXT}}\n\n"
            f"Generate ONLY the business logic and services for {name}:\n"
            f"- Service classes that implement business rules ({terms['service_pattern']})\n"
            f"- Repository {terms['protocol']} and implementations\n"
            f"- Use case classes\n"
            f"- Data transformation logic\n\n"
            f"You MAY reference Foundation types listed in the CONTEXT above.\n"
            f"Do NOT generate any UI, ViewModels, or Views.\n"
            f"Do NOT redefine types that already exist in the Foundation layer.\n\n"
            f"Platform: {platform} / {language} / {framework}"
        )
        return LayerSpec(
            layer=BuildLayer.DOMAIN,
            feature_name=name,
            platform=platform,
            language=language,
            framework=framework,
            description=f"Services, repositories, business logic for {name}",
            task_prompt=prompt,
            depends_on_layers=[BuildLayer.FOUNDATION],
            validation_criteria=["References only Foundation types", "No UI imports", "Services compile"],
        )

    def _application(self, name, desc, platform, language, framework, terms) -> LayerSpec:
        prompt = (
            f"[LAYER: Application — {name}]\n"
            f"Feature: {desc}\n\n"
            f"{{LAYER_CONTEXT}}\n\n"
            f"Generate ONLY the application logic for {name}:\n"
            f"- {terms['viewmodel_pattern']}\n"
            f"- Navigation coordination\n"
            f"- State management\n"
            f"- Data binding between Domain and Presentation\n\n"
            f"You MAY reference Foundation types and Domain services.\n"
            f"Do NOT generate any Views or UI components.\n\n"
            f"Platform: {platform} / {language} / {framework}"
        )
        return LayerSpec(
            layer=BuildLayer.APPLICATION,
            feature_name=name,
            platform=platform,
            language=language,
            framework=framework,
            description=f"ViewModels, state management, navigation for {name}",
            task_prompt=prompt,
            depends_on_layers=[BuildLayer.FOUNDATION, BuildLayer.DOMAIN],
            validation_criteria=["References Foundation + Domain types", "No View code", "State management compiles"],
        )

    def _presentation(self, name, desc, platform, language, framework, terms) -> LayerSpec:
        prompt = (
            f"[LAYER: Presentation — {name}]\n"
            f"Feature: {desc}\n\n"
            f"{{LAYER_CONTEXT}}\n\n"
            f"Generate ONLY the UI for {name}:\n"
            f"- {terms['view_pattern']}\n"
            f"- Design system tokens usage\n"
            f"- Layout and styling\n"
            f"- User interaction handling\n\n"
            f"You MAY reference all previous layers.\n"
            f"Bind to the ViewModels from the Application layer.\n\n"
            f"Platform: {platform} / {language} / {framework}"
        )
        return LayerSpec(
            layer=BuildLayer.PRESENTATION,
            feature_name=name,
            platform=platform,
            language=language,
            framework=framework,
            description=f"Views, UI components, layouts for {name}",
            task_prompt=prompt,
            depends_on_layers=[BuildLayer.FOUNDATION, BuildLayer.DOMAIN, BuildLayer.APPLICATION],
            validation_criteria=["Binds to Application ViewModels", "Uses Design System", "UI renders"],
        )

    def _polish(self, name, desc, platform, language, framework, terms) -> LayerSpec:
        prompt = (
            f"[LAYER: Polish — {name}]\n"
            f"Feature: {desc}\n\n"
            f"{{LAYER_CONTEXT}}\n\n"
            f"Review and enhance {name}:\n"
            f"- Add animations and transitions ({terms['polish_pattern']})\n"
            f"- Optimize performance\n"
            f"- Add accessibility support\n"
            f"- Improve UX micro-interactions\n"
            f"- Add error states and loading states\n\n"
            f"You MAY reference and modify all previous layers.\n\n"
            f"Platform: {platform} / {language} / {framework}"
        )
        return LayerSpec(
            layer=BuildLayer.POLISH,
            feature_name=name,
            platform=platform,
            language=language,
            framework=framework,
            description=f"Animations, accessibility, performance polish for {name}",
            task_prompt=prompt,
            depends_on_layers=[BuildLayer.FOUNDATION, BuildLayer.DOMAIN, BuildLayer.APPLICATION, BuildLayer.PRESENTATION],
            validation_criteria=["Accessibility attributes present", "Animations smooth", "Error states handled"],
        )
