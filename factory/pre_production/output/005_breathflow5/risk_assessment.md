# Risk-Assessment-Report: Minimalistische Atem-Übungs-App

**Erstellt:** Juni 2025
**Basis:** Concept Brief + Legal-Research-Report
**Status:** KI-basierte Ersteinschätzung — keine Rechtsberatung

---

## Risiko-Übersicht (Ampel-Tabelle)

| Rechtsfeld | Risiko | Geschätzte Kosten (einmalig) | Zeitaufwand |
|---|---|---|---|
| Monetarisierung & IAP (App-Store-Regeln) | 🟢 | — | 1–2 Wochen (Implementierung) |
| App Store Richtlinien (Apple + Google) | 🟢 | — | 1 Woche (Review-Vorbereitung) |
| AI-generierter Content / Urheberrecht | 🟡 | 500–1.500 € | 1–2 Wochen |
| Datenschutz DSGVO | 🟢 | 500–1.000 € | 1–2 Wochen |
| Datenschutz COPPA | 🟢 | — | 3–5 Tage |
| Jugendschutz (USK/PEGI/IARC) | 🟢 | 0–100 € | 2–3 Tage |
| Markenrecht / Namenskonflikt | 🟡 | 800–2.500 € | 2–4 Wochen |
| Glücksspielrecht | ⚫ | — | — |
| Social Features | ⚫ | — | — |
| Patente (Atemtechniken + Animation) | 🟢 | 500–1.000 € (Recherche) | 1–2 Wochen |
| Medizinprodukte-Regulierung (EU MDR) | 🔴 | 0 € bei Risiko-Vermeidung / 50.000–200.000 € bei Zertifizierung | 2–4 Wochen (Positionierungsentscheidung) |

---

## Detailbewertung pro Feld

### 1. Monetarisierung & IAP (App-Store-Regeln)

- **Risiko:** 🟢
- **Begründung:** Das gewählte Freemium-Modell mit optionalem Einmalkauf ist das am besten etablierte und rechtlich unproblematischste Modell in beiden App Stores. Alle drei Kerntechniken bleiben dauerhaft kostenlos — das eliminiert das größte rechtliche Risiko im Freemium-Bereich (irreführende Werbung durch nachträgliches Sperren von Basis-Features). Apple und Google wickeln USt./MwSt. als Marketplace-Facilitator ab, die steuerliche Eigenverantwortung des Entwicklers ist für DACH/UK/Nordamerika minimal. Das EU-Verbraucherrecht (Richtlinie 2019/770) ist durch den vollständig clientseitigen Betrieb strukturell leicht erfüllbar — kein Serverausfall, kein Cloud-Dienst, der "wegfallen" kann.
- **Einzige operative Pflicht:** In App-Store-Beschreibung, Kaufdialog und ggf. Onboarding konsistent kommunizieren, was kostenlos bleibt und was der IAP freischaltet. Das ist Texter-Arbeit, kein juristisches Verfahren.
- **Geschätzte Kosten:** — (kein externer Aufwand, interner Redaktionsaufwand < 1 Tag)

---

### 2. App Store Richtlinien (Apple + Google)

