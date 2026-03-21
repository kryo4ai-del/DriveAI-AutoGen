# Competitive-Report: SkillSense

## Vorbemerkung zur Datenlage

Die Web-Recherche-Ergebnisse beziehen sich auf **Card Games / Mobile Games** und sind für SkillSense **vollständig irrelevant**. SkillSense ist eine B2C/B2B Web-App im Bereich "AI-Skill-Analyse & Personalisierung" — kein Mobile Game. Die nachfolgende Analyse basiert daher auf **Marktkenntnis + strukturierter Recherche-Logik**, alle Einschätzungen sind entsprechend markiert.

---

## Wettbewerber-Kategorie(n)

| Kategorie | Beschreibung | Relevanz für SkillSense |
|---|---|---|
| **Direkte Konkurrenz** | Tools die AI-Skills/Prompts analysieren oder empfehlen | 🔴 Keine bekannt |
| **Indirekte Konkurrenz Tier 1** | Prompt-Bibliotheken & Kuratierungsplattformen | 🟡 Mittel |
| **Indirekte Konkurrenz Tier 2** | YouTube/TikTok Content zu AI-Skills | 🟡 Mittel |
| **Indirekte Konkurrenz Tier 3** | Prompt-Optimierungs-Tools | 🟢 Niedrig |
| **Plattform-Eigenentwicklung** | Anthropic / OpenAI native Features | 🔴 Hoch (strategisches Risiko) |

---

## Wettbewerber-Übersicht (Tabelle)

| App / Plattform | Publisher | Nutzer / Reichweite | Rating | Monetarisierung | Kernmechanik |
|---|---|---|---|---|---|
| **PromptBase** | PromptBase Ltd. | ~Schätzung: 500k+ registrierte User [Schätzung] | 3.8/5 ⭐ [Schätzung] | Marketplace-Commission (20%) | Kauf/Verkauf fertiger Prompts |
| **FlowGPT** | FlowGPT Inc. | ~Schätzung: 1M+ MAU [Schätzung] | nicht verfügbar | Freemium + Credits | Community-Prompt-Sharing |
| **Awesome-Claude / GitHub-Listen** | Community (Open Source) | Stars: 2k–15k je Repo [Schätzung] | N/A | Kostenlos | Kuratierte Link-Listen |
| **YouTube-Creator (AI-Tips)** | Diverse Creator | Einzelne Videos: 50k–2M Views [Schätzung] | N/A | AdSense + Affiliate | "Top X Skills"-Listicles |
| **Anthropic Skills-Dokumentation** | Anthropic | Alle Claude-Nutzer (~10M+) [Schätzung] | N/A | Kostenlos (Lead zu Claude Pro) | Offizielle Skill-Docs |
| **GPT Store (OpenAI)** | OpenAI | ~3M GPTs erstellt [Schätzung, OpenAI-Angabe 2024] | variabel | Revenue Share (angekündigt, limitiert) | Custom GPT Discovery & Distribution |
| **SnackPrompt** | SnackPrompt | nicht verfügbar | nicht verfügbar | Freemium | Prompt-Entdeckung + Voting |
| **Claude System Prompt Analyzer (einzelne OSS-Tools)** | GitHub-Indie-Devs | nicht verfügbar | N/A | Kostenlos | Einzelne Sicherheitschecks |

---

## Detailanalyse pro Wettbewerber

### 1. PromptBase

**Beschreibung:** Marktplatz für den Kauf und Verkauf von Prompts für GPT, Claude, Midjourney etc.

**Stärken:**
- Etablierte Marke im Prompt-Ökosystem
- Breite Plattform-Abdeckung (nicht nur Claude)
- Monetarisierung für Creator funktioniert

**Schwächen:**
- Fokus auf **Verkauf**, nicht auf **Analyse** oder **Personalisierung**
- Qualitätskontrolle minimal — Käufer wissen nicht ob ein Prompt zu ihrem Use-Case passt
- Kein Konzept von "Skills" im Claude-Sinne (Prompts ≠ strukturierte SKILL.md-Dateien)
- Keine Sicherheitsanalyse

**Nutzer-Beschwerden [Schätzung aus typischen Marktplatz-Mustern]:**
- "Habe einen Prompt gekauft der bei mir gar nicht funktioniert"
- "Keine Möglichkeit zu wissen ob der Prompt zu meinem Setup passt"
- Qualitätsschwankungen groß

