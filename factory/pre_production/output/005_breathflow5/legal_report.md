# Legal-Research-Report: Minimalistische Atem-Übungs-App

**Erstellt:** Juni 2025
**Basis:** Concept Brief + Web-Recherche-Ergebnisse
**Status:** KI-basierte Ersteinschätzung — keine Rechtsberatung

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Relevanz | Priorität |
|---|---|---|---|
| 1 | Monetarisierung & App-Store-Regeln (IAP) | One-Time-Purchase über Store-System | 🟡 Mittel |
| 2 | App Store Richtlinien | Apple + Google Freemium/IAP-Konformität | 🟡 Mittel |
| 3 | AI-generierter Content | Kreis-Animationen, UI-Assets, ggf. Sounds | 🟡 Mittel |
| 4 | Datenschutz (DSGVO) | DACH-Primärmarkt, kein Backend — trotzdem relevant | 🟡 Mittel |
| 5 | Datenschutz (COPPA) | Zielgruppe 25–45, aber Store-seitige Pflichten | 🟡 Mittel |
| 6 | Jugendschutz (USK/PEGI/IARC) | App-Store-Rating-Pflicht | 🟢 Niedrig |
| 7 | Markenrecht / Namenskonflikt | App-Name noch unbekannt | 🟡 Mittel |
| 8 | Glücksspielrecht | Kein Glücksspielelement im Konzept | ⚫ Nicht relevant |
| 9 | Social Features | Keine sozialen Features im Konzept | ⚫ Nicht relevant |
| 10 | Patente | Atemtechniken + Kreis-Animation | 🟡 Mittel |
| 11 | Medizinprodukte-Regulierung | Gesundheitsbezogene App — EU MDR-Frage | 🔴 Hoch |

> ⚠️ **Neu identifiziertes Feld #11** (Medizinprodukte-Regulierung) wurde im Concept Brief nicht adressiert und ist für dieses Konzept das rechtlich kritischste Feld — Details unter Abschnitt 9.

---

## 1. Monetarisierung & Glücksspielrecht

### Glücksspielrecht
**Relevanz: ⚫ Nicht relevant — kurze Begründung:**
Das Konzept enthält kein Zufallselement, keine Loot-Boxes, keine virtuelle Währung und keinen Mechanismus, der einer Wette oder einem Glücksspiel ähnelt. One-Time-Purchase für deterministische Inhalte (zusätzliche Atemrhythmen, Visualisierungen, Sounds) fällt in keiner bekannten Jurisdiktion unter Glücksspielrecht. Dieses Feld ist für dieses Konzept strukturell ausgeschlossen.

### One-Time-Purchase — Verbraucherrecht & Steuer
**Aktuelle Lage:**
Ein Einmalkauf über Apple App Store oder Google Play Store löst folgende rechtliche Fragen aus:

- **EU-Verbraucherrecht (Richtlinie 2019/770 über digitale Inhalte):** Seit Januar 2022 in der EU in Kraft. Verbraucher haben bei digitalen Käufen Mängelgewährleistungsrechte. Für eine App bedeutet das: Wenn eine bezahlte Funktion dauerhaft nicht funktioniert, können EU-Nutzer Nacherfüllung oder Rückerstattung verlangen. Da die App vollständig clientseitig ist und keine Server-Abhängigkeiten hat, ist das Risiko eines "Ausfalls" gering — aber die Pflicht besteht.

- **Widerrufsrecht (EU):** Digitale Inhalte, die sofort nutzbar sind, können vom Widerrufsrecht ausgenommen werden — aber **nur wenn der Nutzer vor dem Kauf ausdrücklich zustimmt, dass das Widerrufsrecht erlischt** (Art. 16 lit. m Verbraucherrechterichtlinie). Apple und Google handhaben dies in ihren Store-Systemen weitgehend automatisch, aber die App sollte dies in ihrer Kaufbeschreibung klar kommunizieren.

- **USt./MwSt.:** Bei App-Store-Käufen wickelt Apple/Google die Steuer ab (Marketplace-Facilitator-Modell). Für den Entwickler entfällt die direkte USt.-Pflicht gegenüber dem Endnutzer in den meisten Märkten. ⚠️ Ausnahme: In manchen Jurisdiktionen außerhalb des EU/US-Mainstream können eigene Pflichten entstehen — bei Fokus auf DACH/UK/Nordamerika ist dies durch die Store-Systeme abgedeckt.

