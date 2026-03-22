# Legal-Research-Report: Minimalistische Atem-Übungs-App

**Erstellt:** Juni 2025
**Basis:** Concept Brief + Web-Recherche-Ergebnisse (Juni 2025)
**Status:** KI-basierte Ersteinschätzung — keine rechtsverbindliche Beratung

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Relevanz-Einschätzung | Priorität |
|---|---|---|---|
| 1 | Monetarisierung & App-Store-IAP-Regeln | Einmalkauf/Unlock berührt Plattform-Richtlinien | 🟡 Mittel |
| 2 | App Store Richtlinien (Apple/Google) | Direkt relevant für Distribution und IAP | 🟡 Mittel |
| 3 | AI-generierter Content — Urheberrecht | Nur relevant falls Assets KI-generiert | 🟡 Bedingt |
| 4 | Datenschutz (DSGVO / COPPA) | Offline-First reduziert Risiko stark, aber nicht auf null | 🟢 Niedrig (mit Bedingungen) |
| 5 | Jugendschutz (USK / PEGI / IARC) | Pflicht-Rating für App-Store-Distribution | 🟢 Niedrig |
| 6 | Social Features | Keine Social Features geplant | ⚪ Nicht relevant |
| 7 | Markenrecht — Namenskonflikt | App-Name noch unbekannt, generelles Risiko | 🟡 Mittel |
| 8 | Patente | Atemtechniken nicht patentierbar, UI-Pattern Grauzone | 🟢 Niedrig |
| 9 | Medizinrecht / Gesundheitsclaims | Atemübungen im Health-Kontext, Werbeaussagen | 🔴 **Hoch** |

> **Neu hinzugefügtes Rechtsfeld #9 (Medizinrecht):** Das Concept Brief enthält implizite Gesundheitsversprechen ("Beruhigen", Stressreduktion). Dieses Feld fehlt im vorgegebenen Template, ist aber für diese App das höchste rechtliche Risiko und wird daher ergänzt.

---

## 1. Monetarisierung & Glücksspielrecht

### Aktuelle Gesetzeslage
**Glücksspielrecht: Nicht relevant.**
Die App enthält keinerlei Glücksspielelemente (keine Lootboxen, keine zufälligen Belohnungen, keine virtuellen Währungen). Das Monetarisierungsmodell — Einmalkauf (Option A) oder kostenloser Download mit Einmalig-Unlock (Option B) — fällt eindeutig außerhalb des Geltungsbereichs von Glücksspielgesetzen in allen relevanten Märkten (EU, USA, DACH). Keine regulatorische Grauzone vorhanden.

### IAP-Compliance (Einmalig-Unlock, Option B)
Sofern Option B gewählt wird, gilt:

**Apple App Store:** In-App Purchases für digitale Inhalte/Features müssen über Apples StoreKit-System abgewickelt werden. Apple behält 15–30 % Provision (15 % für umsatzschwache Entwickler unter dem Small Business Program, Schwelle: <1 Mio. USD/Jahr App Store Revenue). Ein "Unlock weiterer Übungen oder erweiterter Statistik" ist ein klassisches **Non-Consumable IAP** — einmalig kaufbar, auf Gerät persistent, muss auf allen Geräten desselben Apple-Accounts wiederherstellbar sein (*Restore Purchases*-Funktion ist Pflicht laut Apple-Richtlinien).

**Google Play Store:** Analog: Google Play Billing API ist Pflicht für digitale Inhalte. Provision ebenfalls 15–30 %. Seit 2022 erlaubt Google unter bestimmten Bedingungen alternative Zahlungsmethoden in einigen Ländern (Pilot-Programme), aber für eine Standard-App ist Google Play Billing der sichere Weg.

### Länderspezifisch

| Markt | Besonderheit |
|---|---|
| **EU / DACH** | Kein Glücksspiel-Bezug. Consumer-Rights-Richtlinie 2011/83/EU relevant für digitale Güter: Nutzer müssen vor Kauf über Konditionen informiert werden. Bei Einmalkauf: 14-tägiges Widerrufsrecht, das aber bei sofort nutzbaren digitalen Inhalten entfällt, wenn Nutzer explizit zustimmt. |
| **USA** | Federal Trade Commission (FTC): Preistransparenz-Anforderungen. Keine Besonderheiten für dieses Modell. |
| **China** | ⚠️ Datenpunkt fehlt: App-Distribution in China erfordert eine ICP-Lizenz und lokale Compliance-Maßnahmen. Da China im Concept Brief nicht als Zielmarkt genannt wird, hier nicht weiter vertieft. |
| **Niederlande / Belgien** | Lootbox-spezifische Gesetze greifen nicht — kein zufallsbasiertes Element vorhanden. |

