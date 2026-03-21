# Concept Brief: SkillSense

---

## One-Liner

SkillSense ist die erste datenbasierte Web-App die AI-Nutzern zeigt welche Skills sie wirklich brauchen, welche ein Sicherheitsrisiko sind, und welche sie sofort löschen können — personalisiert statt generisch, 100% client-side statt datenhungrig.

---

## Kern-Mechanik & Core Loop

**Beschreibung:**
Der Core Loop ist dreistufig und bewusst task-basiert, kein Daily-Driver:

1. **Trigger** → Nutzer findet neuen Skill online (YouTube, GitHub, Reddit) oder merkt dass seine AI-Antworten schlechter werden
2. **Aktion** → Upload/Fragebogen in SkillSense (Scanner oder Advisor)
3. **Ergebnis** → Konkreter Score + Empfehlung: behalten, löschen, ersetzen
4. **Optional** → Skill aus kuratierter Datenbank installieren oder via Pro generieren lassen
5. **Rückkehr-Trigger** → Nächster gefundener Skill oder Chat-Export nach 4 Wochen

**Begründung (Daten):**
Der Trend-Report bestätigt: Der App-Markt 2025 verschiebt sich von Download-Volumen zu **Monetarisierungs- und Engagement-Tiefe** (Sensor Tower, 2026). SkillSense ist konzeptuell korrekt positioniert als Tool das nicht täglich genutzt wird, aber bei jeder Nutzung hohen Wert liefert. Das entspricht dem SaaS-Muster von Tools wie Readwise oder Grammarly — niedrige Nutzungsfrequenz, hohe Zahlungsbereitschaft weil der Nutzen klar messbar ist.

Das Competitive-Report bestätigt zusätzlich: Der primäre "Gegner" im Nutzermindset ist nicht ein anderes Tool, sondern ein Verhalten — YouTube-Clickbait-Listen konsumieren und blind installieren. Der Core Loop von SkillSense ersetzt genau diesen Moment mit einem strukturierten, datenbasierten Gegenstück.

**Was passiert in den ersten 60 Sekunden:**

```
0–5 Sek:    Landing Page — Headline trifft Pain Point sofort:
            "Hör auf Skills zu raten. Lass dich beraten."
            CTA: "Deine Skills jetzt prüfen — kostenlos"

5–20 Sek:   Drag & Drop Upload-Bereich sichtbar ohne Scroll
            Alternativ: "Lieber den Fragebogen" als zweiter Einstieg
            Kein Account, kein Login, keine Ablenkung

20–45 Sek:  Datei(en) hochgeladen → Ladeanimation mit
            Echtzeit-Feedback was gerade analysiert wird
            ("Prüfe Sicherheitspatterns... Suche Überlappungen...")

45–60 Sek:  Erstes Ergebnis sichtbar — Score-Anzeige mit
            einer konkreten Handlungsempfehlung
            Kein Wall of Text — drei Kacheln: ✅ Gut / ⚠️ Prüfen / 🔴 Risiko
```

Begründung für diesen Einstieg: Zielgruppen-Report zeigt erste Session-Länge von 8–15 Minuten bei Onboarding-typischen Productivity-Tools. Der sofortige Wert-Beweis (Scan-Ergebnis in unter 60 Sekunden) ist notwendig um diese Session-Länge zu rechtfertigen und Free-to-Pro-Conversion vorzubereiten.

---

## Zielgruppe

**Profil:**

| Segment | Beschreibung | Priorität |
|---|---|---|
| **Der Developer** | 26–38 Jahre, Software Engineer, nutzt Claude täglich mit VS Code, hat 10–20 Skills installiert, zahlt bereits für Copilot + Claude Pro | 🔴 Primär |
| **Der Content Pro** | 28–42 Jahre, Texter/Marketer/Journalist, nutzt Claude für Drafts & Research, 5–10 Skills, Zahlungsbereitschaft vorhanden wenn Nutzen klar | 🔴 Primär |
| **Der AI-Enthusiast** | 20–35 Jahre, Freelancer/Student, testet alles, installiert YouTube-Skills, Free-Tier-Einstieg → Conversion-Ziel | 🟡 Sekundär |
| **Der Business Analyst** | 32–50 Jahre, Consultant/PM, nutzt AI für Reports, kaum Skills bisher, Enterprise-Pfad relevant | 🟡 Sekundär (Phase 2/3) |

