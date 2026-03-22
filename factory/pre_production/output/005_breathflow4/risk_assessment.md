# Risk-Assessment-Report: Minimalistische Atem-Übungs-App

**Durchlauf-ID:** breathflow4 | **Report-Typ:** Risk-Assessment | **Stand:** Juni 2025
**Erstellt von:** Risk-Assessment-Spezialist | **Basis:** Concept Brief + Legal-Research-Report (breathflow4)

---

## Risiko-Übersicht (Ampel-Tabelle)

| # | Rechtsfeld | Risiko | Geschätzte Kosten (einmalig) | Zeitaufwand |
|---|---|---|---|---|
| 1 | Monetarisierung & Glücksspielrecht | 🟢 | — | — |
| 2 | App Store Richtlinien | 🟡 | €300–€800 | 1–2 Wochen |
| 3 | AI-generierter Content / Urheberrecht | 🟡 | €0–€500 | 1 Woche |
| 4 | Datenschutz (DSGVO / COPPA) | 🟡 | €500–€1.500 | 2–3 Wochen |
| 5 | Jugendschutz (USK / PEGI / IARC) | 🟢 | €0–€100 | 1–2 Tage |
| 6 | Social Features | 🟢 | — | — |
| 7 | Markenrecht — Namenskonflikt | 🟡 | €500–€2.000 | 2–4 Wochen |
| 8 | Patente | 🟡 | €800–€2.500 | 2–4 Wochen |
| 9 | Medizinrecht / Gesundheitsrecht | 🔴 | €2.000–€8.000 | 4–10 Wochen |

---

## Detailbewertung pro Feld

### 1. Monetarisierung & Glücksspielrecht

- **Risiko:** 🟢
- **Begründung:** Kein Zufallsmechanismus, kein Echtgeld-Einsatz mit Gewinnchance, kein virtuelles Währungssystem. Der empfohlene Einmalkauf (€1,99–€2,99) ist die regulatorisch sauberste Monetarisierungsform im mobilen Markt. Auch der optionale Spendenbutton ist unproblematisch, sofern die App-Store-Formulierung korrekt ist (→ Feld 2). EU-Glücksspielregulierung 2025 zielt auf Loot Boxes — strukturell nicht anwendbar.
- **Geschätzte Kosten:** Keine.
- **Handlungsbedarf:** Formulierung des IAP-Spendenbuttons im App Store klar und nicht irreführend halten. Kein Rechtsberatungsbedarf erforderlich.

---

### 2. App Store Richtlinien

- **Risiko:** 🟡
- **Begründung:** Drei beherrschbare Stolperstellen, die bei falscher Vorbereitung zu Rejection führen — nicht zu strukturellen Problemen:
  - **Privacy Policy fehlt → Rejection.** Apple und Google verlangen eine Privacy Policy auch bei Apps die keine Daten sammeln. Das ist der häufigste Launch-Blocker für neue Entwickler und vollständig vermeidbar.
  - **IAP-Implementierung des Spendenbuttons.** Ein "optionaler Unterstützungs-IAP der nichts freischaltet" muss Apple-konform formuliert sein. Wird er als regulärer IAP implementiert, nimmt Apple 15–30% Provision. Wird er als Spendenlink außerhalb des IAP-Systems implementiert, riskiert man App-Rejection wegen Verstoß gegen §3.1.1.
  - **Health-App-Kategorie bei Google Play.** Google Play hat 2023 eine separate Policy für Health-Apps eingeführt. Atemübungs-Apps könnten zusätzliche Sicherheitserklärungen erfordern — insbesondere wenn gesundheitliche Claims in der App-Beschreibung gemacht werden (→ direkte Wechselwirkung mit Feld 9).
- **Geschätzte Kosten:** €300–€800 für Jurist oder erfahrenen App-Entwickler zur Erstellung einer DSGVO-konformen Privacy Policy und korrekten IAP-Implementierungsberatung. Alternativ: Privacy-Policy-Generatoren (iubenda, termly.io) für €100–€200/Jahr als Self-Service-Option.
- **Alternative:** Privacy Policy via Template-Generator (iubenda DSGVO-konform, ca. €100–€200/Jahr) selbst erstellen und durch Anwalt einmalig reviewen lassen (€300–€500). Gesamtkosten dann am unteren Ende der Schätzung.

---

