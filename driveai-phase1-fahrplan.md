# DriveAI Swarm Factory — Pre-Production Pipeline
# Phase 1: Von der CEO-Idee zum CEO-Gate (Kill or Go)

---

## Übersicht

Phase 1 deckt den gesamten Weg von einer rohen CEO-Idee bis zur strategischen Kill-or-Go Entscheidung ab. Alles läuft vollautomatisch durch KI-Agents — der einzige menschliche Eingriff ist die finale CEO-Entscheidung am Gate.

**Eingang:** Rohe Idee vom CEO (unstrukturiert, wenige Sätze)  
**Ausgang:** Fertiger Concept Brief + Legal-Report + Risk-Assessment → CEO-Gate  
**Agents:** 7  
**Menschlicher Eingriff:** Nur am CEO-Gate (Kill or Go)

---

## Gesamtfluss

```
CEO-Idee
    │
    ▼
Agent 7: Memory-Agent liefert Learnings-Briefing (falls vorhanden)
    │
    ▼
┌─────────────────────────────────────────────┐
│  KAPITEL 1: CONCEPT BRIEF                   │
│                                             │
│  Agent 1 + Agent 2 + Agent 3 (parallel)     │
│         │           │           │           │
│         └─────────┬─────────────┘           │
│                   ▼                         │
│            Agent 4 (Synthese)               │
│                   │                         │
│                   ▼                         │
│          Fertiger Concept Brief             │
└─────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────┐
│  KAPITEL 2: LEGAL & COMPLIANCE CHECK        │
│                                             │
│  Agent 5 (Legal Research)                   │
│         │                                   │
│         ▼                                   │
│  Agent 6 (Risk Assessment)                  │
│         │                                   │
│         ▼                                   │
│  Legal-Report + Risk-Report                 │
└─────────────────────────────────────────────┘
    │
    ▼
╔═════════════════════════════════════════════╗
║  CEO-GATE: KILL OR GO                      ║
║  CEO bekommt: Concept Brief + Legal-Report ║
║  CEO entscheidet + gibt Begründung         ║
╚═════════════════════════════════════════════╝
    │
    ▼
Agent 7: Memory-Agent speichert Ergebnis + aktualisiert Learnings
    │
    ▼
(Bei GO → weiter zu Phase 2)
```

---

## Kapitel 1: Concept Brief

### Agent 1: Trend-Scout-Agent

**Rolle:** Reiner Rechercheur für aktuelle Markt- und Technologie-Trends  
**Input:** Rohe CEO-Idee + Learnings-Briefing vom Memory-Agent  
**Output:** Strukturierter Trend-Report (Markdown)

**Aufgaben:**

- Aus der CEO-Idee die relevanten Suchfelder extrahieren (z.B. Genre, Mechaniken, Technologien)
- Aktuelle Mobile Gaming Trends recherchieren (was wächst, was stirbt)
- Spezifisch nach den Mechaniken der Idee suchen (z.B. AI-generated Levels, Match-3 Innovationen)
- Virale Mechaniken und Features identifizieren die gerade Engagement treiben
- Social und Community Trends im Gaming recherchieren
- Quellen dokumentieren und Datum der Daten festhalten
- Keine Bewertungen, keine Empfehlungen — nur Fakten und Daten

**Output-Format:**
```
# Trend-Report: [App-Arbeitstitel]
## Suchfelder (extrahiert aus CEO-Idee)
## Trend 1: [Name]
  - Status: wachsend / stagnierend / rückläufig
  - Daten: ...
  - Quellen: ...
## Trend 2: [Name]
  ...
```

---

### Agent 2: Competitor-Scan-Agent

**Rolle:** Wettbewerbsanalyse und Marktsättigung  
**Input:** Rohe CEO-Idee + Learnings-Briefing vom Memory-Agent  
**Output:** Competitive-Report (Markdown)

**Aufgaben:**

- Aus der CEO-Idee die direkten Wettbewerber-Kategorien ableiten
- Top Apps in diesen Kategorien identifizieren (Name, Publisher, Downloads wenn verfügbar)
- Für jede identifizierte App recherchieren: Kernmechanik, Monetarisierung, Rating, Nutzer-Beschwerden
- Öffentliche Revenue-Daten oder Schätzungen suchen wo verfügbar
- Feature-Vergleich erstellen: Was bieten die Wettbewerber was die CEO-Idee auch hat
- Lücken identifizieren: Was bietet keiner der Wettbewerber
- Marktsättigung einschätzen: Wie voll ist die Nische
- Klar markieren wo Daten fehlen oder nur geschätzt sind

