# Feature-Priorisierung: growmeldai

## Phase A — Soft-Launch MVP (36 Features)
**Budget:** 252,500 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F001 | KI-Pflanzenerkennung per Kamera | ki_level_latency_sec, d1_retention, session_duration_min | Kein | 8 |  | Core KI-PoC — ohne funktionierende Pflanzenerkennung scheitert das gesamte Produkt. Muss <3s Latenz erreichen. |
| F002 | Pflanzenprofil-Erstellung | d1_retention, session_duration_min | Kein | 4 | F001 | Basis für alle weiteren Features. Ohne Profil keine personalisierten Pflegepläne. |
| F003 | Standort- und Topfgrößenabfrage | d1_retention | Kein | 3 |  | Notwendig für personalisierte Pflegepläne. Einfache UI-Eingabe. |
| F004 | Personalisierter Pflegeplan | d1_retention, d7_retention | Indirekt (Retention) | 5 | F002, F003 | Core Value Proposition — ohne Pflegeplan kein Nutzenversprechen. |
| F005 | Gieß-Erinnerungen | d7_retention, sessions_per_day | Indirekt (Retention) | 3 | F004 | Kritisch für tägliche Nutzung und Retention. Basis-Erinnerungssystem. |
| F014 | Push-Notification-Einwilligung im Nutzenmoment | d1_retention | Indirekt (Retention) | 2 | F004 | DSGVO-konforme Einwilligung muss im Moment des Nutzenversprechens erfolgen. Rechtlich zwingend. |
| F018 | Kamera-Onboarding ohne Registrierung | d1_retention, onboarding_completion_rate | Kein | 2 |  | Frictionless Onboarding — kritisch für erste Nutzung. Ohne sofortige Kamera-Nutzung hohe Drop-off-Rate. |
| F019 | KI-Identifikation in <3 Sekunden | ki_level_latency_sec, d1_retention | Kein | 4 | F001 | Explizites Go/No-Go Kriterium für Soft Launch. Ohne <3s Latenz scheitert der KI-PoC. |
| F024 | Free-to-Play-Basisversion | d1_retention, conversion_rate | Hoch | 3 |  | Basis-Monetarisierung für Soft Launch. Ohne Free-Tier keine Nutzerakquise. |
| F027 | TestFlight-Closed-Beta | crash_rate, d7_retention | Kein | 2 |  | Technische Stabilität muss vor Soft Launch validiert werden. Crash-Free Rate >98% ist Gating-Kriterium. |
| F028 | Soft-Launch in Australien/Kanada | d7_retention, LTV/CAC-Ratio | Hoch | 1 | F027 | Regionale Validierung der Monetarisierung und Retention. Ohne Soft Launch kein Global Launch. |
| F029 | Plant.id API-Integration | ki_level_latency_sec | Kein | 4 |  | Externe KI-Datenbank für Pflanzenerkennung. Ohne API keine KI-Funktionalität. |
| F030 | OpenWeatherMap-Integration | d7_retention | Indirekt | 3 |  | Wetterdaten für personalisierte Pflegepläne. Kritisch für Nutzenversprechen. |
| F031 | Firebase Analytics | d1_retention, d7_retention, performance_tracking | Indirekt | 2 |  | Basis-Analytics für KPI-Tracking. Ohne Analytics keine Daten für Optimierung. |
| F032 | Firebase Crashlytics | crash_rate | Kein | 1 |  | Echtzeit-Fehlerberichte für Stabilität. Rechtlich und technisch zwingend. |
| F033 | Firebase Cloud Messaging (APNs) | d1_retention, sessions_per_day | Indirekt | 2 |  | Push-Notifications für Erinnerungen. Kritisch für tägliche Nutzung. |
| F034 | Firebase Auth | d1_retention | Indirekt | 2 |  | Nutzerverwaltung für Free-Tier und Premium. Basis für alle weiteren Features. |
| F035 | Cloud Firestore | d7_retention | Indirekt | 3 | F034 | Backend-Datenbank für Pflanzenprofile und Pflegepläne. Ohne Speicherung keine Retention. |
| F036 | Firebase Cloud Functions | ki_level_latency_sec, d7_retention | Indirekt | 3 | F035 | Serverless-Backend für Pflegeplan-Generierung und Erinnerungen. Kritisch für Performance. |
| F037 | Core Location (PLZ-Ebene) | d7_retention | Indirekt | 2 |  | Standortbestimmung für wetterbasierte Pflegeempfehlungen. Ohne Standort keine personalisierten Empfehlungen. |
| F038 | AVFoundation (Kamera-Framework) | ki_level_latency_sec | Kein | 3 |  | Präzise Kamera-Steuerung für schnelle Scans. Kritisch für KI-PoC. |
| F039 | SwiftUI/React Native UI-Framework | d1_retention, onboarding_completion_rate | Kein | 6 |  | Plattformübergreifende UI für iOS und Android. Basis für alle Nutzerinteraktionen. |
| F041 | IAP-Integration (In-App-Purchases) | conversion_rate | Hoch | 3 | F024 | Monetarisierung für Premium-Features. Ohne IAP keine Revenue. |
| F042 | Free-Trial-Mechanik | conversion_rate | Hoch | 2 | F041 | Apple/Google-konforme Testphase für Premium-Features. Kritisch für Conversion. |
| F043 | Freemium-Grenzen-Management | conversion_rate | Hoch | 2 | F024 | Begrenzung der kostenlosen Scans für Monetarisierung. Ohne Grenzen keine Conversion. |
| F044 | DSGVO-Compliance-Management | legal_risk | Kein | 4 |  | Rechtlich zwingend für EU/CA/US-Launch. Ohne Compliance kein App-Store-Release. |
| F045 | COPPA-Compliance | legal_risk | Kein | 3 |  | Altersverifikation für Nutzer unter 13 Jahren. Rechtlich zwingend für US-Markt. |
| F046 | Kamera-Zugriffsmanagement | legal_risk | Kein | 2 |  | DSGVO-konforme Kamera-Nutzung. Ohne Einwilligung keine KI-Erkennung. |
| F047 | Standortdaten-Verarbeitung | legal_risk | Kein | 2 |  | DSGVO-konforme Verarbeitung von Standortdaten. Rechtlich zwingend. |
| F048 | Nutzerprofil-Management | d7_retention | Indirekt | 3 | F034 | Speicherung von Pflanzenbestand und Pflegehistorie. Basis für Retention. |
| F054 | Firebase-Nutzung | crash_rate, performance_tracking | Indirekt | 2 |  | DSGVO-konforme Backend-Infrastruktur. Rechtlich und technisch zwingend. |
| F065 | Nutzerfeedback-Management | app_store_rating | Indirekt | 2 |  | Sammeln von Nutzerfeedback für ASO und Produktverbesserungen. Kritisch für App-Store-Rating. |
| F066 | Performance-Tracking | d1_retention, d7_retention, LTV/CAC-Ratio | Indirekt | 2 | F031 | Tracking von Nutzerakquise und Retention. Basis für Optimierung. |
| F068 | Notfall-Plan für API-Ausfälle | crash_rate, d1_retention | Indirekt | 3 | F029, F030 | Fallback-Mechanismen für Stabilität. Kritisch für Nutzererlebnis. |
| F069 | Daten-Backup-System | legal_risk | Kein | 2 | F035 | DSGVO-konforme Datensicherung. Rechtlich zwingend. |
| F070 | KI-Modell-Fallback | ki_level_latency_sec, crash_rate | Indirekt | 2 | F001 | Offline-Erkennung als Backup für KI-Ausfälle. Kritisch für Nutzererlebnis. |

