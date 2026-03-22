# Risk-Assessment-Report: Brain Training Puzzle App

---

## Risiko-Übersicht (Ampel-Tabelle)

| Rechtsfeld | Risiko | Geschätzte Kosten | Zeitaufwand |
|---|---|---|---|
| Monetarisierung & Glücksspielrecht | 🟡 Mittel | €3.000–6.000 | 3–4 Wochen |
| App Store Richtlinien | 🟡 Mittel | €1.500–3.000 | 2–3 Wochen |
| AI-Content & Urheberrecht | 🟡 Mittel (→🔴 situativ) | €4.000–8.000 | 3–5 Wochen |
| Datenschutz (DSGVO / COPPA) | 🔴 Hoch | €15.000–35.000 einmalig + €6.000–12.000/Jahr | 8–14 Wochen |
| Jugendschutz (USK / PEGI) | 🟢 Niedrig | €500–1.500 | 2–4 Wochen |
| Social Features & Plattformauflagen | 🟡 Mittel | €2.000–4.000 | 2–3 Wochen |
| Markenrecht & Namenskonflikt | 🟡 Mittel | €3.000–7.000 | 4–6 Wochen |
| Wissenschaftskommunikation / FTC | 🔴 Hoch | €8.000–20.000 einmalig + €3.000–6.000/Jahr | 6–10 Wochen |
| Patente | 🟢 Niedrig | €2.000–3.500 | 2–3 Wochen |

---

## Detailbewertung pro Feld

### 1. Monetarisierung & Glücksspielrecht

- **Risiko:** 🟡 Mittel
- **Begründung:** Das Konzept ist durch die Wahl eines transparenten Battle Pass ohne Zufallskomponente strukturell gut aufgestellt. Das Hauptrisiko liegt nicht im aktuellen Recht, sondern in der laufenden EU-Regulierungsdebatte (Parlamentsinitiative Oktober 2025) und in der Sonderposition Belgiens und der Niederlande. Ein technischer Implementierungsfehler — z.B. eine versehentlich zufallsbasierte Bonus-Mechanik im Battle Pass — würde die Risikostufe sofort auf 🔴 heben. Die Rewarded-Ads-Komponente ist regulatorisch unkritisch, solange kein monetärer Einsatz und kein Zufallsgewinn vorliegen.
- **Geschätzte Kosten:**
  - Anwaltliche Prüfung Reward-Mechanik für EU (inkl. Belgien/NL): €3.000–6.000 einmalig
  - Monitoring EU-Gesetzgebung (Jahrespauschale Anwalt oder Compliance-Abo): €1.500–3.000/Jahr
- **Alternative (Risikoreduktion):** Battle-Pass-Mechanik bereits im Design-Dokument durch einen auf Gaming-Recht spezialisierten Anwalt abnehmen lassen — bevor Entwicklung beginnt, nicht danach. Kostet weniger als eine nachträgliche Überarbeitung.

---

### 2. App Store Richtlinien

- **Risiko:** 🟡 Mittel
- **Begründung:** Kein grundsätzlicher Konflikt mit Apple- oder Google-Guidelines, aber mehrere operative Fallstricke mit direktem Revenue-Impact. Die wichtigsten: (a) Apple-Provision von 30% im ersten Jahr muss in der Preiskalkulation abgebildet sein — bei $6,99/Monat verbleiben effektiv ~$4,89 netto, was die LTV-Rechnung verändert. (b) App Tracking Transparency (ATT) reduziert Rewarded-Ad-Revenue bei Nicht-Consent um geschätzt 40–60%, was den Ads-Anteil am Revenue-Mix erheblich drückt. (c) Die Formulierung kognitiver Claims in App-Beschreibung und Screenshots birgt Rejection-Risiko — Apple lehnt irreführende Funktionsversprechen ab.
- **Geschätzte Kosten:**
  - Anwaltliche/UX-Prüfung der Abo-Disclosure und Store-Beschreibung: €1.500–3.000 einmalig
  - Laufende Guidelines-Compliance (Updates nach Apple/Google Policy-Änderungen): im Rahmen regulärer Entwicklungskosten
- **Alternative (Risikoreduktion):** Store-Beschreibung und Abo-UI durch ein auf Mobile-Compliance spezialisiertes UX-/Legal-Team abnehmen lassen. Standard-Praxis für seriöse App-Launches, kein außergewöhnlicher Aufwand.