**Geografisch:** DACH primär (deutschsprachige Positionierung im Pitch), EU-Rollout ab Phase 2, englischsprachiger Markt ab Phase 2 parallel möglich da Tech-Stack keine Lokalisierungsbarriere hat.

**Begründung (Daten):**
Der Zielgruppen-Report identifiziert die Zielgruppe als **bereits zahlende AI-Subscriber** — Claude Pro kostet 20 USD/Monat, GitHub Copilot 10 USD/Monat. Diese Nutzer haben nachweislich Zahlungsbereitschaft für AI-Produktivitätstools etabliert. SkillSense bei 9,99 €/Monat liegt strukturell unter den bestehenden Ausgaben dieser Gruppe — das reduziert die Conversion-Hürde erheblich.

Der Zielgruppen-Report warnt explizit: SkillSense ist **kein Anfänger-Produkt**. Nutzer die noch nie einen Skill installiert haben sind kein primäres Segment für den Scanner — sie sind aber ein sekundäres Segment für den Advisor Light (Fragebogen als Einstieg bevor der erste Skill installiert wird). Diese Differenzierung sollte in der Landing-Page-Copy berücksichtigt werden.

**Kritische Anmerkung zur CEO-Idee:**
Die CEO-Idee nennt "Claude Pro/Max Nutzer die Skills nutzen wollen" als Primärzielgruppe. Der Zielgruppen-Report schärft das: Der Sweet Spot sind Nutzer die **bereits Skills installiert haben und mit den Ergebnissen unzufrieden sind** — nicht Nutzer die noch gar keine Skills haben. Letztere sind eine valide Sekundärzielgruppe aber benötigen andere Messaging ("Installiere von Anfang an die richtigen" statt "Räum auf was nicht funktioniert").

---

## Differenzierung zum Wettbewerb

**Direkte Vergleiche:**

| Wettbewerber | Was er macht | Was SkillSense besser macht |
|---|---|---|
| **YouTube/TikTok Creator** | "Top 10 Skills für alle" — nicht personalisiert, nicht überprüft | Personalisiert durch Fragebogen + Chat-Analyse; Sicherheits-geprüft |
| **GitHub Awesome-Listen** | Statische Kuratierung ohne Qualitätsbewertung | Dynamische Bewertung mit Score, Security-Check, Overlap-Detection |
| **PromptBase** | Marktplatz — verkauft Prompts ohne Fit-Check | Kein Verkauf — Beratung: "Passt das zu dir?" |
| **FlowGPT** | Community-Popularität statt persönlicher Relevanz | Algorithmus basiert auf Nutzungsverhalten, nicht auf Likes |
| **Anthropic Docs** | Technische Dokumentation ohne Analyse-Funktion | Analyse + Handlungsempfehlung + Sicherheitsprüfung |
| **GPT Store** | Discovery durch Popularität | Discovery durch persönlichen Fit + Sicherheits-Gate |

**Unique Selling Points (durch Competitive-Report bestätigt als echte Marktlücken):**

**USP 1 — Personalisierung (Gap 1 im Competitive-Report)**
> Kein einziges existierendes Tool fragt "was nutzt du?" bevor es empfiehlt. SkillSense ist das erste Tool das den Skill-Fit für den individuellen Nutzer berechnet — sowohl über regelbasierten Fragebogen (Light) als auch über Chat-Daten-Analyse (Pro).

**USP 2 — Sicherheits-Analyse (Gap 2 im Competitive-Report)**
> 42 Pattern-Checks für Prompt Injection, versteckte URLs, Scope Escalation, unsichtbare Unicode-Zeichen — das existiert im Markt nicht als nutzerfreundliches Tool. Mit wachsendem Skill-Ökosystem wird dieser USP wichtiger, nicht unwichtiger. First-Mover-Position solide.

**USP 3 — Überlappungs-Erkennung via Jaccard (Gap 3 im Competitive-Report)**
> Cross-Skill-Conflict-Detection existiert in keinem bekannten Tool. Für Nutzer mit 10+ Skills ist das ein praktisch sofort erlebbarer Mehrwert.

