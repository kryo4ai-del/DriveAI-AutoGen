# Factory -- New Quality Gates Proposal

Last Updated: 2026-03-12

---

## Kontext

Die Factory hat aktuell 4 Phase Gates (in `workflows/phase_gates.json`):

| Gate | Prueft |
|---|---|
| `bug_review` | Bugs, Edge Cases, Crash-Risiken |
| `refactor` | Code-Struktur, Naming, Modularitaet |
| `test_generation` | Test-Cases fuer Happy Path und Edge Cases |
| `fix_execution` | Automatische Fixes aus Bug-/Refactor-Report |

Diese Gates pruefen **technische Qualitaet**. Was fehlt: Gates die **Produktqualitaet** pruefen.

Ein technisch einwandfreier Screen der niemanden motiviert ist genauso ein Fehler wie ein Screen der abstuerzt -- nur faellt er erst auf wenn die App im Store liegt und niemand sie benutzt.

---

## Vorgeschlagene neue Gates

### 1. Innovation Gate

**Zweck:** Prueft ob das Produkt/Feature einen echten Differenzierungsfaktor hat.

**Wann:** Vor der Implementation -- nach Spec-Erstellung, vor Architektur-Phase.

**Warum hier:** Wenn die Differenzierung fehlt, ist es billiger das vor dem Coden zu merken als danach. Ein generisches Feature zu implementieren und dann festzustellen dass es austauschbar ist, verschwendet Pipeline-Runs.

**Evaluationskriterien:**

| Kriterium | Pass | Fail |
|---|---|---|
| Differenzierungsfaktor | In einem Satz formulierbar. Beschreibt etwas, das Wettbewerber nicht haben. | "Es funktioniert" oder "Es benutzt KI" oder nicht formulierbar. |
| Zielnutzer-Problem | Konkretes Problem einer konkreten Zielgruppe. | Generisches Problem ("Nutzer wollen X") ohne Spezifik. |
| Vergleich zu Alternativen | Mindestens 2 Alternativen benannt, Unterschied klar. | Keine Alternativen genannt oder Unterschied nur "besser". |

**Pass/Fail:**
- **Pass:** Feature hat klare Differenzierung. Weiter zur Architektur.
- **Conditional Pass:** Differenzierung vorhanden aber schwach. Creative Director ueberarbeitet vor Implementation.
- **Fail:** Keine Differenzierung erkennbar. Zurueck zur Spec-Phase.

**Verantwortlicher Agent:** ProductStrategist (erweiterte System Message) oder Creative Director.

---

### 2. Experience Uniqueness Gate

**Zweck:** Prueft ob das generierte UI/UX sich von generischen Templates unterscheidet.

**Wann:** Nach der Implementation -- bevor Code extrahiert und integriert wird.

**Warum hier:** Der SwiftDeveloper generiert funktionalen Code. Aber funktionaler SwiftUI-Code sieht oft aus wie ein Apple-Tutorial. Dieses Gate prueft ob das Ergebnis eine eigene Identitaet hat.

**Evaluationskriterien:**

| Kriterium | Pass | Fail |
|---|---|---|
| Emotionale Funktion | Jeder Screen hat eine definierte emotionale Funktion (motivieren, bestaetigen, herausfordern). | Screen zeigt nur Daten an ohne emotionalen Kontext. |
| Micro-Copy | Texte haben Persoenlichkeit und reagieren auf Kontext. | Generische Labels ("Score", "History", "Settings"). |
| Visuelle Identitaet | Design folgt dem definierten Design-System des Produkts. | Standard-SwiftUI ohne Anpassungen. |
| Interaktionsmuster | Mindestens ein nicht-triviales Interaktionsmuster (Swipe, Animation, Haptic). | Nur Tap auf Buttons. |

**Pass/Fail:**
- **Pass:** Output hat eigene Identitaet. Weiter zu Code Extraction.
- **Conditional Pass:** Teilweise generisch. Creative Director gibt konkrete Verbesserungen.
- **Fail:** Komplett generisch. Neuer Implementation Run mit angepasstem Prompt.

**Verantwortlicher Agent:** Creative Director.

---

### 3. Motivation Quality Gate

**Zweck:** Prueft ob das Feature Mechanismen enthaelt die den Nutzer zurueckholen.

**Wann:** Nach der Spec-Phase -- vor der Implementation.

**Warum hier:** Motivationsmechaniken muessen geplant werden, sie entstehen nicht zufaellig im Code. Wenn ein Feature ohne Retention-Mechanik spezifiziert ist, sollte das vor der Implementation auffallen.

**Evaluationskriterien:**

| Kriterium | Pass | Fail |
|---|---|---|
| Return-Trigger | Feature hat mindestens einen Mechanismus der den Nutzer ohne Push-Notification zurueckholt. | Keine intrinsische Motivation zur Rueckkehr. |
| Fortschritt | Nutzer kann seinen Fortschritt sehen und vergleichen (mit sich selbst, nicht mit anderen). | Keine Fortschrittsanzeige oder nur absolute Zahlen. |
| Feedback-Loop | App reagiert unterschiedlich auf Erfolg, Misserfolg, Pause und Wiederkehr. | Gleiche Reaktion unabhaengig vom Nutzerverhalten. |
| Abschluss-Gefuehl | Jede Session hat ein klares Ende-Signal ("Fertig fuer heute"). | Session endet einfach oder Nutzer muss selbst aufhoeren. |

