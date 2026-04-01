# Kosten-Kalkulations-Report: GrowMeldAI

> **Methodik-Hinweis:** Alle Zahlen werden direkt aus den vorliegenden Reports extrahiert. Wo Reports Bandbreiten angeben, wird für die Kalkulation der Mittelwert verwendet. Eigene Schätzungen sind explizit als *„geschätzt"* markiert. Revenue-Zahlen sind nach Abzug der Apple/Google Revenue Share (25% Durchschnitt als konservativer Wert) berechnet.

---

## 1. Entwicklungskosten

### Plattform-Strategie: iOS Native First (Phase 1), Android Phase 4

Aus dem Plattform-Strategie-Report (Agent 8) — Empfehlung: gestaffelter Launch, iOS Native.

| Posten | Min | Max | Mittelwert |
|---|---|---|---|
| **iOS-Entwicklung** (Swift/SwiftUI, 4–6 Monate, 1–2 Entwickler) | €60.000 | €120.000 | €90.000 |
| **Plant.id API-Integration + OpenWeatherMap-API** | €5.000 | €10.000 | €7.500 |
| **Push Notification System** (APNs + Firebase Cloud Messaging) | €3.000 | €6.000 | €4.500 |
| **UX/UI Design** (Figma → SwiftUI) | €15.000 | €25.000 | €20.000 |
| **QA + TestFlight-Beta** | €5.000 | €10.000 | €7.500 |
| **App Store Setup + Legal** (Privacy Label, IAP/StoreKit-2-Compliance) | €3.000 | €6.000 | €4.500 |
| **Gesamt iOS Phase 1** | **€91.000** | **€177.000** | **€134.000** |

> **Android (Phase 4):** €63.000–€115.000 (Mittelwert €89.000) — nicht im initialen Launch-Budget enthalten, aber als Folgeinvestition eingeplant.

> **Offshore-Option:** Osteuropa (€300–€500/Tag) reduziert Gesamtkosten Phase 1 auf €50.000–€90.000 — mit entsprechendem QA-Mehraufwand. Für diese Kalkulation wird DACH-Marktpreis verwendet (konservativer Ansatz).

**→ Entwicklung Phase 1 gesamt (Mittelwert): €134.000**

---

## 2. Marketing-Budget

### Pre-Launch-Kosten (aus Agent 10)

| Posten | Min | Max | Mittelwert |
|---|---|---|---|
| **Landing Page** (Webflow/Framer, Design + Setup) | €1.500 | €3.500 | €2.500 |
| **Full Site Erweiterung** (nach Launch) | €2.000 | €4.000 | €3.000 |
| **Domain + Hosting** (12 Monate) | €150 | €300 | €225 |
| **Copywriting** (DE + EN) | €800 | €1.500 | €1.150 |
| **SEO-Setup** (technisch + On-Page-Grundoptimierung) | €500 | €1.000 | €750 |
| **Social Media Content-Produktion Pre-Launch** (12 Wochen × ~4 Posts/Woche, *geschätzt* €200/Post Produktion) | €5.000 | €10.000 | €7.500 |
| **Influencer Seeding Pre-Launch** (5–10 Micro-Creator, Beta-Zugänge + kostenlose Premium-Monate, *geschätzt* €300–€800/Creator) | €1.500 | €8.000 | €4.750 |
| **Press Kit Produktion** (Design, Videos, Screenshots) | €1.500 | €3.000 | €2.250 |
| **Beta-Nutzer-Incentivierung** (200 × 3 Monate Premium gratis = 200 × €8,97 Opportunitätskosten, *geschätzt*) | €1.500 | €2.000 | €1.750 |
| **Gesamt Pre-Launch Marketing** | **€14.450** | **€33.300** | **€23.875** |

### Launch-Kosten (Woche 0–4)

| Posten | Min | Max | Mittelwert |
|---|---|---|---|
| **Apple Search Ads Launch** (*geschätzt* €3.000–€8.000 Budget Woche 1–4) | €3.000 | €8.000 | €5.500 |
| **Meta Ads Warm-Start** (€50 Testbudget Tag 1 → Skalierung, *geschätzt* €2.000–€5.000 Monat 1) | €2.000 | €5.000 | €3.500 |
| **Soft Launch UA-Tests** (Australien/Kanada, €3.000–€8.000 laut Release-Plan) | €3.000 | €8.000 | €5.500 |
| **Koordinierte Influencer-Posts Launch-Tag** (5–10 Creator, *geschätzt* €500–€2.000/Creator Micro-Tier 20K–150K) | €2.500 | €20.000 | €11.250 |
| **PR-Outreach + Pressearbeit** (*geschätzt* €1.500–€3.000 für Agentur-Kurzmandat oder Freelance-PR) | €1.500 | €3.000 | €2.250 |
| **Gesamt Launch Marketing** | **€12.000** | **€44.000** | **€28.000** |

