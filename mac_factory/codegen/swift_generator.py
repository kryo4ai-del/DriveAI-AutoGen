"""
DriveAI Mac Factory — Swift Code Generator

Generates Swift source files from an AppSpec. LLM + deterministic.
"""

import os
import re
import time
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class GenerationResult:
    total_files: int = 0
    successful: int = 0
    stubbed: int = 0
    failed: int = 0
    total_cost: float = 0.0
    duration_seconds: float = 0.0
    files: list = field(default_factory=list)


class SwiftGenerator:
    SWIFT_STARTERS = (
        'import ', '//', '/*', '@', 'struct ', 'class ', 'enum ',
        'protocol ', 'extension ', 'public ', 'private ', 'internal ',
        'final ', 'open ', '#if', 'func ', 'let ', 'var ', 'actor '
    )

    def __init__(self, project_dir: str, safety_guard=None):
        self.project_dir = project_dir
        self.safety_guard = safety_guard
        self.generated_files = []

    def generate(self, spec) -> GenerationResult:
        start = time.time()
        result = GenerationResult()

        print(f"[CodeGen] Generating {spec.app_name}...")

        models_dir = os.path.join(self.project_dir, "Models")
        views_dir = os.path.join(self.project_dir, "Views")
        viewmodels_dir = os.path.join(self.project_dir, "ViewModels")
        services_dir = os.path.join(self.project_dir, "Services")
        for d in (models_dir, views_dir, viewmodels_dir, services_dir):
            os.makedirs(d, exist_ok=True)

        # 1. App entry
        self._generate_app_entry(spec)
        result.total_files += 1
        result.successful += 1

        # 2. Models
        for model in spec.models:
            status, cost = self._generate_model(model, models_dir)
            self._tally(result, status, cost, f"{model.name}.swift")

        # 3. ViewModels
        for screen in spec.screens:
            if screen.viewmodel_name:
                status, cost = self._generate_viewmodel(screen, viewmodels_dir)
                self._tally(result, status, cost, f"{screen.viewmodel_name}.swift")

        # 4. Views
        for screen in spec.screens:
            if screen.view_name:
                status, cost = self._generate_view(screen, views_dir)
                self._tally(result, status, cost, f"{screen.view_name}.swift")

        # 5. ContentView
        self._generate_content_view(spec, views_dir)
        result.total_files += 1
        result.successful += 1

        result.duration_seconds = time.time() - start

        print(f"[CodeGen] Done: {result.total_files} files "
              f"({result.successful} OK, {result.stubbed} stubbed, {result.failed} failed)")
        print(f"[CodeGen] Cost: ${result.total_cost:.2f}, Time: {result.duration_seconds:.0f}s")

        return result

    def _tally(self, result, status, cost, name):
        result.total_files += 1
        result.total_cost += cost
        if status == "success":
            result.successful += 1
        elif status == "stubbed":
            result.stubbed += 1
        else:
            result.failed += 1
        result.files.append({"name": name, "status": status, "cost": cost})

    def _generate_app_entry(self, spec):
        app_name = spec.app_name.replace(" ", "").replace("-", "")
        if not app_name:
            app_name = "App"
        filename = f"{app_name}App.swift"
        filepath = os.path.join(self.project_dir, filename)

        content = (
            "import SwiftUI\n\n"
            f"@main\nstruct {app_name}App: App {{\n"
            "    var body: some Scene {\n"
            "        WindowGroup {\n"
            "            ContentView()\n"
            "        }\n"
            "    }\n"
            "}\n"
        )
        Path(filepath).write_text(content)
        print(f"[CodeGen] Generated: {filename} (deterministic)")

    def _generate_model(self, model, output_dir: str) -> tuple:
        filename = f"{model.name}.swift"
        filepath = os.path.join(output_dir, filename)

        if model.properties:
            content = self._model_from_properties(model)
            Path(filepath).write_text(content)
            print(f"[CodeGen] Generated: {filename} (deterministic, {len(model.properties)} props)")
            return ("success", 0.0)

        return self._generate_with_llm(
            filepath, filename,
            f"Generate a Swift struct called '{model.name}' that conforms to "
            f"{', '.join(model.conforms_to or ['Codable', 'Identifiable'])}. "
            f"Description: {model.description or 'A data model for ' + model.name}. "
            f"Include reasonable properties with proper types. "
            f"Include import Foundation at the top."
        )

    def _generate_viewmodel(self, screen, output_dir: str) -> tuple:
        filename = f"{screen.viewmodel_name}.swift"
        filepath = os.path.join(output_dir, filename)
        models_used = ", ".join(screen.data_models) if screen.data_models else "appropriate data"

        return self._generate_with_llm(
            filepath, filename,
            f"Generate a Swift ViewModel class called '{screen.viewmodel_name}' "
            f"that conforms to ObservableObject. "
            f"It manages data for: {screen.description or screen.name}. "
            f"It uses these models: {models_used}. "
            f"Include @Published properties and basic CRUD methods. "
            f"Use UserDefaults or in-memory storage (NO third-party dependencies). "
            f"Include import Foundation and import Combine at the top."
        )

    def _generate_view(self, screen, output_dir: str) -> tuple:
        filename = f"{screen.view_name}.swift"
        filepath = os.path.join(output_dir, filename)
        components = ", ".join(screen.components) if screen.components else "list and detail"
        nav_targets = ", ".join(screen.navigation_to) if screen.navigation_to else "none"

        return self._generate_with_llm(
            filepath, filename,
            f"Generate a SwiftUI View struct called '{screen.view_name}'. "
            f"Description: {screen.description or screen.name}. "
            f"Components: {components}. "
            f"It uses @StateObject var viewModel = {screen.viewmodel_name}(). "
            f"Navigation to: {nav_targets}. "
            f"Keep it simple and functional. NO third-party dependencies. "
            f"Include import SwiftUI at the top."
        )

    def _generate_content_view(self, spec, views_dir: str):
        filepath = os.path.join(views_dir, "ContentView.swift")

        tabs = []
        icons = ["house", "list.bullet", "gear", "person", "star"]
        for i, screen in enumerate(spec.screens[:5]):
            view_name = screen.view_name or f"{screen.name.replace(' ', '')}View"
            tab_label = screen.name.replace("Screen", "").replace("View", "").strip()
            icon = icons[i % len(icons)]
            tabs.append(
                f'            {view_name}()\n'
                f'                .tabItem {{ Label("{tab_label}", systemImage: "{icon}") }}'
            )

        if not tabs:
            tabs = [f'            Text("Welcome to {spec.app_name}")']

        tab_content = "\n".join(tabs)

        content = (
            "import SwiftUI\n\n"
            "struct ContentView: View {\n"
            "    var body: some View {\n"
            "        TabView {\n"
            f"{tab_content}\n"
            "        }\n"
            "    }\n"
            "}\n"
        )
        Path(filepath).write_text(content)
        print(f"[CodeGen] Generated: ContentView.swift (deterministic, {len(tabs)} tabs)")

    def _generate_with_llm(self, filepath: str, filename: str, prompt: str) -> tuple:
        if self.safety_guard and not self.safety_guard.check():
            self._write_stub(filepath, filename)
            return ("stubbed", 0.0)

        full_prompt = (
            f"{prompt}\n\n"
            "RULES:\n"
            "- Output ONLY valid Swift code\n"
            "- No markdown code fences (```)\n"
            "- No explanations or comments about what you did\n"
            "- No third-party dependencies (no Firebase, Alamofire, etc.)\n"
            "- Use only Foundation, SwiftUI, Combine, UIKit, CoreLocation, MapKit, AVFoundation\n"
            "- Every file must start with an import statement\n"
            "- Keep it simple and compilable"
        )

        try:
            import litellm
            response = litellm.completion(
                model="claude-sonnet-4-6",
                messages=[{"role": "user", "content": full_prompt}],
                max_tokens=4000,
                temperature=0.2
            )

            cost = litellm.completion_cost(response) or 0.0
            if self.safety_guard:
                self.safety_guard.record_llm_call(
                    "claude-sonnet-4-6",
                    response.usage.prompt_tokens,
                    response.usage.completion_tokens,
                    cost
                )

            content = self._sanitize(response.choices[0].message.content)
            if not content:
                print(f"[CodeGen] LLM output empty after sanitize: {filename} -> stubbing")
                self._write_stub(filepath, filename)
                return ("stubbed", cost)

            Path(filepath).write_text(content)
            print(f"[CodeGen] Generated: {filename} (LLM, ${cost:.4f})")
            return ("success", cost)
        except Exception as e:
            print(f"[CodeGen] LLM error for {filename}: {e} -> stubbing")
            self._write_stub(filepath, filename)
            return ("stubbed", 0.0)

    def _model_from_properties(self, model) -> str:
        conforms = ", ".join(model.conforms_to or ["Codable", "Identifiable"])

        props = []
        has_id = False
        for p in model.properties:
            pname = p.get("name", "value")
            ptype = p.get("type", "String")
            optional = p.get("optional", False)

            if pname == "id":
                has_id = True
                if ptype == "UUID":
                    props.append(f"    var id: {ptype} = UUID()")
                else:
                    props.append(f"    var id: {ptype} = {self._swift_default(ptype)}")
            elif optional:
                props.append(f"    var {pname}: {ptype}?")
            else:
                default = self._swift_default(ptype)
                props.append(f"    var {pname}: {ptype} = {default}")

        if not has_id and "Identifiable" in conforms:
            props.insert(0, "    var id: UUID = UUID()")

        props_str = "\n".join(props)
        return f"import Foundation\n\nstruct {model.name}: {conforms} {{\n{props_str}\n}}\n"

    def _swift_default(self, swift_type: str) -> str:
        defaults = {
            "String": '""',
            "Int": "0",
            "Double": "0.0",
            "Float": "0.0",
            "Bool": "false",
            "Date": "Date()",
            "UUID": "UUID()",
            "URL": 'URL(string: "https://example.com")!',
            "Data": "Data()",
            "[String]": "[]",
            "[Int]": "[]",
        }
        return defaults.get(swift_type, '""')

    def _sanitize(self, output: str) -> Optional[str]:
        if not output:
            return None
        content = output.strip()
        content = re.sub(r'```swift\s*\n?', '', content)
        content = re.sub(r'```\s*\n?', '', content)

        lines = content.split('\n')
        start_idx = 0
        for i, line in enumerate(lines):
            if line.strip() and any(line.strip().startswith(s) for s in self.SWIFT_STARTERS):
                start_idx = i
                break

        result = '\n'.join(lines[start_idx:]).strip()
        return (result + '\n') if result and len(result) > 10 else None

    def _write_stub(self, filepath: str, filename: str):
        type_name = Path(filename).stem

        if "View" in type_name and "Model" not in type_name:
            content = (
                "import SwiftUI\n\n"
                f"struct {type_name}: View {{\n"
                "    var body: some View {\n"
                f'        Text("{type_name}")\n'
                "    }\n"
                "}\n"
            )
        elif "ViewModel" in type_name:
            content = (
                "import Foundation\nimport Combine\n\n"
                f"class {type_name}: ObservableObject {{\n    init() {{}}\n}}\n"
            )
        else:
            content = (
                "import Foundation\n\n"
                f"struct {type_name}: Codable, Identifiable {{\n    var id = UUID()\n}}\n"
            )

        Path(filepath).write_text(content)
        print(f"[CodeGen] Stubbed: {filename}")
