# Feature-Priorisierung: echomatch

## Phase A — Soft-Launch MVP (45 Features)
**Budget:** 252,500 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F001 | Match-3 Core Loop | D1, D7, D30, Session-Dauer, Sessions/Tag | Indirekt (Basis für alle Revenue-Features) | 6 |  | Absolutes Core-Feature ohne das nichts funktioniert. Basis aller KPIs. Muss stabil und poliert sein bevor irgendein anderes Feature gebaut wird. |
| F002 | Implizites Spielstil-Tracking (Onboarding) | D1, D7, Session-Dauer | Indirekt (Basis für KI-Personalisierung und adaptive Monetarisierung) | 2 | F001 | KI-PoC-Pflichtbestandteil. Das 15-20 Sekunden Onboarding-Tracking ist der Dateneingangspunkt für die gesamte KI-Pipeline. Ohne diesen Input kann F003 nicht funktionieren. Niedrige Komplexität, hoher Hebel. |
| F003 | KI-basierte Level-Generierung | D1, D7, D30, Session-Dauer | Indirekt (Kernversprechen des Produkts, Retention-Treiber) | 8 | F001, F002, F018, F019 | Explizites Go/No-Go-Kriterium laut Release-Plan. KI-PoC muss in Phase A validiert werden. Hohe Komplexität durch Cloud-Backend, aber nicht verhandelbar. Latenz-Ziel <2s ist hartes technisches Kriterium. |
| F006 | Narrative Hook-Sequenz beim Start | D1, Session-Dauer | Indirekt (emotionaler Anker für Retention) | 2 | F001, F002 | 10-Sekunden-Story-Teaser nach Onboarding. Geringe Komplexität, hoher D1-Impact da erster Eindruck nach Core-Loop entscheidend für Wiederkehr. Assets lokal gebundelt, kein Backend nötig. |
| F022 | Haptic Feedback System | D1, Session-Dauer, App-Store-Rating | Indirekt (Spielqualität, Rating-Impact) | 1 | F001 | Niedriger Aufwand, messbar positiver Effekt auf wahrgenommene Spielqualität und App-Store-Rating (Ziel ≥4,2). Haptics sind heute Standard-Erwartung auf iOS/Android und beeinflussen Store-Reviews direkt. |
| F034 | App Store Rating-Prompt | App-Store-Rating | Indirekt (besseres Rating = höhere organische Conversion) | 1 | F001 | KPI-Ziel ≥4,2 Sterne ist Soft-Launch-Erfolgskriterium. Rating-Prompt nach positivem Spielerlebnis ist Standard-Best-Practice mit nachgewiesener Wirkung. Minimaler Aufwand via SDK. |
| F037 | Session-Design-Enforcement (5-10 Min.) | Session-Dauer, Sessions/Tag, D7 | Indirekt (Commuter-Nutzungskontext = höhere Daily-Engagement-Frequenz) | 2 | F001 | Direkte KPI-Anforderung: Session-Dauer 6-10 Minuten als Soft-Launch-Erfolgskriterium. Level-Pacing muss von Beginn an kalibriert sein, nachträgliches Anpassen ist teuer. Design-Entscheidung mit technischer Enforcement-Komponente. |
| F004 | Tägliche KI-Quests | D7, D30, Sessions/Tag | Indirekt (täglicher Grund zur Rückkehr, Battle-Pass-Progression) | 4 | F003, F018, F036 | Primärer D7/D30-Retention-Treiber. Tägliche neue Quests sind der Hauptgrund für Wiederkehr. Ohne dieses Feature ist D7≥20% und D30≥10% kaum erreichbar. Vereinfachte Version in Phase A akzeptabel. |
| F005 | Narrative Meta-Layer / Overarching Story | D7, D30 | Indirekt (emotionaler Anker, Battle-Pass-Werthöhe) | 4 | F004, F006, F036 | Differenzierungsmerkmal gegenüber generischen Match-3-Titeln. Emotionaler Anker für Langzeit-Retention (D30≥10%). Vereinfachte Narrative-Basis in Phase A, volle Tiefe in Phase B. Ohne Basis-Story fehlt der übergreifende Motivationsrahmen. |
| F009 | Social-Nudge nach Session | Sessions/Tag, D7 | Indirekt (erhöht Virality und organische UA) | 1 | F001, F036 | Minimaler Entwicklungsaufwand (Unity UI Overlay nach Session-Ende), schließt Social-Loop und triggert weitere Sessions. Direkter Impact auf Sessions/Tag-KPI. Voraussetzung: Basis-Nutzerprofil (F036) muss existieren. |
| F010 | Social-Sharing-Mechanismus | D1, App-Store-Rating | Indirekt (organischer UA-Kanal, senkt CPI) | 2 | F001 | Laut Release-Plan primärer organischer UA-Kanal in Phase 1. Soft-Launch-Strategie setzt explizit auf organische UA via Social-Sharing. Kein Backend nötig (native Share-API), minimale Komplexität. |
| F011 | Rewarded Ads Integration | Rewarded-Ad-eCPM | Hoch (primärer Revenue-Kanal für Free-Player, KPI: eCPM ≥$10) | 2 | F001 | Rewarded-Ad-eCPM ≥$10 ist hartes Soft-Launch-KPI. Primärer Revenue-Kanal. Standardimplementierung via Unity Ads / AdMob SDK. Muss in Phase A live sein um eCPM-Ziel zu messen und zu validieren. |
| F012 | Battle-Pass / Saison-Pass | D30 | Hoch (primärer Recurring-Revenue-Anker, $4-9/Monat) | 4 | F013, F036, F038, F039 | Zentraler Monetarisierungs-Anker. Vereinfachte Version (1 Saison, ohne vollautomatische Rotation) in Phase A ausreichend. Volle saisonale Rotation in Phase B. Ohne Battle-Pass kein messbarer Subscription-Revenue im Soft-Launch. |
| F013 | Saison-Timer-System | D30 | Mittel (erzeugt Dringlichkeit für Battle-Pass-Conversion) | 1 | F036 | Technische Abhängigkeit von F012 (Battle-Pass). Minimaler Aufwand (Firebase Remote Config + Unity Timer). Notwendig für Battle-Pass-Funktionalität, daher Phase A zusammen mit F012. |
| F015 | Convenience-IAPs | D7 | Mittel (Ergänzungsmonetarisierung für aktive Spieler) | 2 | F001, F036, F038 | Ergänzt Rewarded Ads und Battle-Pass als drittes Revenue-Standbein. Niedrige Komplexität via Unity IAP. Extra-Leben und Booster sind direkt an Core-Loop gekoppelt und fördern Session-Fortsetzung (Sessions/Tag-KPI). |
| F016 | Foot-in-the-Door IAP-Einstiegsangebot | D7 | Mittel (erhöht IAP-Conversion-Rate signifikant) | 1 | F015, F038 | Psychologisch bewiesener Conversion-Booster. Minimaler Aufwand (Angebots-Logik via Firebase Remote Config). Wichtig für Soft-Launch-Revenue-Validierung: misst ob IAP-Einstieg funktioniert. |
| F018 | KI-Personalisierungs-Engine (Spielstil-Profiling) | D1, D7, D30, Session-Dauer | Indirekt (Basis für adaptive Monetarisierung) | 5 | F002, F036 | Technisches Fundament für F003 und F004. Ohne Spielstil-Profiling können weder KI-Level noch tägliche Quests adaptiv sein. KI-PoC-Pflichtbestandteil. Firebase Analytics + Cloud Run ML-Pipeline. |
| F019 | Cloud-Backend für Level-Auslieferung | KI-Level-Latenz, D1, D7 | Indirekt (Kerninfrastruktur für KI-Differenzierung) | 5 | F018 | Hartes technisches KPI: <2s Latenz auf Mittelklasse-Hardware. Ohne funktionierenden Cloud-Backend für Level-Auslieferung kann KI-PoC nicht validiert werden. Go/No-Go-Kriterium der Closed Beta. |
| F020 | Push-Notification-System | D7, D30, Sessions/Tag | Indirekt (Re-Engagement für Battle-Pass und tägliche Quests) | 2 | F036, F041 | Direkter D7/D30-Retention-Hebel. Tägliche Quest-Notifications sind kritisch für Wiederkehr-Verhalten. Firebase Cloud Messaging ist Standard-Integration. Muss FOMO-Compliance (F041) berücksichtigen. |
| F023 | App Store Optimierung (ASO) | App-Store-Rating, D1 | Mittel (organische Sichtbarkeit = niedrigerer effektiver CPI) | 2 |  | Soft-Launch-Strategie setzt primär auf organische UA. ASO ist Voraussetzung für organischen Traffic. Kein Unity-Stack, aber kritischer Prozess vor Soft-Launch. Früh beginnen da Store-Algorithmen Zeit zum Indizieren brauchen. |
| F024 | A/B-Testing-System | D1, D7, KI-Level-Latenz | Indirekt (Optimierungswerkzeug für alle KPIs) | 2 | F025 | Pflichtbestandteil des KI-PoC: A/B-Test KI-generiert vs. manuell kuratiert ist explizites Release-Plan-Kriterium. Firebase A/B Testing ist im bestehenden Stack enthalten, minimaler Zusatzaufwand. |
| F025 | Retention-Analytics-Dashboard | D1, D7, D30, Session-Dauer, Sessions/Tag | Indirekt (datengetriebene Optimierung aller KPIs) | 2 | F036 | Ohne Analytics-Dashboard können Soft-Launch-KPIs nicht gemessen werden. D1≥40%, D7≥20%, D30≥10% sind harte Go/No-Go-Kriterien. Firebase Analytics + BigQuery ist im Stack vorhanden. |
| F026 | Server-Uptime-Monitoring | KI-Level-Latenz | Indirekt (Infrastruktur-Stabilität sichert Revenue) | 1 | F019 | Hartes KPI: ≥99,5% Uptime im Soft-Launch. Google Cloud Monitoring für Cloud Run ist Standard und minimaler Aufwand. Ohne Monitoring gibt es keine Alerts bei Ausfällen. |
| F027 | Cross-Platform-Deployment (iOS + Android simultan) | D1, D7 | Mittel (doppelter Markt von Beginn an) | 2 | F001 | Laut Release-Plan explizit: iOS + Android simultaner Soft-Launch. Unity macht es kostenneutral. Split-Test iOS vs. Android Retention von Beginn an wertvoll für Phase B Entscheidungen. |
| F028 | ATT-Consent-Flow (iOS) | D1 | Indirekt (Voraussetzung für IDFA-basiertes Tracking und personalisierte Ads) | 1 |  | LEGAL PFLICHT Phase A. Technische Voraussetzung für KI-Personalisierung auf iOS. Apple App Store Guideline Compliance. Muss vor erstem Tracking-Event angezeigt werden. Kein Launch ohne. |
| F029 | Kaltstart-Personalisierung (ohne Tracking-Daten) | D1 | Indirekt (sichert Personalisierung für bis zu 75% iOS-Nutzer ohne ATT-Consent) | 3 | F018, F028 | Bis zu 75% iOS-Nutzer verweigern ATT-Consent. Ohne Fallback degradiert die KI-Personalisierung für den Großteil der iOS-Nutzerbase. Direkt kritisch für D1-Retention-KPI. |
| F030 | TestFlight / Internal Testing Track Integration | Crash-Rate | Kein | 1 | F027 | Technische Voraussetzung für Closed Beta (Phase 0) und Soft-Launch-Vorbereitung. Standard Build-Pipeline. Ohne TestFlight/Internal Track kein strukturierter Beta-Test möglich. |
| F031 | Crash-Reporting-System | Crash-Rate | Indirekt (Stabilität sichert Rating und Retention) | 1 | F001 | Hartes KPI: Crash-Rate <2% Sessions. Firebase Crashlytics ist Standard-SDK-Integration, minimaler Aufwand. Ohne Crash-Reporting gibt es keine Datenbasis für Stabilitätssicherung. Pflicht ab erster Beta. |
| F032 | Strukturiertes Feedback-System (Beta) | D1, KI-Level-Latenz | Kein | 1 | F001, F003 | Explizites Go/No-Go-Kriterium: ≥80% positive Bewertung KI-generierter Level. Ohne strukturierten Feedback-Bogen kann dieses Kriterium nicht gemessen werden. Minimaler Aufwand (Unity UI + Firestore). |
| F036 | Nutzer-Authentifizierung / Spieler-Profil-System | D7, D30 | Indirekt (Basis für persistente Monetarisierung und Social-Features) | 2 | F028, F042, F043 | Infrastruktur-Pflicht. Ohne persistente Spielerprofile kein Battle-Pass, keine KI-Personalisierung über Sessions hinweg, kein Social-Layer. Firebase Authentication mit anonymer Auth als Einstieg ist schnell implementierbar. |
| F038 | IAP-Missbrauchsschutz / Serverseitige Validierung |  | Hoch (schützt Revenue vor Fraud) | 2 | F036 | LEGAL/SICHERHEIT PFLICHT für jeden IAP-Launch. Receipt-Fraud bei Mobile Games ist signifikant. Firebase Cloud Functions für Validierung ist Standard. Muss vor erstem IAP live sein. |
| F039 | Battle-Pass Content Visibility System |  | Mittel (Compliance-Voraussetzung für EU-Märkte) | 1 | F012 | LEGAL PFLICHT Phase A. EU-Glücksspielrechts-Compliance. Vollständige Sichtbarkeit aller Battle-Pass-Inhalte vor Kauf ist in BE/NL rechtlich verpflichtend. Minimaler Aufwand via Firebase Remote Config + Unity UI Preview. |
| F040 | Deterministisches Belohnungsdesign für Daily Quests | D7, D30 | Indirekt (Compliance sichert Zugang zu BE/NL-Märkten) | 1 | F004 | LEGAL PFLICHT Phase A. Eliminiert größtes Glücksspielrechtsrisiko in BE/NL ohne funktionalen Verlust. Serverseitige Lookup-Table statt RNG ist technisch einfacher als variantes System. Kein Grund dies zu verschieben. |
| F041 | FOMO-Mechanik Compliance Filter | Sessions/Tag | Indirekt (Compliance sichert EU-Markt-Zugang) | 2 | F020, F004 | LEGAL PFLICHT Phase A. DSA-Konformität für Push-Notifications und Daily-FOMO-Content. Rate-Limiting und Opt-out via Firebase Remote Config steuerbar. Muss vor Launch in Soft-Launch-Märkten (AU/CA/NZ) berücksichtigt werden. |
| F042 | DSGVO Consent Management System |  | Indirekt (Compliance-Voraussetzung für EU-Launch, Phase B) | 3 |  | LEGAL PFLICHT Phase A. DSGVO-Compliance ist Pflicht. AU/CA/NZ haben ähnliche Datenschutzgesetze (PIPEDA, Privacy Act AU). CMP-Implementierung (Usercentrics/OneTrust) muss vor jedem Launch integriert sein. €15.000-35.000 Bußgeldrisiko. |
| F043 | COPPA Altersverifikation und Minderjährigenschutz |  | Indirekt (Compliance sichert Store-Verfügbarkeit) | 2 | F042 | LEGAL PFLICHT Phase A. COPPA gilt in CA/AU für Nutzer unter 13. Store-Rejection-Risiko ohne Altersgate. Bedingte Deaktivierung von Tracking und Ads für Minderjährige ist Store-Guideline-Pflicht. |
| F044 | App Tracking Transparency (ATT) iOS Implementation |  | Indirekt (Voraussetzung für personalisierte Ads und KI-Tracking) | 1 | F028 | LEGAL PFLICHT Phase A. Technische Konkretisierung von F028. NSUserTrackingUsageDescription in Info.plist ist App-Store-Pflicht. App wird ohne ATT-korrekte Implementierung von Apple abgelehnt. |
| F045 | Apple Privacy Nutrition Label Datendeklaration |  | Indirekt (Store-Submission-Voraussetzung) | 1 | F042, F044 | LEGAL PFLICHT Phase A. App Store Connect Pflichtfeld seit iOS 14. Fehlende oder falsche Deklaration führt zur App-Rejection. Erfordert vollständiges SDK-Audit aller Firebase- und Ad-Module. |
| F046 | Google Play Data Safety Section Deklaration |  | Indirekt (Store-Submission-Voraussetzung) | 1 | F042 | LEGAL PFLICHT Phase A. Google Play Console Pflichtfeld. Fehlende Deklaration führt zu Store-Enforcement-Maßnahmen. Parallel zu F045 durchführbar, da gleicher SDK-Audit zugrunde liegt. |
| F047 | KI-Anbieter IP-Indemnification Vertragsmanagement |  | Indirekt (rechtliche Absicherung des KI-Core-Features) | 1 | F003 | LEGAL PFLICHT Phase A. Beeinflusst Wahl des KI-Backends für Cloud Run. Muss vor KI-PoC-Go-Entscheidung geklärt sein. Google Vertex AI ist nativ GCP-kompatibel und bietet IP-Indemnification. Organisatorischer Prozess, kein großer Entwicklungsaufwand. |
| F049 | Jugendschutz-Rating Integration (USK/PEGI/IARC) |  | Indirekt (Store-Verfügbarkeit in allen Zielmärkten) | 1 | F043 | LEGAL PFLICHT Phase A. IARC-Prozess läuft über Store-Konsolen und ist Pflicht für globale Verfügbarkeit. Feature-Gating via Firebase Remote Config für altersbasierte Segmentierung. Ohne Rating-Badge Store-Restriction möglich. |
| F051 | Markenrechts-Monitoring und Namens-Clearance |  | Indirekt (verhindert kostspieligen Rebranding vor Launch) | 1 |  | LEGAL PFLICHT Phase A. Markenrecherche für 'EchoMatch' in DE/US/EU/AU/CA/UK muss vor Soft-Launch abgeschlossen sein. €4.000-10.000 Risiko plus massiver Rebranding-Aufwand wenn nach Launch Konflikt entdeckt wird. Früh starten. |
| F035 | Minimal Paid UA Creative-Testing | D1 | Mittel (identifiziert performante Creatives für Phase B UA-Skalierung) | 2 | F027, F023 | Laut Release-Plan explizit für Phase 1 Soft-Launch vorgesehen: $2.000-5.000 für Meta/TikTok-Creative-Tests. Kein Unity-Stack. Ergebnisse sind Input für Phase B UA-Strategie und Budget-Allokation. |
| F007 | Asynchrone Friend-Challenges | D7, Sessions/Tag | Indirekt (viraler UA-Kanal, Social-Loop-Schluss) | 4 | F001, F009, F036, F050 | Basis-Social-Feature für Phase A. Asynchrones Design reduziert Komplexität gegenüber Echtzeit-Multiplayer erheblich. Direkt verknüpft mit Social-Nudge (F009) und Sharing (F010). Wichtig für D7-Retention durch Social-Obligation. |
| F050 | Social Feature Schutzpflichten System |  | Indirekt (Compliance-Voraussetzung für Social-Features) | 2 | F043 | LEGAL PFLICHT Phase A sobald Social-Features live gehen. Report/Block-Buttons und Moderations-Workflow sind Pflicht für Social-Feature-Launch. Besonderer Schutz für Minderjährige ist rechtlich verankert. €3.000-6.000 Risiko ohne. |

