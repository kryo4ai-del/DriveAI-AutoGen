# Factory Learning Schema

Last Updated: 2026-03-12

---

## Plausibilitaets-Check gegenueber factory_learning_loop.md

Das konzeptionelle Doc schlaegt 6 separate JSON-Dateien vor (ux_insights.json, design_insights.json, etc.). Das ist fuer den Start zu granular:
- 6 Dateien bedeuten 6 Lese-/Schreib-Operationen pro Run
- Die Trennung nach Typ ist kuenstlich -- eine "Swipe-Navigation fuer Fragen" Erkenntnis ist gleichzeitig UX, Design und Technical
- Leere Dateien erzeugen die Illusion von Struktur ohne Inhalt

**Entscheidung:** Eine einzelne `knowledge.json` mit `type` als Feld. Aufspaltung in separate Dateien nur wenn die Datei > 200 Eintraege hat (wird lange dauern).

---

## Verzeichnisstruktur

```
factory_knowledge/
  README.md              <- Erklaert das System, Regeln, Schema
  knowledge.json         <- Alle Eintraege, nach Typ gefiltert
  index.json             <- Meta: Zaehler, letzte Aenderung, Projekte
```

Kein `patterns/`, kein `failures/`, kein `projects/` Unterordner. Das waere Over-Engineering fuer 0 Eintraege.

Wenn spaeter projektisolierte Snapshots noetig werden:
```
factory_knowledge/
  knowledge.json         <- Cross-project Knowledge
  snapshots/
    askfin_v1.json       <- Snapshot nach AskFin Phase 1
```

Das kommt aber erst wenn es einen zweiten Projekt gibt.

---

## JSON Schema: knowledge.json

```json
{
  "version": "1.0",
  "entries": [
    {
      "id": "FK-001",
      "type": "ux_insight | design_insight | technical_pattern | motivational_mechanic | failure_case | success_pattern",
      "title": "Kurzer Titel (max 80 Zeichen)",
      "description": "Was wurde gelernt. 1-3 Saetze.",
      "context": "In welcher Situation wurde das beobachtet.",
      "source_project": "askfin",
      "product_type": "learning_app | game | productivity | ai_native | utility",
      "applicable_to": ["learning_app", "game"],
      "confidence": "hypothesis | validated | proven | disproven",
      "created": "2026-03-15",
      "updated": "2026-03-15",
      "tags": ["onboarding", "retention", "swiftui"]
    }
  ]
}
```

### Pflichtfelder

| Feld | Typ | Beschreibung |
|---|---|---|
| `id` | string | Eindeutige ID: FK-NNN (fortlaufend) |
| `type` | enum | Einer der 6 definierten Typen |
| `title` | string | Kurz, praegnant, maximal 80 Zeichen |
| `description` | string | Was wurde gelernt. Keine Romane -- 1-3 Saetze |
| `source_project` | string | Welches Projekt hat diese Erkenntnis erzeugt |
| `confidence` | enum | Aktueller Reifegrad |
| `created` | string | ISO-Datum |

### Optionale Felder

| Feld | Typ | Beschreibung |
|---|---|---|
| `context` | string | In welcher Situation beobachtet |
| `product_type` | string | Produkttyp der Quelle |
| `applicable_to` | string[] | Auf welche Produkttypen uebertragbar |
| `updated` | string | ISO-Datum der letzten Aenderung |
| `tags` | string[] | Freitext-Tags fuer Filterung |
| `components` | string[] | Technische Komponenten (nur fuer technical_pattern) |
| `effect` | string | Beobachteter Effekt (nur fuer motivational_mechanic) |
| `lesson` | string | Gelernte Lektion (nur fuer failure_case) |

---

## Die 6 Typen

### ux_insight
Erkenntnisse ueber Nutzer-Interaktion mit der UI.
- Wann erfassen: Wenn ein UI-Pattern besser oder schlechter funktioniert als erwartet
- Beispiel: "Swipe-Navigation fuer Fragen reduziert Friction gegenueber Tap-Buttons"

### design_insight
Erkenntnisse ueber visuelle Gestaltung und Wahrnehmung.
- Wann erfassen: Wenn ein Design-Pattern intuitiv verstaendlich ist oder Verwirrung stiftet
- Beispiel: "Farbkodierung rot/gelb/gruen fuer Kompetenz-Level braucht keine Erklaerung"

