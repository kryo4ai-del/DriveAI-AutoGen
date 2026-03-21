# Legal-Research-Report: SkillSense

**Erstellt:** Juni 2025
**Konzept-Version:** Concept Brief SkillSense (Web-App, DACH-First)
**Risiko-Legende:** 🟢 Gering · 🟡 Mittel · 🔴 Hoch · ⚪ Nicht relevant

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Risiko | Begründung |
|---|---|---|---|
| 1 | Monetarisierung & Glücksspielrecht | 🟢 | Subscription-Modell, keine Lootboxen, kein Zufallselement |
| 2 | App Store Richtlinien | 🟢 | Web-App-First, kein App-Store-Zwang; bedingt relevant |
| 3 | AI-generierter Content — Urheberrecht | 🟡 | Claude-API für Skill-Generierung (Pro-Tier) — Eigentumsfrage offen |
| 4 | Datenschutz (DSGVO / COPPA) | 🟡🔴 | Chat-Export-Upload, Client-Side-Versprechen muss technisch/rechtlich wasserdicht sein |
| 5 | Jugendschutz (USK / PEGI) | ⚪ | Zielgruppe 20–50, kein spielerisches Element, keine Altersfreigabe erforderlich |
| 6 | Social Features | ⚪ | Keine Community-Features im MVP oder geplanten Phasen |
| 7 | Markenrecht — Namenskonflikt | 🟡 | "SkillSense" — Vorrecherche notwendig, Konflikte möglich |
| 8 | Patente | 🟡 | Jaccard-basierte Overlap-Detection + Security-Pattern-Matching — Freihalteraum prüfen |
| 9 | AGB / Nutzungsbedingungen Dritter | 🟡 | Anthropic ToS, Claude-API-Nutzung für kommerzielle Skill-Analyse |
| 10 | Haftung / Disclaimer | 🟡 | Sicherheitsempfehlungen als Produktfeature erzeugen Haftungsrisiko |

> **Hinweis zur Struktur:** Felder 9 und 10 wurden gegenüber dem Standard-Template ergänzt, da sie für dieses spezifische Konzept materiell relevant sind und im Template nicht vorgesehen waren.

---

## 1. Monetarisierung & Glücksspielrecht 🟢

### Aktuelle Gesetzeslage

Glücksspielrechtliche Regulierung (EU-Richtlinien, nationale Glücksspielgesetze DE/AT/CH, US State Laws) greift bei Produkten mit **Zufallsmechanik und Geldwert** — insbesondere Lootboxen, Gacha-Systeme und Pay-to-Win-Elemente. SkillSense hat keines dieser Elemente.

Das Monetarisierungsmodell ist ein klassisches **SaaS-Subscription-Modell:**

```
Free Tier     → Funktionslimitierung (3 Scans, 1 Security Check)
Pro Tier      → 9,99 €/Monat oder 79 €/Jahr
Enterprise    → Jahresvertrag, individuell
```

Alle Leistungen sind deterministisch und transaktionsbasiert. Es gibt keine Zufallskomponente, keinen virtuellen Gegenwert mit Umtauschwert, keine In-App-Währung.

### Länderspezifisch

| Jurisdiction | Bewertung | Anmerkung |
|---|---|---|
| **Deutschland** | ✅ Unbedenklich | GlüStV 2021 betrifft Online-Glücksspiele — nicht anwendbar |
| **Österreich** | ✅ Unbedenklich | GSpG greift nicht bei Subscription-SaaS |
| **Schweiz** | ✅ Unbedenklich | BGS gilt nur für Geldspiele mit Gewinnchance |
| **EU gesamt** | ✅ Unbedenklich | Kein EU-weites Glücksspielrecht; nationale Gesetze greifen nicht |
| **USA** | ✅ Unbedenklich | Kein State Law greift bei Subscription ohne Zufallsmechanik |
| **China** | ⚪ Nicht relevant | DACH-First — China nicht im Scope des MVP |

### Relevanz für dieses Konzept

**Minimal.** Das Modell ist regulatorisch sauber. Einziger theoretischer Edge Case: Falls SkillSense in einer späteren Phase **kuratierte Skill-Pakete als zufällig zusammengestellte "Bundles"** anbieten würde — dann wäre eine Neubewertung notwendig. Im aktuellen Konzept ist das nicht vorgesehen.

