final class CategoryReadinessInvariantTests: XCTestCase {

    // MARK: Happy Path

    func test_validInput_storesValuesUnchanged() {
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 60,
            correctAnswers: 48
        )
        XCTAssertEqual(cat.questionsTotal, 100)
        XCTAssertEqual(cat.questionsAttempted, 60)
        XCTAssertEqual(cat.correctAnswers, 48)
    }

    // MARK: Boundary — correctAnswers > questionsAttempted

    func test_correctAnswersExceedsAttempted_clampedToAttempted() {
        let cat = CategoryReadiness.make(
            questionsTotal: 100,
            questionsAttempted: 30,
            correctAnswers: 50   // impossible: more correct than attempted
        )
        XCTAssertEqual(cat.correctAnswers, 30)
        XCTAssertLessThanOrEqual(cat.accuracyRate, 1.0)
    }

    func test_attemptedExceedsTotal_clampedToTotal() {
        let cat = CategoryReadiness.make(
            questionsTotal: 50,
            questionsAttempted: 80,   // impossible
            correctAnswers: 40
        )
        XCTAssertEqual(cat.questionsAttempted, 50)
    }

    func test_negativeValues_clampedToZero() {
        let cat = CategoryReadiness.make(
            questionsTotal: -10,
            questionsAttempted: -5,
            correctAnswers: -3
        )
        XCTAssertEqual(cat.questionsTotal, 0)
        XCTAssertEqual(cat.questionsAttempted, 0)
        XCTAssertEqual(cat.correctAnswers, 0)
    }

    func test_allZeros_doesNotCrash_returnsZeroRates() {
        let cat = CategoryReadiness.make(
            questionsTotal: 0,
            questionsAttempted: 0,
            correctAnswers: 0
        )
        XCTAssertEqual(cat.accuracyRate, 0)
        XCTAssertEqual(cat.completionRate, 0)
        XCTAssertEqual(cat.weightedScore, 0)
    }

    // MARK: Edge — perfect score

    func test_perfectScore_accuracyRateEqualsOne() {
        let cat = CategoryReadiness.make(
            questionsTotal: 40,
            questionsAttempted: 40,
            correctAnswers: 40
        )
        XCTAssertEqual(cat.accuracyRate, 1.0, accuracy: 0.0001)
        XCTAssertEqual(cat.completionRate, 1.0, accuracy: 0.0001)
        XCTAssertEqual(cat.weightedScore, 1.0, accuracy: 0.0001)
    }
}