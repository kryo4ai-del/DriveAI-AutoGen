# Design-Differenzierungs-Report: echomatch

# Genre-Standard-Analyse: EchoMatch

---

## Was sieht der Nutzer bei ALLEN Wettbewerbern

| Element | Standard-Umsetzung | Genutzt von |
|---|---|---|
| **Layout** | Zentriertes Spielfeld, feste UI-Leiste oben (Züge/Leben/Score), feste Leiste unten (Navigation/Booster) — vollständig symmetrisch, keinerlei dynamische Komposition | Royal Match, Candy Crush, Fishdom, Empires & Puzzles, Block Blast |
| **Farbschema** | Gesättigte Primärfarben auf hellem/weißem Hintergrund: Knallblau, Knallrot, Knallgrün, Knallgelb — hypersaturiert, keine Tonalität, kein visuelles Atmen | Candy Crush (Pastellneon), Royal Match (Blau-Gold-Königreich), Fishdom (Türkis-Orange), alle |
| **Navigation** | Flache Bottom-Navigation-Bar mit 4–5 Icon-Tabs (Home, Map, Shop, Social, Profile) — identisches Mental-Model bei allen Spielen, null Differenzierung | Royal Match, Fishdom, Empires & Puzzles, alle Hybrid-Casuals |
| **Animationen** | Burst-Effekte beim Match (Partikel explodieren), Bounce-Feedback bei Buttons, lineare Progress-Bar-Füllungen, Cascade-Animationen beim Stein-Fall — alle physikalisch vorhersehbar und generisch | Alle Wettbewerber ohne Ausnahme |
| **Typografie** | Abgerundete, fette Display-Schrift für Headlines (oft proprietär, aber immer gleiche Kategorie), Sans-Serif für Body — niemals Kontrast zwischen Schriftcharakteren, niemals expressive Type | Royal Match, Candy Crush, Fishdom — durchgehend |
| **Onboarding** | Hand-Cursor zeigt ersten Zug, Tutorial-Overlay mit abgedunkeltem Hintergrund, statischer Dialog-Bubble mit Charakter — Nutzer wird durch Clicking geführt, kein aktives Entdecken | Alle Wettbewerber identisch |
| **Reward-Screens** | Konfetti-Regen von oben, goldene Sterne (1–3), Coins springen ins UI, übertriebene "GREAT!" / "AMAZING!"-Texte in fetter Type, Sound-Fanfare — emotional infantil, visuell austauschbar | Royal Match, Candy Crush Saga, Candy Crush Soda, Fishdom |
| **Shop/Monetarisierung** | Vollbild-Grid mit Produkt-Kacheln (Icon + Preis + grüner Kaufbutton), rote "BEST VALUE!"-Banner schräg über Kacheln, Countdown-Timer als roter Balken, immer identische Preisarchitektur ($0.99 / $4.99 / $9.99 / $19.99) | Alle ohne Ausnahme — identische Store-Architektur |

---

## Fazit: Der Genre-Standard ist...

Das Match-3-Genre hat sich auf ein visuelles Industriemodell geeinigt, das primär von Candy Crush (2012) abstammt und seitdem cargo-gecultet wird: hypersaturierte Primärfarben auf weißem Grund, symmetrisches Spielfeld-Layout mit fixen UI-Leisten, infantile Reward-Screens mit Konfetti und Sternen, und ein Shop-Design das aussieht als hätte ein A/B-Test von 2015 nie geendet. Die KI — ohne Anweisung — würde exakt diesen Einheitsbrei produzieren, weil er in allen Trainingsdaten dominant ist: bunte Steine auf hellem Grund, abgerundete Buttons, explodierender Score-Counter, Bottom-Nav mit Haus-Icon.

---

## Innovative Referenzen (NICHT aus der eigenen Nische — Genre-übergreifend)

