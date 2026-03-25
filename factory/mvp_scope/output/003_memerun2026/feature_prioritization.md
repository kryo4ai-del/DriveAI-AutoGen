# Feature-Priorisierung: memerun2026

## Phase A — Soft-Launch MVP (27 Features)
**Budget:** 252,500 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F001 | Endless-Runner Core Loop | D1, D7, Session-Dauer, Sessions_pro_Tag | Kein | 8 |  | Absolutes Core-Feature — ohne geht kein Spiel. Muss für Soft Launch funktionieren. |
| F002 | Tap-to-Jump Mechanik | D1, D7, Session-Dauer | Kein | 4 | F001 | Grundlegende Steuerung — ohne geht kein Gameplay. |
| F003 | Swipe-to-Direction Mechanik | D1, D7 | Kein | 3 | F001 | Alternative Steuerung für bessere Usability — wichtig für Retention. |
| F007 | Tutorial-Phase | D1, Session-Dauer | Kein | 2 | F001 | Ohne Tutorial verstehen Nutzer das Spiel nicht — kritisch für D1-Retention. |
| F008 | High-Score-System | D1, D7, Sessions_pro_Tag | Mittel | 3 | F001 | Wettbewerbsaspekt fördert Wiederholungsspiele — wichtig für Retention. |
| F009 | Session-Dauer-Limit | Session-Dauer | Kein | 1 | F001 | Kurze Sessions sind typisch für Mobile — muss kontrolliert werden. |
| F012 | Free-to-Play Modell | Revenue | Hoch | 2 |  | Monetarisierung ist Pflicht für Soft Launch — Basis-IAP muss möglich sein. |
| F013 | In-App-Purchases (IAP) | Revenue | Hoch | 4 | F012 | Basis-IAP für Cosmetics/Power-Ups muss für Monetarisierung verfügbar sein. |
| F014 | Werbeeinblendungen | Revenue | Hoch | 3 | F012 | Hybrid-Modell erfordert Ads für Soft Launch. |
| F018 | Cloud-Save-System | D7, D30 | Kein | 3 |  | Kritisch für Nutzerbindung — ohne Cloud-Save brechen Nutzer schnell ab. |
| F019 | Cross-Platform-Support | Sessions_pro_Tag | Mittel | 4 |  | Soft Launch in AU/CA/NZ erfordert iOS/Android — muss stabil laufen. |
| F021 | Datenschutz-Compliance | Legal | Hoch | 6 |  | Ohne DSGVO/COPPA kein Launch — rechtlich zwingend. |
| F023 | Server-Infrastruktur | Crash_Rate, KI_Latency | Mittel | 8 |  | Skalierbare Backend-Lösung ist Pflicht für Live-Betrieb. |
| F024 | Closed Beta-Testphase | Crash_Rate, Nutzerfeedback | Kein | 4 | F001, F019, F023 | Testphase ist Pflicht für Stabilität und KPI-Optimierung. |
| F025 | Soft Launch | D1, D7, Crash_Rate | Mittel | 0 | F024 | Kein Feature, aber der Prozess selbst ist Phase A — muss vorbereitet sein. |
| F029 | Nutzer-Authentifizierung | D1, D7 | Mittel | 3 |  | Basis für Cloud-Save und Social-Features — ohne geht nichts. |
| F032 | Performance-Tracking | Crash_Rate, Session-Dauer | Kein | 2 | F023 | Ohne Monitoring keine Optimierung — kritisch für KPIs. |
| F036 | Nutzerfeedback-System | Nutzerbindung | Kein | 2 | F029 | Feedback ist essenziell für Iteration — muss in Phase A verfügbar sein. |
| F041 | In-App Purchase System | Revenue | Hoch | 4 | F012 | Rechtlich zwingend für Monetarisierung — muss compliant sein. |
| F042 | Advertisement Integration | Revenue | Hoch | 3 | F014 | Rechtlich zwingend für Ads — muss compliant sein. |
| F047 | DSGVO-Consent-Management | Legal | Hoch | 3 |  | Rechtlich zwingend für EU-Release — muss in Phase A umgesetzt sein. |
| F048 | COPPA-Compliance | Legal | Hoch | 2 | F047 | Rechtlich zwingend für US-Release — muss in Phase A umgesetzt sein. |
| F049 | Jugendschutzmechanismen (USK/PEGI) | Legal | Hoch | 2 |  | Rechtlich zwingend für globalen Release — muss in Phase A umgesetzt sein. |
| F052 | Beta-Programm (TestFlight/Closed Beta) | Crash_Rate, Nutzerfeedback | Kein | 4 | F024 | Testphase ist Pflicht für Stabilität und KPI-Optimierung. |
| F059 | AI-Meme-Generator (PoC) | KI_Latency, Nutzerbindung | Mittel | 6 | F023 | Kritischer Differentiator — muss in Phase A als PoC getestet werden. |
| F060 | Fail-Clip Recording & Export | Social_Sharing, Nutzerbindung | Mittel | 3 | F001 | Social Features sind wichtig für Viralität — Basis muss in Phase A sein. |
| F062 | Datenschutzerklärung & Einwilligungsmanagement | Legal | Hoch | 2 | F047 | Rechtlich zwingend für Launch — muss in Phase A umgesetzt sein. |

