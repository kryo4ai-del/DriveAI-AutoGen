# Creative Director Technical Roadbook: MemeRun 2026
## Version: 1.0 | Status: VERBINDLICH fuer alle Produktionslinien

---

## 1. Produkt-Kurzprofil

**App Name:** MemeRun 2026

**One-Liner:** Ein dynamischer Endless-Runner, der aktuelle, AI-generierte Meme-Inhalte direkt ins Smartphone bringt und durch sofort teilbare Fail-Clips viralen Social Buzz erzeugt.

**Plattformen:** iOS und Android (Native Apps, entwickelt mit Unity)

**Tech-Stack:**
*   **Game Engine:** Unity (C#)
*   **Backend:** Google Firebase (Authentication, Firestore/Realtime Database, Storage, Cloud Messaging, Analytics, Performance Monitoring)
*   **Monetarisierung:** Unity IAP (für In-App Purchases), Google AdMob (für Rewarded Ads)
*   **Testing:** Unity Test Framework (intern), XCUITest Golden Gates (iOS), JUnit (Android)

**Zielgruppe:**
*   **Alter:** 18–34 Jahre
*   **Region:** Global, mit besonderem Fokus auf Nordamerika, Westeuropa und ausgewählte asiatische Märkte.
*   **Profil:** Casual Gamer, der kurze, humorvolle Spielsessions bevorzugt und aktiv Social Media nutzt (TikTok, Reels).

---

## 2. Design-Vision (VERBINDLICH)

### Design-Briefing
MemeRun 2026 entführt den Nutzer in einen dynamischen und humorvollen Endlos-Runner, der durch fließende 3D-Parallax-Elemente, interaktive Mikroanimationen und AI-generierte, sich ständig verändernde Hintergründe überzeugt. Jedes Detail – von den sanften Seifenblasen-Effekten bei der Navigation bis zu den humorvollen Reactions im Fail-Modal – ist darauf ausgelegt, dem User ein immersives und unvergessliches Erlebnis zu garantieren. Die App kombiniert futuristische Neon-Ästhetik mit organischen, verspielten Akzenten, die ein energiegeladenes, meme-inspiriertes Gesamterlebnis schaffen. Bei jedem Tap, Swipe oder schnellen Gestenerlebnis erhält der User taktiles, visuelles und akustisches Feedback, das den Spaß und die Emotionen verstärkt. MemeRun 2026 positioniert sich so als einzigartiger, viraler Blickfang in einem ansonsten eintönigen Genre und setzt neue Standards hinsichtlich visueller Dynamik und interaktiver Überraschungsmomente. Dieses Dokument definiert alle visuellen, haptischen und funktionalen Designentscheidungen verbindlich für die Produktionslinie.

### Emotionale Leitlinie pro App-Bereich (PFLICHT)
| Bereich                    | Emotion                               | Energie | Beschreibung                                                                                                                                                         |
|----------------------------|---------------------------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Onboarding                 | Begeisterung & Neugier                | 7/10    | Der Nutzer wird sofort in eine interaktive, humorvolle Welt gezogen, in der dynamische Animationen und sanfte Übergänge Lust auf mehr machen.                        |
| Core Loop (Gameplay)       | Adrenalin & Immersion                 | 9/10    | Fließende 3D-Übergänge, knackiges Sprungfeedback und überraschende visuelle Effekte erzeugen einen durchgehenden Energieschub.                                          |
| Reward / Ergebnis          | Stolz & Freude                        | 8/10    | Erfolge und Highscores werden mit aufsteigenden Animationen sowie freudigen Soundeffekten zelebriert, was jeden Erfolg zum Triumph werden lässt.                     |
| Shop / Monetarisierung     | Neugier & spielerische Experimentierfreude | 7/10 | Die Shop-Oberfläche setzt auf interaktive, pulsierende Seifenblasen-Effekte bei Buttons, die dezent hervorheben und zum Erkunden einladen.                             |
| Social / Challenges        | Viraler Spaß & Gemeinschaftsgefühl    | 8/10    | Humorvolle Mikroanimationen und dynamische Übergänge bei Social-Features fördern ein unmittelbares Gemeinschaftsgefühl und laden zum Teilen der Erlebnisse ein.        |
| Story / Narrative          | Verspielt & locker                    | 6/10    | Leichte, humorvolle Illustrationen und subtile Animationen unterstützen eine narrative Begleitung, die für eine unbeschwerte Atmosphäre sorgt.                        |
| Settings / Legal           | Ruhe & Vertrautheit                   | 5/10    | Klare, neutrale Gestaltung mit dezenten Animationen verleiht administrativen Bereichen wie Settings einen beruhigenden und vertrauensvollen Charakter.              |

### Differenzierungspunkte (PFLICHT — mindestens 3)
| # | Differenzierung               | Beschreibung                                                                                                                                                                                                                                                                                           | Betroffene Screens                   | Status                |
|---|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|-----------------------|
| 1 | Dynamische 3D-Parallax-Elemente | Einsatz von 3D-Parallax-Scrolls bei der Level- und Spielauswahl: Mehrere Ebenen (Hintergrund, mittlerer Bereich, Vordergrund) bewegen sich mit individuellen Geschwindigkeiten. Zusätzlich werden nahtlose 3D-Übergänge zwischen Gameplay und Menüs implementiert, um tiefen visuellen Eindruck zu hinterlassen.      | S004 (Main Menu), S005 (Game Screen), S007 (Leaderboard) | **VERBINDLICH**           |
| 2 | Interaktive, humorvolle Mikroanimationen   | Bei Fehlversuchen oder besonderen In-Game-Ereignissen wird eine kurze, humorvolle Mikroanimation (z. B. cartoonhafte Reaktionen, aufspringende Meme-Charaktere) eingeblendet, die durch präzises Haptic-Feedback und kurze Soundeffekte unterstützt wird – ideal für virale Social-Media-Momente.        | S005 (Game Screen), S006 (Pause/Fail Modal) | **VERBINDLICH**           |
| 3 | Immersive, dynamisch geladene Meme-Hintergründe | Einsatz von *extern generierten, dynamisch geladenen* Meme-Hintergründen, die sich in Echtzeit basierend auf Spielerfortschritt und -performance ändern. Die Hintergründe kombinieren visuelle Meme-Elemente mit subtilen Farbverläufen und variierenden Szenen, um einen hohen Wiedererkennungswert zu erzielen.                           | S004 (Main Menu), S005 (Game Screen)  | **VERBINDLICH**           |
| 4 | Innovatives, alternatives Navigationskonzept | Entwicklung einer schwebenden, kontextsensitiven Navigationsleiste, die per Gestensteuerung in den Vordergrund rückt. Sie reagiert mit transparenten, dynamischen Effekten beim Scrollen, Tippen und Swipen – und vermeidet so den klassischen, starren Bottom-Tab-Bar-Standard.                   | Alle, v.a. S004, S007, S008, S009 | **VERBINDLICH**           |

### Anti-Standard-Regeln (VERBOTENE – mindestens 4)
| # | VERBOTEN                              | STATTDESSEN                                                                                                         | Betroffene Screens                 | Begründung                                                                                              |
|---|---------------------------------------|----------------------------------------------------------------------------------------------------------------------|------------------------------------|---------------------------------------------------------------------------------------------------------|
| 1 | Flaches Card-Grid für Level-Auswahl   | Dynamische 3D-Parallax-Scroll-Ansicht, bei der Level in verschiedenen Tiefen dargestellt werden.                      | S005, S007                         | Erzeugt visuellen Tiefgang und hebt sich vom einheitlichen Look ab.                                     |
| 2 | Standard Bottom-Tab-Bar (5 Icons)      | Schwebende, kontextadaptive Navigationsleiste mit Gestensteuerung und dynamischer Transparenz.                            | Alle                               | Vermeidet den Standard-Look und bietet eine interaktive, moderne Navigation.                           |
| 3 | Weißer/heller, statischer Hintergrund   | Dynamisch geladene, Meme-basierte Hintergründe mit variierenden Meme-Elementen und Farbverläufen.                          | Alle, v.a. S004 und S005            | Sicherstellung eines hohen Wiedererkennungswerts und kontinuierlichen "Wow"-Effects.                     |
| 4 | Statische Screen-Übergänge             | Nahtlose, animierte Übergänge mit 3D-Elementen und fließenden Parallax-Effekten, die die Screens visuell miteinander verbinden. | Alle                               | Schafft ein flüssiges, immersives Nutzererlebnis, das im Markt einzigartig ist.                          |

### Wow-Momente (PFLICHT-IMPLEMENTIERUNG – mindestens 3)
| # | Name                                     | Screen                             | Was passiert                                                                                                                                                             | Warum kritisch                                                                                          |
|---|------------------------------------------|------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| 1 | 3D-Parallax-Scroll                       | S004 (Main Menu), S005 (Game Screen) | Beim Scrollen bewegen sich Hintergrund-, Mittel- und Vordergrund mit unterschiedlichen Geschwindigkeiten – eine visuelle Tiefe, die den User staunen lässt.             | Schafft den „Wow-Effekt“ und ist essenziell, um sich vom Standard abzuheben und virale Momente zu triggern.|
| 2 | Humorvolle Mikroanimation bei Fail       | S005 (Game Screen), S006 (Pause/Fail Modal)       | Bei jedem Fehlschlag erscheint eine kurze, cartoonhafte Animation (z. B. ein Meme-Charakter reagiert übertrieben), begleitet von präzisem Haptic-Feedback und Sound. | Erhöht den Wiedererkennungswert und fördert das Teilen von In-Game-Erlebnissen in sozialen Netzwerken.     |
| 3 | Dynamisch geladene Meme-Hintergründe   | S004 (Main Menu), S005 (Game Screen)  | Hintergründe verändern sich in Echtzeit, setzen visuelle Meme-Elemente in Szene und vermeiden so jede Wiederholung – der User erlebt stets ein neues visuelles Spektakel. | Verleiht der App ein einzigartiges, sich ständig wandelndes visuelles Profil, das für virale Shares sorgt. |

### Interaktions-Prinzipien (PFLICHT)
*   **Touch-Reaktion:** Jeder Tap löst ein präzises Haptic-Feedback aus (z. B. 50ms leichte Vibration) und eine dezente visuelle Seifenblasen-Expansion (300ms ease-out) aus.
*   **Animations-Prinzip:** Nahtlose 3D-Übergänge und fließende Parallax-Effekte sind Pflicht – alle Animationen müssen flüssig mit mindestens 60fps laufen.
*   **Feedback-Prinzip:** Jede Interaktion (Button-Tap, Swipe, Modal-Öffnung) wird durch abgestimmte visuelle, haptische und akustische Signale begleitet.
*   **Sound-Prinzip:** Dynamische Hintergrundmusik und kurze, prägnante Soundeffekte (z. B. "Ding", "Whoosh", "Plopp") unterstreichen jede Aktion und passen sich dem jeweiligen emotionalen Kontext an.

---

## 3. Stil-Guide (VERBINDLICH)

### Farbpalette
| Name | Hex | Verwendung |
|---|---|---|
| Vibrant Orange | `#FF5722` | Hauptfarbe für Buttons, Links und Akzente in der App |
| Bright Blue | `#03A9F4` | Sekundäre Elemente und Info-Buttons, unterstützt visuelle Hierarchien |
| Amber Gold | `#FFC107` | Hervorhebungen und besondere Markenelemente, die die Dynamik des Spiels unterstreichen |
| background_light | `#FFFFFF` | Hintergrundfarbe im Light Mode, sorgt für Klarheit und Lesbarkeit |
| background_dark | `#121212` | Hintergrundfarbe im Dark Mode, bietet hohen Kontrast und visuelle Tiefe |
| success | `#27ae60` | Indikator für erfolgreiche Aktionen und positive Zustände |
| warning | `#f39c12` | Warnhinweise und aufmerksamkeitsstarke Elemente |
| error | `#e74c3c` | Fehlermeldungen und kritische Benachrichtigungen |
| text_primary | `#212121` | Haupttextfarbe für Lesbarkeit und klare Informationsvermittlung |
| text_secondary | `#757575` | Sekundärtexte und unterstützende Informationen |

### Typografie
| Font | Verwendung | Gewicht | Lizenz |
|---|---|---|---|
| Montserrat | Headings, Title und wichtige UI-Texte, die Wiedererkennungswert besitzen | 600-700 | Google Fonts (Open Font License) |
| Roboto | Hauptkörpertexte, Beschreibungen und allgemeine UI-Elemente | 400-500 | Google Fonts (Apache License, Version 2.0) |
| Roboto Mono | Anzeige von Daten, Scores und technischen Informationen |  | Google Fonts (Apache License, Version 2.0) |

### Illustrations-Stil
*   **Stil:** Flat und minimalistisch
*   **Beschreibung:** Verwendet flache Vektorillustrationen mit vereinfachten Formen und leuchtenden Farben. Der Stil kombiniert verspielte Elemente mit einem modernen, reduzierten Design, um die Dynamik eines Endless-Runner-Spiels widerzuspiegeln.
*   **Begruendung:** Die minimalistische und dennoch lebendige Illustration unterstützt das schnelle Gameplay und die jugendliche Zielgruppe, während sie zur sofortigen Markenwiedererkennung beiträgt.

### Icon-System
*   **Stil:** Flach, linienbasiert und minimalistisch
*   **Library:** Material Icons (angepasst an die Markenidentität)
*   **Grid:** 24x24

### Animations-Stil
*   **Default Duration:** 300ms
*   **Easing:** ease-in-out
*   **Max Lottie:** 500 KB
*   **Static Fallback:** **VERBINDLICH** (Ja, für alle Animationen)

---

## 4. Feature-Map

### Phase A — Soft-Launch MVP (20 Features)
**Budget:** 252,500 EUR (Gesamtbudget für Phase A, inklusive Entwicklung, Marketing, Compliance)
*Hinweis: Die "Wochen" in dieser Tabelle repräsentieren den geschätzten Entwicklungsaufwand pro Feature für einen einzelnen Entwickler. Die DriveAI Factory wird diese Features durch Parallelisierung und Automatisierung innerhalb des vorgegebenen Zeitrahmens von 4-8 Wochen "Factory Time" umsetzen.*

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten |
|---|---|---|---|---|---|
| F001 | Endless-Runner Core Loop | Klassische Endless-Runner-Mechanik mit kontinuierlichem Vorwärtslauf, Hindernissen und Meme-Sammeln. | D1, D7, Session-Dauer, Sessions_pro_Tag | 8 |  |
| F002 | Tap-to-Jump Mechanik | Einfache Steuerung durch Tippen auf den Bildschirm zum Springen des Charakters. | D1, D7, Session-Dauer | 4 | F001 |
| F003 | Swipe-to-Direction Mechanik | Swipe-Gesten zur Steuerung der Laufrichtung (links/rechts). | D1, D7 | 3 | F001 |
| F007 | Tutorial-Phase | Kurze Einführungsphase zur Vermittlung der Steuerungsmechaniken (Tap/Swipe). | D1, Session-Dauer | 2 | F001 |
| F008 | High-Score-System | Speicherung und Anzeige von Bestleistungen (z.B. Meme-Anzahl, Distanz) in Leaderboards. | D1, D7, Sessions_pro_Tag | 3 | F001 |
| F009 | Session-Dauer-Limit | Automatische Beendigung der Session nach ca. 10 Minuten für kurze Spielrunden. | Session-Dauer | 1 | F001 |
| F012 | Free-to-Play Modell (Basis) | Grundspiel kostenlos mit optionalen In-App-Käufen für Premium-Inhalte. | Revenue | 2 |  |
| F013 | IAP System (inkl. Compliance) | Mikrotransaktionen für Cosmetics, Charaktere, Power-Ups oder exklusive Meme-Pakete, compliant mit App Store Richtlinien. | Revenue | 4 | F012 |
| F014 | Ad Integration (inkl. Compliance) | Optionale Werbeanzeigen für Belohnungen (z.B. zusätzliche Memes oder Power-Ups), compliant mit App Store Richtlinien. | Revenue | 3 | F012 |
| F018 | Cloud-Save-System | Speicherung von Fortschritt, Highscores und Battle-Pass-Fortschritt in der Cloud (Firebase). | D7, D30 | 3 | F029 |
| F019 | Cross-Platform-Support | Unterstützung für iOS und Android (Unity). | Sessions_pro_Tag | 4 |  |
| F021 | Datenschutz-Compliance (Allgemein) | Einhaltung von DSGVO, COPPA und regionalen Datenschutzbestimmungen (allgemeine Mechanismen). | Legal | 6 |  |
| F023 | Server-Infrastruktur (Firebase) | Skalierbare Backend-Lösung für Nutzerdaten, Leaderboards und Content-Verwaltung (Firebase Firestore/Realtime Database). | Crash_Rate, KI_Latency | 8 |  |
| F029 | Nutzer-Authentifizierung | Sichere Anmeldung über Plattformen wie Google, Apple oder anonyme Accounts (Firebase Authentication). | D1, D7 | 3 |  |
| F032 | Performance-Tracking | Echtzeit-Überwachung von Spielperformance und Nutzerengagement (Firebase Performance Monitoring). | Crash_Rate, Session-Dauer | 2 | F023 |
| F036 | Nutzerfeedback-System | In-Game-Umfragen oder Feedback-Tools zur Sammlung von Nutzermeinungen (Firebase Remote Config). | Nutzerbindung | 2 | F029 |
| F047 | DSGVO-Consent-Management | Einwilligungsprozesse für Datenerhebung und -verarbeitung gemäß DSGVO. | Legal | 3 | F021 |
| F048 | COPPA-Compliance | Sicherstellung der Einhaltung des Children’s Online Privacy Protection Act (COPPA) für Nutzer unter 13 Jahren. | Legal | 2 | F021, F047 |
| F049 | Jugendschutzmechanismen (USK/PEGI) | Implementierung von Altersbeschränkungen (z.B. ab 16+) und Inhaltswarnungen für Social Features. | Legal | 2 | F021 |
| F062 | Datenschutzerklärung & Einwilligungsmanagement | Klare und transparente Datenschutzerklärung mit Optionen zur Einwilligung in Datenverarbeitung (UI-Implementierung). | Legal | 2 | F047 |

### Phase B — Full Production (36 Features)
*Hinweis: Diese Features werden nach erfolgreichem Soft Launch und unter Berücksichtigung der Factory-Kapazitäten umgesetzt. AI-Features werden auf die Nutzung von extern generierten, kuratierten Inhalten beschränkt.*

| ID | Feature | Beschreibung | KPI-Impact | Wochen | Abhaengigkeiten |
|---|---|---|---|---|---|
| F004 | Dynamisch geladene Meme-Integration | Integration von extern generierten, kuratierten Meme-Assets, die dynamisch aus Firebase Storage geladen werden. | Nutzerbindung, Session-Dauer | 4 | F023 |
| F005 | Dynamische Meme-Aktualisierung | Regelmäßige Updates der Meme-Inhalte basierend auf externen Trends und manueller Kuration, bereitgestellt über Firebase. | Nutzerbindung, Session-Dauer | 3 | F004 |
| F006 | Fail-Clip-Erfassung | Automatische Aufzeichnung von Spiel-Fehlern oder Highlight-Momenten für Social Sharing (lokale Speicherung). | Social_Sharing, Nutzerbindung | 2 | F001 |
| F010 | Charakter-Auswahl | Auswahl verschiedener Charaktere mit unterschiedlichen Designs (IAP-basiert). | Nutzerbindung, IAP_Conversion | 3 | F013 |
| F011 | Power-Up-System | Temporäre Boosts oder Fähigkeiten (z.B. Magnet für Memes, Unsterblichkeit) (IAP-basiert). | Session-Dauer, IAP_Conversion | 4 | F013 |
| F015 | Battle Pass-System | Saisonales Belohnungssystem mit exklusiven Inhalten und Fortschrittsbalken (IAP-basiert, Fortschritt in Firebase). | Retention, Revenue | 6 | F013 |
| F016 | Saisonale Inhalte | Regelmäßige Updates mit neuen Memes, Charakteren oder Events für den Battle Pass (Firebase-basiert). | Nutzerbindung, Retention | 3 | F015 |
| F017 | Social Sharing (TikTok/Reels) | Direkte Integration zum Teilen von Fail-Clips oder Highlight-Momenten auf Social Media (lokale Clips). | Viralität, Nutzerbindung | 3 | F006 |
| F020 | Performance-Optimierung für Android | Anpassungen für Gerätefragmentierung und schwächere Hardware. | Crash_Rate, Session-Dauer | 4 | F019 |
| F022 | Lokalisierungs-System | Sprach- und kulturelle Anpassung für verschiedene Regionen (z.B. Memes, UI-Elemente). | Nutzerbindung, Retention | 5 | F019 |
| F026 | Full Launch | Globaler Markteintritt mit optimiertem Gameplay, stabiler Server-Infrastruktur und vollem Funktionsumfang. | Globaler Erfolg | 0 | F025 (Prozess) |
| F027 | Nutzersegmentierung | Analyse von Nutzerverhalten zur Anpassung von Monetarisierung und Content (Firebase Analytics). | Monetarisierung, Retention | 3 | F032 |
| F028 | Event-System | Regelmäßige In-Game-Events mit begrenzten Meme-Sets oder Challenges (Firebase-basiert). | Nutzerbindung, Retention | 4 | F015 |
| F030 | Push-Benachrichtigungen | Erinnerungen an Sessions, neue Memes oder Battle-Pass-Updates (Firebase Cloud Messaging). | Retention, Sessions_pro_Tag | 2 | F029 |
| F031 | Community-Features | Integration von Nutzer-generierten Inhalten oder Community-Challenges (Firebase-basiert). | Nutzerbindung, Retention | 5 | F029 |
| F033 | KI-Content-Moderation | Manuelle Moderation und Filterung von unangemessenen oder urheberrechtlich geschützten *extern generierten* Memes. | Legal, Nutzerbindung | 4 | F004 |
| F034 | Glücksspielmechanik (regelkonform) | Implementierung von Belohnungssystemen ohne Zufallsmechaniken, die als "glücksspielähnlich" interpretiert werden könnten. | Revenue | 5 | F013 |
| F035 | Exklusive Content-Pakete | Premium-Inhalte wie limitierte Meme-Sets oder Charaktere (IAP-basiert). | IAP_Conversion, Revenue | 3 | F013 |
| F037 | Multiplayer-Ranking | Weltweite oder regionale Leaderboards für Bestleistungen (Firebase Realtime Database). | Nutzerbindung, Retention | 4 | F008 |
| F038 | Nutzerprofil-System | Persönliche Profile mit Statistiken, Freunden und Social-Media-Integration (Firebase Firestore). | Nutzerbindung, Retention | 3 | F029 |
| F039 | Dynamische Meme-Themen | Dynamische Auswahl von Meme-Themen basierend auf externen Trends oder Nutzerpräferenzen (Firebase-basiert). | Nutzerbindung, Session-Dauer | 3 | F004 |
| F040 | Fail-Clip-Editor | Einfacher In-Game-Editor zum Zuschneiden oder Hinzufügen von Effekten zu Fail-Clips (lokal). | Social_Sharing, Nutzerbindung | 2 | F006 |
| F043 | Loot Box / Zufallsmechanik Compliance | Sicherstellung der Regelkonformität von Belohnungssystemen (keine zufallsbasierten Loot Boxes). | Legal, Revenue | 6 | F034 |
| F044 | App Store Richtlinien Compliance | Transparente Kommunikation von In-App Purchases, Werbung und Content in App Store Beschreibungen. | Legal | 2 |  |
| F045 | Dynamischer Meme-Content Filter | Mechanismus zur Filterung fehlerhafter oder inkohärenter *extern generierter* Inhalte (manuelle Review-Option). | Legal, Nutzerbindung | 3 | F033 |
| F046 | Urheberrechtsdokumentation für Meme-Assets | Dokumentation der Quellen und Lizenzbedingungen für *extern generierte* Meme-Assets. | Legal | 4 |  |
| F050 | Social Sharing Features | Direkter Export und Teilen von In-Game-Clips auf TikTok, Instagram Reels oder YouTube Shorts. | Viralität, Nutzerbindung | 2 | F017 |
| F051 | Community-Hub (Landing Page) | Landing Page mit integriertem Community-Bereich (Foren, Discord-Link) und Waitlist-Registrierung. | Nutzerbindung, Marketing | 4 |  |
| F053 | Press Kit | Bereitstellung von Press-Materialien (Press-Release, Fact-Sheet, Artwork) für Medien und Influencer. | Marketing | 2 |  |
| F054 | In-Game Event System | Zeitlich begrenzte In-Game-Events (z.B. Battle Pass-Challenges) zur Steigerung der Nutzerbindung. | Nutzerbindung, Retention | 4 | F028 |
| F055 | Cross-Platform Leaderboards | Globale Leaderboards für Bestenlisten und Wettbewerbe zwischen Nutzern (Firebase). | Nutzerbindung, Retention | 3 | F008 |
| F056 | Social Media Teaser Kampagne | Vorbereitung und Durchführung von Teaser-Kampagnen auf TikTok, Instagram, YouTube Shorts und Twitter. | Marketing | 2 |  |
| F057 | Influencer Marketing Plattform | Identifikation, Ansprache und Management von Micro- und Mid-Tier Influencern für Kooperationen. | Marketing | 4 |  |
| F058 | Paid User Acquisition (UA) | Kampagnen über Meta Ads, TikTok Ads und Apple Search Ads zur Nutzerakquise. | Nutzerakquise | 2 |  |
| F061 | Altersverifikationssystem | Mechanismus zur Überprüfung des Mindestalters (z.B. 16+) für den Zugriff auf die App. | Legal | 2 | F048 |
| F063 | Markenrechtsprüfung (Namenskonflikt) | Prüfung auf mögliche Markenrechtsverletzungen des App-Namens oder Logos. | Legal | 3 |  |

### Backlog (5 Features)
*Hinweis: Diese Features werden nach dem Full Launch in zukünftigen Updates in Betracht gezogen, basierend auf Nutzerfeedback und Marktanalyse.*

| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |
|---|---|---|---|---|
| F024 | Closed Beta-Testphase | v1.0 (Prozess) | Stabilität und KPI-Optimierung vor Soft Launch. | Prozess, nicht Feature. |
| F025 | Soft Launch | v1.0 (Prozess) | Validierung von Monetarisierung und regionalen Besonderheiten. | Prozess, nicht Feature. |
| F052 | Beta-Programm (TestFlight/Closed Beta) | v1.0 (Prozess) | Testphase für Stabilität und KPI-Optimierung. | Prozess, nicht Feature. |
| F086 | Social Feedback Widget | v1.1 | Interaktives Widget für In-App Feedback, das Like/Share Buttons umfasst. | Kann nach Launch hinzugefügt werden. |
| F085 | Currency Icon Set | v1.1 | Grafische Darstellung der In-Game-Währung und Boost-Symbole. | Kann nach Launch optimiert werden. |

---

## 5. Abhaengigkeits-Graph & Kritischer Pfad

### Build-Reihenfolge (Phase A)
Die Features werden in einer optimierten Reihenfolge gebaut, um Abhängigkeiten zu berücksichtigen und die Factory-Durchlaufzeit zu maximieren.

1.  **Foundation (Core Engine & Backend):** F001, F019, F023, F029
2.  **Core Gameplay Mechanics:** F002, F003, F007, F009
3.  **Basic Monetization & Legal:** F012, F013, F014, F021, F047, F048, F049, F062
4.  **Core Systems & Feedback:** F008, F018, F032, F036

### Kritischer Pfad (Phase A)
**Kette:** F001 (8 Wo) → F002 (4 Wo) → F007 (2 Wo) → F012 (2 Wo) → F013 (4 Wo) → F021 (6 Wo) → F023 (8 Wo)
**Gesamtdauer:** 34 Wochen (Entwicklerwochen)
**Beschreibung:** Diese Kette repräsentiert die minimalen sequenziellen Abhängigkeiten für die Kernfunktionalität und kritische Compliance. Jede Verzögerung in diesen Features blockiert den gesamten Soft Launch. Die Factory wird durch Parallelisierung und Automatisierung darauf abzielen, diese 34 Entwicklerwochen in den 4-8 Wochen "Factory Time" zu komprimieren.

### Parallelisierbare Feature-Gruppen (Phase A)
*   **Core Gameplay Enhancements:** F003, F008, F009 (können parallel zu F001 entwickelt werden)
*   **Monetarisierung & Ad-Integration:** F014 (kann parallel zu F013 entwickelt werden)
*   **Backend & System-Features:** F018, F029, F032, F036 (können parallel zu F023 entwickelt werden)
*   **Legal & Compliance Details:** F047, F048, F049, F062 (können parallel zu F021 entwickelt werden)

---

## 6. Screen-Architektur (VERBINDLICH)

### Screen-Uebersicht (12 Screens)
| ID | Screen | Typ | Zweck | Features | States |
|---|---|---|---|---|---|
| S001 | Splash / Loading | Hauptscreen | Display app branding and load initial assets. |  | Normal, Loading, Error |
| S002 | Authentication | Hauptscreen | User login, registration and cloud save initiation. | F029, F018 | Normal, Error |
| S003 | Tutorial | Hauptscreen | Introduce core gameplay mechanics to new users. | F007 | Normal |
| S004 | Main Menu | Hauptscreen | Dashboard for navigating to gameplay, leaderboards, shop etc. | F008 | Normal |
| S005 | Game Screen | Hauptscreen | Core endless-runner gameplay with tap-to-jump and swipe-to-direction mechanics. | F001, F002, F003, F009 | Normal, Paused, Game Over, Error |
| S006 | Pause/Fail Modal | Modal | Pause the game and offer options to retry or share score. | F001 | Normal, Paused |
| S007 | Leaderboard | Hauptscreen | Display user high scores and global leaderboards. | F008 | Normal, Loading, Error |
| S008 | Shop / IAP | Hauptscreen | In-app purchase store for cosmetics and power-ups. | F012, F013, F014 | Normal, Transaction, Error |
| S009 | Settings & Profile | Hauptscreen | Manage app preferences, user profile, cloud save and access legal information. | F021, F047, F048, F049, F062, F018, F029 | Normal, Loading, Error |
| S012 | IAP Confirmation Modal | Modal | Confirm in-app purchase transactions. | F013 | Normal, Processing, Error |
| S013 | Error / Offline Modal | Modal | Inform users about connectivity issues or general errors. |  | Error, Offline |
| S014 | Privacy Consent Modal | Modal | Manage user consents for legal compliance (DSGVO/COPPA). | F047, F048, F049, F062 | Normal |

### Hierarchie
*   **Tab-Bar Navigation (Alternative Navigationskonzept):**
    *   **Home** (S004)
    *   **Leaderboard** (S007)
    *   **Shop** (S008)
    *   **Settings & Profile** (S009)
*   **Modals:** S006, S012, S013, S014
*   **Overlays:** Keine in Phase A (S016 Performance Overlay wurde gestrichen)

### Navigation
Die Navigation erfolgt über das innovative, schwebende, kontextsensitive Navigationskonzept (siehe Design-Vision).

### Alle 7 User Flows
**Flow 1: Onboarding (Erst-Start)**
*   **Pfad:** S001 → S014 → S002 → S003 → S004
*   **Taps bis Core Loop:** 2
*   **Zeitbudget:** ~60 Sekunden
*   **Beschreibung:** App startet mit Splash/Loading (S001), Privacy Consent Modal (S014) erscheint automatisch vor der Authentication, User gibt Consent → Authentication/Registrierung (S002) → Tutorial (S003) mit Tap-to-Jump und Swipe-Intro → Übergang zu Main Menu (S004)
*   **Fallback bei Consent-Nein:** S014 leitet trotzdem weiter zu S002 → generische, nicht-personalisierte Meme-Levels ohne Tracking; kein dynamisch geladener Meme-Content, nur vorgefertigte Meme-Assets.
*   **Fallback bei Auth-Fehler:** S013 (Error/Offline Modal) erscheint → Retry oder als Gast fortfahren.
*   **Fallback bei Tutorial-Skip:** Direkter Sprung zu S004; Tutorial bleibt über Settings jederzeit erneut aufrufbar.

**Flow 2: Core Loop (wiederkehrend)**
*   **Pfad:** S004 → S005 → S006 → S005
*   **Taps bis Match:** 1
*   **Session-Ziel:** 6–10 Minuten
*   **Beschreibung:** User öffnet App auf Main Menu (S004) → Tap auf Play → Game Screen (S005) startet sofort mit aktuellem Meme-Run → bei Pause oder Fail erscheint Pause/Fail Modal (S006) mit Retry, Quit und Share-Option → bei erneutem Play zurück zu S005.
*   **Fallback bei Spielabsturz:** S005 Error-State erscheint → Auto-Retry nach 3 Sekunden → bei erneutem Fehler Rückkehr zu S004 mit Highscore-Sicherung aus lokalem Cache.
*   **Fallback bei schlechter Verbindung:** Lokal gecachte Meme-Assets werden geladen; kein Verbindungsabbruch-Interrupt im laufenden Match.

**Flow 3: Erster Kauf**
*   **Pfad:** S004 → S008 → S012 → S008
*   **Taps bis Kauf:** 3
*   **Beschreibung:** User navigiert über Tab-Bar zu Shop (S008) → Artikel auswählen (Kosmetik oder Power-Up) → IAP Confirmation Modal (S012) erscheint mit Preisübersicht und Bestätigungs-CTA → nach Bestätigung verarbeitet S012 die Transaktion (Processing-State) → Erfolg führt zurück zu S008 mit freigeschaltetem Item.
*   **Fallback bei Transaktionsfehler:** S012 wechselt in Error-State → Fehlermeldung mit Retry-Button; keine Doppelbelastung durch idempotente Transaktions-ID.
*   **Fallback bei Verbindungsabbruch während Kauf:** S013 (Error/Offline Modal) erscheint → Transaktion wird serverseitig in Pending-State gehalten → bei Reconnect automatische Wiederaufnahme.

**Flow 4: Social Challenge (vereinfacht für Phase A)**
*   **Pfad:** S004 → S005 → S006
*   **Taps:** 2
*   **Beschreibung:** User startet vom Main Menu (S004) → spielt einen Run auf Game Screen (S005) → nach Match-Ende oder Fail wird Pause/Fail Modal (S006) aufgerufen → Option zum Teilen des Scores (kein Clip-Export in Phase A).
*   **Fallback bei fehlendem Share:** S006 zeigt Error-State → Hinweis, dass Teilen fehlgeschlagen ist → Option, einen Standard-Screenshot zu teilen.
*   **Fallback bei Ablehnung von Share-Permissions:** S006 zeigt systemseitigen Permission-Dialog → bei Ablehnung bleibt der Score lokal gespeichert mit Hinweis zur manuellen Freigabe.

**Flow 5: Battle-Pass (vereinfacht für Phase A)**
*   **Pfad:** S004 → S009 → S008
*   **Taps:** 2
*   **Beschreibung:** User navigiert über Tab-Bar zu Settings & Profile (S009) → Battle-Pass-Sektion zeigt aktuellen XP-Fortschritt, freigeschaltete und gesperrte Rewards der aktuellen Season → Tap auf gesperrten Reward führt direkt zu Shop (S008) für optionalen Battle-Pass-Upgrade-Kauf.
*   **Fallback bei Sync-Fehler:** S009 wechselt in Syncing/Error-State → lokaler Fortschrittsstand wird angezeigt mit Hinweis auf ausstehende Cloud-Synchronisation.
*   **Fallback bei abgelaufenem Battle-Pass:** S009 zeigt leeren Reward-Track mit Countdown zur nächsten Season und Coming-Soon-Badge.

**Flow 6: Rewarded Ad**
*   **Pfad:** S005 → S006 → S005
*   **Taps:** 1
*   **Beschreibung:** Während des Gameplays auf S005 (Game Over State) erscheint im Pause/Fail Modal (S006) ein Rewarded-Ad-CTA → User tippt auf „Weiterleben / Extra Lives ansehen" → Ad wird inline abgespielt → nach vollständigem Ansehen erhält der User den Reward (z. B. Revive, Power-Up) und kehrt nahtlos zu S005 zurück.
*   **Fallback bei nicht verfügbarer Ad:** S006 blendet den Rewarded-Ad-CTA aus oder ersetzt ihn mit einem deaktivierten, ausgegrautem Button mit Tooltip „Aktuell keine Werbung verfügbar".
*   **Fallback bei Ad-Abbruch:** Kein Reward wird vergeben; User bleibt in S006 mit weiterhin aktivem Retry-Button.

**Flow 7: Consent (Detail)**
*   **Pfad:** S001 → S014 → S002 oder S004
*   **Taps:** 2
*   **Beschreibung:** Splash Screen (S001) lädt initiale Assets → Privacy Consent Modal (S014) erscheint automatisch bei Erst-Start oder nach App-Update mit geänderten Datenschutzbedingungen → User wählt zwischen vollständigem Consent, eingeschränktem Consent oder Ablehnung → je nach Auswahl Routing zu Authentication (S002) bei Neunutzern oder direkt zu Main Menu (S004) bei bekannten Usern.
*   **Fallback bei vollständiger Ablehnung:** Kein Tracking, kein dynamisch geladener Meme-Content; App ist mit generischen Meme-Assets nutzbar; Leaderboard-Funktion und Cloud-Save deaktiviert mit erklärendem Hinweis.
*   **Fallback bei COPPA-Trigger (Altersabfrage ergibt unter 13):** S014 blockiert spezifische Features (Tracking, Social Sharing, IAP) vollständig; elterliche Zustimmung wird eingeholt oder User wird in stark eingeschränkten Modus geleitet.
*   **Re-Consent:** Bei geänderten DSGVO-Bedingungen erscheint S014 erneut beim nächsten App-Start; bestehender Consent wird bis zur Neu-Bestätigung als eingeschränkt behandelt.

### Edge Cases (7 Situationen)
| Situation | Betroffene Screens | Erwartetes Verhalten |
|---|---|---|
| Offline | S001, S002, S007, S008, S009 | Error / Offline Modal (S013) erscheint; eingeschränkter Zugang zu cloudbasierten Funktionen |
| Meme-Content-Ladefehler | S003, S005 | Fallback auf vorgefertigte Meme-Assets; Hinweis im Error-State (intern) |
| Kauf-Fehler | S008, S012 | Fehlermeldung im Transaktionsprozess; Retry Option wird angeboten |
| COPPA / Consent abgelehnt | S014, S002 | Einschränkung bestimmter Features; generische Inhalte werden bereitgestellt, kein Tracking |
| Push-Benachrichtigungen abgelehnt | S009 | Option wird in den Einstellungen markiert; Warnhinweis zur Reaktivierung von Push Notifications |
| Server-Ausfall | S002, S007, S008, S009 | Error Modal (S013) erscheint, Retry-Button wird angeboten; Offline-Modus wenn möglich |
| Leerer Zustand (keine Daten, z. B. leere Leaderboards) | S007 | Leere State-UI mit erklärendem Hinweis; Aufforderung, in Kürze wieder zu prüfen |

### Phase-B Screens mit Platzhaltern
| ID | Screen | Zweck | Platzhalter in Phase A |
|---|---|---|---|
| S020 | Live-Ops Event-Hub | Display seasonal events and live operations content. | Coming Soon Badge (A063) in S004 oder S009 |

---

## 7. Asset-Liste (VERBINDLICH)

### Vollstaendige Asset-Tabelle (Phase A relevant)
*Hinweis: Die Spalte "Screen(s)" wurde an die reduzierte Screen-Anzahl angepasst. "Launch-kritisch" bedeutet, dass das Asset für Phase A benötigt wird.*

| ID | Asset | Screen(s) | Kategorie | Quelle | Format | Prioritaet |
|---|---|---|---|---|---|---|
| A001 | App-Icon | Alle | App-Branding | Custom Design | PNG 1024x1024 | **Launch-kritisch** |
| A002 | Splash Screen Background | S001 | Illustrationen | Custom Design | JPG 1920x1080 | **Launch-kritisch** |
| A003 | Splash Logo | S001 | App-Branding | Custom Design | PNG 1024x1024 | **Launch-kritisch** |
| A004 | Loading Indicator Animation | S001, S012, S009 | Animationen & Effekte | Lottie (Premium) | JSON | **Launch-kritisch** |
| A005 | Authentication Background Illustration | S002 | Illustrationen | Custom Design | JPG 1920x1080 | **Launch-kritisch** |
| A006 | Login Button Icon | S002 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A007 | Registration Button Icon | S002 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A008 | Cloud Save Icon | S002, S009 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A009 | Input Field Background | S002 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A010 | Tutorial Overlay Illustrations | S003 | Illustrationen | Custom Design | PNG | **Launch-kritisch** |
| A011 | Tutorial Step Indicator | S003 | UI-Elemente | Custom Design | PNG | Nice-to-have |
| A012 | Main Menu Background Illustration | S004 | Illustrationen | Custom Design | JPG 1920x1080 | **Launch-kritisch** |
| A013 | Play Button Icon | S004 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A014 | Dashboard Navigation Icons | S004 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A016 | Game Screen Background | S005 | Illustrationen | Custom Design | JPG 1920x1080 | **Launch-kritisch** |
| A017 | Character Sprite Animation | S005 | Gameplay-Assets | Custom Design | PNG Sequence | **Launch-kritisch** |
| A018 | Obstacle Sprite Pack | S005 | Gameplay-Assets | Custom Design | PNG | **Launch-kritisch** |
| A019 | Meme Item Sprite Collection | S005 | Gameplay-Assets | Custom Design | PNG | **Launch-kritisch** |
| A020 | Score Gauge Visual | S005 | Datenvisualisierung | Custom Design | SVG | **Launch-kritisch** |
| A021 | Modal Background Overlay | S006, S012, S013, S014 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A022 | Retry Button Icon (Modal) | S006, S013 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A024 | Leaderboard Background / Card | S007 | Illustrationen | Custom Design | PNG | **Launch-kritisch** |
| A025 | Trophy/Medal Icons | S007 | UI-Elemente | Custom Design | PNG | Nice-to-have |
| A026 | Empty Leaderboard Illustration | S007 | Illustrationen | Custom Design | PNG | Nice-to-have |
| A027 | Shop Background Illustration | S008 | Illustrationen | Custom Design | JPG 1920x1080 | **Launch-kritisch** |
| A028 | Cosmetic Item Icon Pack | S008 | Gameplay-Assets | Custom Design | PNG | **Launch-kritisch** |
| A029 | Power-Up Icon Pack | S008, S005 | Gameplay-Assets | Custom Design | PNG | **Launch-kritisch** |
| A030 | Purchase Confirmation Button Icon | S012 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A031 | Transaction Loading Animation | S008, S012 | Animationen & Effekte | Lottie (Premium) | JSON | **Launch-kritisch** |
| A032 | Settings Background Illustration | S009 | Illustrationen | Custom Design | JPG 1920x1080 | **Launch-kritisch** |
| A033 | Toggle Switch Icons | S009 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A034 | Privacy Information Icon | S009, S014 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A035 | Error/Warning Icon | S009, S013 | UI-Elemente | Custom Design | PNG | Nice-to-have |
| A036 | Profile Background Illustration | S009 | Illustrationen | Custom Design | JPG 1920x1080 | **Launch-kritisch** |
| A037 | Avatar Frame and Placeholder | S009 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A038 | Cloud Sync Icon | S009 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A040 | Feedback Modal Background | S009 (als Link) | UI-Elemente | Custom Design | PNG | Nice-to-have |
| A041 | Star Rating Icon Set | S009 (als Link) | UI-Elemente | Custom Design | PNG | Nice-to-have |
| A042 | Submit Button Icon (Feedback) | S009 (als Link) | UI-Elemente | Custom Design | PNG | Nice-to-have |
| A043 | IAP Confirmation Modal Background | S012 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A044 | Price Tag Icon | S012 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A045 | Confirm Purchase Button Icon | S012 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A046 | Processing Animation Indicator | S012 | Animationen & Effekte | Lottie (Premium) | JSON | **Launch-kritisch** |
| A047 | Error Modal Background | S013 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A048 | Offline Icon/Warning | S013 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A049 | Retry Button Icon (Error Modal) | S013 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A050 | Privacy Consent Modal Background | S014 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A051 | Consent Button Icons | S014 | UI-Elemente | Custom Design | PNG | **Launch-kritisch** |
| A052 | Privacy Illustration (Shield Icon) | S014 | Illustrationen | Custom Design | PNG | **Launch-kritisch** |
| A053 | Share Modal Background | S006 (für Score Share) | UI-Elemente | Custom Design | PNG | Nice-to-have |
| A054 | Social Media Icon Pack | S006 (für Score Share) | UI-Elemente | Custom Design | PNG | Nice-to-have |
| A055 | Share Button Icon | S006 (für Score Share) | UI-Elemente | Custom Design | PNG | Nice-to-have |
| A058 | Leaderboards Details Background | S007 | Illustrationen | Custom Design | PNG | **Launch-kritisch** |
| A063 | Coming Soon Badge Illustration | S004, S009 (Platzhalter) | App-Branding | Custom Design | PNG | Nice-to-have |
| A065 | Share Card UI | S006 (für Score Share) | Social-Assets | Custom Design | PNG | Nice-to-have |
| A067 | Social Media Icon Set | S006 (für Score Share) | Social-Assets | Custom Design | PNG | Nice-to-have |
| A068 | IAP Confirmation UI | S012 | Monetarisierungs-Assets | Custom Design | PNG | **Launch-kritisch** |
| A069 | Transaction Success Icon | S012, S008 | Monetarisierungs-Assets | Custom Design | PNG | **Launch-kritisch** |
| A070 | Transaction Error UI | S012 | Monetarisierungs-Assets | Custom Design | PNG | **Launch-kritisch** |
| A071 | Battle-Pass Progress Visual | S009 | Monetarisierungs-Assets | Custom Design | PNG | **Launch-kritisch** |
| A072 | Shop Item Card Design | S008 | Monetarisierungs-Assets | Custom Design | PNG | **Launch-kritisch** |
| A073 | Payment Processing Spinner | S012 | Monetarisierungs-Assets | Custom Design | PNG | **Launch-kritisch** |
| A080 | Privacy Consent Modal | S014 | Legal-UI | Custom Design | PNG | **Launch-kritisch** |
| A081 | Legal Info Screen | S009 | Legal-UI | Custom Design | PNG | **Launch-kritisch** |
| A083 | Transaction Loading Animation | S012 | Monetarisierungs-Assets | Custom Design | PNG | **Launch-kritisch** |
| A084 | Rewarded Ad Overlay Visual | S005 | Monetarisierungs-Assets | Custom Design | PNG | **Launch-kritisch** |

### Beschaffungswege pro Asset
*   **Custom Design (Figma, Spine, Adobe After Effects):** Alle UI-Elemente, Icons, Illustrationen, Charakter-Sprites und Animationen, die die einzigartige Design-Vision und die Anti-Standard-Regeln umsetzen. Dies ist der primäre Beschaffungsweg für alle **Launch-kritischen** Assets.
*   **Lottie (Premium):** Für komplexe, performante UI-Animationen (z.B. Loading Indicators, Transaction Animations).
*   **Extern generierte Meme-Assets:** Für die dynamisch geladenen Meme-Hintergründe und -Items. Diese werden extern (manuell oder durch externe AI-Dienste) erstellt und in Firebase Storage hochgeladen. **Die Factory generiert KEINE AI-Bilder.**
*   **Native:** Standard-System-UI-Elemente werden nur als Fallback oder für nicht-kritische Elemente verwendet, wo sie die Design-Vision nicht verletzen.

### Format-Anforderungen pro Plattform
| Asset-Typ | Format | Aufloesung/Groesse | Tool | Hinweise |
|---|---|---|---|---|
| unity_sprites | PNG / Sprite Sheet | 2x Retina | TexturePacker | Optimiert für Cross-Platform Rendering in Unity |
| icons | SVG |  | Figma | Vektorformat für Skalierbarkeit, exportiert als PNG für Unity |
| animations | Lottie JSON |  | After Effects + Bodymovin | Bei nicht unterstützenden Endgeräten fallback bereitstellen (PNG Sequence) |
| app_icon_ios | PNG | 1024x1024 + Varianten | Figma | Keine Transparenz, passende Varianten für unterschiedliche iOS-Geräte |
| app_icon_android | PNG Adaptive |  | Figma | Adaptive Icons gemäß Android Guidelines |
| screenshots_store | PNG |  |  | Store-optimierte Screenshots für hohe Auflösung |
| extern_meme_assets | JPG/PNG | Max 1024x1024, optimiert | Extern | Komprimiert für schnelle Ladezeiten, hochgeladen in Firebase Storage |

### Plattform-Varianten Anzahl
*   **iOS:** 1x (Unity Build)
*   **Android:** 1x (Unity Build)
*   **Gesamt:** 2 Plattform-Varianten

### Dark-Mode-Varianten
*   **Notwendig:** 81 Assets (alle UI-Elemente, Hintergründe, Icons müssen Dark-Mode-kompatibel sein)
*   **Umsetzung:** Farbwerte in Unity-Themes definieren, die dynamisch zwischen Light- und Dark-Mode wechseln.

---

## 8. KI-Produktions-Warnungen (VERBINDLICH — KRITISCH)

### Warnungen aus dem Visual Audit
| # | Screen | Stelle | Was KI falsch macht | Was stattdessen | Prompt-Anweisung fuer Produktionslinie |
|---|---|---|---|---|---|
| 1 | **S014** | Privacy Consent Text | KI generiert langen Fließtext | **Visuelle Icons** (A051) mit Tooltips | **PROMPT: Ersetze alle Text-Placeholders für Consent-Optionen in S014 durch A051 (Consent Button Icons)! Nutzer sollen Icons mit Tooltips sehen, nicht Text.** |
| 2 | **S002** | Auth-Button-Beschriftungen | KI generiert generische Buttons mit "Login" / "Registrieren" | **Icons + klare Handlungsaufforderung** (A006, A007) | **PROMPT: Verwende für Login- und Registrierungs-Buttons in S002 nur Icons (A006, A007) mit Hintergrund (A009)! Kein Text auf Buttons.** |
| 3 | **S005** | Power-Up-Anzeige | KI generiert Text wie "Power-Up aktiv!" | **Visuelle Icons** (A029) | **PROMPT: Zeige in S005 für Power-Up-Anzeigen Icons (A029) statt Text an! Nutze Sprite Sheets für Animationen.** |
| 4 | **S008** | Shop-Item-Beschreibungen | KI generiert lange Beschreibungen | **Icons + kurze Tooltips** (A028, A029) | **PROMPT: Keine Textbeschreibungen für Shop-Items in S008! Nutze Icons (A028, A029) mit Hover-Tooltips.** |
| 5 | **S004** | Navigations-Icons | KI generiert Text-Labels | **Klare Icons** (A014) | **PROMPT: Keine Text-Labels für Navigations-Icons in S004! Nutze nur Icons (A014) mit Tooltips.** |
| 6 | **S007** | Trophy Icons | KI generiert SF Symbols (z. B. "trophy") | **Custom-Trophäen** (A025) mit Memes-Design | **PROMPT: Ersetze alle generischen Trophäen-Icons in S007 durch Custom-Trophäen (A025) mit Memes-Design.** |
| 7 | **S008** | Item Icons | KI generiert Graue Boxen mit "Item" | **Cosmetic/Power-Up Icons** (A028, A029) | **PROMPT: Ersetze alle Item-Platzhalter in S008 durch Cosmetic/Power-Up Icons (A028, A029).** |
| 8 | **S009** | Toggle-Switch | KI generiert System-Toggle | **Custom-Toggle** (A033) mit Markenfarben | **PROMPT: Ersetze alle System-Toggle-Switches in S009 durch Custom-Toggle (A033) mit Markenfarben.** |
| 9 | **S009** | Avatar | KI generiert Standard-Profilbild | **Frame + Placeholder** (A037) mit Memes-Design | **PROMPT: Ersetze Standard-Profilbilder in S009 durch Avatar Frame + Placeholder (A037) mit Memes-Design.** |
| 10 | **S012** | Preis-Tag | KI generiert Generischer Platzhalter | **Preis-Tag-Icon** (A044) mit Währungs-Symbol | **PROMPT: Ersetze generische Preis-Platzhalter in S012 durch Preis-Tag-Icon (A044) mit Währungs-Symbol.** |
| 11 | **S013** | Error-Icon | KI generiert SF Symbol (z. B. "exclamationmark.triangle") | **Custom-Warnsymbol** (A035) mit Memes-Design | **PROMPT: Ersetze generische Error-Icons in S013 durch Custom-Warnsymbol (A035) mit Memes-Design.** |
| 12 | **S014** | Consent-Buttons | KI generiert Standard-Buttons | **Custom-Buttons** (A051) mit Icons | **PROMPT: Ersetze Standard-Consent-Buttons in S014 durch Custom-Buttons (A051) mit Icons.** |

### Warnungen aus der Design-Vision
| # | Screen | Standard den KI waehlt | Was Design-Vision verlangt | Prompt-Anweisung |
|---|---|---|---|---|
| 1 | **Alle** | Statische Screen-Übergänge | **Nahtlose, animierte Übergänge mit 3D-Elementen und fließenden Parallax-Effekten.** | **PROMPT: Implementiere für ALLE Screen-Übergänge nahtlose, animierte Übergänge mit 3D-Elementen und fließenden Parallax-Effekten (Anti-Standard-Regel 4).** |
| 2 | **Alle** | Weißer/heller, statischer Hintergrund | **Dynamisch geladene, Meme-basierte Hintergründe mit variierenden Meme-Elementen und Farbverläufen.** | **PROMPT: Verwende für ALLE Hintergründe dynamisch geladene, Meme-basierte Hintergründe mit variierenden Meme-Elementen und Farbverläufen (Anti-Standard-Regel 3).** |
| 3 | **Alle** | Standard Bottom-Tab-Bar (5 Icons) | **Schwebende, kontextadaptive Navigationsleiste mit Gestensteuerung und dynamischer Transparenz.** | **PROMPT: Implementiere eine schwebende, kontextadaptive Navigationsleiste mit Gestensteuerung und dynamischer Transparenz anstelle einer Standard Bottom-Tab-Bar (Anti-Standard-Regel 2).** |
| 4 | **S005, S007** | Flaches Card-Grid für Level-Auswahl | **Dynamische 3D-Parallax-Scroll-Ansicht, bei der Level in verschiedenen Tiefen dargestellt werden.** | **PROMPT: Implementiere für Level-Auswahl und Leaderboards (S005, S007) eine dynamische 3D-Parallax-Scroll-Ansicht anstelle eines flachen Card-Grids (Anti-Standard-Regel 1).** |
| 5 | **S001** | Schwarzer Screen → Home | **Animierter, neon pulsierender Ladehintergrund, in dem das Logo organisch aufblüht.** | **PROMPT: Gestalte den App-Start (S001) mit einem animierten, neon pulsierenden Ladehintergrund, in dem das Logo organisch aufblüht (Wow-Moment 1).** |
| 6 | **S005, S006** | Nüchterne Fehleranzeige | **Humorvolle Mikroanimation bei Fail (cartoonhafte Reaktionen, Meme-Effekt).** | **PROMPT: Implementiere bei Fehlversuchen im Gameplay (S005) und im Pause/Fail Modal (S006) eine humorvolle Mikroanimation (z.B. cartoonhafte Reaktionen, Meme-Effekt) mit Haptic-Feedback und Sound (Wow-Moment 2).** |
| 7 | **S004, S005** | Statische Hintergründe | **Dynamisch geladene Meme-Hintergründe, die sich in Echtzeit ändern.** | **PROMPT: Implementiere in Main Menu (S004) und Game Screen (S005) dynamisch geladene Meme-Hintergründe, die sich in Echtzeit ändern und visuelle Meme-Elemente in Szene setzen (Wow-Moment 3).** |
| 8 | **F004, F005, F039** | Echtzeit AI-Generierung | **Nutzung von extern generierten, kuratierten Meme-Assets aus Firebase Storage.** | **PROMPT: Für F004, F005, F039: Implementiere die dynamische Meme-Integration und Aktualisierung ausschließlich durch das Laden von extern generierten, kuratierten Meme-Assets aus Firebase Storage. KEINE Echtzeit-AI-Generierung durch die Factory.** |
| 9 | **F015, F016, F035** | Abo-Modelle / komplexe Battle Pass Backends | **IAP-getriebene Battle Pass-Systeme und exklusive Content-Pakete ohne Abo-Backend.** | **PROMPT: Für F015, F016, F035: Implementiere Battle Pass-Systeme und exklusive Content-Pakete ausschließlich IAP-getrieben. KEINE Abo-Modelle oder komplexen Subscription-Backends.** |
| 10 | **F034, F043** | Glücksspielmechaniken / Loot Boxes | **Reine Belohnungssysteme ohne Zufallsmechaniken.** | **PROMPT: Für F034, F043: Implementiere ausschließlich reine Belohnungssysteme mit transparenten, festen Preisen. KEINE zufallsbasierten Glücksspielmechaniken oder Loot Boxes.** |

---

## 9. Legal-Anforderungen fuer Produktion

**VERBINDLICH**

*   **Consent-Screens (DSGVO, ATT):**
    *   **Implementierung:** S014 (Privacy Consent Modal) muss bei Erststart und nach relevanten Updates erscheinen.
    *   **Inhalt:** Klare, verständliche Texte zu Datenerhebung, -verarbeitung und -nutzung. Optionen für vollständigen, eingeschränkten Consent und Ablehnung.
    *   **ATT (App Tracking Transparency):** Für iOS muss der ATT-Prompt vor jeglichem Tracking-Versuch (z.B. für AdMob) angezeigt werden, nachdem der DSGVO-Consent eingeholt wurde.
    *   **Prompt-Anweisung:** **PROMPT: Implementiere S014 (Privacy Consent Modal) als obligatorischen Start-Screen. Stelle sicher, dass der ATT-Prompt für iOS nach dem DSGVO-Consent und vor dem Tracking erscheint.**

*   **Age-Gate / COPPA:**
    *   **Implementierung:** Altersabfrage in S014 (Privacy Consent Modal).
    *   **Eingeschränkter Modus:** Bei Altersangabe unter 13 Jahren (COPPA-relevant) oder unter 16 Jahren (Jugendschutz) muss ein stark eingeschränkter Modus aktiviert werden:
        *   Kein Tracking, keine personalisierte Werbung.
        *   IAP nur mit Parental Gate (Eltern-E-Mail-Verifikation).
        *   Keine Social Sharing Features.
        *   Keine Push-Benachrichtigungen.
    *   **Prompt-Anweisung:** **PROMPT: Integriere eine Altersabfrage in S014. Bei COPPA-relevantem Alter (unter 13) oder Jugendschutz-Alter (unter 16) aktiviere den stark eingeschränkten Modus (kein Tracking, IAP mit Parental Gate, keine Social Sharing, keine Push-Notifications).**

*   **Datenschutz:**
    *   **Datensammlung:** Nur notwendige Daten für Core-Funktionalität (Highscores, IAP-Historie, Authentifizierung). Anonymisierte Analytics-Daten nur mit Consent.
    *   **AVV-Verträge:** Sicherstellen, dass mit allen Drittanbietern (Firebase, AdMob) gültige Auftragsverarbeitungsverträge (AVV) bestehen.
    *   **Prompt-Anweisung:** **PROMPT: Implementiere Datensammlung strikt nach dem Prinzip der Datensparsamkeit. Nur notwendige Daten für Core-Funktionalität sammeln. Anonymisierte Analytics nur mit explizitem Consent. Stelle sicher, dass AVV-Verträge mit Drittanbietern berücksichtigt werden.**

*   **Pflicht-UI:**
    *   **Datenschutzerklärung:** Link zur vollständigen Datenschutzerklärung in S009 (Settings & Profile).
    *   **Impressum:** Link zum Impressum in S009 (Settings & Profile).
    *   **KI-Kennzeichnung:** Hinweis in S009 (Settings & Profile) und in der App Store Beschreibung, dass Meme-Inhalte extern generiert und kuratiert werden.
    *   **Prompt-Anweisung:** **PROMPT: Füge in S009 (Settings & Profile) Links zur Datenschutzerklärung und zum Impressum ein. Implementiere einen Hinweis zur externen Generierung und Kuration von Meme-Inhalten in S009 und in den App Store Metadaten.**

*   **App Store Compliance:**
    *   **Apple App Store:** Transparente Darstellung von IAP und Ad-Integration. Einhaltung der Richtlinien für Content (keine anstößigen Memes).
    *   **Google Play Store:** Ähnliche Vorgaben wie Apple. Einhaltung der Richtlinien für Glücksspiel-ähnliche Mechaniken (keine zufallsbasierten Belohnungen).
    *   **Prompt-Anweisung:** **PROMPT: Stelle sicher, dass alle IAP- und Ad-Integrationen transparent und konform mit Apple App Store und Google Play Store Richtlinien sind. Überprüfe alle Inhalte auf Konformität mit Content-Richtlinien.**

---

## 10. Tech-Stack Detail

**VERBINDLICH**

*   **Engine + Version:**
    *   Unity 2023.x LTS (aktuelle Long Term Support Version)
    *   Universal Render Pipeline (URP) für optimierte Grafik-Performance auf mobilen Geräten.
    *   **Prompt-Anweisung:** **PROMPT: Verwende Unity 2023.x LTS mit URP für die gesamte Spielentwicklung.**

*   **Backend-Dienste:**
    *   **Google Firebase:**
        *   **Authentication:** F029 (Nutzer-Authentifizierung)
        *   **Firestore / Realtime Database:** F008 (High-Score-System), F018 (Cloud-Save-System), F023 (Server-Infrastruktur), F038 (Nutzerprofil-System), F055 (Cross-Platform Leaderboards), F015 (Battle Pass-System), F016 (Saisonale Inhalte), F028 (Event-System), F031 (Community-Features), F039 (Dynamische Meme-Themen).
        *   **Storage:** Für die Speicherung der extern generierten, kuratierten Meme-Assets (F004, F005).
        *   **Cloud Messaging:** F030 (Push-Benachrichtigungen).
        *   **Analytics:** F027 (Nutzersegmentierung), F032 (Performance-Tracking).
        *   **Performance Monitoring:** F032 (Performance-Tracking).
    *   **Prompt-Anweisung:** **PROMPT: Implementiere alle Backend-Dienste ausschließlich mit Google Firebase (Authentication, Firestore/Realtime Database, Storage, Cloud Messaging, Analytics, Performance Monitoring). KEINE Cloud Run oder andere benutzerdefinierte Backend-Dienste.**

*   **SDKs:**
    *   **Unity IAP:** F013 (IAP System), F035 (Exklusive Content-Pakete).
    *   **Google AdMob:** F014 (Ad Integration).
    *   **Firebase SDKs:** Für alle oben genannten Firebase-Dienste.
    *   **Social Media SDKs (TikTok, Instagram):** Für F017 (Social Sharing) und F050 (Social Sharing Features) – nur für die Sharing-Funktionalität, keine tiefgreifende Integration.
    *   **Prompt-Anweisung:** **PROMPT: Integriere Unity IAP, Google AdMob und die notwendigen Firebase SDKs. Für Social Sharing (F017, F050) verwende nur die offiziellen Social Media SDKs für Sharing-Funktionalität.**

*   **CI/CD Pipeline:**
    *   Automatisierte Builds für iOS (.ipa) und Android (.aab) über die DriveAI Factory Pipeline.
    *   Automatisierte Tests (Unity Test Framework, XCUITest, JUnit) bei jedem Build.
    *   **Prompt-Anweisung:** **PROMPT: Konfiguriere die CI/CD-Pipeline für automatisierte Unity-Builds für iOS und Android, inklusive der Ausführung aller Unity Test Framework, XCUITest und JUnit Tests.**

*   **Monitoring + Crash-Reporting:**
    *   Firebase Performance Monitoring (F032).
    *   Firebase Crashlytics (für Crash-Reporting).
    *   **Prompt-Anweisung:** **PROMPT: Aktiviere Firebase Performance Monitoring und Firebase Crashlytics für umfassendes Monitoring und Crash-Reporting.**

---

## 11. Release-Anforderungen

**VERBINDLICH**

### Phase 0 (Closed Beta)
*   **Ziel:** Interne und externe Tests der Kerngameplay-Mechanik, Content-Integration sowie Stabilität der Social-Sharing-Features. Feedback zu UI/UX, Monetarisierung und regionale Lokalisierung sammeln.
*   **Dauer:** ca. 4 Wochen
*   **Teilnehmer:** 500–1.000 ausgewählte Nutzer (interne Tester, Influencer im Gaming-Bereich, gezielt eingeladene Beta-Tester aus den Kernregionen).
*   **Erfolgskriterien:**
    *   Fehlerquote < 5% kritischer Bugs.
    *   Positives Nutzerfeedback bzgl. Controls und Content (mind. 70% Zufriedenheitsrate).
    *   Validierung der Monetarisierungskonzepte (erste IAP-Interaktionen & Ad-Reaktionen).
*   **Prompt-Anweisung:** **PROMPT: Bereite die App für eine Closed Beta vor, inklusive Firebase App Distribution für iOS/Android und Integration von Feedback-Tools (F036).**

### Phase 1 (Soft Launch)
*   **Regionen:** Nordamerika (USA, Kanada), Westeuropa (Deutschland, UK, Frankreich), ausgewählte asiatische Länder (z.B. Südkorea, Japan).
*   **KPIs:**
    *   DAU: ≥ 10.000 in den Testregionen.
    *   Retention D1/D7: ≥35%/20%.
    *   IAP-Conversion: ≥3%.
    *   Crash Rate: < 2%.
*   **Go/No-Go Kriterien:** Erreichen aller Soft Launch KPIs. Stabile Server-Performance. Einhaltung aller rechtlichen Vorgaben.
*   **Prompt-Anweisung:** **PROMPT: Konfiguriere die App für einen Soft Launch in den genannten Regionen. Aktiviere Firebase Analytics für die Überwachung der KPIs.**

### Phase 2 (Global Launch)
*   **Checkliste:**
    *   [ ] Server-Infrastruktur getestet und skalierbar (Lasttests durchgeführt, Backup-Server einsatzbereit).
    *   [ ] Monitoring und Alerting aktiv (Echtzeit-Dashboard und Notfallalarmsysteme).
    *   [ ] Support-Kanäle eingerichtet (In-App-Support, E-Mail, Social Media Monitoring).
    *   [ ] Social Media Accounts vorbereitet (TikTok, Instagram, Twitter – fertige Posts und geplante Challenges).
    *   [ ] Website live (Landing Page, FAQ-Bereich, Download-Links).
    *   [ ] Analytics und Tracking aktiv (Google Analytics, Firebase, interne KPIs).
    *   [ ] Crash-Reporting aktiv (Firebase Crashlytics).
    *   [ ] Backup- und Rollback-Plan dokumentiert (schnelle Wiederherstellung der letzten stabilen Version).
    *   [ ] App Store Listing finalisiert (alle Übersetzungen, präzise Beschreibung, korrekte Screenshots).
    *   [ ] Press Kit versendet (Medienanzüge, Teaser-Videos, Schlüssel-Feature-Infografiken).
*   **Prompt-Anweisung:** **PROMPT: Bereite die App für den Global Launch vor, indem alle Punkte der Global Launch Checkliste umgesetzt werden.**

### App Store Submission Checklisten
*   **Apple App Store:**
    *   [ ] Vollständige Dokumentation der Content-Filtermechanismen (für extern generierte Memes).
    *   [ ] Transparente Preispunkte und Monetarisierungserklärung.
    *   [ ] Prüfung des Datenschutzkonzepts inkl. Einwilligungsabfragen (F047, F048, F062).
    *   [ ] Optimiertes App Store Listing (Screenshots, Beschreibung, lokalisierte Inhalte).
    *   [ ] Einhaltung der ATT-Richtlinien.
*   **Google Play Store:**
    *   [ ] Sicherstellung der Einhaltung lokaler Datenschutzvorgaben (z.B. DSGVO).
    *   [ ] Klare Kennzeichnung von IAP und Ad-Integration.
    *   [ ] Finalisierte Version ohne offene kritische Bugs.
    *   [ ] Einhaltung der Richtlinien für Glücksspiel-ähnliche Mechaniken (keine zufallsbasierten Belohnungen).
*   **Prompt-Anweisung:** **PROMPT: Erstelle die App Store Listings für Apple App Store und Google Play Store gemäß den jeweiligen Checklisten. Stelle die Compliance mit allen Richtlinien sicher.**

### Post-Launch Plan (erste 4 Wochen)
*   **Woche 1:** Intensives Monitoring der Server-Performance und Einspielen erster Nutzer-Feedbacks. Schnelle Fehlerbehebung kritischer Bugs (Hotfixes). Social-Media-Aktivitäten (Challenge-Launch, Influencer-Engagement).
*   **Woche 2:** Analyse der Monetarisierungsdaten und Feintuning der IAP-Preispunkte bzw. des Battle Pass-Systems. Erste regionale Updates (z.B. verbesserte Lokalisierungselemente). Planung und Start von Community-Events.
*   **Woche 3:** Erweiterte Analyse von KPI’s (DAU, Retention, ARPU) und Anpassung im Live-Ops. Rollout kleiner Content-Updates (zusätzliche Meme-Content-Pakete, saisonale Themes). Intensivierung von Werbekampagnen und App-Store-Optimierung.
*   **Woche 4:** Auswertung der Launch-Phase: Detailliertes Nutzerfeedback, Crash-Reports, Monetarisierungseffizienz. Planung des nächsten größeren Content-Updates. Community Management und Response auf negative Reviews.
*   **Prompt-Anweisung:** **PROMPT: Implementiere die notwendigen Tools und Prozesse für den Post-Launch Plan, inklusive Monitoring-Dashboards, Hotfix-Deployment-Pipeline und Content-Update-Mechanismen (Firebase Remote Config/Storage).**

---

## 12. KPIs fuer Produktion

**VERBINDLICH**

### Business KPIs
| Metrik | Zielwert (Soft Launch) | Zielwert (Global Launch) | Frequenz |
|---|---|---|---|
| DAU | ≥ 10.000 (Testregionen) | ≥ 15.000 (regional durchschnitt) | Täglich |
| Retention D1 | ≥ 35% | ≥ 40% | Täglich |
| Retention D7 | ≥ 20% | ≥ 25% | Täglich |
| Retention D30 | N/A | ≥ 15% | Wöchentlich |
| ARPU | 1,50€ – 2,00€ | 1,50€ – 2,00€ | Wöchentlich |
| IAP Conversion Rate | ≥ 3% | ≥ 3% | Wöchentlich |
| Ad eCPM | ca. 12€ | ca. 12€ | Wöchentlich |

### Technische KPIs
| Metrik | Zielwert (Soft Launch) | Zielwert (Global Launch) | Frequenz |
|---|---|---|---|
| App-Start-Zeit | < 3 Sekunden | < 2 Sekunden | Wöchentlich |
| Meme-Content-Latenz | < 500 ms (Ladezeit) | < 300 ms (Ladezeit) | Wöchentlich |
| Crash-Rate | < 2% | < 1% | Täglich |
| App-Größe (Download) | < 200 MB | < 150 MB | Monatlich |
| FPS (Gameplay) | ≥ 30 FPS (min. Geräte) | ≥ 60 FPS (Zielgeräte) | Wöchentlich |

### Zielwerte pro Phase
*   **Closed Beta:** Fokus auf Stabilität (Crash Rate < 5%), grundlegende Funktionalität und positives Nutzerfeedback (70% Zufriedenheit).
*   **Soft Launch:** Erreichen der oben genannten Business- und Technischen KPIs in den Testregionen. Go/No-Go-Entscheidung für Global Launch.
*   **Global Launch:** Skalierung der KPIs auf globale Reichweite, kontinuierliche Optimierung und Erhöhung der Retention.

---

## 13. Design-Checkliste (Endabnahme vor Release)

**VERBINDLICH**

*   [ ] **Differenzierungspunkt 1 (Dynamische 3D-Parallax-Elemente)** ist visuell erkennbar und hebt sich klar vom Genre-Standard ab.
*   [ ] **Differenzierungspunkt 2 (Humorvolle Mikroanimationen bei Fehlversuchen und besonderen Events)** ist visuell erkennbar, mit unterstützendem Haptic-Feedback und Soundeffekten.
*   [ ] **Differenzierungspunkt 3 (Dynamisch geladene Meme-Hintergründe)** ist visuell erkennbar und integriert in den Gameplay-Flow.
*   [ ] **KEINE Anti-Standard-Regel wurde verletzt** – alle untersagten Designelemente und Effekte sind ausgeschlossen.
*   [ ] **Wow-Moment 1 (dynamische Parallax-Übergänge)** ist vollständig implementiert und erzeugt einen überzeugenden „Wow“-Effekt.
*   [ ] **Wow-Moment 2 (humorvolle, interaktive Mikroanimationen)** ist vollständig implementiert.
*   [ ] **Wow-Moment 3 (dynamisch geladene Meme-Hintergründe)** ist vollständig implementiert.
*   [ ] Die **emotionale Leitlinie** ist in ALLEN App-Bereichen spürbar (Onboarding bis Settings).
*   [ ] **Interaktions-Prinzipien** (haptisch, visuell und akustisch) werden durchgängig eingehalten.
*   [ ] Die App sieht nicht aus wie die Top 3 Wettbewerber – sie hebt sich visuell und interaktiv deutlich ab.
*   [ ] Ein Testnutzer sagt mindestens einmal "wow" oder "cool" in den ersten 60 Sekunden der Nutzung.
*   [ ] Micro-Interactions mit Priorität "Hoch" sind vollständig implementiert.
*   [ ] Der Core-Loop fühlt sich befriedigend, flüssig und vor allem innovativ an (keine generische Umsetzung).
*   [ ] **Farbkontrast (WCAG AA)** ist für alle Texte und interaktiven Elemente erfüllt (insbesondere für `#03A9F4`, `#FFC107`, `#f39c12` wurden Anpassungen vorgenommen oder dunklere Hintergründe verwendet).
*   [ ] **Touch-Targets** erfüllen die Mindestgrößen (44x44pt / 48x48dp).
*   [ ] **VoiceOver / TalkBack** Labels sind für alle Icons und Buttons implementiert.
*   [ ] **Reduced Motion** Fallbacks sind für alle Animationen vorhanden.
*   [ ] **Dark Mode** ist auf allen Screens vollständig und konsistent implementiert.

**Verantwortlicher für jeden Punkt:** Creative Director (finale Abnahme), Lead UX/UI Designer, Lead Developer.

---

## 14. Quellenverzeichnis

1.  **Concept Brief: # MemeRun 2026** (PHASE 1: PRE-PRODUCTION, CONCEPT BRIEF)
2.  **Trend-Report: # MemeRun 2026** (PHASE 1: PRE-PRODUCTION, TREND REPORT)
3.  **Competitive-Report: # MemeRun 2026** (PHASE 1: PRE-PRODUCTION, COMPETITIVE REPORT)
4.  **Zielgruppen-Profil: # MemeRun 2026** (PHASE 1: PRE-PRODUCTION, AUDIENCE PROFILE)
5.  **Legal-Research-Report: # MemeRun 2026** (PHASE 1: PRE-PRODUCTION, LEGAL REPORT)
6.  **Risk-Assessment-Report: # MemeRun 2026** (PHASE 1: PRE-PRODUCTION, RISK ASSESSMENT)
7.  **CEO-Gate Entscheidung: memerun2026** (PHASE 1: PRE-PRODUCTION, CEO GATE DECISION)
8.  **Plattform-Strategie-Report: # MemeRun 2026** (KAPITEL 3: MARKET STRATEGY, PLATFORM STRATEGY)
9.  **Monetarisierungs-Report: # MemeRun 2026** (KAPITEL 3: MARKET STRATEGY, MONETIZATION REPORT)
10. **Marketing-Strategie-Report: # MemeRun 2026** (KAPITEL 3: MARKET STRATEGY, MARKETING STRATEGY)
11. **Release-Plan-Report: # MemeRun 2026** (KAPITEL 3: MARKET STRATEGY, RELEASE PLAN)
12. **Kosten-Kalkulations-Report: # MemeRun 2026** (KAPITEL 3: MARKET STRATEGY, COST CALCULATION)
13. **Feature-Liste: memerun2026** (KAPITEL 4: MVP & FEATURE SCOPE, FEATURE LIST)
14. **Feature-Priorisierung: memerun2026** (KAPITEL 4: MVP & FEATURE SCOPE, FEATURE PRIORITIZATION)
15. **Screen-Architektur: memerun2026** (KAPITEL 4: MVP & FEATURE SCOPE, SCREEN ARCHITECTURE)
16. **Design-Differenzierungs-Report: memerun2026** (KAPITEL 4.5: DESIGN VISION, TREND BREAKER REPORT)
17. **UX-Emotion-Report: memerun2026** (KAPITEL 4.5: DESIGN VISION, EMOTION ARCHITECT REPORT)
18. **Design-Vision-Dokument: MemeRun 2026** (KAPITEL 4.5: DESIGN VISION, DESIGN VISION DOCUMENT)
19. **Asset-Discovery-Liste: memerun2026** (KAPITEL 5: VISUAL & ASSET AUDIT, ASSET DISCOVERY)
20. **Asset-Strategie-Report: memerun2026** (KAPITEL 5: VISUAL & ASSET AUDIT, ASSET STRATEGY)
21. **Visual-Consistency-Report: memerun2026** (KAPITEL 5: VISUAL & ASSET AUDIT, VISUAL CONSISTENCY)

---
*(Ende des Dokuments)*