- **Risiko:** 🟢
- **Begründung:** Das Konzept ist in seiner aktuellen Form strukturell richtlinienkonform für beide Stores. Kein erzwungener Account (Guideline 5.1.1 Apple erfüllt), kein externes Zahlungssystem für digitale IAP-Inhalte, vollständige Offline-Funktionalität ohne technische Einschränkungen, minimaler Privacy-Manifest-Eintrag ("No data collected") der als Qualitätsmerkmal kommunizierbar ist. Die Health-App-Kategorie wird von beiden Stores genauer geprüft — das Hauptrisiko hier ist nicht die Kategorie selbst, sondern ob die App-Store-Beschreibung implizit medizinische Claims enthält (→ direkte Verbindung zu Feld #11, Medizinprodukte-Regulierung). Wenn das Texting sauber ist, ist dieses Feld grün.
- **Operative Empfehlung:** Apple Privacy Nutrition Label und Google Data Safety Section vor Submission vollständig und korrekt ausfüllen. Bei einer App ohne Datenerhebung ist das der einfachste mögliche Eintrag und gleichzeitig ein marketingfähiges Signal.
- **Geschätzte Kosten:** — (interner Aufwand, kein externer Dienstleister erforderlich)

---

### 3. AI-generierter Content / Urheberrecht

- **Risiko:** 🟡
- **Begründung:** Das Risiko ist nicht existenziell, aber handlungsbedürftig. Die Kreis-Animation ist programmatisch (Code-basiert) umsetzbar — das ist eigene Schöpfung, kein Problem. Das Risiko konzentriert sich auf zwei konkrete Bereiche: (a) **Hintergrundklänge und Ambient-Sounds** als optionaler IAP-Inhalt — hier sind kommerzielle Lizenzen zwingend, "lizenzfrei" ist kein Freifahrtschein; (b) **AI-generierte UI-Assets** (Farbverläufe, Icons, Illustrationen) — deren urheberrechtliche Schutzfähigkeit für den eigenen IP ist nach US Copyright Office (Januar 2025) ohne substanzielle menschliche Bearbeitung fraglich, was den eigenen Schutz schwächt, aber kein Verletzungsrisiko erzeugt, solange keine fremden Werke reproduziert werden. Das Hauptrisiko ist nicht Klage, sondern fehlende Dokumentation, die bei späterer Due-Diligence (Investoren, Exit) Probleme macht.
- **Geschätzte Kosten:** 500–1.500 € — aufgeteilt in: Lizenzkosten für kommerzielle Sound-Assets (200–800 €, abhängig von Plattform und Paket, z.B. Artlist, Soundsnap Commercial License) + anwaltliche Kurzprüfung der Lizenzverträge für die genutzten Asset-Quellen (300–700 €, ein- bis zweistündige Beratung bei einem IP-Anwalt im DACH-Raum).
- **Alternative / Risikominimierung:** Alle visuellen Assets programmatisch (Flutter-native) implementieren statt AI-generiert — dann entfällt das Urheberrechtsproblem vollständig für diesen Bereich. Sounds ausschließlich aus Bibliotheken mit explizit kommerzieller App-Lizenz beziehen und Lizenzdatei im Projektarchiv ablegen.

---

### 4. Datenschutz (DSGVO)

- **Risiko:** 🟢
- **Begründung:** Dieses Konzept ist strukturell der DSGVO-freundlichste App-Typ, der gebaut werden kann. Keine personenbezogenen Daten, kein Backend, keine Analytics-SDKs, kein Account — die meisten DSGVO-Artikel (Art. 13/14 Informationspflichten, Art. 17 Löschrecht, Art. 20 Datenportabilität) treffen faktisch ins Leere, weil nichts erhoben wird. Dennoch gilt: Eine **Datenschutzerklärung ist Pflicht**, auch wenn sie inhaltlich minimal ist. App Stores verlangen sie, und sie muss technisch korrekt sein. Der Inhalt bei diesem Konzept: "Diese App erhebt, speichert und verarbeitet keine personenbezogenen Daten. Alle Nutzungsdaten verbleiben ausschließlich auf Ihrem Gerät." Das ist eine Seite, keine Anwaltsstunde.
- **Einzige operative Pflicht:** Eine rechtssichere, deutschsprachige Datenschutzerklärung erstellen (für DACH-Primärmarkt), die die Nicht-Datenerhebung korrekt dokumentiert und die Store-Anforderungen erfüllt.
- **Geschätzte Kosten:** 500–1.000 € — Anwaltliche Erstellung oder qualitätgesicherte Nutzung eines Datenschutz-Generators mit anwaltlicher Prüfung (z.B. Anwaltskanzlei IT-Recht München, Kanzlei WBS, oder datenschutzbeauftrager.de-Vorlagen mit Prüfung). Der IAP-Kauf über Apple/Google ist kein eigener Datenverarbeitungsvorgang des Entwicklers — die Stores sind selbst Verantwortliche für die Zahlungsabwicklung.

---

### 5. Datenschutz (COPPA)

- **Risiko:** 🟢
- **Begründung:** Die Zielgruppe ist explizit 25–45 Jahre — keine Kinder. COPPA (Children's Online Privacy Protection Act, USA) greift bei Apps, die sich an Kinder unter 13 Jahren richten oder wissen, dass sie von Kindern unter 13 genutzt werden. Da die App (a) keine Daten erhebt und (b) sich an Erwachsene richtet, ist COPPA strukturell nicht ausgelöst. Operative Pflicht: Im App Store das Altersrating korrekt setzen (nicht für Kinder) und in der App-Store-Beschreibung keine Sprache verwenden, die die App für Kinder attraktiv erscheinen lässt. Beides ist durch das Konzept-Positioning (stressbelastete Berufstätige) inhärent erfüllt.
- **Geschätzte Kosten:** — (kein externer Aufwand)

---

### 6. Jugendschutz (USK/PEGI/IARC)

- **Risiko:** 🟢
- **Begründung:** Eine Atem-Übungs-App ohne Gewalt, ohne sexuelle Inhalte, ohne Glücksspiel, ohne Horror-Elemente und ohne User-Generated Content ist für alle Altersgruppen freigegeben. Im Google Play Store wird das IARC-Rating-System genutzt (kostenloser Fragebogen, automatisches Rating). Im Apple App Store wählt der Entwickler das Rating selbst (4+ bei diesem Konzept eindeutig korrekt). USK-Prüfung ist für Mobile-Apps in Deutschland nicht verpflichtend (nur für physische Medien und bestimmte Plattformen), PEGI ist freiwillig.
- **Geschätzte Kosten:** 0–100 € (IARC kostenlos, PEGI-Selbst-Rating-Tool kostenfrei, ggf. minimaler administrativer Aufwand)

---

### 7. Markenrecht / Namenskonflikt

- **Risiko:** 🟡
- **Begründung:** Der App-Name ist noch unbekannt — das ist das Risiko. Im Wellness/Meditation-App-Markt sind viele generische Begriffe (Breathe, Calm, Relax, Atmen, etc.) bereits als Marken eingetragen oder zumindest als App-Namen vergeben. Eine fehlende Markenrecherche vor dem Launch kann im schlimmsten Fall zu einer Abmahnung nach Soft-Launch führen — mit Kosten von 1.000–5.000 € für die Abmahnung selbst plus ggf. Rebranding-Aufwand (App-Store-Umbennenung, neue ASO, neue Assets). Das ist vermeidbar mit einer Vorab-Recherche.
- **Geschätzte Kosten:** 800–2.500 € — aufgeteilt in: EUIPO-Markenrecherche (selbst durchführbar, kostenlos) + USPTO-Recherche (selbst durchführbar, kostenlos) + anwaltliche Bewertung der Recherche-Ergebnisse (600–1.500 €, 1–3 Stunden IT-/Markenanwalt DACH) + optionale eigene Markenanmeldung im DACH-Raum (DPMA-Gebühr ~290 € pro Klasse + Anwaltshonorar 500–1.000 €, falls gewünscht). Eine eigene Markenanmeldung ist für einen Soft-Launch nicht zwingend, aber mittelfristig empfehlenswert.
- **Alternative / Risikominimierung:** Einen distinktiven, nicht-generischen App-Namen wählen (nicht "Breathe", nicht "Atmen", nicht "Calm" — etwas mit eigenem Charakter), der die Markenrecherche erheblich vereinfacht und das Konfliktrisiko strukturell senkt. Ein ungewöhnlicher Name schützt besser und lässt sich leichter selbst eintragen.

---

### 8. Glücksspielrecht

- **Risiko:** ⚫ Nicht relevant
- **Begründung:** Kein Zufallselement, keine virtuelle Währung, kein Loot-Box-Mechanismus. Strukturell ausgeschlossen. Kein Handlungsbedarf.

---

### 9. Social Features

- **Risiko:** ⚫ Nicht relevant
- **Begründung:** Kein Social-Feature im Konzept. Kein User-Generated Content, keine Community-Funktion, kein Sharing-Mechanismus. Strukturell ausgeschlossen. Kein Handlungsbedarf.

---

### 10. Patente (Atemtechniken + Animation)

- **Risiko:** 🟢
- **Begründung:** Die verwendeten Atemtechniken (4-7-8, Box Breathing, einfaches Beruhigen) sind seit Jahrzehnten publizierte, medizinisch-wissenschaftlich dokumentierte Methoden ohne bekannten Patentschutz. Atemtechniken als solche sind in keiner relevanten Jurisdiktion patentierbar (kein technisches Verfahren, kein Produkt). Die Kreis-Visualisierung ist ein UI-Element — als solches nicht patentierbar, solange keine spezifische technische Implementierung eines bestehenden Patents kopiert wird. Eine kurze Freihalterecherche im USPTO und DPMA für relevante Suchbegriffe ("breathing exercise animation", "biofeedback visualization") ist dennoch ratsam als Dokumentation, nicht als Pflicht.
- **Geschätzte Kosten:** 500–1.000 € — anwaltliche Kurzrecherche durch einen Patent-/IP-Anwalt als Absicherungsdokumentation (optional, aber empfehlenswert für spätere Due-Diligence).

---

### 11. Medizinprodukte-Regulierung (EU MDR) ⚠️

- **Risiko:** 🔴
- **Begründung:** Das ist das einzige echte K.O.-Risiko dieses Konzepts — und es ist vollständig durch Positionierungsentscheidungen steuerbar, ohne das Produkt inhaltlich zu verändern. Die Lage:

  Die **EU-Medizinprodukteverordnung (MDR, VO 2017/745)** und die dazugehörige Leitlinie der EU-Kommission zu **Software als Medizinprodukt (MDCG 2019-11)** definieren: Eine Software ist ein Medizinprodukt, wenn sie zur **Diagnose, Prävention, Überwachung, Behandlung oder Linderung von Krankheiten** bestimmt ist. Die Bestimmung ergibt sich dabei nicht allein aus dem Code, sondern **primär aus der Zweckbestimmung des Herstellers** — also aus App-Store-Beschreibung, Marketing-Texten, UI-Texten und Claim-Kommunikation.

  **Das Risiko für dieses Konzept konkret:** Wenn die App-Store-Beschreibung oder das In-App-Texting Formulierungen enthält wie:
  - *"Hilft bei Angststörungen"*
  - *"Bewährt bei Panikattacken"*
  - *"Klinisch getestete Entspannungsmethode"*
  - *"Reduziert Blutdruck"*
  - *"Therapeutisch wirksam"*

  ...dann ist die App potenziell ein **Klasse-I-Medizinprodukt** (mindestens), was eine **technische Dokumentation, Konformitätsbewertung, CE-Kennzeichnung und EUDAMED-Registrierung** erfordert. Kosten: 50.000–200.000 € und 6–24 Monate Vorlaufzeit. Das ist für diesen App-Typ wirtschaftlich nicht darstellbar.

  **Die gute Nachricht:** Das Risiko ist durch sauberes Texting **vollständig vermeidbar**, ohne das Produkt zu verändern.

- **Geschätzte Kosten:**
  - **Bei Risiko-Vermeidung durch Positionierung:** 0–1.500 € (anwaltliche Prüfung der App-Store-Texte und In-App-Kommunikation auf MDR-Compliance, 1–3 Stunden spezialisierter Anwalt für Medizinrecht/MedTech, DACH: 300–500 €/Stunde)
  - **Bei falscher Positionierung + nachträglicher MDR-Zertifizierung:** 50.000–200.000 € + 6–24 Monate Verzögerung — **wirtschaftlich nicht sinnvoll für dieses Produkt**

- **Alternative / Risikominimierung (konkret und umsetzbar):**
  Das Produkt inhaltlich nicht verändern — ausschließlich das Texting anpassen. Die sichere Positionierung lautet:

  ✅ **"Atem-Übungs-App für Alltagsentspannung"** — kein medizinischer Claim
  ✅ **"Geführte Atemübungen für ruhige Momente"** — Lifestyle-Positioning
  ✅ **"Hilft dir, bewusster zu atmen"** — kein Krankheitsbezug
  ✅ **"Für alle, die eine kurze Auszeit suchen"** — allgemeines Wellness-Framing

  ❌ Vermeiden: Krankheitsnamen, klinische Begriffe, therapeutische Versprechen, Referenzen auf medizinische Studien ohne Kontext

  Eine anwaltliche Prüfung des finalen App-Store-Texts und der In-App-Texte durch einen MedTech-Anwalt vor dem Launch ist bei diesem Risikoprofil **keine Option, sondern Pflicht**.

---

## Regionale