# Creative Director Technical Roadbook: EchoMatch
## Version: 1.0 | Status: VERBINDLICH fuer alle Produktionslinien

---

## 1. Produkt-Kurzprofil

**App Name:** EchoMatch

**One-Liner:**
Ein Match-3-Puzzle-Spiel, das sich visuell und emotional vollständig vom Candy-Crush-Industriemodell abkoppelt, indem es ein dunkles, selbstleuchtendes Spielfeld, kontextuelle Navigation und eine narrative Spielerfahrung bietet, die den Nutzer persönlich anspricht.

**Plattformen:**
*   iOS (primär)
*   Android (sekundär)

**Tech-Stack (Inferenz aus Design- und Asset-Reports):**
*   **Game Engine:** Unity (mit Universal Render Pipeline - URP)
*   **Design Tools:** Figma, Adobe Illustrator, Adobe Photoshop
*   **AI-Generierung (Assets):** Midjourney, Adobe Firefly
*   **Animationen:** Lottie (via Bodymovin Plugin für After Effects)
*   **Icon-Basis:** Phosphor Icons (angepasst)
*   **Backend (für AI-Integration, Social, Monetarisierung):** Firebase (Authentication, Firestore, Remote Config, Cloud Functions), Google Cloud Run (für Claude API-Wrapper)
*   **Payment:** Stripe (für Web-Monetarisierung, falls PWA-Ansatz verfolgt wird), Apple StoreKit, Google Play Billing (für native Apps)
*   **Analytics:** Firebase Analytics oder Plausible Analytics (DSGVO-konform)

**Zielgruppe:**
Berufstätige Erwachsene, 18–34 Jahre, leicht weiblich dominiert (~55–60 % weiblich), urban, Tier-1-Märkte (DACH, UK, USA, Skandinavien). Schätzen hochwertige Ästhetik, suchen Flow und Entspannung in kurzen Sessions (5–10 Minuten), sind immunisiert gegen aggressive Dark Patterns und schätzen persönliche Ansprache sowie subtile soziale Interaktion.

---

## 2. Design-Vision (VERBINDLICH)

### Design-Briefing
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
| **D1** | **Dark-Field Luminescence** | Spielfeld-Hintergrund ist #0D0F1A bis #1A1D2E (tiefdunkles Blau-Grau). Spielsteine sind selbstleuchtende Objekte mit Unity URP Bloom-Post-Processing und Emission-Maps — sie emittieren Licht, sie reflektieren es nicht. Roter Stein = Glut. Blauer Stein = biolumineszentes Wasser. Hintergrund pulsiert subtil bei Combos. Farbtemperatur der Steine wechselt kapitelbasiert via ScriptableObjects: Kapitel 1 = kühle Töne, Kapitel 3 = warme Amber-Töne. Performant ab Snapdragon 678+ durch skalierbare Bloom-Intensität. | S001, S004, S006, S008, S009 | **VERBINDLICH — keine Verhandlung** |
| **D2** | **Kontextuelle Navigation** | Keine feste Bottom-Bar mit 5 Icons. Navigation reagiert auf Tageszeit, Quest-State und Session-Phase: 6–10 Uhr morgens = Daily Quest dominiert, Social minimiert; 12–14 Uhr = kompakte Commuter-Ansicht; 19–23 Uhr = Story-Hub-Teaser prominent, Shop-Nudge für Entspannungs-Session. Social-Nudges erscheinen als Lichtpuls auf Freundes-Avataren im Header statt als Push-Banner. Freunde sind als Lichtpunkte ambient auf der Level-Map sichtbar (Zenly-Prinzip) — kein separater Social-Tab nötig. | S005, S007, alle Hub-Screens | **VERBINDLICH — keine Verhandlung** |
| **D3** | **Implizites Spielstil-Tracking ab Sekunde 1** | Das Onboarding-Match (S003) erfasst unsichtbar: Pausenlänge zwischen Zügen (Grübler vs. Intuitiv), Zuggeschwindigkeit, Combo-Orientierung vs. schnelles Räumen. Kein Fragebogen, keine explizite Abfrage. Das erste echte KI-Level ist bereits personalisiert. Die narrative Hook-Sequenz (S004) passt ihr visuelles Setting an den erkannten Spieltyp an: Intuitiv-Schnell = kinetischere, städtischere Welt; Grübler = tiefere, mythologischere Welt. Personalisierung beginnt in Sekunde 1, ist für den Nutzer vollständig unsichtbar. | S003, S004, S006 | **VERBINDLICH — keine Verhandlung** |
| **D4** | **Post-Session-Screen als Poster / Share-Card** | Kein generischer Reward-Overlay mit Konfetti. Der Ergebnis-Screen ist als Poster-Ästhetik designed (Spotify Wrapped-Prinzip): große isolierte Zahl oder Satz auf dunklem Grund, eine Akzentfarbe, lesbare Zusammenfassung des eigenen Spielstils ("Du hast heute 3 Cascades in einem Zug ausgelöst"). Format ist nativ share-optimiert — Nutzer schicken es weil es wie ein Statement aussieht, nicht wie ein UI-Screenshot. | S008, S009 | **VERBINDLICH — keine Verhandlung** |
| **D5** | **Story-NPC als Interface-Brecher** | Narrative Figuren können außerhalb ihrer Story-Screens erscheinen und das Interface kommentieren (Duolingo-Owl-Prinzip). Beispiel: NPC taucht nach einem verlorenen Level im Home Hub auf und gibt einen kontextuellen Kommentar im Ton der Spielwelt — kein generisches "Try again!". Diese Momente sind selten (max. 1× pro Woche) und dadurch bedeutsam. Sind primär für virales Social-Sharing designed: Out-of-Character-Momente die Nutzer screenshotten. | S005, S008, S009 | **VERBINDLICH — keine Verhandlung** |

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
| **W1** | **Logo-Genesis** | S001 | Aus dem dunklen Hintergrund bilden sich drei Spielsteine in den App-Farben, ordnen sich zu einem Match, verschwinden mit einem weichen Resonanz-Puls (einzelner tiefer Kristallton), und aus diesem Puls formt sich das EchoMatch-Logo. Ladezeit ≤2 Sek. — die Animation ist nie fertig bevor sie endet, sie ist die Ladezeit. Bei Slow-Connection wiederholt der Puls sich ruhig als Herzschlag-Echo. | Erste 2 Sekunden prägen den emotionalen Kontrakt — Nutzer erlebt sofort: diese App ist anders als Candy Crush; Logo-Genesis kommuniziert ohne Wort die Kernmechanik und visuelle Identität; kein anderer Wettbewerber hat einen Splash der selbst eine Mini-Geschichte erzählt |
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
**Stil:** Stylized 2.5D Casual Cartoon mit Depth-Layering
**Beschreibung:** Weiche, abgerundete Formen mit leichtem 3D-Extrude-Effekt auf Spielsteinen und wichtigen UI-Elementen; saettigte, leuchtende Farben mit subtilen Gradienten; schwarze Outlines mit variabler Strichstaerke (2-4px) fuer Tiefe; Charaktere und Mascottes haben grosse, ausdrucksstarke Augen und einfache Silhouetten; Hintergrundelemente sind weicher und weniger gesaettigt als Vordergrund-Assets um Spielsteine visuell zu priorisieren; Lichteffekte und Highlights als weisse Glanzpunkte auf Spielsteinen zur Volumenvermittlung
**Begruendung:** 2.5D Casual Cartoon ist der visuelle Standard der kommerziell erfolgreichsten Match-3-Games (Royal Match, Candy Crush, Gardenscapes); die Zielgruppe 18-34 erwartet polished visuals ohne harten Realismus; das Stil ermoeglicht starke Lesbarkeit der Spielsteine bei gleichzeitig emotionaler Attraktivitaet; Dark-Mode-Kompatibilitaet wird durch leuchtende Eigenfarben statt helle Hintergruende gewaehrleistet

### Icon-Stil
**Stil:** Filled mit weichen Kanten, passend zum Illustration-Stil; keine scharfen rechten Winkel
**Library:** Custom Icon Set basierend auf Phosphor Icons (MIT-Lizenz) als Basis, angepasst an EchoMatch-Aesthetik mit 3px corner-radius auf eckigen Elementen
**Grid:** 24x24dp Basisgitter; 48x48dp fuer Gameplay-Booster-Icons; 96x96dp fuer Reward-Item-Icons; 20x20dp fuer Notification-Icon (monochrom, Android-konform)

### Animations-Stil
**Default Duration:** 280ms
**Easing:** cubic-bezier(0.34, 1.56, 0.64, 1) (leichter Bounce)
**Max Lottie:** 500 KB pro Animation
**Static Fallback:** Ja (für alle Lottie-Animationen und komplexen Effekte)

---

## 4. Feature-Map

**HINWEIS:** Die folgenden Feature-Listen sind generische Beispiele für ein Match-3-Spiel und basieren **NICHT** auf spezifischen Feature-Reports für EchoMatch. Die bereitgestellten Reports (Feature List, Prioritization) beziehen sich auf 'skillsense'. Eine dedizierte Feature-Analyse und Priorisierung für EchoMatch ist erforderlich. Die hier dargestellten Wochen und Abhängigkeiten sind Schätzungen für ein typisches Mobile Game.

