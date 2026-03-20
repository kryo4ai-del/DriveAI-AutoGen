# Release-Plan-Report: EchoMatch

---

## Release-Phasen

### Phase 0: Closed Beta (Interner Alpha + KI-PoC-Validierung)

- **Ziel:** Technische Kernstabilität validieren, KI-Level-Generierung als Proof-of-Concept testen, kritisches Risiko 1 (KI-Generierung unbewiesen) vor jeder weiteren Investition adressieren. Match-3-Core-Loop auf Spielbarkeit und Session-Design (5–10 Min.-Ziel) prüfen. Intern: Team + ausgewählte externe Tester (Friends & Family, 50–150 Personen).
- **Dauer:** 8–10 Wochen
- **Teilnehmer:** Internes Entwicklungsteam + Friends & Family (iOS TestFlight + Android Internal Testing Track); Zielgröße: 50–200 Tester
- **Schwerpunkt KI-PoC:** Paralleler A/B-Test: KI-generierte Level vs. manuell kuratierte Level — Spielerzufriedenheit (qualitatives Feedback), Completion-Rate, Session-Abbrüche als primäre Metriken. Latenz der Level-Auslieferung (Cloud-Backend-Response unter 2 Sekunden als technisches Mindestkriterium).
- **Erfolgskriterien:**
  - D1-Retention intern: ≥50% (unrealer Wert für externen Launch, aber für Friends & Family als Qualitätsindikator ausreichend)
  - Durchschnittliche Session-Dauer: 5–12 Minuten (Core-Design-Validierung)
  - KI-Level-Latenz: <2 Sekunden auf Mittelklasse-Hardware (iPhone 12, Samsung Galaxy A52)
  - Mindestens 80% der KI-generierten Level werden von Testern als "spielbar und fair" bewertet (strukturierter Feedback-Bogen)
  - Keine kritischen Crashes in der Core-Loop (Crash-Rate <2% Sessions)
  - Explizite Go/No-Go-Entscheidung für KI-Feature basierend auf PoC-Ergebnissen: Vollautomatisch, Hybrid (KI + Kuration) oder KI-Feature-Delay

---

### Phase 1: Soft Launch — Technische & Retention-Validierung

- **Ziel:** Retention-KPIs in echten Märkten messen, technische Skalierbarkeit des Cloud-Backends unter realen DAU-Lasten testen, organische UA-Mechanismen (Social-Sharing) auf Wirksamkeit prüfen, App Store-Algorithmen kalibrieren. **Kein aggressives UA-Budget in dieser Phase** — organische Nutzerbasis als Qualitätssignal priorisieren.
- **Dauer:** 8–10 Wochen
- **Regionen:** Kanada, Australien, Neuseeland — kulturell und kaufkraftmäßig eng mit USA/UK korreliert, aber UA-Kosten signifikant niedriger; etablierter Industriestandard für Tier-1-Soft-Launch-Proxy (Lancaric 2025)
- **Plattform:** iOS + Android simultaner Soft-Launch (Unity Cross-Platform macht simultanente Deployment kostenneutral; Split-Test iOS vs. Android Retention von Beginn an wertvoll)
- **UA-Strategie Phase 1:** Minimal-paid UA ($2.000–5.000 Testbudget für Meta/TikTok-Creative-Testing); primär organisch durch App-Store-Optimierung (ASO) und Social-Sharing-Mechanismus
- **Erfolgskriterien:**
  - D1-Retention: ≥40%
  - D7-Retention: ≥20%
  - D30-Retention: ≥10%
  - Durchschnittliche Sessions/Tag pro aktivem Nutzer: ≥2,0
  - Durchschnittliche Session-Dauer: 6–10 Minuten
  - App Store Rating: ≥4,2 Sterne (iOS + Android)
  - Rewarded-Ad-eCPM: ≥$10 (Validierung des Ad-Revenue-Fundaments)
  - Server-Uptime: ≥99,5% über Testzeitraum
  - KI-Level-Auslieferungs-Latenz: <2 Sekunden p95 unter Last (100–500 gleichzeitige Nutzer)
  - **Go/No-Go-Kriterium:** D7 ≥20% ist hartes Kriterium für Phase 2. Unter 15% → Feature-Review-Sprint vor Phase 2.