### Relevanz für dieses Konzept
🟢 **Niedrig-Mittel.** Das Monetarisierungsmodell ist rechtlich unkompliziert. Die einzige handlungspflichtige Anforderung ist die technische Implementierung von *Restore Purchases* bei Option B (IAP). Kein anwaltlicher Beratungsbedarf, aber sorgfältige technische Umsetzung erforderlich.

### Quellen
- Apple App Store Review Guidelines (developer.apple.com, aktuell 2025)
- twinr.dev: "IOS In-App Purchase Compliance: Full Guide For 2025"
- Google Play Billing Policy (play.google.com/about/monetization-ads/, Stand 2025)

---

## 2. App Store Richtlinien

### Apple App Store
**Relevante Regeln für dieses Konzept:**

**2.1 — App Completeness:** Die App muss bei Einreichung vollständig funktionsfähig sein. Da alle Features offline laufen, entfällt das Risiko von Server-abhängigen Features, die beim Review nicht funktionieren.

**3.1.1 — In-App Purchase:** Alle digitalen Inhalte/Funktions-Unlocks müssen über Apple IAP abgewickelt werden. Kein Workaround über externe Zahlungslinks (seit Epic v. Apple-Urteil 2024 in den USA leicht gelockert, aber für europäische Märkte weiterhin strikte Durchsetzung). ⚠️ **Wichtig:** Das DMA (Digital Markets Act) der EU zwingt Apple seit März 2024 zur Öffnung für alternative App Stores in der EU — für eine Standard-Distribution über den offiziellen App Store ändert sich für diese App nichts, aber es ist ein sich entwickelndes Rechtsfeld.

**5.1.1 — Data Collection and Storage:** Apples Datenschutz-Anforderungen. Da keine personenbezogenen Daten erhoben werden, ist das **App Privacy Nutrition Label** ("Privacy Details" im App Store Connect) entsprechend auszufüllen: alle Kategorien auf "Not Collected" setzen. Das ist ein positiver Differentiator im App Store — Nutzer sehen explizit "No Data Collected".

**ATT (App Tracking Transparency, iOS 14.5+):** Da kein Analytics-SDK und kein Tracking geplant ist, entfällt der ATT-Prompt vollständig. Das ist ein UX-Vorteil (kein störendes Permission-Popup beim ersten Start).

**HealthKit-Integration:** Falls in zukünftigen Versionen eine HealthKit-Integration erwogen wird (z. B. Atemfrequenz in Apple Health schreiben), gelten zusätzliche Datenschutz-Anforderungen (Guideline 5.1.1(ix)). Für die aktuelle Version: nicht relevant.

### Google Play Store
**Data Safety Section:** Analog zu Apples Privacy Nutrition Label muss im Play Store die "Data Safety"-Sektion ausgefüllt werden. Bei vollständiger Offline-Funktionalität ohne Datenerhebung: alle Felder auf "No data collected/shared" — ebenfalls ein Vertrauensmerkmal.

**Permissions:** Keine Permissions erforderlich für diese App (kein Mikrofon, keine Kamera, kein Location, kein Internet). Minimalste Permission-Anforderung ist positiv für Review und Nutzervertrauen.

**Target API Level:** Google schreibt aktuell vor, dass Apps mindestens API Level 35 (Android 15, Stand 2025) targeten müssen für neue App-Einreichungen. Technische Anforderung, kein Rechtsrisiko.

### Relevanz
🟡 **Mittel.** Keine Showstopper-Risiken, aber mehrere handlungspflichtige Punkte: Privacy Nutrition Label korrekt ausfüllen, Restore-Purchases implementieren (Option B), DMA-Entwicklung beobachten. Kein anwaltlicher Bedarf, aber sorgfältige Umsetzung durch den Entwickler.

### Quellen
- Apple App Store Review Guidelines (developer.apple.com, 2025)
- LinkedIn/Sonu Dhankhar: "App Store Policy Updates 2025: Impact on Monetization & Ads" (2025)
- twinr.dev: "IOS In-App Purchase Compliance" (2025)

