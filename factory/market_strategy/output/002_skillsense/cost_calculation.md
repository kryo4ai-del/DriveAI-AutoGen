# Kosten-Kalkulations-Report: SkillSense

---

## Entwicklungskosten

| Posten | Min | Max | Midpoint |
|---|---|---|---|
| **Web-App (Next.js 14, Full-Stack, DACH-Markt)** | 20.000 € | 44.000 € | 32.000 € |
| *Senior Full-Stack-Entwickler, 250–400 Std. à 80–110 €/Std.* | | | |
| **AI-Integration (Anthropic Claude API, Skill-Generierung Pro-Tier)** | 1.500 € | 3.000 € | 2.250 € |
| *Implementierung API-Wrapper, Rate-Limiting, Spending-Caps (geschätzt)* | | | |
| **Backend / Auth / Payments** | 2.000 € | 4.000 € | 3.000 € |
| *Clerk-Integration, Stripe-Webhooks, Supabase-Setup (geschätzt)* | | | |
| **iOS App** | — | — | nicht im Scope (Phase 3+) |
| **Android App** | — | — | nicht im Scope (Phase 3+) |
| **Gesamt Entwicklung** | **23.500 €** | **51.000 €** | **37.250 €** |

> **Basis:** Plattform-Strategie-Report (Agent 8): Web-App 20.000–44.000 €. AI-Integration und Backend als separate Posten geschätzt auf Basis typischer Integrations-Aufwände für Clerk, Stripe, Supabase, Anthropic API — nicht explizit in den Reports ausgewiesen.

---

## Marketing-Budget

| Phase | Posten | Min | Max | Midpoint |
|---|---|---|---|---|
| **Pre-Launch** | Landing Page + Copywriting (DE) | 3.320 € | 7.040 € | 5.180 € |
| | *Davon: Design/Dev 2.500–5.000 €, Domain 20–40 €, Copy 800–1.500 €, Assets 0–500 €* | | | |
| | E-Mail-Tool (ConvertKit, 8 Wochen) | 0 € | 150 € | 75 € |
| | Press Kit Erstellung (geschätzt) | 200 € | 600 € | 400 € |
| | Beta-Programm Anreize (6 Monate Pro × 80 Nutzer = 80 × 0 €, da Gutschrift) | 0 € | 0 € | 0 € |
| **Pre-Launch gesamt** | | **3.520 €** | **7.790 €** | **5.655 €** |
| **Launch** | Product Hunt Listing | 0 € | 0 € | 0 € |
| | PR-Outreach / Presse-Pitching (geschätzt, Eigenleistung möglich) | 0 € | 1.000 € | 500 € |
| | Social Media Content-Produktion Launch-Woche (geschätzt) | 200 € | 800 € | 500 € |
| **Launch gesamt** | | **200 €** | **1.800 €** | **1.000 €** |
| **Monatlich laufend** | SEO-Content / Blog (1–2 Artikel/Monat, geschätzt) | 300 € | 800 € | 550 € |
| | Community-Management Reddit/LinkedIn (geschätzt, Teilzeit) | 200 € | 500 € | 350 € |
| | Newsletter-Tool (ConvertKit/Beehiiv, Wachstum) | 30 € | 150 € | 90 € |
| | Paid Ads (nicht im MVP empfohlen — erst ab PMF) | 0 € | 0 € | 0 € |
| **Monatlich laufend gesamt** | | **530 €** | **1.450 €** | **990 €** |
| **Gesamt Marketing Q1** *(Pre-Launch + Launch + 3× Monatlich)* | | **5.310 €** | **13.940 €** | **9.625 €** |

> **Basis:** Marketing-Strategie-Report (Agent 10): Landing Page 3.320–7.040 €. Monatliche Werte für SEO, Community, Newsletter geschätzt auf Basis SaaS-Frühphasen-Benchmarks — in den Reports nicht detailliert ausgewiesen.

---

## Compliance-Kosten

