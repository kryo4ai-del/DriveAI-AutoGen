# Legal-Research-Report: GrowMeldAI

**Erstellt:** Juni 2025
**Basis:** Concept Brief GrowMeldAI + Web-Recherche-Ergebnisse
**Status:** KI-basierte Ersteinschätzung — keine rechtsverbindliche Beratung

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Relevanz | Priorität |
|---|---|---|---|
| 1 | Monetarisierung & Glücksspielrecht | Freemium + Abo + Add-Ons | 🟢 Niedrig |
| 2 | App Store Richtlinien | iOS First, IAP, Subscriptions | 🟡 Mittel |
| 3 | AI-generierter Content — Urheberrecht | Pflanzenerkennung, Pflegeempfehlungen, KI-Output | 🟡 Mittel |
| 4 | Datenschutz (DSGVO / COPPA) | Standortdaten, Kamera, Nutzerprofil, ML-Training | 🔴 Hoch |
| 5 | Jugendschutz (USK / PEGI) | Keine Altersbeschränkungsindikatoren erkennbar | 🟢 Niedrig |
| 6 | Social Features — Auflagen | Bewusst nicht priorisiert in Phase 1 | 🟢 Nicht relevant (Phase 1) |
| 7 | Markenrecht — Namenskonflikt | "GrowMeldAI" — keine Vorregistrierung bekannt | 🟡 Mittel |
| 8 | Patente | Bilderkennungs-ML, Diagnose-Loop | 🟡 Mittel |
| 9 | Medizin-/Verbraucherschutzrecht | Pflanzengiftigkeit-Warnungen, Diagnoseempfehlungen | 🟡 Mittel |
| 10 | API-/Drittanbieter-Nutzungsrechte | Plant.id API, OpenWeatherMap, Firebase | 🟡 Mittel |

> ⚠️ **Hinweis zu Rechtsfeld 9 (Medizin-/Verbraucherschutzrecht):** Dieses Feld wurde im ursprünglichen Report-Template nicht aufgeführt, ist aber für GrowMeldAI konzeptspezifisch relevant und wurde daher ergänzt. Gleiches gilt für Rechtsfeld 10.

---

## 1. Monetarisierung & Glücksspielrecht

### Aktuelle Gesetzeslage

**🟢 Geringes Risiko für dieses Konzept.**

Das Monetarisierungsmodell von GrowMeldAI (Freemium + Jahres-Abo + Einmalkauf-Add-Ons) enthält **keine glücksspielähnlichen Mechaniken.** Loot Boxes, Zufallselemente, virtuelle Währungen oder Pay-to-Win-Mechaniken sind im Concept Brief nicht vorgesehen.

Die internationale Regulierungsdebatte zu Glücksspiel in Apps und Games konzentriert sich strukturell auf:
- **Zufallsbasierte Belohnungsmechanismen** (Loot Boxes, Gacha)
- **Virtuelle Währungen** mit unklarem Umtauschverhältnis
- **Pay-to-Win**-Mechaniken in kompetitiven Kontexten

Keines dieser Elemente ist in GrowMeldAI konzeptionell angelegt.

### Länderspezifisch

**EU:**
Das Europäische Parlament hat im Oktober 2025 neue Maßnahmen zum Schutz Minderjähriger diskutiert, die u.a. ein Verbot glücksspielähnlicher Mechaniken (explizit: Loot Boxes) in für Minderjährige zugänglichen Spielen forderten. *(Quelle: Europäisches Parlament, Pressemitteilung 20251013IPR30892, Oktober 2025)* — **Für GrowMeldAI nicht relevant**, da keine solchen Mechaniken vorhanden.

**Belgien / Niederlande:**
Beide Länder haben in der Vergangenheit Loot Boxes als Glücksspiel eingestuft (Belgien 2018, Niederlande 2019). Maßstab ist die **zufallsbasierte Wertzuteilung gegen Echtgeld.** GrowMeldAIs Add-Ons sind klar definierte Einmalkäufe mit transparentem Leistungsinhalt — kein Regulierungsrisiko erkennbar.

**USA:**
Keine bundesweite Loot-Box-Gesetzgebung. Einzelstaatliche Initiativen (z.B. Utah, Hawaii) haben keine abschließende Regulierung erreicht. FTC-Kompetenz greift bei irreführenden Handelspraktiken — bei transparentem Freemium-Modell kein direktes Risiko.

**China:**
Chinas Regulierung zu Loot Boxes (Offenlegungspflicht für Wahrscheinlichkeiten seit 2017) und Mindestalter-Regelungen für Gaming-Apps sind strikt. Da GrowMeldAI keine Glücksspiel-Elemente und keine Gaming-Klassifikation hat, ist das Risiko gering — **allerdings gelten in China separate App-Zulassungspflichten (ICP-Lizenz, Inhaltsgenehmigung), die einen Markteintritt komplex machen.** Dieser Aspekt liegt außerhalb des Glücksspielrechts und sollte bei China-Expansion separat geprüft werden.

### Relevanz für dieses Konzept

Das Freemium+Abo-Modell mit transparenten Einmalkäufen ist **regulatorisch das sauberste verfügbare Monetarisierungsmodell.** Kein Handlungsbedarf aus glücksspielrechtlicher Sicht, sofern das Konzept wie beschrieben umgesetzt wird.

**Handlungsempfehlung:** Sollten in späteren Phasen Gamification-Elemente (z.B. "Pflanzenpunkte", zufällige Belohnungen für Streak-Erhalt) eingeführt werden, ist eine Neubewertung erforderlich.

**Quellen:**
- Europäisches Parlament, Pressemitteilung IPR30892, Oktober 2025
- Reddit-Zusammenfassung EU-Loot-Box-Regulierungsdebatte, 2025
- esportslegal.news: "The USD 15 Billion Loot Box Challenge", Dezember 2025

---

## 2. App Store Richtlinien

### 🟡 Mittleres Risiko — konkrete Compliance-Anforderungen beachten

### Apple App Store

**Subscription-Modell (IAP-Pflicht):**
Apple verlangt für digitale Inhalte und Dienste zwingend die Nutzung des **In-App Purchase (IAP)-Systems.** Das bedeutet:
- Alle Abo-Transaktionen (monatlich + jährlich) müssen über Apple IAP abgewickelt werden
- Apple behält **15–30% Revenue Share** (15% für Abos nach dem ersten Jahr und für Entwickler mit < $1M Jahresumsatz im Small Business Program)
- Die im Concept Brief genannten Preispunkte (€4,99–€6,99/Monat, €29,99–€34,99/Jahr) sind **Endnutzerpreise inklusive Apple-Anteil** — die Nettomarge muss entsprechend kalkuliert werden

**Subscription-spezifische Anforderungen (App Store Review Guidelines, Abschnitt 3.1.2):**
- Klare Beschreibung des Abo-Inhalts vor Kaufabschluss
- Einfache Kündigungsoption (muss im App-eigenen Interface erklärt werden)
- Free-Trial-Regeln: Automatische Umwandlung in bezahltes Abo nur mit explizitem Nutzerhinweis
- **Preisangaben müssen lokal korrekt sein** (keine versteckten Konvertierungen)

**Freemium-Limit-Mechanik:**
Das "3–5 Scans/Monat"-Limit im Free-Tier muss klar kommuniziert werden. Apple toleriert Funktionsbeschränkungen im Free-Tier, aber **die App darf nicht so designt sein, dass sie ohne das Abo faktisch unbrauchbar ist** — dies kann zu Review-Ablehnung führen. Das beschriebene Free-Tier mit Basis-Pflanzenprofil und manuellen Erinnerungen scheint diese Grenze zu respektieren.

**KI-/Diagnose-Features:**
Apple hat keine spezifischen Richtlinien für Pflanzenerkennung-KI. Relevant wird Abschnitt 5.1 (Legal) wenn Diagnose-Outputs als medizinische oder sicherheitsrelevante Empfehlungen wahrgenommen werden könnten — **für Pflanzendiagnose kein direktes Risiko, aber für Giftigkeit-Warnungen (s. Rechtsfeld 9) beachtenswert.**

**Kamera-Zugriff:**
Muss explizit im App-Privacy-Label (Datenschutz-Nährwertkennzeichnung im App Store) deklariert werden. Usage-Description-Strings in der App müssen den Zweck klar beschreiben.

**Push Notifications:**
Das im Concept Brief beschriebene Design (Einwilligung im emotional hohen Moment nach erstem Pflegeplan) ist aus Apple-Sicht technisch korrekt — Apple erzwingt einen nativen Permission-Dialog. Der **Zeitpunkt** der Anfrage liegt in der Verantwortung des Entwicklers; die beschriebene Strategie ist Apple-konform.

### Google Play Store

**Für Phase 1 (iOS First) nachrangig, aber vorbereitend relevant:**

- Google Play Billing System ist äquivalent zu Apple IAP — gleiche Pflichtnutzung für digitale In-App-Inhalte
- **Google hat 2025 Richtlinien zu "Subscription Cancellation" verschärft:** Nutzer müssen Abos direkt in der App kündigen können (nicht nur über Play Store-Einstellungen)
- Datenschutz-Sektion im Play Store (Data Safety Section) erfordert detaillierte Angaben zu erhobenen Daten — äquivalent zu Apples Privacy Nutrition Label
- **Wichtig:** Googles Billing-Policy erlaubt seit 2024/2025 in bestimmten Märkten alternative Payment-Systeme (Folge des Epic-Urteils und regulatorischer Druck) — dies ist komplex und für den MVP nicht empfohlen

