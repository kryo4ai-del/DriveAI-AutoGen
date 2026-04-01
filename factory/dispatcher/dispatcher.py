"""Pipeline Dispatcher — central queue manager for factory products."""
import json
import os
import traceback
from datetime import datetime
from pathlib import Path

from .product_state import ProductEntry, ProductPhase

_ROOT = Path(__file__).resolve().parent.parent.parent
QUEUE_PATH = _ROOT / "factory" / "dispatcher" / "queue_store.json"

# Phase → next phase after successful action
_PHASE_TRANSITIONS = {
    "run_pre_production": ProductPhase.PRE_PRODUCTION_COMPLETE,
    "production_review": ProductPhase.PRODUCTION_REVIEW_PENDING,
    "ceo_gate": None,  # depends on decision
    "run_market_strategy": ProductPhase.MARKET_STRATEGY_COMPLETE,
    "run_mvp_scope": ProductPhase.MVP_SCOPE_COMPLETE,
    "generate_cd_roadbook": ProductPhase.CD_ROADBOOK_COMPLETE,
    "run_feasibility_check": None,  # depends on result
    "start_production": ProductPhase.PRODUCTION_COMPLETE,
    "start_assembly": ProductPhase.ASSEMBLY_COMPLETE,
    "store_prep": ProductPhase.STORE_PREP_COMPLETE,
}


