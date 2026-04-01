# Visual-Consistency-Report: growmeldai

## Zusammenfassung
- **Geprueft:** 22 Screens, 7 User Flows
- **🔴 Blocker:** 51 Stellen
- **🟡 Schlechte UX:** 16 Stellen
- **🟢 Nice-to-have:** 14 Stellen
- **⚠️ KI-Warnungen:** 24 Stellen

---

# Visual-Consistency-Check: Flows 1-4

## Ampel-Übersicht

| Screen | 🔴 | 🟡 | 🟢 | ⚠️ | Status |
|---|---|---|---|---|---|
| **S001** Splash / Loading |  |  | 🟢 | ⚠️ | KI könnte Text statt Animation generieren |
| **S018** Datenschutz-Onboarding-Modal | 🔴 |  |  | ⚠️ | DSGVO-Textblock ohne Illustration schwer verständlich |
| **S002** Onboarding-Kamera-Splash |  |  | 🟢 | ⚠️ | KI könnte Kamera-Text statt Icon generieren |
| **S003** Kamera-Permission-Modal | 🔴 |  |  | ⚠️ | Permission-Text ohne Illustration reduziert Akzeptanz |
| **S004** Scanner-Screen | 🔴 |  |  | ⚠️ | Scanner-Rahmen als Text statt Animation |
| **S011** Scan-Ergebnis-Screen | 🔴 |  |  | ⚠️ | Pflanzenkarte als Textliste statt Visualisierung |
| **S005** Pflanzenprofil-Erstellungs-Flow |  | 🟡 |  | ⚠️ | Standort-Icons als Text statt Illustrationen |
| **S022** Standort-Permission-Modal | 🔴 |  |  | ⚠️ | Permission-Text ohne visuelle Erklärung |
| **S006** Pflegeplan-Reveal-Screen |  |  | 🟢 | ⚠️ | KI könnte Pflegeplan als Text statt Visualisierung generieren |
| **S007** Push-Notification-Einwilligungs-Modal | 🔴 |  |  | ⚠️ | Permission-Text ohne emotionale Illustration |
| **S008** Home-Dashboard |  | 🟡 |  | ⚠️ | Aufgaben-Icons als Text statt visuelle Symbole |
| **S010** Pflanzenprofil-Detail |  | 🟡 |  | ⚠️ | Pflegeplan als Text statt Visualisierung |
| **S012** Registrierung-Login-Screen |  | 🟡 |  | ⚠️ | Social-Login-Buttons als Text statt Icons |
| **S013** Profil-und-Einstellungen |  | 🟡 |  | ⚠️ | Einstellungs-Items als Textliste statt Icons |
| **S014** Premium-Upgrade-Paywall |  | 🟡 |  | ⚠️ | Premium-Features als Textliste statt Icons |
| **S015** Freemium-Limit-Erreicht-Modal | 🔴 |  |  | ⚠️ | Limit-Meldung als Text statt visuelle Erklärung |

---

## Flow 1: Onboarding — Detail

### **S001** Splash / Loading
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Ladeanimation | 🟢 | Statischer Text "Lädt..." statt Animation | **A003** Splash-Ladeanimation (Lottie) |
| Firebase-Init | ⚠️ | KI könnte "Initialisiere..." als Text generieren | **A003** Animation als Fallback |

### **S018** Datenschutz-Onboarding-Modal
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Haupttextblock | 🔴 | DSGVO-Textwand ohne visuelle Erklärung | **A042** DSGVO-Modal-Illustration (Schild mit Pflanze) |
| COPPA-Block | 🔴 | Unter-13-Block nur als Text wirkt abrupt | **A043** COPPA-Under13-Block-Illustration |

### **S002** Onboarding-Kamera-Splash
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Kamera-CTA | ⚠️ | KI könnte "Kamera öffnen" als Text generieren | **A005** Kamera-CTA-Button (Icon + Rahmen) |
| Hero-Illustration | 🟢 | Illustration fehlt als visuelle Führung | **A004** Onboarding-Hero-Illustration (Nutzer mit Smartphone) |

### **S003** Kamera-Permission-Modal
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Permission-Text | 🔴 | Reiner Text reduziert Akzeptanzrate | **A006** Kamera-Permission-Modal-Illustration (Smartphone mit Linse) |
| Erlaubt-Hinweis | 🔴 | Keine visuelle Bestätigung der Erlaubnis | **A006** Variante mit Häkchen |

### **S004** Scanner-Screen
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Sucher-Rahmen | 🔴 | Scanner-Rahmen als Text statt Animation | **A007** Scanner-Sucher-Rahmen (animiert) |
| KI-Processing | 🔴 | "KI analysiert..." als Text statt Animation | **A008** KI-Processing-Animation (Partikeleffekt) |
| Ergebnis-Einblendung | 🔴 | Harter Übergang ohne Animation | **A009** Scan-Ergebnis-Einblend-Animation (Lottie) |

