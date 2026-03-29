"""Visual-Consistency — Kapitel 5 Visual & Asset Audit

Role: Simulates user walkthrough per flow, rates every spot with traffic lights,
identifies KI-development-warnings, scans for placeholders, checks dark mode
and accessibility.
"""

from dotenv import load_dotenv

load_dotenv()

AGENT_NAME = "VisualConsistency"


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


def run(all_reports: dict, asset_discovery: str, asset_strategy: str) -> str:
    """Simulate user walkthroughs and check visual consistency."""
    screen_arch = all_reports.get("screen_architecture", "")

    # Call 1: Flows 1-4 + KI-Warnungen
    print(f"[{AGENT_NAME}] Simulating Flows 1-4 + KI-Warnungen (Call 1/3)...")
    part1 = _check_flows_1_4(screen_arch, asset_discovery)
    _log_counts(part1, "Flows 1-4")

    # Call 2: Flows 5-7 + Platzhalter-Scan
    print(f"[{AGENT_NAME}] Simulating Flows 5-7 + Platzhalter-Scan (Call 2/3)...")
    part2 = _check_flows_5_7(screen_arch, asset_discovery)
    _log_counts(part2, "Flows 5-7")

    # Call 3: Dark Mode + Accessibility + Konsistenz
    print(f"[{AGENT_NAME}] Dark Mode + Accessibility + Konsistenz (Call 3/3)...")
    part3 = _check_dark_a11y(screen_arch, asset_discovery, asset_strategy)
    _log_counts(part3, "Dark/A11Y")

    title = all_reports.get("idea_title", "App")
    return _merge_report(title, part1, part2, part3)


def _log_counts(text: str, label: str):
    red = text.count("\U0001f534")
    yellow = text.count("\U0001f7e1")
    green = text.count("\U0001f7e2")
    warn = text.count("\u26a0\ufe0f")
    print(f"[{AGENT_NAME}] -> {label}: {red} \U0001f534, {yellow} \U0001f7e1, {green} \U0001f7e2, {warn} \u26a0\ufe0f")


def _check_flows_1_4(screen_arch, asset_discovery) -> str:
    prompt = f"""Du bist ein UX-Tester der eine App AUS NUTZERSICHT durchgeht. Du simulierst den ersten App-Start eines echten Nutzers und pruefst bei JEDEM Screen: Sieht der Nutzer was er erwartet, oder fehlt etwas Visuelles?

Dein Spezialauftrag: Den "Fahrschul-App-Fehler" verhindern — Stellen finden wo die Entwicklungs-KI Text generieren wird wo der Nutzer ein Bild erwartet.

## Screen-Architektur
{screen_arch[:12000]}

## Asset-Discovery-Liste
{asset_discovery[:12000]}

Gehe die Flows 1-4 durch, Screen fuer Screen:
- Flow 1: Onboarding (Erst-Start)
- Flow 2: Core Loop (wiederkehrend)
- Flow 3: Erster Kauf
- Flow 4: Social Challenge

Antworte in Markdown (KEIN JSON):

# Visual-Consistency-Check: Flows 1-4

## Ampel-Uebersicht
| Screen | \U0001f534 | \U0001f7e1 | \U0001f7e2 | \u26a0\ufe0f | Status |
|---|---|---|---|---|---|
(alle Screens aus Flow 1-4)

## Flow 1: Onboarding — Detail

### [Screen-Name]
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
(jeden Screen einzeln)

## Flow 2: Core Loop — Detail
(gleiche Struktur)

## Flow 3: Erster Kauf — Detail
(gleiche Struktur)

## Flow 4: Social Challenge — Detail
(gleiche Struktur)

## \u26a0\ufe0f KI-Entwicklungs-Warnungen (Flows 1-4)

| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|
(KONKRETE Anweisungen — "Sprite Sheet verwenden" statt "Bild fehlt")

REGELN:
- Bei JEDEM Screen fragen: "Was sieht der Nutzer WIRKLICH?"
- \U0001f534 Blocker: App NICHT NUTZBAR ohne Asset
- \U0001f7e1 Schlechte UX: Funktioniert, fuehlt sich billig an
- \U0001f7e2 Nice-to-have: Verbesserung, kein Problem ohne
- \u26a0\ufe0f KI-Warnung: Entwicklungs-KI wird WAHRSCHEINLICH das Falsche tun
- Jede KI-Warnung MUSS eine KONKRETE Anweisung haben"""

    return _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="dev")


