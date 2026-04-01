# Screen-Architektur: growmeldai

## Screen-Uebersicht (22 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / Loading | Hauptscreen | App-Start, Asset-Loading, Firebase-Init, Crash-Reporter-Init | F032, F031, F034 | Normal, Slow-Connection, Offline-Fallback, Update-Required |
| S002 | Onboarding-Kamera-Splash | Hauptscreen | Frictionless Onboarding ohne Registrierungszwang, sofortige Kamera-CTA als erster Nutzermoment | F018, F039 | Normal, Kamera-Permission-Denied-Hint |
| S003 | Kamera-Permission-Modal | Modal | DSGVO-konforme Einwilligung zur Kamera-Nutzung vor erstem Scan | F046, F044 | Normal, Bereits-Erlaubt, Abgelehnt-Hinweis |
| S004 | Scanner-Screen | Hauptscreen | Kamera-Sucher für Pflanzenscan, KI-Identifikation in <3s, Core-Feature-Entry-Point | F001, F019, F029, F038, F043, ... | Normal, Scanning-Active, KI-Processing, KI-Ergebnis-Eingeblendet, Scan-Limit-Erreicht, Kamera-Permission-Fehler, Offline-Fallback-Local-Model, API-Fehler-Retry, Niedrige-Konfidenz-Warnung |
| S005 | Pflanzenprofil-Erstellungs-Flow | Subscreen | Schritt-für-Schritt-Erfassung von Standort, Topfgröße und Pflanzennamen nach erfolgreichem Scan | F002, F003, F037 | Schritt-1-Pflanzenname, Schritt-2-Standort, Schritt-3-Topfgröße, Speichern-Loading, Speichern-Fehler, Validierungsfehler |
| S006 | Pflegeplan-Reveal-Screen | Hauptscreen | Erster personalisierter Pflegeplan nach Profilerstellung, emotionaler Höhepunkt für Push-Permission-Anfrage | F004, F005, F014, F030, F033, ... | Normal-Voller-Plan, Wetter-Daten-Loading, Wetter-Fehler-Fallback, Push-Permission-Erteilt, Push-Permission-Abgelehnt, Freemium-Features-Locked |
| S007 | Push-Notification-Einwilligungs-Modal | Modal | DSGVO-konforme Push-Einwilligung im Moment des höchsten empfundenen Nutzens nach Pflegeplan-Reveal | F014, F033, F044 | Normal, Bereits-Erteilt, Systemdialog-Trigger |
| S008 | Home-Dashboard | Hauptscreen | Täglicher Einstiegspunkt, Pflanzenpflegeübersicht, Aufgaben-Feed, Core-Retention-Screen | F004, F005, F030, F031, F048, ... | Normal-Mit-Pflanzen, Leer-Keine-Pflanzen-Onboarding-CTA, Alle-Aufgaben-Erledigt, Wetter-Daten-Loading, Offline-Gecachte-Daten, Fehler-Sync |
| S009 | Meine-Pflanzen-Liste | Hauptscreen | Übersicht aller gespeicherten Pflanzenprofile, Verwaltung des Pflanzenbestands | F002, F048, F035, F043 | Normal-Mit-Pflanzen, Leer-CTA-Erste-Pflanze-Scannen, Suche-Aktiv, Freemium-Limit-Erreicht, Offline-Gecacht, Lade-Zustand |
| S010 | Pflanzenprofil-Detail | Subscreen | Detailansicht einer einzelnen Pflanze mit Pflegeplan, Pflegehistorie und Scan-Möglichkeit | F002, F004, F005, F030, F048 | Normal, Pflegeplan-Loading, Aufgabe-Als-Erledigt-Animiert, Offline-Gecacht, Wetter-Kontext-Aktiv, Fehler-Pflegeplan |
| S011 | Scan-Ergebnis-Screen | Subscreen | Anzeige des KI-Erkennungsergebnisses mit Konfidenz, Pflanzeninfos und Aktion zur Profilerstellung | F001, F019, F029, F070 | Hohe-Konfidenz, Niedrige-Konfidenz-Mit-Alternativen, Keine-Pflanze-Erkannt, Offline-Local-Model-Fallback, API-Fehler-Retry-Option |
| S012 | Registrierung-Login-Screen | Hauptscreen | Firebase Auth-basierte Anmeldung, DSGVO-konform, nach erstem Mehrwert-Erlebnis getriggert | F034, F044, F045 | Registrierung, Login, Passwort-Vergessen, Loading-Auth, Fehler-Auth, Bereits-Eingeloggt-Redirect, COPPA-Under13-Block |
| S013 | Profil-und-Einstellungen | Hauptscreen | Nutzerprofil, App-Einstellungen, Datenschutz, DSGVO-Verwaltung, Premium-Upgrade-Zugang | F034, F044, F045, F046, F047, ... | Freemium-Nutzer, Premium-Nutzer, Nicht-Eingeloggt, Datenschutz-Einstellungen-Offen, Loading |
| S014 | Premium-Upgrade-Paywall | Modal | Free-Trial und Abo-Angebot, Conversion-Optimierung, IAP-Integration | F024, F041, F042, F043 | Free-Trial-Verfügbar, Trial-Läuft, Trial-Abgelaufen, Bereits-Premium, IAP-Loading, IAP-Fehler, IAP-Erfolgreich |
| S015 | Freemium-Limit-Erreicht-Modal | Modal | Weicher Paywall bei Scan-Limit-Erreichen, kontextueller Upgrade-Trigger | F043, F042, F041 | Scan-Limit-Täglich-Erreicht, Pflanzenprofil-Limit-Erreicht, Trial-Angebot-Verfügbar |
| S016 | Gieß-Erinnerungs-Notification-Deeplink | Subscreen | Deeplink-Zielscreen nach Tap auf Push-Notification, direkte Pflegeaktion ermöglichen | F005, F033, F004 | Aufgabe-Fällig, Aufgabe-Überfällig, Aufgabe-Bereits-Erledigt, Pflanze-Nicht-Mehr-Vorhanden |
| S017 | Offline-Fehler-Overlay | Overlay | Kommunikation von Offline-Zustand und API-Ausfällen mit Fallback-Hinweisen | F068, F070, F032 | Komplett-Offline, API-Fehler-Plant-Id, API-Fehler-Wetter, Teilweise-Offline-Cache-Verfügbar |
| S018 | Datenschutz-Onboarding-Modal | Modal | DSGVO-COPPA-konformes Datenschutz-Consent beim ersten App-Start vor jeder Datenverarbeitung | F044, F045, F047, F054 | Erstmalig, Bereits-Akzeptiert-Skip, COPPA-Under13-Hard-Block, Einwilligung-Unvollständig-Validierung |
| S019 | Feedback-und-Bewertungs-Modal | Modal | Nutzerfeedback-Erfassung und App-Store-Bewertungs-Prompt zum optimalen Zeitpunkt | F065, F031 | Positiv-Bewertung-App-Store-Redirect, Negativ-Bewertung-Internes-Feedback, Bereits-Bewertet-Suppressed |
| S020 | Performance-und-Analytics-Debug-Overlay | Overlay | Internes Tracking-Overlay für QA und Beta-Testing, nicht für Endnutzer sichtbar | F031, F032, F066 | Debug-Modus-Aktiv, Produktions-Modus-Hidden |
| S021 | TestFlight-Beta-Feedback-Banner | Overlay | Beta-Feedback-Erfassung während TestFlight-Closed-Beta-Phase | F027, F065, F032 | Beta-Aktiv, Produktions-Modus-Hidden |
| S022 | Standort-Permission-Modal | Modal | DSGVO-konforme Einwilligung zur PLZ-Standortnutzung für wetterbasierte Pflegeempfehlungen | F037, F047, F044 | Normal, Permission-Erteilt, Permission-Abgelehnt-PLZ-Fallback, Standort-Nicht-Verfügbar |

