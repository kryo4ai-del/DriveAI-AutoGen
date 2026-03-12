# Factory -- New Roles Proposal

Last Updated: 2026-03-12

---

## Kontext

Die Factory hat 19 aktive Agents. Sie decken den technischen Workflow ab: Planung -> Architektur -> Implementation -> Review -> Bug-Analyse -> Refactoring -> Tests.

Was fehlt: Agents und Mechanismen die **Produktqualitaet** sicherstellen -- nicht nur Code-Qualitaet.

Dieses Dokument evaluiert 6 vorgeschlagene Rollen und gibt fuer jede eine Empfehlung.

---

## Bewertungskriterien

Fuer jede Rolle:
- **Zweck:** Was macht sie?
- **Verantwortung:** Wofuer ist sie zustaendig?
- **Interaktion:** Wie arbeitet sie mit bestehenden Agents?
- **Implementierungsform:** Full Agent / Review Agent / Phase Gate / Service Module
- **Empfehlung:** Ja / Nein / Anders

---

## 1. Dynamic Model Router Agent

**Zweck:** Entscheidet autonom, welches LLM-Modell fuer einen bestimmten Task verwendet wird -- basierend auf Komplexitaet, Budget und Qualitaetsanforderung.

**Verantwortung:**
- Task-Komplexitaet bewerten (simple template fill vs. komplexe Architektur-Entscheidung)
- Budget-Kontext beruecksichtigen (dev-run vs. production-run)
- Model-Tier upgraden wenn ein Task das aktuelle Tier ueberfordert
- Model-Tier downgraden wenn ein Task einfacher ist als erwartet

**Interaktion:**
- Sitzt VOR der Agent-Ausfuehrung
- Empfaengt Task-Beschreibung vom LeadAgent
- Gibt Modell-Empfehlung an die Pipeline zurueck
- Nutzt `config/model_router.py` als Basis, ueberschreibt bei Bedarf

**Implementierungsform: Service Module**

Begruendung: Kein eigener Agent noetig. Das 3-Tier-System mit statischem Routing funktioniert fuer die meisten Faelle. Was fehlt ist eine Upgrade-Logik -- die gehoert in `model_router.py` als Funktion, nicht als eigener Agent mit LLM-Aufrufen.

**Erweiterung statt neuer Agent:**
```python
# In model_router.py
def evaluate_upgrade(task_description: str, current_tier: int, budget: str) -> dict:
    """Prueft ob ein Task ein hoeheres Tier braucht.

    Kriterien fuer Upgrade:
    - Task enthaelt mehrere Domaenen (z.B. UI + Netzwerk + Persistenz)
    - Task ist als 'premium' oder 'complex' markiert
    - Vorheriger Run desselben Tasks hatte Quality-Gate-Failures

    Kriterien fuer Downgrade:
    - Task ist ein einzelnes Template-Fill
    - Task ist eine Wiederholung eines bereits geloesten Problems
    """
```

**Empfehlung:** Nicht als Agent. Als Erweiterung von `model_router.py`.

---

## 2. Creative Director Agent

**Zweck:** Stellt sicher, dass generierte Produkte eine eigenstaendige Identitaet haben und sich von generischen Apps unterscheiden.

**Verantwortung:**
- Produkt-Differenzierung pruefen ("Was macht diese App anders?")
- Design-Konsistenz sicherstellen (Farben, Typografie, Interaktionsmuster)
- Micro-Copy und Ton vorgeben
- Emotionale Funktion jedes Screens definieren
- Generischen Output ablehnen
- Design-Spezifikation erstellen (Farben, Spacing, Animationen, Haptics)

**Interaktion:**
- Arbeitet NACH dem ProductStrategist und VOR dem iOSArchitect
- Gibt Design-Richtlinien an den Architekten
- Reviewed den Output des SwiftDeveloper auf Design-Konsistenz
- Bekommt Kontext aus `factory_knowledge/` (Design Insights, Success Patterns)

