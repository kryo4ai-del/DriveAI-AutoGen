"""Base adapter interface for all external service adapters.

Every adapter (image, sound, video) inherits from BaseServiceAdapter
and implements generate(), health_check(), and get_capabilities().
"""

import logging
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Optional, Union

logger = logging.getLogger(__name__)


@dataclass
class ServiceResult:
    """Unified result from any external service call."""
    success: bool
    data: Optional[Union[bytes, str]] = None
    format: str = ""
    cost: float = 0.0
    duration_ms: int = 0
    service_id: str = ""
    metadata: dict = field(default_factory=dict)
    error_message: str = ""

    @staticmethod
    def failure(service_id: str, error: str, duration_ms: int = 0) -> "ServiceResult":
        return ServiceResult(
            success=False,
            service_id=service_id,
            error_message=error,
            duration_ms=duration_ms,
        )


class BaseServiceAdapter(ABC):
    """Abstract base class for all external service adapters."""

    def __init__(self, service_id: str, api_key: str):
        self._service_id = service_id
        self._api_key = api_key

    @property
    def service_id(self) -> str:
        return self._service_id

    @abstractmethod
    async def generate(self, prompt: str, specs: dict) -> ServiceResult:
        """Execute the generation request. Must not raise."""
        ...

    @abstractmethod
    def health_check(self) -> bool:
        """Check if service is reachable. Must not raise. Timeout 10s max."""
        ...

    @abstractmethod
    def get_capabilities(self) -> list[str]:
        """Return list of capability strings for this adapter."""
        ...

    def get_cost_estimate(self, specs: dict) -> float:
        """Estimate cost for a request. Override in subclass for accuracy."""
        return 0.0
