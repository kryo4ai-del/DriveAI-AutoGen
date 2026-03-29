"""UX-Emotion-Architect — Kapitel 4.5 Design Vision (Agent 17b)

Role: Defines emotional experience per app area, interaction concepts,
micro-interactions and wow-moments.
"""

from dotenv import load_dotenv

from factory.pre_production.tools.web_research import search_and_fetch

load_dotenv()

from factory.design_vision.config import get_fallback_model

AGENT_NAME = "EmotionArchitect"


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
            model=get_fallback_model(),
            max_tokens=max_tokens,
            messages=[{"role": "user", "content": prompt}]
        )
        return resp.content[0].text


def run(all_reports: dict, trend_breaker_report: str) -> str:
    """Define emotional experience, interactions, and wow-moments."""
    screen_arch = all_reports.get("screen_architecture", "")
    audience = all_reports.get("audience_profile", "")
    concept = all_reports.get("concept_brief", "")

    # Web research
    print(f"[{AGENT_NAME}] Researching UX innovations...")
    search_results = _research_ux()

    # Call 1: Emotion Map + Interaction Concepts per Screen
    print(f"[{AGENT_NAME}] Building Emotion Map + Interaction Concepts (Call 1/2)...")
    part1 = _emotion_map(trend_breaker_report, screen_arch, audience, concept, search_results)
    print(f"[{AGENT_NAME}] -> {len(part1)} chars")

    # Call 2: Micro-Interactions + Wow-Momente
    print(f"[{AGENT_NAME}] Defining Micro-Interactions + Wow-Momente (Call 2/2)...")
    part2 = _micro_and_wow(part1, trend_breaker_report)
    print(f"[{AGENT_NAME}] -> {len(part2)} chars")

    title = all_reports.get("idea_title", "App")
    return f"# UX-Emotion-Report: {title}\n\n{part1}\n\n---\n\n{part2}"


def _research_ux() -> str:
    queries = [
        "best micro-interactions mobile app 2025 2026 examples",
        "mobile game UX emotion design haptic feedback sound",
        "app design wow moment viral screenshot shareworthy UI",
    ]
    parts = []
    for q in queries:
        print(f"[{AGENT_NAME}] Searching: {q}")
        data = search_and_fetch(q, num_results=3, fetch_top_n=1)
        parts.append(f"### {q}")
        for r in data.get("results", []):
            parts.append(f"- {r.get('title', '')} — {r.get('snippet', '')}")
        for fc in data.get("fetched_content", []):
            if fc.get("content"):
                parts.append(fc["content"][:1500])
        parts.append("")
    return "\n".join(parts)


def _emotion_map(tb_report, screen_arch, audience, concept, search_results) -> str:
    prompt = f"""Du bist ein UX-Emotion-Architect. Du designst nicht wie eine App AUSSIEHT, sondern wie sie sich ANFUEHLT.

## Design-Differenzierungs-Report (Agent 17a)
{tb_report[:8000]}

## Screen-Architektur (22 Screens + 7 Flows)
{screen_arch[:6000]}

## Zielgruppen-Profil
{audience[:3000]}

## Concept Brief
{concept[:3000]}

## Web-Recherche: UX-Innovationen
{search_results[:4000]}

Antworte in Markdown (KEIN JSON):

# UX-Emotion-Map

## Gesamt-Emotion der App
- In einem Satz: "Diese App fuehlt sich an wie ..."
- Energie-Level: X/10 (1=meditativ, 10=explosiv)
- Visuelle Temperatur: [Warm / Kuehl / Neon / Organisch / Futuristisch / ...]

## Emotion pro App-Bereich
| Bereich | Emotion | Energie | Konkrete Beschreibung |
|---|---|---|---|
| Onboarding | ... | X/10 | Der Nutzer fuehlt ... weil ... |
| Core Loop (Match-3) | ... | X/10 | ... |
| Reward / Ergebnis | ... | X/10 | ... |
| Shop / Monetarisierung | ... | X/10 | ... |
| Social / Challenges | ... | X/10 | ... |
| Story / Narrative | ... | X/10 | ... |
| Settings / Legal | ... | X/10 | ... |

## Interaktions-Konzepte pro Screen

### S001: Splash / Loading
- **Emotion:** ...
- **Interaktion:** (KONKRET: "Beim Laden pulsiert das Logo wie ein Herzschlag")
- **Touch/Gesten:** ...
- **Sound:** ...

### S002: Consent-Dialog
- **Emotion:** ...
- **Interaktion:** (Wie macht man einen Consent-Dialog der NICHT nervt?)

### S003: Onboarding-Match
- **Emotion:** ...
- **Interaktion:** (KRITISCHSTER Screen — hier entscheidet sich ob der Nutzer bleibt)

(Fuer JEDEN Screen der Architektur — nicht nur die wichtigsten. Mindestens die Hauptscreens S001-S015+)

REGELN:
- NICHT abstrakt sondern KONKRET ("der Button expandiert wie eine Seifenblase")
- Jeder Screen: Emotion + Interaktion + mindestens 1 besonderes Detail
- Sound-Design mitdenken (auch Stille ist Design)
- ALLE Sinne: Sehen, Hoeren, Fuehlen (Haptics)
- Casual-Spieler wollen fluessig und befriedigend, nicht komplex"""

    return _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="standard")


