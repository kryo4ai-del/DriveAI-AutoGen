"""Service Registry — Central database of all external services.

JSON-based registry for image, sound, animation, and video services.
Provides CRUD operations, validation, and cost estimation.
"""

import json
import os
import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Optional
from datetime import date

logger = logging.getLogger(__name__)

REGISTRY_DEFAULT_PATH = str(Path(__file__).parent.parent / "service_registry.json")

REQUIRED_ADD_FIELDS = {"name", "category", "provider", "api_key_env", "capabilities"}


@dataclass
class ServiceEntry:
    """Represents a single external service."""
    service_id: str
    name: str
    category: str
    provider: str
    api_base: str
    api_key_env: str
    status: str
    capabilities: list
    cost_per_call: dict
    quality_score: float
    rate_limit: dict
    added_date: str
    last_health_check: Optional[str]
    notes: str


class ServiceRegistry:
    """Central database of all external services. JSON-based."""

    def __init__(self, registry_path: str = None):
        self._path = registry_path or REGISTRY_DEFAULT_PATH
        self._data = self._load()

    # ------------------------------------------------------------------
    # Internal I/O
    # ------------------------------------------------------------------

    def _load(self) -> dict:
        try:
            with open(self._path, "r", encoding="utf-8") as f:
                return json.load(f)
        except FileNotFoundError:
            logger.warning("Service registry not found at %s — starting empty", self._path)
            return {"services": {}, "categories": {}}
        except json.JSONDecodeError as e:
            logger.error("Failed to parse service registry: %s", e)
            return {"services": {}, "categories": {}}

    def _save(self):
        try:
            with open(self._path, "w", encoding="utf-8") as f:
                json.dump(self._data, f, indent=2, ensure_ascii=False)
        except OSError as e:
            logger.error("Failed to save service registry: %s", e)

    def _to_entry(self, service_id: str, raw: dict) -> ServiceEntry:
        return ServiceEntry(
            service_id=service_id,
            name=raw.get("name", ""),
            category=raw.get("category", ""),
            provider=raw.get("provider", ""),
            api_base=raw.get("api_base", ""),
            api_key_env=raw.get("api_key_env", ""),
            status=raw.get("status", "inactive"),
            capabilities=raw.get("capabilities", []),
            cost_per_call=raw.get("cost_per_call", {}),
            quality_score=raw.get("quality_score", 0.0),
            rate_limit=raw.get("rate_limit", {}),
            added_date=raw.get("added_date", ""),
            last_health_check=raw.get("last_health_check"),
            notes=raw.get("notes", ""),
        )

    # ------------------------------------------------------------------
    # Read
    # ------------------------------------------------------------------

    def get_service(self, service_id: str) -> Optional[ServiceEntry]:
        raw = self._data.get("services", {}).get(service_id)
        if raw is None:
            return None
        return self._to_entry(service_id, raw)

    def get_all_services(self) -> list[ServiceEntry]:
        return [
            self._to_entry(sid, raw)
            for sid, raw in self._data.get("services", {}).items()
        ]

    def get_active_services(self, category: str) -> list[ServiceEntry]:
        return [
            self._to_entry(sid, raw)
            for sid, raw in self._data.get("services", {}).items()
            if raw.get("status") == "active" and raw.get("category") == category
        ]

    def get_capabilities(self, service_id: str) -> list[str]:
        raw = self._data.get("services", {}).get(service_id)
        if raw is None:
            return []
        return raw.get("capabilities", [])

    def is_active(self, service_id: str) -> bool:
        raw = self._data.get("services", {}).get(service_id)
        if raw is None:
            return False
        return raw.get("status") == "active"

    # ------------------------------------------------------------------
    # Write
    # ------------------------------------------------------------------

    def activate(self, service_id: str) -> bool:
        raw = self._data.get("services", {}).get(service_id)
        if raw is None:
            logger.warning("activate: service '%s' not found", service_id)
            return False
        key_env = raw.get("api_key_env", "")
        key_val = os.environ.get(key_env, "")
        if not key_val:
            logger.warning(
                "activate: cannot activate '%s' — env var %s is missing or empty",
                service_id, key_env,
            )
            return False
        raw["status"] = "active"
        self._save()
        return True

    def deactivate(self, service_id: str) -> bool:
        raw = self._data.get("services", {}).get(service_id)
        if raw is None:
            logger.warning("deactivate: service '%s' not found", service_id)
            return False
        raw["status"] = "inactive"
        self._save()
        return True

    def add_service(self, service_data: dict) -> bool:
        sid = service_data.get("service_id", "")
        if not sid:
            logger.warning("add_service: missing service_id")
            return False
        if sid in self._data.get("services", {}):
            logger.warning("add_service: '%s' already exists", sid)
            return False
        missing = REQUIRED_ADD_FIELDS - set(service_data.keys())
        if missing:
            logger.warning("add_service: missing fields %s", missing)
            return False

        entry = {
            "name": service_data["name"],
            "category": service_data["category"],
            "provider": service_data["provider"],
            "api_base": service_data.get("api_base", ""),
            "api_key_env": service_data["api_key_env"],
            "status": "inactive",
            "capabilities": service_data["capabilities"],
            "cost_per_call": service_data.get("cost_per_call", {}),
            "quality_score": 0.0,
            "rate_limit": service_data.get("rate_limit", {}),
            "added_date": date.today().isoformat(),
            "last_health_check": None,
            "notes": service_data.get("notes", ""),
        }
        self._data.setdefault("services", {})[sid] = entry
        self._save()
        return True

    def update_quality_score(self, service_id: str, score: float) -> bool:
        raw = self._data.get("services", {}).get(service_id)
        if raw is None:
            return False
        raw["quality_score"] = max(0.0, min(10.0, score))
        self._save()
        return True

    def update_health_check(self, service_id: str, healthy: bool):
        raw = self._data.get("services", {}).get(service_id)
        if raw is None:
            return
        now = date.today().isoformat()
        raw["last_health_check"] = now
        if not healthy:
            logger.warning("Health check FAILED for service '%s'", service_id)
        self._save()

    # ------------------------------------------------------------------
    # Cost
    # ------------------------------------------------------------------

    def get_cost_estimate(self, service_id: str, request_specs: dict = None) -> float:
        raw = self._data.get("services", {}).get(service_id)
        if raw is None:
            return -1.0
        costs = raw.get("cost_per_call", {})
        if not costs:
            return -1.0
        if request_specs is None:
            request_specs = {}

        # Try exact match on 'size' (images)
        size = request_specs.get("size", "")
        if size and size in costs:
            return costs[size]

        # Try exact match on 'duration' (video)
        duration = request_specs.get("duration", "")
        if duration and duration in costs:
            return costs[duration]

        # Try exact match on 'format' (svg etc)
        fmt = request_specs.get("format", "")
        if fmt and fmt in costs:
            return costs[fmt]

        # Fallback: return lowest cost value
        try:
            return min(costs.values())
        except (ValueError, TypeError):
            return -1.0

    # ------------------------------------------------------------------
    # Categories
    # ------------------------------------------------------------------

    def get_category(self, category_name: str) -> Optional[dict]:
        return self._data.get("categories", {}).get(category_name)

    def get_categories(self) -> list[str]:
        return list(self._data.get("categories", {}).keys())