class PipelineDispatcher:
    """Central queue manager. Tracks products through the factory pipeline."""

    def __init__(self, queue_path: str | Path = QUEUE_PATH):
        self.queue_path = Path(queue_path)
        self.products: list[ProductEntry] = self._load_queue()

    # ── Submit ──────────────────────────────────────────────
    def submit_idea(self, idea: str, title: str,
                    ambition: str = "realistic",
                    platforms: list[str] | None = None,
                    priority: int = 5) -> ProductEntry:
        slug = title.lower().replace(" ", "_").replace("-", "_")
        product_id = f"{len(self.products) + 1:03d}_{slug}"
        entry = ProductEntry(
            id=product_id, title=title, idea=idea,
            ambition=ambition, priority=priority,
            platforms=platforms or ["ios", "android", "web"],
            phase=ProductPhase.IDEA_SUBMITTED,
            created_at=datetime.now().isoformat(),
            updated_at=datetime.now().isoformat(),
        )
        self.products.append(entry)
        self._save_queue()
        # Create project.json so it appears in the dashboard immediately
        self._create_project_json(slug, title, ambition)
        print(f"[Dispatcher] Submitted: {title} (ID: {product_id}, ambition: {ambition})")
        return entry

    def _create_project_json(self, slug: str, title: str, ambition: str = "realistic") -> None:
        """Create a minimal factory/projects/<slug>/project.json for dashboard visibility."""
        project_dir = _ROOT / "factory" / "projects" / slug
        project_dir.mkdir(parents=True, exist_ok=True)
        project_file = project_dir / "project.json"
        if project_file.exists():
            return  # Don't overwrite existing project
        today = datetime.now().strftime("%Y-%m-%d")
        project_data = {
            "project_id": slug,
            "title": title,
            "project_type": "production",
            "archived": False,
            "created": today,
            "updated": today,
            "status": "idea_submitted",
            "current_phase": f"Idee eingereicht — wartet auf Pre-Production ({ambition})",
            "ambition": ambition,
            "runs": {"pre_production": [], "active_run": None},
            "gates": {
                "idea_approval": {"status": "pending", "date": None, "notes": None},
                "ceo_gate": {"status": "pending", "date": None, "notes": None},
                "visual_review": {"status": "pending", "date": None, "notes": None},
            },
            "chapters": {
                "phase1": {"status": "not_started", "run_number": None, "output_dir": None, "date": None},
                "kapitel3": {"status": "not_started", "run_number": None, "output_dir": None, "date": None},
                "kapitel4": {"status": "not_started", "run_number": None, "output_dir": None, "date": None},
                "kapitel45": {"status": "not_started", "run_number": None, "output_dir": None, "date": None},
                "kapitel5": {"status": "not_started", "run_number": None, "output_dir": None, "date": None},
                "kapitel6": {"status": "not_started", "run_number": None, "output_dir": None, "date": None},
            },
            "production": {
                "ios": {"status": "not_started"},
                "android": {"status": "not_started"},
                "web": {"status": "not_started"},
                "assembly": {"status": "not_started"},
            },
            "documents": {},
            "costs": {"serpapi_credits_total": 0, "llm_cost_usd_total": 0.0, "pdf_generation_calls": 0},
            "key_metrics": {},
        }
        with open(project_file, "w", encoding="utf-8") as f:
            json.dump(project_data, f, indent=2, ensure_ascii=False)
        print(f"[Dispatcher] Project created: factory/projects/{slug}/project.json")

    # ── Next Action ─────────────────────────────────────────
    def get_next_action(self, title_filter: str = "") -> dict | None:
        for product in sorted(self.products, key=lambda p: p.priority):
            if title_filter and product.title.lower() != title_filter.lower():
                continue
            if product.phase in (ProductPhase.PARKED, ProductPhase.FAILED,
                                 ProductPhase.CANCELLED, ProductPhase.CEO_NOGO,
                                 ProductPhase.STORE_LIVE,
                                 ProductPhase.PARKED_PARTIALLY,
                                 ProductPhase.PARKED_BLOCKED):
                continue
            action = self._action_for(product)
            if action:
                return action
        return None

    def _action_for(self, p: ProductEntry) -> dict | None:
        phase = p.phase
        base = {"product_id": p.id, "product_title": p.title}

        if phase == ProductPhase.IDEA_SUBMITTED:
            return {**base, "action": "run_pre_production",
                    "description": f"Run Pre-Production for {p.title}",
                    "auto": True}

        if phase == ProductPhase.PRE_PRODUCTION_COMPLETE:
            return {**base, "action": "ceo_gate",
                    "description": f"CEO Decision needed for {p.title}",
                    "auto": False}

        if phase == ProductPhase.CEO_GO:
            return {**base, "action": "run_market_strategy",
                    "description": f"Run Market Strategy for {p.title}",
                    "auto": True}

        if phase == ProductPhase.MARKET_STRATEGY_COMPLETE:
            return {**base, "action": "run_mvp_scope",
                    "description": f"Run MVP Scope for {p.title}",
                    "auto": True}

        if phase == ProductPhase.MVP_SCOPE_COMPLETE:
            return {**base, "action": "generate_cd_roadbook",
                    "description": f"Generate CD Roadbook for {p.title}",
                    "auto": True}

        if phase == ProductPhase.CD_ROADBOOK_COMPLETE:
            return {**base, "action": "run_feasibility_check",
                    "description": f"Feasibility Check for {p.title}",
                    "auto": True}

        if phase == ProductPhase.FEASIBLE:
            return {**base, "action": "production_review",
                    "description": f"CEO Review: Feasibility passed for {p.title}. Approve production start?",
                    "auto": False}

        if phase == ProductPhase.PRODUCTION_REVIEW_PENDING:
            return {**base, "action": "start_production",
                    "description": f"Start Production for {p.title}",
                    "auto": True}

        if phase == ProductPhase.PRODUCTION_COMPLETE:
            return {**base, "action": "start_assembly",
                    "description": f"Assemble {p.title}",
                    "auto": True}

        if phase == ProductPhase.ASSEMBLY_COMPLETE:
            return {**base, "action": "store_prep",
                    "description": f"Store preparation for {p.title}",
                    "auto": True}

        return None

    # ── Execute ─────────────────────────────────────────────
    def execute_next(self, title_filter: str = "", auto_ceo_go: bool = False) -> dict | None:
        action = self.get_next_action(title_filter)
        if not action:
            print("[Dispatcher] No pending actions.")
            return None

        if not action["auto"] and action["action"] == "production_review":
            if auto_ceo_go:
                self.advance_phase(action["product_id"], ProductPhase.PRODUCTION_REVIEW_PENDING,
                                   "Production auto-approved (--auto-ceo-go)")
                return {**action, "success": True, "note": "auto production GO"}
            print(f"[Dispatcher] Production Review needed for {action['product_title']}")
            print(f"  Check roadbooks in the pre-production output directory.")
            print(f"  Then run: python main.py --factory-advance {action['product_title']} --phase production_review_pending")
            return action

        if not action["auto"] and action["action"] == "ceo_gate":
            if auto_ceo_go:
                self.advance_phase(action["product_id"], ProductPhase.CEO_GO,
                                   "Auto-approved (--auto-ceo-go)")
                return {**action, "success": True, "note": "auto CEO GO"}
            print(f"[Dispatcher] CEO decision needed for {action['product_title']}")
            print(f"  Run: python main.py --factory-advance {action['product_title']} --phase ceo_go")
            return action

        print(f"[Dispatcher] Executing: {action['description']}")
        success = self._run_action(action)
        action["success"] = success

        if success:
            next_phase = _PHASE_TRANSITIONS.get(action["action"])
            if next_phase:
                self.advance_phase(action["product_id"], next_phase)
        else:
            self.advance_phase(action["product_id"], ProductPhase.FAILED,
                               f"Action '{action['action']}' failed")

        return action

    def _run_action(self, action: dict) -> bool:
        """Execute action as direct Python call (not subprocess)."""
        act = action["action"]
        product = self._get_product(action["product_id"])
        if not product:
            return False

        try:
            if act == "run_pre_production":
                from factory.pre_production.pipeline import run_pipeline
                result = run_pipeline(product.idea, product.title, ambition=product.ambition)
                if result and result.get("output_dir"):
                    product.pre_production_dir = result["output_dir"]
                    self._save_queue()
                return bool(result)

            elif act == "run_market_strategy":
                try:
                    from factory.market_strategy.pipeline import run_pipeline as run_ms
                    print(f"  Input: {product.pre_production_dir}")
                    result = run_ms(product.pre_production_dir)
                    if result and result.get("output_dir"):
                        product.market_strategy_dir = result["output_dir"]
                        self._save_queue()
                    return bool(result)
                except Exception as e:
                    print(f"  Market Strategy: {e}")
                    # Non-critical — advance anyway
                    return True

            elif act == "run_mvp_scope":
                try:
                    from factory.mvp_scope.pipeline import run_pipeline as run_mvp
                    result = run_mvp(product.pre_production_dir, product.market_strategy_dir)
                    if result and result.get("output_dir"):
                        product.mvp_scope_dir = result["output_dir"]
                        self._save_queue()
                    return bool(result)
                except Exception as e:
                    print(f"  MVP Scope: {e}")
                    return True

            elif act == "generate_cd_roadbook":
                try:
                    from factory.roadbook_assembly.pipeline import run_pipeline as run_rb
                    print(f"  Input: {product.pre_production_dir}")
                    result = run_rb(product.pre_production_dir)
                    if result and result.get("cd_roadbook_path"):
                        product.cd_roadbook_path = result["cd_roadbook_path"]
                        self._save_queue()
                    return bool(result)
                except Exception as e:
                    print(f"  CD Roadbook: {e}")
                    return True

            elif act == "run_feasibility_check":
                from factory.hq.capabilities.feasibility_check import FeasibilityChecker
                slug = product.title.lower().replace(" ", "").replace("-", "")
                checker = FeasibilityChecker()
                result = checker.check_project(slug)
                product.feasibility_result = result
                self._save_queue()

                overall = result.get("overall_status", "not_feasible")
                score = result.get("score", 0.0)
                print(f"  Feasibility: {overall} (score={score})")

                if overall == "feasible":
                    self.advance_phase(product.id, ProductPhase.FEASIBLE,
                                       f"Feasibility passed (score={score})")
                elif overall == "partially_feasible":
                    gaps = ", ".join(g.get("capability", "?")
                                    for g in result.get("capability_gaps", []))
                    self.advance_phase(product.id, ProductPhase.PARKED_PARTIALLY,
                                       f"Partially feasible -- gaps: {gaps}")
                    try:
                        from factory.hq.capabilities.gate_creator import create_feasibility_gate
                        create_feasibility_gate(slug, result)
                    except Exception as e:
                        print(f"  Gate creation failed: {e}")
                else:
                    gaps = ", ".join(g.get("capability", "?")
                                    for g in result.get("capability_gaps", []))
                    self.advance_phase(product.id, ProductPhase.PARKED_BLOCKED,
                                       f"Not feasible -- gaps: {gaps}")
                    try:
                        from factory.hq.capabilities.gate_creator import create_feasibility_gate
                        create_feasibility_gate(slug, result)
                    except Exception as e:
                        print(f"  Gate creation failed: {e}")

                # Update project registry if available
                try:
                    from factory.shared.project_registry import update_feasibility
                    update_feasibility(slug, result)
                except Exception:
                    pass

                return True

            elif act == "start_production":
                # Auto-create project if needed
                slug = product.title.lower().replace(" ", "").replace("-", "")
                proj_dir = os.path.join("projects", slug)
                if not os.path.exists(os.path.join(proj_dir, "project.yaml")):
                    from factory.dispatcher.project_creator import ProjectCreator
                    proj_dir = ProjectCreator().create_from_pipeline_output(
                        product, product.pre_production_dir, product.mvp_scope_dir)
                    product.project_dir = proj_dir
                    self._save_queue()
                # Use orchestrator — create plan AND execute first feature
                from factory.orchestrator.orchestrator import FactoryOrchestrator
                orch = FactoryOrchestrator(slug)
                plan = orch.create_layered_build_plan()
                if not plan or not plan.steps:
                    print(f"  No build steps for {slug}")
                    return False

                # Limit to first feature only (cost control)
                first_feature = plan.steps[0].name.split(" — ")[0] if " — " in plan.steps[0].name else plan.steps[0].name
                original_count = len(plan.steps)
                plan.steps = [s for s in plan.steps if first_feature in s.name]
                print(f"  Build plan: {len(plan.steps)} steps (first feature of {original_count} total)")

                product.project_dir = f"projects/{slug}"
                self._save_queue()

                # Execute (real pipeline calls, not dry-run)
                report = orch.execute_plan(plan, dry_run=False, profile="dev", approval="auto")
                completed = sum(1 for s in plan.steps if s.status == "completed")
                print(f"  Production: {completed}/{len(plan.steps)} steps completed")
                return completed > 0

            elif act == "start_assembly":
                slug = product.title.lower().replace(" ", "_")
                from factory.assembly import AssemblyManager
                mgr = AssemblyManager()
                handoff = mgr.create_handoff(slug)
                if handoff and handoff.is_ready_for_assembly():
                    report = mgr.start_assembly(handoff)
                    product.production_files = handoff.total_files
                    self._save_queue()
                    return report.status in ("complete", "compile_failed")
                return False

            elif act == "store_prep":
                slug = product.title.lower().replace(" ", "_")
                from factory.store import StorePipeline
                pipeline = StorePipeline(slug)
                result = pipeline.run("all")
                return bool(result)

            else:
                print(f"  Unknown action: {act}")
                return False

        except Exception as e:
            print(f"  Error in {act}: {e}")
            traceback.print_exc()
            return False

    # ── Run Full ────────────────────────────────────────────
    def run_full_pipeline(self, title: str, auto_ceo_go: bool = False):
        """Run entire pipeline for a product, step by step."""
        print(f"\n{'='*60}")
        print(f"  Factory Pipeline: {title}")
        print(f"{'='*60}\n")

        steps = 0
        while steps < 20:  # safety limit
            action = self.get_next_action(title)
            if not action:
                break

            result = self.execute_next(title, auto_ceo_go=auto_ceo_go)
            if not result:
                break
            if not result.get("auto", True) and not auto_ceo_go:
                break
            if not result.get("success", False):
                break
            steps += 1

        product = self._get_by_title(title)
        if product:
            print(f"\n[Dispatcher] {title}: {product.phase.value}")

    # ── Phase Management ────────────────────────────────────
    def advance_phase(self, product_id: str, new_phase: ProductPhase, notes: str = ""):
        product = self._get_product(product_id)
        if not product:
            print(f"[Dispatcher] Product not found: {product_id}")
            return
        old = product.phase
        product.phase = new_phase
        product.updated_at = datetime.now().isoformat()
        product.phase_history.append({
            "from": old.value, "to": new_phase.value,
            "timestamp": datetime.now().isoformat(), "notes": notes,
        })
        self._save_queue()
        print(f"[Dispatcher] {product.title}: {old.value} -> {new_phase.value}")

    # ── Queue Status ────────────────────────────────────────
    def get_queue_status(self) -> str:
        if not self.products:
            return "Pipeline Queue: empty"
        lines = [f"Pipeline Queue ({len(self.products)} products):"]
        for p in sorted(self.products, key=lambda x: x.priority):
            phase = p.phase.value
            if "complete" in phase or phase == "store_live":
                icon = "DONE"
            elif phase in ("failed", "ceo_nogo", "cancelled"):
                icon = "STOP"
            elif phase == "parked":
                icon = "PARK"
            elif "pending" in phase or "review" in phase:
                icon = "WAIT"
            else:
                icon = "RUN"
            lines.append(f"  [{icon}] #{p.id}: {p.title} — {phase} (p{p.priority})")
        return "\n".join(lines)

    # ── Persistence ─────────────────────────────────────────
    def _load_queue(self) -> list[ProductEntry]:
        if not self.queue_path.exists():
            return []
        try:
            data = json.loads(self.queue_path.read_text(encoding="utf-8"))
            return [ProductEntry.from_dict(d) for d in data.get("products", [])]
        except Exception:
            return []

    def _save_queue(self):
        self.queue_path.parent.mkdir(parents=True, exist_ok=True)
        data = {"products": [p.to_dict() for p in self.products],
                "updated": datetime.now().isoformat()}
        self.queue_path.write_text(json.dumps(data, indent=2, ensure_ascii=False),
                                   encoding="utf-8")

    def _get_product(self, product_id: str) -> ProductEntry | None:
        for p in self.products:
            if p.id == product_id:
                return p
        return None

    def _get_by_title(self, title: str) -> ProductEntry | None:
        for p in self.products:
            if p.title.lower() == title.lower():
                return p
        return None