### Phase A Budget-Check
- Entwicklerwochen: 31
- Kosten: 124,000 EUR
- Budget: 252,500 EUR
- Status: **im_budget**

### Kritischer Pfad
- Kette: F001 -> F002 -> F003 -> F004 -> F005 -> F033 -> F008
- Gesamtdauer: 30 Wochen
- Beschreibung: Längster abhängiger Pfad über beide Phasen. F001 ist absoluter Startpunkt ohne Abhängigkeiten. F002 benötigt F001 als Dateneingangspunkt für KI-Pipeline. F003 (KI-Level-Generierung) ist Go/No-Go-Kriterium und hängt von F001, F002 sowie F018/F019 ab. F004 (Tägliche KI-Quests) als primärer D7/D30-Treiber benötigt F003 und F036. F005 (Narrative Meta-Layer) baut auf F004 und F006 auf. In Phase B führt F033 (Live-Ops-System) auf F004 auf und ist Voraussetzung für F008 (Kooperative Team-Events) als finales Glied des kritischen Pfads. Gesamtlaufzeit inklusive paralleler Entwicklung beider Phasen beträgt ca. 30 sequenzielle Wochen auf dem kritischen Pfad.

### Parallelisierbare Feature-Gruppen
- **Phase A – Sofort parallel zu F001**: F022, F034, F037 (parallel zu F001)
- **Phase A – Parallel nach F001-Fertigstellung**: F002, F006, F009 (parallel zu F003)
- **Phase A – KI-Backend-Track parallel zu UI-Features**: F003 (parallel zu F006, F009, F010, F022, F034, F037)
- **Phase A – Quest und Story parallel**: F004, F005 (parallel zu F010, F009)
- **Phase B – Revenue und Social parallel**: F014, F017 (parallel zu F033, F021)
- **Phase B – iOS und Dokumentation parallel**: F021, F048 (parallel zu F008, F033)

