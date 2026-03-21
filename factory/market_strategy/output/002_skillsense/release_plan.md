# Release-Plan-Report: SkillSense

---

## Release-Phasen

### Phase 1: Closed Beta (Advisor Pro Early Access)
- **Ziel:** Kernfunktionen unter realen Bedingungen validieren, insbesondere den Skill Scanner (42 Security-Pattern-Checks, Jaccard-Overlap-Detection) und den Advisor Light (Fragebogen). Gleichzeitig Warteliste für Advisor Pro aufbauen und erste qualitative Nutzerfeedback-Daten sammeln. Conversion-Funnel von Free → IAP Bridge (1,99 €) testen.
- **Dauer:** 4 Wochen
- **Teilnehmer:** 150–300 handverlesene Nutzer aus bestehenden Communities (Reddit r/ClaudeAI, r/PromptEngineering, deutschsprachige Dev-Channels auf Discord/Slack). Einladungsbasiert via Wartelisten-Formular auf der Landing Page. Kein öffentlicher Zugang. Schwerpunkt auf Primär-Personas: Developer und Content Pros mit nachweislich installierten Claude-Skills.
- **Erfolgskriterien:**
  - ≥ 60% der Beta-Nutzer führen mindestens einen vollständigen Scan durch (Feature Utilization Rate Kern-Feature)
  - ≥ 25% der Nutzer kehren innerhalb von 14 Tagen für einen zweiten Scan zurück (Rückkehr-Trigger validiert)
  - Scan-Ergebnis in unter 60 Sekunden für 95% der Uploads (technische Performance-Schwelle)
  - Qualitatives Feedback: Mindestens 40 ausgefüllte Feedback-Formulare mit offenen Antworten zu "Was hat dich überrascht?" und "Was fehlt?"
  - Advisor Pro Warteliste: ≥ 200 eingetragene E-Mail-Adressen mit explizitem Opt-in
  - 0 kritische Datenschutzvorfälle (Client-Side-Versprechen muss technisch verifiziert sein)

---

### Phase 2: Soft Launch (DACH)
- **Ziel:** Öffentliche Zugänglichkeit für DACH-Markt herstellen, Free-to-Pro-Conversion-Funnel scharfschalten (inkl. IAP Bridge und Subscription via Stripe), Advisor Pro für Early-Access-Warteliste freischalten (geschlossene Beta innerhalb des Soft Launch). Erstes Revenue validieren. SEO-Grundlage legen.
- **Dauer:** 6 Wochen
- **Region(en):** Deutschland, Österreich, Schweiz (DACH). Englische UI bereits vorhanden, aber Marketingkommunikation und Landing-Page-Copy primär auf Deutsch.
- **Erfolgskriterien:**
  - ≥ 500 registrierte Free-Nutzer bis Ende Woche 6
  - Free-to-Paying-Conversion ≥ 4% (Benchmark: 3–8% SaaS Freemium; Zielwert konservativ wegen Early-Stage)
  - ≥ 20 zahlende Pro-Nutzer (Monatlich oder Jährlich), davon mindestens 5 Jahresabo
  - IAP Bridge (1,99 € Single Scan) von mindestens 30 Nutzern genutzt — Konversions-Brücke funktionsfähig
  - Advisor Pro Closed Beta: ≥ 50 aktive Nutzer aus Warteliste, Net Promoter Score ≥ 35 für dieses Feature
  - Stripe-Integration fehlerfrei: 0 fehlgeschlagene Zahlungen ohne korrektes Error-Handling
  - Core Web Vitals: LCP < 2,5 Sek., CLS < 0,1 auf Desktop (Vercel/Next.js Baseline)

---

### Phase 3: Full Launch (DACH + EU + Englischsprachiger Rollout)
- **Ziel:** Skalierung auf gesamten europäischen Markt und parallel englischsprachige Märkte (UK, US, Kanada, Australien). Advisor Pro öffentlich verfügbar. Team-Tier aktiviert. PR-Welle und Community-Launch auf Product Hunt. SEO-Traffic als organischer Akquisitionskanal aktiv.
- **Datum/Zeitrahmen:** Woche 11–12 nach Beta-Start (ca. 3 Monate nach Phase-1-Beginn). Product-Hunt-Launch auf einen Dienstag oder Mittwoch legen (historisch höchste Upvote-Aktivität laut PH-Community-Daten).
- **Region(en):** Gesamte EU (DSGVO-Compliance bereits durch Web-First-Architektur gegeben), UK, US, Kanada, Australien. Keine aktive Lokalisierung beyond Englisch/Deutsch im Phase-3-Scope — Spanisch, Französisch als Phase-4-Option.