| Posten | Einmalig (Min) | Einmalig (Max) | Laufend/Jahr |
|---|---|---|---|
| **DSGVO-Beratung + Datenschutzerklärung + AVV-Prüfung** | 2.500 € | 4.500 € | — |
| **Technische DSGVO-Implementierung** *(Cookie-Banner, Consent, Account-Deletion)* | 1.500 € | 3.000 € | — |
| **DSGVO-Compliance Jahrescheck** | — | — | 800–1.500 € |
| **AGB / Nutzungsbedingungen** *(Anwaltscheck §312j BGB, Widerrufsrecht)* | 300 € | 800 € | — |
| **Impressum / TMG §5** *(im DSGVO-Paket oft enthalten)* | 0 € | 200 € | — |
| **AI-generierter Content / Lizenzstrategie Skill-Datenbank** | 1.000 € | 2.000 € | — |
| **KI-Kennzeichnung UI-Implementierung (EU AI Act Art. 50)** | 500 € | 1.500 € | — |
| **Markenrecherche EUIPO + DPMA** | 800 € | 1.500 € | — |
| **EU-Markenanmeldung Klassen 35+42** *(empfohlen, optional im MVP)* | 1.500 € | 2.500 € | — |
| **Patent-Freiraumrecherche** *(Jaccard + Security-Pattern-Matching)* | 800 € | 1.500 € | — |
| **Anthropic ToS + Drittanbieter-ToS-Prüfung** *(bündelbar mit DSGVO)* | 500 € | 1.000 € | — |
| **Haftungs-Disclaimer** *(bündelbar mit AGB)* | 300 € | 500 € | — |
| **Stripe Tax Konfiguration** *(EU-OSS, technisch)* | 200 € | 500 € | — |
| **Gesamt Compliance einmalig** | **9.900 €** | **19.500 €** | **800–1.500 €/Jahr** |
| **Gesamt Compliance laufend (Monat)** | — | — | **67–125 €/Monat** |

> **Basis:** Risk-Assessment-Report (Phase 1): DSGVO 4.000–9.000 € einmalig + 800–1.500 €/Jahr; Urheberrecht 1.500–3.500 €; Markenrecht 2.300–4.000 €; Patente 800–1.500 €; ToS-Prüfung 500–1.000 €; Haftung/Disclaimer 800–1.500 €. Einzelposten AGB, Stripe Tax als Teilmengen der jeweiligen Risikobewertungen geschätzt. Markenanmeldung als optionaler Posten separat ausgewiesen.

---

## Infrastruktur-Kosten (monatlich)

### MVP-Phase: 0–500 Nutzer

| Posten | Min/Monat | Max/Monat | Midpoint/Monat | Quelle |
|---|---|---|---|---|
| **Vercel Hosting** *(Pro-Plan ab nennenswertem Traffic)* | 0 € | 20 € | 10 € | Agent 8: "0–150 €/Monat (0–500 Nutzer)" |
| **Supabase** *(Datenbank, Auth-Backup, Free → Pro)* | 0 € | 25 € | 12 € | Agent 8: inkludiert in 0–150 €/Monat |
| **Clerk** *(Authentication)* | 0 € | 25 € | 12 € | Agent 8: inkludiert in 0–150 €/Monat |
| **Stripe** *(Payments, ca. 1,4% + 0,25 € je Transaktion)* | variabel | variabel | ~1–3 % des Revenue | Agent 8: Stripe 1,4% + 0,25 € EU |
| **Anthropic Claude API** *(Pro-Tier Skill-Generierung, 5 Calls/Nutzer/Monat)* | 5 € | 50 € | 25 € | geschätzt: ~0,05–0,10 €/Call × 500 Pro-Nutzer × 5 Calls |
| **Analytics** *(Plausible, DSGVO-konform, empfohlen in Agent 11)* | 9 € | 9 € | 9 € | Plausible.io Standardpreis |
| **Error-Tracking / Crash-Reporting** *(Sentry Free Tier → Team)* | 0 € | 26 € | 13 € | Sentry.io Free bis 5k Events/Monat |
| **Uptime-Monitoring** *(Better Uptime / UptimeRobot Free)* | 0 € | 20 € | 7 € | Agent 11: "Free Tier ausreichend für MVP" |
| **Log-Aggregation** *(Axiom / Logtail Free Tier)* | 0 € | 15 € | 5 € | Agent 11: "Free Tier ausreichend" |
| **Push Notifications** | 0 € | 0 € | 0 € | Nicht im Produkt-Scope (kein Daily-Driver) |
| **CDN / Storage** *(Vercel CDN inkludiert; Skill-Datenbank-JSONs statisch)* | 0 € | 10 € | 3 € | Agent 8: inkludiert in Vercel |
| **Gesamt Infrastruktur MVP** | **14 €** | **200 €** | **96 €/Monat** | |

### Scale-Phase: 500–5.000 Nutzer

| Posten | Min/Monat | Max/Monat | Midpoint/Monat |
|---|---|---|---|
| **Vercel + Supabase + Clerk** *(skalierte Tiers)* | 300 € | 500 € | 400 € |
| **Anthropic API** *(~2.000 Pro-Nutzer × 5 Calls)* | 50 € | 200 € | 125 € |
| **Sentry / Analytics / Monitoring** | 50 € | 100 € | 75 € |
| **Gesamt Infrastruktur Scale** | **400 €** | **800 €** | **600 €/Monat** |

