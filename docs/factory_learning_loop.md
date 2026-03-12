# Factory Learning Loop

Last Updated: 2026-03-12

---

## Zweck

Die Factory baut Produkte. Jedes Produkt erzeugt Erkenntnisse. Ohne ein System, das diese Erkenntnisse speichert und wiederverwendet, faengt die Factory bei jedem neuen Projekt bei Null an.

Dieses Dokument beschreibt, wie die Factory aus jedem Projekt lernt und dieses Wissen auf zukuenftige Projekte uebertraegt.

---

## Das Problem

Aktueller Zustand:
- Die Factory generiert Code, reviewed ihn, fixt Bugs -- aber speichert keine Muster
- Jedes Projekt bekommt die gleichen generischen System Messages
- UX-Entscheidungen, die in AskFin funktioniert haben, sind nicht verfuegbar wenn die Factory eine zweite App baut
- Design-Fehler werden nicht dokumentiert -- sie werden wiederholt
- Technische Loesungen (z.B. "OCR-Pipeline mit Kamera-Fallback") existieren im Code, aber nicht als wiederverwendbares Wissen

---

## Architektur des Learning Loop

```
Projekt laeuft
    |
Erkenntnisse entstehen (automatisch + manuell)
    |
Extraktion (was war gut, was war schlecht, was ist uebertragbar)
    |
Speicherung (factory_knowledge/)
    |
Naechstes Projekt startet
    |
Relevante Erkenntnisse werden geladen (nach Produkttyp, Domaene, Phase)
    |
Agents erhalten kontextuelle Erfahrungswerte
```

---

## Was erfasst wird

### 1. UX Insights

Erkenntnisse darueber, wie Nutzer mit Interfaces interagieren.

**Beispiele:**
- "Swipe-Navigation fuer Fragen funktioniert besser als Tap-Buttons"
- "Empty States mit Handlungsaufforderung reduzieren Abbrueche"
- "Progressive Disclosure bei Erklaerungen erhoeht Verweildauer"

**Struktur:**
```json
{
  "type": "ux_insight",
  "source_project": "askfin",
  "product_type": "learning_app",
  "insight": "Swipe-based question answering reduces friction vs tap buttons",
  "context": "Question training mode",
  "applicable_to": ["learning_app", "quiz_app", "game"],
  "confidence": "validated",
  "date": "2026-03-15"
}
```

### 2. Design Insights

Erkenntnisse ueber visuelle und interaktive Gestaltung.

**Beispiele:**
- "Fortschrittsfarbe (gruen wachsend, rot schrumpfend) ist intuitiv verstaendlich"
- "Dunkler Hintergrund mit hellen Akzenten wirkt fokussierter als helle Themes"
- "Haptic Feedback bei richtig/falsch erhoeht wahrgenommene Qualitaet"

**Struktur:**
```json
{
  "type": "design_insight",
  "source_project": "askfin",
  "product_type": "learning_app",
  "insight": "Progress color coding (green growing, red shrinking) needs no explanation",
  "context": "Skill Map -- users understood the system without onboarding",
  "applicable_to": ["learning_app", "productivity_app", "game"],
  "confidence": "hypothesis",
  "date": "2026-03-15"
}
```

### 3. Technical Patterns

Wiederverwendbare technische Loesungen.

**Beispiele:**
- "OCR -> Parsing -> LLM-Validation Pipeline fuer strukturierte Texterkennung"
- "Adaptive Fragenauswahl: gewichteter Random basierend auf Fehlerhistorie"
- "Offline-Queue mit Sync: lokale Speicherung + Background-Upload bei Konnektivitaet"

**Struktur:**
```json
{
  "type": "technical_pattern",
  "source_project": "askfin",
  "pattern_name": "ocr_to_llm_pipeline",
  "description": "Camera/image -> OCR text extraction -> structured parsing -> LLM validation/enrichment",
  "components": ["VisionKit", "RegEx parser", "AnthropicClient"],
  "applicable_to": ["document_scanner", "receipt_tracker", "learning_app"],
  "complexity": "medium",
  "date": "2026-03-15"
}
```

