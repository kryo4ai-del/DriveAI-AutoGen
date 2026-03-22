# Legal-Research-Report: Brain Training Puzzle App

**Erstellt:** Juni 2025
**Basis:** Concept Brief + Web-Recherche-Ergebnisse (oben dokumentiert)
**Status:** KI-basierte Ersteinschätzung — keine Rechtsberatung

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Risikostufe | Begründung |
|---|---|---|---|
| 1 | Monetarisierung & Glücksspielrecht | 🟡 Mittel | Battle Pass + Rewarded Ads berühren Regulierungsgraubereiche |
| 2 | App Store Richtlinien | 🟡 Mittel | IAP-Pflicht, Abo-Disclosure, Rewarded Ads haben spezifische Regeln |
| 3 | AI-Content — Urheberrecht | 🟡 Mittel | KI-adaptiver Content + evtl. AI-generierte Puzzles/Assets |
| 4 | Datenschutz (DSGVO / COPPA) | 🔴 Hoch | KI-Nutzerprofil + Social Features + EU-Zielmarkt |
| 5 | Jugendschutz (USK / PEGI) | 🟢 Niedrig | Zielgruppe 35–54, aber formale Einstufungspflicht besteht |
| 6 | Social Features — Auflagen | 🟡 Mittel | Leaderboards + Freundes-Challenges bei potenziell gemischter Nutzerbasis |
| 7 | Markenrecht — Namenskonflikt | 🟡 Mittel | Generischer Namensraum "Brain Training" ist stark besetzt |
| 8 | Wissenschaftskommunikation / FTC | 🔴 Hoch | Cognitive-Claims direkt im FTC-Radar (Lumosity-Präzedenz) |
| 9 | Patente | 🟢 Niedrig | Keine bekannten Sperrpatente, aber Screening empfohlen |

---

## 1. Monetarisierung & Glücksspielrecht

### Aktuelle Gesetzeslage

**Battle Pass:**
Battle Passes gelten in den meisten Jurisdiktionen **nicht als Glücksspiel**, solange der Nutzer im Voraus weiß, was er erhält (transparente Reward-Struktur) und keine Zufallselemente bei der Reward-Verteilung bestehen. Die Abgrenzung ist entscheidend: Ein Battle Pass mit fixer Progression (du weißt, dass auf Level 7 Skin X wartet) ist regulatorisch grundverschieden von Loot Boxes mit verdeckten Wahrscheinlichkeiten.

> ⚠️ **Das Konzept beschreibt ausschließlich kosmetische Rewards ohne Zufallsmechanik** — das ist die regulatorisch sichere Variante. Dieser Punkt muss in der finalen Feature-Spezifikation explizit verankert bleiben.

**Rewarded Ads:**
Rewarded Ads (Nutzer schaut Werbung, erhält Hinweis oder Extra-Session) berühren **kein Glücksspielrecht**, solange kein monetärer Einsatz und kein zufallsbasierter Gewinn beteiligt ist. Sie unterliegen aber den Werberecht-Standards der jeweiligen Jurisdiktion.

### Länderspezifisch

**🇪🇺 EU (gesamt):**
- Das Europäische Parlament hat im Oktober 2025 neue Maßnahmen gefordert, die ausdrücklich **Loot Boxes als glücksspielähnliche Mechaniken für Minderjährige** regulieren wollen (Europäisches Parlament, 13. Oktober 2025).
- Der vorliegende Entwurf zielt auf ein Verbot von Loot Boxes in für Minderjährige zugänglichen Spielen — **nicht auf transparente Battle-Pass-Strukturen**.
- Status: Noch kein verbindliches EU-Gesetz, aber politische Richtung ist klar. Für ein App-Launch 2026/2027 ist eine Beobachtung der Legislativentwicklung Pflicht.

**🇧🇪 Belgien / 🇳🇱 Niederlande:**
- Belgien hat Loot Boxes bereits 2018 verboten (Gaming Commission). Niederländische KSA hat 2019 ähnliche Positionen eingenommen.
- Battle Passes mit fixer Reward-Struktur ohne Zufallselemente sind in beiden Ländern **nicht explizit verboten**, aber die nationalen Behörden schauen genau hin.
- **Empfehlung:** Für EU-Launch die Reward-Mechanik durch einen lokalen Anwalt auf belgische/niederländische Konformität prüfen lassen.

