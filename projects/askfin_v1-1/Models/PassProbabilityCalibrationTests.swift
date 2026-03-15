import Foundation
@MainActor
final class PassProbabilityCalibrationTests: XCTestCase {
    func testBoundaryConditions() {
        let service = ReadinessCalculationService()
        
        // Test 0%: should be ~0-10%
        let p0 = service.estimatePassProbability(
            readiness: ReadinessScore(
                overall: 0, timestamp: Date(), questionsAttempted: 0,
                averageScore: 0, categoryScores: [:], confidenceLevel: .low
            )
        )
        XCTAssertLessThan(p0, 10, "0% readiness → <10% pass probability")
        
        // Test pass threshold (75%): should be ~60-75%
        let p75 = service.estimatePassProbability(
            readiness: ReadinessScore(
                overall: 75, timestamp: Date(), questionsAttempted: 30,
                averageScore: 75, categoryScores: [:], confidenceLevel: .high
            )
        )
        XCTAssertGreaterThan(p75, 50, "75% readiness → >50% pass probability")
        XCTAssertLessThan(p75, 85, "75% readiness → <85% pass probability")
        
        // Test 95%: should be ~90%+
        let p95 = service.estimatePassProbability(
            readiness: ReadinessScore(
                overall: 95, timestamp: Date(), questionsAttempted: 50,
                averageScore: 95, categoryScores: [:], confidenceLevel: .expert
            )
        )
        XCTAssertGreaterThan(p95, 85, "95% readiness → >85% pass probability")
    }
    
    func testMonotonicity() {
        let service = ReadinessCalculationService()
        let scores = [0, 25, 50, 75, 90, 100]
        let probabilities = scores.map { score in
            service.estimatePassProbability(
                readiness: ReadinessScore(
                    overall: Double(score), timestamp: Date(), questionsAttempted: 30,
                    averageScore: Double(score), categoryScores: [:], 
                    confidenceLevel: .moderate
                )
            )
        }
        
        // Verify monotonic increase
        for i in 1..<probabilities.count {
            XCTAssertGreaterThanOrEqual(
                probabilities[i],
                probabilities[i-1],
                "Pass probability should increase monotonically with readiness score"
            )
        }
    }
}