# Creative Director Technical Roadbook: EchoMatch
## Version: 1.0 | Status: VERBINDLICH fuer alle Produktionslinien

---

## 1. Produkt-Kurzprofil

**App Name:** EchoMatch

**One-Liner:**
EchoMatch ist ein KI-personalisiertes Hybrid-Casual Match-3-Spiel mit narrativer Story-Layer, das durch tägliche, spielstil-adaptive Levels und kooperative Social-Challenges die größte strukturelle Schwäche des $10-Mrd.-Puzzle-Marktes adressiert: fehlende Personalisierung.

**Plattformen:**
*   **Primär:** iOS (42–45% Nutzeranteil, ~60% Umsatzanteil) und Android (55–58% Nutzeranteil, ~38% Umsatzanteil)
*   **Sekundär:** Keine (Web/Browser explizit ausgeschlossen)
*   **Launch-Strategie:** Gestaffelter Soft-Launch (Kanada, Australien, Neuseeland) vor globalem Tier-1-Launch (USA, UK, DE, AU, CA) und anschließender Tier-2-Expansion (Brasilien, Indien, Südostasien).

**Tech-Stack:**
*   **Engine:** Unity (Industriestandard für Hybrid-Casual, Cross-Platform-Entwicklung)
*   **Backend:** Google Cloud Platform (Cloud Run für KI-Backend, Firebase Firestore/Realtime Database für User-Progress und Social Features, Firebase Cloud Messaging für Push Notifications, Firebase Analytics für Tracking)
*   **KI-Integration:** Modulare AI-Plugin-Architektur mit Cloud-Backend für Level-Generierung (z.B. Google Vertex AI oder OpenAI Enterprise mit IP-Indemnification)
*   **IAP/Ads:** Unity IAP, IronSource/AppLovin MAX (Mediation), AdMob (Rewarded Ads)
*   **Authentifizierung:** Firebase Authentication (anonyme Auth, Google Sign-In, Sign-in with Apple)

**Zielgruppe:**

| Segment | Alter | Region | Verhalten | Ausgabeverhalten |
|---|---|---|---|---|
| **Primär** | 18–34 | USA, UK, DE, AU, CA (Tier-1) | Casual-bis-Mid-Core, Commuter-Sessions (5–10 Min.), Social-affin, personalisierungsgetrieben | Aktive IAP-Käufer: ~$5–15/Monat; 39% fokussieren sich auf **ein** Spiel/Monat; Pay-to-Win-IAPs abgelehnt |
| **Sekundär** | 35–49 | Tier-1 + Brasilien, Indien | Moderate Spender, stärker IAP-getrieben, längere Sessions | Moderate Spender, offen für Battle-Pass und kosmetische IAPs |
| **Nische (nicht ignorieren)** | 50+ | Tier-1 | Höchste Session-Zeit in Puzzle-Games, Ad-Revenue-stark | Primär Ad-Revenue-Nutzer, geringe IAP-Affinität |

---

## 2. Design-Vision (VERBINDLICH)