**Implementierungsform: Full Agent (Tier 2 -- Sonnet)**

Begruendung: Design-Identitaet und Produktdifferenzierung erfordern kreatives Reasoning, das ueber regelbasierte Checks hinausgeht. Der Agent muss die Gesamtvision eines Produkts verstehen und auf jede Phase anwenden. Uebernimmt auch die Verantwortung des vorgeschlagenen "Premium Design Agent" -- ein separater Agent dafuer waere Overhead.

**System Message Kern:**
- Kein generischer Output akzeptabel
- Jeder Screen braucht eine emotionale Funktion
- Design-Signatur muss konsistent sein
- Referenziert Premium Product Principles
- Erstellt konkrete Design-Specs (Farben, Spacing, Animationen)

**Empfehlung:** Ja -- als Full Agent. Hoher Hebel auf Produktqualitaet.

---

## 3. UX Psychology Agent

**Zweck:** Bringt verhaltenspsychologische Erkenntnisse in die Produktgestaltung ein -- Motivation, Gewohnheitsbildung, Engagement-Mechaniken.

**Verantwortung:**
- Motivationsschleifen definieren (was holt den Nutzer zurueck?)
- Feedback-Mechanik pruefen (wie reagiert die App auf Nutzerverhalten?)
- Cognitive Load bewerten (ueberfordert dieser Screen den Nutzer?)
- Onboarding-Flow optimieren (wann versteht der Nutzer den Wert der App?)
- Retention-Mechaniken vorschlagen

**Interaktion:**
- Arbeitet parallel zum Creative Director
- Gibt Input an den Architekten (welche Flows braucht das Feature)
- Reviewed den Output auf psychologische Konsistenz
- Bekommt Kontext aus `factory_knowledge/` (Motivational Mechanics, UX Insights)

**Implementierungsform: Review Agent (Tier 2 -- Sonnet)**

Begruendung: UX-Psychologie ist wertvoll, aber nicht bei jedem Feature noetig. Als Review Agent kann er gezielt eingesetzt werden -- bei neuen Features, bei Onboarding-Aenderungen, bei Engagement-relevanten Screens. Nicht bei jedem Bug-Fix.

**Trigger:**
- Neues Feature wird spezifiziert -> UX Psychology Review
- Onboarding geaendert -> UX Psychology Review
- Retention-Metrik faellt -> UX Psychology Analyse
- Template: `feature` oder `screen` -> optional

**Empfehlung:** Ja -- als Review Agent, nicht als permanenter Pipeline-Teilnehmer.

---

## 4. Premium Design Agent

**Zweck:** Generiert und prueft Design-Spezifikationen: Farben, Spacing, Typografie, Animationen, Micro-Interaktionen.

**Verantwortung:**
- Design-System pflegen (Colors, Typography, Spacing, Components)
- SwiftUI-Code auf Design-Compliance pruefen
- Micro-Interaktionen spezifizieren
- Accessibility mit Design abgleichen

**Interaktion:**
- Wuerde NACH dem Creative Director arbeiten
- Gibt konkrete Design-Specs an den SwiftDeveloper

**Implementierungsform: Zusammenlegen mit Creative Director**

Begruendung: Einen separaten Design Agent und Creative Director zu haben erzeugt Overhead und Abstimmungsbedarf. Der Creative Director sollte beide Verantwortungen uebernehmen: Vision UND Spezifikation.

**Empfehlung:** Nicht separat. Verantwortung ist im Creative Director Agent integriert.

---

## 5. Brand Innovation Agent

**Zweck:** Analysiert Markttrends, Wettbewerber und Differenzierungsmoeglichkeiten fuer jedes Produkt.

**Verantwortung:**
- Wettbewerber-Analyse pro Produktkategorie
- Marktluecken identifizieren
- Differenzierungsfaktor validieren ("Gibt es das schon?")
- Brand-Positionierung vorschlagen

