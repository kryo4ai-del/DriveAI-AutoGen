# DriveAI Swarm Factory — Pre-Production Pipeline
# Phase 2, Kapitel 4: MVP & Feature Scope

---

## Übersicht

Kapitel 4 definiert was tatsächlich gebaut wird. Basierend auf allen Dokumenten aus Kapitel 1–3 (Concept Brief, Tech Brief, Legal Summary, CEO Briefings, Marketing-Konzept, Kostenkalkulation) werden alle Features extrahiert, gegen den Tech-Stack geprüft, in zwei MVP-Schnitte priorisiert (Phase A Soft-Launch + Phase B Full Production) und in eine vollständige Screen-Architektur mit User Flows überführt.

**Eingang:** Alle Dokumente aus Kapitel 1–3 (6 Reports + Fahrpläne)
**Ausgang:** Vollständige Feature-Liste, priorisierte Feature-Map mit Budget-Check, Screen-Architektur mit User Flows und Edge Cases
**Agents:** 3 (Agent 13–15)
**Menschlicher Eingriff:** Keiner

**Wichtige Anpassung gegenüber ursprünglicher Planung:**
Die Factory hat in Kapitel 1–3 deutlich mehr Output geliefert als erwartet — insbesondere einen Tech Brief mit konkretem Stack (Unity 2022 LTS, Core ML/TF Lite, Firebase, Cloud Run), harte KPI-Targets (D1 ≥40%, D7 ≥20%, D30 ≥10%) und eine zweistufige Kostenstruktur (Phase A €252.500 / Phase B €230.000). Alle drei Agents in Kapitel 4 sind darauf angepasst.

---

## Gesamtfluss Kapitel 4

```
Alle Dokumente aus Kapitel 1–3
(Concept Brief, Tech Brief, Legal Summary,
CEO Briefings, Marketing-Konzept, Kosten-Kalkulation)
        │
        ▼
┌─────────────────────────────────────────────┐
│  Agent 13: Feature-Extraction               │
│  Extrahiert ALLE Features aus ALLEN Docs    │
│  Prüft Tech-Stack Kompatibilität            │
└─────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────┐
│  Agent 14: Feature-Priorisierung            │
│  Phase-A MVP (Soft-Launch, €252.500)        │
│  Phase-B Full Production (€230.000)         │
│  Backlog + Budget-Check                     │
└─────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────┐
│  Agent 15: Screen-Architektur               │
│  Screens basierend auf Phase-A Features     │
│  Navigation + User Flows + Edge Cases       │
│  Phase-B Screens separat markiert           │
└─────────────────────────────────────────────┘
        │
        ▼
Kapitel 4 komplett → weiter zu Kapitel 5 (Visual & Asset Audit)
```

---

## Agent 13: Feature-Extraction-Agent

**Rolle:** Extrahiert jedes Feature aus allen bisherigen Dokumenten — explizit genannte und implizit benötigte
**Input:** Concept Brief, Tech Brief, Legal Summary, CEO Briefings (Phase 1+2), Marketing-Konzept, Risk-Assessment
**Output:** Vollständige Feature-Liste (Markdown)

**Aufgaben:**

- Aus dem Concept Brief extrahieren:
  - Match-3 Core Loop (klassische Swipe-Puzzle-Mechanik)
  - KI-Level-Generierung (tägliche neue Levels basierend auf Spielstil)
  - Spielstil-Tracking (implizit ab erstem Match, Profil: kooperativ/kompetitiv/entspannend)
  - Narrative Meta-Layer mit KI-generierten Tages-Quests
  - Social Challenge-Layer (asynchrone Friend-Challenges)
  - Kooperative Team-Events
  - 60-Sekunden-Onboarding-Flow (15–20s Onboarding-Match → 10s Narrative Hook → 2–3min erster Run → Social-Nudge)

- Aus dem Monetarisierungs-Report extrahieren:
  - Battle-Pass System mit saisonaler Rotation (alle 4–6 Wochen)
  - Rewarded Ads Integration mit Frequenz-Steuerung (max X pro Session)
  - Kosmetischer IAP-Shop (kein Pay-to-Win)
  - Virtuelle Währung / Punkte-System mit Umrechnungskurs
  - Preispunkt-Varianten für A/B-Testing ($4,99 vs. $7,99 Battle Pass)
  - Revenue-Tracking pro Kanal (Ads, Pass, IAP)

