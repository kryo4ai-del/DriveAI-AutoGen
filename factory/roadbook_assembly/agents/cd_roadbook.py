"""Creative Director Technical Roadbook — Kapitel 6 Roadbook Assembly (Agent 23)

Role: Creates the Creative Director Technical Roadbook (30-50 pages).
Uses TheBrain model_provider for optimal model selection.
"""

from dotenv import load_dotenv

from factory.brand.brand_loader import load_brand_context
from factory.roadbook_assembly.config import get_fallback_model

load_dotenv()

AGENT_NAME = "CDRoadbook"

# Inject full brand identity for roadbook creation
_BRAND_CONTEXT = load_brand_context(department="roadbook_assembly")

CD_SYSTEM = "Du bist der Technical Roadbook-Autor der DAI-Core Swarm Factory. Schreibe praezise, technisch, actionable. Jede Anweisung muss so klar sein dass die Produktionslinie ohne Rueckfragen bauen kann. VERBINDLICHE Vorgaben klar von Empfehlungen trennen." + _BRAND_CONTEXT

CD_STRUCTURE = """Erstelle das Creative Director Technical Roadbook mit diesen 14 Sektionen.
Das Dokument muss 30-50 Seiten lang sein — ALLES muss drin sein, nichts auslassen.

# Creative Director Technical Roadbook: [App Name]
## Version: 1.0 | Status: VERBINDLICH fuer alle Produktionslinien

---

## 1. Produkt-Kurzprofil
- App Name, One-Liner, Plattformen, Tech-Stack, Zielgruppe

## 2. Design-Vision (VERBINDLICH)
- Design-Briefing (der 5-10 Saetze Absatz — WOERTLICH uebernehmen, wird in JEDEN Prompt eingefuegt)
- Emotionale Leitlinie pro App-Bereich (Tabelle: Bereich | Emotion | Energie | Beschreibung)
- Differenzierungspunkte (PFLICHT, Tabelle: # | Differenzierung | Beschreibung | Screens | Status=MUSS)
- Anti-Standard-Regeln (VERBOTE, Tabelle: # | VERBOTEN | STATTDESSEN | Screens | Begruendung)
- Wow-Momente (PFLICHT, Tabelle: # | Name | Screen | Was passiert | Warum kritisch)
- Interaktions-Prinzipien (Touch, Animation, Feedback, Sound)

## 3. Stil-Guide (VERBINDLICH)
- Farbpalette (Hex-Codes + Dark Mode + Verwendungsregeln)
- Typografie (Fonts, Gewichte, Lizenz)
- Illustrations-Stil
- Icon-System (Library, Stil, Groessen)
- Animations-Stil (Dauer, Easing, Performance-Constraints: max Lottie KB, max Partikel, Fallback)

## 4. Feature-Map
### Phase A — Soft-Launch MVP
- Vollstaendige Feature-Tabelle (ID | Name | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten)
- Budget Phase A
### Phase B — Full Production
- Vollstaendige Feature-Tabelle
- Budget Phase B
### Backlog
- Feature-Tabelle mit geplanter Version

## 5. Abhaengigkeits-Graph & Kritischer Pfad
- Build-Reihenfolge (welche Features zuerst)
- Kritischer Pfad mit Dauer in Wochen
- Parallelisierbare Feature-Gruppen

## 6. Screen-Architektur (VERBINDLICH)
- Screen-Uebersicht (Tabelle: ID | Name | Typ | Zweck | Features | States)
- Hierarchie (Tabs, Subscreens, Modals, Overlays)
- Navigation
- Alle 7 User Flows (mit Screen-Sequenz, Taps, Zeitbudget, Fallback)
- Edge Cases (Tabelle: Situation | Screens | Verhalten)
- Phase-B Screens mit Platzhaltern

## 7. Asset-Liste (VERBINDLICH)
- Vollstaendige Asset-Tabelle (ID | Name | Screen | Kategorie | Quelle | Format | Prioritaet)
- Beschaffungswege pro Asset (Custom/Stock/AI/Free/Native)
- Format-Anforderungen pro Plattform (Sprites, Icons, Animations, App-Icons)
- Plattform-Varianten Anzahl
- Dark-Mode-Varianten

## 8. KI-Produktions-Warnungen (VERBINDLICH — KRITISCH)
### Warnungen aus dem Visual Audit
| # | Screen | Stelle | Was KI falsch macht | Was stattdessen | Prompt-Anweisung fuer Produktionslinie |
### Warnungen aus der Design-Vision
| # | Screen | Standard den KI waehlt | Was Design-Vision verlangt | Prompt-Anweisung |
(JEDE Warnung = eine explizite Anweisung die in den Produktions-Prompt eingefuegt wird)

## 9. Legal-Anforderungen fuer Produktion
- Consent-Screens (DSGVO, ATT): Was muss implementiert werden
- Age-Gate / COPPA: Alterspruefung + eingeschraenkter Modus
- Datenschutz: Welche Daten sammeln/nicht sammeln, AVV-Vertraege
- Pflicht-UI: Datenschutzerklaerung, Impressum, KI-Kennzeichnung
- App Store Compliance: Apple + Google Richtlinien

## 10. Tech-Stack Detail
- Engine + Version (Unity + Plugins)
- Backend-Dienste (Firebase, Cloud Run, etc.)
- SDKs (Ads, Analytics, Auth, Payment) mit Versionen
- CI/CD Pipeline
- Monitoring + Crash-Reporting

## 11. Release-Anforderungen
- Phase 0 (Closed Beta): Ziel, Dauer, Teilnehmer, Erfolgskriterien
- Phase 1 (Soft Launch): Regionen, KPIs, Go/No-Go Kriterien
- Phase 2 (Global Launch): Checkliste
- App Store Submission Checklisten (Apple + Google separat)
- Post-Launch Plan (erste 4 Wochen)

## 12. KPIs fuer Produktion
- Business KPIs (DAU, Retention D1/D7/D30, ARPU, Conversion)
- Technische KPIs (App-Start-Zeit, KI-Latenz, Crash-Rate, App-Groesse)
- Zielwerte pro Phase (Tabelle)

## 13. Design-Checkliste (Endabnahme vor Release)
- Vollstaendige Checkliste aus Design-Vision
- Jeder Punkt muss bestanden werden
- Verantwortlicher fuer jeden Punkt

## 14. Quellenverzeichnis
- Alle 20 Reports mit Kapitel-Zuordnung und Datum

REGELN:
- ALLES muss drin sein — Features, Screens, Assets, Warnungen, Legal, Tech, KPIs
- VERBINDLICH vs EMPFOHLEN klar trennen (VERBINDLICH = fett markiert)
- KI-Warnungen MUESSEN als Prompt-Anweisungen formuliert sein (Copy-Paste-Ready)
- Design-Briefing WOERTLICH uebernehmen
- Anti-Standard-Regeln WOERTLICH uebernehmen
- Tabellen VOLLSTAENDIG (alle Features, alle Screens, alle Assets — nicht abkuerzen)
- Wow-Momente mit konkreter Implementierungsanweisung
- Dieses Dokument muss so detailliert sein dass die Produktionslinie OHNE RUECKFRAGEN bauen kann"""


