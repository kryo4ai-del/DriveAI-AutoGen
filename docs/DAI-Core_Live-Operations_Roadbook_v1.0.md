# DAI-Core Live Operations Roadbook v1.0

## Autonome Live-Operations für Apps

**Dokument:** Roadbook — Live Operations Layer  
**Version:** 1.0  
**Datum:** 29. März 2026  
**Autor:** Andreas (CEO) + Claude (Strategische Planung)  
**Status:** Finaler Entwurf — Bereit zur Umsetzung  

---

## Executive Summary

Nach dem Release einer App verschiebt sich der Fokus von Build → Store zu:  
**Operate → Observe → Decide → Improve → Release → Repeat**

Der Live Operations Layer ist eine neue System-Ebene über der bestehenden DAI-Core Factory. Die Factory bleibt das Build-System. Der neue Layer wird das Betriebs- und Entscheidungs-System. Zusammen machen sie DAI-Core zu einem vollständig autonomen System, das Apps nicht nur produziert, sondern betreibt, verbessert und monetarisiert — ohne menschlichen Eingriff.

**Kern-Architektur:**
- 10 neue Agents im `live_operations` Department
- 1 neuer Agent in der Marketing-Abteilung (`campaign_optimizer`)
- App Registry als zentrale Datenbank (SQLite)
- Firebase Analytics + Remote Config als Data Layer in allen Production Lines
- Store APIs (App Store Connect, Google Play Console) als externe Datenquellen
- 6-Stunden Decision Cycle mit 15–30 Min Anomaly Detection Interrupt
- 3-stufiges Eskalationssystem (Dashboard → Dashboard prominent → Telegram via HQ Assistant)
- Nahtlose Integration mit bestehender Factory Pipeline

---

## Inhaltsverzeichnis

1. Systemarchitektur — Gesamtübersicht
2. App Health Score System
3. App-Kategorie-Profile
4. Analytics Layer
5. Data Layer — Firebase Integration
6. Decision Engine
7. Anomaly Detector
8. Execution Layer — Factory-Rückführung
9. App Registry
10. A/B Testing System
11. Marketing-Integration
12. Eskalations- und Benachrichtigungssystem
13. Agent-Struktur — Live Operations Department
14. Dashboard-Integration — CEO Cockpit
15. Umsetzungsphasen
16. Abhängigkeiten und Voraussetzungen
17. Offene Punkte und Zukunftsthemen

---

## 1. Systemarchitektur — Gesamtübersicht

### Der geschlossene Loop

```
User Behavior
  → Monitoring (metrics_collector)
    → Analyse (analytics_agent + app_health_scorer)
      → Entscheidung (decision_engine)
        → Aktion (update_planner → Factory Pipeline)
          → Release (release_manager → Store Deployment)
            → neue Daten → Monitoring
```

### Systemgrenzen

- **Factory (besteht):** Build-System — Chapters 1–6, Production Lines, QA, Store Pipeline
- **Live Operations (neu):** Betriebs-System — Monitoring, Analyse, Entscheidung, Execution-Trigger
- **Schnittstelle:** Briefing Documents — Live Operations erzeugt sie, Factory führt sie aus
- **Keine neue Build-Pipeline nötig** — Updates laufen durch bestehenden Orchestrator, Assembly, QA

### Datenfluss

```
[Store APIs] ──────────┐
                       ├──→ [metrics_collector] ──→ [analytics_agent] ──→ [app_health_scorer]
[Firebase Analytics] ──┘                                                         │
                                                                                  ▼
[App Registry] ◄────── [release_manager] ◄── [Factory Pipeline] ◄── [update_planner] ◄── [decision_engine]
                                                                                              │
                                                                              [anomaly_detector] (Interrupt)
```

---

## 2. App Health Score System

### Konzept

Jede App die DAI-Core betreibt bekommt eine einzige Zahl zwischen 0 und 100 — den Health Score. Dieser Score ist der zentrale Indikator für den Zustand einer App und das erste was im CEO Cockpit sichtbar ist.

### 5 Scoring-Kategorien

| Kategorie | Beschreibung | Metriken |
|-----------|-------------|----------|
| **Stability** | Technische Stabilität | Crash Rate, ANR Rate (Android), Error Logs |
| **User Satisfaction** | Nutzerzufriedenheit | Store Rating (Durchschnitt + Trend), Support-Ticket-Volumen, Review-Sentiment |
| **Engagement** | Aktive Nutzung | DAU/MAU Ratio, Session Length, Retention (Day 1, Day 7, Day 30) |
| **Revenue** | Monetarisierung | ARPU, Conversion Rate (Free → Paid), Revenue Trend |
| **Growth** | Wachstum | Neue Installs, organisches Wachstum, Store Ranking |

### Standard-Gewichtung

| Kategorie | Gewicht |
|-----------|---------|
| Stability | 25% |
| User Satisfaction | 25% |
| Engagement | 20% |
| Revenue | 20% |
| Growth | 10% |

**Hinweis:** Die Gewichtung wird durch App-Kategorie-Profile überschrieben (siehe Kapitel 3).

### Berechnung

Jede Kategorie wird intern auf 0–100 normalisiert. Der Gesamt-Score ist die gewichtete Summe aller Kategorien.

### Health Score Zonen

