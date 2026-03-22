"""Release-Planner — Phase 2 Market Strategy Pipeline

Role: Plans the concrete path from finished product to successful launch.
Input: Concept Brief + Platform Strategy + Monetization Report.
Output: Release Plan Report.
"""

from dotenv import load_dotenv

load_dotenv()

AGENT_NAME = "ReleasePlanner"


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


def run(concept_brief: str, platform_strategy: str, monetization_report: str) -> str:
    """Create release plan with timeline, phases and risk scenarios."""
    # Extract app name
    app_name = "App"
    for line in concept_brief.splitlines():
        if line.startswith("# ") and ":" in line:
            app_name = line.split(":", 1)[1].strip()
            break

    prompt = f"""Du bist ein Release-Planer für Mobile Apps und Games.

## Concept Brief
{concept_brief}

## Plattform-Strategie (Agent 8)
{platform_strategy}

## Monetarisierungs-Report (Agent 9)
{monetization_report}

Erstelle einen Release-Plan-Report im folgenden Format:

# Release-Plan-Report: {app_name}

## Release-Phasen
### Phase 1: [z.B. Closed Beta]
  - Ziel: ...
  - Dauer: ... Wochen
  - Teilnehmer: ...
  - Erfolgskriterien: ...
### Phase 2: [z.B. Soft Launch]
  - Ziel: ...
  - Dauer: ...
  - Region(en): ...
  - Erfolgskriterien: ...
### Phase 3: [z.B. Full Launch]
  - Ziel: ...
  - Datum/Zeitrahmen: ...
  - Region(en): ...

## Regionale Strategie
  | Region | Phase | Begründung | Lokalisierung nötig |
  |---|---|---|---|

## App Store Submission
### Apple App Store
  - Review-Dauer: ca. ... Tage
  - Häufige Ablehnungsgründe in dieser Kategorie: ...
  - Checkliste vor Submission: ...
### Google Play (falls zutreffend)
  - Review-Dauer: ca. ... Tage
  - Checkliste vor Submission: ...

## Launch-Tag Checkliste
  - [ ] Server-Infrastruktur getestet und skalierbar
  - [ ] Monitoring und Alerting aktiv
  - [ ] Support-Kanäle eingerichtet
  - [ ] Social Media Accounts vorbereitet
  - [ ] Website live
  - [ ] Analytics und Tracking aktiv
  - [ ] Crash-Reporting aktiv
  - [ ] Backup- und Rollback-Plan dokumentiert
  - [ ] App Store Listing finalisiert
  - [ ] Press Kit versendet

## Post-Launch Plan (erste 30 Tage)
  - Woche 1: ...
  - Woche 2: ...
  - Woche 3: ...
  - Woche 4: ...
### KPI-Monitoring
  | Metrik | Zielwert | Frequenz |
  |---|---|---|
  | DAU | ... | täglich |
  | Retention D1/D7/D30 | ...% / ...% / ...% | täglich |
  | ARPU | ...€ | wöchentlich |
  | Crash Rate | <...% | täglich |
  | App Store Rating | >... | täglich |

## Risiken und Fallback
  | Risiko | Wahrscheinlichkeit | Impact | Gegenmaßnahme |
  |---|---|---|---|
  | Downloads unter Erwartung | ... | ... | ... |
  | Server-Probleme Launch-Tag | ... | ... | ... |
  | App Store Ablehnung | ... | ... | ... |
  | Negative Review-Welle | ... | ... | ... |

## Gesamt-Timeline
  | Meilenstein | Zeitpunkt |
  |---|---|
  | Entwicklung abgeschlossen | ... |
  | Closed Beta Start | ... |
  | Soft Launch | ... |
  | Full Launch | ... |
  | Erstes Content-Update | ... |

REGELN:
- Realistische Timelines basierend auf den Plattform- und Monetarisierungs-Entscheidungen
- KPI-Zielwerte konkret und branchenüblich
- Risiken mit echten Gegenmaßnahmen, nicht nur "beobachten"
- Launch-Checkliste vollständig und praxistauglich
- Regionale Strategie konsistent mit Plattform-Strategie"""

    print(f"[{AGENT_NAME}] Generating Release Plan...")
    return _call_llm(prompt, max_tokens=6000, agent_name=AGENT_NAME, profile="standard")
