# Risk-Assessment-Report: Minimalistische Atem-Übungs-App

---

## Risiko-Übersicht (Ampel-Tabelle)

| Rechtsfeld | Risiko | Geschätzte Kosten | Zeitaufwand |
|---|---|---|---|
| Monetarisierung & Glücksspielrecht | 🟢 Niedrig | — | — |
| App Store Richtlinien (Apple / Google) | 🟡 Mittel | 0–300 € | 1–2 Wochen |
| AI-generierter Content — Urheberrecht | 🟡 Mittel | 0–500 € | 1 Woche |
| Datenschutz (DSGVO / COPPA) | 🟡 Mittel | 500–1.500 € | 1–2 Wochen |
| Jugendschutz (USK / PEGI / IARC) | 🟢 Niedrig | 0 € | 1–3 Tage |
| Social Features | ⬛ Nicht relevant | — | — |
| Markenrecht — Namenskonflikt | 🟡 Mittel | 300–1.500 € | 2–4 Wochen |
| Patente | 🟢 Niedrig | 0–500 € | 3–5 Tage |
| Medizinrecht / Gesundheitsrecht | 🟡 Mittel ⚠️ | 500–2.000 € | 2–4 Wochen |

---

## Detailbewertung pro Feld

### 1. Monetarisierung & Glücksspielrecht

- **Risiko:** 🟢 Niedrig
- **Begründung:** Das Tip-IAP-Modell enthält keinerlei randomisierte Mechaniken, Loot Boxes oder Belohnungsschleifen mit variabler Auszahlung. Selbst unter den schärfsten aktuell geltenden Regelungen (Belgien, Niederlande) ist dieses Modell eindeutig nicht betroffen. Die ausstehende EU-Parlamentsforderung zu Loot Boxes richtet sich strukturell gegen andere Mechaniken. Solange keine Gamification-Erweiterungen mit monetären Anreizen eingeführt werden, besteht kein Handlungsbedarf.
- **Geschätzte Kosten:** Keine. Kein rechtlicher Handlungsbedarf vor Launch.
- **Alternative:** Nicht erforderlich. Bei künftiger Feature-Erweiterung Richtung Gamification neu bewerten.

---

### 2. App Store Richtlinien (Apple / Google)

- **Risiko:** 🟡 Mittel
- **Begründung:** Das Risiko ist nicht inhaltlicher, sondern prozessualer Natur. Konkret drei Punkte, die bei Fehlern zur App-Ablehnung führen:

  **Punkt 1 — Tip-Jar-Deklaration:** Apple hat in der Vergangenheit Tip-IAPs zurückgewiesen, die als verschleierte Funktionsfreischaltung interpretiert wurden. Die Formulierung innerhalb der App muss unmissverständlich als freiwillige Entwickler-Unterstützung deklariert sein, nicht als "Premium-Version" oder "Upgrade". Dieser Punkt ist lösbar, erfordert aber Sorgfalt bei der Store-Kommunikation.

  **Punkt 2 — Privacy Nutrition Label (Apple):** Auch bei vollständiger Datenvermeidung muss das Label ausgefüllt werden. Jede eingebundene Flutter-Dependency muss vorab auf potenzielle Datenweitergabe geprüft werden. Eine fehlerhafte Deklaration hier ist gleichzeitig ein rechtliches und ein Reputationsrisiko — gerade für diese Privacy-positionierte App.

  **Punkt 3 — IARC-Fragebogen (Google Play):** Obligatorisch, aber bei diesem Produkt voraussichtlich unkompliziert (Einstufung "Everyone/3+").

  **DMA-Hinweis (EU):** Die Auswirkungen des Digital Markets Act auf alternative Zahlungsmethoden sind für einen kleinen Entwickler mit einem einfachen Tip-IAP voraussichtlich nicht operational relevant, sollten aber beobachtet werden.

- **Geschätzte Kosten:** 0–300 € für Dependency-Audit (eigener Aufwand oder kurze externe Beratung). Kein struktureller Kostenfaktor, wenn intern kompetent abgedeckt.
- **Alternative:** Bei Unsicherheit über Tip-Jar-Klassifikation: Vorherige Abstimmung mit Apple via App Store Review (Feedback-Funktion) oder Ausweichen auf Option A (Paid App, 2,99 €), die diese Klassifikationsfrage eliminiert.

---

### 3. AI-generierter Content — Urheberrecht

