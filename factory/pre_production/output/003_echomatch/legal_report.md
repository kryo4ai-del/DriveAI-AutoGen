# Legal-Research-Report: EchoMatch

**Erstellt auf Basis von:** Concept Brief (intern), Web-Recherche-Ergebnisse (2025), KI-Ersteinschätzung
**Stand:** 2025
**Rechtsgebiet:** Mobile Apps & Games — Internationale Ersteinschätzung

> ⚠️ **Disclaimer:** Dieser Report ist eine KI-basierte Ersteinschätzung und ersetzt keine rechtsverbindliche Beratung durch zugelassene Rechtsanwälte. Alle 🔴 und 🟡 markierten Felder erfordern professionelle juristische Prüfung vor Launch.

---

## Identifizierte Rechtsfelder

| # | Rechtsfeld | Risikostufe | Priorität |
|---|---|---|---|
| 1 | Monetarisierung & Glücksspielrecht | 🔴 Hoch | Sofort |
| 2 | App Store Richtlinien (Apple / Google) | 🟡 Mittel | Pre-Launch |
| 3 | AI-generierter Content — Urheberrecht | 🟡 Mittel | Pre-Production |
| 4 | Datenschutz (DSGVO / COPPA) | 🔴 Hoch | Sofort |
| 5 | Jugendschutz (USK / PEGI / IARC) | 🟡 Mittel | Pre-Launch |
| 6 | Social Features — Schutzpflichten | 🟡 Mittel | Pre-Launch |
| 7 | Markenrecht — Namenskonflikt | 🟡 Mittel | Sofort |
| 8 | Patente | 🟡 Mittel | Pre-Production |

---

## 1. Monetarisierung & Glücksspielrecht

### Aktuelle Gesetzeslage (allgemein)

Das Glücksspielrecht ist im Kontext mobiler Spiele primär dann relevant, wenn Spielmechaniken drei Kerneigenschaften kombinieren: **Geldeinsatz (Consideration), zufälliges Ergebnis (Chance) und geldwerten Gewinn (Prize)** — der sog. "Three-Part Test" in US-Jurisdiktionen. Im EU-Raum variiert die Auslegung erheblich nach Mitgliedstaat.

EchoMatchs Monetarisierungsmodell (Rewarded Ads, Battle-Pass, kosmetische/Convenience-IAPs) ist **strukturell darauf ausgelegt, die klassischen Glücksspiel-Trigger zu vermeiden** — dies ist ein wichtiger Ausgangspunkt. Dennoch bestehen länderspezifische Risiken, die nachfolgend differenziert werden.

---

### Länderspezifisch

#### 🇪🇺 EU (allgemein) — 🔴 Erhöhte Aufmerksamkeit erforderlich

Das Europäische Parlament hat im Oktober 2025 explizit gefordert:
- **Verbot glücksspielähnlicher Mechanismen wie Loot Boxes in für Minderjährige zugänglichen Spielen**
- Verbot von Monetarisierung durch Persuasive Technologies (Dark Patterns) für Minderjährige
- Schnelle Durchsetzung des Digital Services Act (DSA) gegen Sucht-Design

> Quelle: Europäisches Parlament, Pressemitteilung 20251013IPR30892, Oktober 2025

**Relevanz für EchoMatch:** Das Konzept sieht keine klassischen Loot Boxes vor. Der Battle-Pass mit transparenten, vorher sichtbaren Inhalten ist nach aktuellem Stand in der EU grundsätzlich unbedenklicher als Loot Boxes. **Jedoch:** Die täglich wechselnden KI-generierten Quests und Daily-FOMO-Mechaniken könnten unter regulatorische Prüfung als "Sucht-Design" fallen — hier ist Vorsicht geboten. Rewarded Ads sind grundsätzlich unproblematisch.

#### 🇧🇪 Belgien — 🔴 Hohes Risiko (Referenzmarkt für EU-Regulierung)

Belgien hat eines der restriktivsten Glücksspielregime für Spiele in Europa. Die Belgische Glücksspielkommission hat bereits 2018 Loot Boxes als Glücksspiel eingestuft. 2025 haben mehrere EU-Länder ihre Regulierung an das belgische Modell angelehnt.

