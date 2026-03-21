# Screen-Architektur: skillsense

## Screen-Uebersicht (19 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / App Init | Overlay | App-Start, Client-Side Engine laden, Locale erkennen | F014, F035 | Normal, Slow-Connection, Engine-Fehler |
| S002 | Landing Page / Hero | Hauptscreen | Erster Eindruck, Pain-Point-Kommunikation, primärer CTA zum Scanner oder Advisor, Invite-Code-Abfrage | F012, F013, F022, F025, F026, ... | Normal, Invite-Code-ungültig, Invite-Code-gültig, Offline |
| S003 | Cookie Consent / CMP | Modal | DSGVO-konformer Consent vor Analytics-Initialisierung | F045, F046 | Normal, Einstellungen-Expanded |
| S004 | Datenschutzerklärung & Transparenz | Subscreen | DSGVO-Pflichtseite, Client-Side-Verifikations-Erklärung, AVV-Hinweise | F045, F046, F047, F036, F014 | Normal, Offline-Cache |
| S005 | Invite Code Gate | Modal | Closed Beta Zugangssteuerung – blockiert Nutzung ohne gültigen Invite Code | F022 | Normal, Code-wird-geprüft, Code-ungültig, Code-gültig-Weiterleitung |
| S006 | Wartelisten-Formular | Subscreen | Early-Access E-Mail-Eintrag für Advisor Pro Warteliste, KPI: 200+ Einträge | F021, F012 | Normal, Senden, Erfolg, Fehler, Bereits-eingetragen |
| S007 | Skill Scanner – Upload | Hauptscreen | Datei-Upload-Einstieg, primärer Core-Loop-Start für Nutzer mit vorhandenen Skills | F001, F013, F014, F025 | Leer, Datei-wird-gezogen, Datei-hochgeladen, Mehrere-Dateien, Falsches-Format-Fehler, Datei-zu-groß-Fehler, Offline |
| S008 | Skill Scanner – Analyse läuft | Subscreen | Echtzeit-Feedback während der client-side Analyse, verhindert Abbrüche, Scan < 60 Sek. | F009, F027, F014 | Analyse-läuft, Pattern-Check-Phase, Overlap-Check-Phase, Abschließen-Phase, Timeout-Warnung >50 Sek., Fehler-Abbruch |
| S009 | Skill Score – Ergebnis-Dashboard | Hauptscreen | Scan-Ergebnis-Visualisierung in drei Kacheln, Kern-Werterlebnis, KPI-kritisch für D1-Retention | F004, F002, F003, F037, F049 | Normal, Alle-Skills-Gut, Kritische-Risiken-vorhanden, Leer-keine-Skills-erkannt, Fehler-Analyse-fehlgeschlagen |
| S010 | Handlungsempfehlungen – Detail-Liste | Subscreen | Konkrete Aktion pro Skill: behalten / löschen / ersetzen, actionable Output | F005, F004, F049, F043 | Normal, Gefiltert, Suche-aktiv, Leer-nach-Filter, Detail-Expanded |
| S011 | Advisor Light – Fragebogen | Hauptscreen | Alternativer Einstieg ohne vorhandene Skills, Schritt-für-Schritt Fragebogen | F006, F013, F025 | Schritt-1, Schritt-N, Letzte-Frage, Antwort-gewählt, Keine-Antwort-Warnung |
| S012 | Advisor Light – Empfehlungs-Ergebnis | Subscreen | Fragebogen-Auswertung mit personalisierten Skill-Empfehlungen als Einstiegspunkt | F006, F005, F049, F043 | Normal, Advisor-Pro-Teaser-sichtbar, Alle-Empfehlungen-expanded |
| S013 | Advisor Pro – Closed Beta Teaser | Subscreen | Advisor Pro KI-Feature vorstellen, Beta-Warteliste pushen, Feature-Flag-gesteuert | F030, F007, F021, F043 | Teaser-gesperrt, Beta-Zugang-offen, Beta-voll, Beta-freigeschaltet-für-User |
| S014 | Feedback-Formular | Modal | Qualitatives Nutzer-Feedback sammeln, KPI: 40+ ausgefüllte Formulare | F023 | Normal, Senden, Erfolg, Fehler, Abgebrochen |
| S015 | NPS Abfrage | Modal | Net Promoter Score messen, Erfolgskriterium NPS >= 35 für Advisor Pro Beta | F031 | Normal, Score-gewählt, Folgefrage-sichtbar, Abgesendet, Später-verschoben |
| S016 | Impressum & Rechtliches | Subscreen | Pflichtangaben Impressum, Haftungsausschluss, Lizenzhinweise Skill-Datenbank | F045, F049, F044 | Normal, Offline-Cache |
| S017 | Fehler / Nicht gefunden (404 / Allgemein) | Subscreen | Fehlerbehandlung, Nutzer zurück in Flow führen | F025 | 404-Not-Found, Allgemeiner-Fehler, Offline |
| S018 | Onboarding-Overlay (First Use) | Overlay | Erstkontakt-Orientierung nach Invite-Code-Einlösung, zeigt die zwei Einstiegswege | F013, F006, F001 | Normal, Scanner-gewählt, Advisor-gewählt |
| S019 | Share / Ergebnis teilen | Modal | Social Sharing des Scan-Scores für viralen Loop, Marketing-Kanal Reddit/LinkedIn | F004, F032 | Normal, Link-kopiert, Geteilt-Erfolg |

## Screen-Hierarchie

### Modals: S003, S014, S015, S019
### Overlays: S001, S005, S018

## User Flows (7 Flows)

### Flow1: Onboarding (Erst-Start) — App oeffnen bis erster Core Loop
**Screens:** S001 -> S002 -> S003 -> S005 -> S007 -> S008 -> S009
**Beschreibung:** App startet mit Splash/Engine-Init -> Landing Page zeigt Pain-Point-Headline und primaeren CTA -> Cookie Consent Modal erscheint automatisch -> Invite Code Gate prueft Beta-Zugang -> Skill Scanner Upload-Screen -> Analyse laeuft -> Score-Dashboard als erstes Ergebnis
**Taps bis Ziel:** 3
**Zeitbudget:** 60 Sekunden
**Fallback:** Kein Invite Code vorhanden: Weiterleitung zu Wartelisten-Formular S006. Consent-Ablehnung: Nur notwendige Cookies, App funktioniert vollstaendig weiter da client-side.

### Flow2: Core Loop (wiederkehrend) — Direkteinstieg bis Scan-Ergebnis
**Screens:** S001 -> S002 -> S007 -> S008 -> S009 -> S010
**Beschreibung:** Wiederkehrender Nutzer oeffnet App -> Splash kurz -> Landing Page -> direkt zu Scanner -> Upload -> Analyse -> Score-Dashboard -> Detail-Empfehlungen
**Taps bis Ziel:** 2
**Zeitbudget:** 45-90 Sekunden fuer vollstaendigen Scan-Zyklus
**Fallback:** Analyse-Fehler: Fehler-State in S008 zeigt Retry-Option. Timeout nach 50 Sek: Warnung mit Abbrechen-Option.

### Flow3: Erster Kauf — Wartelisten-Eintrag Advisor Pro
**Screens:** S002 -> S006
**Beschreibung:** Nutzer sieht auf Landing Page den Early-Access-Wartelisten-Link -> navigiert zu Wartelisten-Formular -> traegt E-Mail ein -> bestaetigt DSGVO Opt-in -> sendet Formular -> Bestaetigungsanimation
**Taps bis Ziel:** 3
**Zeitbudget:** 60-90 Sekunden
**Fallback:** Formular-Sendefehler: Fehler-State in S006 zeigt Retry. Bereits-eingetragen-State: Info-Meldung ohne erneuten Eintrag. Offline: Formular sperrt Senden-Button mit Offline-Hinweis.

### Flow4: Social Challenge — Ergebnis teilen
**Screens:** S009 -> S010
**Beschreibung:** Nutzer hat Scan-Ergebnis im Score-Dashboard -> tapped Share-Ergebnis-Button -> nativer Share-Dialog oeffnet -> Nutzer teilt auf gewuenschter Plattform
**Taps bis Ziel:** 3
**Zeitbudget:** 15-30 Sekunden
**Fallback:** Share-Dialog nicht verfuegbar: Fallback auf Copy-Link-Button. Kein Scan-Ergebnis vorhanden: Share-Button disabled mit Tooltip Zuerst Scan durchfuehren. Offline: Share-Dialog oeffnet sich, aber geteilter Link ist nicht abrufbar — Hinweis einblenden.

