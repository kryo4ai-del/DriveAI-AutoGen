# proposal_generator.py
# Analyzes pipeline run results and generates knowledge proposals.
# Proposals are stored separately and never auto-committed to the main knowledge base.

import json
import os
import re
from datetime import datetime

_PROPOSALS_DIR = os.path.join(os.path.dirname(__file__), "proposals")

# Maximum proposals per run to prevent flooding.
MAX_PROPOSALS_PER_RUN = 3


def generate_proposals(
    run_id: str,
    user_task: str,
    template: str | None,
    bug_messages: list,
    cd_messages: list,
    refactor_messages: list,
    source_project: str = "askfin",
) -> list[dict]:
    """Analyze run results and generate knowledge proposals.

    Scans agent output for recurring patterns, strong signals, and
    reusable lessons. Returns a list of proposal dicts (max MAX_PROPOSALS_PER_RUN).
    """
    proposals: list[dict] = []

    # Extract text from agent messages
    bug_text = _extract_agent_text(bug_messages, "bug_hunter")
    cd_text = _extract_agent_text(cd_messages, "creative_director")
    refactor_text = _extract_agent_text(refactor_messages, "refactor_agent")

    # Signal 1: Bug Hunter found CRITICAL severity bugs
    critical_bugs = _extract_critical_bugs(bug_text)
    if critical_bugs:
        proposals.append(_make_proposal(
            title=f"Bug pattern: {critical_bugs[0][:60]}",
            category="failure_case",
            lesson=f"Critical bug detected: {critical_bugs[0]}. Screen generation should guard against this.",
            evidence=f"Bug Hunter flagged as CRITICAL in run {run_id}",
            source_run=run_id,
            source_project=source_project,
            tags=["bug-pattern", "code-quality"],
        ))

    # Signal 2: CD rated 'fail' — strong product quality signal
    cd_rating = _extract_cd_rating(cd_text)
    if cd_rating == "fail":
        cd_problems = _extract_cd_problems(cd_text)
        problem_summary = cd_problems[0] if cd_problems else "Generic output detected"
        proposals.append(_make_proposal(
            title=f"Product quality gap: {problem_summary[:55]}",
            category="ux_insight",
            lesson=f"Creative Director rated output as 'fail'. Key issue: {problem_summary}",
            evidence=f"CD review in run {run_id}: rating=fail",
            source_run=run_id,
            source_project=source_project,
            tags=["product-quality", "cd-review"],
        ))

    # Signal 3: CD identified missing emotional design (even in conditional_pass)
    if cd_rating in ("conditional_pass", "fail"):
        emotional_gaps = _extract_emotional_gaps(cd_text)
        if emotional_gaps and len(proposals) < MAX_PROPOSALS_PER_RUN:
            proposals.append(_make_proposal(
                title=f"Emotional design gap: {emotional_gaps[0][:55]}",
                category="ux_insight",
                lesson=f"Implementation lacked emotional engagement: {emotional_gaps[0]}",
                evidence=f"CD finding in run {run_id} for template={template}",
                source_run=run_id,
                source_project=source_project,
                tags=["emotional-design", "ux", "cd-review"],
            ))

    # Signal 4: Refactor identified major duplication
    duplication_signal = _detect_duplication_signal(refactor_text)
    if duplication_signal and len(proposals) < MAX_PROPOSALS_PER_RUN:
        proposals.append(_make_proposal(
            title="File duplication in code generation output",
            category="failure_case",
            lesson=f"Code generation produced duplicate files: {duplication_signal}. Extraction pipeline needs deduplication.",
            evidence=f"Refactor pass in run {run_id}",
            source_run=run_id,
            source_project=source_project,
            tags=["code-generation", "duplication", "pipeline"],
        ))

    # Signal 5: Bug Hunter found lifecycle/memory issues (common SwiftUI pattern)
    lifecycle_bugs = _detect_lifecycle_bugs(bug_text)
    if lifecycle_bugs and len(proposals) < MAX_PROPOSALS_PER_RUN:
        proposals.append(_make_proposal(
            title=f"SwiftUI lifecycle pattern: {lifecycle_bugs[0][:50]}",
            category="technical_pattern",
            lesson=f"Generated SwiftUI code missing lifecycle management: {lifecycle_bugs[0]}",
            evidence=f"Bug Hunter finding in run {run_id}",
            source_run=run_id,
            source_project=source_project,
            tags=["swiftui", "lifecycle", "memory-management"],
        ))

    return proposals[:MAX_PROPOSALS_PER_RUN]


def save_proposals(run_id: str, proposals: list[dict]) -> str | None:
    """Save proposals to a JSON file in the proposals directory.

    Returns the file path if saved, None if no proposals.
    """
    if not proposals:
        return None

    os.makedirs(_PROPOSALS_DIR, exist_ok=True)
    filepath = os.path.join(_PROPOSALS_DIR, f"proposal_{run_id}.json")

    data = {
        "run_id": run_id,
        "generated": datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
        "proposal_count": len(proposals),
        "proposals": proposals,
    }

    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    return filepath


