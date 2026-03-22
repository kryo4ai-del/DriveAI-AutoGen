# Design-Vision-Dokument: EchoMatch
## Version: 1.0
## Status: VERBINDLICH für alle nachfolgenden Pipeline-Schritte

---

## Design-Briefing (wird in jeden Produktions-Prompt injiziert)

EchoMatch ist ein Match-3-Puzzle-Spiel das sich visuell und emotional vollständig vom Candy-Crush-Industriemodell abkoppelt. Das Spielfeld ist dunkel — Mitternachtsblau-Schiefergrün (#0D0F1A bis #1A1D2E) als Grundschicht — und die Spielsteine sind selbstleuchtende Objekte die Licht emittieren statt reflektieren, realisiert durch Unity URP Bloom-Post-Processing und Emission-Maps. Die App fühlt sich an wie ein vertrautes Gespräch mit jemandem der dich wirklich kennt: ruhig genug zum Abschalten, lebendig genug um nicht aufzuhören. Energie-Level ist 6/10 — pulsierend und rhythmisch, niemals explodierend oder chaotisch. Navigation ist kontextuell statt statisch: es gibt keine feste Bottom-Bar mit fünf Icons, stattdessen reagiert die UI auf Tageszeit, Session-Phase und Quest-State. Animationen atmen mit 600–900ms Ease-In-Out statt in 200ms zu bursten. Haptik ist dreischichtig und narrativ bedeutsam. Sound ist Resonanz, nicht Explosion. Reward-Screens verzichten auf Konfetti und AMAZING-Schriften — stattdessen eine 1,5-sekündige goldene Farbverschiebung des gesamten Screens und eine lesbare Zusammenfassung der eigenen Spielhistorie. Jede Designentscheidung muss sich gegen diese Frage behaupten: Würde Candy Crush das genauso machen? Wenn ja, ist es falsch.

---

## Teil 1: Verbindliche Vorgaben

### 1.1 Emotionale Leitlinie

- **Gesamt-Emotion:** Vertraute Lebendigkeit — das Gefühl eines ruhigen Gesprächs mit jemandem der den eigenen Spielstil wirklich kennt; weder infantil noch kühl, sondern warm-präzise
- **Energie-Level:** 6/10 — pulsierend, rhythmisch, niemals chaotisch oder überwältigend
- **Visuelle Temperatur:** Tief-Organisch — Mitternachtsblau-Schiefergrün als Grundschicht, durchbrochen von warmen Bernstein- und Kupfer-Akzenten; Steine sind eigene Lichtquellen; kein Weiß, kein Candy-Neon, keine Hypersättigung

---

### 1.2 Emotion pro App-Bereich (PFLICHT)

| Bereich | Emotion | Energie | Beschreibung |
|---|---|---|---|
| **Onboarding (S003)** | Neugier + sofortige Kompetenz | 5/10 | Nutzer fühlt sich eingeladen, nicht instruiert — kein Zeige-Cursor, kein Overlay; das Spielfeld reagiert auf die erste Berührung wie Wasser auf einen Fingertipp; innerhalb von 5 Sekunden entsteht das Gefühl: "Das kann ich, das macht Klick" |
| **Core Loop / Match-3 (S006)** | Flow + stille Befriedigung | 7/10 | Wie das Knacken einer perfekten Walnuss — Match-Sound ist Resonanz nicht Explosion; KI-Levels fühlen sich maßgeschneidert an und erzeugen ein leises "genau für mich"-Gefühl; vollständiges Vergessen von Zeit und Außenwelt |
| **Reward / Ergebnis** | Wärme + Stolz | 5/10 | Kein Konfetti-Regen, kein AMAZING in 200pt — das Spielfeld atmet aus, der Screen verschiebt sich für 1,5 Sek. zu Gold, die eigene Spielhistorie erscheint als lesbare Geschichte |
| **Shop / Monetarisierung** | Vertrauen + ruhige Entscheidung | 3/10 | Shop öffnet sich wie ein hochwertiger Katalog — viel Luft, klare Hierarchie, kein roter BEST VALUE-Aufkleber; Kaufentscheidung fühlt sich selbstbestimmt an, nicht gepresst |
| **Social / Challenges** | Zugehörigkeit + spielerischer Ehrgeiz | 7/10 | Freunde erscheinen als Lichtpunkte auf der eigenen Map — ambient sichtbar, nie hinter einem Tab versteckt; Challenge-Einladung pulsiert wie ein zweiter Herzschlag; Verbindung ist warm, nicht kompetitiv-aggressiv |
| **Story / Narrative (S004)** | Intimität + Vorfreude | 4/10 | Wie das Umblättern einer Seite kurz vor Mitternacht — langsame atmende Übergänge, organische Texturen, ruhige große Sätze mit Raum; Story-Momente unterbrechen den Spielfluss nicht, sie belohnen ihn |
| **Home Hub (S005)** | Heimkommen + ruhige Dringlichkeit | 5/10 | Beim täglichen Re-Entry das Gefühl "hier bin ich, was erwartet mich heute" — lebendige Komposition statt symmetrische Kachel-Wand; Daily Quest dominiert dynamisch je nach Tageszeit |
| **Splash / Loading (S001)** | Erwartung | 3/10 | Das ruhige Durchatmen vor dem Eintauchen — Logo entsteht aus drei Steinen die matchen, kein Jingle, ein einzelner Kristallton, Stille davor und danach ist Teil des Designs |
| **Consent / DSGVO (S002)** | Respekt | 2/10 | Ehrliches Gespräch statt Kleingedrucktes-Versteck — Rising Card von unten, Spielfeld dahinter sichtbar durch Milchglas, menschliche Sprache, keine Dark Patterns |
| **Settings / Legal** | Neutralität + Respekt | 2/10 | Nutzer fühlt sich nicht wie ein Formular-Ausfüller — klare Struktur, menschliche Consent-Sprache, implizite Botschaft: "Wir verstecken nichts" |

---

### 1.3 Differenzierungspunkte (PFLICHT — mindestens 3)

| # | Differenzierung | Beschreibung | Betroffene Screens | Status |
|---|---|---|---|---|
| **D1** | **Dark-Field Luminescence** | Spielfeld-Hintergrund ist #0D0F1A bis #1A1D2E (tiefdunkles Blau-Grau). Spielsteine sind selbstleuchtende Objekte mit Unity URP Bloom-Post-Processing und Emission-Maps — sie emittieren Licht, sie reflektieren es nicht. Roter Stein = Glut. Blauer Stein = biolumineszentes Wasser. Hintergrund pulsiert subtil bei Combos. Farbtemperatur der Steine wechselt kapitelbasiert via ScriptableObjects: Kapitel 1 = kühle Töne, Kapitel 3 = warme Amber-Töne. Performant ab Snapdragon 678+ durch skalierbare Bloom-Intensität. | S001, S004, S006, S008, S009 | VERBINDLICH — keine Verhandlung |
| **D2** | **Kontextuelle Navigation** | Keine feste Bottom-Bar mit 5 Icons. Navigation reagiert auf Tageszeit, Quest-State und Session-Phase: 6–10 Uhr morgens = Daily Quest dominiert, Social minimiert; 12–14 Uhr = kompakte Commuter-Ansicht; 19–23 Uhr = Story-Hub-Teaser prominent, Shop-Nudge für Entspannungs-Session. Social-Nudges erscheinen als Lichtpuls auf Freundes-Avataren im Header statt als Push-Banner. Freunde sind als Lichtpunkte ambient auf der Level-Map sichtbar (Zenly-Prinzip) — kein separater Social-Tab nötig. | S005, S007, alle Hub-Screens | VERBINDLICH — keine Verhandlung |
| **D3** | **Implizites Spielstil-Tracking ab Sekunde 1** | Das Onboarding-Match (S003) erfasst unsichtbar: Pausenlänge zwischen Zügen (Grübler vs. Intuitiv), Zuggeschwindigkeit, Combo-Orientierung vs. schnelles Räumen. Kein Fragebogen, keine explizite Abfrage. Das erste echte KI-Level ist bereits personalisiert. Die narrative Hook-Sequenz (S004) passt ihr visuelles Setting an den erkannten Spieltyp an: Intuitiv-Schnell = kinetischere, städtischere Welt; Grübler = tiefere, mythologischere Welt. Personalisierung beginnt in Sekunde 1, ist für den Nutzer vollständig unsichtbar. | S003, S004, S006 | VERBINDLICH — keine Verhandlung |
| **D4** | **Post-Session-Screen als Poster / Share-Card** | Kein generischer Reward-Overlay mit Konfetti. Der Ergebnis-Screen ist als Poster-Ästhetik designed (Spotify Wrapped-Prinzip): große isolierte Zahl oder Satz auf dunklem Grund, eine Akzentfarbe, lesbare Zusammenfassung des eigenen Spielstils ("Du hast heute 3 Cascades in einem Zug ausgelöst"). Format ist nativ share-optimiert — Nutzer schicken es weil es wie ein Statement aussieht, nicht wie ein UI-Screenshot. | S008, S009 | VERBINDLICH — keine Verhandlung |
| **D5** | **Story-NPC als Interface-Brecher** | Narrative Figuren können außerhalb ihrer Story-Screens erscheinen und das Interface kommentieren (Duolingo-Owl-Prinzip). Beispiel: NPC taucht nach einem verlorenen Level im Home Hub auf und gibt einen kontextuellen Kommentar im Ton der Spielwelt — kein generisches "Try again!". Diese Momente sind selten (max. 1× pro Woche) und dadurch bedeutsam. Sind primär für virales Social-Sharing designed: Out-of-Character-Momente die Nutzer screenshotten. | S005, S008, S009 | VERBINDLICH — keine Verhandlung |

---

### 1.4 Anti-Standard-Regeln (VERBOTE — mindestens 4)

| # | VERBOTEN | STATTDESSEN | Betroffene Screens | Begründung |
|---|---|---|---|---|
| **A1** | Hypersaturierte Primärfarben auf weißem oder hellem Hintergrund — Candy-Crush-Palette, Knallrot/Knallblau/Knallgrün auf Weiß | Dunkle Grundpalette (#0D0F1A–#1A1D2E), selbstleuchtende Steine via Bloom-Shader, Bernstein- und Kupfer-Akzente, kapitelbasierte Farbtemperatur-Shifts | S006, S001, S004, alle Spielfeld-Screens | Das gesamte Genre cargo-cultet Candy Crush (2012); heller Hintergrund ist das stärkste visuelle Identitätsmerkmal des Einheitsbreis; Dunkelfeld differenziert sofort und ist Qualitätssignal für 18–34-Zielgruppe (Genshin, Alto's Odyssey, Robinhood) |
| **A2** | Feste Bottom-Navigation-Bar mit 4–5 statischen Icons die dauerhaft sichtbar ist | Kontextuelle Navigation die auf Tageszeit, Quest-State und Session-Phase reagiert; soziale Präsenz als ambient leuchtende Elemente auf der Level-Map; Long-Press-Previews und Swipe-Shortcuts als Haupt-Navigations-Geste | S005, S007, alle Hub-Screens | Identisches Mental-Model bei allen Wettbewerbern ohne Ausnahme; feste Bottom-Bar ist das generischste UI-Element des Mobil-Genres; kontextuelle Navigation folgt dem Nutzer statt ihn zu verwalten |
| **A3** | Konfetti-Regen, goldene 1–3-Sterne, "AMAZING!" / "GREAT!" in fetter Type über 100pt, Coin-Sprung-Animationen auf Reward-Screens | 1,5-sekündige goldene Farbverschiebung des gesamten Screens; lesbare Spielhistorie als Poster-Ästhetik; warme Pause statt visueller Überwältigung; Share-optimiertes Format statt Overlay | S008, S009 | Emotional infantil und visuell vollständig austauschbar — alle fünf Top-Wettbewerber nutzen identische Reward-Screen-Sprache; die Reduktion ist selbst das emotionale Statement (Robinhood-Prinzip) |
| **A4** | Roter "BEST VALUE!"-Banner schräg über Shop-Kacheln, Vollbild-Grid mit Produkt-Kacheln, roter Countdown-Timer als Druck-Element, identische Preisarchitektur $0.99/$4.99/$9.99/$19.99 ohne visuelle Differenzierung | Shop öffnet sich als hochwertiger Katalog — viel Luft, klare Hierarchie, kein Schreien; Preisarchitektur visuell klar strukturiert mit Blackspace; Vertrauen ist das Design; kein visueller Druckaufbau durch Farbe oder Timer | S010, alle Shop-Screens | Identische Store-Architektur bei allen Wettbewerbern; BeReal-Prinzip: das Weglassen von Druck-Design ist selbst das Statement; Zielgruppe 18–34 ist immun gegen generische Druck-Mechanik und reagiert auf wahrgenommenes Vertrauen mit höherer Konversionsrate |
| **A5** | Hand-Cursor der ersten Zug zeigt, Tutorial-Overlay mit abgedunkeltem Hintergrund, statische Dialog-Bubble mit erklärender Figur | Spielfeld erscheint ohne Overlay; subtiles einmaliges Pulsieren der Steine als organische Aufmerksamkeits-Lenkung nach 4 Sekunden Inaktivität (Scale 1.0→1.03→1.0 in 1,2 Sek.); erster Stein folgt dem Finger mit 20% Nachzieh-Elastizität wie durch Wasser; Entdeckung durch Spielen nicht durch Erklären | S003 | Identisches Onboarding bei allen Wettbewerbern; instruiertes Onboarding kommuniziert implizit Misstrauen in den Nutzer; entdeckendes Onboarding erzeugt sofortige Kompetenz-Emotion — kritisch für D1-Retention (Entscheidung in ersten 60 Sekunden) |
| **A6** | Burst-Partikel-Explosion beim Match als primäres Feedback | Resonanz-Puls: Stein-Match löst einen Ton aus der nachhallt statt berstet; Cascade-Töne steigen auf statt ab; Special-Steine formen sich via 400ms Morphing-Animation mit tiefem Haptik-Puls; dreischichtige adaptive Sound-Schicht die mit dem Spieltempo atmet | S006, S008 | Physikalisch vorhersehbare Burst-Effekte bei allen Wettbewerbern ohne Ausnahme; Resonanz ist psychologisch nachhaltiger als Explosion; aufsteigende Töne signalisieren Erfolg stärker als abfallende |

---

### 1.5 Wow-Momente (PFLICHT-Implementierung — mindestens 3)

| # | Name | Screen | Was passiert | Warum kritisch |
|---|---|---|---|---|
| **W1** | **Logo-Genesis** | S001 | Aus dem dunklen Hintergrund bilden sich drei Spielsteine in den App-Farben, ordnen sich zu einem Match, verschwinden mit einem weichen Resonanz-Puls (einzelner tiefer Kristallton), und aus diesem Puls formt sich das EchoMatch-Logo. Ladezeit ≤2 Sek. — die Animation ist nie fertig bevor sie endet, sie ist die Ladezeit. Bei Slow-Connection wiederholt der Puls sich ruhig wie ein Herzschlag-Echo. | Erste 2 Sekunden prägen den emotionalen Kontrakt — Nutzer erlebt sofort: diese App ist anders als Candy Crush; Logo-Genesis kommuniziert ohne Wort die Kernmechanik und visuelle Identität; kein anderer Wettbewerber hat einen Splash der selbst eine Mini-Geschichte erzählt |
| **W2** | **Der lebendige erste Stein** | S003 | Der erste Stein den der Nutzer berührt leuchtet von innen heraus auf und folgt dem Finger mit 20% Nachzieh-Elastizität — nicht pixelgenau, wie durch Wasser gezogen. Haptik: leichtes Ticken beim Drag-Start, mittleres Snap beim Einrasten (nicht beim Loslassen — am Snap-Moment), weiches kurzes Rumble wie eine verstummende Stimmgabel beim erfolgreichen Match. Cascade-Töne steigen auf. Kein Tutorial-Text, keine Erklärung — das Feld selbst ist der Lehrer. | Entscheidung über Installation-Retention fällt in den ersten 60 Sekunden; der erste Stein-Touch ist der emotionalste Moment des gesamten Funnels; Elastizität und Eigenleuchten kommunizieren sofort Premium-Qualität und erzeugen das Kompetenz-Gefühl das alle anderen Screens aufbauen |
| **W3** | **Goldene Ausatmung** | S008, S009 | Nach Level-Abschluss keine Konfetti-Explosion. Das Spielfeld atmet einmal aus — alle Steine verblassen sanft innerhalb von 400ms. Dann: der gesamte Screen-Hintergrund verschiebt sich in 1,5 Sek. zu warmem Gold (#C8960C, Sättigung 60%, nicht grell). In dieser Goldpause erscheint eine einzelne Zeile die den Spielstil des Nutzers beschreibt ("Heute: 3 Cascades. Durchschnittszug: 1,4 Sekunden."). Dann: Poster-Format-Share-Card die nativ geteilt werden kann. | Stärkster Kontrastmoment zum Genre — jeder der das zum ersten Mal sieht weiß sofort: das ist nicht Candy Crush; die goldene Pause ist emotional nachhaltiger als Konfetti-Überwältigung; Poster-Share-Card ist der eingebaute virale Mechanismus (Spotify Wrapped-Prinzip); dieser Moment wird auf TikTok geteilt weil er so anders aussieht |
| **W4** | **NPC Interface-Brecher** | S005, S008 | Nach einem verlorenen Level taucht ein Story-NPC als kleines Element im Home Hub auf und hinterlässt einen kurzen kontextuellen Kommentar im Ton der Spielwelt — nie generisch, immer zum Spielstil des Nutzers passend. Max. 1× pro Woche, dadurch selten und bedeutsam. Animation: NPC gleitet von der Bildschirmkante herein (300ms Ease-Out), bleibt 4 Sekunden sichtbar, zieht sich zurück. Tap auf NPC öffnet eine Mini-Story-Sequenz. | Duolingo-Owl-Prinzip angewendet auf narrative Spielwelt — Vierte-Wand-Bruch ist der viralste UI-Moment den Apps produzieren können; erzeugt emotionale Bindung an Charaktere außerhalb der Story-Screens; gibt Nutzern einen Screenshot-würdigen Moment der EchoMatch von allen Wettbewerbern unterscheidet |
| **W5** | **Spieler-Lichtpunkte auf der Level-Map** | S007 | Freunde-Avatare erscheinen als kleine, sanft pulsierende Lichtpunkte direkt auf ihrem aktuellen Level-Punkt der Map — ohne separaten Social-Tab. Ein Freund der gerade aktiv spielt pulsiert schneller (1 Puls/Sek.). Ein Freund der heute noch nicht gespielt hat: minimale Helligkeit, langsamer Puls. Challenge-Einladung: der Lichtpunkt des einladenden Freundes pulsiert in einer zweiten Farbe (Bernstein statt Weiß). Social-Präsenz ist immer ambient sichtbar, nie aufdringlich. | Zenly-Prinzip: soziale Aktivität passiert auf dem primären visuellen Layer; reduziert Tab-Depth auf null; macht soziale Verbindung zu einem natürlichen Teil der Spielwelt statt eines isolierten Features; erzeugt FOMO durch ambient sichtbare Aktivität ohne Push-Notification-Druck |

---

### 1.6 Interaktions-Prinzipien (PFLICHT)

**Touch-Reaktion:**
Jede Berührung erhält sofortiges visuelles Echo — der berührte Stein leuchtet innerhalb von 16ms auf (ein Frame). Drags haben 20% Nachzieh-Elastizität (das Objekt folgt dem Finger wie durch Wasser, nicht pixelgenau). Unmögliche Züge werden nicht mit Fehler-Feedback bestraft — der Stein federt neutral zurück, kein Fehler-Buzz, kein negativer Feedback-Loop. Snap-Feedback (Einrasten) erfolgt am Snap-Moment, nicht beim Finger-Loslassen.

**Animations-Prinzip:**
Atmend statt burstend. Standard-Ease ist Ease-In-Out über 600–900ms für alle narrativen und UI-Übergänge. Gameplay-Animationen sind schneller (Match-Auflösung: 300ms, Stein-Fall: physikbasiert mit leichtem Overshoot-Bounce 8%). Special-Stein-Entstehung: 400ms Morphing-Animation (Metall das sich selbst in eine Form zieht). Hintergrund-Puls bei Combo: Bloom-Intensität steigt von 0.4 auf 0.7 in 200ms, fällt in 600ms zurück. Kein Element animiert ohne Bedeutung — jede Animation kommuniziert Information oder Emotion.

**Feedback-Prinzip:**
Dreischichtig und narrativ bedeutsam:
1. Leichtes Ticken beim Stein-Drag-Start (Hinweis: Aktion beginnt)
2. Mittleres Snap beim Einrasten (Bestätigung: Zug registriert)
3. Tiefes Rumble bei Cascade-Combo: 3-Match = 80ms, 5-Match = 200ms, länger = mehr Gewicht; fühlt sich wie eine Stimmgabel an die langsam verstummt — nie wie ein Fehler-Buzz oder ein Alarm.

Kein negativer Feedback-Buzz für falsche Inputs — neutrale Rückfeder statt Bestrafung.

**Sound-Prinzip:**
Resonanz statt Explosion. Das Spielfeld hat eine adaptive Sound-Schicht mit drei Ebenen:
1. Bewegungs-Whoosh beim Drag (sehr leise, 20% Lautstärke)
2. Resonanz-Kling beim Match-Moment — ein Ton der nachhallt, kein Burst
3. Kaskaden-Töne beim Stein-Fall die aufsteigen statt abfallen (aufsteigend = Erfolg)

Special-Stein-Typen haben eigene Resonanz-Signaturen: Bomb = tiefes Wummern, Line-Clearer = hoher Sweep, Color-Bomb = kurze harmonische Akkord-Folge. Das Tempo der Ambient-Schicht beschleunigt organisch mit dem Spieltempo des Nutzers — langsame Züge = tiefes ruhiges Ambient, schnelle Züge = erhöhtes rhythmisches Tempo. Kein Ton überschreit die anderen — Mixing ist Teil des Designs, kein Afterthought.

Narrative Screens (S001, S002, S004): Stille ist aktiv eingesetzt als emotionales Medium. Sound erscheint gezielt, nicht dauerhaft.

---

### 1.7 Konflikte aufgelöst

| Konflikt | 17a wollte | Tech-Realität | Lösung |
|---|---|---|---|
| **Bloom-Performance auf Low-End-Android** | Vollständige Bloom-Post-Processing und Emission-Maps auf allen Geräten für maximale visuelle Differenzierung | Unity URP Bloom ist auf Snapdragon 600-Serie und älter performancekritisch; ca. 15–20% der Android-Installbasis in Tier-1-Märkten betroffen | Skalierbare Bloom-Intensität: High-End (Snapdragon 778+) = voller Bloom (Intensität 0.7); Mid-Range (Snapdragon 678) = reduzierter Bloom (0.4, kein Full-Screen-Post-Processing); Low-End = Emission-Map bleibt aktiv (Steine leuchten), Bloom deaktiviert, Hintergrund-Puls als einfacher Alpha-Fade statt Shader. Visuelle Differenzierung D1 bleibt auf allen Geräten erhalten — nur Intensität skaliert |
| **Kontextuelle Navigation und iOS HIG** | Navigation komplett ohne Bottom-Bar, rein kontextuell und gestenbasiert | Apples Human Interface Guidelines erwarten auf iOS Bottom-Tab-Bar als primäres Navigations-Pattern; Abweichung kann zu App-Review-Problemen führen; iOS-Nutzer sind auf Bottom-Bar mental konditioniert | Hybride Lösung: Eine minimale, sehr schlanke Bottom-Bar existiert als strukturelles iOS-Compliance-Element (3 Icons maximal: Home, Map, Profil — kein Shop-Icon, kein Social-Icon). Kontextuelle Elemente erscheinen als dynamische Layer über dieser Basis-Bar, die je nach Tageszeit und State die visuelle Prominenz wechseln. Die Bar selbst ist nicht das primäre Navigations-Erlebnis — die kontextuellen Overlays sind es. Anti-Standard-Regel A2 bleibt erfüllt: keine 5-Icon-Symmetrie, keine statische Dominanz der Bar |
| **Spielstil-Tracking vs. ATT-iOS und DSGVO** | Implizites Spielstil-Tracking ab Sekunde 1 ohne Fragebogen (D3) für sofortige KI-Personalisierung | ATT-Framework auf iOS limitiert Behavioral Tracking; DSGVO erfordert Rechtsgrundlage für Verhaltensanalyse; Kaltstart-Personalisierung ohne Consent ist rechtlich riskant | Spielstil-Tracking in S003 erfolgt ausschließlich on-device und wird im Consent-Screen (S002) klar und menschlich erklärt ("Wir lernen wie du spielst — dafür brauchen wir kurz dein OK."). Es handelt sich um First-Party-Gameplay-Daten, keine Third-Party-Tracking — liegt außerhalb des ATT-Scopes wenn kein Advertising-Network involviert. DSGVO-Rechtsgrundlage: Vertragserfüllung (Personalisiertes Spielerlebnis als Kernversprechen des Produkts). Differenzierungspunkt D3 bleibt vollständig erhalten |
| **Narrative Hook (S004) — Two-Version-Rendering** | Zwei verschiedene narrative Hook-Versionen basierend auf erkanntem Spieltyp aus S003 | Erhöhter Asset-Aufwand (doppelte Artwork-Produktion für Hook-Sequenz) und Rendering-Logik; erhöhte Erstladezeit wenn beide Versionen downgeloadet werden | Lösung via On-Demand Asset Loading: Beide Hook-Versionen sind als separate Asset-Bundles in Unity Addressables strukturiert. Nach S003 wird der erkannte Spieltyp lokal gesetzt (kein Server-Call nötig), und nur das entsprechende Bundle wird geladen — max. 800KB zusätzlicher Download im Onboarding-Flow. Ladezeit überbrückt durch Logo-Genesis-Animation (W1) die als natürliche Wartezeit fungiert |
| **Post-Session-Poster als Share-Card** | Poster-Design das nativ auf Social Media geteilt wird (Spotify Wrapped-Prinzip) | iOS Sharing-API und Android Intent-System erfordern Standard-Bildformate; dynamische Text-Generierung ("Du hast heute 3 Cascades ausgelöst") muss auf Device gerendert werden statt server-seitig | Poster-Screen wird via Unity UI Toolkit als Render Texture in 1080×1920px (Stories-Format) gerendert und in Gerät-Galerie gespeichert; Share-Button triggert nativen Share-Sheet mit dem gerenderten Bild. Text-Daten (Cascade-Anzahl, Zuggeschwindigkeit) kommen aus lokalem Session-State — kein Server-Call, keine Latenz. Format ist nativ für Instagram Stories, WhatsApp und iMessage optimiert |

---

*Dieses Dokument ist ab Kompilierung Version 1.0 die verbindliche Design-Referenz für alle nachfolgenden Pipeline-Phasen. Kein nachgelagerter Agent, kein Produktions-Prompt und keine technische Einschränkung darf die Kernpunkte D1–D5, A1–A6 und W1–W5 eliminieren. Anpassungen sind ausschließlich in der Form zulässig die in Abschnitt 1.7 dokumentiert ist: beste umsetzbare Alternative, nicht Streichung.*

---

# Design-Vision-Compiler: EchoMatch
## Teil 2: Empfehlungen, Micro-Interactions & Abnahme-Checkliste
### Version 1.0 — VERBINDLICH für nachgelagerte Pipeline-Schritte

---

## 2.1 Micro-Interactions (Top 15 — nach Priorität sortiert)

| # | Trigger | Unsere Reaktion | Screens | Aufwand | Priorität |
|---|---|---|---|---|---|
| **MI-01** | Nutzer berührt erstmals einen Stein im Onboarding | Stein leuchtet von innen heraus auf (Emission +40%), folgt dem Finger mit 20% Nachzieh-Elastizität — kein pixelgenaues Kleben, sondern Magnetik durch Wasser; nach Snap: kurzes weiches Rumble 80ms | S003 | Mittel | **HOCH** |
| **MI-02** | Erfolgreicher Match-3 oder höher | Kein Burst-Effekt — die gematchten Steine *resonieren*: kurzes Scale-Up 1.0→1.08→0.0 in 300ms mit Emission-Flare; gleichzeitig ein helles Kling-Ton der 1,2 Sek. nachhallt; Hintergrund-Hex pulsiert +5% Helligkeit in 200ms | S006 | Mittel | **HOCH** |
| **MI-03** | Special-Stein entsteht (Bomb, Line-Clearer, Color-Bomb) | Stein morpht sich über 400ms in neue Form — Metall-zu-Form-Animation, nicht Pop-Spawn; endet mit tiefem Haptik-Puls (120ms Rumble); jeder Typ hat eigenen Resonanz-Ton: Bomb = tiefes Wummern, Line = hoher Sweep, Color = Akkord-Folge | S006 | Hoch | **HOCH** |
| **MI-04** | Level erfolgreich abgeschlossen | Screen-weite Farbverschiebung zu Gold (#C9972A) über 1,5 Sek. Ease-In-Out; Spielfeld "atmet aus" (leichte Scale-Down-Animation 1.0→0.97→1.0); danach: lesbare Zusammenfassung der eigenen Zughistorie erscheint als ruhige Typografie — kein Konfetti, keine AMAZING-Schrift | S008 | Mittel | **HOCH** |
| **MI-05** | Cascade-Combo (3+ aufeinanderfolgende Matches) | Haptik eskaliert mit Combo-Tiefe: 3-Match = 80ms, 4-Match = 140ms, 5-Match = 200ms Rumble; Sound-Schicht beschleunigt organisch mit dem Tempo der Züge; Hintergrund-Pulsieren intensiviert sich subtil; keine explodierenden Partikel — nur Licht-Intensitätswellen | S006 | Hoch | **HOCH** |
| **MI-06** | Falscher Zug / unmöglicher Move | Stein federt mit Ease-Back-Out zur Ursprungsposition zurück (250ms); **kein** Fehler-Sound, **kein** rotes X, **keine** Buzz-Haptik — neutrale federnde Physik; der Nutzer wird nicht bestraft, er wird sanft korrigiert | S006 | Niedrig | **HOCH** |
| **MI-07** | App-Start / Splash-Sequenz | Drei Steine in Spieler-Palette-Farben erscheinen aus dem #0D0F1A-Hintergrund, ordnen sich zu Match, verschwinden mit Resonanz-Puls, aus dem Puls formt sich das Logo; bei Slow-Connection: Puls wiederholt sich ruhig als Herzschlag-Echo; Gesamtdauer ≤2 Sek. bei normaler Verbindung | S001 | Mittel | **HOCH** |
| **MI-08** | Consent-Toggle wird aktiviert (DSGVO/ATT) | Toggle wechselt mit weichem Haptik-Puls (40ms) + visueller Emission-Spur entlang der Toggle-Bahn; kein harter Klick-Sound — stattdessen ein leises, warmes Klicken wie ein Lichtschalter in einem ruhigen Raum | S002 | Niedrig | **HOCH** |
| **MI-09** | Tägliches erstes App-Öffnen (Home Hub) | Kurzer atmosphärischer Entry-Ton (2 Sek.) — Morgen (6–10 Uhr) = heller, klarer Ton; Abend (19–23 Uhr) = wärmerer, dunklerer Ton; Daily-Quest-Card fährt mit leichtem Bounce (Ease-Out-Back) von unten ein; Return-Visits desselben Tages = kein Sound, nur sanfte Opacity-Fade | S005 | Mittel | **HOCH** |
| **MI-10** | 4 Sekunden Inaktivität auf Spielfeld | Eine Stein-Reihe beginnt organisch zu "atmen" — Scale 1.0→1.03→1.0 in 1,2 Sek. Loop; kein Pfeil, kein Text, kein Zeige-Cursor; nach weiteren 4 Sek. ohne Interaktion: zweite Reihe beginnt ebenfalls zu atmen mit leichtem Zeitversatz (Kanon-Prinzip) | S006 | Niedrig | **MITTEL** |
| **MI-11** | Long-Press auf Daily Quest-Block | Peek-and-Pop: Level-Preview erscheint als schwebendes Overlay-Card (Depth-of-Field dahinter erhöht sich); beim Loslassen ohne Navigation: Card sinkt zurück mit Ease-In; beim Loslassen mit Wisch-rechts: direkt ins Level — kürzester Weg zum Core Loop | S005 | Mittel | **MITTEL** |
| **MI-12** | Freund-Avatar im Header pulsiert (Social-Nudge) | Kleines Licht-Puls-Icon auf Freundes-Avatar — nicht als Push-Banner, nicht als Badge-Counter; Pulse hat Herzschlag-Rhythmus (0,8 Sek. Intervall); Tap auf Avatar öffnet Kontext-Card mit Challenge-Details; kein separater Social-Tab nötig | S005, S007 | Mittel | **MITTEL** |
| **MI-13** | Letzten 3 Züge eines Levels | Züge-Counter wechselt von neutraler Schrift zu warmem Bernstein (#C9972A); leichte Puls-Animation auf dem Counter (Scale 1.0→1.05→1.0 pro Zug); kein dramatischer Alarm-Sound — stattdessen werden die Ambient-Töne des Spielfelds leise gedämpft, was Stille als Spannung nutzt | S006 | Niedrig | **MITTEL** |
| **MI-14** | Story-Frame-Übergang in Narrative Hook | Parallax-Blend zwischen zwei Standbildern: Vordergrund bewegt sich mit 1,4× Geschwindigkeit des Hintergrunds; letzter Frame friert für 2 Sek. ein bevor Tap-to-Continue erscheint; diese erzwungene Pause ist Teil des Designs — kein sofortiger Weiter-Button | S004 | Hoch | **MITTEL** |
| **MI-15** | Shop-Eintritt | Shop öffnet sich als Katalog-Aufschlag: Seiten-Flip-Animation von rechts (nicht Modal-Pop, nicht Slide-Up) in 600ms Ease-In-Out; viel Whitespace-Äquivalent (hier: Dark-Space) zwischen Produkten; kein roter Aufkleber, keine animierten Preis-Badges; erster Scroll zeigt immer zuerst die kostenlosen Optionen | S010 | Mittel | **NIEDRIG** |

---

## 2.2 UX-Innovationen (Top 5 — nach Machbarkeit × Impact)

| Innovation | Beschreibung | Aufwand | Priorität |
|---|---|---|---|
| **UXI-01: Silent Persona Engine** | Ab S003 misst die App unsichtbar: Pausenlänge zwischen Zügen (Grübler vs. Intuitiv-Spieler), Zuggeschwindigkeit, Combo-Suchmuster. Diese drei Werte erzeugen eine Spieler-Persona ohne ein einziges Formular-Feld. Das erste KI-Level passt sich dieser Persona an. Die Story-Hook (S004) zeigt eine persona-passende Variante: Intuitiv-Spieler = kinetisch/urban, Grübler = mythologisch/tief. Technisch: drei Float-Werte in PlayerPrefs, KI-Mapping via ScriptableObject-Lookup-Tabelle. Datenschutz-konform: alle Daten lokal, kein Backend-Call für diese Funktion. | Mittel — 3 Spieler-Personas, 2 Story-Varianten, 1 Level-Difficulty-Offset | **HOCH** |
| **UXI-02: Kontextuelle Navigation ohne Bottom-Bar** | Statt statischer 5-Icon-Bar: ein kontextuelles Navigation-Cluster das sich je nach Tageszeit, Quest-State und Session-Phase neu konfiguriert. Morgen: Quest-Primär, Social-Sekundär, Shop-Tertiär. Abend: Story-Primär, Quest-Sekundär. Commuter-Modus (12–14 Uhr): alle nicht-essentiellen Elemente kollabieren. Freunde sind als Lichtpunkte auf der Level-Map ambient sichtbar — kein separater Tab. Technisch: Time-based State Machine in einem NavigationController-Component; drei Konfigurationen via ScriptableObjects; keine dynamische Backend-Logik nötig. | Mittel — 3 Nav-Konfigurationen, 1 State-Machine, Level-Map-Overlay für Social-Lichtpunkte | **HOCH** |
| **UXI-03: Adaptive Sound-Schicht im Core Loop** | Das Spielfeld hat eine reaktive Ambient-Schicht: Basis-Ambient-Tempo und -Intensität skalieren mit dem Zug-Tempo des Nutzers. Langsame Züge = ruhiges, tiefes Meeres-Ambient. Schnelle Züge = das Tempo der Resonanz-Töne beschleunigt organisch mit. Combo-Intensität erhöht den Ambient-Layer-Mix (3 Schichten, automatisch geblended). Kein Ton überschreit einen anderen — Mixing-Verhältnisse sind festgelegt und unveränderlich. Technisch: Unity Audio Mixer mit Exposed Parameters, die per Animator-Curve gesteuert werden; kein Echtzeit-DSP nötig. | Mittel — 3 Audio-Schichten, 1 Mixer-Graph, Tempo-Detection-Skript | **HOCH** |
| **UXI-04: Pre-Primer für ATT-Consent** | Der iOS-ATT-System-Dialog erscheint erst nachdem ein eigener Screen vollständig erklärt hat was ATT in menschlicher Sprache bedeutet: "Wir fragen dich gleich ob dein Gerät uns helfen darf relevante Angebote zu zeigen — du kannst Nein sagen, die App funktioniert trotzdem vollständig." Erst dann wird requestTrackingAuthorization aufgerufen. Nachweislich +15–25% ATT-Akzeptanzrate in vergleichbaren Implementierungen. Technisch: Eigener Modal-Screen vor dem ATT-Prompt; kein aufwändiges Backend; iOS-only Feature-Flag. | Niedrig — 1 Screen, 1 Text-Block, 1 Feature-Flag für iOS | **HOCH** |
| **UXI-05: Reward-as-Narrative statt Reward-as-Spectacle** | Level-Abschluss zeigt keine generische Score-Animation. Stattdessen: 1,5-sekündige Gold-Farbverschiebung des gesamten Screens, danach eine kurze lesbare Zusammenfassung der eigenen Partie: "Du hast 3 Combos in Folge gespielt. Dein bisher schnellstes Level." Diese Sätze sind aus 4–5 Vorlagen generiert und mit echten Session-Daten befüllt. Emotional: der Nutzer sieht sich selbst als Spieler-Persönlichkeit gespiegelt, nicht als Punkte-Sammler. Technisch: 4 Template-Strings mit 2 variablen Datenpunkten pro Session; keine KI nötig, einfaches String-Filling. | Niedrig — 4 Text-Templates, 1 Session-Data-Reader, 1 Farbübergangs-Shader | **MITTEL** |

---

## 2.3 Sound-Design

| Moment | Sound-Konzept | Screens |
|---|---|---|
| **App-Start / Logo-Entstehung** | Ein einzelner tiefer Ton — wie eine leicht angeschlagene Kristallschüssel. Frequenz: ~220 Hz mit langem Decay (3 Sek. Ausklang). Davor und danach: bewusste Stille. Kein Jingle, kein Fanfare, kein Musik-Loop. Die Stille ist akustisches Design. | S001 |
| **Consent-Bestätigung abgeschlossen** | Ein einzelner weicher Ton als "Kapitel-beginnt"-Signal — heller als der Splash-Ton (~440 Hz), kurzer Decay (1 Sek.). Signalisiert: Übergang abgeschlossen, etwas Neues beginnt. Kein Sound während des Consent-Ausfüllens. | S002 |
| **Erstes Match im Onboarding** | Drei-Schicht-System: (1) Bewegungs-Whoosh beim Drag (20% Lautstärke, ~50 ms), (2) Resonanz-Kling beim Match-Moment (~880 Hz, 1,2 Sek. Nachklang), (3) aufsteigende Kaskaden-Töne beim Stein-Fall — aufsteigend statt abfallend, weil steigende Tonhöhe psychologisch Erfolg signalisiert | S003 |
| **Narrative Hook Atmospheric Layer** | Ruhige, leicht melancholische Ambient-Textur — keine Melodie, nur Stimmung mit Klang. Frequenz-Bereich: 60–400 Hz mit vereinzelten oberen Harmonischen. Im letzten Story-Frame: Stille. Die Abwesenheit von Sound im entscheidenden Moment verstärkt den Hook. Bei persona-basierten Varianten: Intuitiv-Spieler = leicht rhythmischere Textur, Grübler = stillere, tiefere Textur. | S004 |
| **Täglicher Home-Entry** | Morgen (6–10 Uhr): heller, klarer Einzelton (~660 Hz, kurzer Decay). Abend (19–23 Uhr): wärmerer, dunklerer Ton (~330 Hz, längerer Decay). Zweck: unbewusste Tageszeit-Orientierung ohne visuelle Hinweise. Return-Visits: kein Sound. | S005 |
| **Standard Match-3** | Resonanz-Kling, nicht Burst-Explosion. Ton variiert subtil je nach Stein-Typ: Blau-Stein = höher (~1047 Hz), Rot-Stein = wärmer (~830 Hz), Grün-Stein = mittlerer (~932 Hz). Die Variation ist subtil — kein Nutzer bemerkt sie bewusst, aber das Spielfeld klingt *lebendig* statt monoton. | S006 |
| **Special-Stein-Entstehung** | Bomb = tiefes Wummern (80–120 Hz, 400 ms). Line-Clearer = hoher Sweep (500→2000 Hz, 300 ms). Color-Bomb = kurze harmonische Akkord-Folge (Dur-Dreiklang, 500 ms). Jeder Typ ist eindeutig unterscheidbar. Kein Ton wird lauter als der Match-Basis-Ton. | S006 |
| **Cascade-Combo (3+)** | Sound-Schicht beschleunigt organisch mit dem Combo-Tempo. Basis-Ambient-Intensität erhöht sich um 30% pro Combo-Stufe. Match-Töne überlagern sich zunehmend dicht — aber nie dissonant; Mixing-Verhältnisse sind fixiert. Beim Ende der Cascade: kurze Stille (300 ms) bevor das Ambient-Level wieder sinkt. Die Stille nach dem Sturm. | S006 |
| **Level-Abschluss (Gold-Shift)** | Während der 1,5-Sek.-Goldverschiebung: ein einzelner langer, warmer Ton (~415 Hz, Moll-Vorzeichen für emotionale Tiefe statt Dur-Triumphgefühl). Kein Fanfare, keine AMAZING-Jingle. Nach dem Ton: Stille während die Text-Zusammenfassung erscheint — der Nutzer liest in Ruhe, kein Sound-Rauschen. | S008 |
| **Unmöglicher Zug / Stein federt zurück** | Kein Sound. Die Abwesenheit von Fehler-Feedback ist die Entscheidung. Der Nutzer wird nicht akustisch bestraft. Einziges Signal: die neutrale Federbewegung des Steins. | S006 |

---

## Design-Checkliste (Endabnahme nach Produktion)

### Block A: Differenzierungspunkte

- [ ] **D1 (Dark-Field Luminescence) ist visuell erkennbar:** Spielfeld-Hintergrund ist messbar im Bereich #0D0F1A–#1A1D2E; Spielsteine emittieren nachweislich Licht (Bloom-Effekt sichtbar, Emission-Maps aktiv); kein Stein reflektiert nur — alle leuchten eigenständig; Unterschied zu hellem Candy-Crush-Hintergrund ist für jeden Tester ohne Erklärung sofort sichtbar
- [ ] **D2 (Kontextuelle Navigation) ist funktional:** Zu drei verschiedenen Testzeiten (morgens 8 Uhr, mittags 13 Uhr, abends 21 Uhr) zeigt der Home Hub jeweils eine unterschiedliche Primär-Konfiguration; kein statischer 5-Icon-Bottom-Bar ist im fertigen UI vorhanden; Social-Lichtpunkte auf Level-Map sind ohne separaten Tab sichtbar
- [ ] **D3 (Silent Persona Engine) ist aktiv:** Nach 60 Sekunden Spielzeit im Onboarding sind mindestens 3 Spieler-Datenpunkte in PlayerPrefs geschrieben (Pause-Average, Zug-Speed, Combo-Rate); das erste KI-Level weicht messbar von einem Flat-Difficulty-Level ab; Story-Hook zeigt persona-passende Variante (verifizierbar durch A/B-Test mit zwei simulierten Personas)

---

### Block B: Anti-Standard-Regeln (alle Verbote)

- [ ] **Kein Konfetti-Effekt** ist im gesamten App-Build vorhanden — Partikel-Suche im Particle-System-Inventory ergibt null Konfetti-Emitter
- [ ] **Kein AMAZING / GREAT / PERFECT-Text** in Schriftgröße über 48pt auf Reward-Screens — Typografie-Audit bestätigt maximale Headline-Größe auf S008
- [ ] **Kein roter BEST VALUE-Aufkleber** oder farblich hervorgehobenes Preis-Badge im Shop — visueller Audit von S010 ergibt keine Rot-Hex-Werte (#FF0000 ±30%) in Badge-Elementen
- [ ] **Kein Fehler-Sound / Buzz-Haptik** bei unmöglichem Zug — QA-Test mit 10 bewussten Fehl-Moves ergibt null Audio-Trigger und null Error-Haptik-Events
- [ ] **Kein Tutorial-Overlay mit Zeige-Cursor** auf S003 — Screenshot-Audit von S003 erster Sekunde zeigt null Overlay-Elemente, null Hand-Cursor-Assets
- [ ] **Kein Push-Banner für Social-Nudges** — Social-Benachrichtigungen erscheinen ausschließlich als Lichtpuls auf Freundes-Avataren, nicht als Banner-Overlay
- [ ] **Kein heller Hintergrund** (#FFFFFF oder Werte über #4A4A4A Helligkeit) auf Spielfeld-Screens — automatisierter Color-Picker auf S006-Screenshot ergibt null Werte über definiertem Schwellwert
- [ ] **Kein Bottom-Navigation-Bar mit fünf fixen Icons** — UI-Inventory-Check ergibt kein statisches 5-Icon-Navigationselement

---

### Block C: Wow-Momente

- [ ] **WOW-01 (Dark-Field Luminescence im ersten Spielmoment):** Mindestens 3 von 5 unvorbereiteten Testnutzern beschreiben die Spielfeld-Optik spontan als "anders", "lebendig", "dunkel aber schön" oder äquivalente positive Differenzierungsaussagen — ohne Suggestivfragen
- [ ] **WOW-02 (Silent Persona Engine spürbar):** Mindestens 3 von 5 Testnutzern beschreiben nach der ersten KI-Level-Erfahrung ein Gefühl von "passt irgendwie zu mir" oder "genau richtig schwer" — gemessen via 1-Fragen-Exit-Survey nach Level 2
- [ ] **WOW-03 (Reward als Geschichte):** Mindestens 3 von 5 Testnutzern lesen die Text-Zusammenfassung auf dem Reward-Screen vollständig (Eye-Tracking oder Verweildauer ≥3 Sek. auf Text-Element) statt sofort auf "Weiter" zu tippen

---

### Block D: Emotionale Leitlinie

- [ ] **Gesamt-Energie ist 6/10:** App wirkt weder gehetzt noch einschläfernd — Testnutzer bewerten auf Skala 1–10 (1=schlafend, 10=überwältigt) im Median zwischen 5 und 7
- [ ] **Farbtemperatur ist Tief-Organisch:** Kein Candy-Neon-Wert (Sättigung >90% bei Helligkeit >70%) außerhalb von bewussten Akzent-Momenten (Special-Stein-Aktivierung, Gold-Shift-Reward); Bernstein- und Kupfer-Akzente sind die wärmsten Farben im Interface
- [ ] **Sound ist Resonanz, nicht Explosion:** Peak-Lautstärke aller Match-Sounds liegt unter –12 dBFS; kein Sound hat einen Attack kürzer als 20ms (verhindert perkussive Explosion-Wirkung); QA-Audio-Analyse bestätigt
- [ ] **Animationen atmen in 600–900ms:** Alle primären UI-Transitions werden mit Ease-In-Out in diesem Zeitfenster ausgeführt; kein primäres UI-Element transitioniert unter 400ms oder über 1200ms — automatisierter Timing-Audit via UI-Profiler

---

### Block E: Interaktions-Prinzipien

- [ ] **Haptik ist dreischichtig und aktiv:** QA-Test auf physischem iOS-Gerät (iPhone 12+) und Android-Gerät (Snapdragon 778+) bestätigt drei unterschiedlich intensive Haptik-Events in S006 (Drag-Ticken, Snap, Cascade-Rumble) — alle drei sind subjektiv unterscheidbar
- [ ] **Micro-Interactions HOCH (MI-01 bis MI-09) sind alle implementiert:** Jede der 9 High-Priority-Micro-Interactions hat einen QA-Testfall mit Pass/Fail-Kriterium; alle 9 sind auf Pass
- [ ] **Kein negativer Feedback-Loop** auf falsche Züge: QA-Protokoll dokumentiert 20 bewusste Fehl-Moves auf S006 ohne einen einzigen Fehler-Sound, Fehler-Visual oder Buzz-Haptik-Event

---

### Block F: Differenzierung vom Wettbewerb

- [ ] **Visueller Unterschied zu Top-3-Wettbewerbern ist messbar:** Side-by-Side-Screenshot-Vergleich von EchoMatch S006 mit Candy Crush Saga, Royal Match und Homescapes zeigt auf 5 von 5 befragten Testern sofortige Unterscheidbarkeit ohne Namens-Overlay
- [ ] **60-Sekunden-Wow-Test bestanden:** Mindestens 1 spontane positive Differenzierungsaussage ("wow", "cool", "das sieht anders aus", "interessant") in den ersten 60 Sekunden bei 4 von 5 unvorbereiteten Testnutzern — protokolliert in User-Test-Session

---

## Anschluss an Kapitel 5 (Asset Audit) — KONKRET

### Vorgaben für Agent 17/18 (Asset-Discovery + Stil-Guide)

**Verbindliche Farbpalette für alle Assets:**

| Token | Hex | Verwendung |
|---|---|---|
| `color-background-deep` | #0D0F1A | Spielfeld-Hintergrund, Splash-BG |
| `color-background-mid` | #1A1D2E | Hub-Screens, Card-Hintergründe |
| `color-accent-amber` | #C9972A | Reward-Shift, Gold-Moment, Zug-Counter-Warnung |
| `color-accent-copper` | #B5622A | Sekundäre Highlights, Special-Stein-Warm-Typ |
| `color-stone-red` | #E8412A + Emission | Roter Spielstein — Glut-Charakter, Bloom aktiv |
| `color-stone-blue` | #1A7AE8 + Emission | Blauer Spielstein — Biolumineszenz-Charakter, Bloom aktiv |
| `color-stone-green` | #1AE87A + Emission | Grüner Spielstein — organisches Leuchten, Bloom aktiv |
| `color-text-primary` | #E8E4DC | Fließtext, Narrative-Screens (warm-weiß, nicht reines Weiß) |
| `color-text-secondary` | #8A8478 | Labels, sekundäre UI-Texte |

**Verbindliche Typografie:**

| Rolle | Font | Größe | Gewicht | Verwendung |
|---|---|---|---|---|
| Narrative-Headline | Variable Serif (z.B. Playfair Display) | 28–36pt | Regular | Story-Screens, Reward-Zusammenfassung |
| UI-Primary | Geometric Sans (z.B. DM Sans) | 16–20pt | Medium | Buttons, Labels, Zähler |
| UI-Secondary | Geometric Sans (z.B. DM Sans) | 12–14pt | Regular | Settings, Legal, sekundäre Labels |
| Ambient-Text | Geometric Sans, Letter-Spacing +0.08em | 11–13pt | Light | Kontext-Informationen, Timestamps |

**Verbindlicher Illustrations-Stil:**

- Organisch-dunkel: alle Illustrationen haben einen maximalen Hintergrund-Helligkeit von #2A2D3E
- Lichtquellen-Prinzip: jede Illustration enthält mindestens eine eigene Lichtquelle die von innen heraus leuchtet (kein Außen-Licht)
- Keine flachen Cartoon-Vektoren, keine Candy-Pastell-Paletten, keine Comic-Outlines
- Zulässige Referenz-Ästhetik: biolumineszente Meerestiere, Glut in Kohle, Sternenhimmel durch Wolkenfenster

**Asset-Prioritäts-Hierarchie:**

1. **P0 — Wow-Momente-Assets** (Bloom-Shader für Spielsteine, Gold-Shift-Shader für S008, Logo-Entstehungs-Animation): diese Assets blockieren keinen anderen Schritt — sie werden als erstes produziert
2. **P1 — Core-Loop-Assets** (alle 6 Basis-Stein-Typen mit Emission-Maps, Spielfeld-Hintergrund-Textur mit Puls-Animation)
3. **P2 — Hub und Navigation-Assets** (Home Hub Komposition, kontextuelle Navigation-Elemente, Freund-Avatar-Lichtpunkt-System)
4. **P3 — Monetarisierung und Legal-Assets** (Shop-Katalog-Layout, Consent-Rising-Card)

---

### Vorgaben für Agent 19/20 (Consistency-Check + Review)

**Zusätzliche Ampel-Kategorie:**

```
ROT-DV: Verstoß gegen Design-Vision
Trigger-Bedingungen:
  - Asset-Hintergrund heller als #4A4A4A auf Spielfeld-Screens
  - Partikel-System mit Konfetti-Charakter (hohe Sättigung, randomisierte Rotation, Burst-Emitter)
  - Typografie-Größe über 48pt auf Reward-Screens
  - Roter Farbwert (#FF0000 ±30%) auf nicht-Stein-Elementen
  - Animations-Timing unter 400ms oder über 1200ms für primäre UI-Transitions
```

**Automatisierte KI-Warn-Injektionen in Produktions-Prompts:**

Wenn ein Code-Generations-Prompt ein Reward-Screen-Element enthält:
> ⚠️ DESIGN-VISION-WARNUNG: Die Produktions-KI wird hier standardmäßig einen Konfetti-Emitter oder Score-Pop-Animation generieren. Die Design-Vision verlangt stattd