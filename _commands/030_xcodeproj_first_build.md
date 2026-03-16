# 030 Xcode Project + First Real Build

**Status**: pending
**Ziel**: .xcodeproj erstellen, 195 clean files einbinden, erster echter Xcode Build

## Auftrag

### Schritt 1: Projekt-Struktur entscheiden

Pruefe ob besser:
- **Swift Package (Package.swift)** — minimal, CLI-freundlich
- **.xcodeproj via `swift package generate-xcodeproj`** — veraltet
- **.xcodeproj manuell / via xcodegen** — Standard fuer iOS Apps
- **Xcode direkt** — `xcodebuild` mit einem manuell erstellten Projekt

Empfehlung: **xcodegen** falls installiert, sonst manuelles .xcodeproj

```bash
which xcodegen 2>/dev/null && echo "xcodegen available" || echo "not installed"
```

Falls xcodegen nicht installiert: `brew install xcodegen`

### Schritt 2: Projekt erstellen

Erstelle `projects/askfin_v1-1/project.yml` (fuer xcodegen) oder aequivalent:

```yaml
name: AskFinPremium
targets:
  AskFinPremium:
    type: application
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - path: Models
      - path: Views
      - path: ViewModels
      - path: Services
      - path: App
    settings:
      SWIFT_VERSION: "6.0"
      PRODUCT_BUNDLE_IDENTIFIER: com.askfin.premium
```

**WICHTIG**: `quarantine/` NICHT einbinden!

### Schritt 3: Generieren + Build

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1

# Falls xcodegen:
xcodegen generate
xcodebuild -project AskFinPremium.xcodeproj -scheme AskFinPremium -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -40

# Falls Package.swift:
# Beachte: SwiftUI-Apps brauchen .xcodeproj, Package.swift allein reicht nicht fuer iOS
```

### Schritt 4: Ergebnis analysieren

- Unterscheide: Source-Errors vs Build-System/Config-Errors
- Source-Errors: Gleiche Fix-Patterns wie bisher
- Config-Errors: Info.plist, Bundle, Signing, etc.

## Hinweise

- iOS App braucht mindestens: App Entry Point (@main), Info.plist, Bundle ID
- Pruefe ob ein `@main` App struct existiert (oder ob DriveAIApp.swift in quarantine liegt)
- Falls App Entry Point fehlt: Minimalen erstellen
- Signing: Fuer Simulator-Build kein Signing noetig (`CODE_SIGN_IDENTITY=""`)

## Report

Ergebnis in `_commands/030_xcodeproj_result.md`:
- Gewaehlter Projekt-Typ (xcodegen / manuell / Package.swift)
- Files eingebunden vs ausgeschlossen
- Build-Command
- Build-Ergebnis (clean / warnings / errors)
- Erste Blocker falls vorhanden
- Config vs Source Interpretation

## Git

```bash
git add -A
git commit -m "feat: first .xcodeproj + Xcode build attempt (Report 71-0)

- [Projekt-Typ] erstellt
- 195 clean files eingebunden
- Build: [Ergebnis]"
git push
```