## Phase B — Full Production (7 Features)
**Budget:** 230,000 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F008 | Kooperative Team-Events | D30, Sessions/Tag | Mittel (erhöht Battle-Pass-Wert durch exklusive Event-Inhalte) | 6 | F007, F033, F036 | Erweiterte Social-Feature laut Priorisierungsregel Phase B. Höhere Backend-Komplexität durch Echtzeit-Progress-Aggregation. Wichtig für D30-Retention im globalen Tier-1-Launch. Live-Ops-System (F033) muss zuerst stabil sein. |
| F014 | Kosmetische IAPs | D30 | Hoch (High-Spender-Monetarisierung im Segment 25-49) | 4 | F012, F036, F038 | Wichtiger Revenue-Layer für globalen Launch, aber nicht für Soft-Launch-KPI-Validierung benötigt. Kosmetische Items brauchen polishte Art-Assets die realistische Phase B Timeline benötigen. Direkt an Battle-Pass-Saison-System gekoppelt. |
| F017 | Ad-Revenue-Optimierung für Tier-2-Märkte |  | Hoch (primäres Revenue-Modell für BR/IN/SEA, hohes Volumen) | 2 | F011 | Relevant erst für globalen Tier-1-Launch mit anschließender Tier-2-Expansion. Mediation-Setup via IronSource/MAX erfordert Tier-2-Markt-Daten die erst nach initialem Launch verfügbar sind. Soft-Launch-Märkte (AU/CA/NZ) sind Tier-1. |
| F021 | iOS Live Activities / Dynamic Island Integration | Sessions/Tag, D7 | Indirekt (premium iOS UX-Differenzierung) | 4 | F020 | Differenzierungs-Feature für Tier-1-iOS-Markt. Erfordert native Swift Bridge-Code neben Unity (€5.000-15.000 laut Budget). Nicht kritisch für Soft-Launch-KPIs, aber starkes Differenzierungsmerkmal für globalen Launch auf iPhone-Primärmarkt. |
| F033 | Live-Ops-System für Events | D30, Sessions/Tag | Hoch (ermöglicht laufenden Live-Ops-Rhythmus ohne App-Updates) | 4 | F004, F008, F036 | Vollständiges Live-Ops-System ist für dauerhaften D30-Retention und Battle-Pass-Wert kritisch. Basis-Events können in Phase A über einfache Firebase Remote Config abgebildet werden. Vollautomatisiertes Event-System für Phase B zur Skalierung. |
| F048 | Menschlicher Redaktionsanteil Dokumentation für AI-Content |  | Indirekt (stärkt urheberrechtliche Position für global skalierten Content) | 2 | F003, F047 | Wird wichtiger wenn KI-Content-Volumen mit globalem Launch skaliert. In Phase A genügt einfache Dokumentation. Vollständiges Audit-Log-System im Content-Backend für Phase B wenn mehr narrative Inhalte generiert werden. |
| F052 | Compliance-Dokumentationssystem für Reward-Mechaniken |  | Indirekt (reduziert regulatorisches Risiko in EU-Märkten) | 2 | F039, F040 | Vollständige systematische Dokumentation wird vor EU-Launch (Phase B) relevant da DE/AT/CH-Markt BE/NL-ähnliche Regulierung haben kann. In Phase A genügt informelle Dokumentation der Design-Entscheidungen. |