---

### Phase 2: Soft Launch — Monetarisierungsvalidierung

- **Ziel:** Battle-Pass-Preispunkt ($4,99 vs. $7,99 vs. differenzierte Struktur) per A/B-Test validieren. IAP-Paket-Conversion messen. Rewarded-Ads-Placement-Optimierung (Post-Level vs. Pre-Retry vs. Daily-Quest). ARPU und ARPPU in Tier-1-Proxy-Märkten ermitteln. Battle-Pass-Churn-Rate nach erster Season messen.
- **Dauer:** 8–12 Wochen (inkl. mindestens 1 vollständige Battle-Pass-Season = 4 Wochen)
- **Regionen:** Kanada, Australien, Neuseeland (Fortsetzung) + Schweden, Finnland, Dänemark (Nordics als zusätzliche Tier-1-Proxys mit hoher IAP-Affinität und DSGVO-Jurisdiktion für EU-Compliance-Test)
- **Plattform:** iOS + Android, identisches Build
- **UA-Strategie Phase 2:** Moderates UA-Budget ($10.000–25.000) für skaliertes Creative-Testing; Ziel ist Baseline-CPI-Messung, nicht Skalierung
- **Erfolgskriterien:**
  - ARPU (Gesamt): ≥$0,15/DAU/Tag (Orientierungswert Hybrid-Casual)
  - Battle-Pass-Conversion (Free → Paid): ≥3% der aktiven Nutzer
  - Battle-Pass-Renewal-Rate nach Season 1: ≥55% (Churn-Benchmark)
  - IAP-Conversion (mindestens ein Kauf): ≥2,5% der aktiven Nutzer
  - Rewarded-Ad-Opt-in-Rate: ≥60% der aktiven Free-Player
  - D30-Retention: ≥12%
  - Battle-Pass-Preispunkt-Sieger: Klare A/B-Test-Signifikanz (≥95% Konfidenz) für einen der beiden Preispunkte vor Global-Launch-Commit
  - DSGVO-Consent-Flow funktioniert korrekt in Nordics (EU-Proxy vor DE-Launch)

---

### Phase 3: Global Launch — Tier-1

- **Ziel:** Vollständiger Tier-1-Markteintritt mit validierten Retention- und Monetarisierungs-KPIs. UA-Skalierung auf Basis verifizierter CPI- und LTV-Daten aus Soft-Launch. Erstmover-Vorteil in der KI-Personalisierungs-Nische aktivieren (Risiko 4: Kopierbarkeit durch etablierte Player — Time-to-Market kritisch).
- **Datum/Zeitrahmen:** Monat 14–17 nach Produktionsstart (abhängig von Phase-2-Go/No-Go)
- **Regionen (gestaffelt innerhalb Phase 3):**
  - **Woche 1–2:** USA, UK, Australien (global / simultaner Launch auf iOS + Android)
  - **Woche 3–4:** Deutschland, Österreich, Schweiz (DACH) — setzt abgeschlossene DSGVO-Compliance voraus
  - **Woche 5–8:** Kanada, Frankreich, Niederlande, weitere westeuropäische Tier-1-Märkte
- **UA-Strategie Phase 3:** Skaliertes Budget ($50.000–150.000/Monat in Monat 1–3, abhängig von LTV-Validierung); primär Meta, TikTok, Apple Search Ads (ASA) für iOS; Google UAC für Android; Social-Sharing als organischer UA-Kanal als messbare Komponente (Viral-Koeffizient als KPI)
- **Erfolgskriterien:**
  - 50.000 Downloads in ersten 7 Tagen (organisch + paid kombiniert, Tier-1-Märkte)
  - D1 ≥40%, D7 ≥20%, D30 ≥10% (Soft-Launch-Benchmark halten)
  - App Store Rating: ≥4,3 Sterne nach 500+ Bewertungen
  - Keine schwerwiegenden technischen Incidents in ersten 72 Stunden (Server-Stabilität unter Tier-1-Last)

---

### Phase 4: Global Launch — Tier-2 (Volumen & Ad-Revenue-Skalierung)

