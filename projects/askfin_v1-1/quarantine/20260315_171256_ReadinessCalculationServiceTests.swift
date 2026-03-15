// Tests/ReadinessCalculationServiceTests.swift
@MainActor
final class ReadinessCalculationServiceTests: XCTestCase {
    func testPassProbabilityBoundaries() {
        let service = ReadinessCalculationService()
        
        // Test score 0% → probability should be ~0%
        let score0 = ReadinessScore(
            overall: 0, timestamp: Date(), questionsAttempted: 0,
            averageScore: 0, categoryScores: [:], confidenceLevel: .low
        )
        XCTAssertLessThan(service.estimatePassProbability(readiness: score0), 10)
        
        // Test score 100% → probability should be ~100%
        let score100 = ReadinessScore(
            overall: 100, timestamp: Date(), questionsAttempted: 50,
            averageScore: 100, categoryScores: [:], confidenceLevel: .expert
        )
        XCTAssertGreaterThan(service.estimatePassProbability(readiness: score100), 90)
        
        // Test score 75% (pass threshold) → probability should be ~50-75%
        let score75 = ReadinessScore(
            overall: 75, timestamp: Date(), questionsAttempted: 30,
            averageScore: 75, categoryScores: [:], confidenceLevel: .high
        )
        let prob75 = service.estimatePassProbability(readiness: score75)
        XCTAssertGreaterThan(prob75, 40)
        XCTAssertLessThan(prob75, 85)
    }
}