**Interaktion:**
- Arbeitet VOR dem ProductStrategist
- Nutzt OpportunityAgent-Daten und ResearchMemoryGraph
- Gibt Differenzierungs-Empfehlungen an den Creative Director

**Implementierungsform: Erweiterung bestehender Agents**

Begruendung: Der OpportunityAgent und der AutoResearchAgent decken bereits Markt-Analyse und Trend-Erkennung ab. Ein dritter Agent der dasselbe Feld beackert erzeugt Redundanz.

**Stattdessen:**
- OpportunityAgent bekommt erweiterte System Message: Wettbewerber-Analyse + Differenzierungs-Validierung
- AutoResearchAgent bekommt Task-Typ: `brand_research`
- ProductStrategist bekommt zusaetzliches Feld: `differentiation_factor` (Pflicht)

**Empfehlung:** Nicht als eigener Agent. Bestehende Agents erweitern.

---

## 6. Factory Learning Agent

**Zweck:** Extrahiert Erkenntnisse aus abgeschlossenen Projekten und pflegt die `factory_knowledge/` Wissensbasis.

**Verantwortung:**
- Nach jedem Pipeline-Run: Erkenntnisse extrahieren
- Patterns klassifizieren (UX, Design, Technical, Motivation, Failure, Success)
- Confidence Levels aktualisieren (hypothesis -> validated -> proven)
- Duplikate erkennen und zusammenfuehren
- Relevante Erkenntnisse fuer neue Projekte filtern

**Interaktion:**
- Laeuft NACH dem Pipeline-Run (Post-Processing)
- Liest: Bug-Reports, Refactor-Vorschlaege, Review-Ergebnisse, Code-Extraction-Logs
- Schreibt: `factory_knowledge/*.json`
- Wird beim Projekt-Start gelesen (Pre-Processing)

**Implementierungsform: Full Agent (Tier 3 -- Haiku)**

Begruendung: Wissensextraktion und -klassifizierung ist ein Tier-3-Task (Extraktion, Zusammenfassung, Labeling). Kein teures Reasoning noetig. Aber ein eigener Agent ist gerechtfertigt, weil die Aufgabe regelmaessig, strukturiert und eigenstaendig ist.

**Pipeline-Integration:**
```
[... bestehende Pipeline ...]
  |
Code Extraction -> Xcode Integration -> Git Commit
  |
Factory Learning Agent (post-run, async)
  |
factory_knowledge/ aktualisiert
```

**Empfehlung:** Ja -- als Tier-3 Agent. Niedriger Kosten-Impact, hoher langfristiger Wert.

---

## Zusammenfassung

| Rolle | Empfehlung | Form | Tier | Prioritaet |
|---|---|---|---|---|
| Dynamic Model Router | Erweiterung | Service Module in `model_router.py` | -- | Niedrig |
| Creative Director | **Implementieren** | Full Agent | Tier 2 (Sonnet) | **Hoch** |
| UX Psychology | **Implementieren** | Review Agent | Tier 2 (Sonnet) | Mittel |
| Premium Design | Zusammenlegen | -> Creative Director | -- | -- |
| Brand Innovation | Erweiterung | -> OpportunityAgent + ResearchAgent | -- | Niedrig |
| Factory Learning | **Implementieren** | Full Agent | Tier 3 (Haiku) | **Hoch** |

### Netto-Ergebnis
- **2 neue Agents:** Creative Director (Sonnet) + Factory Learning (Haiku)
- **1 neuer Review Agent:** UX Psychology (Sonnet, on-demand)
- **2 bestehende Agents erweitert:** OpportunityAgent, AutoResearchAgent
- **1 Service Module erweitert:** model_router.py

### Auswirkung auf Agent-Count
- Aktuell: 19 aktiv + 4 deaktiviert = 23
- Neu: 22 aktiv + 4 deaktiviert = 26
- Kosten-Impact: Minimal (Learning Agent auf Haiku, UX Psychology nur on-demand)
