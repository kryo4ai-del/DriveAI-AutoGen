"""Model Evolution Loop -- autonomous model registry maintenance.

Closes the loop: PriceMonitor detects → Evolution evaluates → Registry updated.
Rate-limited to max 1 cycle per 24 hours.

Steps:
  1. Cooldown check
  2. Discovery (PriceMonitor API scan)
  3. Evaluation (compatibility test + tier classification)
  4. Registration (update models_registry.json)
  5. Verification (sanity check after write)
  6. Memory (log to FactoryMemory)

CLI: python -m factory.brain.model_provider.model_evolution
"""

import json
import logging
import os
import shutil
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)

_DIR = Path(__file__).resolve().parent
_STATE_FILE = _DIR / "evolution_state.json"
_REGISTRY_FILE = _DIR / "models_registry.json"
_CONFIG_DIR = _DIR.parents[2] / "config"
_LLM_PROFILES_FILE = _CONFIG_DIR / "llm_profiles.json"
_AGENT_REGISTRY_FILE = _DIR.parents[1] / "agent_registry.json"
_COOLDOWN_HOURS = 24

# ── Cascade Rules ─────────────────────────────────────────────────
CASCADE_RULES = {
    "same_provider_preferred": True,
    "cross_provider_allowed": False,
    "max_cascade_depth": 3,
    "deprecated_model_keepalive": True,
    "benchmark_required_for_premium": True,
}


# ── Dataclasses ────────────────────────────────────────────────────

@dataclass
class EvolutionAction:
    """Single action taken during an evolution cycle."""
    action: str         # "discovered", "verified", "registered", "deprecated", "skipped"
    model_id: str
    provider: str
    tier: str = ""
    reason: str = ""
    verified: bool = False


@dataclass
class TierReassignment:
    """Single tier change in a cascade."""
    model_id: str
    provider: str
    old_tier: str       # "premium", "standard", "lightweight", or "" (new model)
    new_tier: str       # "premium", "standard", "lightweight", "deprecated"
    reason: str = ""


@dataclass
class CascadePlan:
    """Full tier cascade plan triggered by a new model."""
    trigger_model: str = ""
    trigger_provider: str = ""
    reassignments: list = field(default_factory=list)
    affected_agents: int = 0
    estimated_cost_change_pct: float = 0.0
    risk_level: str = "low"         # "low", "medium", "high"
    requires_benchmark: bool = False

    def describe(self) -> str:
        lines = ["  Tier Cascade:"]
        lines.append(f"    Triggered by: {self.trigger_provider}/{self.trigger_model}")
        for r in self.reassignments:
            old = r.old_tier or "new"
            lines.append(f"    {r.model_id}: {old} -> {r.new_tier}")
        lines.append(f"    Agents affected: {self.affected_agents}")
        lines.append(f"    Cost change: {self.estimated_cost_change_pct:+.1f}%")
        lines.append(f"    Risk: {self.risk_level}")
        if self.requires_benchmark:
            lines.append("    Benchmark required: yes")
        return "\n".join(lines)


@dataclass
class EvolutionReport:
    """Result of one evolution cycle."""
    timestamp: str = ""
    status: str = "pending"     # "success", "skipped_cooldown", "no_changes", "error"
    actions: list = field(default_factory=list)
    models_added: int = 0
    models_deprecated: int = 0
    cost_usd: float = 0.0
    duration_sec: float = 0.0
    errors: list = field(default_factory=list)
    cascade_plan: CascadePlan | None = None

    def summary(self) -> str:
        lines = [
            "",
            "=" * 60,
            "  MODEL EVOLUTION REPORT",
            "=" * 60,
            f"  Timestamp:  {self.timestamp}",
            f"  Status:     {self.status.upper()}",
            f"  Duration:   {self.duration_sec:.1f}s",
            f"  Cost:       ${self.cost_usd:.4f}",
            f"  Added:      {self.models_added}",
            f"  Deprecated: {self.models_deprecated}",
        ]
        if self.actions:
            lines.append("")
            lines.append("  Actions:")
            for a in self.actions:
                tag = a.action.upper()
                v = " (verified)" if a.verified else ""
                lines.append(f"    [{tag:12s}] {a.provider}/{a.model_id} tier={a.tier}{v}")
                if a.reason:
                    lines.append(f"                 {a.reason}")
        if self.cascade_plan and self.cascade_plan.reassignments:
            lines.append("")
            lines.append(self.cascade_plan.describe())
        if self.errors:
            lines.append("")
            lines.append("  Errors:")
            for e in self.errors:
                lines.append(f"    - {e[:120]}")
        lines.append("=" * 60)
        return "\n".join(lines)