---

## Regionale Strategie

| Region | Phase | Begründung | Lokalisierung nötig |
|---|---|---|---|
| **Deutschland** | Phase 1 + 2 + 3 | Größter DACH-Markt; DSGVO als Kaufargument stark; iOS-Marktanteil ~58% unter Developers (überproportional zahlungsbereit); deutschsprachige Claude-Community nachweislich aktiv | Deutsch (vollständig): Landing Page, Onboarding, E-Mails, Error-States, Legal-Texte (AGB, Datenschutzerklärung §13 DSGVO) |
| **Österreich** | Phase 2 + 3 | Kleiner aber relevanter DACH-Markt; identische Sprache und DSGVO-Rahmenbedingungen; kein Zusatzaufwand wenn DE-Lokalisierung vorhanden | Deutsch (identisch mit DE, minimale Anpassungen bei Rechtsbegriffen — Datenschutzerklärung für AT-Recht prüfen) |
| **Schweiz** | Phase 2 + 3 | Höchste Kaufkraft im DACH-Raum; Dev-Community in Zürich/Basel stark; Preise können in CHF angezeigt werden (Stripe unterstützt CHF nativ) | Deutsch (DE-Version verwendbar); CHF-Preisanzeige empfohlen (9,99 CHF ≈ 10,40 €, psychologisch äquivalent) |
| **UK** | Phase 3 | Post-Brexit kein EU-DSGVO direkt, aber UK-GDPR identisch; englischsprachig; starke Tech- und Content-Pro-Community in London; kein App-Store-Overhead | Englisch (bereits durch englische UI-Basis vorhanden); GBP-Preisanzeige via Stripe: 8,99 GBP/Monat, 69 GBP/Jahr |
| **USA** | Phase 3 | Größter englischsprachiger SaaS-Markt; Claude-Nutzerbasis überproportional hoch; kein DSGVO aber CCPA relevant (California) — Client-Side-Architektur vereinfacht Compliance erheblich | Englisch; USD-Preise: 9,99 USD/Monat, 79 USD/Jahr (keine Anpassung notwendig — Preise bereits USD-kompatibel) |
| **Kanada / Australien** | Phase 3 | Englischsprachig; ähnliche SaaS-Zahlungsbereitschaft wie UK; kein signifikanter Zusatzaufwand wenn EN-Version live | Englisch (identisch mit US-Version); Lokale Datenschutzgesetze (PIPEDA für CA, Privacy Act für AU) durch Client-Side-Architektur weitgehend abgedeckt |
| **Frankreich / Spanien / Nordics** | Phase 4+ | Relevant aber nachrangig; erfordert echte Lokalisierung der UI und Legal-Texte; kein Phase-3-Scope | Französisch / Spanisch / je nach Land — eigenes Lokalisierungsprojekt nötig |

---

## App Store Submission

### Apple App Store
**Nicht zutreffend für Phase 1–3.**

SkillSense ist eine Web-App (Next.js, Vercel-Deployment). Kein nativer iOS-Build im MVP- und Launch-Scope. Diese Entscheidung ist durch drei Faktoren abgesichert:

1. **Revenue-Schutz:** Kein 15–30% Apple-Cut auf Subscription-Revenue (siehe Plattform-Strategie-Report: +16.548 €/Jahr bei 500 Nutzern durch Web-Direct)
2. **Review-Risiko eliminiert:** Tools die Chat-Daten verarbeiten werden unter Apple Guideline 5.1.1 (Data Collection and Storage) intensiv geprüft — auch bei Client-Side-Verarbeitung ist die Review-Kommunikation aufwendig und risikoreich
3. **Time-to-Market:** Kein Review-Prozess = Deployment in Minuten

**Falls Phase 4+ eine native iOS App vorsieht, gelten folgende Planungsgrundlagen:**

