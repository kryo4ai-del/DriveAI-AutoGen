# Feature-Priorisierung: echomatch

## Phase A — Soft-Launch MVP (36 Features)
**Budget:** 252,500 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F001 | Match-3 Core Loop | D1, D7, Session-Dauer, Sessions_pro_Tag | Kein | 6 |  | Absolutes Core-Feature ohne das kein Spiel möglich ist. Muss stabil laufen für alle KPIs. |
| F002 | KI-basierte Level-Generierung | D1, D7, Session-Dauer, ki_level_latency_sec | Indirekt (Retention) | 8 | F001 | Kritischer USP und Go/No-Go für Soft Launch. Latency muss unter 2s bleiben. |
| F016 | Onboarding-Match-3 | D1, Onboarding-Completion-Rate | Kein | 2 | F001 | Kurzes Onboarding ist essenziell für erste Nutzererfahrung und Retention. |
| F017 | Kamera-Scan-Integration | D1, Scan-Latenz, Onboarding-Completion-Rate | Indirekt (Nutzerbindung) | 4 |  | Kritischer First-Impression-Moment. Scan-Latenz <3s ist Go/No-Go-Kriterium. |
| F018 | Pflanzenpflege-Tracking | D1, D7, Sessions_pro_Tag | Indirekt (Retention) | 3 | F017 | Zentral für das Gameplay-Konzept. Erinnerungen erhöhen Session-Frequenz. |
| F034 | Belohnungs-System | D1, D7, Retention, Monetarisierung | Hoch | 4 | F001 | Grundlage für alle Monetarisierungs- und Retention-Mechanismen. |
| F004 | Tägliche KI-Quests | D1, D7, Session-Dauer, Sessions_pro_Tag | Indirekt (Retention) | 5 | F002, F034 | Persönliche Quests sind zentral für Nutzerbindung und KI-PoC. |
| F005 | Narrative Story-Layer | D1, D7, Session-Dauer | Indirekt (Retention) | 3 | F004 | Grundlegende Story-Elemente für Quests und Nutzerbindung. |
| F006 | Story-Teaser-Sequenz | D1, Session-Dauer | Kein | 1 | F005 | Kurze Hooks für bessere Nutzerbindung in Sessions. |
| F007 | Social Challenge-Layer (Basis) | D7, D30, Sessions_pro_Tag | Indirekt (Retention) | 4 | F034 | Einfache Challenges für Nutzerbindung und organische Viralität. |
| F008 | Friend-Challenges | D7, D30, Sessions_pro_Tag | Indirekt (Retention) | 3 | F007 | Direkte Herausforderungen für erhöhte Session-Frequenz. |
| F011 | Rewarded Ads | rewarded_ad_ecpm, Monetarisierung | Hoch | 2 | F034 | Primäre Monetarisierungsquelle für Soft Launch. Muss stabil laufen. |
| F012 | Battle-Pass-System (Basis) | D7, D30, Monetarisierung, Jahres-Abo-Anteil | Hoch | 5 | F034 | Kritisch für Monetarisierung und Retention. Volle saisonale Rotation erst Phase B. |
| F013 | Kosmetische IAPs | Monetarisierung | Hoch | 3 | F034 | Wichtige Monetarisierungsquelle ohne Pay-to-Win-Risiko. |
| F015 | Push-Notification-System | D7, D30, Retention, Push-Notification-Opt-in-Rate | Indirekt (Retention) | 2 |  | Essenziell für Retention und Nutzerbindung. Muss DSGVO-konform sein. |
| F019 | OpenWeatherMap-Integration | D7, D30, Retention | Indirekt (Nutzerbindung) | 2 | F018 | Differenzierendes Feature für Pflanzenpflege und Nutzerbindung. |
| F020 | Crashlytics-Integration | crash_rate | Kein | 1 |  | Pflicht für stabile Nutzererfahrung und Go/No-Go-Kriterium. |
| F021 | Analytics-System (Firebase) | D1, D7, D30, Retention, LTV/CAC-Ratio | Indirekt (Datengetriebene Entscheidungen) | 2 |  | Grundlage für alle KPI-Messungen und Optimierungen. |
| F022 | ASO-Optimierung | app_store_rating, Organische Downloads | Hoch | 3 |  | Kritisch für Sichtbarkeit und Conversion im App Store. |
| F026 | Push-Notification-Opt-in-Rate-Tracking | Push-Notification-Opt-in-Rate, D7, D30 | Indirekt (Retention) | 1 | F015 | Muss gemessen werden für Retention-Optimierung. |
| F027 | Scan-Latenz-Optimierung | ki_level_latency_sec, Scan-Latenz | Kein | 3 | F017 | Go/No-Go-Kriterium für Soft Launch. Muss unter 2s bleiben. |
| F028 | Retention-Metriken | D7, D30, Retention | Indirekt (Datengetriebene Entscheidungen) | 1 | F021 | Pflicht für alle Retention-Messungen. |
| F029 | LTV/CAC-Ratio-Tracking | LTV/CAC-Ratio | Hoch | 2 | F021 | Kritisch für Unit-Economics und UA-Skalierung. |
| F030 | App Store Rating-System | app_store_rating | Hoch | 1 |  | Wichtig für ASO und Conversion. |
| F041 | Monetarisierungsmodell ohne Glücksspiel-Trigger |  | Hoch | 1 |  | Rechtliche Pflicht für App Store Compliance. |
| F042 | DSGVO-Compliance für Nutzerdaten |  | Hoch | 3 | F021 | Rechtliche Pflicht für EU-Release. Muss vor Soft Launch umgesetzt sein. |
| F043 | COPPA-Compliance für Minderjährige |  | Hoch | 2 | F042 | Rechtliche Pflicht für US-Release. Muss vor Soft Launch umgesetzt sein. |
| F044 | Jugendschutzfilter (USK/PEGI/IARC) |  | Hoch | 1 |  | Rechtliche Pflicht für App Store Compliance. |
| F045 | Social Features Schutzpflichten |  | Hoch | 2 | F007 | Rechtliche Pflicht für Social Features. Muss vor Soft Launch umgesetzt sein. |
| F048 | App Store Richtlinien-Konformität (Apple/Google) |  | Hoch | 1 |  | Rechtliche Pflicht für App Store Compliance. |
| F049 | AI-Inhaltsgenerierung mit Urheberrechtsprüfung |  | Hoch | 1 | F002 | Rechtliche Pflicht für KI-generierte Inhalte. |
| F051 | App Tracking Transparency (ATT) für iOS | Tracking-Einwilligungen | Hoch | 1 | F021 | Rechtliche Pflicht für iOS-Tracking. Muss vor Soft Launch umgesetzt sein. |
| F053 | KI-generierte Quests mit deterministischer Belohnung |  | Indirekt (Compliance) | 1 | F004 | Rechtliche Pflicht zur Vermeidung von Glücksspiel-Risiken. |
| F054 | Battle-Pass mit transparenten Inhalten |  | Hoch | 1 | F012 | Rechtliche Pflicht für Battle-Pass-Systeme. |
| F055 | Rewarded Ads mit Compliance-Prüfung |  | Hoch | 1 | F011 | Rechtliche Pflicht für Rewarded Ads. |
| F063 | Altersverifikation für COPPA-konforme Nutzer |  | Hoch | 2 | F043 | Rechtliche Pflicht für US-Release. |

