"""Product lifecycle states for the factory pipeline."""
from dataclasses import dataclass, field
from enum import Enum


class ProductPhase(Enum):
    IDEA_SUBMITTED = "idea_submitted"
    PRE_PRODUCTION_RUNNING = "pre_production_running"
    PRE_PRODUCTION_COMPLETE = "pre_production_complete"
    CEO_REVIEW_PENDING = "ceo_review_pending"
    CEO_GO = "ceo_go"
    CEO_NOGO = "ceo_nogo"
    CEO_CAUTION = "ceo_caution"
    MARKET_STRATEGY_RUNNING = "market_strategy_running"
    MARKET_STRATEGY_COMPLETE = "market_strategy_complete"
    MVP_SCOPE_RUNNING = "mvp_scope_running"
    MVP_SCOPE_COMPLETE = "mvp_scope_complete"
    CD_ROADBOOK_PENDING = "cd_roadbook_pending"
    CD_ROADBOOK_RUNNING = "cd_roadbook_running"
    CD_ROADBOOK_COMPLETE = "cd_roadbook_complete"
    PRODUCTION_PENDING = "production_pending"
    PRODUCTION_RUNNING = "production_running"
    PRODUCTION_COMPLETE = "production_complete"
    ASSEMBLY_PENDING = "assembly_pending"
    ASSEMBLY_RUNNING = "assembly_running"
    ASSEMBLY_COMPLETE = "assembly_complete"
    REPAIR_RUNNING = "repair_running"
    REPAIR_COMPLETE = "repair_complete"
    STORE_PREP_PENDING = "store_prep_pending"
    STORE_PREP_COMPLETE = "store_prep_complete"
    STORE_SUBMITTED = "store_submitted"
    STORE_LIVE = "store_live"
    PARKED = "parked"
    FAILED = "failed"
    CANCELLED = "cancelled"


@dataclass
class ProductEntry:
    """A product flowing through the factory pipeline."""
    id: str
    title: str
    idea: str
    ambition: str = "realistic"
    phase: ProductPhase = ProductPhase.IDEA_SUBMITTED
    priority: int = 5
    platforms: list[str] = field(default_factory=lambda: ["ios", "android", "web"])
    pre_production_dir: str = ""
    market_strategy_dir: str = ""
    mvp_scope_dir: str = ""
    cd_roadbook_path: str = ""
    project_dir: str = ""
    created_at: str = ""
    updated_at: str = ""
    phase_history: list[dict] = field(default_factory=list)
    ceo_decision: str = ""
    ceo_notes: str = ""
    production_files: int = 0
    compile_errors: int = 0
    store_readiness: float = 0.0

    def to_dict(self) -> dict:
        d = {
            "id": self.id, "title": self.title, "idea": self.idea,
            "ambition": self.ambition, "phase": self.phase.value,
            "priority": self.priority, "platforms": self.platforms,
            "pre_production_dir": self.pre_production_dir,
            "market_strategy_dir": self.market_strategy_dir,
            "mvp_scope_dir": self.mvp_scope_dir,
            "cd_roadbook_path": self.cd_roadbook_path,
            "project_dir": self.project_dir,
            "created_at": self.created_at, "updated_at": self.updated_at,
            "phase_history": self.phase_history,
            "ceo_decision": self.ceo_decision, "ceo_notes": self.ceo_notes,
            "production_files": self.production_files,
            "compile_errors": self.compile_errors,
            "store_readiness": self.store_readiness,
        }
        return d

    @classmethod
    def from_dict(cls, d: dict) -> "ProductEntry":
        d = dict(d)
        d["phase"] = ProductPhase(d.get("phase", "idea_submitted"))
        return cls(**{k: v for k, v in d.items() if k in cls.__dataclass_fields__})