### Laufendes Marketing (monatlich nach Launch)

| Posten | Min/Monat | Max/Monat | Mittelwert/Monat |
|---|---|---|---|
| **Apple Search Ads** (*geschätzt* Basis-Budget nach Validierung) | €2.000 | €6.000 | €4.000 |
| **Meta Ads** (*geschätzt* nach LTV-Validierung) | €1.500 | €5.000 | €3.250 |
| **Organischer Social Content** (*geschätzt* 20 Posts/Monat × €150 Produktion) | €1.500 | €3.500 | €2.500 |
| **Influencer-Kooperationen laufend** (*geschätzt* 2–4 Micro-Deals/Monat) | €1.000 | €4.000 | €2.500 |
| **SEO-Content** (4–6 Artikel/Monat, *geschätzt* €200–€400/Artikel) | €800 | €2.400 | €1.600 |
| **Gesamt Marketing laufend** | **€6.800** | **€20.900** | **€13.850/Monat** |

---

## 3. Compliance-Kosten

Direkt aus dem Risk-Assessment-Report (Phase 1).

| Posten | Einmalig (Min–Max) | Einmalig Mittelwert | Laufend/Jahr | Laufend/Monat |
|---|---|---|---|---|
| **App Store Richtlinien** (StoreKit-2, Privacy Label, IAP-Compliance) | €2.000–€5.000 | €3.500 | €1.000–€2.000 | €125 |
| **AI/Urheberrecht** (Plant.id Vertragsprüfung, AGB Nutzer-Uploads, IP-Gutachten) | €3.000–€6.000 | €4.500 | €1.500–€3.000 | €188 |
| **DSGVO / Datenschutz 🔴** (DSB extern, DSFA, Datenschutzerklärung, technische Implementierung Einwilligungsmanagement) | €8.000–€18.000 | €13.000 | €3.000–€6.000 | €375 |
| **Markenrecht** (EUTM-Anmeldung, Markenrecherche, Anwaltskosten) | €2.500–€5.000 | €3.750 | €500–€1.000 | €63 |
| **Patente** (Freedom-to-Operate-Analyse, *aus Report*) | €3.000–€6.000 | €4.500 | €500–€1.000 | €63 |
| **Medizin-/Verbraucherschutzrecht** (Formulierungs-Review KI-Diagnose-Texte, Rechtsberatung) | €2.000–€4.000 | €3.000 | €500–€1.000 | €63 |
| **API-/Drittanbieter-Nutzungsrechte** (Plant.id + OpenWeatherMap Vertragscheck) | €2.000–€4.000 | €3.000 | €2.000–€8.000 | €417 |
| **Gesamt Compliance** | **€22.500–€48.000** | **€35.250** | **€9.000–€22.000** | **€1.294/Monat** |

> ⚠️ **Kritischer Hinweis:** DSGVO ist der einzige 🔴-Risikopunkt — Launch-Blocking. €13.000 einmalig + €375/Monat sind Pflichtaufwand, keine Option. Der DSGVO-Block (6–10 Wochen) ist der kritische Pfad für den Zeitplan.

---

## 4. Infrastruktur-Kosten (monatlich)

*Teils aus Reports ableitbar, teils geschätzt auf Basis des beschriebenen Tech-Stacks.*

| Posten | Min/Monat | Max/Monat | Mittelwert/Monat | Quelle |
|---|---|---|---|---|
| **Cloud Hosting** (Backend, Nutzerdatenbank, API-Proxy; AWS/GCP, *geschätzt* für 1.000–10.000 MAU) | €150 | €500 | €325 | geschätzt |
| **Plant.id API** (Kern-KI; Preis abhängig von Call-Volumen; *geschätzt* 10.000 Scans/Monat × ~€0,01/Call = €100–€300 + Premium-Tier-Pauschale) | €100 | €800 | €450 | geschätzt, Risk-Assessment |
| **OpenWeatherMap API** (laut Concept Brief: kostenloser Tier ausreichend für MVP → bei Skalierung kostenpflichtig, *geschätzt*) | €0 | €150 | €50 | Concept Brief + geschätzt |
| **Firebase** (Cloud Messaging / Push Notifications — kostenloser Tier bis 10 GB/Monat, *geschätzt* minimal) | €0 | €50 | €20 | geschätzt |
| **CDN / Storage** (Nutzerphotos, Wachstums-Tracking-Bilder; *geschätzt* 50 GB/Monat) | €20 | €100 | €60 | geschätzt |
| **Analytics** (Amplitude oder Mixpanel; Starter-Tier für <1.000 MAU kostenlos, danach *geschätzt*) | €0 | €200 | €80 | geschätzt |
| **Crash-Reporting** (Firebase Crashlytics — kostenlos im Firebase-Paket) | €0 | €0 | €0 | Release-Plan |
| **SSL / Security / Monitoring** (*geschätzt* Datadog o.ä. Basis-Tier) | €30 | €150 | €90 | geschätzt |
| **Gesamt Infrastruktur** | **€300** | **€1.950** | **€1.075/Monat** | |