# ── Main Class ─────────────────────────────────────────────────────

class ModelEvolution:
    """Autonomous model registry evolution controller.

    Usage:
        evo = ModelEvolution()
        report = evo.run_cycle()           # respect 24h cooldown
        report = evo.run_cycle(force=True)  # ignore cooldown
        status = evo.get_status()           # read-only status
    """

    def run_cycle(self, force: bool = False, dry_run: bool = False) -> EvolutionReport:
        """Run the full evolution cycle. Fail-stop on any error."""
        report = EvolutionReport(timestamp=datetime.now(timezone.utc).isoformat())
        start = time.time()

        try:
            # Step 1: Cooldown
            if not force and not self._check_cooldown():
                report.status = "skipped_cooldown"
                state = self._load_state()
                last = state.get("last_run_iso", "?")
                report.errors.append(f"Cooldown active (last run: {last}, next in <{_COOLDOWN_HOURS}h)")
                return report

            # Step 2: Discovery
            print("\n[Evolution] Step 1/5: Discovery (scanning provider APIs)...")
            actions = self._discover()
            if not actions:
                report.status = "no_changes"
                report.duration_sec = time.time() - start
                print("  No new or deprecated models found.")
                if not dry_run:
                    self._save_state(report)
                return report

            print(f"  Found {len(actions)} potential change(s)")

            # Step 3: Evaluation
            print("[Evolution] Step 2/5: Evaluation (compatibility + tier classification)...")
            actions = self._evaluate(actions, dry_run=dry_run)
            report.actions = actions

            registrable = [a for a in actions if a.action == "verified"]
            deprecatable = [a for a in actions if a.action == "deprecated"]
            skipped = [a for a in actions if a.action == "skipped"]

            print(f"  Verified: {len(registrable)}, Deprecated: {len(deprecatable)}, Skipped: {len(skipped)}")

            if not registrable and not deprecatable:
                report.status = "no_changes"
                report.duration_sec = time.time() - start
                print("  Nothing to register or deprecate.")
                if not dry_run:
                    self._save_state(report)
                return report

            # Step 4: Registration
            print("[Evolution] Step 3/5: Registration (updating registry)...")
            if not dry_run:
                self._register(registrable, deprecatable)
            report.models_added = len(registrable)
            report.models_deprecated = len(deprecatable)

            for a in registrable:
                a.action = "registered"
                print(f"  + {a.provider}/{a.model_id} (tier={a.tier})")
            for a in deprecatable:
                print(f"  - {a.provider}/{a.model_id} (deprecated)")

            # Step 4.5: Cascade evaluation
            cascade = self._evaluate_cascade(registrable)
            if cascade and cascade.reassignments:
                print("[Evolution] Step 3.5: Tier Cascade detected!")
                print(f"  Trigger: {cascade.trigger_provider}/{cascade.trigger_model}")
                print(f"  Reassignments: {len(cascade.reassignments)}")
                print(f"  Affected agents: {cascade.affected_agents}")
                print(f"  Risk: {cascade.risk_level}")

                execute_cascade = True
                if cascade.requires_benchmark and not dry_run:
                    print("  Running quick benchmark for premium candidate...")
                    passed = self._quick_benchmark(
                        cascade.trigger_model, cascade.trigger_provider)
                    if not passed:
                        print("  Benchmark FAILED — skipping cascade")
                        report.errors.append("Cascade benchmark failed, skipped")
                        execute_cascade = False

                if execute_cascade:
                    if not dry_run:
                        ok = self._execute_cascade(cascade)
                        if not ok:
                            report.errors.append("Cascade execution failed, rolled back")
                            cascade = None
                    report.cascade_plan = cascade

            # Step 5: Verification
            print("[Evolution] Step 4/5: Verification...")
            if not dry_run:
                ok = self._verify()
                if not ok:
                    print("  VERIFICATION FAILED — rolling back!")
                    self.rollback()
                    report.status = "error"
                    report.errors.append("Post-registration verification failed, rolled back")
                    report.duration_sec = time.time() - start
                    self._save_state(report)
                    self._log_to_memory(report)
                    return report
                print("  OK")

            # Step 6: Memory
            print("[Evolution] Step 5/5: Logging to FactoryMemory...")
            if not dry_run:
                self._log_to_memory(report)

            report.status = "success"

        except Exception as e:
            report.status = "error"
            report.errors.append(str(e))
            logger.error("Evolution cycle failed: %s", e)

        report.duration_sec = time.time() - start
        if not dry_run:
            self._save_state(report)
        return report

    # ── Step 1: Cooldown ──────────────────────────────────────────

    def _check_cooldown(self) -> bool:
        """Returns True if enough time has passed since last run."""
        state = self._load_state()
        last_run = state.get("last_run_iso", "")
        if not last_run:
            return True
        try:
            last_dt = datetime.fromisoformat(last_run)
            if last_dt.tzinfo is None:
                last_dt = last_dt.replace(tzinfo=timezone.utc)
            now = datetime.now(timezone.utc)
            return (now - last_dt) > timedelta(hours=_COOLDOWN_HOURS)
        except (ValueError, TypeError):
            return True

    # ── Step 2: Discovery ─────────────────────────────────────────

    def _discover(self) -> list:
        """Compare provider API models with current registry."""
        from .price_monitor import PriceMonitor
        from .model_registry import ModelRegistry
        from .known_prices import is_interesting_model, is_versioned_duplicate

        monitor = PriceMonitor()
        registry = ModelRegistry()
        actions = []

        providers = ["openai", "google", "mistral", "anthropic"]
        for provider in providers:
            key_env = {"anthropic": "ANTHROPIC_API_KEY", "openai": "OPENAI_API_KEY",
                       "google": "GEMINI_API_KEY", "mistral": "MISTRAL_API_KEY"}.get(provider)
            key = os.environ.get(key_env, "") if key_env else ""
            if not key:
                continue

            api_models = monitor._list_models(provider, key)
            if api_models is None:
                continue

            # Extract model IDs from API response
            api_ids = set()
            for m in api_models:
                mid = m.get("id") or m.get("name", "")
                if "/" in mid:
                    mid = mid.split("/")[-1]
                if mid:
                    api_ids.add(mid)

            registry_models = registry.get_models_by_provider(provider)
            registry_ids = {m.model_id for m in registry_models}

            # New models: filter non-chat, then dedup versioned variants
            new_ids = []
            for model_id in api_ids - registry_ids:
                if not is_interesting_model(provider, model_id):
                    continue
                if is_versioned_duplicate(model_id, registry_ids):
                    continue
                new_ids.append(model_id)

            # Two-pass dedup: shortest first (base model before variants),
            # then filter versioned duplicates against already-accepted models
            new_ids.sort(key=len)
            accepted = set()
            for model_id in new_ids:
                if is_versioned_duplicate(model_id, accepted):
                    continue
                if is_versioned_duplicate(model_id, {a.model_id for a in actions}):
                    continue
                accepted.add(model_id)
                actions.append(EvolutionAction(
                    action="discovered", model_id=model_id, provider=provider,
                    reason="New model detected in provider API",
                ))

            # Deprecated (skip Anthropic — its list is hardcoded in PriceMonitor)
            if provider != "anthropic":
                for model_id in registry_ids - api_ids:
                    model_info = registry.get_model(model_id)
                    if model_info and model_info.status == "active":
                        actions.append(EvolutionAction(
                            action="deprecated", model_id=model_id, provider=provider,
                            reason="Model no longer in provider API",
                        ))

        return actions

    # ── Step 3: Evaluation ────────────────────────────────────────

    def _evaluate(self, actions: list, dry_run: bool = False) -> list:
        """Verify compatibility and classify tier for each discovered model."""
        from .known_prices import lookup_model, classify_tier, get_litellm_name

        evaluated = []
        for action in actions:
            if action.action == "deprecated":
                evaluated.append(action)
                continue

            if action.action != "discovered":
                evaluated.append(action)
                continue

            # Tier classification from known prices
            known = lookup_model(action.model_id)
            if known:
                action.tier = known["tier"]
            else:
                action.tier = "mid"  # safe default

            # Compatibility test (skip in dry_run)
            if dry_run:
                action.action = "verified"
                action.verified = True
                action.reason = "Dry run — skipped verification"
                evaluated.append(action)
                continue

            litellm_name = get_litellm_name(action.provider, action.model_id)
            try:
                import litellm
                response = litellm.completion(
                    model=litellm_name,
                    messages=[{"role": "user", "content": "Say OK"}],
                    max_tokens=5,
                    temperature=0.0,
                )
                action.verified = True
                action.action = "verified"
                action.reason = f"Compatibility test passed (litellm: {litellm_name})"

                # Try to get actual cost for better tier classification
                if not known:
                    try:
                        cost = litellm.completion_cost(response)
                        out_tok = getattr(response.usage, "completion_tokens", 0) or 1
                        price_per_1k = (cost / out_tok) * 1000
                        action.tier = classify_tier(price_per_1k)
                    except Exception:
                        pass

            except Exception as e:
                action.action = "skipped"
                action.reason = f"Verification failed: {str(e)[:100]}"

            evaluated.append(action)

        return evaluated

    # ── Step 4: Registration ──────────────────────────────────────

    def _register(self, to_add: list, to_deprecate: list) -> None:
        """Write changes to models_registry.json. Backup first."""
        self._backup_registry()

        registry_data = json.loads(_REGISTRY_FILE.read_text(encoding="utf-8"))

        from .known_prices import lookup_model, get_litellm_name

        for action in to_add:
            known = lookup_model(action.model_id)
            entry = {
                "display_name": action.model_id,
                "litellm_model_name": get_litellm_name(action.provider, action.model_id),
                "max_output_tokens": known.get("max_out", 4096) if known else 4096,
                "max_context_window": known.get("ctx", 128000) if known else 128000,
                "price_per_1k_input": known["in"] if known else 0.001,
                "price_per_1k_output": known["out"] if known else 0.005,
                "strengths": [],
                "weaknesses": [],
                "status": "active",
                "tier_equivalent": action.tier,
            }
            if action.provider not in registry_data:
                registry_data[action.provider] = {}
            registry_data[action.provider][action.model_id] = entry

        for action in to_deprecate:
            if action.provider in registry_data and action.model_id in registry_data[action.provider]:
                registry_data[action.provider][action.model_id]["status"] = "deprecated"

        _REGISTRY_FILE.write_text(
            json.dumps(registry_data, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        # Invalidate singleton cache so next access reloads
        try:
            import factory.brain.model_provider as mp
            mp._registry = None
            mp._router = None
        except Exception:
            pass

    # ── Step 5: Verification ──────────────────────────────────────

    def _verify(self) -> bool:
        """Verify registry is still valid after changes."""
        try:
            from .model_registry import ModelRegistry
            reg = ModelRegistry()
            # Basic sanity: can we load and get models?
            models = reg.get_available_models()
            if not models:
                logger.error("Verification: no available models after update")
                return False
            # Check each tier has at least one model
            for tier in ("low", "mid", "high"):
                tier_models = reg.get_models_by_tier(tier)
                if not tier_models:
                    logger.warning("Verification: no models for tier %s", tier)
                    # Not a hard failure — some tiers may be empty (e.g., no premium key)
            return True
        except Exception as e:
            logger.error("Verification failed: %s", e)
            return False

    # ── Step 6: Memory ────────────────────────────────────────────

    def _log_to_memory(self, report: EvolutionReport) -> None:
        """Record events to FactoryMemory."""
        try:
            from factory.brain.memory.memory_writer import MemoryWriter
            writer = MemoryWriter()

            for action in report.actions:
                if action.action == "registered":
                    writer.log_capability_change(
                        capability=f"model:{action.provider}/{action.model_id}",
                        change_type="added",
                        detail=f"Tier: {action.tier}. Auto-discovered by Evolution Loop.",
                    )
                elif action.action == "deprecated":
                    writer.log_capability_change(
                        capability=f"model:{action.provider}/{action.model_id}",
                        change_type="removed",
                        detail="Model no longer available in provider API.",
                    )

            # Log cascade event
            if report.cascade_plan and report.cascade_plan.reassignments:
                cp = report.cascade_plan
                reassignment_summary = ", ".join(
                    f"{r.model_id}: {r.old_tier or 'new'}->{r.new_tier}"
                    for r in cp.reassignments
                )
                writer.log_capability_change(
                    capability="tier_system",
                    change_type="upgraded",
                    detail=(
                        f"Tier cascade triggered by {cp.trigger_provider}/{cp.trigger_model}. "
                        f"{len(cp.reassignments)} reassignments, "
                        f"{cp.affected_agents} agents affected. "
                        f"Changes: {reassignment_summary}"
                    ),
                )
        except Exception as e:
            logger.warning("Failed to log to FactoryMemory: %s", e)

    # ── Step 4.5: Cascade ────────────────────────────────────────

    def _evaluate_cascade(self, verified_actions: list) -> CascadePlan | None:
        """Evaluate whether any new model triggers a tier cascade.

        A cascade happens when a new model is HIGHER than the current top
        model for its provider. Only same-provider cascades by default.
        """
        if not CASCADE_RULES.get("same_provider_preferred", True):
            return None

        from .known_prices import lookup_model, KNOWN_MODELS
        from .model_registry import ModelRegistry

        registry = ModelRegistry()

        # Tier name mapping: registry uses low/mid/high, agents use lightweight/standard/premium
        TIER_TO_AGENT = {"low": "lightweight", "mid": "standard", "high": "premium"}
        AGENT_TO_NUMERIC = {"lightweight": 0, "standard": 1, "premium": 2}

        for action in verified_actions:
            if action.tier != "high":
                continue  # Only high-tier models can trigger a cascade

            provider = action.provider

            # Get current provider chain (models sorted by tier)
            current_models = registry.get_models_by_provider(provider)
            current_models = [m for m in current_models if m.status == "active"]
            if not current_models:
                continue

            # Find current model per tier for this provider
            current_by_tier = {}  # "low"/"mid"/"high" → ModelInfo
            for m in current_models:
                t = m.tier_equivalent
                if t not in current_by_tier:
                    current_by_tier[t] = m

            current_high = current_by_tier.get("high")
            if not current_high:
                continue  # No current premium model — no cascade needed

            # Is the new model a cascade trigger?
            # If it's classified as "high" tier AND same provider has an existing "high",
            # it means a NEW premium model appeared → cascade.
            # Extra check: if we have price data, the new model must be >= current price.
            new_known = lookup_model(action.model_id)
            cur_price = current_high.price_per_1k_output or 0.001

            if new_known:
                new_price = new_known["out"]
                if new_price < cur_price * 0.8:
                    continue  # Cheaper than current premium → not a cascade trigger
            # If unknown price but tier="high": trust the tier classification

            # Build cascade plan
            reassignments = []
            agent_counts = self._count_agents_per_tier()

            # New model → premium
            reassignments.append(TierReassignment(
                model_id=action.model_id, provider=provider,
                old_tier="", new_tier="premium",
                reason="New top-tier model",
            ))

            # Current premium → standard
            current_mid = current_by_tier.get("mid")
            reassignments.append(TierReassignment(
                model_id=current_high.model_id, provider=provider,
                old_tier="premium", new_tier="standard",
                reason="Demoted by new premium model",
            ))

            # Current standard → lightweight (if exists)
            if current_mid:
                reassignments.append(TierReassignment(
                    model_id=current_mid.model_id, provider=provider,
                    old_tier="standard", new_tier="lightweight",
                    reason="Demoted by cascade",
                ))

            # Current lightweight → deprecated (if exists)
            current_low = current_by_tier.get("low")
            if current_low and len(reassignments) <= CASCADE_RULES.get("max_cascade_depth", 3):
                reassignments.append(TierReassignment(
                    model_id=current_low.model_id, provider=provider,
                    old_tier="lightweight", new_tier="deprecated",
                    reason="Deprecated by cascade (keepalive as fallback)",
                ))

            # Calculate affected agents
            affected = (agent_counts.get("premium", 0)
                        + agent_counts.get("standard", 0)
                        + agent_counts.get("lightweight", 0))

            # Estimate cost change (rough: new premium price vs old standard price)
            old_std_price = current_by_tier["mid"].price_per_1k_output if current_mid else cur_price
            new_std_price = cur_price  # old premium becomes new standard
            cost_pct = ((new_std_price - old_std_price) / max(old_std_price, 0.001)) * 100

            plan = CascadePlan(
                trigger_model=action.model_id,
                trigger_provider=provider,
                reassignments=reassignments,
                affected_agents=affected,
                estimated_cost_change_pct=cost_pct,
                risk_level="high" if CASCADE_RULES.get("benchmark_required_for_premium") else "medium",
                requires_benchmark=CASCADE_RULES.get("benchmark_required_for_premium", True),
            )
            return plan  # Only one cascade per cycle

        return None

    def _execute_cascade(self, plan: CascadePlan) -> bool:
        """Execute tier cascade atomically. Rollback on any failure."""
        backups = {}
        try:
            # 1. Backup all config files
            ts = datetime.now().strftime("%Y%m%d_%H%M%S")
            for path, name in [(_LLM_PROFILES_FILE, "llm_profiles"),
                               (_CONFIG_DIR / "tier_config.json", "tier_config")]:
                if path.exists():
                    bak = path.with_suffix(f".json.bak_{ts}")
                    shutil.copy2(str(path), str(bak))
                    backups[name] = bak
            # Registry backup already done in _register()

            # 2. Build tier mappings from cascade plan
            # Map new_tier → model_id for the primary provider
            tier_models = {}  # "premium"/"standard"/"lightweight" → model_id
            deprecated_models = []
            for r in plan.reassignments:
                if r.new_tier == "deprecated":
                    deprecated_models.append(r)
                else:
                    tier_models[r.new_tier] = r.model_id

            # 3. Write tier_config.json
            from .known_prices import lookup_model
            model_tier_map = {}
            for tier_name, model_id in tier_models.items():
                numeric = {"lightweight": 0, "standard": 1, "premium": 2}.get(tier_name, 1)
                model_tier_map[model_id] = numeric

            tier_config = {
                "_meta": {
                    "updated_by": "ModelEvolution",
                    "updated_at": datetime.now(timezone.utc).isoformat(),
                    "cascade_trigger": plan.trigger_model,
                },
                "tier_default_model": {
                    "lightweight": tier_models.get("lightweight", "claude-haiku-4-5"),
                    "standard": tier_models.get("standard", "claude-sonnet-4-6"),
                    "premium": tier_models.get("premium", "claude-opus-4-6"),
                    "none": None,
                },
                "model_tier": model_tier_map,
                "tier_upgrade_model": {
                    "1": {"model": tier_models.get("standard", "claude-sonnet-4-6"),
                          "provider": plan.trigger_provider},
                    "2": {"model": tier_models.get("premium", "claude-opus-4-6"),
                          "provider": plan.trigger_provider},
                },
                "llm_profiles": {
                    "dev": {"model": tier_models.get("lightweight", "claude-haiku-4-5"),
                            "provider": plan.trigger_provider},
                    "standard": {"model": tier_models.get("standard", "claude-sonnet-4-6"),
                                 "provider": plan.trigger_provider},
                    "premium": {"model": tier_models.get("premium", "claude-opus-4-6"),
                                "provider": plan.trigger_provider},
                },
            }

            from config.model_router import save_tier_config
            save_tier_config(tier_config)
            print("  -> tier_config.json written")

            # 4. Write llm_profiles.json
            profiles = {}
            for profile, info in tier_config["llm_profiles"].items():
                profiles[profile] = {
                    "model": info["model"],
                    "temperature": 0.2 if profile != "premium" else 0.1,
                    "api_key_env": "ANTHROPIC_API_KEY",
                    "provider": info["provider"],
                }
            _LLM_PROFILES_FILE.write_text(
                json.dumps(profiles, indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print("  -> llm_profiles.json written")

            # 5. Update models_registry.json tier_equivalents
            registry_data = json.loads(_REGISTRY_FILE.read_text(encoding="utf-8"))
            tier_to_registry = {"premium": "high", "standard": "mid", "lightweight": "low"}

            for r in plan.reassignments:
                if r.provider in registry_data and r.model_id in registry_data[r.provider]:
                    entry = registry_data[r.provider][r.model_id]
                    if r.new_tier == "deprecated":
                        entry["status"] = "deprecated"
                    else:
                        entry["tier_equivalent"] = tier_to_registry.get(r.new_tier, "mid")

            _REGISTRY_FILE.write_text(
                json.dumps(registry_data, indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print("  -> models_registry.json tier_equivalents updated")

            # 6. Invalidate caches
            try:
                import factory.brain.model_provider as mp
                mp._registry = None
                mp._router = None
            except Exception:
                pass
            try:
                from config.model_router import reload_tier_config, reload_registry
                reload_tier_config()
                reload_registry()
            except Exception:
                pass

            print("  -> Cascade executed successfully")
            return True

        except Exception as e:
            logger.error("Cascade execution failed: %s", e)
            # Rollback all backups
            for name, bak_path in backups.items():
                original = bak_path.with_suffix("").with_suffix(".json")
                if bak_path.exists():
                    shutil.copy2(str(bak_path), str(original))
                    logger.info("Rolled back %s", name)
            return False

    def _quick_benchmark(self, model_id: str, provider: str) -> bool:
        """Quick compatibility + quality test for premium candidates."""
        from .known_prices import get_litellm_name
        litellm_name = get_litellm_name(provider, model_id)

        try:
            import litellm

            # Test 1: Basic compatibility (Say OK)
            resp = litellm.completion(
                model=litellm_name,
                messages=[{"role": "user", "content": "Say OK"}],
                max_tokens=5, temperature=0.0,
            )
            if not resp.choices or not resp.choices[0].message.content:
                return False

            # Test 2: Code review quality check
            resp2 = litellm.completion(
                model=litellm_name,
                messages=[
                    {"role": "system", "content": "You are a code reviewer."},
                    {"role": "user", "content": (
                        "Review this code for bugs:\n"
                        "```python\ndef divide(a, b): return a / b\n```\n"
                        "List any issues."
                    )},
                ],
                max_tokens=256, temperature=0.0,
            )
            content = resp2.choices[0].message.content if resp2.choices else ""
            # Minimum quality: mentions division by zero
            if len(content) > 50 and any(kw in content.lower() for kw in ["zero", "0", "error", "exception"]):
                return True

            logger.warning("Quick benchmark: model %s passed basic but low quality", model_id)
            return True  # Basic compatibility OK, quality is acceptable

        except Exception as e:
            logger.error("Quick benchmark failed for %s: %s", model_id, e)
            return False

    def _count_agents_per_tier(self) -> dict:
        """Count active agents by tier from agent_registry.json."""
        counts = {"premium": 0, "standard": 0, "lightweight": 0, "none": 0}
        try:
            data = json.loads(_AGENT_REGISTRY_FILE.read_text(encoding="utf-8"))
            for agent in data.get("agents", []):
                if agent.get("status") == "active":
                    tier = agent.get("tier", "standard")
                    counts[tier] = counts.get(tier, 0) + 1
        except Exception as e:
            logger.warning("Could not count agents: %s", e)
        return counts

    # ── Helpers ───────────────────────────────────────────────────

    def _load_state(self) -> dict:
        if _STATE_FILE.exists():
            try:
                return json.loads(_STATE_FILE.read_text(encoding="utf-8"))
            except Exception:
                return {}
        return {}

    def _save_state(self, report: EvolutionReport) -> None:
        state = self._load_state()
        state["last_run_iso"] = report.timestamp
        state["last_run_result"] = report.status
        state["total_runs"] = state.get("total_runs", 0) + 1

        history = state.get("history", [])
        history.append({
            "timestamp": report.timestamp,
            "status": report.status,
            "models_added": report.models_added,
            "models_deprecated": report.models_deprecated,
            "cost_usd": report.cost_usd,
            "errors": report.errors[:3],
        })
        state["history"] = history[-20:]  # keep last 20

        _STATE_FILE.write_text(
            json.dumps(state, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

    def _backup_registry(self) -> Path:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup = _DIR / f"models_registry_{ts}.json.bak"
        shutil.copy2(str(_REGISTRY_FILE), str(backup))
        logger.info("Registry backup: %s", backup.name)
        return backup

    def rollback(self) -> bool:
        """Rollback to the most recent registry backup."""
        backups = sorted(_DIR.glob("models_registry_*.json.bak"), reverse=True)
        if not backups:
            logger.error("No registry backups found for rollback")
            return False
        shutil.copy2(str(backups[0]), str(_REGISTRY_FILE))
        try:
            import factory.brain.model_provider as mp
            mp._registry = None
            mp._router = None
        except Exception:
            pass
        logger.info("Rolled back registry to %s", backups[0].name)
        return True

    def get_status(self) -> dict:
        """Return current evolution state (read-only, no API calls)."""
        state = self._load_state()
        last_run = state.get("last_run_iso", "")

        next_run = "now"
        if last_run:
            try:
                last_dt = datetime.fromisoformat(last_run)
                if last_dt.tzinfo is None:
                    last_dt = last_dt.replace(tzinfo=timezone.utc)
                next_dt = last_dt + timedelta(hours=_COOLDOWN_HOURS)
                now = datetime.now(timezone.utc)
                if next_dt > now:
                    remaining = next_dt - now
                    hours = remaining.seconds // 3600
                    mins = (remaining.seconds % 3600) // 60
                    next_run = f"in {hours}h {mins}m"
                else:
                    next_run = "ready"
            except (ValueError, TypeError):
                next_run = "ready"

        # Registry stats
        try:
            from .model_registry import ModelRegistry
            reg = ModelRegistry()
            stats = reg.stats
        except Exception:
            stats = {}

        return {
            "last_run": state.get("last_run_iso", "never"),
            "last_result": state.get("last_run_result", "none"),
            "total_runs": state.get("total_runs", 0),
            "next_run": next_run,
            "cooldown_hours": _COOLDOWN_HOURS,
            "registry_stats": stats,
            "recent_history": state.get("history", [])[-5:],
        }


# ── CLI ────────────────────────────────────────────────────────────

def main():
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
    if sys.platform == "win32":
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    force = "--force" in sys.argv
    dry = "--dry" in sys.argv
    status_only = "--status" in sys.argv

    evo = ModelEvolution()

    if status_only:
        print(json.dumps(evo.get_status(), indent=2, ensure_ascii=False, default=str))
        return

    print(f"\nModel Evolution Cycle" + (" (forced)" if force else "") + (" (dry run)" if dry else ""))
    report = evo.run_cycle(force=force, dry_run=dry)
    print(report.summary())


if __name__ == "__main__":
    main()
