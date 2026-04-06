// Tests/PerformanceTrackingTests/PerformanceAnalyzerTests.swift
final class PerformanceAnalyzerTests: XCTestCase {
    let analyzer = PerformanceAnalyzer()
    
    func testCalculateMastery_withAllCorrect_returns100Percent() {
        let attempts = [
            QuestionAttempt(questionID: "1", categoryID: "signs", isCorrect: true, timeSpent: 5),
            QuestionAttempt(questionID: "2", categoryID: "signs", isCorrect: true, timeSpent: 5),
        ]
        
        let mastery = analyzer.calculateMastery(from: attempts)
        
        XCTAssertEqual(mastery, 1.0)
    }
    
    func testExamReadiness_calculatesCorrectWeightedScore() {
        let readiness = analyzer.estimateExamReadiness(
            overallScore: 0.9,
            weakAreas: [],
            timeEfficiency: 0.8
        )
        
        // (0.9 * 0.5) + (1.0 * 0.3) + (0.8 * 0.2) = 0.86
        XCTAssertAlmostEqual(readiness.value, 0.86, accuracy: 0.01)
    }
}

// Tests/PerformanceTrackingTests/PerformanceStoreTests.swift
final class PerformanceStoreTests: XCTestCase {
    var store: PerformanceStore!
    
    override func setUp() async throws {
        // Use in-memory database for tests
        store = PerformanceStore(dbQueue: try DatabaseQueue(configuration: .init(useMemoryStorage: true)))
    }
    
    func testSaveAttempt_persists_successfully() async throws {
        let attempt = QuestionAttempt(...)
        try await store.saveQuestionAttempt(attempt)
        
        let fetched = try await store.fetchRawAttempts(categoryID: attempt.categoryID)
        XCTAssertEqual(fetched.count, 1)
    }
}