- **Risiko:** 🟡 Mittel
- **Begründung:** Das Risiko ist nicht akut, aber dokumentationspflichtig. Die Kreis-Animations-UI und Atemanleitungstexte haben bei eigenem oder KI-assistiertem Ursprung kein relevantes Risiko — faktische Inhalte (Atemtechniken) sind urheberrechtlich ohnehin nicht schutzfähig, geometrische Animationen ebenfalls nicht.

  Das Risiko konzentriert sich auf zwei Punkte:

  **Punkt 1 — App-Icon und Grafiken:** Werden diese mit KI-Tools erstellt (Midjourney, DALL·E, Stable Diffusion), gelten die jeweiligen kommerziellen Nutzungsbedingungen des Anbieters. Midjourney erlaubt kommerzielle Nutzung ab Pro-Plan; Stable Diffusion (open source) ist bei eigenem Betrieb unkomplizierter. Ohne dokumentierte Lizenz besteht ein latentes Risiko.

  **Punkt 2 — Hintergrundgeräusche / Sounds:** Falls Ambient-Sounds eingebunden werden (nicht im Concept Brief erwähnt, aber naheliegend): KI-generierte Musik aus Tools wie Suno erfordert explizite kommerzielle Lizenz. Alternativ: Human-komponierte lizenzfreie Sounds (z.B. Freesound.org, CC0-Lizenz) sind rechtssicherer und kostengünstiger.

  Der U.S. Copyright Office-Report (Januar 2025) bestätigt: KI-Outputs sind nicht schutzfähig, schützen den Entwickler also auch nicht gegenüber Dritten. Bei eigenem Original-UI ist dieser Punkt irrelevant.

- **Geschätzte Kosten:** 0 € bei vollständig eigenem oder lizenzdokumentiertem Material. Bis zu 500 € für kommerzielle KI-Tool-Lizenzen (Midjourney Pro ~96 €/Jahr, Suno Pro ~96 €/Jahr) falls genutzt. Alternativ: 0 € durch konsequente CC0- und Open-Source-Asset-Nutzung.
- **Alternative:** Vollständig auf eigene SVG-Animationen (Flutter-nativ), CC0-Sounds und manuell erstellte Texte setzen. Eliminiert das Risiko vollständig und ist für diese Minimal-App technisch problemlos umsetzbar.

---

### 4. Datenschutz (DSGVO / COPPA)

- **Risiko:** 🟡 Mittel
- **Begründung:** Technisch ist das Datenschutzrisiko bei konsequenter Umsetzung des No-Backend-Prinzips sehr gering. Die DSGVO greift bei reinem On-Device-Storage ohne Personenbezug nicht in ihrer vollen Breite. COPPA ist bei dieser Zielgruppe (25–45 Jahre) und ohne Datenerhebung praktisch irrelevant.

  Das Risiko entsteht an drei Stellen:

  **Punkt 1 — Privacy Policy Pflicht:** Apple und Google verlangen eine Privacy Policy für alle Apps, auch wenn keine Daten gesammelt werden. Diese muss ehrlich, vollständig und rechtskonform sein. Eine fehlerhafte oder fehlende Policy führt zur App-Ablehnung im Store. Kosten: 300–800 € für anwaltliche Erstellung oder Template-Anpassung.

  **Punkt 2 — Dependency-Risiko:** Flutter-Plugins (z.B. für lokalen Storage, Animationen) können potenziell Gerätedaten übertragen, wenn sie nicht explizit geprüft werden. Ein unbemerkt eingebundenes SDK würde das stärkste USP des Produkts (Privacy-First) technisch brechen und gleichzeitig eine DSGVO-Verletzung darstellen. Empfehlung: Dependency-Audit vor Launch, alle Plugins auf Datenweitergabe prüfen.

  **Punkt 3 — Reputationsrisiko bei Versagen:** Die Privacy-Positionierung ist der differenzierteste USP dieses Produkts. Die Zielgruppe (Reddit r/Meditation, r/Anxiety, Hacker News) wird technisch in der Lage sein, Datenweitergabe zu entdecken und öffentlich zu machen. Ein Fehler hier ist nicht nur rechtlich, sondern existenziell für das Produkt.

  **Bewertung COPPA:** Da keine Daten gesammelt werden und die Zielgruppe explizit Erwachsene sind, besteht kein COPPA-Risiko. In Privacy Policy und Store-Beschreibung deklarieren: "Nicht für Kinder unter 13 Jahren."