### Phase A — Soft-Launch MVP (Geschätzte 30 Features)

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten |
|---|---|---|---|---|---|
| F001 | Core Match-3 Gameplay | Grundlegende Match-3-Mechanik: Steine tauschen, Matches bilden, Steine fallen lassen. | D1, Session-Dauer | 4 | - |
| F002 | Level-Progression (Kapitel 1) | 15 einzigartige Levels mit steigendem Schwierigkeitsgrad und verschiedenen Zielen. | D7, D30 | 3 | F001 |
| F003 | Basis-Booster-System | 2 einfache Booster (Hammer, Shuffle) mit begrenzter Nutzung pro Level. | Conversion, Session-Dauer | 2 | F001 |
| F004 | Score-System & Highscore | Punktevergabe für Matches und Combos, lokaler Highscore pro Level. | D1, Session-Dauer | 1 | F001 |
| F005 | Level-Ziele (Basis) | Sammle X Steine, erreiche X Punkte, zerstöre X Hindernisse. | D1, Session-Dauer | 1 | F001 |
| F006 | Onboarding-Match (Implizites Tracking) | Erstes Match ohne Tutorial-Overlay, misst Spielstil (D3). | D1, D3 | 2 | F001 |
| F007 | Narrative Hook Sequenz | Kurze, atmosphärische Story-Sequenz nach Onboarding (D3). | D30, Story-Engagement | 2 | F006 |
| F008 | Home Hub (Basis) | Startbildschirm mit Level-Start, Daily Quest Teaser. | D1, D7 | 2 | F002 |
| F009 | Level-Map (Kapitel 1) | Visuelle Darstellung der Level-Progression für Kapitel 1. | D7, D30 | 2 | F002 |
| F010 | Daily Quest (1 Typ) | Eine tägliche Quest (z.B. "Spiele 3 Levels") mit kleiner Belohnung. | D7, D30 | 2 | F008 |
| F011 | Basis-Shop (3 IAPs) | 3 IAP-Angebote (Booster-Paket, Münzen-Paket, Extra-Züge). | Conversion, ARPU | 3 | F003 |
| F012 | Währungs-System (Münzen) | In-Game-Währung (Münzen) für Booster-Käufe. | Conversion, ARPU | 1 | F011 |
| F013 | Settings (Sound, Haptik) | Einstellungsmenü für Sound, Musik, Haptik. | D1, D7 | 1 | - |
| F014 | DSGVO/ATT Consent (S002) | Consent-Management für Datenverarbeitung und Tracking. | Legal Compliance | 2 | - |
| F015 | Crash-Reporting | Automatische Erfassung von App-Crashes. | Tech Stability | 1 | - |
| F016 | Analytics (Basic) | Tracking von D1/D7/D30 Retention, Session-Dauer, Level-Abschluss. | KPI Tracking | 1 | F014 |
| F017 | App-Start-Sequenz (W1) | Logo-Genesis-Animation (W1) beim App-Start. | D1 | 1 | - |
| F018 | Level-Complete-Feedback (W3) | Goldene Ausatmung (W3) nach Level-Abschluss. | D1, D7 | 2 | F004 |
| F019 | Falscher Zug-Feedback (MI-06) | Stein federt zurück, kein Fehler-Sound. | D1, Session-Dauer | 1 | F001 |
| F020 | Match-Feedback (MI-02) | Resonanz-Puls, Kling-Ton, Hintergrund-Hex-Puls. | D1, Session-Dauer | 1 | F001 |
| F021 | Special-Stein-Entstehung (MI-03) | Morphing-Animation, Haptik-Puls, Resonanz-Ton. | D1, Session-Dauer | 2 | F001 |
| F022 | Kontextuelle Navigation (D2) | Basis-Implementierung der kontextuellen Navigation. | D1, D7 | 3 | F008 |
| F023 | Post-Session Share-Card (D4) | Generierung einer Share-Card nach Level-Abschluss. | Viral UA | 2 | F018 |
| F024 | Age-Gate (COPPA) | Altersprüfung beim ersten Start. | Legal Compliance | 1 | F014 |
| F025 | Impressum & Datenschutzerklärung | Rechtlich notwendige Seiten. | Legal Compliance | 1 | - |
| F026 | Reduced Motion Support | Globale Option für reduzierte Animationen. | Accessibility | 1 | F017, F018, F020, F021 |
| F027 | Haptic Language System (Basis) | 3-Schicht-Haptik für Drag, Snap, Combo. | D1, Session-Dauer | 1 | F001 |
| F028 | Chrono-Responsive UI (Basis) | UI-Tints ändern sich leicht nach Tageszeit. | D1, D7 | 1 | F008 |
| F029 | Sound-Personalisierung (Basis) | Ambient-Sound passt sich leicht an Spieltempo an. | D1, Session-Dauer | 1 | F001 |
| F030 | Pre-Primer für ATT-Consent (UXI-04) | Erklärender Screen vor iOS ATT-Prompt. | ATT Opt-in Rate | 1 | F014 |

**Phase A Budget-Check:**
*   **Entwicklerwochen (geschätzt):** 30 Features * (1-4 Wochen/Feature) = ~60-90 Wochen.
*   **Kosten (geschätzt):** Bei 85-120 €/Stunde (DACH Senior Dev) und 40h/Woche: 60 Wochen * 40h * 85€ = 204.000 €. 90 Wochen * 40h * 120€ = 432.000 €.
*   **Budget (generisch):** 252.500 EUR (aus SkillSense Cost Calculation, hier als Platzhalter).
*   **Status:** **im_budget** (wenn man von einem sehr effizienten MVP-Team und niedrigeren Schätzungen ausgeht, aber die SkillSense-Zahl ist ein Platzhalter).

### Phase B — Full Production (Geschätzte 18 Features)

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten |
|---|---|---|---|---|---|
| F031 | Level-Progression (Kapitel 2-3) | Weitere 30 Levels mit neuen Mechaniken und Hindernissen. | D30, LTV | 6 | F002 |
| F032 | Erweiterte Booster (4-6 Typen) | Neue Booster mit komplexeren Effekten. | Conversion, ARPU | 3 | F003 |
| F033 | Battle-Pass System | Saisonale Progression mit Free- und Premium-Tier Rewards. | D30, LTV, ARPU | 8 | F008, F011 |
| F034 | Social-Layer (Freundesliste, Challenges) | Freunde hinzufügen, Level-Fortschritt sehen, Challenges senden/annehmen. | D30, Viral UA | 6 | F009 |
| F035 | Story-NPCs (Interface-Brecher) | Implementierung von D5 (NPCs kommentieren im UI). | Viral UA, D30 | 4 | F007, F008 |
| F036 | Gilden/Teams (Basis) | Spieler können Gilden beitreten, einfache Team-Quests. | D30, LTV | 5 | F034 |
| F037 | Shop-Erweiterung (Cosmetics, Bundles) | Neue IAP-Kategorien: Avatar-Skins, UI-Themes, Value-Bundles. | ARPU, LTV | 4 | F011 |
| F038 | Event-System (Basis) | Zeitlich begrenzte Events mit speziellen Levels und Rewards. | D7, D30, ARPU | 5 | F002, F010 |
| F039 | Cloud Save | Speichert Spielfortschritt in der Cloud. | D30, User Trust | 2 | F028 (Auth) |
| F040 | Cross-Platform Sync | Synchronisiert Fortschritt zwischen iOS und Android. | D30, User Trust | 3 | F039 |
| F041 | Push Notifications (Basic) | Benachrichtigungen für Daily Quest, Challenge-Antworten. | D7, D30 | 2 | F028 (Auth) |
| F042 | A/B Testing Framework | Infrastruktur für In-App A/B-Tests (Pricing, UI-Elemente). | Conversion, ARPU | 3 | F016 |
| F043 | Lokalisierung (EN, FR, ES) | Übersetzung der UI und Story-Texte in weitere Sprachen. | Global Reach | 4 | F007, F008 |
| F044 | Anti-Cheat-Maßnahmen | Serverseitige Validierung von Spielständen. | User Trust | 3 | F001, F039 |
| F045 | Live-Ops Dashboard | Internes Tool zur Verwaltung von Events, Quests, Battle-Pass. | Operational Efficiency | 5 | F010, F033, F038 |
| F046 | Spieler-Lichtpunkte auf Map (W5) | Ambient Social Layer auf Level-Map. | D30, Viral UA | 3 | F009, F034 |
| F047 | NPC Interface-Brecher (W4) | Implementierung von D5 (NPCs kommentieren im UI). | Viral UA, D30 | 4 | F007, F008 |
| F048 | Spieler-Lichtpunkte auf Map (W5) | Ambient Social Layer auf Level-Map. | D30, Viral UA | 3 | F009, F034 |

**Phase B Budget-Check:**
*   **Entwicklerwochen (geschätzt):** 18 Features * (3-8 Wochen/Feature) = ~70-120 Wochen.
*   **Kosten (geschätzt):** 70 Wochen * 40h * 85€ = 238.000 €. 120 Wochen * 40h * 120€ = 576.000 €.
*   **Budget (generisch):** 230.000 EUR (aus SkillSense Cost Calculation, hier als Platzhalter).
*   **Status:** **im_budget** (wenn man von einem sehr effizienten Team und niedrigeren Schätzungen ausgeht, aber die SkillSense-Zahl ist ein Platzhalter).

### Backlog (Geschätzte 5 Features)

| ID | Feature | Geplante Version | Begruendung |
|---|---|---|---|
| F049 | PvP-Modus (Asynchron) | v1.3 | Ermöglicht asynchrone Duelle gegen andere Spieler-Ghosts. |
| F050 | UGC (User Generated Content) | v1.4 | Spieler können eigene Level-Layouts erstellen und teilen. |
| F051 | AR-Integration (ARKit/ARCore) | v2.0 | Spielfeld in Augmented Reality im Raum platzieren. |
| F052 | Voice Chat (Gilden) | v1.3 | Sprachkommunikation innerhalb von Gilden. |
| F053 | Wearable Integration (Apple Watch) | v2.1 | Mini-Game oder Progress-Tracking auf Smartwatches. |

---

## 5. Abhaengigkeits-Graph & Kritischer Pfad

**HINWEIS:** Die folgenden Abhängigkeiten und der kritische Pfad sind generische Beispiele für ein Match-3-Spiel und basieren **NICHT** auf spezifischen Feature-Reports für EchoMatch. Eine dedizierte Analyse für EchoMatch ist erforderlich.

### Build-Reihenfolge (Logische Priorisierung)

