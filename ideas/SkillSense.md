# SkillSense — Produktbrief für DriveAI AutoGen Factory

## Factory-Auftrag
Erstelle ein vollständiges Konzeptdokument für das Produkt "SkillSense" basierend auf diesem Brief.

---

## 1. Produktname
**SkillSense** — "Weißt du wirklich welche Skills du brauchst?"

## 2. Elevator Pitch
SkillSense ist eine Web-App die AI-Nutzern zeigt welche Skills sie wirklich brauchen, welche sie löschen können, und welche ein Sicherheitsrisiko sind. Statt Clickbait-Listen und "Top 10 Skills" Videos liefert SkillSense datenbasierte, personalisierte Empfehlungen — entweder durch einen geführten Fragebogen oder durch Analyse der eigenen Chat-Historie.

## 3. Das Problem
- Hunderte/tausende fertige Skills für Claude und GPT im Internet verfügbar
- YouTube/TikTok voll mit "diese 10 Skills musst du haben" Clickbait
- Nutzer installieren Skills die sich gut anhören, nicht die sie tatsächlich brauchen
- 90% der Nutzer haben wahrscheinlich die falschen Skills installiert
- Skills können sich gegenseitig widersprechen, überlappen oder sogar schädlich sein (Prompt Injection, Exfiltration)
- Niemand prüft ob installierte Skills überhaupt zum eigenen Nutzungsprofil passen
- "Mach eine Analyse und schreib auf was du willst" funktioniert nicht — die meisten wissen nicht was sie wollen

## 4. Die Lösung
Drei Kernfunktionen:

### 4.1 Skill Scanner (kostenlos)
- Nutzer lädt seine Skills hoch (ZIP, SKILL.md Dateien, oder Ordner)
- Sofortige Analyse: Qualitäts-Score (0-100), Sicherheits-Score (0-100), Format-Check
- Überlappungs-Check: Welche Skills widersprechen sich oder machen das Gleiche?
- Sicherheits-Scan: Prompt Injection, versteckte URLs, Scope Escalation, unsichtbare Unicode-Zeichen
- Multi-File-Skill Support: Prüft alle Dateien im Skill-Ordner, nicht nur SKILL.md
- Ergebnis: "3 von 8 Skills sind gut, 2 überlappen sich, 1 ist überflüssig, 2 haben Sicherheitsrisiken"

### 4.2 Skill Advisor Light (kostenlos mit Limit)
- Geführter Fragebogen: 8-12 Fragen zu Nutzungsverhalten
  - "Wofür nutzt du AI hauptsächlich?" (Coding, Schreiben, Recherche, Analyse, Kreativ, Business)
  - "Welche Tools/Plattformen nutzt du?" (VS Code, GitHub, Notion, Slack, etc.)
  - "Wie technisch bist du?" (Anfänger, Fortgeschritten, Entwickler)
  - "Was nervt dich am meisten bei AI?" (Zu lang, zu generisch, vergisst Kontext, etc.)
  - "Welche Sprache sprichst du mit AI?" (Deutsch, Englisch, gemischt)
  - "Wie viele Skills hast du installiert?" (0, 1-5, 5-15, 15+)
- Basierend auf den Antworten: Personalisiertes Skill-Profil
- Empfehlung: "Du brauchst wahrscheinlich diese 3-5 Skills" mit Erklärung warum
- Warnung: "Diese Skill-Typen brauchst du NICHT weil..."
- Kein Zugriff auf Nutzerdaten nötig — rein fragebogenbasiert

### 4.3 Skill Advisor Pro (kostenpflichtig)
- Nutzer exportiert seine Claude Chat-Historie (über Claude Settings → Export)
- Lädt den Export in SkillSense hoch
- Analyse läuft komplett im Browser (JavaScript) — Daten verlassen NIEMALS den Rechner des Nutzers
- Was analysiert wird:
  - Themenverteilung: 40% Coding, 30% Schreiben, 20% Recherche, 10% Sonstiges
  - Wiederkehrende Muster: "Du fragst regelmäßig nach Git-Hilfe aber hast keinen Git-Skill"
  - Fehlende Abdeckung: "Du machst viel Code-Review aber kein Skill unterstützt das"
  - Überflüssige Skills: "Dein Formatting-Skill wird nie getriggert weil du nie nach Formatierung fragst"
