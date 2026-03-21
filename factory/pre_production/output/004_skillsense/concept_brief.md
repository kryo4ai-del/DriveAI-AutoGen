# Concept Brief: SkillSense

---

## One-Liner

SkillSense ist der erste datenbasierte Skill-Advisor für Claude- und GPT-Nutzer — er scannt vorhandene Skills auf Qualität, Sicherheit und Redundanz, und empfiehlt durch Fragebogen oder Chat-Analyse genau die Skills, die der Nutzer wirklich braucht.

---

## Kern-Mechanik & Core Loop

**Beschreibung:**
Der Core Loop besteht aus drei aufeinander aufbauenden Aktionen: **Scannen → Verstehen → Optimieren.** Nutzer laden ihre Skills hoch oder beantworten den Fragebogen (Einstieg ohne Hürde), erhalten einen sofortigen Score mit konkreten Befunden (Qualität, Sicherheit, Überlappung), und bekommen anschließend personalisierte Empfehlungen — was löschen, was behalten, was ergänzen. Der Loop schließt sich, wenn der Nutzer seine Skills aktualisiert und erneut scannt. Pro-Nutzer durchlaufen zusätzlich den Chat-Export-Pfad: Upload → Browser-Analyse → Nutzungsprofil → präzise Gap-Analyse.

**Begründung (Daten):**
Der Scan-zuerst-Ansatz ist entscheidend, weil er **sofortigen Wert ohne Registrierung** liefert. Das ist strukturell richtig: Die Zielgruppe (Claude Pro/GPT Plus Power User, 25–45 Jahre, hohe Tech-Affinität) hat geringe Toleranz für Value-Verzögerung. Der Fragebogen als zweiter Einstiegspunkt bedient Nutzer, die noch keine Skills installiert haben — laut Competitive-Report ist das der häufigste Status Quo (die meisten Nutzer konsumieren Clickbait-Listen, nicht kuratierte Empfehlungen). Der Security-Scanner adressiert eine nachweislich unbesetzte Marktlücke: OWASP Top 10 for LLM Applications listet Prompt Injection auf Platz 1 (2023/2024), kein Consumer-Tool prüft darauf. Das ist kein Nice-to-have — es ist ein akuter Schmerz ohne Lösung.

**Was passiert in den ersten 60 Sekunden:**
Nutzer landet auf der Landing Page → sieht den Claim *"Hör auf Skills zu raten. Lass dich beraten."* → klickt auf **"Skills jetzt scannen"** oder **"Fragebogen starten"** → wählt den Upload-Pfad → zieht eine SKILL.md-Datei ins Drag-and-Drop-Feld → sieht innerhalb von 3–5 Sekunden den ersten Score (Qualität, Sicherheit, Format). Kein Account, kein Loading-Screen, keine Ablenkung. Das erste Ergebnis muss in 60 Sekunden sichtbar sein — das ist die kritische Conversion-Schwelle für diese Zielgruppe.

---

## Zielgruppe

**Profil:**

| Segment | Beschreibung | Priorität |
|---|---|---|
| **Primär** | Claude Pro/Max Nutzer, 28–38 Jahre, Softwareentwickler / Wissensarbeiter / Freelancer, DACH-Markt, zahlen bereits ~20€/Monat für AI | Launch |
| **Sekundär** | GPT Plus Nutzer, leicht jünger (22–40), weniger "Skill-aware", größere absolute Basis | Phase 2 |
| **Tertiär** | Unternehmen mit Claude Team/Enterprise, IT/CTO als Entscheider, Kaufmotiv Compliance + Sicherheit | Phase 3 |

**Begründung (Daten):**
Die Primärzielgruppe hat eine entscheidende Eigenschaft, die der CEO-Brief richtig identifiziert: Sie haben **bereits bewiesen, dass sie für AI zahlen** (Claude Pro ~20€/Monat, GPT Plus ~22$/Monat — Anthropic Pricing / OpenAI Pricing, Stand 2025). SkillSense Pro bei 9,99€/Monat entspricht weniger als 50% dieser bestehenden Ausgaben — das ist psychologisch leicht rechtfertigbar, weil der Nutzer die Referenzgröße bereits kennt. Der DACH-Markt als primärer Launch-Markt ist strategisch korrekt begründet: DSGVO-Sensibilität ist hier am höchsten (GDPR Enforcement Tracker: 4,2 Mrd. € Bußgelder kumulativ seit DSGVO-Einführung), und die Client-side-Architektur von SkillSense ist genau das Argument, das in diesem Markt viral gehen kann. Der Altersbereich (Kern: 28–38) ist ein Proxy basierend auf Stack Overflow Developer Survey 2024 für AI-Tool-Nutzer — keine direkte Quelle für Claude-Nutzer-Demografie verfügbar. ⚠️

