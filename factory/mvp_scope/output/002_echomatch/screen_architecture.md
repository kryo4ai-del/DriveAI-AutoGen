# Screen-Architektur: echomatch

## Screen-Uebersicht (23 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / Loading | Hauptscreen | App-Start, Asset-Loading, Crashlytics-Init, Analytics-Init | F020, F021, F051 | Normal, Slow-Connection, Offline-Error, Update-Required |
| S002 | Age-Gate / Altersverifikation | Modal | COPPA-konforme Altersabfrage vor erstem App-Start, Weiterleitung zu DSGVO-Consent | F043, F063, F044 | Normal, Minderjährig-Gesperrt, Fehler-Ungültiges-Datum |
| S003 | DSGVO / ATT Consent | Modal | DSGVO-Einwilligung, App Tracking Transparency iOS, Push-Notification-Opt-in | F042, F051, F015, F026, F041 | Normal, Teilweise-Abgelehnt, Alles-Abgelehnt |
| S004 | Onboarding – Kamera-Scan | Hauptscreen | Erster Kamera-Scan als kritischer First-Impression-Moment, implizites Spielstil-Tracking-Start | F017, F027, F016 | Normal, Scanning, Scan-Erfolg, Scan-Fehler, Kamera-Berechtigung-Verweigert, Slow-Connection |
| S005 | Onboarding – Tutorial Match-3 | Hauptscreen | Spieler lernt Match-3-Mechanik, implizites Spielstil-Tracking aktiv, kein Fragebogen | F001, F016, F021 | Normal, Hinweis-Aktiv, Level-Abgeschlossen, Abbruch-Bestätigung |
| S006 | Onboarding – Story Teaser | Hauptscreen | Narrative Hook in 10 Sekunden, emotionaler Einstieg in Story-Layer | F005, F006 | Normal, Animierend, Abgeschlossen |
| S007 | Home Dashboard | Hauptscreen | Zentrale Navigationshub, tägliche Quest-Übersicht, Pflanzenstatus, Wetterintegration | F004, F018, F019, F015, F034 | Normal, Neue-Quest-Verfügbar, Pflanze-Braucht-Pflege, Offline, Leer-Erststart |
| S008 | Match-3 Level-Auswahl | Hauptscreen | Levelübersicht, KI-generierte tägliche Levels, Quest-Level-Verknüpfung | F001, F002, F004 | Normal, KI-Level-Lädt, Kein-Internet-Fallback, Alle-Level-Abgeschlossen |
| S009 | Match-3 Gameplay | Hauptscreen | Core Match-3 Loop, KI-generiertes Level, Belohnungs-Trigger | F001, F002, F034, F011 | Normal, Level-Gewonnen, Level-Verloren, Kein-Zug-Möglich, Pause, Rewarded-Ad-Angebot, Quest-Ziel-Erreicht |
| S010 | Level-Ergebnis | Modal | Post-Level-Feedback, Belohnungen, Story-Progress, Quest-Fortschritt, Social-Nudge | F001, F034, F004, F005, F007, ... | Gewonnen-3-Sterne, Gewonnen-2-Sterne, Gewonnen-1-Stern, Verloren, Quest-Abgeschlossen |
| S011 | Story / Narrative Hub | Hauptscreen | Story-Fortschritt, KI-Quest-Narrativ, Kapitelübersicht | F005, F004, F006 | Normal, Neues-Kapitel-Freigeschaltet, Quest-Aktiv, Gesperrt-Wartet-auf-Level |
| S012 | Social Hub | Hauptscreen | Friend-Challenges, Community-Challenges, Leaderboard | F007, F008, F045 | Normal, Keine-Freunde, Challenge-Ausstehend, Neue-Herausforderung-Eingegangen, Offline |
| S013 | Challenge Detail | Subscreen | Details einer aktiven oder eingehenden Challenge, Annahme oder Ablehnung | F007, F008, F045 | Normal, Ausstehend, Aktiv-Laufend, Abgeschlossen-Gewonnen, Abgeschlossen-Verloren, Abgelaufen |
| S014 | Shop | Hauptscreen | Kosmetische IAPs, Battle-Pass, Rewarded Ads, Compliance-konforme Monetarisierung | F011, F012, F013, F034, F041, ... | Normal, Kauf-Lädt, Kauf-Erfolgreich, Kauf-Fehlgeschlagen, Kein-Internet, Angebot-Abgelaufen |
| S015 | Battle-Pass Detail | Subscreen | Battle-Pass Fortschritt, Belohnungs-Übersicht, transparente Inhaltsdarstellung | F012, F054, F034 | Normal-Kostenlos, Premium-Aktiv, Tier-Freigeschaltet-Animation, Abgelaufen |
| S016 | Pflanzenpflege Detail | Subscreen | Gescannte Pflanze, Pflegestatus, Wetter-basierte Empfehlungen | F017, F018, F019 | Normal, Pflege-Fällig, Gut-Versorgt, Kein-Wetter-Daten, Kein-Scan-Vorhanden |
| S017 | Einstellungen | Subscreen | Nutzereinstellungen, Datenschutz, Push-Notifications, Compliance | F015, F042, F043, F044, F048, ... | Normal, Gespeichert, Fehler-beim-Speichern |
| S018 | App Store Rating Prompt | Overlay | Nativer Rating-Prompt nach positivem Spielmoment, ASO-Optimierung | F030, F022 | Normal, Bereits-Bewertet, Abgelehnt |
| S019 | Push Notification Opt-in Prompt | Overlay | DSGVO-konformer Push-Opt-in nach positiver Spielerfahrung, Retention-Optimierung | F015, F026, F042 | Normal, Bereits-Akzeptiert, Abgelehnt |
| S020 | Rewarded Ad Overlay | Overlay | Opt-in Rewarded Ad Angebot nach Level-Niederlage oder vor Bonus, Compliance-konform | F011, F055, F041 | Normal, Ad-Lädt, Ad-Abgespielt, Ad-Fehler, Bereits-Genutzt-Heute |
| S021 | KI-Quest Detail | Modal | Tägliche KI-Quest-Details, Fortschritt, Belohnungs-Preview, deterministische Belohnung | F004, F053, F034, F049 | Normal, Aktiv, Abgeschlossen, Belohnung-Abholbar, Abgelaufen, KI-Lädt |
| S022 | Profil / Statistiken | Subscreen | Spielerprofil, Achievements, Streak, Stats für Social-Context | F034, F021, F028 | Eigenes-Profil, Fremdes-Profil, Leer-Erststart |
| S023 | Offline / No-Connection | Overlay | Offline-Feedback, Fallback auf cached Content, graceful Degradation | F001, F020 | Vollständig-Offline, Langsame-Verbindung, Wiederverbunden |

