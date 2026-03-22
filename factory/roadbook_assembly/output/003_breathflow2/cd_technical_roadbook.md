Gerne, hier ist das Creative Director Technical Roadbook für EchoMatch, präzise, technisch und actionable, wie von der DriveAI Swarm Factory gefordert.

---

# Creative Director Technical Roadbook: EchoMatch
## Version: 1.0 | Status: **VERBINDLICH** für alle Produktionslinien

---

## 1. Produkt-Kurzprofil

*   **App Name:** EchoMatch
*   **One-Liner:** EchoMatch redefiniert das Match-3-Genre mit einer dunklen, atmosphärischen Ästhetik, KI-gesteuerter Personalisierung und emotional resonanten Interaktionen, die sich vollständig vom Candy-Crush-Standard abkoppeln.
*   **Plattformen:** Mobile (iOS, Android)
*   **Tech-Stack:** Unity (Universal Render Pipeline - URP), Firebase (Firestore, Remote Config), Google Cloud Run (für Backend-Logik), Native Share Plugin (für Social Sharing).
*   **Zielgruppe:** Berufstätige Erwachsene, 18–34 Jahre, primär in Tier-1-Märkten (DACH, Nordamerika, UK). Sucht ein hochwertiges, immersives Spielerlebnis für kurze Pausen (Commute, Wartezeiten), das Entspannung bietet, ohne infantil zu wirken. Schätzt Ästhetik, subtile Personalisierung und soziale Verbindung ohne aggressiven Wettbewerbsdruck.

---

## 2. Design-Vision (**VERBINDLICH**)