---

## Differenzierung zum Wettbewerb

**Direkte Vergleiche:**

| Wettbewerber | Was sie tun | Was fehlt | Wie SkillSense gewinnt |
|---|---|---|---|
| **YouTube "Top 10 Skills"** | Generische Listen für alle | Null Personalisierung, kein Sicherheitscheck, kein "Delete this" | Personalisierung + Delete-Empfehlung = direkter Kontrast |
| **GitHub Awesome-Listen** | Community-kuratiert, statisch | Nicht für Non-Developer, kein Scan, kein Update | Zugänglichkeit + Sicherheitsanalyse + dynamische Empfehlung |
| **FlowGPT / PromptBase** | Marktplatz-Logik | Qualitätskontrolle fehlt, kein "brauchst du das?" | Kein Verkauf, nur Beratung — anderes Paradigma |
| **Anthropic Docs** | Offizielle Beispiele | Minimale Inhalte, kein Personalisierungsansatz | Breite Community-Skills + Analyse-Engine |
| **GPT Store** | Millions GPTs, Discovery | Qualitätsproblem, kein Sicherheits-Audit | Audit-Funktion + plattformübergreifend |

**Unique Selling Points (datenbasiert bestätigt):**

1. **Personalisierte Skill-Diagnose** — Vollständig unbesetzt im Markt (Competitive-Report: Gap 1). Kein einziger Wettbewerber fragt *"wofür nutzt du AI eigentlich?"*. Das ist der fundamentale Marktfehler, den SkillSense adressiert.

2. **Security Scanner für End-User** — Vollständig unbesetzt (Competitive-Report: Gap 2). OWASP Prompt Injection auf Platz 1 der LLM-Risiken, kein Consumer-Tool prüft darauf. Das ist ein echter Schmerz, der mit wachsendem Sicherheitsbewusstsein skaliert.

3. **"Delete This"-Empfehlung** — Vollständig unbesetzt (Competitive-Report: Gap 3). Alle Wettbewerber sagen *"installiere mehr"*. SkillSense ist das erste Tool, das aktiv zum Löschen rät. Kontraintuitiv im Markt — deshalb differenzierend und viral.

4. **100% Client-side-Verarbeitung** — Technisch etabliert (Transformers.js / WebWorker), aber als Produkt-Argument im AI-Tool-Markt bisher kaum genutzt. In DACH mit DSGVO-Sensibilität ein starkes Vertrauens-Signal. Pew Research 2023: 79% der Nutzer besorgt über Datennutzung (US-Proxy; EU-Zahlen stärker zu erwarten). ⚠️

5. **Cross-Plattform (Claude + GPT)** — Sehr schwach besetzt (Competitive-Report: Gap 5). Positioniert SkillSense als neutrale Instanz, nicht als Anthropic- oder OpenAI-Partei-Tool.

---

## Monetarisierung

**Modell:**

| Tier | Preis | Inhalt | Ziel |
|---|---|---|---|
| **Free** | 0€ | Scanner bis 3 Skills, Advisor Light (Fragebogen), 1× Security Check/Monat | Acquisition, Vertrauen aufbauen |
| **Pro** | 9,99€/Monat oder 79€/Jahr | Unbegrenzt Scanner, Advisor Pro (Chat-Analyse), 5 Skill-Generierungen/Monat, kuratierte DB | Revenue Core |
| **Enterprise** | Kontakt | Bulk-Analyse, Standardisierung, Sicherheits-Gate, Custom Entwicklung | Phase 3 |