### 3. AI-generierter Content / Urheberrecht

- **Risiko:** 🟡
- **Begründung:** Das Konzept spezifiziert keine KI-generierten Assets explizit. Das Risiko ist **kontextabhängig** — es hängt davon ab, ob Ambient-Sounds, Musik oder visuelle Assets via KI-Tools erstellt werden.
  - **Kreis-Animation als UI-Element:** Urheberrechtlich weitgehend unproblematisch — Kategorie-Standard, geringe Gestaltungshöhe, kein signifikantes Schutzpotenzial für Dritte.
  - **Ambient-Sounds / Musik (falls vorhanden):** Das ist das eigentliche Risiko. GEMA-Rechte (Deutschland), SUISA (Schweiz) und AKM (Österreich) greifen bei kommerzieller Nutzung. KI-generierte Musik muss aus einem kommerziell klar lizenzierten Tool stammen (Suno Pro, ElevenLabs, etc. — jeweilige AGB prüfen).
  - **Icons / visuelle Assets:** Bei Nutzung von CC0-Quellen (The Noun Project free tier, Unsplash, Freesound.org) kein Risiko. Bei KI-generierten Assets: kommerzielle Lizenz des Tools erforderlich.
- **Geschätzte Kosten:** €0 bei konsequenter Nutzung von CC0-Assets und kommerziell lizenzierten Tools. €200–€500 für einmalige rechtliche Prüfung der Asset-Lizenzkette falls KI-Tools eingesetzt werden.
- **Alternative:** Vollständig auf CC0-lizenzierte Assets (Freesound.org für Sounds, Material Design Icons für UI) setzen. Kosten: €0. Risiko: praktisch eliminiert.

---

### 4. Datenschutz (DSGVO / COPPA)

- **Risiko:** 🟡
- **Begründung:** Das Konzept ist technisch nahezu ideal für DSGVO-Konformität konfiguriert — vollständig offline, kein Backend, kein Account, keine Analytics-SDKs. Das ist das geringstmögliche Risikoprofil. Trotzdem bestehen **drei Pflichten**, die auch bei "keine Daten" existieren:
  - **Datenschutzerklärung (Pflicht):** Muss auch erklären, dass *keine* Daten gesammelt werden. Muss im App Store hinterlegt, in der App verlinkt und (für DACH) auf einer Webpräsenz veröffentlicht sein.
  - **Impressumspflicht (Deutschland/Österreich):** Eine kommerzielle App im deutschen Markt erfordert ein rechtssicheres Impressum — erreichbar über die App-Store-Seite oder eine verlinkte Website. Fehlt es, drohen Abmahnungen (Abmahnrisiko in Deutschland ist real und nicht trivial).
  - **COPPA (USA):** Nicht primärer Markt laut Concept Brief, aber bei globalem App-Store-Listing relevant. Falls die App explizit nicht für Kinder unter 13 gedacht ist, reicht eine entsprechende Altersangabe im App Store. Keine aktive COPPA-Compliance erforderlich, solange keine Daten von Minderjährigen gesammelt werden — was bei dieser App der Fall ist.
  - **Lokale Daten (Wochenfortschritt):** SharedPreferences / UserDefaults sind On-Device-Speicherung ohne Personenbezug. DSGVO-relevant nur wenn diese Daten auf Personen rückführbar wären — bei einer Account-freien App ohne Identifier: **nicht der Fall**. Kein DSGVO-Risiko für den lokalen Wochenfortschritt.
- **Geschätzte Kosten:** €500–€1.500 für Datenschutzerklärung (anwaltlich erstellt oder Template + Review), Impressum und einmalige DSGVO-Compliance-Prüfung.
- **Alternative:** DSGVO-Template-Generator (iubenda, Datenschutz-Generator.de) als Basis, einmaliges Anwalts-Review für €300–€600. Gesamtkosten am unteren Ende.

---

### 5. Jugendschutz (USK / PEGI / IARC)