def run(all_reports: dict) -> str:
    """Generate the Creative Director Technical Roadbook."""
    from factory.roadbook_assembly.config import get_agent_model

    selection = get_agent_model("cd_roadbook")
    model = selection.get("model", "")
    provider = selection.get("provider", "")

    all_input = _build_input(all_reports)
    print(f"[{AGENT_NAME}] Model: {model} ({provider}) via TheBrain")
    print(f"[{AGENT_NAME}] Input: {len(all_input) // 1000}k chars (all reports)")

    report = _call_via_router(model, provider, all_input, selection)
    if report:
        return report

    print(f"[{AGENT_NAME}] Fallback: 4 Anthropic Sonnet calls...")
    return _call_fallback(all_reports)


def _build_input(data: dict) -> str:
    parts = []
    for group_key, label in [
        ("group_phase1", "PHASE 1: PRE-PRODUCTION"),
        ("group_k3", "KAPITEL 3: MARKET STRATEGY"),
        ("group_k4", "KAPITEL 4: MVP & FEATURE SCOPE"),
        ("group_k45", "KAPITEL 4.5: DESIGN VISION"),
        ("group_k5", "KAPITEL 5: VISUAL & ASSET AUDIT"),
    ]:
        content = data.get(group_key, "")
        if content:
            parts.append(f"{'=' * 60}\n{label}\n{'=' * 60}\n{content}")
    return "\n\n".join(parts)