### Design-Briefing
**EchoMatch ist ein Match-3-Puzzle-Spiel das sich visuell und emotional vollständig vom Candy-Crush-Industriemodell abkoppelt. Das Spielfeld ist dunkel — Mitternachtsblau-Schiefergrün (#0D0F1A bis #1A1D2E) als Grundschicht — und die Spielsteine sind selbstleuchtende Objekte die Licht emittieren statt reflektieren, realisiert durch Unity URP Bloom-Post-Processing und Emission-Maps. Die App fühlt sich an wie ein vertrautes Gespräch mit jemandem der dich wirklich kennt: ruhig genug zum Abschalten, lebendig genug um nicht aufzuhören. Energie-Level ist 6/10 — pulsierend und rhythmisch, niemals explodierend oder chaotisch. Navigation ist kontextuell statt statisch: es gibt keine feste Bottom-Bar mit fünf Icons, stattdessen reagiert die UI auf Tageszeit, Session-Phase und Quest-State. Animationen atmen mit 600–900ms Ease-In-Out statt in 200ms zu bursten. Haptik ist dreischichtig und narrativ bedeutsam. Sound ist Resonanz, nicht Explosion. Reward-Screens verzichten auf Konfetti und AMAZING-Schriften — stattdessen eine 1,5-sekündige goldene Farbverschiebung des gesamten Screens und eine lesbare Zusammenfassung der eigenen Spielhistorie. Jede Designentscheidung muss sich gegen diese Frage behaupten: Würde Candy Crush das genauso machen? Wenn ja, ist es falsch.**

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
| **D1** | **Dark-Field Luminescence** | Spielfeld-Hintergrund ist **#0D0F1A bis #1A1D2E** (tiefdunkles Blau-Grau). Spielsteine sind selbstleuchtende Objekte mit Unity URP Bloom-Post-Processing und Emission-Maps — sie emittieren Licht, sie reflektieren es nicht. Roter Stein = Glut. Blauer Stein = biolumineszentes Wasser. Hintergrund pulsiert subtil bei Combos. Farbtemperatur der Steine wechselt kapitelbasiert via ScriptableObjects: Kapitel 1 = kühle Töne, Kapitel 3 = warme Amber-Töne. Performant ab Snapdragon 678+ durch skalierbare Bloom-Intensität. | S001, S004, S006, S008, S009 | **VERBINDLICH — keine Verhandlung** |
| **D2** | **Kontextuelle Navigation** | **Keine feste Bottom-Bar mit 5 Icons.** Navigation reagiert auf Tageszeit, Quest-State und Session-Phase: 6–10 Uhr morgens = Daily Quest dominiert, Social minimiert; 12–14 Uhr = kompakte Commuter-Ansicht; 19–23 Uhr = Story-Hub-Teaser prominent, Shop-Nudge für Entspannungs-Session. Social-Nudges erscheinen als Lichtpuls auf Freundes-Avataren im Header statt als Push-Banner. Freunde sind als Lichtpunkte ambient auf der Level-Map sichtbar (Zenly-Prinzip) — kein separater Social-Tab nötig. | S005, S007, alle Hub-Screens | **VERBINDLICH — keine Verhandlung** |
| **D3** | **Implizites Spielstil-Tracking ab Sekunde 1** | Das Onboarding-Match (S003) erfasst unsichtbar: Pausenlänge zwischen Zügen (Grübler vs. Intuitiv), Zuggeschwindigkeit, Combo-Orientierung vs. schnelles Räumen. Kein Fragebogen, keine explizite Abfrage. Das erste echte KI-Level ist bereits personalisiert. Die narrative Hook-Sequenz (S004) passt ihr visuelles Setting an den erkannten Spieltyp an: Intuitiv-Schnell = kinetischere, städtischere Welt; Grübler = tiefere, mythologischere Welt. Personalisierung beginnt in Sekunde 1, ist für den Nutzer vollständig unsichtbar. | S003, S004, S006 | **VERBINDLICH — keine Verhandlung** |
| **D4** | **Post-Session-Screen als Poster / Share-Card** | Kein generischer Reward-overlay mit Konfetti. Der Ergebnis-Screen ist als Poster-Ästhetik designed (Spotify Wrapped-Prinzip): große isolierte Zahl oder Satz auf dunklem Grund, eine Akzentfarbe, lesbare Zusammenfassung des eigenen Spielstils ("Du hast heute 3 Cascades in einem Zug ausgelöst"). Format ist nativ share-optimiert — Nutzer schicken es weil es wie ein Statement aussieht, nicht wie ein UI-Screenshot. | S008, S009 | **VERBINDLICH — keine Verhandlung** |
| **D5** | **Story-NPC als Interface-Brecher** | Narrative Figuren können außerhalb ihrer Story-Screens erscheinen und das Interface kommentieren (Duolingo-Owl-Prinzip). Beispiel: NPC taucht nach einem verlorenen Level im Home Hub auf und gibt einen kontextuellen Kommentar im Ton der Spielwelt — kein generisches "Try again!". Diese Momente sind selten (max. 1× pro Woche) und dadurch bedeutsam. Sind primär für virales Social-Sharing designed: Out-of-Character-Momente die Nutzer screenshotten. | S005, S008, S009 | **VERBINDLICH — keine Verhandlung** |

### Anti-Standard-Regeln (VERBOTE — mindestens 4)

| # | VERBOTEN | STATTDESSEN | Betroffene Screens | Begründung |
|---|---|---|---|---|
| **A1** | Hypersaturierte Primärfarben auf weißem oder hellem Hintergrund — Candy-Crush-Palette, Knallrot/Knallblau/Knallgrün auf Weiß | Dunkle Grundpalette (**#0D0F1A–#1A1D2E**), selbstleuchtende Steine via Bloom-Shader, Bernstein- und Kupfer-Akzente, kapitelbasierte Farbtemperatur-Shifts | S006, S001, S004, alle Spielfeld-Screens | Das gesamte Genre cargo-cultet Candy Crush (2012); heller Hintergrund ist das stärkste visuelle Identitätsmerkmal des Einheitsbreis; Dunkelfeld differenziert sofort und ist Qualitätssignal für 18–34-Zielgruppe (Genshin, Alto's Odyssey, Robinhood) |
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
| **W3** | **Goldene Ausatmung** | S008, S009 | Nach Level-Abschluss keine Konfetti-Explosion. Das Spielfeld atmet einmal aus — alle Steine verblassen sanft innerhalb von 400ms. Dann: der gesamte Screen-Hintergrund verschiebt sich in 1,5 Sek. zu warmem Gold (**#C8960C**, Sättigung 60%, nicht grell). In dieser Goldpause erscheint eine einzelne Zeile die den Spielstil des Nutzers beschreibt ("Heute: 3 Cascades. Durchschnittszug: 1,4 Sekunden."). Dann: Poster-Format-Share-Card die nativ geteilt werden kann. | Stärkster Kontrastmoment zum Genre — jeder der das zum ersten Mal sieht weiß sofort: das ist nicht Candy Crush; die goldene Pause ist emotional nachhaltiger als Konfetti-Überwältigung; Poster-Share-Card ist der eingebaute virale Mechanismus (Spotify Wrapped-Prinzip); dieser Moment wird auf TikTok geteilt weil er so anders aussieht |
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
| **Nunito** | Headings, Level-Bezeichnungen, Battle-Pass-Tier-Labels, CTA-Button-Beschriftungen, Score-HUD-Hauptzahl | 700-800 | SIL Open Font License (Google Fonts); kostenlos, kommerziell nutzbar |
| **Inter** | Body Text, Quest-Beschreibungen, Shop-Kartentext, Onboarding-Erklaerungen, Settings, Notification-Texte | 400-500 | SIL Open Font License (Google Fonts); kostenlos, kommerziell nutzbar |
| **JetBrains Mono** | Numerische Daten mit festem Zeichenabstand: Score-Counter, Countdown-Timer, Move-Counter, Muenz-Zaehler; verhindert Layout-Shift bei sich aendernden Ziffern | 500-600 | SIL Open Font License (JetBrains / Google Fonts); kostenlos, kommerziell nutzbar |

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
*   **Static Fallback:** **VERBINDLICH** für alle Animationen (PNG-Sequenz oder End-State-Bild)

---

## 4. Feature-Map

### Phase A — Soft-Launch MVP (45 Features)
**Budget:** **252.500 EUR**

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten |
|---|---|---|---|---|---|
| **F001** | Match-3 Core Loop | Klassische Swipe-Puzzle-Mechanik als zentrales Gameplay. Spieler tauschen benachbarte Elemente, um Dreier-Ketten zu bilden. | D1, D7, D30, Session-Dauer, Sessions/Tag | 6 | |
| **F002** | Implizites Spielstil-Tracking (Onboarding) | 15–20 Sekunden Onboarding-Match erfasst Spielverhalten ohne Fragebogen. Spielstil-Kategorien (kooperativ, kompetitiv, entspannend) werden passiv abgeleitet. | D1, D7, Session-Dauer | 2 | F001 |
| **F003** | KI-basierte Level-Generierung | Tägliche Levels werden dynamisch auf Basis des erfassten Spielstils per KI generiert. Kein statischer Level-Pool — Inhalte sind pro Nutzer adaptiv. | D1, D7, D30, Session-Dauer | 8 | F001, F002, F018, F019 |
| **F006** | Narrative Hook-Sequenz beim Start | 10-sekündiger Story-Teaser nach dem Onboarding-Match, der den Spieler in die Welt einführt und die narrative Progression initiiert. | D1, Session-Dauer | 2 | F001, F005 |
| **F022** | Haptic Feedback System | Natives Haptic Feedback (Core Haptics auf iOS, Vibration API auf Android) für Match-Ereignisse und UI-Interaktionen zur Verbesserung der Spielhaptik. | D1, Session-Dauer, App-Store-Rating | 1 | F001 |
| **F034** | App Store Rating-Prompt | In-App-Aufforderung zur Bewertung im App Store / Google Play zum optimalen Zeitpunkt (nach positivem Spielerlebnis). Zielwert: ≥4,2 Sterne. | App-Store-Rating | 1 | F001 |
| **F037** | Session-Design-Enforcement (5–10 Min.) | Spieldesign-seitige Begrenzung und Optimierung der Session-Länge auf 5–10 Minuten für Commuter-Nutzungskontext. Level-Länge und Pacing entsprechend kalibriert. | Session-Dauer, Sessions/Tag, D7 | 2 | F001 |
| **F004** | Tägliche KI-Quests | Jeden Tag wird ein neuer Quest-Prompt generiert, der die persönliche Storyentwicklung vorantreibt. Quests sind spielstil-adaptiv und narrativ eingebettet. | D7, D30, Sessions/Tag | 4 | F003, F018, F036 |
| **F005** | Narrative Meta-Layer / Overarching Story (Basis) | Übergreifende Story, die durch tägliche Quests und Spielfortschritt weiterentwickelt wird. Dient als emotionaler Anker statt reiner Dekoration. (Basis-Version für Phase A) | D7, D30 | 4 | F004, F006, F036 |
| **F009** | Social-Nudge nach Session | Nach jedem Match-3-Run erscheint ein kontextueller Nudge (z.B. Freund herausfordern oder Team-Event beitreten), um den Social-Loop zu schließen. | Sessions/Tag, D7 | 1 | F001, F036 |
| **F010** | Social-Sharing-Mechanismus | Spieler können Spielergebnisse oder Challenges über native Share-Sheets (iMessage, AirDrop, allgemeine Share-APIs) teilen. Dient als organischer UA-Kanal. | D1, App-Store-Rating | 2 | F001 |
| **F011** | Rewarded Ads Integration | Spieler können freiwillig Werbeanzeigen schauen, um In-Game-Vorteile (z.B. Extra-Moves, Booster) zu erhalten. Primärer Revenue-Kanal für Free-Player. | Rewarded-Ad-eCPM | 2 | F001 |
| **F012** | Battle-Pass / Saison-Pass (Basis) | Monatliches Abo-Modell ($4–9/Monat) mit exklusiven Belohnungen, narrativen Inhalten und kosmetischen Items. Primärer Recurring-Revenue-Anker. (Basis-Version für Phase A) | D30 | 4 | F013, F036, F038, F039 |
| **F013** | Saison-Timer-System | Zeitlich begrenzte Saisons für den Battle-Pass mit Countdown und automatischem Saison-Wechsel. Erzeugt Dringlichkeit und strukturiert Live-Ops-Rhythmus. | D30 | 1 | F036 |
| **F015** | Convenience-IAPs | Käufliche Convenience-Items (z.B. Extra-Leben, Booster-Pakete) ohne Pay-to-Win-Charakter. Ergänzungsmonetarisierung für aktive Spieler. | D7 | 2 | F001, F036, F038 |
| **F016** | Foot-in-the-Door IAP-Einstiegsangebot | Niedrigpreisiges Einstiegs-IAP-Angebot (z.B. Starter-Pack) zur Erhöhung der Conversion-Rate auf weitere IAP-Käufe durch psychologischen Foot-in-the-Door-Effekt. | D7 | 1 | F015, F038 |
| **F018** | KI-Personalisierungs-Engine (Spielstil-Profiling) | Kontinuierliches Erfassen und Auswerten von Spielverhalten zur Pflege eines Spieler-Stil-Profils (kooperativ, kompetitiv, entspannend). Basis für alle adaptiven Features. | D1, D7, D30, Session-Dauer | 5 | F002, F036 |
| **F019** | Cloud-Backend für Level-Auslieferung | Server-seitige Generierung und Auslieferung von KI-Levels mit einer Latenz-Anforderung unter 2 Sekunden auf Mittelklasse-Hardware. | KI-Level-Latenz, D1, D7 | 5 | F018 |
| **F020** | Push-Notification-System | Native Push-Notifications für Session-Trigger (täglich neue Quests, Challenge-Einladungen, Team-Event-Start). Unterstützt Engagement- und Re-Engagement-Mechaniken. | D7, D30, Sessions/Tag | 2 | F036, F041 |
| **F023** | App Store Optimierung (ASO) | Optimierung von App-Store-Metadaten (Keywords, Screenshots, Beschreibung) für iOS App Store und Google Play zur Verbesserung organischer Sichtbarkeit. | App-Store-Rating, D1 | 2 | |
| **F024** | A/B-Testing-System | Parallele Tests für KI-generierte vs. manuell kuratierte Levels sowie für UI- und Monetarisierungs-Varianten. Erfassung von Completion-Rate, Session-Abbrüchen und Zufriedenheit. | D1, D7, KI-Level-Latenz | 2 | F025 |
| **F025** | Retention-Analytics-Dashboard | Tracking und Auswertung von D1-, D7- und D30-Retention-KPIs sowie Sessions/Tag und Session-Dauer. Grundlage für datengetriebene Optimierungsentscheidungen. | D1, D7, D30, Session-Dauer, Sessions/Tag | 2 | F036 |
| **F026** | Server-Uptime-Monitoring | Kontinuierliches Monitoring der Backend-Verfügbarkeit mit einem Zielwert von ≥99,5% Uptime. Alerts bei kritischen Ausfällen. | KI-Level-Latenz | 1 | F019 |
| **F027** | Cross-Platform-Deployment (iOS + Android simultan) | Gleichzeitiger Launch auf iOS und Android aus einer gemeinsamen Unity-Codebasis. Ermöglicht plattformübergreifende Retention-Split-Tests von Beginn an. | D1, D7 | 2 | F001 |
| **F028** | ATT-Consent-Flow (iOS) | App Tracking Transparency Opt-in-Dialog für iOS-Nutzer vor dem Behavioral-Tracking. Notwendig für IDFA-basiertes Tracking und KI-Personalisierung auf iOS. | D1 | 1 | |
| **F029** | Kaltstart-Personalisierung (ohne Tracking-Daten) | Fallback-Mechanismus für KI-Personalisierung bei Nutzern ohne Tracking-Einwilligung (bis zu 75% auf iOS). Regelbasierte oder populäre Level als initialer Ersatz. | D1 | 3 | F018, F028 |
| **F030** | TestFlight / Internal Testing Track Integration | Bereitstellung der App über Apple TestFlight (iOS) und Google Play Internal Testing Track (Android) für Closed-Beta-Phasen mit kontrollierten Tester-Gruppen. | Crash-Rate | 1 | F027 |
| **F031** | Crash-Reporting-System | Automatisiertes Erfassen und Reporten von App-Crashes mit Zielwert unter 2% Crash-Rate pro Session. Grundlage für Stabilitätssicherung. | Crash-Rate | 1 | F001 |
| **F032** | Strukturiertes Feedback-System (Beta) | In-App-Feedback-Bogen für Beta-Tester zur Bewertung von KI-generierten Levels (Spielbarkeit, Fairness). Ziel: ≥80% positive Bewertung als Go/No-Go-Kriterium. | D1, KI-Level-Latenz | 1 | F001, F003 |
| **F036** | Nutzer-Authentifizierung / Spieler-Profil-System | Persistente Spielerprofile zur Speicherung von Fortschritt, Spielstil, Story-Status und sozialen Verbindungen über Sessions und Geräte hinweg. | D7, D30 | 2 | F028, F042, F043 |
| **F038** | IAP-Missbrauchsschutz / Serverseitige Validierung | Serverseitige Validierung von In-App-Käufen zur Verhinderung von Receipt-Fraud und unberechtigtem Zugriff auf Premium-Inhalte. | Revenue | 2 | F036 |
| **F039** | Battle-Pass Content Visibility System | Alle Battle-Pass-Inhalte müssen vollständig und transparent vor dem Kauf sichtbar sein. Kein versteckter oder randomisierter Inhalt im Battle-Pass, um EU-Glücksspielrechts-Compliance sicherzustellen. | Revenue | 1 | F012 |
| **F040** | Deterministisches Belohnungsdesign für Daily Quests | Daily-Quest-Belohnungen müssen vollständig deterministisch sein – kein variabler oder zufallsbasierter Belohnungsinhalt. Eliminiert das größte Glücksspielrechtsrisiko in BE/NL ohne funktionalen Verlust. | D7, D30 | 1 | F004 |
| **F041** | FOMO-Mechanik Compliance Filter | Push-Notifications und Daily-FOMO-Content (täglich wechselnde KI-Quests) müssen auf manipulative Dark Patterns geprüft und ggf. entschärft werden. Frequenz, Tonalität und Triggerlogik müssen DSA-konform und nicht als Sucht-Design klassifizierbar sein. | Sessions/Tag | 2 | F020, F004 |
| **F042** | DSGVO Consent Management System | Vollständiges Consent-Management für EU-Nutzer: granulare Einwilligungen für Datenverarbeitung, KI-Personalisierung, Analytics und Werbung. Nachweis-fähige Consent-Logs mit Timestamp. Widerrufsmöglichkeit jederzeit. | | 3 | |
| **F043** | COPPA Altersverifikation und Minderjährigenschutz | Altersabfrage beim Onboarding zur Identifikation von Nutzern unter 13 Jahren (COPPA) bzw. unter 16 Jahren (DSGVO Kinder). Separate Datenschutzpfade für Minderjährige: keine Behavioral Tracking, keine personalisierten Ads, eingeschränkte Social Features. | | 2 | F042 |
| **F044** | App Tracking Transparency (ATT) iOS Implementation | Korrekte technische Implementierung des ATT-Frameworks unter iOS für die KI-Personalisierung und Behavioral Tracking. ATT-Permission-Request mit erklärendem Pre-Permission-Screen vor dem System-Prompt. | | 1 | F028 |
| **F045** | Apple Privacy Nutrition Label Datendeklaration | Vollständige und akkurate Deklaration aller erhobenen Datenkategorien im Apple App Store Privacy Nutrition Label. Muss alle KI-Personalisierungs-Daten, Analytics-Events und Werbedaten abdecken. | | 1 | F042, F044 |
| **F046** | Google Play Data Safety Section Deklaration | Vollständige Ausfüllung der Google Play Data Safety Section mit allen Datenkategorien, Erhebungszwecken und Drittanbieter-SDKs. Muss konsistent mit tatsächlicher App-Datenerhebung sein. | | 1 | F042 |
| **F047** | KI-Anbieter IP-Indemnification Vertragsmanagement | Sicherstellung dass der eingesetzte KI-Anbieter für Level-Generierung eine IP-Indemnification-Klausel im Vertrag aufweist (OpenAI Enterprise, Google Vertex AI, Microsoft Azure). Dokumentation der Vertragsprüfung als Compliance-Nachweis. | | 1 | F003 |
| **F049** | Jugendschutz-Rating Integration (USK/PEGI/IARC) | Durchführung des IARC-Rating-Prozesses für Google Play und Apple App Store sowie länderspezifische USK/PEGI-Ratings. Rating-konformes Feature-Gating: altersabhängige Freischaltung von Social Features und Chat-Funktionen. | | 1 | F043 |
| **F051** | Markenrechts-Monitoring und Namens-Clearance | Durchführung einer Markenrecherche für 'EchoMatch' in relevanten Jurisdiktionen (DE, US, EU, AU, CA, UK) vor Launch. Einrichtung eines laufenden Monitorings auf Markenrechtskonflikte nach dem Launch. | | 1 | |
| **F035** | Minimal Paid UA Creative-Testing | Kleines UA-Testbudget ($2.000–5.000) für Meta/TikTok-Creative-Tests im Soft-Launch zur Identifikation performanter Ad-Creatives vor globalem Rollout. | D1 | 2 | F027, F023 |
| **F007** | Asynchrone Friend-Challenges | Spieler können Freunde zu Match-3-Challenges herausfordern, ohne dass beide gleichzeitig online sein müssen. Ergebnisse werden asynchron verglichen. | D7, Sessions/Tag | 4 | F001, F009, F036, F050 |
| **F050** | Social Feature Schutzpflichten System | Technische und organisatorische Maßnahmen für Social Features: Melde-Funktion für unangemessene Inhalte, Blockier-Funktion, Moderations-Workflow für User-Generated Content in Freundes-Challenges. Besonderer Schutz für minderjährige Nutzer. | | 2 | F043 |

### Phase B — Full Production (7 Features)
**Budget:** **230.000 EUR**

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten |
|---|---|---|---|---|---|
| **F008** | Kooperative Team-Events | Gruppen-Events, bei denen mehrere Spieler gemeinsam auf ein kollektives Ziel hinarbeiten. Events sind KI-adaptiv auf erkannte Team-Präferenzen zugeschnitten. | D30, Sessions/Tag | 6 | F007, F033, F036 |
| **F014** | Kosmetische IAPs | Käufliche kosmetische Items (z.B. Themes, Charakterskins, Board-Designs) ohne Gameplay-Vorteil. Zielt auf High-Spender im Segment 25–49. | D30 | 4 | F012, F036, F038 |
| **F017** | Ad-Revenue-Optimierung für Tier-2-Märkte | Spezifische Ad-Placement-Strategie für Brasilien, Indien und Südostasien, wo Ad-Revenue das primäre Monetarisierungsmodell darstellt (hohes Volumen, niedriger ARPU). | | 2 | F011 |
| **F021** | iOS Live Activities / Dynamic Island Integration | Nutzung von iOS Live Activities und Dynamic Island für Session-Trigger und aktive Spielstand-Anzeige außerhalb der App. | Sessions/Tag, D7 | 4 | F020 |
| **F033** | Live-Ops-System für Events | Serverseitig steuerbare zeitlich begrenzte Events (Team-Events, Sonder-Quests), die ohne App-Update ausgerollt werden können. Grundlage für laufenden Live-Ops-Rhythmus. | D30, Sessions/Tag | 4 | F004, F008, F036 |
| **F048** | Menschlicher Redaktionsanteil Dokumentation für AI-Content | Systematische Dokumentation der menschlichen Redaktionsanteile im KI-generierten Content (insbesondere Narrative Layer) zur Stärkung der urheberrechtlichen Position. Workflow-Protokollierung welche Inhalte manuell kuratiert oder nachbearbeitet wurden. | | 2 | F003, F047 |
| **F052** | Compliance-Dokumentationssystem für Reward-Mechaniken | Systematische schriftliche Dokumentation aller Designentscheidungen zu Belohnungsstrukturen als Compliance-Nachweis gegenüber Regulierungsbehörden (insbesondere BE, NL, EU). Beinhaltet Begründung warum Mechaniken kein Glücksspiel darstellen. | | 2 | F039, F040 |

### Backlog — Post-Launch (3 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |
|---|---|---|---|---|
| **F005** | Narrative Meta-Layer / Overarching Story (Vollausbau) | v1.1 | Signifikanter D30-Retention-Lift durch emotionalen Story-Anker; erhöht Battle-Pass-Wert durch narrative exklusive Inhalte | Basis-Narrative in Phase A ausreichend für Soft-Launch-KPIs. Vollständige übergreifende Story mit tiefer narrativer Progression erfordert Content-Produktion die Phase A Budget übersteigt. Vollausbau als erstes Post-Launch-Update mit höchster Priorität. |
| **F014** | Kosmetische IAPs (Erweitert - Vollsortiment) | v1.1 | Signifikanter ARPU-Lift im High-Spender-Segment 25-49; erhöht Battle-Pass-Attraktivität durch breiteres Kosmetik-Portfolio | Basis-Kosmetik-IAPs in Phase B bereits enthalten. Vollständiges Sortiment (Themes, Character-Skins, Board-Designs) benötigt umfangreiche Art-Production die post-Launch realistischer ist. |
| **F033** | Live-Ops-System (Vollautomatisierung) | v1.2 | Ermöglicht wöchentlichen Live-Ops-Rhythmus ohne Entwickler-Eingriff; skaliert Event-Frequenz für D30+ Retention | Basis Live-Ops via Firebase Remote Config in Phase B. Vollautomatisiertes Event-Scheduling und dynamische Event-Generierung durch KI ist komplexes System das nach erstem Daten-Feedback sinnvoller entwickelt werden kann. |

---

## 5. Abhaengigkeits-Graph & Kritischer Pfad

### Build-Reihenfolge (welche Features zuerst)
Die Reihenfolge der Feature-Implementierung folgt der Priorisierung in der Feature-Map (Phase A vor Phase B, dann Backlog) und berücksichtigt die expliziten Abhängigkeiten. Features mit hohem KPI-Impact und geringer Komplexität werden innerhalb einer Phase zuerst umgesetzt.

### Kritischer Pfad mit Dauer in Wochen
**Kette:** F001 (6 Wo) → F002 (2 Wo) → F003 (8 Wo) → F004 (4 Wo) → F005 (4 Wo) → F033 (4 Wo) → F008 (6 Wo)
**Gesamtdauer:** **34 Wochen** (sequenziell, über beide Phasen)
**Beschreibung:** Der kritische Pfad beginnt mit dem Match-3 Core Loop (F001), der die Basis für das implizite Spielstil-Tracking (F002) bildet. Dieses Tracking ist der Dateneingangspunkt für die KI-basierte Level-Generierung (F003), welche ein Go/No-Go-Kriterium für den Soft-Launch darstellt. Die täglichen KI-Quests (F004) als primärer Retention-Treiber bauen auf der KI-Generierung auf. Die narrative Meta-Layer (F005) ist eng mit den Quests verzahnt. In Phase B ist das Live-Ops-System (F033) eine Voraussetzung für die Implementierung kooperativer Team-Events (F008), die den kritischen Pfad abschließen.

### Parallelisierbare Feature-Gruppen
*   **Phase A – Sofort parallel zu F001 (Core Loop):** F022 (Haptic Feedback), F034 (Rating-Prompt), F037 (Session-Design-Enforcement). Diese Features haben geringe Abhängigkeiten und können frühzeitig die UX verbessern.
*   **Phase A – Parallel nach F001-Fertigstellung:** F006 (Narrative Hook), F009 (Social-Nudge), F010 (Social-Sharing). Diese UI-zentrierten Features können parallel zur KI-Backend-Entwicklung (F003, F018, F019) erfolgen.
*   **Phase A – KI-Backend-Track parallel zu UI-Features:** F003 (KI-Level-Generierung), F018 (KI-Engine), F019 (Cloud-Backend). Diese sind technisch komplex und können parallel zu vielen Frontend-Features entwickelt werden.
*   **Phase A – Quest und Story parallel:** F004 (Tägliche KI-Quests), F005 (Narrative Meta-Layer Basis). Diese sind inhaltlich eng verknüpft.
*   **Phase B – Revenue und Social parallel:** F014 (Kosmetische IAPs), F017 (Ad-Revenue-Optimierung). Diese können parallel zu den Live-Ops- und Social-Features entwickelt werden, sobald die Basis-Monetarisierung (F011, F012) steht.
*   **Phase B – iOS und Dokumentation parallel:** F021 (iOS Live Activities), F048 (Menschlicher Redaktionsanteil Dokumentation), F052 (Compliance-Dokumentation). Diese haben geringe Abhängigkeiten zu den Kern-Gameplay-Features.

---

## 6. Screen-Architektur (VERBINDLICH)

### Screen-Uebersicht (22 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| **S001** | Splash / Loading | Hauptscreen | App-Start, Asset-Preloading, Crash-Reporter-Init, Analytics-Init | F031, F025 | Normal, Slow-Connection, Offline-Error, Update-Required |
| **S002** | DSGVO / ATT Consent Onboarding | Modal | Rechtlich verpflichtende Consent-Abfrage vor erstem Tracking-Event, ATT-Prompt iOS, COPPA-Alterscheck | F028, F042, F043 | Normal-iOS, Normal-Android, Minderjähriger-Blocked, ATT-Verweigert-Fallback |
| **S003** | Onboarding Match / Spielstil-Tracking | Hauptscreen | Implizites 15–20s Spielstil-Tracking via erstem spielbaren Match-3-Tutorial, kein Fragebogen, direkter Einstieg in Core-Loop | F001, F002, F022, F037 | Normal, Erste-Züge-Hint-Aktiv, Tracking-Komplett, Langsame-Verbindung-Fallback |
| **S004** | Narrative Hook Sequenz | Hauptscreen | 10-Sekunden Story-Teaser nach Onboarding als emotionaler Anker, erster Eindruck der narrativen Meta-Layer | F006, F005 | Normal, Skip-Aktiviert, Assets-Nicht-Geladen-Fallback |
| **S005** | Home Hub | Hauptscreen | Zentraler Einstiegspunkt nach Onboarding, täglicher Re-Entry-Screen, Daily Quest Prompt, Battle-Pass Teaser, Social Nudge | F004, F005, F009, F012, F013 | Normal-Erster-Start, Normal-Returning-User, Daily-Quest-Abgeschlossen, Battle-Pass-Abgelaufen, Offline, Push-Notification-Deep-Link-Entry |
| **S006** | Puzzle / Match-3 Spielfeld | Hauptscreen | Core-Loop Match-3-Gameplay, KI-generierte Level, Session-Design 5-10 Minuten, Haptic Feedback | F001, F003, F015, F022, F037 | Normal-Spielend, Level-Laden, KI-Level-Latenz-Warten, Zug-Aufgebraucht-Pause, Level-Gewonnen, Level-Verloren, Offline-Fallback-Cached-Level, Booster-Aktiv |
| **S007** | Level-Ergebnis / Post-Session | Hauptscreen | Session-Abschluss-Screen nach gewonnenem oder verlorenem Level, Social-Nudge-Trigger, Rating-Prompt-Trigger, Sharing-CTA | F009, F010, F034, F025, F037 | Gewonnen-Normal, Gewonnen-Quest-Komplett, Verloren-Retry, Verloren-Rewarded-Ad-Angebot, Rating-Prompt-Aktiv, Offline |
| **S008** | Level-Map / Progression | Hauptscreen | Visuelle Level-Übersicht, Fortschrittspfad, Narrative-Meta-Verbindung, tägliche KI-Quest-Markierung | F003, F004, F005, F037 | Normal, Neues-Level-Freigeschaltet-Animation, KI-Level-Geladen, KI-Level-Lädt, Offline-Cached |
| **S009** | Story / Narrative Hub | Hauptscreen | Narrative Meta-Layer Hauptscreen, Story-Kapitel-Übersicht, Quest-Storyfortschritt, emotionaler Anker für D30-Retention | F005, F004, F006 | Normal, Neues-Kapitel-Freigeschaltet, Alle-Kapitel-Gelesen, Offline-Cached-Content |
| **S010** | Social Hub | Hauptscreen | Social-Layer, Friend-Challenges, Team-Events, Social-Sharing-Einstiegspunkt, Leaderboard-Preview | F009, F010, F005 | Normal-Mit-Freunden, Normal-Keine-Freunde, Challenge-Ausstehend, Offline |
| **S011** | Shop / Monetarisierungs-Hub | Hauptscreen | Zentraler IAP-Shop, Battle-Pass-Kauf, Convenience-IAPs, Foot-in-Door-Einstiegsangebot, Rewarded-Ad-Trigger | F011, F012, F015, F016, F038 | Normal, Foot-in-Door-Angebot-Aktiv, Battle-Pass-Bereits-Gekauft, IAP-Fehler, Laden, Offline-Gesperrt |
| **S012** | Battle-Pass Screen | Subscreen | Dedizierter Battle-Pass-Fortschritts-Screen, Reward-Tier-Übersicht, Saison-Timer, Content-Visibility-Compliance | F012, F013, F039, F040 | Normal-Free, Normal-Premium, Saison-Läuft-Ab-Bald, Saison-Abgelaufen, Laden |
| **S013** | Tägliche Quests Screen | Subscreen | Übersicht aller aktiven täglichen KI-Quests, Quest-Fortschritt, Reward-Preview, FOMO-Timer-konform | F004, F040, F041, F013 | Normal-Quests-Offen, Alle-Quests-Abgeschlossen, Quests-Laden, Offline-Cached, Quest-Reset-Countdown |
| **S014** | Push Notification Opt-In | Modal | Permissionsanfrage für Push-Notifications, FOMO-Compliance-konform, Opt-Out erklärend | F020, F041 | Normal, System-Dialog-Folge-iOS, System-Dialog-Folge-Android, Bereits-Erlaubt, Permanent-Abgelehnt |
| **S015** | Social Share Sheet | Overlay | Nativer Social-Sharing-Flow nach Session oder Level-Ergebnis, organischer UA-Kanal | F010 | Normal, Share-Erfolgreich, Share-Abgebrochen, Keine-Share-Apps-Installiert |
| **S016** | Rewarded Ad Interstitial | Overlay | Rewarded-Ad-Angebot vor oder nach Level, Extra-Leben oder Booster als Reward, eCPM-Tracking | F011 | Angebot-Aktiv, Ad-Lädt, Ad-Läuft, Ad-Abgeschlossen-Reward, Ad-Fehler-Fallback, Ad-Übersprungen-Kein-Reward |
| **S017** | Profil / Spieler-Account | Subscreen | Spielerprofil, Statistiken, Account-Verwaltung, Authentifizierung, Firebase Auth Status | F036, F025 | Normal-Anonym-Auth, Normal-Registriert, Sync-Fehler, Offline |
| **S018** | Einstellungen | Subscreen | App-Einstellungen, Consent-Verwaltung, Notification-Einstellungen, Haptic-Toggle, Datenschutz | F022, F020, F041, F042 | Normal, Consent-Neu-Angefragt |
| **S019** | Beta Feedback Screen | Subscreen | Strukturiertes Beta-Feedback für KI-Level-Bewertung, Go/No-Go-Kriterium ≥80% positive Bewertung | F032, F003 | Normal, Formular-Unvollständig, Gesendet-Danke, Senden-Fehler |
| **S020** | Kaltstart Personalisierungs-Fallback | Overlay | Fallback-Personalisierungs-Auswahl für iOS-User ohne ATT-Consent, sichert KI-Personalisierung für bis zu 75% der Nutzer | F029, F028 | Normal-ATT-Verweigert, Auswahl-Getroffen, Nur-Android-Kein-ATT-Nötig |
| **S021** | Offline Error Screen | Overlay | Globaler Offline-Zustand-Handler, Cached-Content-Hinweis, Reconnect-CTA | F019, F026 | Keine-Verbindung, Server-Down, Reconnect-Versucht, Cached-Mode-Aktiv |
| **S022** | A/B Test Variant Loader | Overlay | Transparenter A/B-Test-Konfigurations-Loader beim App-Start, KI-generiert vs. Manuell kuratiert Test-Assignment | F024, F025 | Zuweisung-Lädt, Zuweisung-Komplett, Fallback-Control-Group |

### Screen-Hierarchie

*   **Tab-Bar Navigation (Minimal-Set für iOS HIG Compliance):**
    *   **Home** (S005)
        *   S013 (Tägliche Quests Screen)
        *   S017 (Profil / Spieler-Account)
        *   S018 (Einstellungen)
    *   **Puzzle** (S008)
        *   S006 (Puzzle / Match-3 Spielfeld)
        *   S007 (Level-Ergebnis / Post-Session)
    *   **Story** (S009)
    *   **Social** (S010)
        *   S015 (Social Share Sheet)
    *   **Shop** (S011)
        *   S012 (Battle-Pass Screen)
*   **Modals:** S002 (DSGVO / ATT Consent Onboarding), S014 (Push Notification Opt-In), S019 (Beta Feedback Screen)
*   **Overlays:** S015 (Social Share Sheet), S016 (Rewarded Ad Interstitial), S020 (Kaltstart Personalisierungs-Fallback), S021 (Offline Error Screen), S022 (A/B Test Variant Loader)

### Navigation
Die Navigation ist **kontextuell** und **gestenbasiert**, ergänzt durch eine **minimale, schlanke Bottom-Tab-Bar** für iOS HIG Compliance. Die Bottom-Bar enthält maximal 3 Icons (Home, Puzzle, Profil) und ist nicht das primäre Navigationserlebnis. Kontextuelle Elemente (Radial-Menü, situative Action-Surfaces) erscheinen dynamisch über dieser Basis-Bar.

### User Flows (7 Flows)

#### Flow 1: Onboarding (Erst-Start)
*   **Pfad:** S001 → S002 → S020 (iOS ATT verweigert) → S003 → S004 → S005
*   **Taps bis Core Loop:** **3 Taps** (Consent bestätigen → Tutorial starten → Narrative Skip oder Watch)
*   **Zeitbudget:** ~55–65 Sekunden
*   **Detail:**
    *   S001 lädt Assets, initialisiert Crash-Reporter + Analytics (automatisch, kein Tap)
    *   S002 zeigt DSGVO-Consent + ATT-Prompt (iOS) — **VERBINDLICH:** Pflicht-Tap: **Tap 1** (Zustimmen)
    *   Bei ATT-Zustimmung → direkt S003
    *   Bei ATT-Ablehnung → S020 (Kaltstart-Personalisierungs-Fallback, max. 1 Tap zur Auswahl) → S003
    *   S003 startet implizites 15–20s Spielstil-Tracking-Tutorial (automatisch, kein Fragebogen) — Tap-Sequenz zählt als Gameplay, nicht als Navigation — **VERBINDLICH:** **Tap 2** (erster Spielzug aktiviert Tutorial)
    *   S004 zeigt 10s Narrative Hook — **VERBINDLICH:** **Tap 3** (Skip oder Watch-through → automatisch weiter)
    *   S005 (Home Hub, Erster-Start-State) wird geladen
*   **Fallback bei Consent-Ablehnung:** S020 wird übersprungen → S003 läuft mit generischen Levels (Cache-Preset, kein personalisiertes KI-Profil) → Tracking-Profil bleibt anonym-aggregiert
*   **Fallback bei Minderjährigem (COPPA):** S002 erkennt Alterscheck-Fail → **VERBINDLICH:** Hard-Block, App nicht nutzbar, kein Weiterleiten

#### Flow 2: Core Loop (wiederkehrend)
*   **Pfad:** S005 → S008 → S006 → S007 → S005 (oder S010 für Social Nudge)
*   **Taps bis Match:** **2 Taps**
*   **Session-Ziel:** **6–10 Minuten**
*   **Detail:**
    *   S005 (Returning-User-State) zeigt Daily Quest Prompt + Battle-Pass Teaser — **VERBINDLICH:** **Tap 1** (Navigation zur Level-Map via Tab-Bar: Puzzle-Tab)
    *   S008 zeigt Level-Map mit nächstem freigeschalteten Level + KI-Quest-Markierung — **VERBINDLICH:** **Tap 2** (Level antippen → startet S006)
    *   S006 lädt KI-generiertes Level (State: Level-Laden, max. 2s Ladezeit) → Gameplay startet automatisch
    *   Spieler absolviert 1–3 Levels (5–10 Minuten Gesamt-Session)
    *   S007 erscheint nach Level-Abschluss (Gewonnen oder Verloren)
    *   Bei Gewonnen: Social-Nudge-Trigger sichtbar (CTA → S010 oder S015)
    *   Bei Gewonnen + Quest abgeschlossen: State Gewonnen-Quest-Komplett mit erhöhtem Reward-Feedback
    *   Rückkehr zu S005 über CTA-Button oder Tab-Bar (kein zusätzlicher Tap nötig wenn Auto-Return aktiv)
*   **Gesamt-Taps für eine vollständige Loop-Runde:** 2 Taps bis Match, ~4–6 Taps für vollständige Session inkl. Post-Screen-Navigation

#### Flow 3: Erster Kauf (Foot-in-Door IAP)
*   **Pfad:** S005 → S011 → S011 (Foot-in-Door-Angebot-Aktiv-State) → Nativer Payment-Dialog (OS-Layer) → S011 (Bestätigung) → S005
*   **Taps bis Kauf:** **3 Taps**
*   **Detail:**
    *   S005 zeigt Battle-Pass Teaser oder Shop-Nudge nach erstem gewonnenen Level — **VERBINDLICH:** **Tap 1** (Shop-Tab in Tab-Bar oder direkter CTA-Button)
    *   S011 lädt im State Foot-in-Door-Angebot-Aktiv (zeitlich limitiertes Einstiegsangebot, Preis-Anker prominent) — **VERBINDLICH:** **Tap 2** (Angebot antippen / Kaufen-Button)
    *   Nativer OS-Payment-Dialog erscheint (Apple Pay / Google Pay / Store-Dialog) — **VERBINDLICH:** **Tap 3** (Kauf bestätigen)
    *   S011 wechselt zu Bestätigungs-State, Reward wird gutgeschrieben
    *   Rückkehr zu S005 über Back-Navigation oder Tab-Bar
*   **Trigger-Varianten:**
    *   Alternativ-Einstieg über S007 (Level-Verloren → Rewarded-Ad-Angebot nicht gewünscht → Shop-CTA) → S011
    *   Alternativ-Einstieg über S012 (Battle-Pass-Teaser auf Home Hub) → S012 → S011

#### Flow 4: Social Challenge
*   **Pfad:** S005 → S010 → S010 (Challenge-Ausstehend-State) → S006 → S007 → S015 → S010
*   **Taps:** **3 Taps** bis Challenge-Start
*   **Detail:**
    *   S005 zeigt Social-Nudge (z.B. „Freund hat dich herausgefordert") — **VERBINDLICH:** **Tap 1** (Social-Tab in Tab-Bar)
    *   S010 öffnet im State Challenge-Ausstehend mit prominenter Challenge-Card — **VERBINDLICH:** **Tap 2** (Challenge annehmen)
    *   S006 startet Challenge-Level (KI-generiert, auf Spielstil beider Spieler angepasst, asynchron)
    *   S007 zeigt Ergebnis mit Challenge-Vergleich (eigener Score vs. Freund-Score)
    *   Social-Share-CTA erscheint — **VERBINDLICH:** **Tap 3** (Share antippen → S015 öffnet nativ)
    *   S015 (Share Sheet) → Plattform-Auswahl → Share → Rückkehr zu S010
*   **Kein-Freunde-State:** S010 zeigt Normal-Keine-Freunde-State → CTA „Freunde einladen" → S015 (Invite-Flow) statt Challenge-Flow

#### Flow 5: Battle-Pass
*   **Pfad:** S005 → S012 → S011 → Nativer Payment-Dialog → S012 (Premium-State)
*   **Taps:** **3 Taps** bis Kauf
*   **Detail:**
    *   S005 zeigt Battle-Pass-Teaser-Banner (Returning-User-State, Saison aktiv) — **VERBINDLICH:** **Tap 1** (Battle-Pass-Banner antippen → S012)
    *   S012 öffnet im State Normal-Free (Reward-Tier-Übersicht, gesperrte Premium-Tiers sichtbar als Content-Visibility-Compliance-konformer Anreiz, Saison-Timer läuft) — **VERBINDLICH:** **Tap 2** (Premium kaufen-Button → leitet zu S011 weiter)
    *   S011 bestätigt Battle-Pass-IAP im korrekten Pricing-State — **VERBINDLICH:** **Tap 3** (Kauf bestätigen via OS-Dialog)
    *   S012 wechselt zu Normal-Premium-State, alle Tiers freigeschaltet, bereits gesammelte Rewards sofort einlösbar
    *   Saison-Ablauf-Handling: S012 im State Saison-Läuft-Ab-Bald zeigt FOMO-konformen Countdown (kein Dark Pattern: Ablaufdatum klar kommuniziert) → erhöhte Conversion-Wahrscheinlichkeit
*   **Bereits-Gekauft-State:** S012 zeigt Normal-Premium direkt, kein Kauf-CTA, nur Fortschritts-Tracking

#### Flow 6: Rewarded Ad
*   **Pfad:** S006 (Züge-Aufgebraucht) → S016 (Angebot-Aktiv) → S016 (Ad-Läuft) → S016 (Ad-Abgeschlossen-Reward) → S006 (Booster-Aktiv)
*   **Taps:** **2 Taps**
*   **Detail:**
    *   S006 wechselt in State Zug-Aufgebraucht-Pause → automatisches Overlay-Trigger: S016 erscheint im State Angebot-Aktiv (Extra-Leben oder Booster als Reward kommuniziert) — **VERBINDLICH:** **Tap 1** (Ad anschauen bestätigen)
    *   S016 wechselt zu Ad-Lädt (max. 3s Ladeindikator) → Ad-Läuft (non-skippable 30s Rewarded Ad, eCPM-Tracking aktiv)
    *   Nach Ad-Ende: S016 State Ad-Abgeschlossen-Reward — **VERBINDLICH:** **Tap 2** (Reward einlösen / weiter)
    *   S006 resumt im State Booster-Aktiv mit gutgeschriebenen Extra-Zügen oder Booster-Effekt
*   **Alternativer Trigger:** S007 (Verloren-Rewarded-Ad-Angebot) → S016 → bei Reward → Level-Retry in S006
*   **Ad-Fehler-Handling:** S016 State Ad-Fehler-Fallback → Fehlermeldung → Rückkehr zu S006 oder S007 ohne Reward, kein Hard-Lock

#### Flow 7: Consent-Detail-Flow (vollständig)
*   **Pfad:** S001 → S002 (Normal-iOS oder Normal-Android) → [Verzweigung] → S020 oder S003
*   **Detail nach Entscheidungsbaum:**
    *   **Pfad A — Vollständige Zustimmung (iOS):**
        *   S002 zeigt DSGVO-Text + Zustimmungs-Button + ATT-Erklärungstext
        *   Tap: Zustimmen → iOS-System-ATT-Dialog erscheint (OS-Layer, außerhalb App-Control)
        *   ATT erlaubt → S003 (volles KI-Tracking aktiv, personalisierte Level ab Session 1)
    *   **Pfad B — ATT verweigert (iOS):**
        *   S002 → DSGVO zugestimmt → ATT-System-Dialog → ATT abgelehnt
        *   S020 öffnet (Kaltstart-Personalisierungs-Fallback, State: Normal-ATT-Verweigert)
        *   Nutzer trifft manuelle Stil-Auswahl (1 Tap) → sichert KI-Personalisierung für bis zu 75% der Nutzer ohne IDFA
        *   → S003 (teil-personalisierte Level, regelbasiertes Fallback-Profil)
    *   **Pfad C — Android (kein ATT):**
        *   S002 zeigt DSGVO-only-Flow (State: Normal-Android)
        *   S020 nicht ausgelöst (State: Nur-Android-Kein-ATT-Nötig)
        *   Zustimmung → S003 (volles Tracking über Android-Identifier aktiv)
    *   **Pfad D — Minderjähriger (COPPA):**
        *   S002 führt Alterscheck durch → Unter-13-Erkennung
        *   **VERBINDLICH:** State: Minderjähriger-Blocked → Hard-Block, App nicht nutzbar
        *   Kein Weiterleiten zu S003, kein Tracking, kein Gameplay
    *   **Consent-Verwaltung nachträglich:**
        *   S005 → S017/S018 (Einstellungen, State: Consent-Neu-Angefragt) → S002 re-öffnet als Modal
        *   Änderungen werden sofort auf Tracking + KI-Personalisierungsprofil angewendet

### Edge Cases (7 Situationen)

| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| **Consent vollständig abgelehnt (DSGVO Nein)** | S002, S003, S006, S008 | Kein Tracking, keine KI-Personalisierung; S003 startet mit generischen Preset-Levels aus Cache; S006 liefert nur vorkuratierte statische Levels; S020 wird nicht ausgelöst; Battle-Pass und Shop bleiben nutzbar ohne personalisierte Empfehlungen |
| **ATT verweigert (iOS only)** | S002, S020, S003, S006 | S020 Kaltstart-Fallback öffnet direkt nach S002; Nutzer wählt Spielstil manuell (1 Tap); KI-Personalisierung läuft regelbasiert ohne IDFA; eCPM für Ads reduziert (non-personalized Ads Fallback in S016); Analytics laufen aggregiert weiter |
| **Internetverlust während aktivem Match** | S006, S021 | S006 wechselt zu State Offline-Fallback-Cached-Level; laufende Session wird lokal weitergeführt; Züge und Score werden lokal gecacht; nach Reconnect: automatischer Sync-Versuch; S021 erscheint als Overlay nur bei komplettem Verbindungsabbruch vor Level-Start, nicht mid-Game |
| **KI-Level-Generierung schlägt fehl (Latenz > Timeout)** | S006, S008 | S006 zeigt State KI-Level-Latenz-Warten mit Ladeindikator (max. 5s); nach Timeout: automatischer Fallback auf zuletzt gecachtes kuratiertes Level; S008 markiert KI-Quest-Level als State KI-Level-Lädt; Nutzer wird nicht geblockt; Fehler wird im Backend geloggt |
| **Kauf fehlgeschlagen (IAP-Fehler)** | S011, S012, S016 | S011 wechselt zu State IAP-Fehler; Fehlermeldung mit verständlichem Text (kein Tech-Jargon) + Retry-Button erscheint; kein Reward wird gutgeschrieben; Kauf-State wird nicht lokal als abgeschlossen markiert; bei erneutem Fehler: Support-Link sichtbar; S016 Ad-Fehler-Fallback läuft parallel wenn Ad-Reward betroffen |
| **Server-Totalausfall** | S001, S005, S006, S008, S021 | S001 erkennt Offline-State → State Offline-Error erscheint mit Retry-CTA; bei partiellem Ausfall: S022 fällt auf Fallback-Control-Group zurück (kein A/B-Test-Assignment); S005 lädt im Offline-State mit gecachtem Content; S006 nutzt Offline-Fallback-Cached-Level; S011 zeigt State Offline-Gesperrt (keine IAP-Transaktionen ohne Serverbestätigung möglich); S021 als globaler Handler aktiv |
| **COPPA-Trigger (Nutzer unter 13 erkannt)** | S002 | **VERBINDLICH:** Hard-Block in S002, State Minderjähriger-Blocked; kein Weiterleiten in die App; kein Tracking, kein Analytics-Event-Dispatch |

### Phase-B Screens (4 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| **S023** | Live-Ops Event Hub | Saisonale zeitlich limitierte Events, Kooperative Team-Events, Event-Leaderboards | Coming-Soon-Badge auf Social-Hub-Tab mit Teaser-Illustration |
| **S024** | Gilden / Team-Management | Vollständiger kooperativer Social-Layer, Gilden-Erstellen, Beitreten, Guild-Events | Team-Event-Teaser-Card im Social-Hub mit Coming-Soon-Label |
| **S025** | Adaptive Monetarisierungs-Offer Engine | KI-gesteuerte personalisierte IAP-Angebote basierend auf Ausgabeverhalten und Spielstil-Profil | Kein Platzhalter sichtbar, regulärer Shop aktiv |
| **S026** | Vollständiger Leaderboard Screen | Globale und Freundes-Leaderboards, wöchentliche Ranglisten, saisonale Highscores | Freundes-Leaderboard-Preview mit Top-3 im Social-Hub, voller Screen Phase B |

---

## 7. Asset-Liste (VERBINDLICH)

### Vollständige Asset-Tabelle (Auszug, vollständige Liste in Asset Discovery Report)

| ID | Asset | Beschreibung | Screen(s) | Stat/Dyn | Quelle | Format | Priorität |
|---|---|---|---|---|---|---|---|
| **A001** | App-Icon | Haupt-App-Icon fuer App Store und Google Play sowie Home-Screen. Zeigt das EchoMatch-Logo. | S001, Alle | statisch | Custom Design | PNG 1024×1024 | 🔴 Launch-kritisch |
| **A002** | Splash-Screen-Logo | EchoMatch-Volllogo mit Wortmarke und Icon fuer den Splash-Screen S001. Zentriert. | S001 | statisch | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| **A009** | Match-3-Spielstein-Sprite-Set | Vollstaendiges Sprite-Set aller Match-3-Spielsteine fuer S003 und S006. Mindestens 6 Steintypen. | S003, S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 Launch-kritisch |
| **A010** | Match-3-Spielfeld-Hintergrund | Vollbild-Hintergrund fuer das Spielfeld in S003 und S006. Thematisch zur Spielwelt. | S003, S006 | statisch | AI-generiert | PNG 1920×1080 | 🔴 Launch-kritisch |
| **A012** | Match-Animation-Effekte | Partikel- und Burst-Animationen fuer erfolgreiche Match-3-Kombinationen in S003 und S006. | S003, S006 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| **A017** | Level-Gewonnen-Animation | Vollbild-Gewinn-Animation fuer S007 Gewonnen-State. Konfetti, Sterne, Charakter-Jubel. | S007 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| **A024** | Narrative-Hook-Sequenz-Artwork | Vollbild-Story-Artwork fuer S004 Narrative Hook. 3-5 Panels oder ein kontinuierliches Bild. | S004 | animiert | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| **A025** | Story-Charakter-Portraits | Portrait-Illustrationen aller Haupt-Story-Charaktere fuer S004, S009 und Narrative-Events. | S004, S009 | statisch | Custom Design | PNG 2×/3× | 🔴 Launch-kritisch |
| **A028** | Home Hub Hero-Banner | Dynamisches Hero-Banner-Artwork fuer S005 Home Hub. Wechselt je nach Tageszeit, Event oder Saison. | S005 | statisch | AI-generiert + Custom | PNG 2×/3× | 🔴 Launch-kritisch |
| **A034** | Shop-Angebots-Karten | Visuell gestaltete Angebotskarten fuer S011. Jeder IAP hat eigene Card mit Produktbild, Preis, CTA. | S011 | statisch | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| **A046** | Tab-Bar-Icons | Icon-Set fuer alle 5 Tab-Bar-Eintraege (Home, Puzzle, Story, Social, Shop). Jede mit Aktiv/Inaktiv-State. | S005, S008, S009, S010, S011 | statisch | Free/Open-Source | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| **A048** | Kaltstart-Personalisierungs-Auswahlkarten | Visuell gestaltete Auswahlkarten fuer S020 Spielstil-Praeferenz-Auswahl. Jede Karte mit Illustration. | S020 | animiert | Custom Design | SVG + PNG 2×/3× | 🔴 Launch-kritisch |
| **A049** | Onboarding-Hint-Pfeile und Tutorial-Overlays | Animierte Pfeile, Finger-Tap-Animationen und Highlight-Overlays fuer S003 Tutorial. | S003 | animiert | Lottie + Custom | Lottie JSON + SVG | 🔴 Launch-kritisch |
| **A050** | KI-Level-Lade-Platzhalter-Animation | Thematische Animations-Szene fuer S006 KI-Level-Latenz-Warten-State. Zeigt Spielwelt-Elemente. | S006, S008 | animiert | Custom Design | Lottie JSON | 🔴 Launch-kritisch |
| **A062** | Store-Feature-Grafik (App Store Listing) | Feature-Grafik fuer Google Play Store (1024x500px) und Screenshots-Set fuer App Store. | Alle | statisch | Custom Design | PNG 1024×500 | 🔴 Launch-kritisch |
| **A063** | Notification-Icon (klein, monochrom) | Kleines monochromes Icon fuer Android-Push-Notifications und iOS-Notification-Badges. | S014 | statisch | Custom Design | PNG 96×96 | 🔴 Launch-kritisch |
| **A066** | Hindernisse und Spezialzellen-Sprites | Sprite-Set fuer Level-Hindernisse (Eis, Stein, Kette, Nebel) in S006. Jedes Hindernis mit Abbau-States. | S006 | animiert | AI-generiert + Custom | PNG Sprite-Sheet | 🔴 Launch-kritisch |

### Beschaffungswege pro Asset (Auszug, vollständige Liste in Asset Strategy Report)

| ID | Asset | Quelle | Tool | Kosten EUR | Priorität |
|---|---|---|---|---|---|
| **A001** | App-Icon | Custom Design | Figma + Illustrator | 350 | 🔴 Launch-kritisch |
| **A009** | Match-3-Spielstein-Sprite-Set | AI-generiert + Custom | Midjourney + Figma | 420 | 🔴 Launch-kritisch |
| **A012** | Match-Animation-Effekte | Custom Design | After Effects + Lottie | 380 | 🔴 Launch-kritisch |
| **A024** | Narrative-Hook-Sequenz-Artwork | AI-generiert + Custom | Midjourney + Photoshop | 320 | 🔴 Launch-kritisch |
| **A046** | Tab-Bar-Icons | Free/Open-Source | Phosphor Icons + Figma | 0 | 🔴 Launch-kritisch |
| **A049** | Onboarding-Hint-Pfeile + Tutorial-Overlays | Lottie + Custom | LottieFiles Free + Figma | 20 | 🔴 Launch-kritisch |

### Format-Anforderungen pro Plattform

| Asset-Typ | Format | Aufloesung/Groesse | Tool | Hinweise |
|---|---|---|---|---|
| **unity_sprites** | PNG / Sprite Sheet | @2x (3840x2160 Master) / @3x (5760x3240 Master) | TexturePacker 7.x → Unity Importer | Keine POT-Pflicht ab Unity 2022+, aber 2er-Potenzen empfohlen für Kompression |
| **game_piece_sprites** | PNG Sprite Sheet via TexturePacker | 256x256px @2x (512x512px Master) | Figma + TexturePacker | Jedes Sprite mit 4 States (normal, hover, matched, special) |
| **backgrounds** | PNG | 1920x1080px @2x (3840x2160 Master) | Photoshop | Hintergrund-Layer separat exportieren (BG-Layer, Mid-Layer, FX-Layer) für Parallax |
| **icons** | SVG für UI-Icons, PNG @2x/@3x für In-Game | 24x24dp, 48x48dp, 96x96dp | Figma | SVG für Skalierbarkeit, PNG für Performance in Unity |
| **animations** | Lottie JSON (UI-Animationen, Loading, Feedback) | Max 500KB pro JSON | After Effects 2025 + Bodymovin 5.x Plugin | **VERBINDLICH:** Statisches PNG @2x als Fallback wenn Lottie >500KB oder Runtime-Performance-Problem |
| **app_icon_ios** | PNG | 1024x1024px (Store), alle Größen für Asset Catalog | Figma Export + Asset Catalog Xcode | **VERBINDLICH:** Kein Alpha-Kanal, kein Gradient über gesamte Fläche (Apple Review Richtlinie) |
| **app_icon_android** | PNG Adaptive Icon | Foreground + Background als separate Layer im XML | Android Studio Asset Studio + Figma Export | Adaptive Icon: Foreground + Background als separate Layer im XML definiert |
| **screenshots_store** | PNG (kein JPEG, keine Kompressionsartefakte) | 1290x2796 (iOS), 1080x1920 (Android) | Figma Store-Screenshot-Template + Photoshop Finalisierung | **VERBINDLICH:** 6-8 Screenshots pro Plattform, Fokus auf USP und Wow-Momente |
| **audio** | WAV (Master) + OGG/AAC (komprimiert) | 44.1 kHz, 16-bit Stereo | Audacity / Adobe Audition | **VERBINDLICH:** Loop-Points in BGM-Tracks getestet (kein Click am Loop-Punkt) |
| **fonts** | TTF / OTF Master → Unity Font Asset (TMP) | Variable | TextMesh Pro Font Asset Creator | **VERBINDLICH:** Lizenz-Prüfung für Mobile-Embedding vor Integration (SIL OFL oder Commercial-Lizenz) |

### Plattform-Varianten Anzahl
*   **Gesamtanzahl Assets:** 107
*   **Plattform-Varianten gesamt:** 164 (durch @2x/@3x, iOS/Android-Spezifika)

### Dark-Mode-Varianten
*   **Dark-Mode-Varianten noetig:** 65 Assets (explizit in Asset Discovery Report markiert)

---

## 8. KI-Produktions-Warnungen (VERBINDLICH — KRITISCH)

### Warnungen aus dem Visual Audit (Copy-Paste-Ready Prompt-Anweisungen)

| # | Screen | Stelle | Was KI falsch macht | Was stattdessen | Prompt-Anweisung fuer Produktionslinie |
|---|---|---|---|---|---|
| **W01** | S001 Splash | Vollbild-Atmosphären-Artwork hinter dem Logo | Farbverlauf in Brand-Primärfarbe oder `#1A1A2E` Vollton | A003 Splash-Screen-Hintergrund | **VERBINDLICH:** `Image(asset: "A003_splash_bg")` als Fullscreen-Layer unter Logo platzieren. KEIN `Color.fill()` oder Gradient-Code als Ersatz akzeptieren. |
| **W02** | S002 ATT Consent | Erklärendes Bild BEVOR der iOS-System-ATT-Dialog erscheint | Text-only Pre-Permission-Screen mit App-Beschreibung oder gar keinen Pre-Screen | A007 ATT-Prompt-Visual | **VERBINDLICH:** Pre-Permission-Screen als eigene View implementieren mit `Image(asset: "A007_att_prompt_visual")` als zentralem Element. Der System-Dialog wird erst nach Tap auf Erklärungsscreen getriggert. KEIN direktes `requestTrackingAuthorization()` ohne vorherigen Visual-Screen. |
| **W03** | S002 DSGVO | Visuelle Auflockerung neben Rechtstext | Reinen UITextView/ScrollView mit Rechtstext, kein visuelles Element | A006 DSGVO-Consent-Illustration | **VERBINDLICH:** Illustration als festes Layout-Element in der oberen Hälfte des Consent-Modals platzieren (`Image(asset: "A006_dsgvo_consent_illustration")`). ScrollView mit Rechtstext NUR im unteren Bereich. Illustration darf NICHT weggelassen werden wenn Rechtstext lang ist. |
| **W04** | S003 Spielsteine | Thematisch gestaltete Spielstein-Sprites mit Spielwelt-Ästhetik | Farbige `RoundedRectangle`-Views oder `Circle`-Shapes mit Hex-Farben als Spielstein-Ersatz | A009 Match-3-Spielstein-Sprite-Set | **VERBINDLICH:** Sprite Sheet laden und Einzelframes per Tile-Index rendern. Jeder Spielstein-Typ bekommt eigenen Sprite-Frame aus `A009_gem_sprites.atlas`. KEIN Shape-Rendering als Spielstein. |
| **W05** | S003 Tutorial-Hint | Animierter Finger-Tap-Pfeil der ersten Spielzug zeigt | Statischen Text-Overlay wie „Tippe hier um zu beginnen" oder `Label`-Tooltip | A049 Onboarding-Hint-Pfeile und Tutorial-Overlays | **VERBINDLICH:** Lottie-Animation oder Frame-Animiertes Asset verwenden (`A049_hint_arrow_tap.json`). KEIN `UILabel` oder `Text()`-Overlay als Tutorial-Hinweis im Spielfeld. Animation muss auf den ersten tappbaren Stein zeigen, nicht auf generische Screen-Position. |
| **W06** | S004 Narrative Hook | Vollbild-Story-Artwork oder animierte Sequenz als emotionaler erster Eindruck der Spielwelt | Text-Dialog-Box auf schwarzem oder einfarbigem Hintergrund, eventuell mit generischem Hintergrundbild | A024 Narrative-Hook-Sequenz-Artwork | **VERBINDLICH:** Implementierung als `Image(asset: "A024_narrative_hook_bg")` Fullscreen mit Text-Overlay. KEIN schwarzer Hintergrund mit zentriertem Text als Narrative-Hook. |
| **W07** | S005 Hero-Banner | Tageszeit-abhängig oder Event-abhängig wechselndes Artwork das täglichen Re-Entry-Anreiz visualisiert | Statische Farb-Card oder Text-Banner mit „Willkommen zurück, [Name]" | A028 Home Hub Hero-Banner | **VERBINDLICH:** 3 Banner-Varianten in Asset-Bundle liefern (`A028_hero_morning.png`, `A028_hero_evening.png`, `A028_hero_event.png`). Tageszeit-Logik wählt Asset per lokaler Uhr. KEIN programmatisch generiertes Text-Banner als Hero-Element akzeptieren. |
| **W08** | S006 Spezialsteine | Visuell sofort erkennbare Spezialsteine die sich klar von normalen Steinen unterscheiden (Bombe sieht aus wie Bombe) | Gleiche `RoundedRectangle`-Shapes wie normale Steine, nur mit anderer Farbe oder Outline | A011 Match-3-Spezialstein-Sprites | **VERBINDLICH:** Separate Sprite-Frames für jeden Spezialstein-Typ aus `A011_special_gems.atlas` rendern. Bombe = Bomben-Sprite, Blitz = Blitz-Sprite. KEIN Reuse des normalen Stein-Sprites mit veränderter `tintColor` oder Border. |
| **W09** | S006 Hindernisse | Hinderniszellen die durch ihr Aussehen ihren Typ und Abbau-Zustand kommunizieren (Eis-Crack-States) | Farbige Zellen-Backgrounds (`blue` = Eis, `gray` = Stein) ohne Multi-State-Design | A066 Hindernisse und Spezialzellen-Sprites | **VERBINDLICH:** Sprite-Set mit je 3 Abbau-States pro Hindernis-Typ implementieren (`A066_ice_state_1.png`, `A066_stone_state_1.png`). State-Wechsel über Sprite-Frame-Swap, NICHT über `opacity`-Änderung oder Farb-Overlay. |
| **W10** | S007 Verloren-State | Empathische Charakter-Illustration die Niederlage emotional abfedert und Retry-Motivation aufbaut | Roter Text „Level verloren" oder System-Alert-Style-Dialog, evtl. mit rotem X-Icon | A018 Level-Verloren-Illustration | **VERBINDLICH:** Illustration als Fullscreen-Hintergrund oder zentrales Element des Verloren-Screens (`A018_level_lost_illustration.png`). Retry-Button wird ÜBER die Illustration gelegt. KEIN Alert-Dialog oder System-Modal als Verloren-Screen. |
| **W11** | S011 Foot-in-Door-Angebot | Visuell hervorgehobene Angebots-Card die sich durch Größe, Glanz-Effekt oder animierten Rahmen von anderen Angeboten abhebt | Gleiche Card wie alle anderen Angebote, nur mit anderem Preis oder Text „Bestes Angebot" Label | A035 Foot-in-Door-Angebot-Highlight | **VERBINDLICH:** Dediziertes Highlight-Asset mit animiertem Rahmen/Glow verwenden (`A035_offer_highlight_frame.json` als Lottie). KEIN reines Text-Badge wie „BEST VALUE" ohne visuelles Highlight-Design. Die Card selbst muss größer oder visuell prominenter sein als Standard-Cards. |
| **W12** | S020 Auswahlkarten | Bildbasierte Auswahlkarten die Spielstil durch Illustration zeigen (entspannter Spieler vs. kompetitiver Spieler) | Radio-Button-Liste oder Segmented-Control mit Text-Labels für Spielstil-Optionen | A048 Kaltstart-Personalisierungs-Auswahlkarten | **VERBINDLICH:** Card-basiertes Selection-UI mit Illustration pro Option implementieren. Jede Auswahlkarte enthält `Image(asset: "A048_playstyle_\(type).png")` + Label. KEIN `Picker`, `SegmentedControl` oder `RadioButton`-Pattern ohne visuelles Karten-Design. |
| **W13** | S010 Challenge-Card | Animierte Card mit Gegner-Avatar, Score-Vergleich und Accept/Decline-CTAs | Einfacher `ListCell` mit Spielername und zwei Text-Buttons | A038 Challenge-Card-Design | **VERBINDLICH:** Challenge-Card als dediziertes Custom-View implementieren mit `Image(asset: "A038_challenge_card_bg")` als Hintergrund, Avatar-Image-View für Gegner-Profil. KEIN `UITableViewCell`/`List`-Row als Challenge-Darstellung akzeptieren. |
| **W14** | S015 Share-Bild | Dynamisch generiertes Share-Bild mit App-Branding, Score und Level-Nummer als attraktive visuelle Card | Reinen Text-String teilen: „Ich habe Level 12 mit 4500 Punkten abgeschlossen! #EchoMatch" | A040 Share-Result-bild-Template | **VERBINDLICH:** Share-Bild programmatisch aus Template rendern: `UIGraphicsImageRenderer` oder Canvas-API nutzt `A040_share_template.png` als Hintergrund und rendert Score/Level-Werte als Text-Overlay. `UIActivityViewController` bekommt das **gerenderte UIImage**, NICHT einen Text-String als primären Share-Content. |
| **W15** | S005 | Battle-Pass-Teaser-Banner | Hochwertiges Saison-Artwork mit Teaser-Energie | Generische Text-Card mit Farbfläche | **VERBINDLICH:** Dediziertes `A_BPHomeTeaser`-Asset mit Saison-Artwork erstellen, Variante pro Saison. KEIN programmatisch generiertes Text-Banner. |
| **W16** | S012 | Saison-Abgelaufen-State | Illustration die zeigt „nächste Saison kommt" — motivierend | Leerer Screen oder roter Fehler-Text | **VERBINDLICH:** `A_SeasonEndIllustration` als eigenes Asset definieren. KEIN leerer Screen oder Fehlertext. |
| **W17** | S012 | Free vs. Premium Tier-Leiste | Klarer visueller Unterschied Premium = Gold/Glanz, Free = grau | Eine Tier-Leiste, Premium einfach farblich anders | A031 (1 Variante) | **VERBINDLICH:** A031 auf 2 explizite Varianten erweitern: `A031_free` + `A031_premium` mit eigenem Art-Spec. |
| **W18** | S016 | Ad-Fehler-Fallback | Freundliche Illustration „Leider kein Video verfügbar, versuch es später" | Blanker Screen oder nativer OS-Alert | **VERBINDLICH:** `A_AdErrorIllustration` erstellen, Ton: humorvoll, nicht schuldzuweisend. KEIN blanker Screen oder System-Alert. |
| **W19** | S016 | Reward-Celebration nach Ad | Particle-Explosion oder Screen-Flash wenn Reward erhalten | Statisches Icon kurz angezeigt | A020 statisch | **VERBINDLICH:** Separate `A_RewardCelebrationAnimation` (Lottie) definieren, 1–1,5s. KEIN statisches Icon. |
| **W20** | S016 | Overlay-Container | Semitransparenter gestalteter Rahmen um Ad-Content | Rohes Ad-Fullscreen ohne App-Branding-Rahmen | **VERBINDLICH:** `A_AdOverlayFrame` als schlanker Branding-Rahmen mit Close-Button-Area definieren. KEIN rohes Ad-Layer. |
| **W21** | S007 | Rewarded-Ad-Angebots-CTA | Prominent gestalteter Button „Video schauen → Extra-Leben" | Standard-System-Button ohne emotionale Ladung | **VERBINDLICH:** `A_RewardedAdCTA`-Button-Design als eigenes Asset mit Reward-Icon und Puls-Animation. KEIN System-Button. |
| **W22** | S002 | DSGVO-Consent-Toggles | Gebrandete Toggle-Switches in App-Farbwelt, granular per Kategorie | iOS/Android System-Standard-Toggles in Systemfarbe | **VERBINDLICH:** `A_ConsentToggleSet` definieren mit An/Aus-States in Brand-Farben. KEINE System-Toggles. |
| **W23** | S002 | Opt-In/Opt-Out-Buttons | Visuell gleichwertig — kein Dark Pattern (DSGVO-Pflicht) | Zustimmen-Button groß + primär, Ablehnen klein + grau | **VERBINDLICH:** `A_ConsentButtonPair` mit expliziter Gleichgewichts-Spezifikation, beide gleiche Größe und Sichtbarkeit. KEINE visuelle Hierarchie. |
| **W24** | S002 | Trust-Badge / Privacy-Signal | Kleines „DSGVO-konform"-Badge oder Datenschutz-Siegel unten | Kein Badge — reiner Textblock | **VERBINDLICH:** `A_PrivacyTrustBadge` erstellen, Größe klein, Platzierung Footer des Consent-Modals. KEIN reiner Textblock. |
| **W25** | S020 | Ausgewählt-State Auswahlkarten | Ausgewählte Karte visuell klar hervorgehoben (Rahmen, Checkmark) | Karte wird vielleicht einfach einfärbt, kein klares Feedback | A048 (1 Variante) | **VERBINDLICH:** A048 auf 2 Varianten erweitern: `A048_default` + `A048_selected` mit explizitem Checkmark + Rahmen. |
| **W26** | S020 | Datenschutz-Hinweis-Banner | Sichtbarer Hinweis „Diese Auswahl optimiert dein Spielerlebnis — kein Tracking" | Kein Hinweis — Nutzer könnte S020 als Tracking missverstehen | **VERBINDLICH:** `A_PersonalizationDisclaimer`-Banner definieren, Text + visuelles Datenschutz-Icon. KEIN fehlender Hinweis. |
| **W27** | S018 | Consent-Aktualisiert-Feedback | Kurze Bestätigung „Datenschutzeinstellungen gespeichert" mit Animation | Toast-Notification ohne Branding oder gar kein Feedback | **VERBINDLICH:** `A_ConsentConfirmationToast` definieren, 2s einblenden, nicht-blockierend. KEINE generische Toast-Notification. |

### Warnungen aus der Design-Vision (Copy-Paste-Ready Prompt-Anweisungen)

| # | Screen | Standard den KI waehlt | Was Design-Vision verlangt | Prompt-Anweisung |
|---|---|---|---|---|
| **DV01** | S006, S001, S004, alle Spielfeld-Screens | Weißer oder hellgrauer Hintergrund als Basis-Canvas für alle Screens | **VERBINDLICH:** Dunkler Basis-Canvas (**#0D0F1A bis #1A1D2E**) als primäre Designsprache — kein Screen darf einen hellen Hintergrund als Default haben. Ausnahme nur für DSGVO/ATT-Modal (System-Pflicht). | **VERBINDLICH:** Setze den Hintergrund aller Spielfeld- und Hub-Screens auf die Farbpalette `color-background-deep` (#0D0F1A) oder `color-background-mid` (#1A1D2E). VERMEIDE `#FFFFFF` oder helle Grautöne als Standard-Hintergrund. |
| **DV02** | S005, S007, alle Hub-Screens | Fünf-Icon Bottom-Tab-Bar persistent auf allen Screens | **VERBINDLICH:** Kein persistentes Bottom-Tab-Element. Navigation über kontextuelles Radial-Menü (Swipe-Up) und situative Action-Surfaces die je nach Screen-State eingebettet sind. | **VERBINDLICH:** Implementiere KEINE feste 5-Icon-Bottom-Navigation-Bar. Nutze stattdessen ein kontextuelles Radial-Menü (Swipe-Up) und dynamische Action-Surfaces. Für iOS HIG: eine minimale 3-Icon-Bar (Home, Puzzle, Profil) ist erlaubt, aber nicht dominant. |
| **DV03** | S008, S009 | Konfetti-Regen, drei goldene Sterne und "AMAZING!"-Text auf dem Gewinn-Screen | **VERBINDLICH:** Vollbild-Poster-Karte mit expressiver Typografie (konkrete Session-Aussage wie "47 Züge. Kein Fehler."), Kapitel-Farbwelt als Hintergrund, ein einziger "Teilen"-Button. Kein Konfetti. Keine generischen Lobtext-Banner. | **VERBINDLICH:** Gestalte den Reward-Screen (S008/S009) als Vollbild-Poster-Karte. Verwende expressive Typografie für die Spielhistorie. KEINE Konfetti-Animationen, KEINE 1-3 Sterne, KEINE "AMAZING!"-Texte. Füge einen prominenten "Teilen"-Button hinzu. |
| **DV04** | S010, alle Shop-Screens | Rote "BEST VALUE!"-Schräg-Banner und Puls-Countdown-Timer im Shop | **VERBINDLICH:** Maximale drei Angebote gleichzeitig, kein Schräg-Banner, kein Puls-Effekt beim Timer, Preise in klarer lesbarer Type ohne Gold-Rendering, Countdown als dezenter Text ("noch 23 Tage") nicht als animierter Balken. | **VERBINDLICH:** Implementiere den Shop (S010) mit maximal drei sichtbaren Angeboten. VERMEIDE rote "BEST VALUE!"-Banner und pulsierende Countdown-Timer. Zeige Preise in klarer Typografie. Countdown-Timer als dezenter Text. |
| **DV05** | S006 | Partikel-Burst-Explosion bei jedem Match (200ms-Pop-Effekt) | **VERBINDLICH:** Match-Feedback über Licht-Emission: Steine lösen sich mit einem Glow-Pulse auf (400–600ms Ease-Out), Licht breitet sich kurz auf Nachbar-Felder aus und verblasst. Cascade-Animationen folgen einer organischen Physik-Kurve, nicht linearem Fall. | **VERBINDLICH:** Ersetze Partikel-Burst-Explosionen bei Matches durch Licht-Emissions-Effekte (Glow-Pulse, 400-600ms Ease-Out). Implementiere organische Physik-Kurven für Stein-Fall-Animationen. |
| **DV06** | S004, S007, S009, S011 | Abgerundete fette Display-Schrift für alle Headlines (eine Schriftfamilie, immer gleiche Anmutung) | **VERBINDLICH:** Typografischer Kontrast: Schmale, expressive Schrift (z.B. Kategorie: Condensed Display, hohe x-Höhe) für Story-/Narrative-Momente vs. klare technische Sans-Serif für UI-Elemente (Score, Züge, Preise). Schriftcharakter wechselt mit Kontext. | **VERBINDLICH:** Nutze `Nunito` für Headlines und `Inter` für Body-Text. Für numerische Daten `JetBrains Mono`. Implementiere typografischen Kontrast, indem du `Nunito` für narrative Elemente und `Inter` für UI-Elemente verwendest. |
| **DV07** | S008, S010 | Sozialer Layer hinter einem separaten "Social"-Tab versteckt | **VERBINDLICH:** Freunde-Avatare als Pins direkt auf der Level-Map sichtbar. Kein Tab-Click nötig für soziale Grundinformation. Social-Hub (S010) bleibt für tiefere Interaktion, wird aber nicht als primärer Einstiegspunkt für soziale Präsenz genutzt. | **VERBINDLICH:** Zeige Freunde-Avatare als leuchtende Pins direkt auf der Level-Map (S008). Implementiere KEINEN separaten "Social"-Tab als primären Zugang zur sozialen Präsenz. |
| **DV08** | S003 | Tutorial-Hand-Cursor zeigt ersten Zug, statisches Overlay mit Charakter-Bubble | **VERBINDLICH:** Onboarding ist das erste echte Match — kein Tutorial-Overlay, kein abgedunkelter Hintergrund, kein Hand-Cursor. Spielstil-Tracking beginnt still beim ersten Zug. Einzige Hilfe: dezente Glow-Markierung der validen Züge für die ersten 5 Sekunden, dann verschwindend. | **VERBINDLICH:** Implementiere das Onboarding (S003) als direktes Match ohne Tutorial-Overlay oder Hand-Cursor. Nutze eine dezente Glow-Markierung für gültige Züge für die ersten 5 Sekunden. |

---

## 9. Legal-Anforderungen fuer Produktion

### Consent-Screens (DSGVO, ATT)
*   **VERBINDLICH:** **S002** muss als **Rising Card Modal** von unten erscheinen, mit dem Spielfeld (S003) unscharf im Hintergrund.
*   **VERBINDLICH:** Text auf S002 muss in **zweiter Person, kurz und direkt** formuliert sein ("Wir lernen wie du spielst — dafür brauchen wir kurz dein OK.").
*   **VERBINDLICH:** **Toggle-Switches** statt Checkboxen für granulare Consent-Optionen (DSGVO Art. 7). Jeder Toggle muss beim Aktivieren einen **weichen Haptik-Puls** auslösen.
*   **VERBINDLICH:** Der **iOS ATT-Prompt** (F028) erscheint erst **nachdem** der eigene Consent-Screen (S002) vollständig erklärt hat, was ATT bedeutet (Pre-Permission-Screen mit A007).
*   **VERBINDLICH:** Opt-In und Opt-Out Buttons auf S002 müssen **visuell gleichwertig** gestaltet sein (keine Dark Patterns durch Größe oder Farbe).
*   **VERBINDLICH:** **A_ConsentToggleSet** und **A_ConsentButtonPair** müssen als gebrandete Assets implementiert werden.
*   **VERBINDLICH:** Ein **A_PrivacyTrustBadge** muss im Footer des Consent-Modals platziert werden.

### Age-Gate / COPPA
*   **VERBINDLICH:** **S002** muss eine **Altersabfrage** enthalten, um Nutzer unter 13 (COPPA) bzw. unter 16 (DSGVO) zu identifizieren (F043).
*   **VERBINDLICH:** Bei Erkennung eines Minderjährigen muss ein **Hard-Block** erfolgen (State `Minderjähriger-Blocked` in S002) mit der Illustration **A008**. Die App darf nicht nutzbar sein, kein Tracking, keine Ads.
*   **VERBINDLICH:** Der Block-Screen muss **freundlich, aber klar** kommunizieren, warum der Zugang verwehrt wird.

### Datenschutz
*   **VERBINDLICH:** **Implizites Spielstil-Tracking (F002)** in S003 erfolgt **ausschließlich on-device** und wird im Consent-Screen (S002) klar erklärt. Es handelt sich um First-Party-Gameplay-Daten, nicht Third-Party-Tracking.
*   **VERBINDLICH:** **DSGVO-konforme Consent-Architektur (F042)** mit nachweisbaren Consent-Logs und jederzeitiger Widerrufsmöglichkeit muss implementiert werden.
*   **VERBINDLICH:** **Apple Privacy Nutrition Labels (F045)** und **Google Play Data Safety Section (F046)** müssen **vollständig und akkurat** alle erhobenen Datenkategorien (KI-Personalisierungsdaten, Analytics-Events, Werbedaten) deklarieren.
*   **VERBINDLICH:** Für Nutzer, die ATT verweigern oder DSGVO-Tracking ablehnen, muss die **Kaltstart-Personalisierung (F029)** greifen, die auf regelbasierten oder populären Levels basiert, ohne IDFA-basiertes Tracking.
*   **VERBINDLICH:** **AVV-Verträge** mit allen Drittanbietern (Analytics, Ads, Cloud-Backend) müssen vor Launch abgeschlossen sein.

### Pflicht-UI
*   **VERBINDLICH:** **Datenschutzerklärung und Impressum** müssen über S018 (Einstellungen) und S002 (Consent) jederzeit erreichbar sein.
*   **VERBINDLICH:** **KI-Kennzeichnung:** Im Store-Listing und in den Einstellungen (S018) muss transparent kommuniziert werden, dass Levels und Quests KI-generiert sind.
*   **VERBINDLICH:** **Battle-Pass Content Visibility System (F039):** Alle Battle-Pass-Inhalte müssen vor dem Kauf vollständig und transparent sichtbar sein (S012). Keine zufälligen oder versteckten Belohnungen.
*   **VERBINDLICH:** **Deterministisches Belohnungsdesign (F040):** Daily-Quest-Belohnungen müssen vollständig deterministisch sein (S013). Keine variablen oder zufallsbasierten Reward-Pools.
*   **VERBINDLICH:** **FOMO-Mechanik Compliance Filter (F041):** Push-Notifications und Daily-FOMO-Content müssen auf manipulative Dark Patterns geprüft und entschärft werden. Frequenz, Tonalität und Triggerlogik müssen DSA-konform sein.

### App Store Compliance
*   **VERBINDLICH:** Alle **IAP-Produkte (F012, F015, F016)** und **Battle-Pass-Tiers (F012)** müssen in App Store Connect und Google Play Console korrekt angelegt und mit Preisen in allen Zielwährungen konfiguriert sein.
*   **VERBINDLICH:** **Sign-in with Apple** ist Pflicht, wenn andere Social-Login-Optionen angeboten werden (F036).
*   **VERBINDLICH:** **Rewarded Ads (F011)** müssen den Richtlinien beider Stores entsprechen (freiwilliges Opt-in, keine Interrupt-Ads).
*   **VERBINDLICH:** **Jugendschutz-Rating (F049)** über IARC-System muss vor Submission erfolgen. Altersfreigabe muss mit dem Feature-Set (Social Features) konsistent sein.

---

## 10. Tech-Stack Detail

**Engine + Version:**
*   **VERBINDLICH:** Unity 2022.3 LTS (Long Term Support) oder neuer.
*   **VERBINDLICH:** Universal Render Pipeline (URP) für Bloom-Post-Processing und Emission-Maps.

**Backend-Dienste:**
*   **VERBINDLICH:** Google Cloud Platform (GCP) als primäres Cloud-Backend.
*   **VERBINDLICH:** **Cloud Run:** Für die KI-Level-Generierung (F003, F019), KI-Personalisierungs-Engine (F018), Daily-Quest-Generierung (F004), IAP-Missbrauchsschutz (F038), Moderations-Queue (F050), Audit-Logs (F063).
*   **VERBINDLICH:** **Firebase Firestore:** Für persistente Spielerprofile (F036), Story-Zustände (F005), Quest-Status (F004), Battle-Pass-Status (F012), Social-Challenge-State (F007), Event-Progress (F008), KI-Profil-Daten (F018), vorgenerierte Level-Caches (F067).
*   **VERBINDLICH:** **Firebase Realtime Database:** Optional für hochfrequente, kleine Daten-Updates in Social Features (z.B. Team-Event-Progress-Aggregation F008), falls Firestore Latenzprobleme zeigt.
*   **VERBINDLICH:** **Firebase Cloud Messaging (FCM):** Für Push-Notifications (F020).
*   **VERBINDLICH:** **Firebase Remote Config:** Für A/B-Testing (F024), Feature-Toggling (F065), dynamische UI-Anpassungen (F005, F011), Saison-Timer (F013), Ad-Placement-Optimierung (F017).
*   **VERBINDLICH:** **Firebase Authentication:** Für Nutzer-Authentifizierung (F036) mit anonymer Auth als Einstieg, optional Google Sign-In und Sign-in with Apple.

**SDKs (Ads, Analytics, Auth, Payment):**
*   **VERBINDLICH:** **Unity IAP:** Für In-App-Käufe (F012, F014, F015, F016).
*   **VERBINDLICH:** **Ad Mediation Layer:** IronSource LevelPlay oder AppLovin MAX SDK für Rewarded Ads (F011, F017).
*   **VERBINDLICH:** **Firebase Analytics:** Für Retention-Analytics (F025), Spielstil-Profiling (F018), IAP-Conversion-Tracking (F061), CPI-Monitoring (F059).
*   **VERBINDLICH:** **Firebase Crashlytics:** Für Crash-Reporting (F031).
*   **VERBINDLICH:** **Unity NativeShare Plugin:** Für Social-Sharing (F010).
*   **VERBINDLICH:** **Consent Management Platform (CMP) SDK:** Usercentrics oder OneTrust SDK für DSGVO-Consent-Management (F042).
*   **VERBINDLICH:** **Unity iOS ATT Plugin:** Für App Tracking Transparency (F028, F044).

**CI/CD Pipeline:**
*   **VERBINDLICH:** Automatisierte Build-Pipeline (z.B. Unity Cloud Build, GitHub Actions) für iOS- und Android-Builds.
*   **VERBINDLICH:** Versionierte Abhängigkeiten und Asset-Bundles zur Vermeidung von Breaking Changes bei Unity-Versionswechseln.
*   **VERBINDLICH:** Automatisierte Tests (Unit, Integration, UI) für Core Loop und KI-Generierung.

**Monitoring + Crash-Reporting:**
*   **VERBINDLICH:** Google Cloud Monitoring für Cloud Run Services und Firebase Performance Monitoring für Client-seitige Performance (F026).
*   **VERBINDLICH:** Firebase Crashlytics für Echtzeit-Crash-Reporting (F031).
*   **VERBINDLICH:** Server-Uptime-Monitoring (z.B. BetterUptime) mit Alerts bei kritischen Ausfällen (Ziel: ≥99,5% Uptime).

---

## 11. Release-Anforderungen

### Phase 0: Closed Beta (Interner Alpha + KI-PoC-Validierung)
*   **Ziel:** Technische Kernstabilität validieren, KI-Level-Generierung als Proof-of-Concept testen, kritisches Risiko 1 (KI-Generierung