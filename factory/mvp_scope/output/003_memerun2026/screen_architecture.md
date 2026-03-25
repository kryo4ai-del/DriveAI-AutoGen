# Screen-Architektur: memerun2026

## Screen-Uebersicht (18 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / Loading | Hauptscreen | Display app branding and load initial assets. |  | Normal, Loading, Error |
| S002 | Authentication | Hauptscreen | User login, registration and cloud save initiation. | F029, F018 | Normal, Error |
| S003 | Tutorial | Hauptscreen | Introduce core gameplay mechanics to new users. | F007 | Normal |
| S004 | Main Menu | Hauptscreen | Dashboard for navigating to gameplay, leaderboards, shop etc. | F008, F036 | Normal |
| S005 | Game Screen | Hauptscreen | Core endless-runner gameplay with tap-to-jump and swipe-to-direction mechanics. | F001, F002, F003, F009, F060 | Normal, Paused, Game Over, Error |
| S006 | Pause/Fail Modal | Modal | Pause the game and offer options to retry or share fail clips. | F060 | Normal, Paused |
| S007 | High Score | Hauptscreen | Display user high scores and global leaderboards. | F008 | Normal, Loading, Error |
| S008 | Shop / IAP | Hauptscreen | In-app purchase store for cosmetics and power-ups. | F012, F013, F041, F014, F042 | Normal, Transaction, Error |
| S009 | Settings | Hauptscreen | Manage app preferences and access legal information (DSGVO, COPPA etc.). | F021, F047, F048, F049, F062 | Normal, Loading, Error |
| S010 | Profile / Cloud Save | Hauptscreen | User profile management with cloud save status and settings. | F018, F029 | Normal, Syncing, Error |
| S011 | Feedback Modal | Modal | Allow users to provide in-app feedback. | F036 | Normal, Submitted, Error |
| S012 | IAP Confirmation Modal | Modal | Confirm in-app purchase transactions. | F013, F041 | Normal, Processing, Error |
| S013 | Error / Offline Modal | Modal | Inform users about connectivity issues or general errors. |  | Error, Offline |
| S014 | Privacy Consent Modal | Modal | Manage user consents for legal compliance (DSGVO/COPPA). | F047, F048, F049, F062 | Normal |
| S015 | Share Result Modal | Modal | Enable users to share fail clips and meme-run highlights via social networks. | F060 | Normal |
| S016 | Performance Overlay | Overlay | Show performance metrics for debugging purposes (hidden during normal play). | F032 | Hidden, Visible |
| S017 | Leaderboards Subscreen | Subscreen | Detailed view of leaderboards accessible from the High Score tab. | F008 | Normal, Loading, Error |
| S018 | Fail-Clip Recording & Export | Hauptscreen | Allow users to view, record, and export game fail clips. | F060 | Normal, Processing, Error |

## Screen-Hierarchie

### Tab-Bar Navigation
- **Home** (S004)
- **High Score** (S007)
  - S017
- **Shop** (S008)
- **Profile** (S010)
- **Settings** (S009)

### Modals: S006, S011, S012, S013, S014, S015
### Overlays: S016

## User Flows (7 Flows)

### Flow1: Onboarding (Erst-Start)
**Screens:** S001 -> S002 -> S003
**Beschreibung:** App öffnen -> Authentication inkl. Consent -> Tutorial -> Übergang zum Core Loop (Home)
**Taps bis Ziel:** 2

### Flow2: Core Loop (wiederkehrend)
**Screens:** S004 -> S005
**Beschreibung:** Home -> Tippe auf Play -> Gameplay (Tap und Swipe) bis Match-Ende
**Taps bis Ziel:** 3

### Flow3: Erster Kauf
**Screens:** S004 -> S008 -> S012
**Beschreibung:** Home -> Shop aufrufen -> Artikel auswählen -> IAP Confirmation zur Kaufbestätigung
**Taps bis Ziel:** 3

### Flow4: Social Challenge
**Screens:** S004 -> S015
**Beschreibung:** Home -> Auswahl Social Challenge -> Fail-Clip teilen über Share Options im Share Result Modal
**Taps bis Ziel:** 2

### Flow5: Battle-Pass
**Screens:** S004 -> S010
**Beschreibung:** Home -> Battle-Pass Bereich (über Profil) aufrufen -> Fortschritt einsehen und Rewards freischalten
**Taps bis Ziel:** 2