### Phase A Budget-Check
- Entwicklerwochen: 38
- Kosten: 152,000 EUR
- Budget: 252,500 EUR
- Status: **im_budget**
- Ueber Budget um: 100,500 EUR

### Kritischer Pfad
- Kette: F001 -> F002 -> F004 -> F005 -> F006
- Gesamtdauer: 23 Wochen
- Beschreibung: Längster sequenzieller Pfad ohne Parallelisierung. Muss für Soft Launch stabil laufen.

### Parallelisierbare Feature-Gruppen
- **Onboarding & First Impressions**: F016, F017 (parallel zu F001)
- **Monetarisierung & Retention Basis**: F011, F012, F013, F015 (parallel zu F034)
- **Pflanzenpflege & KI-Integration**: F018, F019 (parallel zu F017, F002)
- **Social Features Basis**: F007, F008 (parallel zu F034)

## Phase B — Full Production (15 Features)
**Budget:** 230,000 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F003 | Spielstil-Tracking | D7, D30, Retention | Indirekt (Personalisierung) | 3 | F002 | Erweitert KI-PoC für bessere Personalisierung, aber nicht kritisch für Soft Launch. |
| F009 | Kooperative Team-Events | D30, Sessions_pro_Tag | Indirekt (Retention) | 6 | F007 | Erweitert Social Features, aber Basis-Challenges reichen für Soft Launch. |
| F010 | Social-Nudge-System | D7, D30, Sessions_pro_Tag | Indirekt (Retention) | 2 | F007 | Erweitert Social Features, aber Basis-Challenges reichen für Soft Launch. |
| F014 | Convenience-IAPs | Monetarisierung | Hoch | 2 | F034 | Erweitert Monetarisierung, aber Basis-IAPs reichen für Soft Launch. |
| F024 | Saison-Timer-System | D30, Monetarisierung | Hoch | 3 | F012 | Erweitert Battle-Pass, aber Basis-System reicht für Soft Launch. |
| F025 | Familienfreigabe-Unterstützung | Monetarisierung | Mittel | 2 | F012 | Erweitert Monetarisierung, aber nicht kritisch für Soft Launch. |
| F031 | KI-generierte Dialoge | D7, Session-Dauer | Indirekt (Retention) | 4 | F005 | Erweitert Story-Layer, aber Basis-Quest-System reicht für Soft Launch. |
| F032 | Team-Event-Logik | D30, Sessions_pro_Tag | Indirekt (Retention) | 5 | F009 | Erweitert Team-Events, aber Basis-Challenges reichen für Soft Launch. |
| F033 | Challenge-Matchmaking | D7, D30, Sessions_pro_Tag | Indirekt (Retention) | 4 | F008 | Erweitert Social Features, aber Basis-Challenges reichen für Soft Launch. |
| F035 | KI-basierte Quest-Empfehlungen | D7, D30, Session-Dauer | Indirekt (Retention) | 3 | F004 | Erweitert Quest-System, aber Basis-Quests reichen für Soft Launch. |
| F036 | Push-Notification-Personalisierung | D7, D30, Retention | Indirekt (Retention) | 3 | F015 | Erweitert Push-Notifications, aber Basis-System reicht für Soft Launch. |
| F037 | Cloud-basierte KI-Inferenz | ki_level_latency_sec | Indirekt (Performance) | 5 | F002 | Optimiert KI-Performance, aber lokale KI reicht für Soft Launch. |
| F038 | Nutzerprofil-System | D7, D30, Retention | Indirekt (Datenmanagement) | 3 | F034 | Erweitert Nutzerdaten-Management, aber Basis-System reicht für Soft Launch. |
| F039 | Soziale Sharing-Funktionen | Organische Downloads | Indirekt (Wachstum) | 2 | F008 | Erweitert Social Features, aber nicht kritisch für Soft Launch. |
| F040 | A/B-Testing-System | D7, D30, Retention | Hoch | 4 | F021 | Wichtig für Optimierung, aber Firebase Remote Config reicht für Soft Launch. |