### Quellen
- Glücksspielstaatsvertrag 2021 (GlüStV 2021), Deutschland
- Österreichisches Glücksspielgesetz (GSpG), BGBl. Nr. 620/1989 idgF
- Belgische Gaming Commission: Stellungnahme zu Lootboxen (2018, weiterhin referenziert 2024)
- Netherlands Kansspelautoriteit: Lootbox-Guidance (2024 Update)

---

## 2. App Store Richtlinien 🟢 (bedingt relevant)

### Vorbemerkung zur Plattformwahl

Das Concept Brief trifft explizit die strategische Entscheidung **gegen eine native App** und **für eine Web-App (Next.js/Vercel)**. Das ist aus rechtlicher Sicht die risikoärmere Wahl — insbesondere für ein Tool das Chat-Daten verarbeitet. Die App-Store-Richtlinien sind damit für das MVP **nicht direkt anwendbar**, aber aus zwei Gründen trotzdem relevant:

1. **Zukünftige Mobile App** (Phase 3+ denkbar)
2. **Progressive Web App (PWA)** — falls SkillSense als PWA auf Mobile installierbar wird, gelten Apple-Regeln teilweise indirekt

### Apple App Store

**Relevante Richtlinien (Stand: App Store Review Guidelines 2025):**

| Regel | Inhalt | Relevanz für SkillSense |
|---|---|---|
| **Guideline 3.1.1** | In-App Purchases für digitale Inhalte müssen über StoreKit laufen | Bei nativer iOS-App: Subscription muss über Apple IAP — 15–30% Gebühr | 
| **Guideline 5.1.1** | Privacy — Datenerhebung muss deklariert werden | Chat-Export-Verarbeitung wäre im App Store Privacy Label zu deklarieren |
| **Guideline 4.2** | Minimum Functionality | Reines "Web-Wrapper"-App-Konzept würde abgelehnt |
| **Guideline 2.5.13** | Apps dürfen keine versteckten Funktionen haben | Security-Scanner muss vollständig in App-Beschreibung kommuniziert werden |

**Kritischer Punkt für hypothetische iOS-App:**
Ein Tool das **Chat-Exporte von Claude analysiert** würde im App Store Review mit hoher Wahrscheinlichkeit unter **Guideline 5.1** geprüft werden — auch wenn die Verarbeitung client-side erfolgt. Apple verlangt im Privacy Nutrition Label die Deklaration ob "User Content" (Chat-Daten gelten als User Content) verarbeitet wird. Client-Side-Processing reduziert das Risiko, eliminiert es aber nicht vollständig aus Apple-Perspektive.

> ⚠️ **Strategische Bestätigung der Web-App-Entscheidung:** Die App-Store-15–30%-Gebühr auf 9,99 €/Monat wäre bei 1.000 Pro-Nutzern ein monatlicher Verlust von 1.500–3.000 € gegenüber direktem Web-Billing via Stripe. Die Web-App-Entscheidung ist ökonomisch und rechtlich korrekt.

### Google Play Store

**Relevante Richtlinien (Stand: Google Play Policy Center 2025):**

| Regel | Inhalt | Relevanz |
|---|---|---|
| **Sensitive Data Policy** | Apps die "sensitive personal information" verarbeiten brauchen prominente Disclosure | Chat-Exporte könnten als sensitiv eingestuft werden |
| **Subscription Policy** | Klare Kommunikation von Laufzeit, Preisen, Kündigung | Standard-Anforderungen — erfüllbar |
| **AI-generated Content Policy** (neu 2024) | AI-generierte Inhalte müssen als solche markiert werden | Relevant für Skill-Generierung via Claude (Pro-Tier) |

### Relevanz für aktuelles Konzept

**Gering bis mittel.** Web-App-First ist die richtige Entscheidung. Für eine hypothetische spätere Mobile-App: Frühzeitig Rechtsberatung zur App-Store-Compliance bei Chat-Daten-Verarbeitung einholen.

### Quellen
- Apple App Store Review Guidelines (developer.apple.com, abgerufen 2025)
- Google Play Developer Policy Center (play.google.com/about/developer-content-policy, 2025)
- twinr.dev: "iOS In-App Purchase Compliance: Full Guide For 2025"

---

