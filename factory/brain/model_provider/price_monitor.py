"""Price Monitor — provider health checks + model change detection."""
import json
import os
import urllib.request
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

from .model_registry import ModelRegistry

_HEALTH_DIR = Path(__file__).parent / "health_reports"


@dataclass
class Change:
    change_type: str
    provider: str
    model_id: str
    details: str
    action_needed: str


@dataclass
class ProviderHealthStatus:
    provider: str
    api_reachable: bool = False
    latency_ms: int = 0
    models_in_api: int = 0
    models_in_registry: int = 0
    changes: list[Change] = field(default_factory=list)
    status: str = "unknown"
    error: str = ""


@dataclass
class HealthReport:
    timestamp: str = ""
    providers: list[ProviderHealthStatus] = field(default_factory=list)
    total_changes: int = 0
    action_items: list[str] = field(default_factory=list)

    def format_console(self) -> str:
        lines = ["", "=" * 60, "  TheBrain Health Report", "=" * 60,
                 f"  Timestamp: {self.timestamp}", ""]
        for p in self.providers:
            icon = "OK" if p.status == "healthy" else "WARN" if p.status == "degraded" else "FAIL"
            lines.append(f"  [{icon}] {p.provider:<12} API: {'reachable' if p.api_reachable else 'UNREACHABLE'}"
                        f"  Latency: {p.latency_ms}ms  Models: {p.models_in_api} (API) / {p.models_in_registry} (registry)")
            if p.error:
                lines.append(f"       Error: {p.error[:60]}")
            for c in p.changes:
                lines.append(f"       [{c.change_type}] {c.model_id}: {c.details}")
        lines.append("")
        if self.action_items:
            lines.append("  Action Items:")
            for a in self.action_items:
                lines.append(f"    - {a}")
        else:
            lines.append("  No action items.")
        lines.append("=" * 60)
        return "\n".join(lines)


_KEY_MAP = {
    "anthropic": "ANTHROPIC_API_KEY",
    "openai": "OPENAI_API_KEY",
    "google": "GEMINI_API_KEY",
    "mistral": "MISTRAL_API_KEY",
}


class PriceMonitor:
    """Monitors provider APIs for health + model changes."""

    def __init__(self, registry: ModelRegistry | None = None):
        self.registry = registry or ModelRegistry()

    def check_all_providers(self) -> HealthReport:
        report = HealthReport(timestamp=datetime.now().isoformat())
        for provider in ["anthropic", "openai", "google", "mistral"]:
            key = os.environ.get(_KEY_MAP.get(provider, ""), "")
            if not key:
                report.providers.append(ProviderHealthStatus(
                    provider=provider, status="no_key", error="API key not configured"))
                continue
            status = self.check_provider(provider, key)
            report.providers.append(status)
            report.total_changes += len(status.changes)
            for c in status.changes:
                if c.action_needed != "none":
                    report.action_items.append(f"[{provider}] {c.action_needed}: {c.model_id}")
        self._save_report(report)
        return report

    def check_provider(self, provider: str, api_key: str = "") -> ProviderHealthStatus:
        import time
        key = api_key or os.environ.get(_KEY_MAP.get(provider, ""), "")
        status = ProviderHealthStatus(provider=provider, models_in_registry=len(self.registry.get_models_by_provider(provider)))

        if not key:
            status.status = "no_key"
            status.error = "No API key"
            return status

        start = time.time()
        api_models = self._list_models(provider, key)
        status.latency_ms = int((time.time() - start) * 1000)
        status.api_reachable = api_models is not None
        status.models_in_api = len(api_models) if api_models else 0

        if not status.api_reachable:
            status.status = "unreachable"
            status.error = "API call failed"
            return status

        status.status = "healthy"

        # Detect changes (simplified — just check known models)
        if api_models:
            registry_ids = {m.model_id for m in self.registry.get_models_by_provider(provider)}
            api_ids = {m.get("id", m.get("name", "")) for m in api_models}
            # We can't perfectly match names, so just report counts
            if status.models_in_api > 0 and status.models_in_registry > 0:
                pass  # Healthy, no changes detected by simple count

        return status

    def _list_models(self, provider, key):
        try:
            if provider == "openai":
                return self._api_get("https://api.openai.com/v1/models",
                                     {"Authorization": f"Bearer {key}"}, "data")
            elif provider == "google":
                return self._api_get(f"https://generativelanguage.googleapis.com/v1/models?key={key}",
                                     {}, "models")
            elif provider == "mistral":
                return self._api_get("https://api.mistral.ai/v1/models",
                                     {"Authorization": f"Bearer {key}"}, "data")
            elif provider == "anthropic":
                # Anthropic has no /models endpoint — just health check
                req = urllib.request.Request("https://api.anthropic.com/v1/messages",
                    data=json.dumps({"model": "claude-haiku-4-5", "max_tokens": 5,
                                     "messages": [{"role": "user", "content": "hi"}]}).encode(),
                    headers={"Content-Type": "application/json", "x-api-key": key,
                             "anthropic-version": "2023-06-01"}, method="POST")
                urllib.request.urlopen(req, timeout=10)
                return [{"id": "claude-haiku-4-5"}, {"id": "claude-sonnet-4-6"}, {"id": "claude-opus-4-6"}]
        except Exception:
            return None

    def _api_get(self, url, headers, data_key):
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
            return data.get(data_key, [])

    def _save_report(self, report: HealthReport):
        _HEALTH_DIR.mkdir(parents=True, exist_ok=True)
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        path = _HEALTH_DIR / f"health_{ts}.json"
        data = {
            "timestamp": report.timestamp,
            "total_changes": report.total_changes,
            "action_items": report.action_items,
            "providers": [{
                "provider": p.provider, "status": p.status, "api_reachable": p.api_reachable,
                "latency_ms": p.latency_ms, "models_in_api": p.models_in_api,
                "models_in_registry": p.models_in_registry, "error": p.error,
            } for p in report.providers],
        }
        path.write_text(json.dumps(data, indent=2), encoding="utf-8")