- **Review-Dauer:** 24–48 Stunden für Standard-Reviews (Apple-Durchschnitt 2024: ~1,5 Tage); bei erstmaligem App-Einreichung oder nach Ablehnung: 3–7 Werktage einplanen. Für Apps mit Datenschutz-sensitivem Scope (Dateiverarbeitung, auch client-side) realistisch 5–10 Werktage einplanen.
- **Häufige Ablehnungsgründe in dieser Kategorie (Productivity/Utility + File Processing):**
  - Guideline 5.1.1: Unklare Privacy-Nutrition-Label-Deklaration — auch wenn keine Daten gesendet werden, muss der Label korrekt ausgefüllt sein ("Data Not Collected" muss explizit angegeben werden)
  - Guideline 4.2 (Minimum Functionality): Wenn die App zu stark einem reinen Web-Wrapper ähnelt — native Features (Haptics, Share Sheet, Widget) müssen nachweisbar integriert sein
  - Guideline 3.1.1: Externe Zahlungslinks (Stripe) in der App sind verboten — StoreKit-Pflicht für In-App-Käufe; Subscription-Verwaltung muss über Apple erfolgen
  - Guideline 2.1: Crashes oder Performance-Probleme bei Review-Geräten (iPhone SE als Baseline-Testgerät bei Apple Reviews bekannt)

- **Checkliste vor Submission (Phase 4+ Referenz):**
  - [ ] Privacy Nutrition Label vollständig ausgefüllt (Data Not Collected für alle Kategorien verifiziert)
  - [ ] App Privacy Policy URL in App-Store-Connect hinterlegt und erreichbar
  - [ ] StoreKit 2 Integration für alle Käufe — kein externer Stripe-Link sichtbar
  - [ ] Alle genutzten APIs mit Purpose-String in Info.plist deklariert (File Access, etc.)
  - [ ] Kein Verweis auf andere Plattformen (Android, Web) in der App-UI
  - [ ] Testflight-Build mit mindestens 20 externen Beta-Testern mindestens 2 Wochen vor Submission
  - [ ] App funktioniert vollständig ohne Account-Erstellung (Apple Guideline 5.1.1 — Guest Mode)
  - [ ] Lösch-Account-Funktion direkt in der App zugänglich (Apple-Pflicht seit 2022)
  - [ ] Screenshots für alle erforderlichen Gerätegrößen (iPhone 6.7", 6.5", 5.5"; iPad 12.9" falls universal)
  - [ ] Age Rating korrekt gesetzt (SkillSense: 4+ oder 12+ je nach Content-Einschätzung)

---

### Google Play
**Nicht zutreffend für Phase 1–3.** Identische strategische Begründung wie Apple App Store.

**Falls Phase 4+ eine native Android App vorsieht:**

- **Review-Dauer:** 1–3 Werktage für Standard-Reviews (Google-Durchschnitt 2024); bei neuen Developer-Accounts: bis zu 7 Tage; bei Updates nach Policy-Verstoß: bis zu 14 Tage
- **Checkliste vor Submission (Phase 4+ Referenz):**
  - [ ] Data Safety Form vollständig ausgefüllt (Äquivalent zu Apples Privacy Nutrition Label)
  - [ ] Target API Level aktuell (Google-Pflicht: immer innerhalb von 1 Jahr nach aktuellem Android-Release)
  - [ ] Billing Library 6+ für In-App-Purchases (ältere Versionen werden ab 2025 abgelehnt)
  - [ ] User Choice Billing aktiviert für DE/AT/CH (reduziert Google-Fee auf 15% — lohnt sich ab Phase 4)
  - [ ] App Bundle (.aab) statt APK — Google-Pflicht seit 2021
  - [ ] Proguard/R8 aktiviert und mit korrekten Keep-Rules für keine versehentliche Code-Obfuskation
  - [ ] Lösch-Account-Funktion zugänglich (Google-Pflicht ab Ende 2023)
  - [ ] Screenshots und Feature-Graphic in korrekten Dimensionen (1024×500px Feature Graphic, 16:9 Screenshots)

---

## Launch-Tag Checkliste