## 3. AI-generierter Content — Urheberrecht 🟡

### Aktuelle Rechtslage

Die urheberrechtliche Bewertung von KI-generiertem Content ist 2025 in einer **aktiven Entwicklungsphase**:

**USA (U.S. Copyright Office):**
- Part 2 des AI-Copyright-Reports (veröffentlicht 29. Januar 2025): KI-generierte Outputs sind **grundsätzlich nicht urheberrechtlich schutzfähig** ohne nachweisbare menschliche kreative Kontrolle
- Praktische Konsequenz: Skill-Texte die Claude via API generiert sind urheberrechtlich **nicht durch SkillSense schützbar** — aber auch nicht durch Dritte
- Ausnahme: Wenn ein menschlicher Autor den Output signifikant bearbeitet und gestaltet, kann dieser Anteil schützbar sein

**EU / Deutschland:**
- EU AI Act (in Kraft seit August 2024, Anwendung gestaffelt bis 2027): Keine explizite Urheberrechtsregel für Outputs, aber **Transparenzpflicht** für KI-generierte Inhalte (Art. 50 EU AI Act)
- Deutsches UrhG §2: Erfordert "persönliche geistige Schöpfung" — AI-Output ohne menschliche Kreativleistung nicht schutzfähig
- BGH-Rechtsprechung zu KI-Werken: Noch keine höchstrichterliche Entscheidung für generative AI (Stand Mitte 2025)

**Reuters/Skadden-Analyse (März/Mai 2025):**
> "Fair use arguments may be weaker where AI outputs directly compete with copyrighted content in active licensing markets."
> "Making commercial use of vast troves of copyrighted works to produce expressive content" — Risiko für Training-Daten-Fragen

### Kommerzielle Nutzung — konkret für SkillSense

Zwei relevante Szenarien:

**Szenario A: Claude generiert Skill-Texte (Pro-Tier-Feature)**

```
Problem:    Wem gehören die generierten Skill-Texte?
Antwort:    Laut Anthropic ToS (Stand 2025): Output gehört dem Nutzer der
            die API aufruft — also SkillSense bzw. dem End-User
Risiko:     Gering, aber Anthropic ToS muss aktiv geprüft werden
            (siehe Abschnitt 9 — Drittanbieter-ToS)
```

**Szenario B: SkillSense kuratiert externe Skills (Datenbank)**

```
Problem:    Skills aus GitHub, Reddit, Community-Quellen könnten
            urheberrechtlich geschützt sein
Antwort:    Kurze Prompt-Texte sind grenzwertig schutzfähig
            (kein ausreichender Schöpfungshöhe-Nachweis in DE)
Risiko:     Mittel — bei wörtlicher Übernahme von Skills ohne
            Lizenz und ohne Quellenangabe
Empfehlung: Klare Lizenzregeln für Skill-Datenbank definieren
            (CC-Lizenz oder explizite Einwilligung der Urheber)
```

**Szenario C: Nutzer uploaded eigene Skill-Dateien**

```
Problem:    SkillSense analysiert Inhalte die dem Nutzer gehören
Antwort:    Reine Analyse ohne Speicherung = kein Urheberrechts-Problem
            Client-Side-Verarbeitung minimiert Risiko zusätzlich
Risiko:     Gering
```

### Kennzeichnungspflicht (EU AI Act Art. 50)

Für **KI-generierte Skill-Vorschläge im Pro-Tier** gilt ab Anwendbarkeit des EU AI Act (GPAI-Regeln ab August 2025): Diese Inhalte sollten als KI-generiert **erkennbar gemacht werden**. Konkret: Ein Label "Von Claude generiert" oder ähnliches reicht — das ist kein Hindernis, sollte aber von Anfang an im UI berücksichtigt werden.

### Relevanz für dieses Konzept

**Mittel.** Kein akutes Blockier-Risiko, aber zwei Hausaufgaben:
1. Lizenzstrategie für kuratierte Skill-Datenbank definieren
2. KI-Kennzeichnung für generierte Skills im UI einbauen

### Quellen
- U.S. Copyright Office: AI Report Part 2 (29. Januar 2025), copyright.gov/ai
- Skadden: "Copyright Office Weighs In on AI Training and Fair Use" (Mai 2025)
- Reuters Legal: "Copyright Law in 2025" (März 2026 — *Hinweis: Datum aus Recherche-Ergebnis, möglicherweise Vorausblick*)
- EU AI Act, Art. 50 (Amtsblatt EU, August 2024)
- Deutsches UrhG §2 Abs. 2

