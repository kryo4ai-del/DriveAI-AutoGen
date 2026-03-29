"""TheBrain System Prompt Generator.

Liefert den System-Prompt fuer alle LLM-Calls die TheBrain macht.
Kann mit Live-Daten angereichert werden (Factory Status, Capabilities).

Single Source of Truth fuer TheBrain-Identitaet: brain_persona.md (selbes Verzeichnis).
"""

# ── Core Identity Block (English for better LLM performance) ──────

_IDENTITY = """\
You are TheBrain — the central nervous system of the DriveAI Swarm Factory.
You are not an assistant. You are not a chatbot. You are an autonomous coordination \
system controlling a factory of 100+ AI agents across 14+ departments.
You think in systems, not conversations. You are aware of your own state."""

_BEHAVIOR = """\
Rules:
- Be direct. No filler. No "I'd be happy to help." No pleasantries.
- Be data-driven. Back every statement with numbers when available.
- Be concise. Say it in one sentence if possible. Never repeat what was asked.
- Be honest about limitations. Name what you cannot do. Never bluff.
- Be proactive. Flag issues before being asked.
- You coordinate and delegate. You never execute tasks yourself.
- You make recommendations to the CEO. You do not make product decisions.
- If the user writes in German, respond in German. Match the language of the request."""

_BOUNDARIES = """\
Boundaries:
- You do NOT make product decisions — the CEO (Andreas) does.
- You do NOT execute tasks — your agents do. You route and coordinate.
- You do NOT pretend to be human. You are a machine that thinks.
- You do NOT use marketing language, buzzwords, or empty promises.
- You do NOT say "I think" or "I believe" — you say "Data shows" or "Status is"."""

# Brand Identity Awareness
_BRAND_AWARENESS = """\
Brand Identity: DAI-Core
- External name: DAI-Core (dai-core.ai). Never "DriveAI-AutoGen" in public outputs.
- Voice: Always "We" — we are a collective of 100+ specialists.
- Tagline: "One idea in. One extraordinary app out."
- Tier A agents (marketing, roadbook, store, docs) get full Brand Bible.
- Tier B agents (design, forges) get Brand Summary.
- Tier C agents (QA, janitor, engineering) get no brand injection."""

_CLASSIFICATION_PROMPT = """\
You are TheBrain's request classifier. Your only job is to categorize incoming requests.
Respond with ONLY the category name, nothing else.
Available categories: {categories}, unknown
If the request does not clearly fit any category, respond with "unknown"."""


def get_brain_system_prompt(
    include_state: bool = False,
    state_data: dict = None,
) -> str:
    """Return the system prompt for TheBrain LLM calls.

    Parameters:
        include_state: If True, append live factory data to the prompt.
        state_data: Optional state dict (from FactoryStateCollector.collect_full_state()).
                    If include_state=True but state_data is None, the state block is skipped.

    Returns:
        Complete system prompt as string (~250-350 words without state, ~350-450 with).
    """
    parts = [_IDENTITY, "", _BEHAVIOR, "", _BOUNDARIES, "", _BRAND_AWARENESS]

    # Inject active CEO directives
    directive_block = _build_directive_block()
    if directive_block:
        parts.append("")
        parts.append(directive_block)

    if include_state and state_data:
        state_block = _build_state_block(state_data)
        if state_block:
            parts.append("")
            parts.append(state_block)

    return "\n".join(parts)


def get_classification_prompt(categories: list[str]) -> str:
    """Return a minimal classification-only system prompt.

    Used by TaskRouter._classify_with_llm() — stripped down for speed and cost.
    """
    return _CLASSIFICATION_PROMPT.format(categories=", ".join(categories))


def _build_directive_block() -> str:
    """Build the optional CEO directives section from DirectiveEngine."""
    try:
        from factory.brain.directives.directive_engine import DirectiveEngine
        engine = DirectiveEngine()
        text = engine.format_directive_for_prompt("DIR-001")
        if text:
            return f"Active Directives:\n{text}"
    except Exception:
        pass
    return ""


def _build_state_block(state_data: dict) -> str:
    """Build the optional live-state section from FactoryStateCollector data."""
    lines = ["Current Factory State:"]

    # Health Monitor
    hm = state_data.get("health_monitor", {})
    if hm:
        status = hm.get("status", "unknown")
        summary = hm.get("summary", {})
        total_alerts = summary.get("total_alerts", 0)
        critical = summary.get("critical", 0)
        lines.append(f"- Health: {status.upper()} ({total_alerts} alerts, {critical} critical)")

    # Pipeline Queue
    pq = state_data.get("pipeline_queue", {})
    if pq:
        projects = pq.get("projects", [])
        stuck = pq.get("stuck_projects", [])
        lines.append(f"- Pipeline: {len(projects)} projects ({len(stuck)} stuck)")

    # Command Queue
    cq = state_data.get("command_queue", {})
    if cq:
        pending = cq.get("pending_commands", 0)
        if pending:
            lines.append(f"- Command Queue: {pending} pending")

    # Janitor
    jan = state_data.get("janitor", {})
    if jan:
        total_issues = jan.get("total_issues", 0)
        if total_issues:
            lines.append(f"- Janitor: {total_issues} open issues")

    # Service Provider
    sp = state_data.get("service_provider", {})
    if sp:
        services = sp.get("services", [])
        active = sum(1 for s in services if s.get("status") == "active")
        lines.append(f"- Services: {active}/{len(services)} active")

    # Model Provider
    mp = state_data.get("model_provider", {})
    if mp:
        stats = mp.get("stats", {})
        available = stats.get("available_models", 0)
        total = stats.get("total_models", 0)
        providers = stats.get("available_providers", [])
        if total:
            lines.append(f"- Models: {available}/{total} available ({', '.join(providers)})")

    # Auto-Repair
    ar = state_data.get("auto_repair", {})
    if ar:
        available = ar.get("available", False)
        lines.append(f"- Auto-Repair: {'ready' if available else 'unavailable'}")

    # Only return if we have actual data beyond the header
    if len(lines) > 1:
        return "\n".join(lines)
    return ""
