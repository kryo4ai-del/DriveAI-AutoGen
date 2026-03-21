# Feature-Priorisierung: skillsense

## Phase A — Soft-Launch MVP (30 Features)
**Budget:** 252,500 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F001 | Skill Scanner – File Upload | D1, D7, Session-Dauer, Sessions-per-Day | Mittel | 2 |  | Kern-Feature des Produkts. Ohne File Upload kein Scan, kein erster Nutzerwert. Soft Launch scheitert ohne dieses Feature. |
| F002 | Skill Scanner – Sicherheits-Pattern-Check | D1, D7, Session-Dauer | Mittel | 2 | F001 | 42 Security-Pattern-Checks sind der primäre Nutzenwert des Scanners. Ohne dieses Feature gibt es kein differenzierendes Ergebnis und keine Grundlage für den Paid-Upgrade. |
| F003 | Skill Scanner – Overlap Detection (Jaccard) | D1, D7, Session-Dauer | Mittel | 2 | F001 | Zweites Kern-Analyse-Feature. Zusammen mit F002 bildet es den vollständigen Scan-Output. Beta-Erfolgskriterium (60% vollständige Scans) nicht erreichbar ohne dieses Feature. |
| F004 | Skill Score – Bewertungsanzeige | D1, D7, Session-Dauer | Mittel | 1 | F002, F003 | Visualisierung der Scan-Ergebnisse in drei Kacheln (Gut/Prüfen/Risiko). Ohne Ergebnis-Darstellung ist der Scanner wertlos. Direkt KPI-kritisch für D1-Retention. |
| F005 | Handlungsempfehlung pro Skill | D1, D7, Session-Dauer | Mittel | 1 | F004 | Konkrete Handlungsanweisung (behalten/löschen/ersetzen) ist der actionable Output. Ohne Empfehlung fehlt der Nutzerwert-Abschluss. KPI-kritisch für Retention. |
| F006 | Advisor Light – Fragebogen-Einstieg | D1, D7, Sessions-per-Day | Mittel | 2 |  | Alternativer Einstieg für Nutzer ohne Skills. Kritisch für Breite der Zielgruppe im Soft Launch und Basis für Advisor Pro (F007). Beta-Erfolgskriterium direkt abhängig. |
| F009 | Echtzeit-Feedback während Analyse (Ladeanimation) | D1, Session-Dauer | Kein | 1 | F001 | Wahrgenommene Transparenz und Vertrauen während des Scans. KPI-Scan-Performance-Kriterium (<60 Sek.) braucht visuelles Feedback. Verhindert Abbrüche während der Analyse. |
| F013 | Kein-Account-Einstieg (Zero-Friction Onboarding) | D1, Sessions-per-Day | Kein | 1 |  | Fundamentale UX-Entscheidung. Ohne Zero-Friction-Onboarding scheitert der D1-KPI (40%). Login-Gate vor erstem Nutzerwert ist im Soft Launch kontraproduktiv. |
| F012 | Landing Page – Pain-Point-Headline & CTA | D1 | Mittel | 1 |  | Ohne funktionale Landing Page kein Traffic, kein Soft Launch. Erste Kommunikationsfläche zum Nutzer. Scheitert der Launch ohne dieses Feature? Ja. |
| F021 | Wartelisten-Formular (Early Access) | D7, D30 | Mittel | 1 | F012 | Beta-Erfolgskriterium: ≥200 E-Mail-Einträge für Advisor Pro Warteliste. Direkt aus Release-Plan als Closed-Beta-KPI definiert. Muss in Phase A vorhanden sein. |
| F022 | Einladungsbasierter Beta-Zugang | D1 | Kein | 1 |  | Phase 1 ist explizit Closed Beta mit 150–300 handverlesenen Nutzern. Invite-Code-System ist technische Voraussetzung für kontrollierten Soft Launch. |
| F023 | Feedback-Formular (Qualitatives Nutzer-Feedback) | D7 | Kein | 1 | F004 | Beta-Erfolgskriterium: ≥40 ausgefüllte Feedback-Formulare. Ohne dieses Feature kann der Soft Launch nicht validiert werden. Direkte Abhängigkeit im Release-Plan. |
| F014 | 100% Client-Side Verarbeitung (Privacy by Design) | D1, D7 | Kein | 2 | F001 | Kritisches Datenschutz-USP und Beta-Erfolgskriterium (0 Datenschutzvorfälle). Ohne diese Architektur-Entscheidung ist das Datenschutzversprechen nicht haltbar. |
| F036 | Datenschutz-Nachweis / Client-Side-Verifikation | D1 | Kein | 1 | F014 | Beta-Erfolgskriterium explizit: 0 kritische Datenschutzvorfälle. Technische Verifikation und öffentliches Versprechen sind Pflicht vor jedem Launch. |
| F045 | DSGVO-Compliance: Datenschutzerklärung & Transparenz-Dokumentation |  | Kein | 1 |  | Legal-Pflicht. Kein Launch ohne vollständige Datenschutzerklärung. DSGVO-Verstoß würde den gesamten Soft Launch gefährden. Immer Phase A per Priorisierungsregel. |
| F046 | Consent Management Platform (CMP) / Cookie-Consent |  | Kein | 1 | F045 | Legal-Pflicht für DSGVO-Konformität. Ohne CMP dürfen Third-Party-Dienste (Analytics, Auth) nicht initialisiert werden. Kein Launch ohne dieses Feature. |
| F047 | Auftragsverarbeitungsverträge (AVV) Management |  | Kein | 1 | F045 | Organisatorische Legal-Pflicht. Ohne AVV mit Google/Firebase, Stripe, Anthropic ist der Betrieb DSGVO-widrig. Muss vor Soft Launch abgeschlossen sein. |
| F049 | Haftungs-Disclaimer für Sicherheitsempfehlungen |  | Kein | 1 | F004, F005 | Legal-Pflicht. Sicherheitsempfehlungen ohne Disclaimer erzeugen Haftungsrisiko ab dem ersten Nutzer. Muss bei Scan-Output immer sichtbar sein. |
| F025 | Responsive Design (Mobile Web) | D1, Sessions-per-Day | Kein | 1 | F012 | Ohne Mobile-Responsiveness verliert der Soft Launch einen signifikanten Anteil der Zielgruppe. D1-KPI (40%) nicht erreichbar wenn mobile Nutzer schlechte Experience haben. |
| F026 | Performance-Optimierung (Core Web Vitals) | D1 | Kein | 1 | F012 | Explizites Soft-Launch-Erfolgskriterium: LCP <2,5 Sek., CLS <0,1. Ohne Performance-Baseline sind SEO und Nutzererfahrung gefährdet. |
| F027 | Scan-Performance-Garantie (< 60 Sekunden) | D1, Session-Dauer | Kein | 1 | F002, F003 | Explizites Beta-Erfolgskriterium: 95% aller Scans unter 60 Sekunden. Technische Pflicht vor Beta-Start. |
| F037 | Conversion-Tracking & Analytics | D1, D7, D30 | Mittel | 1 | F046 | Ohne Analytics können keine KPIs gemessen werden. Basis-Analytics (Firebase/Plausible) ist Pflicht um Soft-Launch-Erfolgskriterien überhaupt validieren zu können. |
| F032 | SEO-Grundlage / Content-Strategie | D1 | Mittel | 1 | F012 | Explizites Soft-Launch-Ziel: SEO-Grundlage legen. Technische SEO (Meta-Tags, SSG) muss beim Launch-Tag vorhanden sein. Einfach umsetzbar via Next.js. |
| F035 | Mehrsprachigkeit / Lokalisierung (DE + EN) | D1 | Mittel | 2 | F012 | Soft-Launch-Ziel ist DACH (DE) mit englischer UI-Basis. Englische UI ist laut Release-Plan bereits in Phase 1 vorhanden. Grundstruktur muss in Phase A gelegt werden. |
| F044 | Lizenzstrategie & Quellenmanagement für Skill-Datenbank |  | Kein | 1 |  | Legal-Pflicht vor Launch der kuratierten Datenbank. Ohne Lizenzklärung der Skill-Quellen besteht Urheberrechtsrisiko ab Tag 1. MVP-Basisdatensatz (30–50 Skills) muss rechtlich sauber sein. |
| F048 | Anthropic ToS Compliance Monitoring |  | Kein | 1 | F007 | Legal-Pflicht. Kommerzielle Claude-API-Nutzung ohne ToS-Konformität gefährdet den API-Zugang. Muss vor Advisor Pro Beta-Start sichergestellt sein. |
| F043 | KI-Content-Kennzeichnung (EU AI Act Art. 50) |  | Kein | 1 | F007 | Legal-Pflicht ab August 2025. Da Soft Launch in diesen Zeitraum fällt, ist die Kennzeichnung KI-generierter Outputs Pflicht. Einfache UI-Annotation, kein großer Aufwand. |
| F030 | Advisor Pro – Closed Beta innerhalb Soft Launch | D7, D30 | Hoch | 1 | F007, F022 | Explizites Release-Plan-Feature für Phase 2. Advisor Pro Closed Beta ist Kernziel des Soft Launch. Feature-Flag-Mechanismus muss in Phase A vorhanden sein. |
| F007 | Advisor Pro – KI-gestützte Skill-Generierung | D7, D30, Session-Dauer | Hoch | 3 | F006, F028 | KI-PoC ist explizites Go/No-Go Kriterium per Priorisierungsregel. Advisor Pro ist das primäre Pro-Feature und Hauptmotivation für Subscription. Beta-NPS-Ziel (≥35) hängt daran. |
| F031 | Net Promoter Score (NPS) Abfrage | D7 | Kein | 1 | F007, F030 | Explizites Soft-Launch-Erfolgskriterium: NPS ≥35 für Advisor Pro Beta. Ohne NPS-Messung kann dieses Kriterium nicht validiert werden. |