---

### 3. AI-Content & Urheberrecht

- **Risiko:** 🟡 Mittel — mit situativer Eskalation auf 🔴
- **Begründung:** Der KI-adaptive Algorithmus selbst ist urheberrechtlich unkritisch (Eigenentwicklung als Trade Secret schützbar). Das Risiko liegt in zwei anderen Bereichen: Erstens, falls KI-Tools zur Generierung visueller Assets verwendet werden, die explizit im Stil von Monument Valley gestaltet sind — hier ist die Grenze zwischen nicht schutzfähiger Stil-Inspiration und potenziellem Infringement 2025 rechtlich ungelöst. Zweitens können ohne substantielle menschliche Überarbeitung KI-generierte Puzzle-Inhalte keinen Copyright-Schutz für das Unternehmen beanspruchen, was Imitationsrisiken durch Wettbewerber erhöht. Die US-Copyright-Office-Guidance vom Januar 2025 ist eindeutig: rein KI-generierte Werke sind nicht schutzfähig.
- **Geschätzte Kosten:**
  - Workflow-Prüfung durch Medien-/IT-Anwalt (Urheberrecht KI-Assets): €4.000–8.000 einmalig
  - Falls externe KI-Asset-Generierung: Lizenzprüfung der verwendeten Tools (Midjourney, DALL-E etc.): €500–1.500 einmalig
- **Alternative (Risikoreduktion):** Visuelle Assets durch menschliche Designer erstellen lassen, die sich von Monument Valley *inspirieren lassen*, aber keine KI-Imitation nutzen. Das schützt vor dem Stil-Konflikt und erzeugt zugleich eigene schutzfähige Werke. Mehrkosten gegenüber reiner KI-Generierung: real, aber im Verhältnis zum Haftungsrisiko vertretbar.

---

### 4. Datenschutz (DSGVO / COPPA)

- **Risiko:** 🔴 Hoch
- **Begründung:** Dies ist das komplexeste Einzelrisiko des gesamten Projekts. Drei Problemstränge überlagern sich: (a) **Kognitionsdaten als potenzielle Gesundheitsdaten nach Art. 9 DSGVO** — das Kalibrierungs-Puzzle generiert ein kognitives Profil, das je nach Formulierung und Auswertungstiefe als besondere Kategorie personenbezogener Daten eingestuft werden könnte. Das würde explizite Einwilligung, Datenschutz-Folgenabschätzung (DSFA) und ggf. Konsultation der Aufsichtsbehörde erfordern. (b) **KI-Nutzerprofil + Social Features** — die Kombination aus Verhaltens-Tracking für Adaptivität und asynchronen Challenge-Features erfordert eine vollständige DSGVO-Umsetzung: Datenschutzerklärung, AVV mit Firebase/PlayFab, Recht auf Löschung/Auskunft implementiert im Backend. (c) **COPPA (USA) / KOSA-Regulierungstrend** — obwohl die Zielgruppe 35–54 ist, genügt eine nicht ausreichend altersverifizierte Registrierung, um COPPA-Pflichten auszulösen, falls Minderjährige faktisch die App nutzen. Rewarded Ads mit potenziell demografisch unkontrollierten Nutzern verstärken dieses Risiko.
- **Geschätzte Kosten:**
  - DSGVO-Erstimplementierung (Anwalt + Datenschutzbeauftragter + technische Umsetzung): €15.000–25.000 einmalig
  - Datenschutz-Folgenabschätzung (DSFA) für Kognitionsdaten-Verarbeitung: €5.000–10.000 einmalig
  - Laufender externer Datenschutzbeauftragter (DSB, in DE ab bestimmten Schwellenwerten Pflicht): €6.000–12.000/Jahr
  - COPPA-Compliance-Prüfung durch US-Anwalt: €3.000–6.000 einmalig
  - **Gesamteinmalig: €23.000–41.000**
  - **Laufend: €6.000–12.000/Jahr**