### Design-Briefing
EchoMatch ist ein Match-3-Puzzle-Spiel das sich visuell und emotional vollständig vom Candy-Crush-Industriemodell abkoppelt. Das Spielfeld ist dunkel — Mitternachtsblau-Schiefergrün (#0D0F1A bis #1A1D2E) als Grundschicht — und die Spielsteine sind selbstleuchtende Objekte die Licht emittieren statt reflektieren, realisiert durch Unity URP Bloom-Post-Processing und Emission-Maps. Die App fühlt sich an wie ein vertrautes Gespräch mit jemandem der dich wirklich kennt: ruhig genug zum Abschalten, lebendig genug um nicht aufzuhören. Energie-Level ist 6/10 — pulsierend und rhythmisch, niemals explodierend oder chaotisch. Navigation ist kontextuell statt statisch: es gibt keine feste Bottom-Bar mit fünf Icons, stattdessen reagiert die UI auf Tageszeit, Session-Phase und Quest-State. Animationen atmen mit 600–900ms Ease-In-Out statt in 200ms zu bursten. Haptik ist dreischichtig und narrativ bedeutsam. Sound ist Resonanz, nicht Explosion. Reward-Screens verzichten auf Konfetti und AMAZING-Schriften — stattdessen eine 1,5-sekündige goldene Farbverschiebung des gesamten Screens und eine lesbare Zusammenfassung der eigenen Spielhistorie. Jede Designentscheidung muss sich gegen diese Frage behaupten: Würde Candy Crush das genauso machen? Wenn ja, ist es falsch.

### Emotionale Leitlinie pro App-Bereich (**PFLICHT**)

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

### Differenzierungspunkte (**PFLICHT** — mindestens 3)

| # | Differenzierung | Beschreibung | Betroffene Screens | Status |
|---|---|---|---|---|
| **D1** | **Dark-Field Luminescence** | Spielfeld-Hintergrund ist #0D0F1A bis #1A1D2E (tiefdunkles Blau-Grau). Spielsteine sind selbstleuchtende Objekte mit Unity URP Bloom-Post-Processing und Emission-Maps — sie emittieren Licht, sie reflektieren es nicht. Roter Stein = Glut. Blauer Stein = biolumineszentes Wasser. Hintergrund pulsiert subtil bei Combos. Farbtemperatur der Steine wechselt kapitelbasiert via ScriptableObjects: Kapitel 1 = kühle Töne, Kapitel 3 = warme Amber-Töne. Performant ab Snapdragon 678+ durch skalierbare Bloom-Intensität. | S001, S004, S006, S008, S009 | **VERBINDLICH** — keine Verhandlung |
| **D2** | **Kontextuelle Navigation** | Keine feste Bottom-Bar mit 5 Icons. Navigation reagiert auf Tageszeit, Quest-State und Session-Phase: 6–10 Uhr morgens = Daily Quest dominiert, Social minimiert; 12–14 Uhr = kompakte Commuter-Ansicht; 19–23 Uhr = Story-Hub-Teaser prominent, Shop-Nudge für Entspannungs-Session. Social-Nudges erscheinen als Lichtpuls auf Freundes-Avataren im Header statt als Push-Banner. Freunde sind als Lichtpunkte ambient auf der Level-Map sichtbar (Zenly-Prinzip) — kein separater Social-Tab nötig. | S005, S007, alle Hub-Screens | **VERBINDLICH** — keine Verhandlung |
| **D3** | **Implizites Spielstil-Tracking ab Sekunde 1** | Das Onboarding-Match (S003) erfasst unsichtbar: Pausenlänge zwischen Zügen (Grübler vs. Intuitiv), Zuggeschwindigkeit, Combo-Orientierung vs. schnelles Räumen. Kein Fragebogen, keine explizite Abfrage. Das erste echte KI-Level ist bereits personalisiert. Die narrative Hook-Sequenz (S004) passt ihr visuelles Setting an den erkannten Spieltyp an: Intuitiv-Schnell = kinetischere, städtischere Welt; Grübler = tiefere, mythologischere Welt. Personalisierung beginnt in Sekunde 1, ist für den Nutzer vollständig unsichtbar. | S003, S004, S006 | **VERBINDLICH** — keine Verhandlung |
| **D4** | **Post-Session-Screen als Poster / Share-Card** | Kein generischer Reward-Overlay mit Konfetti. Der Ergebnis-Screen ist als Poster-Ästhetik designed (Spotify Wrapped-Prinzip): große isolierte Zahl oder Satz auf dunklem Grund, eine Akzentfarbe, lesbare Zusammenfassung des eigenen Spielstils ("Du hast heute 3 Cascades in einem Zug ausgelöst"). Format ist nativ share-optimiert — Nutzer schicken es weil es wie ein Statement aussieht, nicht wie ein UI-Screenshot. | S008, S009 | **VERBINDLICH** — keine Verhandlung |
| **D5** | **Story-NPC als Interface-Brecher** | Narrative Figuren können außerhalb ihrer Story-Screens erscheinen und das Interface kommentieren (Duolingo-Owl-Prinzip). Beispiel: NPC taucht nach einem verlorenen Level im Home Hub auf und gibt einen kontextuellen Kommentar im Ton der Spielwelt — kein generisches "Try again!". Diese Momente sind selten (max. 1× pro Woche) und dadurch bedeutsam. Sind primär für virales Social-Sharing designed: Out-of-Character-Momente die Nutzer screenshotten. | S005, S008, S009 | **VERBINDLICH** — keine Verhandlung |

### Anti-Standard-Regeln (**VERBOTE** — mindestens 4)

| # | **VERBOTEN** | **STATTDESSEN** | Betroffene Screens | Begründung |
|---|---|---|---|---|
| **A1** | Hypersaturierte Primärfarben auf weißem oder hellem Hintergrund — Candy-Crush-Palette, Knallrot/Knallblau/Knallgrün auf Weiß | Dunkle Grundpalette (#0D0F1A–#1A1D2E), selbstleuchtende Steine via Bloom-Shader, Bernstein- und Kupfer-Akzente, kapitelbasierte Farbtemperatur-Shifts | S006, S001, S004, alle Spielfeld-Screens | Das gesamte Genre cargo-cultet Candy Crush (2012); heller Hintergrund ist das stärkste visuelle Identitätsmerkmal des Einheitsbreis; Dunkelfeld differenziert sofort und ist Qualitätssignal für 18–34-Zielgruppe (Genshin, Alto's Odyssey, Robinhood) |
| **A2** | Feste Bottom-Navigation-Bar mit 4–5 statischen Icons die dauerhaft sichtbar ist | Kontextuelle Navigation die auf Tageszeit, Quest-State und Session-Phase reagiert; soziale Präsenz als ambient leuchtende Elemente auf der Level-Map; Long-Press-Previews und Swipe-Shortcuts als Haupt-Navigations-Geste | S005, S007, alle Hub-Screens | Identisches Mental-Model bei allen Wettbewerbern ohne Ausnahme; feste Bottom-Bar ist das generischste UI-Element des Mobil-Genres; kontextuelle Navigation folgt dem Nutzer statt ihn zu verwalten |
| **A3** | Konfetti-Regen, goldene 1–3-Sterne, "AMAZING!" / "GREAT!" in fetter Type über 100pt, Coin-Sprung-Animationen auf Reward-Screens | 1,5-sekündige goldene Farbverschiebung des gesamten Screens; lesbare Spielhistorie als Poster-Ästhetik; warme Pause statt visueller Überwältigung; Share-optimiertes Format statt Overlay | S008, S009 | Emotional infantil und visuell vollständig austauschbar — alle fünf Top-Wettbewerber nutzen identische Reward-Screen-Sprache; die Reduktion ist selbst das emotionale Statement (Robinhood-Prinzip) |
| **A4** | Roter "BEST VALUE!"-Banner schräg über Shop-Kacheln, Vollbild-Grid mit Produkt-Kacheln, roter Countdown-Timer als Druck-Element, identische Preisarchitektur $0.99/$4.99/$9.99/$19.99 ohne visuelle Differenzierung | Shop öffnet sich als hochwertiger Katalog — viel Luft, klare Hierarchie, kein Schreien; Preisarchitektur visuell klar strukturiert mit Blackspace; Vertrauen ist das Design; kein visueller Druckaufbau durch Farbe oder Timer | S010, alle Shop-Screens | Identische Store-Architektur bei allen Wettbewerbern; BeReal-Prinzip: das Weglassen von Druck-Design ist selbst das Statement; Zielgruppe 18–34 ist immun gegen generische Druck-Mechanik und reagiert auf wahrgenommenes Vertrauen mit höherer Konversionsrate |
| **A5** | Hand-Cursor der ersten Zug zeigt, Tutorial-Overlay mit abgedunkeltem Hintergrund, statische Dialog-Bubble mit erklärender Figur | Spielfeld erscheint ohne Overlay; subtiles einmaliges Pulsieren der Steine als organische Aufmerksamkeits-Lenkung nach 4 Sekunden Inaktivität (Scale 1.0→1.03→1.0 in 1,2 Sek.); erster Stein folgt dem Finger mit 20% Nachzieh-Elastizität wie durch Wasser; Entdeckung durch Spielen nicht durch Erklären | S003 | Identisches Onboarding bei allen Wettbewerbern; instruiertes Onboarding kommuniziert implizit Misstrauen in den Nutzer; entdeckendes Onboarding erzeugt sofortige Kompetenz-Emotion — kritisch für D1-Retention (Entscheidung in ersten 60 Sekunden) |
| **A6** | Burst-Partikel-Explosion beim Match als primäres Feedback | Resonanz-Puls: Stein-Match löst einen Ton aus der nachhallt statt berstet; Cascade-Töne steigen auf statt ab; Special-Steine formen sich via 400ms Morphing-Animation mit tiefem Haptik-Puls; dreischichtige adaptive Sound-Schicht die mit dem Spieltempo atmet | S006, S008 | Physikalisch vorhersehbare Burst-Effekte bei allen Wettbewerbern ohne Ausnahme; Resonanz ist psychologisch nachhaltiger als Explosion; aufsteigende Töne signalisieren Erfolg stärker als abfallende |

### Wow-Momente (**PFLICHT**-Implementierung — mindestens 3)

| # | Name | Screen | Was passiert | Warum kritisch |
|---|---|---|---|---|
| **W1** | **Logo-Genesis** | S001 | Aus dem dunklen Hintergrund bilden sich drei Spielsteine in den App-Farben, ordnen sich zu einem Match, verschwinden mit einem weichen Resonanz-Puls (einzelner tiefer Kristallton), und aus diesem Puls formt sich das EchoMatch-Logo. Ladezeit ≤2 Sek. — die Animation ist nie fertig bevor sie endet, sie ist die Ladezeit. Bei Slow-Connection wiederholt der Puls sich ruhig als Herzschlag-Echo. | Erste 2 Sekunden prägen den emotionalen Kontrakt — Nutzer erlebt sofort: diese App ist anders als Candy Crush; Logo-Genesis kommuniziert ohne Wort die Kernmechanik und visuelle Identität; kein anderer Wettbewerber hat einen Splash der selbst eine Mini-Geschichte erzählt |
| **W2** | **Der lebendige erste Stein** | S003 | Der erste Stein den der Nutzer berührt leuchtet von innen heraus auf und folgt dem Finger mit 20% Nachzieh-Elastizität — nicht pixelgenau, wie durch Wasser gezogen. Haptik: leichtes Ticken beim Drag-Start, mittleres Snap beim Einrasten (nicht beim Loslassen — am Snap-Moment), weiches kurzes Rumble wie eine verstummende Stimmgabel beim erfolgreichen Match. Cascade-Töne steigen auf. Kein Tutorial-Text, keine Erklärung — das Feld selbst ist der Lehrer. | Entscheidung über Installation-Retention fällt in den ersten 60 Sekunden; der erste Stein-Touch ist der emotionalste Moment des gesamten Funnels; Elastizität und Eigenleuchten kommunizieren sofort Premium-Qualität und erzeugen das Kompetenz-Gefühl das alle anderen Screens aufbauen |
| **W3** | **Goldene Ausatmung** | S008, S009 | Nach Level-Abschluss keine Konfetti-Explosion. Das Spielfeld atmet einmal aus — alle Steine verblassen sanft innerhalb von 400ms. Dann: der gesamte Screen-Hintergrund verschiebt sich in 1,5 Sek. zu warmem Gold (#C8960C, Sättigung 60%, nicht grell). In dieser Goldpause erscheint eine einzelne Zeile die den Spielstil des Nutzers beschreibt ("Heute: 3 Cascades. Durchschnittszug: 1,4 Sekunden."). Dann: Poster-Format-Share-Card die nativ geteilt werden kann. | Stärkster Kontrastmoment zum Genre — jeder der das zum ersten Mal sieht weiß sofort: das ist nicht Candy Crush; die goldene Pause ist emotional nachhaltiger als Konfetti-Überwältigung; Poster-Share-Card ist der eingebaute virale Mechanismus (Spotify Wrapped-Prinzip); dieser Moment wird auf TikTok geteilt weil er so anders aussieht |
| **W4** | **NPC Interface-Brecher** | S005, S008 | Nach einem verlorenen Level taucht ein Story-NPC als kleines Element im Home Hub auf und hinterlässt einen kurzen kontextuellen Kommentar im Ton der Spielwelt — nie generisch, immer zum Spielstil des Nutzers passend. Max. 1× pro Woche, dadurch selten und bedeutsam. Animation: NPC gleitet von der Bildschirmkante herein (300ms Ease-Out), bleibt 4 Sekunden sichtbar, zieht sich zurück. Tap auf NPC öffnet eine Mini-Story-Sequenz. | Duolingo-Owl-Prinzip angewendet auf narrative Spielwelt — Vierte-Wand-Bruch ist der viralste UI-Moment den Apps produzieren können; erzeugt emotionale Bindung an Charaktere außerhalb der Story-Screens; gibt Nutzern einen Screenshot-würdigen Moment der EchoMatch von allen Wettbewerbern unterscheidet |
| **W5** | **Spieler-Lichtpunkte auf der Level-Map** | S007 | Freunde-Avatare erscheinen als kleine, sanft pulsierende Lichtpunkte direkt auf ihrem aktuellen Level-Punkt der Map — ohne separaten Social-Tab. Ein Freund der gerade aktiv spielt pulsiert schneller (1 Puls/Sek.). Ein Freund der heute noch nicht gespielt hat: minimale Helligkeit, langsamer Puls. Challenge-Einladung: der Lichtpunkt des einladenden Freundes pulsiert in einer zweiten Farbe (Bernstein statt Weiß). Social-Präsenz ist immer ambient sichtbar, nie aufdringlich. | Zenly-Prinzip: soziale Aktivität passiert auf dem primären visuellen Layer; reduziert Tab-Depth auf null; macht soziale Verbindung zu einem natürlichen Teil der Spielwelt statt eines isolierten Features; erzeugt FOMO durch ambient sichtbare Aktivität ohne Push-Notification-Druck |

### Interaktions-Prinzipien

**Touch-Reaktion:**
Jede Berührung erhält sofortiges visuelles Echo — der berührte Stein leuchtet innerhalb von 16ms auf (ein Frame). Drags haben 20% Nachzieh-Elastizität (das Objekt folgt dem Finger wie durch Wasser, nicht pixelgenau). Unmögliche Züge werden nicht mit Fehler-Feedback bestraft — der Stein federt neutral zurück, kein Fehler-Buzz, kein negativer Feedback-Loop. Snap-Feedback (Einrasten) erfolgt am Snap-Moment, nicht beim Finger-Loslassen.

**Animations-Prinzip:**
Atmend statt burstend. Standard-Ease ist Ease-In-Out über 600–900ms für alle narrativen und UI-Übergänge. Gameplay-Animationen sind schneller (Match-Auflösung: 300ms, Stein-Fall: physikbasiert mit leichtem Overshoot-Bounce 8%). Special-Stein-Entstehung: 400ms Morphing-Animation (Metall das sich selbst in eine Form zieht). Hintergrund-Puls bei Combo: Bloom-Intensität steigt von 0.4 auf 0.7 in 200ms, fällt in 600ms zurück. Kein Element animiert ohne Bedeutung — jede Animation kommuniziert Information oder Emotion.

**Feedback-Prinzip:**
Dreischichtig und narrativ bedeutsam:
1.  Leichtes Ticken beim Stein-Drag-Start (Hinweis: Aktion beginnt)
2.  Mittleres Snap beim Einrasten (Bestätigung: Zug registriert)
3.  Tiefes Rumble bei Cascade-Combo: 3-Match = 80ms, 5-Match = 200ms, länger = mehr Gewicht; fühlt sich wie eine Stimmgabel an die langsam verstummt — nie wie ein Fehler-Buzz oder ein Alarm.

Kein negativer Feedback-Buzz für falsche Inputs — neutrale Rückfeder statt Bestrafung.

**Sound-Prinzip:**
Resonanz statt Explosion. Das Spielfeld hat eine adaptive Sound-Schicht mit drei Ebenen:
1.  Bewegungs-Whoosh beim Drag (sehr leise, 20% Lautstärke)
2.  Resonanz-Kling beim Match-Moment — ein Ton der nachhallt, kein Burst
3.  Kaskaden-Töne beim Stein-Fall die aufsteigen statt abfallen (aufsteigend = Erfolg)

Special-Stein-Typen haben eigene Resonanz-Signaturen: Bomb = tiefes Wummern, Line-Clearer = hoher Sweep, Color-Bomb = kurze harmonische Akkord-Folge. Das Tempo der Ambient-Schicht beschleunigt organisch mit dem Spieltempo des Nutzers — langsame Züge = tiefes ruhiges Ambient, schnelle Züge = erhöhtes rhythmisches Tempo. Kein Ton überschreit die anderen — Mixing ist Teil des Designs, kein Afterthought.

Narrative Screens (S001, S002, S004): Stille ist aktiv eingesetzt als emotionales Medium. Sound erscheint gezielt, nicht dauerhaft.

---

## 3. Stil-Guide (**VERBINDLICH**)

### Farbpalette

| Name | Hex | Verwendung |
|---|---|---|
| Echo Violet | `#5B2ECC` | Hauptfarbe für CTA-Buttons, aktive Navigation, Links, Primary-Actions wie Battle-Pass und Level-Start |
| Match Ember | `#FF6B35` | Sekundäre Akzente für Streak-Indikatoren, Booster-Highlights, Quest-Fortschrittsbalken und Saison-Timer-Dringlichkeit |
| Gold Spark | `#FFD700` | Reward-Icons, Coin-Icons, Battle-Pass-Tier-Highlights, Score-Zuwachs-Animationen, Premium-Inhalte |
| Echo Teal | `#00C9A7` | Erfolgs-Feedback auf Spielfeld, Match-Effekte, Daily-Quest-Abschluss, Level-Complete-Sekundärfarbe |
| background_light | `#F4F0FF` | Light Mode Hintergrund für alle nicht-spielbezogenen Screens (Hub, Shop, Profil, Quests) |
| background_dark | `#120D2A` | Dark Mode Hintergrund; tiefes Dunkelviolett passend zur Spielwelt-Ästhetik und zum Match-3-Spielfeld |
| surface_light | `#FFFFFF` | Card-Oberflächen, Modal-Hintergründe, Shop-Angebotskarten und Quest-Cards im Light Mode |
| surface_dark | `#1E1540` | Card-Oberflächen, Modal-Hintergründe und HUD-Elemente im Dark Mode |
| gameplay_bg | `#0E0A24` | Dedizierter Spielfeld-Hintergrund (S003, S006); dunkel genug damit Spielsteine maximalen visuellen Kontrast erhalten |
| success | `#27ae60` | Erfolg, Level-Complete-Bestätigung, Quest-Abschluss-Checkmark |
| warning | `#f39c12` | Warnung bei wenigen verbleibenden Zügen (Move-Counter unter 5), ablaufende Saison-Timer |
| error | `#e74c3c` | Fehler, Level-Failed-State, Verbindungsprobleme, fehlgeschlagene IAP |
| text_primary | `#1A1333` | Haupttext im Light Mode; Headlines, Body-Copy, Level-Bezeichnungen |
| text_primary_dark | `#EDE8FF` | Haupttext im Dark Mode; Headlines und Body-Copy auf dunklen Surfaces |
| text_secondary | `#6B5FA6` | Sekundärtext, Metadaten, Timestamps, inaktive Tab-Labels, Hilfetexte im Light Mode |
| text_secondary_dark | `#9B8FCC` | Sekundärtext und Metadaten im Dark Mode |

### Typografie

| Font | Verwendung | Gewicht | Lizenz |
|---|---|---|---|
| Nunito | Headings, Level-Bezeichnungen, Battle-Pass-Tier-Labels, CTA-Button-Beschriftungen, Score-HUD-Hauptzahl | 700-800 | SIL Open Font License (Google Fonts); kostenlos, kommerziell nutzbar |
| Inter | Body Text, Quest-Beschreibungen, Shop-Kartentext, Onboarding-Erklärungen, Settings, Notification-Texte | 400-500 | SIL Open Font License (Google Fonts); kostenlos, kommerziell nutzbar |
| JetBrains Mono | Numerische Daten mit festem Zeichenabstand: Score-Counter, Countdown-Timer, Move-Counter, Münz-Zähler; verhindert Layout-Shift bei sich ändernden Ziffern | 500-600 | SIL Open Font License (JetBrains / Google Fonts); kostenlos, kommerziell nutzbar |

### Illustrations-Stil
*   **Stil:** Stylized 2.5D Casual Cartoon mit Depth-Layering
*   **Beschreibung:** Weiche, abgerundete Formen mit leichtem 3D-Extrude-Effekt auf Spielsteinen und wichtigen UI-Elementen; gesättigte, leuchtende Farben mit subtilen Gradienten; schwarze Outlines mit variabler Strichstärke (2-4px) für Tiefe; Charaktere und Mascottes haben große, ausdrucksstarke Augen und einfache Silhouetten; Hintergrundelemente sind weicher und weniger gesättigt als Vordergrund-Assets um Spielsteine visuell zu priorisieren; Lichteffekte und Highlights als weiße Glanzpunkte auf Spielsteinen zur Volumenvermittlung
*   **Begründung:** 2.5D Casual Cartoon ist der visuelle Standard der kommerziell erfolgreichsten Match-3-Games (Royal Match, Candy Crush, Gardenscapes); die Zielgruppe 18-34 erwartet polished visuals ohne harten Realismus; das Stil ermöglicht starke Lesbarkeit der Spielsteine bei gleichzeitig emotionaler Attraktivität; Dark-Mode-Kompatibilität wird durch leuchtende Eigenfarben statt helle Hintergründe gewährleistet

### Icon-Stil
*   **Stil:** Filled mit weichen Kanten, passend zum Illustration-Stil; keine scharfen rechten Winkel
*   **Library:** Custom Icon Set basierend auf Phosphor Icons (MIT-Lizenz) als Basis, angepasst an EchoMatch-Ästhetik mit 3px corner-radius auf eckigen Elementen
*   **Grid:** 24x24dp Basisgitter; 48x48dp für Gameplay-Booster-Icons; 96x96dp für Reward-Item-Icons; 20x20dp für Notification-Icon (monochrom, Android-konform)

### Animations-Stil
*   **Default Duration:** 280ms
*   **Easing:** cubic-bezier(0.34, 1.56, 0.64, 1) (leichter Overshoot-Bounce)
*   **Max Lottie:** 500 KB pro Animation
*   **Static Fallback:** **VERBINDLICH** für alle Animationen (siehe Reduced Motion in Abschnitt 15)

---

## 4. Feature-Map

**Hinweis:** Die folgende Feature-Map wurde basierend auf den Design-Vorgaben, der Screen-Architektur und den Asset-Listen für EchoMatch abgeleitet, da keine explizite Feature-Liste in den Rohdaten für diese App vorlag. Die Schätzungen für "Wochen" und "KPI-Impact" sind branchenüblich und dienen als Orientierung.

### Phase A — Soft-Launch MVP (30 Features)
**Budget:** 252.500 EUR (Entwicklung + Asset-Produktion für Phase A)

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten |
|---|---|---|---|---|---|
| F001 | Match-3 Core Loop | Kern-Gameplay-Mechanik: Steine tauschen, Matches bilden, Combos auslösen. | D1, D7, Session-Dauer | 4 | - |
| F002 | AI-driven Level Generation (Basic) | Generierung von Levels basierend auf einfachen Regeln und Spieler-Persona (D3). | D1, D7, Churn | 3 | F001, F003 |
| F003 | Silent Persona Engine (D3) | Unsichtbares Tracking von Spielstil (Zuggeschwindigkeit, Pausen, Combo-Suche) zur Persona-Erkennung. | D1, D7, ARPU | 2 | F001 |
| F004 | Persona-based Narrative Hook (D3) | Anpassung der Narrative Hook Sequenz (S004) an die erkannte Spieler-Persona. | D7, D30 | 2 | F003, F010 |
| F005 | Dark-Field Luminescence (D1) | Implementierung des dunklen Spielfelds mit selbstleuchtenden Steinen (Bloom, Emission Maps). | D1, D7, Conversion | 3 | F001 |
| F006 | Kontextuelle Navigation (D2) | Dynamische UI-Elemente statt fester Bottom-Bar, reagiert auf Tageszeit/State. | D1, D7, Session-Dauer | 3 | F007, F008 |
| F007 | Onboarding-Match (S003) | Interaktives Onboarding ohne Text-Tutorial, mit lebendigem ersten Stein (W2). | D1, D7 | 2 | F001, F005 |
| F008 | Level-Map (S008) | Visuelle Darstellung des Fortschritts mit Level-Knoten und Pfad. | D7, D30 | 2 | F002 |
| F009 | Level-Ergebnis-Screen (S007) | Post-Session-Screen mit Goldener Ausatmung (W3) und Spielhistorie. | D1, D7, Social Share | 2 | F001, F005 |
| F010 | Narrative Hook Sequenz (S004) | Atmosphärische Story-Sequenz mit Parallax-Tiefe. | D7, D30 | 2 | F004 |
| F011 | Home Hub (S005) | Zentraler Einstiegspunkt mit Daily Quest, Battle Pass Teaser. | D1, D7 | 2 | F006, F012 |
| F012 | Daily Quests (S013) | Tägliche Aufgaben mit Belohnungen. | D7, D30 | 2 | F001, F008 |
| F013 | Basic Score Tracking | Zählen von Punkten und Combos im Level. | D1, D7 | 1 | F001 |
| F014 | Move Counter | Anzeige der verbleibenden Züge. | D1, D7 | 1 | F001 |
| F015 | Special Stone Mechanics | Implementierung von Bomben, Blitz-Steinen etc. | D1, D7 | 2 | F001 |
| F016 | Obstacles (Basic) | Einfache Hindernisse wie Eis oder Stein. | D1, D7 | 1 | F001 |
| F017 | Haptic Language System (Basic) | Dreischichtige Haptik für Drag, Snap, Combo. | D1, D7 | 1 | F001 |
| F018 | Adaptive Sound Layer (Basic) | Sound-Design passt sich Zug-Tempo an. | D1, D7 | 1 | F001 |
| F019 | DSGVO/ATT Consent (S002) | Implementierung des Consent-Dialogs mit Pre-Primer (UXI-04). | Legal | 2 | - |
| F020 | Age Gate / COPPA (S002) | Altersprüfung und Block für Minderjährige. | Legal | 1 | F019 |
| F021 | Privacy Policy / Impressum | Rechtlich korrekte Dokumente und Links. | Legal | 1 | - |
| F022 | Basic Analytics (Firebase) | Tracking von D1/D7/D30 Retention, Session-Dauer. | Business KPIs | 1 | F019 |
| F023 | Crash Reporting (Firebase Crashlytics) | Erfassung von App-Abstürzen. | Tech KPIs | 1 | - |
| F024 | Remote Config (Firebase) | Dynamische Anpassung von Gameplay-Parametern. | Business KPIs | 1 | - |
| F025 | Unity URP Setup | Konfiguration der Universal Render Pipeline für Grafik-Features. | Tech KPIs | 1 | - |
| F026 | Asset Loading System (Addressables) | Effizientes Laden von Assets (z.B. Story-Varianten). | Tech KPIs | 1 | - |
| F027 | Basic IAP Shop (S011) | Shop-UI mit Platzhaltern für IAP-Produkte. | ARPU | 2 | F006 |
| F028 | Battle Pass UI (S012) | Visuelle Darstellung des Battle Pass mit Tier-Leiste. | D7, D30, ARPU | 2 | F006 |
| F029 | Rewarded Ad Integration (S016) | Integration eines Ad-SDK für Rewarded Ads. | ARPU | 2 | F009 |
| F030 | Social Share (S015) | Teilen von Level-Ergebnissen als Share-Card (D4). | Social Share | 1 | F009 |

### Phase B — Full Production (18 Features)
**Budget:** 230.000 EUR (Entwicklung + Asset-Produktion für Phase B)

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten |
|---|---|---|---|---|---|
| F031 | AI-driven Level Generation (Advanced) | Komplexere KI-Level-Generierung, adaptiert an Langzeit-Spielstil. | D30, Churn | 4 | F002, F003 |
| F032 | Chrono-Responsive UI (UXI-01) | UI passt sich Tageszeit an (Farbtemperatur, Akzente). | D1, D7 | 2 | F006 |
| F033 | Adaptive Sound Layer (Advanced) | Sound-Design passt sich über Zeit dem Spielstil an. | D7, D30 | 2 | F003, F018 |
| F034 | Narrative Memory System (UXI-05) | Spiel erinnert sich an spezifische Momente und referenziert sie später. | D30, LTV | 3 | F002, F010 |
| F035 | Progressive Interface Reduction (UXI-06) | UI vereinfacht sich mit zunehmender Spieler-Expertise. | D7, D30 | 2 | F003, F006 |
| F036 | Full IAP Shop Integration | Vollständige Integration von In-App Purchases (Stripe/StoreKit/Google Play Billing). | ARPU, Conversion | 3 | F027 |
| F037 | Battle Pass Progression System | Logik für XP-Vergabe, Tier-Freischaltung, Reward-Claiming. | D7, D30, ARPU | 2 | F028 |
| F038 | Friend Challenges (S010) | Spieler können Freunde zu Levels herausfordern. | D7, D30, Social Share | 3 | F008, F039 |
| F039 | Ambient Social Layer (D4) | Freunde-Avatare als Lichtpunkte auf der Level-Map. | D7, D30, Social Share | 2 | F008 |
| F040 | Leaderboards (S010) | Globale und Freundes-Ranglisten. | D7, D30 | 2 | F013, F039 |
| F041 | Story Hub (S009) | Detaillierte Story-Übersicht, Kapitel-Fortschritt. | D7, D30 | 2 | F010 |
| F042 | Story-NPC Interface-Brecher (D5) | NPCs erscheinen außerhalb der Story-Screens und kommentieren. | Social Share, D7 | 2 | F004, F011 |
| F043 | Advanced Obstacles & Mechanics | Komplexere Hindernisse und Gameplay-Mechaniken. | D7, D30 | 2 | F016 |
| F044 | Live-Ops Event System | System für zeitlich begrenzte Events und Aktionen. | D7, D30, ARPU | 3 | F024 |
| F045 | Push Notifications (Contextual) | Kontextbezogene Push-Nachrichten (z.B. "Freund hat Challenge angenommen"). | D7, D30 | 2 | F038 |
| F046 | Account Management (Firebase Auth) | Nutzerkonten, Login, Profilverwaltung. | D7, D30 | 2 | F036 |
| F047 | Cloud Save / Sync | Speichern des Spielfortschritts in der Cloud. | D7, D30 | 2 | F046 |
| F048 | A/B Testing Infrastructure | Infrastruktur für A/B-Tests von Features und Monetarisierung. | Business KPIs | 2 | F024 |

### Backlog — Post-Launch (5 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |
|---|---|---|---|---|
| F049 | Guilds / Teams | v1.2 | Erschließt Community-Segment, erhöht LTV. | Komplexes Social-Feature, benötigt stabile Basis. |
| F050 | Cross-Platform Play | v1.3 | Erweitert Spielerbasis, erhöht Social-Impact. | Technisch aufwendig, nach Validierung der Kern-Features. |
| F051 | User-Generated Content (Level Editor) | v1.4 | Erhöht Content-Vielfalt, Community-Engagement. | Hoher Entwicklungsaufwand, nachweisliche Nachfrage nötig. |
| F052 | Advanced AI Personalization | v1.5 | Tiefere KI-Anpassung des Spielerlebnisses. | Benötigt große Datenbasis und weitere ML-Entwicklung. |
| F053 | Spectator Mode / Replays | v1.2 | Erhöht Social-Engagement, Content-Creation. | Nice-to-have, nach Kern-Social-Features. |

---

## 5. Abhaengigkeits-Graph & Kritischer Pfad

**Hinweis:** Dies ist eine abgeleitete Darstellung basierend auf der Feature-Map und den Design-Vorgaben.

### Build-Reihenfolge (Phase A - Soft-Launch MVP)

1.  **Core Foundation (Woche 1-2):**
    *   F001 (Match-3 Core Loop)
    *   F005 (Dark-Field Luminescence)
    *   F025 (Unity URP Setup)
    *   F013 (Basic Score Tracking)
    *   F014 (Move Counter)
    *   F017 (Haptic Language System - Basic)
    *   F018 (Adaptive Sound Layer - Basic)
    *   F021 (Privacy Policy / Impressum)
    *   F023 (Crash Reporting)
    *   F026 (Asset Loading System)

2.  **Onboarding & Persona (Woche 3-4):**
    *   F007 (Onboarding-Match) - **Abhängig von F001, F005, F017, F018**
    *   F003 (Silent Persona Engine) - **Abhängig von F001, F007**
    *   F004 (Persona-based Narrative Hook) - **Abhängig von F003, F010**
    *   F010 (Narrative Hook Sequenz) - **Abhängig von F026**
    *   F019 (DSGVO/ATT Consent) - **Abhängig von F021**
    *   F020 (Age Gate / COPPA) - **Abhängig von F019**
    *   F022 (Basic Analytics) - **Abhängig von F019**

3.  **Core Gameplay Expansion (Woche 5-6):**
    *   F002 (AI-driven Level Generation - Basic) - **Abhängig von F001, F003**
    *   F015 (Special Stone Mechanics) - **Abhängig von F001**
    *   F016 (Obstacles - Basic) - **Abhängig von F001**
    *   F008 (Level-Map) - **Abhängig von F002**

4.  **Hubs & Monetarisierung (Woche 7-8):**
    *   F011 (Home Hub) - **Abhängig von F006**
    *   F006 (Kontextuelle Navigation) - **Abhängig von F007, F008**
    *   F012 (Daily Quests) - **Abhängig von F001, F008**
    *   F027 (Basic IAP Shop) - **Abhängig von F006**
    *   F028 (Battle Pass UI) - **Abhängig von F006**
    *   F029 (Rewarded Ad Integration) - **Abhängig von F009**
    *   F030 (Social Share) - **Abhängig von F009**
    *   F009 (Level-Ergebnis-Screen) - **Abhängig von F001, F005**
    *   F024 (Remote Config)

### Kritischer Pfad (Phase A)

*   **Gesamtdauer:** ca. 8 Wochen
*   **Beschreibung:** Der kritische Pfad wird durch die Kern-Gameplay-Implementierung (F001, F005), das Onboarding (F007) und die Persona-Engine (F003) bestimmt, da diese die Basis für alle weiteren personalisierten und monetarisierten Features bilden. Legal-Compliance (F019, F020, F021) läuft parallel, ist aber ein harter Blocker für den Soft Launch.

### Parallelisierbare Feature-Gruppen (Phase A)

*   **Gruppe 1: Core Gameplay Foundation:** F001, F005, F013, F014, F015, F016, F017, F018, F025, F026 (können weitgehend parallel entwickelt werden, sobald URP steht)
*   **Gruppe 2: Legal & Compliance:** F019, F020, F021 (können parallel zur Gameplay-Entwicklung laufen, müssen aber vor Soft Launch abgeschlossen sein)
*   **Gruppe 3: Analytics & Tools:** F022, F023, F024 (können parallel integriert werden)
*   **Gruppe 4: UI Shells:** F027, F028 (UI-Platzhalter für Shop/Battle Pass können früh erstellt werden, Logik folgt später)

---

## 6. Screen-Architektur (**VERBINDLICH**)

### Screen-Übersicht (22 Screens)

| ID | Screen | Typ | Zweck | Features (Phase A) | States (Phase A) |
|---|---|---|---|---|---|
| S001 | Splash / Loading | Overlay | App-Start, Engine laden, Logo-Genesis (W1) | F025, F026 | Normal, Slow-Connection, Engine-Fehler |
| S002 | Consent-Dialog (DSGVO / ATT) | Modal | DSGVO-konformer Consent, ATT-Pre-Primer (UXI-04), Age-Gate (F020) | F019, F020 | Normal, Einstellungen-Expanded, Minderjährig-Block |
| S003 | Onboarding-Match | Hauptscreen | Erstes Match, Spielstil-Tracking (D3), lebendiger erster Stein (W2) | F001, F003, F005, F007, F017, F018 | Normal, Inaktivität-Hint, Falscher-Zug |
| S004 | Narrative Hook Sequenz | Subscreen | Emotionaler Story-Einstieg, Persona-Anpassung (D3) | F004, F010 | Normal, Skip-Button-sichtbar, Pause-State |
| S005 | Home Hub | Hauptscreen | Täglicher Einstieg, Daily Quest, Battle Pass Teaser | F006, F011, F012, F028 | Normal, Daily-Quest-aktiv, NPC-Kommentar (W4) |
| S006 | Puzzle / Match-3 Spielfeld | Hauptscreen | Kern-Gameplay, AI-Level, Special Stones, Obstacles | F001, F002, F005, F013, F014, F015, F016, F017, F018 | Normal, Combo-aktiv, Special-aktiv, Wenige-Züge-Warnung, Falscher-Zug |
| S007 | Level-Ergebnis / Post-Session | Subscreen | Level-Abschluss, Goldene Ausatmung (W3), Spielhistorie | F009, F030 | Gewonnen, Verloren (mit Rewarded Ad Angebot) |
| S008 | Level-Map / Progression | Hauptscreen | Visueller Fortschritt, Level-Knoten, Ambient Social (D4) | F006, F008 | Normal, Level-Gesperrt, Level-Offen, Level-Abgeschlossen, Freund-Lichtpunkt (W5) |
| S009 | Story / Narrative Hub | Hauptscreen | Kapitel-Übersicht, Story-Fortschritt | F006, F010 | Normal, Kapitel-Gesperrt, Kapitel-Offen, Kapitel-Abgeschlossen |
| S010 | Social Hub | Hauptscreen | Freundesliste, Challenges, Leaderboard-Platzhalter | F006, F038 (Platzhalter) | Normal, Keine-Freunde-Empty-State, Challenge-aktiv |
| S011 | Shop / Monetarisierungs-Hub | Hauptscreen | IAP-Angebote, Battle Pass Kauf | F006, F027, F028 | Normal, Foot-in-Door-Angebot, Offline-Gesperrt |
| S012 | Battle-Pass Screen | Subscreen | Tier-Übersicht, Belohnungen, Saison-Timer | F006, F028 | Normal, Premium-aktiv, Saison-abgelaufen |
| S013 | Tägliche Quests Screen | Subscreen | Aktive Quests, Fortschritt, Belohnungen | F006, F012 | Normal, Quest-Abgeschlossen, Quest-Claimed |
| S014 | Push Opt-In | Modal | Erklärung und Opt-In für Push-Notifications | F045 (Platzhalter) | Normal, Opt-In-erfolgreich, Opt-In-abgelehnt |
| S015 | Social Share Sheet | Modal | Teilen von Level-Ergebnissen (D4) | F030 | Normal, Link-kopiert, Geteilt-Erfolg |
| S016 | Rewarded Ad Interstitial | Overlay | Vollbild-Werbung, Lade- und Fehler-States | F029 | Ad-Lädt, Ad-Läuft, Ad-Abgeschlossen, Ad-Fehler |
| S017 | Profil | Hauptscreen | Spieler-Avatar, Statistiken, Account-Einstellungen | F046 (Platzhalter) | Normal, Gast-Modus, Angemeldet |
| S018 | Einstellungen | Subscreen | Sound, Haptik, Datenschutz, Legal-Links | F017, F018, F019, F021 | Normal, Reduced-Motion-aktiv, Consent-aktualisiert |
| S019 | Beta Feedback | Modal | Qualitatives Feedback-Formular | F023 | Normal, Senden, Erfolg, Fehler |
| S020 | Kaltstart Personalisierungs-Fallback | Overlay | Spielstil-Auswahl bei ATT-Ablehnung (D3) | F003 | Normal, Auswahl-getroffen |
| S021 | Offline Error | Subscreen | Fehlerbildschirm bei fehlender Internetverbindung | - | Normal, Retry-Option |
| S022 | A/B Test Variant Loader | Overlay | Transparenter Loader für A/B-Test-Zuweisung | F024 | Normal |

### Hierarchie
*   **Hauptscreens (Hubs):** S003, S005, S006, S008, S009, S010, S011, S017
*   **Subscreens:** S004, S007, S012, S013, S018, S021
*   **Modals:** S002, S014, S015, S019
*   **Overlays:** S001, S016, S020, S022

### Navigation
**VERBINDLICH:** Keine persistente Bottom-Navigation-Bar mit 5 Icons. Navigation erfolgt über:
*   **Kontextuelle Action-Surfaces:** Situative Buttons/Karten, die je nach Screen-State und Tageszeit erscheinen (z.B. Daily Quest auf S005).
*   **Swipe-Gesten:** Z.B. Swipe-Up vom Home Hub für ein Radial-Menü (Phase B).
*   **Long-Press-Previews:** Für schnelle Vorschauen ohne Screen-Wechsel.
*   **Ambient Social Layer:** Freunde-Avatare als Lichtpunkte auf der Level-Map (S008) für soziale Interaktion.

### User Flows (7 Flows)

#### Flow 1: Onboarding (Erst-Start) — App öffnen bis erster Core Loop
*   **Screens:** S001 → S002 → S003 → S004 → S005 → S006 → S007
*   **Taps bis Core Loop:** 3 (Consent bestätigen auf S002 → Onboarding-Match starten auf S003 → Level starten auf S005)
*   **Zeitbudget:** ~60 Sekunden bis erstes Ergebnis sichtbar (S007)
*   **Beschreibung:** App initialisiert Client-Side Engine (S001) → DSGVO/ATT Consent (S002) → Onboarding-Match (S003) mit Spielstil-Tracking (D3) → Persona-basierte Narrative Hook (S004) → Home Hub (S005) → Erstes KI-generiertes Level (S006) → Level-Ergebnis (S007).
*   **Fallback Kein Invite Code (Phase A):** S002 leitet zu S020 (Kaltstart Personalisierungs-Fallback) wenn ATT abgelehnt oder kein Invite Code.
*   **Fallback Consent-Ablehnung:** S002 setzt nur notwendige Cookies, App funktioniert vollständig weiter (alles client-side, kein Analytics-Block).
*   **Fallback Engine-Fehler auf S001:** Fehler-State zeigt Retry-Button, nach 3 Fehlversuchen Weiterleitung zu S021.

#### Flow 2: Core Loop (wiederkehrend) — Direkteinstieg bis Level-Ergebnis
*   **Screens:** S001 → S005 → S006 → S007
*   **Taps bis Ergebnis:** 2 (Daily Quest starten auf S005 → Level starten auf S006)
*   **Session-Ziel:** 45–90 Sekunden für vollständigen Level-Zyklus, Gesamtsession 6–10 Minuten inkl. S007-Review.
*   **Beschreibung:** Wiederkehrender Nutzer öffnet App, Splash kurz (S001) → Home Hub (S005) mit kontextueller Navigation (D2) → Daily Quest Level starten (S006) → Level-Ergebnis (S007) mit Goldener Ausatmung (W3).
*   **Fallback Analyse-Timeout >50 Sek. (KI-Level):** S006 zeigt Timeout-Warnung mit Abbrechen-Option und Retry.
*   **Fallback Analyse-Fehler:** Fehler-Abbruch-State auf S006, Weiterleitung zurück zu S005 mit Fehlermeldung.
*   **Fallback Offline:** S006 sperrt Level-Start-Button, zeigt Offline-Hinweis.

#### Flow 3: Erster Kauf — Battle Pass Upgrade
*   **Screens:** S005 → S011 → S012 → (Nativer Payment-Dialog) → S012 (Premium-State) → S005
*   **Taps bis Kauf:** 3 (Battle Pass Teaser auf S005 → Battle Pass Karte auf S011 → „Jetzt kaufen" auf S012)
*   **Zeitbudget:** 60–120 Sekunden.
*   **Beschreibung:** Nutzer sieht Battle Pass Teaser auf Home Hub (S005) → Shop (S011) mit Battle Pass Kaufkarte → Battle Pass Screen (S012) mit Tier-Übersicht und Upgrade-Button → Nativer Payment-Dialog → S012 aktualisiert auf Premium-State → Zurück zum Home Hub (S005).
*   **Fallback Payment-Fehler:** S011 zeigt IAP-Fehler-Dialog.
*   **Fallback Offline:** S011 sperrt Kauf-Buttons, zeigt Offline-Hinweis.

#### Flow 4: Social Challenge — Ergebnis teilen
*   **Screens:** S007 → S015
*   **Taps bis Teilen:** 2 (Share-Button auf S007 → Teilen-Aktion in S015)
*   **Zeitbudget:** 15–20 Sekunden.
*   **Beschreibung:** Nutzer sieht Level-Ergebnis (S007) mit Share-Button → Social Share Sheet (S015) öffnet sich mit vorgefertigtem Poster-Bild (D4) → Nutzer wählt Plattform und teilt → Erfolgs-Feedback.
*   **Fallback Link-kopieren fehlgeschlagen:** S015 zeigt Link als selektierbaren Text.
*   **Fallback Keine Skills erkannt (wenn Share-Content dynamisch):** Share-Button auf S007 ist deaktiviert.
*   **Fallback Offline:** S015 zeigt nur Link-kopieren-Option, native Share-API wird nicht aufgerufen.

#### Flow 5: Story / Narrative — Kapitel entdecken
*   **Screens:** S005 → S009 → S004 (Replay)
*   **Taps bis Story-Start:** 2 (Story Hub Teaser auf S005 → Kapitel auswählen auf S009)
*   **Zeitbudget:** 30–120 Sekunden pro Kapitel.
*   **Beschreibung:** Nutzer sieht Story Hub Teaser auf Home Hub (S005) → Story Hub (S009) mit vertikaler Kapitel-Liste → Kapitel auswählen → Narrative Hook Sequenz (S004) wird abgespielt (Replay-Modus).
*   **Fallback Kapitel gesperrt:** S009 zeigt gesperrtes Kapitel desaturiert, kein Tap-Feedback.
*   **Fallback Offline:** S009 lädt Kapitel-Übersicht aus Cache, Story-Sequenzen können nicht gestreamt werden (falls dynamisch).

#### Flow 6: Rewarded Ad — Extra-Leben erhalten
*   **Screens:** S006 (Level-Verloren) → S007 (Verloren-Rewarded-Ad-Angebot) → S016 (Ad-Overlay) → S006 (Extra-Leben)
*   **Taps bis Extra-Leben:** 2 (Level verloren auf S006 → Rewarded-Ad-CTA auf S007 → Ad schauen auf S016)
*   **Zeitbudget:** 30–60 Sekunden (Ad-Dauer).
*   **Beschreibung:** Nutzer verliert Level (S006) → Level-Ergebnis (S007) zeigt Rewarded-Ad-Angebot für Extra-Leben → Rewarded Ad Interstitial (S016) wird geladen und abgespielt → Nach Ad-Abschluss: Extra-Leben wird gewährt, Nutzer kehrt zu S006 zurück.
*   **Fallback Ad-Fehler:** S016 zeigt Ad-Fehler-Fallback-Illustration, Retry-Option.
*   **Fallback Ad übersprungen:** S016 zeigt „Kein Reward erhalten"-Feedback, kehrt zu S007 zurück.

#### Flow 7: Einstellungen — Haptik anpassen
*   **Screens:** S005 → S017 → S018
*   **Taps bis Einstellung:** 2 (Profil-Icon auf S005 → Einstellungen auf S017)
*   **Zeitbudget:** 15–30 Sekunden.
*   **Beschreibung:** Nutzer tippt auf Profil-Icon auf Home Hub (S005) → Profil-Screen (S017) → Einstellungen (S018) → Haptik-Toggle anpassen → Einstellung wird lokal gespeichert.
*   **Fallback Offline:** S018 erlaubt lokale Änderungen, Cloud-Sync (Phase B) wird bei Verbindung wiederhergestellt.

### Edge Cases (8 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| Offline bei App-Start | S001, S005, S006, S021 | S001 Engine-Init lädt aus lokalem Cache. S005 zeigt Offline-State-Banner. S006 Gameplay funktioniert vollständig (client-side). Monetarisierungs-Features (S011, S012) sind gesperrt, zeigen S021 (Offline Error) mit Reconnect-CTA. |
| KI-Level Generierungs-Fehler oder Timeout | S006, S007 | S006 zeigt Fehler-Abbruch-State mit erklärendem Text und zwei Optionen: Erneut versuchen (primär) und Home Hub (sekundär). Kein leerer Ergebnis-Screen S007. Timeout-Warnung erscheint proaktiv bei >50 Sekunden Generierungszeit. |
| ATT-Consent abgelehnt (iOS) | S002, S020 | S002 zeigt Pre-Primer (UXI-04). Wenn ATT im System-Dialog abgelehnt wird, leitet S002 zu S020 (Kaltstart Personalisierungs-Fallback) um Spielstil manuell zu erfragen. Kein Tracking, aber Personalisierung bleibt erhalten. |
| IAP-Kauf fehlgeschlagen | S011 | S011 zeigt IAP-Fehler-Dialog mit spezifischer Fehlermeldung (z.B. „Zahlung abgelehnt", „Netzwerkfehler"). Retry-Option und Support-Link. Kein App-Absturz. |
| Level-Datei korrupt (KI-Generierung) | S006 | S006 zeigt Fehler-Abbruch-State mit „Level konnte nicht geladen werden". Retry-Option generiert neues Level. |
| Battle Pass Saison abgelaufen | S012 | S012 zeigt „Saison abgelaufen"-Illustration (Platzhalter P08) mit Teaser für nächste Saison. Kauf-Buttons sind deaktiviert. |
| Freundes-Challenge abgelehnt | S010 | S010 zeigt auf dem Avatar des Freundes einen dezenten „Challenge abgelehnt"-Hinweis (z.B. rotes X über Lichtpunkt) für 2 Sekunden, dann verschwindet er. Kein Push-Notification. |
| Reduced Motion aktiviert (OS-Einstellung) | Alle | Alle Animationen (Lottie, Custom) werden auf 0ms Dauer oder statischen Endzustand gesetzt. Keine Bounce-Easings, keine Parallax-Effekte. (Siehe Abschnitt 15) |

### Phase-B Screens mit Platzhaltern (8 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S010 | Social Hub (Full) | Freundesliste, Challenges, Leaderboards | Platzhalter für Leaderboard, Coming-Soon-Badge für Challenges |
| S017 | Profil (Full) | Spieler-Avatar, Statistiken, Account-Einstellungen | Gast-Modus mit Upgrade-CTA zu F046 |
| S023 | Team Hub | Gilden/Team-Verwaltung | Nicht sichtbar (Backlog) |
| S024 | Live-Ops Event Hub | Zeitlich begrenzte Events | Coming-Soon-Badge auf Home Hub (S005) |
| S025 | Story-Kapitel-Detail | Detaillierte Story-Texte, Charakter-Interaktionen | Text-Platzhalter auf S009 |
| S026 | Shop-Detail-Item | Detaillierte Beschreibung von IAP-Items | Kurze Beschreibung auf S011-Karten |
| S027 | Settings (Advanced) | Erweiterte Einstellungen (z.B. Cloud Save) | Nicht sichtbar |
| S028 | Replay Viewer | Anschauen von Level-Replays | Nicht sichtbar (Backlog) |

---

## 7. Asset-Liste (**VERBINDLICH**)

### Vollständige Asset-Tabelle (Auszug, da 107 Assets zu lang für dieses Dokument)
**Hinweis:** Die vollständige Asset-Tabelle umfasst 107 Assets. Hier ist ein repräsentativer Auszug der wichtigsten Assets, um die Struktur und den Detaillierungsgrad zu demonstrieren.

| ID | Asset | Beschreibung | Screen(s) | Stat/Dyn | Quelle | Format | Priorität | Launch-krit. |
|---|---|---|---|---|---|---|---|---|
| **APP-BRANDING** | | | | | | | | |
| A001 | App-Icon | Haupt-App-Icon für App Store und Google Play. | S001, Alle | statisch | Custom Design | PNG 1024×1024 | 🔴 | JA |
| A002 | Splash-Screen-Logo | EchoMatch-Volllogo für Splash-Screen S001. | S001 | statisch | Custom Design | SVG + PNG | 🔴 | JA |
| A062 | Store-Feature-Grafik | Feature-Grafik für Google Play Store. | Alle | statisch | Custom Design | PNG 1024×500 | 🔴 | JA |
| **GAMEPLAY-ASSETS** | | | | | | | | |
| A009 | Match-3-Spielstein-Sprite-Set | Sprite-Set aller Match-3-Spielsteine (6 Typen). | S003, S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 | JA |
| A010 | Match-3-Spielfeld-Hintergrund | Vollbild-Hintergrund für Spielfeld (4 thematische Varianten). | S003, S006 | statisch | AI-generiert | PNG 1920×1080 | 🔴 | JA |
| A011 | Match-3-Spezialstein-Sprites | Sprites für Sonder- und Booster-Steine (Bombe, Blitz). | S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 | JA |
| A066 | Hindernisse und Spezialzellen-Sprites | Sprite-Set für Level-Hindernisse (Eis, Stein, Kette). | S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 | JA |
| **UI-ELEMENTE** | | | | | | | | |
| A004 | Ladebalken / Loading-Indicator | Animierter Spinner für Ladevorgänge. | S001, S006, S011, S012 | animiert | LottieFiles Free | Lottie JSON | 🔴 | JA |
| A014 | Züge-Anzeige / Move-Counter | Visuelles UI-Element für verbleibende Züge. | S006 | animiert | Custom Design | SVG + PNG | 🔴 | JA |
| A016 | Booster-Icons im Spielfeld | Icon-Set für alle verfügbaren Booster. | S006 | animiert | AI-generiert + Custom | PNG + Lottie | 🔴 | JA |
| A022 | Level-Knoten-Icons | Icon-Sprites für Level-Knoten auf der Map. | S008 | animiert | Custom Design | SVG + PNG | 🔴 | JA |
| A046 | Tab-Bar-Icons | Icon-Set für alle 5 Tab-Bar-Einträge (Home, Puzzle, Story, Social, Shop). | S005, S008, S009, S010, S011 | statisch | Free/Open-Source | SVG + PNG | 🔴 | JA |
| **ILLUSTRATIONEN** | | | | | | | | |
| A003 | Splash-Screen-Hintergrund | Atmosphärisches Artwork für S001. | S001 | statisch | AI-generiert + Custom | PNG 2732×2732 | 🔴 | JA |
| A007 | ATT-Prompt-Visual | Pre-Permission-Erklärungsbild für iOS ATT-Prompt. | S002 | statisch | AI-generiert + Custom | SVG + PNG | 🔴 | JA |
| A018 | Level-Verloren-Illustration | Empathische Illustration für S007 Verloren-State. | S007 | statisch | AI-generiert + Custom | PNG | 🔴 | JA |
| **ANIMATIONEN & EFFEKTE** | | | | | | | | |
| A012 | Match-Animation-Effekte | Partikel- und Burst-Animationen für Match-3. | S003, S006 | animiert | Custom Design | Lottie JSON | 🔴 | JA |
| A017 | Level-Gewonnen-Animation | Vollbild-Gewinn-Animation für S007 Gewonnen-State. | S007 | animiert | Custom Design | Lottie JSON | 🔴 | JA |
| A050 | KI-Level-Lade-Platzhalter-Animation | Thematische Animations-Szene für S006 KI-Level-Latenz. | S006, S008 | animiert | Custom Design | Lottie JSON | 🔴 | JA |
| **STORY / NARRATIVE ASSETS** | | | | | | | | |
| A024 | Narrative-Hook-Sequenz-Artwork | Vollbild-Story-Artwork für S004 Narrative Hook. | S004 | animiert | AI-generiert + Custom | PNG | 🔴 | JA |
| A025 | Story-Charakter-Portraits | Portrait-Illustrationen aller Haupt-Story-Charaktere. | S004, S009 | statisch | Custom Design | PNG | 🔴 | JA |
| A026 | Story-Kapitel-Cover-Illustrationen | Cover-Artwork für jedes Story-Kapitel. | S009 | statisch | AI-generiert + Custom | PNG | 🔴 | JA |

### Beschaffungswege pro Asset (Zusammenfassung)

| Quelle | Anzahl Assets | Anteil |
|---|---|---|
| Custom Design (Freelancer) | 28 | 41% |
| AI-generiert + Custom Finish | 18 | 26% |
| Free/Open-Source | 12 | 18% |
| Lottie (Free/Premium) | 10 | 15% |
| **Gesamt** | **68** | **100%** |

### Format-Anforderungen pro Plattform

| Asset-Typ | Format | Auflösung/Größe | Tool | Hinweise |
|---|---|---|---|---|
| unity_sprites | PNG / Sprite Sheet | @2x (3840x2160 Master) | TexturePacker 7.x → Unity Importer | Keine POT-Pflicht ab Unity 2022+, aber 2er-Potenzen empfohlen für Kompression |
| backgrounds | PNG | 1920x1080px @2x (3840x2160 Master) | Photoshop | Hintergrund-Layer separat exportieren (BG-Layer, Mid-Layer, FX-Layer) für Parallax |
| icons | SVG für UI-Icons, PNG @2x/@3x für In-Game | Variabel | Figma Export | SVG für Skalierbarkeit, PNG für Performance in Unity |
| animations | Lottie JSON (UI-Animationen, Loading, Feedback) | Variabel | After Effects 2025 + Bodymovin 5.x Plugin | Statisches PNG @2x wenn Lottie >500KB oder Runtime-Performance-Problem |
| app_icon_ios | PNG | 1024x1024px (Master) | Figma Export + Asset Catalog Xcode | Kein Alpha-Kanal, kein Gradient über gesamte Fläche (Apple Review Richtlinie) |
| app_icon_android | PNG Adaptive Icon | 108x108dp (Master) | Android Studio Asset Studio + Figma Export | Adaptive Icon: Foreground + Background als separate Layer im XML definiert |
| screenshots_store | PNG (kein JPEG) | 1290x2796 (iOS), 1080x1920 (Android) | Figma Store-Screenshot-Template + Photoshop | Keine Kompressionsartefakte, keine Text-Overlays die nicht Teil des UI sind |
| audio | WAV (Master) + OGG/AAC (komprimiert) | Variabel | Audacity / Adobe Audition | Loop-Points in BGM-Tracks testen (kein Click am Loop-Punkt) |
| fonts | TTF / OTF Master → Unity Font Asset (TMP) | Variabel | TextMesh Pro Font Asset Creator | Lizenz-Prüfung für Mobile-Embedding vor Integration (SIL OFL oder Commercial-Lizenz) |

### Plattform-Varianten Anzahl
*   **Gesamt Plattform-Varianten (Assets):** 164 (inkl. @2x/@3x, Light/Dark, States)

### Dark-Mode-Varianten
*   **Dark-Mode-Varianten nötig:** 65 Assets (explizit als "ja" oder "kontrastsicher" markiert)

---

## 8. KI-Produktions-Warnungen (**VERBINDLICH** — **KRITISCH**)

### Warnungen aus dem Visual Audit

| # | Screen | Stelle | Was KI falsch macht | Was stattdessen | **Prompt-Anweisung für Produktionslinie** |
|---|---|---|---|---|---|
| W01 | S001 Splash | Vollbild-Atmosphären-Artwork hinter dem Logo | Farbverlauf in Brand-Primärfarbe oder `#1A1A2E` Vollton | A003 Splash-Screen-Hintergrund | **VERWENDE `Image(asset: "splash_bg")` als Fullscreen-Layer unter dem Logo. AKZEPTIERE KEIN `Color.fill()` oder Gradient-Code als Ersatz.** |
| W02 | S002 ATT Consent | Erklärendes Bild BEVOR der iOS-System-ATT-Dialog erscheint | Text-only Pre-Permission-Screen mit App-Beschreibung oder gar keinen Pre-Screen | A007 ATT-Prompt-Visual | **IMPLEMENTIERE einen Pre-Permission-Screen als eigene View mit `Image(asset: "att_explanation_visual")` als zentralem Element. Der System-Dialog wird erst nach Tap auf diesen Screen getriggert. KEIN direktes `requestTrackingAuthorization()` ohne vorherigen Visual-Screen.** |
| W03 | S002 DSGVO | Visuelle Auflockerung neben Rechtstext | Reinen UITextView/ScrollView mit Rechtstext, kein visuelles Element | A006 DSGVO-Consent-Illustration | **PLATZIERE `Image(asset: "consent_illustration")` als festes Layout-Element in der oberen Hälfte des Consent-Modals. ScrollView mit Rechtstext NUR im unteren Bereich. Die Illustration darf NICHT weggelassen werden.** |
| W04 | S003 Spielsteine | Thematisch gestaltete Spielstein-Sprites mit Spielwelt-Ästhetik | Farbige `RoundedRectangle`-Views oder `Circle`-Shapes mit Hex-Farben als Spielstein-Ersatz | A009 Match-3-Spielstein-Sprite-Set | **LADE `gem_sprites.atlas` und RENDERE Einzelframes per Tile-Index für jeden Spielstein-Typ. AKZEPTIERE KEIN Shape-Rendering als Spielstein.** |
| W05 | S003 Tutorial-Hint | Animierter Finger-Tap-Pfeil der ersten Spielzug zeigt | Statischen Text-Overlay wie „Tippe hier um zu beginnen" oder `Label`-Tooltip | A049 Onboarding-Hint-Pfeile und Tutorial-Overlays | **VERWENDE `LottieAnimationView` oder Frame-animiertes Asset (`hint_arrow_tap.json`). AKZEPTIERE KEIN `UILabel` oder `Text()`-Overlay als Tutorial-Hinweis im Spielfeld. Animation muss auf den ersten tappbaren Stein zeigen.** |
| W06 | S004 Narrative Hook | Vollbild-Story-Artwork oder animierte Sequenz als emotionaler erster Eindruck der Spielwelt | Text-Dialog-Box auf schwarzem oder einfarbigem Hintergrund, eventuell mit generischem Hintergrundbild | A024 Narrative-Hook-Sequenz-Artwork | **IMPLEMENTIERE `Image(asset: "narrative_hook_bg")` als Fullscreen mit Text-Overlay. AKZEPTIERE KEINEN schwarzen Hintergrund mit zentriertem Text als Narrative-Hook.** |
| W07 | S005 Hero-Banner | Tageszeit-abhängig oder Event-abhängig wechselndes Artwork das täglichen Re-Entry-Anreiz visualisiert | Statische Farb-Card oder Text-Banner mit „Willkommen zurück, [Name]" | A028 Home Hub Hero-Banner | **LADE 3 Banner-Varianten (`hero_morning.png`, `hero_evening.png`, `hero_event.png`) und wähle das Asset per lokaler Uhrzeit. AKZEPTIERE KEIN programmatisch generiertes Text-Banner als Hero-Element.** |
| W08 | S006 Spezialsteine | Visuell sofort erkennbare Spezialsteine die sich klar von normalen Steinen unterscheiden (Bombe sieht aus wie Bombe) | Gleiche `RoundedRectangle`-Shapes wie normale Steine, nur mit anderer Farbe oder Outline | A011 Match-3-Spezialstein-Sprites | **RENDERE separate Sprite-Frames für jeden Spezialstein-Typ aus `special_gems.atlas`. AKZEPTIERE KEIN Reuse des normalen Stein-Sprites mit veränderter `tintColor` oder Border.** |
| W09 | S006 Hindernisse | Hinderniszellen die durch ihr Aussehen ihren Typ und Abbau-Zustand kommunizieren (Eis-Crack-States) | Farbige Zellen-Backgrounds (`blue` = Eis, `gray` = Stein) ohne Multi-State-Design | A066 Hindernisse und Spezialzellen-Sprites | **IMPLEMENTIERE ein Sprite-Set mit je 3 Abbau-States pro Hindernis-Typ (`ice_state_1/2/3.png`). State-Wechsel über Sprite-Frame-Swap, NICHT über `opacity`-Änderung oder Farb-Overlay.** |
| W10 | S007 Verloren-State | Empathische Charakter-Illustration die Niederlage emotional abfedert und Retry-Motivation aufbaut | Roter Text „Level verloren" oder System-Alert-Style-Dialog, evtl. mit rotem X-Icon | A018 Level-Verloren-Illustration | **PLATZIERE `level_lost_illustration.png` als Fullscreen-Hintergrund oder zentrales Element des Verloren-Screens. Retry-Button wird ÜBER die Illustration gelegt. AKZEPTIERE KEINEN Alert-Dialog oder System-Modal als Verloren-Screen.** |
| W11 | S011 Foot-in-Door-Angebot | Visuell hervorgehobene Angebots-Card die sich durch Größe, Glanz-Effekt oder animierten Rahmen von anderen Angeboten abhebt | Gleiche Card wie alle anderen Angebote, nur mit anderem Preis oder Text „Bestes Angebot" Label | A035 Foot-in-Door-Angebot-Highlight | **VERWENDE ein dediziertes Highlight-Asset mit animiertem Rahmen/Glow (`offer_highlight_frame.json` als Lottie). AKZEPTIERE KEIN reines Text-Badge wie „BEST VALUE" ohne visuelles Highlight-Design.** |
| W12 | S020 Auswahlkarten | Bildbasierte Auswahlkarten die Spielstil durch Illustration zeigen (entspannter Spieler vs. kompetitiver Spieler) | Radio-Button-Liste oder Segmented-Control mit Text-Labels für Spielstil-Optionen | A048 Kaltstart-Personalisierungs-Auswahlkarten | **IMPLEMENTIERE ein Card-basiertes Selection-UI mit Illustration pro Option (`Image(asset: "playstyle_\(type).png")` + Label). AKZEPTIERE KEIN `Picker`, `SegmentedControl` oder `RadioButton`-Pattern ohne visuelles Karten-Design.** |
| W13 | S010 Challenge-Card | Animierte Card mit Gegner-Avatar, Score-Vergleich und Accept/Decline-CTAs | Einfacher `ListCell` mit Spielername und zwei Text-Buttons | A038 Challenge-Card-Design | **IMPLEMENTIERE die Challenge-Card als dediziertes Custom-View mit `Image(asset: "challenge_card_bg")` als Hintergrund und Avatar-Image-View für Gegner-Profil. AKZEPTIERE KEINE `UITableViewCell`/`List`-Row als Challenge-Darstellung.** |
| W14 | S015 Share-Bild | Dynamisch generiertes Share-Bild mit App-Branding, Score und Level-Nummer als attraktive visuelle Card | Reinen Text-String teilen: „Ich habe Level 12 mit 4500 Punkten abgeschlossen! #EchoMatch" | A040 Share-Result-Bild-Template | **RENDERE das Share-Bild programmatisch aus einem Template (`share_template.png` als Hintergrund) und füge Score/Level-Werte als Text-Overlay hinzu. `UIActivityViewController` bekommt das GERENDERTE `UIImage`, NICHT einen Text-String als primären Share-Content.** |

### Warnungen aus der Design-Vision

| # | Screen | Standard den KI wählt | Was Design-Vision verlangt | **Prompt-Anweisung für Produktionslinie** |
|---|---|---|---|---|
| A1 | S006, S001, S004, alle Spielfeld-Screens | Weißer oder hellgrauer Hintergrund als Basis-Canvas für alle Screens | Dunkler Basis-Canvas (#0D0F1A bis #1A1D2E) als primäre Designsprache — kein Screen darf einen hellen Hintergrund als Default haben. Ausnahme nur für DSGVO/ATT-Modal (System-Pflicht) | **VERWENDE `gameplay_bg` (#0E0A24) oder `background_dark` (#120D2A) als primär. AKZEPTIERE KEINEN hellen Hintergrund (#FFFFFF oder >#4A4A4A Helligkeit) auf Spielfeld-Screens.** |
| A2 | S005, S007, alle Hub-Screens | Fünf-Icon Bottom-Tab-Bar persistent auf allen Screens | Kein persistentes Bottom-Tab-Element. Navigation über kontextuelles Radial-Menü (Swipe-Up) und situative Action-Surfaces die je nach Screen-State eingebettet sind. | **IMPLEMENTIERE KEINE persistente 5-Icon-Bottom-Tab-Bar. Nutze kontextuelle UI-Elemente und Gesten für Navigation. Eine minimale 3-Icon-Bar (Home, Map, Profil) ist für iOS HIG-Compliance erlaubt, darf aber nicht dominant sein.** |
| A3 | S008, S009 | Konfetti-Regen, drei goldene Sterne und "AMAZING!"-Text auf dem Gewinn-Screen | Vollbild-Poster-Karte mit expressiver Typografie (konkrete Session-Aussage wie "47 Züge. Kein Fehler."), Kapitel-Farbwelt als Hintergrund, ein einziger "Teilen"-Button. Kein Konfetti. Keine generischen Lobtext-Banner. | **VERWENDE KEINE Konfetti-Emitter oder "AMAZING!"-Texte. IMPLEMENTIERE den Level-Ergebnis-Screen als Poster-Karte mit `A040 Share-Result-Bild-Template` und dynamischem Text-Overlay.** |
| A4 | S010, alle Shop-Screens | Rote "BEST VALUE!"-Schräg-Banner und Puls-Countdown-Timer im Shop | Maximale drei Angebote gleichzeitig, kein Schräg-Banner, kein Puls-Effekt beim Timer, Preise in klarer lesbarer Type ohne Gold-Rendering, Countdown als dezenter Text ("noch 23 Tage") nicht als animierter Balken. | **IMPLEMENTIERE den Shop (S011) mit maximal 3 sichtbaren Angeboten ohne Scrollzwang. VERWENDE KEINE roten "BEST VALUE!"-Banner oder pulsierende Countdown-Timer. Timer-Text ist dezent (`A033 Saison-Timer-Visual`).** |
| A5 | S003 | Hand-Cursor der ersten Zug zeigt, Tutorial-Overlay mit abgedunkeltem Hintergrund, statische Dialog-Bubble mit erklärender Figur | Spielfeld erscheint ohne Overlay; subtiles einmaliges Pulsieren der Steine als organische Aufmerksamkeits-Lenkung nach 4 Sekunden Inaktivität (Scale 1.0→1.03→1.0 in 1,2 Sek.); erster Stein folgt dem Finger mit 20% Nachzieh-Elastizität wie durch Wasser; Entdeckung durch Spielen nicht durch Erklären. | **IMPLEMENTIERE das Onboarding (S003) OHNE Tutorial-Overlay, Hand-Cursor oder Dialog-Bubbles. Nutze subtiles Stein-Pulsieren und elastisches Drag-Feedback (W2).** |
| A6 | S006, S008 | Partikel-Burst-Explosion bei jedem Match (200ms-Pop-Effekt) | Resonanz-Puls: Stein-Match löst einen Ton aus der nachhallt statt berstet; Cascade-Töne steigen auf statt ab; Special-Steine formen sich via 400ms Morphing-Animation mit tiefem Haptik-Puls; dreischichtige adaptive Sound-Schicht die mit dem Spieltempo atmet. | **VERWENDE KEINE Partikel-Burst-Explosionen. IMPLEMENTIERE Match-Feedback über Licht-Emission (`MI-02`) und Resonanz-Sound (`Sound-Prinzip`).** |

---

## 9. Legal-Anforderungen für Produktion

**Hinweis:** Die folgenden Anforderungen sind generisch für ein Mobile Game in DACH/EU/US-Märkten und wurden basierend auf den Design-Vorgaben (insbesondere S002 Consent-Dialog, D3 Spielstil-Tracking) abgeleitet, da keine spezifischen Legal-Reports für EchoMatch vorlagen.

### Consent-Screens (DSGVO, ATT)
*   **VERBINDLICH:** Implementierung eines **DSGVO-konformen Consent-Management-Systems (CMP)** auf S002.
    *   **Granularität:** Nutzer muss die Möglichkeit haben, einzelnen Datenverarbeitungszwecken (z.B. Analytics, Personalisierung) zuzustimmen oder diese abzulehnen.
    *   **Gleichwertigkeit:** Opt-In- und Opt-Out-Optionen müssen visuell gleich prominent sein (keine Dark Patterns).
    *   **Transparenz:** Klare, verständliche Sprache, die erklärt, welche Daten wofür verwendet werden.
    *   **Widerruf:** Möglichkeit zum Widerruf des Consents jederzeit in den Einstellungen (S018).
*   **VERBINDLICH (iOS):** Implementierung eines **ATT-Pre-Primers** auf S002 (UXI-04).
    *   Ein eigener Screen muss vor dem iOS-System-ATT-Dialog erscheinen und in menschlicher Sprache den Nutzen des Trackings erklären.
    *   Der iOS-System-Dialog `requestTrackingAuthorization()` darf erst nach Interaktion mit diesem Pre-Primer aufgerufen werden.

### Age-Gate / COPPA
*   **VERBINDLICH:** Implementierung eines **Alters-Gates** auf S002 (F020) zur Einhaltung von COPPA (USA) und ähnlichen Jugendschutzgesetzen (z.B. DSGVO Art. 8).
    *   **Altersprüfung:** Abfrage des Geburtsdatums oder Alters des Nutzers.
    *   **Hard-Block:** Nutzer unter 13 Jahren (COPPA-Grenze) müssen vom Zugriff auf die App blockiert werden.
    *   **Freundliche Illustration:** Der Block-Screen (A008) muss eine freundliche, altersgerechte Illustration zeigen, die erklärt, warum der Zugriff nicht möglich ist.
    *   **Keine Datensammlung:** Für Nutzer unter 13 Jahren dürfen **keine personenbezogenen Daten** gesammelt werden.

### Datenschutz
*   **VERBINDLICH:** Erstellung einer **vollständigen und rechtlich wasserdichten Datenschutzerklärung** (Privacy Policy).
    *   **Client-Side-Verarbeitung:** Explizite Erwähnung, dass Spielstil-Tracking (D3) und Level-Daten **ausschließlich lokal auf dem Gerät** verarbeitet werden und das Gerät nicht verlassen.
    *   **Drittanbieter:** Nennung aller Drittanbieter, die personenbezogene Daten verarbeiten (Firebase, Google Cloud Run, Payment-Provider, Ad-SDKs).
    *   **Rechtsgrundlage:** Angabe der Rechtsgrundlage für jede Datenverarbeitung (z.B. Vertragserfüllung, berechtigtes Interesse, Einwilligung).
*   **VERBINDLICH:** Abschluss von **Auftragsverarbeitungsverträgen (AVV)** mit allen relevanten Drittanbietern (Firebase, Google Cloud Run, Payment-Provider, Ad-SDKs).
*   **VERBINDLICH:** Implementierung der **Apple App Privacy Labels** und der **Google Play Data Safety Section** mit korrekten und vollständigen Angaben zu den Datenpraktiken der App.

### Pflicht-UI
*   **VERBINDLICH:** **Datenschutzerklärung und Impressum** (für DE/AT) müssen in der App (S018) und im App Store Listing verlinkt sein.
*   **VERBINDLICH:** **KI-Kennzeichnung:** Alle KI-generierten Inhalte (z.B. KI-generierte Level, wenn diese als solche kommuniziert werden) müssen als "KI-generiert" oder "von KI unterstützt" gekennzeichnet werden, um Transparenz zu gewährleisten.

### App Store Compliance
*   **VERBINDLICH (Apple):** Einhaltung der **Apple App Review Guidelines**.
    *   **IAP:** Alle In-App-Käufe müssen über **Apple StoreKit** abgewickelt werden. Externe Zahlungslinks sind verboten.
    *   **Content:** Altersgerechte Inhalte, keine anstößigen oder irreführenden Elemente.
    *   **Datenschutz:** Korrekte Ausfüllung der Privacy Nutrition Labels.
    *   **Account-Löschung:** Möglichkeit zur Account-Löschung direkt in der App (falls Accounts eingeführt werden).
*   **VERBINDLICH (Google):** Einhaltung der **Google Play Developer Policy Center Guidelines**.
    *   **IAP:** Alle In-App-Käufe müssen über das **Google Play Billing System** abgewickelt werden.
    *   **Data Safety:** Korrekte Ausfüllung des Data Safety Formulars.
    *   **Altersfreigabe:** Korrekte IARC-Altersfreigabe.

---

## 10. Tech-Stack Detail

*   **Engine + Version:**
    *   **VERBINDLICH:** Unity 2022.3 LTS (Long Term Support)
    *   **VERBINDLICH:** Universal Render Pipeline (URP) für alle Grafik-Features (Bloom, Emission Maps).
    *   **VERBINDLICH:** Unity Input System Package für Gestensteuerung (Swipe, Long-Press).
    *   **VERBINDLICH:** TextMeshPro für alle Text-Elemente (Typografie-Kontrolle, Performance).
    *   **VERBINDLICH:** Unity Addressables für effizientes Asset Loading (insbesondere Story-Varianten).
*   **Backend-Dienste:**
    *   **VERBINDLICH:** Firebase (Google Cloud) für:
        *   **Firestore:** Speicherung von Spielerprofilen (F046), Freundeslisten (F039), Level-Metadaten (F002), Battle Pass Progression (F037), Remote Config-Werten (F024).
        *   **Firebase Authentication:** Nutzerkonten (F046), Login.
        *   **Firebase Remote Config:** Dynamische Anpassung von Gameplay-Parametern (F024), A/B-Test-Varianten (F048).
        *   **Firebase Crashlytics:** Crash Reporting (F023).
        *   **Firebase Analytics:** Event-Tracking für KPIs (F022).
    *   **VERBINDLICH:** Google Cloud Run:
        *   Serverless Functions für IAP-Validierung (F036), Battle Pass Logik (F037), Leaderboard-Updates (F040), KI-Level-Generierung (F031) (falls komplexere KI-Modelle serverseitig laufen).
*   **SDKs:**
    *   **VERBINDLICH:** Native Share Plugin (z.B. NativeShare by Yasirkula) für Social Sharing (F030).
    *   **VERBINDLICH:** Unity IAP (für StoreKit/Google Play Billing) für In-App-Käufe (F036).
    *   **VERBINDLICH:** Ad-SDK (z.B. Unity Ads, Google AdMob) für Rewarded Ads (F029).
*   **CI/CD Pipeline:**
    *   **Empfehlung:** Unity Cloud Build oder GitLab CI/CD mit Fastlane für automatisierte Builds und Deployments.
    *   **Empfehlung:** Automatische Tests (Unit, Integration, UI) in die Pipeline integrieren.
*   **Monitoring + Crash-Reporting:**
    *   **VERBINDLICH:** Firebase Crashlytics für Crash Reporting (F023).
    *   **Empfehlung:** Google Cloud Monitoring für Backend-Dienste (Cloud Run, Firestore).
    *   **Empfehlung:** UptimeRobot oder Better Uptime für externe Verfügbarkeitsüberwachung.

---

## 11. Release-Anforderungen

**Hinweis:** Die folgenden Release-Anforderungen sind generisch für ein Mobile Game und wurden basierend auf den Design-Vorgaben und der Asset-Priorisierung abgeleitet, da keine spezifischen Release-Reports für EchoMatch vorlagen.

### Phase 0: Closed Beta
*   **Ziel:** Kernfunktionen unter realen Bedingungen validieren, insbesondere Match-3 Core Loop, Onboarding, Silent Persona Engine (D3), Dark-Field Luminescence (D1) und erste Monetarisierungs-Mechaniken (Rewarded Ads, Basic IAP Shop). Qualitative Nutzerfeedback-Daten sammeln.
*   **Dauer:** 4 Wochen
*   **Teilnehmer:** 100–200 handverlesene Nutzer aus der Zielgruppe (18-34, Match-3-Spieler) über Discord-Communities und Social Media. Einladungsbasiert.
*   **Erfolgskriterien:**
    *   ≥ 70% der Beta-Nutzer schließen das Onboarding-Match (S003) erfolgreich ab.
    *   ≥ 50% der Nutzer spielen mindestens 5 Levels.
    *   D1 Retention ≥ 40%, D7 Retention ≥ 15%.
    *   Qualitatives Feedback: Mindestens 50 ausgefüllte Feedback-Formulare (S019) mit offenen Antworten zu "Was hat dich überrascht?" und "Was fehlt?".
    *   0 kritische Abstürze (Crash-Free Rate > 99.5%).
    *   **VERBINDLICH:** 0 kritische Datenschutzvorfälle (Client-Side-Versprechen muss technisch verifiziert sein).

### Phase 1: Soft Launch
*   **Ziel:** Öffentliche Zugänglichkeit für ausgewählte Märkte herstellen, Monetarisierungs-Funnel scharfschalten (IAP, Rewarded Ads), erste Revenue-Daten validieren. Technische Skalierbarkeit testen.
*   **Dauer:** 6–8 Wochen
*   **Regionen:** Kanada, Australien, Neuseeland (Tier-1-Englischsprachig, geringer Wettbewerb), optional DACH (Deutschland, Österreich, Schweiz) für DSGVO-Validierung.
*   **KPIs (Go/No-Go Kriterien für Global Launch):**
    *   DAU (Daily Active Users) ≥ 1.000 bis Ende Woche 8.
    *   D7 Retention ≥ 20%, D30 Retention ≥ 10%.
    *   ARPU (Average Revenue Per User) ≥ 0,20 USD/Tag.
    *   Conversion Rate (Free → IAP) ≥ 2%.
    *   Ad Watch Rate (Rewarded Ads) ≥ 30%.
    *   **VERBINDLICH:** Crash-Free Rate > 99.8%.
    *   **VERBINDLICH:** App Start Time < 3 Sekunden auf Mid-Range-Geräten.
*   **Go/No-Go Kriterien:** Erreichen der oben genannten KPIs. Positive Nutzer-Reviews (Durchschnitt > 4.0 Sterne). Stabile Server-Performance.

### Phase 2: Global Launch
*   **Ziel:** Skalierung auf alle Tier-1-Märkte (USA, UK, EU gesamt, Japan, Südkorea). Full Production Features (Phase B) aktivieren. PR-Welle und Marketing-Kampagnen starten.
*   **Datum/Zeitrahmen:** 10–12 Wochen nach Beta-Start (ca. 3 Monate nach Phase-0-Beginn).
*   **Checkliste:**
    *   [ ] Alle Phase B Features implementiert und getestet.
    *   [ ] Marketing-Assets (A089-A097) für alle Zielregionen finalisiert.
    *   [ ] App Store Listings (iOS, Android) mit optimierten Screenshots und Texten.
    *   [ ] Server-Infrastruktur für erwarteten Traffic-Peak skaliert und getestet.
    *   [ ] Kundensupport-Kanäle (In-App, E-Mail) eingerichtet und besetzt.
    *   [ ] Rechtliche Dokumente (Privacy Policy, ToS) für alle Zielregionen aktualisiert.
    *   [ ] A/B-Test-Infrastruktur (F048) aktiv für Monetarisierungs-Optimierung.

### App Store Submission Checklisten

#### Apple App Store
*   [ ] **VERBINDLICH:** App-Icon (A001) in allen erforderlichen Größen (1024x1024px Master, etc.) und ohne Alpha-Kanal.
*   [ ] **VERBINDLICH:** App-Preview-Video (A092) und 6-8 Screenshots (A089) für alle iPhone-Größen (6.7", 6.5", 5.5").
*   [ ] **VERBINDLICH:** Vollständige und korrekte Privacy Nutrition Labels ausgefüllt.
*   [ ] **VERBINDLICH:** `requestTrackingAuthorization()` wird erst nach dem ATT-Pre-Primer (S002) aufgerufen.
*   [ ] **VERBINDLICH:** Alle In-App-Käufe über StoreKit (F036) implementiert, keine externen Zahlungslinks.
*   [ ] **VERBINDLICH:** Altersfreigabe korrekt gesetzt (z.B. 4+ oder 9+ für Match-3).
*   [ ] **VERBINDLICH:** Account-Löschfunktion (F046) direkt in der App zugänglich (falls Accounts implementiert).
*   [ ] **VERBINDLICH:** App funktioniert vollständig ohne Account-Erstellung (Guest Mode) für Free-Features.
*   [ ] **VERBINDLICH:** Keine Verweise auf andere Plattformen (Android) in der App-UI.

#### Google Play
*   [ ] **VERBINDLICH:** App-Icon (A001) und Adaptive Icon (A091) in allen erforderlichen Größen.
*   [ ] **VERBINDLICH:** Feature Graphic (A062) 1024x500px und 6-8 Screenshots (A090) für Phone-Format.
*   [ ] **VERBINDLICH:** Vollständiges und korrektes Data Safety Formular ausgefüllt.
*   [ ] **VERBINDLICH:** Alle In-App-Käufe über Google Play Billing (F036) implementiert.
*   [ ] **VERBINDLICH:** IARC-Altersfreigabe-Fragebogen korrekt ausgefüllt.
*   [ ] **VERBINDLICH:** Target API Level aktuell (innerhalb von 1 Jahr nach aktuellem Android-Release).
*   [ ] **VERBINDLICH:** App Bundle (.aab) statt APK eingereicht.
*   [ ] **VERBINDLICH:** Account-Löschfunktion (F046) direkt in der App zugänglich (falls Accounts implementiert).

### Post-Launch Plan (erste 4 Wochen)
*   **Woche 1: Stabilisierung und Sofort-Feedback:** Tägliches Monitoring von Crash-Reports (F023), Server-Logs, IAP-Transaktionen. Behebung kritischer Bugs (P0/P1) innerhalb von 24 Stunden. Auswertung des ersten qualitativen Feedbacks (S019).
*   **Woche 2: Conversion-Optimierung:** Analyse des Monetarisierungs-Funnels (F036). Start des ersten A/B-Tests (F048) zur Optimierung der IAP-Preise oder Rewarded Ad Platzierung.
*   **Woche 3: Retention-Analyse & Content-Planung:** D7 Retention-Analyse. Planung neuer Daily Quests (F012) und Battle Pass Inhalte (F037).
*   **Woche 4: Social & Community Engagement:** Aktive Präsenz in Social Media und Discord. Start erster Friend Challenges (F038) und Leaderboard-Events (F040).

---

## 12. KPIs für Produktion

**Hinweis:** Die folgenden KPIs sind generisch für ein Match-3 Mobile Game und wurden basierend auf den Design-Vorgaben und der Monetarisierungsstrategie abgeleitet, da keine spezifischen KPI-Reports für EchoMatch vorlagen.

### Business KPIs

| KPI | Phase 0 (Beta) | Phase 1 (Soft Launch) | Phase 2 (Global Launch) |
|---|---|---|---|
| **DAU (Daily Active Users)** | 100–200 | 1.000–5.000 | 50.000–200.000 |
| **WAU (Weekly Active Users)** | 200–400 | 2.000–10.000 | 100.000–500.000 |
| **MAU (Monthly Active Users)** | 300–600 | 3.000–15.000 | 150.000–750.000 |
| **D1 Retention** | ≥ 40% | ≥ 35% | ≥ 30% |
| **D7 Retention** | ≥ 15% | ≥ 12% | ≥ 10% |
| **D30 Retention** | ≥ 8% | ≥ 6% | ≥ 5% |
| **ARPU (Average Revenue Per User)** | 0,05–0,10 USD/Tag | 0,20–0,30 USD/Tag | 0,30–0,50 USD/Tag |
| **LTV (Lifetime Value)** | 1–3 USD | 5–10 USD | 10–20 USD |
| **Conversion Rate (Free → IAP)** | 1–2% | 2–3% | 3–5% |
| **Conversion Rate (Free → Battle Pass)** | 0,5–1% | 1–2% | 2–3% |
| **Churn Rate (Monatlich)** | 15–20% | 10–15% | 8–12% |
| **Battle Pass Completion Rate** | 10–15% | 15–20% | 20–25% |
| **Ad Watch Rate (Rewarded Ads)** | 20–30% | 30–40% | 40–50% |
| **Social Share Rate (D4)** | 5–10% | 8–12% | 10–15% |

### Technische KPIs

| KPI | Phase 0 (Beta) | Phase 1 (Soft Launch) | Phase 2 (Global Launch) |
|---|---|---|---|
| **App Start Time (Cold Start)** | < 4 Sek. | < 3 Sek. | < 2,5 Sek. |
| **Level Load Time (KI-Generierung)** | < 5 Sek. | < 3 Sek. | < 2 Sek. |
| **FPS (min/avg)** | 25/30 FPS | 30/45 FPS | 45/60 FPS |
| **Crash Rate** | < 0,5% | < 0,2% | < 0,1% |
| **App Size (Download)** | < 200 MB | < 150 MB | < 100 MB |
| **API Latency (Backend Calls)** | < 500 ms | < 300 ms | < 150 ms |
| **Memory Usage (Max)** | < 500 MB | < 400 MB | < 300 MB |
| **Battery Drain (pro Stunde)** | < 15% | < 10% | < 8% |

---

## 13. Design-Checkliste (Endabnahme vor Release)

### Block A: Differenzierungspunkte

*   [ ] **D1 (Dark-Field Luminescence) ist visuell erkennbar:** Spielfeld-Hintergrund ist messbar im Bereich #0D0F1A–#1A1D2E; Spielsteine emittieren nachweislich Licht (Bloom-Effekt sichtbar, Emission-Maps aktiv); kein Stein reflektiert nur — alle leuchten eigenständig; Unterschied zu hellem Candy-Crush-Hintergrund ist für jeden Tester ohne Erklärung sofort sichtbar.
*   [ ] **D2 (Kontextuelle Navigation) ist funktional:** Zu drei verschiedenen Testzeiten (morgens 8 Uhr, mittags 13 Uhr, abends 21 Uhr) zeigt der Home Hub (S005) jeweils eine unterschiedliche Primär-Konfiguration; kein statischer 5-Icon-Bottom-Bar ist im fertigen UI vorhanden; Social-Lichtpunkte auf Level-Map (S008) sind ohne separaten Tab sichtbar.
*   [ ] **D3 (Silent Persona Engine) ist aktiv:** Nach 60 Sekunden Spielzeit im Onboarding (S003) sind mindestens 3 Spieler-Datenpunkte in PlayerPrefs geschrieben (Pause-Average, Zug-Speed, Combo-Rate); das erste KI-Level weicht messbar von einem Flat-Difficulty-Level ab; Story-Hook (S004) zeigt persona-passende Variante (verifizierbar durch A/B-Test mit zwei simulierten Personas).

### Block B: Anti-Standard-Regeln (alle Verbote)

*   [ ] **Kein Konfetti-Effekt** ist im gesamten App-Build vorhanden — Partikel-Suche im Particle-System-Inventory ergibt null Konfetti-Emitter.
*   [ ] **Kein AMAZING / GREAT / PERFECT-Text** in Schriftgröße über 48pt auf Reward-Screens (S007) — Typografie-Audit bestätigt maximale Headline-Größe auf S007.
*   [ ] **Kein roter BEST VALUE-Aufkleber** oder farblich hervorgehobenes Preis-Badge im Shop (S011) — visueller Audit von S011 ergibt keine Rot-Hex-Werte (#FF0000 ±30%) in Badge-Elementen.
*   [ ] **Kein Fehler-Sound / Buzz-Haptik** bei unmöglichem Zug (S006) — QA-Test mit 10 bewussten Fehl-Moves ergibt null Audio-Trigger und null Error-Haptik-Events.
*   [ ] **Kein Tutorial-Overlay mit Zeige-Cursor** auf S003 — Screenshot-Audit von S003 erster Sekunde zeigt null Overlay-Elemente, null Hand-Cursor-Assets.
*   [ ] **Kein Push-Banner für Social-Nudges** — Social-Benachrichtigungen erscheinen ausschließlich als Lichtpuls auf Freundes-Avataren (S005), nicht als Banner-Overlay.
*   [ ] **Kein heller Hintergrund** (#FFFFFF oder Werte über #4A4A4A Helligkeit) auf Spielfeld-Screens (S006) — automatisierter Color-Picker auf S006-Screenshot ergibt null Werte über definiertem Schwellwert.
*   [ ] **Kein Bottom-Navigation-Bar mit fünf fixen Icons** — UI-Inventory-Check ergibt kein statisches 5-Icon-Navigationselement.

### Block C: Wow-Momente

*   [ ] **W1 (Logo-Genesis):** Mindestens 3 von 5 unvorbereiteten Testnutzern beschreiben die Spielfeld-Optik spontan als "anders", "lebendig", "dunkel aber schön" oder äquivalente positive Differenzierungsaussagen — ohne Suggestivfragen.
*   [ ] **W2 (Der lebendige erste Stein):** Mindestens 3 von 5 Testnutzern beschreiben nach der ersten KI-Level-Erfahrung ein Gefühl von "passt irgendwie zu mir" oder "genau richtig schwer" — gemessen via 1-Fragen-Exit-Survey nach Level 2.
*   [ ] **W3 (Goldene Ausatmung):** Mindestens 3 von 5 Testnutzern lesen die Text-Zusammenfassung auf dem Reward-Screen (S007) vollständig (Eye-Tracking oder Verweildauer ≥3 Sek. auf Text-Element) statt sofort auf "Weiter" zu tippen.

### Block D: Emotionale Leitlinie

*   [ ] **Gesamt-Energie ist 6/10:** App wirkt weder gehetzt noch einschläfernd — Testnutzer bewerten auf Skala 1–10 (1=schlafend, 10=überwältigt) im Median zwischen 5 und 7.
*   [ ] **Farbtemperatur ist Tief-Organisch:** Kein Candy-Neon-Wert (Sättigung >90% bei Helligkeit >70%) außerhalb von bewussten Akzent-Momenten (Special-Stein-Aktivierung, Gold-Shift-Reward); Bernstein- und Kupfer-Akzente sind die wärmsten Farben im Interface.
*   [ ] **Sound ist Resonanz, nicht Explosion:** Peak-Lautstärke aller Match-Sounds liegt unter –12 dBFS; kein Sound hat einen Attack kürzer als 20ms (verhindert perkussive Explosion-Wirkung); QA-Audio-Analyse bestätigt.
*   [ ] **Animationen atmen in 600–900ms:** Alle primären UI-Transitions werden mit Ease-In-Out in diesem Zeitfenster ausgeführt; kein primäres UI-Element transitioniert unter 400ms oder über 1200ms — automatisierter Timing-Audit via UI-Profiler.

### Block E: Interaktions-Prinzipien

*   [ ] **Haptik ist dreischichtig und aktiv:** QA-Test auf physischem iOS-Gerät (iPhone 12+) und Android-Gerät (Snapdragon 778+) bestätigt drei unterschiedlich intensive Haptik-Events in S006 (Drag-Ticken, Snap, Cascade-Rumble) — alle drei sind subjektiv unterscheidbar.
*   [ ] **Micro-Interactions HOCH (MI-01 bis MI-09) sind alle implementiert:** Jede der 9 High-Priority-Micro-Interactions hat einen QA-Testfall mit Pass/Fail-Kriterium; alle 9 sind auf Pass.
*   [ ] **Kein negativer Feedback-Loop** auf falsche Züge: QA-Protokoll dokumentiert 20 bewusste Fehl-Moves auf S006 ohne einen einzigen Fehler-Sound, Fehler-Visual oder Buzz-Haptik-Event.

### Block F: Differenzierung vom Wettbewerb

*   [ ] **Visueller Unterschied zu Top-3-Wettbewerbern ist messbar:** Side-by-Side-Screenshot-Vergleich von EchoMatch S006 mit Candy Crush Saga, Royal Match und Homescapes zeigt auf 5 von 5 befragten Testern sofortige Unterscheidbarkeit ohne Namens-Overlay.
*   