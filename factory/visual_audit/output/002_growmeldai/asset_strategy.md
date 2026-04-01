# Asset-Strategie-Report: growmeldai

## Stil-Guide
### Farbpalette
| Name | Hex | Verwendung |
|---|---|---|
| Forest Green | `#2E7D32` | Hauptfarbe fuer Buttons, CTAs, aktive Navigation, Highlights – repraesentiert Wachstum und Natur |
| Soft Sage | `#A5D6A7` | Hintergruende von Karten, sekundaere Buttons, Hover-States, Onboarding-Gradienten |
| Warm Amber | `#F9A825` | Premium-Badge, Sterne-Bewertungen, Warnhinweise fuer Giftigkeit, Gamification-Elemente |
| background_light | `#F5F9F5` | Light Mode App-Hintergrund – minimales Gruen-Tinting fuer organisches Ambiente |
| background_dark | `#121C12` | Dark Mode App-Hintergrund – tiefes Dunkelgruen statt reines Schwarz fuer markenkongruente Nacht-Optik |
| surface_light | `#FFFFFF` | Light Mode Karten, Modals, Bottom Sheets |
| surface_dark | `#1E2E1E` | Dark Mode Karten, Modals, Bottom Sheets |
| success | `#27AE60` | Erfolg – Scan-Treffer, abgeschlossene Pflegeaufgaben, Konfidenz hoch |
| warning | `#F39C12` | Warnung – niedrige Konfidenz bei Pflanzenerkennung, Giftigkeit-Flag, faellige Aufgaben |
| error | `#E74C3C` | Fehler – fehlgeschlagener Scan, fehlende Pflichtfelder, Verbindungsfehler |
| text_primary | `#1A2E1A` | Haupttext auf hellem Hintergrund – fast-schwarz mit Gruen-Tint fuer harmonischen Gesamteindruck |
| text_secondary | `#5C7A5C` | Sekundaertext, Metadaten, Timestamps, Placeholder-Labels – gedaempftes Gruen-Grau |
| text_on_primary | `#FFFFFF` | Text und Icons auf primaeren Gruen-Buttons und -Flaechen |
| border_subtle | `#D8EDDA` | Subtile Trennlinien, Karten-Borders, Divider in Light Mode |
| overlay_lock | `#1A2E1ACC` | Halbtransparentes Overlay fuer Freemium-Lock auf gesperrten Karten, 80% Opacity |

### Typografie
| Font | Verwendung | Gewicht | Lizenz |
|---|---|---|---|
| Plus Jakarta Sans | Headings H1-H3, Onboarding-Titel, CTA-Button-Labels, App-Wortmarke | 600-700 | Open Font License (OFL) – Google Fonts |
| Inter | Body Text, Pflegeplan-Beschreibungen, Karten-Inhalte, Einstellungs-Labels, Formulare | 400-500 | Open Font License (OFL) – Google Fonts |
| JetBrains Mono | Debug-Overlay (S020), Konfidenz-Scores, technische Datenpunkte, Versionsanzeigen | 400 | Open Font License (OFL) – Google Fonts / JetBrains |

### Illustrations-Stil
- **Stil:** Flat Organic Illustration
- **Beschreibung:** Weiche, organisch geformte Illustrationen mit leichten botanischen Texturen. Keine harten Kanten oder generische Clip-Art. Figuren und Objekte haben eine subtile 2.5D-Tiefe durch einfache Schattierungsgradienten ohne Vollschatten. Farbpalette der Illustrationen haelt sich streng an die App-Palette mit Gruen-Toenen als Basis und Amber als Akzent. Pflanzliche Motive wie Blaetter, Ranken, Topfsilhouetten als wiederkehrende Design-Elemente. Onboarding-Backgrounds verwenden subtile botanische Textur-Patterns als SVG – keine Fotografien.
- **Begruendung:** Millennials 25-40 im DACH-Raum resonieren mit warmem, nicht-infantilem Flat-Design das gleichzeitig Natuerlichkeit kommuniziert. Der organische Ansatz verstaerkt die Pflanzenpflege-Brand-Identity von GrowMeldAI ohne kitschig zu wirken. Konsistenz mit der gruenen Farbpalette schafft visuellen Wiedererkennungswert ueber alle Screens.

### Icon-Stil
- **Stil:** Rounded Outline mit optionalen Filled-States fuer aktive Zustaende
- **Library:** Phosphor Icons (MIT-lizenziert, konsistente Stroke-Weight, botanisch erweiterbar) als Basis – Custom-Icons fuer produktspezifische Motive wie Pflanzenprofil, Scan-Rahmen und Topfgroessen
- **Grid:** 24x24dp Standard, 32x32dp fuer Feature-Icons auf Premium-Screens, 48x48dp fuer Deeplink-Status-Icons S016, 20x20dp fuer Inline-Icons in Listenzeilen

