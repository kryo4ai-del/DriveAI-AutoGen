# Legal-Research-Report: Minimalistische Atem-Übungs-App

**Durchlauf-ID:** breathflow4 | **Report-Typ:** KI-basierte Ersteinschätzung | **Stand:** Juni 2025
**Risiko-Ampel-Legende:** 🟢 Gering | 🟡 Mittel — Aufmerksamkeit empfohlen | 🔴 Hoch — Rechtsberatung dringend empfohlen

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Risiko-Ampel | Priorität |
|---|---|---|---|
| 1 | Monetarisierung & Glücksspielrecht | 🟢 | Niedrig |
| 2 | App Store Richtlinien | 🟡 | Mittel |
| 3 | AI-generierter Content — Urheberrecht | 🟡 | Mittel (kontextabhängig) |
| 4 | Datenschutz (DSGVO / COPPA) | 🟡 | Mittel |
| 5 | Jugendschutz (USK / PEGI / IARC) | 🟢 | Niedrig |
| 6 | Social Features — Auflagen | 🟢 | Nicht relevant |
| 7 | Markenrecht — Namenskonflikt | 🟡 | Mittel |
| 8 | Patente | 🟡 | Mittel (Recherche-Lücke) |
| 9 | Medizinrecht / Gesundheitsrecht | 🔴 | **Hoch — neu identifiziert** |

> ⚠️ **Vorab-Hinweis:** Feld 9 (Medizinrecht) wurde im ursprünglichen Concept Brief nicht adressiert, ist aber für eine Atem-App das rechtlich kritischste Feld. Es wird priorisiert behandelt.

---

## 1. Monetarisierung & Glücksspielrecht 🟢

### Aktuelle Gesetzeslage
Glücksspielrecht ist für dieses Konzept **strukturell nicht anwendbar**. Die Mechanik der App enthält keine Elemente, die unter Glücksspielttatbestände fallen:

- **Kein Zufallsmechanismus** (kein Loot Box, kein Spin, kein randomisierter Reward)
- **Kein Echtgeld-Einsatz mit Gewinnchance**
- **Kein virtuelles Währungssystem**, das in Realgeld rückgetauscht werden kann

Die EU-Parlamentsresolution vom Oktober 2025 (EP Pressemitteilung, Oktober 2025) zielt explizit auf Loot Boxes, Pay-to-Win-Mechaniken und Glücksspiel-ähnliche Systeme bei Minderjährigen — keines dieser Elemente ist im Konzept enthalten.

### Länderspezifisch

| Region | Bewertung |
|---|---|
| **EU / DACH** | Kein Glücksspieltatbestand. Einmaliger App-Kauf (€1,99–€2,99) ist regulatorisch unkompliziert. |
| **Belgien / Niederlande** | Haben 2018/2019 strenge Loot-Box-Regelungen eingeführt — **nicht relevant**, da kein derartiges Modell vorhanden. |
| **USA** | Kein Glücksspieltatbestand auf Bundesebene für dieses Modell. |
| **China** | Nicht primärer Zielmarkt laut Concept Brief. Chinas App-Markt erfordert separate ICP-Lizenzierung — **bei China-Launch gesondert prüfen**, hier nicht weiter ausgeführt. |

### Relevanz für dieses Konzept
**Sehr gering.** Der einmalige App-Kauf (€1,99–€2,99) oder optionale Spendenbutton ist die rechtlich sauberste Monetarisierungsform im mobilen Markt. Keine Abo-Fallstricke (Subscription-Transparenz-Pflichten nach EU-Verbraucherrecht entfallen), keine Loot-Box-Regulierung.

> ⚠️ **Einzige Aufmerksamkeitspflicht:** Wenn ein "optionaler Unterstützungs-IAP" implementiert wird, der faktisch nichts freischaltet, muss die Beschreibung im App Store klar und ehrlich formuliert sein. Apple und Google prüfen, ob IAP-Beschreibungen irreführend sind (Apple App Store Review Guidelines, §3.1.1 — Stand: 2025). Das ist kein Risiko, solange die Beschreibung klar ist.

**Quellen:**
- EU-Parlament Pressemitteilung: "New EU measures needed to make online services safer for minors", Oktober 2025
- Siege.gg: "Several EU Countries Have Introduced Stricter Regulations on Loot Boxes in Games in 2025"

---

## 2. App Store Richtlinien 🟡

### Apple App Store

**Relevante Regelungsbereiche für dieses Konzept:**