**🇩🇪 Deutschland:**
- Glücksspielstaatsvertrag 2021 (GlüStV 2021) reguliert Online-Glücksspiele. Battle Passes ohne Zufallselemente fallen **nicht unter diese Definition**.
- Kein spezifisches Problem für dieses Konzept, sofern keine verdeckten Wahrscheinlichkeitsmechaniken eingebaut werden.

**🇺🇸 USA:**
- Auf Bundesebene kein spezifisches Loot-Box-Gesetz verabschiedet (Stand Juni 2025). FTC hat Interesse signalisiert, aber keine verbindliche Regulierung erlassen.
- Einzelstaatliche Gesetze: Keine relevante Anti-Loot-Box-Gesetzgebung für Battle-Pass-Modelle bekannt.
- Rewarded Ads unterliegen den **FTC Endorsement Guides** und allgemeinen Werbestandards — aber kein spezifisches Glücksspielproblem.

**🇨🇳 China:**
- Chinas **Online Game Administration Regulations** (2023, in Kraft 2025) verlangen Echtnamensregistrierung, Ausgabelimits für Minderjährige und detaillierte IAP-Disclosure.
- China ist für dieses Konzept **kein Primärmarkt** (iOS-first, Nordamerika/Westeuropa/Australien laut Brief) — aber falls ein China-Launch erwogen wird, ist ein separates Compliance-Projekt erforderlich.
- **Empfehlung:** China vorerst aus dem Launch-Scope ausklammern.

**🇦🇺 Australien:**
- Australien hat 2024 Klassifizierungsgesetze reformiert. Loot Boxes sind nicht explizit verboten, müssen aber im App-Rating offengelegt werden. Battle Passes ohne Zufallsmechanik: kein direktes Problem.

### Relevanz für dieses Konzept

🟡 **Mittel** — Das Konzept ist durch die Wahl eines transparenten Battle Passes ohne Loot-Box-Mechanik **regulatorisch gut positioniert**. Die Risiken entstehen aus:
1. Der noch laufenden EU-Regulierungsdebatte (Monitoring erforderlich)
2. Der Notwendigkeit, die Reward-Mechanik in Belgien/Niederlanden formal prüfen zu lassen
3. Der technischen Implementierung: Wenn der Battle Pass auch nur versehentlich Zufallselemente enthält, ändert sich die Risikostufe auf 🔴.

### Quellen
- Europäisches Parlament, Pressemitteilung, 13.10.2025: *"New EU measures needed to make online services safer for minors"*
- Reddit/Gaming, 2025: *"EU moving to regulate loot boxes, pay to win and virtual currencies"*
- siege.gg, 2025: *"Several EU Countries Have Introduced Stricter Regulations on Loot Boxes in Games in 2025"*
- Belgische Gaming Commission, 2018 (Loot-Box-Entscheidung, weiterhin gültig)

---

## 2. App Store Richtlinien

### Apple App Store

**In-App Purchases (IAP):**
- Apple verlangt, dass **alle digitalen Inhalte und Abonnements zwingend über das Apple IAP-System** abgewickelt werden (App Review Guidelines, Sektion 3.1.1).
- Apple nimmt **15–30% Provision** (15% für Abonnements nach dem ersten Jahr, 30% im ersten Jahr). Dies ist ein direkter Kalkulationsfaktor für den Preispunkt ($6,99–8,99/Monat im Brief).

> ⚠️ **Konsequenz für Kalkulation:** Bei $6,99/Monat verbleiben nach Apple-Provision (~30% Jahr 1) effektiv ~$4,89. Der Break-even-LTV-Kalkulation muss dies berücksichtigen. Nach EU Digital Markets Act (DMA) kann für EU-Nutzer ab iOS 17.4 alternativ auf externe Zahlungssysteme verwiesen werden — unter strengen Bedingungen und mit eigener Apple-Fee von 27%.

**Abo-Disclosure-Pflichten:**
- Apple verlangt **klare Disclosure** von Abo-Preis, Abrechnungszeitraum und Kündigungsmodalitäten **vor** dem Kaufabschluss (App Review Guidelines, 3.1.2).
- **Auto-renewing Subscriptions** erfordern spezifische UI-Elemente — kein Dark Pattern erlaubt.

