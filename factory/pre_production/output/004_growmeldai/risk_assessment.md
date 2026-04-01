# Risk-Assessment-Report: GrowMeldAI

---

## Risiko-Übersicht (Ampel-Tabelle)

| # | Rechtsfeld | Risiko | Geschätzte Kosten (einmalig) | Geschätzte Kosten (laufend/Jahr) | Zeitaufwand |
|---|---|---|---|---|---|
| 1 | Monetarisierung & Glücksspielrecht | 🟢 | — | — | — |
| 2 | App Store Richtlinien | 🟡 | €2.000–€5.000 | €1.000–€2.000 | 2–3 Wochen |
| 3 | AI-generierter Content / Urheberrecht | 🟡 | €3.000–€6.000 | €1.500–€3.000 | 3–4 Wochen |
| 4 | Datenschutz (DSGVO / COPPA) | 🔴 | €8.000–€18.000 | €3.000–€6.000 | 6–10 Wochen |
| 5 | Jugendschutz (USK / PEGI) | 🟢 | — | — | — |
| 6 | Social Features | 🟢 | — | — | — |
| 7 | Markenrecht / Namenskonflikt | 🟡 | €2.500–€5.000 | €500–€1.000 | 2–3 Wochen |
| 8 | Patente | 🟡 | €3.000–€6.000 | €500–€1.000 | 3–4 Wochen |
| 9 | Medizin-/Verbraucherschutzrecht | 🟡 | €2.000–€4.000 | €500–€1.000 | 2–3 Wochen |
| 10 | API-/Drittanbieter-Nutzungsrechte | 🟡 | €2.000–€4.000 | €2.000–€8.000 | 2–3 Wochen |

> **Legende:** 🟢 Kein relevantes Risiko, kein Handlungsbedarf | 🟡 Moderates Risiko, managebar mit konkreten Maßnahmen | 🔴 Hohes Risiko, zwingender Handlungsbedarf vor Launch

---

## Detailbewertung pro Feld

---

### 1. Monetarisierung & Glücksspielrecht

**Risiko: 🟢**

**Begründung:** Das gewählte Modell (Freemium + transparentes Jahresabo + klar definierte Einmalkäufe) enthält keine einzige glücksspielrechtlich relevante Mechanik. Keine Zufallselemente, keine virtuelle Währung, kein Pay-to-Win. Das ist regulatorisch das sauberste verfügbare Modell im App-Markt. Auch die diskutierten EU-Loot-Box-Regulierungen treffen dieses Konzept strukturell nicht.

**Einziger Vorsorgehinweis:** Wenn in späteren Phasen Gamification eingeführt wird (Streak-Belohnungen, Badge-Systeme mit zufälligen Elementen), ist eine Neuprüfung erforderlich. Zum jetzigen Konzeptstand: kein Handlungsbedarf.

**Geschätzte Kosten:** —
**Zeitaufwand:** —

---

### 2. App Store Richtlinien

**Risiko: 🟡**

**Begründung:** Das Risiko ist real, aber vollständig managebar. Die drei konkreten Risikopunkte sind:

- **Revenue-Share-Kalkulation:** Apple nimmt 15–30% auf alle IAP-Transaktionen. Bei €29,99 Jahresabo verbleiben netto €21,00–€25,49. Die im Concept Brief genannten Preispunkte sind Bruttopreise — die Unit-Economics-Kalkulation muss das zwingend abbilden. Kein Launch-Blocker, aber ein häufig unterschätzter Margenvernichter in der frühen Phase.

- **Free-Trial-Compliance:** Falls ein Free Trial eingebaut wird (empfehlenswert für Conversion), muss die StoreKit-2-native Implementation erfolgen. Fehler hier führen zu Review-Ablehnung oder, schlimmer, zu ungewollten Abrechnungen, die Apple-Beschwerden und App-Store-Bewertungsschäden auslösen.

- **Freemium-Grenze:** Das "3–5 Scans/Monat"-Limit ist grenzwertig. Apple toleriert das, wenn der Free-Tier echten Standalone-Nutzen bietet. Das beschriebene Basis-Pflanzenprofil mit manuellen Erinnerungen erfüllt diese Anforderung knapp. **Empfehlung:** Im Review-Einreichungsprozess explizit dokumentieren, dass der Free-Tier für einfache Nutzer vollständig funktionsfähig ist.

