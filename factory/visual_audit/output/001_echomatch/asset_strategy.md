# Asset-Strategie-Report: echomatch

## Stil-Guide
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
| Nunito | Headings, Level-Bezeichnungen, Battle-Pass-Tier-Labels, CTA-Button-Beschriftungen, Score-HUD-Hauptzahl | 700-800 | SIL Open Font License (Google Fonts); kostenlos, kommerziell nutzbar |
| Inter | Body Text, Quest-Beschreibungen, Shop-Kartentext, Onboarding-Erklaerungen, Settings, Notification-Texte | 400-500 | SIL Open Font License (Google Fonts); kostenlos, kommerziell nutzbar |
| JetBrains Mono | Numerische Daten mit festem Zeichenabstand: Score-Counter, Countdown-Timer, Move-Counter, Muenz-Zaehler; verhindert Layout-Shift bei sich aendernden Ziffern | 500-600 | SIL Open Font License (JetBrains / Google Fonts); kostenlos, kommerziell nutzbar |

### Illustrations-Stil
- **Stil:** Stylized 2.5D Casual Cartoon mit Depth-Layering
- **Beschreibung:** Weiche, abgerundete Formen mit leichtem 3D-Extrude-Effekt auf Spielsteinen und wichtigen UI-Elementen; saettigte, leuchtende Farben mit subtilen Gradienten; schwarze Outlines mit variabler Strichstaerke (2-4px) fuer Tiefe; Charaktere und Mascottes haben grosse, ausdrucksstarke Augen und einfache Silhouetten; Hintergrundelemente sind weicher und weniger gesaettigt als Vordergrund-Assets um Spielsteine visuell zu priorisieren; Lichteffekte und Highlights als weisse Glanzpunkte auf Spielsteinen zur Volumenvermittlung
- **Begruendung:** 2.5D Casual Cartoon ist der visuelle Standard der kommerziell erfolgreichsten Match-3-Games (Royal Match, Candy Crush, Gardenscapes); die Zielgruppe 18-34 erwartet polished visuals ohne harten Realismus; das Stil ermoeglicht starke Lesbarkeit der Spielsteine bei gleichzeitig emotionaler Attraktivitaet; Dark-Mode-Kompatibilitaet wird durch leuchtende Eigenfarben statt helle Hintergruende gewaehrleistet

### Icon-Stil
- **Stil:** Filled mit weichen Kanten, passend zum Illustration-Stil; keine scharfen rechten Winkel
- **Library:** Custom Icon Set basierend auf Phosphor Icons (MIT-Lizenz) als Basis, angepasst an EchoMatch-Aesthetik mit 3px corner-radius auf eckigen Elementen
- **Grid:** 24x24dp Basisgitter; 48x48dp fuer Gameplay-Booster-Icons; 96x96dp fuer Reward-Item-Icons; 20x20dp fuer Notification-Icon (monochrom, Android-konform)

### Animations-Stil
- **Default Duration:** 280ms
- **Easing:** cubic-bezier(0.34, 1.56, 0.64, 1)
- **Max Lottie:** 500 KB
- **Static Fallback:** Ja

## Beschaffungsstrategie pro Asset
# Beschaffungsstrategie: EchoMatch Assets

## Strategie-Übersicht

**Budget-Philosophie:** Indie/Startup-Budget. Launch-kritische Assets erhalten Custom Design oder AI-Generierung. Nice-to-have Assets primär Free/Open-Source oder Lottie.

---

## Vollständige Asset-Beschaffungstabelle

