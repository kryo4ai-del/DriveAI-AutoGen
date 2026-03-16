# 031 Simulator Launch + Runtime Smoke Test

**Status**: pending
**Ziel**: App im Simulator starten, erster Runtime Smoke Test

## Auftrag

### Schritt 1: App im Simulator starten

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1

# Build + Launch in einem Schritt
xcodebuild -project AskFinPremium.xcodeproj \
  -scheme AskFinPremium \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | tail -5

# Simulator booten falls noetig
xcrun simctl boot "iPhone 16" 2>/dev/null || true

# App installieren + starten
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "AskFinPremium.app" -path "*/Build/Products/Debug-iphonesimulator/*" | head -1)
echo "App path: $APP_PATH"

xcrun simctl install booted "$APP_PATH"
xcrun simctl launch --console booted com.askfin.premium 2>&1 | head -50
```

### Schritt 2: Crash-Logs pruefen

Falls Crash:
```bash
# Console output vom Launch oben sollte den Crash zeigen
# Zusaetzlich:
xcrun simctl get_app_container booted com.askfin.premium 2>/dev/null
log show --predicate 'process == "AskFinPremium"' --last 1m --style compact 2>&1 | tail -30
```

### Schritt 3: Screenshot falls moeglich

```bash
xcrun simctl io booted screenshot ~/DriveAI-AutoGen/_commands/031_screenshot.png 2>/dev/null
```

## Was beobachten

- App startet? Ja/Nein
- Crash? → Welche Exception/Signal?
- Weisser/Schwarzer Screen? → SwiftUI View rendering Problem
- UI sichtbar? → Welche View wird gezeigt?
- Fehler in Console? → Runtime Errors, Missing Resources, etc.

## Report

Ergebnis in `_commands/031_simulator_result.md`:
- Launch-Ergebnis (clean / crash / hang / white screen)
- Console-Output (erste 20-30 Zeilen)
- Crash-Details falls vorhanden
- Screenshot falls moeglich (als Referenz)
- Interpretation: Runtime / Config / UI / Bootstrap

## Git

```bash
git add -A
git commit -m "test: first simulator launch + runtime smoke test (Report 72-0)

- Launch: [Ergebnis]
- Runtime: [clean/crash/issue]"
git push
```