### technical_pattern
Wiederverwendbare technische Loesungen.
- Wann erfassen: Wenn eine Loesung fuer ein Problem gefunden wurde die auch in anderen Projekten noetig sein koennte
- Beispiel: "OCR -> Parsing -> LLM-Validation Pipeline"

### motivational_mechanic
Mechanismen die Nutzer-Engagement erzeugen.
- Wann erfassen: Wenn ein Feature Retention beeinflusst (positiv oder negativ)
- Beispiel: "Daily Challenge mit 5 Fragen erzeugt Gewohnheitsschleife"

### failure_case
Was nicht funktioniert hat und warum.
- Wann erfassen: Nach jedem signifikanten Fehlschlag oder Designfehler
- Beispiel: "Zu viele Statistik-Screens -- Nutzer oeffnet keinen davon"

### success_pattern
Komplette Konzepte die funktioniert haben und uebertragbar sind.
- Wann erfassen: Wenn ein ganzes Feature-Konzept nachweislich funktioniert
- Beispiel: "Skill Map Pattern: Themen-Grid mit Farbkodierung"

---

## Confidence / Maturity Levels

| Level | Bedeutung | Wann gesetzt | Wie genutzt |
|---|---|---|---|
| `hypothesis` | Theorie oder erste Beobachtung, nicht verifiziert | Bei Erstellung | Als Vorschlag, nicht als Regel |
| `validated` | In einem Projekt bestaetigt | Nach positivem Ergebnis im Quellprojekt | Als Standard-Empfehlung |
| `proven` | In 2+ Projekten bestaetigt | Wenn derselbe Eintrag in einem zweiten Projekt funktioniert | Als Factory-Regel |
| `disproven` | In der Praxis widerlegt | Wenn ein Eintrag in einem Projekt gescheitert ist | Als Warnung mitgegeben |

### Promotion-Regeln

```
hypothesis -> validated:
  Bedingung: Mindestens ein positives Ergebnis im Quellprojekt
  Wer: Factory Learning Agent oder manuell
  Wann: Nach Pipeline-Run mit positivem Outcome

validated -> proven:
  Bedingung: Erkenntnis funktioniert in einem ZWEITEN Projekt
  Wer: Factory Learning Agent
  Wann: Nach erfolgreichem Einsatz in neuem Projekt

any -> disproven:
  Bedingung: Erkenntnis hat in einem Projekt nicht funktioniert
  Wer: Factory Learning Agent oder manuell
  Wann: Sofort nach Beobachtung
  Wichtig: Nicht loeschen -- als Warnung behalten
```

---

## Projekt-spezifisch vs. Cross-Project

### Projekt-spezifisch
- Erkenntnisse die nur fuer ein bestimmtes Projekt gelten
- Markiert durch `applicable_to: ["askfin"]` (nur dieses Projekt)
- Beispiel: "AskFin-Nutzer scannen Fragen hauptsaechlich abends" -- nicht uebertragbar

### Cross-Project
- Erkenntnisse die auf andere Produkttypen uebertragbar sind
- Markiert durch `applicable_to: ["learning_app", "quiz_app"]` (Kategorien)
- Beispiel: "Adaptive Fragenauswahl erhoet Retention" -- uebertragbar auf alle Lern-Apps

### Filter-Logik bei Projekt-Start
```
1. Produkttyp des neuen Projekts bestimmen (z.B. "game")
2. Alle Eintraege filtern wo:
   - applicable_to enthaelt den Produkttyp ODER
   - applicable_to enthaelt "all" ODER
   - source_project == aktuelles Projekt
3. Sortieren nach confidence (proven > validated > hypothesis)
4. Top 20 als Kontext an Agents uebergeben
```

---

## Naming Conventions

| Element | Format | Beispiel |
|---|---|---|
| Entry ID | FK-NNN | FK-001, FK-042 |
| Type | snake_case | ux_insight, failure_case |
| Product Type | snake_case | learning_app, ai_native |
| Tags | snake_case | onboarding, swiftui, retention |
| Dates | ISO 8601 | 2026-03-15 |
| Titles | Fliesstext, max 80 Zeichen | "Swipe-Navigation reduziert Friction bei Fragen" |

