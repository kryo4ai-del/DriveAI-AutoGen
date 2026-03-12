# AskFin Premium Reframing

Last Updated: 2026-03-12

---

## Aktueller Stand

AskFin ist eine iOS-App fuer die deutsche Fuehrerscheinpruefung. Sie kann:
- Pruefungsfragen per Kamera scannen (OCR)
- Screenshots importieren und analysieren
- Verkehrszeichen erkennen
- Fragen per LLM erklaeren und beantworten
- Lernverlauf und Statistiken anzeigen
- Schwaechen identifizieren

**Technisch:** Funktional. BUILD SUCCEEDED. MVVM-Architektur, 182 Swift-Dateien, Services/ViewModels/Views sauber getrennt.

**Als Produkt:** Funktional, aber nicht motivierend.

---

## Warum der aktuelle Zustand nicht reicht

AskFin ist aktuell ein Werkzeug. Man oeffnet es, scannt eine Frage, bekommt eine Antwort, schliesst es wieder.

Das Problem:
1. **Kein Grund zurueckzukommen** -- es passiert nichts Neues zwischen den Sessions
2. **Kein Fortschrittsgefuehl** -- Statistiken zeigen Zahlen, aber keine Entwicklung
3. **Keine Persoenlichkeit** -- die App kommuniziert neutral, wie ein Taschenrechner
4. **Kein Rhythmus** -- kein taegliches Ritual, keine Gewohnheitsschleife
5. **Austauschbar** -- sieht aus und fuehlt sich an wie jede andere Lern-App

Der Nutzer hat keinen emotionalen Bezug zur App. Er benutzt sie, weil er muss -- nicht weil er will.

---

## Neue Produktvision

### In einem Satz
AskFin ist dein persoenlicher Fuehrerschein-Coach, der weiss wo du stehst, dich gezielt trainiert und dich pruefungsreif macht -- nicht irgendwann, sondern mit einem klaren Plan.

### Emotionaler Kern
**Von Pruefungsangst zu Pruefungssicherheit.**

Jeder, der fuer die Fuehrerscheinpruefung lernt, hat Angst durchzufallen. Das ist das Kernproblem -- nicht "ich brauche die richtigen Antworten", sondern "ich will sicher sein, dass ich bestehe".

AskFin soll dieses Sicherheitsgefuehl aufbauen. Nicht durch Masse (1000 Fragen durchklicken), sondern durch gezielte Vorbereitung (deine 47 Schwachstellen auf 12 reduzieren).

### Zielnutzer-Problem
"Ich lerne seit Wochen fuer die Theoriepruefung, aber ich weiss nicht ob ich bereit bin. Ich mache immer wieder die gleichen Fehler und hab keine Ahnung ob ich bestehen wuerde."

### Warum der Nutzer taeglich zurueckkommt
1. **Taegliche Challenge** -- 5-10 gezielte Fragen basierend auf seinen Schwaechen
2. **Pruefungsbereitschafts-Score** -- eine Zahl die von Tag zu Tag steigt (oder stagniert)
3. **Schwaechen-Abbau** -- sichtbar, wie Problemthemen verschwinden
4. **Streak** -- "17 Tage in Folge gelernt" erzeugt Verbindlichkeit
5. **Pruefungssimulation** -- "Wuerdest du heute bestehen?" mit realistischer Bewertung

### Warum der Nutzer es weiterempfiehlt
"Die App hat mir gesagt, dass ich in Vorfahrt schwach bin und hat mich so lange darauf trainiert bis ich es konnte. Die anderen Apps werfen dir einfach 1000 Fragen hin."

---

## Experience Pillars

### 1. Training Mode (Taegliches Lernen)

**Was:** Personalisierte taegliche Lern-Sessions
**Wie:** Adaptive Fragenauswahl basierend auf Schwaechen, Vergessenskurve und Themen-Abdeckung
**Gefuehl:** "Die App weiss was ich brauche"

Elemente:
- Taegliche Challenge (5-10 Fragen, ~5 Minuten)
- Themen-Fokus-Sessions (z.B. "Heute: Vorfahrt")
- Quick-Scan (eine Frage scannen, sofort Erklaerung)
- Wiederholungs-Queue (Fragen die zuletzt falsch waren)

### 2. Skill Map (Kompetenz-Uebersicht)

**Was:** Visuelle Darstellung aller Pruefungsthemen und des eigenen Stands
**Wie:** Themen-Karte mit Farbkodierung (rot/gelb/gruen)
**Gefuehl:** "Ich sehe genau wo ich stehe"

Elemente:
- Themen-Grid (Vorfahrt, Technik, Umwelt, Verhalten, etc.)
- Kompetenz-Level pro Thema (nicht gelernt / unsicher / sicher / gemeistert)
- Schwaechen-Highlight (was zuerst trainiert werden sollte)
- Zeitlicher Verlauf (wie sich der Stand ueber Wochen veraendert)

