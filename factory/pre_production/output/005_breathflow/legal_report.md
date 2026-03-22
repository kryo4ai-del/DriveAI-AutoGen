# Legal-Research-Report: Minimalistische Atem-Übungs-App

> **Scope-Hinweis:** Dieser Report bewertet die rechtliche Lage für eine offline-first, account-freie Atemübungs-App (iOS/Android) mit optionalem Tip-IAP, Zielmarkt DACH/UK/USA, Zielgruppe 25–45 Jahre. Die Bewertung basiert auf den bereitgestellten Web-Recherche-Ergebnissen sowie dem allgemeinen Wissensstand bis Frühjahr 2026. Fehlende Primärquellen sind explizit markiert.

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Relevanz für dieses Konzept | Risiko-Ampel |
|---|---|---|---|
| 1 | Monetarisierung & Glücksspielrecht | Tip-IAP als Modell; keine Loot Boxes, keine randomisierten Mechaniken | 🟢 Niedrig |
| 2 | App Store Richtlinien (Apple / Google) | IAP-Pflicht, Tip-Jar-Klassifikation, Offline-Compliance | 🟡 Mittel |
| 3 | AI-generierter Content — Urheberrecht | Potenzielle Nutzung KI-generierter Assets (Animation, Texte) | 🟡 Mittel |
| 4 | Datenschutz (DSGVO / COPPA) | Lokaler Storage, keine Datenübertragung, Zielgruppe Erwachsene | 🟢 Niedrig – 🟡 Mittel |
| 5 | Jugendschutz (USK / PEGI / IARC) | IARC-Rating-Pflicht für Google Play, Apple eigenes System | 🟢 Niedrig |
| 6 | Social Features | Keine Social Features geplant | ⬛ Nicht relevant |
| 7 | Markenrecht — Namenskonflikt | App-Name noch nicht festgelegt; generische Naming-Risiken | 🟡 Mittel |
| 8 | Patente | Atemtechniken als Methoden; UI-Animationen | 🟢 Niedrig – 🟡 Mittel |
| 9 | Medizinrecht / Gesundheitsrecht | Atemübungen als Wellness vs. Medizinprodukt | 🟡 Mittel ⚠️ |

> **Zusätzliches Feld ergänzt:** Medizinrecht/Gesundheitsrecht (Feld 9) wurde gegenüber dem angeforderten Template hinzugefügt, da dieser Aspekt für eine Atemübungs-App mit dokumentierten therapeutischen Sekundärnutzern (Therapeuten, die die App als Hausaufgabe empfehlen) rechtlich material ist und im Template-Brief nicht explizit adressiert wurde.

---

## 1. Monetarisierung & Glücksspielrecht

### Aktuelle Gesetzeslage

Glücksspielrechtliche Regelungen im Kontext von Apps betreffen primär **Loot Boxes, randomisierte Belohnungsmechanismen und Pay-to-Win-Strukturen**. Das EU-Parlament hat im Oktober 2025 Maßnahmen gefordert, die gambling-ähnliche Mechaniken (insbesondere Loot Boxes) in für Minderjährige zugänglichen Diensten verbieten sollen. Die Umsetzung als verbindliches EU-Recht steht zum Zeitpunkt dieser Einschätzung noch aus — es handelt sich um eine parlamentarische Forderung, nicht um geltendes Recht.

Auf nationaler Ebene (DACH-Raum) bestehen unterschiedliche Regelungsintensitäten:
- **Deutschland:** GlüStV 2021 erfasst Glücksspiel im klassischen Sinne; Loot Boxes werden juristisch diskutiert, aber bislang nicht einheitlich als Glücksspiel klassifiziert
- **Österreich/Schweiz:** Vergleichbar restriktive Tendenzen, aber kein spezifisches App-Glücksspielrecht in Kraft

### Länderspezifisch

| Region | Relevante Regelung | Status |
|---|---|---|
| **EU (gesamt)** | EP-Forderung: Loot-Box-Verbot für Minderjährige | Nicht-bindendes Parlament-Statement, Oktober 2025 |
| **Belgien** | Loot Boxes seit 2018 als Glücksspiel klassifiziert | Geltendes Recht |
| **Niederlande** | Loot-Box-Regulierung, 2022 teilweise zurückgenommen | Komplexe Rechtslage |
| **USA** | Bundesrechtlich keine Loot-Box-Spezialregelung; einzelstaatliche Initiativen laufen | Keine bundesweite Regelung |
| **China** | Loot-Box-Disclosure-Pflicht seit 2017; randomisierte Mechaniken streng reguliert | Geltendes Recht |