**Rewarded Ads:**
- Rewarded Ads sind im Apple App Store grundsätzlich erlaubt.
- **Einschränkung:** Apple verlangt, dass Werbetreibende-Tracking über **App Tracking Transparency (ATT)** explizit vom Nutzer erlaubt wird (iOS 14.5+). Rewarded Ads ohne ATT-Consent werden deutlich weniger Revenue generieren (CPM-Einbruch bis zu 60% bei Nicht-Consent laut Branchenberichten).
- **SKAdNetwork** ist Pflicht für Attribution ohne Nutzer-Tracking-Consent.

**App-Review-Risiken:**
- Apples Guidelines verbieten **irreführende Beschreibungen der App-Funktionalität** (2.3.1). Die Formulierung kognitiver Trainingseffekte in App Store Beschreibung und Screenshots muss präzise sein — sonst Rejection-Risiko. Dies verbindet sich direkt mit dem FTC-Thema in Abschnitt 8.

**Aktueller Stand (2025):**
- Der DMA zwingt Apple, alternative App Stores in der EU zuzulassen (ab iOS 17.4). Für dieses Konzept primär relevant als Chance für alternative Zahlungsabwicklung in der EU — aber mit erheblicher Implementierungskomplexität.

### Google Play Store

**IAP und Abos:**
- Google Play verlangt ebenfalls die Nutzung des **Google Play Billing System** für digitale Inhalte (mit 15–30% Provision, ähnliche Struktur wie Apple).
- Seit 2022 erlaubt Google in bestimmten Ländern (inkl. USA) alternative Zahlungsmethoden mit einer reduzierten "User Choice Billing"-Fee — aktuell ~4% unter der Standardprovision.

**Rewarded Ads:**
- Google Play erlaubt Rewarded Ads explizit.
- **Google Play Families Policy:** Falls die App auch für Kinder/Familien vermarktet wird, gelten striktere Werberegeln. Da die Zielgruppe 35–54 ist und die App nicht im "Designed for Families"-Programm eingetragen wird, ist dies voraussichtlich nicht relevant — muss aber bei der Store-Listing-Einrichtung explizit korrekt konfiguriert werden.

**Datenerhebung:**
- Google Play verlangt seit 2022 den **Data Safety-Abschnitt** im Store Listing: vollständige Disclosure aller erhobenen Daten, Nutzungszweck und Drittanbieter-Weitergabe. Dies ist für den KI-Adaptivitätslayer mit Nutzerprofilen besonders relevant.

### Relevanz

🟡 **Mittel** — Kein grundsätzlicher Konflikt mit den Guidelines, aber mehrere operative Compliance-Punkte:
1. IAP-Provision einkalkulieren (Preis-Kalkulation anpassen)
2. Abo-Disclosure-UI muss guidelines-konform sein (kein Dark Pattern)
3. ATT-Framework für Rewarded Ads implementieren (Revenue-Impact einkalkulieren)
4. Data Safety / Privacy Nutrition Label korrekt befüllen
5. App-Beschreibung für kognitive Claims vorab mit Guidelines abgleichen

### Quellen
- Apple Developer, App Review Guidelines (aktuell, aufgerufen Juni 2025): developer.apple.com/app-store/review/guidelines/
- LinkedIn/Sonu Dhankhar: *"App Store Policy Updates 2025: Impact on Monetization & Ads"*, 2025
- twinr.dev: *"iOS In-App Purchase Compliance: Full Guide For 2025"*, 2025

---

## 3. AI-generierter Content — Urheberrecht

### Aktuelle Rechtslage

**USA:**
- Das U.S. Copyright Office hat am **29. Januar 2025 Part 2 seiner AI-Copyright-Guidance** veröffentlicht.
- **Kernaussage:** Rein KI-generierte Werke sind **nicht urheberrechtlich schutzfähig** unter US-Recht. Werke mit signifikanter menschlicher kreativer Auswahl und Gestaltung können Schutz genießen — der KI-generierte Teil selbst jedoch nicht.
- **Praktische Konsequenz:** KI-generierte Puzzle-Inhalte, die ohne substantielle menschliche kreative Überarbeitung veröffentlicht werden, können von Dritten frei kopiert werden. Das Unternehmen kann dafür keinen Copyright-Schutz beanspruchen.

**EU:**
- Die EU-KI-Verordnung (AI Act, in Kraft seit August 2024, schrittweise Anwendung) adressiert Urheberrecht indirekt. Für generative KI-Systeme bestehen **Transparenzpflichten** (Offenlegung, dass Inhalte KI-generiert sind) — relevant falls Puzzle-Content marketingseitig als "handgefertigt" kommuniziert wird.
- EU-Urheberrecht: Ähnliche Position wie USA — keine automatische Schutzfähigkeit für rein maschinell generierte Werke.

