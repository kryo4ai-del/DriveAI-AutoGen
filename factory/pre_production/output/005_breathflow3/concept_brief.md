# Concept Brief: Minimalistische Atem-Übungs-App

---

## One-Liner

Eine offline-first Atem-App ohne Account, die in unter 10 Sekunden startet und berufstätigen Erwachsenen drei bewährte Atemtechniken mit animierter Kreis-Führung und wöchentlichem Minuten-Tracking bereitstellt — ohne Abo, ohne Daten, ohne Ablenkung.

---

## Kern-Mechanik & Core Loop

**Beschreibung:**
Der Nutzer öffnet die App, wählt eine von drei Techniken (4-7-8, Box Breathing, Einfaches Beruhigen), folgt der expandierenden/kontrahierenden Kreis-Animation mit integriertem Timer, und sieht nach der Session den kumulierten Wochenfortschritt in Minuten. Keine weiteren Schritte.

**Begründung (Daten):**
Der Competitive-Report identifiziert als Gap 5 explizit den fehlenden Schnellzugriff ohne Onboarding-Friction — alle großen Anbieter (Calm, Headspace) haben mehrstufiges Onboarding, das in Stresssituationen eine reale Nutzungsbarriere darstellt. Der Trend-Report bestätigt Retention als dominante Markt-KPI 2025/2026 (Sensor Tower State of Gaming 2026). Der leichtgewichtige Habit-Loop — Wochenminuten als einziger Progress-Indikator — entspricht dem Minimal-Viable-Habit-Loop-Prinzip und bedient laut Competitive-Report Gap 4 gezielt: Progress-Tracking ohne Gamification-Druck (keine Streaks, keine Badges), was Calm und Insight Timer nicht bieten.

**Was passiert in den ersten 60 Sekunden:**
- 0–3 Sek.: App öffnet direkt auf der Technik-Auswahl (drei Buttons, kein Splash-Screen, kein Onboarding)
- 3–10 Sek.: Nutzer tippt eine Technik an
- 10–15 Sek.: Kreis-Animation startet, erster Atemzug beginnt
- 60 Sek.: Nutzer ist bereits mitten in der zweiten Atemrunde

Dies ist der stärkste UX-Differentiator gegenüber allen identifizierten Wettbewerbern.

---

## Zielgruppe

**Profil:**
Berufstätige Erwachsene, 25–45 Jahre, leicht weiblich dominiert (~55–60 % weiblich), urban, DACH/UK/USA/Skandinavien. Nutzen die App in konkreten Stresssituationen (Pause im Büro, vor einem schwierigen Gespräch, beim Einschlafen), nicht als tägliches Ritual-Programm. Datensensibel, skeptisch gegenüber Abo-Modellen, suchen schnelle Wirkung ohne App-Beziehung einzugehen.

**Begründung (Daten):**
Das Zielgruppen-Profil (Agent 3) stützt Alter 25–45 auf Wellness-App-Proxies (Calm/Headspace-Nutzerdaten 2023), die konsistent berufstätige Erwachsene mit moderatem bis hohem Stresslevel als Kernnutzer ausweisen. Die Geschlechterverteilung folgt dem Calm/Headspace-Proxy (~55–60 % weiblich). Der Competitive-Report (Gap 3) belegt ein wachsendes Segment datenschutzsensitiver Nutzer in Europa, die explizit nach Cloud-freien Apps suchen — die DACH-Region ist hierfür der stärkste Markt. Das Nutzungsverhalten der Zielgruppe (Stress-getriggert, situativ, nicht geplant) erklärt, warum Schnellzugriff > Feature-Tiefe als Produktprioritä gilt.

---

## Differenzierung zum Wettbewerb

**Direkte Vergleiche:**

| Dimension | CEO-Idee | Breathwrk (direktester Konkurrent) | Oak (nächste Philosophie) |
|---|---|---|---|
| Kein Account | ✅ | ❌ (Schätzung) | ✅ |
| Vollständig Offline | ✅ | ❌ (Schätzung) | ✅ |
| Wochen-Tracking | ✅ | ⚠️ (Paywall) | ❌ |
| Aktive Pflege | ✅ | ✅ | ❌ (Abandonware-Verdacht) |
| Schnellzugriff <10 Sek. | ✅ | ❌ | ✅ |
| Minimalistisches UI | ✅ | ⚠️ | ✅ |

