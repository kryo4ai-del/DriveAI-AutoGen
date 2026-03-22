# Risk-Assessment-Report: Minimalistische Atem-Übungs-App

---

## Risiko-Übersicht (Ampel-Tabelle)

| Rechtsfeld | Risiko | Geschätzte Kosten | Zeitaufwand |
|---|---|---|---|
| Monetarisierung & IAP-Compliance | 🟢 | 0 € (technische Umsetzung intern) | 1–2 Tage |
| App Store Richtlinien | 🟡 | 0–200 € (Privacy Label, Restore Purchases) | 3–5 Tage |
| AI-generierter Content — Urheberrecht | 🟡 | 0–500 € (Asset-Lizenzierung oder Austausch) | 1–3 Tage |
| Datenschutz (DSGVO / COPPA) | 🟡 | 200–500 € (Anwalts-Review Privacy Policy) | 3–5 Tage |
| Jugendschutz (USK / PEGI / IARC) | 🟢 | 0 € (IARC-Fragebogen kostenlos) | 1–2 Stunden |
| Markenrecht — Namenskonflikt | 🟡 | 300–800 € (Markenrecherche + ggf. Anmeldung) | 2–4 Wochen |
| Patente | 🟢 | 0 € | — |
| Medizinrecht / Gesundheitsclaims | 🔴 | 500–1.500 € (Anwalts-Review + Textkorrekturen) | 1–2 Wochen |

---

## Detailbewertung pro Feld

### 1. Monetarisierung & IAP-Compliance

- **Risiko:** 🟢
- **Begründung:** Keinerlei Glücksspielelemente, kein zufallsbasiertes Belohnungssystem, keine virtuellen Währungen. Das Monetarisierungsmodell — Einmalkauf oder Einmalig-Unlock — ist das rechtlich unkomplizierteste Modell, das ein App-Entwickler wählen kann. Keine regulatorische Grauzone in keinem der Zielmärkte (DACH, UK, USA, Skandinavien). Der einzige handlungspflichtige technische Punkt bei Option B ist die Implementierung der *Restore Purchases*-Funktion gemäß Apple-Richtlinien — das ist eine technische, keine rechtliche Anforderung.
- **Geschätzte Kosten:** 0 € extern. Interne Entwicklungszeit für Restore-Purchases-Implementierung: 4–8 Stunden Entwicklerzeit, bereits im normalen Build-Prozess enthalten.
- **Alternative:** Nicht erforderlich.

---

### 2. App Store Richtlinien (Apple / Google)

- **Risiko:** 🟡
- **Begründung:** Kein Showstopper-Risiko, aber zwei handlungspflichtige Punkte mit echter Rejection-Gefahr bei Nichtbeachtung. Erstens: Das **App Privacy Nutrition Label** (Apple) und die **Data Safety Section** (Google Play) müssen korrekt und vollständig ausgefüllt sein, bevor die App eingereicht wird — fehlerhafte oder fehlende Angaben sind ein häufiger Ablehnungsgrund. Zweitens: Bei Option B (Freemium + Einmalig-Unlock) muss die *Restore Purchases*-Funktion technisch vorhanden und testbar sein; Apple-Reviewer prüfen dies aktiv. Der **DMA-Kontext** (EU Digital Markets Act, März 2024) ist ein sich entwickelndes Rechtsfeld, aber für eine Standard-Distribution über den offiziellen App Store ohne alternative Zahlungskanäle derzeit ohne unmittelbare Handlungspflicht. Positiver Effekt der No-Analytics-Architektur: Kein ATT-Prompt, kein Tracking — das beschleunigt den Review-Prozess erfahrungsgemäß.
- **Geschätzte Kosten:** 0 € für Privacy Label und Data Safety (selbst ausfüllbar, kein Anwalt erforderlich). Bei Unsicherheit: 1–2 Stunden Entwicklerzeit zur Kontrolle, 0 € extern.
- **Alternative:** Bei Ablehnung durch Apple/Google wegen formaler Fehler ist der Weg standardisiert: Korrektur einreichen, erneuter Review-Zyklus (5–7 Werktage bei Apple). Kein strukturelles Risiko, nur Zeitverzögerung.

---

### 3. AI-generierter Content — Urheberrecht

