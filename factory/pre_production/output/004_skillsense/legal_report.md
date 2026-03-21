# Legal-Research-Report: SkillSense

**Erstellt:** Juni 2025
**Konzept-Version:** Concept Brief SkillSense (inkl. Abweichungen vom CEO-Brief)
**Scope:** Web-App (Desktop-first), DACH-Primärmarkt, Freemium + Pro-Abo, Client-side-Analyse-Architektur
**Disclaimer:** KI-basierte Ersteinschätzung — keine rechtsverbindliche Beratung.

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Relevanz-Score | Priorität |
|---|---|---|---|
| 1 | Monetarisierung & Glücksspielrecht | 🟢 Niedrig | Low |
| 2 | App Store Richtlinien | 🟢 Niedrig–Mittel | Low (Web-App) |
| 3 | AI-generierter Content — Urheberrecht | 🟡 Mittel | Medium |
| 4 | Datenschutz (DSGVO / COPPA) | 🟡–🔴 Mittel–Hoch | **High** |
| 5 | Jugendschutz (USK / PEGI) | 🟢 Niedrig | Low |
| 6 | Social Features — Auflagen | 🟢 Nicht relevant | — |
| 7 | Markenrecht — Namenskonflikt | 🟡 Mittel | Medium |
| 8 | Patente | 🟡 Mittel (latent) | Medium |
| 9 | Plattform-AGB (Anthropic / OpenAI) | 🔴 **Hoch** | **Critical** |
| 10 | Vertragsrecht / SaaS-Abo-Recht (EU) | 🟡 Mittel | Medium |

> **Hinweis zu Rechtsfeld 9:** Dieses Feld war nicht im vorgegebenen Report-Template enthalten, ist aber für SkillSense das **strukturell kritischste Rechtsrisiko** — es wird daher als eigenständiger Abschnitt ergänzt. Begründung: Die gesamte Produktlogik (Scanner, Empfehlungen, Skill-DB) operiert auf Inhalten und Formaten, die durch Drittanbieter-AGB (Anthropic, OpenAI) reguliert werden.

---

## 1. Monetarisierung & Glücksspielrecht

### Aktuelle Gesetzeslage

Glücksspielrecht reguliert Mechanismen, bei denen (a) ein Einsatz erbracht wird, (b) ein zufällig bestimmtes Ergebnis entsteht und (c) ein Gewinn erzielt werden kann. Die EU-Mitgliedsstaaten regulieren Glücksspiel auf nationaler Ebene; es gibt keine harmonisierte EU-Glücksspielrichtlinie (Stand 2025).

Im Kontext von Mobile/Web-Apps ist die zentrale Debatte **Loot Boxes**: Der EU-Digitalausschuss hat im Oktober 2025 Maßnahmen empfohlen, die glücksspielähnliche Mechanismen (Loot Boxes) in Spielen, die für Minderjährige zugänglich sind, verbieten würden (Europäisches Parlament, Oktober 2025). Der vorgeschlagene **Digital Fairness Act (DFA)** zielt auf Microtransactions und manipulative Game-Design-Elemente ab (The Armored Patrol, Oktober 2025). ⚠️ *DFA ist zum Berichtszeitpunkt noch im Gesetzgebungsverfahren — finale Verabschiedung ausstehend.*

### Länderspezifisch

| Jurisdiktion | Status Loot Boxes / Zufallsmechanik | Relevanz für SkillSense |
|---|---|---|
| **Deutschland** | Kein generelles Verbot; KJM prüft Einzelfälle unter JuSchG | Nicht anwendbar |
| **Belgien** | Loot Boxes seit 2018 als Glücksspiel eingestuft (Gaming Commission) | Nicht anwendbar |
| **Niederlande** | Kfw-Entscheidung 2019; teilweise Regulierung | Nicht anwendbar |
| **EU gesamt** | DFA in Vorbereitung (2025); EP-Empfehlungen Oktober 2025 | Nicht anwendbar |
| **USA** | Bundesebene: kein Loot-Box-Verbot; einzelne Bundesstaaten diskutieren Gesetze | Nicht anwendbar |
| **China** | Offenlegungspflicht für Drop-Rates seit 2017 | Nicht anwendbar |

### Relevanz für dieses Konzept

🟢 **Nicht relevant.**