**Begründung (Daten):**
Der Preispunkt 9,99€/Monat ist marktkonform. Das sekundäre Preistier (~10€/Monat) wächst nachweislich: Notion AI (10$/Monat), Grammarly Premium (~12$/Monat), Otter.ai (~10$/Monat) zeigen, dass Wissensarbeiter diesen Betrag für AI-Produktivitäts-Add-ons akzeptieren. Der Jahresabo-Discount (79€/Jahr = 34% Rabatt) liegt im branchenüblichen Bereich von 20–35% (SaaS-Proxy). Sensor Tower State of Mobile 2026 bestätigt: IAP-Revenue +10,6% YoY bei nur +0,8% Download-Wachstum — Nutzer werden komfortabler mit digitalen Abos, zahlen häufiger/mehr. Hinweis: Diese Daten stammen aus Mobile-IAP; direkte Web-SaaS-Conversion-Rates für diese Nische sind nicht verfügbar. ⚠️

**Erwartete Einnahmen-Aufteilung:**

| Kanal | Erwarteter Anteil | Begründung |
|---|---|---|
| Pro Monat-Abo | ~40% | Niedrigere Bindung, höherer Churn |
| Pro Jahres-Abo | ~45% | Power User bevorzugen Planbarkeit (SaaS-Proxy) |
| Enterprise | ~15% | Kleines Segment, hoher ACV — erst ab Phase 3 relevant |

⚠️ Diese Aufteilung ist eine Schätzung basierend auf SaaS-Produktivitätstool-Benchmarks, keine SkillSense-spezifischen Daten.

**Kritische offene Frage:** Conversion Rate Free → Pro ist die wichtigste unbekannte Größe. Branchenüblich für Freemium-SaaS: 2–5%. Bei 10.000 Free-Nutzern wären das 200–500 Pro-Nutzer = 2.000–5.000€ MRR zum Start. Das ist validierbar — aber nur durch tatsächlichen Launch. ⚠️

---

## Session-Design

**Ziel-Dauer:**
- **Erst-Session (Setup):** 15–45 Minuten. Nutzer geht durch Scanner + Fragebogen + Ergebnisse + erste Empfehlung. Das ist keine Gaming-Session, sondern eine Analyse-Sitzung mit Entscheidungsoutput.
- **Wiederkehr-Session (Audit):** 5–15 Minuten. Neuer Skill hochladen, prüfen lassen, entscheiden.

**Frequenz:**
Niedrigfrequent, hochintensiv — geschätzt 2–4 Sessions pro Monat (Proxy: Produktivitäts-SaaS-Nutzungsmuster). Wiederkehr-Trigger sind ereignisbasiert, nicht habit-based:
- Neuer Skill erscheint im Ökosystem → Re-Scan
- Claude/GPT Update → Kompatibilitätscheck
- Monatliches "Skill-Audit"-Reminder (wenn aktiv kommuniziert via E-Mail/Notification)

**Begründung:**
SkillSense ist kein Daily-Use-Tool — das ist kein Schwäche, sondern eine Eigenschaft der Kategorie. Ähnlich wie ein Antiviren-Scan oder ein SEO-Audit: man macht es nicht täglich, aber wenn man es braucht, braucht man es wirklich. Das hat Implikationen für das Retention-Design: **Externe Trigger (Newsletter, "Neue Skills geprüft: 3 empfohlen für dein Profil") sind wichtiger als In-App-Loops.** Das sollte im Go-to-Market-Plan ab Tag 1 eingeplant sein. Der primäre Gerätekanal ist Desktop (~80%), weil der Upload-Flow (Skill-Dateien, Claude-Export) Desktop-nativ ist — Mobile ist für den Fragebogen nutzbar, aber kein Primärkanal für MVP. Das ist konsistent mit der CEO-Idee und technisch korrekt.

---

## Tech-Stack Tendenz

**Empfehlung:**

| Schicht | Empfehlung | Status |
|---|---|---|
| **Frontend** | Next.js 14+ mit App Router | ✅ Bestätigt |
| **Styling** | Tailwind CSS | ✅ Bestätigt |
| **Hosting** | Vercel (MVP) | ✅ Bestätigt |
| **Analyse-Engine** | TypeScript/WebWorker (Client-side) | ✅ Kritisch — nicht verhandelbar |
| **Skill-DB (MVP)** | JSON im Repo | ✅ Richtig für MVP |
| **Skill-DB (Scale)** | Supabase | ✅ Sinnvoll ab Phase 2 |
| **Auth** | Clerk oder Supabase Auth | ✅ Erst ab Pro-Tier nötig |
| **Payments** | Stripe | ✅ Marktstandard |
| **LLM (Skill-Generierung)** | Anthropic API (Claude Sonnet) | ✅ Bestätigt — aber siehe Abweichungen |

