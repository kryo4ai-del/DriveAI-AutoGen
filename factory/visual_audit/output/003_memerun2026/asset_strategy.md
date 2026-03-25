# Asset-Strategie-Report: memerun2026

## Stil-Guide
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
- **Stil:** Flat und minimalistisch
- **Beschreibung:** Verwendet flache Vektorillustrationen mit vereinfachten Formen und leuchtenden Farben. Der Stil kombiniert verspielte Elemente mit einem modernen, reduzierten Design, um die Dynamik eines Endless-Runner-Spiels widerzuspiegeln.
- **Begruendung:** Die minimalistische und dennoch lebendige Illustration unterstützt das schnelle Gameplay und die jugendliche Zielgruppe, während sie zur sofortigen Markenwiedererkennung beiträgt.

### Icon-Stil
- **Stil:** Flach, linienbasiert und minimalistisch
- **Library:** Material Icons (angepasst an die Markenidentität)
- **Grid:** 24x24

### Animations-Stil
- **Default Duration:** 300ms
- **Easing:** ease-in-out
- **Max Lottie:** 500 KB
- **Static Fallback:** Ja

## Beschaffungsstrategie pro Asset
Hier folgt die vollständige Markdown-Tabelle mit einem Eintrag pro Asset. Die Annahmen zu Quelle, Tool, Format, Kosten und Repo-Pfad basieren auf einem realistischen Indie-/Startup-Budget und den gegebenen Hinweisen.