### Phase A Budget-Check
- Entwicklerwochen: 18
- Kosten: 72,000 EUR
- Budget: 252,500 EUR
- Status: **im_budget**

### Kritischer Pfad
- Kette: 
- Gesamtdauer: ? Wochen
- Beschreibung: 

### Parallelisierbare Feature-Gruppen
- **Phase A – Tag-1-Parallel-Start (Keine Abhaengigkeiten)**: F012, F013, F006, F022 (parallel zu F001)
- **Phase A – F001-Abhaengige Parallelgruppe**: F002, F003, F014, F009 (parallel zu )
- **Phase A – F004-Abhaengige Parallelgruppe**: F023, F021 (parallel zu )
- **Phase B – Infrastruktur-First-Parallelgruppe**: F008, F015, F017, F018, F019 (parallel zu F010)
- **Phase B – Datenbank-Abhaengige Gruppe**: F011, F016 (parallel zu )

## Phase B — Full Production (18 Features)
**Budget:** 230,000 EUR

| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F010 | Kuratierte Skill-Datenbank – Browse & Install | D7, D30, Session-Dauer | Hoch | 3 | F044, F004 | Wichtiges Differenzierungs-Feature für den Global Launch, aber nicht zwingend für den DACH Soft Launch. Soft Launch validiert Core Loop (Scan + Advisor). Datenbank-Browse differenziert Phase B. |
| F011 | Skill-Fit-Check – Persönliche Relevanz-Bewertung | D7, D30 | Mittel | 2 | F010, F006 | Wertvolles Feature zur Differenzierung von popularitätsbasierten Marktplätzen, aber abhängig von F010 (Datenbank). Erst sinnvoll wenn Datenbank vorhanden ist. |
| F015 | Tiefenanalyse-Report (Deep Scan) – IAP | D7, D30 | Hoch | 2 | F020, F029, F002 | IAP-Bridge (1,99€) ist Soft-Launch-Erfolgskriterium (30 Nutzer), aber die volle Stripe-Integration und das vollständige IAP-System werden für den Global Launch skaliert. Phase A kann mit vereinfachtem Proof testen. |
| F016 | Premium Skill Bundle – IAP | D30 | Hoch | 2 | F020, F010, F029 | Setzt kuratierte Datenbank (F010) voraus. Da F010 in Phase B liegt, muss auch dieses IAP in Phase B landen. Differenziert Revenue-Mix für Global Launch. |
| F017 | Chat Export Analysis Token – IAP | D7, D30 | Mittel | 2 | F020, F008, F029 | Einmalkauf für Chat-Analyse. Chat-Export (F008) ist Phase A, aber der vollständige IAP-Token-Mechanismus mit Stripe skaliert besser in Phase B mit der restlichen Monetarisierungs-Infrastruktur. |
| F008 | Chat-Export-Analyse | D7, D30 | Mittel | 2 | F001, F014 | Interessantes Feature für D30-Retention (Rückkehr-Trigger nach 4 Wochen), aber nicht notwendig für den Soft-Launch-Core-Loop. Phase B differenziert mit diesem Feature den Global Launch. |
| F018 | Pro Subscription – Monatsabo (9,99 €/Monat) | D30 | Hoch | 2 | F020, F028, F029 | Vollständige Subscription-Infrastruktur ist für den skalierten Global Launch notwendig. Soft Launch validiert Zahlungsbereitschaft via IAP-Bridge; Subscription wird in Phase B ausgebaut. |
| F019 | Pro Subscription – Jahresabo (79 €/Jahr) | D30 | Hoch | 1 | F018, F038 | Jahresabo setzt Monatsabo (F018) voraus. Jahresabo-Conversion (≥20-35%) ist Soft-Launch-Erfolgskriterium für Phase 2. Wird zusammen mit F018 in Phase B skaliert. |
| F020 | Stripe-Zahlungsintegration | D30 | Hoch | 3 | F028 | Vollständige Stripe-Integration mit Webhooks und Error-Handling ist für Phase B (scharfgeschalteter Conversion-Funnel) nötig. Phase A validiert mit vereinfachtem IAP-Proof, Phase B baut die vollständige Infrastruktur. |
| F028 | Nutzerregistrierung & Account-Management (Pro-Tier) | D7, D30 | Hoch | 2 |  | Account-System für zahlende Pro-Nutzer ist Voraussetzung für Subscription. Free-Tier bleibt account-frei (Phase A). Phase B schaltet den vollständigen Paid-Funnel scharf. |
| F029 | Feature-Differenzierung Free vs. Pro | D7, D30 | Hoch | 2 | F028, F041, F042 | Vollständige Free/Pro-Trennung mit Upgrade-Prompts setzt Account-System (F028) und Tier-Management (F041, F042) voraus. Für Phase B wenn Payment-Infrastruktur steht. |
| F038 | Pricing Page mit Monats-/Jahres-Toggle | D30 | Hoch | 1 | F018, F019 | Pricing Page setzt die vollständige Subscription-Infrastruktur voraus. Wird zusammen mit F018/F019 in Phase B deployed. |
| F040 | Upgrade-Prompts / Paywall-Trigger im Produkt | D7, D30 | Hoch | 1 | F029, F038 | Kontextsensitive Upgrade-Prompts setzen vollständige Free/Pro-Differenzierung voraus. Wichtig für Global Launch Conversion-Optimierung. |
| F041 | SaaS Subscription Management (Free/Pro/Enterprise) | D30 | Hoch | 2 | F028, F020 | Technisches Subscription-Management mit Firebase Custom Claims. Voraussetzung für Feature-Gating. Phase B wenn Payment-Infrastruktur vollständig steht. |
| F042 | Funktionslimitierung nach Tier (Feature Gating) | D7, D30 | Hoch | 2 | F041, F028 | Serverseitige Tier-Validierung setzt Subscription-Management (F041) voraus. Kritisch für korrekte Monetarisierung aber erst nach vollständiger Payment-Infrastruktur sinnvoll. |
| F039 | EU-Rollout / Internationaler Markt (Phase 2+) | D30 | Hoch | 2 | F020, F035 | Explizit für Phase 3 (Global Launch) vorgesehen. Stripe Tax für EU + US + AU ist technische Voraussetzung für internationalen Zahlungsverkehr. Phase B legt die Basis. |
| F024 | Rückkehr-Trigger / Re-Engagement nach 4 Wochen | D30 | Mittel | 2 | F028, F037 | D30-Retention-KPI (10%) wird durch Re-Engagement gefördert. Setzt Account-System (F028) und Analytics (F037) voraus. Phase B wenn Nutzerbasis groß genug ist um E-Mail-Trigger zu rechtfertigen. |
| F034 | Product Hunt Launch | D1 | Hoch | 2 | F012, F032 | Explizit für Phase 3 (Full Launch) vorgesehen. Marketing-Aktion die Demo-Video und vollständige Feature-Reife voraussetzt. Phase B bereitet Assets vor. |

