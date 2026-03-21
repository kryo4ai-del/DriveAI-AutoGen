# Risk-Assessment-Report: SkillSense

**Erstellt:** Juni 2025
**Bewertet durch:** Risk-Assessment-Specialist, DriveAI Swarm Factory
**Basis:** Concept Brief SkillSense + Legal-Research-Report SkillSense
**Disclaimer:** KI-basierte Ersteinschätzung — ersetzt keine rechtsverbindliche Beratung.

---

## Risiko-Übersicht (Ampel-Tabelle)

| Rechtsfeld | Risiko | Geschätzte Kosten | Zeitaufwand |
|---|---|---|---|
| 1. Monetarisierung & Glücksspielrecht | 🟢 Kein Risiko | — | — |
| 2. App Store Richtlinien | 🟢 Kein Risiko (MVP) | — | — |
| 3. AI-Content — Urheberrecht (Skill-DB) | 🟡 Mittleres Risiko | 800–1.500 € einmalig | 2–3 Wochen |
| 4a. DSGVO — Standard-Features | 🟡 Mittleres Risiko | 2.000–4.000 € einmalig | 3–4 Wochen |
| 4b. DSGVO — Chat-Export-Feature | 🔴 Hohes Risiko | 3.500–7.000 € einmalig | 4–6 Wochen |
| 4c. Drittlandtransfer (US-Anbieter) | 🟡 Mittleres Risiko | 500–1.000 € einmalig | 1–2 Wochen |
| 5. Jugendschutz | 🟢 Kein Risiko | — | — |
| 6. Social Features | 🟢 Nicht relevant | — | — |
| 7. Markenrecht — Namenskonflikt | 🟡 Mittleres Risiko | 1.500–3.000 € einmalig | 2–4 Wochen |
| 8. Patente | 🟡 Latentes Risiko | 2.000–4.000 € einmalig | 3–4 Wochen |
| 9. Plattform-AGB (Anthropic / OpenAI) | 🔴 Hohes Risiko | 0–500 € (Monitoring) | Laufend |
| 10. Vertragsrecht / SaaS-Abo-Recht EU | 🟡 Mittleres Risiko | 1.000–2.000 € einmalig | 2–3 Wochen |

---

## Detailbewertung pro Feld

### 1. Monetarisierung & Glücksspielrecht

- **Risiko:** 🟢 Kein Risiko
- **Begründung:** SkillSense enthält keinerlei Zufallsmechanismen, Loot Boxes oder Wett-Elemente. Das Credits-Modell für LLM-Calls ist ein deterministisches Verbrauchsmodell — rechtlich identisch mit API-Kontingenten bei AWS oder Stripe. Der laufende EU Digital Fairness Act betrifft ausschließlich gamifizierte Zufallsmechaniken. Null Berührungspunkte mit dem Produkt.
- **Geschätzte Kosten:** —
- **Zeitaufwand:** —

---

### 2. App Store Richtlinien

- **Risiko:** 🟢 Kein Risiko (MVP-Phase)
- **Begründung:** SkillSense ist eine Web-App, die über den Browser zugänglich ist. Apple- und Google-Provisionen (15–30%) sowie die zugehörigen IAP-Richtlinien greifen ausschließlich bei nativen iOS/Android-Apps. Stripe-Zahlungen direkt via Web sind ohne Provision und ohne Compliance-Aufwand gegenüber App Stores durchführbar. Strategischer Vorteil gegenüber App-nativen Wettbewerbern.
- **Geschätzte Kosten:** —
- **Zeitaufwand:** —
- **Hinweis für Phase 2/3:** Falls eine native Begleit-App entwickelt wird, ändert sich die Bewertung auf 🟡 (IAP-Pflicht, Apple DMA-Entitlement für DACH prüfen). Dieser Schritt sollte erst dann separat bewertet werden.

---

### 3. AI-Content — Urheberrecht (Skill-Datenbank)

