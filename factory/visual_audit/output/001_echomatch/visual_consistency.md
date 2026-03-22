# Visual-Consistency-Report: echomatch

## Zusammenfassung
- **Geprueft:** 22 Screens, 7 User Flows
- **🔴 Blocker:** 65 Stellen
- **🟡 Schlechte UX:** 27 Stellen
- **🟢 Nice-to-have:** 8 Stellen
- **⚠️ KI-Warnungen:** 65 Stellen

---

# Visual-Consistency-Check: Flows 1-4

## Ampel-Übersicht

| Screen | 🔴 Blocker | 🟡 Schlechte UX | 🟢 Nice-to-have | ⚠️ KI-Warnung | Status |
|---|---|---|---|---|---|
| S001 Splash | 2 | 1 | 0 | 2 | 🔴 Kritisch |
| S002 DSGVO/ATT | 1 | 2 | 0 | 3 | 🔴 Kritisch |
| S020 ATT-Fallback | 1 | 1 | 0 | 2 | 🔴 Kritisch |
| S003 Onboarding Match | 3 | 1 | 1 | 3 | 🔴 Kritisch |
| S004 Narrative Hook | 1 | 2 | 1 | 2 | 🔴 Kritisch |
| S005 Home Hub | 1 | 3 | 1 | 3 | 🔴 Kritisch |
| S008 Level-Map | 2 | 2 | 1 | 2 | 🔴 Kritisch |
| S006 Spielfeld | 4 | 2 | 0 | 4 | 🔴 Kritisch |
| S007 Level-Ergebnis | 2 | 2 | 1 | 3 | 🔴 Kritisch |
| S011 Shop | 2 | 2 | 0 | 3 | 🔴 Kritisch |
| S010 Social Hub | 1 | 3 | 1 | 3 | 🔴 Kritisch |
| S015 Share Sheet | 0 | 2 | 1 | 1 | 🟡 Warnung |

---

## Flow 1: Onboarding — Detail

### S001 — Splash / Loading

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Bildschirmmitte: Logo | 🔴 | Ohne Logo sieht der Nutzer beim allerersten App-Start einen schwarzen oder weißen Ladebildschirm — App wirkt kaputt, Erstvertrauen sofort zerstört | A002 Splash-Screen-Logo |
| Vollbild-Hintergrund | 🔴 | Leerer Systemhintergrund hinter dem Logo — keine Spielwelt-Atmosphäre, kein emotionaler erster Eindruck | A003 Splash-Screen-Hintergrund |
| Ladefortschritt unten | 🟡 | Ohne animierten Ladebalken weiß der Nutzer nicht ob die App hängt oder lädt — führt zu Abbrüchen bei langsamer Verbindung | A004 Ladebalken / Loading-Indicator |
| App-Icon (Home Screen) | ⚠️ | App-Icon erscheint dem Nutzer BEVOR er die App öffnet — fehlendes oder generisches Icon senkt schon die Erst-Öffnungsrate | A001 App-Icon |

---

### S002 — DSGVO / ATT Consent

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| ATT Pre-Permission Visual (iOS) | 🔴 | iOS-Nutzer sehen vor dem System-ATT-Dialog KEINEN erklärenden Kontext — ATT-Ablehnungsrate steigt nachweislich auf 60–80% wenn kein erklärendes Bild vorangeht | A007 ATT-Prompt-Visual |
| Illustration zur DSGVO-Auflockerung | 🟡 | Reiner Rechtstext ohne visuelle Auflockerung wirkt wie eine Behörden-App — Nutzer überfliegen oder brechen ab, ohne den Consent zu lesen | A006 DSGVO-Consent-Illustration |
| Minderjährigen-Block-State | 🟡 | Kein Artwork für COPPA-Block — Nutzer unter 13 sehen eine leere Fehlermeldung statt einer altersgerechten, freundlichen Erklärung | A008 Minderjährigen-Block-Illustration |

---

### S020 — Kaltstart Personalisierungs-Fallback

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Spielstil-Auswahlkarten | 🔴 | Ohne visuelle Karten sieht der Nutzer Radio-Buttons oder Textliste — der Spielstil (z.B. „Casually relaxed" vs. „Competitive") ist ohne Bild-Kontext nicht intuitiv wählbar, führt zu Zufallsauswahl statt echtem Signal | A048 Kaltstart-Personalisierungs-Auswahlkarten |
| Hintergrund / Screen-Kontext | 🟡 | Ohne thematischen Hintergrund springt dieser Screen visuell komplett aus dem Onboarding-Fluss heraus — Nutzer fragt sich ob er noch in derselben App ist | A003 (Variante) oder dedizierter Screen-BG |

---

### S003 — Onboarding Match / Spielstil-Tracking

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Match-3-Spielsteine | 🔴 | Ohne Sprite-Set sieht der Nutzer farbige Rechtecke oder Buchstaben-Labels — das Spiel wirkt wie ein Prototyp, Tracking-Validität bricht ein weil Spielverhalten durch schlechte UX verfälscht wird | A009 Match-3-Spielstein-Sprite-Set |
| Spielfeld-Hintergrund | 🔴 | Weißer oder systemgrauer Hintergrund hinter dem Grid — der allererste Spielmoment, den der Nutzer erlebt, hat null Atmosphäre | A010 Match-3-Spielfeld-Hintergrund |
| Grid-Rahmen und Zellen-Design | 🔴 | Unstyled Grid-Lines — Nutzer erkennt nicht sofort wo das Spielfeld beginnt und endet, Tutorial-Hint-Pfeile zeigen ins Nichts | A013 Spielfeld-Grid-Rahmen |
| Tutorial-Hint-Pfeile / Tap-Overlay | 🟡 | Ohne animierte Hint-Pfeile bekommt der neue Nutzer keinen ersten Zug-Hinweis — das implizite Tracking erfasst dann Verwirrung statt Spielstil | A049 Onboarding-Hint-Pfeile und Tutorial-Overlays |
| Partikel-Effekte bei Match | 🟢 | Fehlen der Match-Effekte beim ersten Erfolgserlebnis dämpft den Wow-Moment — funktioniert ohne, aber D1-Retention leidet | A012 Match-Animation-Effekte |

---

### S004 — Narrative Hook Sequenz

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Story-Teaser-Artwork / Sequenz-Bild | 🔴 | Der Narrative Hook ist das emotionale Kernstück das den Spieler für die Meta-Layer begeistern soll — ohne Artwork sieht der Nutzer Textboxen auf leerem Hintergrund, der emotionale Anker für D30-Retention entsteht nicht | A006 (Narrative-Variante) + dediziertes Story-Artwork (Story-Layer-Illustration) |
| Skip-Button-Sichtbarkeit | 🟡 | Wenn der Skip-Button nur als Textelement ohne visuellen Kontrast zur Story-Sequenz existiert, wird er entweder nicht gefunden (Nutzer wartet passiv) oder sofort getappt bevor der Hook wirkt | Kein separates Asset nötig — aber visuelles CTA-Design-Constraint |
| Übergangs-Animation S003→S004 | 🟡 | Harter Schnitt vom Spielfeld zur Story-Sequenz ohne Überblende wirkt wie ein App-Absturz-Recovery | Transition-Asset oder Fade-Overlay |
| Story-Charakter-Illustration | 🟢 | Ohne Charakter-Visual ist der narrative Anker abstrakt — Nutzer verbindet sich nicht mit der Spielwelt | Dediziertes Story-Character-Asset (in Asset-Liste nicht explizit vorhanden — Lücke) |

---

## Flow 2: Core Loop — Detail

### S005 — Home Hub (Returning User)

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Hero-Banner | 🔴 | Ohne Hero-Banner-Artwork ist der zentrale tägliche Re-Entry-Screen eine leere Fläche — kein täglicher Anreiz, kein visueller Aufhänger für Daily Quests oder Battle-Pass | A028 Home Hub Hero-Banner |
| Daily-Quest-Cards | 🟡 | Ohne Quest-Card-Design sieht der Nutzer eine Textliste von Aufgaben — kein visueller Progress-Anreiz, FOMO-Wirkung geht verloren | A029 Daily-Quest-Card-Design |
| Battle-Pass-Teaser-Banner | 🟡 | Ohne Saison-Artwork ist der Battle-Pass-Teaser ein Textlink — Conversion-Rate in S012 sinkt massiv | A032 Battle-Pass-Saison-Banner |
| Tab-Bar-Icons | 🟡 | Ohne Icons nur Text-Labels in der Tab-Bar — auf kleinen Screens (iPhone SE) sind Text-Tabs kaum tappbar und wirken nicht wie ein Spiel | A046 Tab-Bar-Icons |
| Währungs-Anzeige (Header) | 🟢 | Währungsmenge ohne Icon ist eine nackte Zahl — kein spielerisches Gefühl für Ressourcen | A036 Währungs-Icons |

---

### S008 — Level-Map / Progression

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Level-Map-Pfad-Grafik | 🔴 | Ohne Pfad-Illustration ist die Level-Map eine nummerierte Liste von Buttons — das Fortschrittsgefühl, das der Kernmotivationsmotor der Progression ist, existiert nicht | A021 Level-Map-Pfad-Grafik |
| Welt-Hintergrund-Illustration | 🔴 | Verschiedene Welten mit identischem Hintergrund — Nutzer spürt nicht dass er in eine neue Spielwelt aufsteigt, Meilenstein-Gefühl fehlt | A023 Level-Map-Hintergrund-Welten |
| Level-Knoten-Icons (Gesperrt/Offen/Abgeschlossen) | 🟡 | Ohne Icon-Sprites sind Level-Status-Zustände nur durch Farbe oder Text unterscheidbar — Nutzer muss aktiv lesen statt scannen | A022 Level-Knoten-Icons |
| KI-Quest-Markierung auf Level-Knoten | 🟡 | Ohne visuellen Quest-Marker auf dem aktuellen KI-Quest-Level findet der Nutzer das tägliche Ziel nicht auf Anhieb | A065 Spielfeld-Ziel-Indikator-Icons (Variante) + A030 Quest-Icon-Set |
| Neu-freigeschaltete-Level-Animation | 🟢 | Fehlendes Unlock-Feedback dämpft den Progressions-Belohnungsmoment | A022 (animierter State) |