### Phase A Budget-Check
- Entwicklerwochen: 44
- Kosten: 176,000 EUR
- Budget: 252,500 EUR
- Status: **im_budget**
- Ueber Budget um: 76,500 EUR

### Kritischer Pfad
- Kette: F001 -> F002 -> F007 -> F012 -> F013 -> F024 -> F025
- Gesamtdauer: 24 Wochen
- Beschreibung: Ununterbrochene Abhängigkeitskette von Core-Features bis zum Soft Launch. Jede Verzögerung hier blockiert den gesamten Prozess.

### Parallelisierbare Feature-Gruppen
- **Core Gameplay Features**: F003, F008, F009, F018, F029, F032, F036 (parallel zu F001)
- **Monetarisierung & Infrastruktur**: F012, F014, F019, F021, F023 (parallel zu F001)
- **Phase B Features (nach Soft Launch)**: F004, F005, F006, F010, F011, F015, F016, F017, F020, F022 (parallel zu F025)

## Phase B — Full Production (36 Features)
**Budget:** 230,000 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F004 | AI-generierte Meme-Integration | Nutzerbindung, Session-Dauer | Mittel | 4 | F059 | Erweiterte KI-Integration — wichtig für Differenzierung, aber nicht kritisch für Soft Launch. |
| F005 | Dynamische Meme-Aktualisierung | Nutzerbindung, Session-Dauer | Mittel | 3 | F004 | Content-Freshness ist wichtig, aber nicht kritisch für Soft Launch. |
| F006 | Fail-Clip-Erfassung | Social_Sharing, Nutzerbindung | Mittel | 2 | F060 | Erweiterte Clip-Funktionalität — Basis reicht für Soft Launch. |
| F010 | Charakter-Auswahl | Nutzerbindung, IAP_Conversion | Mittel | 3 | F013 | Cosmetics sind wichtig für Monetarisierung, aber nicht kritisch für Soft Launch. |
| F011 | Power-Up-System | Session-Dauer, IAP_Conversion | Hoch | 4 | F013 | Monetarisierungsfeature — wichtig, aber nicht kritisch für Soft Launch. |
| F015 | Battle Pass-System | Retention, Revenue | Hoch | 6 | F013 | Saisonaler Content ist wichtig, aber Basis-Pass reicht für Soft Launch. |
| F016 | Saisonale Inhalte | Nutzerbindung, Retention | Hoch | 3 | F015 | Content-Freshness ist wichtig, aber nicht kritisch für Soft Launch. |
| F017 | Social Sharing (TikTok/Reels) | Viralität, Nutzerbindung | Mittel | 3 | F060 | Social Features sind wichtig, aber Basis-Sharing reicht für Soft Launch. |
| F020 | Performance-Optimierung für Android | Crash_Rate, Session-Dauer | Kein | 4 | F019 | Android-Optimierung ist wichtig, aber nicht kritisch für Soft Launch. |
| F022 | Lokalisierungs-System | Nutzerbindung, Retention | Mittel | 5 | F019 | Lokalisierung ist wichtig für globale Expansion, aber nicht kritisch für Soft Launch. |
| F026 | Full Launch | Globaler Erfolg | Hoch | 0 | F025 | Kein Feature, aber der Prozess selbst ist Phase B — muss vorbereitet sein. |
| F027 | Nutzersegmentierung | Monetarisierung, Retention | Hoch | 3 | F032 | Analytics sind wichtig für Optimierung, aber nicht kritisch für Soft Launch. |
| F028 | Event-System | Nutzerbindung, Retention | Mittel | 4 | F015 | Events sind wichtig für Retention, aber nicht kritisch für Soft Launch. |
| F030 | Push-Benachrichtigungen | Retention, Sessions_pro_Tag | Mittel | 2 | F029 | Push-Nachrichten sind wichtig für Retention, aber nicht kritisch für Soft Launch. |
| F031 | Community-Features | Nutzerbindung, Retention | Mittel | 5 | F029 | Community ist wichtig für langfristige Bindung, aber nicht kritisch für Soft Launch. |
| F033 | KI-Content-Moderation | Legal, Nutzerbindung | Hoch | 4 | F059 | Rechtlich zwingend für KI-Content — muss in Phase B umgesetzt werden. |
| F034 | Glücksspielmechanik (regelkonform) | Revenue | Hoch | 5 | F043 | Monetarisierungsfeature — wichtig, aber rechtlich komplex und nicht kritisch für Soft Launch. |
| F035 | Exklusive Content-Pakete | IAP_Conversion, Revenue | Hoch | 3 | F013 | Monetarisierungsfeature — wichtig, aber nicht kritisch für Soft Launch. |
| F037 | Multiplayer-Ranking | Nutzerbindung, Retention | Mittel | 4 | F008 | Social Features sind wichtig, aber nicht kritisch für Soft Launch. |
| F038 | Nutzerprofil-System | Nutzerbindung, Retention | Mittel | 3 | F029 | Social Features sind wichtig, aber Basis reicht für Soft Launch. |
| F039 | KI-generierte Meme-Themen | Nutzerbindung, Session-Dauer | Mittel | 3 | F004 | Erweiterte KI-Integration — wichtig für Differenzierung, aber nicht kritisch für Soft Launch. |
| F040 | Fail-Clip-Editor | Social_Sharing, Nutzerbindung | Mittel | 2 | F006 | Erweiterte Social Features — Basis reicht für Soft Launch. |
| F043 | Loot Box / Zufallsmechanik Compliance | Legal, Revenue | Hoch | 6 |  | Rechtlich zwingend für Monetarisierung — muss in Phase B umgesetzt werden. |
| F044 | App Store Richtlinien Compliance | Legal | Hoch | 2 |  | Rechtlich zwingend für Store-Release — muss in Phase B umgesetzt sein. |
| F045 | AI-generierter Meme-Content Filter | Legal, Nutzerbindung | Hoch | 3 | F033 | Rechtlich zwingend für KI-Content — muss in Phase B umgesetzt werden. |
| F046 | Urheberrechtsdokumentation für AI-Trainingsdaten | Legal | Hoch | 4 |  | Rechtlich zwingend für KI-Content — muss in Phase B umgesetzt sein. |
| F050 | Social Sharing Features | Viralität, Nutzerbindung | Mittel | 2 | F017 | Erweiterte Social Features — Basis reicht für Soft Launch. |
| F051 | Community-Hub (Landing Page) | Nutzerbindung, Marketing | Mittel | 4 |  | Marketing-Tool — wichtig für Global Launch, aber nicht kritisch für Soft Launch. |
| F053 | Press Kit | Marketing | Kein | 2 |  | Marketing-Tool — wichtig für Global Launch, aber nicht kritisch für Soft Launch. |
| F054 | In-Game Event System | Nutzerbindung, Retention | Mittel | 4 | F028 | Events sind wichtig für Retention, aber nicht kritisch für Soft Launch. |
| F055 | Cross-Platform Leaderboards | Nutzerbindung, Retention | Mittel | 3 | F008 | Social Features sind wichtig, aber nicht kritisch für Soft Launch. |
| F056 | Social Media Teaser Kampagne | Marketing | Kein | 2 |  | Marketing-Tool — wichtig für Global Launch, aber nicht kritisch für Soft Launch. |
| F057 | Influencer Marketing Plattform | Marketing | Hoch | 4 |  | Marketing-Tool — wichtig für Global Launch, aber nicht kritisch für Soft Launch. |
| F058 | Paid User Acquisition (UA) | Nutzerakquise | Hoch | 2 |  | Marketing-Tool — wichtig für Global Launch, aber nicht kritisch für Soft Launch. |
| F061 | Altersverifikationssystem | Legal | Hoch | 2 | F048 | Rechtlich zwingend für COPPA-Compliance — muss in Phase B umgesetzt sein. |
| F063 | Markenrechtsprüfung (Namenskonflikt) | Legal | Hoch | 3 |  | Rechtlich zwingend für Launch — muss in Phase B umgesetzt sein. |