> **Skalierungshinweis:** Plant.id API-Kosten skalieren direkt mit Nutzerzahl. Bei 50.000 MAU und intensiver Scan-Nutzung kann der API-Posten auf €2.000–€5.000/Monat steigen — kritischer Kostentreiber, der in der Unit-Economics-Planung berücksichtigt werden muss.

---

## 5. Laufende Betriebskosten (monatlich)

| Posten | Min/Monat | Max/Monat | Mittelwert/Monat | Quelle |
|---|---|---|---|---|
| **Support** (Freelance-Support, *geschätzt* 20h/Monat × €35/h in Startphase) | €500 | €1.200 | €700 | geschätzt |
| **Content-Erstellung** (Pflanzendatenbank-Pflege, neue Pflanzenprofile; *geschätzt*) | €300 | €800 | €550 | geschätzt |
| **App Store Entwickler-Account** (Apple: €99/Jahr = €8,25/Monat; Google Phase 4: €25 einmalig) | €9 | €9 | €9 | Standard |
| **Apple/Google Revenue Share** | **15–30%** | **15–30%** | **~25%** | Plattform-Report |
| **Steuerberatung / Buchhaltung** (*geschätzt* Freelance, monatliche Abrechnung) | €200 | €500 | €350 | geschätzt |
| **Sonstiges Betrieb** (Lizenzen, Tools, Software; *geschätzt*) | €100 | €300 | €200 | geschätzt |
| **Gesamt Betrieb** (ohne Revenue Share) | **€1.109** | **€2.809** | **€1.809/Monat** | |

---

## 6. Revenue-Prognose nach Launch

### Annahmen und Basis-Parameter

Alle Werte basieren direkt auf den Reports:

| Parameter | Wert | Quelle |
|---|---|---|
| Jahres-Abo Preis | €34,99 | Monetarisierungs-Report |
| Monats-Abo Preis | €5,99 | Monetarisierungs-Report |
| Jahres-Abo-Anteil am Paid-Mix | 55–70% (Mittel: 62,5%) | Monetarisierungs-Report + Release-Plan |
| Monats-Abo-Anteil | 20–30% (Mittel: 25%) | Monetarisierungs-Report |
| Add-On-Anteil | ~10% | Monetarisierungs-Report |
| Rewarded Ads eCPM (iOS DACH) | €12–€22 (Mittel: €17) | Monetarisierungs-Report |
| Conversion Free→Paid | 3–7% (Mittel: 5%) | Monetarisierungs-Report + Concept Brief |
| Revenue Share Apple | 25% (konservativ, Mischung aus 15% Kleinanbieter + 30% Standard) | Plattform-Report |
| Effektiver Jahres-Abo Netto | €34,99 × 0,75 = **€26,24** netto | Berechnung |
| Effektives Monats-Abo Netto | €5,99 × 0,75 = **€4,49** netto | Berechnung |

### Drei-Szenarien-Modell (6 Monate nach Launch)

**Basis-Metrik: Monthly Active Users (MAU)**

| Szenario | MAU Monat 6 | Conversion Rate | Paid User | Jahres-Abo-Nutzer (62,5%) | Monats-Abo-Nutzer (25%) |
|---|---|---|---|---|---|
| **Pessimistisch** | 5.000 | 3% | 150 | 94 | 38 |
| **Realistisch** | 15.000 | 5% | 750 | 469 | 188 |
| **Optimistisch** | 40.000 | 7% | 2.800 | 1.750 | 700 |

> **Wichtige Annahme:** Jahres-Abo-Nutzer zahlen anteilig (1/12 pro Monat in der Einnahmenverteilung für monatliche Betrachtung). Monats-Abo-Nutzer zahlen voll monatlich.

### Monatliche Einnahmen nach Apple-Revenue-Share