**Unique Selling Points:**

**USP 1 — Einziger aktiv gepflegter No-Account-Client in der Nische.**
Oak belegt diese Position philosophisch, entwickelt sie laut Competitive-Report aber nicht weiter ("wirkt verlassen", kein Update seit ~2 Jahren laut Schätzung). Das ist ein klassisches Sleepy-Incumbent-Szenario — die CEO-Idee kann diese Nische übernehmen ohne gegen Calm oder Headspace direkt zu konkurrieren.

**USP 2 — Offline-First als Vertrauensversprechen, nicht als technisches Merkmal.**
Kein Account, kein Backend, keine Daten → keine DSGVO-Komplexität, keine ATT-Friction (Apple iOS 14+), kein Server-Overhead. Laut Trend-Report strukturell ein Kosten- und Vertrauensvorteil, nicht nur ein Marketing-Argument.

**USP 3 — Progress ohne Druck.**
"Du hast diese Woche 14 Minuten geübt" — kein Streak-Verlust, keine Badge-Jagd. Laut Competitive-Report (Gap 4) ein explizit identifiziertes Nutzerbedürfnis, das keiner der großen Anbieter in dieser Form bedient.

---

## Monetarisierung

**Modell:**
**Einmaliger App-Kauf oder kostenloses Basis-Tier + Einmalig-Unlock** im Bereich **1,99–4,99 €**.

Zwei konkrete Optionen zur Entscheidung durch den CEO:

**Option A — Paid App (Einmalkauf, z. B. 1,99 €):**
Sauberste Umsetzung der Philosophie. Kein Freemium-Gefühl, kein "was ist gesperrt", sofortiges Vertrauen. Nachteil: Höhere Conversion-Hürde vor erstem Download.

**Option B — Kostenlos + Einmalig-Unlock (z. B. 2,99–4,99 €):**
Kostenloser Download senkt Einstiegshürde. Unlock könnte zusätzliche Übung(en) oder erweiterte Wochenstatistik (Monatsverlauf) freischalten. Vorteil: Größeres Reichweiten-Potential bei niedrigerem Erstvertrauen.

**⚠️ Kein Abo — klare Empfehlung:**
Das Zielgruppen-Profil (Agent 3) bewertet Abo-Modelle für diese App explizit als schwer rechtfertigbar bei minimalistischem Scope. Calm (~69€/Jahr) und Headspace (~12,99€/Monat) erzielen ihre Abo-Rechtfertigung durch Feature-Breite, die bewusst nicht gebaut werden soll. Ein Abo wäre hier ein Widerspruch zur Produkt-Philosophie und würde Vertrauen kosten.

**Begründung (Daten):**
Zielgruppen-Report nennt 1,99–4,99 € als Preis-Sweetspot für Einmalkäufe in dieser Kategorie. Wellness-Apps erzielen laut Business of Apps 2024 (Proxy) ~5–10 % zahlende Nutzer bei Freemium — bei einem Einmalkauf-Modell ist die Conversion-Rate typischerweise niedriger, der Revenue-per-Paying-User aber höher. iOS-Nutzer zeigen laut Sensor Tower State of Gaming 2026 (via games.gg) überproportionale Zahlungsbereitschaft vs. Android — stützt iOS-First-Launch.

**Erwartete Einnahmen-Aufteilung:**
⚠️ Quantitative Revenue-Prognose ist auf Basis der vorliegenden Daten nicht seriös möglich — der Competitive-Report vermerkt explizit fehlende Revenue-Daten für Nischen-Apps. Folgende Orientierungswerte aus verfügbaren Proxies:
- Realistische Nutzerzahl Nische: 6-stellig (Competitive-Report: "siebenstellig schwierig ohne Viral-Mechanik")
- Bei 100.000 Downloads, 7 % zahlend, 2,99 € Ø-Revenue: ~**20.000 € Einmalertrag** (Schätzung, keine belastbare Primärquelle)
- Diese App ist kein Revenue-Monster — sie ist ein Qualitäts- und Reputationsprodukt

---

## Session-Design

**Ziel-Dauer:** 3–8 Minuten pro Session (entspricht exakt der Länge einer vollständigen 4-7-8 oder Box-Breathing-Runde bei typischer Wiederholungszahl)

