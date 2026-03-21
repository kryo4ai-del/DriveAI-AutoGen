# Screen-Architektur: echomatch

## Screen-Uebersicht (22 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / Loading | Hauptscreen | App-Start, Asset-Preloading, Crash-Reporter-Init, Analytics-Init | F031, F025 | Normal, Slow-Connection, Offline-Error, Update-Required |
| S002 | DSGVO / ATT Consent Onboarding | Modal | Rechtlich verpflichtende Consent-Abfrage vor erstem Tracking-Event, ATT-Prompt iOS, COPPA-Alterscheck | F028, F042, F043 | Normal-iOS, Normal-Android, Minderjähriger-Blocked, ATT-Verweigert-Fallback |
| S003 | Onboarding Match / Spielstil-Tracking | Hauptscreen | Implizites 15-20s Spielstil-Tracking via erstem spielbaren Match-3-Tutorial, kein Fragebogen, direkter Einstieg in Core-Loop | F001, F002, F022, F037 | Normal, Erste-Züge-Hint-Aktiv, Tracking-Komplett, Langsame-Verbindung-Fallback |
| S004 | Narrative Hook Sequenz | Hauptscreen | 10-Sekunden Story-Teaser nach Onboarding als emotionaler Anker, erster Eindruck der narrativen Meta-Layer | F006, F005 | Normal, Skip-Aktiviert, Assets-Nicht-Geladen-Fallback |
| S005 | Home Hub | Hauptscreen | Zentraler Einstiegspunkt nach Onboarding, täglicher Re-Entry-Screen, Daily Quest Prompt, Battle-Pass Teaser, Social Nudge | F004, F005, F009, F012, F013, ... | Normal-Erster-Start, Normal-Returning-User, Daily-Quest-Abgeschlossen, Battle-Pass-Abgelaufen, Offline, Push-Notification-Deep-Link-Entry |
| S006 | Puzzle / Match-3 Spielfeld | Hauptscreen | Core-Loop Match-3-Gameplay, KI-generierte Level, Session-Design 5-10 Minuten, Haptic Feedback | F001, F003, F015, F022, F037 | Normal-Spielend, Level-Laden, KI-Level-Latenz-Warten, Zug-Aufgebraucht-Pause, Level-Gewonnen, Level-Verloren, Offline-Fallback-Cached-Level, Booster-Aktiv |
| S007 | Level-Ergebnis / Post-Session | Hauptscreen | Session-Abschluss-Screen nach gewonnenem oder verlorenem Level, Social-Nudge-Trigger, Rating-Prompt-Trigger, Sharing-CTA | F009, F010, F034, F025, F037 | Gewonnen-Normal, Gewonnen-Quest-Komplett, Verloren-Retry, Verloren-Rewarded-Ad-Angebot, Rating-Prompt-Aktiv, Offline |
| S008 | Level-Map / Progression | Hauptscreen | Visuelle Level-Übersicht, Fortschrittspfad, Narrative-Meta-Verbindung, tägliche KI-Quest-Markierung | F003, F004, F005, F037 | Normal, Neues-Level-Freigeschaltet-Animation, KI-Level-Geladen, KI-Level-Lädt, Offline-Cached |
| S009 | Story / Narrative Hub | Hauptscreen | Narrative Meta-Layer Hauptscreen, Story-Kapitel-Übersicht, Quest-Storyfortschritt, emotionaler Anker für D30-Retention | F005, F004, F006 | Normal, Neues-Kapitel-Freigeschaltet, Alle-Kapitel-Gelesen, Offline-Cached-Content |
| S010 | Social Hub | Hauptscreen | Social-Layer, Friend-Challenges, Team-Events, Social-Sharing-Einstiegspunkt, Leaderboard-Preview | F009, F010, F005 | Normal-Mit-Freunden, Normal-Keine-Freunde, Challenge-Ausstehend, Offline |
| S011 | Shop / Monetarisierungs-Hub | Hauptscreen | Zentraler IAP-Shop, Battle-Pass-Kauf, Convenience-IAPs, Foot-in-Door-Einstiegsangebot, Rewarded-Ad-Trigger | F011, F012, F015, F016, F038, ... | Normal, Foot-in-Door-Angebot-Aktiv, Battle-Pass-Bereits-Gekauft, IAP-Fehler, Laden, Offline-Gesperrt |
| S012 | Battle-Pass Screen | Subscreen | Dedizierter Battle-Pass-Fortschritts-Screen, Reward-Tier-Übersicht, Saison-Timer, Content-Visibility-Compliance | F012, F013, F039, F040 | Normal-Free, Normal-Premium, Saison-Läuft-Ab-Bald, Saison-Abgelaufen, Laden |
| S013 | Tägliche Quests Screen | Subscreen | Übersicht aller aktiven täglichen KI-Quests, Quest-Fortschritt, Reward-Preview, FOMO-Timer-konform | F004, F040, F041, F013 | Normal-Quests-Offen, Alle-Quests-Abgeschlossen, Quests-Laden, Offline-Cached, Quest-Reset-Countdown |
| S014 | Push Notification Opt-In | Modal | Permissionsanfrage für Push-Notifications, FOMO-Compliance-konform, Opt-Out erklärend | F020, F041 | Normal, System-Dialog-Folge-iOS, System-Dialog-Folge-Android, Bereits-Erlaubt, Permanent-Abgelehnt |
| S015 | Social Share Sheet | Overlay | Nativer Social-Sharing-Flow nach Session oder Level-Ergebnis, organischer UA-Kanal | F010 | Normal, Share-Erfolgreich, Share-Abgebrochen, Keine-Share-Apps-Installiert |
| S016 | Rewarded Ad Interstitial | Overlay | Rewarded-Ad-Angebot vor oder nach Level, Extra-Leben oder Booster als Reward, eCPM-Tracking | F011 | Angebot-Aktiv, Ad-Lädt, Ad-Läuft, Ad-Abgeschlossen-Reward, Ad-Fehler-Fallback, Ad-Übersprungen-Kein-Reward |
| S017 | Profil / Spieler-Account | Subscreen | Spielerprofil, Statistiken, Account-Verwaltung, Authentifizierung, Firebase Auth Status | F036, F025 | Normal-Anonym-Auth, Normal-Registriert, Sync-Fehler, Offline |
| S018 | Einstellungen | Subscreen | App-Einstellungen, Consent-Verwaltung, Notification-Einstellungen, Haptic-Toggle, Datenschutz | F022, F020, F041, F042 | Normal, Consent-Neu-Angefragt |
| S019 | Beta Feedback Screen | Subscreen | Strukturiertes Beta-Feedback für KI-Level-Bewertung, Go/No-Go-Kriterium ≥80% positive Bewertung | F032, F003 | Normal, Formular-Unvollständig, Gesendet-Danke, Senden-Fehler |
| S020 | Kaltstart Personalisierungs-Fallback | Overlay | Fallback-Personalisierungs-Auswahl für iOS-User ohne ATT-Consent, sichert KI-Personalisierung für bis zu 75% der Nutzer | F029, F028 | Normal-ATT-Verweigert, Auswahl-Getroffen, Nur-Android-Kein-ATT-Nötig |
| S021 | Offline Error Screen | Overlay | Globaler Offline-Zustand-Handler, Cached-Content-Hinweis, Reconnect-CTA | F019, F026 | Keine-Verbindung, Server-Down, Reconnect-Versucht, Cached-Mode-Aktiv |
| S022 | A/B Test Variant Loader | Overlay | Transparenter A/B-Test-Konfigurations-Loader beim App-Start, KI-generiert vs. Manuell kuratiert Test-Assignment | F024, F025 | Zuweisung-Lädt, Zuweisung-Komplett, Fallback-Control-Group |

