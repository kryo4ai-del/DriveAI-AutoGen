# 038 Post-Session State Persistence + Cross-Tab Reflection Test

**Status**: pending
**Ziel**: Pruefen ob abgeschlossene Training-Session State persistiert und in allen Tabs reflektiert wird

## Auftrag

### Schritt 1: Code-Analyse — State Persistence

Bevor Runtime getestet wird, pruefe den Code:

```bash
# Wo wird Session-Ergebnis gespeichert?
grep -r "saveSession\|persistSession\|recordSession\|sessionCompleted\|onComplete\|finishSession\|endSession" \
  projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | head -20

# Welcher Persistence-Layer existiert?
grep -r "UserDefaults\|CoreData\|FileManager\|@AppStorage\|SwiftData\|Keychain" \
  projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | head -20

# Wie wird Verlauf/History befuellt?
grep -r "history\|ExamHistory\|sessionHistory\|pastSessions" \
  projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | head -20

# Wie wird Lernstand/Progress befuellt?
grep -r "progress\|competence\|readiness.*update\|score.*update" \
  projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | grep -i "update\|save\|persist\|write" | head -20
```

### Schritt 2: XCUITest — Post-Session State

Erstelle `UITests/PostSessionStateTests.swift`:

```swift
import XCTest

final class PostSessionStateTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testPostSessionStateReflection() {
        // 1. Komplette Training-Session
        let dailyBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        guard dailyBtn.waitForExistence(timeout: 5) else { XCTFail("No daily btn"); return }
        dailyBtn.tap()
        sleep(2)

        // Beantworte alle verfuegbaren Fragen
        for _ in 0..<10 {
            let answers = app.buttons.allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.minY > 200 }
            guard let answer = answers.first else { break }
            answer.tap()
            sleep(1)
            // Naechste Frage falls vorhanden
            let next = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Weiter' OR label CONTAINS 'ächste'")).firstMatch
            if next.waitForExistence(timeout: 1) { next.tap(); sleep(1) }
        }

        // Beenden
        let beenden = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden' OR label CONTAINS 'Fertig'")).firstMatch
        if beenden.waitForExistence(timeout: 3) { beenden.tap(); sleep(1) }

        screenshot("01_home_after_session")

        // 2. Home-State pruefen
        //    Hat sich die Pruefungsbereitschaft geaendert?
        let homeTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== HOME STATE ===")
        homeTexts.prefix(15).forEach { print("  \($0)") }

        // 3. Verlauf-Tab pruefen
        let verlaufTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Verlauf'")).firstMatch
        if verlaufTab.waitForExistence(timeout: 3) {
            verlaufTab.tap()
            sleep(2)
            screenshot("02_verlauf_after_session")
            let verlaufTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
            print("=== VERLAUF STATE ===")
            verlaufTexts.prefix(15).forEach { print("  \($0)") }
        }

        // 4. Lernstand-Tab pruefen
        let lernstandTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Lernstand'")).firstMatch
        if lernstandTab.waitForExistence(timeout: 3) {
            lernstandTab.tap()
            sleep(2)
            screenshot("03_lernstand_after_session")
            let lernstandTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
            print("=== LERNSTAND STATE ===")
            lernstandTexts.prefix(15).forEach { print("  \($0)") }
        }

        // Zurueck zu Home
        let homeTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Home'")).firstMatch
        if homeTab.waitForExistence(timeout: 3) { homeTab.tap() }
    }

    private func screenshot(_ name: String) {
        let s = XCUIScreen.main.screenshot()
        let a = XCTAttachment(screenshot: s)
        a.name = name; a.lifetime = .keepAlways; add(a)
    }
}
```

### Ausfuehren

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1
xcodegen generate

xcodebuild test \
  -project AskFinPremium.xcodeproj \
  -scheme AskFinUITests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:AskFinUITests/PostSessionStateTests \
  -resultBundlePath /tmp/askfin_state_results \
  2>&1 | tail -40
```

## Report

Ergebnis in `_commands/038_state_result.md`:

```
## Code-Analyse: State Persistence
- Persistence-Layer: [UserDefaults / CoreData / None / Stub]
- Session-Save: [implementiert / stub / nicht vorhanden]

## Runtime: Post-Session State

### Home nach Session
- Pruefungsbereitschaft: [0% / geaendert / gleich]
- Sichtbare Aenderung: [ja/nein]

### Verlauf nach Session
- Session sichtbar: [ja / nein / empty state]
- Details: [was angezeigt]

### Lernstand nach Session
- Progress sichtbar: [ja / nein / unveraendert]
- Details: [was angezeigt]

## Interpretation
- State Persistence: [funktioniert / stub / nicht implementiert]
- Cross-Tab Reflection: [konsistent / inkonsistent / nicht verbunden]
- Naechster Schritt: [was fehlt]
```

## Git

```bash
git add -A
git commit -m "test: post-session state persistence + cross-tab test (Report 79-0)

- Session-State-Persistence geprueft
- Cross-Tab-Reflection getestet"
git push
```