**Begründung:**
Die Client-side-Architektur via WebWorker ist technisch kein Experiment mehr — Transformers.js (Hugging Face) und ähnliche Projekte haben gezeigt, dass ML-Analyse im Browser produktionstauglich ist (Trend-Report: Trend 3). Das ist kein Nice-to-have: Es ist das Fundament des DSGVO-Versprechens. Wenn die Analyse jemals serverseitig läuft, verliert SkillSense seinen primären Datenschutz-USP in einem Markt, wo dieser USP viral gehen kann. **Die Client-side-Entscheidung ist nicht optional — sie ist die Marke.**

Next.js ist korrekt: Server-Side Rendering hilft für Landing Page SEO, API Routes ermöglichen den optionalen LLM-Call für Skill-Generierung (Pro), ohne ein separates Backend zu brauchen. Vercel als Hosting ist für MVP kosteneffizient und skaliert automatisch.

**Ergänzungsempfehlung:** Eine einfache **Analytics-Schicht ohne Nutzerdaten** (z.B. Plausible Analytics statt Google Analytics) sollte von Tag 1 eingeplant sein. Aggregate-Metriken (welcher Fragebogen-Pfad wird häufiger gewählt? Wie viele Skills werden durchschnittlich hochgeladen?) sind für Produktentscheidungen in Phase 2 essentiell — ohne DSGVO-Konflikt.

---

## Abweichungen von der CEO-Idee

**[Advisor Pro — LLM-Call-Modell]:**
Ursprünglich → *"Skill-Generierung via Anthropic API mit Nutzer-API-Key oder Pay-per-Use"*
Angepasst → **Pay-per-Use als Standard empfohlen, API-Key als Option für Power User**
Begründung: Der Großteil der Primärzielgruppe (Wissensarbeiter, Content Creator) hat keinen eigenen Anthropic API Key — das ist ein Developer-Merkmal. API-Key als einzige Option schließt 60–70% der Zielgruppe aus. Pay-per-Use via Stripe (Credits-Modell, z.B. 5 Credits für Skill-Generierung im Pro-Tier inbegriffen) senkt die Hürde erheblich. API-Key als Opt-in für technische Nutzer behalten — aber nicht als Default.

**[GPT Custom Instructions als Sekundärzielgruppe]:**
Ursprünglich → *"GPT Plus Nutzer mit Custom GPTs / Custom Instructions"*
Angepasst → **Für Phase 2 verschieben, nicht co-launch.**
Begründung: GPT Custom Instructions haben eine andere Struktur als Claude Skills (kein SKILL.md-Format, kein Schema-Standard). Die Scanner-Engine muss für Claude Skills zuerst stabil sein, bevor eine zweite Schema-Logik gebaut wird. Gleichzeitig ist das Marktargument stark (GPT Store hat 3M+ GPTs, massive Community) — aber Halbherzigkeit schadet der Claude-Primärzielgruppe. Sauber in Phase 2 liefern: *"SkillSense für Claude — GPT-Support coming Q3"* ist ein stärkeres Versprechen als ein buggy Dual-Support zum Launch.

**[Marktgröße-Annahme im CEO-Brief]:**
Ursprünglich → *"90% der Nutzer haben wahrscheinlich die falschen Skills installiert"*
Angepasst → **Als Marketing-Claim behalten, aber nicht als Business-Case-Grundlage verwenden.**
Begründung: Die Zahl ist nicht verifizierbar — keine öffentlichen Daten zur aktiven Skill-Nutzungsrate unter Claude Pro-Nutzern existieren (Trend-Report: kritische Datenlücke). Als emotionaler Claim auf der Landing Page ist sie stark und plausibel. Als Business-Case-Basis ist sie riskant — besser: Interne Planung auf konservativen Konversionsszenarien basieren (2–5% Free-to-Pro), nicht auf Marktgrößen-Schätzungen.

