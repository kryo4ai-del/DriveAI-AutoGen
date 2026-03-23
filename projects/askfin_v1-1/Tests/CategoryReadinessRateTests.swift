final class CategoryReadinessRateTests: XCTestCase {

    func test_accuracyRate_computedCorrectly() {
        // 48/60 = 0.8
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 60,
            correctAnswers: 48
        )
        XCTAssertEqual(cat.accuracyRate, 0.8, accuracy: 0.0001)
    }

    func test_completionRate_computedCorrectly() {
        // 60/100 = 0.6
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 60,
            correctAnswers: 48
        )
        XCTAssertEqual(cat.completionRate, 0.6, accuracy: 0.0001)
    }

    func test_weightedScore_formula_60_40_split() {
        // accuracy=0.8, completion=0.6 → (0.8*0.6)+(0.6*0.4) = 0.48+0.24 = 0.72
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 60,
            correctAnswers: 48
        )
        XCTAssertEqual(cat.weightedScore, 0.72, accuracy: 0.0001)
    }

    func test_percentageHelpers_roundCorrectly() {
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 60,
            correctAnswers: 48
        )
        XCTAssertEqual(cat.accuracyPercentage, 80)
        XCTAssertEqual(cat.completionPercentage, 60)
    }
}