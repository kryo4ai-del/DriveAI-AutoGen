# Risk-Assessment-Report: Minimalistische Atem-Übungs-App

---

## Risiko-Übersicht (Ampel-Tabelle)

| Rechtsfeld | Risiko | Geschätzte Kosten | Zeitaufwand |
|---|---|---|---|
| Monetarisierung & IAP-Compliance | 🟢 | 0–200 € | 1–2 Wochen |
| App Store Richtlinien (Apple / Google) | 🟡 | 300–800 € | 2–3 Wochen |
| AI-generierter Content — Urheberrecht | 🟡 | 0–500 € | 1 Woche |
| Datenschutz (DSGVO / COPPA) | 🟡 | 400–900 € | 1–2 Wochen |
| Jugendschutz (USK / PEGI / IARC) | 🟢 | 0 € | < 1 Woche |
| Markenrecht — Namenskonflikt | 🟡 | 300–1.500 € | 2–4 Wochen |
| Patente (Animations-Mechaniken) | 🟢 | 0–300 € | 1 Woche |
| Social Features — Auflagen | ⚪ | — | — |

---

## Detailbewertung pro Feld

### 1. Monetarisierung & IAP-Compliance

- **Risiko:** 🟢
- **Begründung:** Das gewählte OTP-Modell ist die rechtlich sauberste Monetarisierungsform im App-Bereich. Kein Zufallselement, kein Subscription-Trap, kein verdeckter Preismechanismus. Das EU-Verbraucherrecht (Richtlinie 2019/770) ist erfüllt, solange der Leistungsumfang des Kaufs im App-Store-Listing und im In-App-Kaufdialog eindeutig beschrieben ist. Das Widerrufsrecht erlischt bei digitalen Inhalten mit sofortiger Nutzbarkeit nach ausdrücklicher Zustimmung — Apple und Google handhaben dies prozessual selbst. Für DACH kein erhöhter Sonderaufwand. Glücksspielrechtliche Tatbestände (Loot Boxes, randomisierte Inhalte) sind strukturell nicht einschlägig.
- **Geschätzte Kosten:** 0 € technisch. Einmaliger Anwaltsstunden-Aufwand für AGB-Prüfung: 150–200 € (Einzelanwalt, pauschal für einfache digitale Produkte). Dieser Aufwand ist ohnehin mit dem DSGVO-Punkt kombinierbar und fällt nicht separat ins Gewicht.
- **Alternative:** Entfällt bei 🟢. Keine Risikominimierungsmaßnahme erforderlich außer der ohnehin empfohlenen AGB-Prüfung.

---

### 2. App Store Richtlinien (Apple / Google)

- **Risiko:** 🟡
- **Begründung:** Das Risiko liegt nicht im rechtlichen, sondern im **plattform-technischen Compliance-Bereich** — und dort ist es real. Konkret: StoreKit 2 (iOS) und Google Play Billing Library müssen von Anfang an korrekt implementiert sein. Eine nachträgliche Integration nach Ablehnung kostet mehr Zeit und Nerven als eine Vorab-Planung. Zusätzlich verlangt Apple bei Apps mit Wellness/Health-Bezug in der Praxis einen **medizinischen Disclaimer** — fehlt dieser, kann es zu Verzögerungen beim Review-Prozess kommen (typisch: 1–3 Tage Verzögerung pro Revision, im Worst Case mehrere Iterationen). Die Einordnung in die korrekte Kategorie (Health & Fitness, nicht Medical) ist relevant, weil die Kategorie die Auffindbarkeit und Review-Tiefe beeinflusst. Das DMA-Umfeld (EU-Ausnahmen bei externen Zahlungswegen) ist ein sich entwickelndes Rechtsfeld — für einen Erstentwickler ohne Rechtsabteilung ist die Standardimplementierung über Apple/Google-Billing die sicherste Wahl und erzeugt kein eigenständiges Risiko.
- **Geschätzte Kosten:** Entwicklerkosten für korrekte IAP-Implementierung (Flutter: 4–8 Stunden Entwicklungszeit, bei 50–80 €/h Eigenaufwand oder Freelancer ca. 200–600 €). Apple Developer Program: 99 USD/Jahr (~92 €). Google Play: 25 USD einmalig (~23 €). Gesamt technischer Aufwand: 300–800 €, davon der größte Teil Entwicklungszeit.
- **Alternative:** Kein technisch einfacherer Weg bei OTP-Modell — StoreKit und Play Billing sind Pflicht. Risikominimierung durch: (a) frühe Implementierung im Entwicklungsprozess, nicht als letzter Schritt, (b) proaktiver Disclaimer-Text in der App (empfohlen: *"Diese App dient der persönlichen Entspannung und ersetzt keine medizinische Beratung. Bei gesundheitlichen Beschwerden wende dich an eine Ärztin oder einen Arzt."*), (c) App-Kategorie beim Einreichen prüfen: Health & Fitness, nicht Meditation, nicht Medical.