- Aus dem Legal-Report extrahieren:
  - DSGVO-Consent-Screen vor erstem Tracking
  - Age-Gating / Altersverifikation (unter 16 DE, unter 13 COPPA)
  - COPPA-konformer Tracking-Opt-Out für Under-13-Kohorte
  - Consent-Management-Platform (CMP) Integration
  - ATT-Prompt (iOS) mit Fallback bei Ablehnung
  - Privacy Nutrition Labels (iOS) und Data Safety Section (Android)
  - Datenschutzerklärung In-App
  - Deterministisches Reward-Design (kein variabler IAP-Randomizer, Glücksspielrecht-Konformität)

- Aus dem Marketing-Konzept extrahieren:
  - Social-Sharing-Funktionen (Screenshot-Results, Level-Completion-Cards)
  - Referral-System
  - Deep Links für UA-Kampagnen (Meta Ads, Google UAC, TikTok)
  - Push-Notification-System mit personalisierten Triggern (A/B-Test-fähig)
  - In-App Rating-Prompt (Timing optimiert für ≥4,2 Sterne Ziel)
  - Pre-Register / Waitlist Integration
  - Social-Sharing-Nudges nach Level-Completion

- Aus dem Tech Brief extrahieren:
  - On-Device Spielstil-Klassifikation (Core ML auf iOS, TF Lite auf Android)
  - Cloud-seitige Level-Generierung (Google Cloud Run + Custom Model)
  - Firebase Backend (Firestore für Social/Leaderboards, Auth für User-Management, Cloud Functions für Event-Verarbeitung)
  - Analytics Dual-Stack (Firebase Analytics + GameAnalytics)
  - CI/CD Pipeline (Unity Cloud Build + GitHub Actions)
  - Crash-Reporting (Firebase Crashlytics)
  - Cloud Save (Unity Gaming Services)
  - Remote Config für Feature-Flags

- Aus dem Release-Plan extrahieren:
  - A/B-Test Framework für KI-generierte vs. manuell kuratierte Levels (Phase 0)
  - Remote Config für regionale Feature-Steuerung (Soft-Launch Märkte)
  - Server-Monitoring und Alerting (Ziel: ≥99,5% Uptime)
  - Rollback-Mechanismus bei kritischen Bugs
  - Feature-Flag-System für gestaffelten Feature-Rollout

- Aus dem Risk-Assessment extrahieren:
  - Cold-Start-Fallback bei fehlendem ATT-Consent (KI muss ohne personalisiertes Tracking funktionieren, generische Levels als Fallback)
  - On-Device Processing Fallback bei Cloud-Ausfall (lokaler Level-Cache)
  - Offline-Modus für Core-Loop (Match ohne Server-Verbindung spielbar)

- Jedes Feature bekommt:
  - Eindeutige ID (F001, F002, ...)
  - Feature-Name
  - Kurze Beschreibung (1–2 Sätze)
  - Quelle (welches Dokument erfordert dieses Feature)
  - Tech-Stack Kompatibilität (✅ kompatibel / ⚠️ Einschränkung / ❌ nicht umsetzbar mit aktuellem Stack)

- Bei ⚠️ oder ❌: Konkret beschreiben was das Problem ist und einen Lösungsvorschlag machen

