Das folgende Creative Director Technical Roadbook ist für die App **EchoMatch** erstellt. Informationen, die spezifisch für andere Apps in den Rohdaten vorlagen (z.B. "skillsense" oder "breathflow4"), wurden nicht direkt übernommen, sondern, wo sinnvoll und explizit gekennzeichnet, als allgemeine Empfehlungen oder zur Ableitung von Best Practices herangezogen. Fehlende spezifische Daten für EchoMatch werden als solche ausgewiesen.

---

# Creative Director Technical Roadbook: EchoMatch
## Version: 1.0 | Status: VERBINDLICH für alle Produktionslinien

---

## 1. Produkt-Kurzprofil

*   **App Name:** EchoMatch
*   **One-Liner:** Ein Match-3-Puzzle-Spiel, das emotionale Tiefe durch eine dunkle, atmosphärische Ästhetik und personalisiertes Gameplay neu definiert und sich radikal von Genre-Klischees abgrenzt.
*   **Plattformen:** **iOS** (iPhone, iPad), **Android** (Smartphones, Tablets)
*   **Tech-Stack (Kern):** **Unity URP (Universal Render Pipeline)**, C# für Gameplay-Logik.
    *   **Backend-Tendenz (Empfehlung):** Firebase (Firestore für Spielerprofile, Fortschritt, Social-Daten; Cloud Functions für serverseitige Logik wie KI-Level-Generierung, Battle-Pass-Updates; Authentication für Account-Management).
    *   **Zusätzliche SDKs (Empfehlung):** Unity Ads (für Rewarded Ads), Unity Analytics (für Gameplay-Metriken), Stripe (für IAP-Abwicklung, falls nicht über App Stores), Native Share Plugin (für Social Sharing).
