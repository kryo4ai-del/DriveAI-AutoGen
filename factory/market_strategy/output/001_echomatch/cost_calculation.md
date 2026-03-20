# Kosten-Kalkulations-Report: EchoMatch

---

> **Methodik-Hinweis:** Alle Zahlen sind direkt aus den vorliegenden Strategy-Reports extrahiert. Positionen ohne Report-Grundlage sind als *„geschätzt"* markiert. Alle Beträge in Euro (€). Revenue-Prognosen nach Abzug der Platform-Commission (15–30%). Wo Reports Bandbreiten angeben, wird für Kalkulationszwecke der Mittelwert verwendet; für Szenario-Analysen werden Ober- und Untergrenzen separat ausgewiesen.

---

## 1. Entwicklungskosten

### Grundlage
Empfohlener Stack laut Plattform-Strategie-Report (Agent 8): **Unity Cross-Platform** (iOS + Android simultan). Native Einzelentwicklung wird explizit nicht empfohlen. DACH-Markt-Stundensatz: €80–120/h (Mid-Senior Unity Developer).

### Entwicklungskosten-Tabelle

| Posten | Kosten-Untergrenze | Kosten-Obergrenze | Kalkulationsmittelwert |
|---|---|---|---|
| **Unity Cross-Platform MVP** (Kern-Loop + KI-Placeholder + Soft-Launch-Ready, 6–9 Monate) | €120.000 | €200.000 | **€160.000** |
| **KI-Level-Generierung PoC** (separat, vor Full Production, 6–10 Wochen) | €20.000 | €40.000 | **€30.000** |
| **Full Production Aufschlag** (alle drei Layer: KI-Live, Social-Features, Narrative — Differenz MVP zu Full) | €160.000 | €300.000 | **€230.000** |
| **iOS-Native-Bridge-Code** (Live Activities, Dynamic Island, Sign-in with Apple — Unity-Ergänzung) | €5.000 | €15.000 | **€10.000** |
| **Cloud-Backend-Entwicklung** (KI-Level-Generierung serverseitig, API-Architektur — nicht in Unity-Estimate enthalten) | €25.000 | €60.000 | **€42.500** |
| **Consent-Management-Platform (CMP) technische Implementierung** (ATT iOS + DSGVO-Consent-Flow) | €5.000 | €15.000 | **€10.000** |

> ⚠️ **Wichtig:** Die Reports unterscheiden MVP (Soft-Launch-Ready) und Full Production. Die Kalkulation weist beide Stufen separat aus, da sie zeitlich gestaffelt sind.

---

### Entwicklungskosten nach Phasen

**Phase A: KI-PoC + MVP (Soft-Launch-Ready)**

| Posten | Kosten |
|---|---|
| KI-Level-Generierung Proof-of-Concept | €30.000 |
| Unity Cross-Platform MVP (inkl. KI-Placeholder, Core-Loop, Soft-Launch-Ready) | €160.000 |
| iOS Native Bridge Code | €10.000 |
| Cloud-Backend Basis-Architektur | €42.500 |
| CMP / ATT technische Implementierung | €10.000 |
| **Gesamt Entwicklung Phase A (MVP + PoC)** | **€252.500** |

**Phase B: Full Production Aufschlag (nach Soft-Launch-Validierung)**

| Posten | Kosten |
|---|---|
| Full Production Aufschlag (KI-Live, Social-Layer vollständig, Narrative Layer vollständig) | €230.000 |
| **Gesamt Entwicklung Phase B** | **€230.000** |

**Gesamt Entwicklung (MVP + Full Production kombiniert):**

| Posten | Kosten |
|---|---|
| Phase A (MVP + PoC) | €252.500 |
| Phase B (Full Production) | €230.000 |
| **Gesamt Entwicklung gesamt** | **€482.500** |

> ⚠️ Für die **Gesamtbudget-bis-Launch-Kalkulation** wird Phase A als primäre Investition vor dem Tier-1-Launch verwendet. Phase B überschneidet sich teilweise mit dem Soft-Launch-Zeitraum und ist in der Gesamtrechnung separat ausgewiesen.