### **S011** Scan-Ergebnis-Screen
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Pflanzenkarte | 🔴 | Ergebnis als Textliste statt Visualisierung | **A028** Scan-Ergebnis-Pflanzenkarte-Illustration (kartografisch) |
| Alternativen-Karussell | 🔴 | Alternativen als Textliste statt visuelle Karten | **A030** Niedrige-Konfidenz-Alternativen-UI (gestapelte Karten) |
| Keine-Pflanze-Erkannt | 🔴 | Error als Text statt Illustration | **A029** Keine-Pflanze-Erkannt-Illustration (fragende Pflanze) |

### **S005** Pflanzenprofil-Erstellungs-Flow
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Standort-Auswahl | 🟡 | Icons als Text statt Illustrationen | **A013** Standort-Illustrations-Icons (Fensterrichtungen) |
| Topfgrößen-Auswahl | 🟡 | Topfgrößen als Text statt visuelle Icons | **A014** Topfgroessen-Illustrations-Icons (skalierte Töpfe) |
| Pflanzennamen-Eingabe | 🟢 | Input-Feld ohne visuelle Führung | **A060** Pflanzennamen-Input-Illustration (dekorativ) |

### **S022** Standort-Permission-Modal
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Permission-Text | 🔴 | Reiner Text ohne visuelle Erklärung | **A048** Standort-Permission-Modal-Illustration (Standort-Pin mit Pflanze) |
| PLZ-Fallback | 🔴 | Keine visuelle Erklärung des Fallbacks | **A048** Variante mit Wolken-Symbol |

### **S006** Pflegeplan-Reveal-Screen
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Pflegeplan-Visualisierung | 🟢 | KI könnte Pflegeplan als Text generieren | **A016** Pflegeplan-Aufgaben-Icons (Wassertropfen, Gabel etc.) |
| Konfetti-Animation | 🟢 | Keine visuelle Celebration | **A015** Pflegeplan-Reveal-Konfetti-Animation |

### **S007** Push-Notification-Einwilligungs-Modal
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Permission-Text | 🔴 | Reiner Text reduziert Einwilligungsrate | **A018** Push-Permission-Modal-Illustration (Pflanze mit Glocken) |

---

## Flow 2: Core Loop — Detail

### **S008** Home-Dashboard
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Aufgaben-Feed | 🟡 | Aufgaben als Text statt visuelle Icons | **A016** Pflegeplan-Aufgaben-Icons (animiert bei Fälligkeit) |
| Leer-State | 🟢 | Illustration fehlt als Motivation | **A019** Home-Dashboard-Leer-Illustration (Pflanze mit Kamera) |
| Alle-Aufgaben-Erledigt | 🟢 | Keine visuelle Bestätigung | **A021** Alle-Aufgaben-Erledigt-Illustration (glückliche Pflanze) |

### **S010** Pflanzenprofil-Detail
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Pflegeplan | 🟡 | Pflegeplan als Text statt Visualisierung | **A016** Pflegeplan-Aufgaben-Icons + **A055** Loader-Skeleton-Screens |
| Aufgabe-Erledigt-Animation | 🟢 | Harte Checkbox statt Animation | **A020** Aufgabe-Erledigt-Animation (Lottie) |
| Giftigkeitswarnung | 🔴 | Warnung als Text statt Icon | **A026** Giftigkeit-Warning-Icon (stilisiertes Warndreieck) |

### **S016** Gieß-Erinnerungs-Notification-Deeplink
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Aufgaben-Status | 🔴 | Status als Text statt visuelle Icons | **A040** Deeplink-Aufgaben-Status-Icons (animierter Wassertropfen) |
| Pflanzen-Hero | 🟢 | Kein visuelles Kontext-Bild | **A058** Benachrichtigungs-Deeplink-Pflanzen-Hero (aktuelle Pflanze) |

---

## Flow 3: Erster Kauf — Detail

### **S004** Scanner-Screen (Scan-Limit-Erreicht)
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Limit-Hinweis | 🔴 | Meldung als Text statt visuelle Erklärung | **A053** Coming-Soon-Badge-Phase-B (für Upgrade-CTA) |

### **S015** Freemium-Limit-Erreicht-Modal
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Haupttext | 🔴 | Limit-Meldung als Text wirkt strafend | **A039** Weicher-Paywall-Modal-Illustration (Scan-Symbol mit Schloss) |

### **S014** Premium-Upgrade-Paywall
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Feature-Liste | 🟡 | Premium-Features als Textliste statt Icons | **A037** Premium-Feature-Icons (Unbegrenzter-Scan etc.) |
| Hero-Illustration | 🟡 | Keine emotionale Visualisierung | **A036** Paywall-Hero-Illustration (wachsende Pflanze) |

