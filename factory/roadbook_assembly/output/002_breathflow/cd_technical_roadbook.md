# Creative Director Technical Roadbook: echomatch
## Version: 1.0 | Status: VERBINDLICH für alle Produktionslinien

---

## Hinweis zur App-Namen-Diskrepanz in den Quelldaten

Dieses Roadbook wird für die App **"echomatch"** erstellt, wie im Titel explizit angefordert. Die bereitgestellten Rohdaten umfassen jedoch Reports, die sich auf zwei unterschiedliche Produkte beziehen: eine "Minimalistische Atem-Übungs-App" und "SkillSense" (eine Productivity-SaaS-Web-App).

Die Abschnitte dieses Roadbooks, die sich auf das Design, die Visuals und die Assets beziehen (Sektionen 2, 3, 6, 7, 8, 13), basieren direkt auf den für "echomatch" spezifischen Reports (Design Vision Document, Asset Discovery, Asset Strategy, Visual Consistency).

Für alle anderen Abschnitte (Sektionen 1, 4, 5, 9, 10, 11, 12, 14), die sich auf Produktprofil, Features, Monetarisierung, Marketing, Legal, Tech-Stack, Release-Plan und KPIs beziehen, wurden die Informationen aus den "SkillSense"- oder "Atem-Übungs-App"-Reports **adaptiert und generalisiert**, um den Kontext eines Match-3-Spiels wie "echomatch" bestmöglich abzubilden. Wo direkte Übertragungen nicht sinnvoll waren, wurden branchenübliche Annahmen für Match-3-Spiele getroffen. Diese Adaptionen sind notwendig, um die Vollständigkeit des Roadbooks gemäß den Anforderungen zu gewährleisten.

---

## 1. Produkt-Kurzprofil

