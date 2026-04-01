# Release-Plan-Report: GrowMeldAI

---

## Release-Phasen

### Phase 1: Closed Beta (iOS Only)

- **Ziel:** Technische Stabilität validieren, Core Loop auf Alltagstauglichkeit testen, erste qualitative Nutzerfeedback-Daten zu Onboarding und Push-Notification-Einwilligung erheben. Kritisch: Scan-Latenz <3 Sekunden unter realen Bedingungen bestätigen.
- **Dauer:** 6 Wochen
- **Teilnehmer:** 200–500 Tester, rekrutiert über TestFlight-Einladungen; Kanäle: #planttok/Instagram-Pflanzencommunity (organisch), bestehende Newsletter-Interessenten, gezielte Reddit-Outreach (r/houseplants, r/plantclinic). Kein Paid Recruitment.
- **Technische Voraussetzungen:** TestFlight-Build stabil, Plant.id API-Integration funktionsfähig, OpenWeatherMap-Integration aktiv, Firebase Push Notifications (APNs) eingerichtet, Basis-Analytics (Mixpanel oder Amplitude) aktiv, Crashlytics aktiv.
- **Erfolgskriterien:**

| Kriterium | Zielwert |
|---|---|
| Scan-Latenz (Kamera → KI-Ergebnis) | <3 Sekunden bei 90% der Scans |
| Crash-Free Session Rate | >98% |
| Push-Notification Opt-in Rate | >55% (gemessen nach erstem Pflegeplan-Moment) |
| D7-Retention (aktive Rückkehrer) | >30% |
| Onboarding-Completion-Rate (Scan → erstes Profil erstellt) | >70% |
| Qualitatives Feedback-Signal | Mind. 80% positives Sentiment zu Diagnose-Qualität in Tester-Umfrage |

> ⚠️ **Kritischer Gating-Check:** Wenn Scan-Latenz oder Crash-Free Rate die Zielwerte nicht erreichen, wird Phase 2 nicht gestartet. Technische Qualität des First-Impression-Moments ist nicht verhandelbar.

---

### Phase 2: Soft Launch (iOS, ausgewählte Regionen)

- **Ziel:** Monetarisierungsmodell validieren (Free→Paid-Conversion, Jahres-vs.-Monats-Abo-Split), Churn D7/D30 messen, LTV-Erstschätzung für Unit-Economics-Bewertung erstellen, UA-Kanal-Tests mit kleinem Budget durchführen (€3.000–€8.000 gesamt), ASO-Optimierung iterieren.
- **Dauer:** 8–10 Wochen
- **Region(en):** **Australien** (primär) + **Kanada** (sekundär)
  - Australien: etablierter Soft-Launch-Benchmark-Markt (Lancaric Soft Launch Bible 2025); englischsprachig; iOS-affin; kulturell ähnlich zu DACH-Kaufverhalten ohne direkte Wettbewerbs-Überexposition
  - Kanada: ebenfalls iOS-stark, englischsprachig, gute App-Store-Ranking-Daten für Extrapolation auf US/UK
  - Beide Märkte ermöglichen echte Abo-Conversion-Daten bei vergleichsweise niedrigem UA-Risiko
- **Erfolgskriterien:**

| Kriterium | Zielwert | Begründung |
|---|---|---|
| Free→Paid Conversion Rate | >3,5% | Unterkante Kategorie-Benchmark (3–7%); unter diesem Wert Paywall-Placement und Free-Tier-Balance überprüfen |
| Jahres-Abo-Anteil am Paid-Mix | >55% | Jahres-Abo ist primäres Revenue- und Retention-Ziel |
| D7-Retention | >28% | Orientiert an Greg/Planta-Kategorie-Benchmark; unter 20% = strukturelles Retention-Problem |
| D30-Retention | >15% | Mindestanforderung für positives LTV-Signal |
| LTV/CAC-Ratio (organisch) | >3:1 | Mindestanforderung vor paid UA-Skalierung |
| App Store Rating | >4,2 Sterne | Unter 4,0 blockiert Conversion und ASO-Ranking |
| Push-Opt-in-Rate | >50% | Unter diesem Wert ist der primäre Retention-Anker strukturell gefährdet |

