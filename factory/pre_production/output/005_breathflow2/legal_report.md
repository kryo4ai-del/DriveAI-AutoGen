# Legal-Research-Report: Minimalistische Atem-Übungs-App

**Erstellt:** Juni 2025
**Basis:** Concept Brief (Durchlauf #005), Web-Recherche-Ergebnisse, öffentlich zugängliche Quellen
**Disclaimer:** KI-basierte Ersteinschätzung — keine rechtsverbindliche Beratung.

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Relevanz-Einschätzung | Priorität |
|---|---|---|---|
| 1 | Monetarisierung & App-Store-Compliance (OTP/IAP) | Direkt relevant (OTP-Modell geplant) | 🔴 Hoch |
| 2 | App Store Richtlinien (Apple / Google) | Direkt relevant (Plattform-Launch) | 🔴 Hoch |
| 3 | AI-generierter Content — Urheberrecht | Bedingt relevant (falls Assets KI-generiert) | 🟡 Mittel |
| 4 | Datenschutz (DSGVO / COPPA) | Relevant — auch bei Offline-Apps mit lokalem Storage | 🟡 Mittel |
| 5 | Jugendschutz (USK / PEGI / IARC) | Relevant für DACH-Markt und Store-Listing | 🟢 Niedrig |
| 6 | Social Features — Auflagen | Nicht relevant (kein Social-Layer im Konzept) | ⚪ Entfällt |
| 7 | Markenrecht — Namenskonflikt | Relevant vor App-Name-Festlegung | 🟡 Mittel |
| 8 | Patente (Animations-Mechaniken) | Bedingt relevant — Recherche-Lücke | 🟡 Mittel |

---

## 1. Monetarisierung & Glücksspielrecht

### Aktuelle Gesetzeslage

Das klassische **Glücksspielrecht** (Loot Boxes, randomisierte Belohnungen, Pay-to-Win-Mechaniken) ist für dieses Konzept **strukturell nicht einschlägig.** Der geplante One-Time-Purchase (OTP) schaltet definierte, vorab kommunizierte Features frei (zwei zusätzliche Atemtechniken + Wochenstatistik) — kein Zufallselement, keine verdeckten Kosten, keine Subscription-Falle.

Relevant ist stattdessen das **In-App-Purchase-Recht** im Kontext der Plattform-Richtlinien sowie das **EU-Verbraucherrecht** (Preistransparenz, Widerrufsrecht bei digitalen Inhalten).

### Länderspezifisch

**EU / DACH:**
- Die EU-Richtlinie über digitale Inhalte (2019/770, umgesetzt in DE ab 2022) regelt Verträge über digitale Produkte. Bei einem OTP für eine App gilt: Der Nutzer muss **vor dem Kauf** klar informiert werden über den Leistungsumfang. Das Konzept (definierte Feature-Freischaltung) erfüllt diese Anforderung strukturell — vorausgesetzt, die App-Store-Produktseite und der In-App-Kaufdialog beschreiben den Umfang eindeutig.
- **Widerrufsrecht:** Bei digitalen Inhalten, die sofort nach dem Kauf nutzbar sind, erlischt das 14-tägige Widerrufsrecht bei ausdrücklicher Zustimmung des Nutzers (§ 356 Abs. 5 BGB / Art. 16 lit. m Verbraucherrechte-RL). Apple und Google handhaben dies über ihre eigenen Kaufprozesse — der Entwickler ist hier nachgelagert, aber sollte dies in den AGB erwähnen.
- **Österreich / Schweiz:** Vergleichbare Regelungen, kein erhöhter Sonderaufwand für dieses Konzept.

**USA:**
- Kein bundeseinheitliches Gesetz für digitale In-App-Käufe (Stand 2025). Relevante Regulierung läuft primär über die FTC (Transparenzanforderungen) und bundesstaatliche Consumer-Protection-Laws (besonders California CCPA, aber für eine Offline-App mit lokalem Storage ohne Datenweitergabe weitgehend nicht einschlägig — siehe Abschnitt 4).
- **Keine spezifischen Glücksspiel-Risiken** bei festem OTP ohne Zufallskomponente.

**China:**
- ⚠️ **Datenlücke / Nicht primär adressiert im Konzept.** China-Launch ist im Concept Brief nicht als Zielmarkt genannt (DACH + englischsprachige Märkte). Für einen späteren China-Launch wären gesonderte Anforderungen (ICP-Lizenz, spezifische App-Store-Regeln über Drittanbieter) zu prüfen — hier nicht weiter ausgeführt.

**Belgien / Niederlande (Loot-Box-Regulierung):**
- Beide Länder haben Loot Boxes als Glücksspiel eingestuft (BE: 2018, NL: Gaming Authority 2022). **Nicht einschlägig** für dieses Konzept — ein OTP mit definiertem Leistungsumfang ohne Zufallselement fällt in keinem der beiden Länder unter diese Regulierung.

### Relevanz für dieses Konzept

🟢 **Gering bis moderat.** Das OTP-Modell ist rechtlich die unkomplizierteste Monetarisierungsform für digitale Apps — kein Glücksspiel, keine Subscription-Traps, keine verdeckten Kosten. Einziger Handlungsbedarf: **Klare Produktbeschreibung** in App Store / Play Store und in den App-internen Kaufdialogen.

**Empfehlung:** AGB und Datenschutzerklärung (auch für eine Offline-App empfohlen) anwaltlich einmalig prüfen lassen, insbesondere für den EU-Markt.

### Quellen
- EU-Richtlinie 2019/770 über digitale Inhalte (Europäisches Parlament, 2019)
- § 356 Abs. 5 BGB (Widerrufsrecht bei digitalen Inhalten, Stand 2022)
- twinr.dev: "iOS In-App Purchase Compliance: Full Guide For 2025" (abgerufen Juni 2025)
- LinkedIn / Sonu Dhankhar: "App Store Policy Updates 2025: Impact on Monetization & Ads" (2025)

---

## 2. App Store Richtlinien

### Apple App Store

**In-App Purchases (IAP):**
Apple verlangt für alle digitalen Inhalte und Features, die innerhalb der App freigeschaltet werden, die **Verwendung des Apple-eigenen IAP-Systems (StoreKit)**. Ein OTP über StoreKit ist explizit als "Non-Consumable In-App Purchase" vorgesehen — dies ist der korrekte Typ für eine dauerhafte Feature-Freischaltung.

- **Pflicht:** Apple nimmt 30% Provision auf alle IAP-Umsätze (15% für Entwickler mit < 1 Mio. USD Jahresumsatz im Small Business Program — für einen Erstentwickler fast sicher anwendbar).
- **Verbot:** Externe Zahlungslinks oder Hinweise auf alternative Kaufmöglichkeiten außerhalb der App sind nach Apple-Richtlinien in der App selbst **nicht erlaubt** (Guideline 3.1.1). ⚠️ Hinweis: Durch das Epic-Urteil (USA, 2024) und den EU Digital Markets Act (DMA, 2024) gibt es für EU-Apps und US-Apps erste Ausnahmeregelungen — dies ist ein sich entwickelndes Rechtsfeld, Stand 2025 noch nicht vollständig stabilisiert.
- **Inhaltliche Prüfung:** Atemübungs-Apps fallen unter keine spezifisch eingeschränkte Kategorie. Keine Hinweise auf Ablehungs-Risiken durch Inhalte.
- **Gesundheits-Disclaimer-Pflicht:** Apple kann bei Apps mit Wellness/Health-Bezug einen **Disclaimer** verlangen, dass die App keine medizinische Beratung ersetzt. Dies ist in der Praxis üblich und sollte proaktiv eingebaut werden (siehe auch Abschnitt unten).

**Quellen:**
- Apple App Review Guidelines, Section 3.1.1 (Payments, aktuell, abgerufen über developer.apple.com, Juni 2025)
- twinr.dev: "iOS In-App Purchase Compliance: Full Guide For 2025"

### Google Play Store

- **IAP-System:** Google verlangt für digitale In-App-Käufe ebenfalls die Nutzung des **Google Play Billing Systems**. Provision: 30% (15% für erste 1 Mio. USD Jahresumsatz).
- **DMA-Ausnahme:** Im EU-Raum erlaubt Google seit 2024 unter bestimmten Bedingungen alternative Bezahlwege — technisch komplex und für einen Erstentwickler ohne Rechtsabteilung zunächst nicht empfohlen.
- **IARC-Rating:** Google Play verwendet das **IARC-System** (International Age Rating Coalition) für automatisierte Altersfreigaben. Der Entwickler füllt einen Fragebogen aus; für eine Atemübungs-App ohne gewalthaltige, sexuelle oder suchtfördernde Inhalte ist eine **IARC "Everyone" / USK-0-Einstufung** zu erwarten (siehe Abschnitt 5).
- **Health & Wellness Apps:** Keine spezifischen Einschränkungen für Atemübungs-Apps. Medizinischer Disclaimer empfohlen (analog Apple).

### Relevanz für dieses Konzept

🔴 **Hoch — direkt handlungsrelevant.** Beide Plattformen haben klare technische Anforderungen für den OTP-Kauf (StoreKit / Google Play Billing), die korrekt implementiert werden müssen, um nicht abgelehnt zu werden. Dies ist kein rechtliches Risiko im engeren Sinne, sondern ein **Compliance-Risiko beim Launch**.

**Empfehlung:**
1. StoreKit 2 (iOS) und Google Play Billing Library (Android) von Beginn an im Tech-Stack einplanen — nicht nachträglich integrieren.
2. Proaktiv einen Gesundheits-Disclaimer einbauen: *"Diese App ersetzt keine medizinische Beratung. Bei gesundheitlichen Beschwerden konsultiere einen Arzt."*
3. App-Store-Listing auf korrekte Kategorie prüfen (Health & Fitness, nicht Medical).

### Quellen
- Apple App Review Guidelines (developer.apple.com, aktuell, abgerufen Juni 2025)
- Google Play Developer Policy Center (play.google.com/about/developer-content-policy, aktuell)
- twinr.dev: "iOS In-App Purchase Compliance: Full Guide For 2025" (2025)

---

## 3. AI-generierter Content — Urheberrecht

### Aktuelle Rechtslage

**USA:**
Das U.S. Copyright Office hat in einem Report vom **29. Januar 2025 (Part 2)** klargestellt: Rein KI-generierte Werke (ohne substantiellen menschlichen kreativen Beitrag) sind **nicht urheberrechtlich schutzfähig** unter US-Recht. Werke, bei denen ein Mensch KI als Werkzeug nutzt und dabei hinreichend kreative Entscheidungen trifft (Selektion, Arrangement, Bearbeitung), können hingegen Schutz genießen — der Umfang bleibt im Einzelfall zu klären.

**Praktische Implikation:** Wenn Icons, Illustrationen, Sounds oder Texte (z.B. Anweisungstexte im Kreis) vollständig per KI generiert wurden, kann der Entwickler diese Werke möglicherweise **nicht als eigenes Urheberrecht durchsetzen** — Dritte könnten sie kopieren, ohne dass rechtliche Handhabe besteht.

**EU:**
Die EU hat noch keine abschließende Regulierung für KI-Urheberrecht (Stand Juni 2025). Der AI Act (2024) adressiert Urheberrecht nur mittelbar (Transparenzpflichten für KI-generierte Inhalte). Die herrschende Meinung in DE/EU: Urheberrecht entsteht nur durch menschliche Schöpfung — KI-only-Outputs sind nicht schutzfähig, analog zur US-Position.

### Kommerzielle Nutzung

- **Lizenzfragen bei KI-Tools:** Wer Assets mit Tools wie Midjourney, DALL-E, Stable Diffusion o.ä. erstellt und kommerziell nutzt, muss die **Nutzungsbedingungen des jeweiligen Tools** prüfen. Beispiel: Midjourney erlaubt kommerzielle Nutzung für zahlende Nutzer, behält sich aber bestimmte Rechte vor (Stand 2025 — AGB regelmäßig ändernd). ⚠️ **Datenlücke:** Die konkreten AGB der genutzten KI-Tools sind hier nicht bekannt und müssen individuell geprüft werden.
- **Drittansprüche:** Wenn KI-generierter Output erkennbar einem urheberrechtlich geschützten Werk ähnelt (z.B. ein bekanntes Design imitiert), besteht theoretisch Verletzungsrisiko — in der Praxis für abstrakte Kreis-Animationen und UI-Icons gering.

### Relevanz für dieses Konzept

🟡 **Mittel — bedingt relevant.** Das Concept Brief erwähnt keine explizite KI-Asset-Generierung. Die Kernmechanik (animierter Kreis) ist eine technische Animation, kein urheberrechtlich problematischer Content. **Relevant wird dieser Punkt, wenn:** Hintergrundbilder, Icons, Sounds oder sonstige Assets per KI-Tool generiert werden.

**Empfehlung:**
- Für kommerzielle Assets entweder: (a) selbst erstellt / menschlich gestaltet, (b) lizenzierte Stock-Assets (z.B. von Adobe Stock, Envato — kommerzielle Lizenz prüfen), oder (c) KI-generiert mit dokumentiertem menschlichem Gestaltungsbeitrag und geprüften Tool-AGB.
- Für die App-Texte (Atemanweisungen, UI-Copy): kein urheberrechtliches Risiko bei eigenem Verfassen — Atemtechniken selbst (4-7-8, Box Breathing) sind **nicht patentiert oder urheberrechtlich geschützt** als Methoden.

### Quellen
- U.S. Copyright Office: "Copyright and Artificial Intelligence, Part 2" (29. Januar 2025, copyright.gov/ai)
- Reuters Legal: "Copyright Law in 2025: Courts begin to draw lines around AI training, piracy, market harm" (16. März 2026 — Datum im Quell-Snippet, möglicherweise Vorausschau-Artikel, mit Vorbehalt zu behandeln)
- Michael Best & Friedrich LLP: "AI + Copyright: What Every Business Needs to Know in 2025" (michaelbest.com, 2025)

---

## 4. Datenschutz (DSGVO / COPPA)

### DSGVO-Anforderungen

**Grundsatz:** Die DSGVO gilt für alle Apps, die Nutzern in der EU angeboten werden — unabhängig davon, ob ein Backend betrieben wird. Auch bei **rein lokalem Storage** auf dem Gerät des Nutzers können datenschutzrechtliche Pflichten bestehen.

**Was bei dieser App zu prüfen ist:**

| Aspekt | Einschätzung |
|---|---|
| Lokaler Storage (SharedPreferences / Hive) | Speichert nur geräteinterne Daten — kein Transfer an Dritte. DSGVO-Pflichten minimal, aber nicht null. |
| Analytics / Crash-Reporting | ⚠️ Kritischer Punkt: Wenn Firebase Crashlytics, Sentry o.ä. eingebunden wird, werden Gerätedaten an Drittserver übertragen — volle DSGVO-Pflichten inkl. Datenschutzerklärung und ggf. Consent-Banner. |
| Werbung / AdSDKs | Nicht geplant laut Concept Brief — falls doch eingebunden, erhebliche DSGVO-Anforderungen (ATT auf iOS, Consent Management auf Android). |
| App Store Connect / Google Play | Apple und Google erheben beim Download Nutzerdaten — dies liegt in der Verantwortung der Plattformen, nicht des Entwicklers. |

**Mindestpflichten auch für Offline-Apps (EU-Markt):**
1. **Datenschutzerklärung** (Privacy Policy): Pflicht — sowohl im App Store Listing als auch in der App selbst (verlinkbar). Muss beschreiben, welche Daten erhoben werden (auch "keine personenbezogenen Daten werden erhoben" ist eine valide und für diese App positiv kommunizierbare Aussage).
2. **Impressumspflicht** (DE/AT): Für kommerzielle Apps mit DE-Sitz des Entwicklers gilt die Impressumspflicht (§ 5 TMG) — entweder in der App oder über eine verlinkte Website.
3. **Apple App Privacy Labels / Google Data Safety Section:** Beide Plattformen verlangen Selbstauskunft über Datenpraktiken. Für eine reine Offline-App ist dies einfach auszufüllen ("No data collected") — muss aber korrekt und vollständig sein.

**Positiv-Aspekt:** Die "kein Backend, kein Account, kein Cloud"-Positionierung des Konzepts ist aus DSGVO-Perspektive die **strukturell einfachste Ausgangslage** — geringer Compliance-Aufwand, ehrliche Kommunikation möglich, kein Consent-Banner notwendig (sofern keine Drittdienste eingebunden werden).

**⚠️ Risiko-Punkt Third-Party-SDKs:** Das ist die häufigste DSGVO-Falle für kleine App-Entwickler. Cross-Platform-Frameworks (Flutter / React Native) bringen gelegentlich Telemetrie-Komponenten mit — vor dem Launch prüfen, welche Daten das Framework selbst überträgt.

### COPPA (Children's Online Privacy Protection Act, USA)

**Zielgruppe:** 25–45 Jahre, klar nicht auf Kinder ausgerichtet. Die App hat **keine Features, die Kinder anziehen** (kein Gamification, keine Figuren, keine Inhalte für Kinder).

**Einschätzung:** COPPA ist **nicht einschlägig**, solange: