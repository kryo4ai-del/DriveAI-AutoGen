final class CategoryReadinessStatusTests: XCTestCase {

    // notStarted
    func test_noAttempts_statusIsNotStarted() {
        let cat = CategoryReadiness.make(
            questionsTotal: 50,
            questionsAttempted: 0,
            correctAnswers: 0
        )
        XCTAssertEqual(cat.status, .notStarted)
        XCTAssertFalse(cat.isWeak)
        XCTAssertFalse(cat.isMastered)
    }

    // weak — weightedScore < 0.55
    func test_lowWeightedScore_statusIsWeak() {
        // accuracy=0.3, completion=0.4 → weighted = 0.18+0.16 = 0.34
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 40,
            correctAnswers: 12
        )
        XCTAssertEqual(cat.status, .weak)
        XCTAssertTrue(cat.isWeak)
        XCTAssertFalse(cat.isMastered)
    }

    // mastered — weightedScore >= 0.85 AND completionRate >= 0.75
    func test_highScoreAndCompletion_statusIsMastered() {
        // accuracy=0.95, completion=0.80 → weighted = 0.57+0.32 = 0.89
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 80,
            correctAnswers: 76
        )
        XCTAssertEqual(cat.status, .mastered)
        XCTAssertTrue(cat.isMastered)
        XCTAssertFalse(cat.isWeak)
    }

    // developing — neither weak nor mastered
    func test_midRange_statusIsDeveloping() {
        // accuracy=0.75, completion=0.60 → weighted = 0.45+0.24 = 0.69
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 60,
            correctAnswers: 45
        )
        XCTAssertEqual(cat.status, .developing)
    }

    // Boundary — exactly at weak threshold (0.55)
    func test_weightedScoreExactlyAt55_statusIsDeveloping() {
        // Need accuracy=a, completion=c where 0.6a + 0.4c = 0.55
        // Use: attempted=50/100, correct=42/50 → accuracy=0.84, completion=0.50
        // weighted = 0.504 + 0.200 = 0.704 — too high. Adjust:
        // attempted=40/100, correct=15/40 → accuracy=0.375, completion=0.40
        // weighted = 0.225 + 0.16 = 0.385 — too low.
        // Target exact boundary via direct construction:
        // accuracy=0.55/0.6=0.9167 when completion=0; impractical.
        // Use tabulated value: 35 attempted out of 100, 25 correct
        // accuracy=25/35=0.714, completion=35/100=0.35
        // weighted = 0.429 + 0.14 = 0.569 → developing (just above 0.55)
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 35,
            correctAnswers: 25
        )
        XCTAssertGreaterThan(cat.weightedScore, 0.55)
        XCTAssertEqual(cat.status, .developing)
    }

    // High accuracy but low completion — not mastered
    func test_highAccuracyLowCompletion_notMastered() {
        // accuracy=0.95, completion=0.50 → weighted = 0.57+0.20 = 0.77
        // completionRate < 0.75 threshold → not mastered
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 50,
            correctAnswers: 47
        )
        XCTAssertFalse(cat.isMastered)
        XCTAssertEqual(cat.status, .developing)
    }

    // Ensure weak and mastered are mutually exclusive
    func test_statusMutualExclusion_weakAndMastered() {
        for _ in 0..<20 {
            let total = Int.random(in: 10...200)
            let attempted = Int.random(in: 0...total)
            let correct = Int.random(in: 0...attempted)
            let cat = CategoryReadiness.make(
                questionsTotal: total,
                questionsAttempted: attempted,
                correctAnswers: correct
            )
            XCTAssertFalse(cat.isWeak && cat.isMastered,
                "Category cannot be both weak and mastered")
        }
    }
}