---

### S006 — Puzzle / Match-3 Spielfeld

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Spielstein-Sprites (Core) | 🔴 | Ohne Sprites sieht der Nutzer farbige Quadrate oder Buchstaben — das Spiel ist schlicht nicht spielbar im Sinne einer kommerziellen App | A009 Match-3-Spielstein-Sprite-Set |
| Spezialstein-Sprites (Bombe, Blitz, Regenbogen) | 🔴 | Ohne Spezialstein-Design sind Sondersteine von normalen Steinen visuell nicht unterscheidbar — Spieler aktiviert Spezialeffekte versehentlich oder nie, Spieltiefe kollabiert | A011 Match-3-Spezialstein-Sprites |
| Hindernisse (Eis, Stein, Kette) | 🔴 | Ohne Hindernis-Sprites sind alle Zellen optisch gleich — Level-Ziele („Breche Eis auf") sind nicht erkennbar | A066 Hindernisse und Spezialzellen-Sprites |
| Booster-Icons im HUD | 🔴 | Ohne Icons sind Booster-Buttons unbeschriftete Rechtecke oder Texte wie „B1 B2 B3" — Nutzer nutzt Booster nicht, IAP-Motivation für Booster-Käufe sinkt auf null | A016 Booster-Icons im Spielfeld |
| Züge-Anzeige (Move-Counter) | 🟡 | Nackte Zahl ohne visuellen Kontext — Nutzer entwickelt kein Dringlichkeitsgefühl bei wenigen verbleibenden Zügen | A014 Züge-Anzeige / Move-Counter |
| Score-HUD | 🟡 | Statische Zahl ohne Score-Zuwachs-Animation — kein Dopamin-Feedback bei guten Zügen | A015 Punkte-/Score-Anzeige HUD |

---

### S007 — Level-Ergebnis / Post-Session

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Verloren-Illustration | 🔴 | Reiner Text „Du hast verloren" ohne empathische Illustration — emotionaler Tiefpunkt ohne Abfederung führt direkt zu Session-Abbruch statt Retry | A018 Level-Verloren-Illustration |
| Reward-Item-Icons (Gewonnen-State) | 🔴 | Rewards als Textliste (z.B. „+50 Coins, +1 Stern") ohne Icons — Belohnungsmoment hat keinen visuellen Impact, Battle-Pass-Fortschritt fühlt sich nicht wertvoll an | A020 Reward-Item-Icons |
| Social-Nudge-Banner | 🟡 | Ohne visuelles Banner-Design ist der Social-Nudge ein Texthinweis der übersehen wird — Social-Feature-Discovery sinkt | A067 Social-Nudge-Banner-Design |
| Währungs-Icons im Ergebnis-Screen | 🟡 | Ohne Währungs-Icons neben den Reward-Zahlen fehlt der spielerische Kontext der Belohnung | A036 Währungs-Icons |
| Share-CTA-Visual | 🟢 | Share-Button als reiner Text-Button — kein viraler Anreiz | A040 Share-Result-Bild-Template |

---

## Flow 3: Erster Kauf — Detail

### S011 — Shop / Monetarisierungs-Hub

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Shop-Angebots-Karten | 🔴 | Ohne Card-Design sieht der Nutzer eine Preisliste — psychologischer Wert der Angebote wird nicht transportiert, Conversion bricht massiv ein | A034 Shop-Angebots-Karten |
| Foot-in-Door-Highlight | 🔴 | Das Einstiegsangebot muss sich visuell sofort von allen anderen Angeboten abheben — ohne Highlight-Design sieht es aus wie jedes andere Angebot, der Foot-in-Door-Effekt entsteht nicht | A035 Foot-in-Door-Angebot-Highlight |
| Reward-Icons auf Karten | 🟡 | Karten zeigen Reward-Menge als Text ohne Icon — „100 Edelsteine" ohne Edelstein-Bild transportiert keinen wahrgenommenen Wert | A020 Reward-Item-Icons + A036 Währungs-Icons |
| Battle-Pass-Saison-Banner im Shop | 🟡 | Ohne Saison-Artwork im Shop fehlt der emotionale Anker warum der Battle-Pass wertvoll ist | A032 Battle-Pass-Saison-Banner |

---

### S012 — Battle-Pass Screen

*(Wird in Flow 3 als Alternativ-Einstieg erreicht)*

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Tier-Reward-Visualisierung | 🔴 | Ohne horizontale/vertikale Tier-Leiste mit visuellen Reward-Icons sieht der Nutzer eine Tabelle mit Reward-Namen — der „ich will all das haben"-Effekt der Battle-Pass-Kernmechanik entsteht nicht, Kauf-Motivation fehlt | A031 Battle-Pass-Tier-Reward-Visualisierung |
| Saison-Banner Key-Art | 🟡 | Battle-Pass ohne thematisches Saison-Artwork wirkt wie ein generischer Abo-Screen — kein Sammel-Appeal | A032 Battle-Pass-Saison-Banner |
| Saison-Timer-Visual | 🟡 | Reiner Countdown-Text ohne visuellen Dringlichkeits-Indikator — FOMO-Trigger wird nicht ausgelöst | A033 Saison-Timer-Visual |

---

## Flow 4: Social Challenge — Detail

### S010 — Social Hub

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Challenge-Card-Design | 🔴 | Ohne Challenge-Card ist eine ausstehende Challenge ein Texteintrag in einer Liste — der emotionale Reiz der Herausforderung („Freund X fordert dich heraus!") entsteht visuell nicht, Acceptance-Rate sinkt | A038 Challenge-Card-Design |
| Leaderboard-Podest-Design | 🟡 | Top-3 als nummerierte Textliste ohne Podest-Visual — kein Trophy-Gefühl, kein Anreiz in die Top-3 zu kommen | A057 Leaderboard-Top-3-Podest-Design |
| Spieler-Avatar-Rahmen | 🟡 | Avatare ohne Rahmen-Design sind optisch nicht differenzierbar — Seltenheitsstufen und Progression im Social-Layer nicht erkennbar | A037 Social-Hub-Avatar-Rahmen |
| Keine-Freunde-Empty-State | 🟡 | Leere Liste mit Text „Keine Freunde" ohne Illustration — negativer Leerraum ohne Handlungsaufforderung, Invite-CTA-Conversion sinkt | A039 Keine-Freunde-Empty-State-Illustration |
| Coming-Soon-Badge (Phase-B-Teaser) | 🟢 | Ohne Badge sieht der Nutzer gar nichts wo Phase-B-Features kommen sollen — Teaser-Effekt fehlt | A055 Coming-Soon-Badge |

---

### S015 — Social Share Sheet

| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| Share-Result-Bild-Template | 🟡 | Wenn kein visuelles Template generiert wird, teilt der Nutzer einen nackten Text-String — kein virales Bild, kein organischer UA-Effekt | A040 Share-Result-Bild-Template |
| Plattform-Icons im Share-Sheet | 🟡 | Nativer OS-Share-Sheet enthält Plattform-Icons — aber das App-generierte Preview-Bild (Card) fehlt, was die geteilten Inhalte austauschbar macht | A040 (dynamisch generierte Variante) |
| Erfolgs-Feedback nach Share | 🟢 | Kein visuelles Bestätigungs-Feedback nach erfolgreichem Share — Nutzer weiß nicht ob Share funktioniert hat | Kein dediziertes Asset nötig — UI-State-Design |

---

## ⚠️ KI-Entwicklungs-Warnungen (Flows 1-4)

| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|
| W01 | S001 Splash | Vollbild-Atmosphären-Artwork hinter dem Logo | Farbverlauf in Brand-Primärfarbe oder `#1A1A2E` Vollton | A003 Splash-Screen-Hintergrund | **Sprite/Image-View verwenden.** `Image(asset: "splash_bg")` als Fullscreen-Layer unter Logo platzieren. KEIN `Color.fill()` oder Gradient-Code als Ersatz akzeptieren. |
| W02 | S002 ATT Consent | Erklärendes Bild BEVOR der iOS-System-ATT-Dialog erscheint | Text-only Pre-Permission-Screen mit App-Beschreibung oder gar keinen Pre-Screen | A007 ATT-Prompt-Visual | **Pre-Permission-Screen als eigene View implementieren** mit `Image(asset: "att_explanation_visual")` als zentralem Element. Der System-Dialog wird erst nach Tap auf Erklärungsscreen getriggert. KEIN direktes `requestTrackingAuthorization()` ohne vorherigen Visual-Screen. |
| W03 | S002 DSGVO | Visuelle Auflockerung neben Rechtstext | Reinen UITextView/ScrollView mit Rechtstext, kein visuelles Element | A006 DSGVO-Consent-Illustration | **Illustration als festes Layout-Element** in der oberen Hälfte des Consent-Modals platzieren (`Image(asset: "consent_illustration")`). ScrollView mit Rechtstext NUR im unteren Bereich. Illustration darf NICHT weggelassen werden wenn Rechtstext lang ist. |
| W04 | S003 Spielsteine | Thematisch gestaltete Spielstein-Sprites mit Spielwelt-Ästhetik | Farbige `RoundedRectangle`-Views oder `Circle`-Shapes mit Hex-Farben als Spielstein-Ersatz | A009 Match-3-Spielstein-Sprite-Set | **Sprite Sheet laden und Einzelframes per Tile-Index rendern.** Jeder Spielstein-Typ bekommt eigenen Sprite-Frame aus `gem_sprites.atlas`. KEIN Shape-Rendering als Spielstein. Tracking-Algorithmus validiert Spielstil über Interaktions-Timing, nicht über Spielstein-Typ — aber visueller Kontext muss stimmen. |
| W05 | S003 Tutorial-Hint | Animierter Finger-Tap-Pfeil der ersten Spielzug zeigt | Statischen Text-Overlay wie „Tippe hier um zu beginnen" oder `Label`-Tooltip | A049 Onboarding-Hint-Pfeile und Tutorial-Overlays | **Lottie-Animation oder Frame-Animiertes Asset verwenden** (`hint_arrow_tap.json`). KEIN `UILabel` oder `Text()`-Overlay als Tutorial-Hinweis im Spielfeld. Animation muss auf den ersten tappbaren Stein zeigen, nicht auf generische Screen-Position. |
| W06 | S004 Narrative Hook | Vollbild-Story-Artwork oder animierte Sequenz als emotionaler erster Eindruck der Spielwelt | Text-Dialog-Box auf schwarzem oder einfarbigem Hintergrund, eventuell mit generischem Hintergrundbild | Dediziertes Story-Artwork (Lücke in Asset-Liste — **Asset fehlt in A-Liste**) | **Dedicated Story-Artwork-Asset in Asset-Discovery-Liste aufnehmen** (vorgeschlagene ID: A068). Implementierung als `Image(asset: "narrative_hook_bg")` Fullscreen mit Text-Overlay. KEIN schwarzer Hintergrund mit zentriertem Text als Narrative-Hook. |
| W07 | S005 Hero-Banner | Tageszeit-abhängig oder Event-abhängig wechselndes Artwork das täglichen Re-Entry-Anreiz visualisiert | Statische Farb-Card oder Text-Banner mit „Willkommen zurück, [Name]" | A028 Home Hub Hero-Banner | **3 Banner-Varianten in Asset-Bundle liefern** (`hero_morning.png`, `hero_evening.png`, `hero_event.png`). Tageszeit-Logik wählt Asset per lokaler Uhr. KEIN programmatisch generiertes Text-Banner als Hero-Element akzeptieren. |
| W08 | S006 Spezialsteine | Visuell sofort erkennbare Spezialsteine die sich klar von normalen Steinen unterscheiden (Bombe sieht aus wie Bombe) | Gleiche `RoundedRectangle`-Shapes wie normale Steine, nur mit anderer Farbe oder Outline | A011 Match-3-Spezialstein-Sprites | **Separate Sprite-Frames für jeden Spezialstein-Typ** aus `special_gems.atlas` rendern. Bombe = Bomben-Sprite, Blitz = Blitz-Sprite. KEIN Reuse des normalen Stein-Sprites mit veränderter `tintColor` oder Border. |
| W09 | S006 Hindernisse | Hinderniszellen die durch ihr Aussehen ihren Typ und Abbau-Zustand kommunizieren (Eis-Crack-States) | Farbige Zellen-Backgrounds (`blue` = Eis, `gray` = Stein) ohne Multi-State-Design | A066 Hindernisse und Spezialzellen-Sprites | **Sprite-Set mit je 3 Abbau-States pro Hindernis-Typ implementieren** (`ice_state_1/2/3.png`, `stone_state_1/2/3.png`). State-Wechsel über Sprite-Frame-Swap, NICHT über `opacity`-Änderung oder Farb-Overlay. |
| W10 | S007 Verloren-State | Empathische Charakter-Illustration die Niederlage emotional abfedert und Retry-Motivation aufbaut | Roter Text „Level verloren" oder System-Alert-Style-Dialog, evtl. mit rotem X-Icon | A018 Level-Verloren-Illustration | **Illustration als Fullscreen-Hintergrund oder zentrales Element** des Verloren-Screens (`level_lost_illustration.png`). Retry-Button wird ÜBER die Illustration gelegt. KEIN Alert-Dialog oder System-Modal als Verloren-Screen. |
| W11 | S011 Foot-in-Door-Angebot | Visuell hervorgehobene Angebots-Card die sich durch Größe, Glanz-Effekt oder animierten Rahmen von anderen Angeboten abhebt | Gleiche Card wie alle anderen Angebote, nur mit anderem Preis oder Text „Bestes Angebot" Label | A035 Foot-in-Door-Angebot-Highlight | **Dediziertes Highlight-Asset mit animiertem Rahmen/Glow verwenden** (`offer_highlight_frame.json` als Lottie). KEIN reines Text-Badge wie „BEST VALUE" ohne visuelles Highlight-Design. Die Card selbst muss größer oder visuell prominenter sein als Standard-Cards. |
| W12 | S020 Auswahlkarten | Bildbasierte Auswahlkarten die Spielstil durch Illustration zeigen (entspannter Spieler vs. kompetitiver Spieler) | Radio-Button-Liste oder Segmented-Control mit Text-Labels für Spielstil-Optionen | A048 Kaltstart-Personalisierungs-Auswahlkarten | **Card-basiertes Selection-UI mit Illustration pro Option implementieren.** Jede Auswahlkarte enthält `Image(asset: "playstyle_\(type).png")` + Label. KEIN `Picker`, `SegmentedControl` oder `RadioButton`-Pattern ohne visuelles Karten-Design. |
| W13 | S010 Challenge-Card | Animierte Card mit Gegner-Avatar, Score-Vergleich und Accept/Decline-CTAs | Einfacher `ListCell` mit Spielername und zwei Text-Buttons | A038 Challenge-Card-Design | **Challenge-Card als dediziertes Custom-View implementieren** mit `Image(asset: "challenge_card_bg")` als Hintergrund, Avatar-Image-View für Gegner-Profil. KEIN `UITableViewCell`/`List`-Row als Challenge-Darstellung akzeptieren. |
| W14 | S015 Share-Bild | Dynamisch generiertes Share-Bild mit App-Branding, Score und Level-Nummer als attraktive visuelle Card | Reinen Text-String teilen: „Ich habe Level 12 mit 4500 Punkten abgeschlossen! #EchoMatch" | A040 Share-Result-Bild-Template | **Share-Bild programmatisch aus Template rendern:** `UIGraphicsImageRenderer` oder Canvas-API nutzt `share_template.png` als Hintergrund und rendert Score/Level-Werte als Text-Overlay. `UIActivityViewController` bekommt das **gerenderte UIImage**, NICHT einen Text-String als primären Share-Content. |

---

# Visual-Consistency-Check: Flows 5–7 + Platzhalter

---

## Flow 5: Battle-Pass — Detail

### Flow-Pfad
`S005 → S011 → S012 → (Nativer Payment-Dialog) → S012 (Premium-State) → S005`

### Tap-Analyse

| Tap | Screen | Aktion | Erwartetes visuelles Feedback |
|---|---|---|---|
| Tap 1 | S005 | Battle-Pass-Teaser-CTA oder Shop-Tab | Tab-Bar-Icon aktiv-State (A046), Teaser-Card-Animation |
| Tap 2 | S011 | Battle-Pass-Karte antippen | A031-Vorschau expandiert, A034-Card hebt sich hervor |
| Tap 3 | S012 | „Jetzt kaufen"-Button | A004-Ladeindikator, Tier-Visualisierung A031 sperrt kurz |
| — | OS-Layer | Nativer Payment-Dialog | Außerhalb App-Kontrolle |
| Auto | S012 | Premium-State nach Kauf | A031 wechselt auf Premium-Tier-Visualisierung, A033 aktiv |

### Screen-by-Screen Asset-Check

#### S005 — Home Hub (Battle-Pass-Teaser-Einstieg)

| Element | Erwartetes Asset | Asset-ID | Status |
|---|---|---|---|
| Battle-Pass-Teaser-Card | Gestaltete Preview-Card mit Saison-Artwork | A034 | ⚠️ A034 deckt Shop-Karten ab — keine dedizierte Battle-Pass-Preview-Card in Home Hub definiert |
| Daily Quest Prompt gleichzeitig sichtbar | Daily-Quest-Card-Design | A029 | ✅ |
| Tab-Bar Shop-Icon aktiv | Tab-Bar-Icon aktiv-State | A046 | ✅ |
| Währungsanzeige im Header | Soft/Hard-Currency-Icon | A036 | ✅ |

**Fehlender Asset:** Kein dedizierter `A_BP_HomeTeaser`-Asset definiert. A034 ist für S011-Shop-Karten spezifiziert — der Battle-Pass-Teaser-Banner auf S005 hat kein eigenes Asset in der Liste.

---

#### S011 — Shop / Monetarisierungs-Hub

| Element | Erwartetes Asset | Asset-ID | Status |
|---|---|---|---|
| Battle-Pass-Kauf-Karte | Shop-Angebots-Karte mit Battle-Pass-Artwork | A034 | ✅ |
| Foot-in-Door-Highlight (falls aktiv) | Animiertes Highlight-Frame | A035 | ✅ |
| Währungs-Icons in allen Preis-Displays | Soft/Hard-Currency-Icon | A036 | ✅ |
| Reward-Item-Vorschau in Karte | Reward-Icons | A020 | ✅ |
| Ladeindikator (IAP-Laden-State) | Loading-Indicator | A004 | ✅ |
| Offline-Gesperrt-State | Offline-Error-Illustration | A005 | ⚠️ A005 ist für S021 definiert — S011-Offline-State hat keinen eigenen Illustration-Slot |

---

#### S012 — Battle-Pass Screen

| Element | Erwartetes Asset | Asset-ID | Status |
|---|---|---|---|
| Tier-Reward-Visualisierung (Free + Premium) | Horizontale Tier-Leiste | A031 | ✅ |
| Saison-Timer | Visueller Countdown | A033 | ✅ |
| Reward-Item-Icons in Tiers | Reward-Icons | A020 | ✅ |
| Ladeindikator (Laden-State) | Loading-Indicator | A004 | ✅ |
| Währungs-Icons | Soft/Hard-Currency | A036 | ✅ |
| Premium-State-Transformation der Tier-Leiste | A031 Premium-Variant | A031 | ⚠️ A031 hat 1 Variante definiert — Free vs. Premium visuell unterschiedlich? Nicht explizit |
| Saison-Abgelaufen-State | Kein dediziertes Asset sichtbar | — | 🔴 Kein Asset für „Saison abgelaufen"-Illustration definiert |

### Flow-5-Konsistenz-Risiken

| Risiko | Beschreibung | Schwere |
|---|---|---|
| Battle-Pass-Teaser auf S005 ohne eigenes Asset | Home-Hub zeigt Battle-Pass-Teaser, aber kein dedizierter A_BPTeaser existiert in der Liste — KI verwendet wahrscheinlich generische Card | 🔴 |
| A031 Varianten unklar | Nur „1 Variante" angegeben — Free/Premium-Unterschied visuell nicht gesichert | ⚠️ |
| S011 Offline-State ohne eigene Illustration | Offline-Gesperrt-State in Shop hat kein eigenes visuelles Feedback außer A005 (primär für S021) | ⚠️ |
| Saison-Abgelaufen-State leer | S012-State `Saison-Abgelaufen` hat kein Asset | 🔴 |

---

## Flow 6: Rewarded Ad — Detail

### Flow-Pfad
`S006 (Level-Verloren) → S007 (Verloren-Rewarded-Ad-Angebot) → S016 (Ad-Overlay) → S006 (Extra-Leben) oder S007 (Kein-Reward)`

Alternativ-Trigger:
`S006 (Booster-Aktiv) → S016 (vor Level) → S006`

### Tap-Analyse

| Tap | Screen | Aktion | Erwartetes visuelles Feedback |
|---|---|---|---|
| — | S006 | Level verloren (automatisch) | A018 (Verloren-Illustration) erscheint in S007 |
| Tap 1 | S007 | Rewarded-Ad-CTA antippen | S016 wird als Overlay geladen |
| — | S016 | Ad lädt | A004-Ladeindikator im Ad-Overlay |
| — | S016 | Ad läuft | Vollbild-Ad (Drittanbieter-Content) |
| — | S016 | Ad abgeschlossen | Reward-Animation (A020) |
| Auto | S006 | Extra-Leben aktiv | Booster-Icon A016 aktualisiert, Spielfeld weiter |

### Screen-by-Screen Asset-Check

#### S007 — Level-Ergebnis / Post-Session (Verloren-State mit Ad-Angebot)

| Element | Erwartetes Asset | Asset-ID | Status |
|---|---|---|---|
| Verloren-Illustration | Empathische Verlieren-Illustration | A018 | ✅ |
| Rewarded-Ad-Angebots-CTA-Button | — | — | 🔴 Kein dedizierter Asset für den Ad-Angebots-Button/Banner definiert |
| Reward-Vorschau (was bekomme ich) | Reward-Icons | A020 | ✅ |
| Social-Nudge-Banner (Gewonnen-State) | Social-Nudge-Banner | A067 | ✅ (aber nur Gewonnen-State relevant) |
| Währungsanzeige | A036 | A036 | ✅ |

---

#### S016 — Rewarded Ad Interstitial

| Element | Erwartetes Asset | Asset-ID | Status |
|---|---|---|---|
| Ladeindikator (Ad-Lädt-State) | Loading-Indicator | A004 | ✅ |
| Ad-Fehler-Fallback-Illustration | — | — | 🔴 Kein Asset für Ad-Fehler-State definiert — KI zeigt blanken Screen oder System-Alert |
| Reward-Bestätigungs-Animation (Ad-Abgeschlossen) | Reward-Icons | A020 | ⚠️ A020 ist statisch — Reward-Bestätigungs-Celebration-Animation nicht definiert |
| Kein-Reward-State (Ad übersprungen) | — | — | ⚠️ Kein visueller Feedback-Asset für „kein Reward erhalten" definiert |
| Rahmen/Container des Overlays | — | — | ⚠️ S016 hat keinen eigenen UI-Rahmen-Asset — Overlay wirkt nackt |

---

#### S006 — Spielfeld (nach Rewarded Ad, Extra-Leben aktiv)

| Element | Erwartetes Asset | Asset-ID | Status |
|---|---|---|---|
| Booster-Aktiv-Indikator | Booster-Icons | A016 | ✅ |
| Score-Anzeige weiter | Score-HUD | A015 | ✅ |
| Spielfeld-Wiederherstellungs-Animation | — | — | ⚠️ Kein dedizierter „Extra-Leben erhalten"-Feedback-Asset |

### Flow-6-Konsistenz-Risiken

| Risiko | Beschreibung | Schwere |
|---|---|---|
| Ad-Fehler-State völlig ohne Asset | S016 Ad-Fehler-Fallback hat keine Illustration — wichtigster Fallback im Monetarisierungsflow | 🔴 |
| Rewarded-Ad-CTA auf S007 ohne eigenes Asset | Der Button/Banner der das Angebot kommuniziert ist nicht als Asset definiert | 🔴 |
| Reward-Celebration fehlt | Statische A020-Icons ersetzen keine Celebration-Animation nach Ad-Completion | ⚠️ |
| S016-Overlay ohne eigenen visuellen Rahmen | Overlay hat kein UI-Hintergrund/Container-Asset — erscheint als rohes Ad-Layer | ⚠️ |

---

## Flow 7: Consent Detail — Detail

> **Besonderer Fokus:** Legal-UI Qualität, Consent-Design-Compliance, Age-Gate, Privacy-Badges

### Flow-Pfad
`S001 → S002 (DSGVO + ATT) → [Minderjährig: Hard-Block ODER ATT verweigert: S020] → S003`

### Tap-Analyse

| Tap | Screen | Aktion | Erwartetes visuelles Feedback |
|---|---|---|---|
| — | S001 | Automatischer App-Start | A003-Hintergrund, A002-Logo, A004-Ladebalken |
| Tap 1 | S002 | DSGVO-Zustimmung | iOS: ATT-System-Prompt folgt; Android: direkt weiter |
| Tap 1a (iOS) | S002 | ATT-System-Dialog bestätigen oder ablehnen | OS-Layer (keine App-Kontrolle) |
| Tap 1b (ATT abgelehnt) | S020 | Spielstil-Auswahl als Personalisierungs-Fallback | A048-Auswahlkarten |
| Tap 2 (COPPA-Flow) | S002 | Alterscheck unter Mindestalter | A008-Minderj.-Block-Illustration, Hard-Block |

### Screen-by-Screen Asset-Check

#### S002 — DSGVO / ATT Consent Modal ⚠️ LEGAL-KRITISCH

| Element | Erwartetes Asset | Asset-ID | Status | Legal-Anmerkung |
|---|---|---|---|---|
| Consent-Illustration (thematisch) | Kleine thematische Illustration | A006 | ✅ | Pflicht: senkt Ablehnungsrate |
| ATT-Pre-Permission-Visual (iOS only) | ATT-Erklärungs-Illustration | A007 | ✅ | Pflicht: ohne Illustration +20-30% ATT-Ablehnung wahrscheinlich |
| Minderj.-Block-Illustration | Freundlich-klare COPPA-Block-Illustration | A008 | ✅ | Pflicht: COPPA-konformes Design erforderlich |
| Datenschutz-Link-Styling | — | — | 🔴 Kein Asset für visuell erkennbare Datenschutz/AGB-Link-Buttons definiert |
| Toggle-Switches (Consent-Kategorien) | — | — | 🔴 Kein Asset für Consent-Kategorie-Toggles definiert — KI verwendet System-Toggles ohne Marken-Styling |
| Privacy-Badge / Trust-Signal | — | — | 🔴 Kein Trust-Badge-Asset definiert (z.B. Datenschutz-Siegel, DSGVO-konform-Badge) |
| Alterscheck-Input-Feld-Styling | — | — | ⚠️ Kein gestaltetes Altersauswahl-UI-Asset definiert |
| Android-Normal-State vs. iOS-State visuell unterschiedlich? | A006 hat 2 Varianten | A006 | ⚠️ 2 Varianten vorhanden — iOS-ATT-spezifisches Layout separat sichergestellt? |

**Legal-UI-Tiefen-Analyse S002:**

| Aspekt | Anforderung | Asset-Abdeckung | Status |
|---|---|---|---|
| Opt-In muss gleich prominent wie Opt-Out sein | Buttons visuell gleichwertig | Kein dedizierter Button-Asset | 🔴 |
| Consent muss granular sein (DSGVO Art. 7) | Einzelne Toggle pro Zweck | Kein Toggle-Asset | 🔴 |
| Widerruf muss jederzeit erkennbar sein | Link zu Einstellungen sichtbar | Kein Asset | ⚠️ |
| ATT-Text muss Nutzen erklären (Apple-Pflicht) | A007 erklärt visuell | A007 | ✅ |
| COPPA: Hard-Block muss freundlich sein | A008 definiert | A008 | ✅ |
| Kinder dürfen nicht durch Dark Pattern weitergeführt werden | Keine Weiter-CTA nach Block | Nicht definiert | ⚠️ |

---

#### S020 — Kaltstart-Personalisierungs-Fallback (ATT verweigert)

| Element | Erwartetes Asset | Asset-ID | Status |
|---|---|---|---|
| Auswahlkarten Spielstil | Animierte Auswahlkarten | A048 | ✅ |
| Erklärungstext-Bereich visuell gestaltet | — | — | ⚠️ Kein Illustration-Asset für „Warum fragen wir das?" definiert |
| Ausgewählt-State-Highlight der Karten | A048 Auswahl-getroffen-Variant | A048 | ⚠️ Nur 1 Variante — Ausgewählt-State nicht gesichert |
| Datenschutzhinweis am Bottom | — | — | 🔴 Kein visuell gestalteter Hinweis-Banner für „Diese Auswahl ersetzt kein Tracking" definiert |

---

#### S018 — Einstellungen (Consent-Neu-Angefragt-State)

| Element | Erwartetes Asset | Asset-ID | Status |
|---|---|---|---|
| Consent-Verwaltungs-Bereich | Einstellungs-Kategorie-Icons | A059 | ✅ |
| Haptic-Toggle | Haptic-Toggle-Icon | A058 | ✅ |
| Consent-Neu-Angefragt visuelles Feedback | — | — | 🔴 Kein Asset für „Consent wurde aktualisiert"-Bestätigungs-Banner oder Modal definiert |
| Datenschutz-Link visuell erkennbar | — | — | ⚠️ Kein dediziertes Datenschutz-Link-Styling-Asset |

### Flow-7-Konsistenz-Risiken

| Risiko | Beschreibung | Schwere |
|---|---|---|
| Consent-Toggles ohne Branding | Granulare Consent-Toggles sind DSGVO-Pflicht — KI generiert System-Standard-Toggles | 🔴 LEGAL-BLOCKER |
| Keine Trust-Badges | Fehlende Privacy-Trust-Signale auf Consent-Screen senken Conversion und erzeugen Vertrauensproblem | 🔴 |
| Opt-In/Opt-Out-Buttons visuell nicht definiert | Gleichgewichtiges Button-Design ist regulatorische Pflicht (kein Dark Pattern) | 🔴 LEGAL-BLOCKER |
| ATT-iOS vs. Android Differenzierung ungesichert | 2 Varianten bei A006 aber keine Spezifikation was sich unterscheidet | ⚠️ |
| S020-Datenschutzhinweis fehlt | Ohne Hinweis könnte S020 als Tracking-Ersatz missverstanden werden — potenziell non-compliant | 🔴 |

---

## ⚠️ KI-Entwicklungs-Warnungen (Flows 5–7)

| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|
| W01 | S005 | Battle-Pass-Teaser-Banner | Hochwertiges Saison-Artwork mit Teaser-Energie | Generische Text-Card mit Farbfläche | Kein Asset definiert | Dediziertes `A_BPHomeTeaser`-Asset mit Saison-Artwork erstellen, Variante pro Saison |
| W02 | S012 | Saison-Abgelaufen-State | Illustration die zeigt „nächste Saison kommt" — motivierend | Leerer Screen oder roter Fehler-Text | Kein Asset | `A_SeasonEndIllustration` als eigenes Asset definieren |
| W03 | S012 | Free vs. Premium Tier-Leiste | Klarer visueller Unterschied Premium = Gold/Glanz, Free = grau | Eine Tier-Leiste, Premium einfach farblich anders | A031 (1 Variante) | A031 auf 2 explizite Varianten erweitern: `A031_free` + `A031_premium` mit eigenem Art-Spec |
| W04 | S016 | Ad-Fehler-Fallback | Freundliche Illustration „Leider kein Video verfügbar, versuch es später" | Blanker Screen oder nativer OS-Alert | Kein Asset | `A_AdErrorIllustration` erstellen, Ton: humorvoll, nicht schuldzuweisend |
| W05 | S016 | Reward-Celebration nach Ad | Particle-Explosion oder Screen-Flash wenn Reward erhalten | Statisches Icon kurz angezeigt | A020 statisch | Separate `A_RewardCelebrationAnimation` (Lottie) definieren, 1–1,5s |
| W06 | S016 | Overlay-Container | Semitransparenter gestalteter Rahmen um Ad-Content | Rohes Ad-Fullscreen ohne App-Branding-Rahmen | Kein Asset | `A_AdOverlayFrame` als schlanker Branding-Rahmen mit Close-Button-Area definieren |
| W07 | S007 | Rewarded-Ad-Angebots-CTA | Prominent gestalteter Button „Video schauen → Extra-Leben" | Standard-System-Button ohne emotionale Ladung | Kein Asset | `A_RewardedAdCTA`-Button-Design als eigenes Asset mit Reward-Icon und Puls-Animation |
| W08 | S002 | DSGVO-Consent-Toggles | Gebrandete Toggle-Switches in App-Farbwelt, granular per Kategorie | iOS/Android System-Standard-Toggles in Systemfarbe | Kein Asset | `A_ConsentToggleSet` definieren mit An/Aus-States in Brand-Farben |
| W09 | S002 | Opt-In/Opt-Out-Buttons | Visuell gleichwertig — kein Dark Pattern (DSGVO-Pflicht) | Zustimmen-Button groß + primär, Ablehnen klein + grau | Kein Asset | `A_ConsentButtonPair` mit expliziter Gleichgewichts-Spezifikation, beide gleiche Größe und Sichtbarkeit |
| W10 | S002 | Trust-Badge / Privacy-Signal | Kleines „DSGVO-konform"-Badge oder Datenschutz-Siegel unten | Kein Badge — reiner Textblock | Kein Asset | `A_PrivacyTrustBadge` erstellen, Größe klein, Platzierung Footer des Consent-Modals |
| W11 | S020 | Ausgewählt-State Auswahlkarten | Ausgewählte Karte visuell klar hervorgehoben (Rahmen, Checkmark) | Karte wird vielleicht einfach einfärbt, kein klares Feedback | A048 (1 Variante) | A048 auf 2 Varianten erweitern: `A048_default` + `A048_selected` mit explizitem Checkmark + Rahmen |
| W12 | S020 | Datenschutz-Hinweis-Banner | Sichtbarer Hinweis „Diese Auswahl optimiert dein Spielerlebnis — kein Tracking" | Kein Hinweis — Nutzer könnte S020 als Tracking missverstehen | Kein Asset | `A_PersonalizationDisclaimer`-Banner definieren, Text + visuelles Datenschutz-Icon |
| W13 | S018 | Consent-Aktualisiert-Feedback | Kurze Bestätigung „Datenschutzeinstellungen gespeichert" mit Animation | Toast-Notification ohne Branding oder gar kein Feedback | Kein Asset | `A_ConsentConfirmationToast` definieren, 2s einblenden, nicht-blockierend |

---

## 🔴 Platzhalter-Scan

| # | Screen | Element | Platzhalter-Typ | Risiko | Was stattdessen da sein muss |
|---|---|---|---|---|---|
| P01 | S002 | Consent-Kategorie-Toggles | System-Standard-Toggles (iOS blau / Android grün) | 🔴 Bricht Brand-Konsistenz im ersten rechtlich verpflichtenden Screen | Gebrandete `A_ConsentToggleSet`-Assets in App-Farbwelt |
| P02 | S002 | Datenschutz- und AGB-Links | Unterstrichener Systemlink-Text ohne visuelles Styling | 🔴 Wirkt unfertig, senkt Vertrauen in Legal-Screen | Gestaltete Link-Buttons mit Icon + Brand-Farbe |
| P03 | S002 | Trust-/Privacy-Badge | Fehlend (kein Asset definiert) | 🔴 Keine Trust-Signale auf dem wichtigsten Vertrauens-Screen der App | `A_PrivacyTrustBadge` mit DSGVO-Referenz |
| P04 | S010 | Spieler-Avatare ohne Freunde | Standard-Profilbild-Placeholder (graues Personen-Icon) | 🔴 No-Friends-State zeigt leere Avatar-Slots mit System-Placeholder | `A043`-Placeholder explizit für No-Friends-State stylen + Einladungs-CTA-Illustration |
| P05 | S010 | Coming-Soon Phase-B-Bereiche | Text-Label „Demnächst" ohne Badge-Asset | 🔴 Unfertig wirkende UI in sichtbarem Production-Screen | `A055` Coming-Soon-Badge muss auf allen Phase-B-Platzhaltern aktiv sein |
| P06 | S016 | Ad-Fehler-State | Blanker Screen oder nativer OS-Alert-Dialog | 🔴 Häufiger State im Rewarded-Ad-Flow ohne jede visuelle Behandlung | `A_AdErrorIllustration` — humorvolle Illustration, Retry-CTA |
| P07 | S016 | Overlay-Hintergrundrahmen | Kein Asset — rohes Vollbild-Ad ohne App-Branding-Kontext | 🔴 Nutzer verlässt visuell die App — Desorientierung | `A_AdOverlayFrame` als schlanker Branding-Container mit Close-Button |
| P08 | S012 | Saison-Abgelaufen-State | Leerer Screen oder Text „Saison beendet" | 🔴 Emotionaler Tiefpunkt ohne visuellen Ausblick auf nächste Saison | `A_SeasonEndIllustration` mit motivierendem Teaser für nächste Saison |
| P09 | S011 | Offline-Gesperrt-State | Rote Fehlermeldung oder A005 aus S021 zweckentfremdet | 🔴 S011-Offline braucht eigene Aussage: „Kauf nicht möglich ohne Verbindung" | Dedizierte `A_ShopOfflineIllustration` mit Reconnect-CTA |
| P10 | S017 | Anonymer Auth-Avatar | Generisches Personen-Icon oder Buchstaben-Initialen-Kreis | 🔴 Erster Eindruck des Profils ist das System-Placeholder-Icon | `A043` muss als wirklich gestalteter Character-Avatar implementiert sein, nicht System-Icon |
| P11 | S019 | Gesendet-Danke-State | Leerer Screen nach Submit oder Standard-System-Alert „Gesendet" | 🔴 Kein Danke-Illustration-Asset definiert — Beta-Feedback endet ohne emotionale Bestätigung | Dedizierte `A_FeedbackSentIllustration` — wertschätzende, kurze Danke-Illustration |
| P12 | S021 | Server-Down-State | Gleiche A005-Illustration wie Offline — kein Unterschied visuell | ⚠️ Server-Down und Offline sind verschiedene Zustände — gleiche Illustration suggeriert gleiche Ursache | A005 auf 2 Sub-Varianten aufteilen: `A005_offline` und `A005_serverdown` mit unterschiedlichem Text-CTA |
| P13 | S009 | Alle-Kapitel-Gelesen-State | Leerer Screen oder Text „keine neuen Inhalte" | 🔴 Empty-State ohne Illustration in narrativem Hub zerstört emotionalen Anker | Dedizierte `A_StoryAllReadIllustration` — „mehr kommt bald" mit Teaser-Artwork |
| P14 | S008 | KI-Level-Lädt-State | Spinner ohne thematischen Kontext | ⚠️ A004 ist generischer Loader — im thematischen Level-Map-Kontext wirkt er systemfremd | A004-Variante oder `A_MapLoadingAnimation` mit thematischer Level-Map-Ästhetik |
| P15 | S005 | Push-Notification-Deep-Link-Entry-State | Standard Home Hub ohne kontextuellen Einstiegspunkt | ⚠️ Nutzer kommt per Deep-Link und sieht generic Home — keine visuelle Brücke zur Notification | Dedizierter Context-Banner `A_DeepLinkContextBanner` der die Herkunft kurz bestätigt |

---

### Platzhalter-Scan-Zusammenfassung

| Priorität | Anzahl | Sofortmaßnahme |
|---|---|---|
| 🔴 Blocker (Legal + Brand) | 10 | Vor Soft-Launch beheben — P01, P02, P03, P06, P07, P08, P09, P10, P11, P13 |
| ⚠️ Hoch (UX-Qualität) | 5 | Vor Open-Launch beheben — P04, P05, P12, P14, P15 |
| **Gesamt identifizierte Lücken** | **15** | |

> **Kritischste Einzelstelle:** P01 + P02 + P03 gemeinsam auf S002 — der DSGVO-Consent-Screen ist der erste Berührungspunkt mit dem Nutzer, der rechtliche Verbindlichkeit kommunizieren muss. System-Toggles + unstyled Links + kein Trust-Badge auf diesem Screen sind in Kombination ein **Launch-Blocker mit rechtlichem Risiko**.

---

# Konsistenz, Dark Mode & Accessibility

---

## Dark-Mode-Konsistenz

| Screen | Dark-Mode-Status | Probleme | Betroffene Assets |
|---|---|---|---|
| S001 Splash / Loading | ⚠️ Teilweise | A002 (Splash-Logo) ist als „kontrastsicher" markiert, aber A004 (Ladebalken) als „ja" – Inkonsistenz in Terminologie; `background_dark` (#120D2A) korrekt als Basis, aber nicht explizit dokumentiert | A002, A004 |
| S002 DSGVO / ATT Consent | ⚠️ Unklar | Kein Asset in der Discovery-Liste für diesen Screen explizit aufgeführt. Modaltexte auf `surface_dark` (#1E1540) vs. `surface_light` (#FFFFFF) nicht spezifiziert. Datenschutz-Links (Echo Violet #5B2ECC auf #1E1540) riskant | – |
| S003 Onboarding Match | ✅ Implizit OK | A010 (Spielfeld-Hintergrund) hat Dark-Mode „nein" – korrekt, da `gameplay_bg` (#0E0A24) dediziert. A009 und A013 als „kontrastsicher" markiert. Konsistent. | A009, A010, A013 |
| S004 Narrative Hook | ⚠️ Nicht definiert | Kein Asset explizit als Dark-Mode-tauglich markiert. Story-Assets (Illustrationen, Text-Overlays) ohne Dark-Mode-Variante dokumentiert | – |
| S005 Home Hub | ✅ Gut abgedeckt | A029 (Quest-Card) mit Dark-Mode „ja". Hintergrund `background_dark` (#120D2A) korrekt. Tab-Bar-Elemente nicht explizit in Asset-Liste, aber durch `surface_dark` abgedeckt | A029 |
| S006 Puzzle / Match-3 Spielfeld | ✅ Konsistent | `gameplay_bg` (#0E0A24) dediziert. A014, A015, A016 mit Dark-Mode „ja". A010 und A013 korrekt ohne Dark-Mode-Variante (Single-Purpose-Dark-Background). A066 (Hindernisse) jedoch „nein" – problematisch auf dunklem Spielfeld | A066 |
| S007 Level-Ergebnis | ⚠️ Lücke | A020 (Reward-Icons) nur „kontrastsicher", kein explizites Dark-Mode-Asset. Hintergrund-Behandlung (Modal über Spielfeld oder Hub?) nicht spezifiziert | A020 |
| S008 Level-Map | ⚠️ Teilweise | A022 (Level-Knoten) „kontrastsicher". Map-Hintergrund-Asset nicht in Liste sichtbar – fehlt Dark-Mode-Variante für Progressionspfad-Illustration | A022 |
| S009 Story Hub | ❌ Nicht definiert | Keine Story-Assets in der vorliegenden Liste mit Dark-Mode-Markierung. Kapitel-Karten, Illustration-Thumbnails ohne Spezifikation | – |
| S010 Social Hub | ⚠️ Teilweise | A037 (Avatar-Rahmen) „kontrastsicher", A038 (Challenge-Card) mit Dark-Mode „ja". Leaderboard-Hintergrundbehandlung nicht spezifiziert | A037, A038 |
| S011 Shop | ❌ Kein Dark Mode | A034 (Shop-Karten) explizit „nein", A035 (Foot-in-Door-Highlight) explizit „nein". Shop-Screen hat keine Dark-Mode-Variante – bewusste Entscheidung oder Lücke? Sollte dokumentiert werden | A034, A035 |
| S012 Battle-Pass | ✅ Gut | A031 (Tier-Visualisierung) und A033 (Saison-Timer) mit Dark-Mode „ja". `surface_dark` (#1E1540) als Card-Oberfläche korrekt | A031, A033 |
| S013 Tägliche Quests | ✅ Gut | A029 (Quest-Card) „ja", A033 (Timer) „ja", A030 (Quest-Icons) „kontrastsicher". Konsistent mit `background_dark` | A029, A030, A033 |
| S014 Push Opt-In | ⚠️ Unklar | A063 (Notification-Icon) „kontrastsicher". Modal-Hintergrund und CTA-Buttons nicht explizit für Dark Mode dokumentiert | A063 |
| S015 Social Share Sheet | ⚠️ System-abhängig | Native Share-Sheets folgen OS-Dark-Mode automatisch. Custom-Overlay-Elemente (falls vorhanden) nicht spezifiziert | – |
| S016 Rewarded Ad Interstitial | ❌ Extern | Ad-Content liegt außerhalb des Design-Systems. Eigene Rahmen-UI (Lade-State, Fehler-State) ohne Dark-Mode-Spezifikation | – |
| S017 Profil | ⚠️ Teilweise | A037 (Avatar-Rahmen) „kontrastsicher". Statistik-Cards und Account-UI nicht explizit dokumentiert | A037 |
| S018 Einstellungen | ⚠️ Unklar | Keine Assets direkt referenziert. System-UI-Elemente (Toggle, Lists) sollten auf `surface_dark` (#1E1540) basieren – nicht spezifiziert | – |
| S019 Beta Feedback | ⚠️ Unklar | Formular-Elemente ohne Dark-Mode-Spezifikation. Input-Felder auf `surface_dark` nicht definiert | – |
| S020 Kaltstart Personalisierungs-Fallback | ⚠️ Overlay | Dark-Mode-Behandlung für Overlay-Hintergrund nicht spezifiziert. `background_dark` oder Semi-Transparent? | – |
| S021 Offline Error | ⚠️ Unklar | Keine Assets in Liste. Error-Screen-Farbe (`error` #e74c3c) auf `background_dark` (#120D2A) – Kontrast zu prüfen | – |
| S022 A/B Test Variant Loader | ✅ Transparent | Visuell kein eigener Screen, erbt von darunter liegendem Screen. Kein Dark-Mode-Problem | – |

---

## Accessibility-Check

### Farbkontrast (WCAG AA)

> Ratios sind Schätzwerte auf Basis der relativen Luminanz der Hex-Werte. Formel: Contrast Ratio = (L1 + 0.05) / (L2 + 0.05)

| Element | Vordergrund | Hintergrund | Geschätztes Ratio | Ziel | Status |
|---|---|---|---|---|---|
| Haupttext Light Mode | `text_primary` #1A1333 | `background_light` #F4F0FF | ~14,5 : 1 | ≥ 4,5 : 1 | ✅ AAA |
| Haupttext Dark Mode | `text_primary_dark` #EDE8FF | `background_dark` #120D2A | ~13,8 : 1 | ≥ 4,5 : 1 | ✅ AAA |
| Sekundärtext Light Mode | `text_secondary` #6B5FA6 | `background_light` #F4F0FF | ~4,6 : 1 | ≥ 4,5 : 1 | ✅ AA (knapp) |
| Sekundärtext Dark Mode | `text_secondary_dark` #9B8FCC | `background_dark` #120D2A | ~5,9 : 1 | ≥ 4,5 : 1 | ✅ AA |
| Sekundärtext auf surface_light | `text_secondary` #6B5FA6 | `surface_light` #FFFFFF | ~4,3 : 1 | ≥ 4,5 : 1 | ⚠️ FAIL (knapp unter AA) |
| CTA-Button Label (hell) | `surface_light` #FFFFFF | `Echo Violet` #5B2ECC | ~7,0 : 1 | ≥ 4,5 : 1 | ✅ AA |
| CTA-Button Label (dunkel) | `text_primary_dark` #EDE8FF | `Echo Violet` #5B2ECC | ~6,5 : 1 | ≥ 4,5 : 1 | ✅ AA |
| Echo Violet Link auf background_light | `Echo Violet` #5B2ECC | `background_light` #F4F0FF | ~7,2 : 1 | ≥ 4,5 : 1 | ✅ AA |
| Echo Violet Link auf background_dark | `Echo Violet` #5B2ECC | `background_dark` #120D2A | ~4,1 : 1 | ≥ 4,5 : 1 | ❌ FAIL – Links im Dark Mode nicht lesbar |
| Match Ember auf background_dark | `Match Ember` #FF6B35 | `background_dark` #120D2A | ~5,8 : 1 | ≥ 3 : 1 (UI-Komponente) | ✅ AA |
| Match Ember auf gameplay_bg | `Match Ember` #FF6B35 | `gameplay_bg` #0E0A24 | ~6,2 : 1 | ≥ 3 : 1 | ✅ AA |
| Gold Spark auf background_dark | `Gold Spark` #FFD700 | `background_dark` #120D2A | ~12,4 : 1 | ≥ 3 : 1 | ✅ AAA |
| Gold Spark auf surface_dark | `Gold Spark` #FFD700 | `surface_dark` #1E1540 | ~10,2 : 1 | ≥ 3 : 1 | ✅ AAA |
| Echo Teal auf gameplay_bg | `Echo Teal` #00C9A7 | `gameplay_bg` #0E0A24 | ~8,1 : 1 | ≥ 4,5 : 1 | ✅ AAA |
| Success auf surface_light | `success` #27ae60 | `surface_light` #FFFFFF | ~4,7 : 1 | ≥ 4,5 : 1 | ✅ AA (knapp) |
| Success auf surface_dark | `success` #27ae60 | `surface_dark` #1E1540 | ~5,4 : 1 | ≥ 4,5 : 1 | ✅ AA |
| Warning auf surface_light | `warning` #f39c12 | `surface_light` #FFFFFF | ~2,4 : 1 | ≥ 4,5 : 1 | ❌ FAIL – Warning-Text auf weißen Cards nicht lesbar |
| Warning auf background_dark | `warning` #f39c12 | `background_dark` #120D2A | ~8,5 : 1 | ≥ 4,5 : 1 | ✅ AA |
| Error auf surface_light | `error` #e74c3c | `surface_light` #FFFFFF | ~4,0 : 1 | ≥ 4,5 : 1 | ❌ FAIL – Fehlertext auf weißen Cards unzureichend |
| Error auf background_light | `error` #e74c3c | `background_light` #F4F0FF | ~3,8 : 1 | ≥ 4,5 : 1 | ❌ FAIL – Level-Failed-State im Light Mode problematisch |
| Sekundärtext auf surface_dark | `text_secondary_dark` #9B8FCC | `surface_dark` #1E1540 | ~4,7 : 1 | ≥ 4,5 : 1 | ✅ AA (knapp) |
| Move-Counter (JetBrains Mono) auf gameplay_bg | `text_primary_dark` #EDE8FF | `gameplay_bg` #0E0A24 | ~15,1 : 1 | ≥ 4,5 : 1 | ✅ AAA |
| Score-HUD auf gameplay_bg | `Gold Spark` #FFD700 | `gameplay_bg` #0E0A24 | ~13,0 : 1 | ≥ 4,5 : 1 | ✅ AAA |

> **Kritische Befunde:**
> 1. `Echo Violet` #5B2ECC auf `background_dark` #120D2A: **~4,1:1 – FAIL** → Links und aktive Nav im Dark Mode unterschreiten AA. Empfehlung: Im Dark Mode auf `#7B52E8` oder `#8A6AE8` aufhellen.
> 2. `warning` #f39c12 auf hellen Oberflächen: **~2,4:1 – FAIL** → Move-Counter-Warning und Saison-Timer im Light Mode nicht konform. Empfehlung: Text-Farbe auf `#1A1333` setzen, Warning-Farbe nur für ikonische Akzente nutzen.
> 3. `error` #e74c3c auf `surface_light` / `background_light`: **~3,8–4,0:1 – FAIL** → Level-Failed-Labels, IAP-Fehler im Light Mode. Empfehlung: Auf `#c0392b` abdunkeln (~4,8:1 auf Weiß).
> 4. `text_secondary` #6B5FA6 auf `surface_light` #FFFFFF: **~4,3:1 – FAIL** → Quest-Beschreibungen, Shop-Kartentext knapp unter AA.

---

### Touch-Targets

| Screen | Element | Geschätzte Größe | Minimum | Status |
|---|---|---|---|---|
| S006 Spielfeld | Booster-Icons (A016) – 48x48dp laut Icon-Grid | 48 × 48 dp | iOS 44pt / Android 48dp | ✅ OK (Android), ⚠️ grenzwertig iOS |
| S006 Spielfeld | Spielsteine bei kleinem Grid (≤ 7×7 auf 360dp-Display) | ~48 × 48 dp | 44pt / 48dp | ✅ OK bei 7×7, ❌ bei 8×8+ (~40dp) |
| S006 Spielfeld | Zuege-Anzeige A014 – rein informativ, nicht interaktiv | n/a | n/a | ✅ kein Target |
| S008 Level-Map | Level-Knoten A022 – typisch ~40–44dp in Match-3-Maps | ~40–44 dp | 44pt / 48dp | ⚠️ Risiko unterschreitung auf kleinen Displays |
| S011 Shop | Shop-Karten A034 – Karten typisch ausreichend groß | ~80 × 100 dp geschätzt | 44pt / 48dp | ✅ OK |
| S011 Shop | Kauf-CTA-Button auf Shop-Karten | ~44 × 44 dp minimum empfohlen | 44pt / 48dp | ⚠️ Muss explizit auf ≥ 48dp definiert werden |
| S012 Battle-Pass | Tier-Reward-Items A031 – horizontal scrollbare Tier-Punkte | ~36–40 dp geschätzt | 44pt / 48dp | ❌ Wahrscheinlich zu klein – häufiges Problem in Battle-Pass-UIs |
| S013 Quests | Quest-Claim-Button auf A029-Cards | ~44 dp geschätzt | 44pt / 48dp | ⚠️ Explizit definieren |
| S014 Push Opt-In | Opt-In / Opt-Out CTA-Buttons | ~48 dp Mindest-Empfehlung | 44pt / 48dp | ⚠️ Nicht spezifiziert – Pflicht-Definition |
| S018 Einstellungen | Toggle-Schalter (Haptic, Notifications) | iOS native ~51 × 31pt (Touch-Area ~51×44pt) | 44pt | ✅ iOS-nativ OK |
| S018 Einstellungen | Text-Links (Datenschutz, Consent) | Oft zu klein bei Inline-Links | 44pt / 48dp | ⚠️ Explizite Touch-Area-Definition erforderlich |
| S016 Rewarded Ad | „X"-Schließen-Button nach Ad | Typ. 20–30dp bei Ad-Networks | 44pt / 48dp | ❌ Externe Kontrolle – aber eigene Wrapper-Buttons ≥ 44pt gestalten |
| S002 Consent | Consent-Akzeptieren / Ablehnen-Buttons | Unspezifiziert | 44pt / 48dp | ⚠️ Rechtlich relevante Aktion – muss ≥ 48dp sein |
| S015 Share Sheet | Share-Ziel-Icons (nativ) | OS-kontrolliert | n/a | ✅ System-UI |

> **Kritische Befunde:**
> - Battle-Pass Tier-Items (S012) sind in fast allen Markt-Apps zu klein – explizite Mindestgröße 44pt für interaktive Tier-Elemente definieren.
> - Spielsteine bei 8×8-Grid oder größer auf Displays < 390dp Breite: Touch-Target-Problem. Empfehlung: Grid-Größe an Display-Breite anpassen, Minimum 44pt pro Stein erzwingen.
> - Consent-Buttons (S002) haben rechtliche Relevanz – Gleichwertige Größe für Akzeptieren und Ablehnen ist DSGVO-konform erforderlich (Dark Patterns verboten).

---

### VoiceOver / TalkBack

| Screen | Element ohne Label | Empfohlenes Label |
|---|---|---|
| S006 | Spielsteine A009 (Farb-/Form-Sprites ohne Text) | „[Farbe] [Form]-Stein, Position Reihe [X], Spalte [Y]", z.B. „Violetter Kristall, Reihe 3, Spalte 2" |
| S006 | Spezialsteine A011 (Bombe, Blitz etc.) | „Bomben-Stein, aktiviert 3×3-Explosion, Position Reihe [X], Spalte [Y]" |
| S006 | Booster-Buttons A016 (Icon-only) | „Hammer-Booster – entfernt einzelnen Stein, [Verfügbar / Gesperrt]" |
| S006 | Move-Counter A014 | „Verbleibende Züge: [Zahl]" – als Live-Region bei Änderung ansagen |
| S006 | Score-HUD A015 | „Punktestand: [Zahl]" – als Live-Region |
| S006 | Hindernisse A066 (Eis, Stein, Kette) | „[Typ]-Hindernis, benötigt [X] Treffer, Position Reihe [X], Spalte [Y]" |
| S007 | Reward-Icons A020 (ohne Text) | „[Menge] [Währungsname], z.B. „50 Münzen erhalten" |
| S008 | Level-Knoten A022 (gesperrt/offen/abgeschlossen) | „Level [Nummer], [Status: gesperrt / verfügbar / abgeschlossen mit [Sterne]-Sternen]" |
| S008 | Level-Map-Hintergrund (dekorativ) | `aria-hidden="true"` / `accessibilityElementsHidden` – rein dekorativ |
| S010 | Avatar-Rahmen A037 (Seltenheits-Indikator) | „[Spielername], [Rahmen-Seltenheit]-Rahmen, z.B. „Selten" |
| S010 | Challenge-Card A038 | „Herausforderung von [Spielername]: [Beschreibung], [Annehmen / Ablehnen]-Buttons" |
| S011 | Shop-Karten A034 (Preis + Produkt als Bild) | „[Produktname], [Inhalt], Preis: [Betrag], Kaufen-Button" |
| S011 | Foot-in-Door-Highlight A035 (animiertes Badge) | „Sonderangebot: [Prozent] Rabatt, zeitlich begrenzt" |
| S012 | Battle-Pass-Tiers A031 (visuelle Tier-Punkte) | „Stufe [X]: [Reward-Beschreibung], [gesperrt / verfügbar / erhalten]" |
| S012 | Saison-Timer A033 | „Saison endet in: [X Tage, Y Stunden]" – als Live-Region bei kritischer Grenze |
| S013 | Quest-Icons A030 (Icon-only) | „[Quest-Typ]-Quest, z.B. „Kampf-Quest" |
| S001 | Ladebalken A004 | „App wird geladen, [Prozent]%" – progressiveUpdate als Accessibility-Announcement |
| S002 | Consent-Checkboxen / Toggle | „[Consent-Typ] Zustimmung, [aktiviert / deaktiviert], erforderlich / optional" |
| S014 | Illustration / Mascot (dekorativ) | `accessibilityElementsHidden = true` |
| A001 | App-Icon (Home Screen) | iOS/Android verwalten automatisch, kein Custom-Label nötig |
| S009 | Story-Kapitel-Thumbnails | „Kapitel [X]: [Titel], [gelesen / neu / gesperrt]" |
| S017 | Avatar-Bild (Spielerprofil) | „Profilbild von [Spielername]" oder „Profilbild, ändern"-Button wenn interaktiv |
| S019 | Rating-Icons (Sterne) | „[X] von 5 Sternen, ausgewählt" – Sternebewertung als Gruppe |

---

### Reduced Motion

| Animation | Screen | Statischer Fallback | Status |
|---|---|---|---|
| Ladebalken-Animation A004 | S001, S006, S011 | Statischer Fortschrittsbalken mit Prozent-Text | ✅ Laut Stil-Guide „Static Fallback: Ja" – aber Screen-spezifisch dokumentieren |
| Spielstein-Match-Explosion A009 | S003, S006 | Direktes Entfernen + Echo Teal #00C9A7 Farb-Flash auf Zelle | ⚠️ Nicht explizit dokumentiert |
| Spezialstein-Aktivierungs-Animation A011 | S006 | Statischer Highlight-Rahmen + Farbwechsel ohne Bewegung | ⚠️ Fehlt in Asset-Dokumentation |
| Score-Zuwachs-Animation A015 (Zahl rollt hoch) | S006 | Direkter Zahlenwechsel ohne Rollanimation | ⚠️ Nicht dokumentiert |
| Level-Knoten-Freischaltung A022 | S008 | Direkter Zustandswechsel: Schloss → offenes Icon ohne Bounce | ⚠️ Fehlt |
| Battle-Pass-Tier-Claim-Animation A031 | S012 | Statisches Reward-Icon mit Echo Teal Checkmark, kein Konfetti | ⚠️ Fehlt |
| Foot-in-Door-Pulsieren/Glühen A035 | S011 | Statisches Highlight-Styling ohne Pulse-Effekt | ⚠️ Fehlt |
| Saison-Timer-Countdown A033 | S012, S013 | Statische Textanzeige der Restzeit ohne visuelle Puls-Dringlichkeit | ⚠️ Fehlt |
| Challenge-Card-Einflug A038 | S010 | Direktes Erscheinen ohne Slide-Animation | ⚠️ Fehlt |
| Quest-Card-Fortschrittsbalken A029 | S005, S013 | Statischer Balken ohne Füll-Animation | ⚠️ Fehlt |
| Narrative-Hook-Sequenz-Transitions | S004 | Statische Bild-Sequenz ohne Übergangseffekte (Einfaches Bild mit CTA) | ❌ Nicht definiert – Screen existiert als reine Animation |
| Onboarding-Hint-Animation | S003 | Statischer Pfeil-Indikator ohne Bounce | ⚠️ Fehlt |
| App-Icon-Lottie (falls animiert) | S001 | PNG-Fallback A001 | ✅ Lottie-Budget 500KB + Static Fallback definiert |

> **Systemempfehlung:** `prefers-reduced-motion` (Flutter: `MediaQuery.disableAnimations`, iOS: `UIAccessibility.isReduceMotionEnabled`) global abfragen und einen `AnimationController`-Wrapper implementieren, der alle Lottie- und Custom-Animationen auf 0ms-Dauer oder statischen Endzustand setzt. Aktuell fehlt diese Infrastruktur in der Dokumentation vollständig.

---

## Stil-Konsistenz über alle Screens

| Kriterium | Status | Anmerkung |
|---|---|---|
| Farbschema einheitlich | ⚠️ Überwiegend konsistent, 3 kritische Lücken | Echo Violet auf `background_dark` unterschreitet WCAG AA; `warning` und `error` auf hellen Surfaces inkonsistent einsetzbar; Shop (S011) bewusst ohne Dark Mode – muss im Stil-Guide als Ausnahme explizit dokumentiert werden, nicht implizit |
| Icon-Stil konsistent | ✅ Gut definiert | Phosphor-Icons-Basis mit 3px corner-radius, Filled-Style durchgängig. Kritisch: 4 Icon-Grid-Größen (20/24/48/96dp) sind sauber definiert – sicherstellen dass keine weiteren Ad-hoc-Größen eingeführt werden |
| Layout-System konsistent | ⚠️ Teilweise definiert | Kein explizites Grid-System (8dp-Grid?) im Stil-Guide dokumentiert. Card-Surfaces (`surface_light` / `surface_dark`) einheitlich, aber Abstände, Padding und Eckenradien nicht spezifiziert – Risiko für inkonsistente Umsetzung bei mehreren Entwicklern |
| Animations-Sprache einheitlich | ⚠️ Definiert, aber lückenhaft | 280ms + cubic-bezier(0.34, 1.56, 0.64, 1) (leichter Bounce) sind gut gewählt für Casual-Game-Feeling. Problem: Bounce-Easing ist für Reduced Motion und für subtile UI-Übergänge (Fehler-Zustände, Offline-Screens) ungeeignet – zweite Easing-Kurve für „serious states" (error, warning, offline) empfohlen |
| Typografie konsistent | ✅ Sehr gut definiert | Drei-Font-Strategie (Nunito/Inter/JetBrains Mono) mit klaren Verwendungsregeln ist professionell und verhindert Font-Chaos. Gewichtsbereiche (700-800 / 400-500 / 500-600) sind sauber. Fehlend: Schriftgrößen-Scale (z.B. 12/14/16/20/24/32dp) noch nicht definiert |
| Zielgruppen-Passung (18–34) | ✅ Stark | 2.5D Casual Cartoon + Dark-Mode-First + Lottie-Animationen treffen den Erwartungsraum der Zielgruppe präzise. `gameplay_bg` #0E0A24 erzeugt „premium dark gaming"-Atmosphäre. Gold Spark und Match Ember sind emotional aktivierend. Einziges Risiko: Wenn Shop (S011) ohne Dark Mode bleibt, wirkt er „herausgerissen" aus der App-Atmosphäre |
| Illustration-Stil Screen-übergreifend | ⚠️ Risiko bei AI-Generierung | A009 (Spielsteine) via Midjourney + Figma – KI-generierte Assets haben Tendenz zu stilistischen Inkonsistenzen. Expliziter Style-Reference-Prozess (Seed-Images, Style-Tokens) für alle AI-generierten Assets notwendig, damit 2.5D-Cartoon-Stil screen-übergreifend konsistent bleibt |
| Zustandsdesign (States) vollständig | ⚠️ Lücken | Screen-Architektur definiert States sehr detailliert (z.B. S006 mit 8 States). Asset-Discovery bildet diese States nicht vollständig ab – z.B. fehlen explizite Assets für `Level-Failed-State`, `Offline-Fallback-State` und `KI-Level-Latenz-State` in der Asset-Liste |
| DSGVO / Compliance-Design | ⚠️ Strukturell vorhanden, visuell unvollständig | S002 und S018 adressieren Consent korrekt. Visuell fehlen aber Assets für Consent-Verwaltung und explizite „Ablehnen"-Pfade, die gemäß DSGVO gleichwertig zu „Akzeptieren" gestaltet sein müssen (keine Dark Patterns durch visuelle Hierarchie) |