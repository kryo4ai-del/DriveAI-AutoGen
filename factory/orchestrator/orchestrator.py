# factory/orchestrator/orchestrator.py
# The heart of the factory. Orchestrates builds across production lines.

import os
import asyncio
try:
    import nest_asyncio
    nest_asyncio.apply()
except ImportError:
    pass
from factory.pipeline.pipeline_runner import run_pipeline, run_operations_layer
import sys
from datetime import datetime

from factory.project_config import load_project_config
from factory.brain import FactoryBrain
from factory.orchestrator.build_plan import BuildPlan, BuildStep
from factory.orchestrator.spec_parser import parse_spec, parse_spec_file
from factory.orchestrator.build_layers import BuildLayer, LAYER_NAMES
from factory.orchestrator.layer_decomposer import LayerDecomposer
from factory.orchestrator.layer_context import LayerContext


class BuildReport:
    """Result of executing a build plan."""

    def __init__(self, plan: BuildPlan):
        self.plan = plan
        self.started = datetime.now().isoformat()
        self.finished = ""
        self.step_results: list[dict] = []

    def summary(self) -> str:
        completed = sum(1 for s in self.plan.steps if s.status == "completed")
        failed = sum(1 for s in self.plan.steps if s.status == "failed")
        skipped = sum(1 for s in self.plan.steps if s.status == "skipped")
        pending = sum(1 for s in self.plan.steps if s.status == "pending")
        total = len(self.plan.steps)
        return (f"BuildReport: {completed} completed, {failed} failed, "
                f"{skipped} skipped, {pending} pending / {total} total")

    def to_dict(self) -> dict:
        return {
            "plan": self.plan.to_dict(),
            "started": self.started,
            "finished": self.finished,
            "step_results": self.step_results,
        }


