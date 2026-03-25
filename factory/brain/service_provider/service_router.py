"""Service Router — Intelligent routing of external service requests.

TheBrain is the BOSS — no Forge or Department decides which service to use.
The Router makes that decision based on capabilities, cost, quality, and budget.
"""

import logging
import os
from dataclasses import dataclass, field
from typing import Optional

from factory.brain.service_provider.adapters.base_adapter import BaseServiceAdapter, ServiceResult
from factory.brain.service_provider.service_registry import ServiceRegistry

logger = logging.getLogger(__name__)


@dataclass
class ServiceRequest:
    """A request for an external service."""
    category: str
    required_capabilities: list[str] = field(default_factory=list)
    specs: dict = field(default_factory=dict)
    budget_limit: Optional[float] = None
    preferred_service: Optional[str] = None
    quality_minimum: float = 0.0


@dataclass
class RoutingResult:
    """Result of a routing decision."""
    primary_adapter: BaseServiceAdapter
    fallback_adapter: Optional[BaseServiceAdapter]
    service_id: str
    estimated_cost: float
    routing_reason: str


class ServiceRouter:
    """Routes service requests to the best available adapter."""

    def __init__(self, registry: ServiceRegistry):
        self._registry = registry
        self._adapter_map: dict[str, type] = {}
        self._register_adapters()

    # ------------------------------------------------------------------
    # Adapter registration
    # ------------------------------------------------------------------

    def _register_adapters(self):
        try:
            from factory.brain.service_provider.adapters.image.dalle_adapter import DalleAdapter
            self._adapter_map["dalle3"] = DalleAdapter
        except ImportError:
            logger.warning("DalleAdapter not available")

        try:
            from factory.brain.service_provider.adapters.image.stability_adapter import StabilityAdapter
            self._adapter_map["stability_sdxl"] = StabilityAdapter
        except ImportError:
            logger.warning("StabilityAdapter not available")

        try:
            from factory.brain.service_provider.adapters.sound.elevenlabs_sfx_adapter import ElevenLabsSfxAdapter
            self._adapter_map["elevenlabs_sfx"] = ElevenLabsSfxAdapter
        except ImportError:
            logger.warning("ElevenLabsSfxAdapter not available")

        try:
            from factory.brain.service_provider.adapters.image.recraft_adapter import RecraftAdapter
            self._adapter_map["recraft_v3"] = RecraftAdapter
        except ImportError:
            logger.warning("RecraftAdapter not available")

        try:
            from factory.brain.service_provider.adapters.sound.suno_adapter import SunoAdapter
            self._adapter_map["suno_ai"] = SunoAdapter
        except ImportError:
            logger.warning("SunoAdapter not available")

        try:
            from factory.brain.service_provider.adapters.video.runway_adapter import RunwayAdapter
            self._adapter_map["runway_ml"] = RunwayAdapter
        except ImportError:
            logger.warning("RunwayAdapter not available")

        logger.info("ServiceRouter registered %d adapters: %s", len(self._adapter_map), list(self._adapter_map.keys()))

    def _create_adapter(self, service_id: str) -> Optional[BaseServiceAdapter]:
        adapter_cls = self._adapter_map.get(service_id)
        if adapter_cls is None:
            logger.warning("No adapter class for service '%s'", service_id)
            return None

        entry = self._registry.get_service(service_id)
        if entry is None:
            logger.warning("Service '%s' not in registry", service_id)
            return None

        api_key = os.environ.get(entry.api_key_env, "")
        if not api_key:
            logger.warning("API key %s not set for service '%s'", entry.api_key_env, service_id)
            return None

        return adapter_cls(api_key)

    # ------------------------------------------------------------------
    # Routing
    # ------------------------------------------------------------------

    def route(self, request: ServiceRequest) -> Optional[RoutingResult]:
        steps = []
        # 1. Active services in category
        active = self._registry.get_active_services(request.category)
        steps.append(f"{len(active)} active services in '{request.category}'")
        if not active:
            logger.warning("No active services for category '%s'", request.category)
            return None

        # 2. Filter by required capabilities
        if request.required_capabilities:
            required = set(request.required_capabilities)
            active = [s for s in active if required.issubset(set(s.capabilities))]
            steps.append(f"{len(active)} have required capabilities {request.required_capabilities}")
            if not active:
                logger.warning("No service has capabilities %s in category '%s'",
                               request.required_capabilities, request.category)
                return None

        # 3. Filter by budget
        candidates = []
        for s in active:
            cost = self._registry.get_cost_estimate(s.service_id, request.specs)
            if cost < 0:
                cost = 0.0
            if request.budget_limit is not None and cost > request.budget_limit:
                continue
            candidates.append((s, cost))

        if request.budget_limit is not None:
            steps.append(f"{len(candidates)} within budget ${request.budget_limit}")
        if not candidates:
            logger.warning("No service within budget $%.4f for '%s'", request.budget_limit or 0, request.category)
            return None

        # 4. Filter by quality minimum
        if request.quality_minimum > 0:
            candidates = [(s, c) for s, c in candidates if s.quality_score >= request.quality_minimum]
            steps.append(f"{len(candidates)} above quality {request.quality_minimum}")
            if not candidates:
                logger.warning("No service above quality %.1f", request.quality_minimum)
                return None

        # 5. Preferred service?
        if request.preferred_service:
            preferred = [(s, c) for s, c in candidates if s.service_id == request.preferred_service]
            if preferred:
                primary_entry, primary_cost = preferred[0]
                fallback = self._pick_fallback(candidates, primary_entry.service_id)
                reason = "preferred_service"
                steps.append(f"selected {primary_entry.service_id} (preferred)")
                return self._build_result(primary_entry.service_id, primary_cost, fallback, reason, steps)

        # 6. Score-based selection
        max_cost = max(c for _, c in candidates) if candidates else 1.0
        if max_cost == 0:
            max_cost = 1.0

        scored = []
        for s, cost in candidates:
            cost_eff = 1.0 - (cost / max_cost) if max_cost > 0 else 1.0
            score = s.quality_score * 0.6 + cost_eff * 10.0 * 0.4  # normalize cost_eff to ~0-10 range
            scored.append((s, cost, score))

        scored.sort(key=lambda x: -x[2])
        primary_entry, primary_cost, _ = scored[0]
        fallback_id = scored[1][0].service_id if len(scored) > 1 else None

        if len(candidates) == 1:
            reason = "only_option"
        elif all(s.quality_score == 0.0 for s, _ in candidates):
            reason = "cheapest_with_capabilities"
        else:
            reason = "highest_quality"

        steps.append(f"selected {primary_entry.service_id} ({reason})")

        return self._build_result(primary_entry.service_id, primary_cost, fallback_id, reason, steps)

    def _pick_fallback(self, candidates: list, exclude_id: str) -> Optional[str]:
        for s, _ in candidates:
            if s.service_id != exclude_id:
                return s.service_id
        return None

    def _build_result(self, primary_id: str, cost: float,
                      fallback_id: Optional[str], reason: str,
                      steps: list) -> Optional[RoutingResult]:
        primary = self._create_adapter(primary_id)
        if primary is None:
            logger.warning("Could not create adapter for '%s' (API key missing?), trying fallback", primary_id)
            if fallback_id:
                fallback_adapter = self._create_adapter(fallback_id)
                if fallback_adapter:
                    logger.info("Fallback to %s (primary %s had no key)", fallback_id, primary_id)
                    fb_cost = self._registry.get_cost_estimate(fallback_id, {})
                    return RoutingResult(
                        primary_adapter=fallback_adapter, fallback_adapter=None,
                        service_id=fallback_id, estimated_cost=fb_cost if fb_cost >= 0 else cost,
                        routing_reason=f"fallback_from_{primary_id}",
                    )
            return None

        fallback = self._create_adapter(fallback_id) if fallback_id else None

        logger.info("Routed to %s — reason: %s [%s]", primary_id, reason, " → ".join(steps))
        return RoutingResult(
            primary_adapter=primary,
            fallback_adapter=fallback,
            service_id=primary_id,
            estimated_cost=cost,
            routing_reason=reason,
        )

    # ------------------------------------------------------------------
    # Execute
    # ------------------------------------------------------------------

    async def route_and_execute(self, request: ServiceRequest) -> ServiceResult:
        routing = self.route(request)
        if routing is None:
            return ServiceResult.failure("none", f"No service available for {request.category}")

        prompt = request.specs.get("prompt", request.specs.get("text", ""))
        if not prompt:
            prompt = f"Generate {request.category} asset"

        result = await routing.primary_adapter.generate(prompt, request.specs)
        if result.success:
            return result

        if routing.fallback_adapter:
            logger.info("Primary %s failed, trying fallback %s",
                        routing.service_id, routing.fallback_adapter.service_id)
            fallback_result = await routing.fallback_adapter.generate(prompt, request.specs)
            return fallback_result

        return result

    # ------------------------------------------------------------------
    # Info
    # ------------------------------------------------------------------

    def get_available_services(self, category: str) -> list[dict]:
        active = self._registry.get_active_services(category)
        result = []
        for s in active:
            cost = self._registry.get_cost_estimate(s.service_id, {})
            result.append({
                "service_id": s.service_id,
                "name": s.name,
                "capabilities": s.capabilities,
                "estimated_cost": cost,
                "quality_score": s.quality_score,
                "has_adapter": s.service_id in self._adapter_map,
                "has_api_key": bool(os.environ.get(s.api_key_env, "")),
            })
        return result

    def explain_routing(self, request: ServiceRequest) -> str:
        lines = [f"Routing request: category={request.category}, "
                 f"capabilities={request.required_capabilities}, "
                 f"budget={request.budget_limit}, preferred={request.preferred_service}"]

        active = self._registry.get_active_services(request.category)
        lines.append(f"  Step 1: {len(active)} active services in '{request.category}': "
                     f"{[s.service_id for s in active]}")
        if not active:
            lines.append("  → RESULT: None (no active services)")
            return "\n".join(lines)

        if request.required_capabilities:
            required = set(request.required_capabilities)
            filtered = [s for s in active if required.issubset(set(s.capabilities))]
            lines.append(f"  Step 2: {len(filtered)} have capabilities {request.required_capabilities}: "
                         f"{[s.service_id for s in filtered]}")
            active = filtered
            if not active:
                lines.append("  → RESULT: None (no capability match)")
                return "\n".join(lines)

        candidates = []
        for s in active:
            cost = self._registry.get_cost_estimate(s.service_id, request.specs)
            if cost < 0:
                cost = 0.0
            candidates.append((s, cost))

        if request.budget_limit is not None:
            before = len(candidates)
            candidates = [(s, c) for s, c in candidates if c <= request.budget_limit]
            lines.append(f"  Step 3: {len(candidates)}/{before} within budget ${request.budget_limit}: "
                         f"{[s.service_id for s, _ in candidates]}")
            if not candidates:
                lines.append("  → RESULT: None (budget too low)")
                return "\n".join(lines)

        if request.quality_minimum > 0:
            before = len(candidates)
            candidates = [(s, c) for s, c in candidates if s.quality_score >= request.quality_minimum]
            lines.append(f"  Step 4: {len(candidates)}/{before} above quality {request.quality_minimum}")

        if request.preferred_service:
            match = [s for s, _ in candidates if s.service_id == request.preferred_service]
            if match:
                lines.append(f"  Step 5: preferred_service '{request.preferred_service}' found and eligible")
                lines.append(f"  → RESULT: {request.preferred_service} (preferred_service)")
                return "\n".join(lines)
            else:
                lines.append(f"  Step 5: preferred_service '{request.preferred_service}' not eligible, scoring...")

        costs_str = ", ".join(f"{s.service_id}=${c:.3f}" for s, c in candidates)
        lines.append(f"  Step 6: Cost estimates: {costs_str}")

        if candidates:
            # Same scoring as route()
            max_cost = max(c for _, c in candidates) or 1.0
            scored = []
            for s, cost in candidates:
                cost_eff = 1.0 - (cost / max_cost) if max_cost > 0 else 1.0
                score = s.quality_score * 0.6 + cost_eff * 10.0 * 0.4
                scored.append((s.service_id, score, cost))
            scored.sort(key=lambda x: -x[1])
            scores_str = ", ".join(f"{sid}={sc:.2f}" for sid, sc, _ in scored)
            lines.append(f"  Step 7: Scores (quality*0.6 + cost_eff*0.4): {scores_str}")
            lines.append(f"  → RESULT: {scored[0][0]} (score={scored[0][1]:.2f}, cost=${scored[0][2]:.3f})")
        else:
            lines.append("  → RESULT: None")

        return "\n".join(lines)