### 3. Pruefungssimulation (Exam Mode)

**Was:** Realistische Pruefungssimulation unter echten Bedingungen
**Wie:** 30 Fragen, Zeitlimit, Fehlerpunkte-Berechnung, Bestanden/Nicht bestanden
**Gefuehl:** "Jetzt weiss ich ob ich bereit bin"

Elemente:
- Pruefung starten (mit Timer und Fehlerpunkte-Zaehler)
- Ergebnis mit Detail-Analyse (welche Themen haben Punkte gekostet)
- Verlauf der Simulationen (Score-Entwicklung ueber Zeit)
- "Pruefungsbereitschafts-Prognose" -- basierend auf den letzten Simulationen

### 4. Fortschritts-Visualisierung

**Was:** Sichtbare Entwicklung ueber die gesamte Lernzeit
**Wie:** Dashboard mit Key-Metriken und Verlaufsgraphen
**Gefuehl:** "Ich werde besser"

Elemente:
- Pruefungsbereitschafts-Score (0-100%, Hauptmetrik)
- Lern-Streak (Tage in Folge)
- Schwaechen-Counter (von 47 auf 12 reduziert)
- Woechentlicher Fortschrittsbericht
- Geschaetzte Tage bis Pruefungsbereitschaft

### 5. Motivational Feedback

**Was:** Kontextuelle, persoenliche Rueckmeldungen
**Wie:** Micro-Copy die auf den aktuellen Stand reagiert
**Gefuehl:** "Die App versteht mich"

Elemente:
- Nach richtig: Bestaetigung + kurze Erklaerung warum
- Nach falsch: Erklaerung ohne Vorwurf + Einordnung ("Das verwechseln 60% der Lernenden")
- Nach Serie: Anerkennung ("5 richtig in Folge -- Vorfahrt sitzt!")
- Nach Pause: Willkommen zurueck + sanfte Erinnerung ("Letzte Woche warst du bei 73%")
- Vor Pruefung: Aufbauend ("Deine letzten 3 Simulationen waren bestanden -- du bist bereit")

---

## Design-Signatur (Konzept)

### Visuelles Konzept
- **Primaerfarbe:** Dunkel (vertrauenswuerdig, fokussiert) mit einer Akzentfarbe fuer Fortschritt
- **Fortschritt = Farbe:** Gruen waechst, Rot schrumpft -- der visuelle Kern
- **Typografie:** Klar, gross, selbstbewusst -- keine kleinen grauen Labels
- **Animationen:** Subtil aber spuerbar -- Score-Aenderungen animiert, Schwaechen verschwinden visuell

### Interaktions-Signatur
- **Swipe-basiert** -- Fragen beantworten durch Wischen, nicht durch kleine Buttons
- **Haptic Feedback** -- richtig = leichtes Tap, falsch = kurzes Vibrieren
- **Progressive Disclosure** -- Erklaerungen klappen auf, nicht alles auf einmal

### Ton
- Sachlich aber warm
- Ermutigend ohne kindisch zu sein
- Direkt ohne harsch zu sein
- Beispiel: "Vorfahrt ist noch wackelig. 3 von 5 richtig -- aber letzte Woche waren es 1 von 5. Du bist dran."

---

## Abgrenzung zu Wettbewerbern

| App | Ansatz | Schwaeche |
|---|---|---|
| Fuehrerschein-Apps (Standard) | Fragenkatalog durchklicken | Kein adaptives Lernen, keine Motivation |
| Quizlet-Stil | Karteikarten | Keine Pruefungsstruktur, keine Schwaechen-Erkennung |
| Fahrschul-Apps | Offizieller Fragenkatalog | Copyright-Problem, kein eigener Content |

**AskFin-Differenzierung:** Nicht der Fragenkatalog macht den Unterschied, sondern das adaptive Lernsystem dahinter. AskFin trainiert dich -- die anderen testen dich nur.

---

## Offene Fragen (fuer naechste Phase)

1. **Content-Quelle:** Eigene Fragen erstellen vs. lizenzierte Fragen vs. Scan-only (Copyright-Thema LEGAL-001)
2. **LLM-Kosten:** Wie viel LLM-Nutzung pro Session ist wirtschaftlich tragbar?
3. **Offline-Faehigkeit:** Wie viel muss ohne Internet funktionieren?
4. **Monetarisierung:** Free mit Premium-Abo? Einmalkauf? Freemium?
5. **Pruefungsrelevanz:** Soll die App an echte Pruefungsfragen-Datenbanken angebunden werden (Lizenzkosten)?

---

## Naechste Schritte (nach Freigabe)

1. Experience Pillars priorisieren (was zuerst implementieren)
2. Design-System definieren (Farben, Typografie, Komponenten)
3. Training Mode als erstes Feature spezifizieren
4. Skill Map UI-Konzept skizzieren
5. Motivational Feedback Regeln definieren