> **Basis:** Agent 8: "MVP-Phase 0–150 €/Monat, Scale-Phase 300–800 €/Monat". Anthropic-API-Kosten und Plausible geschätzt. Push Notifications explizit ausgeschlossen da kein Use-Case im Produkt.

---

## Laufende Betriebskosten (monatlich)

| Posten | Min/Monat | Max/Monat | Midpoint/Monat | Basis |
|---|---|---|---|---|
| **Support** *(Crisp/Tawk.to kostenlos; Zeitaufwand Gründer 5–10 Std/Monat)* | 0 € | 500 € | 250 € | Agent 11: "Crisp Chat oder Tawk.to kostenlos"; Zeitwert geschätzt |
| **Content-Erstellung** *(SEO-Blog, Social Media, Newsletter)* | 300 € | 800 € | 550 € | Agent 10: monatlich laufend |
| **App Store Gebühren** | 0 € | 0 € | 0 € | Keine native App im Scope |
| **Apple Developer Account** | 0 € | 0 € | 0 € | Nicht im Scope Phase 1–3 |
| **Google Play Account** | 0 € | 0 € | 0 € | Nicht im Scope Phase 1–3 |
| **Apple/Google Revenue Share** | **0 %** | **0 %** | **0 %** | Web-Direct via Stripe; kein App-Store-Cut |
| **Stripe Revenue Share** | ~1,4–2 % | ~1,4–2 % | ~1,7 % | Agent 8: 1,4% + 0,25 € je Transaktion |
| **Domain / SSL** | 2 € | 4 € | 3 € | Agent 10: 20–40 €/Jahr ÷ 12 |
| **Buchhaltungssoftware** *(Lexoffice/Sevdesk, geschätzt)* | 10 € | 30 € | 20 € | geschätzt |
| **Gesamt Betrieb** | **312 €** | **1.334 €** | **823 €/Monat** | |

> **Hinweis:** Da SkillSense eine Web-App ohne nativen App Store ist, entfallen Apple/Google Revenue Share (15–30 %) vollständig. Revenue-Berechnung erfolgt nach Stripe-Gebühr (~1,7 % effektiv).

---

## Revenue-Modell: Grundannahmen

Aus den Reports extrahierte Parameter:

| Parameter | Wert | Quelle |
|---|---|---|
| Pro Monatlich | 9,99 €/Monat | Monetarisierungs-Report |
| Pro Jährlich | 79 €/Jahr = 6,58 €/Monat-Äquivalent | Monetarisierungs-Report |
| Team | 24,99 €/Seat/Monat | Monetarisierungs-Report |
| IAP Single Scan | 1,99 € einmalig | Monetarisierungs-Report |
| Free-to-Paying Conversion | 3–8 % | Monetarisierungs-Report (SaaS Benchmark) |
| Jahresabo-Anteil an Zahlern | 20–35 % | Monetarisierungs-Report (Paddle 2024) |
| Churn Monats-Abo | 5–10 %/Monat | Monetarisierungs-Report |
| Churn Jahres-Abo | 20–35 %/Jahr | Monetarisierungs-Report |
| Revenue Share App Store | 0 % | Plattform-Strategie: Web-Direct |
| Stripe-Gebühr | ~1,7 % effektiv | Plattform-Strategie-Report |
| Nutzerwachstum | — | nicht in Reports quantifiziert → geschätzt |

---

## Revenue vs. Kosten (monatlich nach Launch — Steady State Monat 3–6)

### Nutzerbasis-Annahmen pro Szenario

| Szenario | Registrierte Nutzer | Zahlende Nutzer | Davon Monatsabo | Davon Jahresabo |
|---|---|---|---|---|
| **Pessimistisch** | 300 | 3 % = 9 | 7 | 2 |
| **Realistisch** | 800 | 5 % = 40 | 28 | 12 |
| **Optimistisch** | 2.000 | 7 % = 140 | 91 | 49 |

### Revenue-Berechnung (nach Stripe-Abzug ~1,7 %)

**Pessimistisch:**
- 7 × 9,99 € × (1 − 1,7 %) = **68,67 €**
- 2 × 6,58 € × (1 − 1,7 %) = **12,94 €** *(Jahresabo als monatlicher Equivalent)*
- IAP geschätzt (3 × 1,99 €) = **5,82 €**
- **Gesamt Revenue: ~87 €/Monat**

**Realistisch:**
- 28 × 9,99 € × (1 − 1,7 %) = **274,66 €**
- 12 × 6,58 € × (1 − 1,7 %) = **77,65 €**
- IAP geschätzt (15 × 1,99 €) = **29,10 €**
- **Gesamt Revenue: ~381 €/Monat**

