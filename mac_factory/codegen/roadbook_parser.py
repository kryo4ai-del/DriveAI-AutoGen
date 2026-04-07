"""
DriveAI Mac Factory — Roadbook Parser

Reads a CD Roadbook (JSON or text) and extracts an AppSpec.
"""

import json
from pathlib import Path
from dataclasses import dataclass, field


@dataclass
class DataModel:
    name: str = ""
    properties: list = field(default_factory=list)
    conforms_to: list = field(default_factory=list)
    description: str = ""


@dataclass
class Screen:
    name: str = ""
    view_name: str = ""
    viewmodel_name: str = ""
    description: str = ""
    components: list = field(default_factory=list)
    navigation_to: list = field(default_factory=list)
    data_models: list = field(default_factory=list)


@dataclass
class Feature:
    name: str = ""
    description: str = ""
    screens: list = field(default_factory=list)
    models: list = field(default_factory=list)
    priority: str = "medium"


@dataclass
class AppSpec:
    app_name: str = ""
    bundle_id: str = ""
    description: str = ""
    features: list = field(default_factory=list)
    screens: list = field(default_factory=list)
    models: list = field(default_factory=list)
    api_base_url: str = ""
    design_tokens: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "app_name": self.app_name,
            "bundle_id": self.bundle_id,
            "features": len(self.features),
            "screens": len(self.screens),
            "models": len(self.models)
        }


class RoadbookParser:
    def parse(self, roadbook_path: str) -> AppSpec:
        path = Path(roadbook_path)
        if not path.exists():
            print(f"[CodeGen] Roadbook not found: {roadbook_path}")
            return AppSpec()

        content = path.read_text(errors='ignore')
        if path.suffix == '.json':
            return self._parse_json(content)
        return self._parse_text(content)

    def parse_text(self, content: str) -> AppSpec:
        try:
            json.loads(content)
            return self._parse_json(content)
        except json.JSONDecodeError:
            return self._parse_text(content)

    def _parse_json(self, content: str) -> AppSpec:
        try:
            data = json.loads(content)
        except json.JSONDecodeError:
            return AppSpec()

        spec = AppSpec(
            app_name=data.get("app_name", ""),
            bundle_id=data.get("bundle_id", ""),
            description=data.get("description", "")
        )

        for f in data.get("features", []):
            spec.features.append(Feature(
                name=f.get("name", ""),
                description=f.get("description", ""),
                screens=f.get("screens", []),
                models=f.get("models", []),
                priority=f.get("priority", "medium")
            ))

        for s in data.get("screens", []):
            spec.screens.append(Screen(
                name=s.get("name", ""),
                view_name=s.get("view_name", ""),
                viewmodel_name=s.get("viewmodel_name", ""),
                description=s.get("description", ""),
                components=s.get("components", []),
                navigation_to=s.get("navigation_to", []),
                data_models=s.get("data_models", [])
            ))

        for m in data.get("models", []):
            spec.models.append(DataModel(
                name=m.get("name", ""),
                properties=m.get("properties", []),
                conforms_to=m.get("conforms_to", ["Codable", "Identifiable"]),
                description=m.get("description", "")
            ))

        print(f"[CodeGen] Parsed: {spec.app_name} - {len(spec.features)} features, "
              f"{len(spec.screens)} screens, {len(spec.models)} models")
        return spec

    def _parse_text(self, content: str) -> AppSpec:
        spec = AppSpec()
        lines = content.split('\n')

        for line in lines[:20]:
            line = line.strip()
            if line.startswith('# ') and not line.startswith('## '):
                spec.app_name = line[2:].strip()
                break
            if 'app name' in line.lower() or 'app_name' in line.lower():
                parts = line.split(':', 1)
                if len(parts) > 1:
                    spec.app_name = parts[1].strip().strip('"').strip("'")
                    break

        if not spec.app_name:
            spec.app_name = "GeneratedApp"

        spec.bundle_id = f"com.dai-core.{spec.app_name.lower().replace(' ', '')}"

        current_section = ""
        for line in lines:
            stripped = line.strip()
            if stripped.startswith('## '):
                section_name = stripped[3:].lower()
                if 'feature' in section_name:
                    current_section = "features"
                elif 'screen' in section_name:
                    current_section = "screens"
                elif 'model' in section_name or 'data' in section_name:
                    current_section = "models"
                else:
                    current_section = ""
            elif stripped.startswith('- ') or stripped.startswith('* '):
                item_name = stripped[2:].strip().split(':')[0].split('(')[0].strip()
                if current_section == "features" and item_name:
                    spec.features.append(Feature(name=item_name))
                elif current_section == "screens" and item_name:
                    clean = item_name.replace(' ', '')
                    spec.screens.append(Screen(
                        name=item_name,
                        view_name=f"{clean}View",
                        viewmodel_name=f"{clean}ViewModel"
                    ))
                elif current_section == "models" and item_name:
                    spec.models.append(DataModel(name=item_name.replace(' ', '')))

        print(f"[CodeGen] Parsed (text): {spec.app_name} - {len(spec.features)} features, "
              f"{len(spec.screens)} screens, {len(spec.models)} models")
        return spec