### Phase A Budget-Check
- Entwicklerwochen: 34
- Kosten: 136,000 EUR
- Budget: 252,500 EUR
- Status: **im_budget**
- Ueber Budget um: 116,500 EUR

### Kritischer Pfad
- Kette: F001 -> F002 -> F004 -> F005 -> F014
- Gesamtdauer: 22 Wochen
- Beschreibung: Kritischer Pfad für Soft Launch: KI-Pflanzenerkennung -> Pflanzenprofil -> Pflegeplan -> Gieß-Erinnerungen -> Push-Notification-Einwilligung. Ohne diese Features scheitert der Soft Launch.

### Parallelisierbare Feature-Gruppen
- **KI-Kernfunktionen**: F001, F019, F029 (parallel zu )
- **Onboarding & Monetarisierung**: F018, F024 (parallel zu F001)
- **Infrastruktur & Analytics**: F031, F032, F033 (parallel zu )
- **Erweiterte Erinnerungen**: F005, F015 (parallel zu F001)
- **Standort & Wetter**: F003, F030 (parallel zu )

## Phase B — Full Production (25 Features)
**Budget:** 230,000 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F006 | Dünger-Erinnerungen | d7_retention, sessions_per_day | Indirekt | 2 | F004 | Erweitert Pflegeplan um Dünger-Erinnerungen. Nicht kritisch für Soft Launch, aber wichtig für Nutzenversprechen. |
| F007 | Umtopf-Erinnerungen | d30_retention | Indirekt | 2 | F015 | Erweitert Pflegeplan um Umtopf-Erinnerungen. Langfristige Retention. |
| F008 | Krankheitsdiagnose per Scan | d7_retention, session_duration_min | Hoch | 6 | F001 | Erweitert KI-Funktionalität um Krankheitsdiagnose. Wichtig für Nutzenversprechen, aber komplex. |
| F009 | Behandlungsplan nach Diagnose | d7_retention | Hoch | 3 | F008 | Erweitert Krankheitsdiagnose um Behandlungsplan. Wichtig für Nutzenversprechen. |
| F010 | Follow-up-Erinnerungen nach Behandlung | d30_retention | Indirekt | 2 | F009 | Erweitert Erinnerungen um Follow-up. Langfristige Retention. |
| F011 | Wetter-kontextuelle Gieß-Empfehlungen | d7_retention | Indirekt | 3 | F004, F030 | Erweitert Pflegeplan um wetterbasierte Empfehlungen. Wichtig für Nutzenversprechen. |
| F012 | KI-Wachstums-Tracking | d30_retention, session_duration_min | Hoch | 5 | F001 | Erweitert KI-Funktionalität um Wachstums-Tracking. Wichtig für langfristige Nutzung. |
| F013 | Giftigkeitswarnung für Haustiere/Kinder | legal_risk, app_store_rating | Indirekt | 2 | F002 | Sicherheitsfeature für Nutzer. Wichtig für App-Store-Rating und Compliance. |
| F015 | Tägliche Erinnerungen | d7_retention, sessions_per_day | Indirekt | 2 | F005 | Erweitert Erinnerungen um tägliche Notifications. Wichtig für tägliche Nutzung. |
| F016 | Wöchentliche Pflege-Checks | d30_retention | Indirekt | 2 | F004 | Erweitert Erinnerungen um wöchentliche Checks. Langfristige Retention. |
| F017 | Episodische Erinnerungen | d30_retention | Indirekt | 2 | F004 | Erweitert Erinnerungen um episodische Notifications. Langfristige Retention. |
| F020 | Pflanzenprofil mit Herkunft und Schwierigkeitsgrad | d7_retention | Indirekt | 2 | F002 | Erweitert Pflanzenprofile um Herkunft und Schwierigkeitsgrad. Wichtig für Nutzenversprechen. |
| F021 | Familienfreigabe für Abos | conversion_rate | Hoch | 2 | F041 | Erweitert Monetarisierung um Familienfreigabe. Wichtig für Conversion. |
| F022 | Jahres-Abo-Modell | conversion_rate, LTV/CAC-Ratio | Hoch | 2 | F041 | Primäres Monetarisierungsmodell. Wichtig für Revenue. |
| F023 | Monats-Abo-Modell | conversion_rate | Hoch | 2 | F041 | Flexibles Abo-Modell für Nutzer. Wichtig für Conversion. |
| F025 | Einmalkauf für erweiterte Features | conversion_rate | Hoch | 2 | F041 | Erweitert Monetarisierung um Einmalkäufe. Wichtig für Revenue. |
| F026 | ASO-Optimierung | app_store_rating, conversion_rate | Hoch | 3 |  | Optimierung der App-Store-Präsenz für bessere Sichtbarkeit. Wichtig für Conversion. |
| F057 | TikTok-Integration | user_acquisition | Indirekt | 2 |  | Organischer Content für virales Wachstum. Wichtig für Nutzerakquise. |
| F058 | Instagram-Integration | user_acquisition | Indirekt | 2 |  | Organischer Content für Markenaufbau. Wichtig für Nutzerakquise. |
| F059 | Apple Search Ads | user_acquisition | Hoch | 2 | F026 | Gezielte Anzeigen für Nutzer mit hoher Kaufabsicht. Wichtig für Nutzerakquise. |
| F060 | Meta Ads-Integration | user_acquisition | Hoch | 2 | F026 | Gezielte Anzeigen auf Meta für Skalierung. Wichtig für Nutzerakquise. |
| F062 | ASO-Optimierung (App Store Optimization) | conversion_rate | Hoch | 3 |  | Optimierung der App-Store-Präsenz für bessere Sichtbarkeit. Wichtig für Conversion. |
| F063 | Website-Landing-Page | user_acquisition | Indirekt | 4 |  | Dedizierte Landing Page für Pre-Launch-Marketing und SEO. Wichtig für Nutzerakquise. |
| F064 | SEO-Optimierung | user_acquisition | Indirekt | 4 | F063 | Optimierung der Website für Suchmaschinen. Wichtig für organischen Traffic. |
| F067 | A/B-Testing-Tool | conversion_rate | Hoch | 3 | F031 | Durchführung von A/B-Tests für App-Store-Elemente und Marketing-Kampagnen. Wichtig für Conversion. |