**Frequenz:** 1–2 Sessions pro Tag, Schwerpunkt unter der Woche (Stresskontext Beruf), Nutzungsspitzen morgens und abends

**Begründung:**
Zielgruppen-Report (Agent 3) gibt 3–8 Minuten als Session-Länge für Wellness-Apps an, gestützt auf Headspace-Nutzungsdaten (2023). Dies deckt sich präzise mit der technischen Länge der drei geplanten Übungen. Die Wochenminuten-Anzeige ist damit kein willkürliches Feature, sondern spiegelt reales Nutzungsverhalten: Bei 5 Sessions à 5 Minuten = 25 Minuten/Woche — ein sichtbarer, motivierender Wert ohne Gamification-Druck.

---

## Tech-Stack Tendenz

**Empfehlung:** React Native oder Flutter, lokaler Storage via AsyncStorage (React Native) oder Hive/SharedPreferences (Flutter). Keine externen Dependencies für Core-Funktionalität. Kein Backend, keine Authentifizierungs-Library, kein Analytics-SDK im Basis-Build.

**Begründung:**
Die Offline-First-Anforderung der CEO-Idee ist technisch trivial umsetzbar und der einzige datenrelevante Faktor hier ist die Plattformverteilung: iOS ~55 %, Android ~45 % (Zielgruppen-Report, iOS-Proxy für westliche Wellness-Märkte). Cross-Platform-Framework (React Native/Flutter) ermöglicht Single-Codebase für beide Stores und reduziert Build-Aufwand ohne Offline-Kapazität zu opfern. Ein nativer Swift/Kotlin-Ansatz ist technisch überlegen, aber für diesen Funktionsumfang nicht gerechtfertigt. Der vollständige Verzicht auf Analytics-SDKs ist konsistent mit dem No-Account-Versprechen und eliminiert ATT-Friction auf iOS (Apple iOS 14+ Policy, referenziert in Trend-Report).

---

## Abweichungen von der CEO-Idee

Die CEO-Idee ist in allen Kernpunkten mit den Recherche-Daten kompatibel. Es gibt keine fundamentalen Widersprüche — jedoch zwei Ergänzungsempfehlungen und einen Hinweis:

**[Monetarisierung]: Nicht definiert in CEO-Idee → Einmaliger Unlock empfohlen**
Die CEO-Idee enthält keine Monetarisierungsstrategie ("kein Backend, kein Account" schließt Abo-Infrastruktur de facto aus). Die Recherche legt Einmalkauf oder Freemium+Einmalig-Unlock nahe. Ohne Monetarisierung ist die App ein reines Goodwill-Produkt — legitim, aber explizit entscheidungsbedürftig.

**[Übungsauswahl — Anzahl]: 3 Techniken → Bestätigt, aber Erweiterbarkeit einbauen**
Drei Techniken (4-7-8, Box Breathing, Einfaches Beruhigen) sind als Start ideal. Prana Breath verliert laut Competitive-Report Nutzer durch Überkomplexität ("zu kompliziert für den Alltag"). Drei ist die richtige Zahl. Empfehlung: Architektonisch eine vierte Technik als zukünftigen Unlock vordenken (z. B. Wim Hof Light oder Kohlenhydrat-Atmung) — ohne sie jetzt zu bauen.

**[Scope-Hinweis — Wochenstatistik]: Feature bestätigt, aber Framings entscheidet**
"Wie viele Minuten du diese Woche geübt hast" ist ein bewusst gewähltes, nicht-druckvolles Framing. Dieser Framing-Entscheid ist strategisch richtig (Competitive-Report Gap 4) und muss in der UI-Textur konsequent gehalten werden: kein Verlust-Framing ("Du hast heute noch nicht geübt"), kein Streak-Zähler, nur positive Akkumulation. Dies ist keine Abweichung, sondern eine Implementierungsempfehlung mit strategischer Relevanz.

---

## Stärken des Konzepts (datenbasiert)