### Phase B Budget-Check
- Entwicklerwochen: 22
- Kosten: 88,000 EUR
- Budget: 230,000 EUR
- Status: **im_budget**

## Backlog — Post-Launch (3 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |
|---|---|---|---|---|
| F005 | Narrative Meta-Layer / Overarching Story (Vollausbau) | v1.1 | Signifikanter D30-Retention-Lift durch emotionalen Story-Anker; erhöht Battle-Pass-Wert durch narrative exklusive Inhalte | Basis-Narrative in Phase A ausreichend für Soft-Launch-KPIs. Vollständige übergreifende Story mit tiefer narrativer Progression erfordert Content-Produktion die Phase A Budget übersteigt. Vollausbau als erstes Post-Launch-Update mit höchster Priorität. |
| F014 | Kosmetische IAPs (Erweitert - Vollsortiment) | v1.1 | Signifikanter ARPU-Lift im High-Spender-Segment 25-49; erhöht Battle-Pass-Attraktivität durch breiteres Kosmetik-Portfolio | Basis-Kosmetik-IAPs in Phase B bereits enthalten. Vollständiges Sortiment (Themes, Character-Skins, Board-Designs) benötigt umfangreiche Art-Production die post-Launch realistischer ist. |
| F033 | Live-Ops-System (Vollautomatisierung) | v1.2 | Ermöglicht wöchentlichen Live-Ops-Rhythmus ohne Entwickler-Eingriff; skaliert Event-Frequenz für D30+ Retention | Basis Live-Ops via Firebase Remote Config in Phase B. Vollautomatisiertes Event-Scheduling und dynamische Event-Generierung durch KI ist komplexes System das nach erstem Daten-Feedback sinnvoller entwickelt werden kann. |