---

### 3. AI-generierter Content — Urheberrecht

- **Risiko:** 🟡
- **Begründung:** Das Risiko ist **bedingt relevant** — es hängt vollständig davon ab, ob und welche Assets per KI-Tool generiert werden. Die Kernmechanik (Kreis-Animation als Code) ist urheberrechtlich unproblematisch — Animationslogik ist Funktionalität, kein Kunstwerk. Relevant wird das Feld bei Icons, Hintergrundgrafiken, Sounds und illustrativen Elementen. Nach dem US-Copyright-Office-Report (Januar 2025) und der herrschenden EU-Position sind rein KI-generierte Outputs nicht schutzfähig — das bedeutet: Der Entwickler kann von Nachahmern nicht geschützt werden, riskiert aber umgekehrt auch keine Verletzung fremder Rechte durch den Output selbst (sofern keine erkennbare Imitation geschützter Werke). Das **eigentliche Risiko** liegt in den AGB der genutzten KI-Tools: Midjourney, DALL-E und vergleichbare Dienste haben kommerzielle Nutzungsbedingungen, die sich regelmäßig ändern und individuell geprüft werden müssen. Für eine minimalistische App mit abstrakten Kreis-Animationen und wenigen UI-Elementen ist das Gesamtrisiko überschaubar.
- **Geschätzte Kosten:** 0 € wenn Assets selbst gestaltet oder aus lizenzierten Stock-Quellen stammen (Adobe Stock Einzellizenz ab ca. 30 €/Asset, Envato Elements ca. 16 €/Monat für Pakete). Falls anwaltliche Prüfung der Tool-AGB gewünscht: 1–2 Anwaltsstunden, ca. 200–500 €. Empfohlener Gesamtaufwand: 0–500 €.
- **Alternative:** Risiko auf 🟢 reduzierbar durch: (a) Nutzung von CC0-/Public-Domain-Assets (z.B. über Unsplash, Heroicons, Material Symbols — alle kostenlos, kommerzielle Nutzung explizit erlaubt), (b) selbst gestaltete SVG-Icons (Flutter/React Native: einfach umsetzbar), (c) vollständig code-basierte Animationen ohne externe Assets (für einen animierten Kreis technisch trivial und die ästhetisch sauberste Lösung für dieses Konzept).

---

### 4. Datenschutz (DSGVO / COPPA)