- **Geschätzte Kosten:** 500–1.500 € (Anwaltliche Erstellung einer DSGVO-konformen Privacy Policy für DACH/UK/USA: 500–800 €; Dependency-Audit eigener Aufwand oder externe Prüfung: 0–700 €).
- **Alternative:** Bei eigenem juristischem Grundwissen: DSGVO-konforme Privacy Policy via bewährten Templates (z.B. iubenda, ~60–120 €/Jahr) erstellen, Dependency-Audit selbst durchführen anhand Flutter-Plugin-Dokumentation. Spart Anwaltskosten, erhöht aber eigenes Risiko bei Lücken.

---

### 5. Jugendschutz (USK / PEGI / IARC)

- **Risiko:** 🟢 Niedrig
- **Begründung:** Eine Atemübungs-App ohne Gewalt, Suchtmechaniken, In-App-Chat oder Erwachseneninhalte erhält im IARC-System voraussichtlich die niedrigste Alterseinstufung (3+/Everyone). Der IARC-Fragebogen (Google Play) ist obligatorisch, aber für dieses Produkt in 15–30 Minuten korrekt ausfüllbar. Apple nutzt ein eigenes Rating-System, das vergleichbar unkompliziert ist.

  USK und PEGI sind für reine Mobile Apps ohne physischen Retail-Vertrieb in Deutschland/Österreich nicht verpflichtend — IARC übernimmt diese Funktion für den Google Play Store.

- **Geschätzte Kosten:** 0 €. Kein externer Aufwand erforderlich.
- **Alternative:** Nicht erforderlich.

---

### 6. Social Features

- **Risiko:** ⬛ Nicht relevant
- **Begründung:** Keine Social Features geplant. Bei künftiger Entwicklung (z.B. Gruppen-Sessions für Therapeuten-Use-Case) separaten Compliance-Check auslösen.

---

### 7. Markenrecht — Namenskonflikt

- **Risiko:** 🟡 Mittel
- **Begründung:** Der App-Name ist noch nicht festgelegt, was diesen Punkt offen hält. Das Risiko ist real: Im Wellness/Mindfulness-Segment sind generische Begriffe wie "Breathe", "Calm", "Balance" bereits als Marken eingetragen. Apple hat selbst "Breathe" als App-Name belegt (Apple Watch Breathe-Feature). Namenswahl ohne Markenpräfung kann zu:

  - App Store-Ablehnung führen (Apple/Google lehnen Apps mit Namen ab, die bestehende Marken verletzen)
  - Abmahnungen nach Launch auslösen (DACH: Kosten oft 1.500–5.000 €)
  - Rebranding erzwingen (Zeitverlust, Reputationsschaden)

  Das Risiko ist beherrschbar, aber nicht trivial bei einem noch unbenannten Produkt.

- **Geschätzte Kosten:** 300–500 € für professionelle Markenrecherche (EUIPO, DPMA, USPTO) durch Anwalt oder IP-Recherche-Dienstleister. Alternativ: Eigene Recherche via EUIPO/DPMA-Datenbanken (kostenlos, aber zeitaufwendig und fehleranfälliger). Bei Markeneintragung des eigenen Namens: 850–1.200 € (EUIPO-Anmeldung EU, eine Klasse, Klasse 9/42).
- **Alternative:** Spezifischen, nicht-generischen App-Namen wählen (z.B. Kombination aus nicht-übersetzten Begriffen, erfundenes Wort), der das Kollisionsrisiko strukturell reduziert. Markeneintragung für den eigenen Namen empfohlen, wenn das Produkt langfristig als Brand aufgebaut werden soll.

---

### 8. Patente

- **Risiko:** 🟢 Niedrig
- **Begründung:** Atemtechniken (4-7-8, Box Breathing) sind etablierte, dokumentierte Methoden ohne patentierbaren Ursprung. Sie sind gemeinfrei. Die Animations-Implementierung (animierter Kreis) ist technisch zu generisch für eine patentierbare Erfindung, und entsprechende UI-Patente wären für einen Kleinentwickler in der Praxis kaum durchsetzbar.

  Ein minimales Restrisiko besteht für sehr spezifische UI-Interaktionsmuster, falls ein Wettbewerber (Breathwrk, Calm) Design-Patente auf bestimmte Animations-Implementierungen hält — dies ist im Wellness-App-Segment jedoch praktisch nicht dokumentiert.