- **Risiko:** 🟡
- **Begründung:** Das Risiko ist **vollständig kontrollierbar durch Asset-Entscheidungen vor dem Build**. Wenn keine KI-generierten Assets eingesetzt werden, fällt dieses Feld auf 🟢. Das mittlere Risiko besteht darin, dass im Entwicklungsprozess aus Effizienzgründen KI-Tools (Midjourney, Suno, DALL-E) für Icons, Sounds oder Hintergrundgrafiken eingesetzt werden, ohne die Lizenz- und Herkunftsfrage zu klären. Das konkrete Schadensszenario: Ein Dritter verwendet dieselben KI-generierten Assets (kein eigener Schutzanspruch möglich), oder ein KI-Tool-Anbieter wird wegen Trainingsdaten-Verletzung verklagt, was rückwirkend kommerzielle Nutzbarkeit der Outputs beeinträchtigt. Für diese spezifische App ist das Schadenspotenzial begrenzt — es gibt keine einzigartigen Assets, die das Kernprodukt definieren. Die Kreis-Animation ist programmatisch, nicht grafisch-kreativ im urheberrechtlichen Sinne.
- **Geschätzte Kosten:** Bei Verwendung ausschließlich lizenzklarer Assets (CC0-Quellen wie Freesound, Pixabay, oder manuell erstellte Assets): **0 €**. Bei nachträglichem Asset-Austausch wegen Lizenzproblemen: **100–500 €** für lizenzierte Ersatz-Assets oder Entwicklerzeit. Anwaltsberatung nur erforderlich bei Abmahnungsfall (unwahrscheinlich bei diesem App-Typ und Marktvolumen): **150–300 € pro Stunde**, DACH-Markt.
- **Alternative:** Klare interne Regel vor Asset-Beschaffung: Nur CC0-lizenzierte oder selbst erstellte Assets. Dokumentationspflicht der Quellen in einer internen Asset-Liste. Aufwand: 1 Arbeitsstunde für Prozess-Setup. Eliminiert das Risiko vollständig.

---

### 4. Datenschutz (DSGVO / COPPA)

- **Risiko:** 🟡
- **Begründung:** Die Offline-First-Architektur ist aus Datenschutzperspektive strukturell optimal — es gibt technisch nichts zu "schützen", weil keine Daten das Gerät verlassen. Das verbleibende 🟡-Risiko liegt nicht im Produkt selbst, sondern in zwei formalen Pflichten, die beide App Stores durchsetzen: **(1) Die Privacy Policy ist Pflicht**, unabhängig davon ob Daten erhoben werden. Fehlt sie, wird die App abgelehnt. **(2) Der Entwickler muss als Verantwortlicher im Sinne Art. 13 DSGVO identifizierbar sein** — Name, Kontaktdaten in der Privacy Policy sind gesetzliche Pflicht. Das Restrisiko "Crash-Reporting durch Framework" (React Native / Flutter) ist beherrschbar: Beide Frameworks senden ohne explizit eingebundenes SDK keine Crash-Daten. COPPA ist bei der Zielgruppe 25–45 Jahre doppelt irrelevant. Die Einschätzung "niedrig mit einer klaren Handlungspflicht" aus dem Legal-Report ist korrekt — das 🟡 reflektiert ausschließlich die Formalfehler-Gefahr bei Nichtbeachtung, nicht ein inhärentes Datenschutzrisiko des Produkts.
- **Geschätzte Kosten:** Self-Written Privacy Policy mit Muster-Template: **0 €** möglich, aber riskant bei EU-Distribution. Empfohlen: Anwalts-Review einer kurzen Privacy Policy durch einen auf IT/Datenschutz spezialisierten Anwalt im DACH-Raum: **200–500 €** einmalig (Richtwert für 1–2 Stunden Prüfung eines kurzen Dokuments). Online-Generatoren (iubenda, Termly) mit DSGVO-Compliance-Fokus: **0–100 €/Jahr** als Alternative. Eine einmalig professionell erstellte Privacy Policy ist für diese App ausreichend — kein laufender Beratungsbedarf, solange die Architektur unverändert bleibt.
- **Alternative:** Für eine App dieser Größe und Risikostufe ist ein DSGVO-konformer Online-Generator (iubenda o.ä.) eine legitime Alternative zum Anwalts-Mandat. Empfehlung: Generator für Basis-Erstellung, einmalige Anwalts-Stichprobe zur Validierung. Gesamtkosten unter 300 €.