---

## 4. Datenschutz (DSGVO / COPPA) 🟡🔴

> ⚠️ **Dieses Kapitel hat das höchste Risikopotenzial für SkillSense.** Das "100% Client-Side"-Versprechen ist das zentrale Datenschutz-Argument des Produkts — und gleichzeitig die Stelle die rechtlich und technisch am sorgfältigsten ausgearbeitet werden muss.

### DSGVO-Anforderungen (EU/DACH)

**Anwendbarkeit:** DSGVO gilt vollumfänglich — SkillSense richtet sich an EU-Nutzer (DACH-First), verarbeitet personenbezogene Daten (Chat-Exporte können personenbezogene Informationen enthalten).

#### 4.1 Das "Client-Side"-Versprechen — rechtliche Implikationen

Das Concept Brief positioniert "100% Client-Side / DSGVO by Design" als USP. Das ist konzeptuell korrekt, aber **rechtlich differenziert zu betrachten:**

```
Was Client-Side bedeutet:
✅ Chat-Export wird im Browser des Nutzers verarbeitet
✅ Keine Übertragung der Rohdaten an SkillSense-Server
✅ Kein Zugriff von SkillSense auf den Inhalt der Chats

Was Client-Side NICHT automatisch bedeutet:
⚠️ Telemetrie, Analytics, Error-Logging können trotzdem
   personenbezogene Daten erfassen (IP-Adressen, Session-IDs)
⚠️ Vercel (Hosting) sieht Request-Metadaten
⚠️ Clerk (Auth) verarbeitet E-Mail + Identitätsdaten
⚠️ Stripe verarbeitet Zahlungsdaten
```

**DSGVO-Fazit zum Client-Side-Versprechen:** Es ist technisch korrekt für den **Kern-Use-Case** (Chat-Analyse), aber **nicht für alle Datenflüsse im System.** Die Datenschutzerklärung muss diese Differenzierung klar kommunizieren — andernfalls ist das Marketing-Versprechen irreführend im Sinne von Art. 5 DSGVO (Transparenzprinzip).

#### 4.2 Pflichtanforderungen nach DSGVO

| Anforderung | Artikel | Umsetzung für SkillSense | Status |
|---|---|---|---|
| **Datenschutzerklärung** | Art. 13/14 | Vollständige Datenschutzerklärung für alle Datenflüsse (Vercel, Clerk, Stripe, Analytics) | ❌ Noch nicht erwähnt |
| **Rechtsgrundlage** | Art. 6 | Vertragserfüllung (6(1)(b)) für Pro-Tier; berechtigtes Interesse oder Einwilligung für Analytics | ❌ Zu definieren |
| **Einwilligung** | Art. 7 | Cookie-Banner falls Analytics-Cookies; bei Client-Side-Analyse keine Einwilligung nötig für die Analyse selbst | 🟡 Teilweise relevant |
| **Betroffenenrechte** | Art. 15–22 | Auskunft, Löschung, Portabilität — muss implementierbar sein (Clerk-Account-Deletion) | ❌ Zu planen |
| **Auftragsverarbeitung** | Art. 28 | AVV mit Vercel, Clerk, Stripe, Anthropic (wenn API-Calls Server-Side) | ❌ Kritisch |
| **Datenschutz by Design** | Art. 25 | Client-Side-Ansatz ist starkes Argument hier — muss technisch dokumentiert sein | 🟢 Konzept gut |
| **Drittland-Transfer** | Art. 44ff | Vercel (US), Clerk (US), Stripe (US), Anthropic (US) — alle US-basiert | 🟡 SCCs nötig |

#### 4.3 Drittland-Transfer (USA) — kritischer Punkt

Alle im Tech-Stack genannten Dienste sind US-amerikanisch:

```
Vercel     → US-Hosting (Europäische Regionen verfügbar — nutzen!)
Clerk      → US-basiert (prüfen ob EU-Region verfügbar)
Stripe     → US-Headquarter (EU-Datenverarbeitung möglich)
Anthropic  → US-basiert (API-Calls — sind das Server-Side-Calls