SkillSense enthält **keinerlei Zufallsmechanismen, Loot Boxes, Wett- oder Glücksspiel-Elemente.** Das Monetarisierungsmodell basiert ausschließlich auf:
- Freemium-Zugang (Funktionsumfang-Limitierung)
- Abo-Modell (Pro/Enterprise)
- Optionalem Credits-System für LLM-Calls (deterministisches Verbrauchsmodell)

Credits für Skill-Generierungen sind **kein Glücksspiel**, da kein Zufallselement und kein variables Ergebnis entsteht. Vergleichbar mit API-Call-Kontingenten bei AWS oder Stripe — rechtlich unproblematisch.

### Quellen
- Europäisches Parlament, Pressemitteilung "New EU measures needed to make online services safer for minors", Oktober 2025
- The Armored Patrol, "WG Loot Box System Could Soon Be Illegal in the EU", Oktober 2025
- siege.gg, "Several EU Countries Have Introduced Stricter Regulations on Loot Boxes in Games in 2025", 2025
- Belgian Gaming Commission, Loot Box Ruling, 2018 (Referenz)

---

## 2. App Store Richtlinien

### Vorbemerkung: Plattform-Klassifikation

SkillSense ist konzeptionell als **Web-App (Desktop-first)** geplant, gehostet auf Vercel, vertrieben über direkten Browser-Zugang. Es ist **keine native iOS/Android-App**. Damit entfällt der obligatorische App Store Review-Prozess für den MVP.

### Apple App Store

**Nicht obligatorisch relevant für MVP.** Falls eine native iOS-Begleit-App entwickelt wird:

- **In-App Purchase (IAP) Pflicht:** Apple verlangt für digitale Güter und Abonnements, die innerhalb einer iOS-App konsumiert werden, die Nutzung von Apple IAP (Guideline 3.1.1). Das bedeutet: 15–30% Apple-Provision auf alle Abo-Einnahmen via iOS-App.
- **Reader-App-Ausnahme:** Web-basierte Services, die primär Inhalte konsumieren (kein In-App-Kauf), können als "Reader App" qualifizieren und externe Zahlungslinks anbieten — allerdings mit strengen Einschränkungen (Apple App Review Guidelines, Sektion 3.1.3a).
- **AI-Content:** Keine spezifische Guideline gegen KI-generierte Skill-Empfehlungen; jedoch müssen Apps, die nutzergenerierte oder AI-generierte Inhalte anzeigen, Moderations-Mechanismen vorhalten (Guideline 1.2).
- **2025-Update:** Durch das EU Digital Markets Act Enforcement hat Apple in der EU alternative Payment-Links erlaubt (externe Web-Zahlungen via "Entitlement") — für DACH-Markt potenziell relevant, falls iOS-App gebaut wird.

### Google Play Store

**Nicht obligatorisch relevant für MVP.** Falls eine native Android-App entwickelt wird:

- Ähnliche Billing-Policy wie Apple: Google Play Billing für digitale Güter verpflichtend.
- Google hat 2024/2025 "User Choice Billing" in bestimmten Märkten ausgerollt — erlaubt alternative Payment-Optionen mit reduzierter Provision (~15% statt 30%).
- AI-generierte Inhalte: Play Store Policy verlangt Transparenz über AI-generierten Content; keine grundsätzliche Sperrung.

### Relevanz für dieses Konzept

🟢 **Aktuell gering — strategisch zu beobachten.**

Als Web-App unterliegt SkillSense **nicht** den App Store Guidelines. Stripe-Zahlungen direkt via Web sind ohne Provision möglich. **Empfehlung:** iOS/Android-App als optionalen Phase-2/Phase-3-Schritt behandeln und erst dann die IAP-Compliance-Anforderungen prüfen. Die Web-App-Strategie ist aus Monetarisierungssicht deutlich günstiger (keine 15–30% Provision).

### Quellen
- Apple App Store Review Guidelines (developer.apple.com/app-store/review/guidelines/, abgerufen 2025)
- LinkedIn/Sonu Dhankhar, "App Store Policy Updates 2025: Impact on Monetization", 2025
- EU Digital Markets Act, Enforcement gegen Apple (Europäische Kommission, 2024)

---

## 3. AI-generierter Content — Urheberrecht

### Aktuelle Rechtslage