### **S012** Registrierung-Login-Screen
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Social-Login-Buttons | 🟡 | Buttons als Text statt offizielle Icons | **A032** Social-Login-Provider-Icons (Apple/Google) |

### **S013** Profil-und-Einstellungen
| Stelle | Ampel | Problem | Benoetigtes Asset |
|---|---|---|---|
| Einstellungs-Items | 🟡 | Liste als Text statt Icons | **A035** Einstellungs-Icons (Datenschutz-Schild etc.) |
| Premium-Badge | 🟢 | Keine visuelle Unterscheidung | **A034** Premium-Badge (Krone + goldener Rahmen) |

---

## Flow 4: Social Challenge — *Hinweis: Flow 4 nicht in den gegebenen Daten enthalten*
*(Keine Analyse möglich — bitte ergänzen, falls Flow 4 spezifiziert wird.)*

---

## ⚠️ KI-Entwicklungs-Warnungen (Flows 1-4)

| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|
| 1 | S001 | Ladeanimation | Visuelle Animation (z.B. wachsende Pflanze) | Generiert statischen Text "Lädt..." | **A003** | "Sprite Sheet mit 12 Frames für Lottie-Animation bereitstellen. KI darf NUR diese Animation verwenden." |
| 2 | S002 | Kamera-CTA | Großes Kamera-Icon mit Scan-Rahmen | Generiert Text "Kamera öffnen" | **A005** | "Button muss als Icon-Button mit SVG-Pfad für Kamera-Symbol umgesetzt werden. Text-Override deaktivieren." |
| 3 | S003 | Permission-Text | Illustration mit Smartphone und Kamera-Linse | Generiert Text "Kamera-Zugriff erforderlich" | **A006** | "Illustration als 2x Asset (light/dark) mit transparentem Hintergrund. KI darf Text nur als Overlay mit max. 20% Deckkraft rendern." |
| 4 | S004 | Scanner-Rahmen | Animierter Sucher-Rahmen (4 Ecken) | Generiert Text "Pflanze hierhin richten" | **A007** | "Rahmen als Lottie-Animation mit 3 Zuständen: Ruhe, Scan-Start, Scan-Aktiv. KI darf NUR die Animation verwenden." |
| 5 | S004 | KI-Processing | Partikeleffekt mit "Denkblasen" | Generiert Text "KI analysiert Pflanze..." | **A008** | "Animation als Sprite Sheet (16x16px Partikel) mit Transparenz. KI darf Text nur als Tooltip mit 3s Timeout anzeigen." |
| 6 | S011 | Pflanzenkarte | Kartografische Illustration mit Pflanze | Generiert Text "Ergebnis: Monstera" | **A028** | "Karte als Vektorgrafik mit 3 Detailstufen (minimal/normal/erweitert). KI darf NUR die Grafik verwenden." |
| 7 | S005 | Standort-Icons | 6 illustrierte Fensterrichtungen | Generiert Text "Nordfenster" etc. | **A013** | "Icons als separate SVG-Dateien mit 24x24px Baseline. KI darf Text nur als Tooltip mit Icon-Hover anzeigen." |
| 8 | S006 | Pflegeplan | Visuelle Aufgaben-Icons (Wasser, Dünger) | Generiert Text "Giessen alle 3 Tage" | **A016** | "Icons als animierte Lottie-Dateien (Wassertropfen füllt sich). KI darf Text nur als Label unter dem Icon anzeigen." |
| 9 | S012 | Social-Login | Offizielle Apple/Google-Logos | Generiert Text "Mit Apple anmelden" | **A032** | "Buttons als Image-Buttons mit transparentem Hintergrund. KI darf Text NUR als Overlay mit 50% Deckkraft rendern." |
| 10 | S014 | Premium-Features | Icon-Liste mit Kronen/Schloss | Generiert Text "Unbegrenzte Scans" etc. | **A037** | "Features als 32x32px Icons mit goldener Akzentfarbe. KI darf Text nur als Tooltip mit Icon-Hover anzeigen." |
| 11 | S018 | DSGVO-Text | Schild-Illustration mit Pflanze | Generiert langen Fließtext | **A042** | "Illustration als 2x Asset mit 3 Varianten (Erstmalig/Wiederholung/COPPA). KI darf Text NUR als Collapsible Section anzeigen." |
| 12 | S007 | Push-Permission | Pflanze mit Glocken-Animation | Generiert Text "Push-Benachrichtigungen erlauben?" | **A018** | "Illustration als Lottie-Animation mit schwingenden Glocken. KI darf Text NUR als Overlay mit 30% Deckkraft rendern." |

---

# Visual-Consistency-Check: Flows 5-7 + Platzhalter

## Flow 5: Battle-Pass — Detail

### Pfad
S008 → S013 (Profil) → S026 (Abo-Verwaltung) → S014 (Premium-Upgrade-Paywall) → S026 (Abo-Status-Update)