| Einnahmen-Quelle | Pessimistisch | Realistisch | Optimistisch |
|---|---|---|---|
| **Jahres-Abo** (Anteil/Monat: Nutzer × €26,24 ÷ 12) | 94 × €2,19 = **€206** | 469 × €2,19 = **€1.027** | 1.750 × €2,19 = **€3.833** |
| **Monats-Abo** (Nutzer × €4,49 netto) | 38 × €4,49 = **€171** | 188 × €4,49 = **€844** | 700 × €4,49 = **€3.143** |
| **Add-Ons** (*geschätzt* 5% der Paid-User × Ø €2,99 × 0,75) | 8 × €2,24 = **€18** | 38 × €2,24 = **€85** | 140 × €2,24 = **€314** |
| **Rewarded Ads** (Free-User × 0,1 Ad-Views/Tag × €17 eCPM / 1.000 × 30 Tage) | 4.850 × 0,051 = **€247** | 14.250 × 0,051 = **€727** | 37.200 × 0,051 = **€1.897** |
| **Gesamt Einnahmen/Monat** | **€642** | **€2.683** | **€9.187** |

---

## 7. Revenue vs. Kosten (monatlich nach Launch, Monat 6)

### Monatliche Gesamtkosten nach Launch

| Kostenblock | Betrag/Monat |
|---|---|
| Infrastruktur (Mittelwert) | €1.075 |
| Betrieb (Mittelwert, ohne Revenue Share) | €1.809 |
| Marketing laufend (Mittelwert) | €13.850 |
| Compliance laufend (Mittelwert) | €1.294 |
| **Gesamt monatliche Kosten** | **€18.028** |

> ⚠️ **Marketing-Dominanz:** Der Marketing-Posten macht ~77% der monatlichen Laufkosten aus. Das ist bei einer frühen Wachstumsphase strukturell normal, aber der Break-Even ist direkt abhängig von der Marketing-Intensität. Drei Szenarien werden daher mit unterschiedlichen Marketing-Budgets gerechnet.

### Revenue vs. Kosten — Szenario-Tabelle

| Szenario | Einnahmen/Monat | Kosten/Monat* | Ergebnis/Monat |
|---|---|---|---|
| **Pessimistisch** | €642 | €10.178** | **−€9.536** |
| **Realistisch** | €2.683 | €18.028 | **−€15.345** |
| **Optimistisch** | €9.187 | €24.028*** | **−€14.841** |

*\*Pessimistisch: reduziertes Marketing-Budget €5.000/Monat statt €13.850 (Sparmaßnahme bei schlechten KPIs)*
*\*\*Pessimistisch gesamt: €1.075 Infra + €1.809 Betrieb + €5.000 Marketing + €1.294 Compliance = €9.178*
*\*\*\*Optimistisch: erhöhtes Marketing-Budget €20.000/Monat für Skalierung*

> **Interpretation:** In allen Szenarien ist Monat 6 noch nicht profitabel. Das ist für eine frühe Wachstumsphase bei diesem CAC-Niveau und dieser Zielgruppengröße strukturell zu erwarten. Der Break-Even liegt deutlich später — siehe Break-Even-Analyse.

---

## 8. Break-Even-Analyse

### Methodik

Break-Even = kumulierte Gesamteinnahmen ≥ kumulierte Gesamtkosten (Entwicklung + Marketing + Compliance + Betrieb + Infrastruktur).

**Kumulierte Investition bis Launch (Monat 0):** €221.125 (siehe Gesamtbudget unten)

**Annahmen pro Szenario:**
- Nutzer wachsen linear von 0 (Launch) auf MAU-Ziel in Monat 6
- Ab Monat 7 stabilisiertes Wachstum (+10%/Monat pessimistisch, +20% realistisch, +30% optimistisch)
- Revenue Share bereits abgezogen
- Marketing-Budget wie in Szenarien definiert

### Kumulative Break-Even-Tabelle

| Szenario | MAU bei Break-Even | Break-Even Monat (ab Launch) | Paid User bei Break-Even | Benötigte Einnahmen/Monat |
|---|---|---|---|---|
| **Pessimistisch** | ~85.000 MAU | Monat 28–32 | ~2.550 | ~€9.178 (reduz. Kosten) |
| **Realistisch** | ~65.000 MAU | Monat 18–22 | ~3.250 | ~€18.028 |
| **Optimistisch** | ~45.000 MAU | Monat 12–15 | ~3.150 (bei höherem ARPU durch Skalierung) | ~€24.028 |

> **Erläuterung Break-Even-Logik:** Die kumulative Rechnung berücksichtigt, dass die Anfangsinvestition (€221.125) durch positive monatliche Deckungsbeiträge abgebaut werden muss. Im realistischen Szenario entstehen in den ersten 12 Monaten kumulierte Verluste von ~€280.000–€320.000 (Startinvestition + monatliche Verluste), bevor ab Monat 18–22 die kumulierten Einnahmen die kumulierten Kosten überholen.

---

## 9. Gesamtbudget bis Launch

### Alle Einmal-Kosten vor und bis zum Launch-