**USP 4 — 100% Client-Side / DSGVO by Design (Gap 6 im Competitive-Report)**
> Alle Wettbewerber sind serverbasiert. SkillSense ist das einzige Tool das Chat-Export-Analyse lokal im Browser durchführt. Das ist regulatorisch korrekt und gleichzeitig ein Marketingargument das in der Zielgruppe (tech-affine, datenschutzbewusste Nutzer) direkt zieht.

**USP 5 — Chat-History als Empfehlungsbasis (Gap 4 im Competitive-Report)**
> Die Idee "deine eigene Nutzung als Datenbasis für Empfehlungen" ist konzeptuell der stärkste Differentiator und existiert in dieser Form nicht im Markt. Das ist der entscheidende Grund warum Pro-Tier attraktiv ist.

---

## Monetarisierung

**Modell:**

```
Free Tier          → Skill Scanner (3 Skills), Advisor Light, 1x Security Check/Monat
Pro Tier           → 9,99 €/Monat oder 79 €/Jahr
Team/Enterprise    → Kontaktbasiert, Jahresvertrag
```

**Begründung (Daten):**

Der Trend-Report bestätigt: Non-Game App Subscriptions wuchsen 2025 um +33,9% YoY auf 82,6 Mrd. USD (Appfigures, Januar 2026). Der Markt belohnt Subscription-Modelle, nicht Einmalkäufe.

Der Zielgruppen-Report zeigt: SaaS-Productivity-Tool-Benchmarks (Grammarly, Notion, Readwise) haben eine typische Zahlungsbereitschaft von 8–15 €/Monat in der Zielgruppe. 9,99 €/Monat liegt im oberen Sweet Spot — rechtfertigbar durch messbaren Mehrwert, nicht durch Günstigsein.

Das Jahresabo (79 €) entspricht 6,58 €/Monat. Der Zielgruppen-Report schätzt 20–35% Conversion auf Jahresabo als realistisch (Proxy: Paddle SaaS Report 2024). Das ist monetarisierungsstrategisch wichtig weil Jahresabo-Nutzer eine 3–4x höhere Retention haben als Monats-Abonnenten.

**Erwartete Einnahmen-Aufteilung (Schätzung, nicht durch Primärdaten belegt):**

| Tier | Anteil Nutzer | Anteil Revenue | Anmerkung |
|---|---|---|---|
| Free | ~80% | 0% direkt | Akquisitionskanal → Conversion-Ziel |
| Pro Monatlich | ~12% | ~35% | Höchste Churn-Gefahr |
| Pro Jährlich | ~6% | ~45% | Kern-Revenue, niedrige Churn |
| Enterprise | ~2% | ~20% | Hoher ACV, lange Sales-Cycle |

> ⚠️ **Methodischer Hinweis:** Diese Aufteilung basiert auf SaaS-Proxy-Daten, nicht auf produktspezifischen Messungen. Validierung nach Early-Access-Phase zwingend notwendig.

**Anmerkung zur Free-Tier-Limitierung:**
Die CEO-Idee setzt "3 Skills" als Free-Limit für den Scanner. Das ist vertretbar, aber es gibt ein Risiko: Nutzer mit nur 1–2 Skills (AI-Enthusiasten, Einsteiger) erleben den Mehrwert vollständig im Free Tier und haben keinen Upgrade-Trigger. Empfehlung: Das **Sicherheits-Scan-Detail-Report** als Pro-Feature positionieren — der Free Tier zeigt "2 Risiken gefunden", der Pro Tier zeigt was genau und wie zu beheben. Das ist ein stärkerer Upgrade-Trigger als eine numerische Limit-Mauer.

---

## Session-Design

**Ziel-Dauer:**

| Session-Typ | Ziel-Dauer | Frequenz |
|---|---|---|
| Erster Besuch (Onboarding + erster Scan) | 8–15 Minuten | Einmalig |
| Wiederkehrender Scan (neuer Skill prüfen) | 3–7 Minuten | Trigger-basiert |
| Pro-Session (Chat-Export-Analyse) | 15–25 Minuten | 1x pro Monat oder bei neuem Export |
| Advisor Light (Fragebogen) | 5–10 Minuten | 1x bei Erstnutzung |

**Frequenz:**
2–4 Sessions pro Monat bei aktiven Pro-Nutzern. Kein Daily-Use-Produkt.