---

## 3. AI-generierter Content — Urheberrecht

### Aktuelle Rechtslage (2025)
Die Rechtslage hat sich 2025 konkretisiert:

**USA:** Das U.S. Copyright Office hat in Part 2 seines AI-Reports (29. Januar 2025) und einem Folgedokument (9. Mai 2025) klargestellt: **Rein KI-generierte Werke sind nicht urheberrechtsfähig.** Werke mit "sufficient human authorship" können geschützt sein — die Grenze ist unklar und wird durch laufende Gerichtsverfahren definiert. *Reuters Legal* (März 2026, vorausschauender Datenpunkt aus Web-Ergebnissen): Fair-Use-Argumente für KI-Training sind schwächer, wenn KI-Outputs direkt mit lizenzierten Inhalten auf dem Markt konkurrieren.

**EU:** Die KI-Verordnung (AI Act, gültig ab 2024/2025) und bestehende EU-Urheberrechtsrichtlinie 2019/790 decken KI-generierte Inhalte nicht explizit als schützbar ab. Richtung: ähnlich USA, menschliche Schöpfungshöhe erforderlich.

**Praxisrelevanz für diese App:**
Dies ist **bedingt relevant** — abhängig davon, ob KI-generierte Assets eingesetzt werden:

| Asset-Typ | KI-Einsatz wahrscheinlich? | Rechtliches Risiko |
|---|---|---|
| Kreis-Animation | Eher manuell/programmatisch | Niedrig |
| Icon / Splash-Screen | Möglicherweise KI-generiert | 🟡 Mittleres Risiko |
| Hintergrundmusik / Sounds | Möglicherweise KI-generiert | 🟡 Mittleres Risiko |
| UI-Texte, Beschreibungen | Möglicherweise KI-unterstützt | Niedrig (kein Schutzproblem bei Texten) |

**Konkretes Risiko:** Wer KI-generierte Assets verwendet, kann daran **kein eigenes Urheberrecht** geltend machen — das bedeutet: Dritte könnten dieselben Assets theoretisch verwenden, und der Entwickler hat keinen Schutzanspruch. Umgekehrt besteht das Risiko, dass KI-Tools auf urheberrechtlich geschütztem Material trainiert wurden (Midjourney, Suno etc.) — hier laufen in den USA noch Sammelklagen (Getty Images v. Stability AI u. a.).

### Kommerzielle Nutzung
Für KI-generierte Sounds/Musik gilt: Plattformen wie Suno oder Udio erlauben kommerzielle Nutzung ihrer Outputs, schließen aber Haftung für Trainingsdaten-Ansprüche Dritter aus. **Empfehlung:** Für eine kommerzielle App (auch Einmalkauf) entweder lizenzfreie Human-Made-Assets (z. B. Pixabay, Freesound mit CC0-Lizenz) oder explizit kommerziell lizenzierte KI-Tools mit Indemnification-Klausel verwenden.

### Relevanz für dieses Konzept
🟡 **Bedingt relevant.** Wenn keine KI-generierten Assets verwendet werden: **nicht relevant.** Wenn KI-Assets eingesetzt werden: klare Lizenzprüfung vor Launch erforderlich. Kein anwaltlicher Bedarf bei sorgfältiger Asset-Auswahl, aber Dokumentation der Quellen empfohlen.

### Quellen
- U.S. Copyright Office: "Copyright and Artificial Intelligence" (copyright.gov, Part 2: 29. Januar 2025; Folgedokument: 9. Mai 2025)
- Reuters Legal: "Copyright Law in 2025: Courts begin to draw lines around AI training" (16. März 2026)
- MichaelBest.com: "AI + Copyright: What Every Business Needs to Know in 2025"

---

## 4. Datenschutz (DSGVO / COPPA)

### DSGVO-Anforderungen
**Grundsatz:** Die DSGVO gilt für die Verarbeitung personenbezogener Daten von EU-Bürgern, unabhängig vom Unternehmenssitz. "Verarbeitung" umfasst Erheben, Speichern, Übermitteln.

**Für diese App — Offline-First-Architektur:**

Das Concept Brief beschreibt eine App **ohne Backend, ohne Account, ohne Analytics-SDK, ohne Datenübermittlung.** Die Wochenminuten werden lokal auf dem Gerät gespeichert (AsyncStorage / SharedPreferences). Das bedeutet:

> **Wenn ausschließlich lokal gespeichert wird und keine Daten das Gerät verlassen, greift die DSGVO praktisch nicht** — es gibt keinen Verantwortlichen, der personenbezogene Daten "verarbeitet" im Sinne des Art. 4 DSGVO, weil keine Übermittlung an Dritte oder den Entwickler stattfindet.

**Aber — drei Restrisiken:**

| Restrisiko | Erläuterung | Handlungspflicht |
|---|---|---|
| **App Store Distribution** | Apple/Google erheben Nutzungsdaten (Downloads, Crashes). Der Entwickler hat darauf keinen Einfluss, aber technisch ist die App nicht vollständig "datenfrei". | Keine Pflicht des Entwicklers, aber in Datenschutzerklärung erwähnen. |
| **Crash-Reporting** | Falls das Framework (React Native / Flutter) automatisch Crash-Reports sendet (z. B. via Firebase Crashlytics, wenn eingebunden): DSGVO-relevant. | Kein Crash-Reporting-SDK einbinden — oder explizit deaktivieren und dokumentieren. |
| **Datenschutzerklärung** | Beide App Stores **verlangen eine Datenschutzerklärung (Privacy Policy)** für jede App, unabhängig davon, ob Daten erhoben werden. | 🔴 **Pflicht:** Eine kurze, ehrliche Privacy Policy muss existieren. Inhalt: "Wir erheben keine Daten." Dies ist kein Widerspruch — es ist gerade die Stärke dieses Produkts. |

**Empfohlener Privacy-Policy-Inhalt (Kurzform):**
- Keine personenbezogenen Daten werden erhoben
- Keine Daten werden an Server übermittelt
- Alle Nutzungsdaten (Wochenminuten) verbleiben lokal auf dem Gerät
- Keine Analytics, keine Tracking-Tools
- Kontakt des Verantwortlichen (gesetzliche Pflicht, Art. 13 DSGVO)

**DSGVO-Artikel 13 (Informationspflicht):** Auch bei Nicht-Erhebung von Daten muss der Nutzer informiert werden — die Privacy Policy erfüllt diese Pflicht.

### COPPA (Children's Online Privacy Protection Act, USA)
**Zielgruppe 25–45 Jahre → COPPA nicht anwendbar.**

COPPA gilt für Apps, die sich an Kinder unter 13 Jahren richten oder wissentlich Daten von Kindern unter 13 erheben. Das Zielgruppen-Profil schließt Kinder explizit aus. Da zudem keine Daten erhoben werden, ist COPPA doppelt irrelevant.

**Im App Store:** Bei der IARC/Content-Rating-Einstufung (Google Play) und Apples eigener Einstufung wird die Zielgruppe als "4+" oder "Everyone" eingetragen — das löst automatisch COPPA-Compliance-Prüfungen aus, wenn "Made for Kids" angehakt wird. **Dieses Häkchen darf nicht gesetzt werden.** Die App richtet sich an Erwachsene — entsprechende Einstufung wählen.

### Relevanz für dieses Konzept
🟢 **Niedrig — mit einer klaren Handlungspflicht:** Privacy Policy erstellen und verlinken (App Store + In-App). Kein anwaltlicher Bedarf für die Basis-Version, aber die Privacy Policy sollte von einer juristisch versierten Person gegengelesen werden (Aufwand: minimal, da Inhalt minimal ist).

### Quellen
- gdprlocal.com: "GDPR Compliance for Apps: A 2025 Guide"
- didomi.io: "Essential guide to mobile app compliance in 2025"
- techgdpr.com: "Data protection digest 1-15 Jan 2025: mobile app permissions"
- EU DSGVO Art. 4, 13, 17 (eur-lex.europa.eu)

---

## 5. Jugendschutz (USK / PEGI / IARC)

### Einstufungskriterien
**IARC (International Age Rating Coalition):** Das automatisierte Rating-System, das von Google Play, Microsoft Store, Nintendo eShop und anderen Stores genutzt wird, fragt beim App-Einreichungsprozess einen Fragebogen ab. Für eine Atem-App ohne Gewalt, Sprache, sexuelle Inhalte, Horror, Glücksspiel oder In-App-Käufe für Kinder ist die Einstufung trivial.

**Apple App Store:** Nutzt ein eigenes System, kein IARC. Auch hier wird ein Fragebogen ausgefüllt. Ergebnis ebenfalls eindeutig.

**