### Animations-Stil
- **Default Duration:** 280ms
- **Easing:** cubic-bezier(0.34, 1.10, 0.64, 1.0)
- **Max Lottie:** 450 KB
- **Static Fallback:** Ja

## Beschaffungsstrategie pro Asset
# Beschaffungsstrategie: GrowMeldAI Assets

| ID | Asset | Quelle | Tool | Format | Kosten EUR | Priorität | Repo-Pfad | Notizen |
|---|---|---|---|---|---|---|---|---|
| A001 | App-Icon | Custom Design | Figma + Illustrator | PNG 1024x1024 + SVG | 350 | Launch-kritisch | assets/branding/app_icon/ | Alle iOS/Android-Größen exportieren; Hell+Dunkel; Adaptive Icon für Android |
| A002 | Splash-Screen-Logo | Custom Design | Figma | SVG + PNG @1x/2x/3x | 150 | Launch-kritisch | assets/branding/splash/ | 4 Varianten (Hell/Dunkel × iOS/Android); aus A001 ableiten |
| A003 | Splash-Ladeanimation | Lottie (Custom) | LottieFiles + After Effects | .lottie / .json | 80 | Launch-kritisch | assets/animations/splash/ | Loop; max. 3 Sek.; Dunkel-Modus-safe; Pflanzenwachstum-Motiv |
| A004 | Onboarding-Hero-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 30 | Launch-kritisch | assets/illustrations/onboarding/ | 2 Varianten (Hell/Dunkel); Stil konsistent mit Brand |
| A005 | Kamera-CTA-Button | Custom Design | Figma | SVG + PNG @1x/2x/3x | 80 | Launch-kritisch | assets/ui/buttons/ | 3 Zustände (Default/Pressed/Disabled); Hell+Dunkel |
| A006 | Kamera-Permission-Modal-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 20 | Launch-kritisch | assets/illustrations/permissions/ | 2 Varianten (Hell/Dunkel); freundlicher Ton |
| A007 | Scanner-Sucher-Rahmen | Custom Design | Figma + LottieFiles | .lottie / .json | 60 | Launch-kritisch | assets/animations/scanner/ | Animierte Ecken-Linien; nur Hell-Modus nötig |
| A008 | KI-Processing-Animation | Lottie (Custom) | After Effects + LottieFiles | .lottie / .json | 90 | Launch-kritisch | assets/animations/ai_processing/ | 1 Variante; kein Dunkel-Modus; Loop bis Ergebnis |
| A009 | Scan-Ergebnis-Einblend-Animation | Lottie (Custom) | After Effects + LottieFiles | .lottie / .json | 70 | Launch-kritisch | assets/animations/scan_result/ | 1 Variante; Hell+Dunkel-safe; einmalig (kein Loop) |
| A010 | Konfidenz-Anzeige-Visual | Custom Design | Figma | SVG (dynamisch befüllt) | 100 | Launch-kritisch | assets/ui/data_viz/ | 2 Varianten (Gauge/Balken); Hell+Dunkel; via Code animiert |
| A011 | Pflanzen-Platzhalter-Illustration | Free/Open-Source | unDraw / Storyset | SVG / PNG @2x | 0 | Launch-kritisch | assets/illustrations/placeholders/ | 3 Varianten (neutral/Silhouette/Fragezeichen); Hell+Dunkel |
| A012 | Pflanzenprofil-Schritt-Indikatoren | Custom Design | Figma | SVG (Code-Komponente) | 50 | Launch-kritisch | assets/ui/progress/ | 1 Variante; dynamisch via Code; Hell+Dunkel |
| A013 | Standort-Illustrations-Icons | Stock + Anpassung | Freepik + Figma | SVG-Set | 25 | Launch-kritisch | assets/icons/location/ | 6–8 Icons; 2 Varianten (Hell/Dunkel) |
| A014 | Topfgrößen-Illustrations-Icons | Custom Design | Figma | SVG-Set | 80 | Launch-kritisch | assets/icons/pot_sizes/ | 4–5 skalierte Töpfe; 2 Varianten; Hell+Dunkel |
| A015 | Pflegeplan-Reveal-Konfetti-Animation | Lottie (Free) | LottieFiles Free Library | .lottie / .json | 0 | Launch-kritisch | assets/animations/celebrations/ | Grüne Farbpalette anpassen; einmalig; Hell+Dunkel |
| A016 | Pflegeaufgaben-Icons | Free/Open-Source | Phosphor Icons / Lucide | SVG-Set | 0 | Launch-kritisch | assets/icons/care_tasks/ | Giessen/Düngen/Schneiden/Drehen; 3 Zustände; Hell+Dunkel |
| A017 | Wetter-Icons | Free/Open-Source | Phosphor Icons / weathericons | SVG-Set | 0 | Launch-kritisch | assets/icons/weather/ | Sonne/Wolke/Regen etc.; 2 Varianten; Hell+Dunkel |
| A018 | Push-Permission-Modal-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 20 | Launch-kritisch | assets/illustrations/permissions/ | 2 Varianten (Hell/Dunkel); Pflanze + Glocke |
| A019 | Home-Dashboard-Leer-Illustration | Free/Open-Source | unDraw / Storyset | SVG / PNG @2x | 0 | Launch-kritisch | assets/illustrations/empty_states/ | 2 Varianten (Hell/Dunkel); Brand-Farben anpassen |
| A020 | Aufgabe-Erledigt-Animation | Lottie (Free) | LottieFiles Free Library | .lottie / .json | 0 | Launch-kritisch | assets/animations/task_complete/ | Checkmark + Mini-Bloom; 1 Variante; Hell+Dunkel |
| A021 | Alle-Aufgaben-Erledigt-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 20 | Nice-to-have | assets/illustrations/celebrations/ | 2 Varianten (Hell/Dunkel); fröhliche Pflanze |
| A022 | Pflanzenprofil-Karte-Thumbnail-Rahmen | Custom Design | Figma | SVG (Code-Komponente) | 60 | Launch-kritisch | assets/ui/cards/ | 2 Varianten; abgerundete Ecken; Hell+Dunkel |
| A023 | Pflanzen-Liste-Leer-Illustration | Free/Open-Source | unDraw / Storyset | SVG / PNG @2x | 0 | Launch-kritisch | assets/illustrations/empty_states/ | 2 Varianten; Kamera-CTA integriert; Hell+Dunkel |
| A024 | Freemium-Limit-Lock-Icon | Free/Open-Source | Phosphor Icons / Lucide | SVG | 0 | Nice-to-have | assets/icons/monetization/ | 2 Varianten (Hell/Dunkel); Overlay auf Karte |
| A025 | Gesundheitsstatus-Indikator | Custom Design | Figma | SVG (Code-Komponente) | 40 | Nice-to-have | assets/ui/data_viz/ | 3 Farb-Zustände (grün/gelb/rot); Hell+Dunkel |
| A026 | Giftigkeit-Warning-Icon | Custom Design | Figma | SVG | 50 | Launch-kritisch | assets/icons/warnings/ | 3 Varianten (allgemein/Tier/Kind); Hell+Dunkel; auffälliges Rot |
| A027 | Pflegeplan-Timeline-Visual | Custom Design | Figma | SVG (Code-Komponente) | 90 | Launch-kritisch | assets/ui/data_viz/ | 2 Varianten (Timeline/Kalender); Hell+Dunkel; via Code dynamisch |
| A028 | Scan-Ergebnis-Pflanzenkarte-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 25 | Launch-kritisch | assets/illustrations/scan_result/ | 2 Varianten (Hell/Dunkel); botanisch-clean |
| A029 | Keine-Pflanze-Erkannt-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 20 | Launch-kritisch | assets/illustrations/error_states/ | 2 Varianten (Hell/Dunkel); fragendes Pflanzen-Motiv |
| A030 | Niedrige-Konfidenz-Alternativen-UI | Custom Design | Figma | SVG (Code-Komponente) | 70 | Nice-to-have | assets/ui/cards/ | 2 Varianten; Card-Karussell; Hell+Dunkel |
| A031 | Auth-Screen-Hero-Visual | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 25 | Nice-to-have | assets/illustrations/auth/ | 2 Varianten (Hell/Dunkel); Mehrwert kommunizieren |
| A032 | Social-Login-Provider-Icons | Free/Open-Source | Apple/Google Brand Guidelines | SVG (offiziell) | 0 | Launch-kritisch | assets/icons/social_login/ | Apple + Google + E-Mail; 4 Varianten; Guideline-konform |
| A033 | Profil-Avatar-Placeholder | Free/Open-Source | Phosphor Icons / UI Avatars | SVG / PNG @2x | 0 | Nice-to-have | assets/ui/avatars/ | 2 Varianten (Hell/Dunkel); generisch-neutral |
| A034 | Premium-Badge | Custom Design | Figma | SVG + PNG @2x | 60 | Nice-to-have | assets/ui/badges/ | 3 Varianten (Krone/Stern/Label); goldene Palette; Hell+Dunkel |
| A035 | Einstellungs-Icons | Free/Open-Source | Phosphor Icons / Lucide | SVG-Set | 0 | Nice-to-have | assets/icons/settings/ | Datenschutz/Benachrichtigung/Abo etc.; 2 Varianten; Hell+Dunkel |
| A036 | Paywall-Hero-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 35 | Nice-to-have | assets/illustrations/paywall/ | 2 Varianten (Hell/Dunkel); emotional/üppig |
| A037 | Premium-Feature-Icons | Free/Open-Source + Anpassung | Phosphor Icons + Figma | SVG-Set | 10 | Nice-to-have | assets/icons/premium_features/ | 5–7 Icons; 2 Varianten; Goldton; Hell+Dunkel |
| A038 | IAP-Erfolgs-Animation | Lottie (Free) | LottieFiles Free Library | .lottie / .json | 0 | Nice-to-have | assets/animations/iap_success/ | Konfetti in Grün/Gold; einmalig; Hell+Dunkel |
| A039 | Weicher-Paywall-Modal-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 20 | Nice-to-have | assets/illustrations/paywall/ | 2 Varianten (Hell/Dunkel); motivierend statt strafend |
| A040 | Deeplink-Aufgaben-Status-Icons | Custom Design | Figma | SVG + .lottie | 80 | Launch-kritisch | assets/icons/notifications/ | 2 Varianten; animierter Wassertropfen; Hell+Dunkel |
| A041 | Offline-Fehler-Illustration | Free/Open-Source | unDraw / Storyset | SVG / PNG @2x | 0 | Nice-to-have | assets/illustrations/error_states/ | 2 Varianten (Hell/Dunkel); WLAN-Symbol + Pflanze |
| A042 | DSGVO-Modal-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 20 | Launch-kritisch | assets/illustrations/legal/ | 2 Varianten (Hell/Dunkel); Schild + Pflanze; vertrauensbildend |
| A043 | COPPA-Under13-Block-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 20 | Launch-kritisch | assets/illustrations/legal/ | 2 Varianten (Hell/Dunkel); klar aber freundlich |
| A044 | Feedback-Sternebewertung-Visual | Custom Design | Figma | SVG (Code-Komponente) + .lottie | 70 | Nice-to-have | assets/ui/feedback/ | 2 Varianten; interaktive Sterne-Animation; Hell+Dunkel |
| A045 | Feedback-Modal-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 25 | Nice-to-have | assets/illustrations/feedback/ | 4 Varianten (positiv/negativ/neutral/Bug); Hell+Dunkel |
| A046 | Debug-Overlay-Visual-Elemente | Custom Design | Figma | SVG / PNG | 20 | Nice-to-have | assets/ui/debug/ | 1 Variante; kein Dunkel-Modus nötig; internes QA-Tool |
| A047 | TestFlight-Beta-Banner-Visual | Custom Design | Figma | SVG / PNG @2x | 20 | Nice-to-have | assets/ui/beta/ | 1 Variante; gelb-orange Stripe; Hell+Dunkel |
| A048 | Standort-Permission-Modal-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 20 | Launch-kritisch | assets/illustrations/permissions/ | 2 Varianten (Hell/Dunkel); Pin + Pflanze + Wolken |
| A049 | Tab-Bar-Icons | Free/Open-Source + Anpassung | Phosphor Icons / SF Symbols + Figma | SVG-Set | 10 | Launch-kritisch | assets/icons/navigation/ | Home/Pflanzen/Scanner/Profil; 8 Varianten (aktiv/inaktiv × Hell/Dunkel) |
| A050 | Navigation-Back-und-Close-Icons | Native / Free | SF Symbols (iOS) + Material (Android) | SVG-Set | 0 | Launch-kritisch | assets/icons/navigation/ | Chevron + X; 4 Varianten; plattformkonform; Hell+Dunkel |
| A051 | Scan-Limit-Zähler-Visual | Custom Design | Figma | SVG (Code-Komponente) | 50 | Nice-to-have | assets/ui/data_viz/ | 2 Varianten; Fortschrittsbalken; Hell+Dunkel |
| A052 | Wetter-Widget-Visual | Custom Design | Figma | SVG (Code-Komponente) | 70 | Nice-to-have | assets/ui/widgets/ | 2 Varianten; kompaktes Wetter-Widget; Hell+Dunkel |
| A053 | Coming-Soon-Badge-Phase-B | Custom Design | Figma | SVG + PNG @2x | 25 | Nice-to-have | assets/ui/badges/ | 2 Varianten (Hell/Dunkel); auffällig aber nicht störend |
| A054 | Pflanzenwachstums-Locked-Card-Visual | Custom Design | Figma | SVG + PNG @2x | 40 | Nice-to-have | assets/ui/cards/ | 2 Varianten; Blur-Overlay; Hell+Dunkel |
| A055 | Loader-Skeleton-Screens | Custom Design | Figma | SVG (Code-Komponente) | 80 | Launch-kritisch | assets/ui/loading/ | 4 Varianten (Home/Liste/Detail/Feed); animiert via Code; Hell+Dunkel |
| A056 | Haustier-Giftigkeit-Icon-Set | Free/Open-Source + Anpassung | Phosphor Icons / Noun Project + Figma | SVG-Set | 15 | Launch-kritisch | assets/icons/toxicity/ | Hund/Katze/Kind; 2 Varianten; Hell+Dunkel |
| A057 | Schwierigkeitsgrad-Visual | Custom Design | Figma | SVG (Code-Komponente) | 40 | Nice-to-have | assets/ui/data_viz/ | 2 Varianten; 1–5 Blätter/Sterne; Hell+Dunkel |
| A058 | Benachrichtigungs-Deeplink-Pflanzen-Hero | AI-generiert + Nachbearbeitung | Midjourney + Figma | PNG @2x (dynamisch) | 15 | Nice-to-have | assets/illustrations/notifications/ | 1 Variante; Fallback wenn kein Pflanzenbild; Hell+Dunkel |
| A059 | Onboarding-Hintergrund-Textur | Custom Design | Figma | SVG / PNG @2x | 30 | Nice-to-have | assets/branding/backgrounds/ | 2 Varianten (Hell/Dunkel); subtiler Gradient/Textur |
| A060 | Pflanzennamen-Input-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 15 | Nice-to-have | assets/illustrations/onboarding/ | 2 Varianten (Hell/Dunkel); dekorativ-klein |
| A061 | Premium-Badge-Icon | Custom Design | Figma | SVG + PNG @2x | 40 | Launch-kritisch | assets/icons/monetization/ | 1 Variante; Gold-Palette; Hell+Dunkel; aus A034 ableitbar |
| A062 | Paywall-Hero-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 35 | Launch-kritisch | assets/illustrations/paywall/ | 1 Variante; hell+dunkel; Achtung: Redundanz zu A036 prüfen |
| A063 | Feature-Vergleichs-Tabelle-Grafik | Custom Design | Figma | SVG / PNG @2x | 80 | Launch-kritisch | assets/ui/paywall/ | 1 Variante; Free vs. Premium; Hell+Dunkel; nicht als System-Table |
| A064 | Lock-Overlay-Icon | Free/Open-Source + Anpassung | Phosphor Icons + Figma | SVG | 0 | Launch-kritisch | assets/icons/monetization/ | 1 Variante; semi-transparent; Hell+Dunkel; aus A024 ableitbar |
| A065 | Scan-Limit-Fortschrittsanzeige | Custom Design | Figma | SVG (Code-Komponente) | 50 | Launch-kritisch | assets/ui/data_viz/ | 1 Variante; dynamisch; Hell+Dunkel; Redundanz zu A051 prüfen |
| A066 | Free-Trial-Timer-Komponente | Custom Design | Figma | SVG (Code-Komponente) | 60 | Launch-kritisch | assets/ui/monetization/ | 1 Variante; Countdown-Visualisierung; Hell+Dunkel |
| A067 | Preis-Pill-Komponente | Custom Design | Figma | SVG (Code-Komponente) | 50 | Launch-kritisch | assets/ui/monetization/ | 1 Variante; Jahres-Abo-Badge hervorgehoben; Hell+Dunkel |
| A068 | IAP-Erfolgs-Konfetti-Animation | Lottie (Free) | LottieFiles Free Library | .lottie / .json | 0 | Nice-to-have | assets/animations/iap_success/ | 1 Variante; einmalig; Redundanz zu A038 prüfen |
| A069 | Soft-Paywall-Illustration | AI-generiert + Nachbearbeitung | Midjourney + Figma | SVG / PNG @2x | 25 | Launch-kritisch | assets/illustrations/paywall/ | 1 Variante; kontextuell zum Limit-Moment; Hell+Dunkel |
| A070 | Premium-Nutzer-Status-Banner | Custom Design | Figma | SVG / PNG @2x | 40 | Nice-to-have | assets/ui/profile/ | 1 Variante; Abo-Details sichtbar; Hell+Dunkel |