**Begründung:**
Der Zielgruppen-Report ist hier sehr präzise: SkillSense ist ein **task-based Tool**, kein Daily Driver. Das hat direkte Konsequenzen für das Produkt-Design und die Erfolgsmessung:

- ❌ DAU/MAU sind ungeeignete Metriken für dieses Produkt
- ✅ Richtige Metriken: Feature Utilization Rate, Scan-Frequenz pro aktivem Nutzer, Pro-Conversion-Rate nach erstem Scan, Churn-Rate Pro-Tier

Das Session-Design muss diesen Nutzungsmuster antizipieren: Jede Session muss **sofort Wert liefern** (keine langen Onboarding-Flows, kein "Setup bevor du starten kannst"). Die 60-Sekunden-Ergebnis-Regel aus dem Core Loop ist deshalb keine nice-to-have UX-Entscheidung, sondern strukturell notwendig für Retention bei niedrig-frequenter Nutzung.

**Implikation für Notifications/Re-Engagement:**
Trigger-basiertes Nutzungsmodell bedeutet: Re-Engagement funktioniert nicht über Push-Notifications (kein Daily-Habit-Loop), sondern über **externe Trigger** — neue Skills die viral gehen auf Reddit/X, Anthropic-Updates die bestehende Skills brechen, Sicherheitsvorfälle im AI-Ökosystem. SkillSense sollte einen Newsletter/Update-Service anbieten der bei solchen Triggern aktiv wird ("Dieser neue Skill hat ein bekanntes Sicherheitsproblem — prüf jetzt ob du ihn hast").

---

## Tech-Stack Tendenz

**Empfehlung:**

```
Frontend:           Next.js 14+ (App Router) + TypeScript
Styling:            Tailwind CSS + shadcn/ui (Komponenten-Konsistenz)
Hosting:            Vercel (kostenloses Tier für MVP ausreichend)
Analyse-Engine:     JavaScript/TypeScript im Browser (WebWorker für Pro-Analyse)
Skill-Datenbank:    JSON-Dateien im Repo (MVP) → Supabase (Scale ab Phase 2)
Auth:               Clerk (einfachste Integration, DSGVO-konform für EU)
Payments:           Stripe (Standard, gut dokumentiert)
LLM-Calls:          Anthropic API (Claude Sonnet für Skill-Generierung)
```

**Begründung:**

Der Trend-Report bestätigt die Web-App-first Entscheidung durch harte Daten: Mobile App Downloads sanken 2025 zum **5. Mal in Folge** auf 106,9 Mrd. (-2,7% YoY), während PC/Desktop-Segment Rekordwachstum (+13% Revenue) verzeichnete (Sensor Tower, 2026). Die Plattformwahl ist damit durch Marktdaten bestätigt, nicht nur durch den CEO-Instinkt.

Zusätzlicher strategischer Vorteil der Web-App-Architektur: Kein App-Store-Review-Prozess. Ein Tool das Chat-Daten verarbeitet (auch client-side) würde in Apple App Store Reviews mit hoher Wahrscheinlichkeit Probleme bekommen. Web-App umgeht dieses Risiko vollständig und spart die 15–30% App-Store-Gebühren auf Subscription-Revenue.

Der Zielgruppen-Report bestätigt die Plattformverteilung: ~70% Desktop Web, ~25% Mobile Web. Dark Mode als Default ist korrekt — entspricht der Norm in der Developer-Community (primäre Zielgruppe).

**Einschränkung zur CEO-Idee:**
Die CEO-Idee nennt "React oder Next.js" als Option. Empfehlung: **Next.js ist die klare Wahl**, nicht gleichwertig zu plain React. Begründung: SEO-relevante Landing Page (Server-Side Rendering), API Routes für Stripe-Webhooks und optionale LLM-Calls, und bessere Skalierbarkeit für die kuratierte Skill-Datenbank. Plain React würde hier technische Schulden erzeugen.

---

## Abweichungen von der CEO-Idee

### Abweichung 1: Free-Tier-Limit-Mechanik

**Ursprünglich:** "3 Skills prüfen" als hartes Limit im Free Tier für den Scanner

**Angepasst:** Numerisches Limit beibehalten, aber **Detail-Report als Pro-Feature** positionieren — Free Tier zeigt aggregierten Score ("2 Sicherheitsrisiken gefunden"), Pro Tier zeigt spezifische Findings + Lösungsweg