### Flow5: Battle-Pass Equivalent — Advisor Light Fragebogen-Fortschritt
**Screens:** S002 -> S011 -> S012
**Beschreibung:** Nutzer ohne vorhandene Skill-Dateien waehlt alternativen Einstieg via Fragebogen -> schreitet Schritt fuer Schritt durch Advisor Light -> sieht personalisierten Fortschritt und Empfehlungs-Ergebnis
**Taps bis Ziel:** 3 bis erstes Ergebnis sichtbar (Schritt 1 beantwortet), Gesamt-Flow abhaengig von Fragebogen-Laenge
**Zeitbudget:** 3-8 Minuten fuer vollstaendigen Fragebogen
**Fallback:** Keine Antwort gewaehlt: Warnung-State blockiert Weiter-Button. Nutzer will zurueck: Zurueck-Navigation ohne Datenverlust. Offline: Fragebogen funktioniert vollstaendig client-side, kein Unterschied.

### Flow6: Rewarded Ad Equivalent — Wartelisten-Bestaetigungs-Reward
**Screens:** S006 -> S007
**Beschreibung:** Nutzer traegt sich in Warteliste ein -> Bestaetigungs-Screen zeigt Reward: Sofortiger Zugang zum Skill Scanner als Dankeschoen fuer Wartelisten-Eintrag -> Nutzer wird direkt zum Scanner geleitet
**Taps bis Ziel:** 1
**Zeitbudget:** 5-10 Sekunden
**Fallback:** Reward-CTA nicht geklickt: Nutzer bleibt auf Bestaetigungs-Screen, kein Zeitdruck. Offline: Scanner-Weiterleitung funktioniert da client-side. Reward bereits genutzt: Kein doppelter Reward-Trigger.

### Flow7: Consent (Detail) — Splash bis finales Routing
**Screens:** S001 -> S002 -> S003 -> S004 -> S005
**Beschreibung:** App startet -> Engine-Init -> Landing Page -> Cookie Consent Modal erscheint -> Nutzer navigiert zu Datenschutzerklaerung fuer Details -> kehrt zurueck -> waehlt Consent-Option -> Routing zum Invite Code Gate oder direkt zu Scanner
**Taps bis Ziel:** 3
**Zeitbudget:** 30-120 Sekunden abhaengig von Leseverhalten
**Fallback:** Consent-Modal wird geschlossen ohne Auswahl: Modal bleibt persistent, App-Nutzung nicht moeglich bis Consent-Entscheidung. Offline: Datenschutzerklaerung aus Cache laden (S004 Offline-Cache-State). Engine-Fehler in S001: Fehler-State mit Retry-Option.