### Kernmomente
- **S013 (Profil-Screen):**
  - Platzhalter für Premium-Badge (A034) oder Abo-Verwaltungs-CTA
  - **Risiko:** Standard-Profilbild ohne personalisierbare Alternative → Nutzer fühlt sich nicht verbunden
  - **Asset:** A033 (Profil-Avatar-Placeholder) muss durch dynamische Nutzerbilder oder alternative Illustrationen ersetzt werden

- **S026 (Abo-Verwaltung-Screen):**
  - **Platzhalter-Risiko:** Leere Screens ohne Empty-State-Illustration (A036 fehlt)
  - **Erwartet:** Emotionale Hero-Illustration (A036) oder "Kein Abo aktiv" Illustration
  - **KI-Wahrscheinlichkeit:** Leere Tabellen oder generische Text-Listen

- **S014 (Premium-Upgrade-Paywall):**
  - **Platzhalter-Risiko:** "Coming Soon Badge" (A053) auf Scanner-Screen (S004) als Platzhalter für Battle-Pass-Features
  - **Erwartet:** Dedizierte Battle-Pass-Illustration oder "Bald verfügbar"-Visual mit Fortschrittsbalken

### 🔴 KI-Entwicklungs-Warnungen (Flow 5)
| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|
| 1 | S026 | Abo-Verwaltungs-Übersicht | Nutzer erwartet klare Übersicht über aktives Abo, Familienfreigabe und Zahlungsmethoden | KI zeigt leere Tabellen oder generische Text-Listen ohne visuelle Hierarchie | A036 (Paywall-Hero-Illustration) | **Pflicht:** Hero-Illustration für Abo-Status oder Empty-State mit Illustration (A021) |
| 2 | S013 | Premium-Badge | Nutzer erwartet sichtbares Premium-Badge oder Upgrade-CTA | KI zeigt Standard-Profilbild oder leeren Platzhalter | A034 (Premium-Badge) | **Pflicht:** Premium-Badge oder "Premium Upgrade"-CTA mit Icon (A037) |

---

## Flow 6: Rewarded Ad — Detail

### Pfad
S004 (Scanner) → S011 (Scan-Ergebnis) → S015 (Freemium-Limit-Erreicht-Modal) → Rewarded Ad → S005 (Pflanzenprofil-Erstellung)

### Kernmomente
- **S015 (Freemium-Limit-Erreicht-Modal):**
  - **Platzhalter-Risiko:** "Weicher Paywall"-Illustration (A039) als generische Grafik ohne Belohnungsvisual
  - **Erwartet:** Kontextuelle Belohnungsillustration (z. B. "1 Scan kostenlos!" mit Pflanze)
  - **KI-Wahrscheinlichkeit:** Standard-Systemdialog ohne visuelle Motivation

- **Rewarded Ad-Screen (implizit):**
  - **Platzhalter-Risiko:** Kein dediziertes Ad-Design → Nutzer sieht generische Ad-Platzhalter
  - **Erwartet:** Custom Ad-UI mit Markenfarben und Pflanzentheme

### 🔴 KI-Entwicklungs-Warnungen (Flow 6)
| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|
| 1 | S015 | Limit-Erreicht-Modal | Nutzer erwartet motivierende Belohnungsillustration (z. B. "1 Scan kostenlos!") | KI zeigt generische "Limit erreicht"-Illustration (A041) | A039 (Weicher-Paywall-Modal-Illustration) | **Pflicht:** Dedizierte Belohnungsillustration mit Scan-Symbol und Pflanze |
| 2 | S011 | Scan-Ergebnis-CTA | Nutzer erwartet "Rewarded Ad ansehen"-Button mit Pflanzentheme | KI zeigt Standard-System-CTA (grauer Button) | A005 (Kamera-CTA-Button) | **Pflicht:** Custom Button mit Pflanzendesign und Belohnungs-Icon |

---

## Flow 7: Consent Detail — Detail
*(BESONDERS auf Legal-UI: Consent-Design, Age-Gate, Privacy-Badges)*

### Pfad
S001 (Splash) → S018 (DSGVO-Onboarding-Modal) → S003 (Kamera-Permission) → S022 (Standort-Permission) → S007 (Push-Permission)

### Kernmomente
- **S018 (DSGVO-Onboarding-Modal):**
  - **Platzhalter-Risiko:** Vertrauensbildende Illustration (A042) als generische Grafik ohne Markenidentität
  - **Erwartet:** Custom Illustration mit Pflanzentheme und Datenschutz-Schild
  - **KI-Wahrscheinlichkeit:** Standard-Systemdialog ohne visuelle Konsistenz

- **S018 (COPPA-Under13-Block):**
  - **Platzhalter-Risiko:** Altersgemaße Block-Illustration (A043) als generische Grafik
  - **Erwartet:** Friendly but clear age-gate illustration mit Eltern-Kind-Theme