- **Risiko:** 🟡
- **Begründung:** Das Konzept hat strukturell die **günstigste DSGVO-Ausgangslage**, die eine App haben kann: kein Backend, kein Account, kein Cloud-Transfer, kein Social-Layer. Trotzdem bestehen Mindestpflichten, die nicht optional sind. Eine **Datenschutzerklärung** ist für den EU-Markt Pflicht — auch wenn die ehrliche Aussage darin lautet: "Wir erheben keine personenbezogenen Daten." Diese Aussage ist nicht nur rechtlich ausreichend, sondern gleichzeitig ein Marketingvorteil (positiv im App-Store-Listing kommunizierbar). Die **Impressumspflicht** gilt für kommerzielle Apps mit DE/AT-Sitz. Apple und Google verlangen korrekte Ausfüllung der **Privacy Labels / Data Safety Section** — bei falschen Angaben droht Ablehnung oder nachträgliche Sperrung. Das kritische Risiko liegt bei **Third-Party-SDKs**: Crash-Reporting-Dienste (Firebase Crashlytics, Sentry) und Analytics-Tools übertragen Gerätedaten an externe Server — das erzeugt sofort volle DSGVO-Pflichten inkl. Consent-Management. Flutter selbst sendet keine Telemetrie in Production-Builds, aber dies sollte explizit geprüft werden. COPPA ist bei der Zielgruppe 25–45 Jahre und ohne Kinder-relevante Features nicht einschlägig.
- **Geschätzte Kosten:** Datenschutzerklärung + Impressum: 300–600 € für anwaltlich erstellte/geprüfte Dokumente (DACH-Markt, z.B. über IT-Recht-Kanzlei, trusted.de oder vergleichbare Anbieter — Pakete oft ab 299 €). Alternativ: Datenschutzgeneratoren wie Datenschutz.org oder iubenda (kostenlos bis ca. 60 €/Jahr für Pro-Funktionen) als Grundlage, dann Anwalt nur zur Prüfung (1 Stunde ca. 150–300 €). Kein Consent-Banner erforderlich bei konsequenter Offline-Architektur ohne Drittdienste: 0 € laufend. Gesamtaufwand: 400–900 € einmalig.
- **Alternative:** Risiko auf 🟢 reduzierbar durch: (a) konsequenter Verzicht auf jegliche Drittdienste (kein Firebase, kein Analytics, kein Crash-Reporting in V1 — passt zur Offline-Positionierung und ist für V1 vertretbar), (b) Privacy-Policy-Template von iubenda oder ähnlichem Dienst als kostengünstige Ausgangslage, (c) Nutzung der "kein Backend, keine Daten"-Positionierung als **proaktive** Kommunikation im App-Store-Listing — was rechtliche Transparenzpflichten gleichzeitig erfüllt und das Produkt differenziert.

---

### 5. Jugendschutz (USK / PEGI / IARC)

- **Risiko:** 🟢
- **Begründung:** Eine Atemübungs-App ohne Gewalt, Suchtmechaniken, sexuelle Inhalte, Glücksspielelemente oder Chat-Funktionen erhält beim IARC-Fragebogen (Google Play) und der Apple-eigenen Altersfreigabe automatisch die niedrigste Einstufung: **IARC "Everyone" / USK 0 / PEGI 3.** Dieser Prozess ist vollständig automatisiert und erfordert keine manuelle Einreichung oder Gebühren.
- **Geschätzte Kosten:** 0 €. Zeitaufwand: < 1 Stunde (Ausfüllen des IARC-Fragebogens im Play Console Developer Dashboard und analoge Angaben in App Store Connect).
- **Alternative:** Entfällt bei 🟢.

---

### 6. Markenrecht — Namenskonflikt

- **Risiko:** 🟡
- **Begründung:** Der App-Name ist im Concept Brief noch nicht festgelegt — das ist der richtige Zeitpunkt, dieses Risiko zu adressieren, **bevor** ein Name öffentlich kommuniziert oder das App-Store-Listing erstellt wird. Markenrechtliche Konflikte im App-Bereich entstehen primär durch: (a) identische oder verwechslungsfähige Namen zu bestehenden Apps im selben Markt, (b) eingetragene Marken in den relevanten Klassen (Klasse 9: Software; Klasse 41: Wellness/Education). Im Breathing-App-Markt sind Namen wie "Calm", "Breathwrk", "Oak", "Prana Breath", "Headspace" bereits vergeben — der Umgebungsbereich dieser Begriffe sollte gemieden werden. Eine vollständige Markenrecherche vor Launch ist nicht gesetzlich vorgeschrieben, aber die **praktisch notwendige Grundlage**, um eine kostspielige Umbenennung nach Launch zu vermeiden. Eine Abmahnung nach Launch (z.B. durch einen US-amerikanischen App-Anbieter mit EU-Marke) kann schnell 2.000–5.000 € Anwaltskosten erzeugen — deutlich mehr als eine präventive Recherche.
- **Geschätzte Kosten:** Eigenrecherche (EUIPO-Datenbank, DPMA, WIPO) kostenlos. Anwaltliche Markenrecherche + Gutachten: 300–800 €. Eingetragene EU-Marke (EUTM, falls gewünscht): 850 € für eine Klasse beim EUIPO (plus ggf. Anwaltsgebühren 500–1.000 €). Gesamtrahmen für Recherche ohne Eintragung: 300–800 €. Mit Eintragung: 1.200–2.500 €.
- **Alternative:** Risiko auf 🟢 reduzierbar durch: (a) eigenständige Erstrecherche über EUIPO TMview und Google Play / App Store vor Namensfestlegung, (b) Wahl eines generativen, neuen Begriffs statt beschreibender Wellness-Wörter (beschreibende Begriffe wie "Breathe", "Calm", "Relax" sind in eingetragenen Kombinationen häufig belegt), (c) auf kostspielige Eintragung in V1 verzichten — Recherche-Clearance ist das Minimum, Eintragung optional für spätere Phase.