### Relevanz für dieses Konzept

🟢 **Sehr niedrig.** Das Tip-IAP-Modell enthält **keinerlei randomisierte oder glücksspielähnliche Mechaniken**. Der Nutzer zahlt freiwillig einen festen Betrag ohne Gegenleistungsversprechen über das bestehende Produkt hinaus. Es gibt keine Loot Boxes, keine Währungssysteme, keine Belohnungsschleifen mit variabler Auszahlung. Selbst unter den striktesten EU-Definitionen (Belgien) wäre diese App nicht betroffen.

**Einzige Caveat:** Sollte das Modell in eine Richtung weiterentwickelt werden, die Gamification-Elemente mit monetären Anreizen kombiniert (z.B. "Schalte Premium-Atemführungen frei"), wäre eine erneute Prüfung erforderlich.

### Quellen
- Europäisches Parlament, Pressemitteilung "New EU measures needed to make online services safer for minors", 13. Oktober 2025 (europarl.europa.eu)
- siege.gg, "Several EU Countries Have Introduced Stricter Regulations on Loot Boxes in Games", 2025
- Reddit/r/gaming, EU Loot Box Regulierungsdiskussion, 2025 (als Hintergrundquelle, nicht rechtlich primär)

---

## 2. App Store Richtlinien

### Apple App Store

Die Apple App Store Review Guidelines (developer.apple.com, aktuell 2025) sind für dieses Konzept in mehreren Punkten relevant:

**IAP-Pflicht und Tip-Jar-Klassifikation:**
Apple erlaubt Tip-Jar-IAPs grundsätzlich, **aber mit einer kritischen Einschränkung:** Apple hat in der Vergangenheit Tip-Mechaniken abgelehnt oder Anpassungen gefordert, wenn diese nicht klar als freiwillige Unterstützung des Entwicklers deklariert waren, sondern als verschleierter Kauf von Funktionen oder Inhalten erschienen. Der Tip-Jar muss eindeutig als "Unterstützung für den Entwickler" kommuniziert werden — nicht als "Premium-Version" oder "Upgrade".

**Konkrete Anforderungen (Stand 2025):**
- Alle digitalen Käufe müssen über Apples IAP-System abgewickelt werden (keine externen Zahlungslinks innerhalb der App, mit begrenzten Ausnahmen nach dem EU Digital Markets Act)
- Apple behält 15–30% Provision (15% für kleinere Entwickler im Small Business Program)
- Eine kostenlose App mit ausschließlichem Tip-IAP muss klar kommunizieren, dass alle Funktionen kostenfrei bleiben

**Offline-Compliance:**
Keine bekannten Einschränkungen für vollständig offline betriebene Apps. Apple verlangt keine permanente Internetverbindung als technische Anforderung.

**Privacy Nutrition Label:**
Auch eine App, die nach eigenem Anspruch keine Daten sammelt, muss im App Store ein **Privacy Nutrition Label** ausfüllen. Bei ehrlicher Deklaration ("No data collected") ist dies unproblematisch — aber die Deklaration muss akkurat sein. Ein eingebundenes Crash-Reporting-SDK (z.B. Firebase Crashlytics) würde z.B. als "Diagnostics"-Datenerhebung deklarierungspflichtig.

⚠️ **Technischer Hinweis aus dem Concept Brief:** Das Konzept schließt Analytics-SDKs explizit aus. Dies ist Apple-konform und stärkt die Privacy-Label-Deklaration. Konsequent umsetzen.

### Google Play Store

**IARC-Rating-Pflicht:**
Google Play nutzt das IARC-System (International Age Rating Coalition). Jede App muss vor Veröffentlichung einen Rating-Fragebogen ausfüllen. Für eine Atemübungs-App ohne Gewalt, Suchtmechaniken oder Erwachseneninhalte ist eine **IARC-Einstufung "Alle Altersgruppen" (3+/Everyone)** zu erwarten — dies ist unkompliziert, aber obligatorisch.

**Play Billing:**
Analog zu Apple gilt: Alle IAP müssen über Google Play Billing abgewickelt werden. Google behält ebenfalls 15–30% Provision.

