"""
DriveAI Mac Factory — LLM Client

Routes LLM requests through TheBrain on Windows (HTTP).
Falls back to direct litellm calls when Windows is unreachable.
Reports costs to Windows when connection is available.
"""

import os
import json
import time
from pathlib import Path
from dataclasses import dataclass
from datetime import datetime, timezone


@dataclass
class LLMResponse:
    text: str = ""
    model: str = ""
    cost: float = 0.0
    tokens_in: int = 0
    tokens_out: int = 0
    source: str = ""      # "thebrain" or "local"
    success: bool = False
    error: str = ""


class MacLLMClient:
    """
    LLM Client with TheBrain routing + local fallback.

    Priority:
    1. TheBrain on Windows (HTTP) — central cost tracking
    2. Direct litellm call — if Windows unreachable
    """

    def __init__(self, brain_url: str = None, default_model: str = "claude-sonnet-4-6",
                 safety_guard=None):
        self.brain_url = brain_url or os.environ.get("THEBRAIN_URL", "")

        if not self.brain_url:
            config_path = Path(__file__).parent / "config.yaml"
            if config_path.exists():
                try:
                    import yaml
                    with open(config_path) as f:
                        cfg = yaml.safe_load(f)
                    self.brain_url = cfg.get("thebrain_url", "")
                except Exception:
                    pass

        self.default_model = default_model
        self.safety_guard = safety_guard
        self.brain_available = None
        self.last_brain_check = 0
        self.brain_check_interval = 60

        self.unreported_costs = []
        self.unreported_costs_file = Path(__file__).parent / "costs" / "unreported.json"
        self._load_unreported()

    def completion(self, prompt: str, task_type: str = "code_generation",
                   model: str = "", max_tokens: int = 4000,
                   temperature: float = 0.0, project: str = "") -> LLMResponse:
        if self.safety_guard and not self.safety_guard.check():
            return LLMResponse(
                success=False,
                error=f"Safety guard stopped: {self.safety_guard.stop_reason}"
            )

        use_model = model or self.default_model

        if self.brain_url and self._is_brain_available():
            response = self._call_thebrain(prompt, task_type, use_model, max_tokens, temperature, project)
            if response.success:
                self._record_cost(response, "thebrain")
                return response

        response = self._call_litellm(prompt, use_model, max_tokens, temperature)
        if response.success:
            self._record_cost(response, "local")
            self._queue_cost_report(response, project)

        return response

    def _call_thebrain(self, prompt: str, task_type: str, model: str,
                       max_tokens: int, temperature: float, project: str) -> LLMResponse:
        try:
            import requests
            resp = requests.post(
                f"{self.brain_url}/brain/completion",
                json={
                    "prompt": prompt,
                    "task_type": task_type,
                    "model": model,
                    "max_tokens": max_tokens,
                    "temperature": temperature,
                    "project": project,
                    "source": "mac"
                },
                timeout=120
            )
            if resp.status_code == 200:
                data = resp.json()
                return LLMResponse(
                    text=data.get("response", ""),
                    model=data.get("model", model),
                    cost=data.get("cost", 0.0),
                    tokens_in=data.get("tokens_in", 0),
                    tokens_out=data.get("tokens_out", 0),
                    source="thebrain",
                    success=True
                )
            return LLMResponse(
                success=False, source="thebrain",
                error=f"HTTP {resp.status_code}: {resp.text[:200]}"
            )
        except Exception as e:
            # Catches ConnectionError, Timeout, ImportError (no requests)
            self.brain_available = False
            self.last_brain_check = time.time()
            print(f"[LLM Client] TheBrain unreachable - falling back to local")
            return LLMResponse(success=False, source="thebrain", error=str(e))

    def _call_litellm(self, prompt: str, model: str, max_tokens: int,
                      temperature: float) -> LLMResponse:
        try:
            import litellm
            response = litellm.completion(
                model=model,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=max_tokens,
                temperature=temperature
            )
            cost = litellm.completion_cost(response) or 0.0
            return LLMResponse(
                text=response.choices[0].message.content,
                model=response.model or model,
                cost=cost,
                tokens_in=response.usage.prompt_tokens,
                tokens_out=response.usage.completion_tokens,
                source="local",
                success=True
            )
        except Exception as e:
            return LLMResponse(success=False, source="local", error=str(e))

    def _is_brain_available(self) -> bool:
        now = time.time()
        if self.brain_available is not None and (now - self.last_brain_check) < self.brain_check_interval:
            return self.brain_available

        try:
            import requests
            resp = requests.get(f"{self.brain_url}/brain/status", timeout=5)
            self.brain_available = resp.status_code == 200
        except Exception:
            self.brain_available = False

        self.last_brain_check = now

        if self.brain_available and self.unreported_costs:
            self._flush_unreported_costs()

        return self.brain_available

    def _record_cost(self, response: LLMResponse, source: str):
        if self.safety_guard and response.cost > 0:
            self.safety_guard.record_llm_call(
                response.model, response.tokens_in, response.tokens_out, response.cost
            )

    def _queue_cost_report(self, response: LLMResponse, project: str):
        self.unreported_costs.append({
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "model": response.model,
            "cost": response.cost,
            "tokens_in": response.tokens_in,
            "tokens_out": response.tokens_out,
            "project": project
        })
        self._save_unreported()

    def _flush_unreported_costs(self):
        if not self.unreported_costs or not self.brain_url:
            return
        try:
            import requests
        except ImportError:
            return

        flushed = 0
        for entry in list(self.unreported_costs):
            try:
                requests.post(
                    f"{self.brain_url}/brain/report_cost",
                    json={
                        "source": "mac",
                        "model": entry.get("model", ""),
                        "cost": entry.get("cost", 0),
                        "tokens_in": entry.get("tokens_in", 0),
                        "tokens_out": entry.get("tokens_out", 0),
                        "job_id": entry.get("project", ""),
                        "timestamp": entry.get("timestamp", "")
                    },
                    timeout=10
                )
                flushed += 1
            except Exception:
                break

        if flushed > 0:
            self.unreported_costs = self.unreported_costs[flushed:]
            self._save_unreported()
            print(f"[LLM Client] Flushed {flushed} cost reports to Windows")

    def _load_unreported(self):
        if self.unreported_costs_file.exists():
            try:
                with open(self.unreported_costs_file) as f:
                    self.unreported_costs = json.load(f)
            except Exception:
                self.unreported_costs = []

    def _save_unreported(self):
        self.unreported_costs_file.parent.mkdir(parents=True, exist_ok=True)
        try:
            with open(self.unreported_costs_file, "w") as f:
                json.dump(self.unreported_costs, f, indent=2)
        except Exception:
            pass

    def get_status(self) -> dict:
        return {
            "brain_url": self.brain_url or "not configured",
            "brain_available": self.brain_available,
            "unreported_costs": len(self.unreported_costs),
            "default_model": self.default_model
        }