**USA:**
Das U.S. Copyright Office hat in seinem zweiteiligen Report (Teil 2 veröffentlicht 29. Januar 2025) klargestellt: **AI-generierte Werke sind nicht urheberrechtlich schutzfähig**, wenn kein ausreichender menschlicher kreativer Beitrag nachweisbar ist. Auch wenn ein Mensch den Prompt schreibt, begründet das allein keinen Copyright-Schutz am Output (U.S. Copyright Office, Januar 2025; Michael Best & Friedrich LLP, 2025).

**EU (inkl. DACH):**
Das EU-Urheberrecht (InfoSoc-Richtlinie 2001/29/EG) setzt ebenfalls menschliche Schöpfung voraus. AI-generierte Outputs ohne substanzielle menschliche Formgebung sind in der EU nicht schutzfähig. Der EU AI Act (in Kraft getreten 2024, schrittweise Anwendung) enthält Transparenzpflichten für AI-generierte Inhalte (Art. 50 AI Act): **Kennzeichnungspflicht für AI-generierte Texte** in bestimmten Kontexten.

**Offene Frage Training Data:**
Wenn SkillSense Anthropic API (Claude) für Skill-Generierung nutzt, verwendet Anthropic sein trainiertes Modell. Die Trainingsdaten-Urheberrechtsfrage (Klagen gegen OpenAI, Anthropic, etc.) ist **rechtlich noch nicht abschließend geklärt** (Reuters, März 2026 — Verweis auf fortlaufende Gerichtsverfahren). ⚠️ *Das Risiko liegt bei Anthropic, nicht bei SkillSense als API-Nutzer — solange SkillSense keine eigenen Trainingsdaten erhebt.*

### Kommerzielle Nutzung

Kritische Punkte für SkillSense:

1. **Skill-Generierungen (Pro-Feature):** Claude generiert SKILL.md-Inhalte auf Nutzeranfrage. Diese Outputs sind nach aktuellem Recht **nicht urheberrechtlich von Anthropic oder SkillSense schutzfähig** — sie gehören faktisch niemandem (bzw. dem Nutzer, wenn menschlicher Beitrag substanziell). Für das Produkt ist das **unproblematisch**: SkillSense lizenziert keine Outputs, sondern stellt sie dem Nutzer zur Verfügung.

2. **Kuratierte Skill-Datenbank:** Wenn SkillSense Community-Skills kuratiert und in die Datenbank aufnimmt, können diese Skills **urheberrechtlich von den ursprünglichen Autoren geschützt sein** (sofern sie menschlich geschaffen wurden und die Schöpfungshöhe erreichen). Handlungsbedarf:
   - Klare **Lizenzierung einfordern** (z.B. Creative Commons oder eigene Lizenz) beim Einreichen von Community-Skills.
   - **Keine Skills ohne Einwilligung** in die kuratierte DB aufnehmen.
   - Bestehende GitHub Awesome-Listen-Skills: Lizenz der jeweiligen Repos prüfen (meist MIT oder CC) — nicht automatisch kompatibel mit kommerzieller Nutzung in einer kuratierten DB.

3. **Security Scanner Analyse:** Das Scannen von SKILL.md-Dateien zur Qualitätsbewertung ist **keine urheberrechtlich relevante Nutzung** (vergleichbar mit Search Engine Indexing / Fair Use / Text-und-Data-Mining-Ausnahme Art. 4 DSM-Richtlinie in der EU).

### Relevanz für dieses Konzept

🟡 **Mittel — primär relevant für kuratierte Skill-DB und Community-Inhalte.**

Der AI-Output-Teil ist weniger problematisch als die **Herkunft der Drittanbieter-Skills** in der kuratierten Datenbank. **Empfehlung:** Terms of Service für Skill-Einreichungen von Tag 1 mit expliziter Lizenzierung ausstatten. Für die Anthropic-API-Nutzung die Anthropic Usage Policy prüfen (siehe Abschnitt 9).

### Quellen
- U.S. Copyright Office, "Copyright and Artificial Intelligence — Part 2", 29. Januar 2025 (copyright.gov/ai)
- Michael Best & Friedrich LLP, "AI + Copyright: What Every Business Needs to Know in 2025", 2025
- Reuters, "Copyright Law in 2025: Courts begin to draw lines around AI training", 16. März 2026
- EU AI Act (Verordnung 2024/1689), Art. 50 — Transparenzpflichten
- EU DSM-Richtlinie 2019/790, Art. 4 — Text-und-Data-Mining

---

## 4. Datenschutz (DSGVO / COPPA)

