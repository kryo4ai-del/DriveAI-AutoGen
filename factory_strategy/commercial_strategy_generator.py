# commercial_strategy_generator.py
# Generates structured commercial strategy books for factory projects.
# Uses Anthropic Claude API directly (no AutoGen agents).
# Output: markdown strategy documents stored in strategy_books/.

import json
import os
from datetime import datetime

from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"))

import anthropic

_BASE_DIR = os.path.dirname(os.path.dirname(__file__))
_STRATEGY_DIR = os.path.join(_BASE_DIR, "strategy_books")
_REGISTRY_PATH = os.path.join(_BASE_DIR, "factory", "projects", "project_registry.json")
_KNOWLEDGE_PATH = os.path.join(_BASE_DIR, "factory_knowledge", "knowledge.json")

# Strategy generation model — uses Sonnet for balanced cost/quality
_MODEL = "claude-sonnet-4-6"
_MAX_TOKENS = 4096

_STRATEGY_PROMPT = """You are a commercial strategist for digital products.

Generate a structured Commercial Strategy Book for the project described below.

RULES:
- Be specific to THIS product — no generic advice
- Every recommendation must connect to the product's actual capabilities and constraints
- Acknowledge constraints honestly (legal, content, market position)
- Prioritize actionable strategies over aspirational ones
- Keep each section concise and structured
- Use markdown formatting

REQUIRED SECTIONS:

# Commercial Strategy Book: {project_name}

## 1. Product Positioning
- Problem statement (what pain does this solve?)
- Primary audience (who, demographics, psychographics)
- Differentiator (why this, not alternatives?)
- One-sentence positioning statement

## 2. Monetization Strategy
For each viable model, explain:
- How it works for this product
- Pros and risks
- Recommended pricing approach
Mark the recommended primary model.

## 3. Distribution Strategy
For each viable channel:
- Why it fits this product
- Effort required
- Expected reach
Prioritize channels by effort-to-reach ratio.

## 4. Marketing Angles
3-5 specific storytelling angles with:
- The angle (one sentence)
- Why it works for this audience
- Example headline or hook

## 5. Supporting Assets
List required assets with priority (must-have / nice-to-have):
- What it is
- Why it matters
- Effort estimate (low / medium / high)

## 6. Risks and Constraints
Honest assessment of:
- Legal/licensing constraints
- Market competition
- Resource limitations
- Content dependencies

## 7. Recommended First Steps
Ordered list of 5-7 concrete actions to take first.

PROJECT CONTEXT:
{context}

FACTORY KNOWLEDGE (prior learnings):
{knowledge}
"""


def _load_project_context(project_id: str) -> str:
    """Load project context from registry and available docs."""
    context_parts = []

    # Project registry
    try:
        with open(_REGISTRY_PATH, encoding="utf-8") as f:
            registry = json.load(f)
        projects = registry.get("projects", [])
        for proj in projects:
            if proj.get("id") == project_id:
                context_parts.append(f"Project: {proj.get('name', project_id)}")
                context_parts.append(f"Description: {proj.get('description', 'N/A')}")
                context_parts.append(f"Platform: {proj.get('platform', 'N/A')}")
                context_parts.append(f"Status: {proj.get('status', 'N/A')}")
                features = proj.get("features", [])
                if features:
                    context_parts.append(f"Features ({len(features)}): {', '.join(features[:10])}")
                break
    except (FileNotFoundError, json.JSONDecodeError):
        pass

    # Premium reframing doc (if exists)
    reframing_path = os.path.join(_BASE_DIR, "docs", f"{project_id}_premium_reframing.md")
    if not os.path.exists(reframing_path):
        reframing_path = os.path.join(_BASE_DIR, "docs", "askfin_premium_reframing.md")
    if os.path.exists(reframing_path):
        try:
            with open(reframing_path, encoding="utf-8") as f:
                content = f.read()
            # Truncate to keep prompt manageable
            if len(content) > 3000:
                content = content[:3000] + "\n[... truncated]"
            context_parts.append(f"\n--- Premium Positioning ---\n{content}")
        except Exception:
            pass

    # Compliance decision (if exists)
    compliance_dir = os.path.join(_BASE_DIR, "compliance")
    if os.path.isdir(compliance_dir):
        for fname in os.listdir(compliance_dir):
            if project_id.lower() in fname.lower() and fname.endswith(".md"):
                try:
                    with open(os.path.join(compliance_dir, fname), encoding="utf-8") as f:
                        content = f.read()
                    if len(content) > 2000:
                        content = content[:2000] + "\n[... truncated]"
                    context_parts.append(f"\n--- Compliance/Legal ---\n{content}")
                except Exception:
                    pass

    # Architecture summary
    arch_path = os.path.join(_BASE_DIR, "docs", "architecture.md")
    if os.path.exists(arch_path):
        try:
            with open(arch_path, encoding="utf-8") as f:
                content = f.read()
            if len(content) > 1500:
                content = content[:1500] + "\n[... truncated]"
            context_parts.append(f"\n--- Architecture ---\n{content}")
        except Exception:
            pass

    return "\n".join(context_parts) if context_parts else f"Project: {project_id} (no additional context available)"