**Geschätzte Kosten:**
- Einmalig: €2.000–€5.000 (StoreKit-2-Implementierung, Compliance-Review durch iOS-Entwickler mit IAP-Erfahrung, Privacy Nutrition Label Setup)
- Laufend: €1.000–€2.000/Jahr (Richtlinien-Monitoring, jährliche Compliance-Überprüfung bei Policy-Updates)

**Alternative:** Keine echte Alternative — Apple IAP ist bei iOS-primären digitalen Diensten nicht umgehbar. Die Kosten sind Pflichtaufwand, keine Option.

**Zeitaufwand:** 2–3 Wochen (parallel zur Entwicklung integrierbar, kein separater Block)

---

### 3. AI-generierter Content — Urheberrecht

**Risiko: 🟡**

**Begründung:** Das Risiko ist zweigeteilt und muss differenziert bewertet werden:

**Teil A — Output-Urheberrecht (gering):** Botanische Klassifikationen und generische Pflegeinformationen (Gießfrequenz, Lichtbedarf) sind Fakten und damit gemeinfrei. GrowMeldAIs KI-Output selbst ist in den USA nicht urheberrechtlich schutzfähig (USCO-Position 2025) — was bedeutet, dass Wettbewerber Output nicht kopieren können, aber auch GrowMeldAI ihn nicht exklusiv schützen kann. Das ist ein akzeptables Patt.

**Teil B — Trainingsdaten-Herkunft (mittleres Risiko):** Hier liegt das eigentliche Risiko. Plant.id API: Der Anbieter ist verantwortlich für seine Trainingsdaten — aber GrowMeldAI haftet operativ, wenn die API-Nutzung rechtlich angreifbar ist. **Ohne vertragliche Zusicherung von Plant.id zur Rechtmäßigkeit der Trainingsdaten ist GrowMeldAI exponiert.** Gleiches gilt für die geplante eigene Datenbankentwicklung aus Nutzer-Uploads: Nutzerfotos sind urheberrechtlich geschützt — AGB und Einwilligungsprozess müssen das explizit adressieren.

**Konkrete Risikobewertung 2025:** Die US-Gerichte ziehen Fair-Use-Grenzen, aber für eine Pflanzenpflege-App mit faktenzentriertem Output ist das Exposure begrenzt. Das Hauptrisiko ist nicht ein großes Urheberrechtsverfahren, sondern ein mittelfristiger Vertragsstreit mit Plant.id oder ein nachträgliches Anpassen der Nutzungsbedingungen der API.

**Geschätzte Kosten:**
- Einmalig: €3.000–€6.000 (Anwaltliche Prüfung Plant.id-Vertrag, AGB-Formulierung für Nutzer-Upload-Rechte, IP-Kurzgutachten)
- Laufend: €1.500–€3.000/Jahr (Monitoring Rechtsentwicklung, AGB-Updates bei Gesetzesänderungen)

**Alternative zur Risikoreduktion:** Vertragliche IP-Indemnification-Klausel mit Plant.id als Bedingung für den API-Einsatz. Kostet Verhandlungszeit, nicht Geld. Parallel: AGB-Formulierung für Nutzer-Uploads mit explizitem "nicht-exklusiver weltweiter Lizenz für ML-Training"-Text, kombiniert mit DSGVO-Einwilligung (s. Rechtsfeld 4).

**Zeitaufwand:** 3–4 Wochen (überschneidet sich mit DSGVO-Arbeit — kann gebündelt werden)

---

### 4. Datenschutz (DSGVO / COPPA)

**Risiko: 🔴**

**Begründung:** Dies ist das einzige echte Launch-Blocking-Risiko im gesamten Konzept. Die Begründung ist mehrdimensional:

**Dimension 1 — Datenkategorien mit erhöhtem DSGVO-Sensibilitätsniveau:**
GrowMeldAI erhebt in der Kombination:
- **Kameradaten** (Fotos von Pflanzen, aber potenziell auch von Innenräumen, Gesichtern im Hintergrund)
- **Standortdaten** (für Wetter-API — auch "groben Standort" gilt als personenbezogenes Datum)
- **Nutzungsprofile** (Pflanzenbestand, Routinen, Geo-basierte Klimadaten)
- **ML-Trainingsdaten** (Nutzer-Uploads)