**Relevanz für EchoMatch:** Kein direktes Risiko durch Loot Boxes (nicht im Konzept vorgesehen). Battle-Pass und kosmetische IAPs fallen nach aktuellem Verständnis **nicht** unter das belgische Glücksspielrecht, solange keine zufallsbasierte Belohnungsstruktur vorliegt. ⚠️ **Datenlücke:** Ob die KI-Personalisierung als "psychologisch manipulatives System" unter zukünftige belgische Regulierung fällt, ist derzeit nicht abschließend beurteilbar. Professionelle Prüfung empfohlen.

#### 🇳🇱 Niederlande — 🔴 Aktives Regulierungsumfeld

Die niederländische Kansspelautoriteit (Ksa) verfolgt aktiv Spiele mit zufallsbasierten Kaufmechanismen. 2024–2025 wurden mehrere Publisher zu Geldbußen verurteilt.

**Relevanz für EchoMatch:** Gleiches Bild wie Belgien — kein unmittelbares Loot-Box-Risiko. ⚠️ Zu prüfen: Ob "Daily-AI-Quests mit variablem Belohnungsinhalt" als zufallsbasierter Mechanismus eingestuft werden könnten. Empfehlung: Belohnungsstrukturen für Daily Quests **vollständig transparent und deterministisch** gestalten (keine randomisierten Belohnungspools).

#### 🇩🇪 Deutschland — 🟡 Mittleres Risiko

Der Glücksspielstaatsvertrag (GlüStV 2021) reguliert primär klassisches Glücksspiel. Die Unterhaltungssoftware Selbstkontrolle (USK) und die zuständigen Landesbehörden beobachten das Feld. Eine explizite Loot-Box-Gesetzgebung existiert in DE noch nicht auf Bundesebene, ist aber in der politischen Diskussion.

**Relevanz für EchoMatch:** Geringes unmittelbares Risiko durch das gewählte Monetarisierungsmodell. Die USK-Einstufung (siehe Abschnitt 5) ist jedoch auch für Kaufentscheidungen in DE relevant.

#### 🇺🇸 USA — 🟡 Moderates Risiko, stark bundesstaatlich variierend

Auf Bundesebene gibt es 2025 noch kein einheitliches Glücksspielgesetz für mobile Games. Der FTC Act (Section 5) schützt gegen unfaire und täuschende Praktiken. Einzelne Bundesstaaten (Washington, Minnesota, Hawaii) haben Loot-Box-Gesetze diskutiert oder eingebracht — keines ist bislang federal wirksam.

**Relevanz für EchoMatch:**
- Rewarded Ads: ✅ Unproblematisch
- Battle-Pass mit transparentem Inhalt: ✅ Unproblematisch
- Kosmetische/Convenience-IAPs: ✅ Unproblematisch (solange kein randomisierter Element)
- ⚠️ **COPPA-Überschneidung** (siehe Abschnitt 4): Falls Minderjährige die App nutzen, gelten besondere IAP-Schutzregeln (unbewusste Käufe durch Kinder waren Gegenstand mehrerer FTC-Settlements mit Apple und Google).

#### 🇨🇳 China — 🔴 Hohes Risiko / Separate Strategie erforderlich

China reguliert mobile Spiele durch das **National Press and Publication Administration (NPPA)**. Anforderungen:
- Pflicht-Lizensierung aller kommerziellen Spiele (Spielelizenz erforderlich)
- Real-Name-Registrierung der Nutzer
- Striktes Minderjährigen-Spielzeitlimit (3 Stunden/Woche für unter 18-Jährige)
- Gacha/Loot-Box-Offenlegungspflichten (Wahrscheinlichkeiten müssen publiziert werden)
- AI-generierter Content unterliegt seit 2023 den "Interim Measures for the Management of Generative AI Services" (国家互联网信息办公室)

**Relevanz für EchoMatch:** China ist im Concept Brief nicht als Zielmarkt genannt. **Empfehlung:** China für den initialen Launch explizit ausschließen — der regulatorische Aufwand übersteigt den Nutzen in der Launch-Phase erheblich. Separater China-Markteintrittsplan bei Bedarf.

---

### Relevanz für dieses Konzept (Gesamtbewertung)

Das gewählte Monetarisierungsmodell ist **strukturell regulierungskonform konzipiert** — die bewusste Entscheidung gegen Pay-to-Win und Loot Boxes reduziert das Glücksspielrechtsrisiko erheblich. Die kritischen Prüfpunkte sind:

1. **Daily-Quest-Belohnungsstrukturen:** Müssen deterministisch und transparent sein — keine randomisierten Reward-Pools
2. **Dark-Pattern-Compliance:** FOMO-Mechaniken (Daily AI Content, Push Notifications) könnten unter EU-Regulierung für "Sucht-Design" fallen — insbesondere wenn Minderjährige die App nutzen
3. **Battle-Pass-Inhalte:** Müssen vor Kauf vollständig sichtbar sein (kein Blind-Purchase)

**Priorität:** 🔴 Vor Launch Rechtsberatung in DE, BE, NL einholen. US-Rechtsberatung für FTC-Compliance empfohlen.

---

## 2. App Store Richtlinien

### Apple App Store — 🟡

Relevante Richtlinien (App Store Review Guidelines, Stand 2025):

**In-App Purchases (Guideline 3.1):**
- Alle digitalen Inhalte, die innerhalb der App konsumiert werden, müssen über das Apple In-App-Purchase-System abgewickelt werden → Battle-Pass und kosmetische IAPs fallen hierunter
- Apple behält 15–30% der IAP-Revenue (Small Business Program: 15% für Entwickler unter $1M Jahresumsatz)
- ⚠️ **Subscription-Regelung (Guideline 3.1.2):** Battle-Pass als monatliches Abonnement muss die Apple-Subscription-Guidelines erfüllen: klare Preisangabe, einfache Kündigung, keine versteckten Verlängerungen

**Werbung / Rewarded Ads (Guideline 3.2.1):**
- Rewarded Ads sind explizit erlaubt, solange der Nutzer die Werbung freiwillig initiiert
- ⚠️ Interstitial Ads (Interrupt-Ads) sind für Apple problematischer — das Konzept sieht diese nicht vor, was konform ist

**Zufallsmechanismen (Guideline 3.1.1):**
- Apps, die virtuelle Währung durch Glücksspiel-ähnliche Mechanismen vergeben, müssen Wahrscheinlichkeiten offenlegen
- Da EchoMatch keine Loot Boxes plant: ✅ Kein unmittelbares Risiko — **jedoch Vorsicht** bei variablen Belohnungsstrukturen in Daily Quests (s.o.)

**Datenschutz (Guideline 5.1):**
- App Tracking Transparency (ATT): KI-Personalisierungsfeatures, die Nutzerverhalten tracken, müssen unter iOS ATT-Anforderungen geprüft werden
- Privacy Nutrition Labels (App Privacy Details) müssen korrekt ausgefüllt sein — Behavioral Tracking für KI-Personalisierung muss deklariert werden

**Quelle:** Apple App Store Review Guidelines (developer.apple.com/app-store/review/guidelines/, abgerufen 2025); LinkedIn/Sonu Dhankhar, "App Store Policy Updates 2025", 2025

---

### Google Play Store — 🟡

**Play Policy Center (2025):**
- Ähnliche IAP-Anforderungen wie Apple; Google Play Billing System ist Pflicht für digitale Inhalte
- Google Play's Families Policy: Falls die App für Kinder unter 13 zugänglich ist, gelten erheblich strengere Anforderungen (keine behavioral Ads, begrenzte Datenkollektierung)
- **Rewarded Ads:** Google AdMob unterstützt Rewarded Ads explizit — konform mit Play-Richtlinien
- Google Play nutzt das **IARC-System** für Altersfreigaben (s. Abschnitt 5)

**Financial Features Policy:**
- Subscription-Abonnements müssen einfach kündbar sein (analog zu Apple)
- Preistransparenz ist Pflicht

**Relevanz:**
Das Monetarisierungsmodell ist mit beiden Stores grundsätzlich kompatibel. Die kritischen Compliance-Punkte sind:
1. Korrekte Datenschutz-Deklaration für KI-Behavioral-Tracking
2. Subscription-Compliance für Battle-Pass
3. Altersfreigabe-Korrektheit im IARC-Prozess

**⚠️ Datenlücke:** Die spezifischen 2025-Policy-Updates (LinkedIn-Quelle: "major policy updates from Apple and Google are reshaping how apps earn money and show ads") konnten aus den vorliegenden Recherche-Ergebnissen nicht im Detail extrahiert werden. **Empfehlung:** Beide aktuellen Policy-Dokumente (Apple Guidelines + Google Play Policy Center) vor Launch vollständig durcharbeiten oder durch Counsel prüfen lassen.

---

## 3. AI-generierter Content — Urheberrecht

### Aktuelle Rechtslage — 🟡