| ID    | Asset                                      | Quelle           | Tool                    | Format              | Kosten EUR | Prioritaet       | Repo-Pfad                                    | Notizen                                                   |
|-------|--------------------------------------------|------------------|-------------------------|---------------------|------------|------------------|----------------------------------------------|-----------------------------------------------------------|
| A001  | App-Icon                                   | Custom Design    | Figma                   | PNG 1024x1024       | 350        | Launch-kritisch  | assets/branding/app_icon/                    | Hell + Dunkel Varianten                                   |
| A002  | Splash Screen Background                   | Custom Design    | Figma                   | JPG 1920x1080       | 200        | Launch-kritisch  | assets/illustrations/splash_bg/              | Markenimage, kontrastsicher                               |
| A003  | Splash Logo                                | Custom Design    | Figma                   | PNG 1024x1024       | 200        | Launch-kritisch  | assets/branding/splash_logo/                 | Markenkern, kontrastsicher                                |
| A004  | Loading Indicator Animation                | Lottie (Premium) | Adobe After Effects     | JSON                | 15         | Launch-kritisch  | assets/animations/loading_indicator/         | Animationsindikator                                       |
| A005  | Authentication Background Illustration     | Custom Design    | Figma                   | JPG 1920x1080       | 200        | Launch-kritisch  | assets/illustrations/auth_bg/                | Angenehme, kontrastsichende Hintergrundstimmung            |
| A006  | Login Button Icon                          | Custom Design    | Figma                   | PNG                 | 120        | Launch-kritisch  | assets/icons/login_button/                   | 3 Varianten, kontrastsicher                               |
| A007  | Registration Button Icon                   | Custom Design    | Figma                   | PNG                 | 120        | Launch-kritisch  | assets/icons/registration_button/            | 3 Varianten, kontrastsicher                               |
| A008  | Cloud Save Icon                            | Custom Design    | Figma                   | PNG                 | 60         | Launch-kritisch  | assets/icons/cloud_save/                     | 2 Varianten, kontrastsicher                               |
| A009  | Input Field Background                     | Custom Design    | Figma                   | PNG                 | 60         | Launch-kritisch  | assets/ui/input_field_bg/                    | Klare visuelle Rahmung, kontrastsicher                    |
| A010  | Tutorial Overlay Illustrations             | Custom Design    | Figma                   | PNG                 | 150        | Launch-kritisch  | assets/illustrations/tutorial_overlay/       | Pfeile, Hand-Symbole zur Visualisierung                   |
| A011  | Tutorial Step Indicator                    | Custom Design    | Figma                   | PNG                 | 50         | Nice-to-have     | assets/ui/tutorial_indicator/                | 1 Variante, Dark Mode vorhanden                           |
| A012  | Main Menu Background Illustration          | Custom Design    | Figma                   | JPG 1920x1080       | 200        | Launch-kritisch  | assets/illustrations/main_menu_bg/           | Moderner Look, kontrastsicher                             |
| A013  | Play Button Icon                           | Custom Design    | Figma                   | PNG                 | 90         | Launch-kritisch  | assets/icons/play_button/                    | 3 Varianten, kontrastsicher                               |
| A014  | Dashboard Navigation Icons                 | Custom Design    | Figma                   | PNG                 | 120        | Launch-kritisch  | assets/icons/dashboard_nav/                  | 4 Varianten, kontrastsicher                               |
| A015  | Animated Meme Banner                       | Lottie (Premium) | Adobe After Effects     | JSON                | 15         | Nice-to-have     | assets/animations/animated_meme_banner/       | Dynamische Animation aktueller Meme-Inhalte               |
| A016  | Game Screen Background                     | Custom Design    | Figma                   | JPG 1920x1080       | 200        | Launch-kritisch  | assets/illustrations/game_screen_bg/         | Detailreich mit Meme-Elementen, kontrastsicher            |
| A017  | Character Sprite Animation                 | Custom Design    | Spine / Figma           | PNG Sequence        | 800        | Launch-kritisch  | assets/sprites/character/                    | 6 Varianten für Sprung-, Lauf- & Swipe-Bewegungen          |
| A018  | Obstacle Sprite Pack                       | Custom Design    | Figma                   | PNG                 | 400        | Launch-kritisch  | assets/sprites/obstacles/                    | 8 Varianten, klare visuelle Darstellung                   |
| A019  | Meme Item Sprite Collection                | Custom Design    | Figma                   | PNG                 | 400        | Launch-kritisch  | assets/sprites/meme_items/                   | 10 Varianten, erkennbare Icon-Elemente                    |
| A020  | Score Gauge Visual                         | Custom Design    | Figma                   | SVG                 | 100        | Launch-kritisch  | assets/dataviz/score_gauge/                   | Punktanzeige als Gauge                                    |
| A021  | Modal Background Overlay                   | Custom Design    | Figma                   | PNG                 | 60         | Launch-kritisch  | assets/ui/modal_bg/                          | Transparenter, abgedunkelter Hintergrund, Dark Mode       |
| A022  | Retry Button Icon (Modal)                  | Custom Design    | Figma                   | PNG                 | 90         | Launch-kritisch  | assets/icons/retry_button/                   | 3 Varianten, interaktiv, kontrastsicher                   |
| A023  | Share Fail Clip Button Icon                | Custom Design    | Figma                   | PNG                 | 90         | Nice-to-have     | assets/icons/share_fail_clip/                | Für Social Sharing, kontrastsicher                        |
| A024  | High Score Background / Leaderboard Card     | Custom Design    | Figma                   | PNG                 | 200        | Launch-kritisch  | assets/illustrations/leaderboard_bg/         | Spezielles Kartenlayout für High Scores                   |
| A025  | Trophy/Medal Icons                         | Custom Design    | Figma                   | PNG                 | 150        | Nice-to-have     | assets/icons/trophies/                       | 5 Varianten, zur Darstellung von Leistungen               |
| A026  | Empty Leaderboard Illustration             | Custom Design    | Figma                   | PNG                 | 150        | Nice-to-have     | assets/illustrations/empty_leaderboard/      | Visualisiert leeren Zustand eines Leaderboards            |
| A027  | Shop Background Illustration               | Custom Design    | Figma                   | JPG 1920x1080       | 200        | Launch-kritisch  | assets/illustrations/shop_bg/                | Untermalt das Kauferlebnis im Shop                        |
| A028  | Cosmetic Item Icon Pack                    | Custom Design    | Figma                   | PNG                 | 300        | Launch-kritisch  | assets/icons/cosmetic_items/                 | 10 Varianten, speziell für den Shop                       |
| A029  | Power-Up Icon Pack                         | Custom Design    | Figma                   | PNG                 | 240        | Launch-kritisch  | assets/icons/powerups/                       | 8 Varianten, für Shop & Gameplay                          |
| A030  | Purchase Confirmation Button Icon          | Custom Design    | Figma                   | PNG                 | 90         | Launch-kritisch  | assets/icons/purchase_confirmation/          | Interaktive Bestätigung, kontrastsicher                   |
| A031  | Transaction Loading Animation              | Lottie (Premium) | Adobe After Effects     | JSON                | 15         | Launch-kritisch  | assets/animations/transaction_loading/       | Zeigt Transaktionsstatus als Animation                    |
| A032  | Settings Background Illustration           | Custom Design    | Figma                   | JPG 1920x1080       | 200        | Launch-kritisch  | assets/illustrations/settings_bg/            | Unterstützt visuelle Ästhetik, kontrastsicher              |
| A033  | Toggle Switch Icons                        | Custom Design    | Figma                   | PNG                 | 120        | Launch-kritisch  | assets/icons/toggle_switch/                  | 4 Varianten, kontrastsicher                               |
| A034  | Privacy Information Icon                   | Custom Design    | Figma                   | PNG                 | 60         | Launch-kritisch  | assets/icons/privacy_info/                   | 2 Varianten, zur Kennzeichnung von Datenschutz            |
| A035  | Error/Warning Icon                         | Custom Design    | Figma                   | PNG                 | 60         | Nice-to-have     | assets/icons/error_warning/                  | 2 Varianten, visuell warnend, kontrastsicher              |
| A036  | Profile Background Illustration            | Custom Design    | Figma                   | JPG 1920x1080       | 200        | Launch-kritisch  | assets/illustrations/profile_bg/             | Für Profile/Cloud Save, kontrastsicher                    |
| A037  | Avatar Frame and Placeholder               | Custom Design    | Figma                   | PNG                 | 150        | Launch-kritisch  | assets/icons/avatar_frame/                   | 5 Varianten, Standard-Avatar-Darstellung, kontrastsicher    |
| A038  | Cloud Sync Icon                            | Custom Design    | Figma                   | PNG                 | 60         | Launch-kritisch  | assets/icons/cloud_sync/                     | 2 Varianten, zur Sync-Anzeige, kontrastsicher             |
| A039  | Syncing Animation Indicator                | Lottie (Premium) | Adobe After Effects     | JSON                | 15         | Nice-to-have     | assets/animations/syncing_indicator/         | Zeigt laufende Synchronisation an                        |
| A040  | Feedback Modal Background                  | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/ui/feedback_modal_bg/                 | Hintergrund für Feedback-Modale, Dark Mode               |
| A041  | Star Rating Icon Set                       | Custom Design    | Figma                   | PNG                 | 150        | Nice-to-have     | assets/icons/star_rating/                    | 5 Varianten, für Bewertungssysteme, kontrastsicher         |
| A042  | Submit Button Icon (Feedback)              | Custom Design    | Figma                   | PNG                 | 90         | Launch-kritisch  | assets/icons/feedback_submit/                | Absende-Button im Feedback Modal, kontrastsicher          |
| A043  | IAP Confirmation Modal Background          | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/ui/iap_modal_bg/                      | Hintergrund für IAP-Bestätigung, Dark Mode                |
| A044  | Price Tag Icon                             | Custom Design    | Figma                   | PNG                 | 60         | Launch-kritisch  | assets/icons/price_tag/                       | Klare Preisdarstellung, kontrastsicher                    |
| A045  | Confirm Purchase Button Icon               | Custom Design    | Figma                   | PNG                 | 90         | Launch-kritisch  | assets/icons/purchase_confirm/               | Interaktive Bestätigung, kontrastsicher                   |
| A046  | Processing Animation Indicator             | Lottie (Premium) | Adobe After Effects     | JSON                | 15         | Launch-kritisch  | assets/animations/processing_indicator/      | Animation zur Transaktionsverarbeitung                    |
| A047  | Error Modal Background                     | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/ui/error_modal_bg/                    | Hintergrund für Error/Offline Modals, Dark Mode           |
| A048  | Offline Icon/Warning                       | Custom Design    | Figma                   | PNG                 | 60         | Launch-kritisch  | assets/icons/offline_warning/                | Für Verbindungsfehler, kontrastsicher                     |
| A049  | Retry Button Icon (Error Modal)            | Custom Design    | Figma                   | PNG                 | 90         | Launch-kritisch  | assets/icons/retry_button_error/             | Wiederverwendbar im Error Modal, kontrastsicher           |
| A050  | Privacy Consent Modal Background           | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/ui/privacy_consent_bg/                | Hintergrund für Consent Modal, Dark Mode                 |
| A051  | Consent Button Icons                       | Custom Design    | Figma                   | PNG                 | 90         | Launch-kritisch  | assets/icons/consent_buttons/                | 3 Varianten, für Auswahloptionen, kontrastsicher            |
| A053  | Share Modal Background                     | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/ui/share_modal_bg/                    | Abgesetzter Hintergrund für Share Modal, Dark Mode        |
| A054  | Social Media Icon Pack                     | Custom Design    | Figma                   | PNG                 | 150        | Launch-kritisch  | assets/icons/social_media/                   | 5 Varianten, plattformübergreifend, kontrastsicher          |
| A055  | Share Button Icon                          | Custom Design    | Figma                   | PNG                 | 90         | Launch-kritisch  | assets/icons/share_button/                   | Interaktiver Share-Button, kontrastsicher                 |
| A056  | Performance Graph Overlay                  | Custom Design    | Figma                   | PNG                 | 100        | Nice-to-have     | assets/dataviz/performance_graph/             | Overlay zur Darstellung technischer Metriken              |
| A057  | FPS Counter Icon                           | Custom Design    | Figma                   | PNG                 | 60         | Nice-to-have     | assets/dataviz/fps_counter/                   | Unterstützt technische Anzeige, kontrastsicher            |
| A058  | Leaderboards Details Background            | Custom Design    | Figma                   | PNG                 | 200        | Launch-kritisch  | assets/illustrations/leaderboards_details_bg/ | Detailreicher Hintergrund für Leaderboards              |
| A059  | Subscreen Tab Indicator                    | Custom Design    | Figma                   | PNG                 | 90         | Nice-to-have     | assets/ui/tab_indicator/                     | Visuelle Kennzeichnung für Tabs, kontrastsicher           |
| A060  | Fail-Clip Recording UI Overlay             | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/ui/fail_clip_overlay/                 | UI Overlay für Fail-Clip-Aufnahme, Dark Mode              |
| A061  | Timeline Slider for Video                  | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/ui/timeline_slider/                   | Slider für Videonavigation, kontrastsicher                |
| A062  | Recording Button Icon                      | Custom Design    | Figma                   | PNG                 | 90         | Launch-kritisch  | assets/icons/recording_button/               | Interaktiver Aufnahmebutton, kontrastsicher               |
| A063  | Coming Soon Badge Illustration             | Custom Design    | Figma                   | PNG                 | 150        | Nice-to-have     | assets/branding/coming_soon_badge/           | Platzhalter für Live-Ops Event-Hub, kontrastsicher         |
| A064  | Live-Ops Background Illustration           | Custom Design    | Figma                   | JPG 1920x1080       | 150        | Nice-to-have     | assets/illustrations/live_ops_bg/            | Hintergrund für Live-Ops, kontrastsicher                  |
| A065  | Share Card UI                              | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/social/share_card_ui/                 | Für Fail-Clip Sharing, Dark Mode                          |
| A066  | Fail-Clip Export Overlay                   | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/social/fail_clip_export/              | UI-Element für Aufnahme und Export, Dark Mode             |
| A067  | Social Media Icon Set                      | Custom Design    | Figma                   | PNG                 | 150        | Launch-kritisch  | assets/social/social_media_icons/            | Einheitliches Icon-Set, kontrastsicher                    |
| A068  | IAP Confirmation UI                        | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/monetization/iap_confirmation_ui/     | Bestätigungsmeldung für In-App Käufe, Dark Mode           |
| A069  | Transaction Success Icon                   | Custom Design    | Figma                   | PNG                 | 60         | Launch-kritisch  | assets/monetization/transaction_success/     | Erfolgssymbol, kontrastsicher                             |
| A070  | Transaction Error UI                       | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/monetization/transaction_error/       | Fehleranzeige bei Transaktionen, interaktiv               |
| A071  | Battle-Pass Progress Visual                | Custom Design    | Figma                   | PNG                 | 50         | Launch-kritisch  | assets/monetization/battle_pass_progress/     | Fortschrittsanzeige mit Reward-Icons                      |
| A072  | Shop Item Card Design                      | Custom Design    | Figma                   | PNG                 | 200        | Launch-kritisch  | assets/monetization/shop_item_card/          | Design für Shop-Item-Karten                               |
| A086  | Social Feedback Widget                     | Custom Design    | Figma                   | PNG                 | 100        | Nice-to-have     | assets/social/feedback_widget/               | Interaktives Widget für In-App Feedback, dynamisch        |