**Relevanz für dieses Konzept:** 🟡 Mittel
Die Kombination aus "dauerhaft kostenlos nutzbare Basis + optionaler IAP" ist gut etabliert und rechtlich unproblematisch — sofern klar kommuniziert wird, was kostenlos bleibt und was kostenpflichtig ist. Kritisch: Der Concept Brief beschreibt, dass **alle drei Kerntechniken dauerhaft kostenlos** bleiben. Das muss in App-Store-Beschreibung, Onboarding und Kaufdialog konsistent kommuniziert sein, um irreführende Werbung (§ 5 UWG, EU-Richtlinie 2005/29/EG über unlautere Geschäftspraktiken) zu vermeiden.

**Quellen:** EU-Richtlinie 2019/770 (digitale Inhalte, ab 01.01.2022); EU-Verbraucherrechterichtlinie 2011/83/EU Art. 16; UWG § 5 (DE)

---

## 2. App Store Richtlinien

### Apple App Store
**Aktuelle Lage (Stand: Apple App Review Guidelines, abgerufen Juni 2025):**

Für dieses Konzept relevante Regeln:

- **IAP-Pflicht (Guideline 3.1.1):** Digitale Inhalte, die innerhalb einer iOS-App freigeschaltet werden (z.B. zusätzliche Atemrhythmen, Visualisierungen), **müssen** über das Apple-IAP-System verkauft werden. Die Nutzung externer Zahlungssysteme für digitale In-App-Inhalte ist auf iOS nicht gestattet. ⚠️ Apple behält 15–30% der IAP-Einnahmen ein (15% für Entwickler mit < 1 Mio. USD Jahresumsatz im Small Business Program).

- **Health-App-Kategorie (Guideline 5.1.3 — Health & Fitness):** Apps, die Gesundheitsdaten verarbeiten oder gesundheitsbezogene Funktionen anbieten, unterliegen erhöhten Anforderungen. Da die App **nur lokale Daten speichert und keine Gesundheitsdaten im technischen Sinne (kein Herzfrequenz-Sensor, keine HealthKit-Integration)** nutzt, ist das Risiko hier niedrig. ⚠️ Aber: Apple prüft, ob eine App implizit medizinische Claims macht (→ Verbindung zu Abschnitt 9).

- **Offline-Funktionalität:** Keine spezifischen Einschränkungen. Vollständig offline nutzbare Apps sind richtlinienkonform.

- **Datenschutz-Nutrition-Label (Privacy Manifest, ab Frühjahr 2024 verpflichtend):** Apple verlangt eine vollständige Deklaration aller gesammelten Daten — auch wenn keine Daten gesammelt werden, muss dies explizit deklariert werden ("No data collected"). Das ist für dieses Konzept ein **Vorteil**: Der einfachste mögliche Privacy-Manifest-Eintrag, und er ist ein kommunizierbares Qualitätsmerkmal.

- **No-Account-Pflicht:** Apple verbietet es, Nutzer zur Account-Erstellung zu zwingen, um grundlegende App-Funktionen zu nutzen (Guideline 5.1.1). Das Konzept erfüllt diese Regel strukturell — die App braucht keinen Account.

**Relevanz:** 🟡 Die IAP-Integration muss korrekt implementiert sein. Der Rest ist konzeptionell richtlinienkonform.

### Google Play Store
**Aktuelle Lage (Stand: Google Play Policy, Juni 2025):**

- **IAP / Billing Policy:** Ähnlich wie Apple: Digitale In-App-Inhalte müssen über Google Play Billing abgewickelt werden (mit Ausnahmen für bestimmte Kategorien wie digitale Güter außerhalb der App — für dieses Konzept nicht relevant). Google behält ebenfalls 15–30% ein.

- **Post-Epic-Urteil / Alternative Billing:** In einigen Märkten (z.B. Südkorea, partiell EU nach DMA-Druck) gibt es Öffnungen für alternative Zahlungssysteme. Für DACH/UK/Nordamerika ist Google Play Billing weiterhin de facto Pflicht für digitale IAP-Inhalte. ⚠️ Die Rechtslage ist hier 2025 noch im Fluss (DMA-Durchsetzung durch EU-Kommission laufend) — für den Launch irrelevant, aber mittelfristig beobachtenswert.

- **Permissions / Privacy:** Google Play verlangt ebenfalls eine Data Safety Section. Für eine App ohne Netzwerk-Requests und ohne Analytics-SDKs ist diese Sektion minimal und positiv darstellbar.

- **Health & Fitness / Sensitive Categories:** Vergleichbar mit Apple — gesundheitsbezogene Apps werden genauer geprüft. Medizinische Claims können zur Ablehnung führen (→ Abschnitt 9).

**Quellen:** Apple App Review Guidelines (developer.apple.com, abgerufen Juni 2025); Google Play Developer Policy Center (play.google.com/about/developer-content-policy/, aktuell 2025); LinkedIn-Artikel "App Store Policy Updates 2025" (Sonu Dhankhar, LinkedIn Pulse 2025 — Hinweis: Nicht-primäre Quelle, nur als Orientierung)