---

## Kostenzusammenfassung

| Kategorie | Assets (Anzahl) | Geschätzte Kosten EUR |
|---|---|---|
| Custom Design (Figma/Freelancer) | 38 | ca. 2.540 |
| AI-generiert + Nachbearbeitung | 22 | ca. 490 |
| Free / Open-Source | 16 | 0 |
| Lottie (Free Library) | 5 | 0 |
| Lottie (Custom) | 3 | 240 |
| Stock + Anpassung | 3 | 50 |
| Native (SF Symbols / Material) | 2 | 0 |
| **Gesamt (Richtwert)** | **70 Einzel-Assets / 100 Listeneinträge** | **ca. 3.320 EUR** |

> **Hinweis:** Kosten basieren auf Indie/Startup-Budget. Viele Custom-Design-Assets können von einem einzigen Figma-Freelancer in einem Paket günstiger beauftragt werden (~60–80 EUR/h). Redundanzen zwischen A024/A064, A036/A062, A038/A068 und A051/A065 **vor Beauftragung konsolidieren** – das spart schätzungsweise weitere 150–200 EUR.

## Technische Format-Anforderungen
| Asset-Typ | Format | Aufloesung/Groesse | Tool | Hinweise |
|---|---|---|---|---|
| unity_sprites | PNG / Sprite Sheet | 2x Retina (@2x Basis, @3x fuer iPhone Pro) | TexturePacker | Power-of-2-Dimensionen bevorzugt (512x512, 1024x1024); keine .jpg fuer UI-Elemente mit Transparenz |
| icons | SVG |  | Figma Export + SVGO-Optimierung |  |
| animations | Lottie JSON (.lottie bevorzugt, .json als Fallback) |  | After Effects + Bodymovin / LottieFiles Plugin | Statisches PNG @2x |
| app_icon_ios | PNG | 1024x1024 Master (App Store) + automatische Ableitungen via Xcode Asset Catalog | Figma Export → Asset Catalog via makeappicon.com oder AppIconGenerator | Kein Text, kein Screenshot-Inhalt gemaess App Store Guidelines 4.0 |
| app_icon_android | PNG Adaptive Icon |  | Android Studio Asset Studio oder Figma + Android Icon Template |  |
| screenshots_store | PNG (bevorzugt) oder JPEG max. 85% Qualitaet |  | Figma Device Mockup Templates + Screenshot-Automatisierung via fastlane snapshot | Kein bloss weisser/schwarzer Hintergrund; Brand-Farben nutzen; Textlayer separat halten fuer Lokalisierung |
| illustrations | SVG (bevorzugt fuer skalierbare Inhalte) + PNG @2x als Fallback |  | Figma → SVG Export + SVGO-Optimierung (Level 2) |  |
| splash_screen | SVG Logo-Anteil + Lottie-Animation + Solid Background via LaunchScreen.storyboard |  |  |  |
| fonts | OTF bevorzugt, TTF akzeptiert — kein WOFF/WOFF2 fuer Native |  |  | SF Pro (iOS System Font) als Fallback definiert |
| color_tokens | JSON Color Tokens (Style Dictionary kompatibel) |  |  |  |