**Output-Format:**
```
# Feature-Liste: EchoMatch
## Gesamtanzahl: X Features

### Core Gameplay
| ID | Feature | Beschreibung | Quelle | Tech-Stack |
|---|---|---|---|---|
| F001 | Match-3 Core Loop | Klassische Swipe-Puzzle-Mechanik | Concept Brief | ✅ Unity 2D |
| F002 | KI-Level-Generierung | Tägliche neue Levels basierend auf Spielstil | Concept Brief + Tech Brief | ✅ Cloud Run |
| F003 | Spielstil-Tracking | Implizites Behavioral-Tracking ab erstem Match | Concept Brief + Tech Brief | ✅ Core ML / TF Lite |
| ...

### Narrative & Story
| ID | Feature | Beschreibung | Quelle | Tech-Stack |
| ...

### Social & Multiplayer
| ID | Feature | Beschreibung | Quelle | Tech-Stack |
| ...

### Monetarisierung
| ID | Feature | Beschreibung | Quelle | Tech-Stack |
| ...

### Legal & Compliance
| ID | Feature | Beschreibung | Quelle | Tech-Stack |
| ...

### Marketing & Growth
| ID | Feature | Beschreibung | Quelle | Tech-Stack |
| ...

### Backend & Infrastruktur
| ID | Feature | Beschreibung | Quelle | Tech-Stack |
| ...

### Analytics & Monitoring
| ID | Feature | Beschreibung | Quelle | Tech-Stack |
| ...

## Tech-Stack Konflikte
| Feature-ID | Feature | Problem | Lösungsvorschlag |
|---|---|---|---|
| ... | ... | ... | ... |

## Zusammenfassung
- Gesamtanzahl Features: X
- Davon Tech-Stack kompatibel: X
- Davon mit Einschränkung: X
- Davon nicht umsetzbar: X
```

---

## Agent 14: Feature-Priorisierungs-Agent

**Rolle:** Priorisiert die Feature-Liste in zwei MVP-Schnitte (Phase A und Phase B) plus Backlog, basierend auf KPI-Targets, Budget und Release-Plan
**Input:** Vollständige Feature-Liste (Agent 13) + KPI-Targets aus CEO Briefings + Kostenkalkulation + Release-Plan
**Output:** Priorisierte Feature-Map (Markdown)

**Aufgaben:**

- Jeden Feature-Eintrag aus der Liste bewerten nach vier Kriterien:
  - **KPI-Impact:** Welche der harten KPIs beeinflusst dieses Feature direkt
    - D1-Retention ≥40% (Soft-Launch Markt)
    - D7-Retention ≥20% (Soft-Launch Markt)
    - D30-Retention ≥10% (Soft-Launch Markt)
    - Rewarded-Ad eCPM ≥$10
    - App-Store-Rating ≥4,2 Sterne
    - KI-Level-Latenz <2 Sekunden
    - Crash-Rate <2% der Sessions
    - Sessions pro Tag ≥2,0
    - Session-Dauer 6–10 Minuten
  - **Revenue-Impact:** Wie kritisch ist das Feature für die Monetarisierung ab Tag 1 (Hoch / Mittel / Niedrig / Kein)
  - **Technische Komplexität:** Geschätzter Aufwand in Entwicklerwochen basierend auf dem definierten Tech-Stack
  - **Abhängigkeiten:** Welche anderen Features (Feature-IDs) müssen vorher fertig sein

- **Phase-A-Schnitt (MVP Soft-Launch-Ready):**
  - Budget: €252.500
  - Ziel: Soft Launch in AU/CA/NZ mit validierbaren KPIs
  - Harter Einschluss-Test: Kann der Soft Launch ohne dieses Feature stattfinden UND die KPIs D1 ≥40%, D7 ≥20% erreichen?
  - Wenn NEIN → Phase A (muss rein)
  - Wenn JA → Phase B oder Backlog
  - Legal-Pflichten sind immer Phase A (DSGVO-Consent, Age-Gating, ATT — kein Launch ohne)
  - KI-PoC muss in Phase A enthalten sein (explizites Go/No-Go Kriterium laut Release-Plan)
  - Basis-Monetarisierung muss in Phase A stehen (Rewarded Ads + Basis-IAP, Battle Pass kann vereinfacht sein)

- **Phase-B-Schnitt (Full Production):**
  - Budget: €230.000 (wird nur bei positivem Soft-Launch-Ergebnis ausgelöst)
  - Ziel: Tier-1 Global Launch in USA, UK, DE, AU, CA
  - Features die den Soft-Launch-Learnings entsprechen: Vollständiger Battle-Pass mit saisonaler Rotation, erweitertes Social-System (Teams/Gilden), Live-Ops Event-Infrastruktur, vollständige KI-Personalisierung (falls Phase A mit Hybrid-Kuration lief), skalierte Push-Notification-Strategie, erweitertes Analytics (Amplitude Evaluation)