| Zone | Score | Bedeutung | System-Reaktion |
|------|-------|-----------|-----------------|
| **Grün** | 80–100 | Alles läuft | System beobachtet, keine Aktion |
| **Gelb** | 50–79 | Aufmerksamkeit nötig | Analytics-Analyse wird getriggert, Decision Engine prüft |
| **Rot** | 0–49 | Kritisch | Decision Engine wird sofort aktiv, Eskalation möglich |

---

## 3. App-Kategorie-Profile

### Konzept

Nicht jede App ist gleich. Eine Game-App lebt von Engagement, eine Utility-App von Stability. Die Gewichtung des Health Scores wird automatisch angepasst basierend auf dem App-Kategorie-Profil.

Das Profil wird automatisch zugewiesen basierend auf dem Briefing Document der App — App-Kategorie, Monetarisierungsmodell, Zielgruppe. Kein manueller Eingriff nötig.

### 5 Profile

#### Gaming
| Kategorie | Gewicht | Primäre Metriken |
|-----------|---------|------------------|
| Engagement | **35%** | Session Length, Daily Returns, In-Game Progression |
| Revenue | 25% | In-App Purchases, Ad Revenue, ARPU |
| Stability | 20% | Crash Rate, Frame Drops, Load Times |
| User Satisfaction | 15% | Store Rating, Review Sentiment |
| Growth | 5% | Neue Installs, Viral Coefficient |

#### Education
| Kategorie | Gewicht | Primäre Metriken |
|-----------|---------|------------------|
| User Satisfaction | **30%** | Store Rating, Completion Feedback, Support Volume |
| Engagement | 25% | Completion Rate, Wiederkehr, Lernfortschritt |
| Stability | 20% | Crash Rate, Content Loading |
| Growth | 15% | Neue Installs, Institutionelle Adoption |
| Revenue | 10% | Subscription Retention, Conversion |

#### Utility
| Kategorie | Gewicht | Primäre Metriken |
|-----------|---------|------------------|
| Stability | **35%** | Crash Rate, Response Time, Error Rate |
| User Satisfaction | 25% | Store Rating, Support Tickets |
| Revenue | 20% | Subscription/Premium Conversion |
| Engagement | 10% | Task Completion Rate (nicht Session Length) |
| Growth | 10% | Neue Installs, Referrals |

#### Content / Media
| Kategorie | Gewicht | Primäre Metriken |
|-----------|---------|------------------|
| Engagement | **30%** | Session Length, Content Consumption, Return Rate |
| Growth | 25% | Neue Installs, Social Shares, Viral Coefficient |
| Revenue | 20% | Ad Revenue, Subscription, ARPU |
| User Satisfaction | 15% | Store Rating, Content Quality Feedback |
| Stability | 10% | Streaming Performance, Load Times |

#### Subscription / SaaS
| Kategorie | Gewicht | Primäre Metriken |
|-----------|---------|------------------|
| Revenue | **30%** | MRR, Churn Rate, LTV, Conversion Rate |
| User Satisfaction | 25% | NPS, Support Tickets, Review Sentiment |
| Engagement | 20% | Feature Adoption, DAU/MAU, Workflow Completion |
| Stability | 15% | Uptime, API Response Time, Error Rate |
| Growth | 10% | Trial Starts, Organic Acquisition |

---

## 4. Analytics Layer

### Konzept

Rohdaten werden zu Insights verarbeitet. Der Analytics Layer sieht nicht auf Einzelwerte sondern auf Bewegungen, Muster und Zusammenhänge.

### 4 Kernfunktionen

#### 4.1 Trend Detection

- Arbeitet mit gleitenden Durchschnitten und Trendlinien, nicht Snapshots
- Unterscheidet zwischen saisonalen Effekten (Wochenende, Feiertage) und echten Problemen
- Erkennt: steigende Crash Rate über 3+ Tage, sinkende Retention über 2+ Wochen, Revenue-Trends
- Output: Trend-Richtung (steigend/fallend/stabil), Trend-Stärke, Konfidenz

#### 4.2 Funnel Analysis

- Misst jeden Schritt: Install → Onboarding → First Action → Wiederkehr → Conversion
- Identifiziert den schwächsten Punkt im Funnel (höchster Drop-off)
- Output: Drop-off-Raten pro Schritt, schwächster Punkt, Vergleich mit vorherigen Versionen

#### 4.3 Cohort Analysis

- Gruppiert Nutzer nach Akquisitionszeitpunkt (Woche/Monat)
- Vergleicht Kohorten um Auswirkungen von Updates zu messen
- Beantwortet: "Hat das Update in Version 2.1 die Retention verbessert oder verschlechtert?"
- Output: Kohorten-Vergleichsmatrix, Update-Impact-Score

#### 4.4 Feature Usage Tracking

- Misst welche Features aktiv genutzt werden (Adoption Rate)
- Erkennt ungenutzte Features (Kandidaten für Entfernung oder Verbesserung)
- Erkennt unerwartet populäre Features (Signal für Ausbau)
- Output: Feature-Adoption-Matrix, Empfehlungen

---

## 5. Data Layer — Firebase Integration

### Architektur

Zwei Datenquellen fließen zusammen:

#### Extern: Store APIs
- **App Store Connect** (iOS): Downloads, Revenue, Ratings, Reviews, Crash Reports, Basis-Retention
- **Google Play Console** (Android): Gleiche Metriken, plus ANR Daten, Pre-Launch Reports

#### Intern: Firebase (in jeder App)
- **Firebase Analytics:** Sessions, Feature Usage, Custom Events, Funnels, Kohorten
- **Firebase Remote Config:** Feature Flags, A/B Test Konfiguration
- **Firebase Crashlytics:** Detaillierte Crash Reports mit Stack Traces