**Output-Format:**
```
# Competitive-Report: [App-Arbeitstitel]
## Wettbewerber-Kategorie(n)
## Wettbewerber-Übersicht (Tabelle)
  | App | Publisher | Downloads | Rating | Monetarisierung | Kernmechanik |
## Detailanalyse pro Wettbewerber
  - Stärken / Schwächen / Nutzer-Beschwerden
## Feature-Vergleich (Tabelle)
## Gap-Analyse: Was fehlt im Markt
## Sättigungseinschätzung
## Datenlücken (was nicht verfügbar war)
```

---

### Agent 3: Zielgruppen-Analyst-Agent

**Rolle:** Datenbasierte Zielgruppen-Analyse  
**Input:** Rohe CEO-Idee + Learnings-Briefing vom Memory-Agent  
**Output:** Zielgruppen-Profil (Markdown)

**Aufgaben:**

- Aus der CEO-Idee die wahrscheinlichste Zielgruppe ableiten
- Datenbasiert recherchieren: Welche Altersgruppen spielen dieses Genre am meisten
- Regionale Verteilung recherchieren: Wo ist die Nachfrage am höchsten
- Ausgabeverhalten der Zielgruppe recherchieren: Wie viel geben sie für IAP, Battle Pass, etc. aus
- Session-Verhalten recherchieren: Wie lang und wie oft spielen sie
- Social-Verhalten recherchieren: Welche Community Features nutzt die Zielgruppe
- Plattform-Präferenz prüfen: iOS vs Android Verteilung in der Zielgruppe

**Output-Format:**
```
# Zielgruppen-Profil: [App-Arbeitstitel]
## Primäre Zielgruppe
  - Alter: ...
  - Region(en): ...
  - Spielertyp: ...
## Ausgabeverhalten
  - Durchschnittliche Ausgaben: ...
  - Bevorzugte Zahlungsmodelle: ...
## Session-Verhalten
  - Durchschnittliche Session-Länge: ...
  - Sessions pro Tag: ...
## Social-Verhalten
  - Genutzte Community Features: ...
## Plattform-Verteilung
  - iOS: ...%  |  Android: ...%
## Quellen
```

---

### Agent 4: Concept-Analyst-Agent

**Rolle:** Synthesizer — gleicht CEO-Idee mit Recherche-Daten ab und erstellt den finalen Concept Brief  
**Input:** Rohe CEO-Idee + Trend-Report (Agent 1) + Competitive-Report (Agent 2) + Zielgruppen-Profil (Agent 3)  
**Output:** Fertiger Concept Brief (Markdown)

**Aufgaben:**

- Alle drei Reports plus die originale CEO-Idee als Input nehmen
- Jeden Punkt der CEO-Idee gegen die Recherche-Daten abgleichen
- Wo die Idee mit den Trends übereinstimmt: bestätigen und begründen
- Wo die Idee gegen die Daten läuft: Anpassung vorschlagen und begründen warum
- Wo die Idee eine Lücke im Markt trifft: als Stärke hervorheben
- Monetarisierung konkretisieren basierend auf was bei der Zielgruppe funktioniert
- Core Loop definieren: Was passiert in den ersten 60 Sekunden
- Session-Design festlegen basierend auf Zielgruppen-Daten
- Tech-Stack Tendenz festlegen (noch keine finale Entscheidung)

**Output-Format:**
```
# Concept Brief: [App Name]
## One-Liner
## Kern-Mechanik & Core Loop
  - Beschreibung: ...
  - Begründung (Daten): ...
## Zielgruppe
  - Profil: ...
  - Begründung (Daten): ...
## Differenzierung zum Wettbewerb
  - Vergleiche: ...
  - Unique Selling Points: ...
## Monetarisierung
  - Modell: ...
  - Begründung (Daten): ...
## Session-Design
  - Ziel-Dauer: ...
  - Frequenz: ...
## Tech-Stack Tendenz
  - Empfehlung: ...
  - Begründung: ...
## Abweichungen von der CEO-Idee
  - [Feld]: Ursprünglich → Angepasst, weil ...
```

---

## Kapitel 2: Legal & Compliance Check

