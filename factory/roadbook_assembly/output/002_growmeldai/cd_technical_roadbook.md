# Creative Director Technical Roadbook: GrowMeldAI
## Version: 1.0 | Status: **VERBINDLICH** fuer alle Produktionslinien

---

## 1. Produkt-Kurzprofil

**App Name:** GrowMeldAI

**One-Liner:**
GrowMeldAI ist der erste mobile Pflanzendoktor, der KI-Erkennung, wetterbasierte Pflege-Empfehlungen und automatisches Wachstums-Tracking in einem geschlossenen Diagnose-Loop vereint – für alle, die ihre Pflanzen wirklich nicht sterben lassen wollen.

**Plattformen:**
*   **Primär (Phase 1 Launch):** iOS (Swift/SwiftUI)
*   **Sekundär (Phase 4):** Android (Kotlin/Jetpack Compose)

**Tech-Stack (Kernkomponenten):**
*   **Frontend:** Flutter (für Cross-Platform-Kompatibilität in späteren Phasen, aber iOS-First-Design-Prinzipien)
*   **Backend:** Firebase (Cloud Firestore für Datenbank, Cloud Functions für Logik, Firebase Auth für Authentifizierung, Firebase Cloud Messaging für Push Notifications)
*   **KI/APIs:** Plant.id API (Pflanzenerkennung, Krankheitsdiagnose), OpenWeatherMap API (Wetterdaten)
*   **Analytics/Monitoring:** Firebase Analytics, Firebase Crashlytics

**Zielgruppe:**
*   **Kern:** Millennials, 25–45 Jahre, urban/suburban, Mieter mit Wohnung/Balkon, Home-Office-affin, Nachhaltigkeit-bewusst, nutzt bereits Lifestyle-Apps. Weiblich dominant (~60–65%).
*   **Plattform-Priorität:** iOS First (höherer ARPU, bessere Subscription-Conversion).

---

## 2. Design-Vision (**VERBINDLICH**)

