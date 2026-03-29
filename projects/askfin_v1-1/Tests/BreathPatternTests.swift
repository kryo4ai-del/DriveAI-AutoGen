@MainActor
final class BreathPatternTests: XCTestCase {

    // MARK: - cycleDuration

    func test_cycleDuration_sumOfAllPhases() {
        let pattern = BreathPattern(name: "Test", inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 4, totalCycles: 3)
        XCTAssertEqual(pattern.cycleDuration, 12.0, accuracy: 0.001)
    }

    func test_cycleDuration_withZeroHold() {
        let pattern = BreathPattern(name: "No Hold", inhaleSeconds: 4, holdSeconds: 0, exhaleSeconds: 6, totalCycles: 1)
        XCTAssertEqual(pattern.cycleDuration, 10.0, accuracy: 0.001)
    }

    func test_cycleDuration_withAllZeroPhases() {
        // Edge: degenerate pattern — should not crash, returns 0
        let pattern = BreathPattern(name: "Empty", inhaleSeconds: 0, holdSeconds: 0, exhaleSeconds: 0, totalCycles: 1)
        XCTAssertEqual(pattern.cycleDuration, 0.0)
    }

    // MARK: - Presets

    func test_boxBreathing_preset_values() {
        let p = BreathPattern.boxBreathing
        XCTAssertEqual(p.inhaleSeconds, 4)
        XCTAssertEqual(p.holdSeconds, 4)
        XCTAssertEqual(p.exhaleSeconds, 4)
        XCTAssertEqual(p.totalCycles, 3)
        XCTAssertEqual(p.cycleDuration, 12.0, accuracy: 0.001)
    }

    func test_relaxed_preset_values() {
        let p = BreathPattern.relaxed
        XCTAssertEqual(p.inhaleSeconds, 4)
        XCTAssertEqual(p.holdSeconds, 2)
        XCTAssertEqual(p.exhaleSeconds, 6)
        XCTAssertEqual(p.cycleDuration, 12.0, accuracy: 0.001)
    }

    func test_quick_preset_holdSecondsIsNonZero() {
        // Invariant documented in model: holdSeconds must be > 0
        // to avoid zero-duration phase bug
        XCTAssertGreaterThan(BreathPattern.quick.holdSeconds, 0)
    }

    func test_quick_preset_values() {
        let p = BreathPattern.quick
        XCTAssertEqual(p.inhaleSeconds, 3)
        XCTAssertEqual(p.holdSeconds, 1)
        XCTAssertEqual(p.exhaleSeconds, 3)
        XCTAssertEqual(p.totalCycles, 2)
    }

    // MARK: - Equatable

    func test_equality_sameValues() {
        let a = BreathPattern(name: "X", inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 4, totalCycles: 3)
        let b = BreathPattern(name: "X", inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 4, totalCycles: 3)
        XCTAssertEqual(a, b)
    }

    func test_equality_differentCycleCount() {
        let a = BreathPattern(name: "X", inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 4, totalCycles: 3)
        let b = BreathPattern(name: "X", inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 4, totalCycles: 5)
        XCTAssertNotEqual(a, b)
    }
}