- **Ziel:** Ad-Revenue-Skalierung durch hohes Installvolumen in Brasilien, Indien, Südostasien. Sekundär- und Nischen-Segmente (35–49, 50+) adressieren. Android-First-Märkte erschließen.
- **Datum/Zeitrahmen:** Monat 17–21 nach Produktionsstart (2–4 Monate nach Tier-1-Launch)
- **Regionen:** Brasilien, Indien, Indonesien, Thailand, Vietnam, Malaysia, Mexiko
- **Plattform-Fokus:** Android-dominant; iOS-Launch in Brasilien und Indien parallel, aber Android priorisieren
- **Lokalisierung:** Portugiesisch (Brasilien), Hindi, Bahasa Indonesia als Mindestanforderung für relevante Märkte; englische Basis für Südostasien initial akzeptabel
- **UA-Strategie:** Niedrig-CPI-fokussierte Kampagnen; Meta Advantage+, TikTok; lokale Ad-Networks (InMobi für Indien) als Ergänzung

---

## Regionale Strategie

| Region | Phase | Begründung | Lokalisierung nötig |
|---|---|---|---|
| **Kanada** | Phase 1 + 2 (Soft-Launch) | Tier-1-ARPU-Proxy für USA bei ~30–40% niedrigerem UA-CPI; englischsprachig; App Store- und Google-Play-Algorithmen verhalten sich wie USA-Markt | Nein (Englisch) |
| **Australien** | Phase 1 + 2 + Phase 3 Woche 1 | Etablierter Soft-Launch-Standard (Lancaric 2025); iOS-überproportional stark; Zeit-Offset zu USA/Europa ermöglicht frühe Server-Belastungstests | Nein (Englisch) |
| **Neuseeland** | Phase 1 + 2 | Kleiner, kontrollierbarer Markt mit Tier-1-Kaufkraft; gängiger Startpunkt für erste KPI-Messungen ohne großes Exposure-Risiko | Nein (Englisch) |
| **Schweden / Finnland / Dänemark** | Phase 2 | DSGVO-Jurisdiktion (EU-Compliance-Testmarkt vor DACH-Launch); hohe IAP-Affinität; englischsprachige Spielerschaft akzeptiert englische UI; Battle-Pass-Performance als EU-Proxy | Nein in Phase 2 (Englisch akzeptiert); Ja vor DACH (DE-UI empfohlen) |
| **USA** | Phase 3, Woche 1 | Größter Einzelmarkt für IAP-Revenue und Battle-Pass; Apple Search Ads am effektivsten; höchste eCPM für Rewarded Ads (~$13–18); Erstmover-Fenster für KI-USP hier am größten | Nein (Englisch) |
| **UK** | Phase 3, Woche 1 | Zweithöchster ARPU nach USA in Tier-1; englischsprachig; iOS-stark; wichtig für App-Store-Featuring-Chancen | Nein (Englisch) |
| **Deutschland** | Phase 3, Woche 3–4 | Drittgrößter europäischer Markt; DSGVO-Compliance zwingend und muss vor Launch abgeschlossen sein; deutschsprachige Lokalisierung erhöht Conversion und Rating; Jugendschutzgesetz (JuSchG) beachten | **Ja — Pflicht:** Deutsche UI, DSGVO-Datenschutzerklärung auf Deutsch, Impressum |
| **Österreich / Schweiz** | Phase 3, Woche 3–4 | Zusammen mit DE-Launch; gleiche Compliance-Basis; DE-Lokalisierung ausreichend (AT/CH-Spezifika minimal) | Ja (DE-Lokalisierung deckt DACH ab) |
| **Frankreich / Niederlande / weitere EU** | Phase 3, Woche 5–8 | Ergänzung nach DACH; DSGVO-Compliance bereits durch DACH-Launch etabliert; Lokalisierung erhöht Conversion, aber nicht zwingend für Launch | Empfohlen (FR für Frankreich); optional für weitere EU in Phase 3 |
| **Brasilien** | Phase 4 | Android-dominant; hohes Installvolumen bei niedrigerem ARPU; primär Ad-Revenue; Google Play Billing lokal optimiert; Pix-Zahlungssystem-Relevanz für IAP | **Ja — Pflicht:** Portugiesisch (Brasilien) |
| **Indien** | Phase 4 | Größtes Android-Volumen weltweit; sehr niedriger ARPU; Ad-Revenue-Fokus; UPI-Zahlungsintegration für IAP-Conversion kritisch; Spielerkultur match-3-affin | **Ja — empfohlen:** Hindi; Englisch als Fallback initial akzeptabel |
| **Indonesien / Thailand / Vietnam** | Phase 4 | Wachstumsstarke Märkte; Android-dominant; niedrige CPI; Ad-Revenue-Skalierung; Englisch initial ausreichend für Vietnam und Indonesien | Englisch initial; lokale Sprachen für Phase-4-Optimierung empfohlen |

