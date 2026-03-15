final class ReadinessScoreTests: XCTestCase {

    // MARK: Label Boundaries

    func test_label_boundaries_exactValues() {
        let cases: [(Double, ReadinessLabel)] = [
            (0.00, .notReady),
            (0.39, .notReady),
            (0.40, .developing),
            (0.64, .developing),
            (0.65, .almostReady),
            (0.79, .almostReady),
            (0.80, .ready),
            (0.89, .ready),
            (0.90, .examReady),
            (1.00, .examReady)
        ]
        for (value, expectedLabel) in cases {
            let score = ReadinessScore(value: value, computedAt: .now, trend: .stable)
            XCTAssertEqual(score.label, expectedLabel,
                "Value \(value) should map to \(expectedLabel.rawValue)")
        }
    }

    func test_percentage_roundsCorrectly() {
        XCTAssertEqual(ReadinessScore(value: 0.755, computedAt: .now, trend: .stable).percentage, 76)
        XCTAssertEqual(ReadinessScore(value: 0.754, computedAt: .now, trend: .stable).percentage, 75)
        XCTAssertEqual(ReadinessScore(value: 0.00,  computedAt: .now, trend: .stable).percentage, 0)
        XCTAssertEqual(ReadinessScore(value: 1.00,  computedAt: .now, trend: .stable).percentage, 100)
    }

    func test_codableRoundTrip_allTrendValues() throws {
        for trend in [ReadinessScore.Trend.improving, .stable, .declining] {
            let score = ReadinessScore(value: 0.75, computedAt: .now, trend: trend)
            let data = try JSONEncoder().encode(score)
            let decoded = try JSONDecoder().decode(ReadinessScore.self, from: data)
            XCTAssertEqual(decoded.trend, trend)
        }
    }

    func test_readinessLabel_allCasesHaveColorAndImage() {
        for label in ReadinessLabel.allCases {
            XCTAssertFalse(label.colorName.isEmpty,
                "\(label) missing colorName")
            XCTAssertFalse(label.systemImage.isEmpty,
                "\(label) missing systemImage")
        }
    }
}