---

## Index Schema: index.json

```json
{
  "last_updated": "2026-03-15",
  "total_entries": 0,
  "by_type": {
    "ux_insight": 0,
    "design_insight": 0,
    "technical_pattern": 0,
    "motivational_mechanic": 0,
    "failure_case": 0,
    "success_pattern": 0
  },
  "by_confidence": {
    "hypothesis": 0,
    "validated": 0,
    "proven": 0,
    "disproven": 0
  },
  "projects": []
}
```

---

## Konkrete Beispiele

### AskFin (Learning App)

```json
{
  "id": "FK-001",
  "type": "technical_pattern",
  "title": "OCR-to-LLM Pipeline fuer strukturierte Texterkennung",
  "description": "Kamera-Bild -> VisionKit OCR -> RegEx-Parsing fuer Fragestruktur -> LLM-Validierung und Anreicherung. Funktioniert zuverlaessig fuer gedruckte Pruefungsfragen.",
  "context": "AskFin Question Scanner -- Hauptfeature fuer Fragen-Import",
  "source_project": "askfin",
  "product_type": "learning_app",
  "applicable_to": ["learning_app", "document_scanner", "receipt_tracker"],
  "confidence": "validated",
  "components": ["VisionKit", "RegEx parser", "AnthropicChatCompletionClient"],
  "created": "2026-03-15",
  "tags": ["ocr", "llm", "pipeline", "camera"]
}
```

```json
{
  "id": "FK-002",
  "type": "failure_case",
  "title": "Generischer Fragenkatalog ohne Personalisierung verliert Nutzer",
  "description": "Wenn alle Nutzer dieselben Fragen in derselben Reihenfolge sehen, gibt es keinen Grund die App erneut zu oeffnen. Personalisierung ist der Retention-Mechanismus.",
  "context": "AskFin v1 -- alle Fragen gleich praesentiert",
  "source_project": "askfin",
  "product_type": "learning_app",
  "applicable_to": ["learning_app", "quiz_app"],
  "confidence": "hypothesis",
  "lesson": "Personalisierung ist kein Nice-to-have sondern der Retention-Kern",
  "created": "2026-03-15",
  "tags": ["retention", "personalization", "ux"]
}
```

### Hypothetisches Game (z.B. "DungeonAI")

```json
{
  "id": "FK-010",
  "type": "motivational_mechanic",
  "title": "Adaptive Schwierigkeit haelt Spieler im Flow",
  "description": "Wenn ein Spieler 3x hintereinander gewinnt, wird die Schwierigkeit erhoeht. Bei 3x Niederlage wird sie gesenkt. Haelt den Spieler in der Zone zwischen Langeweile und Frustration.",
  "context": "DungeonAI -- Kampf-Schwierigkeit",
  "source_project": "dungeonai",
  "product_type": "game",
  "applicable_to": ["game", "learning_app"],
  "confidence": "hypothesis",
  "effect": "Laengere durchschnittliche Session-Dauer",
  "created": "2026-04-01",
  "tags": ["difficulty", "flow", "engagement"]
}
```

### Hypothetische Productivity App (z.B. "FocusTime")

```json
{
  "id": "FK-020",
  "type": "ux_insight",
  "title": "Ein-Tap Aktions-Start reduziert Einstiegshuerde",
  "description": "Der haeufigste Workflow (Timer starten) darf maximal 1 Tap vom Homescreen entfernt sein. Jeder zusaetzliche Tap reduziert die Nutzungshaeufigkeit.",
  "context": "FocusTime -- Haupt-Timer-Feature",
  "source_project": "focustime",
  "product_type": "productivity",
  "applicable_to": ["productivity", "utility"],
  "confidence": "hypothesis",
  "created": "2026-04-15",
  "tags": ["friction", "onboarding", "tap-count"]
}
```

---

## Was NICHT gespeichert wird

- Code-Snippets (gehoeren in den Code, nicht in Knowledge)
- Git-History (git log ist authoritative)
- Debugging-Loesungen (der Fix ist im Code)
- Projekt-Status oder Tasks (gehoert in MEMORY.md)
- Agent-Konfiguration (gehoert in config/)