- **Alternative (Risikoreduktion):** Privacy-by-Design von Anfang an als Architekturprinzip verankern — das reduziert die Nachbesserungskosten drastisch. Konkret: Kognitionsprofil so konstruieren, dass es keine Rückschlüsse auf Gesundheitszustände erlaubt (Performance-Metriken statt diagnostischer Interpretationen). Social Features konsequent als Opt-in implementieren (Brief sieht das bereits vor — muss technisch sauber umgesetzt werden). Altersverifikation oder zumindest Alters-Gate im Onboarding einbauen.

---

### 5. Jugendschutz (USK / PEGI)

- **Risiko:** 🟢 Niedrig
- **Begründung:** Die Zielgruppe 35–54 und das Fehlen von Gewalt, Glücksspiel im engen Sinne und expliziten Inhalten sprechen für eine unkomplizierte Altersfreigabe. PEGI 3 oder PEGI 7 ist realistisch. Die formale Einstufung ist Pflicht für den EU-Markt — aber kein inhaltliches Hindernis.
- **Geschätzte Kosten:**
  - PEGI-Bewerbung und -Zertifizierung: €500–1.500 einmalig
  - USK-Kennzeichnung (für Deutschland): im PEGI-Prozess weitgehend abgedeckt, ggf. €200–500 zusätzlich

---

### 6. Social Features & Plattformauflagen

- **Risiko:** 🟡 Mittel
- **Begründung:** Leaderboards und asynchrone Freundes-Challenges sind regulatorisch überschaubar, solange sie sauber als Opt-in implementiert sind (Brief sieht das vor — technische Umsetzung muss dem entsprechen). Das Risiko liegt in zwei Bereichen: (a) Plattform-spezifische Social-Feature-Guidelines (Apple Game Center, Google Play Games) haben eigene Anforderungen an Leaderboard-Implementierungen. (b) Falls Nutzerdaten für das Social-Ranking geteilt werden, entstehen zusätzliche DSGVO-Anforderungen (Datenweitergabe an andere Nutzer). Der Online Safety Act (UK, 2024) und vergleichbare EU-Regulierung (Digital Services Act) können für soziale Komponenten in Apps mit nutzergeneriertem Inhalt relevant werden — hier ist der Umfang für dieses Konzept aber begrenzt.
- **Geschätzte Kosten:**
  - Rechtliche Prüfung Social Features (DSGVO + Plattform-Guidelines): €2.000–4.000 einmalig
  - Im Rahmen der DSGVO-Gesamtimplementierung (Pos. 4) weitgehend abgedeckt

---

### 7. Markenrecht & Namenskonflikt

- **Risiko:** 🟡 Mittel
- **Begründung:** Der Namensraum "Brain Training" ist generisch und damit nicht markenschutzfähig — das ist ein Vorteil (keine Klage wegen des Begriffs selbst) und ein Nachteil (eigener Name braucht Differenzierung, um schutzfähig zu sein). Das Hauptrisiko liegt im App-Namen und Branding: Bestehende Marken wie "Lumosity", "Elevate", "Peak" sind eingetragen. Ein zu ähnlicher Name oder ein Logo mit visueller Verwechslungsgefahr ist ein direktes Abmahnungsrisiko. Im DACH-Raum sind Abmahnkosten real (Streitwerte €10.000–50.000 sind üblich). Internationale Markenrecherche ist Pflicht vor der Namensveröffentlichung.
- **Geschätzte Kosten:**
  - Markenrecherche (DACH + EU + USA + Australien): €1.500–3.000 einmalig
  - Markenanmeldung EU (EUIPO): €850–1.500 Grundgebühr + Anwaltskosten €1.000–2.500
  - US-Markenanmeldung (USPTO): €500–1.000 Gebühren + Anwaltskosten €1.500–2.500
  - **Gesamteinmalig: €3.000–7.000**

---

### 8. Wissenschaftskommunikation / FTC

