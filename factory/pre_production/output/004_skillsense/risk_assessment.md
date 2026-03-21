# Risk-Assessment-Report: SkillSense

---

## Risiko-Übersicht (Ampel-Tabelle)

| Rechtsfeld | Risiko | Geschätzte Kosten | Zeitaufwand |
|---|---|---|---|
| 1. Monetarisierung & Glücksspielrecht | 🟢 | — | — |
| 2. App Store Richtlinien | 🟢 | — | — |
| 3. AI-generierter Content — Urheberrecht | 🟡 | 1.500–3.500 € einmalig | 2–3 Wochen |
| 4. Datenschutz (DSGVO / COPPA) | 🔴 | 4.000–9.000 € einmalig + 800–1.500 €/Jahr | 4–6 Wochen |
| 5. Jugendschutz (USK / PEGI) | ⚪ | — | — |
| 6. Social Features | ⚪ | — | — |
| 7. Markenrecht — Namenskonflikt | 🟡 | 1.200–2.500 € einmalig | 1–2 Wochen |
| 8. Patente | 🟡 | 800–1.500 € einmalig | 1–2 Wochen |
| 9. AGB / Nutzungsbedingungen Dritter (Anthropic ToS) | 🟡 | 500–1.000 € einmalig | 1 Woche |
| 10. Haftung / Disclaimer | 🟡 | 800–1.500 € einmalig | 1 Woche |

---

## Detailbewertung pro Feld

### 1. Monetarisierung & Glücksspielrecht

- **Risiko:** 🟢
- **Begründung:** Reines SaaS-Subscription-Modell ohne Zufallsmechanik, Lootboxen oder virtuellen Gegenwert. GlüStV 2021 (DE), GSpG (AT) und BGS (CH) greifen strukturell nicht. Kein EU-Land hat bisher Subscription-SaaS unter Glücksspielrecht gefasst. Das Modell ist regulatorisch unbedenklich — auch in den Jurisdiktionen die bei Lootboxen besonders aktiv waren (BE, NL).
- **Geschätzte Kosten:** Keine.
- **Einschränkung:** Falls in späteren Phasen randomisierte Skill-Bundles als Feature eingeführt werden sollten, wäre eine Neubewertung zwingend. Das ist im aktuellen Konzept nicht vorgesehen.

---

### 2. App Store Richtlinien

- **Risiko:** 🟢
- **Begründung:** Die Web-App-Entscheidung ist aus App-Store-Perspektive die richtige Wahl. Kein Apple Review-Prozess, keine 15–30 % StoreKit-Pflicht, kein Risiko eines Ablehnungs-Zyklus wegen Chat-Daten-Verarbeitung. Für die aktuelle Roadmap (MVP bis Phase 2) ist dieses Risiko nicht aktiviert.
- **Geschätzte Kosten:** Keine für Web-App.
- **Latentes Risiko:** Sobald eine native iOS-App in Betracht gezogen wird (Phase 3+), ändert sich die Bewertung auf 🟡. Apple Guideline 5.1 (Privacy) würde eine vollständige Privacy-Nutrition-Label-Überprüfung erfordern. Empfehlung: Diese Entscheidung bewusst auf Phase 3 verschieben und dann neu bewerten.

---

### 3. AI-generierter Content — Urheberrecht

- **Risiko:** 🟡
- **Begründung:** Kein akutes Blockier-Risiko, aber zwei strukturelle Schwachstellen. Erstens: Die kuratierte Skill-Datenbank enthält Skills aus Drittquellen (GitHub, Reddit, Community). Ohne klare Lizenzstrategie ist wörtliche Übernahme in DE rechtlich grenzwertig — der Schöpfungshöhe-Nachweis für kurze Prompt-Texte ist niedrig, aber nicht null. Zweitens: KI-generierte Skill-Vorschläge (Pro-Tier) müssen nach EU AI Act Art. 50 ab August 2025 als KI-generiert gekennzeichnet werden. Das ist kein Hindernis, aber ein Implementierungs-Pflichtpunkt der ohne UI-Anpassung eine Compliance-Lücke erzeugt.
- **Geschätzte Kosten:**
  - Anwaltskosten für Lizenzstrategie Skill-Datenbank: **1.000–2.000 €** (einmalig, IT-Rechtsanwalt DACH-Markt)
  - UI-Implementierung KI-Kennzeichnung: **500–1.500 €** (Entwicklungsaufwand)
  - **Gesamt: 1.500–3.500 € einmalig**