## Screen-Hierarchie

### Tab-Bar Navigation
- **Home** (S007)
  - S016
  - S021
- **Puzzle** (S008)
  - S009
  - S010
- **Story** (S011)
  - S021
- **Social** (S012)
  - S013
- **Shop** (S014)
  - S015

### Modals: S010, S021
### Overlays: S018, S019, S020, S023

## User Flows (0 Flows)

## Edge Cases (0 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|

## Phase-B Screens (7 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S024 | Team-Event Hub | Kooperative Team-Events, Gruppen-Challenges, Live-Ops | Coming Soon Badge auf Social-Tab mit Lock-Icon und Teaser-Text |
| S025 | Saison-Event Screen | Saisonale Battle-Pass-Rotation, Saison-Timer, exklusive Inhalte | Saison-1-Coming-Soon-Banner im Battle-Pass Detail |
| S026 | KI-Dialog / Story Chat | KI-generierte Dialoge mit Story-Charakteren, personalisierte Narrative | Statische Dialog-Karten im Story Hub ohne KI-Interaktion |
| S027 | Spielstil-Profil / Personalisierung | Explizite Spielstil-Tracking-Visualisierung, KI-Quest-Empfehlungen | Kein Profil-Screen, Tracking läuft implizit im Hintergrund |
| S028 | Social Sharing | Share-Karten für Ergebnisse, organisches Wachstum via TikTok und Instagram | Kein Share-Button sichtbar im Level-Ergebnis |
| S029 | Nutzerprofil-Erweiterungs-Screen | Vollständiges Nutzerprofil-Management, Cloud-Sync, Avatare | Minimales Profil in S022 ohne erweiterte Verwaltung |
| S030 | Challenge Matchmaking | Automatisches Matchmaking für Challenge-Partner | Nur manuelle Freundes-Challenges ohne Matchmaking |

## Zusammenfassung
- **Phase-A Screens:** 23
- **Phase-B Screens:** 7
- **User Flows:** 0
- **Edge Cases:** 0
- **Tap-Count:** Alle im Ziel ✅

# User Flows & Edge Cases – EchoMatch

---

## Flow 1: Onboarding (Erst-Start)