---

## App Store Submission

### Apple App Store

- **Review-Dauer:** 24–48 Stunden für Erstsubmission (Standardfall); bei KI-Content-Deklaration oder erster Submission eines neuen Accounts potenziell 3–5 Werktage; Update-Reviews nach erstem Approval typischerweise <24 Stunden
- **Häufige Ablehnungsgründe in dieser Kategorie (Puzzle/Casual Games mit IAP und KI):**
  - **Guideline 3.1.1:** IAP-Preise nicht korrekt im App Store Connect hinterlegt oder Währungsanzeige im Spiel weicht von App-Store-Preisen ab → alle IAP-Pakete und Battle-Pass-Preise müssen 1:1 im App Store Connect konfiguriert sein, bevor die Review-Submission erfolgt
  - **Guideline 5.1.1 (Privacy):** Datenschutzerklärung fehlt oder ist nicht erreichbar; Privacy Nutrition Labels unvollständig oder inkorrekt — besonders kritisch bei KI-Behavioral-Tracking; ATT-Prompt muss korrekt implementiert und getestet sein
  - **Guideline 4.3 (Spam):** KI-generierte Level könnten bei mangelhafter Qualität als algorithmisch generierter Spam-Content eingestuft werden → Level-Qualitätssicherung und Beschreibung des KI-Systems in der App-Beschreibung transparent kommunizieren
  - **Guideline 2.1 (App Completeness):** Crash bei Review-Team-Hardware (iPhone SE 2. Gen als Mindestziel der Apple-Reviewer) → Tests auf Low-End-Apple-Geräten zwingend
  - **Guideline 1.1/5.1.4 (Kinder-Sicherheit):** Falls App für unter 13-Jährige zugänglich → COPPA-Compliance und eingeschränkte Ad-Auslieferung; Age-Gate empfohlen wenn Zielgruppe 18+ ist
  - **In-App Purchase Review:** Alle Battle-Pass-Tier-Beschreibungen müssen klar und nicht irreführend sein; "Premium-Upgrade" darf keinen Gameplay-Zwangsvorteil suggerieren (Guideline 3.1.1 + 3.2)

- **Checkliste vor Submission:**
  - [ ] App Store Connect Account vollständig eingerichtet, Bankverbindung und Steuerinformationen hinterlegt
  - [ ] Alle IAP-Produkte (6 IAP-Pakete + 2 Battle-Pass-Tiers) in App Store Connect angelegt, Preise in allen Ziel-Währungen konfiguriert
  - [ ] ATT-Prompt (App Tracking Transparency) korrekt implementiert und auf iOS 14.5+ getestet — erscheint nach erstem sinnvollen Nutzermoment, nicht beim App-Start
  - [ ] Privacy Nutrition Labels vollständig und korrekt ausgefüllt (Behavioral Data, Usage Data, Identifiers, Purchases — alle relevanten Kategorien für EchoMatch)
  - [ ] Datenschutzerklärung URL in App Store Connect hinterlegt; Erreichbarkeit geprüft (kein 404)
  - [ ] App funktioniert auf iPhone SE 2. Generation (kleinste Bildschirmgröße im aktuellen Apple-Lineup, typisches Review-Device)
  - [ ] Crash-freier Start und Core-Loop auf iOS 16 (Mindestversion) und iOS 18 (aktuell) getestet
  - [ ] KI-Level-Generierung funktioniert mit Cloud-Backend — keine Client-Side-Level-Updates, die erneute App-Store-Reviews erfordern würden
  - [ ] Rewarded-Ads-SDK (z. B. ironSource / AppLovin MAX) auf Guideline-Konformität geprüft (keine Auto-Play-Ads ohne User-Interaction)
  - [ ] Age-Gate oder Alterskennzeichnung korrekt konfiguriert (Rating: 4+ oder 12+ je nach Kampfmechaniken in Story — 12+ empfohlen für Battle-Pass-Kontext)
  - [ ] Sign-in with Apple als Login-Option implementiert (Pflicht wenn andere Social-Login-Optionen angeboten werden)
  - [ ] App Store Listing vollständig: Screenshots für alle erforderlichen Gerätegrößen (6,7"; 6,1"; iPad falls relevant), App-Vorschau-Video (15–30 Sek., nicht pflicht aber stark empfohlen), Lokalisierungen für EN-US, DE (für DACH-Launch)
  - [ ] TestFlight-Beta mit mindestens 10 externen Testern ohne interne Verbindung zum Team für finale Pre-Submission-Validierung

