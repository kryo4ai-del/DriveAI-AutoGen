# 032 Navigation + Interaction Smoke Test

**Status**: pending
**Ziel**: Alle 4 Tabs + 3 Home-Cards durchtappen, Runtime-Verhalten dokumentieren

## Auftrag

### Schritt 1: App starten (falls nicht mehr laufend)

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1
xcrun simctl launch booted com.askfin.premium 2>/dev/null || \
  (xcodebuild -project AskFinPremium.xcodeproj -scheme AskFinPremium \
    -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -3 && \
   xcrun simctl install booted $(find ~/Library/Developer/Xcode/DerivedData -name "AskFinPremium.app" -path "*/Debug-iphonesimulator/*" | head -1) && \
   xcrun simctl launch booted com.askfin.premium)
```

### Schritt 2: UI Automation via simctl

Leider kann simctl keine Taps simulieren. Stattdessen:

**Option A**: Falls `xcrun simctl ui` oder Accessibility verfuegbar:
```bash
# Screenshot pro Tab/Aktion
xcrun simctl io booted screenshot ~/DriveAI-AutoGen/_commands/032_home.png
```

**Option B**: AppleScript + Simulator.app:
```bash
osascript -e '
tell application "Simulator" to activate
delay 1
'
```

**Option C (bevorzugt)**: XCUITest direkt ausfuehren:

Erstelle eine einfache Test-Datei und fuehre sie aus. Oder nutze `xcrun simctl` mit Koordinaten-Taps falls verfuegbar.

**Option D (pragmatisch)**: Manuell per Simulator-Fenster navigieren ist nicht moeglich via CLI. Stattdessen:

1. Pruefe ob die Tab-Destinations als SwiftUI Views existieren und was sie rendern wuerden
2. Pruefe ob die 3 Cards NavigationLinks haben und wohin sie fuehren
3. Lese den Code der Tab-Views und Home-Cards um zu bestimmen was passieren wuerde

### Schritt 3: Code-basierte Navigation-Analyse

```bash
# Welche Tabs existieren?
grep -r "TabView\|\.tabItem\|Tab(" projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | head -20

# Welche Navigation von Home?
grep -r "NavigationLink\|NavigationDestination\|sheet\|fullScreenCover" projects/askfin_v1-1/Views/ --include="*.swift" | head -20

# Was passiert bei Tap auf die 3 Cards?
grep -r "Tägliches Training\|Thema üben\|Schwächen trainieren\|dailyTraining\|topicPractice\|weaknessPractice" projects/askfin_v1-1/ --include="*.swift" | head -20
```

### Schritt 4: Screenshots pro Tab (falls App noch laeuft)

```bash
# Versuche Tabs per Accessibility/Koordinaten zu tappen
# Tab Bar ist unten, Tabs von links nach rechts: Home, Lernstand, Generalprobe, Verlauf
# iPhone 16 Screen: 393x852 points

# Lernstand Tab (ca. x=148, y=830)
xcrun simctl io booted screenshot ~/DriveAI-AutoGen/_commands/032_tab_home.png

# Falls simctl keinen Tap-Support hat: Nur Code-Analyse
```

## Report

Ergebnis in `_commands/032_navigation_result.md`:

```
## Tab: Home
- Status: [rendert / leer / crash]
- Screenshot: [falls vorhanden]

## Tab: Lernstand
- Status: [rendert / leer / crash]

## Tab: Generalprobe
- Status: [rendert / leer / crash]

## Tab: Verlauf
- Status: [rendert / leer / crash]

## Card: Tägliches Training
- Navigation: [wired / not wired / crash]
- Destination: [View-Name]

## Card: Thema üben
- Navigation: [wired / not wired / crash]

## Card: Schwächen trainieren
- Navigation: [wired / not wired / crash]

## Interpretation
- [was funktioniert / was fehlt / naechster Schritt]
```

## Git

```bash
git add -A
git commit -m "test: navigation + interaction smoke test (Report 73-0)

- 4 Tabs + 3 Cards getestet
- [Zusammenfassung]"
git push
```