| ID | Asset | Quelle | Tool | Format | Kosten EUR | Priorität | Repo-Pfad | Notizen |
|---|---|---|---|---|---|---|---|---|
| **APP-BRANDING** | | | | | | | | |
| A001 | App-Icon | Custom Design | Figma + Illustrator | PNG 1024×1024 | 350 | 🔴 Launch-kritisch | `assets/branding/app_icon/` | 18 Größenvarianten exportieren; Hell+Dunkel kontrastsicher; Freelancer ~4h à €85 |
| A002 | Splash-Screen-Logo | Custom Design | Figma | SVG + PNG 2×/3× | 150 | 🔴 Launch-kritisch | `assets/branding/splash/` | Ableitung aus A001; 2 Varianten (Hell/Dunkel); Wortmarke + Icon kombiniert |
| A062 | Store-Feature-Grafik | Custom Design | Figma + Photoshop | PNG 1024×500 + 6 Screenshots | 280 | 🔴 Launch-kritisch | `assets/branding/store/` | Google Play Feature Graphic + iOS Screenshot-Set; 6 Varianten; kein Dark Mode erforderlich |
| A063 | Notification-Icon (monochrom) | Custom Design | Figma | PNG 96×96 monochrom | 80 | 🔴 Launch-kritisch | `assets/branding/notifications/` | Ableitung aus A001; Android-Pflicht: reines Weiß auf transparent; 2 Varianten |
| **GAMEPLAY-ASSETS** | | | | | | | | |
| A009 | Match-3-Spielstein-Sprite-Set | AI-generiert + Custom | Midjourney + Figma | PNG Sprite-Sheet 2×/3× | 420 | 🔴 Launch-kritisch | `assets/sprites/game_pieces/` | Mindestens 6 Steintypen × 4 States (normal, hover, matched, special); AI-Basis + Freelancer-Polish ~3h |
| A010 | Match-3-Spielfeld-Hintergrund | AI-generiert | Midjourney / Firefly | PNG 1920×1080 + 2×/3× | 40 | 🔴 Launch-kritisch | `assets/backgrounds/game_field/` | 4 thematische Varianten; kein Dark Mode; AI-Generierung mit Nachbearbeitung in Photoshop |
| A011 | Match-3-Spezialstein-Sprites | AI-generiert + Custom | Midjourney + Figma | PNG Sprite-Sheet animiert | 280 | 🔴 Launch-kritisch | `assets/sprites/special_pieces/` | Bombe, Blitz, Regenbogen-Stein etc.; 2 Varianten; Animationen via Lottie oder Frame-Sprites |
| A013 | Spielfeld-Grid-Rahmen | Custom Design | Figma | SVG + PNG 2×/3× | 160 | 🔴 Launch-kritisch | `assets/sprites/grid/` | 2 Varianten; Zellen-Design + Außenrahmen; Freelancer ~2h; kein Dark Mode nötig |
| A065 | Spielfeld-Ziel-Indikator-Icons | Free/Open-Source | Phosphor Icons + Figma | SVG + PNG 2×/3× | 0 | 🔴 Launch-kritisch | `assets/icons/level_goals/` | Phosphor-Basis + thematische Anpassung in Figma; kontrastsicher; 1 Varianten-Set |
| A066 | Hindernisse und Spezialzellen-Sprites | AI-generiert + Custom | Midjourney + Figma | PNG Sprite-Sheet animiert | 320 | 🔴 Launch-kritisch | `assets/sprites/obstacles/` | Eis, Stein, Kette, Nebel je mit Animations-Frames; kein Dark Mode; Freelancer-Finish erforderlich |
| **UI-ELEMENTE** | | | | | | | | |
| A004 | Ladebalken / Loading-Indicator | Lottie | LottieFiles Free | Lottie JSON | 0 | 🔴 Launch-kritisch | `assets/animations/loading/` | LottieFiles Free-Tier ausreichend; thematisch zum Spielstil anpassen; Hell+Dunkel |
| A014 | Zuege-Anzeige / Move-Counter | Custom Design | Figma | SVG + PNG 2×/3× | 120 | 🔴 Launch-kritisch | `assets/ui/hud/move_counter/` | Animierter Rahmen + Zahl-Highlight; 1 Variante; Dark-Mode-Version erforderlich |
| A015 | Punkte-/Score-Anzeige HUD | Custom Design | Figma | SVG + PNG 2×/3× | 120 | 🔴 Launch-kritisch | `assets/ui/hud/score/` | Score-Zuwachs-Burst als Lottie separat; 1 Variante; Dark-Mode-Version erforderlich |
| A016 | Booster-Icons im Spielfeld | AI-generiert + Custom | Midjourney + Figma | PNG 2×/3× + Lottie | 180 | 🔴 Launch-kritisch | `assets/icons/boosters/` | Hammer, Shuffle, Extra-Move etc.; je Normal + Active State; kontrastsicher |
| A020 | Reward-Item-Icons | AI-generiert + Custom | Midjourney + Figma | PNG 2×/3× | 160 | 🔴 Launch-kritisch | `assets/icons/rewards/` | Münzen, Gems, Booster-Items; 1 Varianten-Set; kontrastsicher; auch für S007/S011/S012 |
| A022 | Level-Knoten-Icons | Custom Design | Figma | SVG + PNG 2×/3× | 200 | 🔴 Launch-kritisch | `assets/icons/level_nodes/` | States: Gesperrt, Offen, Abgeschlossen, Aktuell; animierter Glow als Lottie; kontrastsicher |
| A029 | Daily-Quest-Card-Design | Custom Design | Figma | SVG + PNG 2×/3× | 240 | 🔴 Launch-kritisch | `assets/ui/cards/quest_card/` | 2 Varianten (Hell/Dunkel); Fortschrittsbalken-Element; animierte Version via Lottie |
| A030 | Quest-Icon-Set | Free/Open-Source | Phosphor Icons + Figma | SVG + PNG 2×/3× | 0 | 🟡 Nice-to-have | `assets/icons/quests/` | Phosphor: Sword, Star, Shield etc.; thematisch angepasst; kontrastsicher; 1 Set |
| A031 | Battle-Pass-Tier-Reward-Visualisierung | Custom Design | Figma | SVG + Lottie | 280 | 🔴 Launch-kritisch | `assets/ui/battle_pass/tier_bar/` | Horizontale Tier-Leiste; animiertes Freischalten via Lottie; Hell+Dunkel; 1 Variante |
| A033 | Saison-Timer-Visual | Lottie | LottieFiles Premium | Lottie JSON | 15 | 🟡 Nice-to-have | `assets/animations/season_timer/` | Countdown-Animation mit Dringlichkeits-Effekt; LottieFiles Premium-Asset; Hell+Dunkel |
| A034 | Shop-Angebots-Karten | Custom Design | Figma | SVG + PNG 2×/3× | 220 | 🔴 Launch-kritisch | `assets/ui/cards/shop_offer/` | 2 Varianten (Standard + Featured); kein Dark Mode; Freelancer ~2-3h |
| A035 | Foot-in-Door-Angebot-Highlight | Custom Design + Lottie | Figma + LottieFiles | Lottie JSON + SVG | 180 | 🔴 Launch-kritisch | `assets/ui/shop/entry_offer/` | Animiertes Highlight-Pulsieren; Pfeil oder Glow-Effekt; kein Dark Mode; 1 Variante |
| A036 | Währungs-Icons (Soft + Hard Currency) | AI-generiert + Custom | Midjourney + Figma | PNG 2×/3× | 140 | 🔴 Launch-kritisch | `assets/icons/currency/` | Münze + Gems + Premium-Token; 1 Set; kontrastsicher; wird in vielen Screens genutzt |
| A037 | Social-Hub-Avatar-Rahmen | Custom Design | Figma | SVG + PNG 2×/3× | 160 | 🟡 Nice-to-have | `assets/ui/avatar_frames/` | 4 Seltenheitsstufen (Common → Legendary); kontrastsicher; 1 Set |
| A038 | Challenge-Card-Design | Custom Design | Figma | SVG + Lottie | 200 | 🟡 Nice-to-have | `assets/ui/cards/challenge_card/` | Animierter Herausforderungs-Pulse; Hell+Dunkel; 1 Variante; Freelancer ~2h |
| A040 | Share-Result-Bild-Template | Custom Design | Figma | PNG 1080×1080 | 140 | 🟡 Nice-to-have | `assets/ui/share/result_template/` | 2 Varianten (Gewonnen/Verloren); kein Dark Mode; virales Social-Sharing-Format |
| A043 | Profil-Spieler-Avatar-Placeholder | Free/Open-Source | unDraw / Storyset | SVG + PNG 2×/3× | 0 | 🟡 Nice-to-have | `assets/illustrations/avatar_placeholder/` | unDraw oder Storyset Charakter-Illustration; kontrastsicher; 1 Variante |
| A046 | Tab-Bar-Icons | Free/Open-Source | Phosphor Icons + Figma | SVG + PNG 2×/3× | 0 | 🔴 Launch-kritisch | `assets/icons/tab_bar/` | 5 Icons (Home, Puzzle, Story, Social, Shop); je 2 States (aktiv/inaktiv); Hell+Dunkel |
| A048 | Kaltstart-Personalisierungs-Auswahlkarten | Custom Design | Figma | SVG + PNG 2×/3× | 200 | 🔴 Launch-kritisch | `assets/ui/cards/onboarding_style/` | Illustrated Cards für Spielstil-Wahl; animierter Select-State; kein Dark Mode; 1 Set |
| A049 | Onboarding-Hint-Pfeile + Tutorial-Overlays | Lottie + Custom | LottieFiles Free + Figma | Lottie JSON + SVG | 20 | 🔴 Launch-kritisch | `assets/animations/tutorial/` | Finger-Tap + Pfeil-Animationen; Highlight-Overlay; kontrastsicher; LottieFiles Free-Basis |
| A052 | Beta-Feedback-Rating-Sterne | Lottie | LottieFiles Free | Lottie JSON | 0 | 🟢 Beta-only | `assets/animations/rating_stars/` | Interaktive Stern-Animation; Hell+Dunkel; LottieFiles Free ausreichend |
| A055 | Coming-Soon-Badge (Phase-B) | Custom Design | Figma | SVG + Lottie | 80 | 🟡 Nice-to-have | `assets/ui/badges/coming_soon/` | Animiertes Pulse-Badge; kontrastsicher; 1 Variante; Freelancer ~1h |
| A057 | Leaderboard-Top-3-Podest-Design | Custom Design | Figma | SVG + PNG 2×/3× | 160 | 🟡 Nice-to-have | `assets/ui/social/podium/` | Gold/Silber/Bronze-Podest; Hell+Dunkel; 1 Variante; Trophy-Appeal |
| A058 | Haptic-Feedback-Toggle-Icon | Free/Open-Source | Phosphor Icons + Figma | SVG + PNG 2×/3× | 0 | 🟡 Nice-to-have | `assets/icons/settings/haptic_toggle/` | An/Aus-State; Hell+Dunkel; Phosphor Vibrate-Icon angepasst |
| A059 | Einstellungen-Kategorie-Icons | Free/Open-Source | Phosphor Icons + Figma | SVG + PNG 2×/3× | 0 | 🟡 Nice-to-have | `assets/icons/settings/categories/` | Sound, Haptic, Benachrichtigungen etc.; Hell+Dunkel; Phosphor-Basis |
| A067 | Social-Nudge-Banner-Design | Custom Design | Figma | SVG + Lottie | 140 | 🟡 Nice-to-have | `assets/ui/banners/social_nudge/` | Animierter Banner nach Session; Hell+Dunkel; 1 Variante; Freunde-Invite-CTA |
| A068 | Friend-Challenge-Card | Custom Design | Figma | SVG + PNG 2×/3× | 160 | 🟡 Nice-to-have | `assets/ui/cards/friend_challenge/` | Avatar + Level-Info + Challenge-Status; dynamische Daten-Slots; Hell+Dunkel |
| **ILLUSTRATIONEN** | | | | | | | | |
| A003 | Splash-Screen-Hintergrund | AI-generiert + Custom | Midjourney + Photoshop | PNG 2732×2732 | 80 | 🔴 Launch-kritisch | `assets/backgrounds/splash/` | 4 Varianten (Tageszeit/Saison); kein Dark Mode; AI-Basis + Photoshop-Compositing |
| A005 | Offline-Error-Illustration | Free/Open-Source | unDraw / Storyset | SVG + PNG 2×/3× | 0 | 🟡 Nice-to-have | `assets/illustrations/error_states/offline/` | unDraw "No Connection" thematisch angepasst; Hell+Dunkel; 1 Variante |
| A006 | DSGVO-Consent-Illustration | Free/Open-Source | unDraw + Figma | SVG + PNG 2×/3× | 0 | 🔴 Launch-kritisch | `assets/illustrations/legal/dsgvo/` | 2 Varianten (Consent + Datenschutz-Visual); Hell+Dunkel; unDraw Privacy-Set |
| A007 | ATT-Prompt-Visual | AI-generiert + Custom | Firefly + Figma | SVG + PNG 2×/3× | 40 | 🔴 Launch-kritisch | `assets/illustrations/legal/att_prompt/` | iOS-spezifisch; erklärender Charakter/Visual; Hell+Dunkel; erhöht ATT-Opt-in-Rate |
| A008 | Minderjährigen-Block-Illustration | AI-generiert + Custom | Midjourney + Figma | SVG + PNG 2×/3× | 40 | 🔴 Launch-kritisch | `assets/illustrations/legal/age_block/` | Freundlich aber klar; COPPA-konform; kein Dark Mode; 1 Variante |
| A018 | Level-Verloren-Illustration | AI-generiert + Custom | Midjourney + Figma | PNG 2×/3× | 80 | 🔴 Launch-kritisch | `assets/illustrations/game_states/lose/` | Empathischer Charakter; nicht demotivierend; kein Dark Mode; 1 Variante |
| A021 | Level-Map-Pfad-Grafik | Custom Design | Figma + Illustrator | SVG + PNG 2×/3× | 320 | 🔴 Launch-kritisch | `assets/illustrations/level_map/path/` | Geschwungener Fortschrittspfad; thematisch; kein Dark Mode; Freelancer ~3-4h |
| A023 | Level-Map-Hintergrund-Welten | AI-generiert + Custom | Midjourney + Photoshop | PNG 2×/3× | 160 | 🔴 Launch-kritisch | `assets/backgrounds/level_map/worlds/` | 2+ thematische Welten; kein Dark Mode; AI-Basis + Freelancer-Finish |
| A028 | Home Hub Hero-Banner | AI-generiert + Custom | Midjourney + Figma | PNG 2×/3× | 180 | 🔴 Launch-kritisch | `assets/illustrations/home_hub/hero_banner/` | 3 Varianten (Tageszeit/Event/Saison); kein Dark Mode; dynamisch wechselbar |
| A032 | Battle-Pass-Saison-Banner | AI-generiert + Custom | Midjourney + Photoshop | PNG 2×/3× | 120 | 🔴 Launch-kritisch | `assets/illustrations/battle_pass/season_banner/` | Key-Art pro Saison; kein Dark Mode; 1 Variante; für S012 + S005 |
| A039 | Keine-Freunde-Empty-State-Illustration | Free/Open-Source | unDraw / Storyset | SVG + PNG 2×/3× | 0 | 🟡 Nice-to-have | `assets/illustrations/empty_states/no_friends/` | Einladende Illustration; Hell+Dunkel; unDraw "Friends" angepasst |
| A041 | Rewarded-Ad-Angebots-Illustration | AI-generiert | Midjourney / Firefly | PNG 2×/3× | 20 | 🟡 Nice-to-have | `assets/illustrations/monetization/rewarded_ad/` | Reward visuell dargestellt; kein Dark Mode; 1 Variante; erhöht Ad-Watch-Rate |
| A045 | Sync-Fehler-Illustration | Free/Open-Source | unDraw + Figma | SVG + PNG 2×/3× | 0 | 🟡 Nice-to-have | `assets/illustrations/error_states/sync_error/` | Verbindungsproblem spielweltlich; Hell+Dunkel; unDraw "Sync" angepasst |
| A047 | Push-Notification-Opt-In-Illustration | Free/Open-Source | Storyset + Figma | SVG + PNG 2×/3× | 0 | 🟡 Nice-to-have | `assets/illustrations/permissions/push_optin/` | 2 Varianten (Nutzen-Erklärung + Bestätigung); kein Dark Mode; Storyset Notification-Set |
| A056 | Phase-B-Teaser-Illustrationen | AI-generiert + Custom | Midjourney + Figma | PNG 2×/3× | 80 | 🟡 Nice-to-have | `assets/illustrations/phase_b_teaser/` | Live-Ops Event Hub + Gilden-Card Teaser; kein Dark Mode; 1 Variante; Neugier wecken |
| **ANIMATIONEN & EFFEKTE** | | | | | | | | |
| A012 | Match-Animation-Effekte | Custom Design | After Effects + Lottie | Lottie JSON | 380 | 🔴 Launch-kritisch | `assets/animations/match_effects/` | Partikel-Burst pro Steintyp; kein Dark Mode; Kernbefriedigungsmoment; Freelancer ~4h |
| A017 | Level-Gewonnen-Animation | Custom Design | After Effects + Lottie | Lottie JSON | 300 | 🔴 Launch-kritisch | `assets/animations/game_states/win/` | Konfetti + Sterne + Charakter; kein Dark Mode; 1 Variante; emotionaler Höhepunkt |
| A019 | Stern-Bewertungs-Animation | Lottie | LottieFiles Premium | Lottie JSON | 15 | 🔴 Launch-kritisch | `assets/animations/star_rating/` | 1-3 Sterne sequenziell; kein Dark Mode; LottieFiles Premium-Asset verfügbar |
| A042 | Ad-Lade-Animation | Lottie | LottieFiles Free | Lottie JSON | 0 | 🟡 Nice-to-have | `assets/animations/ad_loading/` | Kurze thematische Loop-Animation; kein Dark Mode; LottieFiles Free ausreichend |
| A050 | KI-Level-Lade-Platzhalter-Animation | Custom Design | After Effects + Lottie | Lottie JSON | 240 | 🔴 Launch-kritisch | `assets/animations/ai_level_loading/` | Spielweltliche Szene; kein Dark Mode; 1 Variante; überbrückt KI-Latenz |
| A051 | Neues-Level-Freischalten-Animation | Lottie | LottieFiles Free + Custom | Lottie JSON | 20 | 🟡 Nice-to-have | `assets/animations/level_unlock/` | Level-Knoten-Pop + Glow; kein Dark Mode; LottieFiles Free-Basis angepasst |
| A053 | Feedback-Gesendet-Danke-Animation | Lottie | LottieFiles Free | Lottie JSON | 0 | 🟢 Beta-only | `assets/animations/feedback_sent/` | Häkchen-Animation; kein Dark Mode; LottieFiles Free "Success" ausreichend |
| A054 | A/B-Test-Loader-Animation | Lottie | LottieFiles Free | Lottie JSON | 0 | 🔴 Launch-kritisch | `assets/animations/ab_test_loader/` | Dezent und transparent; Hell+Dunkel; LottieFiles Free ausreichend; kein Branding |
| A060 | Reward-Freischalten-Animation | Custom Design | After Effects + Lottie | Lottie JSON | 280 | 🔴 Launch-kritisch | `assets/animations/reward_unlock/` | Items regnen herunter; kein Dark Mode; 1 Variante; für S012/S013/S007 |
| A061 | Quest-Abgeschlossen-Checkmark-Animation | Lottie | LottieFiles Free | Lottie JSON | 0 | 🟡 Nice-to-have | `assets/animations/quest_complete/` | Grünes Häkchen füllend; Hell+Dunkel; LottieFiles Free "Checkmark" angepasst |
| A064 | IAP-Kauf-Bestätigungs-Animation | Custom Design | After Effects + Lottie | Lottie JSON | 200 | 🟡 Nice-to-have | `assets/animations/iap_purchase/` | Feier-Regen von Reward-Items; kein Dark Mode; 1 Variante; reduziert Chargeback-Risiko |
| **DATENVISUALISIERUNG** | | | | | | | | |
| A044 | Statistik-Visualisierungs-Grafiken | Native + Custom | React Native Charts + Figma | SVG / Native Components | 120 | 🟡 Nice-to-have | `assets/ui/statistics/charts/` | Victory Native oder React Native Chart Kit; Hell+Dunkel; 1 Set; Freelancer-Styling ~1-2h |
| **STORY / NARRATIVE ASSETS** | | | | | | | | |
| A024 | Narrative-Hook-Sequenz-Artwork | AI-generiert + Custom | Midjourney + Photoshop | PNG 2×/3× | 320 | 🔴 Launch-kritisch | `assets/illustrations/story/narrative_hook/` | 3-5 Story-Panels; kein Dark Mode; AI-Basis + Freelancer-Komposition; emotionaler Hook |
| A025 | Story-Charakter-Portraits | Custom Design | Procreate / Illustrator | PNG 2×/3× | 480 | 🔴 Launch-kritisch | `assets/illustrations/story/characters/` | 3+ Hauptcharaktere; je Normal/Emotion-States; kein Dark Mode; Freelancer ~5-6h |
| A026 | Story-Kapitel-Cover-Illustrationen | AI-generiert + Custom | Midjourney + Photoshop | PNG 2×/3× | 200 | 🔴 Launch-kritisch | `assets/illustrations/story/chapter_covers/` | 1 Cover pro Kapitel; kein Dark Mode; AI-Basis + Freelancer-Konsistenz-Check |
| A027 | Story-Scene-Hintergründe | AI-generiert + Custom | Midjourney + Photoshop | PNG 2×/3× | 240 | 🔴 Launch-kritisch | `assets/backgrounds/story/scenes/` | 3 verschiedene Orte; kein Dark Mode; AI-Basis + Photoshop-Finish; für S004 + S009 |

