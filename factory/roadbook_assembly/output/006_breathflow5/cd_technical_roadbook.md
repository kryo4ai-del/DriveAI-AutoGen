# Creative Director Technical Roadbook: EchoMatch
## Version: 1.0 | Status: VERBINDLICH fuer alle Produktionslinien

---

## 1. Produkt-Kurzprofil

**App Name:** EchoMatch

**One-Liner:** Ein Match-3-Puzzle-Spiel, das sich visuell und emotional vollständig vom Candy-Crush-Industriemodell abkoppelt, indem es ein dunkles, selbstleuchtendes Spielfeld, kontextuelle Navigation und eine KI-gestützte, implizite Spielstil-Personalisierung ab Sekunde 1 bietet – für Spieler, die Flow, Intimität und ein Spiel suchen, das sie wirklich kennt.

**Plattformen:**
*   **Primär:** iOS (Native / Swift), Android (Native / Kotlin)
*   **Sekundär:** Nicht im MVP-Scope

**Tech-Stack (Empfehlung):**
*   **Engine:** Unity (Version 2022.3 LTS oder neuer)
*   **Render Pipeline:** Universal Render Pipeline (URP) für Bloom-Post-Processing und Emission-Maps.
*   **Backend-Dienste:** Firebase (Authentication, Firestore für Spielerprofile, Remote Config für A/B-Tests, Cloud Functions für serverseitige Logik wie KI-Level-Generierung und Challenge-Management).
*   **KI-Integration:** Anthropic Claude API (für Pro-Tier Skill-Generierung in SkillSense, hier als Referenz für KI-Nutzung in EchoMatch: KI-Level-Generierung, Spielstil-Analyse).
*   **Zahlungen:** Stripe (für IAP und Battle Pass, da App Store Gebühren anfallen).
*   **Analytics:** Firebase Analytics oder Plausible Analytics (DSGVO-konform).
*   **CI/CD:** Unity Cloud Build oder GitLab CI/CD.
*   **Monitoring:** Sentry (Error Tracking), UptimeRobot (Uptime Monitoring).

**Zielgruppe:**
*   **Alter:** 18–34 Jahre (Kernzielgruppe), leicht weiblich-dominant (55–60%).
*   **Region(en):** Primär Tier-1-Märkte (DACH, UK, Nordamerika).
*   **Psychografisches Profil:** Spieler, die eine hochwertige, immersive und entspannende Spielerfahrung suchen, die sich von generischen Mobile Games abhebt. Sie schätzen Ästhetik, Story und ein Gefühl der persönlichen Verbindung. Sie sind immun gegen aggressive Monetarisierungs-Taktiken und Dark Patterns. Spielen primär auf dem Commute (5–10 Min. Sessions) und abends zur Entspannung.

---

## 2. Design-Vision (VERBINDLICH)

### Design-Briefing (Wird in JEDEN Produktions-Prompt injiziert)