### Flow6: Rewarded Ad
**Screens:** S005
**Beschreibung:** Während des Spiels wird ein Rewarded Ad triggerisiert -> Ad ansehen -> Reward erhalten
**Taps bis Ziel:** 1

### Flow7: Consent (Detail)
**Screens:** S001 -> S014
**Beschreibung:** Splash wird angezeigt -> Privacy Consent Modal erscheint -> Consent wird eingeholt -> Routing zum nächsten Screen
**Taps bis Ziel:** 2

## Edge Cases (7 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| Offline | S001, S002, S007, S008, S009 | Error / Offline Modal (S013) erscheint; eingeschränkter Zugang zu cloudbasierten Funktionen |
| KI-Fehler | S003, S005 | Fallback auf vorgefertigte Meme-Assets; Hinweis im Error-State |
| Kauf-Fehler | S008, S012 | Fehlermeldung im Transaktionsprozess; Retry Option wird angeboten |
| COPPA / Consent abgelehnt | S014, S002 | Einschränkung bestimmter Features; generische Inhalte werden bereitgestellt, kein Tracking |
| Push-Benachrichtigungen abgelehnt | S009 | Option wird in den Einstellungen markiert; Warnhinweis zur Reaktivierung von Push Notifications |
| Server-Ausfall | S002, S007, S008, S010 | Error Modal erscheint, Retry-Button wird angeboten; Offline-Modus wenn möglich |
| Leerer Zustand (keine Daten, z. B. leere Leaderboards) | S007, S017 | Leere State-UI mit erklärendem Hinweis; Aufforderung, in Kürze wieder zu prüfen |

## Phase-B Screens (1 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S020 | Live-Ops Event-Hub | Display seasonal events and live operations content. | Coming Soon Badge |

## Tap-Count Zusammenfassung

| Flow | Taps | Ziel | Status |
|---|---|---|---|
| Onboarding (Erst-Start) | 2 | max 3 | ✅ ok |
| Core Loop (wiederkehrend) | 3 | max 3 | ✅ ok |
| Erster Kauf | 3 | max 3 | ✅ ok |
| Social Challenge | 2 | max 3 | ✅ ok |
| Battle-Pass | 2 | max 3 | ✅ ok |
| Rewarded Ad | 1 | max 1 | ✅ ok |
| Consent (Detail) | 2 | max 3 | ✅ ok |

## Zusammenfassung
- **Phase-A Screens:** 18
- **Phase-B Screens:** 1
- **User Flows:** 7
- **Edge Cases:** 7
- **Tap-Count:** Alle im Ziel ✅

# User Flows

---

## Flow 1: Onboarding (Erst-Start)

- **Pfad:** S001 → S014 → S002 → S003 → S004
- **Taps bis Core Loop:** 2
- **Zeitbudget:** ~60 Sekunden
- **Beschreibung:** App startet mit Splash/Loading (S001), Privacy Consent Modal (S014) erscheint automatisch vor der Authentication, User gibt Consent → Authentication/Registrierung (S002) → Tutorial (S003) mit Tap-to-Jump und Swipe-Intro → Übergang zu Main Menu (S004)
- **Fallback bei Consent-Nein:** S014 leitet trotzdem weiter zu S002 → generische, nicht-personalisierte Meme-Levels ohne Tracking; kein AI-generierter Content, nur vorgefertigte Meme-Assets
- **Fallback bei Auth-Fehler:** S013 (Error/Offline Modal) erscheint → Retry oder als Gast fortfahren
- **Fallback bei Tutorial-Skip:** Direkter Sprung zu S004; Tutorial bleibt über Settings jederzeit erneut aufrufbar

---

## Flow 2: Core Loop (wiederkehrend)

- **Pfad:** S004 → S005 → S006 → S005 → S015
- **Taps bis Match:** 1
- **Session-Ziel:** 6–10 Minuten
- **Beschreibung:** User öffnet App auf Main Menu (S004) → Tap auf Play → Game Screen (S005) startet sofort mit aktuellem AI-Meme-Run → bei Pause oder Fail erscheint Pause/Fail Modal (S006) mit Retry, Quit und Share-Option → bei erneutem Play zurück zu S005 → nach herausragendem Run oder Fail optional Share Result Modal (S015)
- **Fallback bei Spielabsturz:** S005 Error-State erscheint → Auto-Retry nach 3 Sekunden → bei erneutem Fehler Rückkehr zu S004 mit Highscore-Sicherung aus lokalem Cache
- **Fallback bei schlechter Verbindung:** Lokal gecachte Meme-Assets werden geladen; kein Verbindungsabbruch-Interrupt im laufenden Match