### Phase B Budget-Check
- Entwicklerwochen: 17
- Kosten: 68,000 EUR
- Budget: 230,000 EUR
- Status: **im_budget**

## Backlog — Post-Launch (5 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |
|---|---|---|---|---|
| F033 | Team-Tier / Enterprise-Pfad | v1.2 | Erschließt B2B-Segment und erhöht LTV signifikant. Multi-Seat-Verwaltung für Consultants und PMs. | Explizit für Phase 3 vorgesehen. Komplexe Billing-Infrastruktur (multi-seat) und Sales-Prozess setzen validiertes B2C-Modell voraus. Kein MVP-Scope. |
| F050 | Markenrechts-Prüfung & Namensschutz-Dokumentation | v1.1 | Rechtssicherheit für Markenname SkillSense in DACH. Grundlage für eventuelle Markenanmeldung. | Organisatorische Maßnahme die parallel zu Phase A läuft, aber keinen technischen Deploy-Block darstellt. Kein nativer App Store Scope in Phase A/B. |
| F051 | Patent-Freihalteraum-Analyse für Kerntechnologien | v1.1 | Rechtssicherheit für Jaccard-Algorithmus und Security-Pattern-Matching. | Organisatorische Maßnahme. Jaccard und Pattern-Matching sind etablierte Algorithmen mit bekanntem Patentstand. Tiefere Analyse kann nach Soft Launch mit konkreten Implementierungsdetails erfolgen. |
| F052 | iOS Native App Privacy Nutrition Label Readiness | v2.0 | Vorbereitung für native iOS App. Erschließt App Store Distribution. | Explizit für Phase 3+ vorgesehen. Kein nativer App-Code in Phase A/B. Web-App ist die Deployment-Plattform. Wird relevant wenn React Native oder Swift-Entwicklung beginnt. |
| F053 | Reddit Community Marketing (organisch) | v1.1 | Organischer Entdeckungskanal. Primärer Traffic-Treiber für Soft Launch und darüber hinaus. | Marketing-Aktivität ohne technische Feature-Abhängigkeit. Läuft parallel zu Phase A als Eigenleistung, braucht aber kein eigenes Feature-Slot im Priorisierungs-Framework. |