- **Pfad:** S001 → S002 → S003 → S004 → S005 → S006 → S007
- **Taps bis Core Loop:** 4 Taps (Weiter-CTA in S002, Consent-Bestätigung in S003, Scan-Start in S004, Tutorial-Abschluss in S005)
- **Zeitbudget:** ~55–65 Sekunden
- **Detail-Schritte:**
  - S001 – App lädt, Assets initialisieren, Crashlytics-Init (~2 Sek.)
  - S002 – Altersabfrage (Datum eingeben + Bestätigen) → **Tap 1**
  - S003 – DSGVO/ATT-Consent anzeigen, Nutzer bestätigt → **Tap 2**
  - S004 – Kamera-Scan-Onboarding startet automatisch, Scan-Button → **Tap 3**
  - S005 – Match-3-Tutorial (implizites Spielstil-Tracking aktiv, ~20 Sek.), Level-Abschluss → **Tap 4**
  - S006 – Story-Teaser (10 Sek., autoplay, kein Tap nötig) → endet automatisch
  - S007 – Home Dashboard, Core Loop erreicht
- **Fallback bei Consent-Ablehnung (S003 → Alles-Abgelehnt):** Spielstil-Tracking deaktiviert, KI-Quest-Personalisierung deaktiviert → generische Levels aus Cache, Flow setzt sich mit S004 fort
- **Fallback bei Kamera-Berechtigung verweigert (S004):** Skip-Option anzeigen, Pflanzenpflege-Feature gesperrt bis Berechtigung erteilt, Flow geht direkt zu S005
- **Fallback Slow-Connection (S001 → Slow-Connection):** Progressiver Ladescreen mit Timeout-Indicator, nach 10 Sek. Wechsel zu S001-Offline-Error-State mit Retry-CTA

---

## Flow 2: Core Loop (wiederkehrend)

- **Pfad:** S007 → S021 → S008 → S009 → S010 → S007
- **Taps bis Match-Start:** 3 Taps
- **Session-Ziel:** 6–10 Minuten
- **Detail-Schritte:**
  - S007 – Home Dashboard öffnet sich, tägliche Quest-Card sichtbar → **Tap 1** (Quest antippen → S021)
  - S021 – KI-Quest-Detail, Belohnungs-Preview, Quest akzeptieren → **Tap 2** (→ S008)
  - S008 – Level-Auswahl, empfohlenes KI-Level ist highlighted → **Tap 3** (Level starten → S009)
  - S009 – Match-3 Gameplay, Core Loop aktiv (~3–5 Minuten)
  - S009 → Level-Gewonnen-State → automatischer Übergang zu S010
  - S010 – Level-Ergebnis: Belohnungen animiert, Story-Progress, Quest-Fortschritt, Social-Nudge angezeigt → **Tap 4** (Weiter → S007)
  - S007 – Dashboard aktualisiert (Streak, Quest-Status, Pflanzenstatus)
- **Hinweis:** Flow ist als täglich wiederholbarer Loop konzipiert; ab zweitem Tag entfällt S021-Erstaufruf, direkter Einstieg via S007 → S008 möglich (Taps bis Match: 2)
- **Fallback KI-Level lädt nicht (S008 → KI-Level-Lädt-Timeout):** Fallback auf gecachtes Level der letzten Session, Hinweis-Toast „Heute ein klassisches Level – KI synchronisiert später"

---

## Flow 3: Erster Kauf (IAP / Kosmetik)

