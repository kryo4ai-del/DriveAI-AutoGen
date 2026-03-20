"""Memory-Agent — Phase 1 Pre-Production Pipeline

Role: Persistent knowledge store and learning agent for Phase 1.
Input: Previous learnings (before run), all reports + CEO decision (after run).
Output: Learnings briefing + updated knowledge base.
"""

import re
from datetime import date
from pathlib import Path

MEMORY_DIR = Path(__file__).resolve().parent.parent / "memory"
LEARNINGS_FILE = MEMORY_DIR / "learnings.md"
RUNS_DIR = MEMORY_DIR / "runs"

_TEMPLATE_MARKERS = [
    "(Noch keine Daten — wird nach dem ersten Durchlauf befüllt)",
    "(Noch keine Daten)",
]


def load_learnings() -> str:
    """Read learnings.md and return content. Returns default message on first run."""
    try:
        content = LEARNINGS_FILE.read_text(encoding="utf-8").strip()
    except Exception as e:
        print(f"[MemoryAgent] WARNING: Could not read learnings.md — {e}")
        return "Keine bisherigen Learnings vorhanden. Dies ist der erste Durchlauf."

    # Check if file only contains template headers (no real data)
    stripped = content
    for marker in _TEMPLATE_MARKERS:
        stripped = stripped.replace(marker, "")
    # Remove section headers and whitespace
    stripped = re.sub(r"#.*", "", stripped).strip()
    if not stripped:
        return "Keine bisherigen Learnings vorhanden. Dies ist der erste Durchlauf."

    return content


def get_next_run_number() -> int:
    """Scan runs/ directory and return the next run number."""
    try:
        files = list(RUNS_DIR.glob("*.md"))
    except Exception:
        return 1

    if not files:
        return 1

    max_num = 0
    for f in files:
        match = re.match(r"(\d+)_", f.name)
        if match:
            max_num = max(max_num, int(match.group(1)))
    return max_num + 1


def save_run(run_data: dict) -> str:
    """Save a complete run log to memory/runs/. Returns the filepath."""
    run_num = get_next_run_number()
    title = run_data.get("idea_title", "unknown")
    slug = re.sub(r"[^a-z0-9_]", "", title.lower().replace(" ", "_"))[:30]
    filename = f"{run_num:03d}_{slug}.md"
    filepath = RUNS_DIR / filename

    concept_summary = run_data.get("concept_brief", "")[:500]
    legal_summary = run_data.get("legal_report", "")[:300]
    risk_summary = run_data.get("risk_assessment", "")[:300]

    content = f"""# Run {run_num:03d}: {title}
**Datum:** {date.today().isoformat()}
**Entscheidung:** {run_data.get('ceo_decision', 'N/A')}
**Begründung:** {run_data.get('ceo_reasoning', 'N/A')}

## CEO-Idee
{run_data.get('idea_raw', '')}

## Concept Brief (Zusammenfassung)
{concept_summary}

## Legal (Zusammenfassung)
{legal_summary}

## Risk (Zusammenfassung)
{risk_summary}
"""

    try:
        filepath.write_text(content, encoding="utf-8")
    except Exception as e:
        print(f"[MemoryAgent] WARNING: Could not write run log — {e}")
        return ""

    return str(filepath)


def update_learnings(run_data: dict) -> None:
    """Extract insights from run_data and append to learnings.md."""
    run_num = get_next_run_number() - 1  # just saved, so current is n-1
    title = run_data.get("idea_title", "unknown")
    tag = f"Quelle: Durchlauf #{run_num:03d} ({title})"

    updates: dict[str, str | None] = {
        "## Trends": _extract_trend(run_data.get("trend_report", "")),
        "## Rechtliches": _extract_legal(run_data.get("risk_assessment", "")),
        "## Zielgruppen": _extract_audience(run_data.get("audience_profile", "")),
        "## Wettbewerb": _extract_competition(run_data.get("competitive_report", "")),
    }

    # Kill reasons
    kill_reason = None
    if run_data.get("ceo_decision", "").upper() == "KILL":
        kill_reason = _categorize_kill(run_data.get("ceo_reasoning", ""))

    try:
        content = LEARNINGS_FILE.read_text(encoding="utf-8")
    except Exception as e:
        print(f"[MemoryAgent] WARNING: Could not read learnings.md — {e}")
        return

    for section, insight in updates.items():
        if not insight:
            continue
        entry = f"- [{insight}]: {tag}"
        content = _append_to_section(content, section, entry)

    if kill_reason:
        entry = f"- [{kill_reason}]: {tag}"
        content = _append_to_section(content, "## Kill-Gründe (Häufigkeit)", entry)

    try:
        LEARNINGS_FILE.write_text(content, encoding="utf-8")
    except Exception as e:
        print(f"[MemoryAgent] WARNING: Could not write learnings.md — {e}")