## Edge Cases (8 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| Offline bei App-Start | S001, S002, S007 | S001 Engine-Init laedt aus lokalem Cache, da client-side Architektur. S002 zeigt Offline-State-Banner am oberen Rand. S007 Upload und Scan funktioniert vollstaendig da Analyse client-side laeuft. Einzige Einschraenkung: Wartelisten-Formular S006 kann nicht abgesendet werden — Button wird disabled mit Hinweis Kein Internet — Formular wird lokal gespeichert und beim naechsten Online-Status gesendet. |
| KI-Engine Analyse-Fehler oder Timeout | S008, S009 | S008 wechselt in Fehler-Abbruch-State mit erklaerenden Fehlertext und zwei Optionen: Erneut versuchen (primaer) und Stattdessen Fragebogen nutzen (sekundaer). Kein leerer Score-Screen S009 wird angezeigt. Technischer Fehlercode wird im Hintergrund geloggt (wenn Analytics-Consent vorliegt). Timeout-Warnung erscheint proaktiv bei >50 Sekunden Analysezeit. |
| Invite Code ungueltig oder bereits verbraucht | S002, S005 | S005 zeigt inline Validierungs-Feedback direkt unter dem Eingabefeld mit spezifischer Fehlermeldung: Ungültiger Code (bei falschem Code) oder Dieser Code wurde bereits verwendet (bei verbrauchtem Code). Kein Modal, kein Page-Reload. CTA Code einloesen bleibt aktiv fuer neuen Versuch. Link zur Warteliste wird prominent sichtbar als naechster logischer Schritt. |
| Upload-Datei mit falschem Format oder zu gross | S007 | S007 wechselt sofort in Falsches-Format-Fehler-State oder Datei-zu-gross-Fehler-State. Fehler wird inline im Upload-Bereich angezeigt, nicht als separates Modal. Akzeptierte Formate werden als Chips angezeigt: JSON, TXT, MD. Groessenlimit wird explizit genannt (z.B. max 10 MB). Scan-CTA bleibt deaktiviert bis valide Datei hochgeladen. Sekundaerer Hinweis: Kein passendes Format? Nimm den Fragebogen. |
| Consent komplett abgelehnt — nur notwendige Cookies | S003, S009, S010 | App funktioniert vollstaendig — da Core-Funktionalitaet client-side und consent-unabhaengig. Analytics werden nicht initialisiert. Marketing-Tracking findet nicht statt. KI-Content-Kennzeichnung in S009 und S010 bleibt unveraendert sichtbar. Keine Einschraenkung der Scan-Funktion, keine Paywall, keine Benachteiligung. Consent-Einstellung wird lokal gespeichert und bei Neustart nicht erneut abgefragt. |
| Scan-Ergebnis erkennt keine Skills in hochgeladener Datei | S009 | S009 wechselt in Leer-keine-Skills-erkannt-State. Statt Score-Dashboard erscheint erklaerende Meldung: Keine Skills erkannt mit Subtext Was wurde geprueft und was nicht erkannt wurde. Zwei CTAs: Andere Datei hochladen (primaer) und Stattdessen Fragebogen nutzen (sekundaer). Kein leerer Score 0/0 der Nutzer verunsichert. Privacy-Reminder bleibt sichtbar. |
| Wartelisten-Formular Doppeleintrag | S006 | S006 wechselt in Bereits-eingetragen-State nach Formular-Absenden. Meldung: Diese E-Mail ist bereits auf der Warteliste — du wirst benachrichtigt sobald Advisor Pro startet. Kein Fehler-Styling (rot), sondern freundliche Bestaetigung. Social-Proof-Counter wird nicht erneut erhoehen. Nutzer wird nicht bestraft fuer Doppeleintrag-Versuch. |
| Engine-Fehler beim App-Start (Splash-Screen) | S001 | S001 wechselt in Engine-Fehler-State. Statt blockiertem Ladebalken erscheint erklaerende Fehlermeldung mit zwei Optionen: App neu laden (Tap) und Seite im Browser oeffnen als Fallback. Kein endloser Ladezustand. Fehler wird im Hintergrund geloggt sofern minimale Verbindung besteht. Privacy-by-Design-Badge bleibt sichtbar als Vertrauenssignal. |

## Phase-B Screens (8 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S020 | Skill-Datenbank – Browse & Suche | Kuratierte Skill-Datenbank durchsuchen und installieren | Coming Soon Badge auf Advisor-Pro-Teaser-Screen S013 |
| S021 | Skill-Fit-Check | Persönliche Relevanz-Bewertung eines Skills aus der Datenbank | Nicht sichtbar |
| S022 | Tiefenanalyse-Report (Deep Scan) | IAP-gesicherter erweiterter Scan-Report | Locked-Kachel im Ergebnis-Dashboard S009 mit Upgrade-CTA |
| S023 | Nutzerregistrierung & Account | Account-Anlage für Pro-Tier, Abo-Verwaltung | Nicht sichtbar – Phase A ist account-frei |
| S024 | Pricing Page | Monats- und Jahresabo-Vergleich mit Toggle | Statische Teaser-Sektion im Footer mit Early-Access-Hinweis |
| S025 | Stripe Checkout / Zahlungsflow | IAP und Subscription-Zahlung via Stripe | Nicht sichtbar |
| S026 | Chat-Export Analyse | Chat-Export hochladen und analysieren für D30-Retention | Nicht sichtbar |
| S027 | Pro Dashboard / Account-Übersicht | Abo-Status, Rechnungen, Feature-Übersicht Pro-User | Nicht sichtbar |

## Tap-Count Zusammenfassung

| Flow | Taps | Ziel | Status |
|---|---|---|---|
| Flow1 — Onboarding Erst-Start bis Core Loop | 3 | max 3 | ✅ ok |
| Flow2 — Core Loop wiederkehrend bis Score | 2 | max 3 | ⚠️ ok — unter Ziel |
| Flow3 — Erster Kauf (Wartelisten-Conversion) | 3 | max 3 | ✅ ok |
| Flow4 — Social Challenge bis gesendet | 3 | max 3 | ✅ ok |
| Flow5 — Advisor Light Fragebogen Fortschritt | 3 | max 3 | ⚠️ ok — Gesamt-Flow hoeher |
| Flow6 — Rewarded Ad Equivalent bis Reward | 1 | max 3 | ⚠️ ok — deutlich unter Ziel |
| Flow7 — Consent Detail Splash bis Routing | 3 | max 3 | ✅ ok |