- **Backlog (Post-Launch Updates):**
  - Features die für Version 1.0 nicht nötig sind
  - Priorisiert nach erwartetem Impact für spätere Versionen
  - Jedes Feature mit Begründung warum es verschoben wird

- Budget-Check pro Phase:
  - Geschätzter Gesamtaufwand in Entwicklerwochen × Durchschnittssatz (€80–120/h, DACH-Marktsätze laut Kostenkalkulation)
  - Gegen verfügbares Budget halten
  - Falls über Budget: Konkrete Streichungs- oder Vereinfachungs-Vorschläge mit Risikobewertung

- Abhängigkeits-Graph erstellen:
  - Welche Features müssen in welcher Reihenfolge gebaut werden
  - Kritischer Pfad identifizieren: Die längste Kette von abhängigen Features die den Timeline bestimmt
  - Parallelisierbare Features markieren

- Für jede Priorisierungs-Entscheidung eine kurze Begründung dokumentieren

**Output-Format:**
```
# Feature-Priorisierung: EchoMatch

## Phase A — Soft-Launch MVP (Budget: €252.500)

### Feature-Liste Phase A
| ID | Feature | KPI-Impact | Revenue-Impact | Komplexität | Abhängig von | Begründung |
|---|---|---|---|---|---|---|
| F001 | Match-3 Core Loop | D1, D7, Session-Dauer | — | 6 Wochen | — | Core — ohne geht nichts |
| F002 | KI-Level-Generierung (PoC) | D7, D30 | — | 4 Wochen | F001 | PoC ist Phase-0 Go/No-Go |
| F005 | DSGVO-Consent-Screen | — | — | 1 Woche | — | Legal-Pflicht vor Tracking |
| F010 | Rewarded Ads Basis | eCPM ≥$10 | Hoch | 2 Wochen | F001 | Monetarisierung ab Tag 1 |
| ...

### Phase-A Budget-Check
  - Geschätzter Aufwand gesamt: X Entwicklerwochen
  - Geschätzte Kosten: €X (bei Ø €100/h)
  - Budget verfügbar: €252.500
  - Status: ✅ im Budget / ⚠️ €X über Budget

### Phase-A Abhängigkeits-Graph
```
F001 (Core Loop)
  ├── F002 (KI-Levels) → F003 (Spielstil-Tracking)
  ├── F010 (Rewarded Ads)
  └── F008 (Narrative Basis)

F005 (Consent) → F003 (Tracking) → F002 (KI-Levels)

Kritischer Pfad: F001 → F002 → F003 → KI-PoC-Validierung
Geschätzte Dauer kritischer Pfad: X Wochen
```

### Parallelisierbare Features
  - F005 (Consent) parallel zu F001 (Core Loop)
  - F010 (Ads) parallel zu F008 (Narrative)
  - ...

## Phase B — Full Production (Budget: €230.000)

### Feature-Liste Phase B
| ID | Feature | KPI-Impact | Revenue-Impact | Komplexität | Abhängig von | Begründung |
|---|---|---|---|---|---|---|
| F020 | Battle-Pass saisonale Rotation | D30, D60 | Hoch | 3 Wochen | F011 (Basis-Pass) | Recurring Revenue Anker |
| F025 | Live-Ops Event-System | D30 | Mittel | 4 Wochen | F001, F008 | Saisonale Events für Retention |
| ...

### Phase-B Budget-Check
  - Geschätzter Aufwand gesamt: X Entwicklerwochen
  - Geschätzte Kosten: €X
  - Budget verfügbar: €230.000
  - Status: ✅ / ⚠️

## Backlog (Post-Launch)
| ID | Feature | Geplant für | Erwarteter Impact | Begründung für Verschiebung |
|---|---|---|---|---|
| ... | ... | v1.2 | ... | Kein KPI-Impact für Launch |

## Streichungs-Vorschläge (falls Budget überschritten)
| Feature-ID | Feature | Einsparung | Risiko bei Streichung | Alternative |
|---|---|---|---|---|
| ... | ... | X Wochen / €X | ... | Vereinfachte Version: ... |

## Zusammenfassung
  - Phase A Features: X (davon X Core, X Legal, X Monetarisierung, X Infrastruktur)
  - Phase B Features: X
  - Backlog Features: X
  - Kritischer Pfad Phase A: X Wochen
  - Budget-Status Phase A: ✅ / ⚠️
  - Budget-Status Phase B: ✅ / ⚠️
```