---

## 2. Marketing-Budget

### Grundlage
Marketing-Strategie-Report (Agent 10) + Release-Plan (Agent 11). UA-Budgets aus Release-Plan-Report direkt extrahiert.

### Pre-Launch Marketing

| Posten | Kosten-Untergrenze | Kosten-Obergrenze | Kalkulationsmittelwert |
|---|---|---|---|
| Landing Page (Webflow/Framer Template) | €500 | €1.500 | €1.000 |
| Custom Domain + Hosting (1 Jahr) | €50 | €150 | €100 |
| Copywriting + Key Visual Adaption | €800 | €1.500 | €1.150 |
| DSGVO-Rechtstext Landing Page (Datenschutz, Impressum) | €300 | €600 | €450 |
| Community-Hub-Extension (Notion/Webflow CMS) | €0 | €500 | €250 |
| App-Store-Preview-Video (Freelancer, DACH) | €800 | €2.500 | €1.650 |
| Press Kit Erstellung (Screenshots, GIFs, One-Pager, Trailer) | €1.500 | €4.000 | **€2.750** *(geschätzt, basierend auf üblichen Freelancer-Sätzen DACH)* |
| Social Media Content Production Pre-Launch (16 Wochen, TikTok/Instagram/YouTube) | €3.000 | €8.000 | **€5.500** *(geschätzt)* |
| Micro-Influencer Pre-Launch (2–3 Creator, 50K–300K Follower, TikTok/YouTube) | €2.000 | €6.000 | **€4.000** *(geschätzt, Basis: UGC Factory Guide 2025 im Marketing-Report referenziert)* |
| Referral-Tool (z. B. Referral Hero, tl;drx) | €0 | €600 | €300 |
| **Gesamt Pre-Launch Marketing** | **€8.950** | **€25.350** | **€17.150** |

### Soft-Launch UA-Budget (Phase 1 + Phase 2)

| Phase | Budget (aus Release-Plan-Report) | Kalkulationswert |
|---|---|---|
| Soft-Launch Phase 1 (CA/AU/NZ, organisch-fokussiert) | $2.000–$5.000 | **€4.000** *(Mittelwert, USD→EUR ~1:1 für Kalkulation)* |
| Soft-Launch Phase 2 (+ Nordics, moderates Creative-Testing) | $10.000–$25.000 | **€17.500** *(Mittelwert)* |
| **Gesamt Soft-Launch UA** | **$12.000–$30.000** | **€21.500** |

### Launch-Budget (Tier-1 Global Launch)

| Posten | Budget (aus Release-Plan-Report) | Kalkulationswert |
|---|---|---|
| Paid UA Monat 1–3 nach Global Launch (Meta, TikTok, ASA, Google UAC) | $50.000–$150.000/Monat | **€75.000/Monat** *(Mittelwert; für 3 Monate: €225.000)* |
| Launch-Influencer-Push (3–5 gleichzeitige Creator, Mid-Tier) | €3.000 | €8.000 | **€5.500** *(geschätzt)* |
| PR/Presse (Review-Codes, Embargo-Koordination, keine Paid-PR) | €0 | €2.000 | **€1.000** *(geschätzt)* |
| **Gesamt Launch-Marketing (Monat 1–3)** | | **€231.500** |

### Marketing-Zusammenfassung

| Phase | Kosten |
|---|---|
| Pre-Launch (Landing Page, Content, Influencer, Press Kit) | €17.150 |
| Soft-Launch UA (Phase 1 + Phase 2) | €21.500 |
| **Gesamt Marketing bis Global Launch** | **€38.650** |
| Launch-Phase UA + Activities (Monate 1–3 nach Global Launch) | €231.500 |
| **Monatliches UA-Budget laufend (ab Monat 4, nach Validierung)** | **€50.000–75.000** *(geschätzt, abhängig von LTV-Validierung; Mittelwert: €62.500)* |