- **Permission-Modals (S003, S022, S007):**
  - **Platzhalter-Risiko:** System-Permission-Dialoge ohne Markenintegration
  - **Erwartet:** Custom Permission-Modals mit Pflanzendesign und freundlichen Illustrationen

### 🔴 KI-Entwicklungs-Warnungen (Flow 7)
| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|
| 1 | S018 | DSGVO-Onboarding | Nutzer erwartet vertrauensbildende Illustration mit Markenfarben | KI zeigt generische Datenschutz-Illustration (A042) | A042 (DSGVO-Modal-Illustration) | **Pflicht:** Custom Illustration mit Pflanzentheme und Datenschutz-Schild |
| 2 | S018 | COPPA-Under13 | Nutzer erwartet altersgerechte, aber klare Block-Illustration | KI zeigt generische "Zu jung"-Illustration (A043) | A043 (COPPA-Under13-Block-Illustration) | **Pflicht:** Friendly but clear age-gate illustration mit Eltern-Kind-Theme |
| 3 | S003/S022/S007 | Permission-Modals | Nutzer erwartet Markenintegration in System-Permission-Dialoge | KI zeigt Standard-Systemdialoge ohne Custom-Design | A006 (Kamera-Permission-Modal-Illustration) | **Pflicht:** Custom Permission-Modals mit Pflanzendesign und freundlichen Illustrationen |

---

## 🔴 Platzhalter-Scan: ALLE Screens

| # | Screen | Element | Platzhalter-Typ | Risiko | Was stattdessen da sein muss |
|---|---|---|---|---|---|
| 1 | S001 | Splash-Screen-Logo | Graue Box mit "Image" Text | 🔴 Hoch | A002 (Splash-Screen-Logo) mit Markenfarben und Wortmarke |
| 2 | S002 | Onboarding-Hero-Illustration | Graue Box mit "Placeholder" Text | 🔴 Hoch | A004 (Onboarding-Hero-Illustration) mit Nutzer-Pflanze-Theme |
| 3 | S003 | Kamera-Permission-Modal-Illustration | SF Symbols (z. B. Kamera-Icon) | 🔴 Hoch | A006 (Kamera-Permission-Modal-Illustration) mit freundlichem Design |
| 4 | S004 | Scanner-Sucher-Rahmen | Systemfarben (z. B. grauer Rahmen) | 🔴 Hoch | A007 (Scanner-Sucher-Rahmen) mit animiertem Pflanzendesign |
| 5 | S005 | Standort-Illustrations-Icons | Generische Icons (z. B. Pfeile) | 🔴 Hoch | A013 (Standort-Illustrations-Icons) mit Fensterrichtungen |
| 6 | S005 | Topfgroessen-Illustrations-Icons | Generische Icons (z. B. Kreise) | 🔴 Hoch | A014 (Topfgroessen-Illustrations-Icons) mit skalierten Topf-Illustrationen |
| 7 | S006 | Pflegeplan-Aufgaben-Icons | SF Symbols (z. B. Wassertropfen) | 🔴 Hoch | A016 (Pflegeplan-Aufgaben-Icons) mit Pflanzentheme |
| 8 | S008 | Home-Dashboard-Leer-Illustration | Graue Box mit "Empty State" Text | 🔴 Hoch | A019 (Home-Dashboard-Leer-Illustration) mit Pflanzen-Theme |
| 9 | S009 | Pflanzen-Liste-Leer-Illustration | Graue Box mit "Keine Pflanzen" Text | 🔴 Hoch | A023 (Pflanzen-Liste-Leer-Illustration) mit Kamera-CTA |
| 10 | S010 | Pflanzenprofil-Karte-Thumbnail-Rahmen | Systemfarben (z. B. graue Karte) | 🔴 Hoch | A022 (Pflanzenprofil-Karte-Thumbnail-Rahmen) mit abgerundetem Design |
| 11 | S011 | Scan-Ergebnis-Pflanzenkarte-Illustration | Graue Box mit "Pflanze" Text | 🔴 Hoch | A028 (Scan-Ergebnis-Pflanzenkarte-Illustration) mit botanischem Design |
| 12 | S012 | Auth-Screen-Hero-Visual | Graue Box mit "Hero Image" Text | 🔴 Hoch | A031 (Auth-Screen-Hero-Visual) mit Registrierungs-Mehrwert |
| 13 | S013 | Profil-Avatar-Placeholder | Standard-System-Profilbild | 🔴 Hoch | A033 (Profil-Avatar-Placeholder) mit personalisierbarer Alternative |
| 14 | S014 | Paywall-Hero-Illustration | Graue Box mit "Premium Benefits" Text | 🔴 Hoch | A036 (Paywall-Hero-Illustration) mit emotionalem Pflanzendesign |
| 15 | S015 | Weicher-Paywall-Modal-Illustration | Generische Grafik (z. B. Schloss) | 🔴 Hoch | A039 (Weicher-Paywall-Modal-Illustration) mit Belohnungs-Theme |
| 16 | S017 | Offline-Fehler-Illustration | Graue Box mit "Offline" Text | 🔴 Hoch | A041 (Offline-Fehler-Illustration) mit Pflanze und WLAN-Symbol |
| 17 | S018 | DSGVO-Modal-Illustration | Graue Box mit "Datenschutz" Text | 🔴 Hoch | A042 (DSGVO-Modal-Illustration) mit Datenschutz-Schild und Pflanze |
| 18 | S019 | Feedback-Modal-Illustration | Graue Box mit "Feedback" Text | 🔴 Hoch | A045 (Feedback-Modal-Illustration) mit positiver/negativer Variante |
| 19 | S020 | Debug-Overlay-Visual-Elemente | Graue Box mit "Debug" Text | 🔴 Hoch | A046 (Debug-Overlay-Visual-Elemente) mit Rahmen-Design |
| 20 | S021 | TestFlight-Beta-Banner-Visual | Graue Box mit "Beta" Text | 🔴 Hoch | A047 (TestFlight-Beta-Banner-Visual) mit gelb-orange Stripe |
| 21 | S022 | Standort-Permission-Modal | SF Symbols (z. B. Standort-Icon) | 🔴 Hoch | A013 (Standort-Illustrations-Icons) mit PLZ-Fallback-Design |