EchoMatch ist ein Match-3-Puzzle-Spiel das sich visuell und emotional vollständig vom Candy-Crush-Industriemodell abkoppelt. Das Spielfeld ist dunkel — Mitternachtsblau-Schiefergrün (#0D0F1A bis #1A1D2E) als Grundschicht — und die Spielsteine sind selbstleuchtende Objekte die Licht emittieren statt reflektieren, realisiert durch Unity URP Bloom-Post-Processing und Emission-Maps. Die App fühlt sich an wie ein vertrautes Gespräch mit jemandem der dich wirklich kennt: ruhig genug zum Abschalten, lebendig genug um nicht aufzuhören. Energie-Level ist 6/10 — pulsierend und rhythmisch, niemals explodierend oder chaotisch. Navigation ist kontextuell statt statisch: es gibt keine feste Bottom-Bar mit fünf Icons, stattdessen reagiert die UI auf Tageszeit, Session-Phase und Quest-State. Animationen atmen mit 600–900ms Ease-In-Out statt in 200ms zu bursten. Haptik ist dreischichtig und narrativ bedeutsam. Sound ist Resonanz, nicht Explosion. Reward-Screens verzichten auf Konfetti und AMAZING-Schriften — stattdessen eine 1,5-sekündige goldene Farbverschiebung des gesamten Screens und eine lesbare Zusammenfassung der eigenen Spielhistorie. Jede Designentscheidung muss sich gegen diese Frage behaupten: Würde Candy Crush das genauso machen? Wenn ja, ist es falsch.

### Emotionale Leitlinie pro App-Bereich (PFLICHT)

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

### Differenzierungspunkte (PFLICHT — mindestens 3)

| # | Differenzierung | Beschreibung | Betroffene Screens | Status |
|---|---|---|---|---|
| **D1** | **Dark-Field Luminescence** | Spielfeld-Hintergrund ist #0D0F1A bis #1A1D2E (tiefdunkles Blau-Grau). Spielsteine sind selbstleuchtende Objekte mit Unity URP Bloom-Post-Processing und Emission-Maps — sie emittieren Licht, sie reflektieren es nicht. Roter Stein = Glut. Blauer Stein = biolumineszentes Wasser. Hintergrund pulsiert subtil bei Combos. Farbtemperatur der Steine wechselt kapitelbasiert via ScriptableObjects: Kapitel 1 = kühle Töne, Kapitel 3 = warme Amber-Töne. Performant ab Snapdragon 678+ durch skalierbare Bloom-Intensität. | S001, S004, S006, S008, S009 | **VERBINDLICH** — keine Verhandlung |
| **D2** | **Kontextuelle Navigation** | Keine feste Bottom-Bar mit 5 Icons. Navigation reagiert auf Tageszeit, Quest-State und Session-Phase: 6–10 Uhr morgens = Daily Quest dominiert, Social minimiert; 12–14 Uhr = kompakte Commuter-Ansicht; 19–23 Uhr = Story-Hub-Teaser prominent, Shop-Nudge für Entspannungs-Session. Social-Nudges erscheinen als Lichtpuls auf Freundes-Avataren im Header statt als Push-Banner. Freunde sind als Lichtpunkte ambient auf der Level-Map sichtbar (Zenly-Prinzip) — kein separater Social-Tab nötig. | S005, S007, alle Hub-Screens | **VERBINDLICH** — keine Verhandlung |
| **D3** | **Implizites Spielstil-Tracking ab Sekunde 1** | Das Onboarding-Match (S003) erfasst unsichtbar: Pausenlänge zwischen Zügen (Grübler vs. Intuitiv), Zuggeschwindigkeit, Combo-Orientierung vs. schnelles Räumen. Kein Fragebogen, keine explizite Abfrage. Das erste echte KI-Level ist bereits personalisiert. Die narrative Hook-Sequenz (S004) passt ihr visuelles Setting an den erkannten Spieltyp an: Intuitiv-Schnell = kinetischere, städtischere Welt; Grübler = tiefere, mythologischere Welt. Personalisierung beginnt in Sekunde 1, ist für den Nutzer vollständig unsichtbar. | S003, S004, S006 | **VERBINDLICH** — keine Verhandlung |
| **D4** | **Post-Session-Screen als Poster / Share-Card** | Kein generischer Reward-overlay mit Konfetti. Der Ergebnis-Screen ist als Poster-Ästhetik designed (Spotify Wrapped-Prinzip): große isolierte Zahl oder Satz auf dunklem Grund, eine Akzentfarbe, lesbare Zusammenfassung des eigenen Spielstils ("Du hast heute 3 Cascades in einem Zug ausgelöst"). Format ist nativ share-optimiert — Nutzer schicken es weil es wie ein Statement aussieht, nicht wie ein UI-Screenshot. | S008, S009 | **VERBINDLICH** — keine Verhandlung |
| **D5** | **Story-NPC als Interface-Brecher** | Narrative Figuren können außerhalb ihrer Story-Screens erscheinen und das Interface kommentieren (Duolingo-Owl-Prinzip). Beispiel: NPC taucht nach einem verlorenen Level im Home Hub auf und gibt einen kontextuellen Kommentar im Ton der Spielwelt — kein generisches "Try again!". Diese Momente sind selten (max. 1× pro Woche) und dadurch bedeutsam. Sind primär für virales Social-Sharing designed: Out-of-Character-Momente die Nutzer screenshotten. | S005, S008, S009 | **VERBINDLICH** — keine Verhandlung |

### Anti-Standard-Regeln (VERBOTE — mindestens 4)

| # | VERBOTEN | STATTDESSEN | Betroffene Screens | Begründung |
|---|---|---|---|---|
| **A1** | Hypersaturierte Primärfarben auf weißem oder hellem Hintergrund — Candy-Crush-Palette, Knallrot/Knallblau/Knallgrün auf Weiß | Dunkle Grundpalette (#0D0F1A–#1A1D2E), selbstleuchtende Steine via Bloom-Shader, Bernstein- und Kupfer-Akzente, kapitelbasierte Farbtemperatur-Shifts | S006, S001, S004, alle Spielfeld-Screens | Das gesamte Genre cargo-cultet Candy Crush (2012); heller Hintergrund ist das stärkste visuelle Identitätsmerkmal des Einheitsbreis; Dunkelfeld differenziert sofort und ist Qualitätssignal für 18–34-Zielgruppe (Genshin, Alto's Odyssey, Robinhood) |
| **A2** | Feste Bottom-Navigation-Bar mit 4–5 statischen Icons die dauerhaft sichtbar ist | Kontextuelle Navigation die auf Tageszeit, Quest-State und Session-Phase reagiert; soziale Präsenz als ambient leuchtende Elemente auf der Level-Map; Long-Press-Previews und Swipe-Shortcuts als Haupt-Navigations-Geste | S005, S007, alle Hub-Screens | Identisches Mental-Model bei allen Wettbewerbern ohne Ausnahme; feste Bottom-Bar ist das generischste UI-Element des Mobil-Genres; kontextuelle Navigation folgt dem Nutzer statt ihn zu verwalten |
| **A3** | Konfetti-Regen, goldene 1–3-Sterne, "AMAZING!" / "GREAT!" in fetter Type über 100pt, Coin-Sprung-Animationen auf Reward-Screens | 1,5-sekündige goldene Farbverschiebung des gesamten Screens; lesbare Spielhistorie als Poster-Ästhetik; warme Pause statt visueller Überwältigung; Share-optimiertes Format statt Overlay | S008, S009 | Emotional infantil und visuell vollständig austauschbar — alle fünf Top-Wettbewerber nutzen identische Reward-Screen-Sprache; die Reduktion ist selbst das emotionale Statement (Robinhood-Prinzip) |
| **A4** | Roter "BEST VALUE!"-Banner schräg über Shop-Kacheln, Vollbild-Grid mit Produkt-Kacheln, roter Countdown-Timer als Druck-Element, identische Preisarchitektur $0.99/$4.99/$9.99/$19.99 ohne visuelle Differenzierung | Shop öffnet sich als hochwertiger Katalog — viel Luft, klare Hierarchie, kein Schreien; Preisarchitektur visuell klar strukturiert mit Blackspace; Vertrauen ist das Design; kein visueller Druckaufbau durch Farbe oder Timer | S010, alle Shop-Screens | Identische Store-Architektur bei allen Wettbewerbern; BeReal-Prinzip: das Weglassen von Druck-Design ist selbst das Statement; Zielgruppe 18–34 ist immun gegen generische Druck-Mechanik und reagiert auf wahrgenommenes Vertrauen mit höherer Konversionsrate |
| **A5** | Hand-Cursor der ersten Zug zeigt, Tutorial-Overlay mit abgedunkeltem Hintergrund, statische Dialog-Bubble mit erklärender Figur | Spielfeld erscheint ohne Overlay; subtiles einmaliges Pulsieren der Steine als organische Aufmerksamkeits-Lenkung nach 4 Sekunden Inaktivität (Scale 1.0→1.03→1.0 in 1,2 Sek.); erster Stein folgt dem Finger mit 20% Nachzieh-Elastizität wie durch Wasser; Entdeckung durch Spielen nicht durch Erklären | S003 | Identisches Onboarding bei allen Wettbewerbern; instruiertes Onboarding kommuniziert implizit Misstrauen in den Nutzer; entdeckendes Onboarding erzeugt sofortige Kompetenz-Emotion — kritisch für D1-Retention (Entscheidung in ersten 60 Sekunden) |
| **A6** | Burst-Partikel-Explosion beim Match als primäres Feedback | Resonanz-Puls: Stein-Match löst einen Ton aus der nachhallt statt berstet; Cascade-Töne steigen auf statt ab; Special-Steine formen sich via 400ms Morphing-Animation mit tiefem Haptik-Puls; dreischichtige adaptive Sound-Schicht die mit dem Spieltempo atmet | S006, S008 | Physikalisch vorhersehbare Burst-Effekte bei allen Wettbewerbern ohne Ausnahme; Resonanz ist psychologisch nachhaltiger als Explosion; aufsteigende Töne signalisieren Erfolg stärker als abfallende |

### Wow-Momente (PFLICHT-Implementierung — mindestens 3)

| # | Name | Screen | Was passiert | Warum kritisch |
|---|---|---|---|---|
| **W1** | **Logo-Genesis** | S001 | Aus dem dunklen Hintergrund bilden sich drei Spielsteine in den App-Farben, ordnen sich zu einem Match, verschwinden mit einem weichen Resonanz-Puls (einzelner tiefer Kristallton), und aus diesem Puls formt sich das EchoMatch-Logo. Ladezeit ≤2 Sek. — die Animation ist nie fertig bevor sie endet, sie ist die Ladezeit. Bei Slow-Connection wiederholt der Puls sich ruhig wie ein Herzschlag-Echo. | Erste 2 Sekunden prägen den emotionalen Kontrakt — Nutzer erlebt sofort: diese App ist anders als Candy Crush; Logo-Genesis kommuniziert ohne Wort die Kernmechanik und visuelle Identität; kein anderer Wettbewerber hat einen Splash der selbst eine Mini-Geschichte erzählt |
| **W2** | **Der lebendige erste Stein** | S003 | Der erste Stein den der Nutzer berührt leuchtet von innen heraus auf und folgt dem Finger mit 20% Nachzieh-Elastizität — nicht pixelgenau, wie durch Wasser gezogen. Haptik: leichtes Ticken beim Drag-Start, mittleres Snap beim Einrasten (nicht beim Loslassen — am Snap-Moment), weiches kurzes Rumble wie eine verstummende Stimmgabel beim erfolgreichen Match. Cascade-Töne steigen auf. Kein Tutorial-Text, keine Erklärung — das Feld selbst ist der Lehrer. | Entscheidung über Installation-Retention fällt in den ersten 60 Sekunden; der erste Stein-Touch ist der emotionalste Moment des gesamten Funnels; Elastizität und Eigenleuchten kommunizieren sofort Premium-Qualität und erzeugen das Kompetenz-Gefühl das alle anderen Screens aufbauen |
| **W3** | **Goldene Ausatmung** | S008, S009 | Nach Level-Abschluss keine Konfetti-Explosion. Das Spielfeld atmet einmal aus — alle Steine verblassen sanft innerhalb von 400ms. Dann: der gesamte Screen-Hintergrund verschiebt sich in 1,5 Sek. zu warmem Gold (#C8960C, Sättigung 60%, nicht grell). In dieser Goldpause erscheint eine einzelne Zeile die den Spielstil des Nutzers beschreibt ("Heute: 3 Cascades. Durchschnittszug: 1,4 Sekunden."). Dann: Poster-Format-Share-Card die nativ geteilt werden kann. | Stärkster Kontrastmoment zum Genre — jeder der das zum ersten Mal sieht weiß sofort: das ist nicht Candy Crush; die goldene Pause ist emotional nachhaltiger als Konfetti-Überwältigung; Poster-Share-Card ist der eingebaute virale Mechanismus (Spotify Wrapped-Prinzip); dieser Moment wird auf TikTok geteilt weil er so anders aussieht |
| **W4** | **NPC Interface-Brecher** | S005, S008 | Nach einem verlorenen Level taucht ein Story-NPC als kleines Element im Home Hub auf und hinterlässt einen kurzen kontextuellen Kommentar im Ton der Spielwelt — nie generisch, immer zum Spielstil des Nutzers passend. Max. 1× pro Woche, dadurch selten und bedeutsam. Animation: NPC gleitet von der Bildschirmkante herein (300ms Ease-Out), bleibt 4 Sekunden sichtbar, zieht sich zurück. Tap auf NPC öffnet eine Mini-Story-Sequenz. | Duolingo-Owl-Prinzip angewendet auf narrative Spielwelt — Vierte-Wand-Bruch ist der viralste UI-Moment den Apps produzieren können; erzeugt emotionale Bindung an Charaktere außerhalb der Story-Screens; gibt Nutzern einen Screenshot-würdigen Moment der EchoMatch von allen Wettbewerbern unterscheidet |
| **W5** | **Spieler-Lichtpunkte auf der Level-Map** | S007 | Freunde-Avatare erscheinen als kleine, sanft pulsierende Lichtpunkte direkt auf ihrem aktuellen Level-Punkt der Map — ohne separaten Social-Tab. Ein Freund der gerade aktiv spielt pulsiert schneller (1 Puls/Sek.). Ein Freund der heute noch nicht gespielt hat: minimale Helligkeit, langsamer Puls. Challenge-Einladung: der Lichtpunkt des einladenden Freundes pulsiert in einer zweiten Farbe (Bernstein statt Weiß). Social-Präsenz ist immer ambient sichtbar, nie aufdringlich. | Zenly-Prinzip: soziale Aktivität passiert auf dem primären visuellen Layer; reduziert Tab-Depth auf null; macht soziale Verbindung zu einem natürlichen Teil der Spielwelt statt eines isolierten Features; erzeugt FOMO durch ambient sichtbare Aktivität ohne Push-Notification-Druck |

### Interaktions-Prinzipien (PFLICHT)

**Touch-Reaktion:**
Jede Berührung erhält sofortiges visuelles Echo — der berührte Stein leuchtet innerhalb von 16ms auf (ein Frame). Drags haben 20% Nachzieh-Elastizität (das Objekt folgt dem Finger wie durch Wasser, nicht pixelgenau). Unmögliche Züge werden nicht mit Fehler-Feedback bestraft — der Stein federt neutral zurück, kein Fehler-Buzz, kein negativer Feedback-Loop. Snap-Feedback (Einrasten) erfolgt am Snap-Moment, nicht beim Finger-Loslassen.

**Animations-Prinzip:**
Atmend statt burstend. Standard-Ease ist Ease-In-Out über 600–900ms für alle narrativen und UI-Übergänge. Gameplay-Animationen sind schneller (Match-Auflösung: 300ms, Stein-Fall: physikbasiert mit leichtem Overshoot-Bounce 8%). Special-Stein-Entstehung: 400ms Morphing-Animation (Metall das sich selbst in eine Form zieht). Hintergrund-Puls bei Combo: Bloom-Intensität steigt von 0.4 auf 0.7 in 200ms, fällt in 600ms zurück. Kein Element animiert ohne Bedeutung — jede Animation kommuniziert Information oder Emotion.

**Feedback-Prinzip:**
Dreischichtig und narrativ bedeutsam:
1.  Leichtes Ticken beim Stein-Drag-Start (Hinweis: Aktion beginnt)
2.  Mittleres Snap beim Einrasten (Bestätigung: Zug registriert)
3.  Tiefes Rumble bei Cascade-Combo: 3-Match = 80ms, 5-Match = 140ms, 5+-Match = 200ms, länger = mehr Gewicht; fühlt sich wie eine Stimmgabel an die langsam verstummt — nie wie ein Fehler-Buzz oder ein Alarm.

Kein negativer Feedback-Buzz für falsche Inputs — neutrale Rückfeder statt Bestrafung.

**Sound-Prinzip:**
Resonanz statt Explosion. Das Spielfeld hat eine adaptive Sound-Schicht mit drei Ebenen:
1.  Bewegungs-Whoosh beim Drag (sehr leise, 20% Lautstärke)
2.  Resonanz-Kling beim Match-Moment — ein Ton der nachhallt, kein Burst
3.  Kaskaden-Töne beim Stein-Fall die aufsteigen statt abfallen (aufsteigend = Erfolg)

Special-Stein-Typen haben eigene Resonanz-Signaturen: Bomb = tiefes Wummern, Line-Clearer = hoher Sweep, Color-Bomb = kurze harmonische Akkord-Folge. Das Tempo der Ambient-Schicht beschleunigt organisch mit dem Spieltempo des Nutzers — langsame Züge = tiefes ruhiges Ambient, schnelle Züge = erhöhtes rhythmisches Tempo. Kein Ton überschreit die anderen — Mixing ist Teil des Designs, kein Afterthought.

Narrative Screens (S001, S002, S004): Stille ist aktiv eingesetzt als emotionales Medium. Sound erscheint gezielt, nicht dauerhaft.

---

## 3. Stil-Guide (VERBINDLICH)

### Farbpalette

| Name | Hex | Verwendung |
|---|---|---|
| Echo Violet | `#5B2ECC` | Hauptfarbe fuer CTA-Buttons, aktive Navigation, Links, Primary-Actions wie Battle-Pass und Level-Start |
| Match Ember | `#FF6B35` | Sekundaere Akzente fuer Streak-Indikatoren, Booster-Highlights, Quest-Fortschrittsbalken und Saison-Timer-Dringlichkeit |
| Gold Spark | `#FFD700` | Reward-Icons, Coin-Icons, Battle-Pass-Tier-Highlights, Score-Zuwachs-Animationen, Premium-Inhalte |
| Echo Teal | `#00C9A7` | Erfolgs-Feedback auf Spielfeld, Match-Effekte, Daily-Quest-Abschluss, Level-Complete-Sekundaerfarbe |
| background_light | `#F4F0FF` | Light Mode Hintergrund fuer alle nicht-spielbezogenen Screens (Hub, Shop, Profil, Quests) |
| background_dark | `#120D2A` | Dark Mode Hintergrund; tiefes Dunkelviolett passend zur Spielwelt-Aesthetik und zum Match-3-Spielfeld |
| surface_light | `#FFFFFF` | Card-Oberflaechen, Modal-Hintergruende, Shop-Angebotskarten und Quest-Cards im Light Mode |
| surface_dark | `#1E1540` | Card-Oberflaechen, Modal-Hintergruende und HUD-Elemente im Dark Mode |
| gameplay_bg | `#0E0A24` | Dedizierter Spielfeld-Hintergrund (S003, S006); dunkel genug damit Spielsteine maximalen visuellen Kontrast erhalten |
| success | `#27ae60` | Erfolg, Level-Complete-Bestaetigung, Quest-Abschluss-Checkmark |
| warning | `#f39c12` | Warnung bei wenigen verbleibenden Zuegen (Move-Counter unter 5), ablaufende Saison-Timer |
| error | `#e74c3c` | Fehler, Level-Failed-State, Verbindungsprobleme, fehlgeschlagene IAP |
| text_primary | `#1A1333` | Haupttext im Light Mode; Headlines, Body-Copy, Level-Bezeichnungen |
| text_primary_dark | `#EDE8FF` | Haupttext im Dark Mode; Headlines und Body-Copy auf dunklen Surfaces |
| text_secondary | `#6B5FA6` | Sekundaertext, Metadaten, Timestamps, inaktive Tab-Labels, Hilfetexte im Light Mode |
| text_secondary_dark | `#9B8FCC` | Sekundaertext und Metadaten im Dark Mode |

### Typografie

| Font | Verwendung | Gewicht | Lizenz |
|---|---|---|---|
| Nunito | Headings, Level-Bezeichnungen, Battle-Pass-Tier-Labels, CTA-Button-Beschriftungen, Score-HUD-Hauptzahl | 700-800 | SIL Open Font License (Google Fonts); kostenlos, kommerziell nutzbar |
| Inter | Body Text, Quest-Beschreibungen, Shop-Kartentext, Onboarding-Erklaerungen, Settings, Notification-Texte | 400-500 | SIL Open Font License (Google Fonts); kostenlos, kommerziell nutzbar |
| JetBrains Mono | Numerische Daten mit festem Zeichenabstand: Score-Counter, Countdown-Timer, Move-Counter, Muenz-Zaehler; verhindert Layout-Shift bei sich aendernden Ziffern | 500-600 | SIL Open Font License (JetBrains / Google Fonts); kostenlos, kommerziell nutzbar |

### Illustrations-Stil

*   **Stil:** Stylized 2.5D Casual Cartoon mit Depth-Layering
*   **Beschreibung:** Weiche, abgerundete Formen mit leichtem 3D-Extrude-Effekt auf Spielsteinen und wichtigen UI-Elementen; saettigte, leuchtende Farben mit subtilen Gradienten; schwarze Outlines mit variabler Strichstaerke (2-4px) fuer Tiefe; Charaktere und Mascottes haben grosse, ausdrucksstarke Augen und einfache Silhouetten; Hintergrundelemente sind weicher und weniger gesaettigt als Vordergrund-Assets um Spielsteine visuell zu priorisieren; Lichteffekte und Highlights als weisse Glanzpunkte auf Spielsteinen zur Volumenvermittlung
*   **Begruendung:** 2.5D Casual Cartoon ist der visuelle Standard der kommerziell erfolgreichsten Match-3-Games (Royal Match, Candy Crush, Gardenscapes); die Zielgruppe 18-34 erwartet polished visuals ohne harten Realismus; das Stil ermoeglicht starke Lesbarkeit der Spielsteine bei gleichzeitig emotionaler Attraktivitaet; Dark-Mode-Kompatibilitaet wird durch leuchtende Eigenfarben statt helle Hintergruende gewaehrleistet

### Icon-System

*   **Stil:** Filled mit weichen Kanten, passend zum Illustration-Stil; keine scharfen rechten Winkel
*   **Library:** Custom Icon Set basierend auf Phosphor Icons (MIT-Lizenz) als Basis, angepasst an EchoMatch-Aesthetik mit 3px corner-radius auf eckigen Elementen
*   **Grid:** 24x24dp Basisgitter; 48x48dp fuer Gameplay-Booster-Icons; 96x96dp fuer Reward-Item-Icons; 20x20dp fuer Notification-Icon (monochrom, Android-konform)

### Animations-Stil

*   **Default Duration:** 280ms
*   **Easing:** cubic-bezier(0.34, 1.56, 0.64, 1) (leichter Overshoot-Bounce)
*   **Max Lottie:** 500 KB pro Animation
*   **Static Fallback:** Ja, für alle Animationen muss ein statischer Endzustand oder ein PNG-Fallback existieren, der bei `prefers-reduced-motion` oder Performance-Problemen angezeigt wird.

---

## 4. Feature-Map

### Phase A — Soft-Launch MVP (30 Features)

**Budget Phase A:** 252.500 EUR (Entwicklung) + 2.660 EUR (Asset-Produktion Launch-kritisch) = **255.160 EUR**

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F001 | Skill Scanner – File Upload | Drag & Drop Upload-Bereich für Skill-Dateien und Chat-Exporte. Nutzer können eine oder mehrere Dateien hochladen um eine Analyse zu starten. | D1, D7, Session-Dauer, Sessions-per-Day | 2 |  | Kern-Feature des Produkts. Ohne File Upload kein Scan, kein erster Nutzerwert. Soft Launch scheitert ohne dieses Feature. |
| F002 | Skill Scanner – Sicherheits-Pattern-Check | Automatische Analyse hochgeladener Skills gegen 42 definierte Security-Pattern-Checks. Erkennt potenzielle Sicherheitsrisiken in Skill-Dateien. | D1, D7, Session-Dauer | 2 | F001 | 42 Security-Pattern-Checks sind der primäre Nutzenwert des Scanners. Ohne dieses Feature gibt es kein differenzierendes Ergebnis und keine Grundlage für den Paid-Upgrade. |
| F003 | Skill Scanner – Overlap Detection (Jaccard) | Erkennt inhaltliche Überlappungen zwischen installierten Skills mittels Jaccard-Ähnlichkeitsalgorithmus. Gibt Hinweise auf redundante Skills. | D1, D7, Session-Dauer | 2 | F001 | Zweites Kern-Analyse-Feature. Zusammen mit F002 bildet es den vollständigen Scan-Output. Beta-Erfolgskriterium (60% vollständige Scans) nicht erreichbar ohne dieses Feature. |
| F004 | Skill Score – Bewertungsanzeige | Zeigt pro analysiertem Skill einen konkreten Score an. Ergebnis wird in drei Kategorien visualisiert: Gut, Prüfen, Risiko (drei Kacheln). | D1, D7, Session-Dauer | 1 | F002, F003 | Visualisierung der Scan-Ergebnisse in drei Kacheln (Gut/Prüfen/Risiko). Ohne Ergebnis-Darstellung ist der Scanner wertlos. Direkt KPI-kritisch für D1-Retention. |
| F005 | Handlungsempfehlung pro Skill | Für jeden analysierten Skill wird eine konkrete Empfehlung ausgegeben: behalten, löschen oder ersetzen. Kein Wall of Text – kompakte Darstellung. | D1, D7, Session-Dauer | 1 | F004 | Konkrete Handlungsanweisung (behalten/löschen/ersetzen) ist der actionable Output. Ohne Empfehlung fehlt der Nutzerwert-Abschluss. KPI-kritisch für Retention. |
| F006 | Advisor Light – Fragebogen-Einstieg | Alternativer Einstieg ohne Datei-Upload: Nutzer beantwortet einen strukturierten Fragebogen über seine AI-Nutzung und Skills. Geeignet für Nutzer ohne bestehende Skills. | D1, D7, Sessions-per-Day | 2 |  | Alternativer Einstieg für Nutzer ohne Skills. Kritisch für Breite der Zielgruppe im Soft Launch und Basis für Advisor Pro (F007). Beta-Erfolgskriterium direkt abhängig. |
| F009 | Echtzeit-Feedback während Analyse (Ladeanimation) | Während der Scan läuft, werden dem Nutzer Fortschrittshinweise angezeigt (z.B. 'Prüfe Sicherheitspatterns... Suche Überlappungen...'). Erhöht wahrgenommene Transparenz. | D1, Session-Dauer | 1 | F001 | Wahrgenommene Transparenz und Vertrauen während des Scans. KPI-Scan-Performance-Kriterium (<60 Sek.) braucht visuelles Feedback. Verhindert Abbrüche während der Analyse. |
| F013 | Kein-Account-Einstieg (Zero-Friction Onboarding) | Nutzer kann den Scanner starten ohne Account, Login oder Registrierung. Kein Ablenkungsschirm vor dem ersten Wert-Erlebnis. | D1, Sessions-per-Day | 1 |  | Fundamentale UX-Entscheidung. Ohne Zero-Friction-Onboarding scheitert der D1-KPI (40%). Login-Gate vor erstem Nutzerwert ist im Soft Launch kontraproduktiv. |
| F012 | Landing Page – Pain-Point-Headline & CTA | Landing Page mit sofort sichtbarer Headline ('Hör auf Skills zu raten. Lass dich beraten.') und primärem CTA 'Deine Skills jetzt prüfen – kostenlos'. Kein Login, kein Scroll nötig. | D1 | 1 |  | Ohne funktionale Landing Page kein Traffic, kein Soft Launch. Erste Kommunikationsfläche zum Nutzer. Scheitert der Launch ohne dieses Feature? Ja. |
| F021 | Wartelisten-Formular (Early Access) | Formular auf der Landing Page zur Eintragung in die Advisor-Pro-Warteliste mit explizitem E-Mail-Opt-in. Ziel: ≥ 200 Einträge in der Closed Beta. | D7, D30 | 1 | F012 | Beta-Erfolgskriterium: ≥200 E-Mail-Einträge für Advisor Pro Warteliste. Direkt aus Release-Plan als Closed-Beta-KPI definiert. Muss in Phase A vorhanden sein. |
| F022 | Einladungsbasierter Beta-Zugang | Closed Beta mit einladungsbasiertem Zugang für 150–300 handverlesene Nutzer. Kein öffentlicher Zugang in Phase 1. | D1 | 1 |  | Phase 1 ist explizit Closed Beta mit 150–300 handverlesenen Nutzern. Invite-Code-System ist technische Voraussetzung für kontrollierten Soft Launch. |
| F023 | Feedback-Formular (Qualitatives Nutzer-Feedback) | In-App-Formular nach Scan-Abschluss mit offenen Fragen (z.B. 'Was hat dich überrascht?', 'Was fehlt?'). Ziel: ≥ 40 ausgefüllte Formulare in Beta. | D7 | 1 | F004 | Beta-Erfolgskriterium: ≥40 ausgefüllte Feedback-Formulare. Ohne dieses Feature kann der Soft Launch nicht validiert werden. Direkte Abhängigkeit im Release-Plan. |
| F014 | 100% Client-Side Verarbeitung (Privacy by Design) | Alle Analysen (Scan, Overlap, Security) laufen ausschließlich im Browser des Nutzers. Keine Datei und kein Skill-Inhalt verlässt das Gerät. | D1, D7 | 2 | F001 | Kritisches Datenschutz-USP und Beta-Erfolgskriterium (0 Datenschutzvorfälle). Ohne diese Architektur-Entscheidung ist das Datenschutzversprechen nicht haltbar. |
| F036 | Datenschutz-Nachweis / Client-Side-Verifikation | Technisch verifiziertes und kommuniziertes Versprechen dass keine Nutzerdaten den Browser verlassen. Kritisches Erfolgskriterium der Closed Beta (0 Datenschutzvorfälle). | D1 | 1 | F014 | Beta-Erfolgskriterium explizit: 0 kritische Datenschutzvorfälle. Technische Verifikation und öffentliches Versprechen sind Pflicht vor jedem Launch. |
| F045 | DSGVO-Compliance: Datenschutzerklärung & Transparenz-Dokumentation | Vollständige, rechtlich wasserdichte Datenschutzerklärung die alle tatsächlichen Datenflüsse dokumentiert: Vercel (Hosting), Clerk (Auth), Stripe (Payments), Claude API (Anthropic). Klare Abgrenzung zwischen Client-Side-Verarbeitung (Chat-Analyse) und Server-Side-Verarbeitung (Auth, Payments). Verhindert irreführendes '100% Client-Side'-Versprechen. | Kein | 1 |  | Legal-Pflicht. Kein Launch ohne vollständige Datenschutzerklärung. DSGVO-Verstoß würde den gesamten Soft Launch gefährden. Immer Phase A per Priorisierungsregel. |
| F046 | Consent Management Platform (CMP) / Cookie-Consent | Technische Implementierung eines DSGVO-konformen Consent-Management-Systems für alle Third-Party-Dienste (Auth, Payments, Analytics). Nutzer muss aktiv zustimmen bevor personenbezogene Daten an Drittdienste übermittelt werden. Implizit erforderlich durch DSGVO-Compliance-Anforderung. | Kein | 1 | F045 | Legal-Pflicht für DSGVO-Konformität. Ohne CMP dürfen Third-Party-Dienste (Analytics, Auth) nicht initialisiert werden. Kein Launch ohne dieses Feature. |
| F047 | Auftragsverarbeitungsverträge (AVV) Management | Abschluss und Dokumentation von Auftragsverarbeitungsverträgen mit allen Drittanbietern die personenbezogene Daten verarbeiten: Hosting-Provider, Auth-Provider, Payment-Provider, Claude API (Anthropic). Implizit erforderlich für DSGVO-Compliance. | Kein | 1 | F045 | Organisatorische Legal-Pflicht. Ohne AVV mit Google/Firebase, Stripe, Anthropic ist der Betrieb DSGVO-widrig. Muss vor Soft Launch abgeschlossen sein. |
| F049 | Haftungs-Disclaimer für Sicherheitsempfehlungen | Rechtlich geprüfte Disclaimer-Texte die bei der Ausgabe von Security-Check-Ergebnissen und Sicherheitsempfehlungen angezeigt werden. Klarstellung dass Empfehlungen informatorischer Natur sind und keine professionelle Sicherheitsberatung ersetzen. Reduziert Haftungsrisiko aus dem Produktfeature 'Sicherheitsempfehlungen'. | Kein | 1 | F004, F005 | Legal-Pflicht. Sicherheitsempfehlungen ohne Disclaimer erzeugen Haftungsrisiko ab dem ersten Nutzer. Muss bei Scan-Output immer sichtbar sein. |
| F025 | Responsive Design (Mobile Web) | Vollständig responsive UI die auf mobilen Browsern funktioniert. Advisor-Light-Fragebogen und Landing Page sind auf Mobile vollständig nutzbar; File-Upload optional. | D1, Sessions-per-Day | 1 | F012 | Ohne Mobile-Responsiveness verliert der Soft Launch einen signifikanten Anteil der Zielgruppe. D1-KPI (40%) nicht erreichbar wenn mobile Nutzer schlechte Experience haben. |
| F026 | Performance-Optimierung (Core Web Vitals) | LCP < 2,5 Sekunden und CLS < 0,1 auf Desktop als technische Mindestschwelle. Gilt als Erfolgskriterium für den Soft Launch. | D1 | 1 | F012 | Explizites Soft-Launch-Erfolgskriterium: LCP <2,5 Sek., CLS <0,1. Ohne Performance-Baseline sind SEO und Nutzererfahrung gefährdet. |
| F027 | Scan-Performance-Garantie (< 60 Sekunden) | Technische Anforderung: 95% aller Uploads müssen ein erstes Scan-Ergebnis in unter 60 Sekunden liefern. Erfolgskriterium der Closed Beta. | D1, Session-Dauer | 1 | F002, F003 | Explizites Beta-Erfolgskriterium: 95% aller Scans unter 60 Sekunden. Technische Pflicht vor Beta-Start. |
| F037 | Conversion-Tracking & Analytics | Messung des Free-to-Paying-Conversion-Funnels, Feature Utilization Rate und Rückkehrquote. Notwendig zur Validierung aller Release-Erfolgskriterien. | Mittel | 1 | F046 | Ohne Analytics können keine KPIs gemessen werden. Basis-Analytics (Firebase/Plausible) ist Pflicht um Soft-Launch-Erfolgskriterien überhaupt validieren zu können. |
| F032 | SEO-Grundlage / Content-Strategie | Technische SEO-Basis (Meta-Tags, strukturierte Daten, SSG-Seiten) wird im Soft Launch gelegt. Ziel: organischer Traffic als Wachstumskanal ab Phase 2. | D1 | 1 | F012 | Explizites Soft-Launch-Ziel: SEO-Grundlage legen. Technische SEO (Meta-Tags, SSG) muss beim Launch-Tag vorhanden sein. Einfach umsetzbar via Next.js. |
| F035 | Mehrsprachigkeit / Lokalisierung (DE + EN) | UI und Landing-Page-Copy zunächst auf Deutsch (DACH); englische UI bereits in Phase 1 vorhanden. Phase 2 paralleler englischsprachiger Rollout möglich. | D1 | 2 | F012 | Soft-Launch-Ziel ist DACH (DE) mit englischer UI-Basis. Englische UI ist laut Release-Plan bereits in Phase 1 vorhanden. Grundstruktur muss in Phase A gelegt werden. |
| F044 | Lizenzstrategie & Quellenmanagement für Skill-Datenbank | System zur Verwaltung der Lizenzen von Drittquellen (GitHub, Reddit, Community) für die kuratierte Skill-Datenbank. Sicherstellung dass nur CC-lizenzierte oder selbst erstellte Skills ohne Lizenzklärung übernommen werden. Initialer Kern-Datensatz (30–50 selbst erstellte Skills) als MVP-Basis. | Kein | 1 |  | Legal-Pflicht vor Launch der kuratierten Datenbank. Ohne Lizenzklärung der Skill-Quellen besteht Urheberrechtsrisiko ab Tag 1. MVP-Basisdatensatz (30–50 Skills) muss rechtlich sauber sein. |
| F048 | Anthropic ToS Compliance Monitoring | Überwachung und Einhaltung der Anthropic API-Nutzungsbedingungen für kommerzielle Skill-Analyse. Sicherstellung dass die Claude-API-Nutzung den ToS entspricht, insbesondere für kommerzielle Weiterverarbeitung und Anzeige von API-Outputs gegenüber Endnutzern. | Kein | 1 | F007 | Legal-Pflicht. Kommerzielle Claude-API-Nutzung ohne ToS-Konformität gefährdet den API-Zugang. Muss vor Advisor Pro Beta-Start sichergestellt sein. |
| F043 | KI-Content-Kennzeichnung (EU AI Act Art. 50) | UI-seitige Kennzeichnung aller KI-generierten Skill-Vorschläge (Pro-Tier via Claude API) als 'KI-generiert', verpflichtend ab August 2025 gemäß EU AI Act Art. 50. Betrifft alle Ausgaben der Claude-API im Produktkontext. | Kein | 1 | F007 | Legal-Pflicht ab August 2025. Da Soft Launch in diesen Zeitraum fällt, ist die Kennzeichnung KI-generierter Outputs Pflicht. Einfache UI-Annotation, kein großer Aufwand. |
| F030 | Advisor Pro – Closed Beta innerhalb Soft Launch | Advisor Pro wird im Soft Launch zunächst nur für Nutzer der Warteliste (Early Access) freigeschaltet. Geschlossene Beta innerhalb der öffentlichen Phase 2. | Hoch | 1 | F007, F022 | Explizites Release-Plan-Feature für Phase 2. Advisor Pro Closed Beta ist Kernziel des Soft Launch. Feature-Flag-Mechanismus muss in Phase A vorhanden sein. |
| F007 | Advisor Pro – KI-gestützte Skill-Generierung | Pro-Feature: Generiert auf Basis von Nutzerprofil und Fragebogen-Ergebnissen individuell angepasste Skills via Claude API. Personalisierte Empfehlung statt generische Liste. | Hoch | 3 | F006, F028 | KI-PoC ist explizites Go/No-Go Kriterium per Priorisierungsregel. Advisor Pro ist das primäre Pro-Feature und Hauptmotivation für Subscription. Beta-NPS-Ziel (≥35) hängt daran. |
| F031 | Net Promoter Score (NPS) Abfrage | In-App NPS-Abfrage für Advisor Pro Beta-Nutzer. Ziel: NPS ≥ 35 als Erfolgskriterium des Soft Launch. | Kein | 1 | F007, F030 | Explizites Soft-Launch-Erfolgskriterium: NPS ≥35 für Advisor Pro Beta. Ohne NPS-Messung kann dieses Kriterium nicht validiert werden. |

### Phase B — Full Production (18 Features)

**Budget Phase B:** 230.000 EUR (Entwicklung)

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten | Begruendung |
|---|---|---|---|---|---|---|
| F010 | Kuratierte Skill-Datenbank – Browse & Install | Nutzer können nach dem Scan geprüfte Skills aus einer kuratierten Datenbank durchsuchen und installieren. Datenbank ist redaktionell gepflegt und sicherheitsgeprüft. | D7, D30, Session-Dauer | 3 | F044, F004 | Wichtiges Differenzierungs-Feature für den Global Launch, aber nicht zwingend für den DACH Soft Launch. Soft Launch validiert Core Loop (Scan + Advisor). Datenbank-Browse differenziert Phase B. |
| F011 | Skill-Fit-Check – Persönliche Relevanz-Bewertung | Bewertet ob ein Skill aus der Datenbank zum persönlichen Nutzerprofil passt ('Passt das zu dir?'). Unterscheidet SkillSense von rein popularitätsbasierten Marktplätzen. | D7, D30 | 2 | F010, F006 | Wertvolles Feature zur Differenzierung von popularitätsbasierten Marktplätzen, aber abhängig von F010 (Datenbank). Erst sinnvoll wenn Datenbank vorhanden ist. |
| F015 | Tiefenanalyse-Report (Deep Scan) – IAP | Einmalkauf für 1,99 € ('Deep Scan Pass'): Liefert einen vollständigen Sicherheits-Report eines einzelnen Skills mit erweiterter Detailtiefe über den Free-Scan hinaus. | D7, D30 | 2 | F020, F029, F002 | IAP-Bridge (1,99€) ist Soft-Launch-Erfolgskriterium (30 Nutzer), aber die volle Stripe-Integration und das vollständige IAP-System werden für den Global Launch skaliert. Phase A kann mit vereinfachtem Proof testen. |
| F016 | Premium Skill Bundle – IAP | Einmalkauf für 4,99 € ('Skill Bundle'): Schaltet Zugang zu 10 kuratierten Premium-Skills aus der Datenbank frei. Ergänzung zum Subscription-Modell. | D30 | 2 | F020, F010, F029 | Setzt kuratierte Datenbank (F010) voraus. Da F010 in Phase B liegt, muss auch dieses IAP in Phase B landen. Differenziert Revenue-Mix für Global Launch. |
| F017 | Chat Export Analysis Token – IAP | Einmalkauf für 2,99 €: Schaltet eine einmalige Chat-Historie-Analyse frei. Einstiegs-Konversionsmechanismus für Nutzer ohne Subscription-Bereitschaft. | D7, D30 | 2 | F020, F008, F029 | Einmalkauf für Chat-Analyse. Chat-Export (F008) ist Phase A, aber der vollständige IAP-Token-Mechanismus mit Stripe skaliert besser in Phase B mit der restlichen Monetarisierungs-Infrastruktur. |
| F008 | Chat-Export-Analyse | Nutzer lädt seinen Claude-Chat-Export hoch; die App analysiert die Historie auf Nutzungsmuster und leitet daraus Skill-Empfehlungen ab. Rückkehr-Trigger nach 4 Wochen. | D7, D30 | 2 | F001, F014 | Interessantes Feature für D30-Retention (Rückkehr-Trigger nach 4 Wochen), aber nicht notwendig für den Soft-Launch-Core-Loop. Phase B differenziert mit diesem Feature den Global Launch. |
| F018 | Pro Subscription – Monatsabo (9,99 €/Monat) | Recurring Subscription für Zugang zu Pro-Features: Detail-Reports, Chat-Export-Analyse, Skill-Generierung via Claude, unbegrenzte Scans. Monatlich kündbar. | D30 | 2 | F020, F028, F029 | Vollständige Subscription-Infrastruktur ist für den skalierten Global Launch notwendig. Soft Launch validiert Zahlungsbereitschaft via IAP-Bridge; Subscription wird in Phase B ausgebaut. |
| F019 | Pro Subscription – Jahresabo (79 €/Jahr) | Jahresabo mit Rabatt gegenüber Monatsabo (entspricht 6,58 €/Monat). Zielt auf Churn-Reduktion und höheren LTV. Mindestens 15% Rabatt gegenüber Monatsrate. | D30 | 1 | F018, F038 | Jahresabo setzt Monatsabo (F018) voraus. Jahresabo-Conversion (≥20-35%) ist Soft-Launch-Erfolgskriterium für Phase 2. Wird zusammen mit F018 in Phase B skaliert. |
| F020 | Stripe-Zahlungsintegration | Vollständige Integration von Stripe für Einmalkäufe (IAP), Monats- und Jahresabos. Inkl. korrektem Error-Handling bei fehlgeschlagenen Zahlungen. | D30 | 3 | F028 | Vollständige Stripe-Integration mit Webhooks und Error-Handling ist für Phase B (scharfgeschalteter Conversion-Funnel) nötig. Phase A validiert mit vereinfachtem IAP-Proof, Phase B baut die vollständige Infrastruktur. |
| F028 | Nutzerregistrierung & Account-Management (Pro-Tier) | Account-System für zahlende Pro-Nutzer zur Verwaltung von Subscription, Rechnungen und Feature-Zugängen. Free-Tier bleibt account-frei. | D7, D30 | 2 |  | Account-System für zahlende Pro-Nutzer ist Voraussetzung für Subscription. Free-Tier bleibt account-frei (Phase A). Phase B schaltet den vollständigen Paid-Funnel scharf. |
| F029 | Feature-Differenzierung Free vs. Pro | Klare technische und UX-seitige Trennung zwischen Free-Tier (limitiert auf 3 Scans, kein Detail-Report, kein Chat-Export) und Pro-Tier (unbegrenzt, alle Features). Upgrade-Prompts an relevanten Stellen. | D7, D30 | 2 | F028, F041, F042 | Vollständige Free/Pro-Trennung mit Upgrade-Prompts setzt Account-System (F028) und Tier-Management (F041, F042) voraus. Für Phase B wenn Payment-Infrastruktur steht. |
| F038 | Pricing Page mit Monats-/Jahres-Toggle | Dedizierte Pricing-Seite mit UI-Toggle zwischen Monats- und Jahresplan. Zeigt Ersparnis des Jahresabos transparent an um Jahresabo-Conversion (Ziel ≥ 20-35%) zu fördern. | D30 | 1 | F018, F019 | Pricing Page setzt die vollständige Subscription-Infrastruktur voraus. Wird zusammen mit F018/F019 in Phase B deployed. |
| F040 | Upgrade-Prompts / Paywall-Trigger im Produkt | An relevanten Punkten im Scan-Flow (z.B. nach Free-Scan-Limit oder bei Pro-Only-Features) werden kontextsensitive Upgrade-Prompts angezeigt um Free-to-Pro-Conversion zu fördern. | D7, D30 | 1 | F029, F038 | Kontextsensitive Upgrade-Prompts setzen vollständige Free/Pro-Differenzierung voraus. Wichtig für Global Launch Conversion-Optimierung. |
| F041 | SaaS Subscription Management (Free/Pro/Enterprise) | Verwaltung von drei Subscription-Tiers: Free (limitiert auf 3 Scans, 1 Security Check), Pro (9,99 €/Monat oder 79 €/Jahr) und Enterprise (Jahresvertrag, individuell). Deterministische, transaktionsbasierte Leistungserbringung ohne Zufallskomponente. | D30 | 2 | F028, F020 | Technisches Subscription-Management mit Firebase Custom Claims. Voraussetzung für Feature-Gating. Phase B wenn Payment-Infrastruktur vollständig steht. |
| F042 | Funktionslimitierung nach Tier (Feature Gating) | Serverseitige Tier-Validierung setzt Subscription-Management (F041) voraus. Kritisch für korrekte Monetarisierung aber erst nach vollständiger Payment-Infrastruktur sinnvoll. | D7, D30 | 2 | F041, F028 | Serverseitige Tier-Validierung setzt Subscription-Management (F041) voraus. Kritisch für korrekte Monetarisierung aber erst nach vollständiger Payment-Infrastruktur sinnvoll. |
| F039 | EU-Rollout / Internationaler Markt (Phase 2+) | Ausweitung auf gesamten EU-Markt und englischsprachige Märkte (UK, US, Kanada, Australien) ab Phase 3. Impliziert Steuer- und Zahlungskonformität für mehrere Länder. | D30 | 2 | F020, F035 | Explizit für Phase 3 (Global Launch) vorgesehen. Stripe Tax für EU + US + AU ist technische Voraussetzung für internationalen Zahlungsverkehr. Phase B legt die Basis. |
| F024 | Rückkehr-Trigger / Re-Engagement nach 4 Wochen | System erinnert Nutzer nach ca. 4 Wochen an einen neuen Scan-Zyklus (z.B. via E-Mail oder Browser-Notification). Validiert den Core Loop als non-Daily-Driver. | D30 | 2 | F028, F037 | D30-Retention-KPI (10%) wird durch Re-Engagement gefördert. Setzt Account-System (F028) und Analytics (F037) voraus. Phase B wenn Nutzerbasis groß genug ist um E-Mail-Trigger zu rechtfertigen. |
| F034 | Product Hunt Launch | Koordinierter PR- und Community-Launch auf Product Hunt als Teil der Phase-3-Skalierungsstrategie. Impliziert Launch-Page, Assets und Community-Engagement. | D1 | 2 | F012, F032 | Explizit für Phase 3 (Full Launch) vorgesehen. Marketing-Aktion die Demo-Video und vollständige Feature-Reife voraussetzt. Phase B bereitet Assets vor. |

### Backlog — Post-Launch (5 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |
|---|---|---|---|---|
| F033 | Team-Tier / Enterprise-Pfad | v1.2 | Erschließt B2B-Segment und erhöht LTV signifikant. Multi-Seat-Verwaltung für Consultants und PMs. | Explizit für Phase 3 vorgesehen. Komplexe Billing-Infrastruktur (multi-seat) und Sales-Prozess setzen validiertes B2C-Modell voraus. Kein MVP-Scope. |
| F050 | Markenrechts-Prüfung & Namensschutz-Dokumentation | v1.1 | Rechtssicherheit für Markenname SkillSense in DACH. Grundlage für eventuelle Markenanmeldung. | Organisatorische Maßnahme die parallel zu Phase A läuft, aber keinen technischen Deploy-Block darstellt. Kein nativer App Store Scope in Phase A/B. |
| F051 | Patent-Freihalteraum-Analyse für Kerntechnologien | v1.1 | Rechtssicherheit für Jaccard-Algorithmus und Security-Pattern-Matching. | Organisatorische Maßnahme. Jaccard und Pattern-Matching sind etablierte Algorithmen mit bekanntem Patentstand. Tiefere Analyse kann nach Soft Launch mit konkreten Implementierungsdetails erfolgen. |
| F052 | iOS Native App Privacy Nutrition Label Readiness | v2.0 | Vorbereitung für native iOS App. Erschließt App Store Distribution. | Explizit für Phase 3+ vorgesehen. Kein nativer App-Code in Phase A/B. Web-App ist die Deployment-Plattform. Wird relevant wenn React Native oder Swift-Entwicklung beginnt. |
| F053 | Reddit Community Marketing (organisch) | v1.1 | Organischer Entdeckungskanal. Primärer Traffic-Treiber für Soft Launch und darüber hinaus. | Marketing-Aktivität ohne technische Feature-Abhängigkeit. Läuft parallel zu Phase A als Eigenleistung, braucht aber kein eigenes Feature-Slot im Priorisierungs-Framework. |

---

## 5. Abhaengigkeits-Graph & Kritischer Pfad

**Build-Reihenfolge (Phase A):**

1.  **Woche 1-2 (Parallelisierbar):**
    *   F012 (Landing Page)
    *   F013 (Kein-Account-Einstieg)
    *   F006 (Advisor Light – Fragebogen-Einstieg)
    *   F022 (Einladungsbasierter Beta-Zugang)
    *   F001 (Skill Scanner – File Upload)
    *   F014 (100% Client-Side Verarbeitung)
    *   F025 (Responsive Design)
    *   F026 (Performance-Optimierung)
    *   F027 (Scan-Performance-Garantie)
    *   F032 (SEO-Grundlage)
    *   F035 (Mehrsprachigkeit DE+EN)
    *   F045 (DSGVO-Datenschutzerklärung)
    *   F046 (Consent Management Platform)
    *   F047 (Auftragsverarbeitungsverträge)
    *   F049 (Haftungs-Disclaimer)
    *   F044 (Lizenzstrategie Skill-Datenbank)
    *   F048 (Anthropic ToS Compliance)
    *   F043 (KI-Content-Kennzeichnung)
    *   F036 (Datenschutz-Nachweis)
    *   F037 (Conversion-Tracking & Analytics)
    *   F021 (Wartelisten-Formular)
    *   F023 (Feedback-Formular)
    *   F009 (Echtzeit-Feedback Analyse)

2.  **Woche 3-4 (Abhängig von F001, F014):**
    *   F002 (Sicherheits-Pattern-Check)
    *   F003 (Overlap Detection)
    *   F004 (Skill Score – Bewertungsanzeige)
    *   F005 (Handlungsempfehlung pro Skill)

3.  **Woche 5-7 (Abhängig von F006, F028):**
    *   F007 (Advisor Pro – KI-gestützte Skill-Generierung)
    *   F030 (Advisor Pro – Closed Beta innerhalb Soft Launch)
    *   F031 (Net Promoter Score (NPS) Abfrage)

**Kritischer Pfad (Phase A):**
Der kritische Pfad wird durch die Entwicklung der Kern-Analyse-Features (F001, F002, F003, F004, F005) und die darauf aufbauende KI-Integration (F007) bestimmt, da diese die längsten Entwicklungszeiten haben und aufeinander aufbauen.

*   **Kette:** F001 (2 Wo) → F002 (2 Wo) → F003 (2 Wo) → F004 (1 Wo) → F005 (1 Wo) → F007 (3 Wo)
*   **Gesamtdauer des kritischen Pfads (Phase A):** 2 + 2 + 2 + 1 + 1 + 3 = **11 Wochen**

**Parallelisierbare Feature-Gruppen (Phase A):**

*   **Phase A – Tag-1-Parallel-Start (Keine Abhaengigkeiten):** F012 (Landing Page), F013 (Kein-Account-Einstieg), F006 (Advisor Light), F022 (Einladungsbasierter Beta-Zugang), F025 (Responsive Design), F026 (Performance-Optimierung), F032 (SEO-Grundlage), F035 (Mehrsprachigkeit), F045 (DSGVO-Datenschutzerklärung), F046 (Consent Management Platform), F047 (Auftragsverarbeitungsverträge), F049 (Haftungs-Disclaimer), F044 (Lizenzstrategie Skill-Datenbank), F048 (Anthropic ToS Compliance), F043 (KI-Content-Kennzeichnung), F036 (Datenschutz-Nachweis), F037 (Conversion-Tracking & Analytics), F021 (Wartelisten-Formular), F023 (Feedback-Formular), F009 (Echtzeit-Feedback Analyse).
*   **Phase A – F001-Abhaengige Parallelgruppe:** F002 (Sicherheits-Pattern-Check), F003 (Overlap Detection), F014 (100% Client-Side Verarbeitung), F009 (Echtzeit-Feedback Analyse).
*   **Phase A – F004-Abhaengige Parallelgruppe:** F005 (Handlungsempfehlung pro Skill), F023 (Feedback-Formular), F021 (Wartelisten-Formular).
*   **Phase A – F007-Abhaengige Parallelgruppe:** F030 (Advisor Pro – Closed Beta), F031 (NPS Abfrage).

---

## 6. Screen-Architektur (VERBINDLICH)

### Screen-Uebersicht (19 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / App Init | Overlay | App-Start, Client-Side Engine laden, Locale erkennen | F014, F035 | Normal, Slow-Connection, Engine-Fehler |
| S002 | Landing Page / Hero | Hauptscreen | Erster Eindruck, Pain-Point-Kommunikation, primärer CTA zum Scanner oder Advisor, Invite-Code-Abfrage | F012, F013, F022, F025, F026, ... | Normal, Invite-Code-ungültig, Invite-Code-gültig, Offline |
| S003 | Cookie Consent / CMP | Modal | DSGVO-konformer Consent vor Analytics-Initialisierung | F045, F046 | Normal, Einstellungen-Expanded |
| S004 | Datenschutzerklärung & Transparenz | Subscreen | DSGVO-Pflichtseite, Client-Side-Verifikations-Erklärung, AVV-Hinweise | F045, F046, F047, F036, F014 | Normal, Offline-Cache |
| S005 | Invite Code Gate | Modal | Closed Beta Zugangssteuerung – blockiert Nutzung ohne gültigen Invite Code | F022 | Normal, Code-wird-geprüft, Code-ungültig, Code-gültig-Weiterleitung |
| S006 | Wartelisten-Formular | Subscreen | Early-Access E-Mail-Eintrag für Advisor Pro Warteliste, KPI: 200+ Einträge | F021, F012 | Normal, Senden, Erfolg, Fehler, Bereits-eingetragen |
| S007 | Skill Scanner – Upload | Hauptscreen | Datei-Upload-Einstieg, primärer Core-Loop-Start für Nutzer mit vorhandenen Skills | F001, F013, F014, F025 | Leer, Datei-wird-gezogen, Datei-hochgeladen, Mehrere-Dateien, Falsches-Format-Fehler, Datei-zu-groß-Fehler, Offline |
| S008 | Skill Scanner – Analyse läuft | Subscreen | Echtzeit-Feedback während der client-side Analyse, verhindert Abbrüche, Scan < 60 Sek. | F009, F027, F014 | Analyse-läuft, Pattern-Check-Phase, Overlap-Check-Phase, Abschließen-Phase, Timeout-Warnung >50 Sek., Fehler-Abbruch |
| S009 | Skill Score – Ergebnis-Dashboard | Hauptscreen | Scan-Ergebnis-Visualisierung in drei Kacheln, Kern-Werterlebnis, KPI-kritisch für D1-Retention | F004, F002, F003, F037, F049 | Normal, Alle-Skills-Gut, Kritische-Risiken-vorhanden, Leer-keine-Skills-erkannt, Fehler-Analyse-fehlgeschlagen |
| S010 | Handlungsempfehlungen – Detail-Liste | Subscreen | Konkrete Aktion pro Skill: behalten, löschen oder ersetzen, actionable Output | F005, F004, F049, F043 | Normal, Gefiltert, Suche-aktiv, Leer-nach-Filter, Detail-Expanded |
| S011 | Advisor Light – Fragebogen | Hauptscreen | Alternativer Einstieg ohne vorhandene Skills, Schritt-für-Schritt Fragebogen | F006, F013, F025 | Schritt-1, Schritt-N, Letzte-Frage, Antwort-gewählt, Keine-Antwort-Warnung |
| S012 | Advisor Light – Empfehlungs-Ergebnis | Subscreen | Fragebogen-Auswertung mit personalisierten Skill-Empfehlungen als Einstiegspunkt | F006, F005, F049, F043 | Normal, Advisor-Pro-Teaser-sichtbar, Alle-Empfehlungen-expanded |
| S013 | Advisor Pro – Closed Beta Teaser | Subscreen | Advisor Pro KI-Feature vorstellen, Beta-Warteliste pushen, Feature-Flag-gesteuert | F030, F007, F021, F043 | Teaser-gesperrt, Beta-Zugang-offen, Beta-voll, Beta-freigeschaltet-für-User |
| S014 | Feedback-Formular | Modal | Qualitatives Nutzer-Feedback sammeln, KPI: 40+ ausgefüllte Formulare | F023 | Normal, Senden, Erfolg, Fehler, Abgebrochen |
| S015 | NPS Abfrage | Modal | Net Promoter Score messen, Erfolgskriterium NPS >= 35 für Advisor Pro Beta | F031 | Normal, Score-gewählt, Folgefrage-sichtbar, Abgesendet, Später-verschoben |
| S016 | Impressum & Rechtliches | Subscreen | Pflichtangaben Impressum, Haftungsausschluss, Lizenzhinweise Skill-Datenbank | F045, F049, F044 | Normal, Offline-Cache |
| S017 | Fehler / Nicht gefunden (404 / Allgemein) | Subscreen | Fehlerbehandlung, Nutzer zurück in Flow führen | F025 | 404-Not-Found, Allgemeiner-Fehler, Offline |
| S018 | Onboarding-Overlay (First Use) | Overlay | Erstkontakt-Orientierung nach Invite-Code-Einlösung, zeigt die zwei Einstiegswege | F013, F006, F001 | Normal, Scanner-gewählt, Advisor-gewählt |
| S019 | Share / Ergebnis teilen | Modal | Social Sharing des Scan-Scores für viralen Loop, Marketing-Kanal Reddit/LinkedIn | F004, F032 | Normal, Link-kopiert, Geteilt-Erfolg |

### Hierarchie

*   **Modals:** S003 (Cookie Consent), S014 (Feedback-Formular), S015 (NPS Abfrage), S019 (Share / Ergebnis teilen)
*   **Overlays:** S001 (Splash / App Init), S005 (Invite Code Gate), S018 (Onboarding-Overlay)
*   **Hauptscreens:** S002 (Landing Page / Hero), S007 (Skill Scanner – Upload), S009 (Skill Score – Ergebnis-Dashboard), S011 (Advisor Light – Fragebogen)
*   **Subscreens:** S004 (Datenschutzerklärung & Transparenz), S006 (Wartelisten-Formular), S008 (Skill Scanner – Analyse läuft), S010 (Handlungsempfehlungen – Detail-Liste), S012 (Advisor Light – Empfehlungs-Ergebnis), S013 (Advisor Pro – Closed Beta Teaser), S016 (Impressum & Rechtliches), S017 (Fehler / Nicht gefunden)

### Navigation

Die Navigation ist **kontextuell** und **nicht statisch** (Anti-Standard-Regel A2). Es gibt keine feste Bottom-Navigation-Bar. Stattdessen werden situative Action-Surfaces und ein kontextuelles Radial-Menü (Phase B) verwendet.

### User Flows (7 Flows)

#### Flow 1: Onboarding (Erst-Start) — App oeffnen bis erster Core Loop
*   **Pfad:** S001 → S002 → S003 → S005 → S018 → S007 → S008 → S009
*   **Taps bis Core Loop:** 3 (CTA auf S002 → Invite Code bestätigen auf S005 → Upload starten auf S007)
*   **Zeitbudget:** ~60 Sekunden bis erstes Ergebnis sichtbar
*   **Beschreibung:** App initialisiert Client-Side Engine (S001) → Landing Page trifft Pain Point, primärer CTA „Deine Skills jetzt prüfen" (S002) → Cookie Consent erscheint automatisch vor jeder Analytics-Initialisierung (S003) → Invite Code Gate prüft Beta-Zugang (S005) → Onboarding-Overlay zeigt die zwei Einstiegswege: Scanner oder Advisor (S018) → Nutzer wählt Scanner, Upload-Screen (S007) → Analyse läuft mit Echtzeit-Feedback (S008) → Score-Dashboard als erstes Werterlebnis (S009)
*   **Fallback Kein Invite Code:** S005 leitet direkt zu Wartelisten-Formular S006 — kein Zugang zum Core Loop
*   **Fallback Consent-Ablehnung:** S003 setzt nur notwendige Cookies, App funktioniert vollständig weiter (alles client-side, kein Analytics-Block)
*   **Fallback Engine-Fehler auf S001:** Fehler-State zeigt Retry-Button, nach 3 Fehlversuchen Weiterleitung zu S017

#### Flow 2: Core Loop (wiederkehrend) — Direkteinstieg bis Scan-Ergebnis
*   **Pfad:** S001 → S002 → S007 → S008 → S009 → S010
*   **Taps bis Ergebnis:** 2 (CTA auf S002 → Upload starten auf S007)
*   **Session-Ziel:** 45–90 Sekunden für vollständigen Scan-Zyklus, Gesamtsession 6–10 Minuten inkl. S010-Review
*   **Beschreibung:** Wiederkehrender Nutzer öffnet App, Splash kurz (S001) → Landing Page mit bekanntem CTA (S002) → direkter Einstieg in Upload ohne erneuten Invite-Code-Check (S007) → Analyse läuft, Echtzeit-Phasen-Feedback verhindert Abbruch (S008) → Score-Dashboard zeigt drei Kacheln: Gut / Prüfen / Risiko (S009) → Handlungsempfehlungen im Detail mit Filter- und Suchoption (S010)
*   **Fallback Analyse-Timeout >50 Sek.:** S008 zeigt Timeout-Warnung mit Abbrechen-Option und Retry
*   **Fallback Analyse-Fehler:** Fehler-Abbruch-State auf S008, Weiterleitung zurück zu S007 mit Fehlermeldung
*   **Fallback Offline:** S007 sperrt Upload-Button, zeigt Offline-Hinweis — kein Silent Fail

#### Flow 3: Wartelisten-Eintrag Advisor Pro
*   **Pfad:** S002 → S006 — alternativ: S012 → S013 → S006
*   **Taps bis Eintrag:** 3 (Wartelisten-Link auf S002 → E-Mail eintragen auf S006 → Formular absenden)
*   **Zeitbudget:** 60–90 Sekunden
*   **Beschreibung:** Nutzer sieht Early-Access-CTA auf Landing Page (S002) oder erreicht Teaser nach Advisor-Light-Ergebnis (S012 → S013) → Wartelisten-Formular mit E-Mail-Eingabe und DSGVO-Opt-in (S006) → Bestätigungsanimation bei Erfolg
*   **Fallback Sendefehler:** Fehler-State auf S006 mit Retry-Button, Eingabe bleibt erhalten
*   **Fallback Bereits-eingetragen:** Info-Meldung ohne erneuten Datenbank-Eintrag, kein doppelter Eintrag
*   **Fallback Offline:** Senden-Button gesperrt mit Offline-Hinweis, Formular-Eingabe bleibt lokal erhalten

#### Flow 4: Social Challenge — Ergebnis teilen
*   **Pfad:** S009 → S019
*   **Taps bis Teilen:** 2 (Share-Button auf S009 → Teilen-Aktion in S019)
*   **Zeitbudget:** 15–20 Sekunden
*   **Beschreibung:** Nutzer sieht Score-Dashboard (S009) mit Teilen-CTA → Share-Modal öffnet sich (S019) mit vorgefertigtem Text und Score-Visual für Reddit/LinkedIn → Nutzer wählt Link kopieren oder direktes Teilen → Erfolgs-Feedback
*   **Fallback Link-kopieren fehlgeschlagen:** Clipboard-API nicht verfügbar, Link wird als selektierbarer Text angezeigt
*   **Fallback Keine Skills erkannt:** Share-Button auf S009 ist deaktiviert im State „Leer-keine-Skills-erkannt", kein leeres Ergebnis wird geteilt
*   **Fallback Offline:** Share-Modal zeigt nur Link-kopieren-Option, native Share-API wird nicht aufgerufen

#### Flow 5: Advisor Light — Alternativer Einstieg ohne vorhandene Skills
*   **Pfad:** S002 → S018 → S011 → S012 → S013 → S006
*   **Taps bis Ergebnis:** 3 (Advisor-CTA auf S002 → Advisor wählen in S018 → Fragebogen abschließen in S011)
*   **Zeitbudget:** 3–5 Minuten für vollständigen Fragebogen-Zyklus
*   **Beschreibung:** Nutzer ohne vorhandene Skills wählt „Lieber den Fragebogen" auf Landing Page (S002) → Onboarding-overlay bestätigt Advisor-Einstieg (S018) → Schritt-für-Schritt Fragebogen (S011) mit Fortschrittsanzeige → Personalisierte Skill-Empfehlungen als Ergebnis (S012) → Advisor Pro Teaser weckt Upgrade-Interesse (S013) → Weiterleitung zu Wartelisten-Formular (S006)
*   **Fallback Keine Antwort gewählt:** S011 zeigt Keine-Antwort-Warnung, Weiter-Button bleibt gesperrt bis Auswahl getroffen
*   **Fallback Advisor Pro Beta voll:** S013 zeigt State „Beta-voll" mit Wartelisten-CTA statt direktem Zugang
*   **Fallback Nutzer bricht Fragebogen ab:** Fortschritt wird lokal im Session-State gehalten, Rückkehr zu S011 setzt an letzter Frage fort

#### Flow 6: Feedback & NPS — Qualitative Rückkopplung sammeln
*   **Pfad:** S009 → S014 — parallel nach Session: S015
*   **Taps bis Feedback-Absenden:** 3 (Feedback-Button auf S009 → Formular ausfüllen in S014 → Absenden)
*   **Zeitbudget:** 60–120 Sekunden für qualitatives Feedback
*   **Beschreibung:** Nach Score-Dashboard (S009) erscheint Feedback-CTA → Feedback-Formular-Modal öffnet (S014) für qualitative Eingabe → NPS-Abfrage (S015) wird als separates Modal nach Feedback-Abschluss oder zeitbasiert nach der Session getriggert → Score-Auswahl → optionale Folgefrage sichtbar → Absenden
*   **Fallback Feedback-Sendefehler:** Fehler-State auf S014 mit Retry, Eingabe bleibt erhalten
*   **Fallback NPS später verschoben:** S015 „Später"-Option speichert Trigger, NPS erscheint beim nächsten Core-Loop-Abschluss erneut
*   **Fallback Nutzer bricht S014 ab:** State „Abgebrochen" schließt Modal ohne Datenverlust, kein erneutes Triggern in derselben Session

#### Flow 7: Datenschutz & Transparenz — DSGVO-Detail-Flow
*   **Pfad:** S002 → S003 → S004 → S016 — alternativ: S003 → S004 direkt aus Footer jedes Screens
*   **Taps bis vollständiger Information:** 2 (Datenschutz-Link auf S003 → Datenschutzerklärung S004)
*   **Zeitbudget:** Nutzer-gesteuert, kein Zeitlimit
*   **Beschreibung:** Cookie-Consent-Modal erscheint (S003) → Nutzer expandiert Einstellungen (State: Einstellungen-Expanded) → Link zu Datenschutzerklärung öffnet S004 mit Client-Side-Verifikations-Erklärung und AVV-Hinweisen → Impressum erreichbar via S016 aus Footer — beide Screens im Offline-Cache verfügbar
*   **Fallback Offline auf S004:** Offline-Cache-State liefert zuletzt geladene Version der Datenschutzerklärung mit Timestamp-Hinweis
*   **Fallback Offline auf S016:** Identisch — statischer Cache, kein Ladefehler
*   **Fallback S003 ohne Interaktion:** Kein Auto-Accept, Modal bleibt persistent, App-Nutzung ist gesperrt bis Consent-Entscheidung getroffen wurde

### Edge Cases (8 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| Offline bei App-Start | S001, S002, S007 | S001 Engine-Init laedt aus lokalem Cache, da client-side Architektur. S002 zeigt Offline-State-Banner am oberen Rand. S007 Upload und Scan funktioniert vollstaendig da Analyse client-side laeuft. Einzige Einschraenkung: Wartelisten-Formular S006 kann nicht abgesendet werden — Button wird disabled mit Hinweis Kein Internet — Formular wird lokal gespeichert und beim naechsten Online-Status gesendet. |
| KI-Engine Analyse-Fehler oder Timeout | S008, S009 | S008 wechselt in Fehler-Abbruch-State mit erklaerenden Fehlertext und zwei Optionen: Erneut versuchen (primaer) und Stattdessen Fragebogen nutzen (sekundaer). Kein leerer Score-Screen S009 wird angezeigt. Technischer Fehlercode wird im Hintergrund geloggt (wenn Analytics-Consent vorliegt). Timeout-Warnung erscheint proaktiv bei >50 Sekunden Analysezeit. |
| Invite Code ungueltig oder bereits verbraucht | S002, S005 | S005 zeigt inline Validierungs-Feedback direkt unter dem Eingabefeld mit spezifischer Fehlermeldung: Ungültiger Code (bei falschem Code) oder Dieser Code wurde bereits verwendet (bei verbrauchtem Code). Kein Modal, kein Page-Reload. CTA Code einloesen bleibt aktiv fuer neuen Versuch. Link zur Warteliste wird prominent sichtbar als naechster logischer Schritt. |
| Upload-Datei mit falschem Format oder zu gross | S007 | S007 wechselt sofort in Falsches-Format-Fehler-State oder Datei-zu-gross-Fehler-State. Fehler wird inline im Upload-Bereich angezeigt, nicht als separates Modal. Akzeptierte Formate werden als Chips angezeigt: JSON, TXT, MD. Groessenlimit wird explizit genannt (z.B. max 10 MB). Scan-CTA bleibt deaktiviert bis valide Datei hochgeladen. Sekundaerer Hinweis: Kein passendes Format? Nimm den Fragebogen. |
| Consent komplett abgelehnt — nur notwendige Cookies | S003, S009, S010 | App funktioniert vollstaendig — da Core-Funktionalitaet client-side und consent-unabhaengig. Analytics werden nicht initialisiert. Marketing-Tracking findet nicht statt. KI-Content-Kennzeichnung in S009 und S010 bleibt unveraendert sichtbar. Keine Einschraenkung der Scan-Funktion, keine Paywall, keine Benachteiligung. Consent-Einstellung wird lokal gespeichert und bei Neustart nicht erneut abgefragt. |
| Scan-Ergebnis erkennt keine Skills in hochgeladener Datei | S009 | S009 wechselt in Leer-keine-Skills-erkannt-State. Statt Score-Dashboard erscheint erklaerende Meldung: Keine Skills erkannt mit Subtext Was wurde geprueft und was nicht erkannt wurde. Zwei CTAs: Andere Datei hochladen (primaer) und Stattdessen Fragebogen nutzen (sekundaer). Kein leerer Score 0/0 der Nutzer verunsichert. Privacy-Reminder bleibt sichtbar. |
| Wartelisten-Formular Doppeleintrag | S006 | S006 wechselt in Bereits-eingetragen-State nach Formular-Absenden. Meldung: Diese E-Mail ist bereits auf der Warteliste — du wirst benachrichtigt sobald Advisor Pro startet. Kein Fehler-Styling (rot), sondern freundliche Bestaetigung. Social-Proof-Counter wird nicht erneut erhoehen. Nutzer wird nicht bestraft fuer Doppeleintrag-Versuch. |
| Engine-Fehler beim App-Start (Splash-Screen) | S001 | S001 wechselt in Engine-Fehler-State. Statt blockiertem Ladebalken erscheint erklaerende Fehlermeldung mit zwei Optionen: App neu laden (Tap) und Seite im Browser oeffnen als Fallback. Kein endloser Ladezustand. Fehler wird im Hintergrund geloggt sofern minimale Verbindung besteht. Privacy-by-Design-Badge bleibt sichtbar als Vertrauenssignal. |

### Phase-B Screens mit Platzhaltern

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S020 | Skill-Datenbank – Browse & Suche | Kuratierte Skill-Datenbank durchsuchen und installieren | Coming Soon Badge auf Advisor-Pro-Teaser-Screen S013 |
| S021 | Skill-Fit-Check | Persönliche Relevanz-Bewertung eines Skills aus der Datenbank | Nicht sichtbar |
| S022 | Tiefenanalyse-Report (Deep Scan) | IAP-gesicherter erweiterter Scan-Report | Locked-Kachel im Ergebnis-Dashboard S009 mit Upgrade-CTA |
| S023 | Nutzerregistrierung & Account | Account-Anlage für Pro-Tier, Abo-Verwaltung | Nicht sichtbar – Phase A ist account-frei |
| S024 | Pricing Page | Monats- und Jahresabo-Vergleich mit Toggle | Statische Teaser-Sektion im Footer mit Early-Access-Hinweis |
| S025 | Stripe Checkout / Zahlungsflow | IAP und Subscription-Zahlung via Stripe | Nicht sichtbar |
| S026 | Chat-Export Analyse | Chat-Export hochladen und analysieren für D30-Retention | Nicht sichtbar |
| S027 | Pro Dashboard / Account-Übersicht | Abo-Status, Rechnungen, Feature-Übersicht Pro-User | Nicht sichtbar |

---

## 7. Asset-Liste (VERBINDLICH)

### Vollstaendige Asset-Tabelle

| ID | Asset | Beschreibung | Screen(s) | Kategorie | Quelle | Format | Prioritaet |
|---|---|---|---|---|---|---|---|
| **APP-BRANDING** | | | | | | | |
| A001 | App-Icon | Haupt-App-Icon fuer App Store und Google Play sowie Home-Screen. Zeigt das EchoM | S001, Alle | App-Branding | Custom Design | PNG 1024×1024 | 🔴 Launch-kritisch |
| A002 | Splash-Screen-Logo | EchoMatch-Volllogo mit Wortmarke und Icon fuer den Splash-Screen S001. Zentriert | S001 | App-Branding | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A062 | Store-Feature-Grafik (App Store Listing) | Feature-Grafik fuer Google Play Store (1024x500px) und Screenshots-Set fuer App | Alle | App-Branding | Custom Design | PNG 1024×500 + 6 Screenshots | 🔴 Launch-kritisch |
| A063 | Notification-Icon (klein, monochrom) | Kleines monochromes Icon fuer Android-Push-Notifications und iOS-Notification-Ba | S014 | App-Branding | Custom Design | PNG 96×96 monochrom | 🔴 Launch-kritisch |
| **GAMEPLAY-ASSETS** | | | | | | | |
| A009 | Match-3-Spielstein-Sprite-Set | Vollstaendiges Sprite-Set aller Match-3-Spielsteine fuer S003 und S006. Mindeste | S003, S006 | Gameplay-Assets | AI-generiert + Custom | PNG Sprite-Sheet 2×/3× | 🔴 Launch-kritisch |
| A010 | Match-3-Spielfeld-Hintergrund | Vollbild-Hintergrund fuer das Spielfeld in S003 und S006. Thematisch zur Spielwe | S003, S006 | Gameplay-Assets | AI-generiert | PNG 1920×1080 + 2×/3× | 🔴 Launch-kritisch |
| A011 | Match-3-Spezialstein-Sprites | Sprites fuer Sonder- und Booster-Steine im Spielfeld (z.B. Bombe, Blitz-Stein, R | S006 | Gameplay-Assets | AI-generiert + Custom | PNG Sprite-Sheet animiert | 🔴 Launch-kritisch |
| A013 | Spielfeld-Grid-Rahmen | Visueller Rahmen und Zellen-Design des Match-3-Grids in S003 und S006. Beinhalte | S003, S006 | Gameplay-Assets | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A065 | Spielfeld-Ziel-Indikator-Icons | Icon-Set fuer verschiedene Level-Zieltypen in S006 (Sammle X Steine, Zerstoere X | S006, S008 | Gameplay-Assets | Free/Open-Source | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A066 | Hindernisse und Spezialzellen-Sprites | Sprite-Set fuer Level-Hindernisse (Eis, Stein, Kette, Nebel) in S006. Jedes Hind | S006 | Gameplay-Assets | AI-generiert + Custom | PNG Sprite-Sheet animiert | 🔴 Launch-kritisch |
| **UI-ELEMENTE** | | | | | | | |
| A004 | Ladebalken / Loading-Indicator | Visueller Fortschrittsbalken oder animierter Spinner fuer S001 Ladevorgang. Gebr | S001, S006, S011, S012 | UI-Elemente | Lottie | Lottie JSON | 🔴 Launch-kritisch |
| A014 | Zuege-Anzeige / Move-Counter | Visuelles UI-Element das verbleibende Zuege im Spielfeld S006 anzeigt. Beinhalte | S006 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A015 | Punkte-/Score-Anzeige HUD | Score-Counter im Spielfeld-HUD von S006. Beinhaltet animierten Score-Zuwachs (Za | S006 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A016 | Booster-Icons im Spielfeld | Icon-Set fuer alle verfuegbaren Booster in S006 (z.B. Hammer, Shuffle, Extra-Mov | S006 | UI-Elemente | AI-generiert + Custom | PNG 2×/3× + Lottie | 🔴 Launch-kritisch |
| A020 | Reward-Item-Icons | Icon-Set fuer alle Reward-Items die auf S007, S012, S013 angezeigt werden (Muenz | S007, S012, S013, S011 | UI-Elemente | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| A022 | Level-Knoten-Icons | Icon-Sprites fuer Level-Knoten auf der Map S008. Zustaende: Gesperrt (Schloss), | S008 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A029 | Daily-Quest-Card-Design | Visuell gestaltete Quest-Karte fuer S005 und S013. Zeigt Quest-Icon, Fortschritt | S005, S013 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A030 | Quest-Icon-Set | Thematische Icons fuer verschiedene Quest-Typen in S013 (z.B. Schwert fuer Kampf | S013, S005 | UI-Elemente | Free/Open-Source | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A031 | Battle-Pass-Tier-Reward-Visualisierung | Horizontale oder vertikale Tier-Leiste fuer S012 mit jedem Reward-Tier als visue | S012 | UI-Elemente | Custom Design | SVG + Lottie | 🔴 Launch-kritisch |
| A033 | Saison-Timer-Visual | Visueller Countdown-Timer fuer S012 und S013. Zeigt verbleibende Saison-/Quest-Z | S012, S013 | UI-Elemente | Lottie | Lottie JSON | 🟡 Nice-to-have |
| A034 | Shop-Angebots-Karten | Visuell gestaltete Angebotskarten fuer S011. Jeder IAP hat eigene Card mit Produ | S011 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A035 | Foot-in-Door-Angebot-Highlight | Spezielles visuelles Highlight-Design fuer das erste guenstige IAP-Angebot in S0 | S011 | UI-Elemente | Custom Design + Lottie | Lottie JSON + SVG | 🔴 Launch-kritisch |
| A036 | Waehrungs-Icons (Soft und Hard Currency) | Hochwertige Icons fuer alle In-Game-Waehrungen (z.B. Muenzen als Soft Currency, | S006, S007, S011, S012, S013, | UI-Elemente | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| A037 | Social-Hub-Avatar-Rahmen | Dekorative Rahmen fuer Spieler-Avatare in S010. Verschiedene Seltenheits-Stufen | S010, S017 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A038 | Challenge-Card-Design | Visuell gestaltete Challenge-Karte fuer S010. Zeigt herausfordernden Spieler-Ava | S010 | UI-Elemente | Custom Design | SVG + Lottie | 🟡 Nice-to-have |
| A040 | Share-Result-Bild-Template | Visuelles Template fuer generiertes Share-Bild in S015. Zeigt Score, Level-Numme | S015, S007 | UI-Elemente | Custom Design | PNG 1080×1080 | 🟡 Nice-to-have |
| A043 | Profil-Spieler-Avatar-Placeholder | Standard-Avatar-Illustration fuer neuen Spieler ohne eigenes Bild in S017. Zeigt | S017, S010 | UI-Elemente | Free/Open-Source | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A046 | Tab-Bar-Icons | Icon-Set fuer alle 5 Tab-Bar-Eintraege (Home, Puzzle, Story, Social, Shop). Jede | S005, S008, S009, S010, S011 | UI-Elemente | Free/Open-Source | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A048 | Kaltstart-Personalisierungs-Auswahlkarten | Visuell gestaltete Auswahlkarten fuer S020 Spielstil-Praeferenz-Auswahl. Jede Ka | S020 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A049 | Onboarding-Hint-Pfeile und Tutorial-Overlays | Animierte Pfeile, Finger-Tap-Animationen und Highlight-Overlays fuer S003 Tutori | S003 | UI-Elemente | Lottie + Custom | Lottie JSON + SVG | 🔴 Launch-kritisch |
| A052 | Beta-Feedback-Rating-Sterne | Interaktives Stern-Bewertungs-Element fuer S019 Beta-Feedback-Screen. Tappbare S | S019 | UI-Elemente | Lottie | Lottie JSON | 🟢 Beta-only |
| A055 | Coming-Soon-Badge fuer Phase-B | Visuelles Coming-Soon-Badge fuer S010 Social-Hub (Live-Ops Event Hub Teaser) und | S010 | UI-Elemente | Custom Design | SVG + Lottie | 🟡 Nice-to-have |
| A057 | Leaderboard-Top-3-Podest-Design | Visuelles Podest-Design fuer Top-3-Preview im Social-Hub S010 (Phase-A-Version). | S010 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A058 | Haptic-Feedback-Toggle-Icon | Icon fuer Haptic-Feedback-Toggle in S018 Einstellungen. An- und Aus-State visuel | S018 | UI-Elemente | Free/Open-Source | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A059 | Einstellungen-Kategorie-Icons | Icon-Set fuer alle Einstellungs-Kategorien in S018 (Sound, Haptic, Benachrichtig | S018 | UI-Elemente | Free/Open-Source | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A067 | Social-Nudge-Banner-Design | Visuell gestaltetes Banner fuer Social-Nudge nach Session in S007 und S005. Zeig | S007, S005 | UI-Elemente | Custom Design | SVG + Lottie | 🟡 Nice-to-have |
| A068 | Friend-Challenge-Card | Visuelle Karte fuer ausstehende Friend-Challenges im Social Hub. Zeigt Gegner-Av | S010 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A069 | Leaderboard-Rang-Badge | Kleines Badge-Element das den aktuellen Rang des Spielers (Top 3, Top 10, Top 50 | S010, S005 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A070 | Leaderboard-Eintrag-Row | Einzelne Zeile im Freundes-Leaderboard: Avatar links, Spielername, Punktzahl, Ra | S010 | UI-Elemente | Custom Design | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A071 | Social-Invite-Banner | Banner-Komponente im Social Hub fuer den Zustand Keine-Freunde. Illustriertes le | S010 | UI-Elemente | Static | Static | 🟡 Nice-to-have |
| A072 | Share-Card-Level-Gewonnen | Visuell ansprechende Share-Card fuer gewonnene Level. Enthaelt: Spielername, Lev | S007, S015 | UI-Elemente | Dynamic | Dynamic | 🔴 Launch-kritisch |
| A073 | Share-Card-Highscore-Milestone | Spezielle Share-Card fuer Milestone-Events (Erster Highscore, Level-50-Abschluss | S007, S015 | UI-Elemente | Dynamic | Dynamic | 🟡 Nice-to-have |
| A074 | Share-Sheet-Destination-Icons | Icon-Set fuer Social-Share-Destination-Buttons im Share-Sheet Overlay: Instagram | S015 | UI-Elemente | Static | Static | 🔴 Launch-kritisch |
| A075 | Team-Event-Teaser-Card | Phase-A-Platzhalter-Card im Social Hub fuer kuenftige Gilden/Team-Events (S024). | S010 | UI-Elemente | Static | Static | 🟡 Nice-to-have |
| **ILLUSTRATIONEN** | | | | | | | |
| A003 | Splash-Screen-Hintergrund | Vollbild-Hintergrundbild fuer S001 Splash-Screen. Atmosphaerisches Artwork das E | S001 | Illustrationen | AI-generiert + Custom | PNG 2732×2732 | 🔴 Launch-kritisch |
| A005 | Offline-Error-Illustration | Charakterillustration oder thematisches Bild fuer S021 Offline-Fehlerzustand. Ze | S021, S001 | Illustrationen | Free/Open-Source | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A006 | DSGVO-Consent-Illustration | Kleine thematische Illustration oder Icon-Set fuer S002 Consent-Modal. Visualisi | S002 | Illustrationen | Free/Open-Source | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A007 | ATT-Prompt-Visual | Pre-Permission-Erklaerungsbild fuer iOS ATT-Prompt in S002. Zeigt visuell den Nu | S002 | Illustrationen | AI-generiert + Custom | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A008 | Minderjaerigen-Block-Illustration | Freundliche aber klare Illustration fuer S002 COPPA-Block-State. Zeigt altersger | S002 | Illustrationen | AI-generiert + Custom | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A018 | Level-Verloren-Illustration | Empathische aber nicht demotivierende Illustration fuer S007 Verloren-State. Cha | S007 | Illustrationen | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| A021 | Level-Map-Pfad-Grafik | Visueller Fortschrittspfad fuer S008 Level-Map. Geschwungener Weg durch thematis | S008 | Illustrationen | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| A023 | Level-Map-Hintergrund-Welten | Thematische Hintergrundillustrationen fuer verschiedene Welten auf der Level-Map | S008 | Illustrationen | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| A028 | Home Hub Hero-Banner | Dynamisches Hero-Banner-Artwork fuer S005 Home Hub. Wechselt je nach Tageszeit, | S005 | Illustrationen | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| A032 | Battle-Pass-Saison-Banner | Thematisches Key-Art fuer die aktuelle Battle-Pass-Saison auf S012. Zeigt Saison | S012, S005 | Illustrationen | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| A039 | Keine-Freunde-Empty-State-Illustration | Freundliche Illustration fuer S010 Normal-Keine-Freunde-State. Zeigt einladende | S010 | Illustrationen | Free/Open-Source | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A041 | Rewarded-Ad-Angebots-Illustration | Ansprechende Illustration fuer S016 Rewarded-Ad-Angebotsscreen. Zeigt Reward vis | S016 | Illustrationen | AI-generiert | PNG 2×/3× | 🟡 Nice-to-have |
| A045 | Sync-Fehler-Illustration | Thematische Illustration fuer S017 Sync-Fehler-State. Zeigt Verbindungsproblem i | S017 | Illustrationen | Free/Open-Source | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A047 | Push-Notification-Opt-In-Illustration | Erklaerende Illustration fuer S014 Push-Opt-In-Modal. Zeigt visuell den Nutzen v | S014 | Illustrationen | Free/Open-Source | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A056 | Phase-B-Teaser-Illustrationen | Teaser-Artwork fuer S023 Live-Ops Event Hub und S024 Gilden-Card im Social-Hub. | S010 | Illustrationen | AI-generiert + Custom | PNG 2×/3× | 🟡 Nice-to-have |
| **ANIMATIONEN & EFFEKTE** | | | | | | | |
| A012 | Match-Animation-Effekte | Partikel- und Burst-Animationen fuer erfolgreiche Match-3-Kombinationen in S003 | S003, S006 | Animationen & Effekte | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A017 | Level-Gewonnen-Animation | Vollbild-Gewinn-Animation fuer S007 Gewonnen-State. Konfetti, Sterne, Charakter- | S007 | Animationen & Effekte | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A019 | Stern-Bewertungs-Animation | 1-3 Stern-Vergabe-Animation fuer S007 nach Level-Abschluss. Jeder Stern faellt e | S007 | Animationen & Effekte | Lottie | Lottie JSON | 🔴 Launch-kritisch |
| A042 | Ad-Lade-Animation | Kurze Lade-Animation fuer S016 Ad-Laedt-State. Haelt Nutzer beschaeftigt waehren | S016 | Animationen & Effekte | Lottie | Lottie JSON | 🟡 Nice-to-have |
| A050 | KI-Level-Lade-Platzhalter-Animation | Thematische Animations-Szene fuer S006 KI-Level-Latenz-Warten-State. Zeigt Spiel | S006, S008 | Animationen & Effekte | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A051 | Neues-Level-Freischalten-Animation | Feiernde Animation wenn neues Level auf der Map S008 freigeschaltet wird. Level- | S008 | Animationen & Effekte | Lottie + Custom | Lottie JSON | 🟡 Nice-to-have |
| A053 | Feedback-Gesendet-Danke-Animation | Kurze Bestaetigungs-Animation fuer S019 Gesendet-Danke-State. Haekchen-Animation | S019 | Animationen & Effekte | Lottie | Lottie JSON | 🟢 Beta-only |
| A054 | A/B-Test-Loader-Animation | Dezente Lade-Animation fuer S022 A/B-Test-Konfigurations-Loader. Muss transparen | S022, S001 | Animationen & Effekte | Lottie | Lottie JSON | 🔴 Launch-kritisch |
| A060 | Reward-Freischalten-Animation | Animiertes Freischalten von Rewards auf S012 Battle-Pass und S013 Quest-Abschlus | S012, S013, S007 | Animationen & Effekte | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A061 | Quest-Abgeschlossen-Checkmark-Animation | Animiertes Checkmark fuer Quest-Abschluss in S013 und S005. Gruen ausfullendes H | S013, S005 | Animationen & Effekte | Lottie | Lottie JSON | 🟡 Nice-to-have |
| A064 | IAP-Kauf-Bestaetigung-Animation | Kurze Feier-Animation auf S011 nach erfolgreichem IAP-Kauf. Reward-Items regnen | S011 | Animationen & Effekte | Custom Design | Lottie JSON | 🟡 Nice-to-have |
| **DATENVISUALISIERUNG** | | | | | | | |
| A044 | Statistik-Visualisierungs-Grafiken | Visuelle Charts und Grafiken fuer Spieler-Statistiken in S017. Beinhaltet Fortsc | S017 | Datenvisualisierung | Native + Custom | SVG / Native Components | 🟡 Nice-to-have |
| **STORY / NARRATIVE ASSETS** | | | | | | | |
| A024 | Narrative-Hook-Sequenz-Artwork | Vollbild-Story-Artwork fuer S004 Narrative Hook. 3-5 Panels oder ein kontinuierl | S004 | Story/Narrative Assets | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| A025 | Story-Charakter-Portraits | Portrait-Illustrationen aller Haupt-Story-Charaktere fuer S004, S009 und Narrati | S004, S009 | Story/Narrative Assets | Custom Design | PNG 2×/3× | 🔴 Launch-kritisch |
| A026 | Story-Kapitel-Cover-Illustrationen | Cover-Artwork fuer jedes Story-Kapitel in S009. Thematisches Bild das Kapitel-In | S009 | Story/Narrative Assets | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| A027 | Story-Scene-Hintergruende | Hintergrundillustrationen fuer Story-Sequenzen in S004 und S009. Verschiedene Or | S004, S009 | Story/Narrative Assets | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| **SOCIAL-ASSETS** | | | | | | | |
| A068 | Friend-Challenge-Card | Visuelle Karte fuer ausstehende Friend-Challenges im Social Hub. Zeigt Gegner-Av | S010 | Social-Assets | Custom Design | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A069 | Leaderboard-Rang-Badge | Kleines Badge-Element das den aktuellen Rang des Spielers (Top 3, Top 10, Top 50 | S010, S005 | Social-Assets | Custom Design | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A070 | Leaderboard-Eintrag-Row | Einzelne Zeile im Freundes-Leaderboard: Avatar links, Spielername, Punktzahl, Ra | S010 | Social-Assets | Custom Design | SVG + PNG 2×/3× | 🟡 Nice-to-have |
| A071 | Social-Invite-Banner | Banner-Komponente im Social Hub fuer den Zustand Keine-Freunde. Illustriertes le | S010 | Social-Assets | Static | Static | 🟡 Nice-to-have |
| A072 | Share-Card-Level-Gewonnen | Visuell ansprechende Share-Card fuer gewonnene Level. Enthaelt: Spielername, Lev | S007, S015 | Social-Assets | Dynamic | Dynamic | 🔴 Launch-kritisch |
| A073 | Share-Card-Highscore-Milestone | Spezielle Share-Card fuer Milestone-Events (Erster Highscore, Level-50-Abschluss | S007, S015 | Social-Assets | Dynamic | Dynamic | 🟡 Nice-to-have |
| A074 | Share-Sheet-Destination-Icons | Icon-Set fuer Social-Share-Destination-Buttons im Share-Sheet Overlay: Instagram | S015 | Social-Assets | Static | Static | 🔴 Launch-kritisch |
| A075 | Team-Event-Teaser-Card | Phase-A-Platzhalter-Card im Social Hub fuer kuenftige Gilden/Team-Events (S024). | S010 | Social-Assets | Static | Static | 🟡 Nice-to-have |
| **MONETARISIERUNGS-ASSETS** | | | | | | | |
| A076 | Battle-Pass-Fortschrittsbalken | Horizontale Fortschrittsanzeige des Battle-Pass mit aktueller XP-Position, naech | S012, S005 | Monetarisierungs-Assets | Dynamic | Dynamic | 🔴 Launch-kritisch |
| A077 | Battle-Pass-Reward-Icons-Set-Free | Vollstaendiges Icon-Set fuer alle Free-Tier-Battle-Pass-Rewards einer Saison (ca | S012 | Monetarisierungs-Assets | Static | Static | 🔴 Launch-kritisch |
| A078 | Battle-Pass-Reward-Icons-Set-Premium | Vollstaendiges Icon-Set fuer alle Premium-Tier-Battle-Pass-Rewards (ca. 15-20 Ic | S012 | Monetarisierungs-Assets | Static | Static | 🔴 Launch-kritisch |
| A079 | Battle-Pass-Saison-Timer | Countdown-Timer-Komponente auf S012 und S005 die verbleibende Saison-Zeit anzeig | S012, S005 | Monetarisierungs-Assets | Dynamic | Dynamic | 🔴 Launch-kritisch |
| A080 | Battle-Pass-Upgrade-CTA-Button | Prominenter Kauf-Button fuer den Battle-Pass-Upgrade auf S012. Zeigt Preis ($4,9 | S012 | Monetarisierungs-Assets | Static | Static | 🔴 Launch-kritisch |
| A081 | Foot-in-Door-Angebot-Banner | Spezieller Erstkaeufer-Angebots-Banner im Shop (S011). Zeitlimitiertes Einstiegs | S011 | Monetarisierungs-Assets | Dynamic | Dynamic | 🔴 Launch-kritisch |
| A082 | Shop-Item-Card | Wiederverwendbare Produkt-Card-Komponente fuer alle Shop-Eintraege. Besteht aus: | S011 | Monetarisierungs-Assets | Dynamic | Dynamic | 🔴 Launch-kritisch |
| A083 | Rewarded-Ad-Angebot-Illustration | Illustration fuer den Rewarded-Ad-Interstitial (S016) im Angebot-Aktiv-State. Ze | S016 | Monetarisierungs-Assets | Static | Static | 🔴 Launch-kritisch |
| A084 | Rewarded-Ad-Fehler-Illustration | Illustration fuer den Ad-Fehler-Fallback-State auf S016. Freundliches Fehler-Mot | S016 | Monetarisierungs-Assets | Static | Static | 🟡 Nice-to-have |
| A085 | Waehrungs-Icons-Set | Icon-Set fuer alle In-Game-Waehrungen: Muenzen (Soft Currency, gold), Edelsteine | S005, S006, S011, S012, S013 | Monetarisierungs-Assets | Static | Static | 🔴 Launch-kritisch |
| A086 | Booster-Icons-Set | Icon-Set fuer alle spielbaren Booster (ca. 4-6 Typen): Bombe, Farb-Wirbel, Zeile | S006, S011, S016 | Monetarisierungs-Assets | Static | Static | 🔴 Launch-kritisch |
| A087 | IAP-Bestaetigung-Overlay | Post-Purchase-Bestaetigung nach erfolgreichem IAP. Zeigt: gekauftes Item gross i | S011, S012 | Monetarisierungs-Assets | Dynamic | Dynamic | 🟡 Nice-to-have |
| A088 | IAP-Fehler-Dialog | Fehlerdialog fuer fehlgeschlagene IAP-Transaktionen auf S011. Klar formulierter | S011 | Monetarisierungs-Assets | Static | Static | 🟡 Nice-to-have |
| **MARKETING-ASSETS** | | | | | | | |
| A089 | App-Store-Screenshots-Set-iOS | Set aus 6-8 App-Store-Screenshots fuer den iOS App Store (iPhone 6.7 Zoll Format | | Marketing-Assets | Static | Static | 🔴 Launch-kritisch |
| A090 | App-Store-Screenshots-Set-Android | Set aus 6-8 App-Store-Screenshots fuer den Google Play Store (Phone-Format 1080x | | Marketing-Assets | Static | Static | 🔴 Launch-kritisch |
| A091 | App-Store-Icon-Varianten | App-Icon in allen benoetigen Groessen und Varianten: iOS (1024x1024px fuer Store | | Marketing-Assets | Static | Static | 🔴 Launch-kritisch |
| A092 | App-Preview-Video-Thumbnail | Thumbnail/Poster-Frame fuer das App-Preview-Video im App Store und Play Store. Z | | Marketing-Assets | Static | Static | 🔴 Launch-kritisch |
| A093 | Press-Kit-Cover-Visual | Hochaufloesendes Key-Art fuer Press-Kit und PR-Verwendung. Zeigt EchoMatch-Chara | | Marketing-Assets | Static | Static | 🟡 Nice-to-have |
| A094 | Social-Media-Post-Templates | Template-Set fuer Social-Media-Marketing-Posts: Instagram-Feed-Post (1080x1080px | | Marketing-Assets | Static | Static | 🟡 Nice-to-have |
| A095 | TikTok-Ad-Creative-Frame-Overlay | Visuelles Overlay-Frame-System fuer TikTok-Ad-Creatives: Failed-Level-Hook-Templ | | Marketing-Assets | Static | Static | 🟡 Nice-to-have |
| A096 | Meta-Ad-Creative-Templates | Visual-Templates fuer Meta-Ads (Facebook/Instagram): Carousel-Card-Template (108 | | Marketing-Assets | Static | Static | 🔴 Launch-kritisch |
| A097 | Discord-Server-Banner und Branding | Discord-Server-Branding-Paket: Server-Banner (960x540px), Server-Icon (512x512px | | Marketing-Assets | Static | Static | 🟡 Nice-to-have |
| **LEGAL-UI** | | | | | | | |
| A098 | DSGVO-Consent-Screen-Layout | Vollstaendiges Screen-Layout fuer S002 DSGVO-Consent. Enthaelt: EchoMatch-Logo o | S002 | Legal-UI | Static | Static | 🔴 Launch-kritisch |
| A099 | ATT-Pre-Prompt-Illustration | Custom-Erklaerungsscreen vor dem iOS-System-ATT-Dialog auf S002. Zeigt freundlic | S002 | Legal-UI | Static | Static | 🔴 Launch-kritisch |
| A100 | COPPA-Alterscheck-UI | Altersverifikations-Interface auf S002 fuer COPPA-Compliance. Numerische Jahrgan | S002 | Legal-UI | Static | Static | 🔴 Launch-kritisch |
| A101 | Minderjaehrigen-Blocked-Screen | Screen der erscheint wenn COPPA-Alterscheck ergibt dass Nutzer unter 13 Jahre al | S002 | Legal-UI | Static | Static | 🔴 Launch-kritisch |
| A102 | Datenschutz-Consent-Toggle-Komponente | Wiederverwendbare Toggle-Komponente fuer Datenschutz-Einstellungen. Besteht aus: | S002, S018 | Legal-UI | Static | Static | 🔴 Launch-kritisch |
| A103 | Push-Opt-In-Erklaer-Illustration | Illustration fuer S014 Push-Notification-Opt-In-Screen. Zeigt freundlichen Erkla | S014 | Legal-UI | Static | Static | 🟡 Nice-to-have |
| A104 | Battle-Pass-Content-Visibility-Compliance-Badge | Kleines Informations-Element auf S012 das alle Battle-Pass-Inhalte (auch Premium | S012 | Legal-UI | Static | Static | 🔴 Launch-kritisch |
| A105 | Impressum-und-Datenschutz-Link-Footer | Standardisierter Footer-Bereich mit Links zu: Datenschutzerklaerung, Nutzungsbed | S018, S002 | Legal-UI | Static | Static | 🔴 Launch-kritisch |
| A106 | Kaltstart-Personalisierungs-Auswahl-UI | UI-Komponenten fuer S020 Kaltstart-Personalisierungs-Fallback. Enthaelt: erklaer | S020 | Legal-UI | Static | Static | 🔴 Launch-kritisch |
| A107 | Update-Required-Screen-Visual | Visueller Screen fuer den Update-Required-State von S001. Erklaert freundlich da | S001 | Legal-UI | Static | Static | 🔴 Launch-kritisch |

### Beschaffungswege pro Asset

| Quelle | Anzahl Assets | Anteil |
|---|---|---|
| Custom Design (Freelancer) | 28 | 26% |
| AI-generiert + Custom Finish | 18 | 17% |
| Free/Open-Source | 12 | 11% |
| Lottie (Free/Premium) | 10 | 9% |
| Static (Text/UI-Komponente) | 39 | 37% |
| Dynamic (Runtime-generiert) | 0 | 0% |

### Format-Anforderungen pro Plattform

| Asset-Typ | Format | Auflösung/Größe | Tool | Hinweise |
|---|---|---|---|---|
| unity_sprites | PNG / Sprite Sheet |  | TexturePacker 7.x → Unity Importer | Keine POT-Pflicht ab Unity 2022+, aber 2er-Potenzen empfohlen für Kompression |
| game_piece_sprites | PNG Sprite Sheet via TexturePacker |  |  |  |
| backgrounds | PNG | 1920x1080px @2x (3840x2160 Master) |  | Hintergrund-Layer separat exportieren (BG-Layer, Mid-Layer, FX-Layer) für Parallax |
| icons | SVG für UI-Icons, PNG @2x/@3x für In-Game |  |  |  |
| animations | Lottie JSON (UI-Animationen, Loading, Feedback) |  | After Effects 2025 + Bodymovin 5.x Plugin | Statisches PNG @2x wenn Lottie >500KB oder Runtime-Performance-Problem |
| app_icon_ios | PNG |  | Figma Export + Asset Catalog Xcode | Kein Alpha-Kanal, kein Gradient über gesamte Fläche (Apple Review Richtlinie) |
| app_icon_android | PNG Adaptive Icon |  | Android Studio Asset Studio + Figma Export | Adaptive Icon: Foreground + Background als separate Layer im XML definiert |
| screenshots_store | PNG (kein JPEG, keine Kompressionsartefakte) |  | Figma Store-Screenshot-Template + Photoshop Finalisierung |  |
| audio | WAV (Master) + OGG/AAC (komprimiert) |  |  | Loop-Points in BGM-Tracks testen (kein Click am Loop-Punkt) |
| fonts | TTF / OTF Master → Unity Font Asset (TMP) |  | TextMesh Pro Font Asset Creator | Lizenz-Prüfung für Mobile-Embedding vor Integration (SIL OFL oder Commercial-Lizenz) |

### Plattform-Varianten Anzahl

*   **Gesamtanzahl Assets:** 107
*   **Plattform-Varianten gesamt:** 164 (inkl. iOS/Android spezifische Icons, Store-Grafiken)

### Dark-Mode-Varianten

*   **Dark-Mode-Varianten nötig:** 65 Assets (explizit in Asset Discovery als "ja" oder "kontrastsicher" markiert).
*   **Ausnahmen:** Gameplay-Hintergründe (A010) und Story-Artworks (A024, A025, A026, A027) sind primär für die Dark-Field-Ästhetik konzipiert und benötigen keine separate Light-Mode-Variante. Shop-