- **Risiko:** 🔴 Hoch
- **Begründung:** Dies ist neben dem Datenschutz das zweithöchste Risiko — und das mit der größten reputativen Dimension. Der FTC-Fall gegen Lumosity (2016, $2 Mio. Vergleich) hat einen Präzedenzfall geschaffen, der die gesamte Kategorie unter Beobachtung stellt. Die FTC Endorsement Guides 2023 haben die Anforderungen an substanziierte Werbeclaims verschärft. Konkret: Jede Aussage, die kognitive Verbesserungen verspricht — ob in der App-Beschreibung, im Onboarding oder im Marketing — muss durch peer-reviewed Studien belegbar sein oder als subjektive Wahrnehmung kenntlich gemacht werden. Das gilt nicht nur für den US-Markt: In Deutschland ist das UWG (Gesetz gegen den unlauteren Wettbewerb) ähnlich streng bei nicht substantiierten Wirkversprechen, und die EU-Richtlinie über irreführende Geschäftspraktiken gilt ebenfalls. Das Konzept sieht "ehrliche Evidenzkommunikation" vor — das ist die richtige Richtung, aber ohne rechtliche Absicherung ist es ein Lippenbekenntnis.
- **Geschätzte Kosten:**
  - Anwaltliche Prüfung aller Marketing- und Onboarding-Texte (UWG/FTC): €5.000–10.000 einmalig
  - Wissenschaftliche Kooperation oder externe Validierungsstudie: €8.000–20.000 einmalig (je nach Scope)
  - Laufende rechtliche Prüfung bei Content-Updates (neue Saison, neue Claims): €3.000–6.000/Jahr
  - **Gesamteinmalig: €13.000–30.000**
  - **Laufend: €3.000–6.000/Jahr**
- **Alternative (Risikoreduktion):** Claims auf nachweislich messbare, nicht-diagnostische Trainingseffekte beschränken — z.B. "trainiert Reaktionsgeschwindigkeit in Puzzle-Aufgaben" statt "verbessert deine kognitive Leistung" oder gar "schützt vor Demenz". Eine Universität oder ein unabhängiges Forschungsinstitut (z.B. DZNE, Fraunhofer-Institut) als wissenschaftlichen Partner einzubinden ist keine Kostenposition, sondern ein strategisches Asset, das gleichzeitig differenziert und das Rechtsrisiko strukturell reduziert.

---

### 9. Patente

- **Risiko:** 🟢 Niedrig
- **Begründung:** Im Mobile-Gaming- und Brain-Training-Segment sind keine bekannten Sperrpatente auf Kernmechaniken wie adaptive Schwierigkeitsgrade, Battle-Pass-Strukturen oder Leaderboards identifizierbar — diese Konzepte sind zu generisch für Patentschutz. Ein Screening ist dennoch sinnvoll, insbesondere wenn der KI-Adaptivitäts-Algorithmus proprietäre Methoden verwendet.
- **Geschätzte Kosten:**
  - Basis-Patent-Screening durch IP-Anwalt: €2.000–3.500 einmalig
  - Kein laufender Aufwand erwartet

---

## Regionale Einschränkungen

- **🇧🇪 Belgien:** Battle-Pass-Mechanik muss vor Launch durch lokalen Gaming-Anwalt auf Konformität mit der Gambling Commission-Praxis geprüft werden. Launch ohne diese Prüfung: eingeschränkt empfehlenswert.
- **🇳🇱 Niederlande:** Ähnliche Einschränkung wie Belgien. KSA (Kansspelautoriteit) hat Loot-Box-Ähnliches in der Vergangenheit aggressiv verfolgt. Ohne Rechtsprüfung: eingeschränkt launchbar.
- **🇨🇳 China:** Aufgrund der Online Game Administration Regulations 2023/2025 (Echtnamensregistrierung, Ausgabelimits, separates Genehmigungsverfahren) ist China aus dem initialen Launch-Scope auszuklammern. Ein China-Launch erfordert ein eigenständiges Compliance-Projekt mit geschätzten Kosten von €30.000–80.000+ und einem Zeithorizont von 12–18 Monaten — nicht im MVP-Scope sinnvoll.
- **🇷🇺 Russland:** Aufgrund der geopolitischen Lage, App-Store-Restriktionen und regulatorischer Unberechenbarkeit: aus dem Launch-Scope ausklammern.
- **🇺🇸 USA (COPPA):** Sofern keine Altersverifikation implementiert ist, besteht latentes COPPA-Risiko, falls Minderjährige faktisch die App nutzen. Kein generelles Launch-Hindernis, aber technische Schutzmaßnahme (Age Gate im Onboarding) vor US-Launch Pflicht.

---

## Gesamtkosten-Schätzung Compliance

| Kostenblock | Einmalig | Laufend/Jahr |
|---|---|