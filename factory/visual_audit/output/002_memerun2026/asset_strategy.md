# Asset-Strategie-Report: memerun2026

## Stil-Guide
### Farbpalette
| Name | Hex | Verwendung |
|---|---|---|
| Vibrant Pink | `#FF4081` | Hauptfarbe für Buttons, Links und Akzente im UI, um dynamische und energiegeladene Elemente hervorzuheben. |
| Bright Blue | `#2979FF` | Ergänzende Farbe für sekundäre Aktionen, Icons und Akzentuierungen, die das Hauptdesign unterstützen. |
| Energetic Amber | `#FFC107` | Farbe für Sonderaktionen, Warnhinweise und dynamische Elemente, um Aufmerksamkeit zu erzeugen. |
| background_light | `#FFFFFF` | Hintergrundfarbe im Light Mode für saubere, helle Oberflächen. |
| background_dark | `#121212` | Hintergrundfarbe im Dark Mode, um hohe Kontrastwerte und bessere Lesbarkeit in dunklen Umgebungen zu gewährleisten. |
| success | `#27ae60` | Farbe für Erfolgsmeldungen und bestätigende UI-Elemente. |
| warning | `#f39c12` | Farbe für Warnungen und Hinweise, die Aufmerksamkeit erfordern. |
| error | `#e74c3c` | Farbe für Fehlermeldungen und kritische Benachrichtigungen. |
| text_primary | `#212121` | Primäre Textfarbe für Headlines und Hauptinhalte. |
| text_secondary | `#757575` | Sekundäre Textfarbe für unterstützende Informationen und weniger hervorgehobene Inhalte. |

### Typografie
| Font | Verwendung | Gewicht | Lizenz |
|---|---|---|---|
| Poppins | Headings und prominente UI-Texte | 600-700 | Google Fonts – Open Source |
| Roboto | Body Text und längere Lesetexte | 400-500 | Google Fonts – Open Source |
| Source Code Pro | Daten, Scores und technische Informationen |  | Google Fonts – Open Source |

### Illustrations-Stil
- **Stil:** Flat & Minimalistic with a Playful Twist
- **Beschreibung:** Nutzt flache Vektorillustrationen mit leichten Gradienten und kräftigen Farben, die den Meme-Stil ins visuelle Zentrum rücken. Der Stil kombiniert humorvolle und dynamische Elemente, um die lebendige Atmosphäre des Spiels zu unterstützen.
- **Begruendung:** Diese Stilrichtung spricht die Zielgruppe an, die Spaß an jugendlichen, dynamischen und leicht überzogenen Designs hat, während sie gleichzeitig eine klare visuelle Sprache und Navigation beibehält.

### Icon-Stil
- **Stil:** Flat Minimalistic
- **Library:** Material Icons / Custom Adaptation
- **Grid:** 24x24

### Animations-Stil
- **Default Duration:** 300ms
- **Easing:** ease-in-out
- **Max Lottie:** 500 KB
- **Static Fallback:** Ja

## Beschaffungsstrategie pro Asset
Nachfolgend findest du die vollständige Markdown-Tabelle – für jedes Asset aus der Discovery-Liste – mit einer beispielhaften Beschaffungsstrategie. Dabei wurde für jedes Asset eine realistische Quelle, ein passendes Tool, Format, Kostenabschätzung (in EUR), Priorität (Launch-kritisch oder Nice-to-have), ein Repository-Pfad (wobei die Ordnerstruktur der Kategorie zugeordnet wurde) sowie zusätzliche Notizen eingetragen. Die hier gewählten Zahlen und Eintragungen sind als Beispielwerte für ein Indie-/Startup-Budget zu verstehen und können je nach Detailgrad, Komplexität oder externem Angebot variieren.