1.  **Core Gameplay Foundation:** F001 (Core Match-3), F004 (Score), F005 (Level-Ziele), F019 (Falscher Zug-Feedback), F020 (Match-Feedback), F021 (Special-Stein-Entstehung), F027 (Haptic Language System).
2.  **Onboarding & First Experience:** F006 (Onboarding-Match), F007 (Narrative Hook), F017 (App-Start-Sequenz), F030 (Pre-Primer ATT).
3.  **Basic Progression & Hub:** F002 (Level-Progression Kap. 1), F009 (Level-Map Kap. 1), F008 (Home Hub Basis), F010 (Daily Quest).
4.  **Monetarisierung MVP:** F012 (Währungs-System), F003 (Basis-Booster), F011 (Basis-Shop).
5.  **Compliance & Tech Foundation:** F013 (Settings), F014 (DSGVO/ATT Consent), F024 (Age-Gate), F025 (Impressum/Datenschutz), F015 (Crash-Reporting), F016 (Analytics Basic).
6.  **UX/UI Polish MVP:** F018 (Level-Complete-Feedback), F023 (Post-Session Share-Card), F022 (Kontextuelle Navigation Basis), F026 (Reduced Motion), F028 (Chrono-Responsive UI), F029 (Sound-Personalisierung).

### Kritischer Pfad mit Dauer in Wochen (Geschätzt für Phase A)

**Gesamtdauer (geschätzt):** 18 Wochen

*   **Woche 1-4: Core Gameplay Foundation (F001, F004, F005, F019, F020, F021, F027)**
    *   F001 (Core Match-3) - 4 Wochen
    *   F004 (Score) - 1 Woche (parallel zu F001)
    *   F005 (Level-Ziele) - 1 Woche (parallel zu F001)
    *   F019 (Falscher Zug-Feedback) - 1 Woche (parallel zu F001)
    *   F020 (Match-Feedback) - 1 Woche (parallel zu F001)
    *   F021 (Special-Stein-Entstehung) - 2 Wochen (parallel zu F001)
    *   F027 (Haptic Language System) - 1 Woche (parallel zu F001)
    *   **Kritischer Pfad: F001 (4 Wochen)**
*   **Woche 5-7: Onboarding & First Experience (F006, F007, F017, F030)**
    *   F006 (Onboarding-Match) - 2 Wochen (abhängig von F001)
    *   F007 (Narrative Hook) - 2 Wochen (abhängig von F006)
    *   F017 (App-Start-Sequenz) - 1 Woche (parallel zu F006)
    *   F030 (Pre-Primer ATT) - 1 Woche (parallel zu F006)
    *   **Kritischer Pfad: F006 -> F007 (4 Wochen)**
*   **Woche 8-10: Basic Progression & Hub (F002, F009, F008, F010)**
    *   F002 (Level-Progression Kap. 1) - 3 Wochen (abhängig von F001)
    *   F009 (Level-Map Kap. 1) - 2 Wochen (parallel zu F002)
    *   F008 (Home Hub Basis) - 2 Wochen (parallel zu F002)
    *   F010 (Daily Quest) - 2 Wochen (parallel zu F008)
    *   **Kritischer Pfad: F002 (3 Wochen)**
*   **Woche 11-13: Monetarisierung MVP (F012, F003, F011)**
    *   F012 (Währungs-System) - 1 Woche (abhängig von F001)
    *   F003 (Basis-Booster) - 2 Wochen (abhängig von F012)
    *   F011 (Basis-Shop) - 3 Wochen (abhängig von F012, F003)
    *   **Kritischer Pfad: F012 -> F003 -> F011 (6 Wochen)**
*   **Woche 14-15: Compliance & Tech Foundation (F013, F014, F024, F025, F015, F016)**
    *   F014 (DSGVO/ATT Consent) - 2 Wochen
    *   F024 (Age-Gate) - 1 Woche (parallel zu F014)
    *   F025 (Impressum/Datenschutz) - 1 Woche (parallel zu F014)
    *   F013 (Settings) - 1 Woche (parallel zu F014)
    *   F015 (Crash-Reporting) - 1 Woche (parallel zu F014)
    *   F016 (Analytics Basic) - 1 Woche (parallel zu F014)
    *   **Kritischer Pfad: F014 (2 Wochen)**
*   **Woche 16-18: UX/UI Polish MVP (F018, F023, F022, F026, F028, F029)**
    *   F018 (Level-Complete-Feedback) - 2 Wochen (abhängig von F004)
    *   F023 (Post-Session Share-Card) - 2 Wochen (abhängig von F018)
    *   F022 (Kontextuelle Navigation Basis) - 3 Wochen (abhängig von F008)
    *   F026 (Reduced Motion) - 1 Woche (parallel zu F018)
    *   F028 (Chrono-Responsive UI) - 1 Woche (parallel zu F008)
    *   F029 (Sound-Personalisierung) - 1 Woche (parallel zu F001)
    *   **Kritischer Pfad: F022 (3 Wochen)**

**Gesamtdauer des kritischen Pfades (Summe der längsten Pfade in jeder Phase):** 4 + 4 + 3 + 6 + 2 + 3 = **22 Wochen** (Anpassung der initialen Schätzung, da Abhängigkeiten kumulieren).

### Parallelisierbare Feature-Gruppen

*   **Phase A – Tag-1-Parallel-Start (Keine Abhaengigkeiten):** F001 (Core Match-3), F014 (DSGVO/ATT Consent), F017 (App-Start-Sequenz).
*   **Phase A – F001-Abhaengige Parallelgruppe:** F004 (Score), F005 (Level-Ziele), F019 (Falscher Zug-Feedback), F020 (Match-Feedback), F021 (Special-Stein-Entstehung), F027 (Haptic Language System).
*   **Phase A – F006-Abhaengige Parallelgruppe:** F007 (Narrative Hook), F030 (Pre-Primer ATT).
*   **Phase A – F002-Abhaengige Parallelgruppe:** F009 (Level-Map), F008 (Home Hub), F010 (Daily Quest).
*   **Phase A – F012-Abhaengige Parallelgruppe:** F003 (Basis-Booster), F011 (Basis-Shop).
*   **Phase A – F014-Abhaengige Parallelgruppe:** F024 (Age-Gate), F025 (Impressum/Datenschutz), F013 (Settings), F015 (Crash-Reporting), F016 (Analytics Basic).
*   **Phase A – F008-Abhaengige Parallelgruppe:** F022 (Kontextuelle Navigation), F028 (Chrono-Responsive UI).
*   **Phase A – F018-Abhaengige Parallelgruppe:** F023 (Post-Session Share-Card), F026 (Reduced Motion).

---

## 6. Screen-Architektur (VERBINDLICH)

### Screen-Uebersicht (19 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / App Init | Overlay | App-Start, Client-Side Engine laden, Locale erkennen | F017, W1 | Normal, Slow-Connection, Engine-Fehler |
| S002 | Consent / DSGVO & ATT | Modal | DSGVO-konformer Consent vor Analytics-Initialisierung | F014, F030 | Normal, Einstellungen-Expanded, ATT-Prompt-Visible |
| S003 | Onboarding Match | Hauptscreen | Erstes Match, implizites Spielstil-Tracking (D3), kein Tutorial | F006, W2, MI-01, MI-06 | Leer, Stein-Drag, Match-Erfolg, Inaktivität-Hint |
| S004 | Narrative Hook Sequenz | Subscreen | Emotionale Story-Einführung (D3), persona-basiert | F007, MI-14 | Frame-1, Frame-N, Letzter-Frame-Pause, Skip-Visible |
| S005 | Home Hub | Hauptscreen | Tägliches Re-Entry, Daily Quest, Battle-Pass-Teaser | F008, F010, D2, D5, MI-09, MI-11, MI-12 | Normal, Daily-Quest-Active, Social-Nudge-Active, Battle-Pass-Teaser-Visible |
| S006 | Puzzle / Match-3 Spielfeld | Hauptscreen | Kern-Gameplay, Flow-Erlebnis (D1), Dark-Field Luminescence | F001, F003, F005, D1, MI-02, MI-03, MI-05, MI-06, MI-10, MI-13 | Leer, Stein-Drag, Match-Erfolg, Special-Stein-Entstehung, Inaktivität-Hint, Letzte-Züge-Warnung |
| S007 | Level-Ergebnis / Post-Session | Subscreen | Level-Abschluss-Feedback, Share-Card (D4), Retry/Rewarded-Ad | F018, F023, D4 | Sieg-State, Niederlage-State, Share-Card-Visible, Rewarded-Ad-Offer |
| S008 | Level-Map / Progression | Hauptscreen | Visuelle Level-Progression, Ambient Social Layer (D2) | F002, F009, D2, D5, W5 | Normal, Level-Gesperrt, Level-Offen, Level-Abgeschlossen, Freund-Avatar-Visible, KI-Quest-Markierung |
| S009 | Story / Narrative Hub | Hauptscreen | Kapitel-Übersicht, Story-Fortschritt, NPC-Interaktion (D5) | F007, D5 | Normal, Kapitel-Gesperrt, Kapitel-Offen, Kapitel-Abgeschlossen, NPC-Kommentar-Visible |
| S010 | Social Hub | Hauptscreen | Freundesliste, Challenges, Leaderboard (sekundär) | F034, W5 | Normal, Freund-Online, Challenge-Pending, Leaderboard-Visible, Empty-State-No-Friends |
| S011 | Shop / Monetarisierungs-Hub | Hauptscreen | IAP-Angebote, Battle-Pass-Upgrade, Währungskauf (A4) | F011, F012, F033, A4, MI-15 | Normal, Angebot-Highlight, Battle-Pass-Teaser, Offline-Gesperrt |
| S012 | Battle-Pass Screen | Subscreen | Saisonale Progression, Rewards (A4) | F033, A4, MI-15 | Normal, Premium-Tier-Active, Saison-Abgelaufen, Reward-Claimed |
| S013 | Tägliche Quests Screen | Subscreen | Übersicht der Daily Quests, Fortschritt | F010 | Normal, Quest-Active, Quest-Completed, Quest-Claimed |
| S014 | Push Notification Opt-In | Modal | Erklärung und Opt-In für Push Notifications | F041 | Normal, Opt-In-Accepted, Opt-In-Denied |
| S015 | Share Sheet / Social Share | Modal | Teilen von Level-Ergebnissen (D4) | F023 | Normal, Link-Kopiert, Teilen-Erfolg |
| S016 | Rewarded Ad Interstitial | Overlay | Vollbild-Werbung für In-Game-Belohnung | F003 | Ad-Lädt, Ad-Läuft, Ad-Abgeschlossen, Ad-Fehler |
| S017 | Settings / Profil | Hauptscreen | Sound, Haptik, Account, Legal-Links | F013, F025 | Normal, Account-Logged-In, Account-Guest, Reduced-Motion-Active |
| S018 | Onboarding-Overlay (First Use) | Overlay | Erstkontakt-Orientierung nach Invite-Code-Einlösung, zeigt die zwei Einstiegswege | F006, F008 | Normal, Scanner-gewählt, Advisor-gewählt |
| S019 | Beta Feedback / NPS | Modal | Qualitatives Nutzer-Feedback, NPS-Abfrage | F023 | Normal, Feedback-Gesendet, NPS-Abfrage-Visible |