# ── CLI Entry Point ──────────────────────────────────────────────────────
# Called by production.js:  python -m factory.dispatcher.dispatcher --start-production <slug> --spec <path>

if __name__ == "__main__":
    import argparse
    import sys

    parser = argparse.ArgumentParser(description="Factory Dispatcher CLI")
    parser.add_argument("--start-production", dest="slug", help="Start production for a project slug")
    parser.add_argument("--spec", help="Path to build_spec.yaml")
    args = parser.parse_args()

    if not args.slug:
        parser.print_help()
        sys.exit(1)

    slug = args.slug
    spec_path = args.spec

    # Set working directory to project root
    os.chdir(str(_ROOT))

    from factory.integration.production_logger import ProductionLogger

    logger = ProductionLogger(slug)
    print(f"[Dispatcher] Starting production for {slug}", file=sys.stderr)

    try:
        from factory.orchestrator.orchestrator import FactoryOrchestrator

        orch = FactoryOrchestrator(slug)

        # Create build plan from spec if provided
        if spec_path and os.path.isfile(spec_path):
            plan = orch.create_build_plan(spec_path)
            # Decompose into layered plan
            plan = orch.create_layered_build_plan(spec_path)
        else:
            plan = orch.create_layered_build_plan()

        if not plan or not plan.steps:
            logger.log_production_failed(f"No build steps for {slug}")
            print(f"[Dispatcher] No build steps for {slug}", file=sys.stderr)
            sys.exit(1)

        print(f"[Dispatcher] Build plan: {len(plan.steps)} steps", file=sys.stderr)

        # Execute with production logger
        report = orch.execute_plan(
            plan,
            dry_run=False,
            profile="dev",
            approval="auto",
            production_logger=logger,
        )

        completed = sum(1 for s in plan.steps if s.status == "completed")
        failed = sum(1 for s in plan.steps if s.status == "failed")
        print(f"[Dispatcher] Done: {completed} completed, {failed} failed", file=sys.stderr)

    except Exception as e:
        logger.log_production_failed(str(e))
        print(f"[Dispatcher] Fatal error: {e}", file=sys.stderr)
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)
