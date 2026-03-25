# Visual-Consistency-Report: memerun2026

## Zusammenfassung
- **Geprueft:** 22 Screens, 7 User Flows
- **🔴 Blocker:** 6 Stellen
- **🟡 Schlechte UX:** 14 Stellen
- **🟢 Nice-to-have:** 34 Stellen
- **⚠️ KI-Warnungen:** 26 Stellen

---

# Visual-Consistency-Check: Flows 1-4

## Ampel-Übersicht
| Screen | 🔴 | 🟡 | 🟢 | ⚠️ | Status |
|---|---|---|---|---|---|
| **S001** Splash / Loading |  |  | 🟢 | ⚠️ | OK |
| **S014** Privacy Consent Modal |  |  | 🟢 | ⚠️ | OK |
| **S002** Authentication |  | 🟡 |  | ⚠️ | Warnung |
| **S003** Tutorial |  |  | 🟢 | ⚠️ | OK |
| **S004** Main Menu |  |  | 🟢 | ⚠️ | OK |
| **S005** Game Screen |  | 🟡 |  | ⚠️ | Warnung |
| **S006** Pause/Fail Modal |  |  | 🟢 | ⚠️ | OK |
| **S018** Fail-Clip Recording & Export |  | 🟡 |  | ⚠️ | Warnung |
| **S015** Share Result Modal |  |  | 🟢 | ⚠️ | OK |

---

## Flow 1: Onboarding — Detail

### **S001** Splash / Loading
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Branding** | 🟢 | Logo und Hintergrund werden angezeigt | A001 (App-Icon), A003 (Splash Logo), A002 (Splash Background) |
| **Ladebalken** | 🟢 | Standard-Ladeanimation | Kein Asset nötig (Systemstandard) |
| **Fehlermeldung (Offline)** | ⚠️ | Nutzer erwartet visuelle Rückmeldung bei Ladefehlern | A047 (Error Modal Background), A048 (Offline Icon) |

### **S014** Privacy Consent Modal
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Hintergrund** | 🟢 | Abgedunkelter Hintergrund mit Illustration | A050 (Privacy Consent Modal Background), A052 (Privacy Illustration) |
| **Button-Icons** | 🟢 | Akzeptieren/Eingeschränkt/Ablehnen-Buttons | A051 (Consent Button Icons) |
| **Text-Placeholder** | ⚠️ | KI wird wahrscheinlich generischen Text einfügen | **Kein Text!** → **A051 muss als visuelle Alternative dienen** (z. B. Icons mit Tooltips) |

### **S002** Authentication
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Login-Button** | 🟡 | Nutzer erwartet visuelle Hervorhebung | A006 (Login Button Icon) + Hintergrund (A009) |
| **Registrierungs-Button** | 🟡 | Gleiche Problematik wie Login | A007 (Registration Button Icon) + Hintergrund (A009) |
| **Cloud-Save-Icon** | 🟢 | Wird korrekt angezeigt | A008 (Cloud Save Icon) |
| **Fehlermeldung (Auth-Fehler)** | ⚠️ | Nutzer erwartet visuelle Rückmeldung | A047 (Error Modal Background), A049 (Retry Button Icon) |

### **S003** Tutorial
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Tutorial-Schritte** | 🟢 | Schritt-für-Schritt-Anleitung mit Illustrationen | A010 (Tutorial Overlay Illustrations), A011 (Tutorial Step Indicator) |
| **Tap-to-Jump-Animation** | 🟢 | Visuelle Anleitung für Steuerung | A017 (Character Sprite Animation) |
| **Swipe-Intro** | 🟢 | Visuelle Darstellung der Swipe-Gesten | A017 (Character Sprite Animation) |

### **S004** Main Menu
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Play-Button** | 🟢 | Visuell hervorgehoben | A013 (Play Button Icon) |
| **Navigations-Icons** | 🟢 | Leaderboard, Shop, Profil, Settings | A014 (Dashboard Navigation Icons) |
| **Hintergrund** | 🟢 | Modernes Meme-Design | A012 (Main Menu Background Illustration) |

---

## Flow 2: Core Loop — Detail