---

### 7. Patente (Animations-Mechaniken)

- **Risiko:** 🟢
- **Begründung:** Software-Patente auf UI-Animations-Mechaniken sind in der EU strukturell **nicht durchsetzbar** (Art. 52 EPÜ: keine Patente auf Software als solche). In den USA existiert Software-Patent-Recht, aber die Kreis-Animations-Mechanik für Atemübungen ist seit 2018 dokumentierter Industrie-Standard — ein Patent auf eine derart weit verbreitete und generische Mechanik wäre durch den Stand der Technik ("prior art") angreifbar und hat praktisch keine Klagechancen gegen einen Kleinentwickler. Kein aktiver Hinweis in den vorliegenden Reports auf einschlägige Patentstreitigkeiten in diesem Marktsegment.
- **Geschätzte Kosten:** 0 € für den DACH/EU-Markt. Falls gewünscht: oberflächliche US-Patentrecherche über Google Patents (kostenlos, 2–3 Stunden Eigenaufwand) oder anwaltliche Kurzeinschätzung für 150–300 €.
- **Alternative:** Entfällt bei 🟢. Empfehlung: Keine Ressourcen in vertiefte Patentrecherche investieren — das Risiko ist für dieses Konzept, diese Mechanik und diesen Markt vernachlässigbar.

---

## Regionale Einschränkungen

**DACH (DE/AT/CH):** ✅ **Launchfähig ohne Einschränkungen.** DSGVO-Anforderungen sind bei konsequenter Offline-Architektur mit vertretbarem Aufwand erfüllbar. Impressumspflicht beachten.

**EU gesamt:** ✅ **Launchfähig.** DSGVO gilt EU-weit — ein einmal erstelltes, korrektes Datenschutzdokument deckt alle EU-Märkte ab. Kein länderspezifischer Sonderaufwand identifiziert.

**USA:** ✅ **Launchfähig.** COPPA nicht einschlägig (Zielgruppe 25–45 J.). California CCPA bei reiner Offline-App ohne Datenweitergabe praktisch nicht einschlägig. Kein erhöhter Aufwand.

**China:** ⚠️ **Nicht im primären Scope — gesonderte Prüfung erforderlich.** ICP-Lizenz, lokale Server-Anforderungen, spezifische App-Store-Regeln (Drittanbieter-Stores statt Google Play) erzeugen erheblichen Mehraufwand. Kein Risiko für den aktuellen Launch-Scope (DACH + englischsprachige Märkte), aber explizit **vor einem China-Rollout** separat zu bewerten.

**Belgien / Niederlande (Loot-Box-Regulierung):** ✅ **Nicht einschlägig.** OTP ohne Zufallselement fällt unter keine der bestehenden Glücksspiel-Regulierungen beider Länder.

---

## Gesamtkosten-Schätzung Compliance

| Posten | Einmalig | Laufend (pro Jahr) |
|---|---|---|
| AGB + Datenschutzerklärung + Impressum (anwaltlich geprüft) | 400–700 € | 0 € (außer bei Änderungsbedarf) |
| Apple Developer Program | 92 € | 92 €/Jahr |
| Google Play (einmalig) | 23 € | 0 € |
| IAP-Implementierung (Entwicklungszeit, Eigenaufwand) | 200–600 € | 0 € |
| Markenrecherche (Eigenrecherche + Anwalt-Clearance) | 300–800 € | 0 € |
| Assets / Lizenzen (falls benötigt) | 0–300 € | 0–60 € |
| Gesundheits-Disclaimer (eigenständig formulierbar) | 0 € | 0 € |
| **Gesamtrahmen** | **~1.000–2.500 €** | **~90–150 €** |

**Untere Grenze (~1.000 €):** Eigenrecherche Markenrecht, günstige