### Infrastruktur & Technik
- [ ] Vercel Production-Deployment final verifiziert (nicht Preview-URL, sondern Custom Domain aktiv)
- [ ] Custom Domain mit SSL-Zertifikat (Let's Encrypt via Vercel automatisch, Gültigkeitsdatum prüfen)
- [ ] Vercel Serverless Functions: Kaltstart-Zeiten unter 1,5 Sek. gemessen (relevanter für Stripe-Webhook-Routes)
- [ ] Supabase Connection Pool korrekt konfiguriert für erwarteten Traffic-Peak (Phase-2-Launch: 500+ simultane Nutzer möglich)
- [ ] WebWorker-Analyse-Engine: Last-Test mit 50 simultanen Scan-Anfragen erfolgreich abgeschlossen
- [ ] Stripe Webhook-Endpunkt aktiv und mit korrektem Signing-Secret konfiguriert
- [ ] Stripe Test-Mode deaktiviert, Live-Keys in Vercel Environment Variables (nicht im Code-Repository)
- [ ] Clerk Authentication: Production-Instance aktiv (nicht Development-Instance)
- [ ] CORS-Header korrekt gesetzt für alle API-Routes
- [ ] Rate Limiting aktiv auf allen öffentlichen API-Endpunkten (empfohlen: 100 Requests/Minute pro IP via Vercel Edge Config oder Upstash Redis)
- [ ] CDN-Cache-Headers für statische Assets korrekt (Skill-Datenbank-JSON: Cache-Control: max-age=3600)

### Monitoring & Alerting
- [ ] Vercel Analytics aktiv (Core Web Vitals Monitoring)
- [ ] Sentry (oder äquivalentes Error-Tracking) in Production-Environment initialisiert mit korrektem DSN
- [ ] Sentry Source Maps hochgeladen für lesbares Stack-Trace-Debugging
- [ ] Uptime-Monitoring aktiv (empfohlen: Better Uptime oder UptimeRobot — kostenlose Tier ausreichend für MVP) mit Alert bei >30 Sek. Downtime an Gründer-Handy
- [ ] Stripe-Dashboard Webhook-Delivery-Rate in Echtzeit beobachtbar
- [ ] Supabase Dashboard: Aktive Verbindungen und Query-Performance als Baseline dokumentiert (für Vergleich bei Traffic-Spike)
- [ ] Alert konfiguriert wenn Fehlerrate > 1% der Scan-Anfragen (Sentry Performance Monitoring)
- [ ] Log-Aggregation aktiv (Vercel Log Drain zu Axiom oder Logtail — Free Tier ausreichend)

### Support & Kommunikation
- [ ] Support-E-Mail-Adresse aktiv (support@skillsense.app oder äquivalent) mit Auto-Responder (<4h Antwortzeit kommuniziert)
- [ ] Crisp Chat oder Tawk.to auf Landing Page und Dashboard eingebunden (kostenlos, Live-Chat für Launch-Tag)
- [ ] FAQ-Seite live (mindestens 10 Fragen zu: Datenschutz/Client-Side, Was ist ein Skill, Wie kündige ich, Warum kein Login nötig, Was sind die 42 Security-Checks)
- [ ] Feedback-Formular (Typeform oder Tally) in App verlinkt
- [ ] Discord- oder Slack-Community-Channel für Beta-Nutzer eingerichtet und Invite-Link in Onboarding-E-Mail
- [ ] Escalation-Prozess definiert: Wer entscheidet bei kritischem Bug an einem Samstag? (Kontaktliste intern dokumentiert)

### Marketing & Social Media
- [ ] Twitter/X-Account (@SkillSenseApp o.ä.) mit Launch-Tweet vorgeschrieben und terminiert (Launch-Tag 08:00 CET)
- [ ] LinkedIn-Post für B2B-Awareness (Team-Tier Messaging) formuliert und terminiert
- [ ] Product-Hunt-Listing vollständig: Tagline, Beschreibung, Maker-Kommentar, Gallery (min. 5 Screenshots + 1 Demo-GIF), Pricing korrekt eingetragen
- [ ] Product-Hunt-Launch für Phase-3-Datum geplant (Dienstag oder Mittwoch, 00:01 PST — PH-Tagesrhythmus)
- [ ] Outreach-Liste für Launch-Tag vorbereitet: 20–30 persönliche Nachrichten an Beta-Nutzer mit Bitte um PH-Upvote und ersten Review
- [ ] Reddit-Posts vorbereitet für r/ClaudeAI, r/PromptEngineering, r/SideProject (kein Spam: Mehrwert-fokussierter Post, kein reiner Werbepost)

### Content & SEO
- [ ] Sitemap.xml generiert und bei Google Search Console eingereicht
- [ ] robots.txt korrekt konfiguriert (keine kritischen Routes geblockt)
- [ ] Mindestens 3 Blog-Artikel live zum Launch (empfohlen: "Die 5 gefährlichsten Claude Skills 2025", "Wie prüfe ich einen Claude Skill auf Sicherheit?", "DSGVO und KI-Tools: Was Entwickler wissen müssen")
- [ ] OG-Tags und Twitter-Card-Meta-Tags auf allen Seiten korrekt (mit og:image in 1200×630px)
- [ ] Google Analytics 4 oder Plausible Analytics aktiv (Plausible empfohlen für DSGVO-Compliance ohne Cookie-Banner)
- [ ] Cookie-Banner wenn GA4 — alternativ: Plausible nutzen und Cookie-Banner vermeiden (entspricht dem DSGVO-by-Design-Versprechen)

### Legal & Compliance
- [ ] AGB live und rechtssicher (DACH-Recht: Widerrufsrecht, Vertragsschluss, Haftungsbeschränkung — Anwaltscheck empfohlen, Kosten: 300–800 €)
- [ ] Datenschutzerklärung nach DSGVO Art. 13/14 live (Stripe als Auftragsverarbeiter genannt, Clerk als Auftragsverarbeiter genannt, Anthropic API als Auftragsverarbeiter für Pro-Skill-Generierung genannt)
- [ ] Impressumspflicht erfüllt (DE-Recht: Pflichtangaben nach §5 TMG)
- [ ] Stripe Tax konfiguriert für automatische Mehrwertsteuer-Berechnung (EU-OSS für B2C-Umsätze ab 10.000 €/Jahr Pflicht)
- [ ] Zahlungsseite: Pflichtangaben nach §312j BGB sichtbar ("Kaufen" statt "Weiter" als CTA-Text)
- [ ] Auftragsverarbeitungsverträge (AVV) mit Stripe, Clerk, Vercel, Supabase abgeschlossen oder prüfen ob Standardklauseln der Anbieter ausreichen

### Backup & Rollback
- [ ] Rollback-Prozedur dokumentiert: Vercel ermöglicht 1-Klick-Rollback zum vorherigen Deployment — verantwortliche Person und Entscheidungsschwelle definiert (z.B.: Fehlerrate >5% für >10 Minuten = Rollback)
- [ ] Supabase: Automatische tägliche Backups aktiv (in Supabase Pro-Plan inklusive)
- [ ] Notfall-Maintenance-Mode implementiert: Statische HTML-Seite die bei kritischen Problemen deployed werden kann ("Wir sind gleich zurück — deine Daten sind sicher")
- [ ] Stripe: Zahlungsausfälle durch Dunning-Management konfiguriert (automatische Retry-Logik für fehlgeschlagene Abbuchungen)

---

## Post-Launch Plan (erste 30 Tage)

### Woche 1: Stabilisierung und Sofort-Feedback
**Priorität: Technische Stabilität und erstes qualitatives Feedback auswerten.**

- **Täglich:** Error-Rate in Sentry prüfen, Uptime-Log auswerten, Stripe-Zahlungsfehler reviewen
- Persönliche Dankes-E-Mail an alle Beta-Nutzer die auf Pro konvertiert haben (handgeschrieben, nicht automatisiert) — mit Frage: "Was hat dich zur Entscheidung gebracht?"
- Alle Support-Anfragen innerhalb von 4 Stunden beantworten — jedes Ticket ist qualitatives Nutzer-Feedback
- Reddit/Discord/X auf Erwähnungen monitoren (Google Alerts für "SkillSense" + Brand-Name einrichten)
- Kritische Bugs (P0/P1): Hotfix innerhalb von 24 Stunden deployen — Vercel ermöglicht das ohne Review-Prozess
- Erste Conversion-Funnel-Auswertung: Wo verlassen Nutzer den Onboarding-Flow? (Plausible oder GA4 Funnel-Report)
- Advisor-Pro-Feedback von Early-Access-Nutzern auswerten: Funktioniert die Chat-Export-Analyse für verschiedene Export-Formate und -Größen?

### Woche 2: Conversion-Optimierung Erstes Experiment
**Priorität: Free-to-Pro-Conversion-Rate verstehen und ersten A/B-Test starten.**

- Auswertung: Wie viele Nutzer sehen das "Detail-Report locked"-Gate und wie viele klicken auf "Pro freischalten"? (Conversion-Gate-CTR als erste Kernmetrik)
- A/B-Test st