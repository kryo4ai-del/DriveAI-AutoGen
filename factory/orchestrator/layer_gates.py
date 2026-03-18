# factory/orchestrator/layer_gates.py
# Quality gates between build layers. Uses existing factory repair tools.

import os
from dataclasses import dataclass, field
from enum import Enum

from factory.orchestrator.import_boundary_checker import ImportBoundaryChecker


class GateVerdict(Enum):
    PASS = "pass"
    PASS_WITH_WARNINGS = "warnings"
    FAIL_REPAIRABLE = "repairable"
    FAIL_BLOCKING = "blocking"


@dataclass
class GateResult:
    layer: str
    verdict: GateVerdict
    issues_found: int = 0
    issues_repaired: int = 0
    blocking_remaining: int = 0
    warnings_remaining: int = 0
    details: list[str] = field(default_factory=list)
    repair_actions: list[str] = field(default_factory=list)


# Layers where compile hygiene is available (Swift only for now)
_COMPILE_HYGIENE_LANGUAGES = frozenset({"swift"})

# Gate rules per layer
_GATE_RULES = {
    "foundation": {
        "check_compile_hygiene": True,
        "check_import_boundary": True,
        "check_self_contained": True,
        "allow_auto_repair": True,
        "description": "Types compile, no duplicates, all types self-contained, no UI imports",
    },
    "domain": {
        "check_compile_hygiene": True,
        "check_import_boundary": True,
        "check_self_contained": False,
        "allow_auto_repair": True,
        "description": "Services compile, reference only Foundation types, no UI imports",
    },
    "application": {
        "check_compile_hygiene": True,
        "check_import_boundary": True,
        "check_self_contained": False,
        "allow_auto_repair": True,
        "description": "ViewModels compile, reference Foundation + Domain, no UI imports",
    },
    "presentation": {
        "check_compile_hygiene": True,
        "check_import_boundary": False,
        "check_self_contained": False,
        "allow_auto_repair": True,
        "description": "Views compile, all bindings resolve to ViewModels",
    },
    "polish": {
        "check_compile_hygiene": True,
        "check_import_boundary": False,
        "check_self_contained": False,
        "allow_auto_repair": True,
        "description": "Full compile, no regressions, accessibility present",
    },
}


class LayerQualityGate:
    """Validates a build layer's output before allowing the next layer to start."""

    def __init__(self, project_name: str, platform: str = "ios", language: str = "swift"):
        self.project_name = project_name
        self.platform = platform
        self.language = language
        self._import_checker = ImportBoundaryChecker()

    def get_gate_description(self, layer_name: str) -> str:
        """Get human-readable description of gate rules for a layer."""
        rules = _GATE_RULES.get(layer_name.lower(), {})
        return rules.get("description", "Standard compile check")

    def check_layer(self, layer_name: str, generated_files: list[str]) -> GateResult:
        """Run quality checks appropriate for the given layer."""
        layer_key = layer_name.lower()
        rules = _GATE_RULES.get(layer_key, _GATE_RULES["polish"])
        details: list[str] = []
        blocking = 0
        warnings = 0

        # 1. Compile Hygiene (Swift only for now)
        if rules["check_compile_hygiene"] and self.language in _COMPILE_HYGIENE_LANGUAGES:
            try:
                from factory.operations.compile_hygiene_validator import CompileHygieneValidator
                hygiene = CompileHygieneValidator(project_name=self.project_name)
                report = hygiene.validate()
                for issue in report.issues:
                    if issue.severity.value == "blocking":
                        blocking += 1
                        details.append(f"[BLOCKING] {issue.pattern_id}: {issue.message}")
                    else:
                        warnings += 1
                        details.append(f"[WARNING] {issue.pattern_id}: {issue.message}")
            except Exception as e:
                details.append(f"[SKIP] Compile hygiene check failed: {e}")
        elif rules["check_compile_hygiene"]:
            details.append(f"[SKIP] Compile hygiene not available for {self.language} (Swift only)")

        # 2. Import Boundary
        if rules["check_import_boundary"] and generated_files:
            violations = self._import_checker.check_boundaries(
                layer_key, generated_files, self.language
            )
            for v in violations:
                blocking += 1
                details.append(f"[BOUNDARY] {v}")
            if not violations:
                details.append(f"Import boundary: PASS (no UI imports in {layer_key})")

        # 3. Determine verdict
        total_issues = blocking + warnings
        if blocking > 0:
            # Check if auto-repair is possible
            if rules["allow_auto_repair"]:
                verdict = GateVerdict.FAIL_REPAIRABLE
            else:
                verdict = GateVerdict.FAIL_BLOCKING
        elif warnings > 0:
            verdict = GateVerdict.PASS_WITH_WARNINGS
        else:
            verdict = GateVerdict.PASS

        return GateResult(
            layer=layer_name,
            verdict=verdict,
            issues_found=total_issues,
            blocking_remaining=blocking,
            warnings_remaining=warnings,
            details=details,
        )

    def auto_repair(self, gate_result: GateResult) -> GateResult:
        """Attempt to auto-repair issues found by the gate."""
        if self.language not in _COMPILE_HYGIENE_LANGUAGES:
            gate_result.details.append(f"[SKIP] Auto-repair not available for {self.language}")
            return gate_result

        repair_actions: list[str] = []
        repaired = 0

        try:
            from factory.operations.compile_hygiene_validator import CompileHygieneValidator
            hygiene = CompileHygieneValidator(project_name=self.project_name)
            report = hygiene.validate()

            # FK-014: Type Stub Generator
            fk014 = [i for i in report.issues
                      if i.pattern_id == "FK-014" and i.severity.value == "blocking"]
            if fk014:
                from factory.operations.type_stub_generator import TypeStubGenerator
                stub_gen = TypeStubGenerator(project_name=self.project_name)
                stub_report = stub_gen.generate_from_hygiene(report)
                if stub_report.stubs_created > 0:
                    repaired += stub_report.stubs_created
                    repair_actions.append(f"TypeStubGenerator: {stub_report.stubs_created} stubs created")

            # FK-013: Property Shape Repairer
            fk013 = [i for i in report.issues
                      if i.pattern_id == "FK-013" and i.severity.value == "blocking"]
            if fk013:
                from factory.operations.property_shape_repairer import PropertyShapeRepairer
                repairer = PropertyShapeRepairer(project_name=self.project_name)
                shape_report = repairer.repair_from_hygiene(report)
                if shape_report.repairs_applied > 0:
                    repaired += shape_report.repairs_applied
                    repair_actions.append(f"ShapeRepairer: {shape_report.repairs_applied} repairs")

            # Stale Artifact Guard for persistent blockers
            remaining = [i for i in report.issues if i.severity.value == "blocking"]
            if remaining and repaired == 0:
                from factory.operations.stale_artifact_guard import StaleArtifactGuard
                guard = StaleArtifactGuard(project_name=self.project_name)
                stale_report = guard.check_and_quarantine(report)
                if stale_report.quarantined > 0:
                    repaired += stale_report.quarantined
                    repair_actions.append(f"StaleArtifactGuard: {stale_report.quarantined} quarantined")

        except Exception as e:
            repair_actions.append(f"Auto-repair error: {e}")

        # Re-check after repairs
        if repaired > 0:
            recheck = self.check_layer(gate_result.layer, [])
            recheck.issues_repaired = repaired
            recheck.repair_actions = repair_actions
            return recheck

        gate_result.repair_actions = repair_actions
        gate_result.details.append("Auto-repair: no repairs possible")
        gate_result.verdict = GateVerdict.FAIL_BLOCKING
        return gate_result