## Kosten-Uebersicht
| Kategorie | Anzahl | Kosten | Quellen-Mix |
|---|---|---|---|
| App-Branding & Identity | 3 | 580 EUR | Custom Design (Figma + Illustrator) + Lottie Custom (After Effects) |
| Onboarding & Permissions | 3 | 70 EUR | AI-generiert (Midjourney) + Nachbearbeitung (Figma) |
| Scanner & KI-Flow | 5 | 400 EUR | Custom Design (Figma) + Lottie Custom (After Effects + LottieFiles) |
| Pflanzenprofil & Setup | 4 | 155 EUR | Free/Open-Source (unDraw, Storyset, Freepik) + Custom Design (Figma) |
| Pflegeplan & Dashboard | 4 | 0 EUR | Free/Open-Source (LottieFiles Free, Phosphor Icons, weathericons, unDraw) — kostenlos |
| Store-Presence & Marketing | 4 | 3,500 EUR | Custom Produktion (Figma Mockups + Screenrecording + Schnitt); Press-Kit aus Kosten-Kalkulations-Report (€2.250 Mitte; hier konservativ €3.500 inkl. Video) |
| UI-Komponenten & Restliche Icons | 4 | 0 EUR | Free/Open-Source (Phosphor Icons, Lucide, SF Symbols fuer iOS native) |
| Reserve & Iterations-Puffer | 0 | 500 EUR | Pauschal-Puffer (geschaetzt 15% auf Custom-Design-Positionen) |