def _check_flows_5_7(screen_arch, asset_discovery) -> str:
    prompt = f"""Du bist ein UX-Tester. Fortsetzung der Visual-Consistency-Pruefung.

## Screen-Architektur
{screen_arch[:10000]}

## Asset-Discovery-Liste
{asset_discovery[:10000]}

Gehe die Flows 5-7 durch + Platzhalter-Scan:
- Flow 5: Battle-Pass
- Flow 6: Rewarded Ad
- Flow 7: Consent Detail

Antworte in Markdown (KEIN JSON):

# Visual-Consistency-Check: Flows 5-7 + Platzhalter

## Flow 5: Battle-Pass — Detail
(gleiche Struktur wie vorher)

## Flow 6: Rewarded Ad — Detail
(gleiche Struktur)

## Flow 7: Consent Detail — Detail
(BESONDERS auf Legal-UI: Consent-Design, Age-Gate, Privacy-Badges)

## \u26a0\ufe0f KI-Entwicklungs-Warnungen (Flows 5-7)
| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|

## \U0001f534 Platzhalter-Scan

Scanne ALLE Screens auf Platzhalter die in Production bleiben koennten:

| # | Screen | Element | Platzhalter-Typ | Risiko | Was stattdessen da sein muss |
|---|---|---|---|---|---|

Platzhalter-Typen:
- Graue Boxen mit "Image" oder "Placeholder" Text
- SF Symbols wo Custom-Icons sein sollten
- Systemfarben wo Markenfarben sein sollten
- Standard-Profilbilder ohne personalisierbare Alternative
- Generische Error-Screens ohne Illustration
- Leere Screens ohne Empty-State-Illustration

REGEL: Jeder Platzhalter ist automatisch \U0001f534 — Platzhalter in Production sind IMMER ein Blocker."""

    return _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="dev")


def _check_dark_a11y(screen_arch, asset_discovery, asset_strategy) -> str:
    prompt = f"""Du bist ein Accessibility-Experte und Visual-Consistency-Pruefer.

## Asset-Strategie (Stil-Guide mit Farben)
{asset_strategy[:6000]}

## Screen-Architektur
{screen_arch[:6000]}

## Asset-Discovery (mit Dark-Mode-Markierungen)
{asset_discovery[:6000]}

Pruefe drei Bereiche. Antworte in Markdown (KEIN JSON):

# Konsistenz, Dark Mode & Accessibility

## Dark-Mode-Konsistenz
| Screen | Dark-Mode-Status | Probleme | Betroffene Assets |
|---|---|---|---|
(alle Screens)

## Accessibility-Check

### Farbkontrast (WCAG AA)
| Element | Vordergrund | Hintergrund | Geschaetztes Ratio | Ziel | Status |
|---|---|---|---|---|---|
(Hex-Werte aus Stil-Guide verwenden, Ratio schaetzen)

### Touch-Targets
| Screen | Element | Geschaetzte Groesse | Minimum | Status |
|---|---|---|---|---|

### VoiceOver / TalkBack
| Screen | Element ohne Label | Empfohlenes Label |
|---|---|---|

### Reduced Motion
| Animation | Screen | Statischer Fallback | Status |
|---|---|---|---|

## Stil-Konsistenz ueber alle Screens
| Kriterium | Status | Anmerkung |
|---|---|---|
| Farbschema einheitlich | ... | ... |
| Icon-Stil konsistent | ... | ... |
| Layout-System konsistent | ... | ... |
| Animations-Sprache einheitlich | ... | ... |
| Typografie konsistent | ... | ... |
| Zielgruppen-Passung | ... | ... |

REGELN:
- Farbkontrast-Ratios SCHAETZEN basierend auf Hex-Werten
- Touch-Targets: iOS min 44pt, Android min 48dp
- VoiceOver: Jedes interaktive Element braucht ein Label
- Reduced Motion: Jede Animation braucht statischen Fallback"""

    return _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="dev")


def _merge_report(title: str, part1: str, part2: str, part3: str) -> str:
    # Count totals across all parts
    full = part1 + part2 + part3
    red = full.count("\U0001f534")
    yellow = full.count("\U0001f7e1")
    green = full.count("\U0001f7e2")
    warn = full.count("\u26a0\ufe0f")

    header = f"""# Visual-Consistency-Report: {title}

## Zusammenfassung
- **Geprueft:** 22 Screens, 7 User Flows
- **\U0001f534 Blocker:** {red} Stellen
- **\U0001f7e1 Schlechte UX:** {yellow} Stellen
- **\U0001f7e2 Nice-to-have:** {green} Stellen
- **\u26a0\ufe0f KI-Warnungen:** {warn} Stellen

---

"""
    return header + part1 + "\n\n---\n\n" + part2 + "\n\n---\n\n" + part3