### **S005** Game Screen
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Spieler-Charakter** | 🟡 | Nutzer erwartet klare Animationen | A017 (Character Sprite Animation) |
| **Hindernisse** | 🟡 | Nutzer erwartet erkennbare Objekte | A018 (Obstacle Sprite Pack) |
| **Sammelobjekte (Meme-Items)** | 🟡 | Nutzer erwartet visuelle Unterscheidung | A019 (Meme Item Sprite Collection) |
| **Power-Up-Icon** | 🟡 | Nutzer erwartet sofortige Erkennbarkeit | A029 (Power-Up Icon Pack) |
| **Pause-Button** | 🟢 | Standard-UI-Element | Systemstandard (kein Asset nötig) |
| **Fehlermeldung (Spielabsturz)** | ⚠️ | Nutzer erwartet visuelle Rückmeldung | A047 (Error Modal Background), A049 (Retry Button Icon) |

### **S006** Pause/Fail Modal
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Hintergrund** | 🟢 | Abgedunkelter Overlay | A021 (Modal Background Overlay) |
| **Retry-Button** | 🟢 | Visuell hervorgehoben | A022 (Retry Button Icon) |
| **Share-Button** | 🟢 | Visuell hervorgehoben | A023 (Share Fail Clip Button Icon) |
| **Quit-Button** | 🟢 | Standard-UI-Element | Systemstandard (kein Asset nötig) |

### **S018** Fail-Clip Recording & Export
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Aufnahme-Overlay** | 🟡 | Nutzer erwartet klare UI-Elemente | A060 (Fail-Clip Recording UI Overlay) |
| **Timeline-Slider** | 🟡 | Nutzer erwartet präzise Steuerung | A061 (Timeline Slider for Video) |
| **Aufnahme-Button** | 🟡 | Nutzer erwartet sofortige Erkennbarkeit | A062 (Recording Button Icon) |
| **Fehlermeldung (Aufnahme fehlgeschlagen)** | ⚠️ | Nutzer erwartet visuelle Rückmeldung | A047 (Error Modal Background), A049 (Retry Button Icon) |

### **S015** Share Result Modal
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Hintergrund** | 🟢 | Abgedunkelter Overlay | A053 (Share Modal Background) |
| **Social-Media-Icons** | 🟢 | TikTok, Reels, etc. | A054 (Social Media Icon Pack) |
| **Share-Button** | 🟢 | Visuell hervorgehoben | A055 (Share Button Icon) |

---

## Flow 3: Erster Kauf — Detail

### **S008** Shop / IAP
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Hintergrund** | 🟢 | Modernes Shop-Design | A027 (Shop Background Illustration) |
| **Kosmetik-Icons** | 🟢 | Nutzer erwartet klare Darstellung | A028 (Cosmetic Item Icon Pack) |
| **Power-Up-Icons** | 🟢 | Nutzer erwartet sofortige Erkennbarkeit | A029 (Power-Up Icon Pack) |
| **Preis-Tags** | 🟢 | Nutzer erwartet klare Preisangaben | A044 (Price Tag Icon) |

### **S012** IAP Confirmation Modal
| Stelle | Ampel | Problem | Benötigtes Asset |
|---|---|---|---|
| **Hintergrund** | 🟢 | Abgedunkelter Overlay | A043 (IAP Confirmation Modal Background) |
| **Bestätigungs-Button** | 🟢 | Visuell hervorgehoben | A045 (Confirm Purchase Button Icon) |
| **Abbrechen-Button** | 🟢 | Standard-UI-Element | Systemstandard (kein Asset nötig) |
| **Fehlermeldung (Transaktionsfehler)** | ⚠️ | Nutzer erwartet visuelle Rückmeldung | A047 (Error Modal Background), A049 (Retry Button Icon) |

---

## Flow 4: Social Challenge — Detail

### **S005** Game Screen (Wiederholung)
*(Siehe Flow 2)*

### **S018** Fail-Clip Recording & Export (Wiederholung)
*(Siehe Flow 2)*

### **S015** Share Result Modal (Wiederholung)
*(Siehe Flow 2)*

---

## ⚠️ KI-Entwicklungs-Warnungen (Flows 1-4)

| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|
| 1 | **S014** | Privacy Consent Text | Nutzer erwartet **visuelle Icons** (z. B. Schilder für Datenschutz) | KI generiert langen Fließtext | **A051 (Consent Button Icons)** | **Ersetze alle Text-Placeholders durch A051!** Nutzer sollen Icons mit Tooltips sehen, nicht Text. |
| 2 | **S002** | Auth-Button-Beschriftungen | Nutzer erwartet **Icons + klare Handlungsaufforderung** | KI generiert generische Buttons mit "Login" / "Registrieren" | **A006, A007** | **Verwende nur Icons + Hintergrund (A009)!** Kein Text auf Buttons. |
| 3 | **S005** | Power-Up-Anzeige | Nutzer erwartet **visuelle Icons** (z. B. Blitz für Turbo) | KI generiert Text wie "Power-Up aktiv!" | **A029 (Power-Up Icon Pack)** | **Zeige Icons statt Text an!** Nutze Sprite Sheets für Animationen. |
| 4 | **S018** | Aufnahme-Button | Nutzer erwartet **großes, klares Icon** | KI generiert kleinen Textbutton "Aufnehmen" | **A062 (Recording Button Icon)** | **Ersetze alle Text-Buttons durch A062!** Nutze nur Icons mit Tooltips. |
| 5 | **S008** | Shop-Item-Beschreibungen | Nutzer erwartet **Icons + kurze Tooltips** | KI generiert lange Beschreibungen | **A028, A029** | **Keine Textbeschreibungen!** Nutze Icons mit Hover-Tooltips. |
| 6 | **S006** | Fail-Clip-Share-Button | Nutzer erwartet **visuellen CTA** | KI generiert generischen Textbutton | **A023 (Share Fail Clip Button Icon)** | **Ersetze Text durch A023!** Nutze nur Icons. |
| 7 | **S004** | Navigations-Icons | Nutzer erwartet **klare Icons** | KI generiert Text-Labels | **A014 (Dashboard Navigation Icons)** | **Keine Text-Labels!** Nutze nur Icons mit Tooltips. |

---

# Visual-Consistency-Check: Flows 5-7 + Platzhalter

---

## **Flow 5: Battle-Pass — Detail**

### **Pfad:**
**S004 (Main Menu) → S010 (Profile) → S008 (Shop)**
- **Taps bis Ziel:** 2
- **Session-Ziel:** 3–5 Minuten (Battle-Pass-Übersicht + optional Upgrade-Kauf)
- **Beschreibung:**
  - User navigiert über Tab-Bar zu **Profile (S010)** → Battle-Pass-Sektion zeigt:
    - Aktuellen XP-Fortschritt (visuell als Fortschrittsbalken oder Level-Anzeige)
    - Freigeschaltete Rewards der aktuellen Season (mit Icons/Avataren)
    - Gesperrte Rewards mit Countdown zur nächsten Season oder Preisangabe
    - **CTA-Button** für Battle-Pass-Upgrade (falls verfügbar) → führt direkt zu **Shop (S008)**
  - **Fallback bei Sync-Fehler:**
    - S010 zeigt **Syncing-State** (Ladeanimation) → lokaler Fortschritt wird angezeigt
    - **Error-State** mit Retry-Button und Hinweis auf Cloud-Synchronisation
  - **Fallback bei abgelaufener Season:**
    - Leerer Reward-Track mit **Coming Soon Badge (A063)** und Countdown zur nächsten Season
    - Verweis auf **Live-Ops Event-Hub (S020)** als Platzhalter

### **UI-Konsistenz-Check:**
✅ **Farben:**
- Battle-Pass-Fortschrittsbalken nutzt **Markenfarbe (z. B. Neon-Grün)** für XP
- Gesperrte Rewards sind **deaktiviert (grau/transparenz)** mit Preis-Overlay
- Freigeschaltete Rewards haben **goldenen Rahmen** (wie in Shop-Icons A028)

⚠️ **Potenzielle Inkonsistenzen:**
- **XP-Anzeige:** Falls als Textfeld umgesetzt → muss **dynamisch skalierbar** sein (z. B. "Level 5/10")
- **Reward-Icons:** Müssen **gleiches Design-System** wie Shop-Icons (A028) folgen (gleiche Größe, Rahmen, Hover-Effekte)
- **Countdown-Timer:** Muss **visuell abgehoben** sein (z. B. rote Akzentfarbe für "Season endet in 2 Tagen")

🔴 **Platzhalter-Risiko:**
- **A063 (Coming Soon Badge)** wird aktuell nur als Platzhalter in S020 genutzt → muss in S010 als **visueller Hinweis** auf nächste Season eingebunden werden (z. B. als Overlay auf gesperrten Rewards).