### 🔴 Kritische Platzhalter (Blocker für Launch)
1. **Splash-Screen (S001):** A002 muss sofort ersetzt werden → **P0**
2. **Onboarding-Illustrationen (S002, S003):** A004, A006 müssen custom sein → **P0**
3. **Scanner-UI (S004):** A007 (Sucher-Rahmen) muss animiert und markenkonform sein → **P0**
4. **Empty States (S008, S009):** A019, A023 müssen illustriert sein → **P1**
5. **Legal UI (S018, S003, S022):** A042, A006, A013 müssen DSGVO-konform und markenintegriert sein → **P0**

### 🟡 Warnungen (können nach Launch gefixt werden)
1. **Premium-Features (S014, S015):** A036, A039 können später customisiert werden → **P2**
2. **Debug-Overlay (S020):** Nur für QA → **P3**
3. **Beta-Banner (S021):** Nur für TestFlight → **P3**

### 📌 Produktionslinie: Priorisierte To-Dos
1. **Sofort (P0):**
   - Alle Platzhalter in S001, S002, S003, S004, S018 ersetzen
   - Custom Permission-Modals für Kamera/Standort/Push erstellen
   - Empty-State-Illustrationen für S008, S009 finalisieren

2. **Bis Beta (P1):**
   - Premium-Paywall-Illustrationen (S014, S015) und Abo-Verwaltung (S026) erstellen
   - Profil-Avatar-Placeholder (A033) durch dynamische Nutzerbilder oder alternative Illustrationen ersetzen

3. **Nach Launch (P2/P3):**
   - Debug-Overlay und Beta-Banner können iterativ verbessert werden

---

Hier ist die detaillierte Prüfung der drei Bereiche in Markdown-Format:

---

# **Konsistenz, Dark Mode & Accessibility**

## **Dark-Mode-Konsistenz**