# ── Extraction helpers ────────────────────────────────────────────


def _extract_agent_text(messages: list, agent_name: str) -> str:
    """Extract text content from messages by a specific agent."""
    parts = []
    for msg in messages:
        source = getattr(msg, "source", "")
        content = getattr(msg, "content", "")
        if source == agent_name and isinstance(content, str):
            parts.append(content)
    return "\n".join(parts)


def _extract_critical_bugs(bug_text: str) -> list[str]:
    """Find CRITICAL severity bugs in Bug Hunter output."""
    if not bug_text:
        return []
    # Match: ### N. **Title**\n**Severity:** CRITICAL
    pattern = r"###\s*\d+\.\s*\*\*(.+?)\*\*\s*\n\*\*Severity:\*\*\s*CRITICAL"
    matches = re.findall(pattern, bug_text)
    return matches


def _extract_cd_rating(cd_text: str) -> str | None:
    """Extract the CD rating (pass/conditional_pass/fail)."""
    if not cd_text:
        return None
    match = re.search(r"\*\*Rating:\s*(pass|conditional_pass|fail)\*\*", cd_text)
    return match.group(1) if match else None


def _extract_cd_problems(cd_text: str) -> list[str]:
    """Extract Problem descriptions from CD findings."""
    if not cd_text:
        return []
    pattern = r"\*\*Problem:\*\*\s*(.+?)(?:\n\n|\*\*Suggestion:)"
    matches = re.findall(pattern, cd_text, re.DOTALL)
    return [m.strip()[:200] for m in matches]


def _extract_emotional_gaps(cd_text: str) -> list[str]:
    """Detect findings about missing emotional design."""
    if not cd_text:
        return []
    # Look for CD section headers with emotional/motivation keywords
    pattern = r"###\s*\d+\.\s*\[([^\]]*(?:Emotion|Motivation|Retention|Personality)[^\]]*)\]\s*(.+?)(?:\n---|\Z)"
    matches = re.findall(pattern, cd_text, re.DOTALL | re.IGNORECASE)
    results = []
    for category, content in matches:
        # Extract the title after the category tag
        title_match = re.match(r"\s*(.+?)(?:\n|$)", content)
        if title_match:
            results.append(f"{category}: {title_match.group(1).strip()}")
    return results


def _detect_duplication_signal(refactor_text: str) -> str | None:
    """Detect if refactor pass flagged file duplication."""
    if not refactor_text:
        return None
    # Look for specific duplication patterns
    dup_patterns = [
        r"(\d+)\s*(?:copies|duplicat|identical)",
        r"(?:duplicat|redundant)\w*\s+files?",
        r"generated\s+(\d+)\s+times",
    ]
    for pattern in dup_patterns:
        match = re.search(pattern, refactor_text, re.IGNORECASE)
        if match:
            # Extract only the matching line (not surrounding bash scripts)
            line_start = refactor_text.rfind("\n", 0, match.start()) + 1
            line_end = refactor_text.find("\n", match.end())
            if line_end == -1:
                line_end = min(len(refactor_text), match.end() + 80)
            line = refactor_text[line_start:line_end].strip()
            # Skip lines that are part of code blocks
            if line.startswith(("#", "find ", "xargs", "rm ", "declare")):
                continue
            return line[:150]
    return None


def _detect_lifecycle_bugs(bug_text: str) -> list[str]:
    """Detect SwiftUI lifecycle and memory management issues."""
    if not bug_text:
        return []
    # Match section headers containing lifecycle keywords
    pattern = r"###\s*\d+\.\s*\*\*([^*]*(?:Lifecycle|Memory|MainActor|Retain|Cancellation)[^*]*)\*\*"
    matches = re.findall(pattern, bug_text, re.IGNORECASE)
    if matches:
        return [m.strip() for m in matches[:2]]
    # Fallback: keyword detection in body text
    keywords = ["memory leak", "@MainActor.*missing", "retain cycle"]
    for kw in keywords:
        match = re.search(kw, bug_text, re.IGNORECASE)
        if match:
            return [match.group(0)]
    return []


def _make_proposal(
    title: str,
    category: str,
    lesson: str,
    evidence: str,
    source_run: str,
    source_project: str,
    tags: list[str],
) -> dict:
    """Create a structured proposal entry."""
    return {
        "title": title[:80],
        "type": category,
        "lesson": lesson,
        "evidence": evidence,
        "source_run": source_run,
        "source_project": source_project,
        "confidence": "hypothesis",
        "tags": tags,
        "status": "pending_review",
        "reason": _proposal_reason(category),
    }


def _proposal_reason(category: str) -> str:
    """Explain why this type of finding warrants a knowledge entry."""
    reasons = {
        "failure_case": "Recurring failure patterns should be captured to prevent repetition in future projects.",
        "ux_insight": "Product quality insights from CD reviews can improve future implementation prompts.",
        "technical_pattern": "Technical patterns detected in reviews can be reused across projects.",
    }
    return reasons.get(category, "Pattern detected in run output that may be reusable.")
