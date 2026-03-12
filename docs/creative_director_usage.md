# Creative Director -- Usage Guide

Last Updated: 2026-03-12

---

## Was wurde implementiert

Ein **Advisory Review Pass** der nach dem Bug Hunter und vor dem Refactor laeuft. Er bewertet den generierten Code aus Produktqualitaets-Perspektive -- nicht technisch, sondern ob das Ergebnis wie ein Premium-Produkt wirkt oder wie ein generisches Template.

**Phase 1 = Advisory only.** Der Pass loggt sein Feedback, blockiert aber nichts. Die Pipeline laeuft unabhaengig vom Ergebnis weiter.

---

## Wie es funktioniert

Der Creative Director ist ein normaler AutoGen Agent im Team (wie Bug Hunter, Reviewer, etc.). Er hat eine eigene System Message die ihn auf Produktqualitaet fokussiert.

In der Pipeline laeuft er als separater Pass:
```
Pass 1: Implementation
Pass 2: Bug Review
Pass 2b: Creative Director Review  <-- NEU
Pass 3: Refactor
Pass 4: Test Generation
Pass 5: Fix Execution (full mode)
```

Er wird nur in `standard` und `full` Mode ausgefuehrt (nicht in `quick`).

---

## Wo im Code

| Datei | Was |
|---|---|
| `agents/creative_director.py` | Agent-Modul (identische Struktur wie reviewer.py) |
| `config/agent_roles.json` | Rolle + System Message |
| `config/agent_toggles.json` | Toggle: `"creative_director": true` |
| `config/agent_toggle_config.py` | ALL_AGENTS Liste |
| `config/model_router.py` | Route: `creative_direction -> Sonnet` |
| `tasks/task_manager.py` | Import + Instanziierung + Team-Einbindung |
| `main.py` | Pass 2b zwischen Bug Review und Refactor |

---

## Wie man es ausfuehrt

### Standard-Lauf mit Creative Director

```bash
python main.py --template screen --name TrainingMode --profile dev --approval auto
```

Der CD-Pass laeuft automatisch fuer `screen` und `feature` Templates.

### Fuer Feature-Templates

```bash
python main.py --template feature --name ExamSimulation --profile dev --approval auto
```

### CD wird uebersprungen bei

```bash
# Service-Template -- kein UI, kein Design-Review noetig
python main.py --template service --name QuestionParser --profile dev --approval auto

# ViewModel-Template -- kein direktes UI
python main.py --template viewmodel --name TrainingViewModel --profile dev --approval auto

# Quick Mode -- keine Review-Passes
python main.py --template screen --name Dashboard --mode quick --approval auto
```

### CD manuell deaktivieren

```bash
python main.py --template screen --name Dashboard --profile dev --approval auto --disable-agent creative_director
```

---

## Wann benutzen

**Ja:**
- Beim Generieren von neuen Screens (UI-relevant)
- Beim Generieren von kompletten Features
- Wenn du wissen willst ob der Output generisch wirkt
- Als Feedback-Quelle fuer die naechste Iteration

**Nein:**
- Bei Service- oder ViewModel-only Generierung
- Bei Bug-Fixes (kein neues UI)
- Bei Refactoring (Verhalten bleibt gleich)
- Bei Infrastructure-Aenderungen

---

## Was der CD bewertet

1. **Differenzierung** -- Fuehlt sich das einzigartig an oder wie jede andere App?
2. **Emotionale Funktion** -- Wuerde ein Nutzer etwas fuehlen bei diesem Screen?
3. **Motivation** -- Gibt es einen Grund morgen wiederzukommen?
4. **Design-Identitaet** -- Gibt es eine konsistente visuelle Signatur?
5. **Micro-Copy** -- Kommunizieren Texte mit Persoenlichkeit oder zeigen sie nur Daten?
6. **Interaktionsqualitaet** -- Gibt es Interaktionen jenseits von Standard-Buttons?

### Rating-Skala

| Rating | Bedeutung | Aktion |
|---|---|---|
| `pass` | Premium-Standard erreicht | Weiter |
| `conditional_pass` | Grundsaetzlich gut, aber Verbesserungen noetig | Feedback beruecksichtigen |
| `fail` | Generisch, braucht signifikante Ueberarbeitung | Erneut generieren mit angepasstem Prompt |

---

## Output-Beispiel

```
Rating: conditional_pass

Findings:
1. [Micro-Copy] Empty State ist generisch
   Problem: "Keine Daten vorhanden" sagt nichts aus
   Suggestion: "Noch keine Fragen gescannt -- tippe auf Scan um loszulegen!"

2. [Emotion] Kein Feedback bei korrekter Antwort
   Problem: Die App reagiert gleich auf richtig und falsch
   Suggestion: Unterschiedliche Farbe + Haptic + ermutigendes Micro-Copy

3. [Differenzierung] Standard-List statt Skill-Map
   Problem: Eine flache Liste von Themen ist austauschbar
   Suggestion: Grid mit Farbkodierung (rot/gelb/gruen) fuer Kompetenz-Level

Summary: Funktional solide, aber die UX fühlt sich wie ein Template an.
Drei konkrete Verbesserungen wuerden den Unterschied machen.
```

---

## Limitierungen (Phase 1)

1. **Advisory only** -- blockiert keine Pipeline. Das Rating hat keine Konsequenzen.
2. **Kein factory_knowledge/ Zugriff** -- der CD kennt keine Erkenntnisse aus frueheren Runs.
3. **Kein Pre-Implementation Review** -- der CD sieht den Output, nicht die Spec. Probleme die im Spec stecken erkennt er nicht.
4. **Im SelectorGroupChat** -- der Selector koennte den CD theoretisch auch waehrend des Implementation Pass auswaehlen (unwahrscheinlich bei korrekter Description, aber moeglich).
5. **Feedback-Qualitaet haengt von der System Message ab** -- wenn das Feedback generisch ist, muss die System Message nachgeschaerft werden.

---

## Naechste Schritte (nach Validierung)

1. CD-Feedback analysieren: Ist es spezifisch und umsetzbar?
2. Wenn ja: Gate-Modus einbauen (pass/fail mit Konsequenzen)
3. factory_knowledge/ Kontext an CD uebergeben
4. Pre-Implementation Review als zweite Phase