> ⚠️ **Gating-Entscheidung Soft Launch → Full Launch:** Full Launch wird nur freigegeben, wenn LTV/CAC >3:1 (organisch) und D7-Retention >28% gleichzeitig erfüllt sind. Beide Kriterien müssen grün sein.

---

### Phase 3: Full Launch (iOS DACH + weitere Märkte)

- **Ziel:** Skalierung auf Primärmarkt DACH (Deutschland, Österreich, Schweiz), iOS App Store-Sichtbarkeit maximieren, erste PR-Welle aktivieren, Influencer-Seeding auf #planttok und Plant-Instagram starten, paid UA mit validiertem LTV schrittweise hochfahren.
- **Datum/Zeitrahmen:** Frühling (März–April) — bewusste saisonale Positionierung: Pflanzkauf-Saison, Balkon-Saison, Frühjahrsputz-Moment. Dieser Timing-Vorteil ist nicht verhandelbar — ein Herbst-Launch im September verliert den stärksten organischen Discovery-Anlass des Jahres.
- **Region(en) Phase 3:**
  - **Primär:** DACH (Deutschland, Österreich, Schweiz) — DE-Lokalisierung ab Launch nötig
  - **Sekundär (gleichzeitig):** UK, Niederlande, Belgien — Englisch-Launch ohne zusätzliche Lokalisierung möglich
  - **Tertiär (6–8 Wochen nach Full Launch):** USA, Kanada — nach DACH-Stabilisierung und ASO-Learnings

---

## Regionale Strategie

| Region | Phase | Begründung | Lokalisierung nötig |
|---|---|---|---|
| **Australien** | Phase 2 (Soft Launch) | Etablierter Benchmark-Markt; iOS-stark; niedriges UA-Risiko; kulturell vergleichbar; ermöglicht Monetarisierungsvalidierung ohne Primärmarkt-Exposure | Nein (Englisch) |
| **Kanada** | Phase 2 (Soft Launch) | iOS-affin; englischsprachig; ergänzende Daten zu Australien; ähnliches Kaufverhalten zu UK/USA | Nein (Englisch; FR-CA optional später) |
| **Deutschland** | Phase 3 (Full Launch, Primärmarkt) | Größter DACH-Markt; höchste iOS-ARPU-Erwartung im DACH-Raum; Pflanzenpflege-Affinität kulturell hoch; DSGVO-Compliance bereits gegeben | **Ja — Pflicht** (DE vollständig: UI, App Store Listing, Push-Texte, Onboarding) |
| **Österreich** | Phase 3 (Full Launch) | Teil des DE-Sprachraums; wird durch DE-Lokalisierung abgedeckt; kleiner Markt, aber zero incremental Lokalisierungskosten | Nein (DE-Version abdeckend) |
| **Schweiz** | Phase 3 (Full Launch) | DE/FR/IT-Sprachraum; DE-Version für ~65% der Nutzer ausreichend; FR-CH langfristig optional | Teilweise (DE ausreichend für Mehrheit; FR-CH Phase 4) |
| **UK** | Phase 3 (gleichzeitig mit DACH) | Großer iOS-Markt; englischsprachig; Soft-Launch-Daten aus Australien/Kanada direkt übertragbar; kein zusätzlicher Lokalisierungsaufwand | Nein (Englisch) |
| **Niederlande / Belgien** | Phase 3 (gleichzeitig mit DACH) | Hohe englische Sprachkompetenz; iOS-affin; Pflanzenpflege kulturell relevant (Niederlande als Gartenbau-affiner Markt); geringe incremental Kosten | Nein (Englisch ausreichend für Launch; NL-Lokalisierung Phase 4 optional) |
| **USA** | Phase 3 (6–8 Wochen nach DACH-Launch) | Größter iOS-Revenue-Markt weltweit; aber hoher Wettbewerbsdruck (PictureThis, Greg, Planta alle stark positioniert); Launch erst nach DACH-Stabilisierung und ASO-Learnings | Nein (Englisch; US-spezifische Pflanzennamen-Datenbank prüfen) |
| **Frankreich / Spanien / Italien** | Phase 4 (3–6 Monate nach Full Launch) | Relevante Märkte, aber Lokalisierungsaufwand (FR, ES, IT) rechtfertigt erst nach Validierung der Kern-KPIs | **Ja** (vollständige Lokalisierung nötig) |
| **Android (global)** | Phase 4 (parallel zu FR/ES/IT) | Android-Entwicklung erst nach iOS-Validierung; DACH-Android-Marktanteil hoch (~60–65% Gerätebasis), aber niedrigerer ARPU | **Ja** (DE + EN zum Android-Launch) |