---

## Budget-Zusammenfassung

| Kategorie | Anzahl Assets | Gesamt-Kosten EUR | Ø pro Asset |
|---|---|---|---|
| App-Branding | 4 | 860 | 215 |
| Gameplay-Assets | 6 | 1.220 | 203 |
| UI-Elemente | 27 | 2.973 | 110 |
| Illustrationen | 15 | 1.120 | 75 |
| Animationen & Effekte | 11 | 1.435 | 130 |
| Datenvisualisierung | 1 | 120 | 120 |
| Story / Narrative | 4 | 1.240 | 310 |
| **GESAMT** | **68** | **~8.968** | **~132** |

---

## Quellen-Verteilung

| Quelle | Anzahl Assets | Anteil |
|---|---|---|
| Custom Design (Freelancer) | 28 | 41% |
| AI-generiert + Custom Finish | 18 | 26% |
| Free/Open-Source | 12 | 18% |
| Lottie (Free/Premium) | 10 | 15% |

---

## Kritische Pfad-Hinweise

> **Woche 1-2 (Sofort beauftragen):**
> A001, A002, A009, A010, A012, A025 — Blockieren alle weiteren UI-Entscheidungen

> **Woche 3-4:**
> A003, A013, A017, A021, A024, A028, A036, A046, A049, A050