class FactoryOrchestrator:
    """The heart of the factory. Takes a project and orchestrates its build
    across production lines, from spec to deployable artifacts."""

    def __init__(self, project_name: str):
        self.project_name = project_name
        self.config = load_project_config(project_name)
        self.brain = FactoryBrain()
        self.build_plan: BuildPlan | None = None

    def create_build_plan(self, spec: dict | str | None = None) -> BuildPlan:
        """Create a build plan from a spec or feature list."""
        if isinstance(spec, dict):
            self.build_plan = parse_spec(spec, self.project_name)
        elif isinstance(spec, str) and os.path.isfile(spec):
            import yaml as _yaml
            with open(spec, encoding="utf-8") as f:
                spec_data = _yaml.safe_load(f) or {}
            self.build_plan = parse_spec(spec_data, self.project_name)
        else:
            self.build_plan = parse_spec_file(self.project_name)

        return self.build_plan

    def _build_command(self, step: BuildStep, profile: str = "standard",
                       approval: str = "auto") -> list[str]:
        """Build the CLI command for a build step."""
        return [
            sys.executable, "main.py",
            "--template", step.template,
            "--name", step.template_name,
            "--profile", profile,
            "--approval", approval,
            "--project", self.project_name,
        ]

    def _print_plan(self, plan: BuildPlan):
        """Print the build plan to console."""
        active_lines = self.config.get_active_lines()
        lines_by_step = {}
        for line in set(s.line for s in plan.steps):
            lines_by_step[line] = len(plan.get_steps_for_line(line))

        print("=" * 60)
        print("  Factory Orchestrator — Build Plan")
        print("=" * 60)
        print(f"  Project    : {self.config.name} ({self.project_name})")
        print(f"  Lines      : {', '.join(f'{l} (active)' for l in active_lines)}")
        print(f"  Features   : {len(plan.steps)}")
        if lines_by_step:
            parts = ", ".join(f"{count} {line}" for line, count in lines_by_step.items())
            print(f"  Build Steps: {len(plan.steps)} ({parts})")
        print()
        for i, step in enumerate(plan.steps, 1):
            deps = f" (depends: {', '.join(self._resolve_dep_names(plan, step))})" if step.depends_on else ""
            print(f"  Step {i}: [{step.line}] {step.name} ({step.template}) — {step.status.upper()}{deps}")
        print("=" * 60)

    def _resolve_dep_names(self, plan: BuildPlan, step: BuildStep) -> list[str]:
        """Resolve dependency IDs to step names."""
        id_to_name = {s.id: s.name for s in plan.steps}
        return [id_to_name.get(dep_id, dep_id) for dep_id in step.depends_on]

    def execute_plan(self, plan: BuildPlan | None = None, dry_run: bool = True,
                     profile: str = "standard", approval: str = "auto",
                     production_logger=None) -> BuildReport:
        """Execute a build plan step by step.

        Args:
            production_logger: Optional ProductionLogger instance for live dashboard updates.
        """
        if plan is None:
            plan = self.build_plan or self.create_build_plan()

        self._print_plan(plan)
        report = BuildReport(plan)
        plan.status = "in_progress"

        # Log production start
        if production_logger:
            production_logger.log_production_start(
                total_steps=len(plan.steps),
                slug=self.project_name,
            )

        print()
        if dry_run:
            print("Executing plan (dry_run=True)...")
        else:
            print("Executing plan...")
        print()

        step_num = 0
        while True:
            step = plan.get_next_step()
            if step is None:
                break

            step_num += 1
            cmd = self._build_command(step, profile=profile, approval=approval)
            cmd_str = " ".join(cmd)

            print(f"  Step {step_num}: {step.name}")
            print(f"    Line    : {step.line} ({step.language})")
            print(f"    Command : {cmd_str}")

            # Detect layer name from step name (e.g. "TrainingMode — Foundation" → "foundation")
            _layer_name = self._extract_layer_name(step.name)

            # Log step start
            if production_logger and not dry_run:
                production_logger.log_step_start(
                    phase=_layer_name or "build",
                    screen=step.id,
                    agent=f"orchestrator/{step.line}",
                    message=step.name,
                )

            if dry_run:
                print(f"    Status  : DRY RUN — would execute")
                if _layer_name:
                    from factory.orchestrator.layer_gates import LayerQualityGate
                    _gate = LayerQualityGate(self.project_name, platform=step.line, language=step.language)
                    print(f"    Gate    : {_layer_name.title()} — {_gate.get_gate_description(_layer_name)}")
                step.status = "completed"  # Mark as completed for dependency resolution
                step.result = {"dry_run": True}
                report.step_results.append({
                    "step_id": step.id,
                    "name": step.name,
                    "command": cmd_str,
                    "status": "dry_run",
                })
            else:
                step.status = "running"
                print(f"    Status  : RUNNING...")
                try:
                    from tasks.task_manager import setup_logger
                    _logger, _log_path = setup_logger(f"orchestrator_{step.id}")
                    pipeline_result = asyncio.run(run_pipeline(
                        user_task=step.task_prompt if hasattr(step, 'task_prompt') and step.task_prompt else f"Build {step.name} for {step.line}",
                        task_source=f"orchestrator ({step.id})",
                        run_mode="full",
                        approval_mode=approval,
                        run_id=f"orch_{step.id}",
                        logger=_logger,
                        log_path=_log_path,
                        profile=profile,
                        env_profile=profile,
                        template=step.template if step.template != "custom" else None,
                        template_name_value=step.template_name,
                        project_name=self.project_name,
                    ))
                    # asyncio.run handles cleanup
                    step.status = "completed"
                    step.result = pipeline_result

                    # Integrate generated files into project
                    try:
                        from code_generation.project_integrator import ProjectIntegrator
                        _proj_path = os.path.join('projects', self.project_name)
                        _ext_map = {'swift': ['.swift'], 'kotlin': ['.kt'], 'typescript': ['.ts', '.tsx'], 'csharp': ['.cs']}
                        _lang = step.language if hasattr(step, 'language') else 'swift'
                        _exts = _ext_map.get(_lang, ['.swift'])
                        _integrator = ProjectIntegrator(_proj_path, file_extensions=_exts)
                        _int_result = _integrator.integrate_generated_code(approval='auto')
                        _copied = _int_result.get('files_copied', 0)
                        if _copied:
                            print(f"    Integrated: {_copied} files into {_proj_path}")
                    except Exception as _ie:
                        print(f"    Integration: skipped ({_ie})")

                    print(f"    Status  : COMPLETED")

                    # Log step completion
                    if production_logger:
                        _files_count = 0
                        _loc_count = 0
                        if isinstance(pipeline_result, dict):
                            _files_count = pipeline_result.get("files_generated", 0)
                            _loc_count = pipeline_result.get("loc", 0)
                        production_logger.log_step_complete(
                            phase=_layer_name or "build",
                            screen=step.id,
                            agent=f"orchestrator/{step.line}",
                            files=_files_count or _copied if '_copied' in dir() else 0,
                            loc=_loc_count,
                        )

                    report.step_results.append({
                        "step_id": step.id,
                        "name": step.name,
                        "command": cmd_str,
                        "status": step.status,
                    })
                except Exception as _e:
                    step.status = "failed"
                    step.result = {"error": str(_e)}
                    print(f"    Status  : FAILED ({_e})")
                    self._skip_dependents(plan, step.id)

                    # Log step error
                    if production_logger:
                        production_logger.log_error(
                            phase=_layer_name or "build",
                            screen=step.id,
                            agent=f"orchestrator/{step.line}",
                            message=str(_e),
                        )

                    report.step_results.append({
                        "step_id": step.id,
                        "name": step.name,
                        "command": cmd_str,
                        "status": "failed",
                        "error": str(_e),
                    })
                except Exception as e:
                    step.status = "failed"
                    step.result = {"error": str(e)}
                    print(f"    Status  : FAILED ({e})")
                    self._skip_dependents(plan, step.id)

                    # Log step error (second catch block)
                    if production_logger:
                        production_logger.log_error(
                            phase=_layer_name or "build",
                            screen=step.id,
                            agent=f"orchestrator/{step.line}",
                            message=str(e),
                        )

                # Run quality gate after successful execution
                if step.status == "completed" and _layer_name:
                    gate_result = self._run_layer_gate(step, _layer_name)
                    if gate_result and gate_result.verdict.value == "blocking":
                        step.status = "failed"
                        print(f"    Gate    : FAIL_BLOCKING — {gate_result.blocking_remaining} blocking issues")
                        self._skip_dependents(plan, step.id)

            print()

        # Determine final plan status
        statuses = [s.status for s in plan.steps]
        if all(s == "completed" for s in statuses):
            plan.status = "completed"
        elif any(s == "failed" for s in statuses):
            plan.status = "failed"
        else:
            plan.status = "completed"

        report.finished = datetime.now().isoformat()

        # Print summary
        completed = sum(1 for s in plan.steps if s.status == "completed")
        failed = sum(1 for s in plan.steps if s.status == "failed")
        skipped = sum(1 for s in plan.steps if s.status == "skipped")
        pending = sum(1 for s in plan.steps if s.status == "pending")

        # Log production completion/failure
        if production_logger and not dry_run:
            if plan.status == "completed":
                production_logger.log_production_complete(
                    total_screens=completed,
                    total_files=sum(
                        r.get("files_generated", 0)
                        for r in report.step_results if isinstance(r, dict)
                    ),
                    total_loc=sum(
                        r.get("loc", 0)
                        for r in report.step_results if isinstance(r, dict)
                    ),
                )
            else:
                _errors = [r.get("error", "") for r in report.step_results if r.get("status") == "failed"]
                production_logger.log_production_failed(
                    error="; ".join(filter(None, _errors)) or "Unknown error",
                )

        print("=" * 60)
        print(f"  Plan Summary: {len(plan.steps)} steps, "
              f"{completed} completed, {failed} failed, "
              f"{skipped} skipped, {pending} pending")
        print("=" * 60)

        # Save plan and report
        specs_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
            "projects", self.project_name, "specs",
        )
        os.makedirs(specs_dir, exist_ok=True)
        plan.save(os.path.join(specs_dir, "build_plan.json"))
        with open(os.path.join(specs_dir, "build_report.json"), "w", encoding="utf-8") as f:
            import json
            json.dump(report.to_dict(), f, indent=2, ensure_ascii=False)

        return report

    @staticmethod
    def _extract_layer_name(step_name: str) -> str | None:
        """Extract layer name from step name like 'TrainingMode — Foundation'."""
        if " — " in step_name:
            layer_part = step_name.split(" — ", 1)[1].strip().lower()
            if layer_part in ("foundation", "domain", "application", "presentation", "polish"):
                return layer_part
        return None

    def _run_layer_gate(self, step: BuildStep, layer_name: str):
        """Run quality gate for a completed layer step."""
        try:
            from factory.orchestrator.layer_gates import LayerQualityGate, GateVerdict
            gate = LayerQualityGate(self.project_name, platform=step.line, language=step.language)
            result = gate.check_layer(layer_name, [])

            print(f"    Gate    : {layer_name.title()} — {result.verdict.value.upper()}"
                  f" ({result.blocking_remaining} blocking, {result.warnings_remaining} warnings)")

            if result.verdict == GateVerdict.FAIL_REPAIRABLE:
                print(f"    Repair  : Attempting auto-repair...")
                result = gate.auto_repair(result)
                for action in result.repair_actions:
                    print(f"              {action}")
                print(f"    Gate    : After repair — {result.verdict.value.upper()}"
                      f" ({result.blocking_remaining} blocking)")

            for detail in result.details[:5]:
                print(f"              {detail}")

            return result
        except Exception as e:
            print(f"    Gate    : Error — {e}")
            return None

    def _skip_dependents(self, plan: BuildPlan, failed_step_id: str):
        """Mark all steps that depend on a failed step as skipped."""
        for step in plan.steps:
            if failed_step_id in step.depends_on and step.status == "pending":
                step.status = "skipped"
                print(f"    → Skipping {step.name} (depends on failed step)")
                # Recursively skip dependents of skipped steps
                self._skip_dependents(plan, step.id)

    def create_layered_build_plan(self, spec: dict | str | None = None) -> BuildPlan:
        """Create a build plan where each feature is decomposed into 5 layers.

        Each feature produces 5 steps (Foundation → Domain → Application → Presentation → Polish).
        Layers within a feature are strictly sequential.
        Feature dependencies: Feature B Layer 1 waits for Feature A Layer 5.
        """
        # First get the flat plan to know features and their deps
        flat_plan = self.create_build_plan(spec)
        if not flat_plan.steps:
            return flat_plan

        decomposer = LayerDecomposer()
        active_lines = self.config.get_active_lines()
        platform = active_lines[0] if active_lines else "ios"

        # Get platform details from config
        line_cfg = self.config.lines.get(platform)
        language = line_cfg.language if line_cfg else "swift"
        framework = line_cfg.framework if line_cfg else "swiftui"

        layered_steps: list[BuildStep] = []
        step_counter = 0

        # Map: feature_name → last step_id (Layer 5) for cross-feature deps
        feature_final_step: dict[str, str] = {}
        # Map: (feature_name, layer) → step_id
        feature_layer_step: dict[tuple[str, int], str] = {}

        # First pass: assign IDs
        for flat_step in flat_plan.steps:
            for layer in BuildLayer:
                step_counter += 1
                step_id = f"step_{step_counter:03d}"
                feature_layer_step[(flat_step.name, layer.value)] = step_id
                if layer == BuildLayer.POLISH:
                    feature_final_step[flat_step.name] = step_id

        # Second pass: create steps with dependencies
        step_counter = 0
        for flat_step in flat_plan.steps:
            layer_specs = decomposer.decompose(
                feature_name=flat_step.name,
                feature_description=flat_step.description,
                platform=platform,
                language=language,
                framework=framework,
            )

            for layer_spec in layer_specs:
                step_counter += 1
                step_id = f"step_{step_counter:03d}"
                layer_num = layer_spec.layer.value
                layer_name = LAYER_NAMES[layer_spec.layer]

                # Dependencies: previous layer of same feature
                dep_ids = []
                if layer_num > 1:
                    prev_id = feature_layer_step.get((flat_step.name, layer_num - 1))
                    if prev_id:
                        dep_ids.append(prev_id)

                # Cross-feature deps: only for Layer 1 (Foundation)
                if layer_num == 1 and flat_step.depends_on:
                    for dep_step_id in flat_step.depends_on:
                        # Find which feature this dep belongs to
                        for fs in flat_plan.steps:
                            if fs.id == dep_step_id:
                                final_id = feature_final_step.get(fs.name)
                                if final_id:
                                    dep_ids.append(final_id)

                layered_steps.append(BuildStep(
                    id=step_id,
                    name=f"{flat_step.name} — {layer_name}",
                    step_type=flat_step.step_type,
                    template=flat_step.template,
                    template_name=flat_step.template_name,
                    line=flat_step.line,
                    language=language,
                    depends_on=dep_ids,
                    priority=flat_step.priority,
                    description=layer_spec.description,
                ))

        plan = BuildPlan(
            project_name=self.project_name,
            steps=layered_steps,
            created=datetime.now().isoformat(),
            status="draft",
        )
        self.build_plan = plan
        return plan

    def get_status(self) -> dict:
        """Return current orchestration status."""
        plan_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
            "projects", self.project_name, "specs", "build_plan.json",
        )
        if os.path.isfile(plan_path):
            plan = BuildPlan.load(plan_path)
            return {
                "project": self.project_name,
                "plan_status": plan.status,
                "total_steps": len(plan.steps),
                "completed": sum(1 for s in plan.steps if s.status == "completed"),
                "failed": sum(1 for s in plan.steps if s.status == "failed"),
                "pending": sum(1 for s in plan.steps if s.status == "pending"),
                "skipped": sum(1 for s in plan.steps if s.status == "skipped"),
            }
        return {
            "project": self.project_name,
            "plan_status": "no_plan",
        }