## Budget-Check
- **Geschaetzte Gesamtkosten:** 5,205 EUR
- **Verfuegbares Budget:** 23,875 EUR
- **Status:** im_budget

## Asset-Uebergabe-Protokoll
- **Ordnerstruktur:** {'root': 'growmeldai-assets/', 'tree': {'assets': {'branding': {'app_icon': 'A001 — alle Groessen, Hell+Dunkel+Tinted', 'splash': 'A002 — SVG+PNG @1x/@2x/@3x, 4 Varianten', 'fonts': 'OTF/TTF Lizenz-Dateien + Lizenz-Dokument'}, 'animations': {'splash': 'A003 — .lottie + .json + Fallback-PNG', 'scanner': 'A007 — .lottie + .json', 'ai_processing': 'A008 — .lottie + .json + Fallback-PNG', 'scan_result': 'A009 — .lottie + .json', 'celebrations': 'A015 — .lottie + .json (Farbanpassung dokumentiert)'}, 'illustrations': {'onboarding': 'A004 — SVG+PNG @2x, Hell+Dunkel', 'permissions': 'A006, A018 — SVG+PNG @2x, Hell+Dunkel', 'placeholders': 'A011 — SVG+PNG @2x, 3 Varianten, Hell+Dunkel', 'empty_states': 'A019 — SVG+PNG @2x, Hell+Dunkel'}, 'icons': {'location': 'A013 — SVG-Set, 6-8 Icons, Hell+Dunkel', 'pot_sizes': 'A014 — SVG-Set, 4-5 Icons, Hell+Dunkel', 'care_tasks': 'A016 — SVG-Set, 3 Zustaende, Hell+Dunkel', 'weather': 'A017 — SVG-Set, Hell+Dunkel', 'ui_general': 'Phosphor/Lucide SVG-Set, 24x24 viewbox'}, 'ui': {'buttons': 'A005 — SVG+PNG @1x/@2x/@3x, 3 Zustaende, Hell+Dunkel', 'progress': 'A012 — SVG Code-Komponente, Hell+Dunkel', 'data_viz': 'A010 — SVG dynamisch, 2 Varianten, Hell+Dunkel'}, 'tokens': {'colors': 'color_tokens.json (Style Dictionary), colors_light.xml, colors_dark.xml, Colors.xcassets', 'typography': 'typography_tokens.json', 'spacing': 'spacing_tokens.json'}, 'store': {'ios': {'screenshots': '1290x2796/, 1242x2208/ — je 6 PNG-Screens + Quell-Figma-Link', 'preview_video': 'APP_PREVIEW_1290x2796.mp4 (max. 30 Sek., H.264)', 'app_icon_store': 'icon_1024x1024_store.png'}, 'android': {'screenshots': '1080x1920/ — 4-8 PNG-Screens', 'feature_graphic': 'feature_graphic_1024x500.png', 'app_icon': 'ic_launcher_adaptive/ (foreground + background Layer)'}}, 'press_kit': {'logos': 'SVG + PNG @2x, Hell+Dunkel, Farbe+Monochrom', 'screenshots_hires': 'Alle Store-Screenshots @2x ohne Device-Frame', 'brand_guidelines': 'growmeldai_brand_guidelines_v1.pdf'}}, '_docs': {'asset_register.csv': 'Alle Assets mit ID, Status, Lieferdatum, Abnahme-Datum', 'license_log.csv': 'Alle Fremd-Assets mit Lizenz-Typ, Quelle-URL, Ablaufdatum', 'color_tokens_readme.md': 'Erklaerung Token-Struktur und Verwendung', 'handover_checklist.md': 'Diese Checkliste ausgefuellt'}}}
- **Naming-Convention:** {'schema': '[asset_id]_[descriptor]_[variant]_[scale].[extension]', 'rules': ['Lowercase Snake Case durchgehend — keine Leerzeichen, keine Sonderzeichen', 'Asset-ID-Praefix immer fuehren (a001_, a002_, etc.) fuer Traceability', 'Variant-Suffixe standardisiert: _light / _dark / _tinted (Icons+Illustrations)', 'Scale-Suffixe standardisiert: @1x (weglassen wenn Basisgroesse) / @2x / @3x (nur PNG-Rasterexporte)', 'State-Suffixe fuer UI-Elemente: _default / _pressed / _disabled / _focused', 'Animations ohne Scale-Suffix (Lottie ist vektorbasiert)', 'Store-Assets mit Plattform-Praefix: ios_ / android_', 'Keine Versionsnummern im Dateinamen — Git-Versionierung reicht; bei Major-Redesign Ordner versionieren (v2/)'], 'examples': ['a001_app_icon_light.png', 'a001_app_icon_dark.png', 'a001_app_icon_1024x1024_store.png', 'a003_splash_animation.lottie', 'a003_splash_animation_fallback@2x.png', 'a005_camera_cta_button_light_default@2x.png', 'a005_camera_cta_button_dark_pressed@3x.png', 'a016_care_icon_water_light_default.svg', 'a017_weather_icon_sun_dark.svg', 'ios_screenshot_01_onboarding_1290x2796.png', 'android_screenshot_01_onboarding_1080x1920.png', 'color_tokens_v1.json', 'growmeldai_logo_color_light.svg', 'growmeldai_logo_mono_dark.svg']}
### Delivery-Checkliste
- [ ] {'phase': 'Pre-Delivery (Designer-Seite)', 'items': ['Alle Assets gegen Asset-Register (asset_register.csv) abgeglichen — kein Asset fehlt', 'Jedes Asset in vorgeschriebenen Formaten exportiert (SVG + PNG @2x Minimum; Lottie + Fallback-PNG fuer Animationen)', 'Alle Dark-Mode-Varianten vorhanden (jedes Launch-kritische Asset hat _light UND _dark Version)', 'Alle 3 UI-Zustaende (default/pressed/disabled) fuer interaktive Elemente exportiert', 'SVGs mit SVGO optimiert (max. 150KB) — keine embedded Raster-Daten in SVG-Dateien', 'Lottie-Dateien auf externe Asset-Referenzen geprueft (keine externen Bild-URLs)', 'PNG-Dateien: sRGB-Farbraum verifiziert, keine ICC-Profile fuer Display P3 ausser App-Icon', 'App-Icon iOS: Keine Transparenz-Ebene vorhanden (automatischer App-Store-Reject)', 'App-Icon Android: Safe-Zone-Konformitaet in Android Studio Asset Studio geprueft', 'Store-Screenshots: Alle Pflicht-Groessen fuer iOS (1290x2796 + 1242x2208) UND Android (1080x1920) vorhanden', 'Lizenzen aller Fremd-Assets (Freepik, LottieFiles, unDraw etc.) in license_log.csv eingetragen', 'Color Tokens als JSON exportiert und gegen Figma-Design-Tokens validiert', "Naming Convention auf alle Dateien angewendet — Script-Check: find . -name '* *' (keine Leerzeichen)", 'Ordnerstruktur entspricht Vorgabe — Stichproben-Check durch TAD']}
- [ ] {'phase': 'Technische Validierung (TAD / Lead-Developer)', 'items': ['Xcode Asset Catalog befuellt: App-Icon (alle Slots), LaunchScreen-Assets, Color Assets (Any+Dark)', 'Lottie-Animationen in Test-Build integriert und auf Ziel-Geraeten (iPhone 13 + iPhone 15 Pro) abgespielt', 'Dark-Mode-Toggle: Alle Screens auf Dark-Mode-Artefakte geprueft (falsche Farben, fehlende Assets)', 'Performance-Check: Animations-FPS auf Low-End-Geraet (iPhone X) > 55fps in Instruments', 'Asset-Groessen validiert: Kein einzelnes PNG > 2MB, kein Lottie-JSON > 500KB', 'SF Symbols Kompatibilitaet: iOS-Minimum-Version (iOS 16+) gegen verwendete SF-Symbol-Versionen geprueft', 'Adaptive Icon Android: Auf Circle-, Square- und Squircle-Masken in Android Studio geprueft', 'Alle Icon-SVGs als Template Images in Asset Catalog eingetragen (renderingMode: .template fuer UI-Icons)', 'Farb-Token-Implementierung in Code gegen token_colors.json validiert — kein Hardcode-Hex im Codebase', 'Alle Fallback-PNGs fuer Animationen im Asset Catalog als Notfall-Fallback registriert']}
- [ ] {'phase': 'Abnahme & Archivierung', 'items': ["asset_register.csv: Alle Assets auf Status 'abgenommen' gesetzt mit Datum und Abnahme-Person", 'Git-Commit mit Tag: assets-v1.0-launch erstellt', "Figma-Sourcedateien: Final-Stand als Figma-Version gespeichert ('v1.0 Launch-Handover') und Link in asset_register.csv eingetragen", 'After-Effects-Quelldateien (fuer A003, A007, A008, A009) in separatem /source-files Ordner archiviert (nicht im App-Repo)', 'license_log.csv vollstaendig: Alle 8 Fremd-Asset-Quellen mit Lizenz-URL und Nutzungsrecht dokumentiert', 'Press-Kit-Ordner an Marketing-Verantwortlichen uebergeben und Empfang bestaetigt', 'Store-Screenshot-Quelldateien (Figma) mit Device-Frames als separate Figma-Page archiviert', 'Handover-Meeting durchgefuehrt: Designer + TAD + Lead-Developer — offene Punkte in Issue-Tracker erfasst', 'Naechste Review: Android-Phase-4-Assets (Adaptive Icons, Android-spezifische Anpassungen) — Datum in Projektplan eingetragen']}