---

## 3. AI-generierter Content — Urheberrecht

### Aktuelle Rechtslage
**USA (U.S. Copyright Office, Stand Januar/Mai 2025):**
Das U.S. Copyright Office hat in **Part 2 seines AI-Reports (veröffentlicht 29. Januar 2025)** klargestellt: Outputs, die ausschließlich durch generative KI ohne substanzielle menschliche kreative Kontrolle erzeugt wurden, sind in den USA **nicht urheberrechtlich schutzfähig**. Menschliche Auswahl, Anordnung und kreative Bearbeitung von AI-Outputs können jedoch Schutz begründen.

**Praktische Konsequenz für dieses Konzept:**
- **Schutz eigener AI-Assets:** Wenn die Entwickler AI-Tools nutzen, um z.B. Hintergrundklänge, Farbverläufe oder Animationskurven zu generieren, können diese Elemente in den USA nur dann urheberrechtlich geschützt sein, wenn substanzielle menschliche kreative Bearbeitung nachweisbar ist. Das schwächt den eigenen IP-Schutz.
- **Nutzung fremder AI-Outputs:** AI-generierte Assets von Dritten (z.B. Stock-Sound-Plattformen, die AI-Sounds lizenzieren) haben je nach Plattform und Nutzungsbedingungen unterschiedliche Lizenzen. **Lizenzprüfung für jeden verwendeten Asset ist Pflicht** — auch wenn der Asset "kostenlos" verfügbar ist.

**EU:**
Die EU-Urheberrechtslage zu AI-Outputs ist 2025 noch stärker im Fluss als in den USA. Der **EU AI Act (in Kraft seit August 2024)** enthält keine direkten Urheberrechtsregelungen, aber Erwägungsgrund 105 verweist auf bestehende EU-Urheberrechtsrichtlinien. Es gibt keine einheitliche EU-Rechtsprechung zur Schutzfähigkeit reiner AI-Outputs. Die Tendenz der Mitgliedstaaten folgt dem US-Grundsatz: Menschliche Schöpfungshöhe erforderlich.

**Reuters/Courts (2025, laufend):** Gerichte beginnen, Grenzen zu ziehen — insbesondere: Fair-Use-Argumente sind schwächer, wo AI-Outputs direkt mit urheberrechtlich geschützten Werken konkurrieren (Reuters Legal, 16. März 2026 — ⚠️ Datum liegt in der Zukunft relativ zu diesem Report, als Vorschau auf Rechtsentwicklung gelistet).

### Relevanz für dieses Konzept: 🟡 Mittel

**Konkrete Handlungsempfehlung:**
1. **Kreis-Animation / UI-Assets:** Wenn programmatisch (Code-basiert) generiert → kein Urheberrechtsproblem, da eigene Schöpfung. Wenn AI-generierte visuelle Assets → Lizenz dokumentieren.
2. **Hintergrundklänge / Ambient Sounds (optionaler IAP):** Kritisches Feld. Jeder verwendete Sound braucht eine **kommerzielle Lizenz**, die explizit die Nutzung in einem verkauften App-Produkt erlaubt. Lizenzfreiheit ≠ Lizenzlosigkeit.
3. **Atemtechnik-Beschreibungstexte:** Falls AI-generiert → eigene Überarbeitung dokumentieren, um Schutzfähigkeit zu begründen.
4. **Dokumentation von Anfang an:** Asset-Liste mit Quelle, Lizenzdatum und Lizenztyp anlegen — für potenzielle spätere Due-Diligence (Investoren, Akquisition).

**Quellen:** U.S. Copyright Office, "Copyright and Artificial Intelligence Part 2" (29. Januar 2025, copyright.gov/ai/); Reuters Legal, "Copyright Law in 2025" (16. März 2026 [sic], reuters.com); EU AI Act (VO 2024/1689, in Kraft August 2024)

---

## 4. Datenschutz (DSGVO)

### DSGVO-Ausgangslage: Besonderheit dieses Konzepts

Dieser Abschnitt erfordert eine Vorab-Differenzierung, weil das Konzept eine **strukturelle Datenschutz-Besonderheit** hat, die die rechtliche Analyse verändert:

> Die App speichert ausschließlich lokal (SharedPreferences / AsyncStorage), hat keine Netzwerk-Requests, kein Backend, keine Analytics-SDKs. Es werden nach aktuellem Konzeptstand **keine personenbezogenen Daten erhoben, übermittelt oder an Dritte weitergegeben.**

Das ist rechtlich positiv — aber es bedeutet **nicht**, dass die DSGVO vollständig entfällt.

### Was die