- Ergebnis: Präzise Empfehlungen basierend auf ECHTEM Nutzungsverhalten
- Optional: "Skill für dich erstellen" — generiert einen maßgeschneiderten Skill im Standard-Format

## 5. Zielgruppe
- **Primär:** Claude Pro/Max Nutzer die Skills nutzen (oder nutzen wollen) und nicht wissen welche
- **Sekundär:** GPT Plus Nutzer mit Custom GPTs / Custom Instructions
- **Tertiär:** Unternehmen die Claude Team/Enterprise nutzen und Skills für ihr Team standardisieren wollen

## 6. Technische Architektur

### Frontend (Web-App)
- React oder Next.js
- Hosting: Vercel oder Cloudflare Pages
- Responsive Design (Desktop + Mobile)
- Dark Mode als Default

### Skill-Analyse-Engine (Kernkomponente)
- Basiert auf SkillForge Pro Technologie (bereits gebaut und getestet):
  - Schema-Validierung (skill_schema.yaml Konzept)
  - Security Scanner (42 Pattern-Checks, Pure Python → portiert nach JavaScript)
  - Cross-Skill Analyzer (Überlappungs-Erkennung via Jaccard-Ähnlichkeit)
  - Qualitäts-Scoring (gewichtete Bewertung der Skill-Sektionen)
- Läuft komplett client-side im Browser für Datenschutz
- Kein Backend-Server nötig für die Analyse

### Advisor-Engine
- Fragebogen-Logik: Regelbasiertes Empfehlungssystem (kein LLM nötig für Light-Version)
- Chat-Analyse (Pro): JavaScript-basierte Textanalyse im Browser
  - Topic Modeling (Keyword-Extraktion + Clustering)
  - Pattern Detection (wiederkehrende Frage-Typen)
  - Skill-Gap-Analyse (erkannte Themen vs. installierte Skills)
- Skill-Generierung (Pro): LLM-Call via Anthropic API (mit Nutzer-API-Key oder Pay-per-Use)

### Skill-Datenbank
- Kuratierte Sammlung empfohlener Skills (von DriveAI geprüft und geforged)
- Jeder Skill in der Datenbank hat: SkillForge-Signatur, Security-Score, Qualitäts-Score
- Kategorisiert nach Nutzungsprofil (Coding, Writing, Research, Business, Creative)
- Versioniert — Updates werden geprüft bevor sie in die Datenbank kommen

### Datenschutz-Architektur (KRITISCH)
- DSGVO-konform by Design
- Skill Scanner: Dateien werden im Browser verarbeitet, nie an Server gesendet
- Advisor Light: Nur Fragebogen-Antworten, keine personenbezogenen Daten
- Advisor Pro: Chat-Export wird AUSSCHLIESSLICH im Browser analysiert (WebWorker)
  - Kein Upload auf Server
  - Keine Speicherung
  - Nutzer kann jederzeit die Seite schließen = Daten weg
  - Transparenz: Anzeige "Deine Daten verlassen deinen Rechner nicht"
- Kein Tracking, keine Analytics auf Nutzerdaten
- Kein Account nötig für Scanner und Advisor Light (optional für Pro)
- Datenschutzerklärung prominent und in einfacher Sprache

## 7. Monetarisierung

### Free Tier
- Skill Scanner: bis zu 3 Skills prüfen
- Advisor Light: Fragebogen + Basis-Empfehlungen
- Security Check: 1x pro Monat

### Pro Tier (~9.99€/Monat oder 79€/Jahr)
- Skill Scanner: unbegrenzt
- Advisor Pro: Chat-Export-Analyse
- Custom Skill Generation: bis zu 5 Skills pro Monat erstellen lassen
- Security Check: unbegrenzt
- Zugang zur kuratierten Skill-Datenbank (geprüfte Skills)
- Neue Skills werden automatisch auf Kompatibilität geprüft bevor Installation