| Referenz-App/Design | Kategorie | Was sie anders macht | Relevanz für EchoMatch | Quelle |
|---|---|---|---|---|
| **Duolingo (2023–2025 Redesign)** | EdTech / Gamification | Charaktere reagieren kontextuell auf Performance — nicht nur auf Sieg/Niederlage, sondern auf *wie* der Nutzer spielt (z. B. schnelle Streak = anderer Charakter-State). Mascot-driven Feedback ersetzt generische Reward-Screens vollständig. Dark-Comedy-Ton bricht Kategorie-Norm. | EchoMatch's KI-Layer könnte ähnlich kontextuell reagieren: nicht nur "Level gewonnen" sondern visuelles Feedback das den *Spielstil* spiegelt — kooperativer Run = wärmere Farbe, schneller Run = kinetischere Animation | Duolingo Design Blog / App Store Observations 2024 |
| **Robinhood (App-Redesign 2022–2024)** | Fintech | Dark-First UI als Standard — nicht als "Dark Mode Option" sondern als primäre Designsprache. Schwarzer Hintergrund, sehr sparsame Farbakzente (nur Grün für Gain, Rot für Loss), viel Whitespace/Blackspace. Typografie ist die eigentliche UI-Sprache. | Direkte Gegenantwort zum grellen Genre-Standard: EchoMatch könnte ein tiefes, dunkles Puzzle-Feld nutzen — Steine leuchten *selbst* als Lichtquelle statt auf hellem Grund. Effekt ist dramatischer, moderner, differentierter. | App Annie Design Reports 2023 / Robinhood Pressematerial |
| **BeReal (2022–2023 Viral-Phase)** | Social Media | Radikaler Anti-Perfection-UI: kein Like-Counter sichtbar, kein Algorithmic Feed, kein Boost-Button. Die Interface-Reduktion ist selbst das Statement — das Weglassen ist das Design. Wurde massenhaft auf TikTok diskutiert *wegen* seiner Nicht-Designiertheit. | EchoMatch Shop: Weniger schreien. Kein "BEST VALUE!"-Banner in Rot. Stattdessen klare Preisarchitektur mit viel Luft — das Vertrauen *ist* das Design. Contra-Signal zum übersättigten Puzzle-Shop. | TikTok Viral Analysis / BeReal App Store History |
| **Calm / Headspace (UI-Philosophie)** | Wellness / Meditation | Organische Gradienten statt flacher Flächen, Typografie als primäres emotionales Medium (große, leise Sätze), Animationen die sich *atmen* statt explodieren — Ease-in-Out über 800ms statt 200ms-Burst. Farbpalette kommt aus der Natur (Sonnenuntergangs-Gradients, Ozean-Blautöne), nicht aus dem Regenbogenspektrum. | Die Narrative Meta-Layer von EchoMatch (Story-Hub, Chapter-Screens) könnte diese visuelle Sprache sprechen: langsame, atmende Übergänge, organische Texturen, Gradient-Hintergründe die die emotionale Storybeat spiegeln — statt Konfetti-Explosion auch nach Story-Moments | Apple Design Awards 2023 (Headspace finalist) / Calm Brand Guidelines |
| **Spotify (Wrapped + Now Playing Redesign)** | Musik / Streaming | Dynamische Farbextraktion aus Content: Der Now-Playing-Screen ändert seine komplette Farbpalette basierend auf dem Album-Artwork — die UI *reagiert* auf Inhalt statt umgekehrt. Wrapped nutzt stark typografisch-getriebene Full-Screen-Moments die geteilt werden *weil* sie wie Poster aussehen, nicht wie UI. | EchoMatch Level-Map: Farbwelt der Map könnte dynamisch auf das aktive Story-Kapitel reagieren — dunkles Kapitel = kühle Töne, Wendepunkt = goldene Akzente. Post-Session-Screen designed als Share-Card (Poster-Ästhetik) statt als Reward-Overlay — viral-tauglich per Design. | Spotify Design / Fast Company Design Awards 2024 |
| **Notion (Mobile 2024)** | Productivity | Typografie *ist* Navigation: Kein Icon-Tab-Wald, keine Bottom-Bar, stattdessen kontextuell erscheinende Command-Palette und hierarchisches Text-Layout. Der Screen wechselt seinen Charakter je nach Task-Kontext vollständig. Zeigt dass Navigation kein fixes UI-Element sein muss. | EchoMatch Home Hub: Statt fixer Bottom-Navigation-Bar mit 5 Icons — kontextuelle Navigation die je nach Tageszeit / Quest-State / Session-Phase anders erscheint. Morgens: Daily-Quest prominent. Nach Session: Social-Nudge prominent. Navigation *folgt* dem Nutzer. | Notion Design System Blog / App Store Screenshots |
| **Zenly (R.I.P. 2023) / Life360 Redesign** | Social Location | Spielfeld *ist* die Map — kein getrennter "Social"-Tab, kein separater "Location"-Screen. Die soziale Aktivität passiert auf dem gleichen visuellen Layer wie die Kern-Funktion. Freunde erscheinen als lebendige Elemente im primären Interface, nicht hinter einem Tab-Click. | EchoMatch Level-Map: Freunde *sind* auf der Map sichtbar — kleine Avatare auf ihrem aktuellen Level-Punkt, kein separater Social-Hub nötig. Soziale Präsenz ist ambient in der Kern-Navigation sichtbar, nicht isoliert. Reduziert Tab-Depth, erhöht Social-Salienz. | TechCrunch Zenly Obituary / Life360 Design Release Notes 2024 |