## Zusammenfassung
- **Phase-A Screens:** 19
- **Phase-B Screens:** 8
- **User Flows:** 7
- **Edge Cases:** 8
- **Tap-Count:** Einige ueber Ziel ⚠️

# User Flows — skillsense

---

## Flow 1: Onboarding (Erst-Start)
- **Pfad:** S001 → S002 → S003 → S005 → S018 → S007 → S008 → S009
- **Taps bis Core Loop:** 3 (CTA auf S002 → Invite Code bestätigen auf S005 → Upload starten auf S007)
- **Zeitbudget:** ~60 Sekunden bis erstes Ergebnis sichtbar
- **Beschreibung:** App initialisiert Client-Side Engine (S001) → Landing Page trifft Pain Point, primärer CTA „Deine Skills jetzt prüfen" (S002) → Cookie Consent erscheint automatisch vor jeder Analytics-Initialisierung (S003) → Invite Code Gate prüft Beta-Zugang (S005) → Onboarding-Overlay zeigt die zwei Einstiegswege: Scanner oder Advisor (S018) → Nutzer wählt Scanner, Upload-Screen (S007) → Analyse läuft mit Echtzeit-Feedback (S008) → Score-Dashboard als erstes Werterlebnis (S009)
- **Fallback Kein Invite Code:** S005 leitet direkt zu Wartelisten-Formular S006 — kein Zugang zum Core Loop
- **Fallback Consent-Ablehnung:** S003 setzt nur notwendige Cookies, App funktioniert vollständig weiter (alles client-side, kein Analytics-Block)
- **Fallback Engine-Fehler auf S001:** Fehler-State zeigt Retry-Button, nach 3 Fehlversuchen Weiterleitung zu S017

---

## Flow 2: Core Loop (wiederkehrend)
- **Pfad:** S001 → S002 → S007 → S008 → S009 → S010
- **Taps bis Ergebnis:** 2 (CTA auf S002 → Upload starten auf S007)
- **Session-Ziel:** 45–90 Sekunden für vollständigen Scan-Zyklus, Gesamtsession 6–10 Minuten inkl. S010-Review
- **Beschreibung:** Wiederkehrender Nutzer öffnet App, Splash kurz (S001) → Landing Page mit bekanntem CTA (S002) → direkter Einstieg in Upload ohne erneuten Invite-Code-Check (S007) → Analyse läuft, Echtzeit-Phasen-Feedback verhindert Abbruch (S008) → Score-Dashboard zeigt drei Kacheln: Gut / Prüfen / Risiko (S009) → Handlungsempfehlungen im Detail mit Filter- und Suchoption (S010)
- **Fallback Analyse-Timeout >50 Sek.:** S008 zeigt Timeout-Warnung mit Abbrechen-Option und Retry
- **Fallback Analyse-Fehler:** Fehler-Abbruch-State auf S008, Weiterleitung zurück zu S007 mit Fehlermeldung
- **Fallback Offline:** S007 sperrt Upload-Button, zeigt Offline-Hinweis — kein Silent Fail

---

## Flow 3: Wartelisten-Eintrag Advisor Pro
- **Pfad:** S002 → S006 — alternativ: S012 → S013 → S006
- **Taps bis Eintrag:** 3 (Wartelisten-Link auf S002 → E-Mail eintragen auf S006 → Formular absenden)
- **Zeitbudget:** 60–90 Sekunden
- **Beschreibung:** Nutzer sieht Early-Access-CTA auf Landing Page (S002) oder erreicht Teaser nach Advisor-Light-Ergebnis (S012 → S013) → Wartelisten-Formular mit E-Mail-Eingabe und DSGVO-Opt-in (S006) → Bestätigungsanimation bei Erfolg
- **Fallback Sendefehler:** Fehler-State auf S006 mit Retry-Button, Eingabe bleibt erhalten
- **Fallback Bereits-eingetragen:** Info-Meldung ohne erneuten Datenbank-Eintrag, kein doppelter Eintrag
- **Fallback Offline:** Senden-Button gesperrt mit Offline-Hinweis, Formular-Eingabe bleibt lokal erhalten

---