**USA (U.S. Copyright Office, 2025):**
- Das U.S. Copyright Office hat in **Part 2 des AI-Copyright-Reports (Januar 2025)** klargestellt: AI-generierte Outputs ohne substanziellen menschlichen kreativen Beitrag sind **nicht urheberrechtlich schutzfähig**
- AI-generierte Inhalte mit nachweisbarer menschlicher kreativer Kontrolle können partiell schutzfähig sein
- **Part 3 (Pre-Publication, Mai 2025)** adressiert die Frage des Trainings auf urheberrechtlich geschützten Daten — hier laufen aktive Gerichtsverfahren

> Quelle: U.S. Copyright Office, "Copyright and Artificial Intelligence Part 2" (Januar 2025); Part 3 Pre-Publication (Mai 2025)

**EU:**
- Der EU AI Act (2024, Anwendung ab 2025/2026 stufenweise) enthält Transparenzpflichten für KI-generierte Inhalte
- Urheberrechtlich gilt in der EU: KI-Outputs ohne menschliche Schöpfungshöhe sind nicht schutzfähig (analog USA)
- Richtlinie 2019/790 (DSM-Directive) enthält Text-and-Data-Mining-Ausnahmen, die für KI-Training relevant sind

---

### Kommerzielle Nutzung — Relevante Risiken

**Risiko 1: Training-Datenbasis des KI-Systems**
Falls das für die Level-Generierung eingesetzte KI-Modell auf urheberrechtlich geschützten Spielen oder Level-Designs trainiert wurde, besteht potenzielle Haftung gegenüber den Rechteinhabern. Reuters (März 2026, basierend auf 2025-Urteilen) stellt fest: *"Fair use arguments may be weaker where AI outputs directly compete with copyrighted content in active licensing markets."*

> Quelle: Reuters Legal, "Copyright Law in 2025", 16. März 2026

**Risiko 2: Schutz eigener AI-generierter Level**
EchoMatch kann AI-generierte Levels **nicht** vollumfänglich als eigenes Urheberrecht schützen. Wettbewerber könnten ähnliche Outputs ohne Verletzungsrisiko generieren. Dies verstärkt das im Concept Brief genannte Risiko 4 (Kopierbarkeit des KI-USPs).

**Risiko 3: Narrative Story-Layer**
Falls die KI auch narrative Inhalte generiert: Gleiches Copyright-Problem. Menschliche Autoren-Beteiligung (Redaktionsprozess, kreative Kontrolle) sollte dokumentiert werden, um Schutzfähigkeit zu maximieren.

---

### Relevanz für EchoMatch

| Risiko | Einschätzung | Empfehlung |
|---|---|---|
| Training-Datenbasis | 🔴 Prüfpflicht | KI-Anbieter-Verträge auf IP-Indemnification prüfen |
| Eigener Output-Schutz | 🟡 Strukturell | Hybridansatz (Mensch + KI) für maximale Schutzfähigkeit |
| Narrative Inhalte | 🟡 Prüfpflicht | Menschliche Redaktion dokumentieren |

**Empfehlung:** Bei Auswahl des KI-Dienstleisters (z. B. OpenAI, Google Vertex, Proprietary) explizit auf **IP-Indemnification-Klauseln** achten — führende Anbieter (OpenAI, Microsoft/GitHub) bieten diese mittlerweile für Enterprise-Kunden an. Für den proprietären KI-Stack: Rechtsgutachten zur Training-Datenbasis.

---

## 4. Datenschutz (DSGVO / COPPA)

### DSGVO-Anforderungen — 🔴

**Kernrelevanz für EchoMatch:** Das KI-Personalisierungsfeature ist das **datenschutzrechtlich kritischste Element** des Konzepts. Es basiert auf kontinuierlichem Behavioral Tracking (implizites Spielstil-Tracking ab dem ersten Onboarding-Match) — genau die Datenverarbeitungsform, die unter DSGVO besonderer Rechtfertigung bedarf.

**Rechtsgrundlage (Art. 6 DSGVO):**
Die Verarbeitung von Verhaltensdaten zur KI-Personalisierung kann sich grundsätzlich auf folgende Rechtsgrundlagen stützen:
- **Einwilligung (Art. 6 Abs. 1 lit. a):** Muss freiwillig, informiert und aktiv gegeben werden — eine Pre-Checked-Box oder implizites Tracking ohne Consent ist unzulässig
- **Berech