## Screen-Hierarchie

### Tab-Bar Navigation
- **Home** (S008)
  - S010
  - S016
- **Meine Pflanzen** (S009)
  - S010
  - S011
- **Scannen** (S004)
  - S011
  - S005
  - S006
- **Profil** (S013)
  - S012

### Modals: S003, S007, S014, S015, S018, S019
### Overlays: S017, S020, S021

## User Flows (0 Flows)

## Edge Cases (0 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|

## Phase-B Screens (8 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S023 | Krankheitsdiagnose-Scanner | Spezialisierter Scan-Modus für Pflanzenkrankheiten und Schädlingserkennung | Coming Soon Badge auf Scanner-Screen mit Wartelist-CTA |
| S024 | Behandlungsplan-Screen | Detaillierter Behandlungsplan nach Krankheitsdiagnose mit Follow-up-Erinnerungen | Nicht sichtbar |
| S025 | Wachstums-Tracking-Timeline | Chronologisches Foto-Tracking des Pflanzenwachstums mit KI-Analyse | Locked-Card in Pflanzenprofil-Detail mit Premium-Teaser |
| S026 | Abo-Verwaltung-Screen | Verwaltung von Monats- und Jahresabonnements, Familienfreigabe | Einfaches Abo-Status-Element in Profil-Screen |
| S027 | Wetter-Pflegeempfehlungs-Detail | Detaillierte wetterbasierte Gieß- und Pflegeempfehlungen mit Forecast | Vereinfachtes Wetter-Widget auf Home-Dashboard |
| S028 | Community-Share-Screen | TikTok und Instagram Teilen-Flow für Pflanzenphotos und Diagnose-Ergebnisse | Einfacher Teilen-Button via iOS Share Sheet auf Scan-Ergebnis |
| S029 | A-B-Test-Variant-Manager | Internes Tool zur Steuerung von A-B-Tests für Onboarding und Paywall | Nicht sichtbar, Firebase Remote Config als Basis |
| S030 | Erweiterte-Pflanzenprofil-Details | Herkunft, Schwierigkeitsgrad, botanische Infos, erweiterte Giftigkeitswarnung | Einfacher Giftigkeits-Icon auf Pflanzenprofil-Detail S010 |