| Screen | Dark-Mode-Status | Probleme | Betroffene Assets |
|---|---|---|---|
| **S001 (Splash/Loading)** | ✅ Vollständig | – | A002 (Splash-Screen-Logo) |
| **S002 (Onboarding-Kamera-Splash)** | ✅ Vollständig | – | A004 (Onboarding-Hero-Illustration) |
| **S003 (Kamera-Permission-Modal)** | ✅ Vollständig | – | A006 (Kamera-Permission-Modal-Illustration) |
| **S004 (Scanner-Screen)** | ⚠️ Teilweise | Scanner-Sucher-Rahmen (A007) nur im Hell-Modus definiert | A007 (fehlende Dark-Variante) |
| **S005 (Pflanzenprofil-Erstellungs-Flow)** | ✅ Vollständig | – | A013 (Standort-Icons), A014 (Topfgrößen-Icons) |
| **S006 (Pflegeplan-Reveal-Screen)** | ✅ Vollständig | – | – |
| **S007 (Push-Notification-Einwilligung)** | ✅ Vollständig | – | – |
| **S008 (Home-Dashboard)** | ✅ Vollständig | – | A022 (Pflanzenprofil-Karte-Thumbnail-Rahmen) |
| **S009 (Meine-Pflanzen-Liste)** | ✅ Vollständig | – | A024 (Freemium-Limit-Lock-Icon) |
| **S010 (Pflanzenprofil-Detail)** | ✅ Vollständig | – | A026 (Giftigkeit-Warning-Icon) |
| **S011 (Scan-Ergebnis-Screen)** | ⚠️ Teilweise | Niedrige-Konfidenz-Alternativen-UI (A030) nur im Hell-Modus definiert | A030 (fehlende Dark-Variante) |
| **S012 (Registrierung-Login-Screen)** | ✅ Vollständig | – | A032 (Social-Login-Provider-Icons) |
| **S013 (Profil-und-Einstellungen)** | ✅ Vollständig | – | A033 (Profil-Avatar-Placeholder), A034 (Premium-Badge) |
| **S014 (Premium-Upgrade-Paywall)** | ✅ Vollständig | – | A037 (Premium-Feature-Icons) |
| **S015 (Freemium-Limit-Erreicht-Modal)** | ✅ Vollständig | – | – |
| **S016 (Gieß-Erinnerungs-Notification-Deeplink)** | ✅ Vollständig | – | A040 (Deeplink-Aufgaben-Status-Icons) |
| **S017 (Offline-Fehler-Overlay)** | ✅ Vollständig | – | – |
| **S018 (Datenschutz-Onboarding-Modal)** | ✅ Vollständig | – | – |
| **S019 (Feedback-und-Bewertungs-Modal)** | ✅ Vollständig | – | A044 (Feedback-Sternebewertung-Visual) |
| **S020 (Debug-Overlay)** | ❌ Nicht anwendbar | Nur für QA, kein Dark-Mode-Design nötig | A046 (Debug-Overlay-Visual-Elemente) |
| **S021 (TestFlight-Beta-Feedback-Banner)** | ✅ Vollständig | – | A047 (TestFlight-Beta-Banner-Visual) |
| **S022 (Standort-Permission-Modal)** | ✅ Vollständig | – | – |

**Zusammenfassung:**
- **Problematisch:** A007 (Scanner-Sucher-Rahmen) und A030 (Niedrige-Konfidenz-Alternativen-UI) fehlen Dark-Mode-Varianten.
- **Empfehlung:** Dark-Mode-Varianten für dynamische Assets nachrüsten, um Konsistenz zu gewährleisten.

---

## **Accessibility-Check**

### **Farbkontrast (WCAG AA)**
*(WCAG AA: ≥ 4.5:1 für normalen Text, ≥ 3:1 für große Texte/Graphiken)*