**Praktische Fallunterscheidung für dieses Konzept:**

| KI-Verwendung | Urheberrecht-Risiko | Handlungsempfehlung |
|---|---|---|
| KI-adaptiver Schwierigkeitsgrad (Algorithmus) | Niedriges Risiko | Eigenentwickelter Algorithmus ist Geschäftsgeheimnis, kein Copyright-Problem |
| KI-generierte Puzzle-Layouts | Mittleres Risiko | Ohne menschliche Überarbeitung: kein Copyright-Schutz für das Unternehmen möglich |
| KI-generierte visuelle Assets (Monument-Valley-Ästhetik) | Hohes Risiko | Kombination aus Copyright-Lücke + potenziellem Training-Daten-Konflikt |
| Trainingsdaten des KI-Modells | Mittleres Risiko | Falls das Modell auf geschützten Spielen trainiert wurde: potenzielle Haftung |

### Kommerzielle Nutzung

- Reuters/Practical Law (März 2026, rückblickend auf 2025): *"Fair use arguments may be weaker where AI outputs directly compete with copyrighted content in active licensing markets."*
- Das bedeutet: KI-generierte visuelle Inhalte, die im Stil von Monument Valley (ustwo games) generiert werden, sind ein **aktives Haftungsrisiko**, wenn ustwo games argumentieren kann, dass ein Wettbewerbs-Substitut vorliegt.

> ⚠️ **Kritischer Hinweis:** Das Konzept positioniert sich explizit als "Monument-Valley-Niveau" ästhetisch. Falls KI-Tools verwendet werden, um diesem Stil nahe zu kommen, muss ein Anwalt den konkreten Workflow prüfen. Die Grenze zwischen Stil-Inspiration (nicht schutzfähig) und konkreter Werk-Imitation (möglicherweise schutzfähig) ist 2025 rechtlich noch nicht final geklärt.

### Relevanz

🟡 **Mittel** — mit zwei Caveat-Bereichen die auf 🔴 eskalieren können:
1. KI-generierte Assets für visuelle Ästhetik: Workflow-Prüfung durch Anwalt empfohlen
2. Eigenentwickelter Adaptivitäts-Algorithmus: kein direktes Urheberrechtsproblem, aber Schutz als Trade Secret erwägen

### Quellen
- U.S. Copyright Office, *"Copyright and Artificial Intelligence, Part 2"*, 29.01.2025: copyright.gov/ai/
- Reuters/Practical Law, *"Copyright Law in 2025: Courts begin to draw lines around AI training"*, 16.03.2026
- Michael Best & Friedrich LLP, *"AI + Copyright: What Every Business Needs to Know in 2025"*, 2025

---

## 4. Datenschutz (DSGVO / COPPA)

### DSGVO-Anforderungen

**Betroffene Datenverarbeitungen in diesem Konzept:**

| Datenverarbeitung | DSGVO-Relevanz | Rechtsgrundlage |
|---|---|---|
| Kognitions-Profil aus Kalibrierungs-Puzzle | **Hoch** — ggf. Gesundheitsdaten (Art. 9) | Explizite Einwilligung oder vertragliche Notwendigkeit |
| KI-adaptiver Schwierigkeitsgrad (Nutzungsdaten) | Hoch | Berechtigtes Interesse oder Einwilligung |
| Social Features / Leaderboard | Mittel | Einwilligung (Opt-in laut Brief — korrekt) |
| Streaks / Nutzungsverhalten | Mittel | Vertragserfüllung oder Einwilligung |
| Rewarded Ads (Tracking) | Hoch | Explizite Einwilligung (Art. 6 Abs. 1a) |
| Firebase/PlayFab Backend-Daten | Mittel | Auftragsverarbeitungsvertrag (AVV) Pflicht |

**Kritischer Punkt — Kognitionsdaten als Gesundheitsdaten:**
Das 60-Sekunden-Kalibrierungs-Puzzle generiert ein *"kognitives Profil"*. Wenn dieses Profil Rückschlüsse auf psychische Gesundheit, kognitive Einschränkungen oder neurologische Zustände erlaubt, könnte es als **Gesundheitsdaten nach Art. 9 DSGVO** eingestuft werden. Das würde die Verarbeitungsanforderungen signifikant erhöhen (explizite Einw