Jede dieser Kategorien ist für sich managebar. Die **Kombination** erzeugt ein Profiling-Risiko, das DSGVO Art. 22 (automatisierte Einzelentscheidungen) und Art. 35 (Datenschutz-Folgenabschätzung, DSFA) triggert.

**Dimension 2 — DSFA-Pflicht:**
Eine Datenschutz-Folgenabschätzung ist bei systematischer Verarbeitung von Standortdaten in Kombination mit Nutzerprofilen sehr wahrscheinlich verpflichtend (DSGVO Art. 35). Eine fehlende DSFA ist kein theoretisches Risiko — die deutschen und österreichischen Datenschutzbehörden haben 2023–2025 mehrfach Apps abgemahnt und Bußgelder verhängt, die ohne DSFA KI-basierte Nutzerdatenverarbeitung betrieben haben.

**Dimension 3 — ML-Training auf Nutzerdaten:**
Die geplante Nutzung von Nutzer-Uploads als Trainingsdaten erfordert eine **separate, granulare Einwilligung** (DSGVO Art. 6 Abs. 1a), die klar von der App-Nutzungseinwilligung getrennt ist. Diese Einwilligung muss widerrufbar sein — was impliziert, dass ein Widerruf-Mechanismus und ein Datenlöschprozess für Trainingsdaten technisch implementiert werden muss. Das ist kein trivialer Aufwand.

**Dimension 4 — COPPA (falls US-Launch geplant):**
GrowMeldAI hat keine explizite Altersschranke. Wenn die App in den USA verfügbar ist und keine verifizierte Altersschranke von 13+ Jahren implementiert, greift COPPA. Die FTC hat 2024–2025 Durchsetzungsmaßnahmen gegen Apps verschärft, die keine verifizierte Altersverifikation hatten. Für einen DACH-primären Launch ist das nachrangig, aber für jeden englischsprachigen Store-Release relevant.

**Dimension 5 — Firebase (Google) als Drittanbieter:**
Firebase Cloud Messaging überträgt Daten an Google-Server. Im Kontext des Schrems-II-Urteils und der laufenden EU-US-Datentransfer-Diskussion (EU-US Data Privacy Framework, gültig seit 2023, aber weiterhin unter juristischem Druck) muss die Firebase-Nutzung in der Datenschutzerklärung explizit mit Rechtsgrundlage adressiert werden.

**Geschätzte Kosten:**
- Einmalig: €8.000–€18.000
  - Datenschutzbeauftragter (externer DSB, Erstberatung + DSFA-Erstellung): €3.000–€6.000
  - Anwaltliche Datenschutzerklärung + AGB-Formulierung (DSGVO-konform): €3.000–€6.000
  - Technische Implementierung (Einwilligungsmanagement, Datenlösch-Prozesse, Widerruf-Mechanismus): €2.000–€6.000 (Entwicklungsaufwand)
- Laufend: €3.000–€6.000/Jahr (externer DSB Retainer, jährliche Datenschutzerklärung-Updates, Behördenkorrespondenz)

**Alternative zur Risikoreduktion:**
1. **Standortdaten:** Grobe Standortangabe (PLZ oder Stadt, vom Nutzer manuell eingegeben) statt GPS-basierter Ortung — eliminiert die sensibelste Datenkategorie und reduziert DSFA-Aufwand erheblich. Wetterintegration funktioniert mit PLZ problemlos.
2. **ML-Training:** Phase-1-Launch ohne Nutzer-Upload-Training. Plant.id API als alleinige KI-Basis, eigene Trainingsdaten erst ab Phase 2 mit vollständig aufgesetztem Einwilligungsprozess.
3. **Firebase-Alternative:** EU-basierte Push-Service-Alternative (z.B. OneSignal mit EU-Hosting) prüfen — reduziert Drittland-Transfer-Risiko.

**Zeitaufwand:** 6–10 Wochen — dieser Block ist der kritische Pfad für den Launch-Zeitplan

---

### 5. Jugendschutz (USK / PEGI)

**Risiko: 🟢**