def get_run_history() -> list[dict]:
    """Return list of all previous runs with run_number, idea_title, decision, date."""
    history = []
    try:
        files = sorted(RUNS_DIR.glob("*.md"))
    except Exception:
        return history

    for f in files:
        if f.name == ".gitkeep":
            continue
        match = re.match(r"(\d+)_", f.name)
        if not match:
            continue

        run_number = int(match.group(1))
        entry: dict = {"run_number": run_number, "idea_title": "", "decision": "", "date": ""}

        try:
            lines = f.read_text(encoding="utf-8").splitlines()[:4]
            for line in lines:
                if line.startswith("# Run"):
                    # "# Run 001: EchoMatch Test"
                    parts = line.split(":", 1)
                    if len(parts) > 1:
                        entry["idea_title"] = parts[1].strip()
                elif line.startswith("**Datum:**"):
                    entry["date"] = line.replace("**Datum:**", "").strip()
                elif line.startswith("**Entscheidung:**"):
                    entry["decision"] = line.replace("**Entscheidung:**", "").strip()
        except Exception:
            pass

        history.append(entry)

    return history


# --- Extraction helpers ---

def _extract_trend(report: str) -> str | None:
    """Extract first trend from '## Trend 1: ...' pattern."""
    match = re.search(r"## Trend \d+:\s*(.+)", report)
    return match.group(1).strip() if match else None


def _extract_legal(report: str) -> str | None:
    """Extract first risk line with 🔴 or 🟡."""
    for line in report.splitlines():
        if ("🔴" in line or "🟡" in line) and "risiko" in line.lower() or ("🔴" in line or "🟡" in line):
            return line.strip().strip("|").strip()
    return None


def _extract_audience(report: str) -> str | None:
    """Extract line after '## Primäre Zielgruppe'."""
    lines = report.splitlines()
    for i, line in enumerate(lines):
        if "## Primäre Zielgruppe" in line and i + 1 < len(lines):
            next_line = lines[i + 1].strip()
            if next_line:
                return next_line
    return None


def _extract_competition(report: str) -> str | None:
    """Extract line after '## Sättigungseinschätzung'."""
    lines = report.splitlines()
    for i, line in enumerate(lines):
        if "## Sättigungseinschätzung" in line and i + 1 < len(lines):
            next_line = lines[i + 1].strip()
            if next_line:
                return next_line
    return None


def _categorize_kill(reasoning: str) -> str:
    """Categorize kill reasoning by keyword."""
    lower = reasoning.lower()
    if "rechtlich" in lower or "legal" in lower:
        return "Rechtlich"
    if "markt" in lower or "sättigung" in lower or "wettbewerb" in lower:
        return "Markt/Sättigung"
    if "kosten" in lower or "budget" in lower or "finanziell" in lower:
        return "Finanziell"
    if "risiko" in lower or "risk" in lower:
        return "Risiko"
    return "Sonstiges"


def _append_to_section(content: str, section_header: str, entry: str) -> str:
    """Append an entry below a section header, replacing template placeholder if present."""
    lines = content.splitlines()
    result = []
    inserted = False

    for i, line in enumerate(lines):
        result.append(line)
        if line.strip().startswith(section_header.strip()):
            # Check if next line is a template placeholder
            if i + 1 < len(lines) and lines[i + 1].strip() in [m.strip() for m in _TEMPLATE_MARKERS]:
                # Replace placeholder with entry
                result.append(entry)
                inserted = True
                # Skip the placeholder line
                lines[i + 1] = ""
            else:
                # Find the end of existing entries (next section or end)
                j = i + 1
                while j < len(lines) and not lines[j].startswith("## "):
                    j += 1
                # Insert before next section
                lines.insert(j, entry)
                inserted = True

    if not inserted:
        result.append(entry)

    # Clean up empty lines from replaced placeholders
    return "\n".join(line for line in result if line is not None)