---

## Virale UI-Momente

**Designs die auf TikTok/Instagram geteilt werden, *weil* sie anders aussehen:**

**1. Duolingo's Owl Reaction-Moments**
TikTok-Clips mit Duo der Eule die den Nutzer bei Streak-Verlust "bedroht" haben Hunderte Millionen Views generiert — nicht wegen Gameplay, sondern wegen der unerwarteten *Persönlichkeit* im Interface. Der Charakter bricht die vierte Wand der App. Relevanz: EchoMatch's narrative Figuren könnten ähnliche Out-of-Character-Moments haben — ein Story-NPC der nach einem verlorenen Level im Interface "auftaucht" und kommentiert.

**2. Spotify Wrapped Full-Screen Typography**
Jedes Jahr im Dezember viral: Nutzer teilen ihre Wrapped-Screens nicht als Screenshot sondern als identitäres Statement. Der Grund ist das Design selbst — große, isolierte Zahlen auf schwarzem Grund mit einer einzigen Akzentfarbe wirken wie ein Konzert-Poster, nicht wie eine App-Statistik. Das ist viralitäts-by-design.

**3. Robinhood's "All Red / All Green" Portfolio-Screens**
Paradoxerweise teilen Nutzer sowohl massive Verlust- als auch massive Gewinn-Screens — weil das minimalistische Dark-UI bei beiden Zuständen dramatisch aussieht. Die Emotionalität kommt nicht aus Konfetti sondern aus visueller Reduktion. Ein einziger grüner Prozentwert auf schwarzem Grund ist ikonischer als jede Partikel-Animation.

**4. BeReal's Dual-Camera Raw-Aesthetic**
Der "kein Filter, kein Retouch"-Moment wurde selbst zum ästhetischen Statement auf Instagram — der Anti-Design-Look *ist* das virale Design. Nutzer screenshot-eten den "Late"-Notification-Screen weil er so undesigned wirkte.

**5. Notion's "Blank Canvas" Opening-Screens**
Design-Twitter und TikTok teilen regelmäßig ästhetische Notion-Setups — die App ist zur Leinwand für persönliche Ausdrucksform geworden. Die Typo-Freiheit ist das Feature das fotografiert wird, nicht das Produkt-Feature.

**Für EchoMatch ableitbar:**
Der virale Moment muss ins Design eingebaut werden — der **Post-Session-Share-Screen als Poster** (Spotify-Principle), der **Story-NPC der das Interface bricht** (Duolingo-Principle), und die **Level-Map als lebendige Social-Karte** (Zenly-Principle) sind drei konkrete UI-Momente die Nutzer teilen würden, *weil sie so anders aussehen als alles andere im Puzzle-Genre*.