---

## **Flow 6: Rewarded Ad — Detail**

### **Pfad:**
**S005 (Game Screen) → S006 (Pause/Fail Modal) → S005 (Gameplay fortgesetzt)**
- **Taps bis Ziel:** 1
- **Session-Ziel:** 1–2 Minuten (Ad-Integration ohne Unterbrechung)
- **Beschreibung:**
  - Während des Spiels (S005) erscheint im **Pause/Fail Modal (S006)** ein **Rewarded-Ad-CTA** (z. B. "Watch Ad for Extra Life").
  - User tippt auf CTA → **Inline-Ad** wird abgespielt (kein Fullscreen-Interrupt).
  - Nach vollständigem Ansehen:
    - **Reward wird sofort vergeben** (z. B. +1 Leben, Power-Up)
    - User kehrt **nahtlos zu S005** zurück (kein Ladebildschirm, kein Modal-Close-Delay).
  - **Fallback bei Ad-Fehler:**
    - S006 zeigt **Error-State** mit Retry-Button → Ad wird neu geladen.
    - Falls Ad nicht verfügbar: **generischer Hinweis** ("Ad currently unavailable. Try again later.").

### **UI-Konsistenz-Check:**
✅ **Design-System:**
- **Ad-CTA-Button** nutzt **Markenfarbe (z. B. Blau)** mit **Play-Icon (A006)** für Konsistenz mit anderen Buttons.
- **Ad-Overlay** hat **transparente Hintergrundfarbe** (wie Modal-Hintergrund A021) mit **abgedunkeltem Spielhintergrund**.
- **Reward-Anzeige** nach Ad nutzt **gleiche Animation** wie Power-Up-Aktivierung (z. B. Pop-up mit "+1 Life").

⚠️ **Potenzielle Inkonsistenzen:**
- **Ad-Integration:** Muss **plattformspezifisch** umgesetzt werden (AdMob für Android, SKAdNetwork für iOS).
- **Reward-Delay:** Falls Reward erst nach Ad-Ende vergeben wird → **visueller Countdown** (z. B. "Reward in 3...") für Transparenz.
- **Error-Handling:** Muss **lokalisiert** sein (z. B. "Ad konnte nicht geladen werden" auf Deutsch/Englisch).

🔴 **Platzhalter-Risiko:**
- **Ad-Placeholder:** Falls kein Ad-SDK integriert → **generischer Button mit "Ad unavailable"** → muss durch **echtes Ad-System** ersetzt werden.
- **Reward-Animation:** Aktuell kein Asset für Reward-Pop-up → muss als **dynamische UI-Animation** umgesetzt werden.

---

## **Flow 7: Consent Detail — Detail**
*(Fokus auf Legal-UI: Consent-Design, Age-Gate, Privacy-Badges)*

### **Pfad:**
**S001 (Splash) → S014 (Privacy Consent Modal) → S002 (Authentication)**
- **Taps bis Ziel:** 2
- **Session-Ziel:** 10–15 Sekunden (Compliance vor Onboarding)
- **Beschreibung:**
  - App startet mit **Splash Screen (S001)** → **Privacy Consent Modal (S014)** erscheint **automatisch** (kein Skip möglich).
  - Modal zeigt:
    1. **Hauptüberschrift:** "Datenschutz & Compliance" (DSGVO/COPPA-konform)
    2. **Kurze Zusammenfassung** der Datenverarbeitung (z. B. "Wir speichern deine Highscores in der Cloud.").
    3. **Drei Consent-Optionen** (Icons + Text):
       - ✅ **Vollständig akzeptieren** (grüner Haken, Markenfarbe)
       - ⚠️ **Eingeschränkt akzeptieren** (gelbes Ausrufezeichen, weniger Tracking)
       - ❌ **Ablehnen** (rotes Kreuz, generische Inhalte ohne Tracking)
    4. **Altersabfrage (Age-Gate):**
       - Falls User unter 13/16 (je nach Region) → **COPPA-konforme Meldung** ("Eltern müssen zustimmen").
       - **Eltern-E-Mail-Feld** erscheint (mit Validierung).
    5. **CTA-Buttons:**
       - **"Weiter"** (aktiviert nur bei gültigem Consent)
       - **"Datenschutzerklärung"** (verlinkt zu A050-Hintergrund mit detaillierten Infos)
  - **Fallback bei Consent-Ablehnung:**
    - User wird zu **S002 (Authentication)** weitergeleitet → **generische Meme-Levels** ohne AI-Generierung.
    - **Kein Cloud-Save**, **kein Tracking**, **keine personalisierten Inhalte**.
  - **Fallback bei Age-Gate-Fehler:**
    - Modal zeigt **Error-State** mit Retry-Button → erneute Eingabe der E-Mail.

