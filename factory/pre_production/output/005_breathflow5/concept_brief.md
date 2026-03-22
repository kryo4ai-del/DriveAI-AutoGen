# Concept Brief: Minimalistische Atem-Übungs-App

---

## One-Liner

Eine vollständig offline nutzbare, accountfreie Atem-Übungs-App mit animierter Kreis-Visualisierung, die drei klar benannte Techniken und lokales Wochen-Tracking kombiniert — für Nutzer, die Entspannung ohne Paywall und ohne Datenweitergabe wollen.

---

## Kern-Mechanik & Core Loop

**Beschreibung:**
Der Nutzer öffnet die App → wählt eine Technik (4-7-8, Box Breathing, Einfaches Beruhigen) → folgt einer animierten Kreis-Visualisierung, die Einatmen, Halten und Ausatmen taktet → ein Timer läuft mit → nach Abschluss zeigt ein lokaler Wochentracker die kumulierte Übungszeit.

**Begründung (Daten):**
Die Platzierung der Technikauswahl als erster Screen ist ein bewusster UX-Vorteil gegenüber dem direkten Wettbewerb. Breathwrk und Calm verstecken spezifische Techniken in der Navigation oder sperren sie hinter Paywalls — dies ist eine dokumentierte Nutzerbeschwerde beider Apps (Competitive Report, Breathwrk-Analyse: *"most techniques locked"*; Calm-Analyse: *"I just want the breathing exercises, not all the other stuff"*). Die CEO-Idee löst dieses Problem durch sofortigen, ungefilterten Zugang zur Kernaktion.