- **Risiko:** 🟡 Mittleres Risiko
- **Begründung:** Zwei Bereiche sind zu trennen. Erstens: KI-generierte Skill-Outputs via Claude API sind nach aktuellem EU- und US-Recht nicht urheberrechtlich schutzfähig — das ist für das Produkt unproblematisch, da SkillSense keine Exklusivität auf Outputs beansprucht. Zweitens und kritischer: Die kuratierte Skill-Datenbank kann menschlich geschaffene Drittanbieter-Skills enthalten, die urheberrechtlich geschützt sind. GitHub Awesome-Listen laufen unter MIT- oder CC-Lizenzen, die nicht automatisch kommerzielle Aggregation erlauben. Ohne saubere Lizenzierungslösung besteht das Risiko von Unterlassungsansprüchen einzelner Skill-Autoren — kein existenzielles Risiko, aber operativ störend und reputationsschädigend.
- **Geschätzte Kosten:** 800–1.500 € einmalig (Anwalt für Lizenz-Template und ToS-Klausel für Community-Einreichungen; DACH-Markt, Fachanwalt IT-Recht, Stundenrate 200–350 €)
- **Zeitaufwand:** 2–3 Wochen
- **Maßnahmen:**
  - ToS für Skill-Einreichungen ab Tag 1 mit expliziter Lizenzierungsklausel (Einräumung nicht-exklusiver Nutzungsrechte an SkillSense)
  - Herkunft aller Drittanbieter-Skills in der MVP-DB dokumentieren und Lizenz prüfen
  - Creative-Commons-Attribution-Pflichten einhalten, wo zutreffend
  - KI-generierte Skills im Frontend als solche kennzeichnen (Art. 50 EU AI Act — Transparenzpflicht)

---

### 4a. DSGVO — Standard-Features (Scanner, Fragebogen, Pro-Account)

- **Risiko:** 🟡 Mittleres Risiko
- **Begründung:** Die Client-side-Architektur für Scanner und Fragebogen ist DSGVO-strukturell vorbildlich — keine Personaldaten verlassen den Browser, keine Server-Verarbeitung, kein Consent-Problem für den Analyse-Kern. Das reduziert das DSGVO-Risiko erheblich gegenüber einem Server-side-Ansatz. Das verbleibende Risiko entsteht durch den Pro-Account: E-Mail, Zahlungsdaten via Stripe, Auth-Provider — das ist Standard-SaaS, aber erfordert saubere Umsetzung. Plausible Analytics ist cookielos und DSGVO-freundlich, was den Cookie-Consent-Aufwand minimiert. Das Hauptrisiko bei 🟡 ist nicht die Architektur, sondern die **Umsetzungsqualität der Pflichtdokumente** (Datenschutzerklärung, AVV, Betroffenenrechte). Fehlende oder mangelhafte Dokumente sind in DACH die häufigste Ursache für Abmahnungen durch Mitbewerber (Abmahnwelle §13 TMG / DSGVO ist real und aktiv).
- **Geschätzte Kosten:** 2.000–4.000 € einmalig (Anwalt für Datenschutzerklärung, AGB, AVV-Muster mit Stripe/Vercel/Anthropic/Clerk; DACH-Fachanwalt Datenschutzrecht, 6–12 Stunden)
- **Zeitaufwand:** 3–4 Wochen
- **Maßnahmen:**
  - Datenschutzerklärung gemäß Art. 13/14 DSGVO ab Tag 1 — kein Launch ohne dieses Dokument
  - AVV mit allen US-Drittanbietern (Stripe, Vercel, Anthropic API, Auth-Provider) abschließen — diese bieten standardisierte AVV an, müssen aber aktiv unterzeichnet werden
  - Betroffenenrechte (Auskunft, Löschung, Berichtigung) technisch im Pro-Account implementieren
  - Impressumspflicht gemäß §5 TMG (Deutschland) — Pflicht auch für Web-Apps

---

### 4b. DSGVO — Chat-Export-Feature (Pro)