- **Alternative:** Skill-Datenbank von Anfang an ausschließlich mit CC-lizenzierten oder selbst erstellten Skills befüllen. Aufwand: höher initial, eliminiert das Lizenzrisiko vollständig. Empfehlung für MVP: Kombination — selbst erstellter Kern-Datensatz (30–50 Skills), Drittquellen erst nach Lizenzklärung integrieren.

---

### 4. Datenschutz (DSGVO / COPPA)

- **Risiko:** 🔴
- **Begründung:** Dies ist das einzige echte Blockier-Risiko im Portfolio. Das Problem ist nicht das Produkt-Konzept — das ist datenschutzfreundlich. Das Problem ist die **Lücke zwischen dem Marketing-Versprechen ("100% Client-Side / DSGVO by Design") und den tatsächlichen Datenflüssen im System.** Vier konkrete Risikopunkte:

  **Risikopunkt 1 — Irreführendes Datenschutz-Versprechen:**
  Client-Side gilt nur für die Chat-Analyse. Vercel (Hosting), Clerk (Auth), Stripe (Payments) und potenziell Anthropic (Server-Side-API-Calls für Skill-Generierung) verarbeiten alle personenbezogene Daten. Wenn die Landing Page "100% Client-Side" verspricht ohne diese Differenzierung, ist das nach Art. 5 DSGVO (Transparenzprinzip) irreführend. Im DACH-Markt, bei einer tech-affinen Zielgruppe die DSGVO kennt, kann das zu Reputationsschäden führen die schneller eskalieren als ein Bußgeld.

  **Risikopunkt 2 — Drittland-Transfer USA:**
  Alle vier Infrastruktur-Dienste (Vercel, Clerk, Stripe, Anthropic) sind US-amerikanisch. Seit dem Schrems-II-Urteil (2020) und dem EU-US Data Privacy Framework (2023) ist der Transfer zwar wieder rechtlich möglich — aber nur unter Bedingungen. Für Vercel und Stripe sind EU-Regionen verfügbar und sollten genutzt werden. Für Clerk und Anthropic (Server-Side-API) sind Standardvertragsklauseln (SCCs) nach Art. 46 DSGVO notwendig. Ohne diese sind die Transfers formell rechtswidrig.

  **Risikopunkt 3 — Fehlende Auftragsverarbeitungsverträge (AVV):**
  Art. 28 DSGVO verlangt mit allen Dienstleistern die personenbezogene Daten im Auftrag verarbeiten einen AVV. Vercel, Clerk, Stripe bieten Standard-DPAs an — diese müssen abgeschlossen und dokumentiert werden. Anthropic hat eine DPA veröffentlicht (Stand 2025), die für kommerzielle API-Nutzung abgeschlossen werden muss. Ohne abgeschlossene AVVs ist SkillSense bei einer Datenschutzprüfung formal nicht compliant — unabhängig davon wie datenschutzfreundlich das Produkt tatsächlich ist.

  **Risikopunkt 4 — COPPA (USA):**
  Da der primäre Markt DACH ist und die Zielgruppe 20–50 Jahre alt ist, ist COPPA (Children's Online Privacy Protection Act, USA) derzeit nicht aktiviert. Sobald SkillSense englischsprachigen US-Traffic anzieht, muss eine Altersabfrage oder ein klarer Disclaimer implementiert werden. Kein Blockier-Risiko für das MVP, aber ein Pflichtpunkt für den US-Rollout.

- **Geschätzte Kosten:**
  - Anwaltliche DSGVO-Beratung + Datenschutzerklärung + AVV-Prüfung: **2.500–4.500 €** (IT-Rechtsanwalt DACH, einmalig)
  - Technische Implementierung: Cookie-Banner, Consent-Management, Account-Deletion-Flow: **1.500–3.000 €** (Entwicklungsaufwand)
  - Laufende DSGVO-Compliance-Überprüfung (einmal jährlich): **800–1.500 €/Jahr**
  - **Einmalig gesamt: 4.000–7.500 €**
  - **Laufend: 800–1.500 €/Jahr**

- **Alternative bei unlösbarem Drittland-Problem:**
  Infrastruktur auf EU-only Anbieter umstellen. Konkret: Vercel EU-Region (bereits verfügbar), Lemon Squeezy statt Stripe (EU-Händler of Record, nimmt Stripe-Komplexität ab), Supabase EU-Region statt Clerk, Open-Source-Auth-Alternative (NextAuth.js) die keine eigenen Server nutzt. Das erhöht den Implementierungsaufwand um ca. 2–3 Wochen, eliminiert aber das Drittland-Risiko strukturell.

  > **Empfehlung:** Nicht auf EU-only-Stack umstellen — das ist Overkill. Stattdessen: Vercel EU-Region aktivieren, alle verfügbaren DPAs abschließen, SCCs für Anthropic und Clerk dokumentieren, und das Marketing-Versprechen präzisieren: "Deine Chats verlassen nie deinen Browser" statt "100% Client-Side". Das ist akkurater, genauso überzeugend, und rechtlich sauber.

---

### 5. Jugendschutz (USK / PEGI)

- **Risiko:** ⚪
- **Begründung:** Nicht relevant. Zielgruppe 20–50, kein spielerisches Element, keine gewaltdarstellenden oder sexuellen Inhalte, keine Social-Community-Funktion. USK und PEGI greifen nicht.

---

### 6. Social Features

- **Risiko:** ⚪
- **Begründung:** Keine Community-Features im MVP oder in den geplanten Phasen. Nicht relevant.

---

### 7. Markenrecht — Namenskonflikt

- **Risiko:** 🟡
- **Begründung:** Der Name "SkillSense" ist konzeptuell naheliegend und damit kollisionsgefährdet. Eine schnelle EUIPO-Recherche (EU-Markenamt) zeigt ob der Begriff bereits als Wortmarke in den Klassen 42 (Software-as-a-Service, IT-Dienstleistungen) oder 35 (Unternehmensberatung, Analyse) eingetragen ist. Im DACH-Markt gilt zusätzlich das DPMA (DE), ÖPA (AT) und IGE (CH). Internationale Markeninhaber die "SkillSense" oder ähnliche Begriffe halten könnten Abmahnung oder Unterlassungsklage einleiten — selbst wenn die Marke in einem anderen Land eingetragen ist, kann Verwechslungsgefahr geltend gemacht werden. Das Risiko ist nicht akut, aber die Konsequenz bei einem Treffer (Rebranding nach Launch) wäre erheblich teurer als eine Vorab-Recherche.
- **Geschätzte Kosten:**
  - Markenrecherche durch Anwalt (EUIPO + DPMA): **800–1.500 €** (einmalig)
  - Eigene EU-Markenanmeldung (Klassen 35 + 42): **1.500–2.500 €** (Anwaltsgebühren + EUIPO-Amtsgebühren, einmalig)
  - **Gesamt einmalig: 2.300–4.000 €** (Recherche + Anmeldung kombiniert)
  - Nur Recherche ohne Anmeldung: **800–1.500 €**
- **Alternative bei Namenskonflikt:** Rebranding vor Launch ist deutlich günstiger als nach Launch. Empfehlung: Markenrecherche als Woche-1-Aufgabe vor jeder weiteren Investition in Branding, Domain, oder Marketing-Materialien. Falls Konflikt gefunden wird: Namensvarianten wie "SkillSense AI", "SkillSense.io" prüfen oder konzeptionell alternatives Naming entwickeln.

---

### 8. Patente

- **Risiko:** 🟡
- **Begründung:** Zwei technische Kernfeatures verdienen eine Patent-Freiraumrecherche:

  **Jaccard-basierte Overlap-Detection für Prompt/Skill-Texte:** Der Jaccard-Algorithmus selbst ist seit Jahrzehnten public domain. Die Anwendung auf AI-Skills/Prompts als Überlappungs-Detektor ist konzeptuell neu — aber die Wahrscheinlichkeit einer spezifischen Patentierung genau dieser Anwendung ist niedrig. Das Risiko ist nicht null, weil im NLP/AI-Bereich große Akteure (Google, Microsoft, IBM) breite Anwendungspatente halten.

  **Security-Pattern-Matching für Prompt Injection:** Pattern-basierte Sicherheitsanalyse von Prompts ist ein aktives Forschungsfeld. Anthropic, OpenAI und Sicherheitsunternehmen wie Lakera haben in diesem Bereich Entwicklungen getätigt. Eine Patentrecherche sollte prüfen ob die spezifische 42-Pattern-Implementierung in bekannte Patentansprüche fällt.

  Der praktische Schutz für SkillSense als kleines Startup bei einer potenziellen Patentverletzung ist begrenzt — Patentstreitigkeiten mit großen Akteuren sind prohibitiv teuer. Das reale Risiko ist weniger "Klage" als "Cease-and-Desist die das Feature killt".

- **Geschätzte Kosten:**
  - Patent-Freiraumrecherche durch Patentanwalt (beide Features): **800–1.500 €** (einmalig, DACH-Markt)
  - Bei positivem Befund: Feature-Anpassung (technischer Aufwand, nicht juristisch quantifizierbar)
  - **Gesamt Recherche: 800–1.500 € einmalig**
- **Alternative:** Keine vollständige Patent-Clearance durchführen (kostet Zeit und Geld), aber Workaround-Architektur vorbereiten: Features so implementieren dass die Kernfunktion auch mit alternativen Algorithmen erbracht werden kann. Das ist ein pragmatischer Startup-Ansatz für ein Produkt das noch nicht marktvalidiert ist.

---

### 9. AGB / Nutzungsbedingungen Dritter (Anthropic ToS)

- **Risiko:** 🟡
- **Begründung:** SkillSense nutzt die Anthropic API für den Pro-Tier-Feature (Skill-Generierung via Claude). Anthropic ToS (Stand 2025, usage_policies.pdf) enthält drei Punkte die für SkillSense direkt relevant sind:

  **Punkt 1 — Kommerzielle Nutzung:** Anthropic erlaubt die kommerzielle Nutzung der API für Drittanbieter-Produkte. SkillSense-Nutzung ist grundsätzlich ToS-konform, sofern die API-Calls nicht für "harmful use cases" genutzt werden. Skill-Analyse und Skill-Generierung fallen nicht darunter.

  **Punkt 2 — Output-Ownership:** Laut Anthropic ToS gehen generierte Outputs an den API-Aufrufer (SkillSense bzw. End-User). Das bestätigt den Befund aus Abschnitt 3 (Urheberrecht).

  **Punkt 3 — Nutzungslimits und Kostenrisiko:** Die Claude-API ist pay-per-token. Bei unerwartetem Traffic-Anstieg (viraler Launch-Effekt) können API-Kosten exponentiell skalieren. Ohne Spending-Caps und Rate-Limiting auf SkillSense-Seite entsteht ein wirtschaftliches Risiko das zwar kein Rechtsrisiko ist, aber operativ kritisch werden kann.

  Zusätzlich: Anthropic ToS verlangt bei kommerzieller Nutzung für Produkte mit mehr als 60 API-Anfragen pro Minute eine Enterprise-Vereinbarung. Für das MVP ist das kein Thema, aber bei erfolgreichem Scale ein Compliance-Pflichtpunkt.

- **Geschätzte Kosten:**
  - Anwaltliche ToS-Prüfung (Anthropic + Stripe + Clerk + Vercel): **500–1.000 €** (einmalig, kann gebündelt mit DSGVO-Beratung aus Abschnitt 4 werden)
  - Rate-Limiting-Implementierung: Entwicklungsaufwand, kein direkter Rechtskosten-Block
  - **Gesamt: 500–1.000 € einmalig**
- **Alternative:** ToS-Änderungsrisiko ist real — Anthropic könnte die Nutzungsbedingungen anpassen. Empfehlung: Anthropic-API-Abhängigkeit als **Single-Point-of-Failure** in der Architektur markieren und Abstraktionsschicht einbauen die theoretisch auch OpenAI oder Mistral API nutzen könnte. Das ist keine Compliance-Maßnahme, aber eine strategische Resilienz-Maßnahme.

---

### 10. Haftung / Disclaimer

- **Risiko:** 🟡
- **Begründung:** SkillSense gibt Sicherheitsempfehlungen ("Dieser Skill ist ein Risiko") und löst damit potenziell Nutzeraktionen aus — Skill-Löschung, Skill-Austausch, Entscheidungen über das AI-Setup. Wenn eine Empfehlung falsch ist (False Positive: harmloser Skill als