> **Pre-Launch (Woche 5-6):**
> Alle verbleibenden 🔴 Launch-kritisch Assets + Store-Assets A062/A063

> **Post-Launch (iterativ):**
> Alle 🟡 Nice-to-have und 🟢 Beta-only Assets

## Technische Format-Anforderungen
| Asset-Typ | Format | Aufloesung/Groesse | Tool | Hinweise |
|---|---|---|---|---|
| unity_sprites | PNG / Sprite Sheet |  | TexturePacker 7.x → Unity Importer | Keine POT-Pflicht ab Unity 2022+, aber 2er-Potenzen empfohlen für Kompression |
| game_piece_sprites | PNG Sprite Sheet via TexturePacker |  |  |  |
| backgrounds | PNG | 1920x1080px @2x (3840x2160 Master) |  | Hintergrund-Layer separat exportieren (BG-Layer, Mid-Layer, FX-Layer) für Parallax |
| icons | SVG für UI-Icons, PNG @2x/@3x für In-Game |  |  |  |
| animations | Lottie JSON (UI-Animationen, Loading, Feedback) |  | After Effects 2025 + Bodymovin 5.x Plugin | Statisches PNG @2x wenn Lottie >500KB oder Runtime-Performance-Problem |
| app_icon_ios | PNG |  | Figma Export + Asset Catalog Xcode | Kein Alpha-Kanal, kein Gradient über gesamte Fläche (Apple Review Richtlinie) |
| app_icon_android | PNG Adaptive Icon |  | Android Studio Asset Studio + Figma Export | Adaptive Icon: Foreground + Background als separate Layer im XML definiert |
| screenshots_store | PNG (kein JPEG, keine Kompressionsartefakte) |  | Figma Store-Screenshot-Template + Photoshop Finalisierung |  |
| audio |  |  |  |  |
| fonts | TTF / OTF Master → Unity Font Asset (TMP) |  | TextMesh Pro Font Asset Creator | Lizenz-Prüfung für Mobile-Embedding vor Integration (SIL OFL oder Commercial-Lizenz) |