### 4. Motivational Mechanics

Mechanismen die Nutzer-Engagement erzeugen.

**Beispiele:**
- "Daily Challenge (5 Fragen) erzeugt hohe Return-Rate am naechsten Tag"
- "Streak-Counter ab Tag 3 wirksam, unter Tag 3 irrelevant"
- "Fortschritts-Score motiviert mehr als absolute Zahlen"

**Struktur:**
```json
{
  "type": "motivational_mechanic",
  "source_project": "askfin",
  "mechanic_name": "daily_challenge",
  "description": "5 personalized questions per day, ~5 min completion time",
  "effect": "High day-over-day return rate expected",
  "applicable_to": ["learning_app", "fitness_app", "habit_tracker"],
  "confidence": "hypothesis",
  "date": "2026-03-15"
}
```

### 5. Failure Cases

Was nicht funktioniert hat und warum.

**Beispiele:**
- "Generischer Fragenkatalog ohne Personalisierung -> Nutzer verliert Interesse nach 3 Tagen"
- "Zu viele Statistik-Screens -> Nutzer oeffnet keinen davon"
- "Code-Extraktion mit >10 Files -> Namenskollisionen"

**Struktur:**
```json
{
  "type": "failure_case",
  "source_project": "askfin",
  "what_failed": "Generic question catalog without personalization",
  "why_it_failed": "No reason to return -- user gets same experience every time",
  "lesson": "Personalization is not a nice-to-have, it is the retention mechanism",
  "applicable_to": ["learning_app", "content_app"],
  "date": "2026-03-15"
}
```

### 6. Reusable Success Patterns

Ganze Konzepte die in einem Projekt funktioniert haben und uebertragbar sind.

**Beispiele:**
- "Skill Map Pattern: Themen-Grid mit Farbkodierung fuer Kompetenz-Level"
- "Scan-and-Learn Pattern: Kamera -> Erkennung -> Erklaerung -> Speicherung"
- "Pruefungssimulation Pattern: Zeitlimit + Fehlerpunkte + Bestanden/Nicht bestanden"

**Struktur:**
```json
{
  "type": "success_pattern",
  "source_project": "askfin",
  "pattern_name": "skill_map",
  "description": "Visual grid of all skill areas with color-coded competency levels",
  "components": ["Topic grid view", "Competency model", "Color system", "History tracking"],
  "why_it_works": "Gives users a complete picture of their progress at a glance",
  "applicable_to": ["learning_app", "fitness_app", "skill_tracker"],
  "date": "2026-03-15"
}
```

---

## Speicherformat

### Verzeichnisstruktur
```
factory_knowledge/
  ux_insights.json
  design_insights.json
  technical_patterns.json
  motivational_mechanics.json
  failure_cases.json
  success_patterns.json
  index.json              <-- Uebersicht: Anzahl pro Typ, letzte Aktualisierung
```

### Index (index.json)
```json
{
  "last_updated": "2026-03-15",
  "counts": {
    "ux_insights": 0,
    "design_insights": 0,
    "technical_patterns": 0,
    "motivational_mechanics": 0,
    "failure_cases": 0,
    "success_patterns": 0
  },
  "projects_learned_from": []
}
```

---

## Wie zukuenftige Projekte das Wissen nutzen

### Bei Projekt-Start

Wenn ein neues Projekt bootstrapped wird:

1. **Produkttyp wird klassifiziert** (learning_app, game, productivity, ai_native)
2. **Relevante Erkenntnisse werden gefiltert** nach `applicable_to`
3. **Die relevanten Patterns werden als Kontext** an die planenden Agents uebergeben

### Beispiel: Neues Projekt "FitTrack" (Fitness-App)

