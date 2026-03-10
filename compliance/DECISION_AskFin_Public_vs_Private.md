# AskFin: Public vs. Private — Entscheidungs-Assessment

Erstellt: 2026-03-10
Typ: Planning / Compliance / Product Decision
Status: Draft — keine Rechtsberatung, nur Risiko-Einschätzung

---

## Ausgangslage

AskFin ist eine iOS-Lern-App für die deutsche Führerscheinprüfung (Theorie).
Ursprünglich als privates Familienprojekt gestartet.
Frage: Ist ein öffentlicher App Store Release realistisch und sinnvoll?

---

## Szenario 1: Privat / Familiennutzung

### Risiko-Einschätzung

| Bereich | Risiko | Begründung |
|---|---|---|
| Urheberrecht | **Niedrig** | Private Nutzung zu Lernzwecken ist in der Regel durch Schrankenregelungen gedeckt (§ 53 UrhG — Privatkopie) |
| Lizenzierung | **Niedrig** | Keine kommerzielle Verwertung, kein öffentliches Zugänglichmachen |
| Plattform-Policies | **Entfällt** | Kein App Store Release |
| DSGVO | **Niedrig** | Nur Familienmitglieder als Nutzer, keine externe Datenverarbeitung |
| Haftung | **Niedrig** | Kein öffentliches Angebot, keine Gewährleistungspflichten |

### Gesamtrisiko: NIEDRIG

### Praktische Machbarkeit: HOCH

- App kann frei entwickelt und intern genutzt werden
- Offizielle Prüfungsfragen können als Lernmaterial eingesetzt werden (Privatgebrauch)
- Bilder/Illustrationen aus offiziellen Quellen: im privaten Rahmen unproblematisch
- Keine App Store Review, keine Compliance-Anforderungen
- Verteilung per TestFlight (bis 100 Tester) oder Xcode Direct Install

### Einschränkungen

- Kein Revenue
- Keine öffentliche Sichtbarkeit
- Begrenzte Nutzerbasis
- Kein Portfolio-/Showcase-Wert nach außen

---

## Szenario 2: Öffentlich / App Store

### Risiko-Einschätzung

| Bereich | Risiko | Begründung |
|---|---|---|
| Urheberrecht (Fragen) | **Hoch** | Offizielle Führerschein-Prüfungsfragen sind urheberrechtlich geschützt. Rechteinhaber: TÜV | DEKRA über die "Arbeitsgemeinschaft der Technischen Prüfstellen" (arge tp 21). Lizenzierung ist kostenpflichtig und an strenge Bedingungen geknüpft. |
| Urheberrecht (Bilder) | **Hoch** | Offizielle Prüfungsbilder/Illustrationen sind separat lizenziert. Nutzung ohne Lizenz = Urheberrechtsverletzung. |
| Lizenzierung | **Hoch** | Offizielle Fragenkataloge werden nur an lizenzierte Anbieter vergeben. Lizenzgebühren sind erheblich (geschätzt 5-stellig/Jahr). Kleinere Anbieter werden regelmäßig abgemahnt. |
| Markenrecht | **Mittel** | Begriffe wie "Führerscheinprüfung", "Theorieprüfung" sind generisch. Aber: Bezugnahme auf TÜV/DEKRA als Marken vermeiden. |
| App Store Policies | **Mittel** | Apple prüft auf IP-Verletzungen. Bei Beschwerden durch Rechteinhaber → sofortige Entfernung möglich. |
| DSGVO | **Mittel** | Öffentliche App erfordert: Datenschutzerklärung, Einwilligungsmechanismus, Auskunftsrechte, ggf. Auftragsverarbeitungsverträge bei Analytics/Crash-Reporting. |
| Regulierte Domain | **Mittel** | Bildungsbereich: Keine Zulassungspflicht, aber irreführende Darstellung ("offizielle Prüfungsvorbereitung") kann wettbewerbsrechtlich problematisch sein (UWG). |
| KI-generierte Inhalte | **Niedrig-Mittel** | Wenn Erklärungen KI-generiert sind: Kennzeichnungspflicht möglich (EU AI Act ab 2026). Falsche Erklärungen können Vertrauen und Bewertungen beschädigen. |
| Haftung | **Mittel** | Bei falschen Antworten/Erklärungen: Keine direkte Haftung für Prüfungsergebnisse, aber Verbraucherschutz greift bei kostenpflichtiger App. |

### Gesamtrisiko: HOCH

### Wahrscheinliche Blocker

1. **Fragenkatalog-Lizenz** — Ohne Lizenz keine offiziellen Fragen. Mit Lizenz: hohe Kosten, strenge Auflagen.
2. **Bild-Lizenz** — Offizielle Prüfungsbilder separat lizenziert. Eigene Bilder nötig oder Lizenz erwerben.
3. **Abmahnrisiko** — Etablierte Anbieter (Fahren Lernen, theorie24) haben Rechtsabteilungen und gehen aktiv gegen unlizenzierte Konkurrenz vor.

### Workaround-Optionen