## Zusammenfassung
- **Phase-A Screens:** 22
- **Phase-B Screens:** 8
- **User Flows:** 0
- **Edge Cases:** 0
- **Tap-Count:** Alle im Ziel ✅

# User Flows & Edge Cases – growmeldai

---

## Flow 1: Onboarding (Erst-Start)
- **Pfad:** S001 → S018 → S002 → S003 → S004 → S011 → S005 (Schritt 1–3) → S022 → S006 → S007
- **Taps bis Core Loop:** 6–8 Taps (abhängig von Permission-Dialogen)
- **Zeitbudget:** ~60 Sekunden
- **Kernmomente:**
  - S001: Splash lädt Assets + Firebase-Init
  - S018: DSGVO/COPPA-Consent als erster Gate **vor** jeder Datenverarbeitung
  - S002: Kamera-CTA sofort sichtbar, kein Registrierungszwang
  - S003: Kamera-Permission-Modal (DSGVO-konform, einmalig)
  - S004: Scanner öffnet sich direkt, erster Scan
  - S011: KI-Ergebnis mit hoher Konfidenz
  - S005: 3-Schritt-Profil-Flow (Name → Standort → Topfgröße)
  - S022: Standort-Permission für Wetterdaten (optional, PLZ-Fallback)
  - S006: Pflegeplan-Reveal als emotionaler Höhepunkt
  - S007: Push-Einwilligung **im Moment des höchsten empfundenen Nutzens**