## Streichungs-Vorschlaege (falls ueber Budget)
| Feature | Ersparnis | Risiko | Alternative |
|---|---|---|---|
| F003 Skill Scanner – Overlap Detection (Jaccard) | 8,000 EUR (2 Wo.) | Scan-Output ist weniger vollstaendig. Beta-Erfolgskriterium '60% vollstaendige Scans' schwerer erreichbar. | MVP-Stub: Jaccard-Score als Platzhalter mit statischem Wert einbauen, vollstaendige Berechnung in Phase B nachliefern. |
| F009 Echtzeit-Feedback waehrend Analyse (Ladeanimation) | 4,000 EUR (1 Wo.) | Erhoehte Abbruchrate waehrend Scan. Nutzer koennen unsicher werden ob Verarbeitung laeuft. | Einfacher statischer Ladeindikator (CSS Spinner) ohne animierten Fortschritts-Feedback, ca. 0.25 Wochen Aufwand. |
| F022 Einladungsbasierter Beta-Zugang | 4,000 EUR (1 Wo.) | Kein kontrollierbarer Zugang zur Closed Beta. Risiko unkontrollierten Wachstums oder Missbrauch. | Manuelles Whitelisting per E-Mail-Liste statt Invite-Code-System. Funktioniert bei 150-300 Nutzern operativ, skaliert aber nicht. |
| F021 Wartelisten-Formular (Early Access) | 4,000 EUR (1 Wo.) | Beta-KPI '200 E-Mail-Eintraege' nicht messbar. Kein strukturierter Kanal fuer Advisor Pro Pre-Launch. | Externes Tool (z.B. Tally.so oder Google Forms) als temporaerer Ersatz. Kein Custom-Development noetig, Daten muessen manuell exportiert werden. |
| F017 Chat Export Analysis Token – IAP | 8,000 EUR (2 Wo.) | Mittlere Revenue-Impact-Reduktion in Phase B. D7/D30 Retention-Trigger faellt weg. | Chat-Export-Analyse (F008) bleibt als Free-Feature ohne Token-Gate bis Phase C, wenn Subscription-Infrastruktur vollstaendig ist. |
| F011 Skill-Fit-Check – Persoenliche Relevanz-Bewertung | 8,000 EUR (2 Wo.) | Differenzierungs-Feature gegenueber popularitaetsbasierten Marktplaetzen fehlt in Phase B. | Einfaches Relevanz-Rating (Daumen hoch/runter) ohne algorithmischen Fit-Score als Zwischenloesung in Phase B. |

## Zusammenfassung
- **Gesamt Features:** 53
- **Phase A (Soft-Launch):** 30 Features
- **Phase B (Full Production):** 18 Features
- **Backlog:** 5 Features
- **Phase A Kosten:** 72,000 EUR
- **Phase B Kosten:** 68,000 EUR
- **Kritischer Pfad:** ? Wochen