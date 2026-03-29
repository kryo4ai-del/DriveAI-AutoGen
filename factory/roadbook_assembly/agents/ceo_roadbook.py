"""CEO Strategic Roadbook — Kapitel 6 Roadbook Assembly (Agent 22)

Role: Creates the CEO Strategic Roadbook (15-25 pages).
Uses TheBrain model_provider for optimal model selection.
"""

from dotenv import load_dotenv

from factory.brand.brand_loader import load_brand_context
from factory.roadbook_assembly.config import get_fallback_model

load_dotenv()

AGENT_NAME = "CEORoadbook"

# Inject full brand identity for roadbook creation
_BRAND_CONTEXT = load_brand_context(department="roadbook_assembly")

CEO_SYSTEM = "Du bist ein strategischer Autor fuer CEO-Dokumente der DAI-Core Swarm Factory. Klar, praezise, nicht-technisch, Fokus auf Zahlen und Entscheidungen." + _BRAND_CONTEXT

CEO_STRUCTURE = """Erstelle das CEO Strategic Roadbook mit diesen 13 Sektionen:

# CEO Strategic Roadbook: [App Name]

## 1. Executive Summary (1 Seite)
- Was: Produkt in 2-3 Saetzen
- Warum: Marktluecke + Differenzierung
- Investment: Gesamtbudget bis Launch
- Break-Even: Monat X (realistisch)
- Gesamtrisiko: Ampel + 1 Satz
- Empfehlung: GO / GO mit Auflagen / KILL

## 2. Produkt-Vision
- One-Liner
- Kern-Mechanik (fuer Nicht-Techniker erklaert)
- Unique Selling Points (Top 3)
- Zielgruppe (1-2 Saetze)

## 3. Markt & Wettbewerb
- Marktgroesse und Wachstum
- Top-5 Wettbewerber Tabelle (App | Downloads | Revenue | Kernmechanik)
- Identifizierte Marktluecke

## 4. Zielgruppe & Monetarisierung
- Zielgruppen-Segmente Tabelle
- Monetarisierungsmodell
- Preispunkte
- Revenue-Prognose (3 Szenarien Tabelle: Pessimistisch/Realistisch/Optimistisch)

## 5. Plattform & Technologie Ueberblick
- Welche Plattformen, in welcher Reihenfolge
- Warum diese Entscheidung (keine technischen Details)

## 6. Go-to-Market
- Release-Phasen Tabelle (Phase | Dauer | Region | Ziel)
- Marketing-Kanaele (Top 5)
- Marketing-Budget Tabelle (Phase | Kosten)

## 7. Finanzuebersicht
- Entwicklungskosten
- Marketing-Budget
- Compliance-Kosten
- Gesamtbudget bis Launch
- Break-Even Analyse (3 Szenarien)
- Worst-Case Szenario

## 8. Rechtliche Lage
- Ampel-Tabelle (Rechtsfeld | Risiko | Kosten | Zeitaufwand)
- Sofortmassnahmen vor Launch
- Hinweis: KI-basierte Ersteinschaetzung

## 9. Risikoprofil
- Top-5 Risiken Tabelle (Risiko | Wahrscheinlichkeit | Impact | Gegenmassnahme)
- Kategorien: Strategisch, Technisch, Regulatorisch

## 10. Design-Vision Kurzfassung
- Design-Briefing (5 Saetze)
- Top-3 Differenzierungen vom Genre-Standard
- Top-3 Wow-Momente

## 11. Meilenstein-Timeline
- Tabelle (Meilenstein | Zeitpunkt | Go/No-Go Gate | Budget-Freigabe)

## 12. KPIs & Erfolgskriterien
- Tabelle pro Phase (KPI | Zielwert | Messfrequenz)
- Top 5 KPIs hervorgehoben

## 13. Anhang
- Quellenverzeichnis (welche Reports als Grundlage dienten)
- Glossar fuer Investoren (ARPU, D7-Retention, eCPM, CPI, LTV, DAU, MAU etc.)

REGELN:
- KEINE technischen Details (kein Code, keine APIs, keine SDKs)
- Jede Zahl aus den Reports — nichts erfinden
- Tabellen wo moeglich
- Jede Sektion startet mit 2-3 Saetzen Zusammenfassung
- Executive Summary allein muss fuer GO-Entscheidung reichen
- Glossar am Ende mit Erklaerungen fuer Nicht-Techniker"""