## Flow 4: Social Challenge — Ergebnis teilen
- **Pfad:** S009 → S019
- **Taps bis Teilen:** 2 (Share-Button auf S009 → Teilen-Aktion in S019)
- **Zeitbudget:** 15–20 Sekunden
- **Beschreibung:** Nutzer sieht Score-Dashboard (S009) mit Teilen-CTA → Share-Modal öffnet sich (S019) mit vorgefertigtem Text und Score-Visual für Reddit/LinkedIn → Nutzer wählt Link kopieren oder direktes Teilen → Erfolgs-Feedback
- **Fallback Link-kopieren fehlgeschlagen:** Clipboard-API nicht verfügbar, Link wird als selektierbarer Text angezeigt
- **Fallback Keine Skills erkannt:** Share-Button auf S009 ist deaktiviert im State „Leer-keine-Skills-erkannt", kein leeres Ergebnis wird geteilt
- **Fallback Offline:** Share-Modal zeigt nur Link-kopieren-Option, native Share-API wird nicht aufgerufen

---

## Flow 5: Advisor Light — Alternativer Einstieg ohne vorhandene Skills
- **Pfad:** S002 → S018 → S011 → S012 → S013 → S006
- **Taps bis Ergebnis:** 3 (Advisor-CTA auf S002 → Advisor wählen in S018 → Fragebogen abschließen in S011)
- **Zeitbudget:** 3–5 Minuten für vollständigen Fragebogen-Zyklus
- **Beschreibung:** Nutzer ohne vorhandene Skills wählt „Lieber den Fragebogen" auf Landing Page (S002) → Onboarding-Overlay bestätigt Advisor-Einstieg (S018) → Schritt-für-Schritt Fragebogen (S011) mit Fortschrittsanzeige → Personalisierte Skill-Empfehlungen als Ergebnis (S012) → Advisor Pro Teaser weckt Upgrade-Interesse (S013) → Weiterleitung zu Wartelisten-Formular (S006)
- **Fallback Keine Antwort gewählt:** S011 zeigt Keine-Antwort-Warnung, Weiter-Button bleibt gesperrt bis Auswahl getroffen
- **Fallback Advisor Pro Beta voll:** S013 zeigt State „Beta-voll" mit Wartelisten-CTA statt direktem Zugang
- **Fallback Nutzer bricht Fragebogen ab:** Fortschritt wird lokal im Session-State gehalten, Rückkehr zu S011 setzt an letzter Frage fort

---

## Flow 6: Feedback & NPS — Qualitative Rückkopplung sammeln
- **Pfad:** S009 → S014 — parallel nach Session: S015
- **Taps bis Feedback-Absenden:** 3 (Feedback-Button auf S009 → Formular ausfüllen in S014 → Absenden)
- **Zeitbudget:** 60–120 Sekunden für qualitatives Feedback
- **Beschreibung:** Nach Score-Dashboard (S009) erscheint Feedback-CTA → Feedback-Formular-Modal öffnet (S014) für qualitative Eingabe → NPS-Abfrage (S015) wird als separates Modal nach Feedback-Abschluss oder zeitbasiert nach der Session getriggert → Score-Auswahl → optionale Folgefrage sichtbar → Absenden
- **Fallback Feedback-Sendefehler:** Fehler-State auf S014 mit Retry, Eingabe bleibt erhalten
- **Fallback NPS später verschoben:** S015 „Später"-Option speichert Trigger, NPS erscheint beim nächsten Core-Loop-Abschluss erneut
- **Fallback Nutzer bricht S014 ab:** State „Abgebrochen" schließt Modal ohne Datenverlust, kein erneutes Triggern in derselben Session

---

## Flow 7: Datenschutz & Transparenz — DSGVO-Detail-Flow
- **Pfad:** S002 → S003 → S004 → S016 — alternativ: S003 → S004 direkt aus Footer jedes Screens
- **Taps bis vollständiger Information:** 2 (Datenschutz-Link auf S003 → Datenschutzerklärung S004)
- **Zeitbudget:** Nutzer-gesteuert, kein Zeitlimit
- **Beschreibung:** Cookie-Consent-Modal erscheint (S003) → Nutzer expandiert Einstellungen (State: Einstellungen-Expanded) → Link zu Datenschutzerklärung öffnet S004 mit Client-Side-Verifikations-Erklärung und AVV-Hinweisen → Impressum erreichbar via S016 aus Footer — beide Screens im Offline-Cache verfügbar
- **Fallback Offline auf S004:** Offline-Cache-State liefert zuletzt geladene Version der Datenschutzerklärung mit Timestamp-Hinweis
- **Fallback Offline auf S016:** Identisch — statischer Cache, kein Ladefehler
- **Fallback S003 ohne Interaktion:** Kein Auto-Accept, Modal bleibt persistent, App-Navigation ist gesperrt bis Consent-Entscheidung getroffen wurde