- **Risiko:** 🔴 Hohes Risiko
- **Begründung:** Dies ist das datenschutzrechtlich kritischste Feature des gesamten Produkts. Chat-Historien enthalten mit hoher Wahrscheinlichkeit personenbezogene Daten des Nutzers **und** Dritter (Kunden, Kollegen, Gesprächspartner) — darunter potenziell besondere Kategorien nach Art. 9 DSGVO (Gesundheit, politische Meinung, etc.). Auch bei 100% client-seitiger Verarbeitung bestehen konkrete Risiken: technische Leaks über LocalStorage-Persistenz, Service Worker, Browser-Extensions, oder unbeabsichtigte Übertragung über Analytics-Snippets. Die DSGVO verlangt bei systematischer Analyse personenbezogener Inhalte (selbst lokal) eine **Datenschutz-Folgenabschätzung (DPIA, Art. 35 DSGVO)**. Fehlt diese, drohen bei einer Datenschutzbehörden-Prüfung Bußgelder bis 10 Mio. € oder 2% des weltweiten Jahresumsatzes (das niedrigere Maximum). Für ein Startup ist nicht das Bußgeld das primäre Risiko — es ist der **Reputationsschaden**, wenn ein Tool, das mit Datenschutz wirbt, in eine DSGVO-Beschwerde gerät. Das wäre in DACH viral — in die falsche Richtung.
- **Geschätzte Kosten:** 3.500–7.000 € einmalig (DPIA durch Datenschutzjurist oder zertifizierten Datenschutzbeauftragten: 10–20 Stunden à 250–350 €; technisches Security-Audit der Client-side-Implementierung: 5–10 Stunden Entwicklerzeit + optional externer Pentest 1.500–2.500 €)
- **Zeitaufwand:** 4–6 Wochen
- **Alternative (Risikoreduktion):**
  - **Option A — Feature-Delay:** Chat-Export-Feature aus dem MVP herausnehmen. Launch mit Scanner + Fragebogen. Chat-Export erst nach DPIA und technischem Audit in Phase 2 einführen. Kostet 0 zusätzliche Compliance-Euro zum Launch, gibt Zeit für saubere Implementierung. **Empfohlene Option.**
  - **Option B — Feature-Einschränkung:** Chat-Export auf rein lokale Verarbeitung beschränken UND explizite Nutzer-Einwilligung mit Klartext-Hinweis vor Upload einholen ("Diese Datei verlässt deinen Browser nicht. Trotzdem: Lade keine fremden Personendaten hoch."). DPIA dennoch erforderlich, aber Risikoprofil sinkt.
  - **Option C — Feature-Entfernung:** Chat-Export dauerhaft streichen. Verliert das stärkste Pro-Differenzierungsfeature, eliminiert aber das höchste Risiko vollständig.

---

### 4c. Drittlandtransfer (US-Anbieter)

- **Risiko:** 🟡 Mittleres Risiko
- **Begründung:** Stripe, Vercel, Anthropic API und Auth-Provider (Clerk) sind US-amerikanische Anbieter. Nach Schrems II sind Drittlandtransfers ohne geeignete Garantien unzulässig. Das EU-U.S. Data Privacy Framework (DPF, in Kraft Juli 2023) bietet aktuell die rechtliche Grundlage — **aber das DPF ist politisch fragil.** Ein Schrems-III-Szenario (gerichtliche Kassation des DPF durch den EuGH) ist nicht unwahrscheinlich angesichts der aktuellen geopolitischen Spannungen zwischen EU und USA (2025). Alle genannten Anbieter sind DPF-zertifiziert und bieten EU-Standardvertragsklauseln (SCCs) an — das ist die Mindestabsicherung. Das Risiko ist nicht akut, aber latent und muss monitort werden.
- **Geschätzte Kosten:** 500–1.000 € einmalig (Anwalt prüft AVV und SCC-Abschlüsse mit allen Drittanbietern; 2–3 Stunden)
- **Zeitaufwand:** 1–2 Wochen
- **Maßnahmen:**
  - DPF-Zertifizierungsstatus aller Anbieter bei Launch verifizieren (dataprivacyframework.gov)
  - SCCs als zusätzliche Absicherung in AVV aufnehmen, wo Anbieter diese anbieten
  - Monitoring-Routine etablieren: Bei DPF-Kassation sofortiger Handlungsbedarf (Alternativanbieter evaluieren oder EU-Hosting prüfen — Vercel hat EU-Region, Supabase EU-Hosting, Stripe hat EU-Entitäten)

---

### 5. Jugendschutz