---

## App Store Submission

### Apple App Store

**Review-Dauer:** ca. 1–3 Werktage (Durchschnitt 2024/2025); bei KI/Diagnose-Features mit Gesundheits-Konnotation potenziell 3–5 Tage durch manuelle Review-Prüfung

**Häufige Ablehnungsgründe in dieser Kategorie:**

- **Guideline 2.1 (App Completeness):** Unfertige Features oder Placeholder-Content werden abgelehnt — besonders bei KI-Diagnose-Screens, die noch keine validen Ergebnisse liefern
- **Guideline 3.1.2 (Subscriptions):** Subscription-Benefits müssen vollständig und klar beschrieben sein; "Premium"-Button ohne exakte Feature-Liste ist ein Ablehnungsgrund
- **Guideline 5.1.1 (Data Collection and Storage / DSGVO):** Wenn Nutzer-Fotos für ML-Training gesammelt werden, muss die Einwilligung explizit, granular und App-Review-sichtbar sein — nicht nur im Kleingedruckten der Datenschutzerklärung
- **Guideline 4.0 (Design – Minimum Functionality):** Apps, die primär als Web-Wrapper fungieren oder deren KI-Ergebnisse nicht zuverlässig sind, können unter "Minimum Functionality" fallen — relevanter Schutz: eigene Datenbank-Komponente muss erkennbar sein
- **Guideline 1.4 (Physical Harm):** Medizinisch-analoge Diagnose-Formulierungen ("Deine Pflanze hat definitiv X") können als Harm-Signal gewertet werden — **Formulierungen müssen als Empfehlung/Diagnosehinweis, nicht als Faktenaussage formuliert sein**. Beispiel: "KI-Diagnose-Hinweis: Möglicher Nährstoffmangel — bitte prüfe die Symptome." statt "Deine Pflanze hat Eisenmangel."
- **Privacy Nutrition Label:** Alle Datenkategorien (Fotos, Standort, Nutzungsverhalten) müssen im App Store Privacy Label vollständig deklariert sein — fehlende oder falsche Deklaration ist direkter Ablehnungsgrund

**Checkliste vor Submission:**

- [ ] App-Version ist Build-Candidate (kein Debug-Code, kein TestFlight-spezifischer Code aktiv)
- [ ] Alle KI-Diagnose-Texte als Empfehlung/Hinweis formuliert, nicht als medizinische/biologische Faktenaussage
- [ ] Subscription-Preise, Benefits und Verlängerungsbedingungen auf allen relevanten Screens vollständig sichtbar (StoreKit 2 konform)
- [ ] Privacy Nutrition Label vollständig ausgefüllt: Fotos, Standort (PLZ-Ebene), Nutzungsverhalten, Crashdaten
- [ ] Datenschutzerklärung auf erreichbarer URL, die im App Store Listing verlinkt ist
- [ ] ML-Trainingseinwilligung (falls Nutzerfotos für Training genutzt werden) als separater, granularer Opt-in implementiert — nicht gebündelt mit AGB
- [ ] App funktioniert vollständig ohne Location-Zugriff (Location-Fallback: manuelle PLZ-Eingabe)
- [ ] Kamera-Permission-String beschreibt konkreten Nutzungsfall ("Pflanzenerkennung per Kamera")
- [ ] Push-Notification-Permission wird nicht beim App-Start angefragt, sondern nach erstem Pflegeplan-Ergebnis
- [ ] App Store Listing: Screenshots zeigen Core Features (Scan, Diagnose, Pflegeplan) — kein Placeholder-Content
- [ ] App Store Listing: Keyword-Feld (100 Zeichen) optimiert für "Pflanzenpflege", "Pflanzenerkennung", "Pflanzendoktor", "Gießerinnerung"
- [ ] In-App-Review-Prompt (SKStoreReviewController) implementiert, aber erst nach positivem Erlebnis getriggert (z.B. nach erstem abgeschlossenen Diagnose-Cycle, nicht nach Onboarding)
- [ ] TestFlight-Beta-Feedback zur KI-Diagnose-Qualität ausgewertet und in Submission-Notes für Apple Reviewer dokumentiert