### Hierarchie
*   **Hauptscreens:** S003 (Onboarding Match), S005 (Home Hub), S006 (Puzzle / Match-3 Spielfeld), S008 (Level-Map), S009 (Story / Narrative Hub), S010 (Social Hub), S011 (Shop / Monetarisierungs-Hub), S017 (Settings / Profil)
*   **Subscreens:** S004 (Narrative Hook Sequenz), S007 (Level-Ergebnis / Post-Session), S012 (Battle-Pass Screen), S013 (Tägliche Quests Screen)
*   **Modals:** S002 (Consent / DSGVO & ATT), S014 (Push Notification Opt-In), S015 (Share Sheet / Social Share), S019 (Beta Feedback / NPS)
*   **Overlays:** S001 (Splash / App Init), S016 (Rewarded Ad Interstitial), S018 (Onboarding-Overlay)

### Navigation
**VERBINDLICH:** Keine feste Bottom-Navigation-Bar mit 5 Icons. Navigation ist kontextuell (D2).
*   **Home Hub (S005):** Primärer Einstiegspunkt. Kontextuelle Action-Surfaces für Daily Quest, Battle-Pass-Teaser, Story-Fortschritt.
*   **Radial-Menü (Swipe-Up-Geste von S005):** On-demand-Zugriff auf Hauptbereiche (Spielen, Map, Story, Social, Profil). Schließt sich nach Auswahl.
*   **Situative Action-Surfaces:** Nach Level-Verlust (S007) primär "Nochmal" + "Booster holen". Nach Level-Sieg (S007) primär "Map" + "Story weiter" + "Teilen".
*   **Ambient Social Layer (D2, W5):** Freunde-Avatare als Lichtpunkte auf der Level-Map (S008) und im Home Hub (S005) Header. Antippen öffnet Kontext-Overlay.
*   **Back-Navigation:** Standard-System-Back-Button (Android) oder Swipe-Gesture (iOS) für Modals/Subscreens.

### User Flows (7 Flows)

**HINWEIS:** Die folgenden User Flows sind an die Screen-Architektur von EchoMatch angepasst. Die Tap-Counts und Zeitbudgets sind generische Schätzungen für ein Mobile Game.

#### Flow 1: Onboarding (Erst-Start) — App oeffnen bis erster Core Loop
*   **Screens:** S001 → S002 → S003 → S004 → S005 → S006 → S007
*   **Taps bis Core Loop:** 3 (Consent bestätigen auf S002 → Onboarding Match starten auf S003 → Level starten auf S005)
*   **Zeitbudget:** ~90 Sekunden bis erstes Ergebnis sichtbar (inkl. Onboarding Match und Narrative Hook)
*   **Beschreibung:** App initialisiert (S001) → Consent-Modal (S002) → Onboarding Match (S003) mit implizitem Spielstil-Tracking → Narrative Hook (S004) persona-basiert → Home Hub (S005) → Start Level (S006) → Level-Ergebnis (S007).
*   **Fallback Consent-Ablehnung:** S002 setzt nur notwendige Cookies, App funktioniert vollständig weiter (kein Analytics-Block).
*   **Fallback Engine-Fehler auf S001:** Fehler-State zeigt Retry-Button, nach 3 Fehlversuchen Weiterleitung zu S017 (Settings/Profil) mit Kontakt-Hinweis.

#### Flow 2: Core Loop (wiederkehrend) — Direkteinstieg bis Level-Ergebnis
*   **Screens:** S001 → S005 → S006 → S007
*   **Taps bis Ergebnis:** 2 (Level starten auf S005 → Level abschließen auf S006)
*   **Session-Ziel:** 5–10 Minuten für vollständigen Scan-Zyklus, Gesamtsession 6–10 Minuten inkl. S007-Review
*   **Beschreibung:** Wiederkehrender Nutzer öffnet App, Splash kurz (S001) → Home Hub (S005) mit Daily Quest oder letztem Level → Start Level (S006) → Level-Ergebnis (S007) mit Goldener Ausatmung (W3).
*   **Fallback Analyse-Timeout >50 Sek. (S006):** S006 zeigt Timeout-Warnung mit Abbrechen-Option und Retry.
*   **Fallback Analyse-Fehler (S006):** Fehler-Abbruch-State auf S006, Weiterleitung zurück zu S005 mit Fehlermeldung.
*   **Fallback Offline (S006):** S006 sperrt Level-Start-Button, zeigt Offline-Hinweis — kein Silent Fail.

#### Flow 3: Erster Kauf — Shop-Besuch & IAP
*   **Screens:** S005 → S011 → (Nativer Payment-Dialog) → S011 (Kauf bestätigt) → S005
*   **Taps bis Kauf:** 3 (Shop-CTA auf S005 → IAP-Angebot antippen auf S011 → Kauf bestätigen auf S011)
*   **Zeitbudget:** 30–60 Sekunden
*   **Beschreibung:** Nutzer sieht Shop-CTA auf Home Hub (S005) → Shop (S011) öffnet sich als Katalog (A4) → IAP-Angebot auswählen → Nativer Payment-Dialog → Kaufbestätigung in S011 mit MI-14 (Kauf abgeschlossen) → Rückkehr zu S005.
*   **Fallback Sendefehler:** Fehler-State auf S011 mit Retry-Button, Eingabe bleibt erhalten.
*   **Fallback Offline:** S011 sperrt Kauf-Button mit Offline-Hinweis.

#### Flow 4: Social Challenge — Ergebnis teilen
*   **Screens:** S007 → S015
*   **Taps bis Teilen:** 2 (Share-Button auf S007 → Teilen-Aktion in S015)
*   **Zeitbudget:** 15–20 Sekunden
*   **Beschreibung:** Nutzer sieht Level-Ergebnis (S007) mit Teilen-CTA → Share-Modal öffnet sich (S015) mit vorgefertigtem Text und Share-Card (D4) → Nutzer wählt Link kopieren oder direktes Teilen → Erfolgs-Feedback.
*   **Fallback Link-kopieren fehlgeschlagen:** Clipboard-API nicht verfügbar, Link wird als selektierbarer Text angezeigt.
*   **Fallback Offline:** S015 zeigt nur Link-kopieren-Option, native Share-API wird nicht aufgerufen.