**Begründung:** Der Competitive-Report zeigt dass die Zielgruppe bekannte Freemium-Muster (Grammarly, Notion) gewohnt ist. Ein hartes Zahlen-Limit ("du kannst keine weiteren Dateien hochladen") erzeugt Frustration. Ein Feature-Gate ("du siehst dass es ein Problem gibt, aber du brauchst Pro um zu verstehen welches") erzeugt Neugier und Conversion-Motivation — das ist der bewährtere Mechanismus laut SaaS-Benchmark-Daten.

---

### Abweichung 2: DACH-First statt global von Anfang an

**Ursprünglich:** Keine explizite geografische Priorisierung im CEO-Brief (gemischte Deutsch/Englisch-Referenzen)

**Angepasst:** DACH-First für MVP und Phase 2, englischsprachiger Rollout als Phase 2 parallel möglich

**Begründung:** Der Zielgruppen-Report identifiziert die DACH-Positionierung durch die deutschsprachigen Elemente im Pitch. Das ist strategisch korrekt für den MVP weil: (1) DSGVO-Compliance ist in DACH ein Kaufargument, in US eher neutral; (2) Deutsche Nutzercommunity für Claude wächst nachweislich (Community-Signale laut Zielgruppen-Report: Reddit r/ClaudeAI hat deutliche deutschsprachige Präsenz); (3) DACH-First ermöglicht scharfes Messaging bevor internationaler Rollout die Positionierung verwässert. English-Content-Unterstützung (Skill-Analyse ist sprachunabhängig) sollte trotzdem von Anfang an im Produkt vorhanden sein.

---

### Abweichung 3: Advisor Pro als Phase 1.5, nicht Phase 2

**Ursprünglich:** Advisor Pro (Chat-Export-Analyse) explizit als "nicht im MVP" kategorisiert

**Angepasst:** Advisor Pro sollte als **geschlossene Beta** parallel zum MVP-Launch vorbereitet werden — nicht im öffentlichen MVP, aber innerhalb von 4–6 Wochen nach Launch für Early-Access-Nutzer verfügbar

**Begründung:** Der Competitive-Report zeigt dass USP 5 (Chat-History als Empfehlungsbasis) der stärkste konzeptuelle Differentiator ist. Wenn SkillSense dieses Feature zu lange zurückhält, riskiert es dass Anthropic oder ein anderer Wettbewerber eine ähnliche Funktion einführt bevor SkillSense sie gelauncht hat. Das strategische Fenster für First-Mover-Position bei diesem spezifischen Feature ist zeitlich begrenzt. Empfehlung: MVP-Launch mit Scanner + Advisor Light + "Early Access für Advisor Pro" Warteliste — das generiert gleichzeitig Leads und Feedback für die Pro-Entwicklung.

---

### Abweichung 4: Zielgruppen-Messaging schärfen

**Ursprünglich:** Primärzielgruppe = "Claude Pro/Max Nutzer die Skills nutzen oder nutzen wollen"

**Angepasst:** Primärzielgruppe = "Claude Pro/Max Nutzer die **bereits** Skills installiert haben und **nicht sicher sind ob sie die richtigen haben**"

**Begründung:** Der Zielgruppen-Report zeigt: Nutzer ohne installierte Skills brauchen einen anderen Einstiegs-Pitch ("installiere von Anfang an die richtigen") als Nutzer mit 10+ installierten Skills ("finde heraus was davon du wirklich brauchst"). Die stärkste Emotion in der primären Zielgruppe ist **Unsicherheit über bestehende Installations-Entscheidungen**, nicht Neugier auf neue Skills. Das sollte die Landing Page Copy widerspiegeln.

---

## Stärken des Konzepts (datenbasiert)

### Stärke 1: Marktlücke ist real und unbesetzt

Der Competitive-Report hat nach bekannten Wettbewerbern gesucht und **kein einziges Tool gefunden das personalisierte Skill-Empfehlungen gibt**. Das ist ungewöhnlich klar als Marktlücke — normalerweise gibt es zumindest partielle Wettbewerber. Alle fünf kritischen Gaps die SkillSense adressiert (Personalisierung, Sicherheitsanalyse, Überlappungserkennung, verhaltensbasierte Empfehlungen,