**Relevanz für SkillSense:** Niedrig — anderes Produkt, aber zeigt dass Nutzer bereit sind für Prompt/Skill-Qualität zu zahlen ✅

---

### 2. FlowGPT

**Beschreibung:** Community-Plattform für das Teilen und Entdecken von Prompts und Custom GPTs.

**Stärken:**
- Große Community, Social Features (Likes, Comments, Remixes)
- Breite Kategorisierung nach Use Cases
- Niedrige Einstiegshürde

**Schwächen:**
- Vollständig crowd-kuratiert → Qualität unkontrolliert
- **Kein Personalisierungs-Layer** — User sehen was popular ist, nicht was zu ihnen passt
- Keine Sicherheitsanalyse der Prompts
- Kein Claude-spezifisches Skill-Format-Verständnis
- Spam und Duplikate sind bekanntes Problem

**Nutzer-Beschwerden [Schätzung]:**
- Überwältigende Menge ohne sinnvolle Filterung
- Qualität sehr unterschiedlich
- Keine Möglichkeit zu prüfen ob ein Prompt sicher ist

**Relevanz für SkillSense:** Mittel — zeigt den Bedarf nach Kuration und Personalisierung deutlich

---

### 3. GitHub Awesome-Listen (z.B. awesome-claude-prompts)

**Beschreibung:** Community-kuratierte Listen von empfohlenen Prompts/Skills auf GitHub.

**Stärken:**
- Kostenlos, transparent, open source
- Von echten Nutzern getestet (meistens)
- Versionskontrolle durch Git

**Schwächen:**
- **Statisch und nicht personalisiert** — gleiche Liste für alle
- Kein Sicherheits-Check der gelisteten Skills
- Kein Format-Standard, keine Qualitätsbewertung
- Wartung hängt von einzelnen Maintainern ab
- Technische Hürde für nicht-technische Nutzer

**Nutzer-Beschwerden [Schätzung]:**
- "Ich weiß nicht welche davon ich wirklich brauche"
- Viele veraltete Einträge
- Keine Erklärung warum ein Skill empfohlen wird

**Relevanz für SkillSense:** Hoch — das ist genau der Status Quo den SkillSense ersetzt

---

### 4. YouTube/TikTok AI-Content Creator

**Beschreibung:** Influencer und Creator die "Top X Claude Skills"-Videos produzieren.

**Stärken:**
- Massiver Reach (Millionen Views)
- Niedrige Nutzungshürde — Video ansehen reicht
- Emotional engaging (zeigt Results)

**Schwächen:**
- **Incentiv-Problem:** Creator optimieren für Views, nicht für Nutzermehrwert
- **Nicht personalisiert:** Eine Empfehlung für alle
- Kein Update-Mechanismus wenn Skills veralten
- Keine Sicherheitsanalyse
- Kein Check ob Skills sich widersprechen
- Verleitet Nutzer dazu Skills zu installieren die sie nie nutzen

**Nutzer-Beschwerden [Schätzung aus allgemeinem Social-Media-Muster]:**
- "Hab alle installierten Skills aus Videos — merke keinen Unterschied"
- "Weiß nicht mehr welcher Skill was macht"
- "Viele Videos zeigen den gleichen Kram"

**Relevanz für SkillSense:** Sehr hoch — **das ist der primäre Gegner** in der Nutzermindset-Frage

---

### 5. Anthropic Native (Claude Settings / Offizielle Docs)

**Beschreibung:** Anthropic's eigene Skill-Dokumentation und möglicherweise zukünftige native Tools.

**Stärken:**
- Höchstes Vertrauen bei Nutzern
- Direkte Plattform-Integration möglich
- Kein Onboarding-Aufwand

**Schwächen (aktuell):**
- **Keine Analyse-Funktion** für bestehende Skills
- **Keine Personalisierung** basierend auf Nutzungsverhalten
- **Keine Sicherheits-Prüfung** von Community-Skills
- Docs sind technisch und nicht nutzerzentriert
- Kein Cross-Skill-Conflict-Check

**Strategisches Risiko für SkillSense:**
> 🔴 **Hoch.** Wenn Anthropic eine "Skill Health"-Funktion in Claude Pro integriert, wird SkillSense als eigenständiges Tool stark unter Druck kommen. **Mitigation:** Plattform-Agnostizität (Claude + GPT) und tiefere Analyse als ein nativer Basic-Check.