## Screen-Hierarchie

### Tab-Bar Navigation
- **Home** (S005)
  - S013
  - S017
  - S018
- **Puzzle** (S008)
  - S006
  - S007
- **Story** (S009)
- **Social** (S010)
  - S015
- **Shop** (S011)
  - S012

### Modals: S002, S014, S019
### Overlays: S015, S016, S020, S021, S022

## User Flows (0 Flows)

## Edge Cases (0 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|

## Phase-B Screens (4 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S023 | Live-Ops Event Hub | Saisonale zeitlich limitierte Events, Kooperative Team-Events, Event-Leaderboards | Coming-Soon-Badge auf Social-Hub-Tab mit Teaser-Illustration |
| S024 | Gilden / Team-Management | Vollständiger kooperativer Social-Layer, Gilden-Erstellen, Beitreten, Guild-Events | Team-Event-Teaser-Card im Social-Hub mit Coming-Soon-Label |
| S025 | Adaptive Monetarisierungs-Offer Engine | KI-gesteuerte personalisierte IAP-Angebote basierend auf Ausgabeverhalten und Spielstil-Profil | Kein Platzhalter sichtbar, regulärer Shop aktiv |
| S026 | Vollständiger Leaderboard Screen | Globale und Freundes-Leaderboards, wöchentliche Ranglisten, saisonale Highscores | Freundes-Leaderboard-Preview mit Top-3 im Social-Hub, voller Screen Phase B |