def _load_knowledge_summary() -> str:
    """Load factory knowledge entries as compact summary."""
    try:
        with open(_KNOWLEDGE_PATH, encoding="utf-8") as f:
            data = json.load(f)
        entries = data.get("entries", [])
        if not entries:
            return "No factory knowledge available."
        lines = []
        for e in entries:
            if e.get("product_type") == "ai_pipeline":
                continue  # Skip pipeline-internal entries
            eid = e.get("id", "?")
            title = e.get("title", "")
            lesson = e.get("lesson") or e.get("effect") or e.get("description", "")
            if len(lesson) > 120:
                lesson = lesson[:117] + "..."
            lines.append(f"- [{eid}] {title}: {lesson}")
        return "\n".join(lines) if lines else "No product knowledge available."
    except (FileNotFoundError, json.JSONDecodeError):
        return "No factory knowledge available."


def generate_strategy_book(
    project_id: str,
    project_name: str | None = None,
    extra_context: str = "",
) -> str:
    """Generate a commercial strategy book for a project.

    Args:
        project_id: Project identifier (e.g. 'askfin')
        project_name: Display name (e.g. 'AskFin'). Defaults to project_id.
        extra_context: Additional context to include in the prompt.

    Returns:
        Generated strategy book as markdown string.
    """
    name = project_name or project_id
    context = _load_project_context(project_id)
    if extra_context:
        context += f"\n\n--- Additional Context ---\n{extra_context}"
    knowledge = _load_knowledge_summary()

    prompt = _STRATEGY_PROMPT.format(
        project_name=name,
        context=context,
        knowledge=knowledge,
    )

    client = anthropic.Anthropic()
    response = client.messages.create(
        model=_MODEL,
        max_tokens=_MAX_TOKENS,
        messages=[{"role": "user", "content": prompt}],
    )

    return response.content[0].text


def save_strategy_book(project_id: str, content: str) -> str:
    """Save a strategy book to the strategy_books directory.

    Returns the file path.
    """
    os.makedirs(_STRATEGY_DIR, exist_ok=True)
    filename = f"{project_id}_strategy.md"
    path = os.path.join(_STRATEGY_DIR, filename)

    # Add generation metadata header
    header = (
        f"<!-- Generated: {datetime.now().isoformat(timespec='seconds')} -->\n"
        f"<!-- Project: {project_id} -->\n"
        f"<!-- Model: {_MODEL} -->\n\n"
    )

    with open(path, "w", encoding="utf-8") as f:
        f.write(header + content)

    return path


def generate_and_save(
    project_id: str,
    project_name: str | None = None,
    extra_context: str = "",
) -> tuple[str, str]:
    """Generate and save a strategy book. Returns (content, file_path)."""
    content = generate_strategy_book(project_id, project_name, extra_context)
    path = save_strategy_book(project_id, content)
    return content, path


# CLI entry point
if __name__ == "__main__":
    import sys

    pid = sys.argv[1] if len(sys.argv) > 1 else "askfin"
    pname = sys.argv[2] if len(sys.argv) > 2 else None
    print(f"Generating strategy book for: {pid}")
    content, path = generate_and_save(pid, pname)
    print(f"Saved to: {path}")
    print(f"Length: {len(content)} chars")