---

### 6. GPT Store (OpenAI)

**Beschreibung:** OpenAIs Marktplatz für Custom GPTs.

**Stärken:**
- Integriert in ChatGPT — kein zusätzliches Tool nötig
- Ratings und Usage-Metriken sichtbar
- Breite Nutzer-Basis

**Schwächen:**
- Kein Personalisierungs-Layer ("was passt zu MIR?")
- Kein Security-Scanning der Custom GPTs
- Kein Überlappungs-Check über installierte GPTs
- Discovery durch Popularität, nicht durch persönlichen Fit

**Relevanz für SkillSense:** Mittel — zeigt den Marktbedarf, aber kein direkter Konkurrent für die Analyse-Funktion

---

## Feature-Vergleich (Tabelle)

| Feature | **SkillSense** | PromptBase | FlowGPT | GitHub-Listen | YouTube | Anthropic Docs | GPT Store |
|---|---|---|---|---|---|---|---|
| **Personalisierte Empfehlung** | ✅ Kern-Feature | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Sicherheits-Scan** | ✅ 42 Checks | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Überlappungs-Erkennung** | ✅ Jaccard-Algo | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Qualitäts-Score** | ✅ 0-100 | ❌ | 🟡 Votes | ❌ | ❌ | ❌ | 🟡 Stars |
| **Chat-Analyse (eigene Daten)** | ✅ Pro Feature | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **100% Client-Side** | ✅ | ❌ | ❌ | ✅ | N/A | N/A | ❌ |
| **DSGVO by Design** | ✅ | 🟡 | 🟡 | ✅ | ❌ | 🟡 | 🟡 |
| **Claude-spezifisch** | ✅ (+ GPT) | 🟡 | 🟡 | 🟡 | 🟡 | ✅ | ❌ |
| **Kein Account nötig** | ✅ (Free) | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ |
| **Kuratierte Datenbank** | ✅ geprüft | 🟡 ungeprüft | 🟡 Community | 🟡 Community | ❌ | ❌ | 🟡 Community |
| **Skill-Generierung** | ✅ Pro | ❌ | ❌ | ❌ | ❌ | ❌ | 🟡 manuell |
| **Kostenlos nutzbar** | ✅ (Tier) | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **B2B/Team-Features** | ✅ geplant | ❌ | ❌ | ❌ | ❌ | 🟡 | ❌ |

**Legende:** ✅ Vorhanden | 🟡 Teilweise/Eingeschränkt | ❌ Nicht vorhanden

---

## Gap-Analyse: Was fehlt im Markt

### 🔴 Kritische Gaps (SkillSense adressiert diese direkt)

**Gap 1: Personalisierung**
> Kein einziges Tool fragt "was nutzt du?" bevor es empfiehlt. Der Markt funktioniert nach Popularität, nicht nach individuellem Fit. Eine YouTube-Empfehlung gilt für einen Coding-Profi genauso wie für einen Blogger — das ist strukturell falsch.

**Gap 2: Sicherheits-Analyse**
> Prompt Injection, versteckte URLs, Scope Escalation in Skills — **niemand prüft das systematisch**. Mit wachsendem Skill-Ökosystem wird dies zum echten Sicherheitsproblem. SkillSense ist hier First-Mover.

**Gap 3: Überlappungs- und Konflikt-Erkennung**
> Wenn ein Nutzer 15 Skills hat, prüft niemand ob sich diese widersprechen oder gegenseitig neutralisieren. Das ist ein blinder Fleck im gesamten Markt.

**Gap 4: Datenbasierte Analyse des eigenen Verhaltens**
> Niemand nutzt die eigene Chat-Historie als Signal für Empfehlungen. Das ist konzeptuell der stärkste Differentiator von SkillSense — "zeig mir was ich wirklich tue, nicht was ich denke dass ich tue."

**Gap 5: Qualitäts-Standard für Skills**
> Es gibt kein standardisiertes Format, keine Qualitätsbewertung, keinen "SkillForge-Siegel"-Äquivalent. Der Markt ist formatlos.

### 🟡 Sekundäre Gaps

**Gap 6: Datenschutz-bewusstes Tool**
> Alle bestehenden Plattformen sind serverbasiert. Ein 100% client-