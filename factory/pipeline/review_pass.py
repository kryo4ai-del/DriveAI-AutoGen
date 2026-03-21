"""Review Pass — single-call API execution for review/analysis passes.

Replaces SelectorGroupChat for non-implementation passes.
Each pass gets ONLY what it needs: code, summary, prior findings.
Uses ProviderRouter (LiteLLM) for multi-provider support.
"""
import os
import re
import json
from dataclasses import dataclass, field
from pathlib import Path

try:
    from factory.brain.model_provider import get_model, get_router
    _BRAIN_AVAILABLE = True
except ImportError:
    _BRAIN_AVAILABLE = False


@dataclass
class SimpleMessage:
    """Minimal AutoGen-compatible message for backward compat."""
    source: str
    content: str


@dataclass
class ReviewResult:
    """Result of a single review pass."""
    content: str = ""
    agent_name: str = ""
    pass_name: str = ""
    model: str = ""
    provider: str = ""
    input_tokens: int = 0
    output_tokens: int = 0
    cost_usd: float = 0.0
    digest: str = ""

    @property
    def messages(self) -> list:
        """AutoGen-compatible message list for backward compat."""
        return [SimpleMessage(source=self.agent_name, content=self.content)]


_PASS_TASK_TYPE = {
    "bug_review": "bug_hunting",
    "creative_review": "creative_direction",
    "ux_psychology": "ux_psychology_review",
    "refactor": "refactoring",
    "test_generation": "test_generation",
    "fix_execution": "code_generation",
}

_ROLES_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "config", "agent_roles.json")


def _get_agent_system_message(agent_name: str, platform: str = "ios") -> str:
    """Load system message from agent_roles.json + platform role enhancement."""
    try:
        with open(_ROLES_PATH, encoding="utf-8") as f:
            roles = json.load(f)
        base = roles.get(agent_name, {}).get("system_message", f"You are the {agent_name}.")
    except Exception:
        base = f"You are the {agent_name}."

    try:
        from config.platform_role_resolver import PlatformRoleResolver
        resolver = PlatformRoleResolver(platform)
        return resolver.resolve_role(agent_name, base)
    except Exception:
        return base


def _build_review_prompt(pass_name, task_prompt, code_context, impl_summary,
                         review_digests, knowledge_block):
    """Build focused prompt with ONLY what the pass needs."""
    sections = []
    if knowledge_block:
        sections.append(f"[Factory Knowledge]\n{knowledge_block}")
    if impl_summary:
        sections.append(f"[Implementation Summary]\n{impl_summary}")
    if review_digests:
        sections.append(f"[Prior Review Findings]\n{review_digests}")
    if code_context:
        sections.append(f"[Generated Code]\n{code_context}")
    sections.append(f"[Your Task]\n{task_prompt}")
    return "\n\n".join(sections)


def get_code_context(impl_messages: list, max_chars: int = 15000) -> str:
    """Extract code blocks from implementation pass messages."""
    code_blocks = []
    for msg in impl_messages:
        content = getattr(msg, "content", str(msg)) or ""
        for match in re.finditer(r"```\w*\n(.*?)```", content, re.DOTALL):
            code_blocks.append(match.group(1).strip())
    combined = "\n\n".join(code_blocks)
    if len(combined) > max_chars:
        combined = combined[:max_chars] + "\n... (truncated)"
    return combined