## Streichungs-Vorschlaege (falls ueber Budget)
| Feature | Ersparnis | Risiko | Alternative |
|---|---|---|---|
| F005 Narrative Meta-Layer / Overarching Story | 16,000 EUR (4 Wo.) | Schwächerer emotionaler Anker für D30-Retention. Differenzierung gegenüber generischen Match-3-Titeln reduziert. | Auf minimale Stub-Narrative in Phase A reduzieren (1 Woche), volle Tiefe in Phase B implementieren. |
| F010 Social-Sharing-Mechanismus | 8,000 EUR (2 Wo.) | Geringere organische Virality und reduzierter D1-Impact durch fehlendes Share-Feature. | Native OS Share-Sheet ohne Custom-UI als 0.5-Wochen-Lösung als Fallback. |
| F021 iOS Live Activities / Dynamic Island Integration | 16,000 EUR (4 Wo.) | Kein iOS-Differenzierungsmerkmal für Dynamic Island. Sessions/Tag und D7 leicht betroffen. | Standard Push Notifications via F020 als Ersatz. Dynamic Island in Phase C nachrüsten. |
| F048 Menschlicher Redaktionsanteil Dokumentation für AI-Content | 8,000 EUR (2 Wo.) | Schwächere urheberrechtliche Absicherung bei skaliertem KI-Content-Volumen. | Einfaches manuelles Audit-Log in Phase B, vollständiges System in Phase C vor globalem Launch. |
| F017 Ad-Revenue-Optimierung für Tier-2-Märkte | 8,000 EUR (2 Wo.) | Kein Revenue aus Tier-2-Märkten (BR/IN/SEA) im initialen Launch-Fenster. | Basis-Mediation via single SDK ohne Optimierung als 0.5-Wochen-Übergangslösung bis Phase C. |

## Zusammenfassung
- **Gesamt Features:** 55
- **Phase A (Soft-Launch):** 45 Features
- **Phase B (Full Production):** 7 Features
- **Backlog:** 3 Features
- **Phase A Kosten:** 124,000 EUR
- **Phase B Kosten:** 88,000 EUR
- **Kritischer Pfad:** 30 Wochen