def run(all_reports: dict) -> str:
    """Generate the CEO Strategic Roadbook."""
    from factory.roadbook_assembly.config import get_agent_model

    selection = get_agent_model("ceo_roadbook")
    model = selection.get("model", "")
    provider = selection.get("provider", "")

    # Build input from all chapter groups
    all_input = _build_input(all_reports)
    print(f"[{AGENT_NAME}] Model: {model} ({provider}) via TheBrain")
    print(f"[{AGENT_NAME}] Input: {len(all_input) // 1000}k chars (all reports)")

    # Try TheBrain router first
    report = _call_via_router(model, provider, all_input, selection)
    if report:
        return report

    # Fallback: 3 Anthropic Sonnet calls
    print(f"[{AGENT_NAME}] Fallback: 3 Anthropic Sonnet calls...")
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
            parts.append(f"{'='*60}\n{label}\n{'='*60}\n{content}")
    return "\n\n".join(parts)


def _call_via_router(model: str, provider: str, all_input: str, selection: dict) -> str | None:
    try:
        from factory.brain.model_provider import get_router

        router = get_router()
        litellm_name = selection.get("litellm_model_name", f"{provider}/{model}")
        max_tokens = selection.get("expected_output_tokens", 20000)

        # Use split_strategy from selection if available
        split = selection.get("split_strategy", {})
        if split.get("alternative_model"):
            alt_info = None
            try:
                from factory.brain.model_provider import get_registry
                alt_info = get_registry().get_model(split["alternative_model"])
            except Exception:
                pass
            if alt_info:
                litellm_name = alt_info.litellm_model_name
                model = split["alternative_model"]
                provider = split.get("alternative_provider", provider)

        print(f"[{AGENT_NAME}] Generating CEO Strategic Roadbook via {litellm_name}...")

        prompt = f"""## Alle Reports aus 5 Kapiteln (Rohdaten)

{all_input}

---

{CEO_STRUCTURE}"""

        response = router.call(
            model_id=model,
            provider=provider,
            messages=[
                {"role": "system", "content": CEO_SYSTEM},
                {"role": "user", "content": prompt},
            ],
            max_tokens=max_tokens,
        )

        report = response.content
        cost = getattr(response, "cost_usd", 0) or 0
        print(f"[{AGENT_NAME}] Generated: {len(report) // 1000}k chars, Cost: ${cost:.4f}")
        return report

    except Exception as e:
        print(f"[{AGENT_NAME}] Router call failed: {e}")
        return None


def _call_fallback(data: dict) -> str:
    """Fallback: 3 Anthropic Sonnet calls split by chapter groups."""
    import anthropic

    client = anthropic.Anthropic()
    model = get_fallback_model()
    parts = []

    # Call 1: Sections 1-4 (Phase 1 + Monetization)
    print(f"[{AGENT_NAME}] Fallback Call 1/3: Sections 1-4...")
    input1 = (data.get("group_phase1", "") + "\n\n" + data.get("group_k3", ""))[:60000]
    resp1 = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": f"""{CEO_SYSTEM}

{input1}

Erstelle NUR die Sektionen 1-4 des CEO Strategic Roadbook:
1. Executive Summary
2. Produkt-Vision
3. Markt & Wettbewerb
4. Zielgruppe & Monetarisierung

{CEO_STRUCTURE.split('## 5.')[0]}"""}],
    )
    parts.append(resp1.content[0].text)

    # Call 2: Sections 5-7 (Platform + Marketing + Finance)
    print(f"[{AGENT_NAME}] Fallback Call 2/3: Sections 5-7...")
    input2 = data.get("group_k3", "")[:40000]
    resp2 = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": f"""{CEO_SYSTEM}

{input2}

Erstelle NUR die Sektionen 5-7:
## 5. Plattform & Technologie Ueberblick
## 6. Go-to-Market
## 7. Finanzuebersicht"""}],
    )
    parts.append(resp2.content[0].text)

    # Call 3: Sections 8-13 (Legal + Risk + Design + Timeline + KPIs + Glossar)
    print(f"[{AGENT_NAME}] Fallback Call 3/3: Sections 8-13...")
    input3 = "\n\n".join([
        data.get("group_phase1", "")[:20000],
        data.get("group_k45", "")[:20000],
        data.get("group_k5", "")[:15000],
        data.get("group_k4", "")[:10000],
    ])
    resp3 = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": f"""{CEO_SYSTEM}

{input3}

Erstelle NUR die Sektionen 8-13:
## 8. Rechtliche Lage
## 9. Risikoprofil
## 10. Design-Vision Kurzfassung
## 11. Meilenstein-Timeline
## 12. KPIs & Erfolgskriterien
## 13. Anhang (Quellenverzeichnis + Glossar)"""}],
    )
    parts.append(resp3.content[0].text)

    report = "\n\n---\n\n".join(parts)
    print(f"[{AGENT_NAME}] Fallback complete: {len(report) // 1000}k chars (3 Sonnet calls)")
    return report