---

### Google Play (Phase 4 — Android)

**Review-Dauer:** ca. 1–7 Tage (algorithmisch + manuell seit 2024; bei neuen Entwicklerkonten bis zu 7 Tage für erste Releases)

**Checkliste vor Submission (Phase 4):**

- [ ] Data Safety Section vollständig ausgefüllt (Äquivalent zu Apple Privacy Label, aber Google-spezifisch: explizite Angabe ob Daten geteilt werden und ob Datenlöschung möglich ist)
- [ ] Target SDK auf aktuellem Required-Level (Google erzwingt jährliche SDK-Updates)
- [ ] Battery-Optimizer-Hinweis im Onboarding implementiert: Nutzer aktiv auffordern, GrowMeldAI von Batterieoptimierung auszunehmen (kritisch für Push-Notification-Zuverlässigkeit auf Samsung, Huawei, Xiaomi)
- [ ] Google Play Billing Library (aktuelle Version) für alle In-App-Purchases und Subscriptions implementiert
- [ ] CameraX statt Camera2 direkt (breitere Geräte-Kompatibilität über 24.000+ Gerätemodelle)
- [ ] Fragmentierungs-QA auf Top-20-Geräten durchgeführt (Samsung S-Series, Pixel, Huawei, Xiaomi-Mittelklasse)
- [ ] TensorFlow Lite Offline-Modell für schwache Netzwerkverbindungen getestet (WASM/NPU-Beschleunigung wo verfügbar)
- [ ] Play Store Listing: Screenshots und Feature-Graphic für Android-spezifisches Material-You-Design angepasst
- [ ] App Bundle (AAB) statt APK eingereicht
- [ ] Proguard/R8 Obfuskation aktiv, API-Keys nicht im Client-Code

---

## Launch-Tag Checkliste