---

# Differenzierungspunkte & Anti-Standard-Regeln: EchoMatch

---

## Differenzierungspunkt 1: Dark-Field Luminescence

- **Standard ist:** Hypersaturierte Primärfarben auf weißem oder hellem Hintergrund — Steine werden beleuchtet von außen, Hintergrund ist neutral-hell, Spielfeld wirkt wie ein Kinderbuch
- **Unsere Lösung:** Das Spielfeld ist dunkel (tiefdunkles Blau-Grau, #0D0F1A bis #1A1D2E als Grundpalette). Die Match-3-Steine sind selbstleuchtende Objekte — sie emittieren Licht durch Glow-Shader (Bloom-Effekt), nicht reflektieren es. Ein roter Stein wirkt wie eine Glut, ein blauer Stein wie biolumineszentes Wasser. Der Hintergrund atmet subtil mit dem Gameplay: Combo = Hintergrund-Puls, Stille = minimales Partikel-Drift. Farbtemperatur der Steine ändert sich je nach aktivem Story-Kapitel (Kapitel 1 = kühle Töne, Kapitel 3 = warme Amber-Töne)
- **Warum besser für die Zielgruppe:** 18–34-Jährige in Tier-1-Märkten sind konditioniert auf hochwertige Spielästhetik (Genshin Impact, Alto's Odyssey, Monument Valley). Dunkle, atmosphärische Spielfelder sind ein Qualitätssignal — differenziert sofort vom Candy-Crush-Brei. Gleichzeitig wirkt das Spielfeld auf dem nächtlichen Commute (primärer Use-Case laut Session-Design 5–10 Min.) angenehmer für die Augen. Dark-First ist 2024/2025 der Erwachsenen-Modus — Robinhood, Spotify, Steam beweisen das
- **Technisch machbar mit Unity:** Ja — Unity URP (Universal Render Pipeline) unterstützt Bloom-Post-Processing und Emission-Maps nativ. Glow-Shader für Match-3-Steine sind Standard-Asset-Store-Material. Hintergrund-Puls via Animator-Controller auf Canvas-Layer. Kapitel-basierte Farbpaletten-Wechsel via ScriptableObjects parametrisierbar. Performant ab mid-range Android (Snapdragon 678+) wenn Bloom-Intensität skaliert wird
- **Betroffene Screens:** S006, S008, S004, S009, S001

---

## Differenzierungspunkt 2: Kontextuelle Navigation statt fixer Bottom-Bar

- **Standard ist:** Fünf statische Icons in einer fixen Bottom-Navigation-Bar, immer sichtbar, immer identisch — unabhängig davon ob der Nutzer gerade verloren hat, einen Quest-Streak aufrecht hält oder zum ersten Mal seit drei Tagen die App öffnet
- **Unsere Lösung:** Keine persistente Bottom-Bar. Stattdessen ein kontextuell erscheinendes **Radial-Menü** das via Swipe-Up-Geste vom Home-Hub aus erreichbar ist, kombiniert mit **situativen Action-Surfaces** die je nach State in den Screen eingebettet sind. Konkret: Nach einem verlorenen Level erscheint primär "Nochmal" + "Booster holen" — kein Shop-Tab, kein Map-Tab, kein Social-Tab der ablenkt. Nach einer gewonnenen Session erscheint "Map" + "Story weiter" + "Teilen". Morgens beim Re-Entry erscheint die Daily-Quest als primäres visuelles Element, nicht als Tab hinter einem Icon. Das Radial-Menü (5 Sektoren: Spielen, Map, Story, Social, Profil) erscheint on-demand, schließt sich nach Auswahl, hinterlässt keinen Viewport-Platz-Raub von 60px am unteren Screen
- **Warum besser für die Zielgruppe:** Reduziert kognitive Last im Commuter-Kontext. Der Nutzer sieht immer das, was jetzt relevant ist — nicht fünf gleichwertige Optionen. Entspricht dem mentalen Modell von Notion (kontextuelle Command-Palette) und modernem iOS-Design (kontextuelle Toolbars). Für EchoMatch's Social-Layer bedeutet das: Social-Nudge erscheint *dann* wenn die Wahrscheinlichkeit hoch ist (Post-Session), nicht permanent als Tab der ignoriert wird
- **Technisch machbar mit Unity:** Ja mit Aufwand — Radial-Menü in Unity via UI Toolkit oder uGUI als Overlay-Canvas realisierbar. State-Machine (GameState ScriptableObject) triggert via Event-System unterschiedliche Action-Surface-Prefabs. Swipe-Gesture via Input System Package. Größter Aufwand: State-Mapping für alle 22 Screens (ca. 3–5 Entwicklertage extra). Kein externer Vendor nötig
- **Betroffene Screens:** S005, S006, S007, S008, S009, S010, S011

---

## Differenzierungspunkt 3: Post-Session Share-Card statt Reward-Overlay

- **Standard ist:** Konfetti von oben, drei goldene Sterne, "AMAZING!"-Text in Comic-Bold, Coins springen animiert in die UI-Leiste, Sound-Fanfare — ein Reward-Screen der aussieht wie 2013 und auf keiner Social-Media-Plattform freiwillig geteilt wird
- **Unsere Lösung:** Der Post-Session-Screen ist als **Poster-Karte** designed — Vollbild, typografisch geführt, mit dynamischer Farbwelt aus dem aktuellen Story-Kapitel. Konkret: Schwarzer oder tiefdunkler Hintergrund, große expressive Type (z.B. "47 Züge. Kein Fehler." oder "Kapitel 2 abgeschlossen."), darunter eine minimalistische visuelle Zusammenfassung (Score, Streak, Quest-Status als Piktogramme, keine Zahlenberge). Unten: ein einzelner "Teilen"-Button der die Karte als PNG exportiert — ready for Instagram Stories, WhatsApp. Sterne werden durch ein einziges atmosphärisches Bild ersetzt: Charakter-Silhouette vor Kapitel-Hintergrund, stil nah an Spotify Wrapped. Kein Konfetti. Kein Sound-Fanfare (optionale subtile Audio-Ambience statt Fanfare)
- **Warum besser für die Zielgruppe:** Spotify Wrapped hat bewiesen: Menschen teilen ästhetisch designte Zusammenfassungen freiwillig wenn sie wie persönliche Statements aussehen, nicht wie Werbebanner. EchoMatch's organischer UA-Kanal (Social Sharing) funktioniert nur wenn der geteilte Content nicht peinlich aussieht. Die Zielgruppe 18–34 teilt keine Candy-Crush-Screenshots — aber sie teilen Spotify-Wrapped-Stories. Der Share-Card-Ansatz macht jeden Level-Abschluss zu einem potenziellen organischen Touchpoint
- **Technisch machbar mit Unity:** Ja — Unity `ScreenCapture.CaptureScreenshotAsTexture()` für In-App-Screenshot, anschließend via Native Share Plugin (iOS UIActivityViewController / Android Intent) als PNG teilen. Dynamische Typografie via TextMeshPro mit programmatischer Textsetzung (Score-Daten als String-Injection). Kapitel-basierte Hintergrundfarben via ScriptableObject-Palette. Kein signifikanter Mehraufwand gegenüber Standard-Reward-Screen
- **Betroffene Screens:** S007, S015

---

## Differenzierungspunkt 4: Ambientes Social-Layer auf der Level-Map

- **Standard ist:** Ein separater "Social"-Tab hinter einem People-Icon in der Bottom-Nav — Freunde sind unsichtbar im Kern-Interface, soziale Aktivität ist in einen Silo verbannt der aktiv geklickt werden muss
- **Unsere Lösung:** Freunde-Avatare sind **direkt auf der Level-Map** als lebendige Elemente sichtbar — kleine animierte Avatar-Pins die auf dem Level-Punkt stehen wo sich der Freund aktuell befindet. Kein separater Social-Tab nötig für die Grundinformation. Antippen eines Avatar-Pins öffnet ein minimales Overlay (Name, letztes Level, Challenge-Button) — nicht einen vollständigen Screen-Wechsel. Die Map selbst kommuniziert also gleichzeitig: eigenen Fortschritt + sozialen Kontext. Neu freigeschaltete Level durch einen Freund triggern eine subtile Glow-Animation am entsprechenden Map-Knoten
- **Warum besser für die Zielgruppe:** Soziale Vergleichs-Mechanik (FOMO, Competitive Pull) ist im Match-3-Genre ein bewiesener Retention-Treiber — aber nur wenn sie im Flow sichtbar ist, nicht hinter einem Tab-Click begraben. Ambient Social Presence erhöht die wahrgenommene Lebendigkeit der App ohne aktive Interaktion zu erzwingen. Referenz: Zenly's Kernprinzip war "Soziales passiert auf der primären UI-Layer"
- **Technisch machbar mit Unity:** Ja — Avatar-Pins als Prefabs auf dem Map-Scroll-Container, Position via Level-ID-Mapping aus Firestore (Freunde-Fortschrittsdaten via Cloud-Sync). Polling oder WebSocket-Update alle 5 Minuten ausreichend (kein Echtzeit-Zwang). Avatar-Sprites als Nutzer-Profilbild gecached. Overlay via Animator-Panel über Map-Canvas. Datenschutz: nur Freunde die App-intern connected sind sichtbar (DSGVO-konform, Opt-in via Social Hub S010)
- **Betroffene Screens:** S008, S010

---

## Differenzierungspunkt 5: Stiller Shop — Vertrauen als Design-Aussage

- **Standard ist:** Vollbild-Grid mit 6–8 Kacheln, jede mit schrägem rotem "BEST VALUE!"-Banner, Countdown-Timer als roter Pulsbalken, grüne "KAUFEN!"-Buttons, Preisarchitektur in Goldfarbe auf dunklem Kachelgrund — visueller Schrei auf allen Ebenen gleichzeitig
- **Unsere Lösung:** Der Shop (S011) folgt einer **Editorial-Layout-Logik**: Viel Raum zwischen Elementen, maximal drei Angebote gleichzeitig sichtbar ohne Scrollzwang, keine Schräg-Banner. Preise stehen in klarer, lesbarer Type ohne Gold-Schimmer. Der Battle-Pass hat eine eigene prominente Karte oben — klar, groß, mit einer einzigen Aussage ("Saison 1 — noch 23 Tage"). Foot-in-Door-Angebot wird nicht durch einen Countdown-Timer unter Druck gesetzt sondern durch einen dezenten Hinweis ("Einmaliges Angebot für neue Spieler") ohne Sekundenanzeige. Farbakzente im Shop folgen der Kapitel-Farbwelt, keine generischen Gold-Grün-Schemata
- **Warum besser für die Zielgruppe:** Die Zielgruppe 18–34 ist maximal immunisiert gegen Dark-Pattern-Ästhetik — sie erkennt und ressentiert rote Countdown-Timer als Manipulation. Vertrauen als Design-Signal ist der Differentiator: Ein Shop der nicht schreit signalisiert Qualität und Selbstsicherheit des Produkts. BeReal's Radikalprinzip — das Weglassen *ist* das Design — übertragen auf Monetarisierung. Conversion kommt durch Vertrauen, nicht durch visuellen Druck bei dieser Zielgruppe
- **Technisch machbar mit Unity:** Ja — UI Toolkit oder uGUI ScrollView mit fixem Layout-Grid. Kein technischer Mehraufwand gegenüber Standard-Shop. Remote Config (Firebase) für Angebots-Inhalte. Timer-Logik bleibt erhalten, wird nur visuell dezenter dargestellt (kein Puls-Effekt, kein Rot)
- **Betroffene Screens:** S011, S012

---

## Anti-Standard-Regeln (VERBINDLICH für Produktionslinie)

| # | Was die KI normalerweise machen würde | Was stattdessen gebaut werden MUSS | Betroffene Screens | Begründung |
|---|---|---|---|---|
| 1 | Weißer oder hellgrauer Hintergrund als Basis-Canvas für alle Screens | Dunkler Basis-Canvas (#0D0F1A bis #1A1D2E) als primäre Designsprache — kein Screen darf einen hellen Hintergrund als Default haben. Ausnahme nur für DSGVO/ATT-Modal (System-Pflicht) | S001, S003, S004, S005, S006, S007, S008, S009, S010, S011 | Heller Hintergrund = Candy Crush 2012. Dunkles UI = sofortiger Qualitätssignal für 18–34-Zielgruppe, differenziert auf dem ersten Screenshot im App Store |
| 2 | Fünf-Icon Bottom-Tab-Bar persistent auf allen Screens | Kein persistentes Bottom-Tab-Element. Navigation über kontextuelles Radial-Menü (Swipe-Up) und situative Action-Surfaces die je nach Screen-State eingebettet sind | Alle Screens außer S002, S014 | Jede zweite Mobile-App hat diese Bottom-Bar. Sie kostet 60px Viewport, ignoriert Nutzer-Kontext und ist das sichtbarste Genre-Klischee nach dem Spielfeld selbst |
| 3 | Konfetti-Regen, drei goldene Sterne und "AMAZING!"-Text auf dem Gewinn-Screen | Vollbild-Poster-Karte mit expressiver Typografie (konkrete Session-Aussage wie "47 Züge. Kein Fehler."), Kapitel-Farbwelt als Hintergrund, ein einziger "Teilen"-Button. Kein Konfetti. Keine generischen Lobtext-Banner | S007 | Konfetti-Screens werden nicht geteilt. Poster-Karten werden geteilt. Social Sharing ist primärer organischer UA-Kanal — der Screen muss share-würdig sein, nicht infantil belohnend |
| 4 | Rote "BEST VALUE!"-Schräg-Banner und Puls-Countdown-Timer im Shop | Maximale drei Angebote gleichzeitig, kein Schräg-Banner, kein Puls-Effekt beim Timer, Preise in klarer lesba-rer Type ohne Gold-Rendering, Countdown als dezenter Text ("noch 23 Tage") nicht als animierter Balken | S011, S012 | Dark Patterns sind bei 18–34-Jährigen kontraproduktiv — sie erzeugen Ressentiment statt Conversion. Stille Shop-Ästhetik ist Differenzierung und Vertrauensaufbau |
| 5 | Partikel-Burst-Explosion bei jedem Match (200ms-Pop-Effekt) | Match-Feedback über Licht-Emission: Steine lösen sich mit einem Glow-Pulse auf (400–600ms Ease-Out), Licht breitet sich kurz auf Nachbar-Felder aus und verblasst. Cascade-Animationen folgen einer organischen Physik-Kurve, nicht linearem Fall | S006 | Burst-Partikel sind der universelle Match-3-Standard seit 2012. Licht-basiertes Feedback ist kohärent mit der Dark-Field-Ästhetik und fühlt sich hochwertiger an |
| 6 | Abgerundete fette Display-Schrift für alle Headlines (eine Schriftfamilie, immer gleiche Anmutung) | Typografischer Kontrast: Schmale, expressive Schrift (z.B. Kategorie: Condensed Display, hohe x-Höhe) für Story-/Narrative-Momente vs. klare technische Sans-Serif für UI-Elemente (Score, Züge, Preise). Schriftcharakter wechselt mit Kontext | S004, S007, S009, S011 | Eine Schrift für alles kommuniziert keine Hierarchie und keinen Charakter. Typografischer Kontrast ist das günstigste Differenzierungsmittel — zero technischer Aufwand, maximaler visueller Impact |
| 7 | Sozialer Layer hinter einem separaten "Social"-Tab versteckt | Freunde-Avatare als Pins direkt auf der Level-Map sichtbar. Kein Tab-Click nötig für soziale Grundinformation. Social-Hub (S010) bleibt für tiefere Interaktion, wird aber nicht als primärer Einstiegspunkt für soziale Präsenz genutzt | S008, S010 | Soziale Mechaniken wirken nur wenn sie im primären Flow sichtbar sind. Tab-Klick-Hürde eliminiert den FOMO-Effekt der Retention antreibt |
| 8 | Tutorial-Hand-Cursor zeigt ersten Zug, statisches Overlay mit Charakter-Bubble | Onboarding ist das erste echte Match — kein Tutorial-Overlay, kein abgedunkelter Hintergrund, kein Hand-Cursor. Spielstil-Tracking beginnt still beim ersten Zug. Einzige Hilfe: dezente Glow-Markierung der validen Züge für die ersten 5 Sekunden, dann verschwindend | S003 | Das Standard-Tutorial macht den Nutzer zum passiven Clicker. Direktes Spielen mit minimalem Hint aktiviert Agency-Gefühl sofort und ist Differenzierungsmerkmal das im App-Store-Review auffällt |

---

## Tech-Stack Kompatibilität

| Differenzierung | Umsetzbar | Zusätzlicher Aufwand | Hinweise |
|---|---|---|---|
| Dark-Field Luminescence (Glow-Shader, Bloom) | ✅ Ja | Mittel (+3–5 Tage Shader-Entwicklung) | Unity URP Bloom-Post-Processing nativ. Emission-Maps für Stein-Sprites. Performance-Skalierung für mid-range Android zwingend testen (Bloom-Intensität per Qualitätsstufe) |
| Kontextuelle Radial-Navigation | ✅ Ja mit Aufwand | Hoch (+5–8 Tage für State-Machine + alle Screen-States) | State-Machine via ScriptableObject-Events in Unity. Radial-Menü als Canvas-Overlay. Größter Aufwand: State-Mapping für alle 22 Screens vollständig definieren vor Produktion |
| Post-Session Share-Card als PNG | ✅ Ja | Gering (+1–2 Tage) | `ScreenCapture.CaptureScreenshotAsTexture()` + Native Share Plugin (NativeShare by Yasirkula — bewährt, kostenlos). TextMeshPro für dynamische Score-Strings. Kapitel-Palette via ScriptableObject |
| Ambientes Social-Layer auf Level-Map | ✅ Ja | Mittel (+3–4 Tage Backend + 2 Tage Frontend) | Avatar-Pins als Prefabs auf Map-ScrollRect. Freunde-Fortschrittsdaten via Firestore (bereits im Stack). Polling alle 5 Min. ausreichend. DSGVO: Opt-in-Gate via S010 Social Hub bereits geplant |
| Stiller Shop — Editorial Layout | ✅ Ja | Gering (+0–1 Tage gegenüber Standard) | Simpler als Standard-Shop (weniger Elemente, kein Schräg-Banner-System). Remote Config (Firebase) für Angebotsdaten bereits im Stack. Kein technischer Mehraufwand |
| Licht-Emission Match-Feedback | ✅ Ja | Mittel (+2–3 Tage Animation + Testing) | Animator-Controller auf Stein-Prefabs, Glow-Pulse via Shader-Parameter-Animation. Cascade-Physik via Unity Physics2D mit angepasster Gravity-Scale statt linearem Tween |
| Typografischer Kontrast (zwei Schrift-Charaktere) | ✅ Ja | Gering (+1 Tag Setup) | Zwei Schriftfamilien via TextMeshPro Font Assets. Klare Regel: Condensed Display nur S004/S007/S009, Sans-Serif für alle UI-Elemente. Google Fonts (Lizenzkostenfreiheit prüfen für kommerzielle Nutzung) |
| Onboarding ohne Tutorial-Overlay | ✅ Ja | Gering (+1–2 Tage gegenüber Standard) | Hint-System via Glow-Markierung auf validen Zügen (bereits für S006 entwickelt) statt separatem Tutorial-System. Vereinfacht Codebase gegenüber Standard-Tutorial-Overlay |