### **UI-Konsistenz-Check:**
✅ **Legal-Design-Standards:**
- **Consent-Buttons** nutzen **klare Farbcodierung** (Grün = Akzeptieren, Gelb = Eingeschränkt, Rot = Ablehnen).
- **Altersabfrage** ist **visuell abgehoben** (z. B. mit **roter Umrandung** für COPPA-Hinweis).
- **Datenschutzerklärung** ist als **unterstrichener Link** umgesetzt (wie in A051).

⚠️ **Potenzielle Inkonsistenzen:**
- **Textlänge:** Consent-Text muss **kurz und verständlich** sein (max. 2–3 Sätze pro Option).
- **Button-Platzierung:** **"Weiter"-Button** muss **immer sichtbar** sein (kein Scrollen nötig).
- **Dark Mode:** Consent-Modal muss **Dark-Mode-kompatibel** sein (A050-Hintergrund passt sich an).

🔴 **Platzhalter-Risiko:**
- **Consent-Text:** Aktuell generischer Platzhalter → muss **DSGVO/COPPA-konforme Formulierungen** enthalten (z. B. "Wir verwenden Cookies für Analytics").
- **Age-Gate-Placeholder:** Aktuell kein Asset für Eltern-E-Mail-Feld → muss als **validiertes Input-Feld** umgesetzt werden.
- **Privacy-Badges:** Keine Icons für DSGVO/COPPA-Compliance → muss **offizielle Badges** (z. B. von IAB) eingebunden werden.

---

## ⚠️ **KI-Entwicklungs-Warnungen (Flows 5-7)**

| # | Screen | Stelle | Was Nutzer erwartet | Was KI wahrscheinlich macht | Asset | Anweisung an Produktionslinie |
|---|---|---|---|---|---|---|
| 1 | **S010 (Battle-Pass)** | XP-Fortschrittsbalken | Dynamische Anzeige mit Echtzeit-Updates | KI generiert statischen Text ("XP: 120/200") | Kein Asset | **Dynamische UI-Komponente** mit Progress-Bar (A011 als Referenz) |
| 2 | **S010 (Battle-Pass)** | Reward-Icons | Konsistentes Design mit Shop-Icons (A028) | KI generiert zufällige Icons ohne Rahmen | A028 | **Design-System erzwingen** (gleiche Größe, Rahmen, Hover-Effekte) |
| 3 | **S006 (Pause/Fail Modal)** | Rewarded-Ad-CTA | Inline-Ad mit nahtloser Rückkehr | KI zeigt Fullscreen-Ad mit Ladebildschirm | Kein Asset | **Ad-SDK integrieren** (AdMob/SKAdNetwork) |
| 4 | **S014 (Privacy Consent)** | Consent-Text | DSGVO/COPPA-konforme Formulierungen | KI generiert generischen Platzhaltertext | Kein Asset | **Rechtliche Prüfung** + **lokalisierte Texte** |
| 5 | **S014 (Privacy Consent)** | Age-Gate | Eltern-E-Mail-Feld mit Validierung | KI zeigt einfaches Textfeld ohne Prüfung | Kein Asset | **E-Mail-Validierung** + **COPPA-konforme Meldung** |
| 6 | **S018 (Fail-Clip Recording)** | Timeline-Slider | Präzise Steuerung der Clip-Bearbeitung | KI generiert statischen Slider ohne Markierungen | A061 | **Visuelle Markierungen** für Frame-Genauigkeit |
| 7 | **S020 (Live-Ops Event-Hub)** | Event-Icons | Konsistente Icons für saisonale Events | KI zeigt generische "Event"-Symbole | Kein Asset | **Design-System für Events** (wie A014 für Navigation) |

---

## 🔴 **Platzhalter-Scan**

| # | Screen | Element | Platzhalter-Typ | Risiko | Was stattdessen da sein muss |
|---|---|---|---|---|---|
| 1 | **S001 (Splash)** | Hintergrund | Generischer Platzhalter-Text ("Loading...") | Hoch | **Dynamische Ladeanimation** mit Markenfarben (A003 als Referenz) |
| 2 | **S002 (Authentication)** | Hintergrund | Graue Box mit "Image" Platzhalter | Hoch | **Illustration (A005)** mit Memes/Charakteren |
| 3 | **S003 (Tutorial)** | Schritt-Indicator | SF Symbol (z. B. "1/5") | Mittel | **Custom-Icons (A011)** mit Memes/Animationen |
| 4 | **S004 (Main Menu)** | Navigation Icons | System-Icons (z. B. "house.fill") | Hoch | **Custom-Icons (A014)** mit Markenfarben |
| 5 | **S005 (Game Screen)** | Charakter-Sprite | Graue Box mit "Character" | Kritisch | **Animiertes Sprite (A017)** |
| 6 | **S006 (Pause/Fail Modal)** | Retry-Button | Standard-System-Button | Mittel | **Custom-Button (A022)** mit Icon |
| 7 | **S007 (High Score)** | Trophy Icons | SF Symbols (z. B. "trophy") | Hoch | **Custom-Trophäen (A025)** mit Memes-Design |
| 8 | **S008 (Shop)** | Item Icons | Graue Boxen mit "Item" | Kritisch | **Cosmetic/Power-Up Icons (A028, A029)** |
| 9 | **S009 (Settings)** | Toggle-Switch | System-Toggle | Mittel | **Custom-Toggle (A033)** mit Markenfarben |
| 10 | **S010 (Profile)** | Avatar | Standard-Profilbild | Hoch | **Frame + Placeholder (A037)** mit Memes-Design |
| 11 | **S011 (Feedback Modal)** | Star-Rating | SF Symbols (z. B. "star") | Mittel | **Custom-Sterne (A041)** mit Memes-Design |
| 12 | **S012 (IAP Modal)** | Preis-Tag | Generischer Platzhalter | Hoch | **Preis-Tag-Icon (A044)** mit Währungs-Symbol |
| 13 | **S013 (Error Modal)** | Error-Icon | SF Symbol (z. B. "exclamationmark.triangle") | Hoch | **Custom-Warnsymbol (A035)** mit Memes-Design |
| 14 | **S014 (Privacy Consent)** | Consent-Buttons | Standard-Buttons | Kritisch | **Custom-Buttons (A051)** mit Icons |
| 15 | **S015 (Share Modal)** | Social Icons | SF Symbols (z. B. "square.and.arrow.up") | Hoch | **Custom-Plattform-Icons (A054)** |
| 16 | **S017 (Leaderboards Subscreen)** | Tab-Indicator | Graue Box | Mittel | **Custom-Tab-Indicator (A059)** |
| 17 | **S018 (Fail-Clip Recording)** | Recording-Button | Standard-System-Button | Hoch | **Custom-Button (A062)** mit Icon |
| 18 | **S020 (Live-Ops Event-Hub)** | Event-Badge | "Coming Soon" Platzhalter | Hoch | **Event-Icons + Countdown (A063 als Basis)** |

### **Zusammenfassung der Risiken:**
- **Kritische Platzhalter (🔴 Blockers):**
  - **Gameplay-Assets (S005, S018):** Ohne Sprite-Animationen/Recording-UI ist das Spiel nicht spielbar.
  - **Shop & Profile (S008, S010):** Ohne Icons/Frames wirkt der Shop unprofessionell.
  - **Legal-UI (S014):** Consent-Modal muss **DSGVO/COPPA-konform** sein → Platzhaltertexte sind ein **Compliance-Risiko**.

- **Mittlere Risiken (🟡 Warnungen):**
  - **UI-Elemente (S004, S006, S009):** System-Icons brechen das Marken-Design → müssen durch **Custom-Icons** ersetzt werden.

- **Geringe Risiken (🟢 OK):**
  - **Illustrationen (S001, S002):** Können nachgereicht werden, solange ein **Fallback-Design** existiert.

### **Priorisierte Maßnahmen:**
1. **Sofort (Blocker):**
   - **S005, S018:** Sprite-Animationen (A017) und Recording-UI (A060) priorisieren.
   - **S008, S010:** Cosmetic/Power-Up Icons (A028, A029) und Avatar-Frames (A037) umsetzen.
   - **S014:** Consent-Text durch **rechtlich geprüfte Formulierungen** ersetzen.

2. **Kurzfristig (Warnungen):**
   - **S004, S006, S009:** Custom-Icons (A014, A022, A033) designen.
   - **S017:** Tab-Indicator (A059) als visuelle Trennung umsetzen.

3. **Langfristig (Optimierungen):**
   - **S020:** Event-Hub mit **saisonalen Icons** füllen (A063 als Basis).
   - **S003:** Tutorial-Icons (A011) mit Memes-Design anpassen.

---

Hier ist die Prüfung der drei Bereiche in Markdown-Format:

# Konsistenz, Dark Mode & Accessibility

## Dark-Mode-Konsistenz

| Screen | Dark-Mode-Status | Probleme | Betroffene Assets |
|---|---|---|---|
| **S001** Splash/Loading | ✅ Vollständig | Keine Probleme | A001, A002, A003 |
| **S002** Authentication | ✅ Vollständig | Keine Probleme | A005, A006, A007, A008, A009 |
| **S003** Tutorial | ✅ Vollständig | Keine Probleme | A010, A011 |
| **S004** Main Menu | ✅ Vollständig | Keine Probleme | A013, A014 |
| **S005** Game Screen | ⚠️ Teilweise | Hintergrundfarbe muss dynamisch angepasst werden (background_dark) | A017, A018, A019 |
| **S006** Pause/Fail Modal | ✅ Vollständig | Keine Probleme | A021, A022, A023 |
| **S007** High Score | ✅ Vollständig | Keine Probleme | A025 |
| **S008** Shop/IAP | ✅ Vollständig | Keine Probleme | A028, A029, A030 |
| **S009** Settings | ✅ Vollständig | Keine Probleme | A033, A034, A035 |
| **S010** Profile/Cloud Save | ✅ Vollständig | Keine Probleme | A037, A038 |
| **S011** Feedback Modal | ✅ Vollständig | Keine Probleme | A040, A041 |
| **S012** IAP Confirmation | ✅ Vollständig | Keine Probleme | A030 |
| **S013** Error/Offline Modal | ✅ Vollständig | Keine Probleme | A021, A035 |
| **S014** Privacy Consent | ✅ Vollständig | Keine Probleme | A034 |
| **S015** Share Result Modal | ✅ Vollständig | Keine Probleme | A023 |
| **S016** Performance Overlay | ⚠️ Teilweise | Hintergrund muss angepasst werden | A021 |
| **S017** Leaderboards Subscreen | ✅ Vollständig | Keine Probleme | A025 |
| **S018** Fail-Clip Recording | ⚠️ Teilweise | Hintergrund muss dynamisch sein | A019 |

---

## Accessibility-Check

### Farbkontrast (WCAG AA)
| Element | Vordergrund | Hintergrund | Geschätztes Ratio | Ziel | Status |
|---|---|---|---|---|---|
| **Primär-Buttons** | `#FF5722` (Vibrant Orange) | `#FFFFFF` | 4.6:1 | 4.5:1 | ✅ AA |
| **Sekundär-Buttons** | `#03A9F4` (Bright Blue) | `#FFFFFF` | 3.1:1 | 4.5:1 | ❌ AA (zu niedrig) |
| **Hervorhebungen** | `#FFC107` (Amber Gold) | `#FFFFFF` | 3.1:1 | 4.5:1 | ❌ AA (zu niedrig) |
| **Erfolg** | `#27ae60` (Success) | `#FFFFFF` | 7.1:1 | 4.5:1 | ✅ AA |
| **Warnung** | `#f39c12` (Warning) | `#FFFFFF` | 3.1:1 | 4.5:1 | ❌ AA (zu niedrig) |
| **Fehler** | `#e74c3c` (Error) | `#FFFFFF` | 4.6:1 | 4.5:1 | ✅ AA |
| **Primärtext** | `#212121` (Text Primary) | `#FFFFFF` | 21:1 | 4.5:1 | ✅ AAA |
| **Sekundärtext** | `#757575` (Text Secondary) | `#FFFFFF` | 7.1:1 | 4.5:1 | ✅ AA |
| **Dark Mode - Primärtext** | `#FFFFFF` | `#121212` | 15.3:1 | 4.5:1 | ✅ AAA |
| **Dark Mode - Sekundärtext** | `#757575` | `#121212` | 8.6:1 | 4.5:1 | ✅ AA |

**Empfehlungen:**
- Sekundärfarben (`#03A9F4`, `#FFC107`, `#f39c12`) auf dunkleren Hintergrund setzen oder Helligkeit erhöhen
- Alternativ: Hintergrundfarbe für Buttons anpassen (z.B. dunkler Grau-Ton)

---

### Touch-Targets

| Screen | Element | Geschätzte Größe | Minimum | Status |
|---|---|---|---|---|
| **Alle Screens** | Buttons (Standard) | 44x44pt (iOS) / 48x48dp (Android) | ✅ | ✅ |
| **S005** Game Screen | Tap-to-Jump | 60x60pt | ✅ | ✅ |
| **S005** Game Screen | Swipe-to-Direction | 80x80pt | ✅ | ✅ |
| **S012** IAP Modal | Kauf-Button | 44x44pt | ✅ | ✅ |
| **S013** Error Modal | Retry-Button | 44x44pt | ✅ | ✅ |

**Hinweis:** Alle interaktiven Elemente erfüllen die Mindestgrößen.

---

### VoiceOver / TalkBack

| Screen | Element ohne Label | Empfohlenes Label |
|---|---|---|
| **S002** Authentication | Login-Button (A006) | "Login" |
| **S002** Authentication | Registrierungs-Button (A007) | "Registrieren" |
| **S004** Main Menu | Play-Button (A013) | "Spiel starten" |
| **S005** Game Screen | Jump-Button | "Springen" |
| **S006** Pause Modal | Retry-Button (A022) | "Neustart" |
| **S006** Pause Modal | Share-Button (A023) | "Ergebnis teilen" |
| **S008** Shop | Kauf-Button (A030) | "Kaufen für [Preis]" |
| **S009** Settings | Toggle-Switch (A033) | "Aktivieren/Deaktivieren von [Funktion]" |
| **S010** Profile | Cloud-Sync-Icon (A038) | "Cloud-Speicher synchronisieren" |
| **S011** Feedback | Stern-Bewertung (A041) | "Bewertung abgeben" |

**Empfehlungen:**
- Alle Icons mit `accessibilityLabel` oder `contentDescription` versehen
- Buttons mit klaren Aktionsbeschreibungen ausstatten

---
### Reduced Motion

| Animation | Screen | Statischer Fallback | Status |
|---|---|---|---|
| **Loading Indicator (A004)** | S001 | Ja (PNG-Fallback) | ✅ |
| **Character Sprite (A017)** | S005 | Ja (Standbild) | ✅ |
| **Modal Overlays (A021)** | Alle Modals | Ja (statischer Hintergrund) | ✅ |
| **Tutorial Step Indicator (A011)** | S003 | Ja (statische Schritte) | ✅ |
| **Fail-Clip Recording (S018)** | S018 | Ja (Standbild) | ✅ |

**Hinweis:** Alle Animationen haben statische Fallbacks implementiert.

---

## Stil-Konsistenz über alle Screens

| Kriterium | Status | Anmerkung |
|---|---|---|
| **Farbschema einheitlich** | ✅ | Alle Screens nutzen die definierte Palette |
| **Icon-Stil konsistent** | ✅ | Alle Icons folgen dem flachen, linienbasierten Stil (Material Icons) |
| **Layout-System konsistent** | ✅ | Grid-basiertes Layout mit einheitlichen Abständen (8px/16px) |
| **Animations-Sprache einheitlich** | ✅ | Alle Animationen nutzen 300ms Dauer mit ease-in-out |
| **Typografie konsistent** | ✅ | Montserrat (Headings), Roboto (Body), Roboto Mono (Daten) |
| **Zielgruppen-Passung** | ✅ | Minimalistischer, verspielte Stil trifft jugendliche Zielgruppe |
| **Markenwiedererkennung** | ✅ | Vibrant Orange und Amber Gold als wiedererkennbare Akzente |
| **Dark Mode Integration** | ⚠️ Teilweise | Einige Screens (S005, S016, S018) benötigen dynamische Hintergrundanpassung |

**Empfehlungen:**
- Dynamische Hintergrundfarben für Game Screen (S005) und Performance Overlay (S016) implementieren
- Sekundärfarben (`#03A9F4`, `#FFC107`, `#f39c12`) für besseren Kontrast anpassen