### Phase B Budget-Check
- Entwicklerwochen: 37
- Kosten: 148,000 EUR
- Budget: 230,000 EUR
- Status: **im_budget**
- Ueber Budget um: 82,000 EUR

## Backlog — Post-Launch (5 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |
|---|---|---|---|---|
| F057 | Influencer Marketing Plattform | v1.3 | Skalierbare Influencer-Koordination für langfristige Kampagnen | Manuelle Koordination ist ausreichend für Soft Launch und frühe Phasen. |
| F058 | Paid User Acquisition (UA) | v1.2 | Skalierbare UA-Kampagnen für globale Expansion | Organisches Wachstum ist ausreichend für Soft Launch. |
| F051 | Community-Hub (Landing Page) | v1.2 | Zentrale Anlaufstelle für Community-Engagement | Social Features im Spiel reichen für Soft Launch. |
| F053 | Press Kit | v1.1 | Professionelle Medienpräsentation für Global Launch | Kann kurz vor Global Launch erstellt werden. |
| F056 | Social Media Teaser Kampagne | v1.1 | Vorbereitung viraler Content-Strategie | Kann parallel zum Soft Launch vorbereitet werden. |

## Streichungs-Vorschlaege (falls ueber Budget)
| Feature | Ersparnis | Risiko | Alternative |
|---|---|---|---|
| F021 Datenschutz-Compliance | 24,000 EUR (6 Wo.) | Rechtliche Sperre des Launches | Externe Beratung oder verzögerter Start |
| F023 Server-Infrastruktur | 32,000 EUR (8 Wo.) | Hohe Crash-Rate und Instabilität im Live-Betrieb | Cloud-Service mit Pay-as-you-go-Modell oder Basis-Server |
| F014 Werbeeinblendungen | 12,000 EUR (3 Wo.) | Geringere Revenue im Soft Launch | Manuelle Integration später |

## Zusammenfassung
- **Gesamt Features:** 68
- **Phase A (Soft-Launch):** 27 Features
- **Phase B (Full Production):** 36 Features
- **Backlog:** 5 Features
- **Phase A Kosten:** 176,000 EUR
- **Phase B Kosten:** 148,000 EUR
- **Kritischer Pfad:** 24 Wochen