**Optimistisch:**
- 91 × 9,99 € × (1 − 1,7 %) = **892,40 €**
- 49 × 6,58 € × (1 − 1,7 %) = **317,07 €**
- IAP geschätzt (50 × 1,99 €) = **97,02 €**
- **Gesamt Revenue: ~1.306 €/Monat**

### Kosten pro Szenario (Monat 3–6, MVP-Phase)

| Posten | Pessimistisch | Realistisch | Optimistisch |
|---|---|---|---|
| Infrastruktur | 50 € | 100 € | 200 € |
| Betrieb | 400 € | 650 € | 900 € |
| Marketing laufend | 530 € | 750 € | 1.100 € |
| Compliance laufend | 67 € | 100 € | 125 € |
| **Gesamt Kosten** | **1.047 €** | **1.600 €** | **2.325 €** |

### Gesamttabelle

| Szenario | Einnahmen/Monat | Kosten/Monat | Ergebnis/Monat |
|---|---|---|---|
| **Pessimistisch** | **~87 €** | **~1.047 €** | **−960 €** |
| **Realistisch** | **~381 €** | **~1.600 €** | **−1.219 €** |
| **Optimistisch** | **~1.306 €** | **~2.325 €** | **−1.019 €** |

> ⚠️ **Interpretation:** Alle Szenarien sind in den ersten Monaten nach Launch negativ — das ist für Early-Stage-SaaS strukturell normal. Der Negativsaldo ist im optimistischen Szenario sogar höher als im pessimistischen, weil Marketingausgaben mit dem Wachstum skalieren. Das Ziel ist nicht monatelanger Monatsprofitabilität, sondern Break-Even auf kumulativer Basis.

---

## Break-Even Analyse

Break-Even = kumulierte Einnahmen ≥ kumulierte Gesamtkosten (Entwicklung + Pre-Launch + laufend)

**Kumulierte Startkosten bis Launch:**
- Entwicklung Midpoint: 37.250 €
- Marketing Pre-Launch + Launch Midpoint: 6.655 €
- Compliance einmalig Midpoint: 14.700 €
- Infrastruktur Setup (3 Monate vor Launch): 300 €
- **Summe ohne Puffer: ~58.905 €**

**Break-Even-Berechnung (monatlicher Nettobeitrag = Revenue − laufende Kosten):**

| Szenario | Nettobeitrag/Monat | Monate bis Break-Even | Break-Even Monat | Benötigte zahlende Nutzer |
|---|---|---|---|---|
| **Pessimistisch** | −960 € | ∞ (kein Break-Even) | — | >600 zahlende Nutzer nötig |
| **Realistisch** | −1.219 € | Positiver Nettobeitrag ab ~80–100 zahlenden Nutzern; Break-Even kumulativ ca. Monat 18–24 | **Monat 20** | **~80–100 zahlende Nutzer** |
| **Optimistisch** | −1.019 € (Monat 3–6); positiv ab ~200 Zahlern | Break-Even kumulativ ca. Monat 12–15 | **Monat 13** | **~200 zahlende Nutzer** |

**Zur Erläuterung der Nutzerschwellen:**

- Ab **~105 zahlenden Nutzern** (Midpoint Abo-Mix) übersteigt der monatliche Revenue die laufenden Kosten (~1.600 €/Monat realistisch) → monatlicher Cash-Flow positiv
- Kumulativer Break-Even (Rückzahlung der Startkosten) erfordert deutlich mehr Zeit und Nutzer

| Szenario | Break-Even Monat | Benötigte zahlende Nutzer |
|---|---|---|
| **Pessimistisch** | kein Break-Even in 24 Monaten | >600 |
| **Realistisch** | **Monat 20** | **~105** |
| **Optimistisch** | **Monat 13** | **~200** |

---

## Gesamtbudget bis Launch

| Posten | Min | Max | Midpoint |
|---|---|---|---|
| **Entwicklung Web-App** | 23.500 € | 51.000 € | 37.250 € |
| **Marketing Pre-Launch + Launch** | 3.720 € | 9.590 € | 6.655 € |
| **Compliance einmalig** | 9.900 € | 19.500 € | 14.700 € |
| **Infrastruktur Setup (3 Monate Pre-Launch)** | 42 € | 600 € | 300 € |
| **Zwischensumme** | **37.162 €** | **80.690 €** | **58.905 €** |
| **Puffer 25 %** | **9.290 €** | **20.173 €** | **14.726 €** |
| **Gesamtbudget bis Launch** | **46.452 €** | **100.863 €** | **73.631 €** |

---

## Monatliche Kosten nach Launch

| Posten | Min/Monat | Max/Monat | Midpoint/Monat |
|---|---|---|