- **Fallback bei DSGVO-Ablehnung:** S018 blockiert → App nicht nutzbar (Hard Block für Mindestanforderungen); optionale Einwilligungen (Standort, Push) → App weiter nutzbar mit reduziertem Funktionsumfang
- **Fallback bei Kamera-Ablehnung:** S003 Abgelehnt-Hinweis → S004 Kamera-Permission-Fehler-State → Hinweis zur manuellen Suche (falls implementiert) oder erneutem Erlauben

---

## Flow 2: Core Loop (wiederkehrend täglich)
- **Pfad:** S008 → S016 (via Push-Notification-Deeplink) → S010 → Aufgabe-Erledigt-Animation → S008
- **Alternativ-Pfad ohne Notification:** S008 → S010 → Aufgabe abhaken → S008
- **Taps bis Aufgabe erledigt:** 2–3 Taps
- **Session-Ziel:** 2–5 Minuten (tägliche Micro-Session via Erinnerung)
- **Kernmomente:**
  - S008 (Home-Dashboard): Aufgaben-Feed zeigt fällige Pflegeaufgaben, Wetter-Kontext sichtbar
  - S010 (Pflanzenprofil-Detail): Aufgabe als erledigt markieren → Animations-Feedback
  - S016 (Deeplink): Direkter Einstieg nach Notification-Tap → reduziert Friction maximal
- **Erweiterter Loop (wöchentlich):** S008 → S004 → S011 → S010 (Diagnose-Update) → S010 (Behandlungsplan aktiv)
- **Erweiterter Loop (neue Pflanze):** S008 (CTA) → S004 → S011 → S005 → S006 → S008

---

## Flow 3: Erster Kauf (Freemium → Premium)
- **Pfad A – Scan-Limit-Trigger:** S004 (Scan-Limit-Erreicht-State) → S015 → S014 → IAP-Systemdialog → S014 (IAP-Erfolgreich) → S006 oder S004
- **Pfad B – Profil-Limit-Trigger:** S009 (Freemium-Limit-Erreicht-State) → S015 → S014 → IAP-Systemdialog → S014 (IAP-Erfolgreich) → S009
- **Pfad C – Proaktiv aus Profil:** S013 (Freemium-Nutzer-State) → S014 → IAP-Systemdialog → S014 (IAP-Erfolgreich) → S013 (Premium-Nutzer-State)
- **Taps bis Kauf:** 3–4 Taps (Pfad A/B: 4 Taps inkl. Systemdialog)
- **Kernmomente:**
  - S015: Weicher Paywall mit kontextuellem Nutzenversprechen + Free-Trial-Angebot
  - S014: Conversion-optimierte Paywall mit Trial-CTA als primärer Button
  - IAP-Systemdialog: Native iOS/Android-Dialog
  - S014 IAP-Erfolgreich: Positives Feedback, Rückkehr zum auslösenden Kontext

---

## Flow 4: Registrierung / Account-Erstellung (nach erstem Mehrwert)
- **Pfad:** S006 (Pflegeplan-Reveal, Push-Permission erteilt) → S008 (Home, erste Session) → S013 → S012 (Registrierung) → S012 (Loading-Auth) → S008 (eingeloggt, Daten synchronisiert)
- **Alternativ-Trigger:** S009 (Freemium-Limit) → S015 → S014 → S012 (Registrierung als Pre-Step vor IAP)
- **Taps bis Account erstellt:** 4–5 Taps
- **Kernmomente:**
  - Registrierung wird **nicht** beim ersten Start erzwungen – erst nach erstem Mehrwert-Erlebnis
  - S012 zeigt Registrierung als Standard-State, Login als sekundäre Option
  - Nach erfolgreicher Auth → Redirect zurück zu S008 mit gesyncten Pflanzendaten
- **Fallback:** S013 (Nicht-Eingeloggt-State) zeigt eingeschränkte Funktionen, persistenter Hinweis auf Vorteile der Registrierung

---