### Agent 5: Legal-Research-Agent

**Rolle:** Recherchiert die rechtliche Lage für alle relevanten Felder des Konzepts  
**Input:** Fertiger Concept Brief (von Agent 4)  
**Output:** Strukturierter Legal-Research-Report (Markdown)

**Aufgaben:**

- Den fertigen Concept Brief als Input nehmen und alle rechtlich relevanten Felder identifizieren
- Monetarisierung prüfen: Fallen Mechaniken unter Glücksspielrecht (Lootboxen, Gacha, Zufalls-Rewards)
- Länderspezifische Regulierungen recherchieren: Belgien, Niederlande, China, USA, EU jeweils separat
- In-App Purchase Regelungen recherchieren: Apple App Store Guidelines, Google Play Policies
- Rewarded Ads Regelungen recherchieren: Besondere Auflagen bei Minderjährigen
- AI-generierter Content: Urheberrechtslage recherchieren — wem gehört AI-generierter Output, darf er kommerziell genutzt werden
- Welches AI-Tool wird tendenziell eingesetzt und was sagen dessen Nutzungsbedingungen zur kommerziellen Verwertung
- Datenschutz: DSGVO-Anforderungen für Personalisierung und Spielstil-Tracking recherchieren
- COPPA prüfen: Falls Zielgruppe Kinder unter 13 einschließen könnte, welche Auflagen gelten
- Jugendschutz: USK/PEGI Einstufungskriterien recherchieren basierend auf den geplanten Features
- Social Features: Gibt es Auflagen für Chat, Freundeslisten, Social Challenges bei Minderjährigen
- Markenrecht: Prüfen ob der App-Name bereits geschützt ist oder Konflikte bestehen
- Patente: Recherchieren ob Kernmechaniken durch bestehende Patente geschützt sind
- Jedes Thema mit aktueller Quellenlage und Datum dokumentieren

**Output-Format:**
```
# Legal-Research-Report: [App Name]
## Identifizierte Rechtsfelder
## 1. Monetarisierung & Glücksspielrecht
  - Aktuelle Gesetzeslage: ...
  - Länderspezifisch: ...
  - Quellen: ...
## 2. App Store Richtlinien
  - Apple: ...
  - Google: ...
## 3. AI-generierter Content — Urheberrecht
  ...
## 4. Datenschutz (DSGVO, COPPA)
  ...
## 5. Jugendschutz (USK/PEGI)
  ...
## 6. Social Features — Auflagen
  ...
## 7. Markenrecht — Namenskonflikt
  ...
## 8. Patente
  ...
## Hinweis
Dieser Report ist eine KI-basierte Ersteinschätzung und ersetzt keine rechtsverbindliche Beratung.
```

---

### Agent 6: Risk-Assessment-Agent

**Rolle:** Bewertet Risiken, schätzt Kosten, liefert Entscheidungsgrundlage für CEO-Gate  
**Input:** Concept Brief (Agent 4) + Legal-Research-Report (Agent 5)  
**Output:** Risk-Assessment-Report (Markdown)

**Aufgaben:**

- Concept Brief plus Legal-Research-Report als Input nehmen
- Für jedes identifizierte Rechtsfeld eine Risiko-Bewertung erstellen: 🟢 Grün (kein Problem), 🟡 Gelb (machbar mit Aufwand), 🔴 Rot (kritisch)
- Bei Gelb und Rot: Geschätzte Kosten recherchieren (Lizenzgebühren, Anwaltskosten, Zertifizierungskosten, Altersfreigabe-Verfahren)
- Bei Rot: Konkrete Alternativen vorschlagen die das Problem umgehen (z.B. Lootboxen ersetzen durch transparenten Shop)
- Regionale Launch-Einschränkungen auflisten: In welchen Ländern ist ein Launch mit dem aktuellen Konzept nicht möglich
- Prüfen ob Anpassungen am Konzept die roten Felder auf Gelb oder Grün bringen können
- Gesamtkosten-Schätzung für Compliance erstellen: Was kostet es das Konzept rechtssicher zu machen
- Zeitaufwand-Schätzung: Wie lange dauern Zertifizierungen, Anmeldungen, Prüfungen
- Finale Zusammenfassung mit klarer Empfehlung: Gesamtrisiko Grün/Gelb/Rot und warum
- Hinweis einfügen dass dieser Report eine KI-basierte Ersteinschätzung ist und keine rechtsverbindliche Beratung ersetzt