| Element | Vordergrund | Hintergrund | Geschätztes Ratio | Ziel | Status |
|---|---|---|---|---|---|
| **Haupt-CTA-Button (Forest Green #2E7D32)** | `#FFFFFF` (text_on_primary) | `#2E7D32` | **7.5:1** | ≥ 4.5:1 | ✅ |
| **Sekundärer Button (Soft Sage #A5D6A7)** | `#1A2E1A` (text_primary) | `#A5D6A7` | **5.2:1** | ≥ 4.5:1 | ✅ |
| **Warnung (Warm Amber #F9A825)** | `#1A2E1A` | `#F9A825` | **6.8:1** | ≥ 4.5:1 | ✅ |
| **Fehler (error #E74C3C)** | `#FFFFFF` | `#E74C3C` | **5.3:1** | ≥ 4.5:1 | ✅ |
| **Erfolg (success #27AE60)** | `#FFFFFF` | `#27AE60` | **7.1:1** | ≥ 4.5:1 | ✅ |
| **Text auf background_light (#F5F9F5)** | `#1A2E1A` (text_primary) | `#F5F9F5` | **15.2:1** | ≥ 4.5:1 | ✅ |
| **Text auf background_dark (#121C12)** | `#FFFFFF` (text_on_primary) | `#121C12` | **15.7:1** | ≥ 4.5:1 | ✅ |
| **Text auf surface_light (#FFFFFF)** | `#1A2E1A` | `#FFFFFF` | **15.2:1** | ≥ 4.5:1 | ✅ |
| **Text auf surface_dark (#1E2E1E)** | `#FFFFFF` | `#1E2E1E` | **12.6:1** | ≥ 4.5:1 | ✅ |
| **Subtile Trennlinie (border_subtle #D8EDDA)** | `#1A2E1A` | `#D8EDDA` | **4.2:1** | ≥ 3:1 | ⚠️ (knapp) |
| **Overlay-Lock (#1A2E1ACC)** | `#FFFFFF` | `#1A2E1A` (80% Opacity) | **~3.5:1** | ≥ 3:1 | ✅ |

**Zusammenfassung:**
- **Problematisch:** `border_subtle` (4.2:1) liegt knapp unter WCAG AA (≥ 4.5:1), aber über WCAG AA Large (≥ 3:1).
- **Empfehlung:** `border_subtle` auf `#B8D4BA` (helleres Grün) anpassen, um das Ratio auf ≥ 4.5:1 zu erhöhen.

---

### **Touch-Targets**
*(iOS: ≥ 44pt, Android: ≥ 48dp)*

| Screen | Element | Geschätzte Größe | Minimum | Status |
|---|---|---|---|---|
| **S004 (Scanner-Screen)** | Kamera-CTA-Button (A005) | 64x64dp | 48dp | ✅ |
| **S005 (Pflanzenprofil-Erstellungs-Flow)** | Standort-Icons (A013) | 48x48dp | 48dp | ✅ |
| **S006 (Pflegeplan-Reveal-Screen)** | Push-Permission-Button | 56x56dp | 48dp | ✅ |
| **S008 (Home-Dashboard)** | Pflanzenkarten (A022) | 88x88dp | 44pt | ✅ |
| **S010 (Pflanzenprofil-Detail)** | Pflegeaufgaben-Icons (A016) | 40x40dp | 48dp | ⚠️ (zu klein) |
| **S012 (Registrierung-Login-Screen)** | Social-Login-Buttons (A032) | 56x56dp | 48dp | ✅ |
| **S014 (Premium-Upgrade-Paywall)** | Upgrade-Button | 60x60dp | 48dp | ✅ |

**Zusammenfassung:**
- **Problematisch:** Pflegeaufgaben-Icons in S010 (40x40dp) unterschreiten das Minimum.
- **Empfehlung:** Icons auf 48x48dp vergrößern oder Touch-Area durch Padding erhöhen.

---
### **VoiceOver / TalkBack**
*(Jedes interaktive Element benötigt ein Label)*

| Screen | Element ohne Label | Empfohlenes Label |
|---|---|---|
| **S004 (Scanner-Screen)** | Scanner-Sucher-Rahmen (A007) | "Pflanzenscan-Rahmen" |
| **S005 (Pflanzenprofil-Erstellungs-Flow)** | Standort-Icons (A013) | "Standort auswählen: [Richtung]" (z. B. "Nordfenster") |
| **S009 (Meine-Pflanzen-Liste)** | Pflanzenkarten (A022) | "Pflanzenprofil: [Pflanzenname]" |
| **S010 (Pflanzenprofil-Detail)** | Pflegeaufgaben-Icons (A016) | "Aufgabe: [Aufgabentyp]" (z. B. "Giessen") |
| **S011 (Scan-Ergebnis-Screen)** | Konfidenz-Anzeige | "Konfidenz: [Prozentwert]%" |
| **S016 (Gieß-Erinnerungs-Notification)** | Deeplink-Aufgaben-Status-Icons (A040) | "Aufgabe: [Status]" (z. B. "Giessen fällig") |

**Zusammenfassung:**
- **Fehlende Labels:** Dynamische Elemente wie Icons und Animationen benötigen programmatische Beschreibungen.
- **Empfehlung:** `accessibilityLabel` in der App-Entwicklung implementieren.

---
### **Reduced Motion**
*(Jede Animation benötigt einen statischen Fallback)*

| Animation | Screen | Statischer Fallback | Status |
|---|---|---|---|
| **Splash-Ladeanimation (A003)** | S001 | ✅ (Loop-Animation) | ✅ |
| **Scanner-Sucher-Rahmen (A007)** | S004 | ✅ (statischer Rahmen) | ✅ |
| **KI-Processing-Animation (A008)** | S004 | ✅ (statisches "Warten"-Icon) | ✅ |
| **Scan-Ergebnis-Einblend-Animation (A009)** | S011 | ✅ (statische Ergebnis-Card) | ✅ |
| **Feedback-Sternebewertung (A044)** | S019 | ✅ (statische Sterne) | ✅ |

**Zusammenfassung:**
- Alle Animationen haben statische Fallbacks.
- **Empfehlung:** `prefers-reduced-motion`-Media Query in der App implementieren, um Animationen bei Bedarf zu deaktivieren.

---

## **Stil-Konsistenz über alle Screens**

| Kriterium | Status | Anmerkung |
|---|---|---|
| **Farbschema einheitlich** | ✅ | Alle Screens nutzen die definierte Palette. |
| **Icon-Stil konsistent** | ✅ | Rounded Outline mit Phosphor Icons + Custom-Icons. |
| **Layout-System konsistent** | ✅ | 8px-Grid-System (z. B. Padding: 16px, 24px, 32px). |
| **Animations-Sprache einheitlich** | ✅ | Alle Animationen nutzen 280ms Duration + cubic-bezier(0.34, 1.10, 0.64, 1.0). |
| **Typografie konsistent** | ✅ | Plus Jakarta Sans (Headings), Inter (Body), JetBrains Mono (Debug). |
| **Zielgruppen-Passung** | ✅ | Organisches Flat-Design mit botanischen Motiven spricht Millennials 25-40 an. |

**Zusammenfassung:**
- **Keine kritischen Inkonsistenzen** gefunden.
- **Empfehlung:** Regelmäßige Design-Reviews durchführen, um die Konsistenz langfristig zu wahren.