### Plattformunterstützung

Firebase läuft auf allen 4 DAI-Core Production Lines:
- iOS (Swift) ✓
- Android (Kotlin) ✓
- Web (JavaScript) ✓
- Unity (C#) ✓

### Factory-Änderung erforderlich

**Jede Production Line bekommt zwei neue Pflichtmodule:**

1. **Analytics Module:** Firebase Analytics SDK Integration, Standard-Events (Session Start, Feature Used, Funnel Step, Conversion), Custom Event API für app-spezifische Events
2. **Feature Flag Module:** Firebase Remote Config Integration, Feature Toggle System, A/B Test Group Assignment

Diese Module werden als fester Bestandteil jeder Assembly eingebaut — wie Assets und Sound bereits heute.

### Datenfluss

```
[App auf Nutzer-Gerät]
  → Firebase Analytics (Events, Sessions, Crashes)
  → Firebase Remote Config (Feature Flags lesen)

[Store]
  → App Store Connect API (Revenue, Ratings, Downloads)
  → Google Play Console API (Revenue, Ratings, Downloads)

[metrics_collector Agent]
  → Holt Daten aus allen Quellen
  → Normalisiert in einheitliches Format
  → Speichert in App Registry
  → Übergibt an analytics_agent
```

---

## 6. Decision Engine

### Konzept

Die Decision Engine ist das Herzstück des Live Operations Layers. Sie beantwortet zwei Fragen: "Was tun wir jetzt?" und "Was tun wir NICHT?"

### 3 Kernprinzipien

#### Prinzip 1: Gewichtetes Scoring statt einfacher Thresholds

Jeder potenzielle Trigger bekommt einen **Severity Score** (0–100) basierend auf drei Dimensionen:

| Dimension | Beschreibung | Beispiel |
|-----------|-------------|---------|
| **Abweichung** | Wie stark weicht der Wert vom Zielwert ab? | Crash Rate 5% vs Ziel 1% = hoch |
| **Impact** | Wie viele Nutzer sind betroffen? | 50 DAU vs 50.000 DAU = unterschiedlich |
| **Velocity** | Wie schnell verschlechtert sich der Trend? | Langsam über Wochen vs Spike in Stunden |

#### Prinzip 2: Action Queue mit Priorisierung

- Decision Engine füllt eine priorisierte Queue (höchster Severity Score oben)
- Sequentielle Abarbeitung — kein paralleles Multi-Update
- Vor jedem nächsten Punkt: Prüfung ob sich die Situation bereits geändert hat

#### Prinzip 3: Cooling Period

Nach jeder ausgeführten Aktion geht die Decision Engine für diese App in Beobachtungsmodus:

| Aktionstyp | Cooling Period |
|-----------|---------------|
| Hotfix | 48 Stunden |
| Patch | 1 Woche |
| Feature Update | 2 Wochen |
| Strategic Pivot | CEO-definiert |

### 4 Entscheidungstypen

#### Hotfix
- **Trigger:** Severity Score > 85, Stability-Kategorie Rot, Crash Rate steigt schnell
- **Reaktion:** Sofort, minimaler Scope, Express-Pipeline
- **Cooling:** 48 Stunden

#### Patch
- **Trigger:** Mehrere Issues mit Severity Scores 40–70, kein einzelnes kritisch
- **Reaktion:** Gesammelt innerhalb einer Woche, gebündelt deployen
- **Cooling:** 1 Woche

#### Feature Update
- **Trigger:** Analytics zeigt Verbesserungspotenziale, Funnel-Drop-offs, Feature Requests
- **Reaktion:** Geplant, vollständiges Briefing Document, volle Factory Pipeline
- **Cooling:** 2 Wochen

#### Strategic Pivot
- **Trigger:** Health Score seit längerem unter 50 trotz Patches/Updates
- **Reaktion:** CEO-Eskalation — Report + Handlungsvorschlag ins Dashboard, Telegram-Notification
- **CEO entscheidet:** Repositionierung, neues Monetarisierungsmodell, oder App einstellen
- **Cooling:** CEO-definiert

### Zyklus

- **Normaler Zyklus:** Alle 6 Stunden
- **Ablauf pro Zyklus:**
  1. metrics_collector holt frische Daten
  2. analytics_agent verarbeitet zu Insights
  3. app_health_scorer berechnet neuen Score
  4. decision_engine vergleicht mit Zielwerten und vorherigem Score
  5. Falls Action nötig: Eintrag in Action Queue mit Severity Score
  6. Höchster Eintrag wird als Briefing Document an Factory übergeben

---

## 7. Anomaly Detector

### Konzept

Der einzige Agent der außerhalb des 6-Stunden-Zyklus agiert. Läuft alle 15–30 Minuten. Erkennt nur dramatische Abweichungen — keine Trendanalyse, keine Kohortenberechnung.

### Trigger-Kriterien

| Anomalie | Beschreibung |
|----------|-------------|
| Crash Rate Explosion | Crash Rate verdoppelt sich innerhalb einer Stunde |
| Revenue Ausfall | Revenue fällt auf Null oder nahe Null |
| Health Score Absturz | Score fällt um > 20 Punkte in einem Zyklus |
| Server/API Ausfall | App-Endpoints nicht erreichbar |
| Post-Update Regression | Neue Version zeigt sofort schlechtere Metriken als Vorgänger |

### Eskalationswege

#### Automatischer Rollback
- **Wann:** Problem klar identifizierbar UND letzte stabile Version bekannt
- **Beispiel:** Crash in Modul das im letzten Update geändert wurde → Rollback auf vorherige Version
- **Ablauf:** Anomaly Detector → App Registry (letzte stabile Version) → Store Deployment → Cooling Period
- **Dokumentation:** Vollständig im Dashboard protokolliert (Stufe 2 — Warnung)

#### CEO-Eskalation
- **Wann:** Problem unklar oder zu komplex für automatischen Fix
- **Ablauf:** Emergency Report → Dashboard (prominent) → HQ Assistant sendet Telegram-Nachricht
- **CEO-Aktion:** Report lesen, entscheiden, System führt aus

### Rollback-Fähigkeit

Die App Registry speichert nicht nur die aktuelle Version sondern auch die **letzte stabile Version** (letzter Release mit Health Score > 80 nach Cooling Period). Ein Rollback ist ein erneuter Upload dieser Version über die bestehende Store Pipeline.

---

## 8. Execution Layer — Factory-Rückführung

### Konzept

Der Execution Layer ist die Brücke zwischen Decision Engine und bestehender Factory. Er erzeugt keine neuen Build-Pipelines — er nutzt die bestehenden.

### Ablauf

```
Decision Engine: "Patch nötig für App X"
  → update_planner holt App-Daten aus Registry
    → update_planner erstellt Briefing Document
      → Briefing geht an Factory Orchestrator
        → Factory baut Update (bestehende Pipeline)
          → QA prüft
            → release_manager deployt
              → App Registry wird aktualisiert
                → Cooling Period startet
                  → Monitoring-Zyklus beginnt
```

### Briefing Document Format (Live Operations Update)

Das Briefing Document für ein Live Operations Update unterscheidet sich vom normalen Factory-Briefing in einem kritischen Punkt: **Es startet nicht bei Null.**

Pflichtfelder:

```
update_type: hotfix | patch | feature_update
app_id: [aus App Registry]
current_version: [aus App Registry]
repository_path: [aus App Registry]
app_profile: gaming | education | utility | content | subscription

problem_description: [Was ist das Problem, mit Daten belegt]
desired_outcome: [Was soll nach dem Update anders sein]
affected_modules: [Welche Code-Module betroffen sind]
scope_constraints: [Was NICHT geändert werden darf]

triggered_by: decision_engine | anomaly_detector
severity_score: [0-100]
data_evidence: [Metriken die das Problem belegen]
```

### Wichtig

Der Factory Orchestrator sieht kein "Live Operations Update" — er sieht ein Briefing Document wie jedes andere. Die Intelligenz liegt im update_planner der das richtige Format erzeugt, nicht in der Factory.

---

## 9. App Registry

### Konzept

Zentrale Datenbank für alle Apps die DAI-Core jemals released hat. Gedächtnis des Live Operations Layers.

### Technologie

**SQLite** — leichtgewichtig, kein Server nötig, läuft lokal.

### Migration von bestehender JSON

Die Assembly-Phase bereitet bereits eine `factory/store_pipeline/app_registry.json` vor mit Basis-Feldern (App Name, Package/Bundle ID, Store IDs, Version, Timestamp, Store-Status). Beim ersten Start des Live Operations Layers wird diese JSON importiert und um die Live Operations Felder erweitert.

### Datenmodell

#### Core-Felder (aus Assembly-JSON)
| Feld | Typ | Beschreibung |
|------|-----|-------------|
| app_id | STRING (PK) | Eindeutige App-ID |
| app_name | STRING | App-Name |
| bundle_id | STRING | iOS Bundle ID |
| package_name | STRING | Android Package Name |
| apple_app_id | STRING | Apple App Store ID |
| google_package | STRING | Google Play Package Name |
| current_version | STRING | Aktuell live Version |
| last_upload_timestamp | DATETIME | Letzter Upload |
| store_status | STRING | submitted / live / suspended |

#### Live Operations Felder (neu)
| Feld | Typ | Beschreibung |
|------|-----|-------------|
| app_profile | STRING | gaming / education / utility / content / subscription |
| health_score | FLOAT | Aktueller Health Score (0–100) |
| health_zone | STRING | green / yellow / red |
| last_stable_version | STRING | Letzte Version mit Health Score > 80 nach Cooling |
| cooling_until | DATETIME | Cooling Period Ende (NULL wenn nicht aktiv) |
| cooling_type | STRING | hotfix / patch / feature_update / NULL |
| monetization_model | STRING | ads / subscription / iap / freemium / paid |
| firebase_project_id | STRING | Firebase Projekt-ID für API-Zugriff |
| total_releases | INT | Gesamtanzahl Releases |
| first_release_date | DATETIME | Datum des ersten Release |

#### Verknüpfte Tabellen

**release_history**
| Feld | Typ | Beschreibung |
|------|-----|-------------|
| release_id | STRING (PK) | Eindeutige Release-ID |
| app_id | STRING (FK) | Referenz auf App |
| version | STRING | Versionsnummer |
| release_date | DATETIME | Release-Datum |
| update_type | STRING | initial / hotfix / patch / feature_update |
| triggered_by | STRING | manual / decision_engine / anomaly_detector |
| changes_summary | TEXT | Was wurde geändert |
| health_score_before | FLOAT | Health Score vor Release |
| health_score_after | FLOAT | Health Score nach Cooling Period |

**action_queue**
| Feld | Typ | Beschreibung |
|------|-----|-------------|
| action_id | STRING (PK) | Eindeutige Action-ID |
| app_id | STRING (FK) | Referenz auf App |
| action_type | STRING | hotfix / patch / feature_update / strategic_pivot |
| severity_score | FLOAT | Priorität (0–100) |
| status | STRING | pending / in_progress / completed / cancelled |
| created_at | DATETIME | Wann erstellt |
| started_at | DATETIME | Wann gestartet |
| completed_at | DATETIME | Wann abgeschlossen |
| briefing_document | TEXT | Generiertes Briefing (JSON) |

**health_score_history**
| Feld | Typ | Beschreibung |
|------|-----|-------------|
| record_id | STRING (PK) | Eindeutige Record-ID |
| app_id | STRING (FK) | Referenz auf App |
| timestamp | DATETIME | Zeitpunkt der Messung |
| overall_score | FLOAT | Gesamt Health Score |
| stability_score | FLOAT | Stability Einzelscore |
| satisfaction_score | FLOAT | User Satisfaction Einzelscore |
| engagement_score | FLOAT | Engagement Einzelscore |
| revenue_score | FLOAT | Revenue Einzelscore |
| growth_score | FLOAT | Growth Einzelscore |

---

## 10. A/B Testing System

### Konzept

Jedes Feature Update wird automatisch als A/B Test ausgerollt. Das System lernt ob Änderungen tatsächlich verbessern — statt blind zu deployen.

### Technologie

**Firebase Remote Config** — Feature Flags und A/B Test Gruppen werden remote gesteuert ohne App-Update.

### Ablauf

1. Feature Update wird gebaut
2. `ab_test_manager` erstellt Test-Plan: Variante A (aktuell) vs Variante B (neu)
3. Firebase Remote Config weist X% der Nutzer Variante B zu
4. Testperiode läuft (Dauer abhängig von Traffic / statistischer Signifikanz)
5. `ab_test_manager` wertet aus: Vergleich der Zielmetriken zwischen A und B
6. **Variante B besser:** Rollout auf 100%
7. **Variante B schlechter:** Rollback, alle bleiben bei A

### Mindest-Nutzerbasis

A/B Testing wird nur aktiviert wenn die App eine Mindest-Nutzerbasis hat (konfigurierbar, Vorschlag: > 500 DAU). Unter diesem Schwellenwert sind die Daten statistisch nicht aussagekräftig — Updates werden direkt ausgerollt.

### Wissensbasis

Der `ab_test_manager` baut über Zeit eine interne Wissensbasis auf:

- Welche Art von Änderungen wirken bei welchem App-Profil
- Durchschnittliche Impact-Werte (z.B. "Onboarding-Vereinfachung verbessert Day-1 Retention bei Gaming-Apps um ~12%")
- Diese Insights fließen zurück in die Decision Engine und verbessern zukünftige Vorschläge

---

## 11. Marketing-Integration

### Konzept

Die bestehende Marketing-Abteilung (11 Agents) wird nicht umgebaut sondern um einen **Live-Modus** erweitert. Zusätzlich kommt ein neuer Agent hinzu.

### Dual-Mode Architektur

#### Launch Mode (besteht)
- Trigger: Factory Orchestrator — "App ist fertig, erstelle Store-Material"
- Output: Store Listings, Screenshots, ASO, Beschreibungen, Social Media Launch Posts

#### Live Mode (neu)
- Trigger: Decision Engine via `marketing_trigger_queue`
- Output: Update Notes, Re-Engagement Content, Feature Highlights, Damage Control

### marketing_trigger_queue

Neuer Input-Kanal für die Marketing-Abteilung. Die Decision Engine schreibt strukturierte Briefings:

```
trigger_type: re_engagement | update_announcement | rating_response | monetization_optimization
app_id: [App]
context: [Was ist passiert, mit Daten]
focus: [Worauf soll der Content fokussieren]
urgency: low | medium | high
channels: [store_listing | social_media | push_notification]
```

### Szenarien

| Trigger | Marketing-Reaktion |
|---------|-------------------|
| Retention sinkt | Re-Engagement Kampagne, Push Notification Texte, Feature-Highlight Posts |
| Gute Bewertungen | User Testimonials teilen, Momentum für organisches Wachstum nutzen |
| Neues Update released | Update Notes, Social Media Ankündigung, Feature-Highlight Content |
| Schlechte Bewertungen | Review-Antworten, Kommunikations-Anpassung, ggf. Damage Control |
| ARPU unter Ziel | Neue Store Screenshots, neue Beschreibungen, ASO-Optimierung |

### Neuer Agent: campaign_optimizer (#12 in Marketing)

- A/B Tests für Marketing-Material (Store Screenshots, Beschreibungen, Keywords)
- Arbeitet mit `ab_test_manager` aus Live Operations zusammen
- Misst welche Variante mehr Downloads/Conversion bringt
- Optimiert kontinuierlich die Store-Präsenz

### Keine Breaking Changes

Die bestehenden 11 Marketing-Agents brauchen keine Änderung an ihrer Kernlogik. Sie bekommen nur einen zweiten Input-Kanal. Ein Agent der ein Store Listing erstellen kann, kann auch ein Update Listing erstellen — das Briefing-Format entscheidet über den Output, nicht der Agent selbst.

---

## 12. Eskalations- und Benachrichtigungssystem

### 3 Stufen

#### Stufe 1 — Info
- **Wann:** Normaler Betrieb, autonome Entscheidungen, Patches, Updates
- **Wo:** Dashboard-Protokoll
- **Aktion nötig:** Nein — CEO kann lesen wenn gewünscht, aber kein aktiver Alert

#### Stufe 2 — Warnung
- **Wann:** Anomaly Detector schlägt an, automatischer Rollback wird durchgeführt
- **Wo:** Dashboard — prominente Anzeige mit allen Details
- **Inhalt:** Was ist passiert, was wurde automatisch getan, aktueller Status
- **Aktion nötig:** Nein, aber CEO sollte es wissen

#### Stufe 3 — CEO-Eskalation
- **Wann:** Strategic Pivot nötig, unklare Anomalie, Situation erfordert menschliches Urteil
- **Wo:** Dashboard + **Telegram-Nachricht via HQ Assistant**
- **Inhalt Telegram:** Kurz und knapp — "App X hat ein Problem das dein Eingreifen braucht. Details im Dashboard."
- **Inhalt Dashboard:** Vollständiger Report + Handlungsvorschlag
- **Aktion nötig:** Ja — CEO entscheidet GO, KILL, oder alternative Anweisung

### Dashboard-Dokumentation

**Alles wird protokolliert.** Jede autonome Entscheidung, jeder Rollback, jeder Hotfix, jeder Health Score Verlauf. Ein komplettes Logbuch pro App. Vollständige Transparenz — CEO kann jederzeit nachvollziehen was das System getan hat und warum.

### HQ Assistant Integration

Der bestehende HQ Assistant (25 Tools, ElevenLabs Voice, persistenter Memory) bekommt einen neuen Output-Kanal: Telegram. Er entscheidet nicht selbst wann er kontaktiert — die Decision Engine setzt den Eskalationslevel und der Assistant führt aus.

---

## 13. Agent-Struktur — Live Operations Department

### Department: `live_operations`

| # | Agent | Rolle | Zyklus | Input | Output |
|---|-------|-------|--------|-------|--------|
| 1 | **metrics_collector** | Rohdaten aus allen Quellen holen | Vor jedem 6h-Zyklus | Store APIs, Firebase | Normalisierte Metriken |
| 2 | **analytics_agent** | Rohdaten zu Insights verarbeiten | Im 6h-Zyklus | Normalisierte Metriken | Trends, Funnels, Kohorten, Feature Usage |
| 3 | **app_health_scorer** | Health Score berechnen | Im 6h-Zyklus | Analytics Insights + App-Profil | Health Score (0–100) pro App |
| 4 | **anomaly_detector** | Dramatische Abweichungen erkennen | Alle 15–30 Min | Rohdaten (Subset) | Alarm oder Stille |
| 5 | **decision_engine** | Entscheidungen treffen | Im 6h-Zyklus | Health Scores, Insights, Action Queue | Priorisierte Aktionen |
| 6 | **update_planner** | Briefing Documents erstellen | Bei Bedarf | Entscheidung + App Registry | Briefing Document → Factory |
| 7 | **review_manager** | Store-Bewertungen managen | Im 6h-Zyklus | Store APIs (Reviews) | Sentiment-Daten, Auto-Replies |
| 8 | **support_agent** | Support-Anfragen verarbeiten | Continuous | Support-Kanäle | Kategorisierte Issues, Eskalationen |
| 9 | **ab_test_manager** | A/B Tests planen und auswerten | Bei Feature Updates | Firebase Remote Config | Test-Ergebnisse, Rollout/Rollback |
| 10 | **release_manager** | Release-Prozess koordinieren | Bei Bedarf | QA-Ergebnis + App Registry | Store Upload, Registry Update, Cooling Start |

### In Marketing-Abteilung (erweitert)

| # | Agent | Rolle | Neu/Bestehend |
|---|-------|-------|---------------|
| 12 | **campaign_optimizer** | A/B Tests für Marketing-Material | **Neu** |
| 1–11 | Bestehende Agents | Erhalten Live-Mode via marketing_trigger_queue | **Erweitert** |

### Gesamt: 10 neue Agents + 1 neuer Marketing-Agent + 11 erweiterte Marketing-Agents

---

## 14. Dashboard-Integration — CEO Cockpit

### Neue Dashboard-Elemente

Das bestehende HQ Dashboard (React + Tailwind + Node.js/Express) wird um Live Operations Elemente erweitert:

#### App Fleet Overview
- Alle aktiven Apps auf einen Blick
- Health Score pro App (farbcodiert: grün/gelb/rot)
- Aktuelle Version, letztes Update, Cooling Status
- Sortierbar nach Health Score (schlechteste zuerst)

#### App Detail View (pro App)
- Health Score Verlauf (Chart über Zeit)
- Einzelscores aller 5 Kategorien
- Aktive Cooling Period mit Countdown
- Action Queue: Was steht an, was wurde kürzlich ausgeführt
- Release History: Alle Versionen, was sich geändert hat, Impact

#### Live Operations Log
- Chronologisches Logbuch aller autonomen Entscheidungen
- Filterbar nach App, Aktionstyp, Eskalationsstufe
- Jeder Eintrag: Was wurde entschieden, warum (mit Daten), was wurde getan, Ergebnis

#### Decision Engine Monitor
- Aktueller Zyklus-Status
- Nächster geplanter Zyklus
- Action Queue Übersicht
- Anomaly Detector Status (letzte Prüfung, Ergebnis)

#### Strategic Pivot Panel (nur bei Stufe 3)
- Prominente Anzeige wenn CEO-Eingriff nötig
- Vollständiger Report mit allen relevanten Daten
- Handlungsvorschlag der Decision Engine
- GO / KILL / Alternative Anweisung Buttons

---

## 15. Umsetzungsphasen

### Phase 1: Foundation (Geschätzt: 2–3 Wochen)

**Ziel:** Daten fließen, Health Score funktioniert.

| Task | Beschreibung | Abhängigkeit |
|------|-------------|-------------|
| 1.1 | App Registry aufsetzen (SQLite) | JSON aus Assembly muss existieren |
| 1.2 | Migration Script: JSON → SQLite | 1.1 |
| 1.3 | Firebase Analytics SDK in iOS Production Line | Keine |
| 1.4 | Firebase Analytics SDK in Android Production Line | Keine |
| 1.5 | Firebase Analytics SDK in Web Production Line | Keine |
| 1.6 | Firebase Analytics SDK in Unity Production Line | Keine |
| 1.7 | metrics_collector Agent bauen | 1.1 |
| 1.8 | app_health_scorer Agent bauen | 1.7 |
| 1.9 | App-Kategorie-Profile implementieren | 1.8 |
| 1.10 | Health Score im Dashboard anzeigen | 1.8 + Dashboard existiert |

**Ergebnis Phase 1:** Für jede App existiert ein Health Score der im Dashboard sichtbar ist. Daten fließen aus Store APIs und Firebase.

---

### Phase 2: Analytics (Geschätzt: 2–3 Wochen)

**Ziel:** System versteht was die Daten bedeuten.

| Task | Beschreibung | Abhängigkeit |
|------|-------------|-------------|
| 2.1 | analytics_agent bauen | Phase 1 abgeschlossen |
| 2.2 | Trend Detection implementieren | 2.1 |
| 2.3 | Funnel Analysis implementieren | 2.1 |
| 2.4 | Cohort Analysis implementieren | 2.1 |
| 2.5 | Feature Usage Tracking implementieren | 2.1 |
| 2.6 | Analytics Dashboard-Elemente | 2.2–2.5 |
| 2.7 | review_manager Agent bauen | Phase 1 |
| 2.8 | support_agent Agent bauen | Phase 1 |

**Ergebnis Phase 2:** System erkennt Trends, Probleme und Chancen. Review- und Support-Daten fließen ein.

---

### Phase 3: Decision Engine (Geschätzt: 3–4 Wochen)

**Ziel:** System trifft autonome Entscheidungen.

| Task | Beschreibung | Abhängigkeit |
|------|-------------|-------------|
| 3.1 | decision_engine Agent bauen | Phase 2 abgeschlossen |
| 3.2 | Severity Scoring implementieren | 3.1 |
| 3.3 | Action Queue implementieren | 3.1 |
| 3.4 | Cooling Period Logik | 3.1 |
| 3.5 | 6-Stunden Cron-Cycle einrichten | 3.1 |
| 3.6 | anomaly_detector Agent bauen | Phase 1 |
| 3.7 | 15–30 Min Interrupt-Cycle einrichten | 3.6 |
| 3.8 | Rollback-Mechanismus implementieren | 3.6 + App Registry |
| 3.9 | Eskalationslogik (3 Stufen) | 3.1 + 3.6 |
| 3.10 | Telegram-Integration für HQ Assistant | 3.9 |
| 3.11 | Decision Engine Dashboard-Elemente | 3.1–3.9 |

**Ergebnis Phase 3:** System trifft Entscheidungen, eskaliert bei Bedarf, CEO wird über Telegram benachrichtigt.

---

### Phase 4: Execution (Geschätzt: 2–3 Wochen)

**Ziel:** Entscheidungen fließen automatisch zurück in die Factory.

| Task | Beschreibung | Abhängigkeit |
|------|-------------|-------------|
| 4.1 | update_planner Agent bauen | Phase 3 |
| 4.2 | Briefing Document Generator (Live Ops Format) | 4.1 |
| 4.3 | Factory-Schnittstelle: Briefing → Orchestrator | 4.2 |
| 4.4 | release_manager Agent bauen | Phase 3 + Store Pipeline |
| 4.5 | App Registry Update nach Release | 4.4 |
| 4.6 | Cooling Period Aktivierung nach Release | 4.4 |
| 4.7 | Geschlossener Loop Test: Problem → Fix → Release → Monitoring | 4.1–4.6 |

**Ergebnis Phase 4:** Der vollständige Loop funktioniert. Problem erkannt → Fix gebaut → Released → Neue Daten fließen.

---

### Phase 5: Optimization (Geschätzt: 3–4 Wochen)

**Ziel:** System lernt und optimiert.

| Task | Beschreibung | Abhängigkeit |
|------|-------------|-------------|
| 5.1 | Firebase Remote Config in alle Production Lines | Phase 1 (Firebase SDK) |
| 5.2 | ab_test_manager Agent bauen | 5.1 |
| 5.3 | A/B Test Workflow implementieren | 5.2 |
| 5.4 | Mindest-Nutzerbasis-Check (> 500 DAU) | 5.2 |
| 5.5 | Wissensbasis-Aufbau starten | 5.3 |
| 5.6 | Marketing marketing_trigger_queue implementieren | Phase 4 |
| 5.7 | Marketing Live-Mode aktivieren | 5.6 |
| 5.8 | campaign_optimizer Agent bauen (Marketing #12) | 5.6 + 5.2 |

**Ergebnis Phase 5:** A/B Testing läuft, Marketing reagiert auf Live-Daten, System baut Wissensbasis auf.

---

### Phase 6: Full Autonomy (Geschätzt: 2–3 Wochen)

**Ziel:** System läuft vollständig autonom mit CEO-Reporting.

| Task | Beschreibung | Abhängigkeit |
|------|-------------|-------------|
| 6.1 | Vollautonomer Loop Stress-Test | Phase 4 + 5 |
| 6.2 | Strategic Pivot Panel im Dashboard | Phase 3 |
| 6.3 | App Fleet Overview im Dashboard | Phase 1–5 |
| 6.4 | Wöchentlicher CEO-Report (automatisch generiert) | Alle Phasen |
| 6.5 | Self-Healing Validierung: System erkennt und behebt eigene Fehler | Alle Phasen |
| 6.6 | Performance-Optimierung der Zyklen | Alle Phasen |
| 6.7 | Dokumentation und Onboarding-Protokoll für Live Ops Agents | Alle Phasen |

**Ergebnis Phase 6:** DAI-Core betreibt Apps vollständig autonom. CEO sieht alles, greift nur bei Strategic Pivot ein.

---

## 16. Abhängigkeiten und Voraussetzungen

### Harte Abhängigkeiten (müssen existieren bevor Live Ops starten kann)

| Voraussetzung | Status | Benötigt für |
|--------------|--------|-------------|
| Factory Production Lines funktionsfähig | ✓ Existiert | Phase 4 (Execution) |
| Store Pipeline funktionsfähig | In Arbeit | Phase 4 (Release) |
| App Registry JSON (Assembly-Phase) | Geplant | Phase 1 (Migration) |
| HQ Dashboard funktionsfähig | ✓ Existiert | Phase 1 (Anzeige) |
| HQ Assistant funktionsfähig | ✓ Existiert | Phase 3 (Telegram) |
| TheBrain Model Routing | ✓ Existiert | Alle Agents |
| Mindestens 1 App live im Store | Noch nicht | Phase 1 (Daten) |

### Weiche Abhängigkeiten (können parallel entwickelt werden)

| Voraussetzung | Beschreibung |
|--------------|-------------|
| Marketing-Abteilung live | Für Phase 5 Marketing-Integration, aber Live Ops funktioniert auch ohne |
| Firebase Account + Projekt | Setup nötig, kein Entwicklungsaufwand |
| Store API Credentials | App Store Connect + Google Play Console API Keys |
| Telegram Bot Token | Für HQ Assistant Telegram-Integration |

### Factory-Änderungen (einmalig, in Phase 1 + 5)

| Änderung | Phase | Betrifft |
|----------|-------|---------|
| Firebase Analytics SDK als Pflichtmodul | Phase 1 | Alle 4 Production Lines |
| Firebase Remote Config als Pflichtmodul | Phase 5 | Alle 4 Production Lines |

---

## 17. Offene Punkte und Zukunftsthemen

### Offene Entscheidungen

| Punkt | Beschreibung | Entscheidung nötig |
|-------|-------------|-------------------|
| Anomaly Detector Intervall | 15 oder 30 Minuten? | Kann mit 30 starten und bei Bedarf verkürzen |
| DAU Minimum für A/B Tests | 500 als Vorschlag — korrekt? | Kann konfigurierbar gemacht werden |
| App-Profil Zuweisung | Automatisch aus Briefing oder manuell bestätigt? | Empfehlung: automatisch mit CEO-Override |

### Zukunftsthemen (nicht Teil dieses Roadbooks)

| Thema | Beschreibung |
|-------|-------------|
| **Predictive Analytics** | ML-basierte Vorhersagen — "Diese App wird in 2 Wochen unter Health Score 50 fallen" |
| **Cross-App Learning** | Erkenntnisse aus App A auf App B anwenden |
| **TheBrain als eigener Kunde** | Wenn TheBrain live geht, überwacht Live Ops auch TheBrain selbst |
| **Multi-Store Expansion** | Amazon App Store, Huawei AppGallery, Samsung Galaxy Store |
| **Eigenes Analytics SDK (Direktive 001)** | Wenn Firebase-Kosten bei Scale relevant werden |
| **Automatische Preisoptimierung** | Dynamic Pricing basierend auf Marktdaten und Nutzerverhalten |
| **User Acquisition Automation** | Automatisierte Paid-Marketing Kampagnen basierend auf LTV-Daten |

---

## Schluss

Dieses Roadbook definiert den Weg von DAI-Core als reinem Build-System zu einem vollständig autonomen App-Betriebs-System. Der Live Operations Layer ist die logische Erweiterung der Factory-Philosophie: **Das System ist das Produkt, nicht die einzelnen Apps.**

Nach Umsetzung aller 6 Phasen verbessern sich Apps kontinuierlich selbst, Releases basieren auf Daten statt Bauchgefühl, Bugs werden automatisch erkannt und gefixt, Features entstehen aus realem Nutzerverhalten, und Marketing reagiert datengetrieben auf Live-Situationen.

Der CEO sieht alles, greift nur ein wenn es strategisch nötig ist.

**Die Factory baut. Live Operations betreibt. Zusammen sind sie DAI-Core.**