Die Factory laedt:
- **UX Insights:** "Empty States mit Handlungsaufforderung" (applicable_to: alle)
- **Motivational Mechanics:** "Daily Challenge", "Streak-Counter" (applicable_to: fitness_app)
- **Success Patterns:** "Skill Map" -> wird zu "Muscle Group Map" (applicable_to: fitness_app)
- **Failure Cases:** "Zu viele Statistik-Screens" (applicable_to: alle)

Die Agents wissen jetzt:
- Taegliche Challenges funktionieren fuer Retention
- Skill Maps sind uebertragbar auf andere Kompetenz-Domaenen
- Zu viele Statistik-Screens sind kontraproduktiv

### Beispiel: Neues Projekt "WordQuest" (Vokabel-Spiel)

Die Factory laedt:
- **UX Insights:** "Swipe-Navigation fuer Fragen" (applicable_to: quiz_app, game)
- **Technical Patterns:** "Adaptive Fragenauswahl" (applicable_to: learning_app)
- **Motivational Mechanics:** "Daily Challenge" + "Fortschritts-Score"
- **Failure Cases:** "Generischer Katalog ohne Personalisierung"

### Beispiel: Neues Projekt "InvoiceAI" (Produktivitaet + KI)

Die Factory laedt:
- **Technical Patterns:** "OCR -> Parsing -> LLM Pipeline" (applicable_to: document_scanner)
- **UX Insights:** "Progressive Disclosure" (applicable_to: alle)
- **Design Insights:** "Dunkler Hintergrund fuer Fokus" (applicable_to: productivity_app)

### Beispiel: Neues Projekt "DungeonAI" (KI-Spiel)

Die Factory laedt:
- **Motivational Mechanics:** Alle (applicable_to: game)
- **Design Insights:** "Haptic Feedback" (applicable_to: game)
- **Success Patterns:** Adaptiert "Skill Map" zu "Character Stats"

---

## Wann Erkenntnisse erfasst werden

### Automatisch (durch Agents)
- **Nach Bug Review:** Wenn ein Pattern-Bug auftritt -> `failure_case`
- **Nach Refactor:** Wenn ein technisches Pattern verbessert wird -> `technical_pattern` Update
- **Nach Deployment:** Wenn ein Feature live geht -> `success_pattern` Kandidat

### Manuell (durch den Nutzer/Entwickler)
- "Das hat gut funktioniert" -> `success_pattern`
- "Das war ein Fehler" -> `failure_case`
- "Die Nutzer moegen X" -> `ux_insight` oder `motivational_mechanic`

### Durch den Factory Learning Agent (vorgeschlagen)
- Analysiert abgeschlossene Projekte
- Extrahiert Muster aus Code-Reviews und Bug-Reports
- Schlaegt neue Eintraege vor, die manuell bestaetigt werden

---

## Confidence Levels

| Level | Bedeutung | Aktion |
|---|---|---|
| `hypothesis` | Noch nicht validiert, basiert auf Theorie oder einer Beobachtung | Kann genutzt werden, aber als Vorschlag, nicht als Regel |
| `validated` | In mindestens einem Projekt getestet und bestaetigt | Wird als Standard-Empfehlung genutzt |
| `proven` | In mehreren Projekten bestaetigt | Wird zur Factory-Regel |
| `disproven` | Hat in der Praxis nicht funktioniert | Wird als Warnung mitgegeben |

Erkenntnisse starten als `hypothesis` und werden mit jedem Projekt aktualisiert.

---

## Integration in die Factory-Pipeline

### Erweiterung (konzeptionell)
```
Projekt-Start
  |
Knowledge Loading (factory_knowledge/ -> nach Produkttyp filtern)
  |
Agent Context Enrichment (relevante Erkenntnisse in System Messages)
  |
[... bestehende Pipeline ...]
  |
Projekt-Ende
  |
Knowledge Extraction (neue Erkenntnisse aus dem Run)
  |
Knowledge Storage (factory_knowledge/ aktualisieren)
```

Kein Rewrite noetig -- es ist eine zusaetzliche Schicht vor und nach dem bestehenden Workflow.