## Flow 5: Diagnose-Loop (Pflanze zeigt Symptome)
- **Pfad:** S008 (Aufgaben-Feed oder manuell) → S009 → S010 (Pflanzenprofil-Detail) → S004 (Re-Scan via CTA im Profil) → S011 (Diagnose-Ergebnis) → S010 (Behandlungsplan aktiv, Follow-up-Erinnerung gesetzt) → S008
- **Taps bis Diagnose:** 4–5 Taps
- **Alternativ über Home-CTA:** S008 → S004 → S011 → S005 (neue Pflanze) oder S010 (bestehende Pflanze updaten)
- **Kernmomente:**
  - S010: "Neue Diagnose starten"-CTA öffnet S004 im Kontext der aktuellen Pflanze
  - S011 (Niedrige-Konfidenz-State): Alternativen werden angezeigt, Nutzer wählt manuell
  - S011: Behandlungsplan wird direkt im Ergebnis-Screen zusammengefasst
  - S010: Pflegehistorie wird mit Diagnose-Eintrag aktualisiert
  - Follow-up-Erinnerung automatisch gesetzt (Push-Permission vorausgesetzt)
- **Mehrwert:** Schließt den vollständigen Diagnose-Loop (bestätigter Markt-Gap)

---

## Flow 6: Offline-Nutzung (kein Internet)
- **Pfad:** S001 (Offline-Fallback-State) → S017 (Komplett-Offline-Overlay, dismissable) → S008 (Offline-Gecachte-Daten-State) → S010 (Offline-Gecacht) → Aufgabe lokal abhaken → S008
- **Scan-Versuch offline:** S004 → S017 (API-Fehler-Plant-Id) → S004 (Offline-Fallback-Local-Model-State, reduzierte KI-Genauigkeit) → S011 (Offline-Local-Model-Fallback-State)
- **Taps bis Offline-Core-Loop:** 3 Taps (Overlay dismissen → Home → Profil)
- **Kernmomente:**
  - S017 ist **dismissable** – Nutzer kann mit gecachten Daten weiterarbeiten
  - S008 zeigt gecachte Pflanzendaten + lokal ausstehende Aufgaben
  - Erledigte Aufgaben werden lokal gespeichert + bei Reconnect synchronisiert
  - S004 mit Local-Model-Fallback: Eingeschränkte Pflanzenidentifikation (~70% Genauigkeit) auch ohne Internet
  - S011 Offline-State: Klar kommunizieren, dass Ergebnis aus lokalem Modell stammt

---

## Flow 7: DSGVO/Consent-Management (Detail)
- **Erst-Start-Pfad:** S001 → S018 (Erstmalig-State) → [Vollständige Einwilligung] → S002
- **Kamera-Consent-Pfad:** S002 → S003 (Normal-State) → [Einwilligung] → S004
- **Push-Consent-Pfad:** S006 → S007 (Normal-State) → [Einwilligung] → S007 (Systemdialog-Trigger) → S006/S008
- **Standort-Consent-Pfad:** S005 (Schritt-2-Standort) → S022 (Normal-State) → [Einwilligung oder Ablehnung → PLZ-Fallback] → S006
- **Nachträgliche Consent-Verwaltung:** S013 → S013 (Datenschutz-Einstellungen-Offen-State) → individuelle Einwilligungen verwalten
- **COPPA-Pfad (unter 13):** S018 (COPPA-Under13-Hard-Block-State) → App-Nutzung vollständig blockiert, Elternteil-Hinweis angezeigt
- **Einwilligungs-Reihenfolge (chronologisch):**
  1. S018: Datenschutz-Basis-Consent (Pflicht, vor jeder Datenverarbeitung)
  2. S003: Kamera-Permission (vor erstem Scan)
  3. S022: Standort-Permission (vor Pflegeplan-Generierung mit Wetterdaten)
  4. S007: Push-Notification-Einwilligung (nach Pflegeplan-Reveal)

---

# Edge Cases

