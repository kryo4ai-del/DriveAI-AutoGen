"""Review-Assistant — Kapitel 5 Visual & Asset Audit (Agent 20)

Role: Interactive agent triggered by human reviewer feedback. Categorizes feedback,
suggests changes, and provides updated report entries.
"""

from dotenv import load_dotenv
from pathlib import Path

load_dotenv()

AGENT_NAME = "ReviewAssistant"


def _call_llm(prompt: str, system: str = "", max_tokens: int = 8000, agent_name: str = "unknown", profile: str = "standard") -> str:
    """Call LLM via TheBrain with Anthropic fallback."""
    try:
        from factory.brain.model_provider import get_model, get_router
        selection = get_model(profile=profile, expected_output_tokens=max_tokens)
        router = get_router()

        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": prompt})

        response = router.call(
            model_id=selection["model"],
            provider=selection["provider"],
            messages=messages,
            max_tokens=max_tokens,
        )

        if response.error:
            raise RuntimeError(response.error)

        cost_str = f", Cost: ${response.cost_usd:.4f}" if response.cost_usd else ""
        print(f"[{agent_name}] {selection['model']} ({selection['provider']}){cost_str}")
        return response.content

    except Exception as e:
        print(f"[{agent_name}] TheBrain failed ({e}), falling back to Anthropic Sonnet")
        import anthropic
        client = anthropic.Anthropic()
        resp = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=max_tokens,
            messages=[{"role": "user", "content": prompt}]
        )
        return resp.content[0].text


def process_feedback(feedback: str, asset_discovery: str, asset_strategy: str,
                     visual_consistency: str) -> str:
    """Process reviewer feedback and return analysis + suggested changes.

    Args:
        feedback: Free-text feedback from the reviewer
        asset_discovery: Current asset discovery report
        asset_strategy: Current asset strategy report
        visual_consistency: Current visual consistency report

    Returns:
        Markdown string with categorized feedback, changes, and updated entries
    """
    print(f"[{AGENT_NAME}] Processing feedback...")

    prompt = f"""Du bist der Review-Assistant der DriveAI Visual Audit Pipeline.

Ein menschlicher Reviewer hat folgendes Feedback gegeben:

## Reviewer-Feedback
{feedback}

## Aktuelle Reports (Kontext)
### Asset-Discovery (Auszug)
{asset_discovery[:3000]}

### Asset-Strategie (Auszug)
{asset_strategy[:2000]}

### Visual-Consistency (Auszug)
{visual_consistency[:3000]}

Analysiere das Feedback und antworte in Markdown:

# Review-Assistant Antwort

## Feedback-Kategorie
(missing_asset / wrong_asset / style_problem / priority_change / ki_warning / other)

## Betroffene Screens
- S00X: ...

## Empfohlene Aenderungen
1. ...
2. ...

## Aktualisierte Eintraege
(Falls ein Asset hinzugefuegt, geaendert oder entfernt werden soll)

### Neues Asset (falls noetig)
| ID | Asset | Beschreibung | Screen(s) | Stat./Dyn. | Launch-kritisch |
|---|---|---|---|---|---|

### Geaenderte Ampel-Bewertung (falls noetig)
| Screen | Stelle | Alt | Neu | Begruendung |
|---|---|---|---|---|

### Neue KI-Warnung (falls noetig)
| Screen | Stelle | Was Nutzer erwartet | Was KI macht | Anweisung |
|---|---|---|---|---|

## Zusammenfassung
- Aenderungen: X
- Betroffene Reports: ...
- Status: Feedback verarbeitet"""

    result = _call_llm(prompt, max_tokens=4000, agent_name=AGENT_NAME, profile="standard")
    print(f"[{AGENT_NAME}] Feedback verarbeitet ({len(result)} Zeichen)")
    return result


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Visual Review Assistant — Agent 20")
    parser.add_argument("--run-dir", type=str, required=True, help="Kapitel 5 output directory")
    parser.add_argument("--feedback", type=str, required=True, help="Reviewer feedback text")
    args = parser.parse_args()

    run_dir = Path(args.run_dir)
    reports = {}
    for filename, key in [("asset_discovery.md", "asset_discovery"), ("asset_strategy.md", "asset_strategy"), ("visual_consistency.md", "visual_consistency")]:
        filepath = run_dir / filename
        if filepath.exists():
            reports[key] = filepath.read_text(encoding="utf-8")
        else:
            reports[key] = ""

    result = process_feedback(
        feedback=args.feedback,
        asset_discovery=reports["asset_discovery"],
        asset_strategy=reports["asset_strategy"],
        visual_consistency=reports["visual_consistency"],
    )
    print(result)