--------------------------------------------------------------------------------------------------
| ID    | Asset                                      | Quelle         | Tool            | Format            | Kosten EUR | Prioritaet      | Repo-Pfad                                           | Notizen                                    |
|-------|--------------------------------------------|----------------|-----------------|-------------------|------------|-----------------|-----------------------------------------------------|--------------------------------------------|
| A001  | App-Icon                                   | Custom Design  | Figma           | PNG 1024x1024     | 350        | Launch-kritisch | assets/branding/app_icon/                           | Hell+Dunkel Varianten                      |
| A002  | Splash Screen Background                   | Custom Design  | Figma           | PNG               | 150        | Launch-kritisch | assets/illustrations/splash/                        | 3 Varianten                                |
| A003  | Loading Spinner Animation                  | Lottie         | After Effects   | JSON/Lottie       | 100        | Launch-kritisch | assets/animations/loading_spinner/                  | 1 Variante                                 |
| A004  | Authentication Background                  | Custom Design  | Figma           | PNG               | 120        | Launch-kritisch | assets/illustrations/auth/                          | 2 Varianten                                |
| A005  | Social Login Icon Set                      | Custom Design  | Figma           | PNG               | 120        | Nice-to-have    | assets/ui/social_login/                             | 3 Varianten                                |
| A006  | Authentication Primary CTA Button          | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/ui/cta_buttons/                              | 2 Varianten                                |
| A007  | Tutorial Overlay Graphics                  | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/illustrations/tutorial/                      | 2 Varianten                                |
| A008  | Character Tutorial Animation               | Custom Design  | After Effects   | JSON              | 100        | Nice-to-have    | assets/animations/tutorial/                         | 1 Variante                                 |
| A009  | Main Menu Background                       | Custom Design  | Figma           | PNG               | 150        | Launch-kritisch | assets/illustrations/main_menu/                     | 2 Varianten                                |
| A010  | Tab Navigation Icon Set                    | Custom Design  | Figma           | PNG               | 150        | Launch-kritisch | assets/ui/navigation/                               | 5 Varianten                                |
| A011  | Play Button Icon                           | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/ui/buttons/                                  | 1 Variante                                 |
| A012  | Game Background                            | Custom Design  | Figma           | PNG               | 150        | Launch-kritisch | assets/illustrations/game_bg/                       | 3 Varianten                                |
| A013  | Character Sprite Animation                 | Custom Design  | Spine           | PNG Sequence      | 200        | Launch-kritisch | assets/sprites/character/                           | Animation für Jump & Run                   |
| A014  | Obstacle Sprite Set                        | Custom Design  | Figma           | PNG               | 150        | Launch-kritisch | assets/sprites/obstacles/                           | 5 Varianten, Meme-Stil                     |
| A015  | Meme Collectible Icon                      | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/sprites/collectibles/                        | 3 Varianten                                |
| A016  | Score Gauge Visual                         | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/data/score_gauge/                            | 1 Variante                                 |
| A017  | Pause Modal Background                     | Custom Design  | Figma           | PNG               | 120        | Launch-kritisch | assets/illustrations/modals/                        | 2 Varianten                                |
| A018  | Retry Button Icon                          | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/buttons/                                  | 1 Variante                                 |
| A019  | Quit Button Icon                           | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/buttons/                                  | 1 Variante                                 |
| A020  | Share Fail Clip Icon                       | Custom Design  | Figma           | PNG               | 70         | Nice-to-have    | assets/ui/buttons/                                  | 1 Variante                                 |
| A021  | High Score Background                      | Custom Design  | Figma           | PNG               | 120        | Launch-kritisch | assets/illustrations/high_score/                    | 2 Varianten                                |
| A022  | Leaderboard Table UI                       | Custom Design  | Figma           | PNG               | 120        | Launch-kritisch | assets/ui/tables/                                   | 1 Variante                                 |
| A023  | Score Badge Icons                          | Custom Design  | Figma           | PNG               | 100        | Nice-to-have    | assets/ui/badges/                                   | 3 Varianten                                |
| A024  | Shop Background                            | Custom Design  | Figma           | PNG               | 120        | Launch-kritisch | assets/illustrations/shop/                          | 2 Varianten                                |
| A025  | IAP Product Display Frame                  | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/ui/iap/                                      | 1 Variante                                 |
| A026  | IAP Item Icon Set                          | Custom Design  | Figma           | PNG               | 150        | Launch-kritisch | assets/ui/iap/                                      | 5 Varianten                                |
| A027  | Purchase Button                            | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/ui/buttons/                                  | 1 Variante                                 |
| A028  | Transaction Processing Spinner             | Custom Design  | After Effects   | JSON              | 100        | Launch-kritisch | assets/animations/transaction_spinner/             | 1 Variante                                 |
| A029  | Settings Background Pattern                | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/illustrations/settings/                      | 2 Varianten                                |
| A030  | Custom Toggle Switch                       | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/ui/toggles/                                  | 2 Varianten                                |
| A031  | Legal Information Icon                     | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/legal_icons/                              | 1 Variante                                 |
| A032  | Profile Avatar Frame                       | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/profile/                                  | 1 Variante                                 |
| A033  | Cloud Sync Status Icon                     | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/status/                                   | 1 Variante                                 |
| A034  | Battle-Pass Progress Bar                   | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/data/battle_pass/                            | 1 Variante                                 |
| A035  | Feedback Modal Background                  | Custom Design  | Figma           | PNG               | 80         | Nice-to-have    | assets/illustrations/modals/                        | 1 Variante                                 |
| A036  | Feedback Submit Button                     | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/ui/buttons/                                  | 1 Variante                                 |
| A037  | IAP Confirmation Layout Background         | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/illustrations/iap_confirmation/             | 1 Variante                                 |
| A038  | Error Modal Icon                           | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/icons/                                    | 1 Variante                                 |
| A039  | Error Modal Background                     | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/illustrations/error_modal/                   | 1 Variante                                 |
| A040  | Error Modal Retry Button                   | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/buttons/                                  | 1 Variante                                 |
| A041  | Privacy Consent Modal Background           | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/illustrations/privacy_consent/              | 1 Variante                                 |
| A042  | Consent Option Button Icons                | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/ui/buttons/                                  | 3 Varianten                                |
| A043  | Share Result Modal Background              | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/illustrations/share_result/                 | 1 Variante                                 |
| A044  | Social Media Share Icons                   | Custom Design  | Figma           | PNG               | 120        | Launch-kritisch | assets/ui/icons/                                    | 3 Varianten                                |
| A045  | Share Button Icon                          | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/buttons/                                  | 1 Variante                                 |
| A046  | Performance Metrics Graph Overlay          | Custom Design  | Figma           | PNG               | 120        | Nice-to-have    | assets/data/performance_graph/                      | 1 Variante                                 |
| A047  | Debug Toggle Icon                          | Custom Design  | Figma           | PNG               | 50         | Nice-to-have    | assets/ui/icons/                                    | 1 Variante                                 |
| A048  | Leaderboard Detail Background              | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/illustrations/leaderboard_detail/            | 1 Variante                                 |
| A049  | Fail-Clip Preview Frame                    | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/ui/frames/                                   | 1 Variante                                 |
| A050  | Record Button Icon                         | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/buttons/                                  | 1 Variante                                 |
| A051  | Export Button Icon                         | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/buttons/                                  | 1 Variante                                 |
| A052  | Fail-Clip Editing Toolbar Icons            | Custom Design  | Figma           | PNG               | 120        | Nice-to-have    | assets/ui/icons/                                    | 1 Variante                                 |
| A053  | Fail-Clip Error Indicator                  | Custom Design  | Figma           | PNG               | 70         | Launch-kritisch | assets/ui/icons/                                    | 1 Variante                                 |
| A054  | Live-Ops Event Coming Soon Badge           | Custom Design  | Figma           | PNG               | 50         | Nice-to-have    | assets/ui/badges/                                   | 1 Variante                                 |
| A055  | Share Card Template                        | Custom Design  | Figma           | PNG               | 120        | Launch-kritisch | assets/social/share_card/                           | 1 Variante                                 |
| A056  | Social Share Animation                     | Custom Design  | After Effects   | JSON              | 100        | Launch-kritisch | assets/social/share_animation/                      | 1 Variante                                 |
| A057  | IAP Confirmation Modal Visual              | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/monetization/iap_confirmation/               | 1 Variante                                 |
| A058  | Shop & Product Display Asset               | Custom Design  | Figma           | PNG               | 120        | Launch-kritisch | assets/monetization/shop_display/                   | 1 Variante                                 |
| A059  | Battle Pass Progress UI                    | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/monetization/battle_pass_ui/                 | 1 Variante                                 |
| A060  | Rewarded Ad Overlay                        | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/monetization/rewarded_ad/                    | 1 Variante                                 |
| A061  | App Store Screenshots Collection           | Custom Design  | Photoshop       | JPEG              | 50         | Launch-kritisch | assets/marketing/app_store_screenshots/            | Kuratierte Screenshots                     |
| A062  | Preview Video Teaser Visual                | Custom Design  | Premiere Pro    | MP4               | 200        | Launch-kritisch | assets/marketing/preview_video/                    | Teaser Clip                                |
| A063  | Press Kit Template                         | Custom Design  | Illustrator     | PDF               | 100        | Launch-kritisch | assets/marketing/press_kit/                         | Template                                   |
| A064  | Social Media Template Bundle               | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/marketing/social_templates/                 | Bundle                                     |
| A065  | Landing Page Teaser Banner                 | Custom Design  | Figma           | PNG               | 120        | Launch-kritisch | assets/marketing/landing_page/                      | Banner                                     |
| A066  | Influencer Promo Visual Kit                | Custom Design  | Figma           | PNG               | 150        | Launch-kritisch | assets/marketing/influencer_promo/                  | Visual Kit                                 |
| A067  | Privacy Consent Modal Visual               | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/legal/privacy_consent/                      |                                            |
| A068  | Legal Settings UI Visual                   | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/legal/legal_settings/                       |                                            |
| A069  | In-App Legal Disclaimer Visual             | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/legal/in_app_disclaimer/                    |                                            |
| A070  | Social Share Button Icon Animation         | Custom Design  | After Effects   | JSON              | 100        | Launch-kritisch | assets/social/share_button_animation/             | 1 Variante                                 |
| A071  | IAP Currency Icon Set                      | Custom Design  | Figma           | PNG               | 80         | Launch-kritisch | assets/monetization/iap_currency/                  | 1 Variante                                 |
| A072  | Pricing Tag Visual Effects                 | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/monetization/pricing_tags/                   | 1 Variante                                 |
| A073  | Beta Program Invitation Visual             | Custom Design  | Figma           | PNG               | 100        | Launch-kritisch | assets/marketing/beta_invitation/                   | Invitation                                 |
| A074  | Launch Day Live Banner                     | Custom Design  | Figma           | PNG               | 150        | Launch-kritisch | assets/marketing/launch_live_banner/               | Global Launch Banner                       |