- **Risiko:** 🟢
- **Begründung:** Eine minimalistische Atemübungs-App ohne Gewalt, sexuelle Inhalte, Glücksspiel oder problematische Kommunikationsfunktionen erhält mit hoher Wahrscheinlichkeit die niedrigste Altersfreigabe (USK 0 / PEGI 3 / IARC "Everyone"). Google Play nutzt das IARC-Selbsteinstufungssystem — der Fragebogen ist kostenlos und dauert ca. 15 Minuten. Apple vergisst man in der Praxis oft: Die Altersfreigabe wird im App Store Connect beim Upload gesetzt.
- **Geschätzte Kosten:** €0–€100 (Zeitaufwand für IARC-Fragebogen, keine externen Kosten).
- **Handlungsbedarf:** Minimal. Sorgfältige Beantwortung des IARC-Fragebogens reicht aus.

---

### 6. Social Features

- **Risiko:** 🟢
- **Begründung:** Keine Social Features im Konzept. Keine User-Generated-Content-Haftung, keine Community-Management-Pflichten, keine NetzDG-Relevanz (Deutschland). Dieses Feld ist strukturell nicht anwendbar.
- **Geschätzte Kosten:** Keine.

---

### 7. Markenrecht — Namenskonflikt

- **Risiko:** 🟡
- **Begründung:** Der App-Name ist im Concept Brief nicht spezifiziert ("BreathFlow" ist die Durchlauf-ID, nicht notwendigerweise der App-Name). Das ist das eigentliche Risiko dieses Feldes: **Der Name wurde noch nicht auf Konflikte geprüft.**
  - Die Kategorie "Breathing Apps" ist im App Store stark belegt. Namen wie "Breathwrk", "Calm", "Oak", "Prana Breath" sind eingetragen. Ähnlich klingende Namen können zu App-Store-Rejection oder Abmahnungen führen.
  - Im DACH-Markt ist eine Markenrecherche im DPMA (Deutsches Patent- und Markenamt), EUIPO (EU-Markenamt) und WIPO empfohlen, bevor Marketing-Assets erstellt oder der App-Name final festgelegt wird.
  - Naming-Konflikt ist eines der häufigsten und teuersten nachträglichen Probleme bei App-Launches — weil Rebranding nach erfolgtem Launch Bewertungen, ASO und organisches Ranking zerstört.
- **Geschätzte Kosten:** €500–€2.000 für Markenrecherche und anwaltliche Erstprüfung. Eigene Markeneintragung (DE oder EU) optional: €290 (DPMA, eine Klasse) bis €850+ (EUIPO). Gesamtpaket mit Anwalt: €1.500–€3.500.
- **Alternative:** Selbstrecherche über DPMA Online, EUIPO eSearch Plus und TMview (kostenlos) als ersten Schritt — reduziert Anwaltskosten auf reines Review. Zeithorizont: 1–2 Wochen Eigenrecherche + 1 Woche Anwalt.

---

### 8. Patente

- **Risiko:** 🟡
- **Begründung:** Der Legal-Research-Report weist dieses Feld als "Recherche-Lücke" aus — das ist korrekt und das eigentliche Risikosignal. Eine detaillierte Patentrecherche wurde nicht durchgeführt.
  - **Animierter Atem-Kreis:** Das Grundprinzip einer sich ausdehnenden Kreis-Animation zur Atemanleitung ist Kategorie-Standard und damit Prior Art. Ein Patent auf das Grundprinzip ist unwahrscheinlich. Spezifische Implementierungen (bestimmte Animationsalgorithmen, spezifische UI-Interaktionsmuster) könnten patentiert sein.
  - **Relevantere Risikoquellen:** Software-Patente in den USA (nicht in der EU) auf spezifische Breathing-App-Mechaniken. Die großen Player (Calm, Headspace) haben Patent-Portfolios — ob diese auf Atemübungs-Mechaniken ausgedehnt wurden, ist ungeprüft.
  - **EU-Kontext:** Softwarepatente sind in der EU grundsätzlich nicht patentierbar (Art. 52 EPÜ) — in der Praxis gibt es Graubereiche bei "computer-implemented inventions". Für den DACH-Launch ist das Patentrisiko strukturell geringer als für einen US-Launch.
- **Geschätzte Kosten:** €800–€2.500 für eine gezielte Patentrecherche durch einen Patentanwalt oder via professioneller Patentdatenbank (Espacenet kostenlos für Selbstrecherche; professionelle Recherche durch Kanzlei €1.500–€2.500).
- **Alternative:** Für den DACH-Launch zunächst Selbstrecherche via Espacenet (kostenlos) auf offensichtliche Konflikte. Professionelle Patentrecherche vor US-Launch zwingend empfohlen — für den initialen DACH-Launch ist das Risiko beherrschbar ohne vollständige Patentrecherche, sofern keine US-Distribution geplant ist.