---

## Flow 3: Erster Kauf

- **Pfad:** S004 → S008 → S012 → S008
- **Taps bis Kauf:** 3
- **Beschreibung:** User navigiert über Tab-Bar zu Shop (S008) → Artikel auswählen (Kosmetik oder Power-Up) → IAP Confirmation Modal (S012) erscheint mit Preisübersicht und Bestätigungs-CTA → nach Bestätigung verarbeitet S012 die Transaktion (Processing-State) → Erfolg führt zurück zu S008 mit freigeschaltetem Item
- **Fallback bei Transaktionsfehler:** S012 wechselt in Error-State → Fehlermeldung mit Retry-Button; keine Doppelbelastung durch idempotente Transaktions-ID
- **Fallback bei Verbindungsabbruch während Kauf:** S013 (Error/Offline Modal) erscheint → Transaktion wird serverseitig in Pending-State gehalten → bei Reconnect automatische Wiederaufnahme

---

## Flow 4: Social Challenge

- **Pfad:** S004 → S005 → S018 → S015
- **Taps:** 2
- **Beschreibung:** User startet vom Main Menu (S004) → spielt einen Run auf Game Screen (S005) → nach Match-Ende oder Fail wird Fail-Clip Recording & Export (S018) aufgerufen → Clip wird vorschauangezeigt und kann bearbeitet werden → Share Result Modal (S015) öffnet sich mit direkten Share-Optionen für TikTok, Reels und weitere Plattformen
- **Fallback bei fehlendem Clip:** S018 zeigt Error-State → Hinweis, dass Clip-Aufnahme fehlgeschlagen ist → Option, einen Standard-Screenshot zu teilen
- **Fallback bei Ablehnung von Share-Permissions:** S015 zeigt systemseitigen Permission-Dialog → bei Ablehnung bleibt der Clip lokal gespeichert mit Hinweis zur manuellen Freigabe

---

## Flow 5: Battle-Pass

- **Pfad:** S004 → S010 → S008
- **Taps:** 2
- **Beschreibung:** User navigiert über Tab-Bar zu Profil (S010) → Battle-Pass-Sektion zeigt aktuellen XP-Fortschritt, freigeschaltete und gesperrte Rewards der aktuellen Season → Tap auf gesperrten Reward führt direkt zu Shop (S008) für optionalen Battle-Pass-Upgrade-Kauf
- **Fallback bei Sync-Fehler:** S010 wechselt in Syncing/Error-State → lokaler Fortschrittsstand wird angezeigt mit Hinweis auf ausstehende Cloud-Synchronisation
- **Fallback bei abgelaufenem Battle-Pass:** S010 zeigt leeren Reward-Track mit Countdown zur nächsten Season und Coming-Soon-Badge (Verweis auf S020)

---

## Flow 6: Rewarded Ad

- **Pfad:** S005 → S006 → S005
- **Taps:** 1
- **Beschreibung:** Während des Gameplays auf S005 (Game Over State) erscheint im Pause/Fail Modal (S006) ein Rewarded-Ad-CTA → User tippt auf „Weiterleben / Extra Lives ansehen" → Ad wird inline abgespielt → nach vollständigem Ansehen erhält der User den Reward (z. B. Revive, Power-Up) und kehrt nahtlos zu S005 zurück
- **Fallback bei nicht verfügbarer Ad:** S006 blendet den Rewarded-Ad-CTA aus oder ersetzt ihn mit einem deaktivierten, ausgegrautem Button mit Tooltip „Aktuell keine Werbung verfügbar"
- **Fallback bei Ad-Abbruch:** Kein Reward wird vergeben; User bleibt in S006 mit weiterhin aktivem Retry-Button

---

## Flow 7: Consent (Detail)

