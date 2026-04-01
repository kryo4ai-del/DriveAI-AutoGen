# Design-Vision-Dokument: GrowMeldAI
## Version: 1.0
## Status: VERBINDLICH für alle nachfolgenden Pipeline-Schritte

---

## Design-Briefing (wird in jeden Produktions-Prompt injiziert)

GrowMeldAI ist ein botanisches Diagnosewerkzeug, das sich visuell und emotional wie ein lebendig gewordener Wissenschaftsatlas des 18. Jahrhunderts anfühlt — präzise, warm und nie beliebig. Die gesamte App basiert auf einem proprietären Kupferstich-Illustrationssystem: dünne Linien (0.5–1.5px) in tiefem Tinte-Schwarz (#1A1208) auf warmem Pergament-Elfenbein (#F5EDD6), ergänzt durch eine serifenbetonte Primärtypografie (GFS Didot / Didot-Equivalent) für botanische Namen und Schlüsselinformationen. Es gibt **keinen weißen Hintergrund, keine salbeigrünen Flächen, keine Bottom-Tab-Bar, kein Konfetti**. Navigation erfolgt ausschließlich über Swipe-Gesten. Animationen sind organisch-langsam und folgen botanischen Wachstumsmetaphern — kein Bounce, kein Fade-Generic, keine spinnenden Lader. Der Scanner-Screen zeigt sichtbare KI-Analyse als sich langsam vollendende Kupferstich-Zeichnung über der Pflanze, nicht als pulsierender Kreis. Der Pflegeplan-Reveal ist der emotionale Höhepunkt der App: er erscheint wie ein sich öffnender Briefumschlag, zeigt eine Kupferstich-Zeitlinie der nächsten 7 Pflegetage und beweist durch kontextuelle Wetterdaten, dass die App wirklich denkt. Die App fühlt sich an wie ein ruhiger Sonntagmorgen mit einem alten Botanikbuch — Energie-Level 4/10, nie laut, nie drängerisch, immer präzise und bedeutsam.

---

## Teil 1: Verbindliche Vorgaben

### 1.1 Emotionale Leitlinie

- **Gesamt-Emotion:** Das Gefühl des ersten neuen Triebs an einer Pflanze, die man fast aufgegeben hatte — stille Freude, Kompetenz, Geborgenheit
- **Energie-Level:** 4/10 — ruhig, aber nie still. Kein Wellness-App-Schläfrigkeit, sondern konzentrierte botanische Aufmerksamkeit
- **Visuelle Temperatur:** Organisch-warm mit wissenschaftlicher Präzision. Pergament-Töne, Kupferstich-Linien, Momente echter Wärme — niemals das erwartbare „Salbeigrün trifft Lifestyle-Wellness"

---

### 1.2 Emotion pro App-Bereich (PFLICHT)

| Bereich | Emotion | Energie | Beschreibung |
|---|---|---|---|
| **Splash / Loading** | Erwartungsvolle Stille | 2/10 | Eine einzelne botanische Ranke wächst langsam aus einem Punkt heraus. Der Nutzer schaut zu — kein Interaktions-Druck. Die App keimت. |
| **Onboarding** | Neugier + Einladung | 5/10 | Keine Erklär-Slides. Sofort Kamera-Aufforderung: *„Was wächst bei dir?"* — der Nutzer ist Entdecker, nicht Tutorial-Empfänger. |
| **Kamera-Permission** | Transparenz ohne Bürokratie | 3/10 | Pergament-Modal das sich aufrollt. Kurzer, ehrlicher Text. DSGVO als aufklappbares Blatt, nicht als Rechtsblock. |
| **Scanner** | Konzentration + Magie | 6/10 | Höchste Energie der App — kurze Spannung während die Kupferstich-Linien die Pflanze nachzeichnen, dann Auflösung in Ruhe. |
| **Pflanzenprofil-Erstellung** | Fürsorge-Ritual | 4/10 | Eine Frage pro Screen, persönlich formuliert. Fortschrittsbalken als wachsende Pflanze. Das Einzug-Geben einer Pflanze in das eigene Leben. |
| **Pflegeplan-Reveal** | Staunen + Geborgenheit | 5/10 | Emotionaler Peak der App. Briefumschlag-Öffnung, Kupferstich-Zeitlinie, Wetterdaten-Beweis — „Jemand denkt wirklich mit." |
| **Push-Permission** | Vertrauen (bereits verdient) | 3/10 | Erscheint erst nach 2s Sichtzeit des Pflegeplans. Fragt als Person: *„Soll ich dich erinnern?"* — kein System-Alert-Klon. |
| **Core Loop (Pflege-Check)** | Fürsorge + Kompetenz | 3/10 | Ruhiges Gefühl von Kontrolle über ein lebendiges System. Keine Gamification-Hektik. Bestätigung statt Druck. |
| **Reward / Erledigt** | Stiller Stolz | 2/10 | Kein Konfetti. Das tiefe, ruhige Gefühl einer gut gemachten Sache. Wie wenn Erde Wasser annimmt. |
| **Home-Dashboard** | Guten-Morgen-Ruhe | 3/10 | Ruhige Übersicht, alles im Blick, nichts drängt sich auf. Stille als aktives Design-Element. |
| **Monetarisierung / Paywall** | Vertrauen + Fairness | 2/10 | Kein Druck, kein durchgestrichener Preis als erster visueller Eindruck. Neugier auf Mehr von jemandem, dem man bereits vertraut. |
| **Profil / Einstellungen** | Kontrolle + Ruhe | 1/10 | Kleines, aufgeräumtes Büro. Alles da, nichts drängt. Tiefster Energie-Punkt der App. |

---

### 1.3 Differenzierungspunkte (PFLICHT)

| # | Differenzierung | Beschreibung | Betroffene Screens | Status |
|---|---|---|---|---|
| **D01** | **Botanisches Kupferstich-Illustrationssystem** | Kein Foto in Card, kein Salbei-Vektor. Jede Pflanze bekommt eine SVG-Kupferstich-Illustration mit botanischen Beschriftungslinien. Hintergrundfarbe durchgehend Pergament-Elfenbein `#F5EDD6`. Linienfarbe Tinte-Schwarz `#1A1208`, Linienstärke 0.5–1.5px. Diese Illustrationen sind das Interface, nicht Dekoration. | Alle Screens, besonders Pflanzenprofil, Scanner-Overlay, Onboarding | **VERBINDLICH** |
| **D02** | **Serifenbetonte Typografie-Dominanz** | Botanische Lateinnamen in GFS Didot (oder Didot-Equivalent via Custom Font), 72px Heavy, als Hero-Element des Pflanzenprofils. Schafft sofortige Premium-Bildsprache und unterscheidet jeden Screenshot von jedem Wettbewerber. SF Pro / Roboto / „Nature Fonts" sind verboten. | Pflanzenprofil, Scan-Ergebnis, Onboarding-Headline | **VERBINDLICH** |
| **D03** | **Lebendige Scanner-KI-Visualisierung** | Der Scan-Moment zeigt sich langsam vollendende Kupferstich-Linien die Blattadern und Umrisse nachzeichnen — keine blau-glühende KI-Visualisierung, kein pulsierender Rahmen. States: vollständige Linien = hohe Konfidenz, gestrichelte Linien = niedrige Konfidenz. Sepia-Überlagerung bei Scan-Limit. | Scanner-Screen (S004) | **VERBINDLICH** |
| **D04** | **Gesture-First Navigation ohne Bottom-Tab-Bar** | Keine Tab-Bar. Swipe-Navigation zwischen den Hauptbereichen (Scanner ↔ Pflanzengarten ↔ Kalender). Die Geste ist die Metapher für das Blättern durch einen Garten. Drag-to-open-Sidebar für sekundäre Navigation. | Alle Screens | **VERBINDLICH** |
| **D05** | **Pflegeplan als emotionaler Briefumschlag-Reveal** | Der Pflegeplan erscheint nicht als Liste. Panel öffnet sich von unten wie ein Briefumschlag. Vertikale Kupferstich-Zeitlinie (7 Tage) mit sich füllenden Symbolen (Wassertropfen, Sonne, Schaufel). Wetterdaten-Kontext als typografisch hervorgehobener Aha-Satz. | Pflegeplan-Reveal (S006) | **VERBINDLICH** |
| **D06** | **Wachsendes Pflanzenstängel-Fortschrittssystem** | Kein linearer Fortschrittsbalken. Eine Pflanzenstängel-Illustration treibt pro abgeschlossenem Schritt ein neues Blatt aus — Schritt 1: Keimling, Schritt 2: erstes Blatt, Schritt 3: vollständige Pflanze. Gilt für Onboarding-Flow und alle mehrstufigen Flows. | Profilerstellungs-Flow (S005), Onboarding | **VERBINDLICH** |
| **D07** | **Dynamic Island — lebende Pflanzenstatus-Anzeige** | Die Pflanze im Dynamic Island welkt sichtbar wenn Gieß-Termin überfällig ist (tropfende Linie), blüht auf wenn Pflege aktuell. Live Activity für iOS 16+. TikTok-viraler Moment: 2-Sekunden-Clip des welkenden Dynamic-Island-Symbols. | iOS Dynamic Island / Live Activity | **VERBINDLICH für iOS, Android-Alternative: Persistent Notification mit botanischer Illustration** |

---

### 1.4 Anti-Standard-Regeln (VERBOTE)

| # | VERBOTEN | STATTDESSEN | Betroffene Screens | Begründung |
|---|---|---|---|---|
| **A01** | Weißer (`#FFFFFF`) oder hellgrauer Hintergrund | Pergament-Elfenbein `#F5EDD6` als Basis-Hintergrundfarbe, `#1A1208` als Text/Linien-Farbe | **ALLE Screens** | Weißer Hintergrund ist der generische KI-Default für Pflanzenpflege-Apps — sofortige visuelle Beliebigkeit |
| **A02** | Grün als Primärfarbe (Salbei, Smaragd, Minze in jeder Form) | Warmtöne der Kupferstich-Palette: Elfenbein, Tinte-Schwarz, Terrakotta-Akzent `#8B4513` für Calls-to-Action, botanisches Dunkelgrün `#2D4A1E` nur als sparsamer Sekundär-Akzent (max. 10% Flächenanteil) | **ALLE Screens** | Alle 6 Wettbewerber lösen Natur-Palette mit Grün — GrowMeldAI differenziert durch wissenschaftliche Bibliotheks-Ästhetik statt Garten-Center-Ästhetik |
| **A03** | Bottom-Tab-Bar mit 4–5 Icons | Swipe-Gesture-Navigation + Drag-to-open-Sidebar. Keine persistente Tab-Leiste sichtbar | **ALLE Screens** | Bottom-Tab-Bar ist das universelle „ich habe nicht über Navigation nachgedacht"-Signal; Geste als Garten-Blättern-Metapher ist konzeptuell kohärent |
| **A04** | Konfetti-Animation oder grüner Checkmark als Reward | Organische botanische Partikel-Animation: Blütenblätter expandieren aus Pflanzenmitte (300ms ease-out, cubic-bezier(0.25, 0.46, 0.45, 0.94)), wissenschaftliche Herbarium-Labels erscheinen sequenziell mit 80ms Versatz | Reward-Screens, Scan-Ergebnis | Konfetti ist das universelle „Utility-App hat kein eigenes Reward-System"-Signal; identisch in jeder Kategorie |
| **A05** | Pulsierender Rahmen / blau-glühende KI-Visualisierung im Scanner | Kupferstich-Linien die sich langsam über Blattadern und Umrisse legen (SVG path animation, `stroke-dashoffset` von 100% → 0% über 1.8s) | Scanner-Screen (S004) | Pulsierender Rahmen ist direkter Clone des generischen „AI Scanner" UI-Patterns — alle Wettbewerber identisch |
| **A06** | Serifenlose Systemschriften (SF Pro, Roboto) als Primärtypografie | GFS Didot (Google Fonts, kostenlos) oder äquivalente Didot-Serif als Primärtypografie für Headlines, botanische Namen, Schlüsselaussagen. Sans-Serif (Inter oder Equivalent) nur für Fließtext unter 14px | **ALLE Screens** | Systemschriften kommunizieren „keine typografische Entscheidung getroffen" — Didot-Serif ist sofort erkennbar und kommuniziert wissenschaftliche Ernsthaftigkeit |
| **A07** | Standard-Paywall-Screen (3 Bullet-Punkte, durchgestrichener Preis, grüner CTA) | Paywall als Kupferstich-„Bibliotheks-Mitgliedschaft": visuell eine alte Institutionskarte, botanische Illustration, warme Formulierung *„Erweitere dein Herbar"* statt Feature-Liste | Paywall / Monetarisierungs-Screen | Generische Paywalls brechen die emotionale Konsistenz — Vertrauen wird durch Design-Konsistenz aufgebaut, nicht durch Marketing-Templates |
| **A08** | Swipe-Onboarding mit Feature-Erklärungsslides | Direkt Kamera als erster Screen. Einzige Headline: *„Was wächst bei dir?"* — kein Feature-Grid, kein App-Name im ersten Frame, keine Registrierung vor erstem Scan | Onboarding (S001–S002) | Feature-Erklärungsslides signalisieren, dass die App nicht vertraut, dass ihr Produkt für sich spricht |

---

### 1.5 Wow-Momente (PFLICHT-IMPLEMENTIERUNG)

| # | Name | Screen | Was passiert (exakt) | Warum kritisch |
|---|---|---|---|---|
| **W01** | **Die lebendige Kupferstich-Erkennung** | S004 Scanner | Sobald Pflanze im Kamerabild erkannt: SVG-Pfadanimation legt Kupferstich-Linien über Blattadern und Umrisse. Animation: `stroke-dashoffset` 100%→0%, Dauer 1.8s, ease-in-out. Mehrere Pfade starten mit 150ms Versatz für organischen Effekt. Niedrige Konfidenz = Linien gestrichelt (dasharray sichtbar). Kein UI-Chrome während dieser Animation. | Dies ist der TikTok-Moment. Niemand macht das. Screenshots und Screen-Recordings dieses Moments sind von alleine teilbar. Differenziert GrowMeldAI in 3 Sekunden von allen Wettbewerbern. |
| **W02** | **Der Briefumschlag-Pflegeplan** | S006 Pflegeplan-Reveal | Panel öffnet sich von unten (450ms, cubic-bezier(0.34, 1.56, 0.64, 1) — leichter Overshoot für organisches Gefühl). Kupferstich-Symbole (Wassertropfen, Sonne, Schaufel) füllen sich sequenziell von unten wie Thermometer (je 200ms, 100ms Versatz). Wetter-Satz erscheint zuletzt, 600ms nach Reveal-Start, 20px größer als Umgebungstext. 2-Ton Gitarren-Akkord (unter 1s) beim Panel-Erscheinen, dann Stille. | Dies ist der Aha-Moment der App — der Moment in dem der Nutzer versteht, dass GrowMeldAI wirklich denkt. Dieser Moment entscheidet über Subscription-Intent und App-Weiterempfehlung. Darf unter keinen Umständen als Liste gerendert werden. |
| **W03** | **Der wachsende Onboarding-Stängel** | S005 Profilerstellungs-Flow | Statt Fortschrittsbalken: eine SVG-Pflanzenstängel-Illustration (`#2D4A1E` auf `#F5EDD6`). Nach jedem abgeschlossenen Schritt: neues Blatt wächst aus (path morph animation, 400ms ease-out). Schritt 1: Keimling (2cm). Schritt 2: +1 Blatt. Schritt 3: vollständige kleine Pflanze mit Blüte. Haptik bei jedem Blatt-Erscheinen: ein weiches, tiefes `UIImpactFeedbackGenerator(.soft)`. | Pflanzenwachstum als direkte Metapher für Fortschritt ist einzigartig kohärent mit dem Produkt. Macht einen funktionalen Fortschrittsindikator zu einem emotionalen Produkt-Statement. Screenshots-worthy für App-Store-Previews. |
| **W04** | **Dynamic Island — die welkende Pflanze** | iOS Dynamic Island / Live Activity | Live Activity zeigt miniaturisierte botanische Linienpflanze. Bei überfälligem Gieß-Termin: Pflanzenlinie „droopt" über 30-Minuten-Periode (interpolierte SVG-Pfad-Transformation, subtil — nicht dramatisch). Bei frisch gegossener Pflanze: Linie richtet sich auf und ein Blatt erscheint (300ms). | Viral-Hebel Nr. 1. Jeder 2-Sekunden-Clip dieses Moments auf TikTok ist kostenlose Verbreitung. Existiert in keiner anderen Pflanzenpflege-App. Beweist, dass GrowMeldAI über Standard-App-Denken hinausgeht. |
| **W05** | **Der Splash-Screen-Keimling** | S001 Splash | App-Logo entfaltet sich als einzelne botanische Ranke aus einem Punkt: SVG path-drawing-Animation, organisch-langsam (1.2–3.0s je nach Ladezeit). Keine Bounce, kein Overshoot — echtes organisches Tempo (ease-in-out mit leichter Verlangsamung am Ende). Bei schnellem Laden: Ranke blüht kurz auf (Blüte erscheint, 400ms). Hintergrundfarbe sofort `#F5EDD6` — der erste Frame der App ist nie weiß. Einziger Sound: organisches Knistern unter 0.3s (wie Buchaufschlagen). | First Impression ist irreversibel. Der erste Frame kommuniziert das gesamte Design-Versprechen: Wärme, Botanik, Präzision. Kein weißer Flash, kein generischer Ladescreen — sofortige Marken-Identität. |

---

### 1.6 Interaktions-Prinzipien (PFLICHT)

**Touch-Reaktion:**
Alle interaktiven Elemente reagieren auf Touch mit botanisch-organischer Haptik:
- Standard-Tap: `UIImpactFeedbackGenerator(.light)` — keinen harten Klick, ein weiches Antippen
- Auswahl / Bestätigung: `UIImpactFeedbackGenerator(.soft)` — tiefes, weiches Puls-Gefühl
- Wichtige Aktionen (Kamera öffnen, Plan bestätigen): einmaliger klarer `UIImpactFeedbackGenerator(.medium)` Puls — nie repetitiv
- Auswahl-Karten im Profilierungsflow: Force-Touch / Long-Press löst Vertiefungs-Animation aus (`scaleX(0.97) scaleY(0.97)`, 150ms ease-in), `UIImpactFeedbackGenerator(.soft)` beim Nachgeben
- Verboten: `UINotificationFeedbackGenerator(.error)` als erstes Feedback-Signal — Fehler werden visuell kommuniziert, nicht erschreckend vibriert

**Animations-Prinzip:**
Alle Animationen folgen der Wachstumsmetapher — organisch, nie mechanisch:
- Primäre Kurve: `cubic-bezier(0.25, 0.46, 0.45, 0.94)` — ease-out-organisch
- Reveal-Animationen (Panels, Modals): leichter Overshoot `cubic-bezier(0.34, 1.56, 0.64, 1)` — wie eine Pflanze die kurz über ihre Zielposition hinausschießt
- Keine Bounce-Animationen im Spring-Physics-Sinn — Overshoot max. 4% der Zielgröße
- Keine linearen Animationen außer für rein technische Loading-Indikatoren
- Kupferstich-Linien-Animationen: `stroke-dashoffset`-basiert, immer ease-in-out, Dauer 1.5–2.0s
- Transitions zwischen Screens: horizontaler Wisch-Übergang mit Parallax (Hintergrundebene 60% Geschwindigkeit der Vordergrundebene) — kein generischer Push/Fade
- Mindest-Animationsdauer: 120ms. Maximum für nicht-interaktive Animationen: 2.0s

**Feedback-Prinzip:**
- Jede Nutzaktion erhält Feedback innerhalb von 80ms — visuell, haptisch oder beides
- Fehler-States werden durch visuelle Degradation kommuniziert (gestrichelte Linien, Sepia-Überlagerung), nicht durch Rot-Färbung oder Alert-Dialoge
- Konfidenz-Kommunikation im Scanner ausschließlich über Linienvollständigkeit (gestrichelt = unsicher, durchgehend = sicher) — kein Prozentwert, kein Text-Label
- Leere States zeigen botanische Kupferstich-Illustrationen mit einer einzigen einladenden Frage — keine „Noch keine Pflanzen hinzugefügt"-Texte
- Alle primären CTA-Buttons pulsieren **einmal** sanft beim ersten Erscheinen (`scaleX(1.0)→scaleX(1.03)→scaleX(1.0)`, 600ms) — nie repetitiv, nie mehr als einmal pro Session

**Sound-Prinzip:**
- Alle Sounds sind organisch — keine Synthesizer, keine digitalen Beep-Töne
- Sound-Palette: Buchaufschlagen/Papierrascheln (0.1–0.3s), Gitarren-Akkord-Geste (unter 1.0s), helles Glöckchen (unter 0.5s, nur für positive Bestätigungen)
- Lautstärke: maximal 40% des System-Volumes — niemals aufdringlich
- Jeder Sound ist opt-in über iOS/Android-Stummschalter respektiert — kein Sound erzwingt sich
- Keine Hintergrundmusik, kein kontinuierlicher Ambient-Sound außer dem gedämpften Blätter-Rauschen im aktiven Scanner (unter System-Audio, Kopfhörer-wahrnehmbar)
- Sound-Konsistenz: das „Buchaufschlagen"-Geräusch ist die Audio-Signatur der App — erscheint bei Splash, Onboarding-Kamera-Tap und Profilerstellungs-Übergängen in konsistenten Tonhöhen-Variationen

---

### 1.7 Konflikte aufgelöst

| Konflikt | 17a wollte | Tech-Realität / Einschränkung | Lösung |
|---|---|---|---|
| **Kupferstich-Illustrationen für alle Pflanzen** | Eine dedizierte Kupferstich-SVG-Illustration pro Pflanze im Katalog (potenziell tausende Pflanzen) | Tausende Hand-Kupferstich-SVGs sind produktionstechnisch nicht skalierbar. Asset-Größe und Erstellungsaufwand prohibitiv. | **Zwei-Ebenen-System:** (1) Top-100 Pflanzen erhalten dedizierte Kupferstich-SVGs (Hand-crafted oder Illustrator-Workflow). (2) Alle anderen Pflanzen erhalten ein **generatives Kupferstich-System**: ein parametrisches Flutter-Widget das Blattform-Daten aus der Botanik-API nutzt um prozedurale Kupferstich-Linien zu rendern (`CustomPainter`, thin strokes). Qualitativ unterschiedlich aber visuell kohärent. Kein Foto-Fallback unter keinen Umständen. |
| **GFS Didot als Custom Font** | GFS Didot (Google Fonts) als primäre Serif-Schrift | GFS Didot ist im Google Fonts Flutter-Package vorhanden, aber Gewichtungs-Varianten limitiert. Heavy-Weight möglicherweise nicht verfügbar. | **Primär:** GFS Didot via `google_fonts` Package (Flutter). **Fallback bei fehlendem Heavy-Weight:** LibreCaslon (Google Fonts, vollständige Gewichtungs-Palette) oder EB Garamond (Heavy-Simulation via `fontWeight: FontWeight.w900`). Kein Fallback auf serifenlose Schrift erlaubt. |
| **Kupferstich-Linien-Scanner-Animation auf Android** | SVG `stroke-dashoffset`-Animation für Scanner-Overlay | Flutter `AnimatedBuilder` auf Android mit komplexen SVG-Paths kann Performance-Issues bei 60fps erzeugen, insbesondere auf Mid-Range-Android-Geräten | **Lösung:** `flutter_svg` Package für statische SVG-Darstellung. Animation via `CustomPainter` mit `canvas.drawPath()` und progressivem Path-Building in `AnimationController` (0.0→1.0). Performance-Test-Schwellenwert: muss auf Pixel 6a (Mid-Range-Referenzgerät) stabil 60fps liefern. Wenn nicht: Animation-Komplexität reduzieren (weniger parallele Paths), aber visuelles Prinzip bleibt erhalten. Kein Fallback auf pulsierenden Rahmen. |
| **Dynamic Island für iOS / Android-Parität** | Dynamic Island lebende Pflanze als Pflicht-Feature | Android hat kein Dynamic Island. Flutter-Dynamic-Island-Support nur via nativen iOS-Platform-Channels (Swift/Objective-C), kein Cross-Platform-Package ausgereift. | **iOS:** Native Swift Live Activity + Dynamic Island Integration via Platform Channel. Separates iOS-Widget-Target. **Android-Parität:** Persistent Notification mit botanischer Kupferstich-Illustration im Large-Format (Android 12+ Notification Styles). Zusätzlich: Android-Widget (4x1 Homescreen) mit welkender Pflanzen-SVG-Animation via `Glance API`. Funktional equivalent, visuell angepasst. |
| **Papier-Textur im Pergament-Modal** | Realistische Papier-Textur als Modal-Hintergrund (S003 Permission-Modal) | PNG-Textur-Overlay bei 60fps-Animationen kann auf älteren Geräten zu Frame-Drops führen. Overlay-Blending ist in Flutter `Stack`+`Opacity` machbar aber nicht kostenlos. | **Lösung:** Papier-Textur als subtiles, statisches SVG-Noise-Pattern (nicht PNG) im Modal-Hintergrund — `FractionalTranslation` während der Aufroll-Animation ist rein Transform-basiert (GPU-accelerated). Textur-Intensität: max. 8% Opacity-Overlay. Auf Low-End-Geräten (RAM < 3GB): Textur-Layer wird automatisch deaktiviert, Hintergrundfarbe `#F5EDD6` ohne Textur — thermischer und Speicher-Sensor-basiertes Adaptive Rendering via Flutter's `PerformanceOverlay`-Monitoring. |
| **Bottom-Tab-Bar-Elimination vs. Nutzbarkeit** | Vollständige Elimination der Bottom-Tab-Bar, reine Gesture-Navigation | Swipe-Navigation ohne Tab-Bar hat nachweisbar höhere Discoverability-Probleme bei Erst-Nutzern. iOS HIG und Android Material Guidelines warnen vor versteckter Navigation. | **Kompromiss:** Keine persistente Tab-Bar. Stattdessen: beim allerersten App-Start erscheint **einmalig** ein subtiler Swipe-Hint (3 Punkte mit Pfeil, 2s sichtbar, dann fade-out, nie wieder). Im Sidebar (Drag-to-open) sind alle Hauptbereiche aufgelistet als Fallback-Navigation. Nutzer der App nach 3 Tagen: kein Hint mehr. Dies erfüllt Discoverability-Anforderungen ohne Tab-Bar-Kompromiss. |
| **Sound-Design auf Android** | Organische Sound-Palette (Buchaufschlagen, Gitarren-Akkord) | Android-Audiolatenz ist historisch höher als iOS. `SoundPool` für kurze Sounds, `MediaPlayer` für längere — beide haben plattformspezifische Latenz-Charakteristiken. | **Lösung:** `just_audio` Flutter-Package für alle Sounds (niedrigste Cross-Platform-Latenz). Alle Sound-Assets als `.ogg` für Android, `.aaf`/`.caf` für iOS — plattformspezifische Asset-Varianten im Flutter Asset-System. Maximale Sound-Latenz-Toleranz: 80ms nach Touch-Event. Sounds die

---

# Design-Vision-Dokument: GrowMeldAI
## Teil 2: Empfehlungen, Micro-Interactions & Abnahme-Checkliste
### Version: 1.0 | Status: VERBINDLICH für Produktionslinie

---

## 2.1 Micro-Interactions (EMPFOHLEN — Top 15)

> Sortierung: **Hoch** → **Mittel** → **Niedrig**. Bei Zeitdruck: nur Hoch-Items implementieren.

| # | Trigger | Unsere Reaktion | Screens | Aufwand | Priorität |
|---|---|---|---|---|---|
| **MI-01** | Pflanze wird im Kamera-Viewfinder erkannt (vor Tap) | Kupferstich-Linien legen sich organisch über Blattadern und Umrisse — nicht sofort, sondern in 1,2–2,0s aufbauend wie ein Stift der zeichnet. Linienstärke beginnt bei 0.5px, endet bei 1.5px. Hohe Konfidenz = vollständige Linien. Niedrige Konfidenz = gestrichelte Linien. | S004 Scanner | Hoch | **Hoch** |
| **MI-02** | Pflegeplan-Reveal: Panel erscheint | Das Panel fährt nicht von unten hoch — es rollt sich auf wie ein Pergament-Brief. Easing: `cubic-bezier(0.22, 1, 0.36, 1)`, Dauer 480ms. Jedes Pflegesymbol (Wassertropfen, Sonne, Schaufel) füllt sich sequenziell von unten wie ein Thermometer, 80ms Verzögerung zwischen Symbolen. | S006 Pflegeplan-Reveal | Hoch | **Hoch** |
| **MI-03** | Wetter-Kontext erscheint im Pflegeplan (*„Kein Gießen wegen Regen"*) | Der Satz erscheint 600ms nach den Symbolen mit einem sanften Underline-Draw-Effekt — eine Kupferstich-Linie unterstreicht den Text von links nach rechts in 300ms. Typografisches Gewicht springt auf Bold. Dieser Moment ist der Aha-Moment: er bekommt die längste visuelle Aufmerksamkeit. | S006 Pflegeplan-Reveal | Mittel | **Hoch** |
| **MI-04** | Tap auf Aufgabe im Core-Loop (Pflege erledigt) | Kein Häkchen-Bounce. Das Kupferstich-Symbol der Aufgabe (z. B. Wassertropfen) „füllt" sich mit Tinte von unten — der Umriss war leer, wird schwarz ausgefüllt. Dauer: 400ms. Danach: 1px Ripple in `#C4813A` (Kupfer-Akzent) der nach außen verblasst. Haptik: einzelner, weicher Puls (10ms, medium impact). | Home-Dashboard, Core-Loop | Mittel | **Hoch** |
| **MI-05** | Kamera-Button auf S002 wird getappt | Button "öffnet sich wie eine Blüte" — 4 botanische Strich-Elemente fahren vom Zentrum nach außen (je 60px, 200ms), dann Kamera-Transition. Haptik: sanfter Doppelpuls, 15ms Pause zwischen den Pulsen. Entspricht dem Gefühl: *reif, bereit.* | S002 Onboarding-Kamera-Splash | Mittel | **Hoch** |
| **MI-06** | Profil-Erstellungs-Flow: Schritt abgeschlossen | Auf dem Fortschrittsbalken (Pflanzenstängel-Illustration) treibt ein neues Blatt aus. Das Blatt erscheint mit einem `scale(0) → scale(1)` in 350ms + leichtem Overshooting auf 1.08 → zurück auf 1.0. Kein generischer Ladebalken. Die Pflanze wächst sichtbar. | S005 Pflanzenprofil-Erstellung | Mittel | **Hoch** |
| **MI-07** | Auswahl-Karte im Profil-Erstellungs-Flow wird gedrückt | Karte kippt mit 3D-Tilt-Effekt: `rotateX(8deg)` + `translateY(-4px)` + leichte Box-Shadow-Verstärkung in 120ms. Haptik: ein weiches, tiefes Puls-Gefühl (30ms, soft impact) — unterscheidet sich bewusst von normalen Button-Taps. | S005 Pflanzenprofil-Erstellung | Mittel | **Hoch** |
| **MI-08** | Scan-Ergebnis wird geladen (KI verarbeitet) | Die Kupferstich-Linien auf dem Pflanzenbild "zittern" in einem organischen Noise-Pattern — kein Spinner, kein Skeleton-Screen. Die Linien werden dichter, Strichstärke pulst zwischen 0.8px und 1.5px im 800ms-Rhythmus. Visuell: *„jemand zeichnet schneller".* | S004 Scanner | Hoch | **Hoch** |
| **MI-09** | Push-Permission-Button (*„Ja, bitte"*) erscheint | Button pulsiert genau einmal sanft beim Modal-Erscheinen: `scale(1.0 → 1.04 → 1.0)` in 600ms. Kein wiederholtes Pulsieren. Einmal. Dann still. Aufmerksamkeit ohne Aggression. | S007 Push-Permission | Niedrig | **Mittel** |
| **MI-10** | Swipe-Navigation zwischen Hauptbereichen | Beim Swipe erscheinen an der Swipe-Kante botanische Kupferstich-Ornamente — wie Seitenränder eines alten Buchs. Sie sind sichtbar während des Swipe-Drags (Parallax-Offset 0.3x der Swipe-Distanz) und verblassen beim Loslassen in 200ms. Navigation fühlt sich an wie Blättern, nicht wie Scrollen. | Alle Hauptbereiche | Hoch | **Mittel** |
| **MI-11** | DSGVO-Zeile (*„Warum?"*) wird getappt und expandiert | Die Zeile öffnet sich mit einer botanischen Blatt-Falt-Animation: Content expandiert mit `max-height`-Transition (300ms, ease-out), begleitet von einer sich entfaltenden Blatt-Linie (SVG-Pfad-Animation, 250ms) links der Zeile. Erstes sichtbares Element: die Pflanze-hinter-Lupe-Illustration, nicht Rechtstext. | S003 Kamera-Permission | Niedrig | **Mittel** |
| **MI-12** | Scroll auf dem Pflegeplan-Screen | Pflanzenfoto-Hintergrundebene scrollt mit 0.4x Geschwindigkeit der Pflegeplan-Ebene. Echter Parallax-Tiefeneffekt — das Foto bleibt präsent, die Infos scrollen darüber. Erzeugt Layering-Tiefe ohne 3D-Overengineering. | S006 Pflegeplan-Reveal, Home-Dashboard | Niedrig | **Mittel** |
| **MI-13** | Splash-Screen: Logo-Ranke bei schnellem Laden fertig | Die Ranke „blüht" kurz auf — eine stilisierte Blüte öffnet sich in 300ms am Ende der Ranke (`path`-Animation, 4 Blütenblätter, radial expandierend). Nur wenn Loading < 1.5s. Bei langsamem Laden: Ranke wächst einfach weiter, keine Blüte. | S001 Splash | Niedrig | **Mittel** |
| **MI-14** | Long-Press auf eine Pflanzenkarte im Garten | Eine Lupe mit Kupferstich-Linierung erscheint über der Karte, Karte hebt sich leicht (`translateY(-8px)`, Shadow `+12px`). Nach 400ms Haltezeit: Kontextmenü öffnet sich als botanische Pergament-Karte von unten. Kein generisches iOS-Context-Menu. | Home-Dashboard, Pflanzengarten | Hoch | **Niedrig** |
| **MI-15** | Scan-Limit erreicht — Viewfinder-Sepia-State | Sepia-Filter fährt graduell über den Viewfinder-Bereich: `sepia(0%) → sepia(60%)` in 800ms. Die Kupferstich-Erkennungslinien verblassen gleichzeitig auf 30% Opacity. Text erscheint in der Mitte mit Fade-in (300ms): *„Heute waren es viele Entdeckungen."* — weiche, würdige Limitation, kein Barrier-Gate-Feeling. | S004 Scanner | Mittel | **Niedrig** |

---

## 2.2 UX-Innovationen (EMPFOHLEN)

> Top 5 nach **Impact × Machbarkeit**. Alle fünf sind MVP-kompatibel.

| Innovation | Beschreibung | Aufwand | Priorität |
|---|---|---|---|
| **UX-I01: Lebendige Scanner-KI als Kupferstich-Zeichner** | Der KI-Scan-Prozess ist visuell keine Tech-Metapher (kein Laserstrahl, kein pulsierender Ring) — sondern ein Zeichner der eine botanische Studie anfertigt. Die Linien legen sich über die Echtzeitkamera-Ansicht via Canvas-Overlay, folgen echten Blattadern (Segmentation-Output nutzen wenn verfügbar, sonst Edge-Detection-Näherung). States kommunizieren Konfidenz ohne Text. **Impact:** Stärkster Differenzierungspunkt im App Store Screenshot-Set. Kein Wettbewerber zeigt Scan-Feedback so. **Technisch:** Canvas-Overlay + SVG-Pfad-Animation + Kamera-API. Laufbar auf Flutter/React Native mit Skia-Renderer. | Hoch | **Hoch** |
| **UX-I02: Gesture-First Navigation (Buch-Blättern-Metapher)** | Keine Tab-Bar. Keine Navbar. Die drei Hauptbereiche (Scanner / Pflanzengarten / Kalender) sind wie Seiten eines aufgeschlagenen Buches. Swipe-Links/Rechts blättert zwischen ihnen. Beim Übergang erscheinen kurzzeitig Seitenrand-Ornamente (Kupferstich-Bordüren) die das Blättern physisch erfahrbar machen. Drag-to-open-Sidebar (< 40px Drag-Schwelle) für Profil/Einstellungen. **Impact:** Macht Navigation selbst zum Markenerlebnis. Eliminiert generische Infra-UI vollständig aus dem sichtbaren Raum. **Technisch:** Custom Navigator + GestureDetector (Flutter) / PanResponder (RN). Kein nativer Tab-Navigator. | Hoch | **Hoch** |
| **UX-I03: Kontextueller Wetter-Intelligenz-Moment im Pflegeplan** | Der Pflegeplan bezieht in Echtzeit Wetterdaten (Open-Meteo API, kostenlos) und passt Pflege-Empfehlungen an. Der visuelle Beweis: ein dedizierter, typografisch hervorgehobener Satz (*„Wegen Regen am Donnerstag — kein Gießen nötig"*) erscheint mit Underline-Draw-Animation und ist der einzige fettgedruckte Satz im gesamten Plan. **Dieser Moment definiert den Aha-Moment der App.** Er beweist Intelligenz, nicht Vollständigkeit. **Technisch:** Wetter-API-Call beim Pflegeplan-Laden, simples Rule-Set (Regen > 3mm → kein Gießen). 1 API-Endpoint, < 200ms. | Mittel | **Hoch** |
| **UX-I04: Single-Focus Onboarding-Flow (Eine Frage, ein Screen)** | Statt Multi-Step-Form auf einem Screen oder Swipe-Carousel: jede Profil-Frage bekommt ihren eigenen Screen. Fullscreen, eine Frage, eine Antwort-Methode, kein visuelles Rauschen. Die Antwort-Karten sind Kupferstich-Illustrationen, nicht Text-Dropdowns. Der Fortschrittsbalken ist eine wachsende Pflanze, kein Fortschrittsbalken. **Impact:** Eliminiert kognitiven Overload beim Onboarding. Jeder Schritt fühlt sich bedeutsam an statt prozedural. **Konversion-Hypothese:** Higher completion rate weil jede Frage eine emotionale Antwort hat, keine funktionale. **Technisch:** Einfacher Screen-Stack, SharedElement-Transition zwischen Screens. Niedrig-Risiko. | Mittel | **Hoch** |
| **UX-I05: Botanischer Stil-Guide als Interface-Sprache** | Das gesamte UI ist keine App mit Illustrationen — die Illustrationen *sind* das Interface. Pflanzenkarten, Scan-Overlay, Fortschrittsindikatoren, Navigations-Ornamente: alles ist SVG-Kupferstich. Dieser Ansatz hat eine klare Regel: **kein einziges Standard-UI-Element (keine Card mit weißem Hintergrund, kein generisches Icon aus SF Symbols / Material Icons, keine runden Pill-Buttons in Grün)** erscheint ohne botanische Reinterpretation. **Impact:** App Store-Screenshots sind sofort erkennbar und nicht kategoriespezifisch austauschbar. Marken-Schutz durch visuellen Stil, nicht durch Logo. **Technisch:** SVG-Asset-Bibliothek erforderlich (ca. 40–60 Core-Assets). Einmaliger Aufwand, dann systematisch skalierbar. | Hoch | **Mittel** |

---

## 2.3 Sound-Design (EMPFOHLEN)

> Alle Sounds sind optional-aktivierbar. Default: **Sound ON** — aber nie aufdringlich. Max. Lautstärke relativ: 40% des System-Volumes.

| # | Moment | Sound-Konzept | Datei-Typ | Dauer | Screens |
|---|---|---|---|---|---|
| **SD-01** | App-Start / Splash | Ein einziges organisches Knistern — wie das Aufblättern einer alten Botanikseite. Nicht digital. Kein Synthesizer. Aufgenommen: echtes Buchpapier. Kaum bewusst wahrnehmbar, aber unbewusst verortend. | `.caf` / `.m4a` | 280ms | S001 Splash |
| **SD-02** | Kamera-Button-Tap (Onboarding + Scanner-Start) | Weiches, organisches „Öffnen" — wie ein Buch das aufgeschlagen wird, aber gedämpft auf 15% der echten Lautstärke. Zweimal verwendet (S002 + S003) mit minimaler Pitch-Variation (+3 Semitöne in S003) — Kontinuität der Audio-Sprache. | `.caf` | 150ms | S002, S003 |
| **SD-03** | Scan-Erkennung erfolgreich (Linien vollständig) | Ein Stift der auf Papier absetzt — das kurze, trockene Geräusch des ersten Kontakts einer Feder mit Pergament. Nicht „Kamera-Klick", nicht „Erfolgs-Ping". Präzise und bedeutsam. | `.caf` | 120ms | S004 Scanner |
| **SD-04** | Pflegeplan-Reveal | Eine kurze, warme Akkord-Geste: zwei Töne in organischer Resonanz (Gitarren-Obertöne, kein Synthesizer). Nicht-harmonisch-aufgelöst — der zweite Ton schwingt leicht nach. Lautstärke: sehr leise. Danach absolute Stille — der Plan spricht. | `.caf` | 800ms | S006 Pflegeplan-Reveal |
| **SD-05** | Push-Permission-Bestätigung (*„Ja, bitte"*) | Kleine, helle Haustür-Glocke: einzelner Ton, kurz nachklingend. Freundlich, nicht triumphierend. Das Gefühl: *jemand ist jetzt für deine Pflanze da.* | `.caf` | 400ms | S007 Push-Permission |
| **SD-06** | Pflegeaufgabe erledigt (Core-Loop) | Kein Fanfare. Kein Chime-Set. Ein einziger, tiefer, weicher Ton — wie ein gedämpftes Glockenspiel-Glied, das kurz angeschlagen wird. Subfrequenz-Anteil sichtbar, aber nicht wuchtig. Stilles Stolz-Gefühl in einem Ton. | `.caf` | 350ms | Home-Dashboard, Core-Loop |
| **SD-07** | Seitenübergang (Swipe-Navigation) | Ein sehr leises Papier-Rascheln — exakt das Geräusch einer Buchseite, die umgeblättert wird. Getriggert am Ende des Swipe-Gestures (beim Loslassen), nicht beim Start. Dauer passt sich an Swipe-Geschwindigkeit an: schneller Swipe = kürzeres Rascheln (min. 80ms). | `.caf` | 80–200ms (dynamisch) | Alle Hauptbereiche |
| **SD-08** | Fehler / Pflanze nicht erkannt | Kein Error-Buzzer. Stattdessen: ein leises, nachdenkliches „Hmm" — wie das Geräusch einer Schreibfeder die kurz pausiert. Neutral, nicht alarmierend. Der Text erklärt den Fehler. Der Sound signalisiert nur: *kurze Pause.* | `.caf` | 200ms | S004 Scanner (Fehler-State) |

---

## Design-Checkliste (für Endabnahme nach Produktion)

> Jedes Item ist **objektiv prüfbar**. Kein Item enthält subjektive Wertungen ohne Messkriterium. Human-Review-Gate: alle **Hoch-Priorität**-Items müssen ✅ sein vor App-Store-Einreichung.

---

### Sektion A: Differenzierungspunkte (VERBINDLICH)

- [ ] **D01 — Kupferstich-Illustrationssystem:** Mindestens 1 Kupferstich-SVG-Illustration ist auf jedem Haupt-Screen sichtbar. Hintergrundfarbe auf allen Screens ist `#F5EDD6` (Pergament-Elfenbein) — kein reines Weiß (`#FFFFFF`) ist als Primär-Hintergrund sichtbar. Prüfung: Screenshot-Farb-Sampling auf jedem Screen.
- [ ] **D02 — Serifenbetonte Typografie:** Botanische Lateinnamen auf dem Pflanzenprofil-Screen werden in GFS Didot oder validiertem Didot-Äquivalent, min. 48px, dargestellt. SF Pro / Roboto / System-Default-Fonts erscheinen an keiner Haupt-Headline-Position. Prüfung: Font-Inspector oder Screenshot-Review.
- [ ] **D03 — Lebendige KI-Visualisierung:** Im Scanner-Screen sind beim Scan-Prozess Kupferstich-Linien über dem Kamerabild sichtbar — kein pulsierender Ring, kein blau-glühender Rahmen, kein Spinner im Vollbild. Prüfung: Screen-Recording des Scan-Flows, Frame-by-Frame-Review.
- [ ] **D04 — Gesture-First Navigation:** Keine Tab-Bar im sichtbaren UI auf keinem Screen. Navigation zwischen Scanner / Pflanzengarten / Kalender funktioniert ausschließlich via Swipe-Geste. Prüfung: UI-Audit aller Screens, Tab-Bar-Komponente darf nicht im Widget-Tree existieren.
- [ ] **D05 — Pflegeplan als Briefumschlag-Reveal:** Der Pflegeplan-Screen zeigt eine Kupferstich-Zeitlinie der nächsten 7 Pflegetage mit sequenziell befüllten Symbolen. Der Wetter-Kontext-Satz (wenn Wetterdaten verfügbar) ist typografisch hervorgehoben (Bold + Underline-Draw-Animation). Prüfung: Funktions-Test mit aktivierten Wetterdaten.

---

### Sektion B: Anti-Standard-Regeln (VERBOTE — alle müssen ✅ sein)

- [ ] **KEIN weißer Hintergrund:** `background-color: #FFFFFF` oder `Colors.white` existiert nicht als Primär-Hintergrundfarbe auf irgendeinem Screen. Prüfung: Automatischer Code-Scan nach `#FFFFFF` / `white` in Background-Kontexten.
- [ ] **KEIN Salbeigrün:** Kein Farbwert im Bereich HSL(100–140, 20–60%, 40–70%) erscheint als Primär- oder Sekundärfarbe. Prüfung: Farb-Audit via Design-Token-Liste.
- [ ] **KEINE Bottom-Tab-Bar:** Keine `BottomNavigationBar` / `TabBar` / `UITabBarController` auf irgendeinem Screen. Prüfung: Komponenten-Audit im Quellcode.
- [ ] **KEIN Konfetti bei Rewards:** Keine Konfetti-Animation, kein Partikelsystem bei Aufgaben-Abschluss oder Reward-States. Prüfung: Screen-Recording aller Reward-Interaktionen.
- [ ] **KEIN pulsierender KI-Kreis im Scanner:** Keine kreisförmige, pulsierende Scan-Animation über dem Kamerabild. Prüfung: Screen-Recording des Scanner-Screens.
- [ ] **KEIN generisches Permission-Modal:** Der Kamera-Permission-Hinweis ist kein System-Alert-Klon mit Standard-Styling. Es existiert ein Custom-Modal mit Pergament-Textur und kurzem persönlichem Text. Prüfung: Screenshot-Vergleich mit iOS/Android-System-Alert.
- [ ] **KEINE Erklär-Slides im Onboarding:** Es existiert kein Feature-Explanation-Carousel mit 3–5 Slides zu Beginn der App. Der erste interaktive Screen ist die Kamera-Einladung. Prüfung: Flow-Walkthrough Schritt 1.

---

### Sektion C: Wow-Momente (VERBINDLICH)

- [ ] **WOW-01 — Scanner-Kupferstich-Linien:** Ein Testnutzer, der das erste Mal den Scanner öffnet und eine Pflanze ins Bild hält, bemerkt die Kupferstich-Linien-Animation ohne Hinweis darauf. Prüfung: Usability-Test mit 3 Personen, min. 2/3 erwähnen die Animation spontan oder zeigen nonverbale Reaktion (Lächeln, Nachfragen).
- [ ] **WOW-02 — Wetter-Aha-Moment:** Der Satz mit Wetter-Kontext im Pflegeplan (z. B. *„Wegen Regen am Donnerstag — kein Gießen nötig"*) ist das erste Element, das ein Testnutzer beim Pflegeplan-Reveal laut liest oder kommentiert. Prüfung: Think-Aloud-Test mit 3 Personen, Reaktion auf Wetter-Satz protokollieren.
- [ ] **WOW-03 — Pflanzenprofil-Latein-Hero:** Der Pflanzenprofil-Screen zeigt den botanischen Lateinnamen in min. 48px Didot als visuell dominantestes Element — sichtbar ohne Scrollen, oberhalb der Fold-Linie. Prüfung: Screenshot auf iPhone 14 Standard (390px Breite), Lateinname muss im First Viewport sichtbar sein.

---

### Sektion D: Emotionale Leitlinie

- [ ] **Energie-Level-Konsistenz:** Kein Screen überschreitet Energie-Level 6/10. Prüfung: Review aller Animation-Timings — keine Bounce-Animationen mit `spring`-Easing außer MI-06 (Blatt-Austreibung, kontrollierter Overshooting max. 8%). Keine Elemente mit Blink- oder Attention-Seeking-Animationen nach dem ersten Render.
- [ ] **Stiller Reward-State:** Der Aufgaben-Erledigt-State enthält keine Partikeleffekte, keine Konfetti-Explosionen, keine Score-Einblendung. Das einzige visuelle Feedback ist die Tinten-Füllungs-Animation (MI-04) + optionaler Sound SD-06. Prüfung: Screen-Recording aller Erledigt-Interaktionen.
- [ ] **Paywall ohne Druck-Signale:** Auf dem Monetarisierungs-Screen ist kein durchgestrichener Preis als erstes visuelles Element sichtbar. Kein Countdown-Timer. Kein „Nur heute"-Banner. Prüfung: Screenshot-Audit des Paywall-Screens, Heatmap-Simulation der visuellen Prioritäten.
- [ ] **Profilbereich: tiefster Energiepunkt:** Der Profil/Einstellungs-Screen enthält keine animierten Elemente beim initialen Laden außer dem Seiten-Übergang. Keine Auto-Play-Animationen, keine pulsierenden CTAs. Prüfung: Accessibility-Audit (Reduce Motion aktiv) + normaler Audit.

---

### Sektion E: Micro-Interactions (Hoch-Priorität — PFLICHT)

- [ ] **MI-01 — Kupferstich-Scan-Overlay:** Implementiert und funktional auf iOS + Android. Linien erscheinen within 1,5s nach Pflanzenerkennung. Prüfung: Performance-Test auf Mindest-Zielgerät (iPhone 12 / Pixel 6).
- [ ] **MI-02 — Briefumschlag-Reveal-Animation:** Panel-Easing ist `cubic-bezier(0.22, 1, 0.36, 1)`. Dauer: 480ms ±20ms. Symbole füllen sich sequenziell mit 80ms Delay. Prüfung: Frame-Rate-Recording (min. 55fps auf Zielgerät).
- [ ] **MI-03 — Wetter-Underline-Draw:** Erscheint min. 600ms nach Symbolen. SVG-Pfad-Animation von links nach rechts, 300ms. Prüfung: Screen-Recording, Frame-Counting.
- [ ] **MI-04 — Tinten-Füllungs-Reward:** Kupferstich-Symbol füllt sich von unten in 400ms. Ripple in `#C4813A`. Haptik: single soft pulse. Prüfung: Funktionstest auf iOS (CoreHaptics) + Android (VibrationEffect).
- [ ] **MI-05 — Blüten-Öffnungs-Button:** 4 Strich-Elemente fahren vom Zentrum nach außen, 200ms. Haptik: Doppelpuls, 15ms Pause. Prüfung: Frame-Recording + Haptik-Test.
- [ ] **MI-06 — Pflanzen-Fortschrittsbalken:** Nach jedem Schritt treibt ein neues Blatt aus. `scale(0 → 1.08 → 1.0)`, 350ms. Prüfung: Walkthrough des gesamten Onboarding-Flows, Blatt-Count muss mit Schritt-Count übereinstimmen.
- [ ] **MI-07 — Karten-3D-Tilt:** `rotateX(8deg)` + `translateY(-4px)` beim Druck, 120ms. Haptik: soft deep pulse. Prüfung: Funktionstest auf allen Onboarding-Karten.
- [ ] **MI-08 — Scan-Processing-Zittern:** Linien-Noise-Pattern aktiv während KI-Verarbeitung. Strichstärke pulst 0.8px ↔ 1.5px, 800ms-Zyklus. Kein Spinner sichtbar. Prüfung: Screen-Recording mit simulierter 2G-Verzögerung (min. 3s Processing-Zeit).

---

### Sektion F: Technische Qualität

- [ ] **Frame-Rate:** Alle Animationen laufen mit min. 55fps auf iPhone 12 und Pixel 6 (Mindest-Zielgeräte). Prüfung: Xcode Instruments / Android GPU Profiler.
- [ ] **Haptik-Konsistenz:** Haptisches Feedback ist auf iOS via CoreHaptics und auf Android via VibrationEffect implementiert — kein Fallback auf generischen `vibrate(50ms)`-Call. Prüfung: Test auf physischen Geräten beider Plattformen.
- [ ] **Wetter-API-Fallback:** Wenn Wetterdaten nicht verfügbar sind (kein Netz, API-Fehler), erscheint der Wetter-Kontext-Satz nicht. Der Pflegeplan ist vollständig ohne ihn. Kein leerer Placeholder sichtbar. Prüfung: Test im Airplane-Mode.
- [ ] **Sound-Deaktivierung:** Alle Sounds respektieren das System-Lautlos-Profil (iOS Silent Mode, Android Do Not Disturb). Zusätzlich: In-App Sound-Toggle in Einstellungen vorhanden. Prüfung: Test mit aktiv