---

### 5. Jugendschutz (USK / PEGI / IARC)

- **Risiko:** 🟢
- **Begründung:** Die App enthält keine jugendschutzrelevanten Inhalte. Der IARC-Fragebogen (Google Play) und Apples eigenes Rating-System produzieren für eine Atem-App ohne Gewalt, Horror, Sprache, sexuelle Inhalte oder Glücksspiel automatisch die niedrigste Altersfreigabe ("Everyone" / "4+"). Einziger handlungspflichtiger Punkt: Das "Made for Kids"-Flag in Google Play darf **nicht** aktiviert werden — das würde COPPA-Compliance-Anforderungen auslösen und die IAP-Funktion deaktivieren. Die App richtet sich an Erwachsene; die Einstufung "Everyone" ist korrekt und schließt Kinder nicht aus, aktiviert aber keine Sonderregeln.
- **Geschätzte Kosten:** 0 €. Der IARC-Fragebogen ist kostenlos und dauert ca. 15–30 Minuten.
- **Alternative:** Nicht erforderlich.

---

### 6. Markenrecht — Namenskonflikt

- **Risiko:** 🟡
- **Begründung:** Der App-Name ist zum Zeitpunkt dieses Reports unbekannt — das ist der Kern des Risikos. Generische Begriffe wie "Breathe", "Calm", "Breath" sind in der Wellness-App-Kategorie stark belegt. Apple hält selbst die Marke "Breathe" (Apple Watch Feature). Breathwrk, Calm, Headspace, Prana Breath sind eingetragene Marken in den USA und/oder EU. Ein Namenskonflikt vor oder nach Launch ist das realistischste rechtliche Risiko für dieses Projekt — nicht wegen Vorsatz, sondern wegen der Dichte existierender Marken in diesem Bereich. Schadensszenario: App muss nach Launch umbenannt werden (Store-Listing ändern, Update pushen, Marketing-Material ersetzen) — operativer Aufwand von mehreren Wochen und Vertrauensverlust bei frühen Nutzern. Schwerwiegenderes Szenario: Abmahnung durch Markeninhaber (bei großen Playern wie Apple oder Calm: reales Risiko, da deren Rechtsabteilungen aktiv monitoren).
- **Geschätzte Kosten:** Markenrecherche (DPMA für Deutschland, EUIPO für EU, USPTO für USA) selbst durchführbar via Online-Datenbanken: **0 €**, aber zeitaufwendig und fehleranfällig ohne Fachkenntnis. Empfohlen: Markenrecherche durch IP-Anwalt im DACH-Raum: **300–600 €** einmalig. Optional: EU-Markenanmeldung beim EUIPO: **850 € Basisgebühr** für eine Klasse, zuzüglich Anwaltskosten (300–500 €) — sinnvoll wenn der Name ein echter Differentiator werden soll. Für eine minimalistische App dieser Größe ist die Markenanmeldung optional, die Recherche jedoch **Pflicht vor Launch**.
- **Alternative:** Pragmatische Risikovermeidung ohne Markenanmeldung: (a) App-Namen vor der Entwicklung gegen DPMA, EUIPO und USPTO prüfen (selbst oder per Anwalt), (b) Namen wählen, der keine offensichtlichen Konflikte aufweist, (c) auf Markenanmeldung zunächst verzichten und nachholen, wenn die App Traktion zeigt. Kosten dieser Alternative: **300–600 €** für professionelle Recherche, 0 € für Anmeldung. Risiko: Kein eigener Schutz des Namens in der Wachstumsphase.

---

### 7. Patente

- **Risiko:** 🟢
- **Begründung:** Atemtechniken (4-7-8, Box Breathing, einfaches Beruhigen) sind seit Jahrzehnten in der öffentlichen Domäne — keine Patentierbarkeit, keine bestehenden Patente. UI-Patterns wie expandierende/kontrahierende Kreis-Animationen als Atemführung existieren in mehreren Apps (Breathwrk, Calm, Oak) und sind damit Prior Art, die eine Patentanmeldung durch Dritte nachträglich blockieren würde. Software-Patente im EU-Raum sind durch das Europäische Patentübereinkommen (EPÜ) stark eingeschränkt ("Software als solche" ist nicht patentierbar). Im US-Markt ist die Lage nach *Alice Corp. v. CLS Bank* (2014) ebenfalls restriktiv für abstrakte UI-Ideen. Kein identifizierbares Patent-Risiko für dieses Konzept.
- **Geschätzte Kosten:** 0 €.
- **Alternative:** Nicht erforderlich.