---

### Google Play

- **Review-Dauer:** Erstsubmission: 3–7 Werktage (automatisiertes Screening + potenziell manueller Review); Updates nach erstem Approval: typischerweise weniger als 24 Stunden; ⚠️ KI-Content-Deklaration und Daten-Safety-Sektion erhöhen Wahrscheinlichkeit eines manuellen Reviews und damit Dauer
- **Häufige Ablehnungsgründe in dieser Kategorie:**
  - **Data Safety Section unvollständig:** Alle Datenerhebungen (KI-Behavioral-Tracking, Ad-IDs, Gerätedaten) müssen in der Data-Safety-Sektion korrekt deklariert sein — häufigster Ablehnungsgrund 2023–2025 für Apps mit Analytics-Stack
  - **Irreführende In-App-Purchases:** IAP-Beschreibungen müssen dem tatsächlichen Inhalt entsprechen; Battle-Pass-Inhalte müssen vollständig und klar beschrieben sein
  - **Ads Policy:** Rewarded-Ads-Implementierung darf nicht irreführend sein; Ads dürfen nicht durch UI-Elemente verborgen werden; interstitielle Ads während Gameplay (nicht EchoMatchs Modell, aber zu prüfen) sind policy-riskant
  - **Families Policy:** Falls App unter 13-Jährigen zugänglich ist (ohne expliziten Age-Gate) → drastische Ad-Einschränkungen und COPPA-Compliance-Pflicht; Age-Gate implementieren
  - **KI-generierter Content:** Google Play hat seit 2024 explizite Anforderungen an Transparenz bei KI-generiertem Content — Beschreibung des KI-Systems im Store-Listing empfohlen
  - **Targeting API Level:** App muss aktuelles Android Target SDK Level verwenden (aktuell: Android 14 / API 34 als Minimum für neue Submissions); Unity-Build-Settings müssen entsprechend konfiguriert sein

- **Checkliste vor Submission:**
  - [ ] Google Play Console Account vollständig eingerichtet, Merchant-Account für Play Billing konfiguriert
  - [ ] Alle IAP-Produkte (6 IAP-Pakete + 2 Battle-Pass-Tiers) als In-app Products in Play Console angelegt; Subscriptions (Battle-Pass) korrekt als Subscription-Produkte konfiguriert (nicht als one-time IAP)
  - [ ] Data Safety Sektion vollständig ausgefüllt: Alle erhobenen Datentypen, Verwendungszweck, Sharing mit Dritten (Ad-Networks, Analytics) korrekt deklariert
  - [ ] Datenschutzerklärung URL in Play Console hinterlegt
  - [ ] App gegen Android 8.0–15 getestet (Mindest-Android-Version: 8.0 / API 26 empfohlen für ausreichende Gerätebasis); expliziter Test auf Low-End-Gerät (Snapdragon 400-Klasse, 3GB RAM — z. B. Samsung Galaxy A22)
  - [ ] Target SDK Level auf aktuellem Stand (API 34+)
  - [ ] Play Billing Library Version aktuell (mindestens Version 6.x)
  - [ ] KI-Level-Generierung: Cloud-Backend-Calls funktionieren auf Android ohne On-Device-KI-Inferenz auf Low-End-Geräten
  - [ ] Age-Gate implementiert; App-Rating in Play Console korrekt gesetzt (IARC-Rating-Tool vollständig ausgefüllt)
  - [ ] Rewarded-Ads-Implementierung überprüft: Opt-in ist vollständig fre