**§3.1.1 — In-App Purchase:**
Einmalige Käufe und optionale Spendenbuttons sind zulässig. Apple verlangt, dass alle digitalen Inhalte und Funktionen über das Apple IAP-System abgewickelt werden — kein direkter Zahlungslink aus der App heraus. Für eine €1,99-App oder einen In-App-Spendenbutton gilt: Apple behält 15–30% Provision (15% für Entwickler unter €1 Mio. Jahresumsatz im Small Business Program).

> 🟡 **Achtung:** Wenn der "Spendenbutton" rechtlich als Zahlung für einen nicht-physischen Benefit gewertet wird (z. B. "Unterstütze die Entwicklung"), fällt er unter IAP-Pflicht. Ein echter Spendenbutton für eine Non-Profit-Organisation wäre ausgenommen — für einen kommerziellen App-Entwickler gilt die IAP-Pflicht. Formulierung und Implementierung müssen Apple-konform sein.

**§5.1.1 — Datenschutz (Privacy Policy):**
Apple verlangt eine Privacy Policy für alle Apps, die im App Store verfügbar sind — **auch wenn keine Nutzerdaten gesammelt werden**. Dies ist ein häufiger Rejection-Grund. Die Privacy Policy muss erklären, dass keine Daten gesammelt werden.

**§5.1.2 — Data Use and Sharing:**
Apple führt seit iOS 14 die "App Privacy Labels" (Nutrition Labels) verpflichtend ein. Für eine vollständig offline arbeitende App ohne Analytics, die keinerlei Daten erhebt, ist das Label "No Data Collected" zutreffend — und ein **aktives Vertrauenssignal** gegenüber datenschutzbewussten Nutzern. Dies ist konsistent mit der Positionierung des Concept Briefs.

**Wichtig:** App Tracking Transparency (ATT) Framework greift nur, wenn Tracking implementiert ist. Bei vollständiger Offline-Nutzung ohne Analytics: **ATT-Framework nicht erforderlich** — das vereinfacht den Launch erheblich.

**§1.4 — Physical Harm:**
Medizinische und gesundheitsbezogene Apps unterliegen verschärften Prüfungen (→ Feld 9, Medizinrecht). Apple prüft bei Atemübungs-Apps, ob gesundheitliche Claims gemacht werden.

### Google Play Store

**Relevante Regelungsbereiche:**

**Datenschutz-Sektion (Data Safety):**
Google Play verlangt seit 2022 eine Data Safety-Erklärung für alle Apps. Analog zu Apple: Für eine vollständig offline arbeitende App ohne Datenweitergabe ist "No data shared / No data collected" die korrekte Angabe — ebenfalls ein Vertrauenssignal.

**Health & Fitness Apps — Play Store Policy:**
Google Play hat 2023 eine separate Policy für Health-Apps eingeführt. Apps die gesundheitsbezogene Features anbieten müssen ggf. zusätzliche Erklärungen zur Sicherheit abgeben. Atemübungs-Apps fallen potenziell in diese Kategorie.

**IARC-Bewertungssystem:**
Google Play nutzt IARC für Alterskennzeichnungen. Für eine Atemübungs-App ohne problematische Inhalte: Bewertung "Everyone / USK 0" zu erwarten (→ Feld 5).

### Relevanz
🟡 **Mittel.** Hauptrisiken: (1) Fehlende Privacy Policy führt zu Ablehnung, (2) Gesundheits-Claims können verschärfte Review-Prozesse auslösen, (3) IAP-Implementierung muss plattformkonform sein. Alle drei Punkte sind **beherrschbar** mit korrekter Vorbereitung — kein strukturelles Hindernis für den Launch.

**Quellen:**
- Apple App Store Review Guidelines, developer.apple.com (abgerufen 2025)
- LinkedIn: "App Store Policy Updates 2025: Impact on Monetization & Ads" (Sonu Dhankhar, 2025)
- Twinr.dev: "iOS In-App Purchase Compliance: Full Guide For 2025"

---

## 3. AI-generierter Content — Urheberrecht 🟡

### Aktuelle Rechtslage

Der Concept Brief spezifiziert nicht explizit, ob KI-generierte Assets (Musik, Sounds, Animationen, Icons) verwendet werden. Die rechtliche Einschätzung erfolgt daher in zwei Szenarien:

**Szenario A: Keine KI-generierten Inhalte** → Dieses Feld ist **nicht relevant**. Standard-Urheberrecht für manuell erstellte oder lizenzierte Assets gilt unverändert.

**Szenario B: KI-generierte Assets werden verwendet** (z. B. Ambient-Sounds, Animationsdesign via Midjourney/Sora, Icons via DALL-E):