**[Mobile — Explizit als Non-Priority bestätigen]:**
Ursprünglich → *"Responsive Design (Desktop + Mobile)"*
Angepasst → **Desktop-first mit Mobile-Baseline, keine mobile-optimierte UX für MVP.**
Begründung: Zielgruppen-Report zeigt eindeutig ~80% Desktop für den primären Use Case (Datei-Upload, Analyse). Responsive Design sollte vorhanden sein (technisch), aber UX-Optimierungszeit sollte nicht auf Mobile verwendet werden, bis der Desktop-Flow stabil konvertiert. Mobile-first-Reflex schadet hier dem MVP-Fokus.

---

## Stärken des Konzepts (datenbasiert)

**Stärke 1: Vollständig unbesetzte Nische mit nachweisbarem Schmerz**
Der Competitive-Report identifiziert 6 Markt-Gaps, von denen 4 als *"vollständig unbesetzt"* eingestuft sind (personalisierte Diagnose, Sicherheits-Audit, Delete-Empfehlung, Nutzungsanalyse). Das ist außergewöhnlich für ein 2025 lanciertes Produkt. Die meisten Nischen haben mindestens indirekte Wettbewerber — hier gibt es buchstäblich kein Tool, das personalisierte Skill-Empfehlungen gibt. First-Mover-Vorteil ist real, aber das Zeitfenster ist begrenzt (Anthropic könnte native Analyse einbauen — Risiko bleibt Mittel, nicht Niedrig).

**Stärke 2: Datenschutz-Architektur als viraler Differenzierer im richtigen Markt**
Die 100% Client-side-Verarbeitung trifft auf einen Markt, der nach ChatGPT-Sperren (Italien 2023), DSGVO-Bußgeldern (4,2 Mrd. € kumulativ) und wachsendem Bewusstsein für AI-Datenschutzrisiken sensibilisiert ist. Im DACH-Markt ist *"deine Chat-Historie verlässt deinen Rechner nie"* nicht nur ein technisches Feature — es ist ein Share-würdiges Statement, das organische Reichweite generiert. Dieser USP kostet keine Marketingausgaben, wenn er richtig kommuniziert wird.

**Stärke 3: Zahlungsbereitschaft der Zielgruppe ist vorab bewiesen**
Die Primärzielgruppe zahlt bereits 20–22€/Monat für AI-Tools. SkillSense Pro bei 9,99€/Monat ist in Relation dazu ein niedriger Zusatzbetrag für ein Tool, das die bestehende AI-Investition optimiert. Das Argument *"du zahlst 20€/Monat für Claude — lass uns sicherstellen dass du ihn auch richtig nutzt"* ist direkt auf den bestehenden Ausgabenkontext aufgebaut. Es muss keine neue Zahlungsbereitschaft erzeugt werden, nur eine bestehende Bereitschaft auf ein angrenziges Problem gelenkt werden.

---

## Risiken und offene Fragen

**Risiko 1 — Plattform-Abhängigkeit (hoch):**
Der größte strukturelle Risikofaktor ist nicht Wettbewerb — es ist Anthropic selbst. Wenn Anthropic eine native Skill-Analyse-Funktion in Claude.ai einbaut, verliert SkillSense seinen Primärmarkt. Die Mitigation im CEO-Brief (Cross-Platform-Strategie, First-Mover) ist richtig, aber nicht ausreichend als einzige Absicherung. Empfehlung: Ab Phase 2 aktiv eine **Platform-agnostische Positionierung** aufbauen (SkillSense als unabhängige Audit-Instanz, nicht als Claude-Tool) — damit wird ein möglicher Anthropic-Schritt zur Bestätigung des Marktes, nicht zur Bedrohung.

**Risiko 2 — Kritische Datenlücke: Aktive Skill-Nutzungsrate (ungelöst):**
Weder Trend-Report noch Competitive-Report noch Zielgruppen-Report konnten beantworten, wie viele Claude Pro Nutzer aktiv Skills installiert haben. Diese Zahl ist für die Marktgrößenabschätzung entscheidend. Wenn die aktive Skill-Nutzungsrate unter Claude Pro-Nutzern bei <10% liegt, ist der adressierbare Markt zum Launch sehr klein — und Advisor Light (Fragebogen ohne eigene Skills) wird wichtiger als der Scanner. **Empfehlung vor Launch:** 50–100 Nutzer aus r/ClaudeAI und r/Prom