### Design-Briefing
GrowMeldAI ist ein botanisches Diagnosewerkzeug, das sich visuell und emotional wie ein lebendig gewordener Wissenschaftsatlas des 18. Jahrhunderts anfühlt — präzise, warm und nie beliebig. Die gesamte App basiert auf einem proprietären Kupferstich-Illustrationssystem: dünne Linien (0.5–1.5px) in tiefem Tinte-Schwarz (#1A1208) auf warmem Pergament-Elfenbein (#F5EDD6), ergänzt durch eine serifenbetonte Primärtypografie (GFS Didot / Didot-Equivalent) für botanische Namen und Schlüsselinformationen. Es gibt **keinen weißen Hintergrund, keine salbeigrünen Flächen, keine Bottom-Tab-Bar, kein Konfetti**. Navigation erfolgt ausschließlich über Swipe-Gesten. Animationen sind organisch-langsam und folgen botanischen Wachstumsmetaphern — kein Bounce, kein Fade-Generic, keine spinnenden Lader. Der Scanner-Screen zeigt sichtbare KI-Analyse als sich langsam vollendende Kupferstich-Zeichnung über der Pflanze, nicht als pulsierender Kreis. Der Pflegeplan-Reveal ist der emotionale Höhepunkt der App: er erscheint wie ein sich öffnender Briefumschlag, zeigt eine Kupferstich-Zeitlinie der nächsten 7 Pflegetage und beweist durch kontextuelle Wetterdaten, dass die App wirklich denkt. Die App fühlt sich an wie ein ruhiger Sonntagmorgen mit einem alten Botanikbuch — Energie-Level 4/10, nie laut, nie drängerisch, immer präzise und bedeutsam.

### Emotionale Leitlinie pro App-Bereich (**PFLICHT**)

| Bereich | Emotion | Energie | Beschreibung |
|---|---|---|---|
| **Splash / Loading** | Erwartungsvolle Stille | 2/10 | Eine einzelne botanische Ranke wächst langsam aus einem Punkt heraus. Der Nutzer schaut zu — kein Interaktions-Druck. Die App keimt. |
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

### Differenzierungspunkte (**PFLICHT**)

| # | Differenzierung | Beschreibung | Betroffene Screens | Status |
|---|---|---|---|---|
| **D01** | **Botanisches Kupferstich-Illustrationssystem** | Kein Foto in Card, kein Salbei-Vektor. Jede Pflanze bekommt eine SVG-Kupferstich-Illustration mit botanischen Beschriftungslinien. Hintergrundfarbe durchgehend Pergament-Elfenbein `#F5EDD6`. Linienfarbe Tinte-Schwarz `#1A1208`, Linienstärke 0.5–1.5px. Diese Illustrationen sind das Interface, nicht Dekoration. | Alle Screens, besonders Pflanzenprofil, Scanner-Overlay, Onboarding | **VERBINDLICH** |
| **D02** | **Serifenbetonte Typografie-Dominanz** | Botanische Lateinnamen in GFS Didot (oder Didot-Equivalent via Custom Font), 72px Heavy, als Hero-Element des Pflanzenprofils. Schafft sofortige Premium-Bildsprache und unterscheidet jeden Screenshot von jedem Wettbewerber. SF Pro / Roboto / „Nature Fonts" sind verboten. | Pflanzenprofil, Scan-Ergebnis, Onboarding-Headline | **VERBINDLICH** |
| **D03** | **Lebendige Scanner-KI-Visualisierung** | Der Scan-Moment zeigt sich langsam vollendende Kupferstich-Linien die Blattadern und Umrisse nachzeichnen — keine blau-glühende KI-Visualisierung, kein pulsierender Rahmen. States: vollständige Linien = hohe Konfidenz, gestrichelte Linien = niedrige Konfidenz. Sepia-Überlagerung bei Scan-Limit. | Scanner-Screen (S004) | **VERBINDLICH** |
| **D04** | **Gesture-First Navigation ohne Bottom-Tab-Bar** | Keine Tab-Bar. Swipe-Navigation zwischen den Hauptbereichen (Scanner ↔ Pflanzengarten ↔ Kalender). Die Geste ist die Metapher für das Blättern durch einen Garten. Drag-to-open-Sidebar für sekundäre Navigation. | Alle Screens | **VERBINDLICH** |
| **D05** | **Pflegeplan als emotionaler Briefumschlag-Reveal** | Der Pflegeplan erscheint nicht als Liste. Panel öffnet sich von unten wie ein Briefumschlag. Vertikale Kupferstich-Zeitlinie (7 Tage) mit sich füllenden Symbolen (Wassertropfen, Sonne, Schaufel). Wetterdaten-Kontext als typografisch hervorgehobener Aha-Satz. | Pflegeplan-Reveal (S006) | **VERBINDLICH** |
| **D06** | **Wachsendes Pflanzenstängel-Fortschrittssystem** | Kein linearer Fortschrittsbalken. Eine Pflanzenstängel-Illustration treibt pro abgeschlossenem Schritt ein neues Blatt aus — Schritt 1: Keimling, Schritt 2: erstes Blatt, Schritt 3: vollständige Pflanze. Gilt für Onboarding-Flow und alle mehrstufigen Flows. | Profilerstellungs-Flow (S005), Onboarding | **VERBINDLICH** |
| **D07** | **Dynamic Island — lebende Pflanzenstatus-Anzeige** | Die Pflanze im Dynamic Island welkt sichtbar wenn Gieß-Termin überfällig ist (tropfende Linie), blüht auf wenn Pflege aktuell. Live Activity für iOS 16+. TikTok-viraler Moment: 2-Sekunden-Clip des welkenden Dynamic-Island-Symbols. | iOS Dynamic Island / Live Activity | **VERBINDLICH für iOS, Android-Alternative: Persistent Notification mit botanischer Illustration** |

### Anti-Standard-Regeln (**VERBOTE**)

| # | **VERBOTEN** | **STATTDESSEN** | Betroffene Screens | Begründung |
|---|---|---|---|---|
| **A01** | Weißer (`#FFFFFF`) oder hellgrauer Hintergrund | Pergament-Elfenbein `#F5EDD6` als Basis-Hintergrundfarbe, `#1A1208` als Text/Linien-Farbe | **ALLE Screens** | Weiß = generischer KI-Default für Pflanzenpflege-Apps — sofortige visuelle Beliebigkeit |
| **A02** | Grün als Primärfarbe (Salbei, Smaragd, Minze in jeder Form) | Warmtöne der Kupferstich-Palette: Elfenbein, Tinte-Schwarz, Terrakotta-Akzent `#8B4513` für Calls-to-Action, botanisches Dunkelgrün `#2D4A1E` nur als sparsamer Sekundär-Akzent (max. 10% Flächenanteil) | **ALLE Screens** | Alle 6 Wettbewerber nutzen Grün — GrowMeldAI differenziert durch wissenschaftliche Bibliotheks-Ästhetik statt Garten-Center-Ästhetik |
| **A03** | Bottom-Tab-Bar mit 4–5 Icons | Swipe-Gesture-Navigation + Drag-to-open-Sidebar. Keine persistente Tab-Leiste sichtbar | **ALLE Screens** | Bottom-Tab-Bar = universelles „ich habe nicht über Navigation nachgedacht"-Signal; Geste als Garten-Blättern-Metapher ist konzeptuell kohärent |
| **A04** | Konfetti-Animation oder grüner Checkmark als Reward | Organische botanische Partikel-Animation: Blütenblätter expandieren aus Pflanzenmitte (300ms ease-out, cubic-bezier(0.25, 0.46, 0.45, 0.94)), wissenschaftliche Herbarium-Labels erscheinen sequenziell mit 80ms Versatz | Reward-Screens, Scan-Ergebnis | Konfetti = Duolingo-Klon. Der Blütenblatt-Effekt ist direkt aus der Bildsprache der App abgeleitet und fühlt sich earned an statt generisch. |
| **A05** | Pulsierender Rahmen / blau-glühende KI-Visualisierung im Scanner | Kupferstich-Linien die sich langsam über Blattadern und Umrisse legen (SVG path animation, `stroke-dashoffset` von 100% → 0% über 1.8s) | Scanner-Screen (S004) | Pulsierender Rahmen ist direkter Clone des generischen „AI Scanner" UI-Patterns — alle Wettbewerber identisch |
| **A06** | Serifenlose Systemschriften (SF Pro, Roboto) als Primärtypografie | GFS Didot (Google Fonts, kostenlos) oder äquivalente Didot-Serif als Primärtypografie für Headlines, botanische Namen, Schlüsselaussagen. Sans-Serif (Inter oder Equivalent) nur für Fließtext unter 14px | **ALLE Screens** | Systemschriften kommunizieren „keine typografische Entscheidung getroffen" — Didot-Serif ist sofort erkennbar und kommuniziert wissenschaftliche Ernsthaftigkeit |
| **A07** | Standard-Paywall-Screen (3 Bullet-Punkte, durchgestrichener Preis, grüner CTA) | Paywall als Kupferstich-„Bibliotheks-Mitgliedschaft": visuell eine alte Institutionskarte, botanische Illustration, warme Formulierung *„Erweitere dein Herbar"* statt Feature-Liste | Paywall / Monetarisierungs-Screen | Feature-Bullet-Paywalls sind emotional kalt und austauschbar. Die Herbarium-Paywall verkauft eine Erfahrung statt eine Feature-Liste — passend zu einer Zielgruppe die für Ästhetik und Qualität zahlt. |
| **A08** | Swipe-Onboarding mit Feature-Erklärungsslides | Direkt Kamera als erster Screen. Einzige Headline: *„Was wächst bei dir?"* — kein Feature-Grid, kein App-Name im ersten Frame, keine Registrierung vor erstem Scan | Onboarding (S001–S002) | Feature-Erklärungsslides signalisieren, dass die App nicht vertraut, dass ihr Produkt für sich spricht |

### Wow-Momente (**PFLICHT**)

| # | Name | Screen | Was passiert (exakt) | Warum kritisch |
|---|---|---|---|---|
| **W01** | **Die lebendige Kupferstich-Erkennung** | S004 Scanner | Sobald Pflanze im Kamerabild erkannt: SVG-Pfadanimation legt Kupferstich-Linien über Blattadern und Umrisse. Animation: `stroke-dashoffset` 100%→0%, Dauer 1.8s, ease-in-out. Mehrere Pfade starten mit 150ms Versatz für organischen Effekt. Niedrige Konfidenz = Linien gestrichelt (dasharray sichtbar). Kein UI-Chrome während dieser Animation. | Dies ist der TikTok-Moment. Niemand macht das. Screenshots und Screen-Recordings dieses Moments sind von alleine teilbar. Differenziert GrowMeldAI in 3 Sekunden von allen Wettbewerbern. |
| **W02** | **Der Briefumschlag-Pflegeplan** | S006 Pflegeplan-Reveal | Panel öffnet sich von unten (450ms, cubic-bezier(0.34, 1.56, 0.64, 1) — leichter Overshoot für organisches Gefühl). Kupferstich-Symbole (Wassertropfen, Sonne, Schaufel) füllen sich sequenziell von unten wie Thermometer (je 200ms, 100ms Versatz). Wetter-Satz erscheint zuletzt, 600ms nach Reveal-Start, 20px größer als Umgebungstext. 2-Ton Gitarren-Akkord (unter 1s) beim Panel-Erscheinen, dann Stille. | Dies ist der Aha-Moment der App — der Moment in dem der Nutzer versteht, dass GrowMeldAI wirklich denkt. Dieser Moment entscheidet über Subscription-Intent und App-Weiterempfehlung. Darf unter keinen Umständen als Liste gerendert werden. |
| **W03** | **Der wachsende Onboarding-Stängel** | S005 Profilerstellungs-Flow | Statt Fortschrittsbalken: eine SVG-Pflanzenstängel-Illustration (`#2D4A1E` auf `#F5EDD6`). Nach jedem abgeschlossenen Schritt: neues Blatt wächst aus (path morph animation, 400ms ease-out). Schritt 1: Keimling (2cm). Schritt 2: +1 Blatt. Schritt 3: vollständige kleine Pflanze mit Blüte. Haptik bei jedem Blatt-Erscheinen: ein weiches, tiefes `UIImpactFeedbackGenerator(.soft)`. | Pflanzenwachstum als direkte Metapher für Fortschritt ist einzigartig kohärent mit dem Produkt. Macht einen funktionalen Fortschrittsindikator zu einem emotionalen Produkt-Statement. Screenshots-worthy für App-Store-Previews. |
| **W04** | **Dynamic Island — die welkende Pflanze** | iOS Dynamic Island / Live Activity | Live Activity zeigt miniaturisierte botanische Linienpflanze. Bei überfälligem Gieß-Termin: Pflanzenlinie „droopt" über 30-Minuten-Periode (interpolierte SVG-Pfad-Transformation, subtil — nicht dramatisch). Bei frisch gegossener Pflanze: Linie richtet sich auf und ein Blatt erscheint (300ms). | Viral-Hebel Nr. 1. Jeder 2-Sekunden-Clip dieses Moments auf TikTok ist kostenlose Verbreitung. Existiert in keiner anderen Pflanzenpflege-App. Beweist, dass GrowMeldAI über Standard-App-Denken hinausgeht. |
| **W05** | **Der Splash-Screen-Keimling** | S001 Splash | App-Logo entfaltet sich als einzelne botanische Ranke aus einem Punkt: SVG path-drawing-animation, organisch-langsam (1.2–3.0s je nach Ladezeit). Keine Bounce, kein Overshoot — echtes organisches Tempo (ease-in-out mit leichter Verlangsamung am Ende). Bei schnellem Laden: Ranke blüht kurz auf (Blüte erscheint, 400ms). Hintergrundfarbe sofort `#F5EDD6` — der erste Frame der App ist nie weiß. Einziger Sound: organisches Knistern unter 0.3s (wie Buchaufschlagen). | First Impression ist irreversibel. Der erste Frame kommuniziert das gesamte Design-Versprechen: Wärme, Botanik, Präzision. Kein weißer Flash, kein generischer Ladescreen — sofortige Marken-Identität. |

### Interaktions-Prinzipien (**PFLICHT**)

**Touch-Reaktion:**
Alle interaktiven Elemente reagieren auf Touch mit botanisch-organischer Haptik:
*   Standard-Tap: `UIImpactFeedbackGenerator(.light)` — keinen harten Klick, ein weiches Antippen
*   Auswahl / Bestätigung: `UIImpactFeedbackGenerator(.soft)` — tiefes, weiches Puls-Gefühl
*   Wichtige Aktionen (Kamera öffnen, Plan bestätigen): einmaliger klarer `UIImpactFeedbackGenerator(.medium)` Puls — nie repetitiv
*   Auswahl-Karten im Profilierungsflow: Force-Touch / Long-Press löst Vertiefungs-Animation aus (`scaleX(0.97) scaleY(0.97)`, 150ms ease-in), `UIImpactFeedbackGenerator(.soft)` beim Nachgeben
*   **Verboten:** `UINotificationFeedbackGenerator(.error)` als erstes Feedback-Signal — Fehler werden visuell kommuniziert, nicht erschreckend vibriert

**Animations-Prinzip:**
Alle Animationen folgen der Wachstumsmetapher — organisch, nie mechanisch:
*   Primäre Kurve: `cubic-bezier(0.25, 0.46, 0.45, 0.94)` — ease-out-organisch
*   Reveal-Animationen (Panels, Modals): leichter Overshoot `cubic-bezier(0.34, 1.56, 0.64, 1)` — wie eine Pflanze die kurz über ihre Zielposition hinausschießt
*   Keine Bounce-Animationen im Spring-Physics-Sinn — Overshoot max. 4% der Zielgröße
*   Keine linearen Animationen außer für rein technische Loading-Indikatoren
*   Kupferstich-Linien-Animationen: `stroke-dashoffset`-basiert, immer ease-in-out, Dauer 1.5–2.0s
*   Transitions zwischen Screens: horizontaler Wisch-Übergang mit Parallax (Hintergrundebene 60% Geschwindigkeit der Vordergrundebene) — kein generischer Push/Fade
*   Mindest-Animationsdauer: 120ms. Maximum für nicht-interaktive Animationen: 2.0s

**Feedback-Prinzip:**
*   Jede Nutzaktion erhält Feedback innerhalb von 80ms — visuell, haptisch oder beides
*   Fehler-States werden durch visuelle Degradation kommuniziert (gestrichelte Linien, Sepia-Überlagerung), nicht durch Rot-Färbung oder Alert-Dialoge
*   Konfidenz-Kommunikation im Scanner ausschließlich über Linienvollständigkeit (gestrichelt = unsicher, durchgehend = sicher) — kein Prozentwert, kein Text-Label
*   Leere States zeigen botanische Kupferstich-Illustrationen mit einer einzigen einladenden Frage — keine „Noch keine Pflanzen hinzugefügt"-Texte
*   Alle primären CTA-Buttons pulsieren **einmal** sanft beim ersten Erscheinen (`scaleX(1.0)→scaleX(1.03)→scaleX(1.0)`, 600ms) — nie repetitiv, nie mehr als einmal pro Session

**Sound-Prinzip:**
*   Alle Sounds sind organisch — keine Synthesizer, keine digitalen Beep-Töne
*   Sound-Palette: Buchaufschlagen/Papierrascheln (0.1–0.3s), Gitarren-Akkord-Geste (unter 1.0s), helles Glöckchen (unter 0.5s, nur für positive Bestätigungen)
*   Lautstärke: maximal 40% des System-Volumes — niemals aufdringlich
*   Jeder Sound ist opt-in über iOS/Android-Stummschalter respektiert — kein Sound erzwingt sich
*   Keine Hintergrundmusik, kein kontinuierlicher Ambient-Sound außer dem gedämpften Blätter-Rauschen im aktiven Scanner (unter System-Audio, Kopfhörer-wahrnehmbar)
*   Sound-Konsistenz: das „Buchaufschlagen"-Geräusch ist die Audio-Signatur der App — erscheint bei Splash, Onboarding-Kamera-Tap und Profilerstellungs-Übergängen in konsistenten Tonhöhen-Variationen

---

## 3. Stil-Guide (**VERBINDLICH**)

### Farbpalette
Die Farbpalette ist direkt aus der Design-Vision abgeleitet und überschreibt generische DAI-Core Brand-Farben für die App-Produktion.

| Name | Hex | Verwendung |
|---|---|---|
| Pergament-Elfenbein | `#F5EDD6` | **VERBINDLICH:** Primäre Hintergrundfarbe für alle Screens (ersetzt `#F5F9F5` und `#FFFFFF`) |
| Tinte-Schwarz | `#1A1208` | **VERBINDLICH:** Primäre Textfarbe, Linien, Icons, primäre CTA-Buttons (ersetzt `#1A2E1A`) |
| Warmes Gold | `#C9973A` | **VERBINDLICH:** Akzentfarbe für aktive Zustände, CTAs, Vitality-Score-Höhepunkte, Premium-Badges (ersetzt `#F9A825`) |
| Botanisches Dunkelgrün | `#2D4A1E` | **VERBINDLICH:** Sparsamer Sekundär-Akzent (max. 10% Flächenanteil), Illustrationselemente (ersetzt `#2E7D32`) |
| Terrakotta-Akzent | `#8B4513` | **VERBINDLICH:** Akzentfarbe für Warnhinweise, Fehlertexte (ersetzt `#E74C3C` und `#F39C12`) |
| Hintergrund-Dunkel | `#13121A` | **VERBINDLICH:** Dark Mode App-Hintergrund (aus DAI-Core Brand Bible, angepasst an botanische Ästhetik) |
| Oberfläche-Dunkel | `#1E1D25` | **VERBINDLICH:** Dark Mode Karten, Modals, Bottom Sheets (aus DAI-Core Brand Bible, angepasst) |
| Text auf Primär | `#FFFFFF` | Text und Icons auf primären Tinte-Schwarz-Buttons und -Flächen |
| Text Sekundär | `#B0B0C0` | Sekundärtext, Metadaten, Timestamps, Placeholder-Labels (aus DAI-Core Brand Bible, angepasst) |
| Border Subtil | `#4A4A5A` | Subtile Trennlinien, Karten-Borders, Divider (aus DAI-Core Brand Bible, angepasst) |
| Overlay Lock | `#1A1208CC` | Halbtransparentes Overlay für Freemium-Lock auf gesperrten Karten, 80% Opacity |

### Typografie
| Font | Verwendung | Gewicht | Lizenz |
|---|---|---|---|
| **GFS Didot** | **VERBINDLICH:** Headlines H1-H3, Onboarding-Titel, botanische Namen, Schlüsselaussagen, App-Wortmarke | 400-700 (Regular, Bold, Heavy) | Open Font License (OFL) – Google Fonts |
| **Inter** | **VERBINDLICH:** Body Text, Pflegeplan-Beschreibungen, Karten-Inhalte, Einstellungs-Labels, Formulare | 400-500 (Regular, Medium) | Open Font License (OFL) – Google Fonts |
| **JetBrains Mono** | **VERBINDLICH:** Debug-Overlay (S020), Konfidenz-Scores, technische Datenpunkte, Versionsanzeigen | 400 (Regular) | Open Font License (OFL) – Google Fonts / JetBrains |

### Illustrations-Stil
*   **Stil:** **VERBINDLICH:** Botanisches Kupferstich-Illustrationssystem
*   **Beschreibung:** Dünne, präzise Linien (0.5–1.5px) in tiefem Tinte-Schwarz (`#1A1208`) auf warmem Pergament-Elfenbein (`#F5EDD6`). Jede Pflanze erhält eine dedizierte Kupferstich-Illustration mit botanischen Beschriftungslinien. Keine harten Kanten, keine generische Clip-Art. Figuren und Objekte haben eine subtile 2.5D-Tiefe durch einfache Schattierungsgradienten ohne Vollschatten. Pflanzliche Motive wie Blätter, Ranken, Topfsilhouetten als wiederkehrende Design-Elemente. Onboarding-Backgrounds verwenden subtile botanische Textur-Patterns als SVG – keine Fotografien.
*   **Begründung:** Millennials 25-40 im DACH-Raum resonieren mit handwerklicher, intellektueller Ästhetik. Der Kupferstich-Ansatz verstärkt die wissenschaftliche Brand-Identity von GrowMeldAI ohne kitschig zu wirken. Konsistenz mit der Pergament-Farbpalette schafft visuellen Wiedererkennungswert über alle Screens.

### Icon-System
*   **Stil:** **VERBINDLICH:** Rounded Outline mit optionalen Filled-States für aktive Zustände, im Kupferstich-Linienstil.
*   **Library:** Phosphor Icons (MIT-lizenziert, konsistente Stroke-Weight, botanisch erweiterbar) als Basis – Custom-Icons für produktspezifische Motive wie Pflanzenprofil, Scan-Rahmen und Topfgrößen.
*   **Grid:** 24x24dp Standard, 32x32dp für Feature-Icons auf Premium-Screens, 48x48dp für Deeplink-Status-Icons S016, 20x20dp für Inline-Icons in Listenzeilen.

### Animations-Stil
*   **Default Duration:** **VERBINDLICH:** 280ms (für Standard-UI-Elemente)
*   **Easing:** **VERBINDLICH:** `cubic-bezier(0.34, 1.10, 0.64, 1.0)` (für Standard-UI-Elemente)
*   **Max Lottie:** **VERBINDLICH:** 450 KB (pro Animation)
*   **Static Fallback:** **VERBINDLICH:** Ja (für alle Animationen)
*   **Zusätzliche Regeln:** Alle Animationen folgen der Wachstumsmetapher (organisch, nie mechanisch). Primäre Kurve: `cubic-bezier(0.25, 0.46, 0.45, 0.94)`. Reveal-Animationen: leichter Overshoot `cubic-bezier(0.34, 1.56, 0.64, 1)`. Keine Bounce-Animationen im Spring-Physics-Sinn. Keine linearen Animationen außer für rein technische Loading-Indikatoren. Kupferstich-Linien-Animationen: `stroke-dashoffset`-basiert, immer ease-in-out, Dauer 1.5–2.0s. Transitions zwischen Screens: horizontaler Wisch-Übergang mit Parallax. Mindest-Animationsdauer: 120ms. Maximum für nicht-interaktive Animationen: 2.0s.

---

## 4. Feature-Map

### Phase A — Soft-Launch MVP (36 Features)
**Budget Phase A:** €136.000 (Entwicklerkosten)

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhängigkeiten |
|---|---|---|---|---|---|
| F001 | KI-Pflanzenerkennung per Kamera | Nutzer fotografiert Pflanze, KI identifiziert Art und erstellt Profil in unter 3 Sekunden. | ki_level_latency_sec, d1_retention, session_duration_min | 8 | |
| F002 | Pflanzenprofil-Erstellung | Automatische Generierung eines Profils mit Name, Herkunft, Schwierigkeitsgrad und Giftigkeitswarnung. | d1_retention, session_duration_min | 4 | F001 |
| F003 | Standort- und Topfgrößenabfrage | Nutzer gibt Fensterrichtung und Topfgröße an, um Pflegeplan zu personalisieren. | d1_retention | 3 | |
| F004 | Personalisierter Pflegeplan | Generierung eines Pflegeplans basierend auf Pflanzentyp, Standort und Wetterdaten. | d1_retention, d7_retention | 5 | F002, F003 |
| F005 | Gieß-Erinnerungen | Automatische Erinnerungen zum Gießen basierend auf Pflanzentyp und Wetterdaten. | d7_retention, sessions_per_day | 3 | F004 |
| F014 | Push-Notification-Einwilligung im Nutzenmoment | Einwilligung zur Push-Notification wird nach erstem Pflegeplan angefragt. | d1_retention | 2 | F004 |
| F018 | Kamera-Onboarding ohne Registrierung | Sofortige Kamera-Nutzung ohne vorherige Registrierung im ersten Screen. | d1_retention, onboarding_completion_rate | 2 | |
| F019 | KI-Identifikation in <3 Sekunden | Schnelle Pflanzenerkennung für sofortige Nutzerfeedback. | ki_level_latency_sec, d1_retention | 4 | F001 |
| F024 | Free-to-Play-Basisversion | Kostenlose Basisversion mit eingeschränktem Feature-Set (z.B. begrenzte Scan-Anzahl). | d1_retention, conversion_rate | 3 | |
| F027 | TestFlight-Closed-Beta | Geschlossene Beta-Phase für technische Stabilität und Nutzerfeedback. | crash_rate, d7_retention | 2 | |
| F028 | Soft-Launch in Australien/Kanada | Regionale Soft-Launch-Phase zur Monetarisierungsvalidierung. | d7_retention, LTV/CAC-Ratio | 1 | F027 |
| F029 | Plant.id API-Integration | Externe KI-Datenbank für Pflanzenerkennung und Krankheitsdiagnose. | ki_level_latency_sec | 4 | |
| F030 | OpenWeatherMap-Integration | Wetterdaten-API für kontextuelle Pflegeempfehlungen. | d7_retention | 3 | |
| F031 | Firebase Analytics | Tracking von Nutzerverhalten, Retention und Conversion. | d1_retention, d7_retention, performance_tracking | 2 | |
| F032 | Firebase Crashlytics | Echtzeit-Fehlerberichte und Stabilitätsmonitoring. | crash_rate | 1 | |
| F033 | Firebase Cloud Messaging (APNs) | Push-Notifications für Erinnerungen und Updates. | d1_retention, sessions_per_day | 2 | |
| F034 | Firebase Auth | Nutzerauthentifizierung und -verwaltung. | d1_retention | 2 | |
| F035 | Cloud Firestore | Backend-Datenbank für Pflanzenprofile, Pflegepläne und Nutzerdaten. | d7_retention | 3 | F034 |
| F036 | Firebase Cloud Functions | Serverless-Backend für Pflegeplan-Generierung, Erinnerungen und Datenverarbeitung. | ki_level_latency_sec, d7_retention | 3 | F035 |
| F037 | Core Location (PLZ-Ebene) | Standortbestimmung für wetterbasierte Pflegeempfehlungen. | d7_retention | 2 | |
| F038 | AVFoundation (Kamera-Framework) | Präzise Steuerung der Kamera für schnelle Scans. | ki_level_latency_sec | 3 | |
| F039 | SwiftUI/React Native UI-Framework | Plattformübergreifende UI-Entwicklung für iOS und Android. | d1_retention, onboarding_completion_rate | 6 | |
| F041 | IAP-Integration (In-App-Purchases) | Monetarisierung über Freemium-Modell mit Jahres-Abo, Einmalkäufen und Add-Ons für iOS (Apple IAP) und Android (Google Play Billing). | conversion_rate | 3 | F024 |
| F042 | Free-Trial-Mechanik | Kostenlose Testphase für Premium-Features mit automatischer Abrechnung nach Ablauf (StoreKit-2-native Implementation). | conversion_rate | 2 | F041 |
| F043 | Freemium-Grenzen-Management | Begrenzung der kostenlosen Scans pro Monat (z.B. 3–5 Scans) mit Hinweisen auf Premium-Upgrade. | conversion_rate | 2 | F024 |
| F044 | DSGVO-Compliance-Management | Einholung, Verwaltung und Dokumentation von Nutzer-Einwilligungen für Datenerhebung (Standort, Kamera, Nutzerprofil) gemäß DSGVO. | legal_risk | 4 | |
| F045 | COPPA-Compliance | Altersverifikation und Schutz von Daten Minderjähriger (unter 13 Jahren) gemäß Children’s Online Privacy Protection Act (COPPA). | legal_risk | 3 | |
| F046 | Kamera-Zugriffsmanagement | Sichere Handhabung von Kamera-Zugriffen für Pflanzenerkennung mit expliziter Nutzer-Einwilligung. | legal_risk | 2 | |
| F047 | Standortdaten-Verarbeitung | Verarbeitung von Standortdaten für lokale Wetterdaten (z.B. OpenWeatherMap) und personalisierte Empfehlungen. | legal_risk | 2 | |
| F048 | Nutzerprofil-Management | Erstellung und Verwaltung von Nutzerprofilen mit Speicherung von Pflanzenbestand, Pflegehistorie und Präferenzen. | d7_retention | 3 | F034 |
| F054 | Firebase-Nutzung | Nutzung von Firebase für Authentifizierung, Datenbank (Firestore), Analytics und Cloud Functions. | crash_rate, performance_tracking | 2 | |
| F065 | Nutzerfeedback-Management | Sammeln, Analysieren und Reagieren auf Nutzerfeedback (z.B. App-Store-Bewertungen, Support-Tickets). | app_store_rating | 2 | |
| F066 | Performance-Tracking | Tracking von Nutzerakquise und Retention. Basis für Optimierung. | d1_retention, d7_retention, LTV/CAC-Ratio | 2 | F031 |
| F068 | Notfall-Plan für API-Ausfälle | Implementierung von Fallback-Mechanismen für den Fall von API-Ausfällen (z.B. Plant.id, OpenWeatherMap). | crash_rate, d1_retention | 3 | F029, F030 |
| F069 | Daten-Backup-System | Regelmäßige Backups von Nutzerdaten (Pflanzenbestand, Pflegehistorie) zur Vermeidung von Datenverlust. | legal_risk | 2 | F035 |
| F070 | KI-Modell-Fallback | Implementierung eines Fallback-Mechanismus für die Pflanzenerkennung, falls das KI-Modell nicht verfügbar ist. | ki_level_latency_sec, crash_rate | 2 | F001 |

### Phase B — Full Production (25 Features)
**Budget Phase B:** €108.000 (Entwicklerkosten)

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhängigkeiten |
|---|---|---|---|---|---|
| F006 | Dünger-Erinnerungen | Erweitert Pflegeplan um Dünger-Erinnerungen. | d7_retention, sessions_per_day | 2 | F004 |
| F007 | Umtopf-Erinnerungen | Erweitert Pflegeplan um Umtopf-Erinnerungen. | d30_retention | 2 | F015 |
| F008 | Krankheitsdiagnose per Scan | Nutzer scannt Pflanze bei Symptomen, KI diagnostiziert Krankheit und schlägt Behandlung vor. | d7_retention, session_duration_min | 6 | F001 |
| F009 | Behandlungsplan nach Diagnose | Automatische Generierung eines Behandlungsplans basierend auf Diagnoseergebnis. | d7_retention | 3 | F008 |
| F010 | Follow-up-Erinnerungen nach Behandlung | Erinnerungen zur Überprüfung des Behandlungserfolgs und erneuter Scan-Empfehlung. | d30_retention | 2 | F009 |
| F011 | Wetter-kontextuelle Gieß-Empfehlungen | Gieß-Empfehlungen werden an lokale Wetterdaten angepasst (z.B. Regenmenge der letzten Tage). | d7_retention | 3 | F004, F030 |
| F012 | KI-Wachstums-Tracking | Automatische Auswertung von Foto-Timelines zur Bestimmung des Pflanzenwachstums. | d30_retention, session_duration_min | 5 | F001 |
| F013 | Giftigkeitswarnung für Haustiere/Kinder | Push-Notification bei Neuzugang einer giftigen Pflanze mit Sicherheitshinweisen. | legal_risk, app_store_rating | 2 | F002 |
| F015 | Tägliche Erinnerungen | Automatische Push-Notifications zur täglichen Pflanzenpflege. | d7_retention, sessions_per_day | 2 | F005 |
| F016 | Wöchentliche Pflege-Checks | Wöchentliche Erinnerungen für umfassende Pflegeüberprüfung. | d30_retention | 2 | F004 |
| F017 | Episodische Erinnerungen | Erinnerungen bei neuen Pflanzen, Krankheitsfällen oder saisonalen Pflegehinweisen. | d30_retention | 2 | F004 |
| F020 | Pflanzenprofil mit Herkunft und Schwierigkeitsgrad | Anzeige von Herkunftsregion, Pflege-Schwierigkeitsgrad und Wachstumsbedingungen. | d7_retention | 2 | F002 |
| F021 | Familienfreigabe für Abos | Unterstützung für Familienfreigabe bei Jahres-Abos. | conversion_rate | 2 | F041 |
| F022 | Jahres-Abo-Modell | Primäres Monetarisierungsmodell mit Rabatt gegenüber Monatsabo. | conversion_rate, LTV/CAC-Ratio | 2 | F041 |
| F023 | Monats-Abo-Modell | Flexibles Abo-Modell für Nutzer mit kürzerer Bindungsdauer. | conversion_rate | 2 | F041 |
| F025 | Einmalkauf für erweiterte Features | Zusätzliche Features wie erweiterte Krankheitserkennung oder Export-Pakete als Einmalkauf. | conversion_rate | 2 | F041 |
| F026 | ASO-Optimierung | App Store Optimization für bessere Sichtbarkeit und Conversion. | app_store_rating, conversion_rate | 3 | |
| F057 | TikTok-Integration | Erstellung und Verbreitung von organischem Content auf TikTok (#planttok) für virales Wachstum. | user_acquisition | 2 | |
| F058 | Instagram-Integration | Erstellung und Verbreitung von organischem Content auf Instagram (Reels + Stories) für Markenaufbau. | user_acquisition | 2 | |
| F059 | Apple Search Ads | Schaltung von gezielten Anzeigen in Apple Search Ads für Nutzer mit hoher Kaufabsicht. | user_acquisition | 2 | F026 |
| F060 | Meta Ads-Integration | Schaltung von gezielten Anzeigen auf Meta (Instagram + Facebook) für Skalierung. | user_acquisition | 2 | F026 |
| F062 | ASO-Optimierung (App Store Optimization) | Optimierung der App-Store-Präsenz (Titel, Beschreibung, Keywords, Screenshots) für bessere Sichtbarkeit. | conversion_rate | 3 | |
| F063 | Website-Landing-Page | Erstellung einer dedizierten Landing Page für Pre-Launch-Marketing und SEO. | user_acquisition | 4 | |
| F064 | SEO-Optimierung | Optimierung der Website für Suchmaschinen (z.B. Google) zur Generierung von organischem Traffic. | user_acquisition | 4 | F063 |
| F067 | A/B-Testing-Tool | Durchführung von A/B-Tests für App-Store-Elemente (z.B. Screenshots, Icons) und Marketing-Kampagnen. | conversion_rate | 3 | F031 |

### Backlog (7 Features)

| ID | Feature | Geplante Version | Erwarteter Impact | Begründung |
|---|---|---|---|---|
| F050 | Pflanzengiftigkeit-Warnsystem | v1.2 | Sicherheitsfeature für Nutzer | Wichtig für Nutzer, aber nicht kritisch für Launch. Kann später implementiert werden. |
| F051 | Diagnose-Empfehlungs-System | v1.2 | Erweitert Krankheitsdiagnose um Empfehlungen | Komplex und nicht kritisch für Launch. Kann später implementiert werden. |
| F052 | Plant.id-API-Integration | v1.3 | Alternative KI-Datenbank für Pflanzenerkennung | Plant.id ist bereits integriert. Alternative API kann später hinzugefügt werden. |
| F053 | OpenWeatherMap-API-Integration | v1.3 | Alternative Wetterdaten-API | OpenWeatherMap ist bereits integriert. Alternative API kann später hinzugefügt werden. |
| F055 | Markenrechtliche Prüfung | v1.0 | Rechtliche Absicherung des Namens | Rein rechtlicher Prozess, keine technische Implementierung. |
| F056 | Patentrecherche | v1.0 | Rechtliche Absicherung der KI-Algorithmen | Rein rechtlicher Prozess, keine technische Implementierung. |
| F061 | Influencer-Marketing-Tool | v1.1 | Management von Micro-Influencern | Rein prozessuales Tool, keine technische Integration. |

---

## 5. Abhängigkeits-Graph & Kritischer Pfad

### Build-Reihenfolge
Die Build-Reihenfolge folgt der Feature-Priorisierung in Phase A, wobei technische Abhängigkeiten und der kritische Pfad strikt eingehalten werden müssen.

1.  **KI-Kernfunktionen:** F001 (KI-Pflanzenerkennung), F019 (KI-Identifikation <3s), F029 (Plant.id API-Integration), F038 (AVFoundation).
2.  **Basis-Onboarding & Profil:** F018 (Kamera-Onboarding ohne Registrierung), F002 (Pflanzenprofil-Erstellung), F003 (Standort/Topfgröße).
3.  **Pflegeplan & Erinnerungen:** F004 (Personalisierter Pflegeplan), F005 (Gieß-Erinnerungen), F014 (Push-Einwilligung im Nutzenmoment), F030 (OpenWeatherMap-Integration), F037 (Core Location PLZ).
4.  **Infrastruktur & Analytics:** F031 (Firebase Analytics), F032 (Firebase Crashlytics), F033 (Firebase Cloud Messaging), F034 (Firebase Auth), F035 (Cloud Firestore), F036 (Firebase Cloud Functions), F054 (Firebase-Nutzung).
5.  **Monetarisierung (MVP):** F024 (Free-to-Play-Basisversion), F041 (IAP-Integration), F042 (Free-Trial-Mechanik), F043 (Freemium-Grenzen-Management).
6.  **Compliance (MVP):** F044 (DSGVO-Compliance), F045 (COPPA-Compliance), F046 (Kamera-Zugriffsmanagement), F047 (Standortdaten-Verarbeitung).
7.  **Resilienz:** F068 (Notfall-Plan API-Ausfälle), F069 (Daten-Backup-System), F070 (KI-Modell-Fallback).
8.  **UI-Framework:** F039 (SwiftUI/React Native UI-Framework) läuft parallel zu allen UI-bezogenen Features.
9.  **Test & Release:** F027 (TestFlight-Closed-Beta), F028 (Soft-Launch).

### Kritischer Pfad mit Dauer in Wochen
Die folgende Kette von Features stellt den kritischen Pfad für den Soft Launch dar. Jede Verzögerung in dieser Kette verzögert den gesamten Launch.

*   **Kette:** F001 (KI-Pflanzenerkennung) → F002 (Pflanzenprofil-Erstellung) → F004 (Personalisierter Pflegeplan) → F005 (Gieß-Erinnerungen) → F014 (Push-Notification-Einwilligung im Nutzenmoment)
*   **Gesamtdauer:** 22 Wochen
*   **Beschreibung:** Ohne eine funktionierende KI-Pflanzenerkennung (F001) kann kein Pflanzenprofil erstellt werden (F002). Ohne Profil kann kein personalisierter Pflegeplan generiert werden (F004). Ohne Pflegeplan sind Gieß-Erinnerungen (F005) und die kritische Push-Notification-Einwilligung im Nutzenmoment (F014) nicht möglich. Diese Kette bildet den Kern-Loop und das primäre Wertversprechen der App.

### Parallelisierbare Feature-Gruppen
Um die Entwicklungszeit zu optimieren, können folgende Feature-Gruppen parallel zum kritischen Pfad entwickelt werden:

*   **KI-Kernfunktionen:** F001, F019, F029 (Plant.id API-Integration) können parallel zu F038 (AVFoundation) entwickelt werden.
*   **Onboarding & Monetarisierung:** F018 (Kamera-Onboarding ohne Registrierung), F024 (Free-to-Play-Basisversion) können parallel zu F001 entwickelt werden.
*   **Infrastruktur & Analytics:** F031 (Firebase Analytics), F032 (Firebase Crashlytics), F033 (Firebase Cloud Messaging) können parallel zu F034 (Firebase Auth) und F035 (Cloud Firestore) entwickelt werden.
*   **Erweiterte Erinnerungen:** F005 (Gieß-Erinnerungen) und F015 (Tägliche Erinnerungen) können parallel zu F001 entwickelt werden, sobald die Abhängigkeit F004 erfüllt ist.
*   **Standort & Wetter:** F003 (Standort- und Topfgrößenabfrage) und F030 (OpenWeatherMap-Integration) können parallel zu F037 (Core Location PLZ) entwickelt werden.
*   **Compliance-Grundlagen:** F044 (DSGVO-Compliance), F045 (COPPA-Compliance), F046 (Kamera-Zugriffsmanagement), F047 (Standortdaten-Verarbeitung) können weitgehend parallel zu den Kern-Features entwickelt werden, da sie primär rechtliche und technische Rahmenbedingungen schaffen.

---

## 6. Screen-Architektur (**VERBINDLICH**)

### Screen-Übersicht (22 Screens)

| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / Loading | Hauptscreen | App-Start, Asset-Loading, Firebase-Init, Crash-Reporter-Init | F032, F031, F034 | Normal, Slow-Connection, Offline-Fallback, Update-Required |
| S002 | Onboarding-Kamera-Splash | Hauptscreen | Frictionless Onboarding ohne Registrierungszwang, sofortige Kamera-CTA als erster Nutzermoment | F018, F039 | Normal, Kamera-Permission-Denied-Hint |
| S003 | Kamera-Permission-Modal | Modal | DSGVO-konforme Einwilligung zur Kamera-Nutzung vor erstem Scan | F046, F044 | Normal, Bereits-Erlaubt, Abgelehnt-Hinweis |
| S004 | Scanner-Screen | Hauptscreen | Kamera-Sucher für Pflanzenscan, KI-Identifikation in <3s, Core-Feature-Entry-Point | F001, F019, F029, F038, F043 | Normal, Scanning-Active, KI-Processing, KI-Ergebnis-Eingeblendet, Scan-Limit-Erreicht, Kamera-Permission-Fehler, Offline-Fallback-Local-Model, API-Fehler-Retry, Niedrige-Konfidenz-Warnung |
| S005 | Pflanzenprofil-Erstellungs-Flow | Subscreen | Schritt-für-Schritt-Erfassung von Standort, Topfgröße und Pflanzennamen nach erfolgreichem Scan | F002, F003, F037 | Schritt-1-Pflanzenname, Schritt-2-Standort, Schritt-3-Topfgröße, Speichern-Loading, Speichern-Fehler, Validierungsfehler |
| S006 | Pflegeplan-Reveal-Screen | Hauptscreen | Erster personalisierter Pflegeplan nach Profilerstellung, emotionaler Höhepunkt für Push-Permission-Anfrage | F004, F005, F014, F030, F033 | Normal-Voller-Plan, Wetter-Daten-Loading, Wetter-Fehler-Fallback, Push-Permission-Erteilt, Push-Permission-Abgelehnt, Freemium-Features-Locked |
| S007 | Push-Notification-Einwilligungs-Modal | Modal | DSGVO-konforme Push-Einwilligung im Moment des höchsten empfundenen Nutzens nach Pflegeplan-Reveal | F014, F033, F044 | Normal, Bereits-Erteilt, Systemdialog-Trigger |
| S008 | Home-Dashboard | Hauptscreen | Täglicher Einstiegspunkt, Pflanzenpflegeübersicht, Aufgaben-Feed, Core-Retention-Screen | F004, F005, F030, F031, F048 | Normal-Mit-Pflanzen, Leer-Keine-Pflanzen-Onboarding-CTA, Alle-Aufgaben-Erledigt, Wetter-Daten-Loading, Offline-Gecachte-Daten, Fehler-Sync |
| S009 | Meine-Pflanzen-Liste | Hauptscreen | Übersicht aller gespeicherten Pflanzenprofile, Verwaltung des Pflanzenbestands | F002, F048, F035, F043 | Normal-Mit-Pflanzen, Leer-CTA-Erste-Pflanze-Scannen, Suche-Aktiv, Freemium-Limit-Erreicht, Offline-Gecacht, Lade-Zustand |
| S010 | Pflanzenprofil-Detail | Subscreen | Detailansicht einer einzelnen Pflanze mit Pflegeplan, Pflegehistorie und Scan-Möglichkeit | F002, F004, F005, F030, F048 | Normal, Pflegeplan-Loading, Aufgabe-Als-Erledigt-Animiert, Offline-Gecacht, Wetter-Kontext-Aktiv, Fehler-Pflegeplan |
| S011 | Scan-Ergebnis-Screen | Subscreen | Anzeige des KI-Erkennungsergebnisses mit Konfidenz, Pflanzeninfos und Aktion zur Profilerstellung | F001, F019, F029, F070 | Hohe-Konfidenz, Niedrige-Konfidenz-Mit-Alternativen, Keine-Pflanze-Erkannt, Offline-Local-Model-Fallback, API-Fehler-Retry-Option |
| S012 | Registrierung-Login-Screen | Hauptscreen | Firebase Auth-basierte Anmeldung, DSGVO-konform, nach erstem Mehrwert-Erlebnis getriggert | F034, F044, F045 | Registrierung, Login, Passwort-Vergessen, Loading-Auth, Fehler-Auth, Bereits-Eingeloggt-Redirect, COPPA-Under13-Block |
| S013 | Profil-und-Einstellungen | Hauptscreen | Nutzerprofil, App-Einstellungen, Datenschutz, DSGVO-Verwaltung, Premium-Upgrade-Zugang | F034, F044, F045, F046, F047 | Freemium-Nutzer, Premium-Nutzer, Nicht-Eingeloggt, Datenschutz-Einstellungen-Offen, Loading |
| S014 | Premium-Upgrade-Paywall | Modal | Free-Trial und Abo-Angebot, Conversion-Optimierung, IAP-Integration | F024, F041, F042, F043 | Free-Trial-Verfügbar, Trial-Läuft, Trial-Abgelaufen, Bereits-Premium, IAP-Loading, IAP-Fehler, IAP-Erfolgreich |
| S015 | Freemium-Limit-Erreicht-Modal | Modal | Weicher Paywall bei Scan-Limit-Erreichen, kontextueller Upgrade-Trigger | F043, F042, F041 | Scan-Limit-Täglich-Erreicht, Pflanzenprofil-Limit-Erreicht, Trial-Angebot-Verfügbar |
| S016 | Gieß-Erinnerungs-Notification-Deeplink | Subscreen | Deeplink-Zielscreen nach Tap auf Push-Notification, direkte Pflegeaktion ermöglichen | F005, F033, F004 | Aufgabe-Fällig, Aufgabe-Überfällig, Aufgabe-Bereits-Erledigt, Pflanze-Nicht-Mehr-Vorhanden |
| S017 | Offline-Fehler-Overlay | Overlay | Kommunikation von Offline-Zustand und API-Ausfällen mit Fallback-Hinweisen | F068, F070, F032 | Komplett-Offline, API-Fehler-Plant-Id, API-Fehler-Wetter, Teilweise-Offline-Cache-Verfügbar |
| S018 | Datenschutz-Onboarding-Modal | Modal | DSGVO-COPPA-konformes Datenschutz-Consent beim ersten App-Start vor jeder Datenverarbeitung | F044, F045, F047, F054 | Erstmalig, Bereits-Akzeptiert-Skip, COPPA-Under13-Hard-Block, Einwilligung-Unvollständig-Validierung |
| S019 | Feedback-und-Bewertungs-Modal | Modal | Nutzerfeedback-Erfassung und App-Store-Bewertungs-Prompt zum optimalen Zeitpunkt | F065, F031 | Positiv-Bewertung-App-Store-Redirect, Negativ-Bewertung-Internes-Feedback, Bereits-Bewertet-Suppressed |
| S020 | Performance-und-Analytics-Debug-Overlay | Overlay | Internes Tracking-Overlay für QA und Beta-Testing, nicht für Endnutzer sichtbar | F031, F032, F066 | Debug-Modus-Aktiv, Produktions-Modus-Hidden |
| S021 | TestFlight-Beta-Feedback-Banner | Overlay | Beta-Feedback-Erfassung während TestFlight-Closed-Beta-Phase | F027, F065, F032 | Beta-Aktiv, Produktions-Modus-Hidden |
| S022 | Standort-Permission-Modal | Modal | DSGVO-konforme Einwilligung zur PLZ-Standortnutzung für wetterbasierte Pflegeempfehlungen | F037, F047, F044 | Normal, Permission-Erteilt, Permission-Abgelehnt-PLZ-Fallback, Standort-Nicht-Verfügbar |

### Hierarchie
*   **Gesture-First Navigation (keine Bottom-Tab-Bar):**
    *   **Swipe Right:** Scanner (S004)
    *   **Swipe Left:** Meine Pflanzen (S009)
    *   **Swipe Up:** Home (S008) - Default-Screen
    *   **Drag-to-open-Sidebar:** Profil (S013) - für sekundäre Navigation
*   **Modals:** S003, S007, S014, S015, S018, S019, S022
*   **Overlays:** S017, S020, S021

### Navigation
Die Navigation erfolgt primär über Swipe-Gesten zwischen den Hauptbereichen (Home, Meine Pflanzen, Scanner). Sekundäre Navigation (Profil, Einstellungen) ist über eine Drag-to-open-Sidebar erreichbar. Innerhalb von Flows (z.B. Pflanzenprofil-Erstellung) wird eine Schritt-für-Schritt-Navigation verwendet.

### Alle 7 User Flows

**Flow 1: Onboarding (Erst-Start)**
*   **Pfad:** S001 → S018 → S002 → S003 → S004 → S011 → S005 (Schritt 1–3) → S022 → S006 → S007
*   **Taps bis Core Loop:** 6–8 Taps (abhängig von Permission-Dialogen)
*   **Zeitbudget:** ~60 Sekunden
*   **Kernmomente:**
    *   S001: Splash lädt Assets + Firebase-Init
    *   S018: DSGVO/COPPA-Consent als erster Gate **vor** jeder Datenverarbeitung
    *   S002: Kamera-CTA sofort sichtbar, kein Registrierungszwang
    *   S003: Kamera-Permission-Modal (DSGVO-konform, einmalig)
    *   S004: Scanner öffnet sich direkt, erster Scan
    *   S011: KI-Ergebnis mit hoher Konfidenz
    *   S005: 3-Schritt-Profil-Flow (Name → Standort → Topfgröße)
    *   S022: Standort-Permission für Wetterdaten (optional, PLZ-Fallback)
    *   S006: Pflegeplan-Reveal als emotionaler Höhepunkt
    *   S007: Push-Einwilligung **im Moment des höchsten empfundenen Nutzens**
*   **Fallback bei DSGVO-Ablehnung:** S018 blockiert → App nicht nutzbar (Hard Block für Mindestanforderungen); optionale Einwilligungen (Standort, Push) → App weiter nutzbar mit reduziertem Funktionsumfang
*   **Fallback bei Kamera-Ablehnung:** S003 Abgelehnt-Hinweis → S004 Kamera-Permission-Fehler-State → Hinweis zur manuellen Suche (falls implementiert) oder erneutem Erlauben

**Flow 2: Core Loop (wiederkehrend täglich)**
*   **Pfad:** S008 → S016 (via Push-Notification-Deeplink) → S010 → Aufgabe-Erledigt-Animation → S008
*   **Alternativ-Pfad ohne Notification:** S008 → S010 → Aufgabe abhaken → S008
*   **Taps bis Aufgabe erledigt:** 2–3 Taps
*   **Session-Ziel:** 2–5 Minuten (tägliche Micro-Session via Erinnerung)
*   **Kernmomente:**
    *   S008 (Home-Dashboard): Aufgaben-Feed zeigt fällige Pflegeaufgaben, Wetter-Kontext sichtbar
    *   S010 (Pflanzenprofil-Detail): Aufgabe als erledigt markieren → Animations-Feedback
    *   S016 (Deeplink): Direkter Einstieg nach Notification-Tap → reduziert Friction maximal
*   **Erweiterter Loop (wöchentlich):** S008 → S004 → S011 → S010 (Diagnose-Update) → S010 (Behandlungsplan aktiv)
*   **Erweiterter Loop (neue Pflanze):** S008 (CTA) → S004 → S011 → S005 → S006 → S008

**Flow 3: Erster Kauf (Freemium → Premium)**
*   **Pfad A – Scan-Limit-Trigger:** S004 (Scan-Limit-Erreicht-State) → S015 → S014 → IAP-Systemdialog → S014 (IAP-Erfolgreich) → S006 oder S004
*   **Pfad B – Profil-Limit-Trigger:** S009 (Freemium-Limit-Erreicht-State) → S015 → S014 → IAP-Systemdialog → S014 (IAP-Erfolgreich) → S009
*   **Pfad C – Proaktiv aus Profil:** S013 (Freemium-Nutzer-State) → S014 → IAP-Systemdialog → S014 (IAP-Erfolgreich) → S013 (Premium-Nutzer-State)
*   **Taps bis Kauf:** 3–4 Taps (Pfad A/B: 4 Taps inkl. Systemdialog)
*   **Kernmomente:**
    *   S015: Weicher Paywall mit kontextuellem Nutzenversprechen + Free-Trial-Angebot
    *   S014: Conversion-optimierte Paywall mit Trial-CTA als primärer Button
    *   IAP-Systemdialog: Native iOS/Android-Dialog
    *   S014 IAP-Erfolgreich: Positives Feedback, Rückkehr zum auslösenden Kontext

**Flow 4: Registrierung / Account-Erstellung (nach erstem Mehrwert)**
*   **Pfad:** S006 (Pflegeplan-Reveal, Push-Permission erteilt) → S008 (Home, erste Session) → S013 → S012 (Registrierung) → S012 (Loading-Auth) → S008 (eingeloggt, Daten synchronisiert)
*   **Alternativ-Trigger:** S009 (Freemium-Limit) → S015 → S014 → S012 (Registrierung als Pre-Step vor IAP)
*   **Taps bis Account erstellt:** 4–5 Taps
*   **Kernmomente:**
    *   Registrierung wird **nicht** beim ersten Start erzwungen – erst nach erstem Mehrwert-Erlebnis
    *   S012 zeigt Registrierung als Standard-State, Login als sekundäre Option
    *   Nach erfolgreicher Auth → Redirect zurück zu S008 mit gesyncten Pflanzendaten
*   **Fallback:** S013 (Nicht-Eingeloggt-State) zeigt eingeschränkte Funktionen, persistenter Hinweis auf Vorteile der Registrierung

**Flow 5: Diagnose-Loop (Pflanze zeigt Symptome)**
*   **Pfad:** S008 (Aufgaben-Feed oder manuell) → S009 → S010 (Pflanzenprofil-Detail) → S004 (Re-Scan via CTA im Profil) → S011 (Diagnose-Ergebnis) → S010 (Behandlungsplan aktiv, Follow-up-Erinnerung gesetzt) → S008
*   **Taps bis Diagnose:** 4–5 Taps
*   **Alternativ über Home-CTA:** S008 → S004 → S011 → S005 (neue Pflanze) oder S010 (bestehende Pflanze updaten)
*   **Kernmomente:**
    *   S010: "Neue Diagnose starten"-CTA öffnet S004 im Kontext der aktuellen Pflanze
    *   S011 (Niedrige-Konfidenz-State): Alternativen werden angezeigt, Nutzer wählt manuell
    *   S011: Behandlungsplan wird direkt im Ergebnis-Screen zusammengefasst
    *   S010: Pflegehistorie wird mit Diagnose-Eintrag aktualisiert
    *   Follow-up-Erinnerung automatisch gesetzt (Push-Permission vorausgesetzt)
*   **Mehrwert:** Schließt den vollständigen Diagnose-Loop (bestätigter Markt-Gap)

**Flow 6: Offline-Nutzung (kein Internet)**
*   **Pfad:** S001 (Offline-Fallback-State) → S017 (Komplett-Offline-Overlay, dismissable) → S008 (Offline-Gecachte-Daten-State) → S010 (Offline-Gecacht) → Aufgabe lokal abhaken → S008
*   **Scan-Versuch offline:** S004 → S017 (API-Fehler-Plant-Id) → S004 (Offline-Fallback-Local-Model-State, reduzierte KI-Genauigkeit) → S011 (Offline-Local-Model-Fallback-State)
*   **Taps bis Offline-Core-Loop:** 3 Taps (Overlay dismissen → Home → Profil)
*   **Kernmomente:**
    *   S017 ist **dismissable** – Nutzer kann mit gecachten Daten weiterarbeiten
    *   S008 zeigt gecachte Pflanzendaten + lokal ausstehende Aufgaben
    *   Erledigte Aufgaben werden lokal gespeichert + bei Reconnect synchronisiert
    *   S004 mit Local-Model-Fallback: Eingeschränkte Pflanzenidentifikation (~70% Genauigkeit) auch ohne Internet
    *   S011 Offline-State: Klar kommunizieren, dass Ergebnis aus lokalem Modell stammt

**Flow 7: DSGVO/Consent-Management (Detail)**
*   **Erst-Start-Pfad:** S001 → S018 (Erstmalig-State) → [Vollständige Einwilligung] → S002
*   **Kamera-Consent-Pfad:** S002 → S003 (Normal-State) → [Einwilligung] → S004
*   **Push-Consent-Pfad:** S006 → S007 (Normal-State) → [Einwilligung] → S007 (Systemdialog-Trigger) → S006/S008
*   **Standort-Consent-Pfad:** S005 (Schritt-2-Standort) → S022 (Normal-State) → [Einwilligung oder Ablehnung → PLZ-Fallback] → S006
*   **Nachträgliche Consent-Verwaltung:** S013 → S013 (Datenschutz-Einstellungen-Offen-State) → individuelle Einwilligungen verwalten
*   **COPPA-Pfad (unter 13):** S018 (COPPA-Under13-Hard-Block-State) → App-Nutzung vollständig blockiert, Elternteil-Hinweis angezeigt
*   **Einwilligungs-Reihenfolge (chronologisch):**
    1.  S018: Datenschutz-Basis-Consent (Pflicht, vor jeder Datenverarbeitung)
    2.  S003: Kamera-Permission (vor erstem Scan)
    3.  S022: Standort-Permission (vor Pflegeplan-Generierung mit Wetterdaten)
    4.  S007: Push-Notification-Einwilligung (nach Pflegeplan-Reveal)

### Edge Cases

| Situation | Betroffene Screens | Verhalten |
|---|---|---|
| DSGVO-Basis-Consent abgelehnt (S018) | S018, S001 | Hard Block: App nicht nutzbar, Hinweis auf Notwendigkeit, Consent erneut anfragen bei App-Neustart |
| COPPA – Nutzer unter 13 | S018, S012 | S018: Hard Block mit Elternteil-Hinweis; S012: COPPA-Under13-Block, kein Account möglich, kein Tracking |
| Kamera-Permission dauerhaft abgelehnt | S003, S004, S002 | S004 zeigt Kamera-Permission-Fehler-State mit Deep-Link zu iOS/Android-Systemeinstellungen; Onboarding-Scan nicht möglich |
| Push-Permission abgelehnt (S007) | S007, S006, S008, S010 | App bleibt voll nutzbar; kein Retention-Mechanismus via Push; In-App-Nudge nach 7 Tagen in S008 oder S010 (einmalig, nicht aufdringlich) |
| Standort-Permission abgelehnt (S022) | S022, S006, S010 | PLZ-Fallback: Nutzer gibt PLZ manuell ein; Pflegeplan mit eingeschränkten Wetterdaten; S006 zeigt Wetter-Fehler-Fallback-State |
| Scan-Limit täglich erreicht (Freemium) | S004, S015, S014 | S004 wechselt in Scan-Limit-Erreicht-State; S015 erscheint als weicher Paywall mit Trial-Angebot; kein Hard Block ohne Aktion |
| Pflanzenprofil-Limit erreicht (Freemium) | S009, S015, S014 | S009 zeigt Freemium-Limit-Erreicht-State; Hinweis auf gesperrte Slots; S015 mit Upgrade-CTA |
| KI-Identifikation schlägt fehl (API-Fehler) | S004, S011, S017 | S011 zeigt API-Fehler-Retry-Option; S017 als Overlay mit Kontext; Local-Model-Fallback aktiviert (offline oder API-Down) |
| KI-Ergebnis mit niedriger Konfidenz (<60%) | S004, S011 | S011 Niedrige-Konfidenz-State: Top-3-Alternativen anzeigen; Nutzer wählt manuell; Hinweis auf Unsicherheit klar kommuniziert |
| Keine Pflanze erkannt | S011 | S011 Keine-Pflanze-Erkannt-State: Hinweis auf bessere Aufnahmebedingungen (Licht, Abstand, Winkel); Re-Scan-CTA; kein Profil-Flow ausgelöst |
| Internetverlust während Scan | S004, S017 | S004 wechselt zu Offline-Fallback-Local-Model-State; S017 als dismissbares Overlay; Ergebnis mit Offline-Kennzeichnung in S011 |
| Internetverlust im Pflegeplan-Flow | S005, S006, S017 | S006 zeigt Wetter-Daten-Loading → Wetter-Fehler-Fallback; Pflegeplan wird ohne Wetterdaten generiert; S017 als Hinweis-Overlay |
| IAP-Kauf fehlgeschlagen | S014 | S014 IAP-Fehler-State: Klare Fehlermeldung, Retry-CTA, Support-Link; kein Premium-Status aktiviert; vorheriger State bleibt erhalten |
| IAP-Kauf erfolgreich, Premium nicht aktiviert (Restore-Problem) | S014, S013 | S014 zeigt Loading-State; Fallback: "Kauf wiederherstellen"-Option prominent; S013 zeigt Restore-Purchase-CTA |
| Deeplink-Ziel nicht mehr vorhanden (Pflanze gelöscht) | S016 | S016 Pflanze-Nicht-Mehr-Vorhanden-State: Hinweis + Redirect zu S008 (Home) oder S009 (Pflanzenliste) |
| Aufgabe via Deeplink bereits erledigt | S016 | S016 Aufgabe-Bereits-Erledigt-State: Positives Feedback-Element, CTA zu S008 oder S010 |
| App-Start erfordert Update (Force-Update) | S001 | S001 Update-Required-State: Blocker mit Store-Link, keine weitere Navigation möglich |
| Sehr langsame Verbindung | Alle Screens | Lade-Indikatoren (A003, A008) werden länger angezeigt; Fallback auf gecachte Daten (S017) |

### Phase-B Screens mit Platzhaltern (8 geplant)

| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S023 | Krankheitsdiagnose-Scanner | Spezialisierter Scan-Modus für Pflanzenkrankheiten und Schädlingserkennung | Coming Soon Badge auf Scanner-Screen mit Wartelist-CTA |
| S024 | Behandlungsplan-Screen | Detaillierter Behandlungsplan nach Krankheitsdiagnose mit Follow-up-Erinnerungen | Nicht sichtbar |
| S025 | Wachstums-Tracking-Timeline | Chronologisches Foto-Tracking des Pflanzenwachstums mit KI-Analyse | Locked-Card in Pflanzenprofil-Detail mit Premium-Teaser |
| S026 | Abo-Verwaltung-Screen | Verwaltung von Monats- und Jahresabonnements, Familienfreigabe | Einfaches Abo-Status-Element in Profil-Screen |
| S027 | Wetter-Pflegeempfehlungs-Detail | Detaillierte wetterbasierte Gieß- und Pflegeempfehlungen mit Forecast | Vereinfachtes Wetter-Widget auf Home-Dashboard |
| S028 | Community-Share-Screen | TikTok und Instagram Teilen-Flow für Pflanzenphotos und Diagnose-Ergebnisse | Einfacher Teilen-Button via iOS Share Sheet auf Scan-Ergebnis |
| S029 | A-B-Test-Variant-Manager | Internes Tool zur Steuerung von A-B-Tests für Onboarding und Paywall | Nicht sichtbar, Firebase Remote Config als Basis |
| S030 | Erweiterte-Pflanzenprofil-Details | Herkunft, Schwierigkeitsgrad, botanische Infos, erweiterte Giftigkeitswarnung | Einfacher Giftigkeits-Icon auf Pflanzenprofil-Detail S010 |

---

## 7. Asset-Liste (**VERBINDLICH**)

### Vollständige Asset-Tabelle (Auszug, vollständige Liste in `asset_register.csv`)

| ID | Name | Screen(s) | Kategorie | Quelle | Format | Priorität |
|---|---|---|---|---|---|---|
| A001 | App-Icon | Alle | App-Branding | Custom Design | PNG 1024x1024 + SVG | Launch-kritisch |
| A002 | Splash-Screen-Logo | S001 | App-Branding | Custom Design | SVG + PNG @1x/2x/3x | Launch-kritisch |
| A003 | Splash-Ladeanimation | S001 | Animationen & Effekte | Lottie (Custom) | .lottie / .json | Launch-kritisch |
| A004 | Onboarding-Hero-Illustration | S002 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A005 | Kamera-CTA-Button | S002, S004 | UI-Elemente | Custom Design | SVG + PNG @1x/2x/3x | Launch-kritisch |
| A006 | Kamera-Permission-Modal-Illustration | S003 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A007 | Scanner-Sucher-Rahmen | S004 | UI-Elemente | Custom Design | .lottie / .json | Launch-kritisch |
| A008 | KI-Processing-Animation | S004 | Animationen & Effekte | Lottie (Custom) | .lottie / .json | Launch-kritisch |
| A009 | Scan-Ergebnis-Einblend-Animation | S004, S011 | Animationen & Effekte | Lottie (Custom) | .lottie / .json | Launch-kritisch |
| A010 | Konfidenz-Anzeige-Visual | S011 | Datenvisualisierung | Custom Design | SVG (dynamisch befüllt) | Launch-kritisch |
| A011 | Pflanzen-Platzhalter-Illustration | S009, S010, S011 | Illustrationen | Free/Open-Source | SVG / PNG @2x | Launch-kritisch |
| A012 | Pflanzenprofil-Schritt-Indikatoren | S005 | UI-Elemente | Custom Design | SVG (Code-Komponente) | Launch-kritisch |
| A013 | Standort-Illustrations-Icons | S005 | UI-Elemente | Stock + Anpassung | SVG-Set | Launch-kritisch |
| A014 | Topfgrößen-Illustrations-Icons | S005 | UI-Elemente | Custom Design | SVG-Set | Launch-kritisch |
| A015 | Pflegeplan-Reveal-Konfetti-Animation | S006 | Animationen & Effekte | Lottie (Free) | .lottie / .json | Launch-kritisch |
| A016 | Pflegeaufgaben-Icons | S006, S008, S010, S016 | UI-Elemente | Free/Open-Source | SVG-Set | Launch-kritisch |
| A017 | Wetter-Icons | S006, S008, S010 | UI-Elemente | Free/Open-Source | SVG-Set | Launch-kritisch |
| A018 | Push-Permission-Modal-Illustration | S007 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A019 | Home-Dashboard-Leer-Illustration | S008 | Illustrationen | Free/Open-Source | SVG / PNG @2x | Launch-kritisch |
| A020 | Aufgabe-Erledigt-Animation | S008, S010, S016 | Animationen & Effekte | Lottie (Free) | .lottie / .json | Launch-kritisch |
| A021 | Alle-Aufgaben-Erledigt-Illustration | S008 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Nice-to-have |
| A022 | Pflanzenprofil-Karte-Thumbnail-Rahmen | S009, S008 | UI-Elemente | Custom Design | SVG (Code-Komponente) | Launch-kritisch |
| A023 | Pflanzen-Liste-Leer-Illustration | S009 | Illustrationen | Free/Open-Source | SVG / PNG @2x | Launch-kritisch |
| A024 | Freemium-Limit-Lock-Icon | S009, S010 | UI-Elemente | Free/Open-Source | SVG | Nice-to-have |
| A025 | Gesundheitsstatus-Indikator | S009, S010, S008 | Datenvisualisierung | Custom Design | SVG (Code-Komponente) | Nice-to-have |
| A026 | Giftigkeit-Warning-Icon | S010, S011 | UI-Elemente | Custom Design | SVG | Launch-kritisch |
| A027 | Pflegeplan-Timeline-Visual | S010, S006 | Datenvisualisierung | Custom Design | SVG (Code-Komponente) | Launch-kritisch |
| A028 | Scan-Ergebnis-Pflanzenkarte-Illustration | S011 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A029 | Keine-Pflanze-Erkannt-Illustration | S011 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A030 | Niedrige-Konfidenz-Alternativen-UI | S011 | UI-Elemente | Custom Design | SVG (Code-Komponente) | Nice-to-have |
| A031 | Auth-Screen-Hero-Visual | S012 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Nice-to-have |
| A032 | Social-Login-Provider-Icons | S012 | UI-Elemente | Free/Open-Source | SVG (offiziell) | Launch-kritisch |
| A033 | Profil-Avatar-Placeholder | S013 | UI-Elemente | Free/Open-Source | SVG / PNG @2x | Nice-to-have |
| A034 | Premium-Badge | S013, S014 | UI-Elemente | Custom Design | SVG + PNG @2x | Nice-to-have |
| A035 | Einstellungs-Icons | S013 | UI-Elemente | Free/Open-Source | SVG-Set | Nice-to-have |
| A036 | Paywall-Hero-Illustration | S014 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Nice-to-have |
| A037 | Premium-Feature-Icons | S014, S015 | UI-Elemente | Free/Open-Source + Anpassung | SVG-Set | Nice-to-have |
| A038 | IAP-Erfolgs-Animation | S014 | Animationen & Effekte | Lottie (Free) | .lottie / .json | Nice-to-have |
| A039 | Weicher-Paywall-Modal-Illustration | S015 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Nice-to-have |
| A040 | Deeplink-Aufgaben-Status-Icons | S016 | UI-Elemente | Custom Design | SVG + .lottie | Launch-kritisch |
| A041 | Offline-Fehler-Illustration | S017 | Illustrationen | Free/Open-Source | SVG / PNG @2x | Nice-to-have |
| A042 | DSGVO-Modal-Illustration | S018 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A043 | COPPA-Under13-Block-Illustration | S018 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A044 | Feedback-Sternebewertung-Visual | S019 | UI-Elemente | Custom Design | SVG (Code-Komponente) + .lottie | Nice-to-have |
| A045 | Feedback-Modal-Illustration | S019 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Nice-to-have |
| A046 | Debug-Overlay-Visual-Elemente | S020 | UI-Elemente | Custom Design | SVG / PNG | Nice-to-have |
| A047 | TestFlight-Beta-Banner-Visual | S021 | UI-Elemente | Custom Design | SVG / PNG @2x | Nice-to-have |
| A048 | Standort-Permission-Modal-Illustration | S022 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A049 | Tab-Bar-Icons | S008, S009, S004, S013 | UI-Elemente | Free/Open-Source + Anpassung | SVG-Set | Launch-kritisch |
| A050 | Navigation-Back-und-Close-Icons | Alle | UI-Elemente | Native / Free | SVG-Set | Launch-kritisch |
| A051 | Scan-Limit-Zähler-Visual | S004, S009 | Datenvisualisierung | Custom Design | SVG (Code-Komponente) | Nice-to-have |
| A052 | Wetter-Widget-Visual | S008, S006 | Datenvisualisierung | Custom Design | SVG (Code-Komponente) | Nice-to-have |
| A053 | Coming-Soon-Badge-Phase-B | S004 | UI-Elemente | Custom Design | SVG + PNG @2x | Nice-to-have |
| A054 | Pflanzenwachstums-Locked-Card-Visual | S010 | UI-Elemente | Custom Design | SVG + PNG @2x | Nice-to-have |
| A055 | Loader-Skeleton-Screens | S008, S009, S010, S006 | UI-Elemente | Custom Design | SVG (Code-Komponente) | Launch-kritisch |
| A056 | Haustier-Giftigkeit-Icon-Set | S010, S011 | UI-Elemente | Free/Open-Source + Anpassung | SVG-Set | Launch-kritisch |
| A057 | Schwierigkeitsgrad-Visual | S010, S011 | Datenvisualisierung | Custom Design | SVG (Code-Komponente) | Nice-to-have |
| A058 | Benachrichtigungs-Deeplink-Pflanzen-Hero | S016 | Illustrationen | AI-generiert + Nachbearbeitung | PNG @2x (dynamisch) | Nice-to-have |
| A059 | Onboarding-Hintergrund-Textur | S001, S002, S003, S005, S006 | App-Branding | Custom Design | SVG / PNG @2x | Nice-to-have |
| A060 | Pflanzennamen-Input-Illustration | S005 | Illustrationen | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Nice-to-have |
| A061 | Premium-Badge-Icon | S009, S010, S013, S014, S015 | Monetarisierungs-Assets | Custom Design | SVG + PNG @2x | Launch-kritisch |
| A062 | Paywall-Hero-Illustration | S014 | Monetarisierungs-Assets | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A063 | Feature-Vergleichs-Tabelle-Grafik | S014 | Monetarisierungs-Assets | Custom Design | SVG / PNG @2x | Launch-kritisch |
| A064 | Lock-Overlay-Icon | S009, S010, S006 | Monetarisierungs-Assets | Free/Open-Source + Anpassung | SVG | Launch-kritisch |
| A065 | Scan-Limit-Fortschrittsanzeige | S004, S009, S015 | Monetarisierungs-Assets | Custom Design | SVG (Code-Komponente) | Launch-kritisch |
| A066 | Free-Trial-Timer-Komponente | S013, S014 | Monetarisierungs-Assets | Custom Design | SVG (Code-Komponente) | Launch-kritisch |
| A067 | Preis-Pill-Komponente | S014 | Monetarisierungs-Assets | Custom Design | SVG (Code-Komponente) | Launch-kritisch |
| A068 | IAP-Erfolgs-Konfetti-Animation | S014 | Monetarisierungs-Assets | Lottie (Free) | .lottie / .json | Nice-to-have |
| A069 | Soft-Paywall-Illustration | S015 | Monetarisierungs-Assets | AI-generiert + Nachbearbeitung | SVG / PNG @2x | Launch-kritisch |
| A070 | Premium-Nutzer-Status-Banner | S013 | Monetarisierungs-Assets | Custom Design | SVG / PNG @2x | Nice-to-have |
| A071 | DSGVO-Consent-Screen-Illustration | S018 | Legal-UI | AI-generiert + Nachbearbeitung | static | Launch-kritisch |
| A072 | Consent-Toggle-Komponente | S018, S013 | Legal-UI | Custom Design | static | Launch-kritisch |
| A073 | COPPA-Altersverifikations-Illustration | S018, S012 | Legal-UI | AI-generiert + Nachbearbeitung | static | Launch-kritisch |
| A074 | Kamera-Permission-Erklär-Illustration | S003 | Legal-UI | Custom Design | static | Launch-kritisch |
| A075 | Push-Permission-Erklär-Illustration | S007 | Legal-UI | Custom Design | static | Launch-kritisch |
| A076 | Standort-Permission-Erklär-Illustration | S022 | Legal-UI | Custom Design | static | Launch-kritisch |
| A077 | Datenschutz-Einstellungs-Übersicht-Icons | S013 | Legal-UI | Custom Design | static | Launch-kritisch |
| A078 | App-Store-Screenshot-Set iOS | S004, S011, S006, S008, S010 | Marketing-Assets | Custom Design | static | Launch-kritisch |
| A079 | App-Store-Preview-Video-Storyboard | S004, S011, S006, S008, S016 | Marketing-Assets | Custom Design | dynamic | Launch-kritisch |
| A080 | App-Icon-Varianten-Set | S001 | Marketing-Assets | Custom Design | static | Launch-kritisch |
| A081 | TikTok-Share-Card-Template | S011 | Marketing-Assets | Custom Design | dynamic | Nice-to-have |
| A082 | Instagram-Share-Card-Template | S011, S010 | Marketing-Assets | Custom Design | dynamic | Nice-to-have |
| A083 | Landing-Page-Hero-Visual | - | Marketing-Assets | Custom Design | static | Launch-kritisch |
| A084 | Press-Kit-Illustration-Set | - | Marketing-Assets | Custom Design | static | Nice-to-have |
| A085 | Social-Media-Post-Template-Set | - | Marketing-Assets | Custom Design | static | Nice-to-have |
| A086 | Influencer-Brief-Visual-Mockup | - | Marketing-Assets | Custom Design | static | Nice-to-have |
| A087 | Beta-Feedback-Banner-Grafik | S021 | Marketing-Assets | Custom Design | static | Nice-to-have |
| A088 | App-Store-Feature-Grafik | - | Marketing-Assets | Custom Design | static | Nice-to-have |
| A089 | Bewertungs-Modal-Illustration | S019 | Marketing-Assets | Custom Design | static | Nice-to-have |
| A090 | Onboarding-Value-Proposition-Screens | S002 | Marketing-Assets | Custom Design | dynamic | Launch-kritisch |
| A091 | Waitlist-Signup-Confirmation-Grafik | - | Marketing-Assets | Custom Design | static | Nice-to-have |
| A092 | Social-Proof-Testimonial-Cards | - | Marketing-Assets | Custom Design | static | Nice-to-have |
| A093 | Push-Notification-Visuals | S016 | Marketing-Assets | Custom Design | static | Launch-kritisch |
| A094 | Giftigkeits-Warn-Icon-Set | S010, S011 | Legal-UI | Custom Design | static | Launch-kritisch |
| A095 | KI-Disclaimer-Komponente | S011, S010, S006 | Legal-UI | Custom Design | static | Launch-kritisch |
| A096 | Impressum-und-AGB-Screen-Layout | S013 | Legal-UI | Custom Design | static | Launch-kritisch |
| A097 | Daten-Löschungs-Bestätigungs-Modal | S013 | Legal-UI | Custom Design | static | Launch-kritisch |
| A098 | Drittanbieter-Transparenz-Liste | S013, S018 | Legal-UI | Custom Design | static | Launch-kritisch |
| A099 | Abo-Kündigung-Hinweis-Komponente | S014 | Legal-UI | Custom Design | static | Launch-kritisch |
| A100 | Offline-Status-Illustration | S017 | Marketing-Assets | Custom Design | static | Launch-kritisch |

### Beschaffungswege pro Asset (Zusammenfassung)
*   **Custom Design (Figma/Freelancer):** 38 Assets (ca. €2.540)
*   **AI-generiert + Nachbearbeitung:** 22 Assets (ca. €490)
*   **Free / Open-Source:** 16 Assets (€0)
*   **Lottie (Free Library):** 5 Assets (€0)
*   **Lottie (Custom):** 3 Assets (€240)
*   **Stock + Anpassung:** 3 Assets (€50)
*   **Native (SF Symbols / Material):** 2 Assets (€0)
*   **Gesamt (Richtwert):** 70 Einzel-Assets / 100 Listeneinträge (ca. €3.320)

### Format-Anforderungen pro Plattform

| Asset-Typ | Format | Auflösung/Größe | Tool | Hinweise |
|---|---|---|---|---|
| **unity_sprites** | PNG / Sprite Sheet | 2x Retina (@2x Basis, @3x für iPhone Pro) | TexturePacker | Power-of-2-Dimensionen bevorzugt (512x512, 1024x1024); keine .jpg für UI-Elemente mit Transparenz |
| **icons** | SVG | | Figma Export + SVGO-Optimierung | |
| **animations** | Lottie JSON (.lottie bevorzugt, .json als Fallback) | | After Effects + Bodymovin / LottieFiles Plugin | Statisches PNG @2x als Fallback |
| **app_icon_ios** | PNG | 1024x1024 Master (App Store) + automatische Ableitungen via Xcode Asset Catalog | Figma Export → Asset Catalog via makeappicon.com oder AppIconGenerator | Kein Text, kein Screenshot-Inhalt gemäß App Store Guidelines 4.0 |
| **app_icon_android** | PNG Adaptive Icon | | Android Studio Asset Studio oder Figma + Android Icon Template | |
| **screenshots_store** | PNG (bevorzugt) oder JPEG max. 85% Qualität | | Figma Device Mockup Templates + Screenshot-Automatisierung via fastlane snapshot | Kein bloß weißer/schwarzer Hintergrund; Brand-Farben nutzen; Textlayer separat halten für Lokalisierung |
| **illustrations** | SVG (bevorzugt für skalierbare Inhalte) + PNG @2x als Fallback | | Figma → SVG Export + SVGO-Optimierung (Level 2) | |
| **splash_screen** | SVG Logo-Anteil + Lottie-Animation + Solid Background via LaunchScreen.storyboard | | | |
| **fonts** | OTF bevorzugt, TTF akzeptiert — kein WOFF/WOFF2 für Native | | | GFS Didot (Google Fonts) als Primärfont, Inter als Body, JetBrains Mono für Code/Debug |
| **color_tokens** | JSON Color Tokens (Style Dictionary kompatibel) | | | |

### Plattform-Varianten Anzahl
*   **Gesamtanzahl Assets:** 100
*   **Plattform-Varianten gesamt:** 187 (inkl. iOS/Android-spezifische Anpassungen)

### Dark-Mode-Varianten
*   **Dark-Mode-Varianten nötig:** 84 (für alle Launch-kritischen Assets und UI-Elemente)

---

## 8. KI-Produktions-Warnungen (**VERBINDLICH — KRITISCH**)

### Warnungen aus dem Visual Audit
Diese Anweisungen müssen **direkt in die Prompts der Produktionslinie** eingefügt werden, um visuelle Inkonsistenzen und Abweichungen von der Design-Vision zu verhindern.

| # | Screen | Stelle | Was KI falsch macht | Was stattdessen | Prompt-Anweisung für Produktionslinie |
|---|---|---|---|---|---|
| 1 | S001 | Ladeanimation | Generiert statischen Text "Lädt..." | Visuelle Animation (z.B. wachsende Pflanze) | **VERBINDLICH:** "Sprite Sheet mit 12 Frames für Lottie-Animation A003 bereitstellen. KI darf NUR diese Animation verwenden. Kein statischer Text 'Lädt...' oder generischer Spinner." |
| 2 | S002 | Kamera-CTA | Generiert Text "Kamera öffnen" | Großes Kamera-Icon mit Scan-Rahmen | **VERBINDLICH:** "Button muss als Icon-Button A005 mit SVG-Pfad für Kamera-Symbol umgesetzt werden. Text-Override 'Kamera öffnen' deaktivieren. Keine Text-Buttons für primäre Aktionen." |
| 3 | S003 | Permission-Text | Generiert Text "Kamera-Zugriff erforderlich" | Illustration A006 mit Smartphone und Kamera-Linse | **VERBINDLICH:** "Illustration A006 als 2x Asset (light/dark) mit transparentem Hintergrund. KI darf Text nur als Overlay mit max. 20% Deckkraft rendern. Keine generischen System-Alerts." |
| 4 | S004 | Scanner-Rahmen | Generiert Text "Pflanze hierhin richten" | Animierter Sucher-Rahmen A007 (4 Ecken) | **VERBINDLICH:** "Rahmen als Lottie-Animation A007 mit 3 Zuständen: Ruhe, Scan-Start, Scan-Aktiv. KI darf NUR die Animation verwenden. Kein statischer Text 'Pflanze hierhin richten'." |
| 5 | S004 | KI-Processing | Generiert Text "KI analysiert Pflanze..." | Partikeleffekt A008 mit "Denkblasen" | **VERBINDLICH:** "Animation A008 als Sprite Sheet (16x16px Partikel) mit Transparenz. KI darf Text nur als Tooltip mit 3s Timeout anzeigen. Kein statischer Text 'KI analysiert Pflanze...' oder generischer Spinner." |
| 6 | S011 | Pflanzenkarte | Generiert Text "Ergebnis: Monstera" | Kartografische Illustration A028 mit Pflanze | **VERBINDLICH:** "Karte als Vektorgrafik A028 mit 3 Detailstufen (minimal/normal/erweitert). KI darf NUR die Grafik verwenden. Kein reiner Text für Scan-Ergebnisse." |
| 7 | S005 | Standort-Icons | Generiert Text "Nordfenster" etc. | 6 illustrierte Fensterrichtungen A013 | **VERBINDLICH:** "Icons A013 als separate SVG-Dateien mit 24x24px Baseline. KI darf Text nur als Tooltip mit Icon-Hover anzeigen. Keine Text-Labels für Standort-Auswahl." |
| 8 | S006 | Pflegeplan | Generiert Text "Giessen alle 3 Tage" | Visuelle Aufgaben-Icons A016 (Wasser, Dünger) | **VERBINDLICH:** "Icons A016 als animierte Lottie-Dateien (Wassertropfen füllt sich). KI darf Text nur als Label unter dem Icon anzeigen. Keine reinen Text-Listen für Pflegepläne." |
| 9 | S012 | Social-Login | Generiert Text "Mit Apple anmelden" | Offizielle Apple/Google-Logos A032 | **VERBINDLICH:** "Buttons als Image-Buttons A032 mit transparentem Hintergrund. KI darf Text NUR als Overlay mit 50% Deckkraft rendern. Keine Text-Buttons für Social Login." |
| 10 | S014 | Premium-Features | Generiert Text "Unbegrenzte Scans" etc. | Icon-Liste A037 mit Kronen/Schloss | **VERBINDLICH:** "Features als 32x32px Icons A037 mit goldener Akzentfarbe. KI darf Text nur als Tooltip mit Icon-Hover anzeigen. Keine reinen Text-Listen für Premium-Features." |
| 11 | S018 | DSGVO-Text | Generiert langen Fließtext | Schild-Illustration A042 mit Pflanze | **VERBINDLICH:** "Illustration A042 als 2x Asset mit 3 Varianten (Erstmalig/Wiederholung/COPPA). KI darf Text NUR als Collapsible Section anzeigen. Keine Textwand für DSGVO-Consent." |
| 12 | S007 | Push-Permission | Generiert Text "Push-Benachrichtigungen erlauben?" | Pflanze mit Glocken-Animation A018 | **VERBINDLICH:** "Illustration A018 als Lottie-Animation mit schwingenden Glocken. KI darf Text NUR als Overlay mit 30% Deckkraft rendern. Keine generischen System-Alerts für Push-Permission." |
| 13 | S015 | Limit-Erreicht-Modal | Generiert generische "Limit erreicht"-Illustration (A041) | Motivierende Belohnungsillustration A039 (z. B. "1 Scan kostenlos!") | **VERBINDLICH:** "Dedizierte Belohnungsillustration A039 mit Scan-Symbol und Pflanze. Keine generische 'Limit erreicht'-Illustration." |
| 14 | S026 | Abo-Verwaltungs-Übersicht | KI zeigt leere Tabellen oder generische Text-Listen ohne visuelle Hierarchie | Hero-Illustration A036 für Abo-Status oder Empty-State mit Illustration A021 | **VERBINDLICH:** "Hero-Illustration A036 für Abo-Status oder Empty-State mit Illustration A021. Keine leeren Tabellen oder generischen Text-Listen." |
| 15 | S013 | Premium-Badge | KI zeigt Standard-Profilbild oder leeren Platzhalter | Sichtbares Premium-Badge A034 oder Upgrade-CTA mit Icon A037 | **VERBINDLICH:** "Premium-Badge A034 oder 'Premium Upgrade'-CTA mit Icon A037. Keine leeren Platzhalter für Premium-Status." |
| 16 | S018 | COPPA-Under13 | KI zeigt generische "Zu jung"-Illustration (A043) | Altersgerechte, aber klare Block-Illustration A043 | **VERBINDLICH:** "Friendly but clear age-gate illustration A043 mit Eltern-Kind-Theme. Keine generische 'Zu jung'-Illustration." |
| 17 | S003/S022/S007 | Permission-Modals | KI zeigt Standard-Systemdialoge ohne Custom-Design | Custom Permission-Modals mit Pflanzendesign und freundlichen Illustrationen | **VERBINDLICH:** "Custom Permission-Modals mit Pflanzendesign und freundlichen Illustrationen (A006, A048, A018). Keine Standard-Systemdialoge." |
| 18 | S001 | Splash-Screen-Logo | Graue Box mit "Image" Text | A002 (Splash-Screen-Logo) mit Markenfarben und Wortmarke | **VERBINDLICH:** "A002 (Splash-Screen-Logo) mit Markenfarben und Wortmarke. Keine grauen Platzhalter." |
| 19 | S002 | Onboarding-Hero-Illustration | Graue Box mit "Placeholder" Text | A004 (Onboarding-Hero-Illustration) mit Nutzer-Pflanze-Theme | **VERBINDLICH:** "A004 (Onboarding-Hero-Illustration) mit Nutzer-Pflanze-Theme. Keine grauen Platzhalter." |
| 20 | S005 | Topfgroessen-Illustrations-Icons | Generische Icons (z. B. Kreise) | A014 (Topfgroessen-Illustrations-Icons) mit skalierten Topf-Illustrationen | **VERBINDLICH:** "A014 (Topfgroessen-Illustrations-Icons) mit skalierten Topf-Illustrationen. Keine generischen Icons." |
| 21 | S008 | Home-Dashboard-Leer-Illustration | Graue Box mit "Empty State" Text | A019 (Home-Dashboard-Leer-Illustration) mit Pflanzen-Theme | **VERBINDLICH:** "A019 (Home-Dashboard-Leer-Illustration) mit Pflanzen-Theme. Keine grauen Platzhalter." |
| 22 | S009 | Pflanzen-Liste-Leer-Illustration | Graue Box mit "Keine Pflanzen" Text | A023 (Pflanzen-Liste-Leer-Illustration) mit Kamera-CTA | **VERBINDLICH:** "A023 (Pflanzen-Liste-Leer-Illustration) mit Kamera-CTA. Keine grauen Platzhalter." |
| 23 | S010 | Pflanzenprofil-Karte-Thumbnail-Rahmen | Systemfarben (z. B. graue Karte) | A022 (Pflanzenprofil-Karte-Thumbnail-Rahmen) mit abgerundetem Design | **VERBINDLICH:** "A022 (Pflanzenprofil-Karte-Thumbnail-Rahmen) mit abgerundetem Design. Keine Systemfarben." |
| 24 | S012 | Auth-Screen-Hero-Visual | Graue Box mit "Hero Image" Text | A031 (Auth-Screen-Hero-Visual) mit Registrierungs-Mehrwert | **VERBINDLICH:** "A031 (Auth-Screen-Hero-Visual) mit Registrierungs-Mehrwert. Keine grauen Platzhalter." |
| 25 | S017 | Offline-Fehler-Illustration | Graue Box mit "Offline" Text | A041 (Offline-Fehler-Illustration) mit Pflanze und WLAN-Symbol | **VERBINDLICH:** "A041 (Offline-Fehler-Illustration) mit Pflanze und WLAN-Symbol. Keine grauen Platzhalter." |

### Warnungen aus der Design-Vision
Diese Anweisungen adressieren technische Herausforderungen bei der Umsetzung der Design-Vision und müssen **direkt in die Prompts der Produktionslinie** eingefügt werden.

| # | Screen | Standard den KI wählt | Was Design-Vision verlangt | Prompt-Anweisung |
|---|---|---|---|---|
| 1 | Alle | Generische Fotos für Pflanzen | **VERBINDLICH:** Kupferstich-Illustrationen (D01) | **VERBINDLICH:** "Implementiere ein Zwei-Ebenen-System für Pflanzenillustrationen: Top-100 Pflanzen erhalten dedizierte Kupferstich-SVGs (A028). Alle anderen Pflanzen nutzen ein generatives Kupferstich-System (CustomPainter Flutter-Widget) basierend auf Blattform-Daten aus der Botanik-API. KEINE Fotos als primäre Pflanzenvisualisierung." |
| 2 | Alle | System-Fonts (SF Pro, Roboto) | **VERBINDLICH:** GFS Didot als Primärschrift (D02) | **VERBINDLICH:** "Verwende GFS Didot (Google Fonts Flutter-Package) für alle Headlines und botanischen Namen. Bei fehlendem Heavy-Weight, nutze LibreCaslon oder EB Garamond als Fallback. KEINE serifenlosen Systemschriften für Headlines." |
| 3 | S004 | Pulsierender Rahmen im Scanner | **VERBINDLICH:** SVG `stroke-dashoffset`-Animation (D03) | **VERBINDLICH:** "Implementiere die Scanner-Animation A007/A008/A009 mit `flutter_svg` und `CustomPainter` für progressive Pfad-Zeichnung. Performance-Test auf Pixel 6a (Mid-Range-Referenzgerät) muss stabil 60fps liefern. Bei Performance-Problemen: Komplexität der Animation reduzieren, aber visuelles Prinzip der Kupferstich-Linien beibehalten. KEIN pulsierender Rahmen oder generischer Spinner." |
| 4 | iOS Dynamic Island | Kein Dynamic Island Support | **VERBINDLICH:** Lebende Pflanze im Dynamic Island (D07) | **VERBINDLICH:** "Implementiere native Swift Live Activity + Dynamic Island Integration via Platform Channel für iOS. Für Android-Parität: Persistent Notification mit botanischer Kupferstich-Illustration im Large-Format (Android 12+ Notification Styles) und Android-Widget (4x1 Homescreen) mit welkender Pflanzen-SVG-Animation via Glance API." |
| 5 | S001 | Schwarzer/weißer Splash-Screen | **VERBINDLICH:** Pergament-Elfenbein `#F5EDD6` (A01) | **VERBINDLICH:** "Der Splash-Screen S001 muss sofort mit der Hintergrundfarbe Pergament-Elfenbein `#F5EDD6` erscheinen. KEIN weißer oder schwarzer Flash. Die Splash-Ladeanimation A003 muss organisch auf diesem Hintergrund ablaufen." |
| 6 | S003 | Generisches Modal-Design | **VERBINDLICH:** Pergament-Modal das sich aufrollt | **VERBINDLICH:** "Implementiere das Kamera-Permission-Modal S003 als 'aufgerolltes Pergament' mit 3D-Transform-Animation. Die Papier-Textur muss als subtiles, statisches SVG-Noise-Pattern (nicht PNG) im Hintergrund des Modals implementiert werden. Auf Low-End-Geräten (RAM < 3GB) wird der Textur-Layer automatisch deaktiviert." |
| 7 | Alle | Bottom-Tab-Bar | **VERBINDLICH:** Gesture-First Navigation (D04) | **VERBINDLICH:** "Implementiere KEINE persistente Bottom-Tab-Bar. Die Navigation zwischen Hauptbereichen erfolgt über Swipe-Gesten (PageView oder custom GestureDetector). Beim allerersten App-Start erscheint EINMALIG ein subtiler Swipe-Hint (3 Punkte mit Pfeil, 2s sichtbar, dann fade-out). Im Sidebar (Drag-to-open) sind alle Hauptbereiche als Fallback-Navigation gelistet. Accessibility für Screen-Reader muss über Hidden Buttons gewährleistet sein." |
| 8 | Alle | Standard-Sound-Design | **VERBINDLICH:** Organische Sound-Palette | **VERBINDLICH:** "Verwende `just_audio` Flutter-Package für alle Sounds. Sound-Assets als `.ogg` für Android und `.caf` für iOS. Maximale Sound-Latenz-Toleranz: 80ms nach Touch-Event. Alle Sounds sind organisch (Buchaufschlagen, Gitarren-Akkord) und respektieren den System-Lautlos-Modus. KEINE Synthesizer oder digitalen Beep-Töne." |

---

## 9. Legal-Anforderungen für Produktion

### Consent-Screens (DSGVO, ATT)
*   **DSGVO-Onboarding-Modal (S018):** **VERBINDLICH**
    *   Muss beim allerersten App-Start erscheinen, **bevor** jegliche Datenverarbeitung stattfindet.
    *   Enthält eine vertrauensbildende Illustration (A042) und einen kurzen, persönlichen Text.
    *   Optionen für granulare Einwilligung (z.B. für ML-Training, Analytics) müssen vorhanden sein.
    *   Muss einen Hard Block für die App-Nutzung implementieren, wenn der Basis-Consent abgelehnt wird.
*   **Kamera-Permission-Modal (S003):** **VERBINDLICH**
    *   Erscheint vor dem ersten Scan-Versuch.
    *   Custom-Design mit Illustration (A006) und kurzem, ehrlichem Text.
    *   Erklärt den Zweck der Kamera-Nutzung klar.
*   **Standort-Permission-Modal (S022):** **VERBINDLICH**
    *   Erscheint vor der Generierung des ersten Pflegeplans mit Wetterdaten.
    *   Custom-Design mit Illustration (A048) und Erklärung des Nutzens (wetterbasierte Empfehlungen).
    *   Bietet PLZ-Fallback, wenn Standortzugriff abgelehnt wird.
*   **Push-Notification-Einwilligungs-Modal (S007):** **VERBINDLICH**
    *   Erscheint nach dem Pflegeplan-Reveal (S006), im Moment des höchsten empfundenen Nutzens.
    *   Custom-Design mit Illustration (A018) und persönlich formulierter Frage.
    *   Die Ablehn-Option ist als "Nicht jetzt" formuliert, um die Tür offen zu lassen.
*   **ATT (App Tracking Transparency) für iOS:** **VERBINDLICH**
    *   Der ATT-Prompt muss vor dem ersten Tracking-Event (z.B. Firebase Analytics) angezeigt werden.
    *   Der Zeitpunkt der Anzeige muss optimiert werden, um die Opt-in-Rate zu maximieren (z.B. nach dem ersten erfolgreichen Scan oder Pflegeplan-Reveal).

### Age-Gate / COPPA
*   **COPPA-Under13-Block (S018, S012):** **VERBINDLICH**
    *   Muss eine Altersverifikation implementieren, die Nutzer unter 13 Jahren (für US-Markt) blockiert.
    *   S018 zeigt einen Hard Block mit altersgerechter, aber klarer Illustration (A043) und Elternteil-Hinweis.
    *   Keine Datenerfassung oder -verarbeitung für Nutzer unter 13 Jahren.

### Datenschutz
*   **Datenkategorien:** **VERBINDLICH**
    *   **Kameradaten:** Fotos von Pflanzen (potenziell auch Innenräume, Gesichter im Hintergrund).
    *   **Standortdaten:** PLZ-Ebene (manuell eingegeben) für Wetter-API. KEINE GPS-basierte Ortung in Phase 1.
    *   **Nutzungsprofile:** Pflanzenbestand, Routinen, Geo-basierte Klimadaten.
    *   **ML-Trainingsdaten:** **VERBINDLICH:** KEINE Nutzer-Uploads für ML-Training in Phase 1. Plant.id API als alleinige KI-Basis. Eigene Trainingsdaten erst ab Phase 2 mit vollständig aufgesetztem, granularem Einwilligungsprozess.
*   **DSFA (Datenschutz-Folgenabschätzung):** **VERBINDLICH**
    *   Eine DSFA ist bei systematischer Verarbeitung von Standortdaten in Kombination mit Nutzerprofilen sehr wahrscheinlich verpflichtend. Muss vor Launch erstellt werden.
*   **AVV-Verträge:** **VERBINDLICH**
    *   Auftragsver