> ⚠️ Das monatliche UA-Budget post-Launch ist die größte variable Kostenposition und der stärkste Hebel auf den Break-Even. Die Reports empfehlen explizit, das Budget an validierte LTV-Daten aus dem Soft-Launch zu koppeln — nicht pauschal zu skalieren.

---

## 3. Compliance-Kosten

### Grundlage: Risk-Assessment-Report (Agent 11 / Phase 1)

### Einmalige Compliance-Kosten (Pre-Launch)

| Posten | Kosten-Untergrenze | Kosten-Obergrenze | Kalkulationsmittelwert |
|---|---|---|---|
| Rechtsberatung Glücksspielrecht (DE/BE/NL, Reward-Mechaniken-Prüfung) | €8.000 | €15.000 | €11.500 |
| DSGVO-Compliance (Consent-Architektur, Datenschutz-Folgenabschätzung Art. 35, CMP, Rechtsberatung DE/UK/AU, COPPA USA) | €15.000 | €35.000 | €25.000 |
| AI-Urheberrecht (IP-Indemnification-Prüfung, Rechtsgutachten Training-Datenbasis) | €6.000 | €12.000 | €9.000 |
| Jugendschutz-Klassifizierung (USK/PEGI/IARC) | €3.000 | €8.000 | €5.500 |
| Social Features / DSA-Compliance (Nutzungsbedingungen, Moderationskonzept) | €3.000 | €6.000 | €4.500 |
| Markenrecherche + Anmeldung (EUIPO + USPTO + UK IPO) | €4.000 | €10.000 | €7.000 |
| Patent Freedom-to-Operate-Recherche (KI-Personalisierungsmechanik) | €5.000 | €10.000 | €7.500 |
| App Store Compliance / ATT-Implementierung (rechtliche Prüfung) | €0 | €2.000 | €1.000 |
| **Gesamt Compliance einmalig** | **€44.000** | **€98.000** | **€71.000** |

### Laufende Compliance-Kosten (jährlich, aus Risk-Assessment-Report)

| Posten | p.a. Untergrenze | p.a. Obergrenze | Kalkulationsmittelwert p.a. | Kalkulationsmittelwert/Monat |
|---|---|---|---|---|
| DSGVO-Datenschutzbeauftragter (extern) | €6.000 | €12.000 | €9.000 | €750 |
| Laufende Rechtsberatung (Policy-Updates, neue Märkte) | €5.000 | €10.000 | €7.500 | €625 |
| Markenüberwachung (EU + USA) | €1.500 | €3.000 | €2.250 | €188 |
| Compliance-Monitoring (App Store Policies, Regulierungsänderungen) | €2.000 | €4.000 | €3.000 | €250 |
| **Gesamt Compliance laufend** | **€14.500 p.a.** | **€29.000 p.a.** | **€21.750 p.a.** | **€1.813/Monat** |

---

## 4. Infrastruktur-Kosten (monatlich)

### Grundlage
Plattform-Strategie-Report (Agent 8): Cloud-Backend als Pflichtarchitektur für KI-Level-Generierung. Firebase-Stack empfohlen. Konkrete Infrastrukturkosten sind in keinem Report explizit beziffert — alle Positionen sind **geschätzt** auf Basis von Marktstandard-Preisen für vergleichbare Mobile-Game-Backends (Skalierungsstufe: 10.000–100.000 DAU).

