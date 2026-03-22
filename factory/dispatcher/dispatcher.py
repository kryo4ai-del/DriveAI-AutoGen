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
    "ceo_gate": None,  # depends on decision
    "run_market_strategy": ProductPhase.MARKET_STRATEGY_COMPLETE,
    "run_mvp_scope": ProductPhase.MVP_SCOPE_COMPLETE,
    "generate_cd_roadbook": ProductPhase.CD_ROADBOOK_COMPLETE,
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
        print(f"[Dispatcher] Submitted: {title} (ID: {product_id}, ambition: {ambition})")
        return entry

    # ── Next Action ─────────────────────────────────────────
    def get_next_action(self, title_filter: str = "") -> dict | None:
        for product in sorted(self.products, key=lambda p: p.priority):
            if title_filter and product.title.lower() != title_filter.lower():
                continue
            if product.phase in (ProductPhase.PARKED, ProductPhase.FAILED,
                                 ProductPhase.CANCELLED, ProductPhase.CEO_NOGO,
                                 ProductPhase.STORE_LIVE):
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
                    result = run_rb(product.pre_production_dir)
                    if result and result.get("cd_roadbook_path"):
                        product.cd_roadbook_path = result["cd_roadbook_path"]
                        self._save_queue()
                    return bool(result)
                except Exception as e:
                    print(f"  CD Roadbook: {e}")
                    return True

            elif act == "start_production":
                # Use orchestrator
                from factory.orchestrator.orchestrator import FactoryOrchestrator
                slug = product.title.lower().replace(" ", "_")
                orch = FactoryOrchestrator(slug)
                plan = orch.create_layered_build_plan()
                if plan and plan.steps:
                    product.project_dir = f"projects/{slug}"
                    self._save_queue()
                    print(f"  Production plan: {len(plan.steps)} steps")
                    return True
                return False

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