Der wöchentliche Fortschritts-Screen ist das einzige Tracking-Feature und schließt einen dokumentierten Marktgap: Kein aktiver Wettbewerber bietet Praxis-Tracking ohne Account und ohne Cloud. Oak hat kein Tracking. Calm und Headspace tracken ausschließlich mit Account. (Competitive Report, Gap #3)

**Was passiert in den ersten 60 Sekunden:**
App öffnen → Drei Techniken sichtbar, keine Onboarding-Screens, kein Registrierungs-Prompt → Technik antippen → Kreisanimation startet sofort → Nutzer atmet mit. Die gesamte Strecke von Launch bis zur ersten aktiven Atemübung unter 15 Sekunden ist das strukturelle Gegenprogramm zu Calm und Headspace, die durch Account-Erstellung und Onboarding-Flows den Einstieg verzögern (Competitive Report, Calm: *"Forced to create an account just to try it"*).

---

## Zielgruppe

**Profil:**
Stressbelastete Berufstätige, 25–45 Jahre, leicht weiblich-dominant (55–60% weiblich / 40–45% männlich), primär DACH, UK, Nordamerika. Psychografisch: Mindfulness-Einsteiger oder -Gelegenheitsnutzer, die eine schnelle, niedrigschwellige Entspannungsroutine suchen — ohne Onboarding-Aufwand, ohne Account, ohne das Gefühl, einer Abo-Falle zu begegnen. Nutzen die App morgens (6–8:30 Uhr), abends (21–23 Uhr) und spontan bei Stressspitzen tagsüber.

**Begründung (Daten):**
Das Altersprofil (25–45) weicht bewusst vom Mobile-Gaming-Durchschnitt (18–24) ab und stützt sich auf Wellness-App-Proxy-Daten aus Calm/Headspace-Marktberichten (Zielgruppen-Report, Sensor Tower Health & Fitness Report 2024). Die Nutzungszeiten (Morgen/Abend) sind durch publizierte Headspace-Nutzungsdaten belegt (Zielgruppen-Report). Die DACH-Priorisierung wird durch Gap #4 des Competitive Reports gestützt: Europäische Nutzer sind nachweislich privacy-sensitiver, und das No-Account/No-Backend-Positioning ist im DSGVO-Kontext ein kommunizierbarer USP — nicht nur ein technisches Detail.

⚠️ **Einschränkung:** Alle demografischen Zahlen sind Proxy-Werte aus verwandten App-Kategorien, keine direkten Messdaten der Breathing-App-Nische. Validierung im Soft-Launch erforderlich.

---

## Differenzierung zum Wettbewerb

**Direkte Vergleiche:**

| Wettbewerber | Stärke des Konkurrenten | Lücke, die die CEO-Idee füllt |
|---|---|---|
| **Oak** | Kostenlos, kein Account, minimalistisch — konzeptionell nächster Verwandter | Seit ~2021 nicht mehr aktiv entwickelt, kein Wochen-Tracking, keine Kreis-Animation, iOS-only. Dieser Slot ist de facto vakant. (Competitive Report, Gap #1) |
| **Breathwrk** | Fokussiert auf Atemübungen, gute Animationen | Abo-Pflicht, Account erforderlich, nicht vollständig offline, soziale Features überladen die UX (Competitive Report, Breathwrk-Analyse) |
| **Calm** | Marktführer, starke Brand | Atemübungen sind Nebenfeature, sehr komplex, Account + Abo zwingend, Nutzer beschweren sich explizit über Bloat (Competitive Report) |
| **Headspace** | Strukturiertes Lernsystem | Kein reiner Timer-/Technik-Fokus, Account + Abo, offline eingeschränkt (Competitive Report) |
| **Prana Breath** | Offline, breite Techniken, Android-stark | Visuell veraltet, zu komplex für Einsteiger, unübersichtliche Monetarisierung (Competitive Report) |

**Unique Selling Points:**

1. **"Kein-Bullshit"-Positioning:** Vollständig offline + kein Account + kein Abo — diese Kombination hat im Jahr 2025 keinen aktiven, gepflegten Wettbewerber. (Competitive Report, Sättigungseinschätzung: *Minimalistische Atem-Apps [offline, kein Account, kein Abo]: 🟢 Niedrig gesättigt*)

2. **Sofort-Zugang zur Kernaktion:** Technikauswahl als erster Screen, ohne Onboarding-Gate — direktes Gegenprogramm zu den dokumentierten Hauptbeschwerden gegen Calm und Breathwrk.

3. **Lokales Wochen-Tracking als Privacy-Feature:** Fortschrittsanzeige ohne Cloud, ohne Account — kommunizierbarer Datenschutz-USP im DSGVO-Kontext, kein aktiver Wettbewerber bietet dies in dieser Kombination. (Competitive Report, Gap #3 und #4)

4. **Android-Parität:** Oak (nächster Vergleichspunkt) ist iOS-only. Ein modernes minimalistisches Produkt auf Android ist strukturell unterversorgt. (Competitive Report, Gap #5)

---

## Monetarisierung

**Modell:**
**Empfehlung: One-Time-Purchase (Einmalkauf), 1,99–3,99 €, mit einer dauerhaft kostenlosen Basisstufe.**

Konkreter Vorschlag:
- **Kostenlos:** Alle drei Techniken vollständig nutzbar, Kreis-Animation, Timer, Wochen-Tracking
- **Einmalig kaufbar (1,99–3,99 €):** Optionale Erweiterungen — z.B. zusätzliche Atemrhythmen, alternative Visualisierungen, Hintergrundklänge / -farben

**Begründung (Daten):**
Die Zielgruppe dieser App — privacy-affin, kein Account gewünscht, minimalistisch orientiert — reagiert nachweislich negativ auf Abo-Druck ohne Backend-Mehrwert (Zielgruppen-Report: *"Subscription schwierig — Nutzerbasis dieser App-Philosophie reagiert negativ auf Abo-Druck"*). Oak ist das Beweisexemplar: Kostenlos, kein Abo, wird von Apple als "Hidden Gem" empfohlen und hat trotz fehlender Weiterentwicklung eine loyale Nutzerbasis aufgebaut (Competitive Report).

Die durchschnittliche Ausgabenbereitschaft der Zielgruppe liegt bei 2–5 USD/Monat (Zielgruppen-Report, Proxy Sensor Tower Health & Fitness 2024) — ein Einmalkauf im Bereich 1,99–3,99 € entspricht dieser Schmerzgrenze, ohne die Abo-Aversion zu triggern.

⚠️ **Abweichung von der CEO-Idee (kein Monetarisierungsmodell spezifiziert):** Die CEO-Idee erwähnt kein Monetarisierungsmodell. Die Recherche legt nahe, dass eine komplett kostenlose App ohne jede Monetarisierungsoption eine vertane Möglichkeit wäre — der Markt zeigt, dass Nutzer dieser Kategorie bereit sind, einen fairen Einmalkauf zu tätigen, wenn die App ihr Versprechen hält. Finale Entscheidung beim CEO.

**Erwartete Einnahmen-Aufteilung (Schätzung auf Basis der Proxydaten):**
- ~80–90% der Nutzer: kostenlose Stufe (kein Umsatz, aber Markenaufbau und Bewertungen)
- ~10–20% der Nutzer: Einmalkauf (Hauptumsatzträger)
- ⚠️ Keine belastbaren Conversion-Rate-Daten für diese spezifische Nische verfügbar — diese Schätzung basiert auf allgemeinen Freemium-Benchmarks aus dem Health-App-Segment.

---

## Session-Design

**Ziel-Dauer:** 4–10 Minuten pro Session (technisch durch die Übungen vorgegeben: 4-7-8 ca. 4 Min, Box Breathing ca. 5–8 Min)

**Frequenz:** 1–2 Sessions pro Tag

**Begründung:**
Die Session-Länge ist nicht durch ein Design-Ziel, sondern durch die Natur der Atemtechniken selbst determiniert — das ist ein struktureller Vorteil. Nutzer wissen, was sie erwartet, und können die App in einen konkreten Zeitslot einplanen (Zielgruppen-Report: Session-Verhalten Wellness-Apps, Headspace-Proxy). Die Doppelnutzung morgens und abends ist durch dokumentierte Nutzungsmuster von Meditation-Apps belegt (Zielgruppen-Report: Hauptnutzungszeiten 6–8:30 Uhr und 21–23 Uhr). Der wöchentliche Tracker macht genau diese Routine sichtbar und schafft einen leichten Habit-Loop ohne Gamification-Druck.

---

## Tech-Stack Tendenz

**Empfehlung:** Cross-Platform (Flutter oder React Native), vollständig clientseitig, lokaler Datenspeicher (z.B. SharedPreferences / AsyncStorage für Wochen-Tracking), keine Netzwerk-Requests, keine Analytics-SDKs die Drittdaten senden.

**Begründung:**
- Kein Backend ist nicht nur ein technisches Feature, sondern das zentrale Produkt-Versprechen — der Tech-Stack muss dies strukturell verankern, nicht nur als Policy.
- Cross-Platform ist durch die Android-Parität-Anforderung begründet (Competitive Report, Gap #5: Oak ist iOS-only, Android ist underserved).
- Der Verzicht auf Tracking-SDKs (z.B. Firebase Analytics, Amplitude) ist konsequent zum Privacy-Positioning und im DSGVO-Kontext relevant (Competitive Report, Gap #4). Das stärkt das Nutzervertrauen und vereinfacht die Datenschutzerklärung erheblich.
- Animationen (Kreis-Visualisierung) sind mit Flutter nativ hochwertig umsetzbar ohne externe Libraries.

⚠️ **Einschränkung:** Die Recherche enthält keine Tech-Stack-spezifischen Daten. Diese Empfehlung basiert auf der Ableitung aus den Produkt-Anforderungen (offline, cross-platform, kein Backend), nicht auf Marktdaten.

---

## Abweichungen von der CEO-Idee

**[Monetarisierung]:** Ursprünglich nicht spezifiziert (implizit kostenlos) → **Empfehlung: Freemium mit optionalem Einmalkauf**, weil die Zielgruppen-Daten eine Ausgabenbereitschaft von 2–5 USD belegen und das Abo-Modell der direkten Wettbewerber nachweislich als Hauptkritikpunkt in Reviews auftaucht — der Einmalkauf ist der Mittelweg zwischen "kostenlos wie Oak" (keine Einnahmen) und "Abo wie Breathwrk" (Nutzerabweisung). Finale Entscheidung beim CEO.

**[Platform-Scope]:** Ursprünglich nicht explizit spezifiziert → **Empfehlung: iOS und Android gleichzeitig**, weil Oak als einziger direkter Vergleichspunkt iOS-only ist und Android dadurch strukturell unterversorgt ist (Competitive Report, Gap #5). Der No-Backend-Ansatz macht Cross-Platform technisch einfacher als bei Wettbewerbern mit Cloud-Sync.

**[Kein weiterer Änderungsbedarf]:** Die Kernelemente der CEO-Idee — drei Techniken, Kreis-Animation, Timer, Wochen-Tracking, offline, kein Account, kein Backend — werden durch die Recherche vollständig bestätigt und nicht durch Marktdaten in Frage gestellt. Es gibt keine Anpassungsempfehlung an der inhaltlichen Konzeption.

---

## Stärken des Konzepts (datenbasiert)

**Stärke #1: Der nächste direkte Wettbewerber ist inaktiv.**
Oak ist konzeptionell der engste Verwandte (kostenlos, kein Account, minimalistisch, offline) — wird aber seit ca. 2021 nicht mehr aktiv entwickelt, hat kein Wochen-Tracking und ist iOS-only. Dieser Marktslot ist de facto vakant. Ein modernes, gepflegtes Produkt an dieser Position hat keinen aktiven Gegner. (Competitive Report, Gap #1 und Sättigungseinschätzung: *"Minimalistische Atem-Apps: 🟢 Niedrig gesättigt"*)

**Stärke #2: Das Produkt löst die dokumentierten Hauptbeschwerden gegen alle aktiven Wettbewerber.**
Die häufigsten Nutzerbeschwerden gegen Calm, Headspace und Breathwrk sind einheitlich: zu komplex, zu teuer, Account-Pflicht, Techniken versteckt oder gesperrt. Die CEO-Idee adressiert jeden dieser Punkte strukturell — nicht als Marketing-Claim, sondern als technische Architektur-Entscheidung. (Competitive Report, Detailanalysen aller Wettbewerber)

**Stärke #3: Offline + kein Account + lokales Tracking ist ein echter DSGVO-USP im DACH-Markt.**
Kein aktiver Wettbewerber bietet Wochen-Tracking ohne Cloud und ohne Account. Im europäischen Markt, wo DSGVO-Enforcement 2024 weiter verschärft wurde, ist "Keine Daten, kein Server, kein Account" ein kommunizierbarer und verteidigbarer Vorteil — nicht nur ein technisches Detail. (Competitive Report, Gap #3 und #4; Zielgruppen-Report, Privacy-first-Affinität der Kernzielgruppe)

---

## Risiken und offene Fragen

**Risiko #1: Reaktion von Breathwrk.**
Breathwrk ist der aktivste direkte Wettbewerber im reinen Atem-App-Segment. Sollte Breathwrk eine vollständig kostenlose Stufe ohne Account-Pflicht einführen, würde der Gap erheblich kleiner. Aktuell gibt es kein Signal dafür — aber das Risiko ist real und nicht durch Daten ausgeschlossen. (Competitive Report, Sättigungseinschätzung: *"Diese Moves würden den Gap schließen — aber nicht sofort."*)

**Risiko #2: Discovery-Problem im App Store.**
UA-Kosten erreichten Ende 2024 Rekordhöhen, organische Discovery wird strukturell schwieriger (Trend-Report, Trend #5, bigabid.com 2026). Diese Daten beziehen sich auf Gaming, aber der Grundmechanismus — steigende Werbedruck-Kosten, sinkende organische Sichtbarkeit — ist plattformseitig für alle App-Kategorien relevant. Für eine App ohne Marketing-Budget ist App-Store-Optimierung (ASO) und ggf. ein gezielter Apple-Feature-Ansatz (Oak wurde als "Hidden Gem" featured) die primäre Discovery-Strategie. Konkrete UA-Kosten für Wellness-Apps konnten nicht belegt werden.

**Offene Frage #1: Exakte Marktgröße der Breathing-App-Nische.**
Der Wellness-App-Markt gesamt ist mit ~5 Mrd. USD (2024) belegt, aber das Breathing-Sub-Segment ist in keiner der verfügbaren Recherchen separat ausgewiesen. Die Nischengröße (und damit das realistische Umsatzpotenzial) bleibt eine Schätzung. (Competitive Report, Datenlücken-Tabelle)

**Offene Frage #2: Conversion-Rate für Einmalkauf im Offline-App-Segment.**
Es liegen keine Benchmark-Daten vor, wie hoch der Anteil zahlender Nutzer bei einer Freemium-App ohne Account und ohne Cloud-Features typischerweise ist. Die 10–20%-Schätzung im Monetarisierungsabschnitt ist eine strukturelle Ableitung, keine belegte Zahl.

**Offene Frage #3: Optimale Wahl der dritten Technik ("Einfaches Beruhigen").**
Die CEO-Idee benennt "Einfaches Beruhigen" als dritten Slot, ohne die genaue Methodik zu spezifizieren. Aus Nutzerperspektive (dokumentierte Beschwerden: *"I know how to breathe, I just need the timer"*) ist eine sehr einfache, selbsterklärende Technik (z.B. 4-4-Rhythmus oder verlängertes Ausatmen) vermutlich die richtige Wahl — aber welche konkrete Technik die beste Nutzer-Retention erzeugt, ist durch die vorliegenden Daten nicht beantwortbar und sollte im Soft-Launch A/B-getestet werden.

---

*Alle Aussagen in diesem Brief sind mit ihrer jeweiligen Datenquelle (Trend-Report, Competitive Report oder Zielgruppen-Report) verknüpft. Wo Proxy-Daten verwendet wurden, ist dies explizit gekennzeichnet. Der CEO trifft die finalen Produkt- und Monetarisierungsentscheidungen auf Basis dieser Grundlage.*