## Kosten-Uebersicht
| Kategorie | Anzahl | Kosten | Quellen-Mix |
|---|---|---|---|
| App-Branding | 4 | 860 EUR | 100% Custom Design (Figma + Illustrator + Photoshop) |
| Gameplay-Sprites | 6 | 1,220 EUR | 50% AI-generiert + Custom Polish (Midjourney/Firefly + Figma), 30% Custom Design, 20% Free/Open-Source |
| UI-Elemente / HUD | 5 | 580 EUR | 40% Custom Design, 40% AI-generiert + Custom, 20% Lottie Free |
| Development (Phase A MVP + KI-PoC) | 0 | 252,500 EUR | Unity Cross-Platform Dev + Cloud-Backend + CMP/ATT + iOS Native Bridge |
| Development (Phase B Full Production) | 0 | 230,000 EUR | Unity Full Production Aufschlag (KI-Live, Social-Layer, Narrative) |
| Asset-Produktion Gesamt (Branding + Gameplay + UI) | 15 | 2,660 EUR | Custom Design 45%, AI+Custom 40%, Free/Open-Source 15% |

## Budget-Check
- **Geschaetzte Gesamtkosten:** {'phase_a_development': 252500, 'asset_production_launch_critical': 2660, 'phase_a_gesamt': 255160, 'phase_b_development': 230000, 'gesamtprojekt_inkl_phase_b': 485160, 'hinweis': 'Ohne UA-Budget, ohne laufende Server-Kosten, ohne App-Store-Gebühren; Revenue-Prognosen nach 15-30% Platform-Commission'} EUR
- **Verfuegbares Budget:** {'wert': 'Nicht in vorliegenden Reports definiert', 'empfehlung': 'Budget-Freigabe durch Finance vor Phase-B-Commit einholen; Phase-A-Commitment €255.160 als Mindest-Seed-Kapital', 'soft_launch_threshold': 'Phase A €255.160 validiert KI-PoC und MVP; Phase B nur bei positiven Soft-Launch-KPIs (D30 Retention >15%, ARPU Tier-1 >€0.30)'} EUR
- **Status:** phase_a_kalkulierbar_phase_b_budget_pending_validierung