**USA (U.S. Copyright Office, Stand 2025):**
- Part 2 des AI-Copyright-Reports (veröffentlicht 29. Januar 2025): KI-generierte Outputs sind grundsätzlich **nicht urheberrechtlich schutzfähig**, wenn keine substantielle menschliche kreative Kontrolle nachweisbar ist.
- Praktische Implikation: Ein Entwickler kann keine Urheberrechte an vollständig KI-generierten Assets geltend machen — aber auch Dritte können sie nicht geltend machen. Das ist für die **Nutzung** in einer kommerziellen App kein direktes Problem, nur für den **Schutz** der eigenen Assets.

**EU (Stand 2025):**
- Die EU hat noch keinen finalisierten Rechtsrahmen speziell für KI-generiertes Urheberrecht. Der EU AI Act (in Kraft seit August 2024) adressiert das Urheberrecht an Outputs indirekt — primär über Transparenzpflichten für "GPAI"-Modelle, nicht über den Output-Schutz.
- Grundsatz: Auch in der EU gilt, dass nur menschliche Schöpfungen urheberrechtlich schutzfähig sind. KI-generierte Outputs ohne menschliche Gestaltungshöhe sind schutzlos.

### Kommerzielle Nutzung — Praktische Risiken

| Risikoquelle | Beschreibung |
|---|---|
| **Training-Daten-Streit** | Der US Copyright Office Part 3 Report (Pre-Publication, 2025) adressiert, ob Training auf urheberrechtlich geschütztem Material Fair Use ist. Für den **Nutzer** des KI-Tools ist das sekundär — relevant ist ob das genutzte KI-Tool AGB-konform kommerziell nutzbar ist. |
| **AGB der KI-Tools** | Midjourney, DALL-E, Suno etc. haben unterschiedliche kommerzielle Lizenzmodelle. Midjourney erlaubt kommerzielle Nutzung nur im Pro-Plan. Suno hat spezifische Einschränkungen für kommerzielle Releases. **→ Konkrete AGB des jeweiligen Tools vor Asset-Nutzung prüfen.** |
| **Kompetitiver Marktkonflikt** | Reuters/Reuters Legal (März 2026): "Fair use arguments may be weaker where AI outputs directly compete with copyrighted content in active licensing markets." Für Ambient-Sounds in einer App: Wenn diese direkt Musik aus dem Streaming-Markt imitieren, steigt das Risiko. Für abstrakte Atem-Animationsdesigns: Risiko gering. |

### Relevanz für dieses Konzept
🟡 **Mittel, aber managebar.** Primäre Empfehlung: Für Ambient-Sounds (falls verwendet) entweder **menschlich komponiert**, **CC0-lizenziert** (Freesound.org, Pixabay etc.) oder **kommerziell klarlizenzierte KI-Tools** nutzen. Die Kreis-Animation selbst ist als UI-Element nicht sonderlich urheberrechtlich schützenswert — das ist Kategorie-Standard (wie im Concept Brief korrekt beschrieben).

> ⚠️ **Spezifisches Risiko:** Wenn die App Ambient-Sounds oder Musik enthält (z. B. für die Atem-Session), müssen GEMA-Rechte (Deutschland), SUISA (Schweiz), AKM (Österreich) ausgeschlossen sein. GEMA-freie Musik oder CC0-Assets sind für DACH zwingend empfohlen.

**Quellen:**
- U.S. Copyright Office: "Copyright and Artificial Intelligence", Part 2 (29. Januar 2025), Part 3 Pre-Publication Version
- Reuters Legal: "Copyright Law in 2025: Courts begin to draw lines around AI training" (März 2026)

---

## 4. Datenschutz (DSGVO / COPPA) 🟡

### DSGVO-Anforderungen (primär relevant — DACH-Markt)

**Grundsätzliche Einschätzung:**
Das Concept Brief beschreibt eine technisch nahezu ideale DSGVO-Konfiguration: vollständig offline, kein Backend, kein Account, lokales State-Management (SharedPreferences/UserDefaults), keine Analytics-SDKs. Dies ist das **geringstmögliche DSGVO-Risikoprofil** für eine mobile App.

**Was trotzdem geprüft werden muss:**

| Anforderung | Status bei diesem Konzept | Handlungsbedarf |
|---|---|---|
| **Datenschutzerklärung** | Pflicht — auch bei "Keine Daten" | Muss erstellt und hinterlegt werden (App Store + Website/Impressum) |
| **Verarbeitungsverzeichnis (Art. 30 DSGVO)** | Entfällt weitgehend, wenn keine personenbezogenen Daten verarbeitet werden | Minimaler Aufwand |
| **Technische und organisatorische Maßnahmen (TOM)** | Lokal gespeicherte Daten (Wochen