### Phase B Budget-Check
- Entwicklerwochen: 27
- Kosten: 108,000 EUR
- Budget: 230,000 EUR
- Status: **im_budget**
- Ueber Budget um: 122,000 EUR

## Backlog — Post-Launch (7 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |
|---|---|---|---|---|
| F050 | Pflanzengiftigkeit-Warnsystem | v1.2 | Sicherheitsfeature für Nutzer | Wichtig für Nutzer, aber nicht kritisch für Launch. Kann später implementiert werden. |
| F051 | Diagnose-Empfehlungs-System | v1.2 | Erweitert Krankheitsdiagnose um Empfehlungen | Komplex und nicht kritisch für Launch. Kann später implementiert werden. |
| F052 | Plant.id-API-Integration | v1.3 | Alternative KI-Datenbank für Pflanzenerkennung | Plant.id ist bereits integriert. Alternative API kann später hinzugefügt werden. |
| F053 | OpenWeatherMap-API-Integration | v1.3 | Alternative Wetterdaten-API | OpenWeatherMap ist bereits integriert. Alternative API kann später hinzugefügt werden. |
| F055 | Markenrechtliche Prüfung | v1.0 | Rechtliche Absicherung des Namens | Rein rechtlicher Prozess, keine technische Implementierung. |
| F056 | Patentrecherche | v1.0 | Rechtliche Absicherung der KI-Algorithmen | Rein rechtlicher Prozess, keine technische Implementierung. |
| F061 | Influencer-Marketing-Tool | v1.1 | Management von Micro-Influencern | Rein prozessuales Tool, keine technische Integration. |

## Zusammenfassung
- **Gesamt Features:** 68
- **Phase A (Soft-Launch):** 36 Features
- **Phase B (Full Production):** 25 Features
- **Backlog:** 7 Features
- **Phase A Kosten:** 136,000 EUR
- **Phase B Kosten:** 108,000 EUR
- **Kritischer Pfad:** 22 Wochen