def _micro_and_wow(emotion_map, tb_report) -> str:
    prompt = f"""Du bist ein UX-Emotion-Architect. Definiere jetzt die Micro-Interactions und WOW-Momente.

## Emotion-Map und Interaktions-Konzepte
{emotion_map[:10000]}

## Design-Differenzierungs-Report (Anti-Standard-Regeln)
{tb_report[:5000]}

Antworte in Markdown (KEIN JSON):

# Micro-Interactions & Wow-Momente

## Micro-Interactions Katalog
| Trigger | Standard-Reaktion (LANGWEILIG) | Unsere Reaktion (WOW) | Betroffene Screens | Aufwand |
|---|---|---|---|---|
| App-Start | Schwarzer Screen → Home | [kreative Alternative] | S001 | ... |
| Laden/Warten | Spinner | [kreative Alternative] | Alle | ... |
| Button-Tap | Opacity-Change | [kreative Alternative] | Alle | ... |
| Erfolg / Gewinn | Gruener Haken | [kreative Alternative mit Dopamin] | S009, S015 | ... |
| Fehler | Rote Box mit Text | [kreative Alternative] | S008, S017 | ... |
| Scrollen | Einfaches Scrollen | [kreative Alternative] | S005, S010, S012 | ... |
| Inaktivitaet (>5s) | Nichts | [Screen lebt, atmet] | Alle | ... |
| Pull-to-Refresh | Standard Pull | [kreative Alternative] | S004, S010 | ... |
| Swipe (Match-3) | Stein gleitet linear | [Physik? Magnetisch? Bounce?] | S006 | ... |
| Combo (3er) | Kurzes Blinken | [Partikel + Screen-Shake + Sound] | S006 | ... |
| Combo (4er+) | Staerkeres Blinken | [Explosion + Ketten-Reaktion] | S006 | ... |
| Kauf abgeschlossen | Bestaetigungstext | [kreative Alternative] | S014 | ... |
| Level geschafft | "Level Complete" Text | [Triumph-Gefuehl] | S015 | ... |
| Freund herausgefordert | Toast-Nachricht | [kreative Alternative] | S011 | ... |
| Battle-Pass Stufe | Progress-Bar fuellt sich | [Belohnungs-Gefuehl] | S012 | ... |
(mindestens 15 Micro-Interactions)

## WOW-Momente (PFLICHT — mindestens 3)

### Wow-Moment 1: [Name]
- **Screen:** S00X
- **Was passiert:** (Konkrete Szene — was sieht, hoert, fuehlt der Nutzer)
- **Warum WOW:** (Warum anders als alles in anderen Apps)
- **Warum teilt er es:** (Warum Screenshot oder Freund zeigen)
- **Produktionslinie-Prioritaet:** ABSOLUT — darf NICHT vereinfacht werden

### Wow-Moment 2: [Name]
...

### Wow-Moment 3: [Name]
...

## UX-Innovation-Empfehlungen
| Innovation | Beschreibung | Passt zur Zielgruppe | Umsetzbar mit Stack | Prioritaet |
|---|---|---|---|---|
(mindestens 5 Innovationen)

REGELN:
- Micro-Interactions: JEDER Standard-Moment wird durch besseren ersetzt
- Wow-Momente: MINDESTENS 3 — die Momente die die App zum Gespraechsthema machen
- Wow-Momente duerfen NIEMALS vereinfacht werden — sie sind heilig
- Alles muss zur Zielgruppe passen: smooth und satisfying, nicht overwhelming
- Aufwand-Einschaetzung pro Micro-Interaction"""

    return _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="standard")
