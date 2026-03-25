"""Stufe 3: LLM-verstaerkte Tiefenanalyse.

Laeuft einmal im Monat. Nutzt Claude Sonnet um Code tatsaechlich zu verstehen.
Kosten: ~$0.50-2.00 pro Lauf.
"""

import json
import logging
import os
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[3]


def deep_analyze(graph: dict, findings: list, config: dict) -> dict:
    """LLM-enhanced analysis of complex findings.

    Analyzes duplicate_logic, scattered_logic, inconsistent_pattern,
    oversized_module findings with actual code understanding.

    Returns enriched findings with LLM insights.
    """
    # Only complex findings that need LLM understanding
    complex_types = ("duplicate_logic", "scattered_logic", "inconsistent_pattern", "large_file")
    complex_findings = [f for f in findings if f.get("type") in complex_types]

    if not complex_findings:
        return {
            "message": "Keine komplexen Findings -- LLM-Analyse nicht noetig.",
            "analyzed_count": 0,
            "cost_usd": 0.0,
            "insights": [],
        }

    # Collect code context for affected files
    code_context = _collect_code_context(complex_findings, max_lines_per_file=100)

    # Batch LLM call
    try:
        from dotenv import load_dotenv
        load_dotenv(PROJECT_ROOT / ".env")
    except ImportError:
        pass

    try:
        import anthropic
        client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
    except Exception as e:
        logger.error("Anthropic client init failed: %s", e)
        return {
            "message": f"LLM-Analyse fehlgeschlagen: {e}",
            "analyzed_count": 0,
            "cost_usd": 0.0,
            "insights": [],
        }

    prompt = _build_analysis_prompt(complex_findings, code_context)

    try:
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=4096,
            system="""Du bist der Factory Janitor der DriveAI Swarm Factory.
Deine Aufgabe: Code-Hygiene-Probleme analysieren und konkrete, sichere Loesungsvorschlaege machen.

Regeln:
- Vorschlaege muessen SICHER sein -- keine Aenderung darf bestehende Funktionalitaet brechen
- Bei jedem Vorschlag: klar sagen welche Dateien betroffen sind und welche Imports sich aendern
- Wenn du unsicher bist ob ein Zusammenlegen sicher ist: als "report_only" markieren, nicht als Vorschlag
- Deutsch fuer Beschreibungen, Code-Beispiele in der jeweiligen Sprache
- Antworte als JSON-Array""",
            messages=[{"role": "user", "content": prompt}],
        )

        # Calculate cost
        input_tokens = response.usage.input_tokens
        output_tokens = response.usage.output_tokens
        cost = (input_tokens * 3 / 1_000_000) + (output_tokens * 15 / 1_000_000)

        # Parse response
        text = ""
        for block in response.content:
            if hasattr(block, "text"):
                text += block.text

        insights = _parse_llm_response(text)

        logger.info("Deep analysis: %d findings analyzed, $%.4f cost", len(complex_findings), cost)

        return {
            "message": f"{len(complex_findings)} Findings analysiert.",
            "analyzed_count": len(complex_findings),
            "cost_usd": round(cost, 4),
            "insights": insights,
        }

    except Exception as e:
        logger.error("LLM analysis failed: %s", e)
        return {
            "message": f"LLM-Analyse Fehler: {e}",
            "analyzed_count": 0,
            "cost_usd": 0.0,
            "insights": [],
        }


def _collect_code_context(findings: list, max_lines_per_file: int = 100) -> str:
    """Collect code snippets for affected files."""
    seen_files = set()
    snippets = []

    for f in findings:
        for path in f.get("affected_files", [])[:3]:  # Max 3 files per finding
            if path in seen_files:
                continue
            seen_files.add(path)

            abs_path = PROJECT_ROOT / path
            if not abs_path.exists():
                continue

            try:
                content = abs_path.read_text(encoding="utf-8", errors="ignore")
                lines = content.splitlines()
                if len(lines) > max_lines_per_file:
                    # Take first 50 + last 50
                    truncated = lines[:50] + [f"... ({len(lines) - 100} Zeilen ausgelassen) ..."] + lines[-50:]
                    content = "\n".join(truncated)
                snippets.append(f"=== {path} ===\n{content}\n")
            except Exception:
                continue

    # Limit total context
    result = "\n".join(snippets)
    if len(result) > 30000:
        result = result[:30000] + "\n... (abgeschnitten)"
    return result


def _build_analysis_prompt(findings: list, code_context: str) -> str:
    """Build the analysis prompt for the LLM."""
    findings_json = json.dumps([{
        "id": f.get("id"),
        "type": f.get("type"),
        "title": f.get("title"),
        "description": f.get("description"),
        "affected_files": f.get("affected_files", []),
        "affected_count": f.get("affected_count"),
    } for f in findings], indent=2, ensure_ascii=False)

    return f"""Analysiere diese Code-Hygiene-Findings der DriveAI Factory:

{findings_json}

Code-Kontext:
{code_context}

Fuer jedes Finding:
1. Ist es ein echtes Problem oder ein False Positive?
2. Wenn echtes Problem: konkreter Loesungsvorschlag mit betroffenen Dateien
3. Sicherheitsbewertung: Kann das autonom gefixt werden (green/yellow) oder nur als Report (red)?
4. Geschaetzter Aufwand in Zeilen Code-Aenderung

Antwort als JSON-Array:
[
  {{
    "finding_id": "F001",
    "is_real_problem": true,
    "assessment": "Kurze Bewertung",
    "suggestion": "Konkreter Vorschlag",
    "safety": "green|yellow|red",
    "effort_lines": 20,
    "affected_files": ["file1.py"]
  }}
]"""


def _parse_llm_response(text: str) -> list:
    """Parse LLM JSON response with fallback."""
    # Find JSON array in response
    start = text.find("[")
    end = text.rfind("]")
    if start == -1 or end == -1:
        return [{"raw_response": text[:2000]}]

    json_str = text[start:end + 1]
    try:
        return json.loads(json_str)
    except json.JSONDecodeError:
        # Try repair
        try:
            # Close unclosed braces
            open_b = json_str.count("{") - json_str.count("}")
            open_a = json_str.count("[") - json_str.count("]")
            json_str += "}" * max(0, open_b) + "]" * max(0, open_a)
            return json.loads(json_str)
        except json.JSONDecodeError:
            return [{"raw_response": text[:2000]}]