---

## Agent 15: Screen-Architect-Agent

**Rolle:** Erstellt die vollständige Screen-Architektur, Navigation und User Flows basierend auf dem Phase-A MVP Feature-Set
**Input:** Priorisierte Feature-Map Phase A (Agent 14) + Concept Brief (60-Sekunden-Onboarding) + Marketing-Konzept (Social-Sharing UX)
**Output:** Screen-Architektur-Dokument (Markdown)

**Aufgaben:**

- Jeden Screen der App definieren basierend auf den Phase-A Features:
  - Screen-Name und eindeutige ID (S001, S002, ...)
  - Typ: Hauptscreen, Subscreen, Modal, Overlay
  - Zweck: Was tut der Nutzer hier (1 Satz)
  - Features: Welche Feature-IDs (aus Agent 13/14) sind auf diesem Screen sichtbar
  - UI-Elemente: Buttons, Listen, Anzeigen, Eingabefelder, Animationen, Popups
  - Zustandsvarianten: Normal, Leer-Zustand, Lade-Zustand, Fehler-Zustand, Offline-Zustand

- Screen-Hierarchie definieren:
  - Hauptscreens (Tab-Bar / Hauptnavigation): z.B. Home, Puzzle, Story, Social, Shop
  - Subscreens: z.B. Level-Auswahl, Freundesliste, Battle-Pass Detail, Einstellungen
  - Modale Screens: z.B. Consent-Dialog, Kauf-Bestätigung, Reward-Screen, Altersabfrage
  - Overlays: z.B. Tutorial-Hints, Achievement-Popups, Push-Permission-Request, Ad-Preview

- Navigation definieren:
  - Von jedem Screen zu jedem erreichbaren Screen
  - Gesten: Tap, Swipe, Back, Drag
  - Sackgassen identifizieren und vermeiden
  - Zurück-Navigation konsistent definieren

- **User Flows für kritische Pfade:**

  - **Flow 1: Onboarding (Erst-Start, 60 Sekunden laut Concept Brief)**
    - App öffnen → Splash/Loading → Altersabfrage → DSGVO-Consent → [iOS: ATT-Prompt] → Onboarding-Match (implizites Tracking startet) → Narrative Hook-Sequenz → erster vollständiger Match-3-Run → Social-Nudge → Home
    - Ziel: Maximal 2 Taps bis zum Core Loop
    - Zeitbudget: ~60 Sekunden bis erster Match gestartet
    - Fallback: Bei Consent-Ablehnung → generische Levels, kein Spielstil-Tracking

  - **Flow 2: Core Loop (wiederkehrend)**
    - Home → Level-Auswahl → Match-3 spielen → Ergebnis-Screen → Reward → nächstes Level oder Story-Quest
    - Ziel: Maximal 2 Taps bis zum Match
    - Session-Dauer-Ziel: 6–10 Minuten

  - **Flow 3: Erster Kauf**
    - Shop-Trigger (in Match-Ergebnis, Home oder Push) → Shop-Screen → Produkt-Auswahl → Kauf-Bestätigung (Apple/Google Payment Sheet) → Reward-Anzeige
    - Ziel: Maximal 3 Taps bis zum Kauf
    - Keine Sackgasse nach Kauf — Nutzer wird zurück in den Loop geführt

  - **Flow 4: Social Challenge**
    - Home → Social-Tab → Freundesliste → Challenge senden → [Freund spielt] → Ergebnis vergleichen
    - Ziel: Maximal 3 Taps bis Challenge gesendet

  - **Flow 5: Battle-Pass**
    - Home oder Post-Match → Pass-Übersicht → Fortschritt einsehen → Upgrade-Option → Kauf
    - Muss den Fortschritt visuell zeigen (was habe ich, was kommt als nächstes)

  - **Flow 6: Rewarded Ad**
    - Trigger in Match (Extra-Leben, Bonus-Reward) oder Shop → Ad-Preview-Overlay → Ad abspielen → Reward erhalten
    - Ziel: 1 Tap zum Trigger, kein Zwang (freiwillig)

  - **Flow 7: Consent (Detail)**
    - Erst-Start → Altersabfrage (unter 13 / 13–15 / 16+) → DSGVO-Info-Screen → Consent Ja/Nein → [iOS: ATT-Prompt Ja/Nein] → Weiterleitung basierend auf Ergebnis
    - Bei unter 13: COPPA-Modus (kein Behavioral-Tracking, elterlicher Consent erforderlich)
    - Bei 13–15 (DE): Elterlicher Consent für Tracking erforderlich
    - Bei Consent Nein: Generische Levels, kein Spielstil-Tracking, KI-Personalisierung deaktiviert
    - Bei ATT Nein (iOS): On-Device Processing ohne Cloud-Synchronisation der Spielstil-Daten