---

### 8. Medizinrecht / Gesundheitsclaims

- **Risiko:** 🔴
- **Begründung:** Dies ist das einzige strukturelle Rechtsrisiko dieses Projekts, und es wird im Concept Brief unterschätzt. Das Problem liegt nicht im Produkt selbst, sondern in den **Werbeaussagen und UI-Texten**, die zwangsläufig entstehen werden. Konkrete Risiko-Trigger aus dem Concept Brief:
  - "Einfaches Beruhigen" als Technikbezeichnung ist eine implizite Wirkungsaussage
  - "berufstätigen Erwachsenen in Stresssituationen" suggeriert therapeutische Wirksamkeit
  - "bewährte Atemtechniken" impliziert medizinische Evidenz
  - App-Store-Beschreibung und Marketing werden Formulierungen wie "reduziert Stress", "beruhigt das Nervensystem", "hilft beim Einschlafen" enthalten — alles regulierte Gesundheitsaussagen

  **Rechtlicher Rahmen DACH:** Die EU-Health-Claims-Verordnung (EG) Nr. 1924/2006 gilt primär für Lebensmittel, aber die zugrunde liegenden Prinzipien — belegte Wirksamkeit für gesundheitliche Aussagen — werden regulatorisch auch auf digitale Gesundheitsprodukte angewandt. Wichtiger: Das **Heilmittelwerbegesetz (HWG)** in Deutschland verbietet explizit irreführende Werbung für Heilbehandlungen und Therapien. Eine App, die "Stress reduziert" oder "beruhigt" ohne wissenschaftlichen Wirksamkeitsnachweis, bewegt sich in diesem Graubereich. Das **DiGA-Framework** (Digitale Gesundheitsanwendungen, §33a SGB V) ist für diese App nicht verpflichtend — es wäre nur relevant, wenn die App als Medizinprodukt positioniert oder erstattet werden soll, was nicht der Fall ist. Aber: Die Abgrenzung "Wellness-App" vs. "Medizinprodukt" hängt explizit von den Werbeaussagen ab. Eine App, die "nachweislich Panikattacken lindert", wäre ein Medizinprodukt — eine App, die "Atemübungen für ruhige Momente" anbietet, ist es nicht.

  **Konkretes Schadensszenario:** Abmahnung durch Wettbewerber oder Verbraucherverbände (in Deutschland aktiv und verhältnismäßig häufig im Digital-Health-Bereich) wegen unzulässiger Gesundheitswerbung. Kosten einer Abmahnung: **1.000–5.000 €** inklusive Anwaltskosten und ggf. Unterlassungserklärung.

- **Geschätzte Kosten:** Präventiv: **500–1.500 €** für anwaltliche Prüfung aller Werbeaussagen (App-Store-Beschreibung, In-App-Texte, Website/Landing Page) durch einen auf Medizin-/Wettbewerbsrecht spezialisierten Anwalt im DACH-Raum. Dies ist keine optionale Ausgabe — es ist die günstigste Versicherung gegen das teuerste Risiko dieses Projekts.

- **Alternative zur Risikoreduktion:** Konsequentes Framing als **Wellness- und Entspannungs-Tool**, nicht als Gesundheits- oder Therapie-Tool. Konkrete Sprachregeln:

  | ❌ Vermeiden | ✅ Verwenden |
  |---|---|
  | "Reduziert Stress" | "Momente der Ruhe" |
  | "Beruhigt das Nervensystem" | "Geführte Atemübungen" |
  | "Hilft bei Angst" | "Für bewusste Atempausen" |
  | "Bewährte Therapietechnik" | "Bekannte Atemtechniken" |
  | "Verbessert den Schlaf" | "Für ruhigere Abende" |

  Diese Sprachregelung kostet nichts, eliminiert aber das Abmahnungsrisiko strukturell. Kombiniert mit einem einmaligen Anwalts-Review ist das 🔴-Risiko auf 🟢 reduzierbar.

---

## Regionale Einschränkungen

| Land / Region | Status | Begründung |
|---|---|---|
| **Deutschland / Österreich / Schweiz (DACH)** | 