### Team/Enterprise (Kontaktanfrage)
- Bulk-Analyse aller Skills im Unternehmen
- Skill-Standardisierung: einheitliches Format für alle Mitarbeiter
- Zentrale Skill-Verwaltung mit Sicherheits-Gate
- Custom Skill-Entwicklung

## 8. Abgrenzung — Was SkillSense NICHT ist
- Kein Skill-Marketplace (wir verkaufen keine Skills, wir beraten welche gebraucht werden)
- Kein Skill-Editor (dafür gibt es SkillForge Pro intern)
- Kein Chat-Assistent (wir analysieren, wir chatten nicht)
- Keine Browser-Extension die Chats mitliest (Datenschutz!)
- Kein Ersatz für Claude/GPT (wir machen die bestehende Nutzung besser)

## 9. MVP-Scope (Minimum Viable Product)
Für den ersten Launch reichen:
1. **Skill Scanner** — Upload, Qualität, Sicherheit, Überlappungen (Frontend-only)
2. **Advisor Light** — Fragebogen mit regelbasierten Empfehlungen
3. **Landing Page** mit klarer Positionierung: "Hör auf Skills zu raten. Lass dich beraten."
4. **5-10 kuratierte Skill-Empfehlungen** pro Nutzungsprofil als Startinhalt

Was NICHT im MVP:
- Advisor Pro (Chat-Analyse) — Phase 2
- Custom Skill Generation — Phase 2
- Team/Enterprise Features — Phase 3
- Mobile App — Phase 3

## 10. Wettbewerb
- **Direkt:** Nichts. Es gibt aktuell kein Tool das personalisierte Skill-Empfehlungen gibt.
- **Indirekt:** Clickbait-Videos ("Top 10 Skills"), GitHub Awesome-Listen (z.B. awesome-claude-skills), Anthropic's eigene Skill-Dokumentation
- **Vorteil:** SkillSense ist datenbasiert und personalisiert. Eine YouTube-Liste ist für alle gleich. SkillSense sagt dir was DU brauchst.

## 11. Risiken
| Risiko | Wahrscheinlichkeit | Mitigation |
|---|---|---|
| Anthropic baut sowas selbst ein | Mittel | First-Mover-Advantage + plattformübergreifend (Claude UND GPT) |
| Skill-Ökosystem wächst nicht | Niedrig | Trend zeigt klar nach oben, Skills sind in Free/Pro/Max/Team/Enterprise |
| Datenschutz-Bedenken der Nutzer | Hoch | 100% Client-side Verarbeitung, kein Upload, transparente Kommunikation |
| Zu wenig kuratierte Skills | Mittel | Starte mit 20-30 geprüften Skills, Community-Beiträge später |

## 12. Tech-Stack Empfehlung
- **Frontend:** Next.js 14+ (React, Server-Side Rendering, API Routes)
- **Styling:** Tailwind CSS (schnell, konsistent)
- **Hosting:** Vercel (kostenlos für MVP, skaliert automatisch)
- **Analyse-Engine:** JavaScript/TypeScript (läuft im Browser)
- **Skill-Datenbank:** JSON-Dateien im Repo (für MVP, Supabase für Scale)
- **Auth (wenn nötig):** Clerk oder Supabase Auth
- **Payments:** Stripe (für Pro Tier)
- **LLM für Skill-Generation:** Anthropic API (Claude Sonnet)

## 13. Factory-Anweisung
Erstelle aus diesem Brief ein vollständiges Konzeptdokument mit:
- Detaillierter Feature-Spezifikation pro Funktion
- Wireframe-Beschreibungen für jede Seite
- Datenmodell (welche Daten werden wie verarbeitet)
- API-Design (falls Backend-Endpunkte nötig)
- Datenschutz-Konzept (DSGVO-Checkliste)
- Phasenplan (MVP → Phase 2 → Phase 3)
- Geschätzter Aufwand pro Phase
- Go-to-Market Strategie