| Option | Machbarkeit | Aufwand | Risiko-Reduktion |
|---|---|---|---|
| **Eigener Fragenkatalog** | Möglich | Hoch (500+ Fragen erstellen, fachlich prüfen) | Eliminiert Urheberrechtsrisiko für Fragen |
| **Eigene Illustrationen** | Möglich | Hoch (KI-generiert oder Grafiker beauftragen) | Eliminiert Bildrechte-Problem |
| **"Inoffiziell"-Positionierung** | Einfach | Niedrig (Disclaimer, Naming) | Reduziert Marken- und Irreführungsrisiko |
| **Disclaimer** | Einfach | Niedrig | Reduziert Haftungsrisiko, aber nicht Urheberrecht |
| **Freemium ohne offizielle Fragen** | Möglich | Mittel | Umgeht Lizenzproblem, reduziert Wert |
| **Offizielle Lizenz erwerben** | Theoretisch möglich | Sehr hoch (Kosten + Auflagen) | Eliminiert alle Rechteprobleme |

### Aufwand-Schätzung für App-Store-Ready (ohne offizielle Lizenz)

| Aufgabe | Geschätzter Aufwand |
|---|---|
| Eigenen Fragenkatalog erstellen (500+ Fragen) | Wochen bis Monate |
| Eigene Illustrationen (Verkehrssituationen) | Wochen |
| DSGVO-Compliance (Datenschutz, Consent, Impressum) | Tage |
| App Store Listing + Screenshots + Beschreibung | Tage |
| Legal Disclaimer Integration | Stunden |
| Fachliche Prüfung der Inhalte | Wochen |
| **Gesamt** | **2-4 Monate Vollzeit** |

---

## Szenario 3: Factory Showcase / Internes Produkt

### Beschreibung

AskFin wird nicht als Consumer-Produkt veröffentlicht, sondern dient als:
- Referenzprojekt für die AI App Factory
- Demonstrator für das Multi-Agent-System (14 Agents, 8 Data Stores)
- Portfolio-Stück für YouTube-Content und Entwickler-Community
- Testbett für neue Factory-Features (Agents, Pipelines, Workflows)

### Risiko-Einschätzung

| Bereich | Risiko | Begründung |
|---|---|---|
| Urheberrecht | **Niedrig** | Keine öffentliche Verbreitung der App selbst. Code und Architektur sind eigenes Werk. |
| Showcase-Nutzung | **Niedrig** | Screenshots/Videos der eigenen App für YouTube/Portfolio sind unproblematisch. |
| IP der Factory | **Kein Risiko** | Die AI App Factory selbst (Agents, Pipeline, Docs) ist komplett eigenes Werk. |

### Gesamtrisiko: NIEDRIG

### Vorteile

- Kein Rechtsrisiko
- Voller Showcase-Wert für YouTube und Portfolio
- Factory-Weiterentwicklung profitiert von realem Testprojekt
- Kann jederzeit zu Szenario 1 (privat) oder 2 (öffentlich) erweitert werden
- Kein Zeitdruck für Lizenzfragen

---

## Empfehlung

### Kurzfristig (jetzt)

**Szenario 3: Factory Showcase + Szenario 1: Private Nutzung**

- AskFin als internes Familien-Tool und Factory-Demonstrator weiterbetreiben
- Für YouTube: App-Architektur und Factory-System zeigen (eigener Code, kein geschützter Content)
- Kein App Store Release anstreben

### Mittelfristig (wenn gewünscht)

**Szenario 2 evaluieren — aber nur mit eigenem Content:**

- Eigenen Fragenkatalog aufbauen (kann KI-unterstützt sein, muss fachlich geprüft werden)
- Eigene Illustrationen (KI-generiert + manuelle Nachbearbeitung)
- "Inoffizielle Lernhilfe"-Positionierung
- DSGVO-Compliance aufbauen
- Dann App Store Release mit eigenem Content

### Nicht empfohlen

- App Store Release mit offiziellen Prüfungsfragen ohne Lizenz → **Abmahnrisiko zu hoch**
- Offizielle Lizenz erwerben → **Kosten/Nutzen-Verhältnis für Einzelentwickler unrealistisch**

---

## Entscheidungsmatrix

| Szenario | Risiko | Aufwand | Revenue | Showcase-Wert | Empfehlung |
|---|---|---|---|---|---|
| Privat (Familie) | Niedrig | Keiner | Keiner | Niedrig | Ja |
| Öffentlich (offizielle Fragen) | Kritisch | Mittel | Möglich | Hoch | Nein |
| Öffentlich (eigener Content) | Niedrig-Mittel | Sehr hoch | Möglich | Hoch | Später evaluieren |
| Factory Showcase | Niedrig | Keiner | Indirekt (YouTube) | Sehr hoch | Ja (Hauptfokus) |

---

## Nächste Schritte

1. Entscheidung treffen: Showcase + Privat als Hauptpfad bestätigen
2. Falls öffentlicher Release gewünscht: Eigenen Fragenkatalog als separates Projekt planen
3. Factory weiter ausbauen — AskFin als lebendes Testprojekt nutzen
4. YouTube-Content auf Factory-System fokussieren (kein geschützter Prüfungscontent zeigen)

---

*Dieses Dokument ist eine Risiko-Einschätzung und keine Rechtsberatung. Bei konkreten Rechtsfragen sollte ein auf IT-/Medienrecht spezialisierter Anwalt konsultiert werden.*