- **Tap-Count-Analyse:**
  - Für jeden Flow die Anzahl der Taps vom Ausgangspunkt bis zum Ziel zählen
  - Maximal 3 Taps bis zum Core Loop (Onboarding ausgenommen)
  - Maximal 3 Taps bis zum Kauf
  - Bei Überschreitung: Vorschlag zur Vereinfachung

- **Edge Cases pro Screen dokumentieren:**

  | Situation | Betroffene Screens | Erwartetes Verhalten |
  |---|---|---|
  | Allererster App-Start | Alle | Onboarding-Flow, keine vorherigen Daten, Tutorial-Overlays |
  | Consent komplett abgelehnt | S002, S003, alle Gameplay-Screens | Generische Levels, kein Tracking, reduzierte Personalisierung |
  | ATT abgelehnt (iOS) | S003, KI-Screens | On-Device-Only-Modus, keine Cloud-Sync von Spielstil-Daten |
  | Internetverlust mitten im Match | S006 (Match-Screen) | Match lokal weiterspielen, Ergebnis nach Reconnect synchronisieren |
  | KI-Level-Generierung fehlgeschlagen | S005, S006 | Fallback auf kuratiertes Level aus lokalem Cache, keine Fehlermeldung an Nutzer |
  | Kauf fehlgeschlagen | S014 (Kauf-Bestätigung) | Fehlermeldung, kein Geld abgebucht, Retry-Option |
  | Push-Notification abgelehnt | S004 (Home) | Kein Prompt wiederholen, In-App-Nudge nach 7 Tagen |
  | Server-Ausfall | Social-Screens, Leaderboards | Offline-Modus für Core-Loop, Social-Features grau/deaktiviert |
  | Nutzer unter 13 (COPPA) | S002, alle Tracking-Screens | Kein Behavioral-Tracking, kein Social mit Fremden, elterlicher Consent-Flow |

- **Phase-B Screens separat markieren:**
  - Screens die erst für den Global Launch gebaut werden müssen
  - Abhängigkeiten zu Phase-B Features dokumentieren
  - Platzhalter in Phase-A Navigation definieren (z.B. "Coming Soon" Badge)