Diese Tabelle enthält für jedes der im Asset-Discovery-Dokument genannten Assets einen vollständigen Eintrag mit Quelle, Tool, Format, den realistischen Kosten in EUR, Priorität (basierend auf Launch-kritisch vs. Nice-to-have), dem vorgeschlagenen Repo-Pfad sowie zusätzlichen Notizen.

## Technische Format-Anforderungen
| Asset-Typ | Format | Aufloesung/Groesse | Tool | Hinweise |
|---|---|---|---|---|
| unity_sprites | PNG / Sprite Sheet | 2x Retina | TexturePacker | Optimiert für Cross-Platform Rendering in Unity |
| icons | SVG |  |  | Vektorformat für Skalierbarkeit |
| animations | Lottie JSON |  | After Effects + Bodymovin | Bei nicht unterstützenden Endgeräten fallback bereitstellen |
| app_icon_ios | PNG | 1024x1024 + Varianten |  | Keine Transparenz, passende Varianten für unterschiedliche iOS-Geräte |
| app_icon_android | PNG Adaptive |  |  | Adaptive Icons gemäß Android Guidelines |
| screenshots_store | PNG |  |  | Store-optimierte Screenshots für hohe Auflösung |

## Kosten-Uebersicht
| Kategorie | Anzahl | Kosten | Quellen-Mix |
|---|---|---|---|
| Development | None | 205,000 EUR |  |
| Marketing | None | 80,000 EUR |  |
| Compliance | None | 88,000 EUR |  |
| Asset Creation | 13 | 3,500 EUR |  |

## Budget-Check
- **Geschaetzte Gesamtkosten:** 376,500 EUR
- **Verfuegbares Budget:** 400,000 EUR
- **Status:** im_budget

## Asset-Uebergabe-Protokoll
- **Ordnerstruktur:** assets/branding, assets/illustrations, assets/icons, assets/animations, assets/ui
- **Naming-Convention:** lowercase_snake_case
### Delivery-Checkliste
- [ ] Alle Assets gemäß technischen Format-Anforderungen geprüft
- [ ] Ordnerstruktur und Namenskonventionen einheitlich implementiert
- [ ] Design-Quellfiles (z.B. Figma Dateien) sind enthalten
- [ ] Metadaten und Lizenzinformationen dokumentiert
- [ ] Finale Dateigrößen und Resolutionswerte validiert