- **Pfad:** S010 → S014 → S015 → S014 (Kauf-Bestätigung) → S007
- **Taps bis Kauf:** 3 Taps
- **Detail-Schritte:**
  - S010 – Level-Ergebnis zeigt Shop-Nudge (z. B. „Neues Skin verfügbar") → **Tap 1** (Shop-CTA → S014)
  - S014 – Shop-Hauptscreen, kosmetisches Item oder Battle-Pass-Angebot sichtbar → **Tap 2** (Item antippen → S015 oder direkt Kauf-CTA → Tap 2)
  - S015 – Battle-Pass-Detail (optional, wenn Battle-Pass-Angebot), Inhalte transparent dargestellt → **Tap 3** (Kaufen-CTA)
  - S014 – Kauf-Lädt-State → Native Store-Payment-Sheet öffnet (iOS/Android, 0 zusätzliche App-Taps)
  - S014 – Kauf-Erfolgreich-State: Bestätigungs-Animation, Item freigeschaltet → **Tap 4** (Schließen → S007)
- **Compliance-Hinweis:** Keine Loot-Boxen, kein Pay-to-Win; alle IAPs sind kosmetisch oder Battle-Pass – entsprechend kein Zufallsmechanismus-Disclosure nötig
- **Fallback Kauf-Fehlgeschlagen (S014 → Kauf-Fehlgeschlagen):** Fehlermeldung mit Fehlercode, Retry-CTA und „Später kaufen"-Option; kein doppeltes Abbuchen durch idempotente Transaktions-ID
- **Fallback Kein-Internet (S014 → Kein-Internet):** Shop-Inhalte aus Cache darstellbar, Kauf-CTAs deaktiviert mit Tooltip „Verbindung nötig", S023-Overlay nicht triggern (zu disruptiv)

---

## Flow 4: Social Challenge (Freund herausfordern)

- **Pfad:** S007 → S012 → S013 → S009 → S010 → S012
- **Taps bis Challenge-Start:** 3 Taps
- **Detail-Schritte:**
  - S007 – Home Dashboard, Social-Tab-Badge zeigt ausstehende Challenge → **Tap 1** (Social-Tab → S012)
  - S012 – Social Hub, eingehende Challenge-Card sichtbar oder Freund aus Liste auswählen → **Tap 2** (Challenge-Card antippen → S013)
  - S013 – Challenge-Detail: Gegner-Stats, Level-Info, Belohnungs-Preview → **Tap 3** (Annehmen → S009)
  - S009 – Match-3 Gameplay mit Challenge-Kontext-Banner (Gegner-Score sichtbar, asynchron)
  - S009 → Level-Gewonnen oder Level-Verloren → automatisch S010
  - S010 – Ergebnis mit Challenge-Outcome (Gewonnen/Verloren-State), Social-Share-Option
  - S010 → Weiter → S012 (zurück zum Social Hub, aktualisierter Challenge-Status)
- **Fallback Keine-Freunde (S012 → Keine-Freunde-State):** Community-Challenge als Alternative prominent anzeigen, Einladungs-CTA für Freunde, keine Sackgasse
- **Fallback Challenge-Abgelaufen (S013 → Abgelaufen-State):** Klar kommunizieren mit Zeitstempel, CTA „Neue Challenge starten" statt Fehlermeldung
- **Fallback Offline (S012):** Gecachte Challenge-Daten anzeigen (read-only), Aktions-CTAs deaktiviert, S023-Offline-Indicator nicht vollflächig, sondern als Banner

---

## Flow 5: Battle-Pass (Fortschritt prüfen & Tier freischalten)

- **Pfad:** S007 → S014 → S015 → S009 → S010 → S015
- **Taps bis Battle-Pass-Screen:** 2 Taps
- **Detail-Schritte:**
  - S007 – Home Dashboard, Battle-Pass-Progress-Bar im Header oder als Quick-Access-Card → **Tap 1** (Shop-Tab oder Battle-Pass-Card → S014)
  - S014 – Shop-Hauptscreen, Battle-Pass-Banner prominent → **Tap 2** (Battle-Pass-CTA → S015)
  - S015 – Battle-Pass-Detail: aktueller Tier, nächste Belohnung, Fortschrittsbalken, Upgrade-CTA falls Free-Tier
  - Falls Premium bereits aktiv: Weiter-CTA → S008 (Level spielen um XP zu farmen) → **Tap 3**
  - S008 → S009 – Level spielen, Battle-Pass-XP wird akkumuliert
  - S009 → S010 – Level-Ergebnis zeigt Battle-Pass-XP-Gewinn explizit
  - S010 → CTA „Battle-Pass prüfen" → S015 – Tier-Freigeschaltet-Animation spielt ab
- **Fallback Battle-Pass abgelaufen (S015 → Abgelaufen-State):** Klarer Ablauf-Timestamp, Saison-1-Coming-Soon-Banner (Phase-B Teaser S025), kein Kauf mehr möglich, abgelaufene Rewards bleiben erhalten
- **Fallback Tier-Animation-Fehler:** Belohnung trotzdem gutschreiben (serverseitig), Animation-Fallback auf statische Bestätigungs-Card, kein Silent-Fail

---

## Flow 6: Rewarded Ad (nach Level-Niederlage)

- **Pfad:** S009 → S020 → S009 (Retry) → S010
- **Taps bis Ad-Start:** 2 Taps
- **Detail-Schritte:**
  - S009 – Level-Verloren-State: Rewarded-Ad-Angebot erscheint automatisch nach ~1,5 Sek. Delay (kein sofortiger Interrupt) → **Tap 1** (Ad ansehen → S020)
  - S020 – Rewarded Ad Overlay: Ad-Lädt-State mit Ladeindikator (~2 Sek.), dann Ad-Abgespielt
  - S020 – Ad vollständig abgespielt → Belohnung automatisch gutgeschrieben (Extra-Leben oder -Züge)
  - S020 → automatischer Rücksprung zu S009 (Level-Retry mit Bonus) → **kein weiterer Tap nötig**
  - S009 – Level erfolgreich oder erneut verloren → S010
  - Alternativpfad ohne Ad: S009 (Level-Verloren) → S020 abgelehnt → **Tap 2** (Nein-CTA) → S010 direkt
- **Compliance:** Vollständig Opt-in, kein Forced-Ad, kein Ad nach Ad (Cooldown), DSGVO-konform durch S003-Consent
- **Fallback Ad-Fehler (S020 → Ad-Fehler-State):** Fehlermeldung „Keine Werbung verfügbar", Belohnung NICHT gutschreiben, Retry-Option nach 30 Sek., alternativer CTA „Level trotzdem fortsetzen?" (ohne Belohnung)
- **Fallback Bereits-Genutzt-Heute (S020 → Bereits-Genutzt-Heute):** Daily-Cap-Hinweis mit Timer bis Reset, kein erneutes Anzeigen desselben Overlays in dieser Session

---

## Flow 7: Consent-Management (Detail-Flow)

- **Pfad Erst-Start:** S001 → S002 → S003 → S004
- **Pfad Einstellungs-Revisit:** S007 → S017 → S003 (Consent-Revisit) → S017
- **Pfad COPPA-Block:** S001 → S002 (Minderjährig-Gesperrt) → Hard-Stop
- **Detail-Schritte Erst-Start:**
  - S001 – App-Start, Consent-Status wird geprüft: kein gespeicherter Status → S002 triggern
  - S002 – Altersabfrage: Datum-Eingabe → **Tap 1** (Bestätigen)
    - Ergebnis ≥ 18 Jahre: → S003
    - Ergebnis 13–17 Jahre: → S002 Minderjährig-Gesperrt-State (eingeschränktes COPPA-Tracking-Regime, kein ATT)
    - Ergebnis < 13 Jahre: → Hard-Stop-Screen, kein App-Zugang, COPPA-compliant
  - S003 – DSGVO-Consent (drei granulare Optionen): Analytics, Personalisierung, Push-Notifications
    - Alle akzeptiert: Volles KI-Tracking, Push aktiv → S004
    - Teilweise abgelehnt (S003 → Teilweise-Abgelehnt): Nur akzeptierte Features aktiv, Rest deaktiviert → S004 mit reduziertem Feature-Set
    - Alles abgelehnt (S003 → Alles-Abgelehnt): Generische Levels, kein Tracking, kein Push → S004
  - S003 – iOS ATT-Prompt: wird nach DSGVO-Modal ausgelöst (native iOS-Dialog, nicht im App-Control)
- **Detail-Schritte Einstellungs-Revisit:**
  - S017 – Einstellungen → Datenschutz-Sektion → **Tap 1** (Einwilligungen verwalten → S003)
  - S003 – Consent-Revisit: aktueller Status vorausgefüllt, Änderungen möglich
  - Änderung gespeichert → **Tap 2** (Bestätigen) → zurück zu S017
  - App-Restart nicht erforderlich, Consent-Status wird live angewendet (Analytics-SDK deaktiviert ohne Restart)
- **Hinweis:** ATT-Prompt kann auf iOS nur einmal nativ angezeigt werden; bei Ablehnung Weiterleitung zu iOS-Einstellungen über Deep-Link in S017

---

# Edge Cases

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| **Consent vollständig abgelehnt** | S003, S004, S005, S007, S008, S021 | Spielstil-Tracking deaktiviert; KI-Quest-Personalisierung ausgeschaltet; generische Levels aus statischem Pool; kein Push-Opt-in-Prompt (S019 wird nicht getriggert); alle anderen Features vollständig nutzbar; Consent-Status persistent gespeichert |
| **Internetverlust während aktivem Match** | S009, S023 | Match läuft lokal weiter (clientseitiges State-Management); kein Spielabbruch; S023-Offline-Indicator als nicht-invasives Banner (nicht Fullscreen-Overlay); nach Reconnect: Score-Sync im Hintergrund, kein