### Phase B Budget-Check
- Entwicklerwochen: 32
- Kosten: 128,000 EUR
- Budget: 230,000 EUR
- Status: **im_budget**
- Ueber Budget um: 102,000 EUR

## Backlog — Post-Launch (14 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |
|---|---|---|---|---|
| F023 | UA-Kanal-Tests | v1.2 | Skalierbare Nutzerakquise | Erst sinnvoll nach Retention-Validierung in Phase A. |
| F046 | Markenrechtliche Namensprüfung | v1.1 | Rechtliche Absicherung | Externe Recherche erforderlich, kein technisches Feature. |
| F047 | Patentrecherche für KI-Mechanismen | v1.1 | Rechtliche Absicherung | Externe Recherche erforderlich, kein technisches Feature. |
| F050 | DSGVO-konformes Consent-Management | v1.1 | DSGVO-Compliance | Wird durch F042 abgedeckt, aber Consent-Management-System kann in v1.1 optimiert werden. |
| F052 | Push-Notification-Opt-in für Minderjährige | v1.1 | COPPA/DSGVO-Compliance | Wird durch F043 und F063 abgedeckt. |
| F056 | TikTok-Integration für organisches Wachstum | v1.2 | Organische Reichweite | Erst sinnvoll nach Retention-Validierung in Phase A. |
| F057 | Instagram Reels & Stories für organische Reichweite | v1.2 | Organische Reichweite | Erst sinnvoll nach Retention-Validierung in Phase A. |
| F058 | Apple Search Ads für hochkonvertierende Nutzer | v1.2 | Bezahlte Nutzerakquise | Erst sinnvoll nach Retention-Validierung in Phase A. |
| F059 | Meta Ads für skalierbare Nutzerakquise | v1.2 | Bezahlte Nutzerakquise | Erst sinnvoll nach Retention-Validierung in Phase A. |
| F060 | Influencer-Marketing mit Micro-Influencern | v1.2 | Organische Reichweite | Erst sinnvoll nach Retention-Validierung in Phase A. |
| F061 | Landing Page für Pre-Launch und SEO | v1.1 | Organische Reichweite | Kann nach Soft Launch weiter optimiert werden. |
| F062 | Community-Management für organisches Wachstum | v1.2 | Organische Reichweite | Erst sinnvoll nach Retention-Validierung in Phase A. |
| F050 | DSGVO-konformes Consent-Management | v1.1 | DSGVO-Compliance | Wird durch F042 abgedeckt, aber Consent-Management-System kann in v1.1 optimiert werden. |
| F064 | Automatisierte Moderation für Social Features | v1.2 | Sicherheit und Compliance | Erst sinnvoll nach Social Features-Erweiterung in Phase B. |

## Zusammenfassung
- **Gesamt Features:** 65
- **Phase A (Soft-Launch):** 36 Features
- **Phase B (Full Production):** 15 Features
- **Backlog:** 14 Features
- **Phase A Kosten:** 152,000 EUR
- **Phase B Kosten:** 128,000 EUR
- **Kritischer Pfad:** 23 Wochen