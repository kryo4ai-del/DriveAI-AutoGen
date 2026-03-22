"""Design-Vision-Compiler — Kapitel 4.5 Design Vision (Agent 17c)

Role: Compiles everything into a binding Design-Vision-Document for the
production pipeline.
"""

import anthropic
from dotenv import load_dotenv

from factory.design_vision.config import AGENT_MODEL_MAP

load_dotenv()

AGENT_NAME = "VisionCompiler"


def run(all_reports: dict, trend_breaker_report: str, emotion_architect_report: str) -> str:
    """Compile binding Design-Vision-Document from 17a + 17b outputs."""
    client = anthropic.Anthropic()
    model = AGENT_MODEL_MAP["vision_compiler"]

    platform = all_reports.get("platform_strategy", "")

    # Call 1: Binding Rules + Design-Briefing
    print(f"[{AGENT_NAME}] Compiling Teil 1: Verbindliche Vorgaben (Call 1/2)...")
    part1 = _compile_binding(client, model, trend_breaker_report, emotion_architect_report, platform)
    print(f"[{AGENT_NAME}] -> {len(part1)} chars")

    # Call 2: Recommendations + Checkliste + K5 Anschluss
    print(f"[{AGENT_NAME}] Compiling Teil 2: Empfehlungen + Checkliste (Call 2/2)...")
    part2 = _compile_recommendations(client, model, emotion_architect_report, part1)
    print(f"[{AGENT_NAME}] -> {len(part2)} chars")

    return part1 + "\n\n---\n\n" + part2


def _compile_binding(client, model, tb_report, ea_report, platform) -> str:
    prompt = f"""Du bist der Design-Vision-Compiler der DriveAI Swarm Factory. Fasse die Ergebnisse des Trend-Breakers und des Emotion-Architects in ein VERBINDLICHES Design-Dokument zusammen.

Dieses Dokument wird in JEDER nachfolgenden Pipeline-Phase als Referenz genutzt. Was hier steht, ist Gesetz fuer die Produktionslinie.

## Trend-Breaker Report (Agent 17a)
{tb_report[:12000]}

## Emotion-Architect Report (Agent 17b)
{ea_report[:12000]}

## Tech-Stack
{platform[:2000]}

Antworte in Markdown (KEIN JSON):

# Design-Vision-Dokument: [App Name]
## Version: 1.0
## Status: VERBINDLICH fuer alle nachfolgenden Pipeline-Schritte

---

## Design-Briefing (wird in jeden Produktions-Prompt injiziert)

[5-10 Saetze die die GESAMTE Design-Vision zusammenfassen. Dieser Text wird der Produktionslinie als System-Kontext mitgegeben. Er muss so klar und inspirierend sein, dass ein Entwickler oder eine KI nach dem Lesen GENAU weiss wie die App aussehen und sich anfuehlen soll.]

---

## Teil 1: Verbindliche Vorgaben

### 1.1 Emotionale Leitlinie
- Gesamt-Emotion: [aus 17b]
- Energie-Level: X/10
- Visuelle Temperatur: ...

### 1.2 Emotion pro App-Bereich (PFLICHT)
| Bereich | Emotion | Energie | Beschreibung |
|---|---|---|---|
(uebernehmen aus 17b, konsolidiert)

### 1.3 Differenzierungspunkte (PFLICHT — mindestens 3)
| # | Differenzierung | Beschreibung | Betroffene Screens | Status |
|---|---|---|---|---|
(uebernehmen aus 17a, konsolidiert mit 17b)

### 1.4 Anti-Standard-Regeln (VERBOTE — mindestens 4)
| # | VERBOTEN | STATTDESSEN | Betroffene Screens | Begruendung |
|---|---|---|---|---|
(uebernehmen aus 17a)

### 1.5 Wow-Momente (PFLICHT-IMPLEMENTIERUNG — mindestens 3)
| # | Name | Screen | Was passiert | Warum kritisch |
|---|---|---|---|---|
(uebernehmen aus 17b, die wichtigsten 3-5)

### 1.6 Interaktions-Prinzipien (PFLICHT)
- Touch-Reaktion: ...
- Animations-Prinzip: ...
- Feedback-Prinzip: ...
- Sound-Prinzip: ...
(konsolidiert aus 17b)

### 1.7 Konflikte aufgeloest
| Konflikt | 17a wollte | Tech-Realitaet | Loesung |
|---|---|---|---|

REGELN:
- Teil 1 ist VERBINDLICH — keine Verhandlung, keine Vereinfachung
- Jeder Punkt KONKRET — "Seifenblasen-Expansion mit 300ms ease-out" statt "innovative Animation"
- Wow-Momente duerfen NIEMALS gestrichen werden
- Anti-Standard-Regeln duerfen NIEMALS umgangen werden
- Bei Tech-Konflikten: beste UMSETZBARE Alternative waehlen"""

    response = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