*   **Zielgruppe:** 18–34 Jahre, Tier-1-Märkte (primär DACH, UK, US). Spieler, die eine hochwertige, immersive und emotional ansprechende Spielerfahrung suchen, die sich von generischen Casual Games abhebt. Sie schätzen Ästhetik, Story und subtile Personalisierung.

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
| **W1** | **Logo-Genesis** | S001 | Aus dem dunklen Hintergrund bilden sich drei Spielsteine in den App-Farben, ordnen sich zu einem Match, verschwinden mit einem weichen Resonanz-Puls (einzelner tiefer Kristallton), und aus diesem Puls formt sich das EchoMatch-Logo. Ladezeit ≤2 Sek. — die Animation ist nie fertig bevor sie endet, sie ist die Ladezeit. Bei Slow-Connection wiederholt der Puls sich ruhig als Herzschlag-Echo. | Erste 2 Sekunden prägen den emotionalen Kontrakt — Nutzer erlebt sofort: diese App ist anders als Candy Crush; Logo-Genesis kommuniziert ohne Wort die Kernmechanik und visuelle Identität; kein anderer Wettbewerber hat einen Splash der selbst eine Mini-Geschichte erzählt |
| **W2** | **Der lebendige erste Stein** | S003 | Der erste Stein den der Nutzer berührt leuchtet von innen heraus auf und folgt dem Finger mit 20% Nachzieh-Elastizität — nicht pixelgenau, wie durch Wasser gezogen. Haptik: leichtes Ticken beim Drag-Start, mittleres Snap beim Einrasten (nicht beim Loslassen — am Snap-Moment), weiches kurzes Rumble wie eine verstummende Stimmgabel beim erfolgreichen Match. Cascade-Töne steigen auf. Kein Tutorial-Text, keine Erklärung — das Feld selbst ist der Lehrer. | Entscheidung über Installation-Retention fällt in den ersten 60 Sekunden; der erste Stein-Touch ist der emotionalste Moment des gesamten Funnels; Elastizität und Eigenleuchten kommunizieren sofort Premium-Qualität und erzeugen das Kompetenz-Gefühl das alle anderen Screens aufbauen |
| **W3** | **Goldene Ausatmung** | S008, S009 | Nach Level-Abschluss keine Konfetti-Explosion. Das Spielfeld atmet einmal aus — alle Steine verblassen sanft innerhalb von 400ms. Dann: der gesamte Screen-Hintergrund verschiebt sich in 1,5 Sek. zu warmem Gold (#C8960C, Sättigung 60%, nicht grell). In dieser Goldpause erscheint eine einzelne Zeile die den Spielstil des Nutzers beschreibt ("Heute: 3 Cascades. Durchschnittszug: 1,4 Sekunden."). Dann: Poster-Format-Share-Card die nativ geteilt werden kann. | Stärkster Kontrastmoment zum Genre — jeder der das zum ersten Mal sieht weiß sofort: das ist nicht Candy Crush; die goldene Pause ist emotional nachhaltiger als Konfetti-Überwältigung; Poster-Share-Card ist der eingebaute virale Mechanismus (Spotify Wrapped-Prinzip); dieser Moment wird auf TikTok geteilt weil er so anders aussieht |
| **W4** | **NPC Interface-Brecher** | S005, S008 | Nach einem verlorenen Level taucht ein Story-NPC als kleines Element im Home Hub auf und hinterlässt einen kurzen kontextuellen Kommentar im Ton der Spielwelt — nie generisch, immer zum Spielstil des Nutzers passend. Max. 1× pro Woche, dadurch selten und bedeutsam. Animation: NPC gleitet von der Bildschirmkante herein (300ms Ease-Out), bleibt 4 Sekunden sichtbar, zieht sich zurück. Tap auf NPC öffnet eine Mini-Story-Sequenz. | Duolingo-Owl-Prinzip angewendet auf narrative Spielwelt — Vierte-Wand-Bruch ist der viralste UI-Moment den Apps produzieren können; erzeugt emotionale Bindung an Charaktere außerhalb der Story-Screens; gibt Nutzern einen Screenshot-würdigen Moment der EchoMatch von allen Wettbewerbern unterscheidet |
| **W5** | **Spieler-Lichtpunkte auf der Level-Map** | S007 | Freunde-Avatare erscheinen als kleine, sanft pulsierende Lichtpunkte direkt auf ihrem aktuellen Level-Punkt der Map — ohne separaten Social-Tab. Ein Freund der gerade aktiv spielt pulsiert schneller (1 Puls/Sek.). Ein Freund der heute noch nicht gespielt hat: minimale Helligkeit, langsamer Puls. Challenge-Einladung: der Lichtpunkt des einladenden Freundes pulsiert in einer zweiten Farbe (Bernstein statt Weiß). Social-Präsenz ist immer ambient sichtbar, nie aufdringlich. | Zenly-Prinzip: soziale Aktivität passiert auf dem primären visuellen Layer; reduziert Tab-Depth auf null; macht soziale Verbindung zu einem natürlichen Teil der Spielwelt statt eines isolierten Features; erzeugt FOMO durch ambient sichtbare Aktivität ohne Push-Notification-Druck |

### Interaktions-Prinzipien (PFLICHT)

*   **Touch-Reaktion:**
    Jede Berührung erhält sofortiges visuelles Echo — der berührte Stein leuchtet innerhalb von 16ms auf (ein Frame). Drags haben 20% Nachzieh-Elastizität (das Objekt folgt dem Finger wie durch Wasser, nicht pixelgenau). Unmögliche Züge werden nicht mit Fehler-Feedback bestraft — der Stein federt neutral zurück, kein Fehler-Buzz, kein negativer Feedback-Loop. Snap-Feedback (Einrasten) erfolgt am Snap-Moment, nicht beim Finger-Loslassen.

*   **Animations-Prinzip:**
    Atmend statt burstend. Standard-Ease ist Ease-In-Out über 600–900ms für alle narrativen und UI-Übergänge. Gameplay-Animationen sind schneller (Match-Auflösung: 300ms, Stein-Fall: physikbasiert mit leichtem Overshoot-Bounce 8%). Special-Stein-Entstehung: 400ms Morphing-Animation (Metall das sich selbst in eine Form zieht). Hintergrund-Puls bei Combo: Bloom-Intensität steigt von 0.4 auf 0.7 in 200ms, fällt in 600ms zurück. Kein Element animiert ohne Bedeutung — jede Animation kommuniziert Information oder Emotion.

*   **Feedback-Prinzip:**
    Dreischichtig und narrativ bedeutsam:
    1.  Leichtes Ticken beim Stein-Drag-Start (Hinweis: Aktion beginnt)
    2.  Mittleres Snap beim Einrasten (Bestätigung: Zug registriert)
    3.  Tiefes Rumble bei Cascade-Combo: 3-Match = 80ms, 5-Match = 200ms, länger = mehr Gewicht; fühlt sich wie eine Stimmgabel an die langsam verstummt — nie wie ein Fehler-Buzz oder ein Alarm.
    Kein negativer Feedback-Buzz für falsche Inputs — neutrale Rückfeder statt Bestrafung.

*   **Sound-Prinzip:**
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
*   **Easing:** cubic-bezier(0.34, 1.56, 0.64, 1) (leichter Bounce)
*   **Max Lottie:** 500 KB pro Animation
*   **Static Fallback:** Ja, für alle Lottie-Animationen und komplexe Custom-Animationen.

---

## 4. Feature-Map

**Hinweis:** Die vorliegenden Reports enthalten keine spezifische Feature-Liste für EchoMatch. Die folgende Feature-Map wurde basierend auf der Design-Vision, Screen-Architektur und den allgemeinen Anforderungen eines Match-3-Spiels abgeleitet. Die Schätzung von KPI-Impact und Wochen ist eine Annahme basierend auf Industriestandards und der Komplexität der Design-Vorgaben.

### Phase A — Soft-Launch MVP (30 Features)
**Budget Phase A (Entwicklung):** Nicht explizit in Reports für EchoMatch definiert. **Empfehlung:** Ein realistisches Budget für ein Match-3 MVP mit den hier definierten Design-Ansprüchen liegt bei **250.000 - 400.000 EUR**.

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhängigkeiten | Begründung |
|---|---|---|---|---|---|---|
| F001 | Match-3 Core Loop | Grundlegende Match-3-Mechanik: Stein-Swap, Match-Erkennung (3er, 4er, 5er), Kaskaden, Stein-Fall. | D1, D7, Session-Dauer | 4 | - | **VERBINDLICH:** Kern-Gameplay. Ohne dies kein Spiel. |
| F002 | D1: Dark-Field Luminescence | Implementierung des dunklen Spielfeld-Hintergrunds, selbstleuchtende Steine (Bloom, Emission-Maps), kapitelbasierte Farb-Shifts. | D1, D7, ARPU | 3 | F001 | **VERBINDLICH:** Kern-Differenzierung D1. Muss von Anfang an visuell überzeugen. |
| F003 | D3: Implizites Spielstil-Tracking | Messung von Zuggeschwindigkeit, Pausenlänge, Combo-Orientierung im Onboarding-Match. | D1, D7, ARPU | 2 | F001 | **VERBINDLICH:** Kern-Differenzierung D3. Basis für Personalisierung. |
| F004 | W2: Lebendiger erster Stein | Stein leuchtet auf, folgt Finger mit Elastizität, haptisches Feedback beim Snap. | D1, D7 | 1 | F001 | **VERBINDLICH:** Wow-Moment W2. Kritisch für erste 60 Sekunden. |
| F005 | W1: Logo-Genesis Splash | Animation des Logos aus drei matchenden Steinen, Resonanz-Puls, Spieler-Farbpalette. | D1 | 1 | - | **VERBINDLICH:** Wow-Moment W1. Erster emotionaler Kontakt. |
| F006 | A5: Onboarding ohne Tutorial-Overlay | Spielfeld erscheint ohne Text-Overlay, subtiles Pulsieren der Steine als Hint. | D1 | 1 | F001 | **VERBINDLICH:** Anti-Standard A5. Aktiviert Agency-Gefühl. |
| F007 | A6: Resonanz-Puls Match-Feedback | Match-Feedback über Licht-Emission, nachhallender Ton, aufsteigende Kaskaden-Töne. | D1, D7 | 2 | F001 | **VERBINDLICH:** Anti-Standard A6. Hochwertiges Feedback. |
| F008 | Level-Struktur & Ziele | Definition von Level-Layouts, Hindernissen, Zielen (z.B. X Steine sammeln, X Eis brechen). | D7, D30 | 2 | F001 | Basis für Progression. |
| F009 | Basis-Booster-System | 2-3 grundlegende Booster (Hammer, Shuffle) mit UI-Integration und Effekten. | ARPU | 2 | F001 | Monetarisierungs-Grundlage. |
| F010 | W3: Goldene Ausatmung Level-Complete | Screen-weite Gold-Farbverschiebung, lesbare Spielhistorie, Poster-Format-Share-Card. | D7, D30, Viralität | 2 | F001 | **VERBINDLICH:** Wow-Moment W3. Kern für Social Sharing. |
| F011 | A3: Kein Konfetti/AMAZING Reward | Implementierung des Post-Session-Screens ohne Konfetti, Sterne, generische Lobtexte. | D7, Viralität | 1 | F010 | **VERBINDLICH:** Anti-Standard A3. Differenziert Reward-Moment. |
| F012 | S005 Home Hub Basis | Grundlayout des Home Hub mit Platzhaltern für Daily Quest, Battle Pass, Story. | D1, D7 | 2 | - | Einstiegspunkt für wiederkehrende Nutzer. |
| F013 | S008 Level-Map Basis | Einfache Level-Map mit linearer Progression, Level-Knoten-Icons (Gesperrt/Offen/Abgeschlossen). | D7, D30 | 2 | F008 | Visualisiert Fortschritt. |
| F014 | S004 Narrative Hook Sequenz | 10-Sekunden-Sequenz mit 3-4 Standbildern, Parallax-Tiefe, persona-passendes Setting. | D7, D30 | 2 | F003 | **VERBINDLICH:** Emotionaler Anker für Story. |
| F015 | S002 Consent-Dialog (DSGVO/ATT) | Rising Card-Modal, menschliche Sprache, Toggle-Switches, ATT-Pre-Primer. | Legal Compliance | 2 | - | **VERBINDLICH:** Legal-Pflicht. |
| F016 | S018 Settings Basis | Grundlegende Einstellungen (Sound, Haptik, Sprache) mit Dark Mode Toggle. | UX | 1 | - | Basis-UX-Anforderung. |
| F017 | A1: Dunkle Grundpalette UI | Implementierung der dunklen UI-Farbpalette (#120D2A, #1E1540) für alle UI-Elemente. | D1 | 1 | - | **VERBINDLICH:** Anti-Standard A1. Visuelle Identität. |
| F018 | A2: Kontextuelle Navigation (Basis) | Keine Bottom-Bar. Implementierung eines Radial-Menüs (Swipe-Up) vom Home Hub. | D1, D7 | 2 | F012 | **VERBINDLICH:** Anti-Standard A2. Kern-Navigationsprinzip. |
| F019 | A4: Stiller Shop (Basis) | Shop-Layout mit max. 3 Angeboten, viel Dark-Space, keine roten "BEST VALUE!"-Banner. | ARPU | 2 | - | **VERBINDLICH:** Anti-Standard A4. Vertrauensbildende Monetarisierung. |
| F020 | IAP-Integration (Stripe/StoreKit) | Basis-Integration für 1-2 IAP-Produkte (z.B. Booster-Paket). | ARPU | 3 | - | Monetarisierungs-Grundlage. |
| F021 | Rewarded Ads Integration | Integration eines Rewarded Ad SDK (z.B. Unity Ads) für Extra-Züge/Leben. | ARPU | 2 | F001 | Monetarisierungs-Grundlage. |
| F022 | W4: NPC Interface-Brecher (Basis) | Ein Story-NPC kann im Home Hub erscheinen und kontextuellen Kommentar geben. | Viralität, D7 | 2 | F012, F014 | **VERBINDLICH:** Wow-Moment W4. Viralitäts-Potenzial. |
| F023 | W5: Spieler-Lichtpunkte Level-Map (Basis) | Freunde-Avatare als Lichtpunkte auf der Level-Map, pulsierend bei Aktivität. | D7, D30, Viralität | 2 | F013 | **VERBINDLICH:** Wow-Moment W5. Ambient Social. |
| F024 | UXI-01: Silent Persona Engine | Implementierung der 3 Spieler-Persona-Werte in PlayerPrefs, KI-Mapping-Tabelle. | D1, D7 | 2 | F003 | **VERBINDLICH:** UX-Innovation UXI-01. Kern der Personalisierung. |
| F025 | UXI-04: Pre-Primer für ATT-Consent | Eigener Modal-Screen vor dem iOS ATT-Prompt mit menschlicher Erklärung. | Legal Compliance | 1 | F015 | **VERBINDLICH:** UX-Innovation UXI-04. Erhöht ATT-Akzeptanz. |
| F026 | UXI-03: Adaptive Sound-Schicht (Basis) | Basis-Ambient-Tempo und -Intensität skalieren mit Zug-Tempo des Nutzers. | D1, D7 | 2 | F001 | **VERBINDLICH:** UX-Innovation UXI-03. Immersive Sound-Erfahrung. |
| F027 | UXI-05: Reward-as-Narrative (Basis) | Level-Abschluss-Text als lesbare Zusammenfassung der Partie (4-5 Templates). | D7, Viralität | 1 | F010 | **VERBINDLICH:** UX-Innovation UXI-05. Narrative Belohnung. |
| F028 | UXI-02: Kontextuelle Navigation (Basis) | Time-based State Machine für 3 Nav-Konfigurationen (Morgen, Mittag, Abend). | D1, D7 | 2 | F018 | **VERBINDLICH:** UX-Innovation UXI-02. Dynamische Navigation. |
| F029 | UXI-00: Haptic Language System (Basis) | 3-4 distinkte Haptik-Muster (Soft-Settle, Echo-Pulse, Rumble) für Kern-Interaktionen. | D1, D7 | 1 | F001 | **VERBINDLICH:** UX-Innovation UXI-00. Taktiles Feedback. |
| F030 | UXI-00: Chrono-Responsive UI (Basis) | UI verändert visuelle Temperatur je nach Tageszeit (Morgen, Mittag, Abend). | D1, D7 | 1 | F017 | **VERBINDLICH:** UX-Innovation UXI-00. Atmosphärische Anpassung. |

### Phase B — Full Production (23 Features)
**Budget Phase B (Entwicklung):** Nicht explizit in Reports für EchoMatch definiert. **Empfehlung:** Ein realistisches Budget für die Skalierung auf Full Production liegt bei **200.000 - 350.000 EUR**.

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhängigkeiten | Begründung |
|---|---|---|---|---|---|---|
| F031 | KI-Level-Generierung (Live) | Dynamische Level-Generierung basierend auf Spieler-Persona und Fortschritt. | D7, D30, ARPU | 4 | F003, F024, F008 | Kern-Feature für Langzeit-Retention und Personalisierung. |
| F032 | Story-Kapitel-System | Mehrere Story-Kapitel mit freischaltbaren Inhalten, Charakter-Interaktionen. | D7, D30 | 3 | F014 | Vertieft die Meta-Layer, erhöht Engagement. |
| F033 | Battle-Pass System (Full) | Vollständiges Battle-Pass-System mit Free/Premium-Tiers, XP-Progression, Rewards. | ARPU, D30 | 4 | F020, F021 | Haupt-Monetarisierungs-Säule. |
| F034 | Social Hub (Full) | Freundesliste, Leaderboards, Challenge-System, Gilden/Teams (Basis). | D7, D30, Viralität | 3 | F023 | Skaliert soziale Interaktion. |
| F035 | Shop (Full) | Erweiterter Shop mit mehr IAP-Produkten, Bundles, zeitlich begrenzten Angeboten. | ARPU | 2 | F020 | Erweitert Monetarisierungs-Optionen. |
| F036 | Daily Quest System (Full) | Dynamische Daily Quests mit verschiedenen Zielen und Belohnungen. | D1, D7 | 2 | F012 | Fördert tägliches Engagement. |
| F037 | Event System (Live-Ops) | Möglichkeit, In-Game-Events (z.B. Wochenend-Events, saisonale Events) zu konfigurieren. | D7, D30, ARPU | 3 | F033, F036 | Hält das Spiel frisch, treibt Monetarisierung. |
| F038 | W4: NPC Interface-Brecher (Full) | Mehr NPCs, komplexere Kommentare, visuelle Effekte beim Auftauchen. | Viralität, D7 | 2 | F022 | Skaliert Wow-Moment W4. |
| F039 | W5: Spieler-Lichtpunkte Level-Map (Full) | Mehr Interaktionen mit Lichtpunkten (Challenge-Einladung, Profil-Peek). | D7, D30, Viralität | 2 | F023 | Skaliert Wow-Moment W5. |
| F040 | UXI-01: Silent Persona Engine (Full) | Verfeinerung der Persona-Erkennung, mehr persona-spezifische Level-Varianten. | D7, D30 | 2 | F024, F031 | Vertieft Personalisierung. |
| F041 | UXI-02: Kontextuelle Navigation (Full) | Mehr Nav-Konfigurationen (z.B. nach Event-Status, nach Story-Fortschritt). | D1, D7 | 2 | F028 | Vertieft dynamische Navigation. |
| F042 | UXI-03: Adaptive Sound-Schicht (Full) | Mehr Audio-Schichten, komplexere Blending-Logik, persona-spezifische Sound-Anpassung. | D1, D7 | 2 | F026 | Vertieft immersive Sound-Erfahrung. |
| F043 | UXI-05: Reward-as-Narrative (Full) | Mehr Template-Strings, komplexere Daten-Injektion, persona-spezifische Narrative. | D7, Viralität | 2 | F027 | Vertieft narrative Belohnung. |
| F044 | UXI-00: Haptic Language System (Full) | 5-6 distinkte Haptik-Muster, Haptik-Intro im Onboarding. | D1, D7 | 2 | F029 | Vertieft taktiles Feedback. |
| F045 | UXI-00: Chrono-Responsive UI (Full) | Mehr Tageszeit-Tints, saisonale Anpassungen (z.B. Winter-Tints). | D1, D7 | 2 | F030 | Vertieft atmosphärische Anpassung. |
| F046 | UXI-00: Sound-Personalisierung durch Spielstil | Sound-Design passt sich über Zeit dem erkannten Spieltyp an (Attack, Decay, Reverb). | D7, D30 | 2 | F026, F024 | Vertieft Sound-Immersion. |
| F047 | UXI-00: Narrative Memory System | Spiel erinnert sich an spezifische Momente und referenziert sie später (Text-Zeilen). | D7, D30 | 2 | F032 | Vertieft narrative Bindung. |
| F048 | UXI-00: Progressive Interface Reduction | UI-Elemente blenden sich bei erfahreneren Nutzern automatisch aus. | D7, D30 | 2 | F016 | Effizienz für Experten. |
| F049 | Push Notifications (Marketing) | Gezielte Push-Nachrichten für Events, Daily Quests, Churn-Prevention. | D7, D30 | 2 | F037 | Re-Engagement. |
| F050 | Analytics (Full) | Detailliertes Event-Tracking, Funnel-Analyse, LTV-Berechnung. | Business KPIs | 2 | F020 | Datenbasierte Entscheidungen. |
| F051 | A/B Testing System | In-Game A/B-Testing für Features, Monetarisierung, UI-Elemente. | Business KPIs | 2 | F050 | Optimierung. |
| F052 | Lokalisierung (Multi-Language) | Unterstützung weiterer Sprachen (z.B. Französisch, Spanisch). | DAU | 3 | - | Globale Reichweite. |
| F053 | Cloud Save / Cross-Device Sync | Spielerfortschritt wird in der Cloud gespeichert und über Geräte synchronisiert. | D7, D30 | 2 | F028 | Nutzerkomfort, Retention. |

### Backlog (5 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begründung |
|---|---|---|---|---|
| F054 | Gilden / Teams (Full) | v1.2 | Erhöht soziale Bindung und Langzeit-Retention. | Komplexes Feature, erfordert stabile Social-Basis. |
| F055 | PvP-Modus (Asynchron) | v1.3 | Erhöht Wettbewerb und Re-Playability. | Erfordert Balancing und Anti-Cheat-Maßnahmen. |
| F056 | User-Generated Content (Level-Editor) | v1.4 | Erhöht Community-Engagement und Content-Vielfalt. | Hoher Entwicklungsaufwand, Moderation nötig. |
| F057 | AR-Integration (Match-3 in Real World) | v2.0 | Innovatives Feature, erschließt neue Zielgruppen. | Hoher technischer Aufwand, Nischen-Feature. |
| F058 | Desktop-Version (PC/Mac) | v2.1 | Erschließt neue Plattformen, erhöht Reichweite. | Anpassung der UI/UX für Desktop-Input. |

---

## 5. Abhängigkeits-Graph & Kritischer Pfad

**Hinweis:** Die vorliegenden Reports enthalten keinen spezifischen Abhängigkeits-Graph oder kritischen Pfad für EchoMatch. Die folgende Ableitung basiert auf der oben erstellten Feature-Map und Best Practices für die Spieleentwicklung.

### Build-Reihenfolge (Phase A - Soft-Launch MVP)

1.  **Core Gameplay Foundation:** F001 (Match-3 Core Loop)
2.  **Visual & Emotional Core:** F002 (D1: Dark-Field Luminescence), F005 (W1: Logo-Genesis Splash), F017 (A1: Dunkle Grundpalette UI)
3.  **Onboarding & First Experience:** F006 (A5: Onboarding ohne Tutorial-Overlay), F004 (W2: Lebendiger erster Stein), F003 (D3: Implizites Spielstil-Tracking), F024 (UXI-01: Silent Persona Engine)
4.  **Core Feedback & UX:** F007 (A6: Resonanz-Puls Match-Feedback), F026 (UXI-03: Adaptive Sound-Schicht (Basis)), F029 (UXI-00: Haptic Language System (Basis))
5.  **Legal & Compliance (Launch Blocker):** F015 (S002 Consent-Dialog (DSGVO/ATT)), F025 (UXI-04: Pre-Primer für ATT-Consent)
6.  **Progression & Meta-Layer (Basis):** F008 (Level-Struktur & Ziele), F013 (S008 Level-Map Basis), F014 (S004 Narrative Hook Sequenz)
7.  **Monetarisierung (Basis):** F020 (IAP-Integration), F021 (Rewarded Ads Integration), F009 (Basis-Booster-System)
8.  **Home & Navigation:** F012 (S005 Home Hub Basis), F018 (A2: Kontextuelle Navigation (Basis)), F028 (UXI-02: Kontextuelle Navigation (Basis)), F030 (UXI-00: Chrono-Responsive UI (Basis))
9.  **Reward & Social (Basis):** F010 (W3: Goldene Ausatmung Level-Complete), F011 (A3: Kein Konfetti/AMAZING Reward), F027 (UXI-05: Reward-as-Narrative (Basis)), F022 (W4: NPC Interface-Brecher (Basis)), F023 (W5: Spieler-Lichtpunkte Level-Map (Basis))
10. **Settings:** F016 (S018 Settings Basis)

### Kritischer Pfad (Phase A - Soft-Launch MVP)

*   **Kette:** F001 (4 Wo) → F002 (3 Wo) → F003 (2 Wo) → F024 (2 Wo) → F014 (2 Wo) → F010 (2 Wo) → F015 (2 Wo)
*   **Gesamtdauer:** **17 Wochen**
*   **Beschreibung:** Der kritische Pfad wird durch die sequentielle Entwicklung des Kern-Gameplays, der visuellen Differenzierung, des impliziten Spielstil-Trackings (als Basis für Personalisierung und Story-Hook), der Story-Hook-Sequenz (als emotionaler Anker), des Level-Complete-Flows (für Retention und Viralität) und der rechtlich notwendigen Consent-Mechanismen bestimmt. Jeder dieser Schritte muss abgeschlossen sein, bevor der nächste beginnen kann, da sie fundamentale Aspekte des Spielerlebnisses und der Compliance betreffen.

### Parallelisierbare Feature-Gruppen (Phase A)

*   **Gruppe 1: Branding & Initialisierung (Parallel zu F001):**
    *   F005 (W1: Logo-Genesis Splash)
    *   F017 (A1: Dunkle Grundpalette UI)
*   **Gruppe 2: Onboarding & Erste Interaktion (Parallel zu F002):**
    *   F006 (A5: Onboarding ohne Tutorial-Overlay)
    *   F004 (W2: Lebendiger erster Stein)
    *   F029 (UXI-00: Haptic Language System (Basis))
*   **Gruppe 3: Core Feedback & Sound (Parallel zu F003):**
    *   F007 (A6: Resonanz-Puls Match-Feedback)
    *   F026 (UXI-03: Adaptive Sound-Schicht (Basis))
*   **Gruppe 4: Monetarisierung & Booster (Parallel zu F008):**
    *   F009 (Basis-Booster-System)
    *   F020 (IAP-Integration)
    *   F021 (Rewarded Ads Integration)
*   **Gruppe 5: Home & Navigation (Parallel zu F013):**
    *   F012 (S005 Home Hub Basis)
    *   F018 (A2: Kontextuelle Navigation (Basis))
    *   F028 (UXI-02: Kontextuelle Navigation (Basis))
    *   F030 (UXI-00: Chrono-Responsive UI (Basis))
*   **Gruppe 6: Reward & Social (Parallel zu F014):**
    *   F011 (A3: Kein Konfetti/AMAZING Reward)
    *   F027 (UXI-05: Reward-as-Narrative (Basis))
    *   F022 (W4: NPC Interface-Brecher (Basis))
    *   F023 (W5: Spieler-Lichtpunkte Level-Map (Basis))
*   **Gruppe 7: Legal & Settings (Parallel zu F010):**
    *   F016 (S018 Settings Basis)
    *   F025 (UXI-04: Pre-Primer für ATT-Consent)

---

## 6. Screen-Architektur (VERBINDLICH)

### Screen-Übersicht (19 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / App Init | Overlay | App-Start, Client-Side Engine laden, Locale erkennen | F005, F030 | Normal, Slow-Connection, Engine-Fehler |
| S002 | Consent / DSGVO / ATT | Modal | DSGVO-konformer Consent vor Analytics-Initialisierung | F015, F025 | Normal, Einstellungen-Expanded, ATT-Pre-Prompt |
| S003 | Onboarding Match | Hauptscreen | Erster Spielmoment, Spielstil-Tracking | F001, F003, F004, F006, F007 | Normal, Inaktiv-Hint, Match-Erfolg, Match-Fehler |
| S004 | Narrative Hook Sequenz | Subscreen | Emotionaler Story-Einstieg, Persona-Anpassung | F014, F024 | Normal, Skip-Sichtbar, Persona-Variante-A, Persona-Variante-B |
| S005 | Home Hub | Hauptscreen | Tägliches Re-Entry, kontextuelle Navigation | F012, F018, F022, F028, F030 | Normal, Daily-Quest-Dominant, Battle-Pass-Teaser, Social-Nudge |
| S006 | Puzzle / Match-3 Spielfeld | Hauptscreen | Kern-Gameplay-Loop | F001, F002, F007, F008, F009, F026, F029 | Normal, Special-Stein-Entstehung, Combo-Aktiv, Wenige-Züge-Warnung, Level-Verloren |
| S007 | Level-Ergebnis / Post-Session | Subscreen | Belohnung, Statistik, Social Sharing | F010, F011, F027 | Sieg-Gold-Shift, Niederlage-Verblassen, Share-Ready, Rewarded-Ad-Angebot |
| S008 | Level-Map / Progression | Hauptscreen | Fortschritt visualisieren, Level auswählen | F013, F023 | Normal, Level-Gesperrt, Level-Offen, Level-Abgeschlossen, Freund-Avatar-Sichtbar |
| S009 | Story / Narrative Hub | Hauptscreen | Kapitel-Übersicht, Story-Fortschritt | F014, F032 | Normal, Kapitel-Gesperrt, Kapitel-Offen, Kapitel-Abgeschlossen |
| S010 | Social Hub | Hauptscreen | Freundesliste, Challenges, Leaderboards | F023, F034 | Normal, Keine-Freunde-Empty-State, Challenge-Ausstehend, Leaderboard-Ansicht |
| S011 | Shop / Monetarisierungs-Hub | Hauptscreen | IAP-Angebote, Battle-Pass-Kauf | F019, F020, F035 | Normal, Foot-in-Door-Highlight, Offline-Gesperrt, Kauf-Bestätigung |
| S012 | Battle-Pass Screen | Subscreen | Battle-Pass-Progression, Rewards | F033 | Normal, Free-Tier, Premium-Tier, Saison-Abgelaufen, Reward-Claimed |
| S013 | Tägliche Quests Screen | Subscreen | Aktuelle Quests, Fortschritt | F036 | Normal, Quest-Aktiv, Quest-Abgeschlossen, Quest-Claimed |
| S014 | Push Opt-In | Modal | Erläuterung und Abfrage für Push-Notifications | F049 | Normal, Opt-In-Erfolgreich, Opt-In-Fehler |
| S015 | Share Sheet | Modal | Teilen von Spielergebnissen | F010, F011 | Normal, Link-Kopiert, Teilen-Erfolgreich |
| S016 | Rewarded Ad Interstitial | Overlay | Vollbild-Werbung für In-Game-Belohnungen | F021 | Ad-Lädt, Ad-Fehler, Ad-Abgeschlossen |
| S017 | Profil / Einstellungen | Hauptscreen | Spielerprofil, Account-Management, Settings | F016, F053 | Normal, Account-Verwaltung, Sprache-Auswahl, Haptik-Toggle |
| S018 | Fehler / Nicht gefunden (404 / Allgemein) | Subscreen | Fehlerbehandlung, Nutzer zurück in Flow führen | - | 404-Not-Found, Allgemeiner-Fehler, Offline |
| S019 | Beta Feedback / NPS | Modal | Qualitatives Feedback, Net Promoter Score | - | Normal, Senden, Erfolg, Fehler |

### Screen-Hierarchie
*   **Hauptscreens:** S003, S005, S006, S008, S009, S010, S011, S017
*   **Subscreens:** S004, S007, S012, S013, S018
*   **Modals:** S002, S014, S015, S019
*   **Overlays:** S001, S016

### Navigation
**VERBINDLICH:** Keine persistente Bottom-Navigation-Bar. Navigation erfolgt über:
*   **Kontextuelles Radial-Menü:** Erscheint via Swipe-Up-Geste vom Home Hub (S005) aus. Enthält 5 Sektoren: Spielen, Map, Story, Social, Profil. Schließt sich nach Auswahl.
*   **Situative Action-Surfaces:** In Screens eingebettete Buttons/CTAs, die je nach State erscheinen (z.B. "Nochmal" nach Niederlage, "Map" nach Sieg).
*   **Ambient Social Presence:** Freunde-Avatare als Lichtpunkte auf der Level-Map (S008).
*   **Chrono-Responsive UI:** Home Hub (S005) passt sich Tageszeit an, priorisiert relevante Aktionen.

### User Flows (7 Flows)

#### Flow 1: Onboarding (Erst-Start) — App öffnen bis erster Core Loop
*   **Screens:** S001 → S002 → S003 → S004 → S005 → S006 → S007
*   **Taps bis Ziel:** 3 (Consent bestätigen auf S002 → Ersten Zug auf S003 → Level starten auf S005)
*   **Zeitbudget:** **VERBINDLICH:** 60 Sekunden bis erstes Ergebnis sichtbar (S007)
*   **Beschreibung:** App initialisiert Client-Side Engine (S001) → DSGVO/ATT Consent (S002) → Onboarding Match (S003) → Narrative Hook Sequenz (S004) → Home Hub (S005) → Startet erstes Level (S006) → Level-Ergebnis (S007).
*   **Fallback Consent-Ablehnung:** S002 setzt nur notwendige Cookies, App funktioniert vollständig weiter (alles client-side, kein Analytics-Block).
*   **Fallback Engine-Fehler auf S001:** Fehler-State zeigt Retry-Button, nach 3 Fehlversuchen Weiterleitung zu S018.

#### Flow 2: Core Loop (wiederkehrend) — Direkteinstieg bis Level-Ergebnis
*   **Screens:** S001 → S005 → S006 → S007
*   **Taps bis Ergebnis:** 2 (Daily Quest starten auf S005 → Ersten Zug auf S006)
*   **Session-Ziel:** 45–90 Sekunden für vollständigen Scan-Zyklus, Gesamtsession 6–10 Minuten inkl. S007-Review.
*   **Beschreibung:** Wiederkehrender Nutzer öffnet App, Splash kurz (S001) → Home Hub (S005) → Startet Daily Quest (S006) → Level-Ergebnis (S007).
*   **Fallback Analyse-Timeout >50 Sek.:** S006 zeigt Timeout-Warnung mit Abbrechen-Option und Retry.
*   **Fallback Analyse-Fehler:** Fehler-Abbruch-State auf S006, Weiterleitung zurück zu S006 mit Fehlermeldung.
*   **Fallback Offline:** S006 sperrt Level-Start-Button, zeigt Offline-Hinweis.

#### Flow 3: Erster Kauf — Battle-Pass-Upgrade
*   **Screens:** S005 → S011 → S012 → (Nativer Payment-Dialog) → S012 (Premium-State) → S005
*   **Taps bis Kauf:** 3 (Shop-Tab auf S005 → Battle-Pass-Karte auf S011 → „Jetzt kaufen"-Button auf S012)
*   **Zeitbudget:** 60–90 Sekunden.
*   **Beschreibung:** Nutzer sieht Battle-Pass-Teaser auf Home Hub (S005) → navigiert zu Shop (S011) → wählt Battle-Pass-Angebot (S012) → Nativer Payment-Dialog → Bestätigung → Battle-Pass-Screen zeigt Premium-Status.
*   **Fallback Payment-Fehler:** S012 zeigt Fehler-State mit Retry-Option.
*   **Fallback Offline:** S011 sperrt Kauf-Buttons, zeigt Offline-Hinweis.

#### Flow 4: Social Challenge — Ergebnis teilen
*   **Screens:** S007 → S015
*   **Taps bis Teilen:** 2 (Share-Button auf S007 → Teilen-Aktion in S015)
*   **Zeitbudget:** 15–20 Sekunden.
*   **Beschreibung:** Nutzer sieht Level-Ergebnis (S007) mit Teilen-CTA → Share-Modal öffnet sich (S015) mit vorgefertigtem Text und Score-Visual für Social Media → Nutzer wählt Link kopieren oder direktes Teilen → Erfolgs-Feedback.
*   **Fallback Link-kopieren fehlgeschlagen:** S015 zeigt Link als selektierbaren Text.
*   **Fallback Keine Skills erkannt:** Share-Button auf S007 ist deaktiviert.
*   **Fallback Offline:** S015 zeigt nur Link-kopieren-Option.

#### Flow 5: Story-Fortschritt — Kapitel lesen
*   **Screens:** S005 → S009 → S004 (bei neuem Kapitel) → S009
*   **Taps bis Kapitel-Start:** 2 (Story-Tab auf S005 → Kapitel auswählen auf S009)
*   **Zeitbudget:** Nutzer-gesteuert.
*   **Beschreibung:** Nutzer wählt Story-Tab auf Home Hub (S005) → Story Hub (S009) zeigt Kapitel-Übersicht → wählt neues Kapitel → Narrative Hook Sequenz (S004) → kehrt zu Story Hub (S009) zurück.
*   **Fallback Kapitel gesperrt:** S009 zeigt gesperrten Zustand, kein Tap möglich.
*   **Fallback Offline:** S009 lädt Kapitel-Daten aus Cache.

#### Flow 6: Rewarded Ad — Extra-Leben erhalten
*   **Screens:** S006 (Level-Verloren) → S007 (Verloren-Rewarded-Ad-Angebot) → S016 (Ad-Overlay) → S006 (Extra-Leben)
*   **Taps bis Extra-Leben:** 1 (Rewarded-Ad-CTA auf S007)
*   **Zeitbudget:** 30–60 Sekunden (Ad-Dauer).
*   **Beschreibung:** Nutzer verliert Level (S006) → Level-Ergebnis zeigt Rewarded-Ad-Angebot (S007) → Nutzer tippt CTA → Rewarded Ad Interstitial (S016) → Ad läuft → Ad abgeschlossen → Extra-Leben wird gewährt → Level (S006) wird fortgesetzt.
*   **Fallback Ad-Fehler:** S016 zeigt Ad-Fehler-State, kein Reward.
*   **Fallback Ad übersprungen:** S016 zeigt Kein-Reward-State.

#### Flow 7: Datenschutz & Transparenz — DSGVO-Detail-Flow
*   **Screens:** S002 → S017 (Settings) → S002 (Consent-Einstellungen)
*   **Taps bis vollständiger Information:** 2 (Einstellungen-Link auf S002 → Datenschutz-Link auf S017)
*   **Zeitbudget:** Nutzer-gesteuert.
*   **Beschreibung:** Consent-Modal erscheint (S002) → Nutzer navigiert zu Einstellungen (S017) → wählt Datenschutz-Option → kehrt zu S002 zurück, um Consent-Einstellungen zu ändern.
*   **Fallback Offline auf S017:** Offline-Cache-State liefert zuletzt geladene Version der Einstellungen.
*   **Fallback S002 ohne Interaktion:** Modal bleibt persistent, App-Nutzung nicht möglich bis Consent-Entscheidung getroffen wurde.

### Edge Cases (8 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| Offline bei App-Start | S001, S005, S006 | S001 Engine-Init lädt aus lokalem Cache. S005 zeigt Offline-State-Banner. S006 Level-Start gesperrt, Offline-Hinweis. |
| KI-Level-Generierung Fehler/Timeout | S006, S007 | S006 wechselt in Fehler-Abbruch-State mit Retry-Option. Kein leeres Ergebnis. Timeout-Warnung bei >50 Sek. |
| ATT-Consent verweigert (iOS) | S002, S003, S004 | S002 zeigt ATT-Pre-Primer. Bei Ablehnung: App funktioniert vollständig, keine Personalisierung durch ATT-Daten. |
| Upload-Datei mit falschem Format/zu groß | N/A (kein File Upload in EchoMatch) | N/A |
| Consent komplett abgelehnt | S002, alle Analytics | App funktioniert vollständig. Analytics werden nicht initialisiert. Keine Einschränkung der Spielfunktion. |
| Level erkennt keine Skills in hochgeladener Datei | N/A (kein Skill-Upload) | N/A |
| Battle-Pass Saison abgelaufen | S012 | S012 wechselt in "Saison-Abgelaufen"-State mit Teaser für nächste Saison. |
| Engine-Fehler beim App-Start | S001, S018 | S001 wechselt in Engine-Fehler-State mit Retry-Option. Nach 3 Fehlversuchen Weiterleitung zu S018. |

### Phase-B Screens (8 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S020 | Kaltstart Personalisierungs-Fallback | Spielstil-Auswahl bei fehlendem Tracking | Nicht sichtbar (nur bei ATT-Ablehnung) |
| S021 | Offline Error Screen | Generischer Offline-Fehler-Screen | S001, S005 zeigen Banner |
| S022 | A/B Test Variant Loader | Lädt A/B-Test-Konfiguration | Nicht sichtbar (Hintergrundprozess) |
| S023 | Live-Ops Event Hub | Übersicht aktueller und kommender Events | Coming-Soon-Badge auf S005 |
| S024 | Gilden / Teams | Team-Verwaltung, Team-Challenges | Coming-Soon-Badge auf S010 |
| S025 | PvP-Modus Lobby | Auswahl Gegner, Matchmaking | Coming-Soon-Badge auf S010 |
| S026 | Level Editor | Erstellung eigener Level (UGC) | Nicht sichtbar |
| S027 | Profil / Statistiken (Full) | Detaillierte Spielerstatistiken, Achievements | S017 zeigt Basis-Profil |

---

## 7. Asset-Liste (VERBINDLICH)

### Vollständige Asset-Tabelle (107 Assets)

| ID | Asset | Beschreibung | Screen(s) | Stat/Dyn | Warum kein Text | Varianten | Dark Mode | Launch-krit. |
|---|---|---|---|---|---|---|---|---|
| **APP-BRANDING** | | | | | | | | |
| A001 | App-Icon | Haupt-App-Icon fuer App Store und Google Play sowie Home-Screen. Zeigt das EchoM | S001, Alle | statisch | Store-Pflicht, visueller Ersterkennungswert, kein  | 18 | kontrastsicher | JA |
| A002 | Splash-Screen-Logo | EchoMatch-Volllogo mit Wortmarke und Icon fuer den Splash-Screen S001. Zentriert | S001 | statisch | App-Name als reiner Text wirkt unprofessionell und | 2 | kontrastsicher | JA |
| A062 | Store-Feature-Grafik (App Store Listing) | Feature-Grafik fuer Google Play Store (1024x500px) und Screenshots-Set fuer App  | Alle | statisch | Pflichtasset fuer Store-Listing; ohne Screenshot-S | 6 | nein | JA |
| A063 | Notification-Icon (klein, monochrom) | Kleines monochromes Icon fuer Android-Push-Notifications und iOS-Notification-Ba | S014 | statisch | Android erfordert monochromates Notification-Icon; | 2 | kontrastsicher | JA |
| **GAMEPLAY-ASSETS** | | | | | | | | |
| A009 | Match-3-Spielstein-Sprite-Set | Vollstaendiges Sprite-Set aller Match-3-Spielsteine fuer S003 und S006. Mindeste | S003, S006 | animiert | Text-Labels auf Spielsteinen machen das Spiel unsp | 4 | kontrastsicher | JA |
| A010 | Match-3-Spielfeld-Hintergrund | Vollbild-Hintergrund fuer das Spielfeld in S003 und S006. Thematisch zur Spielwe | S003, S006 | statisch | Einfarbiger Hintergrund laesst Spielfeld uninspiri | 4 | nein | JA |
| A011 | Match-3-Spezialstein-Sprites | Sprites fuer Sonder- und Booster-Steine im Spielfeld (z.B. Bombe, Blitz-Stein, R | S006 | animiert | Sondersteine muessen durch Aussehen sofort als mae | 2 | kontrastsicher | JA |
| A013 | Spielfeld-Grid-Rahmen | Visueller Rahmen und Zellen-Design des Match-3-Grids in S003 und S006. Beinhalte | S003, S006 | statisch | Unstyled Grid-Lines wirken wie Debug-Ansicht; das  | 2 | nein | JA |
| A065 | Spielfeld-Ziel-Indikator-Icons | Icon-Set fuer verschiedene Level-Zieltypen in S006 (Sammle X Steine, Zerstoere X | S006, S008 | statisch | Level-Ziele muessen auf einen Blick verstanden wer | 1 | kontrastsicher | JA |
| A066 | Hindernisse und Spezialzellen-Sprites | Sprite-Set fuer Level-Hindernisse (Eis, Stein, Kette, Nebel) in S006. Jedes Hind | S006 | animiert | Hindernisse als farbige Bloecke ohne Design sind v | 1 | nein | JA |
| **UI-ELEMENTE** | | | | | | | | |
| A004 | Ladebalken / Loading-Indicator | Visueller Fortschrittsbalken oder animierter Spinner fuer S001 Ladevorgang. Gebr | S001, S006, S011, S012 | animiert | System-Spinner signalisiert nicht fertige App; Pro | 1 | ja | JA |
| A014 | Zuege-Anzeige / Move-Counter | Visuelles UI-Element das verbleibende Zuege im Spielfeld S006 anzeigt. Beinhalte | S006 | animiert | Nackte Zahl ohne visuellen Kontext vermittelt kein | 1 | ja | JA |
| A015 | Punkte-/Score-Anzeige HUD | Score-Counter im Spielfeld-HUD von S006. Beinhaltet animierten Score-Zuwachs (Za | S006 | animiert | Statische Zahl ohne Fortschrittsindikator gibt kei | 1 | ja | JA |
| A016 | Booster-Icons im Spielfeld | Icon-Set fuer alle verfuegbaren Booster in S006 (z.B. Hammer, Shuffle, Extra-Mov | S006 | animiert | Text-Buttons fuer Booster sind nicht intuitiv bedi | 1 | kontrastsicher | JA |
| A020 | Reward-Item-Icons | Icon-Set fuer alle Reward-Items die auf S007, S012, S013 angezeigt werden (Muenz | S007, S012, S013, S011 | statisch | Text-Labels fuer Rewards (z.B. '50 Coins') ohne Ic | 1 | kontrastsicher | JA |
| A022 | Level-Knoten-Icons | Icon-Sprites fuer Level-Knoten auf der Map S008. Zustaende: Gesperrt (Schloss),  | S008 | animiert | Level-Status muss auf einen Blick erkennbar sein;  | 1 | kontrastsicher | JA |
| A029 | Daily-Quest-Card-Design | Visuell gestaltete Quest-Karte fuer S005 und S013. Zeigt Quest-Icon, Fortschritt | S005, S013 | animiert | Text-Liste von Quests ohne Card-Design hat keinen  | 2 | ja | JA |
| A030 | Quest-Icon-Set | Thematische Icons fuer verschiedene Quest-Typen in S013 (z.B. Schwert fuer Kampf | S013, S005 | statisch | Quest-Typ muss auf einen Blick unterscheidbar sein | 1 | kontrastsicher | nein |
| A031 | Battle-Pass-Tier-Reward-Visualisierung | Horizontale oder vertikale Tier-Leiste fuer S012 mit jedem Reward-Tier als visue | S012 | animiert | Tabelle von Reward-Namen ohne visuelle Darstellung | 1 | ja | JA |
| A033 | Saison-Timer-Visual | Visueller Countdown-Timer fuer S012 und S013. Zeigt verbleibende Saison-/Quest-Z | S012, S013 | animiert | Reiner Text-Countdown ohne visuelles Dringlichkeit | 1 | ja | nein |
| A034 | Shop-Angebots-Karten | Visuell gestaltete Angebotskarten fuer S011. Jeder IAP hat eigene Card mit Produ | S011 | statisch | Textliste von Preisen ohne visuellen Angebots-Cont | 2 | nein | JA |
| A035 | Foot-in-Door-Angebot-Highlight | Spezielles visuelles Highlight-Design fuer das erste guenstige IAP-Angebot in S0 | S011 | animiert | Das Einstiegsangebot muss sich visuell klar von an | 1 | nein | JA |
| A036 | Waehrungs-Icons (Soft und Hard Currency) | Hochwertige Icons fuer alle In-Game-Waehrungen (z.B. Muenzen als Soft Currency,  | S006, S007, S011, S012, S013,  | statisch | Text-Label 'Coins: 500' ohne Icon-Visualisierung h | 1 | kontrastsicher | JA |
| A037 | Social-Hub-Avatar-Rahmen | Dekorative Rahmen fuer Spieler-Avatare in S010. Verschiedene Seltenheits-Stufen  | S010, S017 | statisch | Avatare ohne Rahmen-Design sind visuell nicht unte | 1 | kontrastsicher | nein |
| A038 | Challenge-Card-Design | Visuell gestaltete Challenge-Karte fuer S010. Zeigt herausfordernden Spieler-Ava | S010 | animiert | Challenge-Einladung als reiner Text-Eintrag erzeug | 1 | ja | nein |
| A040 | Share-Result-Bild-Template | Visuelles Template fuer generiertes Share-Bild in S015. Zeigt Score, Level-Numme | S015, S007 | statisch | Geteilter reiner Text hat keinen viralen Effekt; b | 2 | nein | nein |
| A043 | Profil-Spieler-Avatar-Placeholder | Standard-Avatar-Illustration fuer neuen Spieler ohne eigenes Bild in S017. Zeigt | S017, S010 | statisch | Generisches Personen-Icon oder Initialen-Kreis bri | 1 | kontrastsicher | nein |
| A046 | Tab-Bar-Icons | Icon-Set fuer alle 5 Tab-Bar-Eintraege (Home, Puzzle, Story, Social, Shop). Jede | S005, S008, S009, S010, S011 | statisch | Text-only Tab-Bar ist auf kleinen Screens schwer t | 2 | ja | JA |
| A048 | Kaltstart-Personalisierungs-Auswahlkarten | Visuell gestaltete Auswahlkarten fuer S020 Spielstil-Praeferenz-Auswahl. Jede Ka | S020 | animiert | Text-basierte Radio-Buttons fuer Spielstil-Auswahl | 1 | nein | JA |
| A049 | Onboarding-Hint-Pfeile und Tutorial-Overlays | Animierte Pfeile, Finger-Tap-Animationen und Highlight-Overlays fuer S003 Tutori | S003 | animiert | Text-Tutorials unterbrechen den impliziten Trackin | 1 | kontrastsicher | JA |
| A052 | Beta-Feedback-Rating-Sterne | Interaktives Stern-Bewertungs-Element fuer S019 Beta-Feedback-Screen. Tappbare S | S019 | animiert | Numerische Skala 1-5 ohne visuelle Sterne hat nied | 1 | ja | nein |
| A055 | Coming-Soon-Badge fuer Phase-B | Visuelles Coming-Soon-Badge fuer S010 Social-Hub (Live-Ops Event Hub Teaser) und | S010 | animiert | Text-Label 'Demnächst verfügbar' ohne visuellen Ba | 1 | kontrastsicher | nein |
| A057 | Leaderboard-Top-3-Podest-Design | Visuelles Podest-Design fuer Top-3-Preview im Social-Hub S010 (Phase-A-Version). | S010 | statisch | Nummerierte Liste fuer Top-3 hat keinen Trophy-App | 1 | ja | nein |
| A058 | Haptic-Feedback-Toggle-Icon | Icon fuer Haptic-Feedback-Toggle in S018 Einstellungen. An- und Aus-State visuel | S018 | statisch | Standard-System-Toggle ohne thematisches Icon bric | 1 | ja | nein |
| A059 | Einstellungen-Kategorie-Icons | Icon-Set fuer alle Einstellungs-Kategorien in S018 (Sound, Haptic, Benachrichtig | S018 | statisch | Generic System-Icons in Einstellungen brechen das  | 1 | ja | nein |
| A067 | Social-Nudge-Banner-Design | Visuell gestaltetes Banner fuer Social-Nudge nach Session in S007 und S005. Zeig | S007, S005 | animiert | Reiner Text-Hinweis auf Social-Features nach Sessi | 1 | ja | nein |
| A068 | Friend-Challenge-Card | Visuelle Karte fuer ausstehende Friend-Challenges im Social Hub. Zeigt Gegner-Av | S010 | dynamic | Challenge-Kontext (Gegner, Level, Timer) ist nutze | 1 | ja | JA |
| A069 | Leaderboard-Rang-Badge | Kleines Badge-Element das den aktuellen Rang des Spielers (Top 3, Top 10, Top 50 | S010, S005 | dynamic | Rang-Visualisierung durch Farbe und Icon kommunizi | 1 | ja | JA |
| A070 | Leaderboard-Eintrag-Row | Einzelne Zeile im Freundes-Leaderboard: Avatar links, Spielername, Punktzahl, Ra | S010 | dynamic | Leaderboard ohne visuelle Differenzierung zwischen | 1 | ja | JA |
| A071 | Social-Invite-Banner | Banner-Komponente im Social Hub fuer den Zustand Keine-Freunde. Illustriertes le | S010 | static | Empty-State ohne Illustration wirkt abweisend und  | 1 | ja | JA |
| A072 | Share-Card-Level-Gewonnen | Visuell ansprechende Share-Card fuer gewonnene Level. Enthaelt: Spielername, Lev | S007, S015 | dynamic | Generischer System-Share-Sheet ohne Custom-Card ve | 2 | nein | JA |
| A073 | Share-Card-Highscore-Milestone | Spezielle Share-Card fuer Milestone-Events (Erster Highscore, Level-50-Abschluss | S007, S015 | dynamic | Milestone-Momente sind emotional aufgeladen und er | 2 | nein | nein |
| A074 | Share-Sheet-Destination-Icons | Icon-Set fuer Social-Share-Destination-Buttons im Share-Sheet Overlay: Instagram | S015 | static | System-native Share-Sheets sind nicht branded und  | 1 | ja | JA |
| A075 | Team-Event-Teaser-Card | Phase-A-Platzhalter-Card im Social Hub fuer kuenftige Gilden/Team-Events (S024). | S010 | static | Leerer Tab oder hidden Feature verschenkt Anticipa | 1 | ja | nein |
| **ILLUSTRATIONEN** | | | | | | | | |
| A003 | Splash-Screen-Hintergrund | Vollbild-Hintergrundbild fuer S001 Splash-Screen. Atmosphaerisches Artwork das E | S001 | statisch | Einfarbiger oder Text-Hintergrund zerstoert ersten | 4 | nein | JA |
| A005 | Offline-Error-Illustration | Charakterillustration oder thematisches Bild fuer S021 Offline-Fehlerzustand. Ze | S021, S001 | statisch | Reiner Text-Fehler frustriert, Illustration schaff | 1 | ja | nein |
| A006 | DSGVO-Consent-Illustration | Kleine thematische Illustration oder Icon-Set fuer S002 Consent-Modal. Visualisi | S002 | statisch | Reines Rechtstext-Modal ohne visuelle Auflockerung | 2 | ja | JA |
| A007 | ATT-Prompt-Visual | Pre-Permission-Erklaerungsbild fuer iOS ATT-Prompt in S002. Zeigt visuell den Nu | S002 | statisch | Ohne erklaerende Illustration ist ATT-Ablehnungsra | 1 | ja | JA |
| A008 | Minderjaerigen-Block-Illustration | Freundliche aber klare Illustration fuer S002 COPPA-Block-State. Zeigt altersger | S002 | statisch | Reiner Fehlertext bei Minderjaerigen-Block wirkt a | 1 | nein | JA |
| A018 | Level-Verloren-Illustration | Empathische aber nicht demotivierende Illustration fuer S007 Verloren-State. Cha | S007 | statisch | Reiner Verlieren-Text ohne emotionale visuelle Auf | 1 | nein | JA |
| A021 | Level-Map-Pfad-Grafik | Visueller Fortschrittspfad fuer S008 Level-Map. Geschwungener Weg durch thematis | S008 | statisch | Eine Liste von Level-Nummern ist keine Level-Map;  | 1 | nein | JA |
| A023 | Level-Map-Hintergrund-Welten | Thematische Hintergrundillustrationen fuer verschiedene Welten auf der Level-Map | S008 | statisch | Einfarbiger Hintergrund macht alle Welten identisc | 2 | nein | JA |
| A028 | Home Hub Hero-Banner | Dynamisches Hero-Banner-Artwork fuer S005 Home Hub. Wechselt je nach Tageszeit,  | S005 | statisch | Textliste auf dem Home Screen hat keinen Appeal un | 3 | nein | JA |
| A032 | Battle-Pass-Saison-Banner | Thematisches Key-Art fuer die aktuelle Battle-Pass-Saison auf S012. Zeigt Saison | S012, S005 | statisch | Saison-Name ohne Artwork hat keinen Sammel-Appeal  | 1 | nein | JA |
| A039 | Keine-Freunde-Empty-State-Illustration | Freundliche Illustration fuer S010 Normal-Keine-Freunde-State. Zeigt einladende  | S010 | statisch | Leere Liste oder Text 'Keine Freunde' ohne Illustr | 1 | ja | nein |
| A041 | Rewarded-Ad-Angebots-Illustration | Ansprechende Illustration fuer S016 Rewarded-Ad-Angebotsscreen. Zeigt Reward vis | S016 | statisch | Text-Angebot 'Schaue Werbung fuer Extra-Leben' ohn | 1 | nein | nein |
| A045 | Sync-Fehler-Illustration | Thematische Illustration fuer S017 Sync-Fehler-State. Zeigt Verbindungsproblem i | S017 | statisch | Generic error icon bricht Spielwelt-Immersion | 1 | ja | nein |
| A047 | Push-Notification-Opt-In-Illustration | Erklaerende Illustration fuer S014 Push-Opt-In-Modal. Zeigt visuell den Nutzen v | S014 | statisch | Reiner Text-Erklaerungsscreen ohne visuellen Anrei | 2 | nein | nein |
| A056 | Phase-B-Teaser-Illustrationen | Teaser-Artwork fuer S023 Live-Ops Event Hub und S024 Gilden-Card im Social-Hub.  | S010 | statisch | Text-Beschreibung kommender Features erzeugt keine | 1 | nein | nein |
| **ANIMATIONEN & EFFEKTE** | | | | | | | | |
| A012 | Match-Animation-Effekte | Partikel- und Burst-Animationen fuer erfolgreiche Match-3-Kombinationen in S003  | S003, S006 | animiert | Ohne visuelle Match-Explosion fehlt das Kernbefrie | 1 | nein | JA |
| A017 | Level-Gewonnen-Animation | Vollbild-Gewinn-Animation fuer S007 Gewonnen-State. Konfetti, Sterne, Charakter- | S007 | animiert | Text 'Sie haben gewonnen' ohne visuelle Feier-Anim | 1 | nein | JA |
| A019 | Stern-Bewertungs-Animation | 1-3 Stern-Vergabe-Animation fuer S007 nach Level-Abschluss. Jeder Stern faellt e | S007 | animiert | Sterne sind der visuelle Leistungsindikator; ohne  | 1 | nein | JA |
| A042 | Ad-Lade-Animation | Kurze Lade-Animation fuer S016 Ad-Laedt-State. Haelt Nutzer beschaeftigt waehren | S016 | animiert | Blank-Screen oder reiner Spinner waehrend Ad laedt | 1 | nein | nein |
| A050 | KI-Level-Lade-Platzhalter-Animation | Thematische Animations-Szene fuer S006 KI-Level-Latenz-Warten-State. Zeigt Spiel | S006, S008 | animiert | Ladebildschirm mit Text 'KI generiert Level...' oh | 1 | nein | JA |
| A051 | Neues-Level-Freischalten-Animation | Feiernde Animation wenn neues Level auf der Map S008 freigeschaltet wird. Level- | S008 | animiert | Neues Level erscheint ohne Animation wirkt wie Bug | 1 | nein | nein |
| A053 | Feedback-Gesendet-Danke-Animation | Kurze Bestaetigungs-Animation fuer S019 Gesendet-Danke-State. Haekchen-Animation | S019 | animiert | Reiner Text 'Danke' ohne Animation macht Feedback- | 1 | nein | nein |
| A054 | A/B-Test-Loader-Animation | Dezente Lade-Animation fuer S022 A/B-Test-Konfigurations-Loader. Muss transparen | S022, S001 | animiert | Blank-Screen waehrend A/B-Zuweisung signalisiert A | 1 | ja | JA |
| A060 | Reward-Freischalten-Animation | Animiertes Freischalten von Rewards auf S012 Battle-Pass und S013 Quest-Abschlus | S012, S013, S007 | animiert | Reward-Erhalt ohne Animation ist der groesste verp | 1 | nein | JA |
| A061 | Quest-Abgeschlossen-Checkmark-Animation | Animiertes Checkmark fuer Quest-Abschluss in S013 und S005. Gruen ausfullendes H | S013, S005 | animiert | Quest-Status-Aenderung ohne Animation wird vom Spi | 1 | ja | nein |
| A064 | IAP-Kauf-Bestaetigung-Animation | Kurze Feier-Animation auf S011 nach erfolgreichem IAP-Kauf. Reward-Items regnen  | S011 | animiert | Stiller Text 'Kauf erfolgreich' nach IAP ist verpa | 1 | nein | nein |
| **DATENVISUALISIERUNG** | | | | | | | | |
| A044 | Statistik-Visualisierungs-Grafiken | Visuelle Charts und Grafiken fuer Spieler-Statistiken in S017. Beinhaltet Fortsc | S017 | animiert | Nackte Zahlen fuer Statistiken haben keine motivie | 1 | ja | nein |
| **STORY / NARRATIVE ASSETS** | | | | | | | | |
| A024 | Narrative-Hook-Sequenz-Artwork | Vollbild-Story-Artwork fuer S004 Narrative Hook. 3-5 Panels oder ein kontinuierl | S004 | animiert | Text-Beschreibung einer Story-Szene ist kein emoti | 1 | nein | JA |
| A025 | Story-Charakter-Portraits | Portrait-Illustrationen aller Haupt-Story-Charaktere fuer S004, S009 und Narrati | S004, S009 | statisch | Namensbeschriftungen ohne Charakterbild lassen Sto | 3 | nein | JA |
| A026 | Story-Kapitel-Cover-Illustrationen | Cover-Artwork fuer jedes Story-Kapitel in S009. Thematisches Bild das Kapitel-In | S009 | statisch | Kapitel-Titel als Text ohne Bild haben keinen emot | 1 | nein | JA |
| A027 | Story-Scene-Hintergruende | Hintergrundillustrationen fuer Story-Sequenzen in S004 und S009. Verschiedene Or | S004, S009 | statisch | Dialoge vor leerem Hintergrund oder Farbflaeche ze | 3 | nein | JA |
| **MONETARISIERUNGS-ASSETS** | | | | | | | | |
| A076 | Battle-Pass-Fortschrittsbalken | Horizontale Fortschrittsanzeige des Battle-Pass mit aktueller XP-Position, naech | S012, S005 | dynamic | Battle-Pass-Fortschritt ohne visuell befriedigende | 1 | ja | JA |
| A077 | Battle-Pass-Reward-Icons-Set-Free | Vollstaendiges Icon-Set fuer alle Free-Tier-Battle-Pass-Rewards einer Saison (ca | S012 | static | Generische Reward-Symbole ohne eigenstaendiges Des | 1 | ja | JA |
| A078 | Battle-Pass-Reward-Icons-Set-Premium | Vollstaendiges Icon-Set fuer alle Premium-Tier-Battle-Pass-Rewards (ca. 15-20 Ic | S012 | static | Premium-Rewards muessen visuell klar wertvoller wi | 1 | ja | JA |
| A079 | Battle-Pass-Saison-Timer | Countdown-Timer-Komponente auf S012 und S005 die verbleibende Saison-Zeit anzeig | S012, S005 | dynamic | FOMO-Timer ist dokumentierter Conversion-Treiber f | 1 | ja | JA |
| A080 | Battle-Pass-Upgrade-CTA-Button | Prominenter Kauf-Button fuer den Battle-Pass-Upgrade auf S012. Zeigt Preis ($4,9 | S012 | static | Kauf-CTA ist direkter Revenue-Touchpoint und muss  | 1 | ja | JA |
| A081 | Foot-in-Door-Angebot-Banner | Spezieller Erstkaeufer-Angebots-Banner im Shop (S011). Zeitlimitiertes Einstiegs | S011 | dynamic | Foot-in-Door-Erstangebot ist die primaere Conversi | 1 | ja | JA |
| A082 | Shop-Item-Card | Wiederverwendbare Produkt-Card-Komponente fuer alle Shop-Eintraege. Besteht aus: | S011 | dynamic | Shop ohne eigenstaendige Card-Komponente wirkt wie | 1 | ja | JA |
| A083 | Rewarded-Ad-Angebot-Illustration | Illustration fuer den Rewarded-Ad-Interstitial (S016) im Angebot-Aktiv-State. Ze | S016 | static | Rewarded-Ad-Opt-In-Rate haengt direkt davon ab wie | 1 | ja | JA |
| A084 | Rewarded-Ad-Fehler-Illustration | Illustration fuer den Ad-Fehler-Fallback-State auf S016. Freundliches Fehler-Mot | S016 | static | Ad-Fehler-States ohne eigene Illustration wirken a | 1 | ja | nein |
| A085 | Waehrungs-Icons-Set | Icon-Set fuer alle In-Game-Waehrungen: Muenzen (Soft Currency, gold), Edelsteine | S005, S006, S011, S012, S013 | static | Waehrungs-Icons sind die am haeufigsten wiederholt | 1 | ja | JA |
| A086 | Booster-Icons-Set | Icon-Set fuer alle spielbaren Booster (ca. 4-6 Typen): Bombe, Farb-Wirbel, Zeile | S006, S011, S016 | static | Booster sind sowohl Gameplay-Element als auch Mone | 1 | ja | JA |
| A087 | IAP-Kauf-Bestaetigung-Overlay | Post-Purchase-Bestaetigung nach erfolgreichem IAP. Zeigt: gekauftes Item gross i | S011, S012 | dynamic | Post-Purchase-Moment ist kritisch fuer Kauf-Satisf | 1 | ja | JA |
| A088 | IAP-Fehler-Dialog | Fehlerdialog fuer fehlgeschlagene IAP-Transaktionen auf S011. Klar formulierter  | S011 | static | IAP-Fehler ohne professionell gestalteten Dialog e | 2 | ja | JA |
| **MARKETING-ASSETS** | | | | | | | | |
| A089 | App-Store-Screenshots-Set-iOS | Set aus 6-8 App-Store-Screenshots fuer den iOS App Store (iPhone 6.7 Zoll Format |  | static | App-Store-Screenshots sind der primaere Conversion | 1 | nein | JA |
| A090 | App-Store-Screenshots-Set-Android | Set aus 6-8 App-Store-Screenshots fuer den Google Play Store (Phone-Format 1080x |  | static | Play-Store-Anforderungen unterscheiden sich von Ap | 1 | nein | JA |
| A091 | App-Store-Icon-Varianten | App-Icon in allen benoetigen Groessen und Varianten: iOS (1024x1024px fuer Store |  | static | App-Icon ist der kleinste und gleichzeitig am haeu | 2 | nein | JA |
| A092 | App-Preview-Video-Thumbnail | Thumbnail/Poster-Frame fuer das App-Preview-Video im App Store und Play Store. Z |  | static | Video-Thumbnail entscheidet ob Nutzer das Preview- | 2 | nein | JA |
| A093 | Press-Kit-Cover-Visual | Hochaufloesendes Key-Art fuer Press-Kit und PR-Verwendung. Zeigt EchoMatch-Chara |  | static | Press-Kit ohne professionelles Key-Art-Visual wird | 2 | nein | nein |
| A094 | Social-Media-Post-Templates | Template-Set fuer Social-Media-Marketing-Posts: Instagram-Feed-Post (1080x1080px |  | static | Social-Media-Posts ohne konsistente Templates fueh | 1 | nein | nein |
| A095 | TikTok-Ad-Creative-Frame-Overlay | Visuelles Overlay-Frame-System fuer TikTok-Ad-Creatives: Failed-Level-Hook-Templ |  | static | TikTok-Ads erfordern spezifische Creative-Struktur | 1 | nein | nein |
| A096 | Meta-Ad-Creative-Templates | Visual-Templates fuer Meta-Ads (Facebook/Instagram): Carousel-Card-Template (108 |  | static | Meta ist der primaere UA-Kanal — professionelle Ad | 1 | nein | JA |
| A097 | Discord-Server-Banner und Branding | Discord-Server-Branding-Paket: Server-Banner (960x540px), Server-Icon (512x512px |  | static | Discord ist der primaere Beta-Community-Hub — unpr | 1 | nein | nein |
| **LEGAL-UI** | | | | | | | | |
| A098 | DSGVO-Consent-Screen-Layout | Vollstaendiges Screen-Layout fuer S002 DSGVO-Consent. Enthaelt: EchoMatch-Logo o | S002 | static | DSGVO-Consent-Screens sind rechtlich verpflichtend | 2 | ja | JA |
| A099 | ATT-Pre-Prompt-Illustration | Custom-Erklaerungsscreen vor dem iOS-System-ATT-Dialog auf S002. Zeigt freundlic | S002 | static | ATT-Opt-In-Rate ist direkt revenue-relevant da Tra | 1 | ja | JA |
| A100 | COPPA-Alterscheck-UI | Altersverifikations-Interface auf S002 fuer COPPA-Compliance. Numerische Jahrgan | S002 | static | COPPA-Verletzungen sind mit Bussgeldern bis $50.00 | 1 | ja | JA |
| A101 | Minderjaehrigen-Blocked-Screen | Screen der erscheint wenn COPPA-Alterscheck ergibt dass Nutzer unter 13 Jahre al | S002 | static | Fehlendes oder schlecht gestaltetes Blocked-Screen | 1 | ja | JA |
| A102 | Datenschutz-Consent-Toggle-Komponente | Wiederverwendbare Toggle-Komponente fuer Datenschutz-Einstellungen. Besteht aus: | S002, S018 | static | Consent-Toggles sind rechtlich kritische UI-Elemen | 1 | ja | JA |
| A103 | Push-Opt-In-Erklaer-Illustration | Illustration fuer S014 Push-Notification-Opt-In-Screen. Zeigt freundlichen Erkla | S014 | static | Push-Opt-In-Rate ist direkt retention-relevant — c | 2 | ja | JA |
| A104 | Battle-Pass-Content-Visibility-Compliance-Badge | Kleines Informations-Element auf S012 das alle Battle-Pass-Inhalte (auch Premium | S012 | static | EU-Regulierung (insbesondere UK CMA und Belgische  | 1 | ja | JA |
| A105 | Impressum-und-Datenschutz-Link-Footer | Standardisierter Footer-Bereich mit Links zu: Datenschutzerklaerung, Nutzungsbed | S018, S002 | static | Fehlendes Impressum ist in Deutschland Abmahnungsr | 1 | ja | JA |
| A106 | Kaltstart-Personalisierungs-Auswahl-UI | UI-Komponenten fuer S020 Kaltstart-Personalisierungs-Fallback. Enthaelt: erklaer | S020 | static | S020 ist kritisch fuer KI-Personalisierung bei bis | 1 | ja | JA |
| A107 | Update-Required-Screen-Visual | Visueller Screen fuer den Update-Required-State von S001. Erklaert freundlich da | S001 | static | Force-Update-Screens die wie System-Alerts aussehe | 2 | ja | JA |

### Beschaffungswege pro Asset

| Kategorie | Anzahl Assets | Gesamt-Kosten EUR | Ø pro Asset | Quellen-Mix |
|---|---|---|---|---|
| App-Branding | 4 | 860 | 215 | 100% Custom Design (Figma + Illustrator + Photoshop) |
| Gameplay-Assets | 6 | 1.220 | 203 | 50% AI-generiert + Custom Polish (Midjourney/Firefly + Figma), 30% Custom Design, 20% Free/Open-Source |
| UI-Elemente | 27 | 2.973 | 110 | 40% Custom Design, 40% AI-generiert + Custom, 20% Lottie Free |
| Illustrationen | 15 | 1.120 | 75 | 50% AI-generiert + Custom Polish (Midjourney/Firefly + Photoshop), 30% Custom Design, 20% Free/Open-Source |
| Animationen & Effekte | 11 | 1.435 | 130 | 50% Custom Design (After Effects + Lottie), 30% Lottie Free, 20% Lottie Premium |
| Datenvisualisierung | 1 | 120 | 120 | 100% Native + Custom (React Native Charts + Figma) |
| Story / Narrative | 4 | 1.240 | 310 | 60% AI-generiert + Custom Polish (Midjourney + Photoshop), 40% Custom Design |
| Monetarisierungs-Assets | 13 | 1.600 | 123 | 60% Custom Design, 40% AI-generiert + Custom |
| Marketing-Assets | 9 | 1.000 | 111 | 50% Custom Design, 30% AI-generiert + Custom, 20% Free/Open-Source |
| Legal-UI | 10 | 800 | 80 | 50% Custom Design, 30% Free/Open-Source, 20% AI-generiert + Custom |
| **GESAMT** | **107** | **~12.368** | **~115** | |

### Format-Anforderungen pro Plattform

| Asset-Typ | Format | Auflösung/Größe | Tool | Hinweise |
|---|---|---|---|---|
| unity_sprites | PNG / Sprite Sheet | @2x (3840x2160 Master) / @3x (5760x3240 Master) | TexturePacker 7.x → Unity Importer | Keine POT-Pflicht ab Unity 2022+, aber 2er-Potenzen empfohlen für Kompression |
| game_piece_sprites | PNG Sprite Sheet via TexturePacker | 256x256px pro Frame (Master) | TexturePacker | Für Bloom-Effekte: Emission-Map als separater Kanal oder Textur |
| backgrounds | PNG | 1920x1080px @2x (3840x2160 Master) | Photoshop | Hintergrund-Layer separat exportieren (BG-Layer, Mid-Layer, FX-Layer) für Parallax |
| icons | SVG für UI-Icons, PNG @2x/@3x für In-Game | 24x24dp, 48x48dp, 96x96dp | Figma, Illustrator | SVG für Skalierbarkeit, PNG für Performance in Unity |
| animations | Lottie JSON (UI-Animationen, Loading, Feedback) | Max 500KB pro JSON | After Effects 2025 + Bodymovin 5.x Plugin | Statisches PNG @2x wenn Lottie >500KB oder Runtime-Performance-Problem |
| app_icon_ios | PNG | 1024x1024px (Store), 180x180px (Home Screen) | Figma Export + Asset Catalog Xcode | Kein Alpha-Kanal, kein Gradient über gesamte Fläche (Apple Review Richtlinie) |
| app_icon_android | PNG Adaptive Icon | Foreground + Background als separate Layer im XML | Android Studio Asset Studio + Figma Export | Adaptive Icon: Foreground + Background als separate Layer im XML definiert |
| screenshots_store | PNG (kein JPEG, keine Kompressionsartefakte) | iOS: 1290x2796px, 1242x2688px; Android: 1080x1920px | Figma Store-Screenshot-Template + Photoshop Finalisierung | 6-8 Screenshots pro Plattform |
| audio | WAV (Master) + OGG/AAC (komprimiert) | 44.1 kHz, 16-bit Stereo | Audacity, Adobe Audition | Loop-Points in BGM-Tracks testen (kein Click am Loop-Punkt) |
| fonts | TTF / OTF Master → Unity Font Asset (TMP) | Variable | TextMesh Pro Font Asset Creator | Lizenz-Prüfung für Mobile-Embedding vor Integration (SIL OFL oder Commercial-Lizenz) |

### Plattform-Varianten Anzahl
*   **Gesamt Plattform-Varianten:** 164 (inkl. Auflösungen, States)

### Dark-Mode-Varianten
*   **Gesamt Dark-Mode-Varianten nötig:** 65

---

## 8. KI-Produktions-Warnungen (VERBINDLICH — KRITISCH)

### Warnungen aus dem Visual Audit

| # | Screen | Stelle | Was KI falsch macht | Was stattdessen | Prompt-Anweisung für Produktionslinie |
|---|---|---|---|---|---|
| W01 | S001 Splash | Vollbild-Atmosphären-Artwork hinter dem Logo | Farbverlauf in Brand-Primärfarbe oder `#1A1A2E` Vollton | A003 Splash-Screen-Hintergrund | **VERWENDE `Image(asset: "splash_bg")` als Fullscreen-Layer unter dem Logo. KEIN `Color.fill()` oder Gradient-Code als Ersatz akzeptieren.** |
| W02 | S002 ATT Consent | Erklärendes Bild BEVOR der iOS-System-ATT-Dialog erscheint | Text-only Pre-Permission-Screen mit App-Beschreibung oder gar keinen Pre-Screen | A007 ATT-Prompt-Visual | **IMPLEMENTIERE Pre-Permission-Screen als eigene View mit `Image(asset: "att_explanation_visual")` als zentralem Element. Der System-Dialog wird erst nach Tap auf Erklärungsscreen getriggert. KEIN direktes `requestTrackingAuthorization()` ohne vorherigen Visual-Screen.** |
| W03 | S002 DSGVO | Visuelle Auflockerung neben Rechtstext | Reinen UITextView/ScrollView mit Rechtstext, kein visuelles Element | A006 DSGVO-Consent-Illustration | **PLATZIERE `Image(asset: "consent_illustration")`