def _call_via_router(model: str, provider: str, all_input: str, selection: dict) -> str | None:
    try:
        from factory.brain.model_provider import get_router

        router = get_router()
        litellm_name = selection.get("litellm_model_name", f"{provider}/{model}")

        split = selection.get("split_strategy", {})
        if split.get("alternative_model"):
            try:
                from factory.brain.model_provider import get_registry
                alt_info = get_registry().get_model(split["alternative_model"])
                if alt_info:
                    litellm_name = alt_info.litellm_model_name
                    model = split["alternative_model"]
                    provider = split.get("alternative_provider", provider)
            except Exception:
                pass

        print(f"[{AGENT_NAME}] Generating CD Technical Roadbook via {litellm_name}...")

        prompt = f"""## Alle Reports aus 5 Kapiteln (Rohdaten — 20 Reports)

{all_input}

---

{CD_STRUCTURE}"""

        response = router.call(
            model_id=model,
            provider=provider,
            messages=[
                {"role": "system", "content": CD_SYSTEM},
                {"role": "user", "content": prompt},
            ],
            max_tokens=30000,
        )

        report = response.content
        cost = getattr(response, "cost_usd", 0) or 0
        print(f"[{AGENT_NAME}] Generated: {len(report) // 1000}k chars, Cost: ${cost:.4f}")
        return report

    except Exception as e:
        print(f"[{AGENT_NAME}] Router call failed: {e}")
        return None


def _call_fallback(data: dict) -> str:
    """Fallback: 4 Anthropic Sonnet calls split by topic."""
    import anthropic

    client = anthropic.Anthropic()
    model = get_fallback_model()
    parts = []

    # Call 1: Sections 1-3 (Produkt + Design-Vision + Stil-Guide)
    print(f"[{AGENT_NAME}] Fallback Call 1/4: Sections 1-3...")
    input1 = (data.get("group_k45", "") + "\n\n" + data.get("group_k5", ""))[:60000]
    resp1 = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": f"""{CD_SYSTEM}

{input1}

Erstelle NUR Sektionen 1-3 des CD Technical Roadbook:
1. Produkt-Kurzprofil
2. Design-Vision (VERBINDLICH) — Design-Briefing WOERTLICH uebernehmen
3. Stil-Guide (VERBINDLICH) — Hex-Codes, Fonts, Animations-Constraints"""}],
    )
    parts.append(resp1.content[0].text)

    # Call 2: Sections 4-6 (Features + Screens)
    print(f"[{AGENT_NAME}] Fallback Call 2/4: Sections 4-6...")
    input2 = data.get("group_k4", "")[:60000]
    resp2 = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": f"""{CD_SYSTEM}

{input2}

Erstelle NUR Sektionen 4-6:
4. Feature-Map (Phase A + Phase B + Backlog, VOLLSTAENDIGE Tabellen)
5. Abhaengigkeits-Graph & Kritischer Pfad
6. Screen-Architektur (alle Screens, alle Flows, Edge Cases)"""}],
    )
    parts.append(resp2.content[0].text)

    # Call 3: Sections 7-8 (Assets + KI-Warnungen)
    print(f"[{AGENT_NAME}] Fallback Call 3/4: Sections 7-8...")
    input3 = data.get("group_k5", "")[:60000]
    resp3 = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": f"""{CD_SYSTEM}

{input3}

Erstelle NUR Sektionen 7-8:
7. Asset-Liste (VOLLSTAENDIG — alle Assets mit ID, Quelle, Format)
8. KI-Produktions-Warnungen (JEDE Warnung als Prompt-Anweisung formuliert)"""}],
    )
    parts.append(resp3.content[0].text)

    # Call 4: Sections 9-14 (Legal + Tech + Release + KPIs + Checkliste)
    print(f"[{AGENT_NAME}] Fallback Call 4/4: Sections 9-14...")
    input4 = "\n\n".join([
        data.get("group_phase1", "")[:20000],
        data.get("group_k3", "")[:20000],
        data.get("group_k45", "")[:10000],
    ])
    resp4 = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": f"""{CD_SYSTEM}

{input4}

Erstelle NUR Sektionen 9-14:
9. Legal-Anforderungen (Consent, Age-Gate, DSGVO, App Store)
10. Tech-Stack Detail (Engine, Backend, SDKs, CI/CD, Monitoring)
11. Release-Anforderungen (Beta, Soft Launch, Global, Checklisten)
12. KPIs fuer Produktion (Business + Technisch, Tabelle)
13. Design-Checkliste (Endabnahme)
14. Quellenverzeichnis"""}],
    )
    parts.append(resp4.content[0].text)

    report = "\n\n---\n\n".join(parts)
    print(f"[{AGENT_NAME}] Fallback complete: {len(report) // 1000}k chars (4 Sonnet calls)")
    return report