**Anwendbarkeit:** Nicht jedes Feature braucht alle Kriterien:
- Feature-Templates (`feature`, `screen` mit User-Facing UI): Alle Kriterien
- Service-Templates (`service`): Gate ueberspringen
- ViewModel-Templates (`viewmodel`): Nur Feedback-Loop pruefen

**Pass/Fail:**
- **Pass:** Feature hat Motivations-Mechaniken. Weiter zur Implementation.
- **Conditional Pass:** Teilweise vorhanden. UX Psychology Agent ergaenzt Vorschlaege.
- **Fail:** Keine Motivation erkennbar in einem User-Facing Feature. Zurueck zur Spec-Phase.

**Verantwortlicher Agent:** UX Psychology Agent (Review) oder ProductStrategist (erweitert).

---

### 4. Premium Design Gate

**Zweck:** Prueft ob der generierte Code den Design-Standards des Produkts entspricht.

**Wann:** Nach der Implementation, vor Code-Extraction -- parallel zum bestehenden Bug Review.

**Warum hier:** Design-Probleme sind genauso Bugs wie Crashes. Sie fallen nur dem Compiler nicht auf.

**Evaluationskriterien:**

| Kriterium | Pass | Fail |
|---|---|---|
| Farb-Konsistenz | Verwendet definierte Farben aus dem Design-System. | Hardcoded Colors oder undefinierte Farben. |
| Typografie | Folgt der definierten Typografie-Hierarchie. | Zufaellige Font-Sizes ohne System. |
| Spacing | Konsistentes Spacing (8pt-Grid oder definiertes System). | Zufaellige Paddings und Margins. |
| Animationen | Sinnvolle Transitions und Micro-Interaktionen wo definiert. | Keine Animationen oder Standard-Transitions ueberall. |
| Accessibility-Kompatibilitaet | Design-Entscheidungen kollidieren nicht mit A11Y-Anforderungen. | Zu niedrige Kontraste, zu kleine Touch Targets. |
| Dark/Light Mode | Beide Modes beruecksichtigt oder bewusst nur einer gewaehlt. | Nur einer implementiert ohne Entscheidung. |

**Pass/Fail:**
- **Pass:** Design entspricht dem Standard. Weiter zu Code Extraction.
- **Conditional Pass:** Kleine Abweichungen. Refactor Agent mit Design-Kontext.
- **Fail:** Schwere Design-Verstoesse. Creative Director gibt Feedback, neuer Pass.

**Verantwortlicher Agent:** Creative Director (Design-Review-Phase).

---

## Integration in die Pipeline

### Aktuelle Pipeline
```
Spec -> Implementation -> Bug Review -> Refactor -> Test Gen -> Fix -> Extract -> Integrate -> Commit
```

### Erweiterte Pipeline
```
Spec
  |
Innovation Gate              <-- NEU (vor Implementation)
  |
Motivation Quality Gate      <-- NEU (vor Implementation)
  |
Implementation
  |
Bug Review (bestehend)
  |
Premium Design Gate          <-- NEU (parallel zu Bug Review)
  |
Experience Uniqueness Gate   <-- NEU (nach Implementation)
  |
Refactor (bestehend, erweitert um Design-Feedback)
  |
Test Generation (bestehend)
  |
Fix Execution (bestehend)
  |
Code Extraction -> Integration -> Commit
  |
Factory Learning Agent       <-- NEU (post-run)
```

### Konfiguration (phase_gates.json Erweiterung)

```json
{
  "innovation_gate": {
    "enabled": true,
    "phase": "pre_implementation",
    "required_for": ["feature", "screen"],
    "skip_for": ["service", "viewmodel"],
    "responsible_agent": "creative_director"
  },
  "motivation_quality_gate": {
    "enabled": true,
    "phase": "pre_implementation",
    "required_for": ["feature", "screen"],
    "skip_for": ["service"],
    "partial_for": ["viewmodel"],
    "responsible_agent": "ux_psychology"
  },
  "experience_uniqueness_gate": {
    "enabled": true,
    "phase": "post_implementation",
    "required_for": ["feature", "screen"],
    "skip_for": ["service", "viewmodel"],
    "responsible_agent": "creative_director"
  },
  "premium_design_gate": {
    "enabled": true,
    "phase": "post_implementation",
    "required_for": ["feature", "screen"],
    "skip_for": ["service"],
    "partial_for": ["viewmodel"],
    "responsible_agent": "creative_director"
  }
}
```

### Mode-Verhalten

| Mode | Neue Gates |
|---|---|
| `quick` | Alle ueberspringen |
| `standard` | Aktiv fuer `feature` und `screen` Templates |
| `full` | Aktiv fuer alle, keine Ausnahmen |

---

## Zusammenfassung

| Gate | Phase | Prueft | Verantwortlich | Prioritaet |
|---|---|---|---|---|
| Innovation Gate | Pre-Impl | Differenzierung | Creative Director / Strategist | Hoch |
| Motivation Quality Gate | Pre-Impl | Retention-Mechaniken | UX Psychology / Strategist | Mittel |
| Experience Uniqueness Gate | Post-Impl | UI/UX-Identitaet | Creative Director | Hoch |
| Premium Design Gate | Post-Impl | Design-Standards | Creative Director | Mittel |

### Netto-Ergebnis
- 4 neue Gates (2 pre-implementation, 2 post-implementation)
- Template-abhaengig: `feature`/`screen` = alle Gates, `service` = Skip, `viewmodel` = Partial
- Mode-abhaengig: `quick` = Skip all, `standard` = aktiv, `full` = aktiv + strict
- Kein Impact auf bestehende Gates -- additive Erweiterung