- **Geschätzte Kosten:** 0–500 € für eine oberflächliche Patentrecherche (Google Patents, eigene Prüfung) als Vorsichtsmaßnahme. Nicht zwingend erforderlich.
- **Alternative:** Nicht erforderlich bei Standard-Implementierung ohne technische Alleinstellungsmerkmale in der UI-Mechanik.

---

### 9. Medizinrecht / Gesundheitsrecht

- **Risiko:** 🟡 Mittel ⚠️
- **Begründung:** Dies ist das am meisten unterschätzte Rechtsfeld für dieses Konzept und verdient besondere Aufmerksamkeit.

  Das Concept Brief nennt explizit **Therapeuten, die die App als Hausaufgabe empfehlen** als sekundäres Zielgruppensegment. Genau diese Formulierung — und die Sprache, die in der App-Beschreibung und im Marketing verwendet wird — entscheidet darüber, ob die App rechtlich als **Wellness-Produkt** oder als **Medizinprodukt** eingestuft wird.

  **EU Medical Device Regulation (MDR, EU 2017/745):** Seit Mai 2021 vollständig anwendbar. Software kann als Medizinprodukt (Software as a Medical Device / SaMD) klassifiziert werden, wenn sie zur **Diagnose, Behandlung oder Linderung von Krankheiten** eingesetzt wird. Apps, die explizit therapeutische Wirkungen beanspruchen (z.B. "hilft bei Angststörungen", "therapeutisch angewendet") können unter die MDR fallen — mit erheblichen Zertifizierungsanforderungen (CE-Kennzeichnung, klinische Bewertung, QMS nach ISO 13485).

  **Die entscheidende Grenzlinie liegt im Marketing und in den App-Store-Texten:**

  | Formulierung | Rechtliche Einordnung |
  |---|---|
  | "Entspannungsübungen für den Alltag" | ✅ Wellness — kein Medizinprodukt |
  | "Stressreduktion" (allgemein) | ✅ Wellness — kein Medizinprodukt |
  | "Hilft bei Angstzuständen" | ⚠️ Grauzone — potenziell MDR-relevant |
  | "Therapeutisch empfohlen bei Panikattacken" | 🔴 Medizinprodukt — MDR-pflichtig |
  | "Klinisch bewährte Atemtechnik" (ohne Beleg) | 🔴 Irreführende Gesundheitsaussage — zusätzlich wettbewerbsrechtlich angreifbar |

  Das Sekundärzielgruppen-Segment "Therapeuten empfehlen die App als Hausaufgabe" in der Außenkommunikation zu verwenden, ohne dass die App MDR-konform zertifiziert ist, wäre ein kalkulierbares aber vermeidbares Risiko. **Es reicht, dieses Segment in der internen Strategie zu halten und im externen Marketing ausschließlich Wellness-Sprache zu verwenden.**

  **Zusätzlich relevant (DACH):** Das deutsche Heilmittelwerbegesetz (HWG) verbietet irreführende Werbung für Produkte mit gesundheitsbezogenen Wirkversprechen. Auch ohne MDR-Relevanz können Health Claims zu wettbewerbsrechtlichen Abmahnungen führen.

- **Geschätzte Kosten:** 500–2.000 € für anwaltliche Prüfung der App-Store-Texte und Marketing-Materialien auf MDR-Relevanz und HWG-Konformität. Wenn MDR-Einstufung als Medizinprodukt droht: Kosten explodieren (CE-Zertifizierung: 20.000–100.000 €) — aber dies ist durch Sprach-Compliance vollständig vermeidbar.
- **Alternative:** Konsequente Wellness-Sprache in allen öffentlichen Kommunikationsmitteln. Therapeuten-Segment nur intern als strategische Zielgruppe führen, niemals als öffentliches Wirkversprechen. Eine kurze anwaltliche Textprüfung der App-Store-Beschreibung (300–500 €) eliminiert dieses Risiko praktisch vollständig.

---

## Regionale Einschränkungen

| Region | Status | Begründung |
|---|---|---|
| **DACH (Deutschland, Österreich, Schweiz)** | ✅ Launchbar | Keine spezifischen Einschränkungen. DSGVO-Compliance und HWG-konforme Sprache erforderlich. |
| **UK** | ✅