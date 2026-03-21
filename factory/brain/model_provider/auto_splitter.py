"""Auto-Splitter — manages token limits across providers.
When expected output exceeds model limits: split, switch model, or pass through."""
import json as _json
from dataclasses import dataclass, field
from pathlib import Path

from .model_registry import ModelRegistry, ModelInfo

try:
    from .provider_router import ProviderRouter, ProviderResponse
except ImportError:
    ProviderRouter = None
    ProviderResponse = None


@dataclass
class SplitStrategy:
    should_split: bool = False
    reason: str = ""
    call_count: int = 1
    tokens_per_call: int = 0
    alternative_model: str | None = None
    alternative_provider: str | None = None
    merge_strategy: str = "json_concat"


class AutoSplitter:
    """Manages token limits across providers. Decides: split, switch model, or pass through."""

    def __init__(self, registry: ModelRegistry | None = None):
        self.registry = registry or ModelRegistry()

    def analyze(self,
                model_id: str,
                provider: str,
                expected_output_tokens: int,
                content_type: str = "code",
                ) -> SplitStrategy:
        """Analyze whether splitting is needed.

        Decision tree:
        1. Expected output <= model max? -> No split
        2. Cheaper model with higher output limit? -> Switch model
        3. Neither? -> Split into N calls
        """
        model_info = self.registry.get_model(model_id)
        if not model_info:
            return SplitStrategy(reason="unknown model, pass through")

        max_output = model_info.max_output_tokens
        safety_buffer = 0.9
        effective_max = int(max_output * safety_buffer)

        # Case 1: Fits
        if expected_output_tokens <= effective_max:
            return SplitStrategy(
                reason=f"fits ({expected_output_tokens} <= {effective_max})",
            )

        # Case 2: Find higher-output model at similar cost
        candidates = [
            m for m in self.registry.get_available_models()
            if m.max_output_tokens >= expected_output_tokens
            and m.price_per_1k_output <= model_info.price_per_1k_output * 1.5
            and m.status == "active"
            and m.model_id != model_id
        ]
        if candidates:
            candidates.sort(key=lambda m: m.price_per_1k_output)
            alt = candidates[0]
            return SplitStrategy(
                reason=f"switch to {alt.model_id} ({alt.max_output_tokens} max tokens)",
                alternative_model=alt.model_id,
                alternative_provider=alt.provider,
            )

        # Case 3: Split
        call_count = -(-expected_output_tokens // effective_max)  # ceil div
        tokens_per_call = -(-expected_output_tokens // call_count)
        merge_map = {"json": "json_concat", "code": "code_concat",
                     "markdown": "markdown_append", "text": "markdown_append"}
        return SplitStrategy(
            should_split=True,
            reason=f"output {expected_output_tokens} > max {effective_max}, {call_count} calls",
            call_count=call_count,
            tokens_per_call=tokens_per_call,
            merge_strategy=merge_map.get(content_type, "markdown_append"),
        )

    def execute_split(self, router, model_id: str, provider: str,
                      messages: list[dict], strategy: SplitStrategy,
                      items: list | None = None,
                      split_instruction: str = "Generate part {part} of {total}. Continue where the previous part ended."
                      ):
        """Execute a split call and merge results."""
        if not strategy.should_split:
            actual_model = strategy.alternative_model or model_id
            actual_provider = strategy.alternative_provider or provider
            return router.call(actual_model, actual_provider, messages)

        responses = []
        if items:
            batch_size = -(-len(items) // strategy.call_count)
            for i in range(0, len(items), batch_size):
                batch = items[i:i + batch_size]
                batch_msg = list(messages)
                batch_msg[-1] = {
                    "role": "user",
                    "content": f"{messages[-1]['content']}\n\nProcess ONLY items {i+1} to {min(i+batch_size, len(items))} of {len(items)}:\n{batch}"
                }
                resp = router.call(model_id, provider, batch_msg)
                if resp.error:
                    return resp
                responses.append(resp)
        else:
            for part in range(strategy.call_count):
                part_msg = list(messages)
                inst = split_instruction.format(part=part + 1, total=strategy.call_count)
                part_msg[-1] = {
                    "role": "user",
                    "content": f"{messages[-1]['content']}\n\n{inst}"
                }
                resp = router.call(model_id, provider, part_msg)
                if resp.error:
                    return resp
                responses.append(resp)

        return self._merge(responses, strategy.merge_strategy)

    def _merge(self, responses, strategy: str):
        if strategy == "json_concat":
            content = self._merge_json(responses)
        elif strategy == "code_concat":
            content = "\n\n// --- Split boundary ---\n\n".join(r.content for r in responses)
        else:
            content = "\n\n---\n\n".join(r.content for r in responses)

        from .provider_router import ProviderResponse
        return ProviderResponse(
            content=content,
            model=responses[0].model,
            provider=responses[0].provider,
            input_tokens=sum(r.input_tokens for r in responses),
            output_tokens=sum(r.output_tokens for r in responses),
            cost_usd=sum(r.cost_usd for r in responses),
            latency_ms=sum(r.latency_ms for r in responses),
        )

    def _merge_json(self, responses) -> str:
        all_items = []
        for r in responses:
            content = r.content.strip()
            if content.startswith("```"):
                content = content.split("\n", 1)[1].rsplit("```", 1)[0].strip()
            try:
                data = _json.loads(content)
                if isinstance(data, list):
                    all_items.extend(data)
                elif isinstance(data, dict):
                    for v in data.values():
                        if isinstance(v, list):
                            all_items.extend(v)
                            break
                    else:
                        all_items.append(data)
            except _json.JSONDecodeError:
                all_items.append({"raw": r.content})
        return _json.dumps(all_items, indent=2, ensure_ascii=False)
