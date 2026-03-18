# factory/orchestrator/build_layers.py
# Layer definitions for the 5-layer build order.

from dataclasses import dataclass, field
from enum import Enum
from typing import Optional


class BuildLayer(Enum):
    FOUNDATION = 1    # Core Types, Protocols, Interfaces, Base Models
    DOMAIN = 2        # Business Logic, Services, Use Cases, Repositories
    APPLICATION = 3   # ViewModels, Coordinators, State Management, Navigation
    PRESENTATION = 4  # Views, UI Components, Design System, Layouts
    POLISH = 5        # Animations, Performance, Accessibility, Final UX


@dataclass
class LayerSpec:
    """Specification for what to build in a single layer."""
    layer: BuildLayer
    feature_name: str
    platform: str              # ios, android, web
    language: str              # swift, kotlin, typescript
    framework: str             # swiftui, jetpack_compose, nextjs
    description: str           # what this layer should produce
    task_prompt: str           # the actual prompt for the pipeline
    depends_on_layers: list[BuildLayer] = field(default_factory=list)
    validation_criteria: list[str] = field(default_factory=list)
    status: str = "pending"    # pending, completed, failed, skipped


# Human-readable layer names
LAYER_NAMES = {
    BuildLayer.FOUNDATION: "Foundation",
    BuildLayer.DOMAIN: "Domain",
    BuildLayer.APPLICATION: "Application",
    BuildLayer.PRESENTATION: "Presentation",
    BuildLayer.POLISH: "Polish",
}