### DSGVO-Anforderungen

Dies ist das **rechtlich kritischste Feld** für SkillSense — gleichzeitig auch das Feld, in dem das Produkt durch seine Client-side-Architektur strukturell am stärksten positioniert ist.

#### 4.1 Verarbeitungssituation je Feature

| Feature | Datenverarbeitung | DSGVO-Relevanz |
|---|---|---|
| **Skill-Scanner (Client-side)** | Keine Übertragung an Server; Datei bleibt im Browser | 🟢 Minimal — kein Personenbezug übertragen |
| **Fragebogen (Client-side)** | Antworten lokal verarbeitet; kein Server-Upload | 🟢 Minimal — sofern kein Account |
| **Chat-Export-Analyse (Client-side)** | ⚠️ Kritisch: Chat-Historien enthalten höchstwahrscheinlich personenbezogene Daten des Nutzers UND Dritter | 🔴 Hoch |
| **Pro-Account (Stripe + Auth)** | E-Mail, Zahlungsdaten, Account-Daten → Server-seitig | 🟡 Standard-DSGVO-Pflichten |
| **Analytics (Plausible)** | Aggregiert, cookielos, IP-anonymisiert | 🟢 Datenschutzfreundlich |
| **LLM-API-Call (Anthropic)** | Prompt-Daten werden an Anthropic übertragen | 🟡 Auftragsverarbeitung prüfen |

#### 4.2 Chat-Export-Analyse — Hochrisiko-Bereich

Das Pro-Feature "Chat-Export-Upload → Browser-Analyse" ist das **datenschutzrechtlich sensibelste Feature.** Chat-Historien können enthalten:
- Namen, Adressen, Gesundheitsdaten, Finanzdaten (Art. 9/10 DSGVO — besondere Kategorien)
- Daten **Dritter** (z.B. Gesprächspartner, Kunden, Kollegen des Nutzers)

Auch wenn die Analyse client-seitig erfolgt und keine Daten den Server erreichen, muss SkillSense:
- **Transparent kommunizieren**, was mit der Datei passiert (Datenschutzhinweis vor Upload, nicht in AGB versteckt)
- **Technisch sicherstellen**, dass keine Leaks via Service Worker, LocalStorage-Persistenz oder Analytics-Snippets entstehen
- **Keine Chat-Inhalte** für Training oder DB-Anreicherung verwenden (auch nicht anonymisiert ohne explizite Einwilligung)

> ⚠️ **Empfehlung:** Vor dem Pro-Launch ein **DSGVO-konformes Data Flow Audit** durch einen Datenschutzjuristen oder zertifizierten DSBA durchführen lassen. Client-side ist kein Freifahrtschein — es muss technisch wasserdicht sein.

#### 4.3 Pflichtanforderungen (Überblick)

| Anforderung | Basis | Status-Einschätzung für SkillSense |
|---|---|---|
| **Datenschutzerklärung** | Art. 13/14 DSGVO | Pflicht ab Tag 1, auch ohne Account |
| **Einwilligung für Cookies/Tracking** | Art. 6 DSGVO + ePrivacy | Plausible Analytics ist cookielos → vereinfacht |
| **Auftragsverarbeitungsvertrag (AVV)** | Art. 28 DSGVO | Mit Stripe, Anthropic (API), Vercel, Auth-Provider zwingend |
| **Recht auf Auskunft/Löschung** | Art. 15–17 DSGVO | Muss in Pro-Account implementiert sein |
| **Datenminimierung** | Art. 5 Abs. 1c DSGVO | Client-side-Architektur ist strukturell konform |
| **Verzeichnis von Verarbeitungstätigkeiten** | Art. 30 DSGVO | Ab >250 Mitarbeitern oder Risikoverarbeitung — bei Chat-Export-Feature: prüfen |
| **DPIA (Datenschutz-Folgenabschätzung)** | Art. 35 DSGVO | **Wahrscheinlich erforderlich** bei Chat-Export-Feature (systematische Analyse personenbezogener Inhalte) |

#### 4.4 Drittlandtransfer

Vercel, Stripe, Anthropic und Clerk sind US-amerikanische Anbieter. Datentransfer in die USA ist nach Schrems II (EuGH 2020) ohne geeignete Garantien unzulässig. Aktuell gilt das **EU-U.S. Data Privacy Framework (DPF)** (in Kraft seit Juli 2023) als