**Begründung:** GrowMeldAI enthält keine jugendschutzrelevanten Inhalte (keine Gewalt, keine sexuellen Inhalte, kein Glücksspiel, keine Fremdkommunikation in Phase 1). Eine USK-Klassifikation ist für reine Utility-Apps im deutschen Markt nicht verpflichtend. PEGI ist für Games-Klassifikation vorgesehen — nicht zutreffend.

Die App wird voraussichtlich als **"Ohne Altersbeschränkung" (USK 0 äquivalent)** eingestuft. Im App Store entspricht das der Altersfreigabe "4+" (Apple).

**Einziger Hinweis:** Die Giftigkeit-Warnungen (Rechtsfeld 9) könnten theoretisch bei sehr strenger Auslegung als "beängstigende Inhalte für Kleinkinder" interpretiert werden — dies ist aber kein realistisches Szenario und kein Blocking-Risk.

**Geschätzte Kosten:** —
**Zeitaufwand:** —

---

### 6. Social Features

**Risiko: 🟢 (Phase 1 nicht relevant)**

**Begründung:** Die bewusste Entscheidung, keine In-App-Community zu bauen, eliminiert einen ganzen Rechtsblock (Moderationspflichten, NetzDG-Compliance in Deutschland, DSA-Pflichten für Plattformen). Die Export-Funktion für Wachstumsfotos zu Instagram/TikTok ist aus rechtlicher Sicht eine reine Output-Funktion ohne Plattformverantwortung.

**Vorsorgehinweis für Phase 2:** Falls Community-Features später eingeführt werden, greift der Digital Services Act (DSA) ab bestimmten Nutzerschwellen. Dieser Punkt sollte bei der Phase-2-Planung frühzeitig evaluiert werden.

**Geschätzte Kosten:** —
**Zeitaufwand:** —

---

### 7. Markenrecht — Namenskonflikt

**Risiko: 🟡**

**Begründung:** "GrowMeldAI" ist ein zusammengesetzter Begriff. Eine schnelle Markenrecherche zeigt kein identisches Trademark im DACH-Raum — aber das ist kein Freifahrtschein. Drei konkrete Risiken:

**Risiko A — "GrowMeld"-Bestandteil:** "Grow" als generischer Begriff ist nicht schutzfähig. "Meld" ist ungewöhnlich — hier liegt die Schutzfähigkeit und gleichzeitig das Kollisionsrisiko mit etwaigen bestehenden "Meld"-Marken im Software-/App-Bereich.

**Risiko B — "AI"-Suffix:** Viele App-Unternehmen haben in 2023–2025 massenhaft "AI"-Marken registriert. Eine vollständige Recherche im EUIPO- und USPTO-Register ist zwingend, bevor Marketing-Investitionen in den Markennamen fließen.

**Risiko C — Internationaler Schutz:** Ein nur in Deutschland eingetragenes Trademark schützt nicht im englischsprachigen Markt. Bei geplantem iOS-Launch (global sichtbar im App Store) ist zumindest eine EU-Gemeinschaftsmarke (EUTM) empfehlenswert.

**Geschätzte Kosten:**
- Einmalig: €2.500–€5.000
  - Markenrecherche durch Anwalt (EUIPO + USPTO): €800–€1.500
  - EUTM-Anmeldung (EU-weiter Schutz): €850–€1.200 (offizielle Gebühren) + €800–€1.500 Anwaltskosten
  - Optionale USPTO-Anmeldung (USA): €500–€1.000 zusätzlich
- Laufend: €500–€1.000/Jahr (Trademark-Monitoring-Service, Verlängerungsgebühren ab Jahr 10)

**Alternative:** Falls "GrowMeldAI" Kollisionen zeigt — Namensanpassung ist in dieser frühen Phase kostengünstig. Nach signifikanten Marketing-Investitionen wird ein Rebranding teuer. **Markenrecherche sollte daher vor jeder UA-Ausgabe abgeschlossen sein.**

**Zeitaufwand:** 2–3 Wochen (Recherche + Anmeldung laufen parallel, Registrierungsbescheid dauert Monate, aber der Anmeldezeitpunkt sichert Priorität)

---

### 8. Patente

**Risiko: 🟡**

**Begründung:** Das Risiko ist real, aber oft überschätzt. Die differenzierte Einschätzung:

**Bilderkennungs-ML:** Grundlegende Computer-Vision- und ML-Algorithmen (