**Output-Format:**
```
# Risk-Assessment-Report: [App Name]

## Risiko-Übersicht (Ampel-Tabelle)
| Rechtsfeld | Risiko | Geschätzte Kosten | Zeitaufwand |
|---|---|---|---|
| Glücksspielrecht | 🟡 Gelb | ~X € | X Wochen |
| Datenschutz | 🟢 Grün | — | — |
| ... | ... | ... | ... |

## Detailbewertung pro Feld
### 1. [Feld]
  - Risiko: ...
  - Begründung: ...
  - Kosten: ...
  - Alternative (falls Rot/Gelb): ...

## Regionale Einschränkungen
  - [Land]: Nicht launchbar weil ...
  - [Land]: Eingeschränkt weil ...

## Gesamtkosten-Schätzung Compliance
  - Einmalig: ...
  - Laufend: ...

## Zeitaufwand gesamt
  - Geschätzt: ...

## Gesamtrisiko-Bewertung
  - [🟢/🟡/🔴] — Begründung: ...

## CEO-Entscheidungsgrundlage
  - Bei GO: Diese Maßnahmen sind nötig: ...
  - Bei KILL: Hauptgründe: ...

## Hinweis
Dieser Report ist eine KI-basierte Ersteinschätzung und ersetzt keine rechtsverbindliche Beratung.
```

---

## Übergreifend: Agent 7 — Phase-1-Memory-Agent

**Rolle:** Persistenter Wissensspeicher und Lern-Agent für die gesamte Phase 1  
**Input (vor Durchlauf):** Bisherige Learnings-Datenbank  
**Input (nach Durchlauf):** CEO-Idee, Concept Brief, Legal-Report, Risk-Report, CEO-Entscheidung + Begründung  
**Output:** Learnings-Briefing (vor Durchlauf) + aktualisierte Wissensdatenbank (nach Durchlauf)

**Aufgaben vor jedem Durchlauf:**

- Learnings-Datenbank lesen
- Relevante Erkenntnisse aus früheren Durchläufen extrahieren
- Learnings-Briefing an Agent 1 bis 6 erstellen (z.B. "Bei Konzepten mit Personalisierung war COPPA bisher immer ein Thema — priorisiere das hoch")

**Aufgaben nach dem CEO-Gate:**

- Kompletten Durchlauf speichern: CEO-Idee, alle Reports, CEO-Entscheidung und Begründung
- Bei Kill: Grund kategorisieren (rechtlich, finanziell, Markt, Sättigung, etc.)
- Bei Go: Dokumentieren welche Anpassungen vom Original abweichen und warum
- Aggregierte Learnings-Datei aktualisieren mit neuen Erkenntnissen

**Speicherformat:**

```
/driveai-factory/memory/phase1/
├── durchlaeufe/
│   ├── 001_echomatch.md
│   ├── 002_[naechste-idee].md
│   └── ...
└── learnings.md  (aggregierte Erkenntnisse)
```

**Learnings-Datei Struktur:**
```
# Phase-1 Learnings (aktualisiert nach jedem Durchlauf)

## Trends
- [Erkenntnis]: Quelle: Durchlauf #X

## Rechtliches
- [Erkenntnis]: Quelle: Durchlauf #X

## Zielgruppen
- [Erkenntnis]: Quelle: Durchlauf #X

## Wettbewerb
- [Erkenntnis]: Quelle: Durchlauf #X

## Kill-Gründe (Häufigkeit)
- Rechtlich: X mal
- Finanziell: X mal
- ...
```

---

## Hinweise

- Die ersten 1–2 Durchläufe laufen ohne Learnings (Memory-Agent hat noch keine Daten — das ist normal)
- Alle Agents arbeiten mit Web-Recherche auf öffentlich zugängliche Daten
- Wo Daten fehlen (z.B. hinter Paywalls wie Sensor Tower Premium), wird das klar markiert
- Der CEO kann jederzeit entscheiden, zusätzliche Datenquellen (Paid APIs) anzubinden
- Dieser Fahrplan deckt NUR Phase 1 ab — Phase 2 (ab CEO-Go bis Roadbook/Creative Director) wird separat geplant

---

*DriveAI Swarm Factory — Pre-Production Pipeline v1.0*
*Erstellt: 2026-03-19*