- **Risiko:** 🟢 Kein Risiko
- **Begründung:** SkillSense richtet sich an erwachsene Wissensarbeiter (Kern: 28–38 Jahre). Das Produkt enthält keine Inhalte, die USK/PEGI-relevant wären, und keinen User-Generated-Content in Echtzeit. Altersverifikation ist nicht erforderlich. Der Fragebogen enthält keine alterssensitiven Fragen. Einzige Empfehlung: In den ToS eine Mindestaltersangabe (16 Jahre, entspricht DSGVO-Einwilligungsfähigkeit in Deutschland) aufnehmen — das ist eine Standardklausel ohne operativen Aufwand.
- **Geschätzte Kosten:** — (im Rahmen der ohnehin zu erstellenden ToS abgedeckt)

---

### 6. Social Features

- **Risiko:** 🟢 Nicht relevant
- **Begründung:** SkillSense hat zum Launch keine Social Features, kein Forum, keinen Chat zwischen Nutzern, kein User-Profile-System mit öffentlicher Sichtbarkeit. Damit entfallen Auflagen aus NetzDG (Deutschland), DSA (EU Digital Services Act — für Plattformen mit UGC), und verwandten Regularien. Falls in Phase 2/3 Community-Features eingeführt werden (z.B. Skill-Bewertungen, Community-Einreichungen), ist eine separate DSA-Compliance-Prüfung erforderlich.

---

### 7. Markenrecht — Namenskonflikt

- **Risiko:** 🟡 Mittleres Risiko
- **Begründung:** Der Name "SkillSense" ist generisch genug, um auf den ersten Blick unauffällig zu wirken. Genau das ist das Problem: Generische beschreibende Markennamen sind schwerer zu schützen und schwieriger einzutragen — gleichzeitig könnten ähnliche Namen im DACH- oder EU-Raum bereits eingetragen sein, ohne dass eine schnelle Google-Suche das aufdeckt. Eine professionelle Markenrecherche im EUIPO-Register (EU-Marke) und DPMA-Register (Deutschland) ist vor Launch obligatorisch. Zusätzlich ist "SkillSense" als Domain und Social-Media-Handle zu prüfen — Domaininhaber können Unterlassungsansprüche geltend machen, wenn eine Verwechslungsgefahr besteht. Ohne Markenanmeldung kann SkillSense seinen Namen nicht aktiv schützen, falls ein Konkurrent ihn später anmeldet.
- **Geschätzte Kosten:**
  - Markenrecherche EUIPO + DPMA: 500–1.000 € (Anwalt, 2–3 Stunden) oder selbst über euipo.europa.eu (kostenlos, aber ohne juristische Absicherung)
  - Markenanmeldung EU (EUIPO): 850 € Amtsgebühr für 1 Klasse + ca. 500–1.000 € Anwaltskosten = **1.350–1.850 € einmalig**
  - Gesamt: **1.500–3.000 € einmalig** (Recherche + Anmeldung kombiniert)
- **Zeitaufwand:** 2–4 Wochen (Recherche 1 Woche, Anmeldung ist dann ein laufender Prozess — Eintragung dauert 5–7 Monate, Schutz beginnt ab Anmeldetag)
- **Alternative (falls Namenskonflikt besteht):**
  - Namensanpassung vor Launch ist die kostengünstigste Option. Ein Rebranding nach Launch (mit aufgebautem Traffic, Nutzerbase, Backlinks) kostet ein Vielfaches.
  - Empfehlung: Markenrecherche in Woche 1 durchführen — vor jeglicher öffentlichen Kommunikation des Namens.

---

### 8. Patente

- **Risiko:** 🟡 Latentes Risiko
- **Begründung:** Im Bereich KI-Analyse-Tools und personalisierter Empfehlungssysteme existieren zahlreiche Softwarepatente, primär aus dem US-Raum. In der EU sind Softwarepatente grundsätzlich nicht patentierbar (Art. 52 EPÜ) — jedoch können technisch formulierte Patente ("als technische Erfindung verkleidet") auch in Europa Schutz genießen. Das konkrete Risiko für SkillSense: Ein US-amerikanisches Unternehmen mit Patent auf "personalisierte KI-Tool-Empfehlung basierend auf Nutzungsanalyse" könnte theoretisch Ansprüche geltend machen, sobald SkillSense in den US-Markt expandiert. Für den **DACH-Launch ist das Risiko gering** — für Phase 2/3 mit US-Expansion steigt es. Zusätzlich: Die eigene Analyse-Engine (Client-side Security Scanner, Qualitätsbew