**Stärke 1 — Nischen-Lücke ist real und identifiziert.**
Der Competitive-Report bewertet die Kombination Offline-First + Kein Account + Minimalistisches UI + Aktive Pflege als "niedrig gesättigt" — Oak belegt die Nische, bedient sie aber nicht mehr. Dies ist kein generisches "Whitespace"-Argument, sondern ein konkret belegtes Sleepy-Incumbent-Szenario. Die CEO-Idee trifft exakt diese Lücke.

**Stärke 2 — Strukturelle Kostenvorteile durch No-Backend-Architektur.**
Trend-Report (Agent 1) benennt explizit: kein Server-Overhead, keine DSGVO-Audit-Pflicht für personenbezogene Daten, keine ATT-Friction auf iOS. Das ist kein Marketing-Merkmal — es ist ein operativer Vorteil, der die App dauerhaft wartungsarm hält und das Vertrauensversprechen gegenüber datensensiblen Nutzern (DACH, Europa) einlösbar macht.

**Stärke 3 — Session-Design passt präzise auf das Zielgruppenverhalten.**
3–8 Minuten Ziel-Session-Länge (Zielgruppen-Report, Headspace-Proxy 2023) entspricht der technischen Länge der drei geplanten Übungen. Das ist keine Konstruktion — die Übungen und das Nutzungsverhalten der Zielgruppe sind nativ kompatibel. Es braucht kein künstliches Retention-Design, weil die Übung selbst die natürliche Session-Länge definiert.

---

## Risiken und offene Fragen

**Risiko 1 — Markgröße der Nische quantitativ unklar (Hoch)**
Der Competitive-Report vermerkt explizit: siebenstellige Nutzerzahlen "schwierig ohne Monetarisierungs- oder Viral-Mechanik". Exakte Download-Zahlen für Breathwrk, Oak und Prana Breath waren nicht verfügbar. Die tatsächliche Größe des adressierbaren No-Account-Nischen-Segments ist nicht quantifizierbar auf Basis der vorliegenden Daten. Empfehlung: Soft-Launch mit ASO-Test vor größerer Marketing-Investition.

**Risiko 2 — Monetarisierungsentscheid steht aus (Hoch, CEO-Entscheidung)**
Ohne Monetarisierungsstrategie ist die App ein Goodwill-Produkt. Option A (Paid) vs. Option B (Freemium+Unlock) haben unterschiedliche Implikationen für Download-Volumen und Revenue — beide sind mit den Recherche-Daten kompatibel, aber die Entscheidung gehört zum CEO.

**Risiko 3 — ASO-Potential unklar (Mittel)**
Kein Suchanfragen-Volumen für "breathing app", "4-7-8 app" oder ähnliche Keywords war in den Recherche-Ergebnissen verfügbar (Competitive-Report, Datenlücken-Tabelle). App-Store-Optimierung ist für eine No-Marketing-Budget-App der primäre Akquisitionskanal — das Potential ist nicht quantifizierbar.

**Risiko 4 — Nutzer-Beschwerden gegen Wettbewerber sind Schätzungen (Niedrig)**
Die im Competitive-Report zitierten Nutzer-Zitate ("Ich zahle 70€ im Jahr, nutze aber nur die 2-Minuten-Atemübung") basieren auf Schätzungen, nicht auf verifizierter Review-Analyse. Die Gap-Hypothesen sind qualitativ plausibel und durch Produktlogik gestützt, aber nicht durch echte Review-Mining-Daten abgesichert. Empfehlung: App-Store-Review-Analyse der Konkurrenz vor Launch als validierender Schritt.

**Offene Frage — Langzeit-Retention ohne Social Layer (Mittel)**
Die App hat bewusst keinen Social-Layer, keine Community, keine Notifications. Das ist philosophisch richtig. Die offene Frage: Wie oft kehren Nutzer nach 30 Tagen zurück, wenn es keine externen Retention-Trigger gibt? Die Wochenminuten-Anzeige ist der einzige Habit-Loop-Anker. Ob dieser ausreicht, lässt sich erst durch echte D30-Retention-Daten beantworten — nicht durch die vorliegenden Reports.

---

*Concept Brief erstellt auf Basis: Trend-Report (Agent 1), Competitive-Report (Agent 2), Zielgruppen-Profil (Agent 3). Alle Aussagen rückgebunden auf jeweilige Datenquellen und Schätzungs-Markierungen der Ursprungs-Reports. Finale Produktentscheidungen liegen beim CEO.*