| Posten | Kosten/Monat (Soft-Launch) | Kosten/Monat (Post-Global-Launch, ~50K DAU) | Herleitung |
|---|---|---|---|
| **Cloud Hosting** (Google Cloud / AWS für KI-Backend + API-Server) | €800 | €3.500 | *geschätzt; KI-Inferenz serverseitig ist rechenintensiv; Skalierung linear mit DAU* |
| **KI-Service API** (OpenAI / Google Vertex / Azure AI für Level-Generierung) | €500 | €2.500 | *geschätzt; ca. 1–3 API-Calls/DAU/Tag für Level-Generierung; ~$0,002–0,01/Call* |
| **Datenbank** (Firebase Realtime DB oder Firestore für User-Progress, KI-Daten, Social-Features) | €200 | €800 | *geschätzt; Firebase Spark→Blaze-Plan; hochfrequente Reads durch Daily-AI-Content* |
| **CDN / Storage** (Asset-Delivery: Level-Assets, Artwork, Audio; CloudFront oder GCS) | €150 | €600 | *geschätzt; ~500MB App-Assets, täglich aktualisierte KI-Level-Daten* |
| **Analytics** (Firebase Analytics kostenlos + optionales GameAnalytics Pro) | €0–150 | €150 | *Firebase Analytics kostenfrei; GameAnalytics Pro ab ~€150/Monat für erweiterte Retention-KPIs* |
| **Crash-Reporting** (Firebase Crashlytics kostenlos / Sentry für erweiterte Diagnose) | €0–80 | €80 | *Sentry Developer Plan ab €26/Monat; Team-Plan €80/Monat — ausreichend für Launch-Phase* |
| **Push Notifications** (Firebase Cloud Messaging kostenlos bis ~500K/Monat, danach kostenpflichtig) | €0 | €100 | *geschätzt; bei 50K DAU + 2–4 Push/Tag = ~4M Push/Monat → Kosten erst bei sehr hohem Volumen relevant* |
| **A/B-Testing** (Unity Remote Config inklusive / Firebase A/B Testing kostenlos) | €0 | €0 | *Im Unity/Firebase-Stack enthalten; kein separater Kostenpunkt* |
| **Monitoring / Uptime** (Statuspage / BetterUptime für Server-Monitoring) | €30 | €80 | *geschätzt; BetterUptime Starter ~€30/Monat* |
| **Gesamt Infrastruktur** | **€1.680–1.910/Monat** | **€7.810/Monat** | |

> Für Kalkulationszwecke: **Soft-Launch: €1.800/Monat**, **Post-Global-Launch: €7.800/Monat**

---

## 5. Laufende Betriebskosten (monatlich)

### Grundlage
Teilweise aus Reports extrahiert, teilweise geschätzt.

| Posten | Kosten/Monat | Quelle / Herleitung |
|---|---|---|
| **Customer Support** (Community-Management, Bug-Reports, App-Store-Review-Responses) | €1.500–3.000 | *geschätzt; 1 Teilzeit-Support/Community-Manager im DACH-Markt* |
| **Content-Erstellung** (Tägliche KI-Quest-Kuration, Battle-Pass-Season-Content, Social-Media-Content) | €2.000–4.000 | *geschätzt; Hybrid KI + manuell laut Concept Brief; 1 Content Creator/Game Designer Teilzeit* |
| **Battle-Pass Season-Produktion** (Artwork, Narrative-Chapter, neue Kosmetika — amortisiert auf 4 Wochen) | €3.000–6.000 | *geschätzt; pro Season ~€3.000–6.000; = Monatswert* |
| **App Store Jahresgebühren** (amortisiert auf Monat) | €21 | Apple Developer Program: €99/Jahr = €8,25/Monat; Google Play: $25 einmalig ≈ €0/Monat danach |
| **Apple/Google Revenue Share** | **15–30% des Brutto-Revenue** | Direkt aus Plattform-Report: 15% unter $1M Jahresumsatz (Apple Small Business Program + Google Play äquivalent); 30% danach |
| **Unity-Lizenzkosten** (Unity Personal/Plus: kostenlos bis $200K Jahresumsatz) | €0 | Kostenfrei in Early Stage; bei >$200K ARR: Unity Pro ~€2.000/Jahr/Seat |
| **Live-Ops Event-Produktion** (Saisonale Events, kooperative Team-Events) | €1.000–2.500 | *geschätzt; monatliche Live-Ops als Retention-Mechanik* |
| **Gesamt Betrieb (ohne Revenue Share)** | **€7.521–15.521/Monat** | |
| **Kalkulationsmittelwert Betrieb** | **€11.500/Monat** | |