**EU Digital Markets Act (DMA) — Sonderfall:**
Seit 2024 müssen Apple und Google in der EU alternative Zahlungsmethoden unter bestimmten Bedingungen ermöglichen. Die praktische Umsetzung ist komplex und für einen kleinen Entwickler mit einem einfachen Tip-IAP voraussichtlich nicht relevant — aber rechtlich zu beobachten.

### Relevanz

🟡 **Mittel.** Nicht wegen inhaltlicher Risiken, sondern wegen **prozessualer Anforderungen**, die bei Missachtung zur App-Ablehnung führen:

1. Tip-Jar korrekt als Entwickler-Unterstützung deklarieren
2. Privacy Nutrition Label (Apple) korrekt und vollständig ausfüllen
3. IARC-Fragebogen (Google Play) korrekt beantworten
4. Keine externen Zahlungsaufforderungen in der App

### Quellen
- Apple Developer, App Store Review Guidelines, 2025 (developer.apple.com)
- twinr.dev, "iOS In-App Purchase Compliance: Full Guide For 2025" (Sekundärquelle)
- LinkedIn/Sonu Dhankhar, "App Store Policy Updates 2025: Impact on Monetization & Ads" (Sekundärquelle, März 2025)
- USK/IARC-Dokumentation (usk.de)

---

## 3. AI-generierter Content — Urheberrecht

### Aktuelle Rechtslage

Das U.S. Copyright Office hat in **Part 2 seines AI-Copyright-Reports (Januar 2025)** klargestellt: KI-generierte Outputs sind grundsätzlich **nicht urheberrechtlich schutzfähig**, wenn sie ohne ausreichende menschliche kreative Kontrolle entstanden sind. Menschliche Auswahl, Anordnung und Bearbeitung von KI-Outputs können jedoch zu partieller Schutzfähigkeit führen.

In der **EU** (und damit DACH) ist die Rechtslage vergleichbar, aber noch weniger harmonisiert: Der EU AI Act (in Kraft seit 2024) enthält Transparenzpflichten für KI-generierte Inhalte, adressiert Urheberschaft aber nur indirekt. Nationale Urheberrechte (deutsches UrhG, österreichisches UrhG) schützen grundsätzlich nur menschliche Schöpfungen.

**Für kommerzielle Nutzung (Reuters/Pracin, März 2026):** Fair-Use-Argumente werden schwächer bewertet, wenn KI-Outputs direkt mit lizenzierten Originalmärkten konkurrieren. Für einfache UI-Animationen (Kreis-Atemanimation) und App-Texte ist das Risiko niedrig — diese sind weder stilistisch einzigartig noch konkurrieren sie mit einem etablierten Lizenzmarkt.

### Kommerzielle Nutzung — Praktische Implikationen

Für dieses Konzept sind folgende Szenarien denkbar:

| Asset-Typ | KI-Einsatz möglich? | Rechtliches Risiko | Empfehlung |
|---|---|---|---|
| Kreis-Animations-UI | Ja (generiert oder manuell) | 🟢 Niedrig | Eigene Umsetzung, keine KI-Lizenz-Problematik |
| App-Store-Texte (Beschreibung) | Ja (KI-assistiert) | 🟢 Niedrig | Keine Drittrechte betroffen |
| App-Icon / Grafiken | Bedingt | 🟡 Mittel | Auf Lizenzbedingungen des KI-Tools achten (z.B. Midjourney Commercial License) |
| Hintergrundmusik / Sounds | Risikoreich | 🟡 Mittel | Lizenzierten Human-Komponisten bevorzugen oder explizit lizenzfreie KI-Musik (z.B. Suno Commercial) |
| Atemanleitungs-Texte | Ja | 🟢 Niedrig | Faktische Inhalte (Atemtechnik-Beschreibungen) sind ohnehin nicht schutzfähig |

### Relevanz

🟡 **Mittel** — nicht wegen hohem Risiko, sondern wegen **Dokumentationspflicht bei kommerziellem Einsatz:**

Wenn KI-Tools für Assets genutzt werden, sollten die jeweiligen **Nutzungsbedingungen des KI-Anbieters** geprüft und die kommerzielle Nutzungslizenz dokumentiert werden. Bei einem reinen Flutter/Code-Projekt mit manuell erstellten SVG-Animationen entfällt dieses Risiko vollständig.