## Asset-Uebergabe-Protokoll
- **Ordnerstruktur:** {'root': 'assets/', 'subdirectories': {'branding': {'app_icon': 'assets/branding/app_icon/', 'splash': 'assets/branding/splash/', 'store': 'assets/branding/store/', 'notifications': 'assets/branding/notifications/'}, 'sprites': {'game_pieces': 'assets/sprites/game_pieces/', 'special_pieces': 'assets/sprites/special_pieces/', 'obstacles': 'assets/sprites/obstacles/', 'grid': 'assets/sprites/grid/', 'characters': 'assets/sprites/characters/'}, 'backgrounds': 'assets/backgrounds/', 'ui': {'hud': 'assets/ui/hud/', 'menus': 'assets/ui/menus/', 'modals': 'assets/ui/modals/', 'buttons': 'assets/ui/buttons/'}, 'icons': {'boosters': 'assets/icons/boosters/', 'rewards': 'assets/icons/rewards/', 'level_goals': 'assets/icons/level_goals/', 'navigation': 'assets/icons/navigation/'}, 'animations': {'loading': 'assets/animations/loading/', 'feedback': 'assets/animations/feedback/', 'celebrations': 'assets/animations/celebrations/', 'transitions': 'assets/animations/transitions/'}, 'audio': {'sfx': 'assets/audio/sfx/', 'music': 'assets/audio/music/', 'ui_sounds': 'assets/audio/ui_sounds/'}, 'fonts': 'assets/fonts/', 'source_files': 'assets/_source/', 'exports_raw': 'assets/_exports_raw/', 'readme': 'assets/README.md'}}
- **Naming-Convention:** {'schema': 'lowercase_snake_case', 'pattern': '[asset_id]_[descriptor]_[variant]_[resolution].[ext]', 'examples': ['a001_app_icon_default_1024.png', 'a009_game_piece_blue_normal_3x.png', 'a009_game_piece_blue_matched_3x.png', 'a011_special_piece_bomb_sheet_2048.png', 'a004_loading_indicator_loop.json', 'a010_bg_forest_theme_2x.png'], 'variant_suffixes': {'hell_modus': '_light', 'dunkel_modus': '_dark', 'retina_2x': '_2x', 'retina_3x': '_3x', 'animiert': '_anim', 'static_fallback': '_static', 'sheet': '_sheet'}, 'verboten': ['Leerzeichen', 'Umlaute (ä/ö/ü)', 'Großbuchstaben', 'Sonderzeichen außer _ und -', 'Versionsnummern im Dateinamen (Version via Git-Tag)']}
### Delivery-Checkliste
- [ ] EXPORT-QUALITÄT: Alle PNGs mit lossless-Kompression exportiert (pngquant oder TinyPNG max 85% Kompression)
- [ ] EXPORT-QUALITÄT: Alle SVGs optimiert via SVGO (removeComments, removeMetadata, cleanupIDs)
- [ ] EXPORT-QUALITÄT: Lottie-JSONs validiert via LottieFiles Preview (Loop, Timing, keine fehlenden Assets)
- [ ] AUFLÖSUNGEN: 2x UND 3x Varianten für alle Sprites und Icons vorhanden
- [ ] AUFLÖSUNGEN: @1x nur wenn explizit für Low-End-Android-Fallback angefordert
- [ ] DARK MODE: Alle als Dark-Mode-pflichtig markierten Assets (A014, A015) in _light und _dark Variante vorhanden
- [ ] FARBPROFIL: Alle Assets in sRGB (kein Adobe RGB, kein CMYK)
- [ ] ALPHA: Transparenz-Check — kein unerwartetes Weiß durch falsche Alpha-Vorverarbeitung
- [ ] KONTRAST: WCAG AA 4.5:1 Check für alle UI-Icons gegen Ziel-Hintergrundfarbe (Screenshot als Nachweis)
- [ ] NAMING: Dateinamen entsprechen snake_case-Schema, Asset-ID als Präfix vorhanden
- [ ] ORDNERSTRUKTUR: Alle Dateien im definierten Repo-Pfad abgelegt (kein Assets-Dump im Root)
- [ ] SPRITE-SHEETS: TexturePacker-Atlas-Dateien (.tpsheet) UND exportierte PNGs vorhanden
- [ ] SPRITE-SHEETS: Sprite-Daten-JSON / Unity-Sprite-Metadata mitgeliefert
- [ ] AUDIO: SFX als WAV (Master) + OGG/AAC (komprimiert) vorhanden
- [ ] AUDIO: Loop-Points in BGM-Tracks getestet (kein Click am Loop-Punkt)
- [ ] APP-ICONS: iOS — alle 10 Größenvarianten exportiert, keine Transparenz, Display P3
- [ ] APP-ICONS: Android — Adaptive-Icon-Layer (Foreground/Background) separat, Notification-Icon monochrom weiß
- [ ] STORE-ASSETS: iOS Screenshots in 1290x2796 und 1242x2688, Feature Graphic Android 1024x500
- [ ] SOURCE-FILES: Figma-Link oder .fig-Export in assets/_source/ hinterlegt
- [ ] LIZENZ: Alle AI-generierten Assets (Midjourney, Firefly) mit Lizenz-Dokumentation in assets/_source/licenses.md
- [ ] LIZENZ: Free/Open-Source-Assets mit Quelle und Lizenz-Typ dokumentiert (z.B. Phosphor Icons MIT)
- [ ] ÜBERGABE: Git-Tag mit Versionsnummer gesetzt (z.B. assets-v1.0.0-soft-launch)
- [ ] ÜBERGABE: README.md in assets/ aktualisiert mit Änderungslog und offenen TODOs
- [ ] ÜBERGABE: Developer-Briefing: Asset-ID-Mapping-Tabelle an Unity-Entwickler übergeben
- [ ] UNITY-INTEGRATION: Import-Settings-Vorlage (.meta-Dateien) für TextureImporter-Einstellungen mitgeliefert
- [ ] UNITY-INTEGRATION: Sprite-Atlas-Konfiguration (.spriteatlasv2) für jede Asset-Kategorie vorbereitet
- [ ] FINAL-CHECK: Smoke-Test auf physischem iOS- und Android-Gerät durchgeführt (kein Pixelrauschen, keine fehlenden Frames)