## Zusammenfassung
- **Phase-A Screens:** 22
- **Phase-B Screens:** 4
- **User Flows:** 0
- **Edge Cases:** 0
- **Tap-Count:** Alle im Ziel ✅

# User Flows & Edge Cases — EchoMatch

---

## Flow 1: Onboarding (Erst-Start)

- **Pfad:** S001 → S002 → S020 (iOS ATT verweigert) → S003 → S004 → S005
- **Taps bis Core Loop:** 3 Taps (Consent bestätigen → Tutorial starten → Narrative Skip oder Watch)
- **Zeitbudget:** ~55–65 Sekunden
- **Detail:**
  - S001 lädt Assets, initialisiert Crash-Reporter + Analytics (automatisch, kein Tap)
  - S002 zeigt DSGVO-Consent + ATT-Prompt (iOS) — Pflicht-Tap: **Tap 1** (Zustimmen)
  - Bei ATT-Zustimmung → direkt S003
  - Bei ATT-Ablehnung → S020 (Kaltstart-Personalisierungs-Fallback, max. 1 Tap zur Auswahl) → S003
  - S003 startet implizites 15–20s Spielstil-Tracking-Tutorial (automatisch, kein Fragebogen) — Tap-Sequenz zählt als Gameplay, nicht als Navigation — **Tap 2** (erster Spielzug aktiviert Tutorial)
  - S004 zeigt 10s Narrative Hook — **Tap 3** (Skip oder Watch-through → automatisch weiter)
  - S005 (Home Hub, Erster-Start-State) wird geladen
- **Fallback bei Consent-Ablehnung:** S020 wird übersprungen → S003 läuft mit generischen Levels (Cache-Preset, kein personalisertes KI-Profil) → Tracking-Profil bleibt anonym-aggregiert
- **Fallback bei Minderjährigem (COPPA):** S002 erkennt Alterscheck-Fail → Hard-Block, App nicht nutzbar, kein Weiterleiten

---

## Flow 2: Core Loop (wiederkehrend)

- **Pfad:** S005 → S008 → S006 → S007 → S005 (oder S010 für Social Nudge)
- **Taps bis Match:** 2 Taps
- **Session-Ziel:** 6–10 Minuten
- **Detail:**
  - S005 (Returning-User-State) zeigt Daily Quest Prompt + Battle-Pass Teaser — **Tap 1** (Navigation zur Level-Map via Tab-Bar: Puzzle-Tab)
  - S008 zeigt Level-Map mit nächstem freigeschalteten Level + KI-Quest-Markierung — **Tap 2** (Level antippen → startet S006)
  - S006 lädt KI-generiertes Level (State: Level-Laden, max. 2s Ladezeit) → Gameplay startet automatisch
  - Spieler absolviert 1–3 Levels (5–10 Minuten Gesamt-Session)
  - S007 erscheint nach Level-Abschluss (Gewonnen oder Verloren)
  - Bei Gewonnen: Social-Nudge-Trigger sichtbar (CTA → S010 oder S015)
  - Bei Gewonnen + Quest abgeschlossen: State Gewonnen-Quest-Komplett mit erhöhtem Reward-Feedback
  - Rückkehr zu S005 über CTA-Button oder Tab-Bar (kein zusätzlicher Tap nötig wenn Auto-Return aktiv)
- **Gesamt-Taps für eine vollständige Loop-Runde:** 2 Taps bis Match, ~4–6 Taps für vollständige Session inkl. Post-Screen-Navigation

---

## Flow 3: Erster Kauf (Foot-in-Door IAP)

- **Pfad:** S005 → S011 → S011 (Foot-in-Door-Angebot-Aktiv-State) → Nativer Payment-Dialog (OS-Layer) → S011 (Bestätigung) → S005
- **Taps bis Kauf:** 3 Taps
- **Detail:**
  - S005 zeigt Battle-Pass Teaser oder Shop-Nudge nach erstem gewonnenen Level — **Tap 1** (Shop-Tab in Tab-Bar oder direkter CTA-Button)
  - S011 lädt im State Foot-in-Door-Angebot-Aktiv (zeitlich limitiertes Einstiegsangebot, Preis-Anker prominent) — **Tap 2** (Angebot antippen / Kaufen-Button)
  - Nativer OS-Payment-Dialog erscheint (Apple Pay / Google Pay / Store-Dialog) — **Tap 3** (Kauf bestätigen)
  - S011 wechselt zu Bestätigungs-State, Reward wird gutgeschrieben
  - Rückkehr zu S005 über Back-Navigation oder Tab-Bar