---

### 9. Medizinrecht / Gesundheitsrecht

- **Risiko:** 🔴
- **Begründung:** Dies ist das kritischste Rechtsfeld — und das einzige mit strukturellem Blockade-Potenzial für den Launch. Der Concept Brief adressiert es nicht. Das ist die wichtigste Ergänzung dieses Reports.

**Das Kernproblem:** Atemübungs-Apps bewegen sich auf einem regulatorischen Grenzgebiet zwischen "Wellness-App" (keine Regulierung) und "Medizinprodukt" (starke Regulierung). Die Einordnung hängt maßgeblich von der **Kommunikation** ab — nicht nur von der Funktion.

**EU Medical Device Regulation (MDR 2017/745):**
Seit Mai 2021 vollständig in Kraft. Eine App ist ein Medizinprodukt der Klasse I oder höher, wenn sie:
- Zur Diagnose, Prävention, Überwachung, Behandlung oder Linderung von Krankheiten dient, **oder**
- Zur Überwachung oder Beeinflussung physiologischer Prozesse eingesetzt wird

Atemübungs-Apps können unter diese Definition fallen, **wenn** in der App-Beschreibung, im Marketing oder in der App selbst Aussagen gemacht werden wie:
- "Reduziert Angstzustände / Panikattacken"
- "Verbessert Schlafqualität klinisch nachgewiesen"
- "Therapeutisch wirksam bei Stress"
- "Empfohlen bei Bluthochdruck / Atemwegserkrankungen"

Wird die App dagegen ausschließlich als "Wellness-Tool" positioniert ("hilft dir, bewusster zu atmen", "eine Minute Pause für deinen Tag"), ist sie **kein Medizinprodukt** nach MDR.

**Apple App Store Health-Review (§1.4):**
Apple lehnt Apps ab, die medizinische Claims machen ohne entsprechende Zertifizierung. Gleichzeitig lehnt Apple Apps ab, die gesundheitliche Informationen bereitstellen die "ungenau sein und Schaden anrichten könnten". Das ist eine Grauzone die durch klare, nicht-medizinische Kommunikation navigiert werden kann.

**Das konkrete Risiko für dieses Konzept:**
Die 4-7-8-Technik ist eine von Dr. Andrew Weil entwickelte und prominent vermarktete Entspannungsmethode. In der öffentlichen Wahrnehmung wird sie oft mit Schlafproblemen, Angstreduktion und Stressmanagement verbunden. Wenn die App-Beschreibung oder In-App-Texte diese Verbindungen explizit herstellen — auch unbewusst durch Formulierungen wie "hilft beim Einschlafen" oder "beruhigt das Nervensystem" — betritt man regulatorisch ungesichertes Terrain.

- **Geschätzte Kosten:** €2.000–€8.000 für:
  - Rechtsberatung durch auf Medizinrecht spezialisierten Anwalt (€1.500–€4.000 einmalig)
  - Formulierungsreview aller App-Texte, App-Store-Beschreibungen, Marketing-Materialien (€500–€2.000)
  - Ggf. MDR-Konformitätsbewertung falls Medizinprodukt-Klassifikation nicht sicher ausgeschlossen werden kann (€2.000–€6.000 zusätzlich — aber bei konsequenter Wellness-Positionierung vermeidbar)

- **Alternative (Risiko-Reduktion auf 🟡):**
  Konsequente und dokumentierte "Wellness-Only"-Positionierung. Konkret:
  1. **Keine medizinischen oder therapeutischen Claims** in App-Text, App-Store-Beschreibung, Website oder Social Media. Nicht "reduziert Angst", sondern "eine Pause für deinen Alltag". Nicht "verbessert Schlaf klinisch", sondern "begleitet dich beim Einschlafen".
  2. **Disclaimer in der App:** "Diese App ist kein Medizinprodukt und ersetzt keine medizinische Beratung." Einmalig bei erstem Start sichtbar — nicht als Onboarding-Screen (widerspricht dem Zero-Friction-Prinzip), sondern als persistente Info in den Einstellungen.
  3. **Einmaliges Anwalts-Review** der finalen App-Store-Beschreibung und aller In-App-Texte durch einen auf Mediz