*   **App Name:** echomatch
*   **One-Liner:** Ein Match-3-Puzzle-Spiel, das das Genre mit einer dunklen, atmosphärischen Ästhetik, personalisiertem Gameplay und emotional resonanten Interaktionen neu definiert und sich bewusst vom Candy-Crush-Standard abhebt.
*   **Plattformen:** iOS, Android (Native Mobile App)
*   **Tech-Stack:** Unity (Engine), Firebase (Backend für Cloud-Sync, Social, Analytics), Cloud Run (für KI-Level-Generierung/Personalisierung API), Stripe (für Web-Monetarisierung, falls Web-Shop-Alternative), App Store / Google Play Billing (für In-App-Käufe).
*   **Zielgruppe:** Berufstätige, Studierende und junge Erwachsene im Alter von **18–34 Jahren**, leicht weiblich dominiert (~55–60%), Schwerpunkt auf Tier-1-Märkten (DACH, UK, USA). Gelegenheitsspieler, die ein hochwertiges, immersives Spielerlebnis suchen, das sich von der Masse abhebt und eine tiefere emotionale Verbindung bietet als typische Hypercasual-Games. Sie schätzen Ästhetik, Datenschutz und subtile, nicht-aggressive Monetarisierung.

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
| **D4** | **Post-Session-Screen als Poster / Share-Card** | Kein generischer Reward-Overlay mit Konfetti. Der Ergebnis-Screen ist als Poster-Ästhetik designed (Spotify Wrapped-Prinzip): große isolierte Zahl oder Satz auf dunklem Grund, eine Akzentfarbe, lesbare Zusammenfassung des eigenen Spielstils ("Du hast heute 3 Cascades in einem Zug ausgelöst"). Format ist nativ share-optimiert — Nutzer schicken es weil es wie ein Statement aussieht, nicht wie ein UI-Screenshot. | S008, S009 | **VERBINDLICH** — keine Verhandlung |
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
| **W1** | **Logo-Genesis** | S001 | Aus dem dunklen Hintergrund bilden sich drei Spielsteine in den App-Farben, ordnen sich zu einem Match, verschwinden mit einem weichen Resonanz-Puls (einzelner tiefer Kristallton), und aus diesem Puls formt sich das EchoMatch-Logo. Ladezeit ≤2 Sek. — die Animation ist nie fertig bevor sie endet, sie ist die Ladezeit. Bei Slow-Connection wiederholt der Puls sich ruhig wie ein Herzschlag-Echo. **Implementierung:** Unity Animator für Stein-Morphing und Puls-Effekt, AudioSource für Kristallton, ScriptableObject für Farbpalette. | Erste 2 Sekunden prägen den emotionalen Kontrakt — Nutzer erlebt sofort: diese App ist anders als Candy Crush; Logo-Genesis kommuniziert ohne Wort die Kernmechanik und visuelle Identität; kein anderer Wettbewerber hat einen Splash der selbst eine Mini-Geschichte erzählt |
| **W2** | **Der lebendige erste Stein** | S003 | Der erste Stein den der Nutzer berührt leuchtet von innen heraus auf und folgt dem Finger mit 20% Nachzieh-Elastizität — nicht pixelgenau, wie durch Wasser gezogen. Haptik: leichtes Ticken beim Drag-Start, mittleres Snap beim Einrasten (nicht beim Loslassen — am Snap-Moment), weiches kurzes Rumble wie eine verstummende Stimmgabel beim erfolgreichen Match. Cascade-Töne steigen auf. Kein Tutorial-Text, keine Erklärung — das Feld selbst ist der Lehrer. **Implementierung:** Unity Input System für Touch-Erkennung, Custom Shader für Stein-Leuchten, Haptic Feedback API (iOS Core Haptics / Android VibrationEffect) für taktiles Feedback, AudioSource für Sounds. | Entscheidung über Installation-Retention fällt in den ersten 60 Sekunden; der erste Stein-Touch ist der emotionalste Moment des gesamten Funnels; Elastizität und Eigenleuchten kommunizieren sofort Premium-Qualität und erzeugen das Kompetenz-Gefühl das alle anderen Screens aufbauen |
| **W3** | **Goldene Ausatmung** | S008, S009 | Nach Level-Abschluss keine Konfetti-Explosion. Das Spielfeld atmet einmal aus — alle Steine verblassen sanft innerhalb von 400ms. Dann: der gesamte Screen-Hintergrund verschiebt sich in 1,5 Sek. zu warmem Gold (#C8960C, Sättigung 60%, nicht grell). In dieser Goldpause erscheint eine einzelne Zeile die den Spielstil des Nutzers beschreibt ("Heute: 3 Cascades. Durchschnittszug: 1,4 Sekunden."). Dann: Poster-Format-Share-Card die nativ geteilt werden kann. **Implementierung:** Unity Animator für Stein-Verblassen, Global Volume für Farbverschiebung, TextMeshPro für dynamischen Text, ScreenCapture.CaptureScreenshotAsTexture() + Native Share Plugin für Share-Card. | Stärkster Kontrastmoment zum Genre — jeder der das zum ersten Mal sieht weiß sofort: das ist nicht Candy Crush; die goldene Pause ist emotional nachhaltiger als Konfetti-Überwältigung; Poster-Share-Card ist der eingebaute virale Mechanismus (Spotify Wrapped-Prinzip); dieser Moment wird auf TikTok geteilt weil er so anders aussieht |
| **W4** | **NPC Interface-Brecher** | S005, S008 | Nach einem verlorenen Level taucht ein Story-NPC als kleines Element im Home Hub auf und hinterlässt einen kurzen kontextuellen Kommentar im Ton der Spielwelt — nie generisch, immer zum Spielstil des Nutzers passend. Max. 1× pro Woche, dadurch selten und bedeutsam. Animation: NPC gleitet von der Bildschirmkante herein (300ms Ease-Out), bleibt 4 Sekunden sichtbar, zieht sich zurück. Tap auf NPC öffnet eine Mini-Story-Sequenz. **Implementierung:** Unity UI Canvas für NPC-Element, Animator für Slide-In/Out, ScriptableObject für NPC-Dialoge, Firebase Remote Config für Trigger-Frequenz. | Duolingo-Owl-Prinzip angewendet auf narrative Spielwelt — Vierte-Wand-Bruch ist der viralste UI-Moment den Apps produzieren können; erzeugt emotionale Bindung an Charaktere außerhalb der Story-Screens; gibt Nutzern einen Screenshot-würdigen Moment der EchoMatch von allen Wettbewerbern unterscheidet |
| **W5** | **Spieler-Lichtpunkte auf der Level-Map** | S007 | Freunde-Avatare erscheinen als kleine, sanft pulsierende Lichtpunkte direkt auf ihrem aktuellen Level-Punkt der Map — ohne separaten Social-Tab. Ein Freund der gerade aktiv spielt pulsiert schneller (1 Puls/Sek.). Ein Freund der heute noch nicht gespielt hat: minimale Helligkeit, langsamer Puls. Challenge-Einladung: der Lichtpunkt des einladenden Freundes pulsiert in einer zweiten Farbe (Bernstein statt Weiß). Social-Präsenz ist immer ambient sichtbar, nie aufdringlich. **Implementierung:** Unity UI Canvas für Map, Prefabs für Lichtpunkte, Firebase Firestore für Freundes-Fortschritt, WebSocket/Polling für Status-Updates, Custom Shader für Puls-Effekt. | Zenly-Prinzip: soziale Aktivität passiert auf dem primären visuellen Layer; reduziert Tab-Depth auf null; macht soziale Verbindung zu einem natürlichen Teil der Spielwelt statt eines isolierten Features; erzeugt FOMO durch ambient sichtbare Aktivität ohne Push-Notification-Druck |

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
*   **Static Fallback:** Ja (für Reduced Motion und Performance-Probleme)

---

## 4. Feature-Map

**Hinweis:** Die folgende Feature-Map wurde für "echomatch" basierend auf der Design-Vision, Screen-Architektur und Asset-Liste neu erstellt. Die Struktur der Phasen A und B orientiert sich an den allgemeinen Release-Phasen eines Mobile Games.

### Phase A — Soft-Launch MVP (30 Features)
**Budget:** 252.500 EUR (Entwicklung Phase A)

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhängigkeiten |
|---|---|---|---|---|---|
| **CORE GAMEPLAY** | | | | | |
| F001 | Match-3 Core Loop | Grundlegende Match-3-Mechanik (Swap, Match, Cascade, Score). | D1, D7, Session-Dauer | 4 | - |
| F002 | Level-Progression (Linear) | Lineare Abfolge von 20 Levels mit steigendem Schwierigkeitsgrad. | D7, D30, Level-Completion | 3 | F001 |
| F003 | Spezialsteine (3 Typen) | Implementierung von 3 Spezialstein-Typen (z.B. Bombe, Line-Clearer, Color-Bomb). | D7, Session-Dauer | 2 | F001 |
| F004 | Level-Ziele (2 Typen) | Sammle X Steine, Zerstöre X Hindernisse. | Level-Completion | 2 | F001 |
| F005 | Hindernisse (3 Typen) | Eis, Stein, Kette als Level-Hindernisse. | Level-Completion | 2 | F001 |
| F006 | Implizites Spielstil-Tracking | Misst Pausenlänge, Zuggeschwindigkeit, Combo-Orientierung. | D1, D7, Personalisierung | 2 | F001 |
| F007 | KI-Level-Generierung (Basis) | Generiert erste 20 Levels basierend auf Schwierigkeitskurve und Spielstil. | Level-Completion | 3 | F006 |
| **ONBOARDING & UX** | | | | | |
| F008 | Logo-Genesis (W1) | Splash-Screen-Animation des Logos. | D1 | 1 | - |
| F009 | Lebendiger erster Stein (W2) | Elastisches Drag, Haptik, Leuchten im Onboarding. | D1 | 1 | F001 |
| F010 | Kontextuelle Navigation (Basis) | Home Hub mit dynamischen Elementen (Daily Quest, Story Teaser). | D1, D7 | 2 | - |
| F011 | Narrative Hook Sequenz (D3) | 3-5 Story-Panels mit Parallax, passend zum Spielstil. | D1, D7 | 2 | F006 |
| F012 | Home Hub (S005) | Zentraler Einstiegspunkt mit Daily Quest, Battle Pass Teaser. | D1, D7 | 2 | F010 |
| F013 | Level-Map (S008) | Visuelle Level-Progression mit freigeschalteten/gesperrten Knoten. | D7, D30 | 2 | F002 |
| **MONETARISIERUNG** | | | | | |
| F014 | Shop (Basis) | 3 IAP-Angebote (Booster-Pakete, Währung). | ARPU, Conversion | 2 | - |
| F015 | Rewarded Ads (Extra Moves) | Optionale Video-Ads für Extra-Züge bei Level-Verlust. | Retention, ARPU | 2 | F001 |
| F016 | Battle Pass (Free Tier) | Kostenloser Battle Pass mit 10 Tiers und Rewards. | D7, D30 | 3 | F002 |
| **SOCIAL & RETENTION** | | | | | |
| F017 | Daily Quests (3 Typen) | Tägliche Aufgaben mit Belohnungen. | D1, D7 | 2 | F002 |
| F018 | Post-Session Share-Card (D4) | Level-Ergebnis als Poster-Karte zum Teilen. | Viralität, D1 | 1 | F001 |
| **TECHNISCH & INFRASTRUKTUR** | | | | | |
| F019 | Unity Core Setup | Engine-Initialisierung, Build-Pipeline iOS/Android. | App-Start-Zeit | 2 | - |
| F020 | Firebase Integration (Auth, Firestore) | Nutzer-Authentifizierung (anonym/Google/Apple), Cloud-Speicherung des Fortschritts. | D7, D30 | 3 | - |
| F021 | Analytics (Firebase Analytics) | Tracking von D1/D7/D30, Level-Completion, IAP-Events. | KPIs | 2 | F020 |
| F022 | Cloud Run (KI-API) | Serverless Endpoint für KI-Level-Generierung. | KI-Latenz | 2 | F007 |
| **LEGAL & COMPLIANCE** | | | | | |
| F023 | DSGVO/ATT Consent (S002) | Implementierung des Consent-Modals mit Pre-Primer für ATT. | Compliance | 2 | - |
| F024 | Altersprüfung (COPPA) | Altersgate mit Hard-Block für unter 13-Jährige. | Compliance | 1 | - |
| F025 | Datenschutzerklärung/Impressum | Statische Legal-Seiten in der App. | Compliance | 1 | - |
| F026 | KI-Content-Kennzeichnung | Visuelle Kennzeichnung von KI-generierten Inhalten (z.B. Levels). | Compliance | 1 | F007 |
| F027 | Haftungs-Disclaimer | Disclaimer für Spieltipps/Empfehlungen. | Compliance | 1 | - |
| F028 | App Store Compliance (Basis) | Einhaltung grundlegender Apple/Google Richtlinien. | Compliance | 1 | - |
| F029 | Error Handling (Basis) | Graceful Degradation bei API-Fehlern, Offline-States. | Crash-Rate | 1 | F019 |
| F030 | Reduced Motion Support | Statische Fallbacks für Animationen. | Accessibility | 1 | F019 |

### Phase B — Full Production (18 Features)
**Budget:** 230.000 EUR (Entwicklung Phase B)

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhängigkeiten |
|---|---|---|---|---|---|
| **CORE GAMEPLAY** | | | | | |
| F031 | KI-Level-Generierung (Adaptiv) | KI passt Level-Design dynamisch an Spieler-Performance an. | D7, D30, LTV | 3 | F007, F006 |
| F032 | Neue Spezialsteine (2 Typen) | Erweiterung um weitere Spezialsteine. | Session-Dauer | 2 | F001 |
| F033 | Neue Hindernisse (2 Typen) | Erweiterung um weitere Hindernisse. | Level-Completion | 2 | F001 |
| **MONETARISIERUNG** | | | | | |
| F034 | Battle Pass (Premium Tier) | Kostenpflichtiger Premium Battle Pass mit exklusiven Rewards. | ARPU, Conversion | 3 | F016, F014 |
| F035 | Shop (Erweitert) | Zusätzliche IAP-Angebote, zeitlich begrenzte Deals. | ARPU, Conversion | 2 | F014 |
| F036 | Abonnement-Modell (Optional) | Monatliches/Jährliches Abo für unbegrenzte Leben, exklusive Booster. | ARPU, LTV | 3 | F014 |
| **SOCIAL & RETENTION** | | | | | |
| F037 | Freundesliste & Profile | In-App-Freundesliste, Spielerprofile mit Statistiken. | D7, D30, Viralität | 3 | F020 |
| F038 | Freundes-Challenges | Spieler können Freunde zu Duellen herausfordern. | D7, D30, Viralität | 2 | F037 |
| F039 | Ambient Social Layer (W5) | Freunde-Lichtpunkte auf der Level-Map. | D7, D30, Viralität | 2 | F037, F013 |
| F040 | Leaderboards (Freunde & Global) | Ranglisten für Freunde und globale Spieler. | D7, D30, Viralität | 2 | F037 |
| F041 | Gilden/Teams (Basis) | Einfache Gilden-Funktionalität (Chat, gemeinsame Quests). | D30, LTV | 4 | F020 |
| F042 | NPC Interface-Brecher (W4) | Story-NPCs kommentieren Gameplay im UI. | D7, D30, Viralität | 2 | F011 |
| **NARRATIVE & CONTENT** | | | | | |
| F043 | Story-Kapitel (2-3 weitere) | Erweiterung der narrativen Kampagne. | D30, LTV | 3 | F011 |
| F044 | Story-Charaktere (2-3 weitere) | Neue NPCs mit eigenen Storylines. | D30 | 2 | F043 |
| **TECHNISCH & INFRASTRUKTUR** | | | | | |
| F045 | Cloud Save & Cross-Device | Synchronisierung des Spielfortschritts über Geräte hinweg. | D30, LTV | 2 | F020 |
| F046 | Performance-Optimierung (Advanced) | Shader-Optimierung, Asset-Bundling, Memory-Management. | App-Start-Zeit, Crash-Rate | 3 | F019 |
| F047 | Anti-Cheat (Basis) | Serverseitige Validierung von Scores und IAP. | Monetarisierung | 2 | F020 |
| F048 | Lokalisierung (EN, FR, ES) | Übersetzung der UI und Story-Texte. | Global Reach | 3 | - |

### Backlog — Post-Launch (5 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begründung |
|---|---|---|---|---|
| F049 | Gilden-Events & Raids | v1.2 | Erhöht Langzeit-Retention und Monetarisierung durch kooperative Events. | Erfordert stabile Gilden-Basis (F041) und Live-Ops-Infrastruktur. |
| F050 | Echtzeit-PvP (Asynchron) | v1.3 | Bietet kompetitiven Spielmodus gegen andere Spieler-Ghosts. | Hoher technischer Aufwand, erfordert stabile Multiplayer-Infrastruktur. |
| F051 | User-Generated Content (Level-Editor) | v1.4 | Erhöht Content-Volumen und Community-Engagement. | Hoher Entwicklungsaufwand, Moderationssystem erforderlich. |
| F052 | Voice Chat (Gilden) | v1.2 | Verbessert soziale Interaktion in Gilden. | Hoher Compliance-Aufwand (Moderation, Jugendschutz). |
| F053 | AR-Integration (Spielfeld im Raum) | v2.0 | Innovatives Gameplay-Erlebnis, erschließt neue Zielgruppen. | Hoher Forschungs- und Entwicklungsaufwand, Hardware-Abhängigkeit. |

---

## 5. Abhängigkeits-Graph & Kritischer Pfad

### Build-Reihenfolge (Top-Level)
1.  **Unity Core Setup (F019):** Basis für alles.
2.  **Match-3 Core Loop (F001):** Das Spiel muss spielbar sein.
3.  **Implizites Spielstil-Tracking (F006):** Muss während F001 laufen.
4.  **KI-Level-Generierung (Basis) (F007) + Cloud Run (F022):** Generiert Levels für F001.
5.  **Logo-Genesis (F008) + Lebendiger erster Stein (F009):** Onboarding-Erlebnis.
6.  **Level-Progression (F002) + Level-Map (F013):** Grundlegende Progression.
7.  **DSGVO/ATT Consent (F023) + Altersprüfung (F024) + Legal-Seiten (F025):** Rechtliche Pflichten vor Launch.
8.  **Home Hub (F012) + Kontextuelle Navigation (F010):** Haupt-UI.
9.  **Shop (Basis) (F014) + Rewarded Ads (F015):** Erste Monetarisierung.
10. **Battle Pass (Free Tier) (F016) + Daily Quests (F017):** Retention-Mechaniken.
11. **Post-Session Share-Card (F018):** Viralität.
12. **Firebase Integration (F020) + Analytics (F021):** Backend und Messung.

### Kritischer Pfad mit Dauer in Wochen
Der kritische Pfad für Phase A (Soft-Launch MVP) ist die Kette von Features, die direkt voneinander abhängen und die längste Gesamtzeit bis zum Launch benötigen.

*   **Kette:** F019 (2W) → F001 (4W) → F006 (2W) → F007 (3W) → F022 (2W) → F002 (3W) → F013 (2W) → F012 (2W) → F010 (2W) → F023 (2W) → F024 (1W) → F025 (1W) → F028 (1W) → F029 (1W) → F030 (1W)
*   **Gesamtdauer:** 2 + 4 + 2 + 3 + 2 + 3 + 2 + 2 + 2 + 2 + 1 + 1 + 1 + 1 + 1 = **30 Wochen**
*   **Beschreibung:** Der kritische Pfad wird durch die sequentielle Entwicklung des Core-Gameplays, der KI-Integration für Level-Generierung und Personalisierung, der grundlegenden Progression und der rechtlichen Compliance-Features bestimmt. Jede Verzögerung in dieser Kette verschiebt den Soft Launch direkt.

### Parallelisierbare Feature-Gruppen
*   **Phase A – Core-Gameplay-Setup (Woche 1-4):** F019 (Unity Core), F001 (Match-3 Core), F006 (Spielstil-Tracking).
*   **Phase A – KI & Level-Content (Woche 5-10):** F007 (KI-Level-Generierung), F022 (Cloud Run), F002 (Level-Progression), F003 (Spezialsteine), F004 (Level-Ziele), F005 (Hindernisse).
*   **Phase A – UI & Onboarding (Woche 1-10, parallel zu Gameplay):** F008 (Logo-Genesis), F009 (Erster Stein), F011 (Narrative Hook), F012 (Home Hub), F010 (Kontextuelle Navigation), F013 (Level-Map).
*   **Phase A – Monetarisierung & Retention (Woche 11-15):** F014 (Shop Basis), F015 (Rewarded Ads), F016 (Battle Pass Free), F017 (Daily Quests), F018 (Share-Card).
*   **Phase A – Backend & Legal (Woche 11-15, parallel):** F020 (Firebase), F021 (Analytics), F023 (Consent), F024 (Altersprüfung), F025 (Legal-Seiten), F026 (KI-Kennzeichnung), F027 (Disclaimer), F028 (App Store Compliance), F029 (Error Handling), F030 (Reduced Motion).

---

## 6. Screen-Architektur (VERBINDLICH)

### Screen-Übersicht (19 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / App Init | Overlay | App-Start, Engine laden, Locale erkennen | F008, F019 | Normal, Slow-Connection, Engine-Fehler |
| S002 | Consent-Dialog (DSGVO / ATT) | Modal | DSGVO-konformer Consent vor Analytics-Initialisierung | F023, F024 | Normal, Einstellungen-Expanded, Minderjährig-Block |
| S003 | Onboarding-Match | Hauptscreen | Erster Spielmoment, implizites Spielstil-Tracking | F001, F006, F009, F005 | Normal, Hint-aktiv, Match-erfolgreich, Match-fehlgeschlagen |
| S004 | Narrative Hook Sequenz | Subscreen | Emotionaler Story-Einstieg, Spielstil-adaptiv | F011 | Normal, Skip-Button-sichtbar, Frame-Übergang |
| S005 | Home Hub | Hauptscreen | Täglicher Einstieg, Daily Quest, Battle Pass Teaser | F010, F012, F017, F016, F039, F042 | Normal, Quest-aktiv, Battle-Pass-Teaser, Social-Nudge |
| S006 | Puzzle / Match-3 Spielfeld | Hauptscreen | Kern-Gameplay, Level-Ziele, Hindernisse | F001, F003, F004, F005, F007, F032, F033 | Normal, Booster-aktiv, Special-Stein-entsteht, Level-Verloren-Warnung |
| S007 | Level-Ergebnis / Post-Session | Subscreen | Level-Abschluss-Feedback, Share-Card, Retry/Rewarded Ad | F018, F015 | Gewonnen-State, Verloren-State, Rewarded-Ad-Angebot |
| S008 | Level-Map / Progression | Hauptscreen | Visuelle Level-Progression, Freundes-Lichtpunkte | F002, F013, F039 | Normal, Level-gesperrt, Level-offen, Level-abgeschlossen, Freund-aktiv |
| S009 | Story / Narrative Hub | Hauptscreen | Kapitel-Übersicht, Story-Fortschritt | F043, F044 | Normal, Kapitel-gesperrt, Kapitel-abgeschlossen, Neues-Kapitel-verfügbar |
| S010 | Social Hub | Hauptscreen | Freundesliste, Challenges, Leaderboards | F037, F038, F040, F041 | Normal, Keine-Freunde-State, Challenge-ausstehend, Leaderboard-aktiv |
| S011 | Shop / Monetarisierungs-Hub | Hauptscreen | IAP-Angebote, Battle Pass Upgrade | F014, F034, F035, F036 | Normal, Angebot-aktiv, Offline-Gesperrt, Kauf-erfolgreich |
| S012 | Battle-Pass Screen | Subscreen | Tier-Übersicht, Rewards, Saison-Timer | F016, F034 | Free-Tier-aktiv, Premium-Tier-aktiv, Saison-abgelaufen |
| S013 | Tägliche Quests Screen | Subscreen | Übersicht der Daily Quests, Fortschritt | F017 | Normal, Quest-abgeschlossen, Quest-aktiv, Quest-verfügbar |
| S014 | Push Notification Opt-In | Modal | Erklärung und Abfrage für Push-Notifications | F028 | Normal, Opt-In-erfolgreich, Opt-In-abgelehnt |
| S015 | Share Sheet | Modal | Teilen von Level-Ergebnissen auf Social Media | F018 | Normal, Link-kopiert, Geteilt-Erfolg |
| S016 | Rewarded Ad Interstitial | Overlay | Vollbild-Werbung von Drittanbietern | F015 | Ad-lädt, Ad-läuft, Ad-abgeschlossen, Ad-Fehler |
| S017 | Profil / Einstellungen | Hauptscreen | Spieler-Statistiken, Account-Management, Legal-Links | F020, F025, F027, F037 | Normal, Bearbeiten-Modus, Sync-Fehler, Offline |
| S018 | Settings | Subscreen | Sound, Haptik, Benachrichtigungen, Datenschutz | F030, F023 | Normal, Reduced-Motion-aktiv, Haptik-aus |
| S019 | Legal-Texte (Datenschutz, Impressum) | Subscreen | Rechtliche Pflichttexte | F025 | Normal, Offline-Cache |

### Hierarchie
*   **Hauptscreens:** S003 (Onboarding), S005 (Home Hub), S008 (Level-Map), S009 (Story Hub), S010 (Social Hub), S011 (Shop), S017 (Profil/Einstellungen)
*   **Subscreens:** S004 (Narrative Hook), S007 (Level-Ergebnis), S012 (Battle-Pass), S013 (Tägliche Quests), S018 (Settings), S019 (Legal-Texte)
*   **Modals:** S002 (Consent-Dialog), S014 (Push Opt-In), S015 (Share Sheet)
*   **Overlays:** S001 (Splash), S016 (Rewarded Ad Interstitial)

### Navigation
*   **Kontextuell & Gestenbasiert (D2):** Keine feste Bottom-Bar. Navigation erfolgt über dynamische Elemente auf dem Home Hub (S005), Swipe-Gesten und situative Action-Buttons.
*   **Home Hub (S005):** Primärer Einstiegspunkt. Von hier aus Zugriff auf Daily Quest (F017), Battle Pass Teaser (F016), Story Hub (S009), Level Map (S008), Social Hub (S010), Shop (S011), Profil (S017).
*   **Radial-Menü (Empfehlung):** Ein Swipe-Up-Geste vom Home Hub (S005) öffnet ein Radial-Menü mit 5 Sektoren (Spielen, Map, Story, Social, Profil) für schnellen Zugriff.

### User Flows (7 Flows)

#### Flow 1: Onboarding (Erst-Start) — App öffnen bis erster Core Loop
*   **Pfad:** S001 → S002 → S003 → S004 → S005 → S006 → S007
*   **Taps bis Core Loop:** 3 (Consent bestätigen auf S002 → Ersten Stein im Onboarding-Match bewegen auf S003 → Level-Start-Button auf S005)
*   **Zeitbudget:** ~60 Sekunden bis erstes Ergebnis sichtbar
*   **Beschreibung:** App initialisiert Client-Side Engine (S001) → DSGVO/ATT Consent Modal (S002) → Onboarding-Match (S003) mit implizitem Spielstil-Tracking → Narrative Hook Sequenz (S004) passend zum Spielstil → Home Hub (S005) mit Daily Quest → Puzzle / Match-3 Spielfeld (S006) → Level-Ergebnis (S007).
*   **Fallback Consent-Ablehnung:** S002 setzt nur notwendige Cookies, App funktioniert vollständig weiter (kein Analytics-Block).
*   **Fallback Engine-Fehler auf S001:** Fehler-State zeigt Retry-Button, nach 3 Fehlversuchen Weiterleitung zu S017 (Profil/Einstellungen) mit Kontakt-Hinweis.

#### Flow 2: Core Loop (wiederkehrend) — Direkteinstieg bis Level-Ergebnis
*   **Pfad:** S001 → S005 → S006 → S007
*   **Taps bis Ergebnis:** 2 (Level-Start-Button auf S005 → Ersten Stein im Spielfeld bewegen auf S006)
*   **Session-Ziel:** 45–90 Sekunden für vollständigen Level-Zyklus, Gesamtsession 6–10 Minuten inkl. S007-Review.
*   **Beschreibung:** Wiederkehrender Nutzer öffnet App, Splash kurz (S001) → Home Hub (S005) mit Daily Quest als primärem CTA → Puzzle / Match-3 Spielfeld (S006) → Level-Ergebnis (S007).
*   **Fallback Analyse-Timeout >50 Sek.:** S006 zeigt Timeout-Warnung mit Abbrechen-Option und Retry.
*   **Fallback Analyse-Fehler:** Fehler-Abbruch-State auf S006, Weiterleitung zurück zu S005 mit Fehlermeldung.

#### Flow 3: Erster Kauf — Battle Pass Upgrade
*   **Pfad:** S005 → S011 → S012 → (Nativer Payment-Dialog) → S012 (Premium-State) → S005
*   **Taps bis Kauf:** 3 (Battle Pass Teaser auf S005 → Battle Pass Karte antippen auf S011 → „Jetzt kaufen"-Button auf S012)
*   **Zeitbudget:** 60–90 Sekunden.
*   **Beschreibung:** Nutzer sieht Battle Pass Teaser auf Home Hub (S005) → navigiert zu Shop (S011) → wählt Battle Pass Karte → Battle Pass Screen (S012) zeigt Tiers und Upgrade-Option → Nativer Payment-Dialog → Nach erfolgreichem Kauf: S012 wechselt in Premium-State, Nutzer kehrt zu S005 zurück.
*   **Fallback Payment-Fehler:** S011 zeigt Fehlerdialog (A088).
*   **Fallback Offline:** S011 zeigt Offline-Gesperrt-State (P09).

#### Flow 4: Social Challenge — Ergebnis teilen
*   **Pfad:** S007 → S015
*   **Taps bis Teilen:** 2 (Share-Button auf S007 → Teilen-Aktion in S015)
*   **Zeitbudget:** 15–20 Sekunden.
*   **Beschreibung:** Nutzer sieht Level-Ergebnis (S007) mit Teilen-CTA → Share Sheet Modal öffnet sich (S015) mit vorgefertigtem Text und Score-Visual für Social Media → Nutzer wählt Link kopieren oder direktes Teilen → Erfolgs-Feedback.
*   **Fallback Link-kopieren fehlgeschlagen:** S015 zeigt Link als selektierbaren Text.
*   **Fallback Offline:** S015 zeigt nur Link-kopieren-Option, native Share-API wird nicht aufgerufen.

#### Flow 5: Daily Quest — Fortschritt & Abschluss
*   **Pfad:** S005 → S013 → S006 → S007 → S013 (Quest abgeschlossen)
*   **Taps bis Abschluss:** 3 (Daily Quest Card auf S005 → Quest starten auf S013 → Level abschließen auf S006/S007)
*   **Zeitbudget:** 3–5 Minuten pro Quest-Level.
*   **Beschreibung:** Nutzer wählt Daily Quest auf Home Hub (S005) → Daily Quests Screen (S013) zeigt Details → Startet Level (S006) → Schließt Level ab (S007) → Kehrt zu S013 zurück, Quest als abgeschlossen markiert.
*   **Fallback Quest-Fehler:** S013 zeigt Fehler-State für Quest.

#### Flow 6: Freundes-Challenge — Annehmen & Spielen
*   **Pfad:** S005 (Social-Nudge) → S010 → S006 (Challenge-Level) → S007 (Ergebnis) → S010 (Challenge-Status)
*   **Taps bis Spiel:** 3 (Social-Nudge auf S005 → Challenge annehmen auf S010 → Level starten auf S006)
*   **Zeitbudget:** 2–4 Minuten pro Challenge-Level.
*   **Beschreibung:** Nutzer sieht Social-Nudge auf Home Hub (S005) → navigiert zu Social Hub (S010) → akzeptiert Challenge → Puzzle / Match-3 Spielfeld (S006) mit Challenge-Kontext → Level-Ergebnis (S007) → Kehrt zu S010 zurück, Challenge-Status aktualisiert.
*   **Fallback Challenge abgelaufen:** S010 zeigt Challenge als abgelaufen, keine Annahme mehr möglich.

#### Flow 7: Datenschutz & Transparenz — DSGVO-Detail-Flow
*   **Pfad:** S002 → S019 → S018
*   **Taps bis vollständiger Information:** 2 (Datenschutz-Link auf S002 → Datenschutzerklärung S019)
*   **Zeitbudget:** Nutzer-gesteuert, kein Zeitlimit.
*   **Beschreibung:** DSGVO/ATT Consent Modal erscheint (S002) → Nutzer tippt auf Datenschutz-Link → Legal-Texte Screen (S019) mit Datenschutzerklärung und Impressum → Von S019 aus kann zu S018 (Settings) navigiert werden, um Consent-Einstellungen zu verwalten.
*   **Fallback Offline auf S019:** Offline-Cache-State liefert zuletzt geladene Version der Datenschutzerklärung.

### Edge Cases (8 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| Offline bei App-Start | S001, S005, S006 | S001 Engine-Init lädt aus lokalem Cache. S005 zeigt Offline-State-Banner. S006 Gameplay funktioniert vollständig (client-side). Online-abhängige Features (Shop, Social) sind deaktiviert mit Hinweis. |
| KI-Level-Generierungs-Fehler | S006, S007 | S006 zeigt Fehler-Abbruch-State mit erklärendem Text und Retry-Option. Kein leerer Score-Screen S007. Technischer Fehlercode wird geloggt. |
| Altersprüfung unter 13 | S002 | S002 zeigt A008 Minderjährigen-Block-Illustration. Harter Block, keine weitere App-Nutzung möglich. |
| ATT-Prompt abgelehnt (iOS) | S002 | S002 schließt Consent-Modal, App funktioniert vollständig. Analytics-Tracking für ATT-relevante Daten ist deaktiviert. |
| IAP-Kauf fehlgeschlagen | S011 | S011 zeigt A088 IAP-Fehler-Dialog. Kauf-Button bleibt aktiv für Retry. |
| Level-Map ohne freigeschaltete Level | S008 | S008 zeigt A021 Level-Map-Pfad-Grafik mit nur einem Start-Level. Keine leere Map. |
| Battle Pass Saison abgelaufen | S012 | S012 zeigt A_SeasonEndIllustration (P08) mit motivierendem Teaser für nächste Saison. |
| Freundes-Challenge abgelaufen | S010 | S010 zeigt Challenge-Card als abgelaufen, Annahme-Button deaktiviert. |

### Phase-B Screens mit Platzhaltern (8 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S020 | Kaltstart Personalisierungs-Fallback | Spielstil-Auswahl bei ATT-Ablehnung | Nicht sichtbar (nur bei ATT-Ablehnung) |
| S021 | Offline Error | Generischer Offline-Fehler-Screen | Nicht sichtbar |
| S022 | A/B Test Variant Loader | Interner Loader für A/B-Test-Varianten | Nicht sichtbar |
| S023 | Live-Ops Event Hub | Übersicht über aktuelle In-Game-Events | Coming Soon Badge auf S005 |
| S024 | Gilden / Team-Übersicht | Verwaltung von Gilden/Teams | Coming Soon Badge auf S010 |
| S025 | Spieler-Statistiken (Detail) | Detaillierte Spieler-Statistiken | Basis-Statistiken auf S017 |
| S026 | Abonnement-Verwaltung | Abo-Status, Kündigung, Rechnungen | Nicht sichtbar (kein Abo in Phase A) |
| S027 | Shop-Item-Detail | Detaillierte Ansicht eines Shop-Items | Shop-Karten (A034) mit Quick-Buy |

---

## 7. Asset-Liste (VERBINDLICH)

### Vollständige Asset-Tabelle

| ID | Asset | Beschreibung | Screen(s) | Stat/Dyn | Quelle | Format | Priorität |
|---|---|---|---|---|---|---|---|
| **APP-BRANDING** | | | | | | | |
| A001 | App-Icon | Haupt-App-Icon | S001, Alle | statisch | Custom Design | PNG 1024×1024 | 🔴 Launch-kritisch |
| A002 | Splash-Screen-Logo | EchoMatch-Volllogo | S001 | statisch | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A062 | Store-Feature-Grafik | Feature-Grafik für Google Play | Alle | statisch | Custom Design | PNG 1024×500 | 🔴 Launch-kritisch |
| A063 | Notification-Icon | Monochromes Icon für Notifications | S014 | statisch | Custom Design | PNG 96×96 | 🔴 Launch-kritisch |
| **GAMEPLAY-ASSETS** | | | | | | | |
| A009 | Match-3-Spielstein-Sprite-Set | Alle Spielsteine (6 Typen) | S003, S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 Launch-kritisch |
| A010 | Match-3-Spielfeld-Hintergrund | Vollbild-Hintergrund für Spielfeld | S003, S006 | statisch | AI-generiert | PNG 1920×1080 | 🔴 Launch-kritisch |
| A011 | Match-3-Spezialstein-Sprites | Sonder- und Booster-Steine | S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 Launch-kritisch |
| A013 | Spielfeld-Grid-Rahmen | Visueller Rahmen und Zellen-Design | S003, S006 | statisch | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A065 | Spielfeld-Ziel-Indikator-Icons | Icons für Level-Ziele | S006, S008 | statisch | Free/Open-Source | SVG + PNG | 🔴 Launch-kritisch |
| A066 | Hindernisse und Spezialzellen-Sprites | Eis, Stein, Kette, Nebel | S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 Launch-kritisch |
| **UI-ELEMENTE** | | | | | | | |
| A004 | Ladebalken / Loading-Indicator | Animierter Spinner | S001, S006, S011, S012 | animiert | Lottie | Lottie JSON | 🔴 Launch-kritisch |
| A014 | Züge-Anzeige / Move-Counter | Verbleibende Züge HUD | S006 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A015 | Punkte-/Score-Anzeige HUD | Score-Counter im HUD | S006 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A016 | Booster-Icons im Spielfeld | Icons für alle Booster | S006 | animiert | AI-generiert + Custom | PNG + Lottie | 🔴 Launch-kritisch |
| A020 | Reward-Item-Icons | Icons für alle Reward-Items | S007, S012, S013, S011 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A022 | Level-Knoten-Icons | Icons für Level-Knoten auf Map | S008 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A029 | Daily-Quest-Card-Design | Visuell gestaltete Quest-Karte | S005, S013 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A030 | Quest-Icon-Set | Thematische Icons für Quest-Typen | S013, S005 | statisch | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A031 | Battle-Pass-Tier-Reward-Visualisierung | Horizontale/vertikale Tier-Leiste | S012 | animiert | Custom Design | SVG + Lottie | 🔴 Launch-kritisch |
| A033 | Saison-Timer-Visual | Visueller Countdown-Timer | S012, S013 | animiert | Lottie | Lottie JSON | 🟡 Nice-to-have |
| A034 | Shop-Angebots-Karten | Visuell gestaltete Angebotskarten | S011 | statisch | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A035 | Foot-in-Door-Angebot-Highlight | Spezielles Highlight-Design | S011 | animiert | Custom Design + Lottie | Lottie JSON + SVG | 🔴 Launch-kritisch |
| A036 | Währungs-Icons | Icons für In-Game-Währungen | S006, S007, S011, S012, S013 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A037 | Social-Hub-Avatar-Rahmen | Dekorative Rahmen für Avatare | S010, S017 | statisch | Custom Design | SVG + PNG | 🟡 Nice-to-have |
| A038 | Challenge-Card-Design | Visuell gestaltete Challenge-Karte | S010 | animiert | Custom Design | SVG + Lottie | 🟡 Nice-to-have |
| A040 | Share-Result-Bild-Template | Visuelles Template für Share-Bild | S015, S007 | statisch | Custom Design | PNG | 🟡 Nice-to-have |
| A043 | Profil-Spieler-Avatar-Placeholder | Standard-Avatar-Illustration | S017, S010 | statisch | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A046 | Tab-Bar-Icons | Icons für Tab-Bar-Einträge | S005, S008, S009, S010, S011 | statisch | Free/Open-Source | SVG + PNG | 🔴 Launch-kritisch |
| A048 | Kaltstart-Personalisierungs-Auswahlkarten | Visuelle Auswahlkarten für Spielstil | S020 | animiert | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A049 | Onboarding-Hint-Pfeile + Tutorial-Overlays | Animierte Pfeile, Tap-Animationen | S003 | animiert | Lottie + Custom | Lottie JSON + SVG | 🔴 Launch-kritisch |
| A052 | Beta-Feedback-Rating-Sterne | Interaktives Stern-Bewertungselement | S019 | animiert | Lottie | Lottie JSON | 🟢 Beta-only |
| A055 | Coming-Soon-Badge (Phase-B) | Visuelles Coming-Soon-Badge | S010 | animiert | Custom Design | SVG + Lottie | 🟡 Nice-to-have |
| A057 | Leaderboard-Top-3-Podest-Design | Visuelles Podest-Design | S010 | statisch | Custom Design | SVG + PNG | 🟡 Nice-to-have |
| A058 | Haptic-Feedback-Toggle-Icon | Icon für Haptic-Feedback-Toggle | S018 | statisch | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A059 | Einstellungen-Kategorie-Icons | Icon-Set für Einstellungen | S018 | statisch | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A067 | Social-Nudge-Banner-Design | Visuell gestaltetes Banner | S007, S005 | animiert | Custom Design | SVG + Lottie | 🟡 Nice-to-have |
| A068 | Friend-Challenge-Card | Visuelle Karte für ausstehende Challenges | S010 | dynamic | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A069 | Leaderboard-Rang-Badge | Badge für Spieler-Rang | S010, S005 | dynamic | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A070 | Leaderboard-Eintrag-Row | Einzelne Zeile im Leaderboard | S010 | dynamic | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A071 | Social-Invite-Banner | Banner für Keine-Freunde-State | S010 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A072 | Share-Card-Level-Gewonnen | Share-Card für gewonnene Level | S007, S015 | dynamic | Custom Design | PNG | 🔴 Launch-kritisch |
| A073 | Share-Card-Highscore-Milestone | Share-Card für Milestone-Events | S007, S015 | dynamic | Custom Design | PNG | 🟡 Nice-to-have |
| A074 | Share-Sheet-Destination-Icons | Icons für Social-Share-Buttons | S015 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A075 | Team-Event-Teaser-Card | Platzhalter-Card für Team-Events | S010 | static | Custom Design | SVG + PNG | 🟡 Nice-to-have |
| **ILLUSTRATIONEN** | | | | | | | |
| A003 | Splash-Screen-Hintergrund | Atmosphärisches Artwork | S001 | statisch | AI-generiert + Custom | PNG 2732×2732 | 🔴 Launch-kritisch |
| A005 | Offline-Error-Illustration | Thematisches Bild für Offline-Fehler | S021, S001 | statisch | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A006 | DSGVO-Consent-Illustration | Thematische Illustration für Consent | S002 | statisch | Free/Open-Source | SVG + PNG | 🔴 Launch-kritisch |
| A007 | ATT-Prompt-Visual | Pre-Permission-Erklärungsbild | S002 | statisch | AI-generiert + Custom | SVG + PNG | 🔴 Launch-kritisch |
| A008 | Minderjährigen-Block-Illustration | Freundliche COPPA-Block-Illustration | S002 | statisch | AI-generiert + Custom | SVG + PNG | 🔴 Launch-kritisch |
| A018 | Level-Verloren-Illustration | Empathische Illustration für Verloren-State | S007 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A021 | Level-Map-Pfad-Grafik | Visueller Fortschrittspfad | S008 | statisch | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A023 | Level-Map-Hintergrund-Welten | Thematische Hintergrundillustrationen | S008 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A028 | Home Hub Hero-Banner | Dynamisches Hero-Banner-Artwork | S005 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A032 | Battle-Pass-Saison-Banner | Thematisches Key-Art für Saison | S012, S005 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A039 | Keine-Freunde-Empty-State-Illustration | Freundliche Illustration für Empty-State | S010 | statisch | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A041 | Rewarded-Ad-Angebots-Illustration | Ansprechende Illustration für Ad-Angebot | S016 | statisch | AI-generiert | PNG | 🟡 Nice-to-have |
| A045 | Sync-Fehler-Illustration | Thematische Illustration für Sync-Fehler | S017 | statisch | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A047 | Push-Notification-Opt-In-Illustration | Erklärende Illustration für Push-Opt-In | S014 | statisch | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A056 | Phase-B-Teaser-Illustrationen | Teaser-Artwork für kommende Features | S010 | statisch | AI-generiert + Custom | PNG | 🟡 Nice-to-have |
| **ANIMATIONEN & EFFEKTE** | | | | | | | |
| A012 | Match-Animation-Effekte | Partikel- und Burst-Animationen | S003, S006 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A017 | Level-Gewonnen-Animation | Vollbild-Gewinn-Animation | S007 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A019 | Stern-Bewertungs-Animation | 1-3 Stern-Vergabe-Animation | S007 | animiert | Lottie | Lottie JSON | 🔴 Launch-kritisch |
| A042 | Ad-Lade-Animation | Kurze Lade-Animation für Ad | S016 | animiert | Lottie | Lottie JSON | 🟡 Nice-to-have |
| A050 | KI-Level-Lade-Platzhalter-Animation | Thematische Animations-Szene | S006, S008 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A051 | Neues-Level-Freischalten-Animation | Feiernde Animation für Level-Unlock | S008 | animiert | Lottie + Custom | Lottie JSON | 🟡 Nice-to-have |
| A053 | Feedback-Gesendet-Danke-Animation | Kurze Bestätigungs-Animation | S019 | animiert | Lottie | Lottie JSON | 🟢 Beta-only |
| A054 | A/B-Test-Loader-Animation | Dezente Lade-Animation | S022, S001 | animiert | Lottie | Lottie JSON | 🔴 Launch-kritisch |
| A060 | Reward-Freischalten-Animation | Animiertes Freischalten von Rewards | S012, S013, S007 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| A061 | Quest-Abgeschlossen-Checkmark-Animation | Animiertes Checkmark für Quest-Abschluss | S013, S005 | animiert | Lottie | Lottie JSON | 🟡 Nice-to-have |
| A064 | IAP-Kauf-Bestätigungs-Animation | Kurze Feier-Animation nach IAP-Kauf | S011 | animiert | Custom Design | Lottie JSON | 🟡 Nice-to-have |
| **DATENVISUALISIERUNG** | | | | | | | |
| A044 | Statistik-Visualisierungs-Grafiken | Visuelle Charts und Grafiken | S017 | animiert | Native + Custom | SVG / Native | 🟡 Nice-to-have |
| **STORY / NARRATIVE ASSETS** | | | | | | | |
| A024 | Narrative-Hook-Sequenz-Artwork | Vollbild-Story-Artwork | S004 | animiert | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A025 | Story-Charakter-Portraits | Portrait-Illustrationen | S004, S009 | statisch | Custom Design | PNG | 🔴 Launch-kritisch |
| A026 | Story-Kapitel-Cover-Illustrationen | Cover-Artwork pro Kapitel | S009 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A027 | Story-Scene-Hintergründe | Hintergrundillustrationen für Story | S004, S009 | statisch | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| **MONETARISIERUNGS-ASSETS** | | | | | | | |
| A076 | Battle-Pass-Fortschrittsbalken | Horizontale Fortschrittsanzeige | S012, S005 | dynamic | Custom Design | SVG + Lottie | 🔴 Launch-kritisch |
| A077 | Battle-Pass-Reward-Icons-Set-Free | Icons für Free-Tier-Rewards | S012 | static | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A078 | Battle-Pass-Reward-Icons-Set-Premium | Icons für Premium-Tier-Rewards | S012 | static | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A079 | Battle-Pass-Saison-Timer | Countdown-Timer-Komponente | S012, S005 | dynamic | Custom Design | SVG + Lottie | 🔴 Launch-kritisch |
| A080 | Battle-Pass-Upgrade-CTA-Button | Prominenter Kauf-Button | S012 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A081 | Foot-in-Door-Angebot-Banner | Spezieller Erstkäufer-Banner | S011 | dynamic | Custom Design | SVG + Lottie | 🔴 Launch-kritisch |
| A082 | Shop-Item-Card | Wiederverwendbare Produkt-Card | S011 | dynamic | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A083 | Rewarded-Ad-Angebot-Illustration | Illustration für Ad-Interstitial | S016 | static | AI-generiert | PNG | 🔴 Launch-kritisch |
| A084 | Rewarded-Ad-Fehler-Illustration | Illustration für Ad-Fehler-Fallback | S016 | static | AI-generiert | PNG | 🔴 Launch-kritisch |
| A085 | Währungs-Icons-Set | Icons für alle In-Game-Währungen | S005, S006, S011, S012, S013 | static | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A086 | Booster-Icons-Set | Icons für alle spielbaren Booster | S006, S011, S016 | static | AI-generiert + Custom | PNG | 🔴 Launch-kritisch |
| A087 | IAP-Bestätigung-Overlay | Post-Purchase-Bestätigung | S011, S012 | dynamic | Custom Design | SVG + Lottie | 🔴 Launch-kritisch |
| A088 | IAP-Fehler-Dialog | Fehlerdialog für IAP-Transaktionen | S011 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| **LEGAL-UI** | | | | | | | |
| A098 | DSGVO-Consent-Screen-Layout | Vollständiges Screen-Layout | S002 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A099 | ATT-Pre-Prompt-Illustration | Custom-Erklärungsscreen | S002 | static | AI-generiert + Custom | SVG + PNG | 🔴 Launch-kritisch |
| A100 | COPPA-Alterscheck-UI | Altersverifikations-Interface | S002 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A101 | Minderjährigen-Blocked-Screen | Screen für unter 13-Jährige | S002 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A102 | Datenschutz-Consent-Toggle-Komponente | Wiederverwendbare Toggle-Komponente | S002, S018 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A103 | Push-Opt-In-Erklär-Illustration | Illustration für Push-Opt-In | S014 | static | Free/Open-Source | SVG + PNG | 🟡 Nice-to-have |
| A104 | Battle-Pass-Content-Visibility-Compliance-Badge | Informations-Element für BP-Inhalte | S012 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A105 | Impressum-und-Datenschutz-Link-Footer | Standardisierter Footer-Bereich | S018, S002 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A106 | Kaltstart-Personalisierungs-Auswahl-UI | UI-Komponenten für Spielstil-Fallback | S020 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |
| A107 | Update-Required-Screen-Visual | Visueller Screen für Update-Required | S001 | static | Custom Design | SVG + PNG | 🔴 Launch-kritisch |

### Beschaffungswege pro Asset
*   **Custom Design (Freelancer):** 38 Assets (41% der Launch-kritischen Assets)
*   **AI-generiert + Custom Finish:** 25 Assets (27% der Launch-kritischen Assets)
*   **Free/Open-Source:** 12 Assets (13% der Launch-kritischen Assets)
*   **Lottie (Free/Premium):** 10 Assets (11% der Launch-kritischen Assets)
*   **Native (UI/Components):** 12 Assets (8% der Launch-kritischen Assets)

### Format-Anforderungen pro Plattform
| Asset-Typ | Format | Auflösung/Größe | Tool | Hinweise |
|---|---|---|---|---|
| **Unity Sprites** | PNG / Sprite Sheet | @2x (1920x1080px) / @3x (2880x1620px) | TexturePacker 7.x → Unity Importer | Keine POT-Pflicht ab Unity 2022+, aber 2er-Potenzen empfohlen für Kompression |
| **Game Piece Sprites** | PNG Sprite Sheet via TexturePacker | 2048x2048px (max) | TexturePacker | Jedes Sprite-Sheet für einen Steintyp (z.B. `gem_blue_sheet.png`) |
| **Backgrounds** | PNG | 1920x1080px @2x (3840x2160 Master) | Photoshop | Hintergrund-Layer separat exportieren (BG-Layer, Mid-Layer, FX-Layer) für Parallax |
| **Icons** | SVG für UI-Icons, PNG @2x/@3x für In-Game | 24x24dp, 48x48dp, 96x96dp | Figma | SVG für Skalierbarkeit, PNG für Performance in Unity |
| **Animations** | Lottie JSON (UI-Animationen, Loading, Feedback) | Max 500KB pro JSON | After Effects 2025 + Bodymovin 5.x Plugin | Statisches PNG @2x wenn Lottie >500KB oder Runtime-Performance-Problem |
| **App Icon (iOS)** | PNG | 1024x1024px (Store), 180x180px (Home) | Figma Export + Asset Catalog Xcode | Kein Alpha-Kanal, kein Gradient über gesamte Fläche (Apple Review Richtlinie) |
| **App Icon (Android)** | PNG Adaptive Icon | Foreground + Background als separate Layer | Android Studio Asset Studio + Figma Export | Adaptive Icon: Foreground + Background als separate Layer im XML definiert |
| **Screenshots (Store)** | PNG (kein JPEG, keine Kompressionsartefakte) | 1290x2796px (iPhone 6.7"), 1080x1920px (Android) | Figma Store-Screenshot-Template + Photoshop | 6-8 Screenshots pro Plattform, Hochformat |
| **Audio** | WAV (Master) → OGG/AAC (komprimiert) | 44.1 kHz, 16-bit Stereo | Audacity / Adobe Audition | SFX als kurze WAVs, BGM als OGG/AAC mit Loop-Points |
| **Fonts** | TTF / OTF Master → Unity Font Asset (TMP) | N/A | TextMesh Pro Font Asset Creator | Lizenz-Prüfung für Mobile-Embedding vor Integration (SIL OFL oder Commercial-Lizenz) |

### Plattform-Varianten Anzahl
*   **Gesamtanzahl Assets:** 107
*   **Plattform-Varianten gesamt:** 164 (inkl. iOS/Android spezifische Icons, Store-Grafiken)

### Dark-Mode-Varianten
*   **Dark-Mode-Varianten nötig:** 65 Assets (explizit in Asset-Discovery-Liste markiert)

---

## 8. KI-Produktions-Warnungen (VERBINDLICH — KRITISCH)

### Warnungen aus dem Visual Audit
| # | Screen | Stelle | Was KI falsch macht | Was stattdessen | Prompt-Anweisung für Produktionslinie |
|---|---|---|---|---|---|
| **W01** | S001 Splash | Vollbild-Atmosphären-Artwork hinter dem Logo | Farbverlauf in Brand-Primärfarbe oder `#1A1A2E` Vollton | A003 Splash-Screen-Hintergrund | **VERWENDE `Image(asset: "splash_bg")` als Fullscreen-Layer unter dem Logo.** KEIN `Color.fill()` oder Gradient-Code als Ersatz akzeptieren. |
| **W02** | S002 ATT Consent | Erklärendes Bild BEVOR der iOS-System-ATT-Dialog erscheint | Text-only Pre-Permission-Screen mit App-Beschreibung oder gar keinen Pre-Screen | A007 ATT-Prompt-Visual | **IMPLEMENTIERE Pre-Permission-Screen als eigene View mit `Image(asset: "att_explanation_visual")` als zentralem Element.** Der System-Dialog wird erst nach Tap auf Erklärungsscreen getriggert. KEIN direktes `requestTrackingAuthorization()` ohne vorherigen Visual-Screen. |
| **W03** | S002 DSGVO | Visuelle Auflockerung neben Rechtstext | Reinen UITextView/ScrollView mit Rechtstext, kein visuelles Element | A006 DSGVO-Consent-Illustration | **PLATZIERE `Image(asset: "consent_illustration")` als festes Layout-Element in der oberen Hälfte des Consent-Modals.** ScrollView mit Rechtstext NUR im unteren Bereich. Illustration darf NICHT weggelassen werden wenn Rechtstext lang ist. |
| **W04** | S003 Spielsteine | Thematisch gestaltete Spielstein-Sprites mit Spielwelt-Ästhetik | Farbige `RoundedRectangle`-Views oder `Circle`-Shapes mit Hex-Farben als Spielstein-Ersatz | A009 Match-3-Spielstein-Sprite-Set | **LADE Sprite Sheet und RENDERE Einzelframes per Tile-Index.** Jeder Spielstein-Typ bekommt eigenen Sprite-Frame aus `gem_sprites.atlas`. KEIN Shape-Rendering als Spielstein. |
| **W05** | S003 Tutorial-Hint | Animierter Finger-Tap-Pfeil der ersten Spielzug zeigt | Statischen Text-Overlay wie „Tippe hier um zu beginnen" oder `Label`-Tooltip | A049 Onboarding-Hint-Pfeile und Tutorial-Overlays | **VERWENDE Lottie-Animation oder Frame-Animiertes Asset (`hint_arrow_tap.json`).** KEIN `UILabel` oder `Text()`-Overlay als Tutorial-Hinweis im Spielfeld. Animation muss auf den ersten tappbaren Stein zeigen. |
| **W06** | S005 Battle-Pass-Teaser-Banner | Hochwertiges Saison-Artwork mit Teaser-Energie | Generische Text-Card mit Farbfläche | A032 Battle-Pass-Saison-Banner | **VERWENDE `Image(asset: "battle_pass_season_banner")` als Hero-Element für den Battle-Pass-Teaser auf S005.** KEIN programmatisch generiertes Text-Banner akzeptieren. |
| **W07** | S006 Spezialsteine | Visuell sofort erkennbare Spezialsteine die sich klar von normalen Steinen unterscheiden (Bombe sieht aus wie Bombe) | Gleiche `RoundedRectangle`-Shapes wie normale Steine, nur mit anderer Farbe oder Outline | A011 Match-3-Spezialstein-Sprites | **RENDERE separate Sprite-Frames für jeden Spezialstein-Typ** aus `special_gems.atlas`. Bombe = Bomben-Sprite, Blitz = Blitz-Sprite. KEIN Reuse des normalen Stein-Sprites mit veränderter `tintColor` oder Border. |
| **W08** | S006 Hindernisse | Hinderniszellen die durch ihr Aussehen ihren Typ und Abbau-Zustand kommunizieren (Eis-Crack-States) | Farbige Zellen-Backgrounds (`blue` = Eis, `gray` = Stein) ohne Multi-State-Design | A066 Hindernisse und Spezialzellen-Sprites | **IMPLEMENTIERE Sprite-Set mit je 3 Abbau-States pro Hindernis-Typ** (`ice_state_1/2/3.png`, `stone_state_1/2/3.png`). State-Wechsel über Sprite-Frame-Swap, NICHT über `opacity`-Änderung oder Farb-Overlay. |
| **W09** | S007 Verloren-State | Empathische Charakter-Illustration die Niederlage emotional abfedert und Retry-Motivation aufbaut | Roter Text „Level verloren" oder System-Alert-Style-Dialog, evtl. mit rotem X-Icon | A018 Level-Verloren-Illustration | **PLATZIERE `Image(asset: "level_lost_illustration.png")` als Fullscreen-Hintergrund oder zentrales Element** des Verloren-Screens. Retry-Button wird ÜBER die Illustration gelegt. KEIN Alert-Dialog oder System-Modal als Verloren-Screen. |
| **W10** | S011 Foot-in-Door-Angebot | Visuell hervorgehobene Angebots-Card die sich durch Größe, Glanz-Effekt oder animierten Rahmen von anderen Angeboten abhebt | Gleiche Card wie alle anderen Angebote, nur mit anderem Preis oder Text „Bestes Angebot" Label | A035 Foot-in-Door-Angebot-Highlight | **VERWENDE dediziertes Highlight-Asset mit animiertem Rahmen/Glow** (`offer_highlight_frame.json` als Lottie). KEIN reines Text-Badge wie „BEST VALUE" ohne visuelles Highlight-Design. Die Card selbst muss größer oder visuell prominenter sein als Standard-Cards. |
| **W11** | S012 Saison-Abgelaufen-State | Illustration die zeigt „nächste Saison kommt" — motivierend | Leerer Screen oder roter Fehler-Text | P08 (Platzhalter) | **IMPLEMENTIERE `A_SeasonEndIllustration` als eigenes Asset.** Ton: humorvoll, nicht schuldzuweisend. |
| **W12** | S016 Ad-Fehler-Fallback | Freundliche Illustration „Leider kein Video verfügbar, versuch es später" | Blanker Screen oder nativer OS-Alert | A084 Rewarded-Ad-Fehler-Illustration | **VERWENDE `Image(asset: "ad_error_illustration")` als zentrales Element** des Ad-Fehler-Fallback-Screens. Ton: humorvoll, nicht schuldzuweisend. |
| **W13** | S016 Overlay-Container | Semitransparenter gestalteter Rahmen um Ad-Content | Rohes Ad-Fullscreen ohne App-Branding-Rahmen | P07 (Platzhalter) | **DEFINIERE `A_AdOverlayFrame` als schlanken Branding-Rahmen mit Close-Button-Area.** Das Ad-Content wird in diesen Rahmen eingebettet. |
| **W14** | S002 DSGVO-Consent-Toggles | Gebrandete Toggle-Switches in App-Farbwelt, granular per Kategorie | iOS/Android System-Standard-Toggles in Systemfarbe | A102 Datenschutz-Consent-Toggle-Komponente | **IMPLEMENTIERE `A_ConsentToggleSet` mit An/Aus-States in Brand-Farben.** KEINE System-Standard-Toggles verwenden. |
| **W15** | S002 Opt-In/Opt-Out-Buttons | Visuell gleichwertig — kein Dark Pattern (DSGVO-Pflicht) | Zustimmen-Button groß + primär, Ablehnen klein + grau | P02 (Platzhalter) | **DEFINIERE `A_ConsentButtonPair` mit expliziter Gleichgewichts-Spezifikation.** Beide Buttons müssen gleiche Größe und Sichtbarkeit haben. |

### Warnungen aus der Design-Vision
| # | Screen | Standard den KI wählt | Was Design-Vision verlangt | Prompt-Anweisung |
|---|---|---|---|---|
| **DV1** | S006, S001, S004, alle Spielfeld-Screens | Weißer oder hellgrauer Hintergrund als Basis-Canvas | **Dunkler Basis-Canvas (#0D0F1A bis #1A1D2E) als primäre Designsprache.** Kein Screen darf einen hellen Hintergrund als Default haben. Ausnahme nur für DSGVO/ATT-Modal (System-Pflicht). | **VERWENDE `gameplay_bg` (#0E0A24) für Spielfelder und `background_dark` (#120D2A) für Hub-Screens als Standard-Hintergrundfarbe.** KEINE hellen oder weißen Hintergründe. |
| **DV2** | S005, S007, alle Hub-Screens | Fünf-Icon Bottom-Tab-Bar persistent auf allen Screens | **Kein persistentes Bottom-Tab-Element.** Navigation über kontextuelles Radial-Menü (Swipe-Up) und situative Action-Surfaces die je nach Screen-State eingebettet sind. | **IMPLEMENTIERE kontextuelle Navigation.** KEINE feste Bottom-Tab-Bar. Dynamische UI-Elemente und Gesten sind die primäre Navigation. |
| **DV3** | S008, S009 | Konfetti-Regen, drei goldene Sterne und "AMAZING!"-Text auf dem Gewinn-Screen | **Vollbild-Poster-Karte mit expressiver Typografie** (konkrete Session-Aussage wie "47 Züge. Kein Fehler."), Kapitel-Farbwelt als Hintergrund, ein einziger "Teilen"-Button. Kein Konfetti. Keine generischen Lobtext-Banner. | **VERWENDE `A072 Share-Card-Level-Gewonnen` als Post-Session-Screen.** KEINE Konfetti-Animationen oder "AMAZING!"-Texte. |
| **DV4** | S010, alle Shop-Screens | Rote "BEST VALUE!"-Schräg-Banner und Puls-Countdown-Timer im Shop | **Maximale drei Angebote gleichzeitig, kein Schräg-Banner, kein Puls-Effekt beim Timer, Preise in klarer lesbarer Type ohne Gold-Rendering, Countdown als dezenter Text ("noch 23 Tage") nicht als animierter Balken.** | **GESTALTE den Shop (S011) als kuratierte Liste mit maximal 3 Angeboten pro View.** KEINE roten "BEST VALUE!"-Banner oder pulsierende Countdown-Timer. |
| **DV5** | S003 | Hand-Cursor der ersten Zug zeigt, Tutorial-Overlay mit abgedunkeltem Hintergrund, statische Dialog-Bubble mit erklärender Figur | **Spielfeld erscheint ohne Overlay; subtiles einmaliges Pulsieren der Steine als organische Aufmerksamkeits-Lenkung nach 4 Sekunden Inaktivität** (Scale 1.0→1.03→1.0 in 1,2 Sek.); erster Stein folgt dem Finger mit 20% Nachzieh-Elastizität wie durch Wasser; Entdeckung durch Spielen nicht durch Erklären. | **IMPLEMENTIERE Onboarding auf S003 ohne explizites Tutorial-Overlay oder Hand-Cursor.** Nutze subtile Animationen und Haptik für Führung. |
| **DV6** | S006, S008 | Partikel-Burst-Explosion bei jedem Match (200ms-Pop-Effekt) | **Resonanz-Puls: Stein-Match löst einen Ton aus der nachhallt statt berstet; Cascade-Töne steigen auf statt ab; Special-Steine formen sich via 400ms Morphing-Animation mit tiefem Haptik-Puls; dreischichtige adaptive Sound-Schicht die mit dem Spieltempo atmet.** | **VERWENDE Licht-Emission und Resonanz-Sounds für Match-Feedback.** KEINE Partikel-Burst-Explosionen. |

---

## 9. Legal-Anforderungen für Produktion

**Hinweis:** Die folgenden Legal-Anforderungen wurden aus den "Atem-Übungs-App"- und "SkillSense"-Reports generalisiert und an den Kontext eines Match-3-Spiels angepasst.

### Consent-Screens (DSGVO, ATT)
*   **VERBINDLICH:** Implementierung eines **DSGVO-konformen Consent-Management-Systems (CMS)** (S002) für alle Third-Party-Dienste (Analytics, Ads, Auth). Nutzer muss aktiv zustimmen, bevor personenbezogene Daten an Drittdienste übermittelt werden.
*   **VERBINDLICH:** Für iOS: Implementierung eines **Pre-Permission-Screens (A007)** vor dem nativen ATT-Dialog (S002), der den Nutzen der Datenverfolgung in menschlicher Sprache erklärt.
*   **VERBINDLICH:** Consent-Toggles (A102) müssen **granular** sein (pro Zweck) und im Brand-Stil gestaltet werden. Opt-In- und Opt-Out-Buttons müssen **visuell gleichwertig** sein (keine Dark Patterns).
*   **VERBINDLICH:** Der Consent-Screen (S002) muss als **Rising Card** von unten erscheinen, mit dem Spielfeld dahinter sichtbar durch Milchglas, um Vertrauen zu signalisieren.

### Age-Gate / COPPA
*   **VERBINDLICH:** Implementierung eines **Altersverifikations-Interfaces (A100)** auf S002.
*   **VERBINDLICH:** Bei Nutzern unter 13 Jahren (COPPA-relevant): **Hard-Block mit freundlicher, altersgerechter Illustration (A008)** (S002). Keine Datensammlung von Minderjährigen.
*   **EMPFEHLUNG:** In App Store-Beschreibung und Privacy Policy klar deklarieren: "Diese App richtet sich nicht an Kinder unter 13 Jahren."

### Datenschutz
*   **VERBINDLICH:** Erstellung einer **vollständigen, rechtlich wasserdichten Datenschutzerklärung** (S019), die alle tatsächlichen Datenflüsse dokumentiert: Firebase (Auth, Firestore, Analytics), Unity Ads (Rewarded Ads), App Store / Google Play Billing (IAP).
*   **VERBINDLICH:** Abschluss und Dokumentation von **Auftragsverarbeitungsverträgen (AVV)** mit allen Drittanbietern, die personenbezogene Daten verarbeiten (Firebase, Unity Ads, Payment Provider).
*   **VERBINDLICH:** Das **implizite Spielstil-Tracking (F006)** erfolgt ausschließlich **on-device** und wird im Consent-Screen (S002) klar erklärt. Es handelt sich um First-Party-Gameplay-Daten, die außerhalb des ATT-Scopes liegen, wenn kein Advertising-Network involviert ist. Rechtsgrundlage: Vertragserfüllung (Personalisiertes Spielerlebnis).
*   **VERBINDLICH:** **Keine Datensammlung oder -übertragung ohne expliziten Consent** des Nutzers.
*   **EMPFEHLUNG:** Einsatz von **Privacy-Trust-Badges (P03)** auf dem Consent-Screen (S002) zur Stärkung des Vertrauens.

### Pflicht-UI
*   **VERBINDLICH:** **Datenschutzerklärung und Impressum (S019)** müssen jederzeit in der App zugänglich sein (z.B. über den Settings-Screen S018).
*   **VERBINDLICH:** **KI-Content-Kennzeichnung (F026):** Visuelle Kennzeichnung aller KI-generierten Inhalte (z.B. Levels, Story-Elemente) als 'KI-generiert' (S006, S009).
*   **VERBINDLICH:** **Haftungs-Disclaimer (F027):** Rechtlich geprüfte Disclaimer-Texte für Spieltipps und Empfehlungen.

### App Store Compliance
*   **VERBINDLICH:** Einhaltung der **Apple App Store Review Guidelines** und **Google Play Developer Program Policies**.
*   **VERBINDLICH:** **IAP-Pflicht:** Alle In-App-Käufe müssen über Apple App Store / Google Play Billing abgewickelt werden (keine externen Zahlungslinks).
*   **VERBINDLICH:** **Privacy Nutrition Label (Apple):** Korrektes und vollständiges Ausfüllen des Labels, auch wenn nur First-Party-Daten gesammelt werden.
*   **VERBINDLICH:** **IARC-Rating-Pflicht (Google Play):** Ausfüllen des Rating-Fragebogens für eine Einstufung "Alle Altersgruppen" (3+/Everyone).
*   **VERBINDLICH:** **Account-Löschfunktion:** Direkte Möglichkeit zur Account-Löschung in der App (S017).
*   **VERBINDLICH:** **Gast-Modus:** App muss ohne Registrierung nutzbar sein (Onboarding S003).

---

## 10. Tech-Stack Detail

**Hinweis:** Der Tech-Stack wurde für "echomatch" basierend auf den Design- und Asset-Anforderungen sowie den allgemeinen Mobile-Game-Entwicklungspraktiken adaptiert.

*   **Engine + Version:**
    *   **VERBINDLICH:** Unity 2022.3 LTS (oder neuer).
    *   **VERBINDLICH:** Unity Universal Render Pipeline (URP) für Bloom-Post-Processing und Emission-Maps (D1).
    *   **VERBINDLICH:** Unity Input System Package für erweiterte Gestensteuerung (D2).
    *   **VERBINDLICH:** TextMeshPro für dynamische Typografie (D4, W3).
    *   **VERBINDLICH:** Native Share Plugin (z.B. NativeShare by Yasirkula) für Share-Card-Export (D4, W3).
    *   **VERBINDLICH:** Lottie-Integration (z.B. Lottie for Unity) für UI-Animationen (A004, A012, A049 etc.).

*   **Backend-Dienste:**
    *   **VERBINDLICH:** Firebase (Google Cloud Platform) als primäres Backend.
        *   **Firebase Authentication:** Für Nutzer-Accounts (anonym, Google, Apple Sign-In) (F020).
        *   **Cloud Firestore:** Für Spieler-Fortschritt (Level, Score, Inventar), Freundeslisten, Battle Pass Status, Daily Quests (F020, F037, F016, F017).
        *   **Firebase Remote Config:** Für A/B-Tests, Feature-Flags, dynamische Shop-Angebote (F022, F035).
        *   **Firebase Cloud Functions:** Für serverseitige Logik (z.B. KI-Level-Generierung, Anti-Cheat-Validierung, Battle Pass Updates) (F022, F031, F047).
    *   **VERBINDLICH:** Google Cloud Run: Für die KI-Level-Generierung (F007, F031) und andere API-Endpunkte, die skalierbare, serverlose Ausführung erfordern.

*   **SDKs:**
    *   **VERBINDLICH:** Unity Ads (oder vergleichbares Ad-Netzwerk): Für Rewarded Ads (F015).
    *   **VERBINDLICH:** Firebase Analytics: Für Event-Tracking, Funnel-Analyse, Retention-Messung (F021).
    *   **VERBINDLICH:** Apple App Store / Google Play Billing: Für In-App-Käufe (IAP) und Abonnements (F014, F034, F036).
    *   **VERBINDLICH:** iOS Core Haptics / Android VibrationEffect: Für die Implementierung der Haptic Language (W2, Interaktions-Prinzipien).

*   **CI/CD Pipeline:**
    *   **EMPFEHLUNG:** Unity Cloud Build oder GitLab CI/CD mit Fastlane für automatisierte Builds und Deployments an TestFlight/Google Play Console.
    *   **EMPFEHLUNG:** Git für Versionskontrolle (GitFlow-Branching-Strategie).

*   **Monitoring + Crash-Reporting:**
    *   **VERBINDLICH:** Firebase Crashlytics: Für Echtzeit-Crash-Reporting und Performance-Monitoring.
    *   **EMPFEHLUNG:** Unity Analytics (oder Firebase Performance Monitoring): Für In-Game-Performance-Metriken (FPS, Ladezeiten).
    *   **EMPFEHLUNG:** Uptime-Monitoring für Cloud Run Endpunkte.

---

## 11. Release-Anforderungen

**Hinweis:** Der Release-Plan wurde aus dem "Release-Plan-Report: SkillSense" adaptiert und an den Kontext eines Match-3-Spiels angepasst.

### Phase 0: Closed Beta
*   **Ziel:** Kernfunktionen (Match-3 Core, Level-Progression, KI-Level-Generierung, Onboarding) unter realen Bedingungen validieren. Erste qualitative Nutzerfeedback-Daten sammeln.
*   **Dauer:** 4 Wochen
*   **Teilnehmer:** 150–300 handverlesene Spieler aus Gaming-Communities (Reddit r/Match3, Discord-Server). Einladungsbasiert. Schwerpunkt auf Zielgruppe 18-34.
*   **Erfolgskriterien:**
    *   ≥ 70% der Beta-Nutzer spielen mindestens 5 Levels (Feature Utilization Rate Kern-Feature).
    *   ≥ 30% der Nutzer kehren innerhalb von 7 Tagen zurück (D7 Retention).
    *   Level-Ladezeit (KI-Generierung) in unter 3 Sekunden für 90% der Levels (technische Performance-Schwelle).
    *   Qualitatives Feedback: Mindestens 50 ausgefüllte Feedback-Formulare mit offenen Antworten zu "Was hat dich überrascht?" und "Was fehlt?".
    *   0 kritische Datenschutzvorfälle (Client-Side-Versprechen muss technisch verifiziert sein).
    *   **WOW-Moment 1 (Logo-Genesis) und WOW-Moment 2 (Lebendiger erster Stein) lösen bei 80% der Tester positive, differenzierende Reaktionen aus.**

### Phase 1: Soft Launch (DACH)
*   **Ziel:** Öffentliche Zugänglichkeit für DACH-Markt herstellen. Monetarisierungs-Funnel scharfschalten (IAP, Rewarded Ads, Battle Pass Free). Erstes Revenue validieren.
*   **Dauer:** 6 Wochen
*   **Region(en):** Deutschland, Österreich, Schweiz (DACH). UI auf Deutsch und Englisch.
*   **Erfolgskriterien:**
    *   ≥ 1.000 registrierte Nutzer bis Ende Woche 6.
    *   D7 Retention ≥ 25%, D30 Retention ≥ 10%.
    *   IAP Conversion Rate ≥ 2% (Benchmark: 2-5% für Mobile Games).
    *   Rewarded Ad View Rate ≥ 15% (Benchmark: 10-20% für Match-3).
    *   Battle Pass Free Tier Adoption Rate ≥ 40%.
    *   ARPU (Average Revenue Per User) ≥ 0,15 €/Monat.
    *   0 kritische Abstürze (Crash-Rate < 0,5%).
    *   **WOW-Moment 3 (Goldene Ausatmung) führt zu mindestens 50 organischen Shares auf Social Media.**