async def run_review_pass(
    agent_name: str,
    pass_name: str,
    task_prompt: str,
    code_context: str = "",
    impl_summary: str = "",
    review_digests: str = "",
    knowledge_block: str = "",
    platform: str = "ios",
    profile: str = "dev",
    line: str = "",
    logger=None,
) -> ReviewResult:
    """Execute a review pass as a single direct API call.

    Uses TheBrain ProviderRouter for multi-provider support.
    Falls back to Anthropic direct call if ProviderRouter unavailable.
    """
    system_msg = _get_agent_system_message(agent_name, platform)
    user_msg = _build_review_prompt(
        pass_name, task_prompt, code_context, impl_summary,
        review_digests, knowledge_block,
    )

    # Try TheBrain ProviderRouter
    if _BRAIN_AVAILABLE:
        try:
            selection = get_model(
                agent_name=agent_name,
                task_type=_PASS_TASK_TYPE.get(pass_name, "code_review"),
                profile=profile,
                line=line,
            )
            router = get_router()
            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=[
                    {"role": "system", "content": system_msg},
                    {"role": "user", "content": user_msg},
                ],
                max_tokens=4096,
                temperature=0.0,
            )
            if not response.error:
                result = ReviewResult(
                    content=response.content,
                    agent_name=agent_name,
                    pass_name=pass_name,
                    model=selection["model"],
                    provider=selection["provider"],
                    input_tokens=response.input_tokens,
                    output_tokens=response.output_tokens,
                    cost_usd=response.cost_usd,
                    digest=response.content[:600] if response.content else "",
                )
                print(f"  Model: {selection['model']} ({selection['provider']})")
                print(f"  Tokens: {response.input_tokens} in + {response.output_tokens} out, cost: ${response.cost_usd:.6f}")
                if logger:
                    logger.info(f"  Model: {selection['model']} ({selection['provider']})")
                    logger.info(f"  Tokens: {response.input_tokens}+{response.output_tokens}, cost: ${response.cost_usd:.6f}")
                    logger.info(response.content)
                return result
        except Exception as e:
            print(f"  [WARNING] ProviderRouter failed ({e}), falling back to Anthropic")

    # Fallback: direct Anthropic call
    return await _fallback_anthropic_call(
        agent_name, pass_name, system_msg, user_msg, profile, logger
    )


async def _fallback_anthropic_call(agent_name, pass_name, system_msg, user_msg, profile, logger):
    """Fallback: call Anthropic directly via urllib."""
    import urllib.request

    model_map = {"dev": "claude-haiku-4-5", "standard": "claude-sonnet-4-6", "premium": "claude-opus-4-6"}
    model = model_map.get(profile, "claude-haiku-4-5")
    api_key = os.environ.get("ANTHROPIC_API_KEY", "")

    if not api_key:
        return ReviewResult(content="[ERROR] No ANTHROPIC_API_KEY", agent_name=agent_name, pass_name=pass_name)

    data = json.dumps({
        "model": model,
        "max_tokens": 4096,
        "system": system_msg,
        "messages": [{"role": "user", "content": user_msg}],
    }).encode("utf-8")

    req = urllib.request.Request(
        "https://api.anthropic.com/v1/messages",
        data=data,
        headers={
            "Content-Type": "application/json",
            "x-api-key": api_key,
            "anthropic-version": "2023-06-01",
        },
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            result_data = json.loads(resp.read().decode("utf-8"))
        content = ""
        in_tok = result_data.get("usage", {}).get("input_tokens", 0)
        out_tok = result_data.get("usage", {}).get("output_tokens", 0)
        for block in result_data.get("content", []):
            if block.get("type") == "text":
                content += block["text"]
        # Estimate cost
        prices = {"claude-haiku-4-5": (0.0008, 0.004), "claude-sonnet-4-6": (0.003, 0.015), "claude-opus-4-6": (0.015, 0.075)}
        pin, pout = prices.get(model, (0.001, 0.005))
        cost = (in_tok * pin + out_tok * pout) / 1000

        print(f"  Model: {model} (anthropic, fallback)")
        print(f"  Tokens: {in_tok} in + {out_tok} out, cost: ${cost:.6f}")
        if logger:
            logger.info(f"  Model: {model} (fallback), {in_tok}+{out_tok} tok, ${cost:.6f}")
            logger.info(content)

        return ReviewResult(
            content=content, agent_name=agent_name, pass_name=pass_name,
            model=model, provider="anthropic",
            input_tokens=in_tok, output_tokens=out_tok, cost_usd=cost,
            digest=content[:600],
        )
    except Exception as e:
        return ReviewResult(content=f"[ERROR] {e}", agent_name=agent_name, pass_name=pass_name)