### Relevanz

**Konkrete Handlungsempfehlungen:**
1. Subscription-Preiskalkulation muss Apple-Revenue-Share (15–30%) von Anfang an einkalkulieren
2. Free-Trial-Implementierung (falls geplant) muss Apple StoreKit 2-konform implementiert werden — Twinr-Compliance-Guide empfiehlt explizit StoreKit-native Implementation *(Quelle: twinr.dev/blogs/ios-in-app-purchase-compliance, 2025)*
3. Privacy Nutrition Label muss Kamera-Nutzung, Standortdaten (für Wetter), Nutzungsverhalten vollständig abbilden
4. App-Review-Einreichung sollte Diagnose-Features mit klarem Disclaimer versehen (kein Ersatz für botanische Fachberatung)

**Quellen:**
- Apple App Store Review Guidelines (developer.apple.com/app-store/review/guidelines/, aktuell 2025)
- twinr.dev: "iOS In-App Purchase Compliance: Full Guide For 2025"
- LinkedIn/Dhankhar: "App Store Policy Updates 2025: Impact on Monetization", 2025

---

## 3. AI-generierter Content — Urheberrecht

### 🟡 Mittleres Risiko — differenzierte Betrachtung nach Content-Typ

### Aktuelle Rechtslage

Die urheberrechtliche Lage zu KI-generiertem Content ist **2025 noch in aktiver Entwicklung**, insbesondere in den USA und der EU.

**USA:**
Drei US-Bundesdistriktgerichte haben 2025 begonnen, Grenzen für Fair Use bei KI-Training zu ziehen. Zentrale Tendenz: **Fair-Use-Argumente sind schwächer, wenn KI-Output direkt mit urheberrechtlich geschütztem Content in Lizenzierungsmärkten konkurriert.** *(Quelle: Reuters/practicelaw, März 2026; IPWatchdog, Dezember 2025)*

Das U.S. Copyright Office hat im Bericht "Copyright and Artificial Intelligence" festgehalten: **Rein KI-generierte Inhalte ohne menschliche kreative Mitwirkung sind in den USA nicht urheberrechtlich schutzfähig** — d.h. GrowMeldAI kann KI-generierte Pflegetexte nicht selbst als urheberrechtlich geschütztes Asset schützen, aber auch Dritte können sie nicht schützen.

**EU:**
Der EU AI Act (in Kraft seit 2024, schrittweise Anwendung bis 2026) enthält Transparenzpflichten für KI-Systeme. Für Pflanzenerkennung-Apps gelten diese als **"Minimal Risk"-Systeme** — keine spezifischen AI Act-Hochrisikopflichten. Jedoch gilt: KI-Training auf urheberrechtlich geschützten Bilddaten unterliegt der **EU Text and Data Mining Exception (DSM-Richtlinie Art. 4)**, die kommerzielle Nutzung von opt-out-geschützten Daten einschränkt.

### Für GrowMeldAI relevante Content-Kategorien

**1. Pflanzenerkennung (KI-Output: Pflanzenname, Klassifikation)**
Botanische Klassifikationen sind **nicht urheberrechtlich schutzfähig** (Fakten sind gemeinfrei). Kein Urheberrechtsrisiko für den Output selbst.

**2. Pflegeempfehlungen (KI-generierter Text)**
Generische Pflegehinweise (Gießfrequenz, Lichtbedarf) basieren auf faktischen Informationen — gemeinfrei. **Risiko entsteht, wenn Pflegetexte aus urheberrechtlich geschützten Quellen (Büchern, Datenbanken) ohne Lizenz trainiert wurden.** Plant.id API: Der Anbieter trägt die Verantwortung für die Rechtmäßigkeit seiner Trainingsdaten — **GrowMeldAI sollte vertraglich sicherstellen, dass Plant.id eine entsprechende Zusicherung gibt.**

**3. Eigene Trainingsdaten (Nutzer-Uploads)**
Das Concept Brief sieht vor, Nutzer-Uploads für ML-Training zu verwenden. Dies erfordert:
- **Explizite DSGVO-konforme Einwilligung** der Nutzer (s. Rechtsfeld 4)
- Klare AGB-Formulierung zu Nutzungsrechten an hochgeladenen Fotos
- Nutzer-Fotos sind urheberrechtlich geschüt