**Output-Format:**
```
# Screen-Architektur: EchoMatch (Phase A MVP)

## Screen-Übersicht
| ID | Screen | Typ | Zweck | Features | Zustandsvarianten |
|---|---|---|---|---|---|
| S001 | Splash / Loading | Hauptscreen | App-Start, Asset-Loading | — | Normal, Slow-Connection |
| S002 | Consent-Dialog | Modal | DSGVO + Alter + ATT | F005, F006, F007 | Standard, Under-13, Under-16 |
| S003 | Onboarding-Match | Hauptscreen | Erstes implizites Tracking-Match | F001, F003 | Mit Tracking, Ohne Tracking |
| S004 | Home / Hub | Hauptscreen | Zentrale Navigation | F001, F010, F015 | Normal, Erst-Start, Offline |
| S005 | Level-Auswahl | Subscreen | Level wählen, Fortschritt sehen | F001, F002 | Normal, KI-Fallback |
| S006 | Match-Screen | Hauptscreen | Aktives Match-3 Gameplay | F001 | Normal, Offline, Tutorial |
| S007 | Narrative Hook | Hauptscreen | Story-Sequenz nach Onboarding | F008 | Standard |
| S008 | Story-Hub | Hauptscreen (Tab) | Story-Fortschritt, Tages-Quests | F008, F009 | Normal, Keine Quest |
| S009 | Quest-Detail | Subscreen | Quest-Beschreibung und Ziel | F009 | Aktiv, Abgeschlossen |
| S010 | Social-Hub | Hauptscreen (Tab) | Freunde, Challenges, Teams | F012, F013 | Normal, Keine Freunde, Offline |
| S011 | Freundesliste | Subscreen | Freunde verwalten, Challenge senden | F012 | Normal, Leer |
| S012 | Shop | Hauptscreen (Tab) | IAPs, Battle-Pass, Kosmetik | F010, F011, F014 | Normal, Sale-Aktiv |
| S013 | Produkt-Detail | Subscreen | Einzelnes Produkt, Kauf-Option | F014 | Normal |
| S014 | Kauf-Bestätigung | Modal | Payment Sheet, Bestätigung | F014 | Erfolgreich, Fehlgeschlagen |
| S015 | Reward-Screen | Modal | Belohnung anzeigen nach Aktion | F001, F010, F011 | Standard, Ad-Reward |
| S016 | Social-Nudge | Overlay | Aufforderung Freunde einladen | F012 | Standard, Skip-Option |
| S017 | Einstellungen | Subscreen | Account, Datenschutz, Notifications | F005, F006 | Standard |
| S018 | Ad-Preview | Overlay | Rewarded Ad Vorschau | F010 | Standard |
| ...

## Screen-Hierarchie

### Hauptnavigation (Tab-Bar)
  - Home / Hub (S004)
  - Puzzle / Level-Auswahl (S005)
  - Story (S008)
  - Social (S010)
  - Shop (S012)

### Subscreens
  - S005 → S006 (Match-Screen)
  - S005 → S009 (Quest-Detail)
  - S010 → S011 (Freundesliste)
  - S012 → S013 (Produkt-Detail)
  - S004 → S017 (Einstellungen)

### Modale Screens
  - S002 (Consent-Dialog)
  - S014 (Kauf-Bestätigung)
  - S015 (Reward-Screen)

### Overlays
  - S016 (Social-Nudge)
  - S018 (Ad-Preview)
  - Tutorial-Hints (kontextbasiert)
  - Achievement-Popup
  - Push-Permission-Request

## User Flows

### Flow 1: Onboarding (Erst-Start)
S001 Splash → S002 Consent (Alter + DSGVO + ATT) → S003 Onboarding-Match → S007 Narrative Hook → S006 Erster Run → S016 Social-Nudge → S004 Home

  - Taps bis Core Loop: 2 (Consent-Bestätigung + Match-Start)
  - Zeitbudget: ~60 Sekunden
  - Fallback bei Consent-Nein: S003 ohne Tracking → generische Levels

### Flow 2: Core Loop (wiederkehrend)
S004 Home → S005 Level-Auswahl → S006 Match → S015 Reward → S005 oder S008 Story

  - Taps bis Match: 2
  - Session-Ziel: 6–10 Minuten

### Flow 3: Erster Kauf
S004 Home → S012 Shop → S013 Produkt-Detail → S014 Kauf-Bestätigung → S015 Reward

  - Taps bis Kauf: 3
  - Nach Kauf: Zurück in Core Loop (kein Dead-End)

### Flow 4: Social Challenge
S004 Home → S010 Social → S011 Freunde → Challenge senden → S015 Ergebnis

  - Taps bis Challenge: 3

### Flow 5: Battle-Pass
S004 Home → S012 Shop → Pass-Übersicht → Fortschritt → Upgrade → S014 Kauf

  - Fortschritt visuell sichtbar (Progress-Bar)

### Flow 6: Rewarded Ad
[Trigger in S006 oder S015] → S018 Ad-Preview → Ad abspielen → Reward-Overlay

  - Taps: 1 (freiwilliger Trigger-Tap)

### Flow 7: Consent (Detail)
S001 → Altersabfrage → Routing:
  - Unter 13 → COPPA-Modus (kein Tracking, elterlicher Consent)
  - 13–15 → Elterlicher Consent für Tracking
  - 16+ → Standard DSGVO-Consent
→ [iOS: ATT-Prompt] → Fallback-Pfad bei Ablehnung → Weiter zu S003

## Edge Cases
| Situation | Betroffene Screens | Verhalten |
|---|---|---|
| Consent abgelehnt | S002, alle Gameplay | Generische Levels, kein Tracking, kein personalisierter Content |
| ATT abgelehnt (iOS) | KI-Screens | On-Device-Only, keine Cloud-Sync |
| Internetverlust im Match | S006 | Lokal weiterspielen, nach Reconnect synchronisieren |
| KI-Level-Generation fehlgeschlagen | S005, S006 | Kuratiertes Level aus Cache, kein Fehler sichtbar |
| Kauf fehlgeschlagen | S014 | Fehlermeldung, kein Abzug, Retry |
| Server-Ausfall | S010, S011, Leaderboards | Core-Loop offline spielbar, Social-Features deaktiviert |
| Nutzer unter 13 (COPPA) | S002, alle | Kein Tracking, kein Social mit Fremden, eingeschränkter Shop |
| Push abgelehnt | S004 | Kein erneuter Prompt, In-App-Nudge nach 7 Tagen |

## Phase-B Screens (erst für Global Launch)
| ID | Screen | Zweck | Abhängig von |
|---|---|---|---|
| S020 | Live-Ops Event-Hub | Saisonale Events, zeitbegrenzte Challenges | Phase-B Feature-Set |
| S021 | Erweitertes Team-System | Gilden-Management, Team-Leaderboards | Social-Layer Ausbau |
| S022 | Erweiterte Battle-Pass-Ansicht | Saisonale Rotation, Premium-Track | Battle-Pass v2 |
| S023 | Erweiterte Analytics-Ansicht (intern) | Amplitude-Dashboard-Integration | Phase-B Analytics |
| ... | ... | ... | ... |

  - In Phase A: Platzhalter in Navigation (z.B. "Coming Soon" Badge auf Event-Tab)
  - Phase-B Screens werden nach Soft-Launch-Learnings finalisiert

## Tap-Count-Zusammenfassung
| Flow | Taps bis Ziel | Ziel erreicht |
|---|---|---|
| Onboarding → Core Loop | 2 | ✅ (Ziel: max 3) |
| Core Loop → Match | 2 | ✅ |
| Home → Kauf | 3 | ✅ (Ziel: max 3) |
| Home → Social Challenge | 3 | ✅ |
| Rewarded Ad Trigger | 1 | ✅ |
```

---

## Zusammenfassung Kapitel 4

| Agent | Rolle | Input | Output |
|---|---|---|---|
| Agent 13 | Feature-Extraction | Alle 6 Reports aus Kapitel 1–3 | Vollständige Feature-Liste mit Tech-Check |
| Agent 14 | Feature-Priorisierung | Feature-Liste + KPIs + Budget + Release-Plan | Phase-A/B Schnitte + Budget-Check + Abhängigkeiten |
| Agent 15 | Screen-Architektur | Phase-A Features + Concept Brief + Marketing | Screens + Navigation + User Flows + Edge Cases |

**Reihenfolge:** Strikt sequenziell (Agent 13 → Agent 14 → Agent 15)

**Gesamt-Agent-Zählung nach Kapitel 4:** 15 Agents
- Phase 1: Agent 1–7 (Concept Brief + Legal + Memory)
- Kapitel 3: Agent 8–12 (Strategie + Marketing + Kosten)
- Kapitel 4: Agent 13–15 (Features + Priorisierung + Screens)

---

*DriveAI Swarm Factory — Pre-Production Pipeline v1.0*
*Phase 2, Kapitel 4*
*Erstellt: 2026-03-20*