def _compile_recommendations(client, model, ea_report, part1) -> str:
    prompt = f"""Du bist der Design-Vision-Compiler. Erstelle Teil 2: Empfehlungen, Micro-Interactions, und die Abnahme-Checkliste.

## Emotion-Architect Report (Micro-Interactions + UX-Innovationen)
{ea_report[:12000]}

## Teil 1 (Kontext)
{part1[:6000]}

Antworte in Markdown (KEIN JSON):

## Teil 2: Empfehlungen

### 2.1 Micro-Interactions (EMPFOHLEN — Top 15)
| # | Trigger | Unsere Reaktion | Screens | Aufwand | Prioritaet |
|---|---|---|---|---|---|
(Top 15 aus 17b, nach Prioritaet sortiert: Hoch → Mittel → Niedrig)

### 2.2 UX-Innovationen (EMPFOHLEN)
| Innovation | Beschreibung | Aufwand | Prioritaet |
|---|---|---|---|
(Top 5 aus 17b, nach Machbarkeit und Impact)

### 2.3 Sound-Design (EMPFOHLEN)
| Moment | Sound-Konzept | Screens |
|---|---|---|
(wichtigste Sound-Momente aus 17b)

---

## Design-Checkliste (fuer Endabnahme nach Produktion)

- [ ] Differenzierungspunkt 1 ist visuell erkennbar und unterscheidet sich klar vom Genre-Standard
- [ ] Differenzierungspunkt 2 ist visuell erkennbar
- [ ] Differenzierungspunkt 3 ist visuell erkennbar
- [ ] KEINE Anti-Standard-Regel wurde verletzt (alle Verbote eingehalten)
- [ ] Wow-Moment 1 ist vollstaendig implementiert und erzeugt "wow"-Effekt
- [ ] Wow-Moment 2 ist vollstaendig implementiert
- [ ] Wow-Moment 3 ist vollstaendig implementiert
- [ ] Emotionale Leitlinie ist in ALLEN App-Bereichen spuerbar
- [ ] Interaktions-Prinzipien werden durchgaengig eingehalten
- [ ] Die App sieht NICHT aus wie die Top-3-Wettbewerber
- [ ] Ein Testnutzer sagt mindestens einmal "wow" oder "cool" in den ersten 60 Sekunden
- [ ] Micro-Interactions mit Prioritaet "Hoch" sind implementiert
- [ ] Core-Loop fuehlt sich befriedigend und fluessig an (nicht generisch)

---

## Anschluss an Kapitel 5 (Asset Audit)

### Vorgaben fuer Agent 17/18 (Asset-Discovery + Strategie):
- Stil-Guide MUSS die Farbpalette, Typografie und Illustrations-Stil aus dieser Design-Vision uebernehmen
- Assets MUESSEN zur emotionalen Leitlinie passen
- Jedes Asset das einem Wow-Moment dient hat HOECHSTE Prioritaet

### Vorgaben fuer Agent 19/20 (Consistency-Check + Review):
- Neue Ampel-Kategorie: Rot "Verstoss gegen Design-Vision"
- Zusaetzliche KI-Warnungen: "Hier wird die Produktions-KI den Standard-Weg nehmen — die Design-Vision verlangt [Innovation]"
- Design-Checkliste wird ins Human Review Gate integriert

### Design-Briefing fuer die Produktionslinie:
(Der Text aus Abschnitt "Design-Briefing" oben wird in jeden Code-Generation-Prompt injiziert)

REGELN:
- Checkliste muss PRUEFBAR sein — keine subjektiven Kriterien
- Kapitel-5-Anschluss KONKRET — nicht "beruecksichtigen" sondern "diese Farben, diese Fonts"
- Empfehlungen nach Prioritaet sortiert — bei Zeitdruck nur "Hoch"-Items"""

    response = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text