- **Trigger-Varianten:**
  - Alternativ-Einstieg über S007 (Level-Verloren → Rewarded-Ad-Angebot nicht gewünscht → Shop-CTA) → S011
  - Alternativ-Einstieg über S012 (Battle-Pass-Teaser auf Home Hub) → S012 → S011

---

## Flow 4: Social Challenge

- **Pfad:** S005 → S010 → S010 (Challenge-Ausstehend-State) → S006 → S007 → S015 → S010
- **Taps:** 3 Taps bis Challenge-Start
- **Detail:**
  - S005 zeigt Social-Nudge (z.B. „Freund hat dich herausgefordert") — **Tap 1** (Social-Tab in Tab-Bar)
  - S010 öffnet im State Challenge-Ausstehend mit prominenter Challenge-Card — **Tap 2** (Challenge annehmen)
  - S006 startet Challenge-Level (KI-generiert, auf Spielstil beider Spieler angepasst, asynchron)
  - S007 zeigt Ergebnis mit Challenge-Vergleich (eigener Score vs. Freund-Score)
  - Social-Share-CTA erscheint — **Tap 3** (Share antippen → S015 öffnet nativ)
  - S015 (Share Sheet) → Plattform-Auswahl → Share → Rückkehr zu S010
- **Kein-Freunde-State:** S010 zeigt Normal-Keine-Freunde-State → CTA „Freunde einladen" → S015 (Invite-Flow) statt Challenge-Flow

---

## Flow 5: Battle-Pass

- **Pfad:** S005 → S012 → S011 → Nativer Payment-Dialog → S012 (Premium-State)
- **Taps:** 3 Taps bis Kauf
- **Detail:**
  - S005 zeigt Battle-Pass-Teaser-Banner (Returning-User-State, Saison aktiv) — **Tap 1** (Battle-Pass-Banner antippen → S012)
  - S012 öffnet im State Normal-Free (Reward-Tier-Übersicht, gesperrte Premium-Tiers sichtbar als Content-Visibility-Compliance-konformer Anreiz, Saison-Timer läuft) — **Tap 2** (Premium kaufen-Button → leitet zu S011 weiter)
  - S011 bestätigt Battle-Pass-IAP im korrekten Pricing-State — **Tap 3** (Kauf bestätigen via OS-Dialog)
  - S012 wechselt zu Normal-Premium-State, alle Tiers freigeschaltet, bereits gesammelte Rewards sofort einlösbar
  - Saison-Ablauf-Handling: S012 im State Saison-Läuft-Ab-Bald zeigt FOMO-konformen Countdown (kein Dark Pattern: Ablaufdatum klar kommuniziert) → erhöhte Conversion-Wahrscheinlichkeit
- **Bereits-Gekauft-State:** S012 zeigt Normal-Premium direkt, kein Kauf-CTA, nur Fortschritts-Tracking

---

## Flow 6: Rewarded Ad

- **Pfad:** S006 (Züge-Aufgebraucht) → S016 (Angebot-Aktiv) → S016 (Ad-Läuft) → S016 (Ad-Abgeschlossen-Reward) → S006 (Booster-Aktiv)
- **Taps:** 2 Taps
- **Detail:**
  - S006 wechselt in State Zug-Aufgebraucht-Pause → automatisches Overlay-Trigger: S016 erscheint im State Angebot-Aktiv (Extra-Leben oder Booster als Reward kommuniziert) — **Tap 1** (Ad anschauen bestätigen)
  - S016 wechselt zu Ad-Lädt (max. 3s Ladeindikator) → Ad-Läuft (non-skippable 30s Rewarded Ad, eCPM-Tracking aktiv)
  - Nach Ad-Ende: S016 State Ad-Abgeschlossen-Reward — **Tap 2** (Reward einlösen / weiter)
  - S006 resumt im State Booster-Aktiv mit gutgeschriebenen Extra-Zügen oder Booster-Effekt
- **Alternativer Trigger:** S007 (Verloren-Rewarded-Ad-Angebot) → S016 → bei Reward → Level-Retry in S006
- **Ad-Fehler-Handling:** S016 State Ad-Fehler-Fallback → Fehlermeldung → Rückkehr zu S006 oder S007 ohne Reward, kein Hard-Lock

---

## Flow 7: Consent-Detail-Flow (vollständig)

- **Pfad:** S001 → S002 (Normal-iOS oder Normal-Android) → [Verzweigung] → S020 oder S003
- **Detail nach Entscheidungsbaum:**

  **Pfad A — Vollständige Zustimmung (iOS):**
  - S002 zeigt DSGVO-Text + Zustimmungs-Button + ATT-Erklärungstext
  - Tap: Zustimmen → iOS-System-ATT-Dialog erscheint (OS-Layer, außerhalb App-Control)
  - ATT erlaubt → S003 (volles KI-Tracking aktiv, personalisierte Level ab Session 1)

  **Pfad B — ATT verweigert (iOS):**
  - S002 → DSGVO zugestimmt → ATT-System-Dialog → ATT abgelehnt
  - S020 öffnet (Kaltstart-Personalisierungs-Fallback, State: Normal-ATT-Verweigert)
  - Nutzer trifft manuelle Stil-Auswahl (1 Tap) → sichert KI-Personalisierung für bis zu 75% der Nutzer ohne IDFA
  - → S003 (teil-personalisierte Level, regelbasiertes Fallback-Profil)

  **Pfad C — Android (kein ATT):**
  - S002 zeigt DSGVO-only-Flow (State: Normal-Android)
  - S020 nicht ausgelöst (State: Nur-Android-Kein-ATT-Nötig)
  - Zustimmung → S003 (volles Tracking über Android-Identifier aktiv)

  **Pfad D — Minderjähriger (COPPA):**
  - S002 führt Alterscheck durch → Unter-13-Erkennung
  - State: Minderjähriger-Blocked → Hard-Block, App nicht nutzbar
  - Kein Weiterleiten zu S003, kein Tracking, kein Gameplay

  **Consent-Verwaltung nachträglich:**
  - S005 → S017/S018 (Einstellungen, State: Consent-Neu-Angefragt) → S002 re-öffnet als Modal
  - Änderungen werden sofort auf Tracking + KI-Personalisierungsprofil angewendet

---

# Edge Cases

| Situation | Betroffene Screens | Verhalten |
|---|---|---|
| Consent vollständig abgelehnt (DSGVO Nein) | S002, S003, S006, S008 | Kein Tracking, keine KI-Personalisierung; S003 startet mit generischen Preset-Levels aus Cache; S006 liefert nur vorkuratierte statische Levels; S020 wird nicht ausgelöst; Battle-Pass und Shop bleiben nutzbar ohne personalisierte Empfehlungen |
| ATT verweigert (iOS only) | S002, S020, S003, S006 | S020 Kaltstart-Fallback öffnet direkt nach S002; Nutzer wählt Spielstil manuell (1 Tap); KI-Personalisierung läuft regelbasiert ohne IDFA; eCPM für Ads reduziert (non-personalized Ads Fallback in S016); Analytics laufen aggregiert weiter |
| Internetverlust während aktivem Match | S006, S021 | S006 wechselt zu State Offline-Fallback-Cached-Level; laufende Session wird lokal weitergeführt; Züge und Score werden lokal gecacht; nach Reconnect: automatischer Sync-Versuch; S021 erscheint als Overlay nur bei komplettem Verbindungsabbruch vor Level-Start, nicht mid-Game |
| KI-Level-Generierung schlägt fehl (Latenz > Timeout) | S006, S008 | S006 zeigt State KI-Level-Latenz-Warten mit Ladeindikator (max. 5s); nach Timeout: automatischer Fallback auf zuletzt gecachtes kuratiertes Level; S008 markiert KI-Quest-Level als State KI-Level-Lädt; Nutzer wird nicht geblockt; Fehler wird im Backend geloggt |
| Kauf fehlgeschlagen (IAP-Fehler) | S011, S012, S016 | S011 wechselt zu State IAP-Fehler; Fehlermeldung mit verständlichem Text (kein Tech-Jargon) + Retry-Button erscheint; kein Reward wird gutgeschrieben; Kauf-State wird nicht lokal als abgeschlossen markiert; bei erneutem Fehler: Support-Link sichtbar; S016 Ad-Fehler-Fallback läuft parallel wenn Ad-Reward betroffen |
| Server-Totalausfall | S001, S005, S006, S008, S021 | S001 erkennt Offline-State → State Offline-Error erscheint mit Retry-CTA; bei partiellem Ausfall: S022 fällt auf Fallback-Control-Group zurück (kein A/B-Test-Assignment); S005 lädt im Offline-State mit gecachtem Content; S006 nutzt Offline-Fallback-Cached-Level; S011 zeigt State Offline-Gesperrt (keine IAP-Transaktionen ohne Serverbestätigung möglich); S021 als globaler Handler aktiv |
| COPPA-Trigger (Nutzer unter 13 erkannt) | S002 | Hard-Block in S002, State Minderjähriger-Blocked; kein Weiterleiten in die App; kein Tracking, kein Analytics-