### Quellen
- Reuters/Pracin, "Copyright Law in 2025: Courts begin to draw lines around AI training", 16. März 2026
- U.S. Copyright Office, "Copyright and Artificial Intelligence Part 2", 29. Januar 2025 (copyright.gov)
- U.S. Copyright Office, "Part 3: Generative AI Training" (Pre-Publication), 9. Mai 2025 (copyright.gov)

---

## 4. Datenschutz (DSGVO / COPPA)

### DSGVO-Anforderungen

Das Konzept beschreibt eine App, die:
- Kein Backend betreibt
- Keine Cloud-Daten sendet
- Nur lokal (SQLite/AsyncStorage) Wochenminuten speichert
- Kein Analytics-SDK einbindet

Unter dieser technischen Voraussetzung gilt:

**Positive Einschätzung:** Wenn **keinerlei personenbezogene Daten** erhoben, verarbeitet oder übertragen werden, greifen die DSGVO-Pflichten nur minimal. Der Wochenminuten-Counter auf dem Gerät des Nutzers speichert keine personenbezogenen Daten im DSGVO-Sinne — es sei denn, die App selbst überträgt oder verknüpft diese Daten mit einer Person. Bei reinem On-Device-Storage ohne Übertragung: kein DSGVO-Anwendungsfall im engeren Sinne.

**Kritische Punkte, die trotzdem beachtet werden müssen:**

1. **Privacy Policy ist dennoch Pflicht** — Apple und Google verlangen eine Privacy Policy für alle Apps im Store, auch wenn keine Daten gesammelt werden. Die Policy muss dann ehrlich deklarieren: "Diese App sammelt keinerlei Daten."

2. **Third-Party-SDKs:** Jedes eingebundene Framework (auch Flutter selbst, inkl. bestimmter Plugins) kann potenziell Gerätedaten übertragen. Sorgfältige Prüfung aller Dependencies auf Datenweitergabe ist erforderlich.

3. **Crash-Reporting:** Das Concept Brief schließt Crash-Reporting-Dienste mit Datenweitergabe explizit aus. Wenn dennoch ein Dienst genutzt wird (z.B. Apple's eigenes Crash-Reporting über das Entwickler-Dashboard): Prüfung ob dies als Datenübertragung im DSGVO-Sinne gilt.

4. **EU AI Act Transparenzpflicht** (falls KI-generierter Content in der App): Kennzeichnungspflicht für KI-generierte Inhalte ab bestimmten Schwellenwerten. Für eine Atemanimations-App unwahrscheinlich relevant, aber zu beachten falls KI-Sprachausgabe eingebunden wird.

**Datenschutz-Erklärung (Muster-Struktur für diese App):**
- Welche Daten werden erhoben: Keine
- Welche Daten werden lokal gespeichert: Anonyme Nutzungsstatistiken (Wochenminuten) — nur auf dem Gerät, nicht übertragen
- Drittanbieter: Keine
- Kontaktmöglichkeit des Verantwortlichen: Erforderlich (Name/E-Mail des Entwicklers)

### COPPA (Children's Online Privacy Protection Act — USA)

COPPA gilt für Apps, die sich **bewusst an Kinder unter 13 Jahren richten** oder **wissend Daten von Kindern unter 13 sammeln**.

Das Zielgruppen-Profil dieser App (25–45 Jahre) schließt Kinder als Primärzielgruppe explizit aus. Da zudem keine Daten gesammelt werden, ist COPPA selbst im hypothetischen Fall einer Minderjährigen-Nutzung nicht verletzt — es gibt keine Datenerhebung, die COPPA regulieren würde.

**Empfehlung:** In der App Store-Beschreibung und der Privacy Policy klar deklarieren: "Diese App richtet sich nicht an Kinder unter 13 Jahren."

### Relevanz

🟢 **Niedrig** — unter der Voraussetzung konsequenter technischer Umsetzung des No-Backend-Prinzips.

🟡 **Mittel** — für die **Dokumentationspflicht** (Privacy Policy, Store-Deklarationen) und die **Dependency-Prüfung** aller eingebundenen Libraries.

⚠️ **Die Privacy-Positionierung ist der stärkste USP des Konzepts. Ein technischer Fehler hier (z.B. unbemerktes SDK, das Daten überträgt) wäre gleichzeitig ein rechtliches UND ein Reputationsrisiko mit besonderer Schwere für diese spezifische Zielgruppe.**

### Quellen
- DSGVO Art. 4, 5, 6, 13 (keine direkten Suchtreffer,