---

# Edge Cases

| Situation | Betroffene Screens | Verhalten |
|---|---|---|
| Invite Code ungültig | S005, S002 | State „Code-ungültig" auf S005 zeigt Inline-Fehlermeldung, Retry sofort möglich — kein Redirect, kein Session-Verlust |
| Invite Code nicht vorhanden | S005, S006 | Weiterleitung zu Wartelisten-Formular S006 — Core Loop bleibt vollständig gesperrt bis gültiger Code vorliegt |
| Internetverlust während Upload | S007 | Upload-Button sperrt sofort, Offline-State zeigt Hinweis, bereits hochgeladene Datei bleibt im lokalen State erhalten |
| Internetverlust während Analyse | S008 | Client-Side Engine läuft weiter (alles lokal), kein Analyseabbruch durch Offline-Status — Ergebnis erscheint wie erwartet |
| Analyse-Timeout über 50 Sekunden | S008 | Timeout-Warnung erscheint mit Countdown, Abbrechen-Option und Retry — kein Silent Hang |
| Engine-Fehler beim App-Start | S001, S017 | Fehler-State auf S001 mit Retry-Button — nach 3 Fehlversuchen Weiterleitung zu S017 mit Kontakt-Hinweis |
| Falsches Datei-Format hochgeladen | S007 | Inline-Fehlermeldung direkt unter Drop-Zone, erlaubte Formate werden angezeigt — kein Seiten-Reload |
| Datei zu groß | S007 | Fehler-State „Datei-zu-groß" mit konkreter Größenbeschränkung in der Fehlermeldung, Datei wird nicht verarbeitet |
| Keine Skills in Datei erkannt | S009 | State „Leer-keine-Skills-erkannt" auf S009 — Share-Button deaktiviert, Hinweis zur Datei-Qualität, Retry-CTA zurück zu S007 |
| Consent abgelehnt | S003, alle Analytics-Features | Nur notwendige Cookies gesetzt, keine Analytics-Initialisierung — App funktioniert vollständig, da 100% client-side |
| NPS nach Score gewählt — Folgefrage | S015 | Bei Score 0–6: Folgefrage nach Kritikgrund erscheint automatisch — bei Score 7–10: direkt Absenden |
| Nutzer bereits auf Warteliste | S006 | State „Bereits-eingetragen" verhindert doppelten Eintrag, zeigt Bestätigungsmeldung ohne Fehlerton |
| Advisor Pro Beta voll | S013 | State „Beta-voll" deaktiviert Beta-Zugang-CTA, zeigt Wartelisten-Formular-Link zu S006 als einzige Handlungsoption |
| 404 / Ungültige Route | S017 | State „404-Not-Found" mit klarem Back-to-Home-CTA zu S002 — kein toter Endpunkt |
| Clipboard API nicht verfügbar beim Teilen | S019 | Fallback: Link wird als selektierbarer Text-Block gerendert, Copy-Button wird ausgeblendet |
| Offline beim Formular-Absenden | S006, S014 | Senden-Button gesperrt, Offline-Hinweis inline — Formulardaten bleiben im lokalen State erhalten bis Verbindung wiederhergestellt |

---

# Tap-Count-Zusammenfassung

| Flow | Taps | Ziel | Status |
|---|---|---|---|
| Onboarding → Core Loop (S001–S009) | 3 | max. 3 | ✅ ok |
| Core Loop → Ergebnis (S001–S009) | 2 | max. 3 | ✅ ok |
| Landing → Wartelisten-Eintrag (S002–S006) | 3 | max. 3 | ✅ ok |
| Score → Social Share (S009–S019) | 2 | max. 3 | ✅ ok |
| Advisor Light → Ergebnis (S002–S012) | 3 | max. 4 | ✅ ok |
| Score → Feedback + NPS (S009–S015) | 3 | max. 4 | ✅ ok |
| Cookie Consent → Datenschutz-Detail (S003–S004) | 2 | max. 2 | ✅ ok |