#### Flow 5: Battle-Pass — Fortschritt & Upgrade
*   **Screens:** S005 → S011 → S012 → (Nativer Payment-Dialog) → S012 (Premium-State) → S005
*   **Taps bis Upgrade:** 3 (Battle-Pass-Teaser auf S005 → Battle-Pass-Karte antippen auf S011 → „Jetzt kaufen"-Button auf S012)
*   **Zeitbudget:** 45–90 Sekunden
*   **Beschreibung:** Nutzer sieht Battle-Pass-Teaser auf Home Hub (S005) → Shop (S011) mit Battle-Pass-Angebot → Battle-Pass Screen (S012) mit Tier-Übersicht → Upgrade auf Premium → Nativer Payment-Dialog → S012 zeigt Premium-State → Rückkehr zu S005.
*   **Fallback Payment-Fehler:** Fehler-State auf S012 mit Retry.
*   **Fallback Offline:** S012 sperrt Kauf-Button mit Offline-Hinweis.

#### Flow 6: Rewarded Ad — Extra-Leben erhalten
*   **Screens:** S006 (Level-Verloren) → S007 (Verloren-Rewarded-Ad-Angebot) → S016 (Ad-Overlay) → S006 (Extra-Leben)
*   **Taps bis Extra-Leben:** 2 (Rewarded-Ad-CTA auf S007 → Ad starten auf S016)
*   **Zeitbudget:** 30–60 Sekunden (Ad-Dauer + Ladezeit)
*   **Beschreibung:** Nutzer verliert Level (S006) → Level-Ergebnis (S007) zeigt Rewarded-Ad-Angebot → Ad-Overlay (S016) lädt und spielt Ad → Nach Ad-Abschluss: Extra-Leben wird gewährt, Rückkehr zu S006.
*   **Fallback Ad-Fehler:** S016 zeigt Ad-Fehler-Fallback-Illustration, Retry-Option.
*   **Fallback Ad übersprungen:** S016 zeigt „Kein Reward erhalten"-Feedback, Rückkehr zu S007.

#### Flow 7: Datenschutz & Transparenz — DSGVO-Detail-Flow
*   **Screens:** S002 → S017 (Settings) → S025 (Impressum/Datenschutz)
*   **Taps bis vollständiger Information:** 2 (Einstellungen-Link auf S002 → Datenschutz-Link auf S017)
*   **Zeitbudget:** Nutzer-gesteuert, kein Zeitlimit
*   **Beschreibung:** Consent-Modal erscheint (S002) → Nutzer wählt „Einstellungen" → Settings (S017) → Link zu Impressum/Datenschutz (S025).
*   **Fallback Offline auf S025:** S025 lädt statische HTML-Seite aus Cache.

### Edge Cases (8 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| Offline bei App-Start | S001, S005, S006 | S001 Engine-Init lädt aus lokalem Cache. S005 zeigt Offline-State-Banner. S006 Gameplay funktioniert vollständig (client-side). Monetarisierungs-Features (Shop, Rewarded Ad) sind gesperrt mit Offline-Hinweis. |
| KI-Level-Generierungs-Fehler oder Timeout | S006, S007 | S006 wechselt in Fehler-Abbruch-State mit erklärendem Fehlertext und zwei Optionen: Erneut versuchen (primär) und Anderes Level wählen (sekundär). Kein leerer Ergebnis-Screen S007. |
| IAP-Kauf fehlgeschlagen | S011 | S011 zeigt IAP-Fehler-Dialog (A088) mit spezifischer Fehlermeldung (z.B. „Zahlung abgelehnt") und Retry-Option. Kein automatischer Retry. |
| Upload-Datei mit falschem Format (falls relevant) | S006 | N/A für EchoMatch (kein File Upload im Core Loop). |
| Consent komplett abgelehnt — nur notwendige Cookies | S002, S016 | App funktioniert vollständig – da Core-Funktionalität client-side und consent-unabhängig. Analytics werden nicht initialisiert. Personalisierte Ads (S016) werden nicht angezeigt, stattdessen Ad-Fehler-Fallback. |
| Level-Ergebnis erkennt keine Skills (falls relevant) | S007 | N/A für EchoMatch (keine Skill-Erkennung). |
| Battle-Pass Saison abgelaufen | S012 | S012 wechselt in `Saison-Abgelaufen`-State (A_SeasonEndIllustration) mit Teaser für nächste Saison. Kauf-Button für aktuellen Battle-Pass ist deaktiviert. |
| Engine-Fehler beim App-Start (Splash-Screen) | S001, S017 | S001 wechselt in Engine-Fehler-State. Erklärende Fehlermeldung mit zwei Optionen: App neu laden (Tap) und Support kontaktieren (Link zu S017). |

### Phase-B Screens mit Platzhaltern

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S020 | Gilden / Team-Hub | Verwaltung von Gilden, Team-Quests | Coming-Soon-Badge (A055) auf S010 Social Hub |
| S021 | Event-Hub | Übersicht über aktuelle und kommende Events | Coming-Soon-Badge (A055) auf S005 Home Hub |
| S022 | Spieler-Profil (Erweitert) | Detaillierte Statistiken, Erfolge, Avatar-Anpassung | Basis-Profil in S017 (Settings) |
| S023 | UGC-Level-Editor | Erstellung und Teilen eigener Level-Layouts | Nicht sichtbar |
| S024 | PvP-Challenge-Setup | Konfiguration und Start von asynchronen PvP-Duellen | Challenge-Card (A038) auf S010 Social Hub |

---

## 7. Asset-Liste (VERBINDLICH)

### Vollstaendige Asset-Tabelle (Auszug, da 107 Assets zu lang für Roadbook)

| ID | Asset | Beschreibung | Screen(s) | Stat/Dyn | Quelle | Format | Priorität |
|---|---|---|---|---|---|---|---|
| **APP-BRANDING** | | | | | | | |
| A001 | App-Icon | Haupt-App-Icon | S001, Alle | statisch | Custom Design | PNG | 🔴 Launch-kritisch |
| A002 | Splash-Screen-Logo | EchoMatch-Volllogo | S001 | statisch | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A062 | Store-Feature-Grafik | Feature-Grafik für App Store Listing | Alle | statisch | Custom Design | PNG | 🔴 Launch-kritisch |
| A063 | Notification-Icon | Kleines monochromes Icon | S014 | statisch | Custom Design | PNG | 🔴 Launch-kritisch |
| **GAMEPLAY-ASSETS** | | | | | | | |
| A009 | Match-3-Spielstein-Sprite-Set | Alle Match-3-Spielsteine | S003, S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 Launch-kritisch |
| A010 | Match-3-Spielfeld-Hintergrund | Vollbild-Hintergrund | S003, S006 | statisch | AI-generiert | PNG | 🔴 Launch-kritisch |
| A011 | Match-3-Spezialstein-Sprites | Sonder- und Booster-Steine | S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 Launch-kritisch |
| A013 | Spielfeld-Grid-Rahmen | Visueller Rahmen und Zellen-Design | S003, S006 | statisch | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A065 | Spielfeld-Ziel-Indikator-Icons | Icon-Set für Level-Zieltypen | S006, S008 | statisch | Free/Open-Source | SVG + PNG | 🔴 Launch-kritisch |
| A066 | Hindernisse und Spezialzellen-Sprites | Sprite-Set für Level-Hindernisse | S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 Launch-kritisch |
| **UI-ELEMENTE** | | | | | | | |
| A004 | Ladebalken / Loading-Indicator | Visueller Fortschrittsbalken | S001, S006, S011, S012 | animiert | Lottie | Lottie JSON | 🔴 Launch-kritisch |
| A014 | Züge-Anzeige / Move-Counter | Visuelles UI-Element | S006 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A015 | Punkte-/Score-Anzeige HUD | Score-Counter im HUD | S006 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A016 | Booster-Icons im Spielfeld | Icon-Set für Booster | S006 | animiert | AI-generiert + Custom | PNG + Lottie | 🔴 Launch-kritisch |
| A020 | Reward-Item-Icons | Icon-Set für Reward-Items | S007, S012, S013, S011 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A022 | Level-Knoten-Icons | Icon-Sprites für Level-Knoten | S008 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A029 | Daily-Quest-Card-Design | Visuell gestaltete Quest-Karte | S005, S013 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A030 | Quest-Icon-Set | Thematische Icons für Quest-Typen | S013, S005 | statisch | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A031 | Battle-Pass-Tier-Reward-Visualisierung | Horizontale/vertikale Tier-Leiste | S012 | animiert | Custom Design | SVG + Lottie | 🔴 Launch-kritisch |
| A033 | Saison-Timer-Visual | Visueller Countdown-Timer | S012, S013 | animiert | Lottie | Lottie JSON | 🟡 Nice-to-have |
| A034 | Shop-Angebots-Karten | Visuell gestaltete Angebotskarten | S011 | statisch | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A035 | Foot-in-Door-Angebot-Highlight | Spezielles visuelles Highlight | S011 | animiert | Custom Design + Lottie | Lottie JSON + SVG | 🔴 Launch-kritisch |
| A036 | Währungs-Icons | Icons für In-Game-Währungen | S006, S007, S011, S012, S013 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A046 | Tab-Bar-Icons | Icon-Set für Tab-Bar-Einträge | S005, S008, S009, S010, S011 | statisch | Free/Open-Source | SVG + PNG | 🔴 Launch-kritisch |
| A048 | Kaltstart-Personalisierungs-Auswahlkarten | Visuell gestaltete Auswahlkarten | S020 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A049 | Onboarding-Hint-Pfeile | Animierte Pfeile, Tap-Animationen | S003 | animiert | Lottie + Custom | Lottie JSON + SVG | 🔴 Launch-kritisch |
| **ILLUSTRATIONEN** | | | | | | | |
| A003 | Splash-Screen-Hintergrund | Vollbild-Hintergrundbild | S001 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A007 | ATT-Prompt-Visual | Pre-Permission-Erklärungsbild | S002 | statisch | AI-generiert + Custom | SVG + PNG | 🔴 Launch-kritisch |
| A018 | Level-Verloren-Illustration | Empathische Illustration | S007 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A021 | Level-Map-Pfad-Grafik | Visueller Fortschrittspfad | S008 | statisch | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A023 | Level-Map-Hintergrund-Welten | Thematische Hintergrundillustrationen | S008 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A024 | Narrative-Hook-Sequenz-Artwork | Vollbild-Story-Artwork | S004 | animiert | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A025 | Story-Charakter-Portraits | Portrait-Illustrationen | S004, S009 | statisch | Custom Design | PNG | 🔴 Launch-kritisch |
| A026 | Story-Kapitel-Cover-Illustrationen | Cover-Artwork pro Kapitel | S009 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A027 | Story-Scene-Hintergründe | Hintergrundillustrationen | S004, S009 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A028 | Home Hub Hero-Banner | Dynamisches Hero-Banner-Artwork | S005 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A032 | Battle-Pass-Saison-Banner | Thematisches Key-Art | S012, S005 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| **ANIMATIONEN & EFFEKTE** | | | | | | | |
| A012 | Match-Animation-Effekte | Partikel- und Burst-Animationen | S003, S006 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A017 | Level-Gewonnen-Animation | Vollbild-Gewinn-Animation | S007 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A019 | Stern-Bewertungs-Animation | 1-3 Stern-Vergabe-Animation | S007 | animiert | Lottie | Lottie JSON | 🔴 Launch-kritisch |
| A050 | KI-Level-Lade-Platzhalter-Animation | Thematische Animations-Szene | S006, S008 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A060 | Reward-Freischalten-Animation | Animiertes Freischalten von Rewards | S012, S013, S007 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |

### Beschaffungswege pro Asset (Zusammenfassung)
*   **Custom Design (Freelancer):** 41% der Assets (z.B. App-Icon, Splash-Logo, Charakter-Portraits, komplexe UI-Elemente, Kern-Animationen).
*   **AI-generiert + Custom Finish:** 26% der Assets (z.B. Spielsteine, Spielfeld-Hintergründe, Illustrationen, Story-Artworks). AI als Basis, dann manuelle Nachbearbeitung für Stil-Konsistenz.
*   **Free/Open-Source:** 18% der Assets (z.B. Basis-Icons, Placeholder-Avatare, einfache Illustrationen).
*   **Lottie (Free/Premium):** 15% der Assets (z.B. Ladebalken, einfache UI-Animationen, Stern-Bewertungen).

### Format-Anforderungen pro Plattform
*   **Sprites (Spielsteine, Charaktere, Hindernisse):** PNG Sprite Sheets (via TexturePacker) für Unity. Auflösung @2x und @3x.
*   **Hintergründe (Spielfeld, Splash, Map):** PNG. Master-Auflösung 3840x2160px (für 4K-Displays), exportiert @2x und @3x. Layer-Export für Parallax-Effekte.
*   **Icons (UI, Booster, Rewards):** SVG für UI-Icons (für Skalierbarkeit), PNG @2x/@3x für In-Game-Icons.
*   **Animationen (UI, Loading, Feedback):** Lottie JSON (für UI-Animationen). Statisches PNG @2x/@3x als Fallback, wenn Lottie >500KB oder Performance-Probleme.
*   **App-Icons (iOS):** PNG in allen 18 benötigten Größen (1024x1024px für Store, 180x180px für Home Screen etc.). Kein Alpha-Kanal, keine Gradienten über die gesamte Fläche.
*   **App-Icons (Android):** Adaptive Icon (Foreground + Background als separate Layer im XML definiert). Notification-Icon monochrom (weiß auf transparent).
*   **Store-Screenshots:** PNG (kein JPEG) in 1290x2796px (iOS) und 1080x1920px (Android).
*   **Audio:** SFX als WAV (Master) + OGG/AAC (komprimiert). Musik als OGG/AAC.
*   **Fonts:** TTF/OTF Master → Unity TextMesh Pro Font Asset. Lizenzprüfung für Mobile-Embedding.

### Plattform-Varianten Anzahl
*   **Gesamt Assets:** 107
*   **Plattform-Varianten gesamt (inkl. Auflösungen, Dark Mode):** ca. 164 (geschätzt)

### Dark-Mode-Varianten
*   **Dark-Mode-Varianten nötig:** 65 Assets (für UI-Elemente, Texte, Icons, die sich an den System-Dark-Mode anpassen müssen).
*   **Ausnahmen:** Gameplay-Hintergründe (A010) und Spielfeld (S006) sind per Design immer dunkel (`gameplay_bg`). Shop (S011) ist bewusst ohne Dark Mode (A034, A035).

---

## 8. KI-Produktions-Warnungen (VERBINDLICH — KRITISCH)

### Warnungen aus dem Visual Audit

| # | Screen | Stelle | Was KI falsch macht | Was stattdessen | Prompt-Anweisung fuer Produktionslinie |
|---|---|---|---|---|---|
| W01 | S001 Splash | Vollbild-Atmosphären-Artwork hinter dem Logo | Farbverlauf in Brand-Primärfarbe oder `#1A1A2E` Vollton | A003 Splash-Screen-Hintergrund | **Sprite/Image-View verwenden.** `Image(asset: "splash_bg")` als Fullscreen-Layer unter Logo platzieren. KEIN `Color.fill()` oder Gradient-Code als Ersatz akzeptieren. |
| W02 | S002 ATT Consent | Erklärendes Bild BEVOR der iOS-System-ATT-Dialog erscheint | Text-only Pre-Permission-Screen mit App-Beschreibung oder gar keinen Pre-Screen | A007 ATT-Prompt-Visual | **Pre-Permission-Screen als eigene View implementieren** mit `Image(asset: "att_explanation_visual")` als zentralem Element. Der System-Dialog wird erst nach Tap auf Erklärungsscreen getriggert. KEIN direktes `requestTrackingAuthorization()` ohne vorherigen Visual-Screen. |
| W03 | S002 DSGVO | Visuelle Auflockerung neben Rechtstext | Reinen UITextView/ScrollView mit Rechtstext, kein visuelles Element | A006 DSGVO-Consent-Illustration | **Illustration als festes Layout-Element** in der oberen Hälfte des Consent-Modals platzieren (`Image(asset: "consent_illustration")`). ScrollView mit Rechtstext NUR im unteren Bereich. Illustration darf NICHT weggelassen werden wenn Rechtstext lang ist. |
| W04 | S003 Spielsteine | Thematisch gestaltete Spielstein-Sprites mit Spielwelt-Ästhetik | Farbige `RoundedRectangle`-Views oder `Circle`-Shapes mit Hex-Farben als Spielstein-Ersatz | A009 Match-3-Spielstein-Sprite-Set | **Sprite Sheet laden und Einzelframes per Tile-Index rendern.** Jeder Spielstein-Typ bekommt eigenen Sprite-Frame aus `gem_sprites.atlas`. KEIN Shape-Rendering als Spielstein. Tracking-Algorithmus validiert Spielstil über Interaktions-Timing, nicht über Spielstein-Typ — aber visueller Kontext muss stimmen. |
| W05 | S003 Tutorial-Hint | Animierter Finger-Tap-Pfeil der ersten Spielzug zeigt | Statischen Text-Overlay wie „Tippe hier um zu beginnen" oder `Label`-Tooltip | A049 Onboarding-Hint-Pfeile und Tutorial-Overlays | **Lottie-Animation oder Frame-Animiertes Asset verwenden** (`hint_arrow_tap.json`). KEIN `UILabel` oder `Text()`-Overlay als Tutorial-Hinweis im Spielfeld. Animation muss auf den ersten tappbaren Stein zeigen, nicht auf generische Screen-Position. |
| W06 | S004 Narrative Hook | Vollbild-Story-Artwork oder animierte Sequenz als emotionaler erster Eindruck der Spielwelt | Text-Dialog-Box auf schwarzem oder einfarbigem Hintergrund, eventuell mit generischem Hintergrundbild | A024 Narrative-Hook-Sequenz-Artwork | **Dedicated Story-Artwork-Asset in Asset-Discovery-Liste aufnehmen** (vorgeschlagene ID: A024). Implementierung als `Image(asset: "narrative_hook_bg")` Fullscreen mit Text-Overlay. KEIN schwarzer Hintergrund mit zentriertem Text als Narrative-Hook. |
| W07 | S005 Hero-Banner | Tageszeit-abhängig oder Event-abhängig wechselndes Artwork das täglichen Re-Entry-Anreiz visualisiert | Statische Farb-Card oder Text-Banner mit „Willkommen zurück, [Name]" | A028 Home Hub Hero-Banner | **3 Banner-Varianten in Asset-Bundle liefern** (`hero_morning.png`, `hero_evening.png`, `hero_event.png`). Tageszeit-Logik wählt Asset per lokaler Uhr. KEIN programmatisch generiertes Text-Banner als Hero-Element akzeptieren. |
| W08 | S006 Spezialsteine | Visuell sofort erkennbare Spezialsteine die sich klar von normalen Steinen unterscheiden (Bombe sieht aus wie Bombe) | Gleiche `RoundedRectangle`-Shapes wie normale Steine, nur mit anderer Farbe oder Outline | A011 Match-3-Spezialstein-Sprites | **Separate Sprite-Frames für jeden Spezialstein-Typ** aus `special_gems.atlas` rendern. Bombe = Bomben-Sprite, Blitz = Blitz-Sprite. KEIN Reuse des normalen Stein-Sprites mit veränderter `tintColor` oder Border. |
| W09 | S006 Hindernisse | Hinderniszellen die durch ihr Aussehen ihren Typ und Abbau-Zustand kommunizieren (Eis-Crack-States) | Farbige Zellen-Backgrounds (`blue` = Eis, `gray` = Stein) ohne Multi-State-Design | A066 Hindernisse und Spezialzellen-Sprites | **Sprite-Set mit je 3 Abbau-States pro Hindernis-Typ implementieren** (`ice_state_1/2/3.png`, `stone_state_1/2/3.png`). State-Wechsel über Sprite-Frame-Swap, NICHT über `opacity`-Änderung oder Farb-Overlay. |
| W10 | S007 Verloren-State | Empathische Charakter-Illustration die Niederlage emotional abfedert und Retry-Motivation aufbaut | Roter Text „Level verloren" oder System-Alert-Style-Dialog, evtl. mit rotem X-Icon | A018 Level-Verloren-Illustration | **Illustration als Fullscreen-Hintergrund oder zentrales Element** des Verloren-Screens (`level_lost_illustration.png`). Retry-Button wird ÜBER die Illustration gelegt. KEIN Alert-Dialog oder System-Modal als Verloren-Screen. |
| W11 | S011 Foot-in-Door-Angebot | Visuell hervorgehobene Angebots-Card die sich durch Größe, Glanz-Effekt oder animierten Rahmen von anderen Angeboten abhebt | Gleiche Card wie alle anderen Angebote, nur mit anderem Preis oder Text „Bestes Angebot" Label | A035 Foot-in-Door-Angebot-Highlight | **Dediziertes Highlight-Asset mit animiertem Rahmen/Glow verwenden** (`offer_highlight_frame.json` als Lottie). KEIN reines Text-Badge wie „BEST VALUE" ohne visuelles Highlight-Design. Die Card selbst muss größer oder visuell prominenter sein als Standard-Cards. |
| W12 | S020 Auswahlkarten | Bildbasierte Auswahlkarten die Spielstil durch Illustration zeigen (entspannter Spieler vs. kompetitiver Spieler) | Radio-Button-Liste oder Segmented-Control mit Text-Labels für Spielstil-Optionen | A048 Kaltstart-Personalisierungs-Auswahlkarten | **Card-basiertes Selection-UI mit Illustration pro Option implementieren.** Jede Auswahlkarte enthält `Image(asset: "playstyle_\(type).png")` + Label. KEIN `Picker`, `SegmentedControl` oder `RadioButton`-Pattern ohne visuelles Karten-Design. |
| W13 | S010 Challenge-Card | Animierte Card mit Gegner-Avatar, Score-Vergleich und Accept/Decline-CTAs | Einfacher `ListCell` mit Spielername und zwei Text-Buttons | A038 Challenge-Card-Design | **Challenge-Card als dediziertes Custom-View implementieren** mit `Image(asset: "challenge_card_bg")` als Hintergrund, Avatar-Image-View für Gegner-Profil. KEIN `UITableViewCell`/`List`-Row als Challenge-Darstellung akzeptieren. |
| W14 | S015 Share-Bild | Dynamisch generiertes Share-Bild mit App-Branding, Score und Level-Nummer als attraktive visuelle Card | Reinen Text-String teilen: „Ich habe Level 12 mit 4500 Punkten abgeschlossen! #EchoMatch" | A040 Share-Result-Bild-Template | **Share-Bild programmatisch aus Template rendern:** `UIGraphicsImageRenderer` oder Canvas-API nutzt `share_template.png` als Hintergrund und rendert Score/Level-Werte als Text-Overlay. `UIActivityViewController` bekommt das **gerenderte UIImage**, NICHT einen Text-String als primären Share-Content. |
| W15 | S005 | Battle-Pass-Teaser-Banner | Hochwertiges Saison-Artwork mit Teaser-Energie | Generische Text-Card mit Farbfläche | **Dediziertes `A_BPHomeTeaser`-Asset mit Saison-Artwork erstellen**, Variante pro Saison. |
| W16 | S012 | Saison-Abgelaufen-State | Illustration die zeigt „nächste Saison kommt" — motivierend | Leerer Screen oder roter Fehler-Text | **`A_SeasonEndIllustration` als eigenes Asset definieren.** |
| W17 | S012 | Free vs. Premium Tier-Leiste | Klarer visueller Unterschied Premium = Gold/Glanz, Free = grau | Eine Tier-Leiste, Premium einfach farblich anders | **A031 auf 2 explizite Varianten erweitern:** `A031_free` + `A031_premium` mit eigenem Art-Spec. |
| W18 | S016 | Ad-Fehler-Fallback | Freundliche Illustration „Leider kein Video verfügbar, versuch es später" | Blanker Screen oder nativer OS-Alert | **`A_AdErrorIllustration` erstellen**, Ton: humorvoll, nicht schuldzuweisend. |
| W19 | S016 | Reward-Celebration nach Ad | Particle-Explosion oder Screen-Flash wenn Reward erhalten | Statisches Icon kurz angezeigt | **Separate `A_RewardCelebrationAnimation` (Lottie) definieren**, 1–1,5s. |
| W20 | S016 | Overlay-Container | Semitransparenter gestalteter Rahmen um Ad-Content | Rohes Ad-Fullscreen ohne App-Branding-Rahmen | **`A_AdOverlayFrame` als schlanker Branding-Rahmen mit Close-Button-Area definieren.** |
| W21 | S007 | Rewarded-Ad-Angebots-CTA | Prominent gestalteter Button „Video schauen → Extra-Leben" | Standard-System-Button ohne emotionale Ladung | **`A_RewardedAdCTA`-Button-Design als eigenes Asset mit Reward-Icon und Puls-Animation.** |
| W22 | S002 | DSGVO-Consent-Toggles | Gebrandete Toggle-Switches in App-Farbwelt, granular per Kategorie | iOS/Android System-Standard-Toggles in Systemfarbe | **`A_ConsentToggleSet` definieren** mit An/Aus-States in Brand-Farben. |
| W23 | S002 | Opt-In/Opt-Out-Buttons | Visuell gleichwertig — kein Dark Pattern (DSGVO-Pflicht) | Zustimmen-Button groß + primär, Ablehnen klein + grau | **`A_ConsentButtonPair` mit expliziter Gleichgewichts-Spezifikation**, beide gleiche Größe und Sichtbarkeit. |
| W24 | S002 | Trust-Badge / Privacy-Signal | Kleines „DSGVO-konform"-Badge oder Datenschutz-Siegel unten | Kein Badge — reiner Textblock | **`A_PrivacyTrustBadge` erstellen**, Größe klein, Platzierung Footer des Consent-Modals. |
| W25 | S020 | Ausgewählt-State Auswahlkarten | Ausgewählte Karte visuell klar hervorgehoben (Rahmen, Checkmark) | Karte wird vielleicht einfach einfärbt, kein klares Feedback | **A048 auf 2 Varianten erweitern:** `A048_default` + `A048_selected` mit explizitem Checkmark + Rahmen. |
| W26 | S020 | Datenschutz-Hinweis-Banner | Sichtbarer Hinweis „Diese Auswahl optimiert dein Spielerlebnis — kein Tracking" | Kein Hinweis — Nutzer könnte S020 als Tracking missverstehen | **`A_PersonalizationDisclaimer`-Banner definieren**, Text + visuelles Datenschutz-Icon. |
| W27 | S018 | Consent-Aktualisiert-Feedback | Kurze Bestätigung „Datenschutzeinstellungen gespeichert" mit Animation | Toast-Notification ohne Branding oder gar kein Feedback | **`A_ConsentConfirmationToast` definieren**, 2s einblenden, nicht-blockierend. |

### Warnungen aus der Design-Vision

| # | Screen | Standard den KI waehlt | Was Design-Vision verlangt | Prompt-Anweisung |
|---|---|---|---|---|
| DV1 | S006, S001, S004, alle Spielfeld-Screens | Weißer oder hellgrauer Hintergrund als Basis-Canvas für alle Screens | **Dunkler Basis-Canvas** (#0D0F1A bis #1A1D2E) als primäre Designsprache — kein Screen darf einen hellen Hintergrund als Default haben. Ausnahme nur für DSGVO/ATT-Modal (System-Pflicht) | **VERWENDE `color-background-deep` (#0D0F1A) oder `color-background-mid` (#1A1D2E) als primären Hintergrund für alle Screens. KEIN WEISS ODER HELLGRAU.** |
| DV2 | S005, S007, alle Hub-Screens | Fünf-Icon Bottom-Tab-Bar persistent auf allen Screens | **Kein persistentes Bottom-Tab-Element.** Navigation über kontextuelles Radial-Menü (Swipe-Up) und situative Action-Surfaces die je nach Screen-State eingebettet sind. | **IMPLEMENTIERE KEINE PERSISTENTE BOTTOM-TAB-BAR. NUTZE KONTEXTUELLE NAVIGATIONSELEMENTE UND GESTEN.** |
| DV3 | S008, S009 | Konfetti-Regen, drei goldene Sterne und "AMAZING!"-Text auf dem Gewinn-Screen | **Vollbild-Poster-Karte** mit expressiver Typografie (konkrete Session-Aussage wie "47 Züge. Kein Fehler."), Kapitel-Farbwelt als Hintergrund, ein einziger "Teilen"-Button. **KEIN KONFETTI. KEINE GENERISCHEN LOBTEXT-BANNER.** | **ERSTELLE EINEN POSTER-ARTIGEN REWARD-SCREEN. KEINE KONFETTI-ANIMATIONEN. KEINE "AMAZING!"-TEXTE. NUTZE `color-accent-amber` (#C9972A) FÜR DEN FARB-SHIFT.** |
| DV4 | S010, alle Shop-Screens | Roter "BEST VALUE!"-Banner schräg über Shop-Kacheln, Vollbild-Grid mit Produkt-Kacheln, roter Countdown-Timer als Druck-Element | **Maximale drei Angebote gleichzeitig**, kein Schräg-Banner, kein Puls-Effekt beim Timer, Preise in klarer lesbarer Type ohne Gold-Rendering, Countdown als dezenter Text ("noch 23 Tage") nicht als animierter Balken. | **GESTALTE DEN SHOP ALS HOCHWERTIGEN KATALOG. KEINE ROTEN "BEST VALUE!"-BANNER. KEINE PULSIERENDEN TIMER. MAXIMAL DREI ANGEBOTE SICHTBAR.** |
| DV5 | S003 | Hand-Cursor der ersten Zug zeigt, Tutorial-Overlay mit abgedunkeltem Hintergrund, statische Dialog-Bubble mit erklärender Figur | **Spielfeld erscheint ohne Overlay; subtiles einmaliges Pulsieren der Steine** als organische Aufmerksamkeits-Lenkung nach 4 Sekunden Inaktivität (Scale 1.0→1.03→1.0 in 1,2 Sek.); erster Stein folgt dem Finger mit 20% Nachzieh-Elastizität wie durch Wasser; Entdeckung durch Spielen nicht durch Erklären. | **VERZICHTE AUF JEDES EXPLIZITE TUTORIAL-OVERLAY ODER HAND-CURSOR. NUTZE SUBTILE PULSIERENDE STEINE UND ELASTISCHES STEIN-DRAG-VERHALTEN FÜR DAS ONBOARDING.** |
| DV6 | S006, S008 | Burst-Partikel-Explosion beim Match als primäres Feedback | **Resonanz-Puls:** Stein-Match löst einen Ton aus der nachhallt statt berstet; Cascade-Töne steigen auf statt ab; Special-Steine formen sich via 400ms Morphing-Animation mit tiefem Haptik-Puls; dreischichtige adaptive Sound-Schicht die mit dem Spieltempo atmet. | **IMPLEMENTIERE KEINE BURST-PARTIKEL-EXPLOSIONEN BEI MATCHES. NUTZE LICHT-EMISSION UND RESONANZ-SOUNDS. SPECIAL-STEINE MORPHEN SICH.** |

---

## 9. Legal-Anforderungen fuer Produktion

**HINWEIS:** Die folgenden Legal-Anforderungen sind generische Prinzipien, die aus den Legal-Reports für 'Minimalistische Atem-Übungs-App' abgeleitet wurden. Eine spezifische, auf EchoMatch zugeschnittene Rechtsberatung ist zwingend erforderlich, da sich die Anforderungen für ein Mobile Game (insbesondere Monetarisierung, Jugendschutz, AI-Content) erheblich unterscheiden können.

### Consent-Screens (DSGVO, ATT)
*   **VERBINDLICH:** Implementierung eines DSGVO-konformen Consent-Management-Systems (CMP) für alle Third-Party-Dienste (Analytics, Payment, Ads). Nutzer muss aktiv zustimmen, bevor personenbezogene Daten an Drittdienste übermittelt werden.
*   **VERBINDLICH:** Der Consent-Screen (S002) muss als `rising card` von unten erscheinen, mit dem Spielfeld dahinter sichtbar (leicht unscharf). Sprache: kurz, direkt, in zweiter Person. Toggle-Switches statt Checkboxen.
*   **VERBINDLICH:** Opt-In- und Opt-Out-Optionen müssen visuell gleichwertig gestaltet sein (keine Dark Patterns).
*   **VERBINDLICH (iOS):** Ein Pre-Primer-Screen (UXI-04) muss vor dem iOS-System-ATT-Dialog erscheinen, um den Nutzer über die Bedeutung der Anfrage aufzuklären.
*   **VERBINDLICH:** Bei Ablehnung des Consents muss die App vollständig funktionsfähig bleiben (Core Gameplay ist client-side und consent-unabhängig). Analytics und personalisierte Ads werden deaktiviert.

### Age-Gate / COPPA
*   **VERBINDLICH:** Implementierung eines Altersverifikations-Interfaces (Age-Gate) beim ersten App-Start (S002) zur Einhaltung des Children's Online Privacy Protection Act (COPPA) in den USA und ähnlicher Jugendschutzgesetze.
*   **VERBINDLICH:** Wenn der Nutzer unter 13 Jahre alt ist, muss ein freundlicher, aber klarer Block-Screen (A008) angezeigt werden, der die Nutzung der App verhindert. Keine Weiterleitung zu anderen Inhalten oder Funktionen.
*   **VERBINDLICH:** Die App darf im App Store nicht als "Made for Kids" gekennzeichnet werden, da sie sich an Erwachsene richtet.

### Datenschutz
*   **VERBINDLICH:** Eine vollständige, rechtlich wasserdichte Datenschutzerklärung (S025) muss vorhanden und in der App sowie in den App Stores verlinkt sein. Sie muss alle tatsächlichen Datenflüsse dokumentieren (Firebase, Cloud Run, Payment-Provider, Ad-Networks).
*   **VERBINDLICH:** Abschluss und Dokumentation von Auftragsverarbeitungsverträgen (AVV) mit allen Drittanbietern, die personenbezogene Daten verarbeiten (Hosting, Auth, Payment, Ad-Networks).
*   **VERBINDLICH:** Das implizite Spielstil-Tracking (D3) muss ausschließlich on-device erfolgen und im Consent-Screen (S002) klar erklärt werden. Es handelt sich um First-Party-Gameplay-Daten, die nicht für Advertising-Zwecke an Dritte weitergegeben werden.
*   **VERBINDLICH:** Implementierung einer Account-Löschfunktion direkt in der App (S017) gemäß Apple- und Google-Richtlinien.

### Pflicht-UI
*   **VERBINDLICH:** Impressumspflicht (S025) gemäß deutschem Telemediengesetz (§5 TMG) muss erfüllt sein.
*   **VERBINDLICH:** KI-generierte Inhalte (z.B. Level-Layouts, Story-Elemente, wenn KI-generiert) müssen gemäß EU AI Act Art. 50 (gültig ab August 2025) als 'KI-generiert' gekennzeichnet werden. Dies betrifft alle Ausgaben der KI im Produktkontext.
*   **VERBINDLICH:** Haftungs-Disclaimer (S025) für alle Spieltipps, Empfehlungen oder Story-Elemente, die als Ratschläge missverstanden werden könnten.

### App Store Compliance
*   **VERBINDLICH:** Einhaltung der Apple App Store Review Guidelines und Google Play Developer Program Policies.
*   **VERBINDLICH:** Alle In-App-Käufe (IAP) und Abonnements müssen über Apple StoreKit bzw. Google Play Billing abgewickelt werden. Externe Zahlungslinks (z.B. Stripe für native Apps) sind verboten.
*   **VERBINDLICH:** Korrektes Ausfüllen des App Privacy Nutrition Label (Apple) und der Data Safety Section (Google Play) mit präzisen Angaben zu Datenerhebung und -nutzung.
*   **VERBINDLICH:** Implementierung der "Restore Purchases"-Funktion für alle Non-Consumable IAPs und Abonnements.
*   **VERBINDLICH:** Die App muss auf allen unterstützten Geräten und OS-Versionen stabil laufen (keine Abstürze, Performance-Probleme).

---

## 10. Tech-Stack Detail

**HINWEIS:** Die folgende Tech-Stack-Detail-Sektion ist eine Inferenz aus den Design- und Asset-Reports für EchoMatch sowie generischen Best Practices für Mobile Games. Ein dedizierter Tech-Stack-Report für EchoMatch wurde nicht bereitgestellt.

### Engine + Version
*   **Engine:** Unity 2022.3 LTS (Long Term Support) oder neuer.
*   **Render Pipeline:** Universal Render Pipeline (URP) für optimierte Performance und visuelle Effekte (Bloom, Emission Maps).
*   **Input System:** Unity Input System Package (für Gestensteuerung, Haptik).
*   **UI System:** Unity UI Toolkit (für performante und skalierbare UI-Elemente) oder uGUI (für schnelle Prototypen).

### Backend-Dienste
*   **Authentication:** Firebase Authentication (E-Mail/Passwort, Google/Apple Sign-In).
*   **Database:** Firebase Firestore (für Spielerprofile, Fortschritt, Social-Daten, Battle-Pass-Status, Shop-Konfiguration).
*   **Cloud Functions:** Firebase Cloud Functions (für serverseitige Logik: IAP-Validierung, Battle-Pass-Updates, KI-Level-Generierung, Push-Notification-Trigger).
*   **Remote Config:** Firebase Remote Config (für A/B-Tests, Feature-Flags, dynamische Shop-Angebote).
*   **AI Integration:** Google Cloud Run (als Serverless-Wrapper für externe KI-APIs wie Anthropic Claude API für Level-Generierung oder Story-Elemente).

### SDKs mit Versionen
*   **Analytics:** Firebase Analytics SDK (v10.x) oder Plausible Analytics SDK (v1.x) für DSGVO-konformes Tracking.
*   **Payment:**
    *   iOS: StoreKit 2 (für In-App Purchases und Subscriptions).
    *   Android: Google Play Billing Library (v6.x).
    *   (Optional, falls PWA-Fallback): Stripe SDK (v14.x) für Web-Payments.
*   **Ads:** Google AdMob SDK (v22.x) oder Unity Ads SDK (v4.x) für Rewarded Ads.
*   **Social:** Firebase Social SDKs (für Google/Apple Sign-In), Native Share Plugin (für plattform-native Share-Sheets).
*   **Lottie:** Lottie-Unity-Plugin (v4.x) für Lottie-Animationen.
*   **Haptics:** iOS Core Haptics, Android VibrationEffect API (direkte native Integration, kein Third-Party-SDK).

### CI/CD Pipeline
*   **Version Control:** Git (GitHub/GitLab).
*   **Build Automation:** GitHub Actions oder GitLab CI/CD für automatisierte Unity-Builds (iOS, Android APK/AAB).
*   **Deployment:** Fastlane (für automatisierte App Store Connect / Google Play Console Uploads).
*   **Testing:** Unity Test Framework für Unit- und Integrationstests.

### Monitoring + Crash-Reporting
*   **Crash Reporting:** Sentry SDK (v4.x) für Echtzeit-Crash-Reporting und Performance-Monitoring.
*   **Uptime Monitoring:** UptimeRobot oder Better Uptime (für Backend-Services).
*   **Logging:** Firebase Crashlytics (für Unity-spezifische Crashes), Google Cloud Logging (für Cloud Functions/Run).
*   **Performance Monitoring:** Unity Profiler (für In-Editor-Performance), Firebase Performance Monitoring (für Runtime-Performance).

---

## 11. Release-Anforderungen

**HINWEIS:** Die folgenden Release-Anforderungen sind generische Phasen und Kriterien, die aus den Release-Reports für 'SkillSense' abgeleitet wurden. Spezifische Daten und Erfolgskriterien für EchoMatch müssen definiert werden.

### Phase 0 (Closed Beta)
*   **Ziel:** Kernfunktionen (Core Match-3, Level-Progression, Onboarding, erste IAPs) unter realen Bedingungen validieren. Design-Vision-Elemente (D1-D5, W1-W5) auf Nutzerakzeptanz und Wow-Effekt testen. Technische Stabilität und Performance auf verschiedenen Geräten sicherstellen.
*   **Dauer:** 4–6 Wochen
*   **Teilnehmer:** 100–200 handverlesene Nutzer aus Gaming-Communities (Reddit r/Match3, Discord-Server). Einladungsbasiert. Fokus auf Zielgruppe 18-34.
*   **Erfolgskriterien (Beispiel):**
    *   ≥ 70% der Beta-Nutzer spielen mindestens 5 Levels.
    *   ≥ 30% der Nutzer kehren innerhalb von 7 Tagen zurück (D7 Retention).
    *   App-Start-Zeit < 3 Sekunden auf 90% der Testgeräte.
    *   Qualitatives Feedback: Mindestens 50 ausgefüllte Feedback-Formulare mit Fokus auf Design-Vision-Elemente.
    *   0 kritische Abstürze (Crash-Rate < 0.1%).
    *   Wow-Momente (W1-W5) werden von >50% der Nutzer als "besonders" oder "anders" wahrgenommen (qualitativ).

### Phase 1 (Soft Launch)
*   **Ziel:** Öffentliche Zugänglichkeit für ausgewählte Märkte herstellen. Free-to-Paid-Conversion-Funnel scharfschalten (IAP, Battle-Pass). Erste Revenue-Daten validieren. Marketing-Kanäle (ASO, Social Media) testen.
*   **Dauer:** 6–8 Wochen
*   **Regionen:** Kanada, Australien, Neuseeland (Tier-2-Märkte für Mobile Games).
*   **Erfolgskriterien (Beispiel):**
    *   ≥ 10.000 Downloads bis Ende Woche 8.
    *   D7 Retention ≥ 25%, D30 Retention ≥ 10%.
    *   Free-to-Paying Conversion ≥ 2% (IAP + Battle-Pass).
    *   ARPU (Average Revenue Per User) ≥ 0.15 USD.
    *   Battle-Pass-Adoption ≥ 15% der zahlenden Nutzer.
    *   ASO-Ranking für Kern-Keywords in Top 20.
    *   0 kritische Monetarisierungs-Fehler (z.B. fehlgeschlagene IAPs).

### Phase 2 (Global Launch)
*   **Ziel:** Skalierung auf globale Märkte. Full Marketing-Push (PR, Influencer, Paid UA). Erreichen von 6-stelligen Nutzerzahlen.
*   **Datum/Zeitrahmen:** Woche 12–16 nach Beta-Start (ca. 3–4 Monate nach Phase-0-Beginn). Product-Hunt-Launch (falls relevant für Games) auf einen Dienstag oder Mittwoch.
*   **Regionen:** USA, UK, DACH, EU, Skandinavien, Japan, Südkorea.
*   **Checkliste (Beispiel):**
    *   [ ] Alle Phase-1-Erfolgskriterien erfüllt.
    *   [ ] Server-Infrastruktur für erwarteten Traffic-Peak skaliert und getestet.
    *   [ ] Marketing-Materialien für alle Zielregionen lokalisiert.
    *   [ ] PR-Kampagne