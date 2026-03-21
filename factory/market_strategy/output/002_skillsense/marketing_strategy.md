# Marketing-Strategie-Report: SkillSense

---

## Marketing-Kanal-Analyse

### Effektivste Kanäle für die Zielgruppe

SkillSense adressiert eine tech-affine, community-aktive Zielgruppe die Kaufentscheidungen für digitale Tools stark über Peer-Empfehlungen, organische Entdeckung und trusted Content Creators trifft. Die Kanalbewertung basiert auf diesem Verhalten:

| Kanal | Relevanz | Begründung |
|---|---|---|
| **Reddit** (r/ClaudeAI, r/PromptEngineering, r/ChatGPT) | 🔴 Hoch | Primärer Entdeckungskanal für AI-Tools. Developer und Content Pros validieren neue Tools hier vor dem Kauf. Organische Reichweite bei relevantem Mehrwert möglich. |
| **LinkedIn** | 🔴 Hoch | B2B-Awareness für Persona "Content Pro" und "Business Analyst". Thought Leadership Posts über AI-Skill-Qualität funktionieren in diesem Segment sehr gut. |
| **YouTube** (DE) | 🟡 Mittel-Hoch | AI-Tutorial-Creator haben hohe Vertrauensebene bei Zielgruppe. Deutschsprachige Nische: ~50–500K Abonnenten überschaubar erreichbar. Langfristig wichtigster organischer Kanal. |
| **X / Twitter** | 🟡 Mittel | AI-Power-User sind auf X aktiv, besonders im englischsprachigen Segment. Für DACH-First weniger effizient, aber für Phase-2-Expansion relevant. Viralpotenzial bei richtigem Framing. |
| **Newsletter / E-Mail-Marketing** | 🟡 Mittel | Hohe Zahlungsbereitschaft in Newsletter-Zielgruppen (Ben's Bites, KI-Update, The Prompt). Kooperationen mit bestehenden KI-Newslettern erzielen qualifizierte Leads. |
| **SEO / Organische Suche** | 🟡 Mittel (langfristig: 🔴) | Mittel für Launch, aber strategisch wichtigster Kanal ab Monat 3+. Keywords wie "Claude Skills testen", "Claude Custom Instructions prüfen" haben aktuell niedrigen Wettbewerb. |
| **Product Hunt** | 🟡 Mittel | Klassischer Launch-Kanal für SaaS-Tools. Relevant für initiale Sichtbarkeit, Tech-affine Early Adopter und Backlink-Aufbau. Top-5-Ranking am Launch-Tag generiert Schneeball-Effekt. |
| **TikTok / Instagram Reels** | 🟠 Niedrig-Mittel | Zielgruppe ist hier weniger aktiv für Tool-Entscheidungen. Sekundär für Persona "AI-Enthusiast" (20–35 Jahre). Aufwand-zu-Ertrag-Verhältnis schlechter als Reddit/LinkedIn für DACH. |
| **Discord** (AI-Server) | 🟡 Mittel | Community-Building und direkte Zielgruppenansprache in bestehenden AI-Servern. Wichtig für Beta-Phase und Early-Access-Warteliste. |
| **Paid Ads (Meta/Google)** | 🟠 Niedrig (MVP) | Zu teuer und zu ungenau für eine eng definierte B2B-SaaS-Nische im MVP-Stadium. Erst sinnvoll ab validiertem Product-Market-Fit und klarem LTV. |

### Was machen erfolgreiche Wettbewerber

**Grammarly:** Content-Marketing-first (SEO-Artikel über Schreib-Fehler), YouTube-Ads mit klarem Before/After, Influencer-Kooperationen mit Produktivitäts-Creatorn. Kaum direktes Community-Marketing — Wachstum über Produktviralität (In-App-Branding im geteilten Text).

**Notion:** Fast ausschließlich Community-getrieben. Reddit, YouTube-Tutorials von Drittanbietern, Template-Gallery als Viralmechanismus. Paid UA minimal in der Wachstumsphase.

**Readwise:** Newsletter-first. Produktwachstum fast ausschließlich über Kooperationen mit anderen Produktivitäts-Newslettern und Twitter-Thought-Leadership. Kein signifikantes Paid-Marketing.

**Beobachtung für SkillSense:** Die stärksten Parallelen bestehen zu Readwise — niedrige Nutzungsfrequenz, hoher messbarer Nutzen, community-getriebenes Wachstum, Newsletter als Primärkanal. Die Readwise-Strategie (Owned Media + Newsletter-Kooperationen + organische Community-Präsenz) ist das direkteste Playbook für SkillSense.

### Quellen

- Paddle SaaS Report 2024 (SaaS-Kanal-Benchmarks)
- Grammarly / Notion / Readwise: öffentlich bekannte Marketing-Strategien (LinkedIn-Posts der Gründer, Podcast-Interviews 2023–2024)
- Reddit r/ClaudeAI, r/PromptEngineering: Community-Recherche 2024–2025 (qualitative Validierung)
- businessofapps.com: Mobile Game Marketing Costs 2025 (CPI-Benchmarks als Proxy)
- impact.com: Influencer Pricing Guide 2025

---

## Website-Entscheidung

### Empfehlung: **Ja**

### Typ: **Landing Page + leichtgewichtige Full Site**

```
Struktur:
  /              → Conversion-optimierte Landing Page (Pain → USP → CTA → Social Proof)
  /scan          → Einstieg in den Skill-Scanner (App Shell)
  /advisor       → Einstieg in den Advisor Light (Fragebogen)
  /blog          → SEO-Content (ab Woche 4 nach Launch)
  /pricing       → Detaillierte Preisübersicht mit FAQ
  /changelog     → Transparenz-Signal für tech-affine Nutzer (erhöht Vertrauen)
  /datenschutz   → DSGVO-Pflichtseite + aktives Marketing-Argument
```

### Begründung

SkillSense ist eine Web-App — die Website ist gleichzeitig das Produkt und das Marketing-Instrument. Eine reine Landing Page (Single Page) wäre zu limitiert weil:

1. **SEO braucht Tiefe:** Einzelne Keywords wie "Claude Skills prüfen", "Custom Instructions Sicherheit", "AI Skills DSGVO" brauchen eigenständige Seiten oder Blog-Posts um zu ranken. Eine Single Page kann nicht für mehrere Keywords gleichzeitig optimiert werden.

2. **Vertrauen braucht Fläche:** Tech-affine Nutzer prüfen Pricing-Seiten, Changelogs und Datenschutz-Seiten aktiv bevor sie zahlen. Diese Seiten müssen existieren und gepflegt sein.

3. **Der /changelog ist unterschätzt:** Für Developer-Zielgruppe ist ein öffentlicher Changelog ein starkes Vertrauenssignal — "das Team baut aktiv weiter". Das kostet nichts außer Disziplin.

Die Landing Page selbst folgt der im Concept Brief definierten 60-Sekunden-Logik:

```
Above the Fold:
  Headline:     "Hör auf, Skills zu raten. Lass dich beraten."
  Subline:      "Prüfe deine Claude-Skills in 60 Sekunden — kostenlos, 100% im Browser."
  CTA Primary:  [Skills jetzt prüfen — kostenlos]
  CTA Secondary: [Lieber den Fragebogen nutzen]
  Trust Signal: "Keine Registrierung. Keine Datenweitergabe. Läuft lokal."

Below the Fold:
  1. Wie es funktioniert (3 Steps visuell)
  2. USP-Kacheln: Personalisiert / Sicherheitsgeprüft / DSGVO by Design
  3. Social Proof (nach Beta: Zitate echter Nutzer)
  4. Preisübersicht kompakt
  5. FAQ (7–10 Fragen, SEO-relevant)
  6. Final CTA
```

### Geschätzte Kosten

| Komponente | Kosten | Anmerkung |
|---|---|---|
| Next.js Landing Page (Design + Entwicklung, Freelancer DACH) | 2.500–5.000 € | Falls zusammen mit App-Entwicklung: Overhead minimal |
| Vercel Hosting (MVP-Phase) | 0 € | Free Tier ausreichend bis ~50.000 Seitenaufrufe/Monat |
| Domain (.de + .com) | 20–40 €/Jahr | Beide registrieren, .de primary für DACH |
| Copywriting (professionell, DE) | 800–1.500 € | Alternativ: Eigenleistung mit Claude als Draft-Tool |
| Design-Assets (Illustrationen, Icons) | 0–500 € | shadcn/ui + Tailwind deckt viel ab; optionale Custom-Illustrationen |
| **Gesamt** | **3.320–7.040 €** | Falls Landing Page in App-Entwicklung integriert: unteres Ende realistisch |

---

## Pre-Launch Strategie

### Landing Page & Waitlist

**Empfehlung:** Live schalten **8 Wochen vor Launch** — nicht früher, nicht später.

Zu früh (>12 Wochen) erzeugt Erwartungen die das MVP nicht erfüllen kann und führt zu Ghosting der Warteliste. Zu spät (<4 Wochen) reicht nicht für organischen Aufbau.

**Features der Pre-Launch-Seite:**

```
Pflicht:
  ✅ E-Mail-Eintrag für Early Access (Mailchimp oder ConvertKit)
  ✅ Klare Erwartungssetzung: "Wir launchen im [Monat]. Du bist dabei."
  ✅ Eine-Satz-Pitch + 3 USP-Bullets
  ✅ "Wie es funktioniert" — drei Schritte, visuell

Optional aber empfohlen:
  ✅ Referral-Mechanismus: "Bring 3 Freunde — du bekommst 3 Monate Pro kostenlos"
     (Schafft viralen Loop schon vor Launch — bewährtes Muster: Dropbox, Superhuman)
  ✅ Counter: "Bereits X Nutzer auf der Warteliste" (ab 50 Einträgen aktivieren)
  ✅ Demo-GIF oder kurzes Screen-Recording (30 Sekunden) um die Kernmechanik zu zeigen
     ohne das Produkt freizugeben

Nicht auf Pre-Launch-Seite:
  ❌ Pricing (zu früh — erzeugt Commitment-Probleme wenn sich etwas ändert)
  ❌ Vollständige Feature-Liste (überwältigt und verspricht zu viel)
  ❌ Login / App-Zugang (ist noch nicht fertig)
```

**Wartelisten-Tool-Empfehlung:** ConvertKit (einfachste DSGVO-konforme Integration, gute Automatisierungs-Flows) oder Beehiiv wenn gleichzeitig ein Newsletter aufgebaut werden soll.

**Ziel-Warteliste:** 300–500 qualifizierte Einträge vor Launch (realistisch bei konsequenter Community-Präsenz in 8 Wochen).

---

### Social Media Teaser

**Plattformen:** LinkedIn (primär), Reddit (primär), X/Twitter (sekundär), YouTube Community Tab (falls Kanal bereits existiert)

**Content-Typen und Timeline:**

```
8 Wochen vor Launch — "Problem-Awareness-Phase":
  LinkedIn:  "Wie viele Claude-Skills hast du installiert? Weißt du was sie tun?"
             → Umfrage-Post. Ziel: Kommentare und Awareness schaffen.
  Reddit:    Authentischer Post in r/ClaudeAI:
             "I analyzed 50 popular Claude skills from GitHub — here's what I found"
             (Echter Content, kein Pitch. Link zu Pre-Launch-Seite am Ende.)

6 Wochen vor Launch — "Lösung-Teaser-Phase":
  LinkedIn:  Screen-Recording GIF: "Ich habe gerade meinen ersten Skill-Scan gemacht.
             Ergebnis: 2 Sicherheitsrisiken die ich nicht kannte." (Authentisch, kein Ad)
  X/Twitter: Thread: "42 Dinge die in Claude Skills schief gehen können — ein Thread"
             (Reichweite aufbauen, Expertise demonstrieren)
  Reddit:    Deep-Dive-Post: "Prompt Injection in Custom Instructions — wie erkenne ich das?"
             → Keine Erwähnung von SkillSense. Vertrauen aufbauen als Experte.

4 Wochen vor Launch — "Early Access Ankündigung":
  LinkedIn:  "Wir bauen SkillSense — der erste Skill-Analyzer für Claude-Nutzer.
             Early Access für die ersten 500 Nutzer auf der Warteliste."
  Reddit:    Show HN-ähnlicher Post in r/ClaudeAI:
             "I'm building a tool to analyze Claude skills for security and fit — WIP"
             Mit echten Screenshots. Community-Feedback aktiv einfordern.
  Newsletter: Erste E-Mail an Warteliste: "Was kommt, warum es gebaut wird, wie du
              früh reinkommst"

2 Wochen vor Launch — "Countdown-Phase":
  LinkedIn:  "Launch in 2 Wochen. Was wir gelernt haben aus 100+ Beta-Feedback-Sessions"
  Reddit:    Antworten in relevanten Threads (nicht pitchen — helfen)
  E-Mail:    Zweite Wartelisten-Mail: "Du bist auf der Liste — hier ist was dich erwartet"
             + Referral-Erinnerung
```

---

### Beta-Programm

**Typ:** Geschlossene Beta (Invite-only, kein öffentlicher Zugang)

**Begründung:** Ein offenes Beta-Programm in einer frühen Phase erzeugt unkontrollierbare Erwartungen und Churn bevor das Produkt polished genug ist. Für SkillSense — das stark auf Vertrauen und Sicherheits-Versprechen setzt — ist ein schlechtes erstes Erlebnis besonders schädlich.

**Ziel-Teilnehmerzahl:** 50–80 Nutzer (nicht mehr)

Begründung: Qualität vor Quantität. 50–80 aktive Beta-Nutzer liefern mehr verwertbares Feedback als 500 passive Tester. Auswahl-Kriterien: Developer-Hintergrund (Primär-Persona), mindestens 5 installierte Claude-Skills, aktiver Reddit/Discord-Account (Multiplikator-Potenzial).

**Dauer:** 3–4 Wochen vor offiziellem Launch

**Rekrutierungs-Kanäle:**
- Direkte Ansprache in r/ClaudeAI und r/PromptEngineering ("Looking for 50 beta testers...")
- Discord-Server: Anthropic Community, AI-Enthusiasten-Server
- LinkedIn: Direkte Nachrichten an Developer und Content Pros die AI-Posts schreiben
- Warteliste: Erste 50 Einträge bekommen automatisch Beta-Zugang

**Beta-Feedback-Struktur:**
```
Woche 1: Onboarding-Feedback (erste 60 Sekunden — Concept Brief-Kriterium)
Woche 2: Core Feature Feedback (Scanner, Advisor)
Woche 3: Pro-Feature-Interesse und Zahlungsbereitschaft validieren
Woche 4: Exit-Interview (5 Fragen per Typeform) + NPS-Messung
```

**Anreiz für Beta-Nutzer:** 6 Monate Pro kostenlos nach Launch als Dankeschön + namentliche Erwähnung im Changelog (Entwickler schätzen das).

---

### Press Kit

**Inhalte:**

```
Pflicht:
  ✅ One-Pager PDF (DE + EN): Produkt, USPs, Zielgruppe, Gründer-Story in 2 Seiten
  ✅ Logo-Package: SVG, PNG (verschiedene Größen, Light/Dark-Mode-Varianten)
  ✅ 5–7 annotierte Screenshots (mit Erklärungen was zu sehen ist)
  ✅ 60-Sekunden-Demo-Video (Screen-Recording, kein Voice-Over nötig für Press-Kit)
  ✅ Fact Sheet: Kernzahlen (Warteliste-Größe, Beta-Feedback-Quote, Launch-Datum)
  ✅ Gründer-Bio + Foto (Vertrauen und Kontakt für Journalisten)
  ✅ Pressekontakt-E-Mail (dediziert: press@skillsense.app)

Optional:
  ✅ Vergleichs-Grafik: "SkillSense vs. Blind installieren" (visuell, shareable)
  ✅ Zitate aus Beta-Feedback (mit Erlaubnis der Beta-Nutzer)
  ✅ B-Roll: kurze Screen-Recordings einzelner Features (für Video-Content-Creator)

Hosting:
  /press-Seite auf der Website (öffentlich zugänglich, kein Login)
  Alternativ: Notion-Seite als Press Kit (schneller zu erstellen, einfach zu teilen)
```

---

## Launch-Strategie

### Launch-Typ

**Empfehlung: Soft Launch → Global Launch (zweistufig)**

```
Stufe 1 — Soft Launch (Woche 1–2):
  Region:    DACH (DE, AT, CH)
  Zugang:    Warteliste-Einlösung + Product Hunt Launch
  Ziel:      Erste echte Nutzungsdaten, Conversion-Funnel validieren,
             kritische Bugs identifizieren bevor größere Wellen kommen

Stufe 2 — Global Launch (Woche 3–4):
  Region:    EU + Englischsprachiger Markt (Tech-Blogs, englische Reddit-Communities)
  Zugang:    Vollständig öffentlich, keine Warteliste mehr
  Ziel:      Skalierung auf erste 1.000 registrierte Nutzer
```

**Begründung:** SkillSense ist DACH-first positioniert und hat eine DSGVO-Compliance-Story die in DACH ein Kaufargument ist. Der Soft Launch in DACH erlaubt es, das Produkt in der Kernzielgruppe zu validieren bevor das englischsprachige Tech-Ökosystem (schnellere, lautere Community-Reaktionen) den Launch kommentiert. Ein Produktproblem das auf Hacker News breit diskutiert wird ist schwerer zu recovern als eines das in r/ClaudeAI angemerkt wird.

---

### Launch-Tag Plan

```
06:00 Uhr (MEZ) — Product Hunt Submission live schalten
  → Frühes Einreichen maximiert die Sichtbarkeit im PH-Tagesranking
  → Maker-Kommentar vorbereitet: ehrliche Story, kein Marketing-Speak

08:00 Uhr — E-Mail an Warteliste
  → Betreff: "Du warst auf der Liste. Jetzt kannst du rein."
  → Personalisiert: "Du bist Nummer [X] — danke für deine Geduld."
  → CTA: Direktlink zum Scanner, kein Umweg über Landing Page

09:00 Uhr — LinkedIn-Post (Gründer-Account)
  → Persönliche Launch-Story: Warum gebaut, was gelernt, was als nächstes
  → Kein Marketing-Copy. Authentischer Text.
  → Bitte um Unterstützung auf Product Hunt (direkter Link)

10:00 Uhr — Reddit Posts
  → r/ClaudeAI: "I built SkillSense — a tool to analyze your Claude skills for
     security risks and personal fit. Here's what I learned building it."
  → r/PromptEngineering: Technischer Post über die Sicherheits-Pattern-Analyse
  → Keine Cross-Posts zur gleichen Zeit — gestaffelt über den Tag

12:00 Uhr — X/Twitter Thread
  → "We're live. Here's the story of why SkillSense exists in one thread."
  → Retweet durch vorab identifizierte AI-Accounts anfragen

14:00 Uhr — Discord-Ankündigungen
  → In relevanten AI-Servern in passenden Channels ankündigen
  → Community-Guidelines beachten — kein Spam

16:00 Uhr — Follow-up LinkedIn Post
  → Erste Zahlen: "X Scans in den ersten 8 Stunden — das haben wir gelernt"
  → Echte Reaktionen aus der Community teilen (mit Erlaubnis)

18:00 Uhr — Product Hunt Update Kommentar
  → Aktiv auf Kommentare antworten (Product Hunt belohnt Engagement)
  → Kurze Zusammenfassung des Tages als Maker-Kommentar

Tag 1 Ziel: 200+ Website-Besucher, 50+ Scans, Top-5 Product Hunt in Kategorie
```

---

### PR & Presse

**Ziel-Outlets:**

| Outlet | Typ | Relevanz | Pitch-Ansatz |
|---|---|---|---|
| **t3n** (DE) | Tech-Magazin DACH | 🔴 Hoch | "Das erste Tool das Claude-Skills auf Sicherheitsrisiken prüft" — DSGVO-Winkel stark für dt. Leser |
| **Heise / iX** (DE) | Tech/Developer | 🔴 Hoch | Technischer Tiefen-Artikel: Prompt Injection in Custom Instructions — SkillSense als Lösung |
| **The Decoder** (DE) | KI-Fokus | 🔴 Hoch | KI-Ökosystem-Winkel: "Warum AI-Skills ein Sicherheitsrisiko sein können" |
| **Gründerszene** (DE) | Startup | 🟡 Mittel | Gründer-Story: Kleines Tool, echtes Problem, DACH-Built |
| **Ben's Bites** (EN) | KI-Newsletter | 🟡 Mittel | Kurz-Pitch: "New tool that does X" — passt in deren Format |
| **Product Hunt Newsletter** | Community | 🟡 Mittel | Automatisch bei gutem PH-Ranking |
| **Hacker News** (Show HN) | Dev-Community | 🟡 Mittel (Risiko) | Technischer Post — Community ist kritisch aber bei gutem Produkt powerful |

**Pitch-Ansatz:**

Der stärkste Nachrichtenwinkel für SkillSense ist **nicht** "neues Produktivitätstool" — das ist zu generisch. Die stärkeren Winkel sind:

```
Winkel 1 — Sicherheits-Winkel (für Tech-Medien):
  "Prompt Injection in Claude Skills: Ein unterschätztes Risiko — und wie
  man es erkennt" → SkillSense als Tool dazu erwähnen, nicht als Lead

Winkel 2 — DSGVO-Winkel (für DACH-Medien):
  "Das erste KI-Tool das Chat-Daten gar nicht erst auf Server lädt —
  warum Client-Side Processing der neue Standard sein sollte"

Winkel 3 — Marktlücken-Winkel (für Startup-Medien):
  "Claude Skills sind ein Milliardenmarkt ohne Qualitätskontrolle —
  SkillSense will das ändern"
```

**Pitch-Timeline:**
- 4 Wochen vor Launch: Press Kit versenden + Embargo-Anfrage (Artikel erscheint zum Launch)
- Launch-Tag: Follow-up E-Mail
- 1 Woche nach Launch: Erste Nutzungszahlen als Update-Hook anbieten

---

## App Store Optimization (ASO)

> **Vorbemerkung:** SkillSense ist eine Web-App ohne nativen App Store im MVP. ASO in klassischem Sinne (Apple App Store / Google Play) ist damit nicht relevant. Dieser Abschnitt wird daher als **Web-SEO-Strategie** interpretiert, die funktional dieselbe Rolle übernimmt: Auffindbarkeit durch Nutzer die aktiv nach einer Lösung suchen.

### Primäre Keywords (DE)

```
"Claude Skills prüfen"
"Custom Instructions sicherheit"
"Claude AI Skills analyzer"
"Claude Skills empfehlungen"
"Anthropic Skills test"
"Claude Prompt Injection prüfen"
"KI Skills DSGVO"
"Claude Skills Qualität"
```

**Begründung:** Diese Keywords haben aktuell sehr geringen Wettbewerb (der Markt ist jung), aber wachsende Suchvolumina. First-Mover-SEO-Positionierung jetzt aufzubauen ist strategisch wertvoll — in 12–18 Monaten werden diese Terms deutlich wettbewerbsintensiver.

### Sekundäre Keywords (DE + EN)

```
DE:
"Claude Custom Instructions optimieren"
"AI Workflow verbessern Claude"
"Claude Skills Datenbank"
"Prompt Engineering Tool kostenlos"
"Claude Sicherheit Tipps"

EN (für Phase-2-Rollout vorbereiten):
"Claude skills analyzer"
"Custom instructions security check"
"Best Claude skills 2025"
"Claude AI skill manager"
"Prompt injection detector"
```

### Screenshot-Strategie (für Web: Meta-Preview + Social Cards)

Da kein App Store, werden Screenshots als **Open Graph / Twitter Card Images** und **Blog-Illustrationen** eingesetzt:

```
Social Card 1 (OG-Default):
  Headline: "Hör auf Skills zu raten."
  Visual: Score-Dashboard mit drei Kacheln (✅ Gut / ⚠️ Prüfen / 🔴 Risiko)
  Subtext: "Kostenlos. Lokal. In 60 Sekunden."

Social Card 2 (Scanner-Feature):
  Visual: Drag-and-Drop-Interface mit Ladeanimation