| Situation | Betroffene Screens | Verhalten |
|---|---|---|
| DSGVO-Basis-Consent abgelehnt (S018) | S018, S001 | Hard Block: App nicht nutzbar, Hinweis auf Notwendigkeit, Consent erneut anfragen bei App-Neustart |
| COPPA – Nutzer unter 13 | S018, S012 | S018: Hard Block mit Elternteil-Hinweis; S012: COPPA-Under13-Block, kein Account möglich, kein Tracking |
| Kamera-Permission dauerhaft abgelehnt | S003, S004, S002 | S004 zeigt Kamera-Permission-Fehler-State mit Deep-Link zu iOS/Android-Systemeinstellungen; Onboarding-Scan nicht möglich |
| Push-Permission abgelehnt (S007) | S007, S006, S008, S010 | App bleibt voll nutzbar; kein Retention-Mechanismus via Push; In-App-Nudge nach 7 Tagen in S008 oder S010 (einmalig, nicht aufdringlich) |
| Standort-Permission abgelehnt (S022) | S022, S006, S010 | PLZ-Fallback: Nutzer gibt PLZ manuell ein; Pflegeplan mit eingeschränkten Wetterdaten; S006 zeigt Wetter-Fehler-Fallback-State |
| Scan-Limit täglich erreicht (Freemium) | S004, S015, S014 | S004 wechselt in Scan-Limit-Erreicht-State; S015 erscheint als weicher Paywall mit Trial-Angebot; kein Hard Block ohne Aktion |
| Pflanzenprofil-Limit erreicht (Freemium) | S009, S015, S014 | S009 zeigt Freemium-Limit-Erreicht-State; Hinweis auf gesperrte Slots; S015 mit Upgrade-CTA |
| KI-Identifikation schlägt fehl (API-Fehler) | S004, S011, S017 | S011 zeigt API-Fehler-Retry-Option; S017 als Overlay mit Kontext; Local-Model-Fallback aktiviert (offline oder API-Down) |
| KI-Ergebnis mit niedriger Konfidenz (<60%) | S004, S011 | S011 Niedrige-Konfidenz-State: Top-3-Alternativen anzeigen; Nutzer wählt manuell; Hinweis auf Unsicherheit klar kommuniziert |
| Keine Pflanze erkannt | S011 | S011 Keine-Pflanze-Erkannt-State: Hinweis auf bessere Aufnahmebedingungen (Licht, Abstand, Winkel); Re-Scan-CTA; kein Profil-Flow ausgelöst |
| Internetverlust während Scan | S004, S017 | S004 wechselt zu Offline-Fallback-Local-Model-State; S017 als dismissbares Overlay; Ergebnis mit Offline-Kennzeichnung in S011 |
| Internetverlust im Pflegeplan-Flow | S005, S006, S017 | S006 zeigt Wetter-Daten-Loading → Wetter-Fehler-Fallback; Pflegeplan wird ohne Wetterdaten generiert; S017 als Hinweis-Overlay |
| IAP-Kauf fehlgeschlagen | S014 | S014 IAP-Fehler-State: Klare Fehlermeldung, Retry-CTA, Support-Link; kein Premium-Status aktiviert; vorheriger State bleibt erhalten |
| IAP-Kauf erfolgreich, Premium nicht aktiviert (Restore-Problem) | S014, S013 | S014 zeigt Loading-State; Fallback: "Kauf wiederherstellen"-Option prominent; S013 zeigt Restore-Purchase-CTA |
| Deeplink-Ziel nicht mehr vorhanden (Pflanze gelöscht) | S016 | S016 Pflanze-Nicht-Mehr-Vorhanden-State: Hinweis + Redirect zu S008 (Home) oder S009 (Pflanzenliste) |
| Aufgabe via Deeplink bereits erledigt | S016 | S016 Aufgabe-Bereits-Erledigt-State: Positives Feedback-Element, CTA zu S008 oder S010 |
| App-Start erfordert Update (Force-Update) | S001 | S001 Update-Required-State: Blocker mit Store-Link, keine weitere Navigation möglich |
| Sehr langsame Verbind