> **Revenue Share separat ausgewiesen** (15–30%), da er umsatzabhängig ist und in der Revenue-vs.-Kosten-Analyse abgezogen wird.

---

## 6. Revenue-Prognosen

### Grundlage und Herleitung

Die Revenue-Prognose basiert auf folgenden Werten aus den Reports:

**Inputs aus Monetarisierungs-Report (Agent 9):**
- ARPU Mobile Games Puzzle-Segment: ~$3/Monat (Gesamtdurchschnitt)
- Aktive IAP-Käufer: $5–15/Monat
- Conversion Free → Paying: 2–5% (Branchendurchschnitt)
- Battle-Pass-Conversion Ziel: ≥3% aktiver Nutzer
- Battle-Pass-Preis: €4,99 (Standard) / €7,99 (Premium) → Mittelwert ~€6,50
- Rewarded-Ads-eCPM (USA, Puzzle): $10–18; Mittelwert $14 ≈ €13
- Revenue-Split: Rewarded Ads ~40–50%, Battle Pass ~30–40%, IAP ~15–25%

**DAU-Annahmen für Szenarien (geschätzt, basierend auf Soft-Launch-Zielen aus Release-Plan):**

| Szenario | DAU (Monat 3 nach Global Launch) | Herleitung |
|---|---|---|
| Pessimistisch | 5.000 DAU | Unterhalb Soft-Launch-Zielen; schlechte Retention; eingeschränkte UA-Wirkung |
| Realistisch | 25.000 DAU | Soft-Launch-Ziele erfüllt (D1≥40%, D7≥20%); moderates UA-Budget wirkt |
| Optimistisch | 75.000 DAU | Starkes Organic-Wachstum durch KI-USP + Social-Sharing; UA skaliert profitabel |

**Revenue-Berechnung pro Szenario:**

*Annahme: ARPU Gesamt €0,10/DAU/Tag (konservativ; Release-Plan-Zielwert: ≥$0,15/DAU/Tag; hier €0,10 als realistischer Einstiegswert, €0,15 für Optimistisch, €0,05 für Pessimistisch)*

**Brutto-Revenue (vor Platform-Commission):**

| Szenario | DAU | ARPU/Tag | Brutto-Revenue/Monat |
|---|---|---|---|
| Pessimistisch | 5.000 | €0,05 | €7.500 |
| Realistisch | 25.000 | €0,10 | €75.000 |
| Optimistisch | 75.000 | €0,15 | €337.500 |

**Netto-Revenue (nach 20% Platform-Commission als Mittelwert 15–30%):**

| Szenario | Brutto-Revenue/Monat | Platform-Commission (20%) | Netto-Revenue/Monat |
|---|---|---|---|
| Pessimistisch | €7.500 | –€1.500 | **€6.000** |
| Realistisch | €75.000 | –€15.000 | **€60.000** |
| Optimistisch | €337.500 | –€67.500 | **€270.000** |

---

## 7. Revenue vs. Kosten (monatlich nach Global Launch)

### Monatliche Kosten nach Launch (Zusammenfassung)

| Kostenblock | Pessimistisch/Monat | Realistisch/Monat | Optimistisch/Monat |
|---|---|---|---|
| Infrastruktur | €1.800 | €7.800 | €12.000 *(geschätzt bei ~75K DAU)* |
| Betrieb (ohne Revenue Share) | €7.521 | €11.500 | €15.521 |
| Marketing UA laufend | €15.000 | €62.500 | €100.000 |
| Compliance laufend | €1.813 | €1.813 | €1.813 |
| **Gesamt Kosten/Monat** | **€26.134** | **€83.613** | **€129.334** |

### Revenue vs. Kosten

| Szenario | Netto-Revenue/Monat | Kosten/Monat | Ergebnis/Monat |
|---|---|---|---|
| **Pessimistisch** | €6.000 | €26.134 | **–€20.134** |
| **Realistisch** | €60.000 | €83.613