--------------------------------------------------------------------------------------------------

Hinweise zur Tabelle:
• Alle Assets wurden mit der Quelle „Custom Design“ (bzw. Lottie bei Animationen) eingestuft – in der Praxis könnte man bei einfachen Icons auch auf AI-generierte oder Stock-Assets zurückgreifen.
• Das Tool „Figma“ wird für statische, UI- und Illustrations-Elemente sowie „After Effects“ für Animationen gewählt.
• Preise basieren auf einem Indie-/Startup-Budget und können je nach Aufwand (z. B. 1–3 Stunden pro Asset) variieren.
• Der Repo-Pfad orientiert sich an der Kategorie des Assets (z. B. assets/branding/ für Marken-Elemente, assets/sprites/ für Gameplay-Sprites etc.).
• Priorität ist „Launch-kritisch“ bei denen, bei denen in der Discovery-Liste „JA“ angegeben wurde, ansonsten „Nice-to-have“.

Diese Tabelle dient als Ausgangspunkt für die detaillierte Beschaffungsstrategie im Rahmen der App-Entwicklung.

## Technische Format-Anforderungen
| Asset-Typ | Format | Aufloesung/Groesse | Tool | Hinweise |
|---|---|---|---|---|
| unity_sprites | PNG / Sprite Sheet | 2x Retina | TexturePacker |  |
| icons | SVG |  |  |  |
| animations | Lottie JSON |  | After Effects + Bodymovin | Statisches PNG |
| app_icon_ios | PNG | 1024x1024 + Varianten |  | Keine Transparenz erlaubt – explizit für iOS App Store Richtlinien |
| app_icon_android | PNG Adaptive |  |  |  |
| screenshots_store | PNG |  |  |  |

## Kosten-Uebersicht
| Kategorie | Anzahl | Kosten | Quellen-Mix |
|---|---|---|---|
| Entwicklungskosten |  | 0 EUR |  |
| Marketing |  | 0 EUR |  |
| Compliance |  | 0 EUR |  |
| Infrastruktur |  | 0 EUR |  |

## Budget-Check
- **Geschaetzte Gesamtkosten:** 373,000 EUR
- **Verfuegbares Budget:** 400,000 EUR
- **Status:** im_budget

## Asset-Uebergabe-Protokoll
- **Ordnerstruktur:** assets/ with subfolders such as branding, illustrations, animations, ui, etc.
- **Naming-Convention:** lowercase_snake_case (e.g., app_icon.png, main_menu_bg.png)
### Delivery-Checkliste
- [ ] Finale Dateien in den spezifizierten Formaten
- [ ] Quelle-Dateien (z.B. Figma, After Effects) inkludiert
- [ ] Dokumentation der Ordnerstruktur und Namenskonvention
- [ ] Versionskontrolle wird sicher gestellt (z.B. Git, zentrales Asset-Repository)
- [ ] Validierung gegen die technischen Format-Anforderungen