- [ ] **Server-Infrastruktur getestet und skalierbar** — Load-Test auf 10× erwartetes Day-1-Traffic-Volumen durchgeführt; Auto-Scaling für Plant.id API-Proxy und Nutzer-Datenbank aktiv
- [ ] **Monitoring und Alerting aktiv** — Datadog/New Relic oder vergleichbares Tool mit Alerts für API-Latenz >500ms, Error Rate >1%, Plant.id API-Quota-Annäherung (>80% des Daily Limits)
- [ ] **Crashlytics aktiv** — Firebase Crashlytics für iOS produktiv; Alert bei Crash-Rate >0,5% innerhalb der ersten 2 Stunden
- [ ] **Analytics und Tracking aktiv** — Amplitude oder Mixpanel: Events für Onboarding-Steps, Scan-Completion, Push-Opt-in, Paywall-View, Abo-Conversion live und getestet; keine Event-Gaps im Funnel
- [ ] **Plant.id API-Quota geprüft** — Tageslimit bekannt, Alert bei 70% Verbrauch; Fallback-Logik für Quota-Überschreitung implementiert (Nutzer erhält "Kurze Warteschlange"-Hinweis statt Error)
- [ ] **Support-Kanäle eingerichtet** — In-App-Feedback-Button aktiv; dedizierte Support-E-Mail (support@growmeldai.com) eingerichtet; Antwortzeit-Versprechen intern definiert (max. 48h für Phase 3)
- [ ] **Social Media Accounts vorbereitet** — Instagram (@GrowMeldAI), TikTok (@GrowMeldAI) mit Teaser-Content befüllt (min. 3 Posts/Videos vor Launch); erste Influencer-Kollaborationen (Micro-Influencer 10k–100k Follower, #planttok) koordiniert und Launch-Tag-Post vereinbart
- [ ] **Website live** — growmeldai.com mit App-Store-Badge (iOS), Feature-Übersicht (Scan, Diagnose, Wetter, Tracking), Press-Kit-Download-Link, Datenschutzerklärung/Impressum (DSGVO-konform)
- [ ] **App Store Listing finalisiert** — alle Screenshots, App-Beschreibung (DE + EN), Keywords, Promotional Text (170 Zeichen, änderbar ohne Review) und App Preview Video (optional, aber empfohlen für Conversion) final
- [ ] **Press Kit versendet** — an relevante deutsche Tech-/Lifestyle-Medien (t3n, Chip, AndroidPIT/NextPit, Brigitte.de, Plant-Blogger) min. 5 Werktage vor Launch; enthält: App-Icon, Screenshots, One-Pager, Zugang zu Press-TestFlight-Build
- [ ] **Backup- und Rollback-Plan dokumentiert** — klare interne Eskalationskette: wer entscheidet bei kritischem Bug über Hotfix vs. App-Rücknahme; App Store Connect "Pause Distribution"-Option bekannt und getestet
- [ ] **Push-Notification-Test (Production)** — Gieß-Erinnerungs-Push im Production-Build auf echten Geräten (iOS 16, 17, 18) validiert; Timing-Logik für morgendliche 7–9 Uhr-Zustellung getestet
- [ ] **DSGVO-Compliance finalisiert** — Datenschutzerklärung aktuell; Cookie-Consent (falls Web-Anteil); Nutzer-Datenlöschungs-Flow implementiert und testbar; Auftragsverarbeitungsverträge mit Plant.id und OpenWeatherMap vorhanden
- [ ] **Onboarding-A/B-Test vorbereitet** — zwei Onboarding-Varianten (mit/ohne sofortige Kamera-Aufforderung) im Analytics-System konfiguriert, Start nach Tag 3 geplant (nicht am Launch-Tag selbst)
- [ ] **Internes War-Room-Setup** — Launch-Tag: dedizierter Slack/Teams-Channel mit Entwickler, PM, Marketing; stündliche Status-Updates intern; klare Verantwortlichkeiten für Bug-Triage, Social-Response und Presse-Anfragen

---

## Post-Launch Plan (erste 30 Tage)

### Woche 1: Stabilisierung und Beobachtung

Fokus: Technische Qualität sichern, erste Nutzersignale lesen, keine voreiligen Änderungen am Produkt.

- Crashlytics täglich auswerten; Hotfix-Releases innerhalb von 24h bei kritischen Bugs (Crash Rate >1% oder Scan-Feature nicht funktional)
- Amplitude-Funnel täglich lesen: wo brechen Nutzer im Onboarding ab? (Ziel: >70% Completion bis erstes Pflanzenprofil)
- Erste App Store Reviews täglich sichten; auf 1-Stern-Reviews innerhalb von 24h antworten (Standard-Antwort mit Support-Kontakt; kein defensiver Ton)
- Push-Notification Opt-in-Rate nach 48h prüfen: liegt die Rate unter 45%, Placement und Kontext des Permission-Dialogs analysieren
- Social Media: täglich 1 Organic-Post auf Instagram/TikTok (Pflanzenpflege-Tipp, kein reines Produkt-Selling); Community-Kommentare beantworten
- Influencer-Posts aus Pre-Launch-Vereinbarungen live schalten (Launch-Woche)
- Plant.id API-Kosten vs. Nutzung täglich tracken — frühzeitig Anomalien erkennen

### Woche 2: Erste Optimierungsiterationen

Fokus: Onboarding optimieren, Push-Opt-in-Rate verbessern, ersten Monetarisierungs-Funnel auswerten.

- Onboarding-A/B-Test starten (falls Woche 1 stabil): Variation testet alternativen CTA-Text beim Pflegeplan-Paywall-Moment
- Paywall-Conversion-Rate erste Auswertung: liegt Free→Paid unter 2%, Paywall-Placement-Hypothesen formulieren (zu früh? falscher Feature-Teaser?)
- D7-Retention-Erste-Kohorte auswerten — erste valide Retention-Daten aus Launch-Woche
- App Store Keyword-Performance in App Store Connect Analytics prüfen; Promotional Text anpassen (ohne Review möglich)
- Ersten Presse-Follow-up: haben Medien aus Woche 1 berichtet? Nachfassen bei t3n, Chip
- Community-Seeding: 3–5 organische Posts in r/houseplants (Reddit), r/plantclinic mit echter Hilfe (keine direkte Werbung — Community-Normen beachten); App nur auf Nachfrage nennen

### Woche 3: