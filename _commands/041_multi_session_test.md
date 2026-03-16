# 041 Multi-Session State Coherence Test

**Status**: pending
**Ziel**: 2+ Sessions durchfuehren, State-Kohaerenz ueber alle Tabs pruefen

## Auftrag

### XCUITest: Multi-Session

Erstelle `UITests/MultiSessionTests.swift`:

```swift
import XCTest

final class MultiSessionTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testTwoSessionsStateCoherence() {
        // === Session 1: Taegliches Training ===
        completeTrainingSession("ägliches Training")
        sleep(1)
        screenshot("01_home_after_session1")

        // === Session 2: Schwaechen trainieren ===
        completeTrainingSession("Schwächen")
        sleep(1)
        screenshot("02_home_after_session2")

        // === Verlauf pruefen ===
        tapTab("Verlauf")
        sleep(2)
        screenshot("03_verlauf_after_2_sessions")
        let verlaufTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== VERLAUF ===")
        verlaufTexts.prefix(20).forEach { print("  \($0)") }

        // === Lernstand pruefen ===
        tapTab("Lernstand")
        sleep(2)
        screenshot("04_lernstand_after_2_sessions")
        let lernstandTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== LERNSTAND ===")
        lernstandTexts.prefix(20).forEach { print("  \($0)") }

        // === Home pruefen ===
        tapTab("Home")
        sleep(1)
        screenshot("05_home_final")
        let homeTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== HOME ===")
        homeTexts.prefix(15).forEach { print("  \($0)") }
    }

    // MARK: - Helpers

    private func completeTrainingSession(_ buttonLabel: String) {
        let btn = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", buttonLabel)).firstMatch
        guard btn.waitForExistence(timeout: 5) else { return }
        btn.tap()
        sleep(2)

        // Beantworte alle Fragen
        for _ in 0..<10 {
            let answers = app.buttons.allElementsBoundByIndex.filter {
                $0.exists && $0.isHittable && $0.frame.minY > 200
            }
            guard let answer = answers.first else { break }
            answer.tap()
            sleep(1)
            let next = app.buttons.matching(NSPredicate(
                format: "label CONTAINS 'Weiter' OR label CONTAINS 'ächste'"
            )).firstMatch
            if next.waitForExistence(timeout: 1) { next.tap(); sleep(1) }
        }

        // Beenden
        let beenden = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'Beenden' OR label CONTAINS 'Fertig'"
        )).firstMatch
        if beenden.waitForExistence(timeout: 3) { beenden.tap(); sleep(1) }
    }

    private func tapTab(_ label: String) {
        let tab = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", label)).firstMatch
        if tab.waitForExistence(timeout: 3) { tab.tap() }
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
  -only-testing:AskFinUITests/MultiSessionTests/testTwoSessionsStateCoherence \
  -resultBundlePath /tmp/askfin_multi_results \
  2>&1 | tail -40
```

## Report

Ergebnis in `_commands/041_multi_session_result.md`:

```
## Sessions durchgefuehrt
- Session 1: [Typ, Fragen beantwortet]
- Session 2: [Typ, Fragen beantwortet]

## Verlauf nach 2 Sessions
- Eintraege sichtbar: [Anzahl]
- Korrekt: [ja/nein — 2 separate Eintraege?]
- Duplikate: [ja/nein]

## Lernstand nach 2 Sessions
- State: [unveraendert / aktualisiert]

## Home nach 2 Sessions
- Readiness: [Wert]
- Konsistent: [ja/nein]

## Screenshots
- [Liste]

## Interpretation
- State-Kohaerenz: [konsistent / inkonsistent]
- History-Akkumulation: [korrekt / ueberschrieben / dupliziert]
```

## Git

```bash
git add -A
git commit -m "test: multi-session state coherence test (Report 82-0)

- 2 Sessions + Cross-Tab State Verification"
git push
```