- **Pfad:** S001 → S014 → S002 oder S004
- **Taps:** 2
- **Beschreibung:** Splash Screen (S001) lädt initiale Assets → Privacy Consent Modal (S014) erscheint automatisch bei Erst-Start oder nach App-Update mit geänderten Datenschutzbedingungen → User wählt zwischen vollständigem Consent, eingeschränktem Consent oder Ablehnung → je nach Auswahl Routing zu Authentication (S002) bei Neunutzern oder direkt zu Main Menu (S004) bei bekannten Usern
- **Fallback bei vollständiger Ablehnung:** Kein Tracking, kein AI-Content; App ist mit generischen Meme-Assets nutzbar; Leaderboard-Funktion und Cloud-Save deaktiviert mit erklärendem Hinweis
- **Fallback bei COPPA-Trigger (Altersabfrage ergibt unter 13):** S014 blockiert spezifische Features (Tracking, Social Sharing, IAP) vollständig; elterliche Zustimmung wird eingeholt oder User wird in stark eingeschränkten Modus geleitet
- **Re-Consent:** Bei geänderten DSGVO-Bedingungen erscheint S014 erneut beim nächsten App-Start; bestehender Consent wird bis zur Neu-Bestätigung als eingeschränkt behandelt

---

# Edge Cases

| Situation | Betroffene Screens | Verhalten |
|---|---|---|
| Consent abgelehnt | S014, S002, S005, S007 | Kein Tracking, kein AI-Content; generische vorgefertigte Meme-Assets werden geladen; Leaderboards und Cloud-Save sind deaktiviert; Hinweis-Banner in S004 mit Option zur Consent-Überarbeitung in S009 |
| Internetverlust im Match | S005, S006, S013 | Laufendes Match wird lokal ohne Unterbrechung fortgesetzt; AI-Content-Nachladung pausiert und greift auf gecachte Assets zurück; S013 erscheint erst nach Match-Ende, nicht während des Spiels; Highscore wird lokal gespeichert und bei Reconnect synchronisiert |
| KI-Fehler (AI-Content-Generierung schlägt fehl) | S003, S005, S018 | Sofortiger Fallback auf vorgefertigtes Meme-Asset-Pack ohne User-Unterbrechung; dezenter Error-Hinweis im Performance Overlay (S016) für Debugging; kein sichtbarer Fehler im normalen Spielfluss |
| Kauf fehlgeschlagen | S008, S012, S013 | S012 wechselt in Error-State mit klarer Fehlermeldung und Retry-Button; idempotente Transaktions-ID verhindert Doppelbelastung; bei wiederholtem Fehler erscheint S013 mit Support-Link; Item wird nicht freigeschaltet bis Transaktion bestätigt |
| Server-Ausfall (Backend nicht erreichbar) | S002, S007, S008, S010, S013 | S013 erscheint mit Retry-Button und geschätzter Wartezeit; Core Loop (S004 → S005) bleibt offline voll spielbar mit lokalen Assets; Leaderboard (S007, S017) zeigt letzten gecachten Stand mit Timestamp; IAP (S008) und Cloud-Save (S010) sind deaktiviert mit erklärendem Hinweis |
| COPPA (Altersabfrage ergibt unter 13) | S014, S002, S008, S009, S015 | Tracking und Analytics vollständig deaktiviert; IAP in S008 nur mit elterlicher Zustimmung (Parental Gate); Social Sharing in S015 deaktiviert; Push-Benachrichtigungen in S009 deaktiviert; UI zeigt kindgerechten, eingeschränkten Modus ohne Werbung |
| Push-Benachrichtigungen abgelehnt | S009, S004 | In S009 wird die Option als deaktiviert markiert mit erklärendem Hinweis zu verpassten Event-Alerts; nach 7 Tagen erscheint ein sanfter In-App-Nudge auf S004 (Banner, nicht Modal) mit Opt-in-CTA; kein erneuter System-Permission-Dialog ohne expliziten User-Tap |

---

# Tap-Count-Zusammenfassung

| Flow | Taps | Ziel | Status |
|---|---|---|---|
| Onboarding → Core Loop | 2 | max 3 | ✅ ok |
| Core Loop → Match Start | 1 | max 3 | ✅ ok |
| Home → Kauf abgeschlossen | 3 | max 3 | ✅ ok |
| Social Challenge → Share | 2 | max 3 | ✅ ok |
| Battle-Pass → Fortschritt | 2 | max 3 | ✅ ok |
| Rewarded Ad → Reward | 1 | max 2 | ✅ ok |
| Consent Detail → Next Screen | 2 | max 3 | ✅ ok |