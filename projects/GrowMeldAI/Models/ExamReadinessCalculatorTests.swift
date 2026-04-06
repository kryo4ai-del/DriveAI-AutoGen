import XCTest
@testable import DriveAI

final class ExamReadinessCalculatorTests: XCTestCase {
    var calculator: ExamReadinessCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = ExamReadinessCalculator()
    }
    
    // MARK: - Happy Path
    
    func test_calculate_withPerfectScores_returnsHighProbability() async {
        let categoryScores: [UUID: Double] = [
            UUID(): 0.95,
            UUID(): 0.92,
            UUID(): 0.88
        ]
        let weights = categoryScores.mapValues { _ in 1.0 / Double(categoryScores.count) }
        
        let result = await calculator.calculate(
            categoryScores: categoryScores,
            categoryWeights: weights,
            daysUntilExam: 14,
            questionsAnswered: 150,
            averageVelocity: 10.0
        )
        
        XCTAssertGreaterThanOrEqual(result.passProbability, 0.85)
        XCTAssertEqual(result.readinessLevel, .veryHighConfidence)
        XCTAssertTrue(result.isExamReady)
    }
    
    func test_calculate_withModerateScores_returnsModerateReadiness() async {
        let categoryScores: [UUID: Double] = [
            UUID(): 0.68,
            UUID(): 0.72,
            UUID(): 0.65
        ]
        let weights = categoryScores.mapValues { _ in 1.0 / Double(categoryScores.count) }
        
        let result = await calculator.calculate(
            categoryScores: categoryScores,
            categoryWeights: weights,
            daysUntilExam: 30,
            questionsAnswered: 50,
            averageVelocity: 2.0
        )
        
        XCTAssertGreaterThan(result.passProbability, 0.4)
        XCTAssertLessThan(result.passProbability, 0.75)
        XCTAssertEqual(result.readinessLevel, .moderate)
    }
    
    func test_calculate_withLowScores_returnsLowConfidence() async {
        let categoryScores: [UUID: Double] = [
            UUID(): 0.45,
            UUID(): 0.38,
            UUID(): 0.52
        ]
        let weights = categoryScores.mapValues { _ in 1.0 / Double(categoryScores.count) }
        
        let result = await calculator.calculate(
            categoryScores: categoryScores,
            categoryWeights: weights,
            daysUntilExam: 7,
            questionsAnswered: 20,
            averageVelocity: 1.0
        )
        
        XCTAssertLessThan(result.passProbability, 0.6)
        XCTAssertEqual(result.readinessLevel, .needsWork)
    }
    
    // MARK: - Velocity Boost
    
    func test_calculate_withHighVelocity_bootsReadiness() async {
        let baseScores: [UUID: Double] = [
            UUID(): 0.70,
            UUID(): 0.70,
            UUID(): 0.70
        ]
        let weights = baseScores.mapValues { _ in 1.0 / 3.0 }
        
        let lowVelocityResult = await calculator.calculate(
            categoryScores: baseScores,
            categoryWeights: weights,
            daysUntilExam: 14,
            questionsAnswered: 20,
            averageVelocity: 1.0
        )
        
        let highVelocityResult = await calculator.calculate(
            categoryScores: baseScores,
            categoryWeights: weights,
            daysUntilExam: 14,
            questionsAnswered: 20,
            averageVelocity: 12.0
        )
        
        XCTAssertGreater(
            highVelocityResult.passProbability,
            lowVelocityResult.passProbability,
            "Higher velocity should boost readiness"
        )
    }
    
    // MARK: - Time Pressure Factor
    
    func test_calculate_withExamSoon_reducesProbability() async {
        let categoryScores: [UUID: Double] = [
            UUID(): 0.75,
            UUID(): 0.75,
            UUID(): 0.75
        ]
        let weights = categoryScores.mapValues { _ in 1.0 / 3.0 }
        
        let thirtyDaysOut = await calculator.calculate(
            categoryScores: categoryScores,
            categoryWeights: weights,
            daysUntilExam: 30,
            questionsAnswered: 100,
            averageVelocity: 5.0
        )
        
        let oneDayOut = await calculator.calculate(
            categoryScores: categoryScores,
            categoryWeights: weights,
            daysUntilExam: 1,
            questionsAnswered: 100,
            averageVelocity: 5.0
        )
        
        XCTAssertGreater(
            thirtyDaysOut.passProbability,
            oneDayOut.passProbability,
            "Shorter timeframe should apply pressure penalty"
        )
    }
    
    // MARK: - Edge Cases
    
    func test_calculate_withZeroQuestionsAnswered_returnsMinimumReadiness() async {
        let categoryScores: [UUID: Double] = [:]
        let weights: [UUID: Double] = [:]
        
        let result = await calculator.calculate(
            categoryScores: categoryScores,
            categoryWeights: weights,
            daysUntilExam: 30,
            questionsAnswered: 0,
            averageVelocity: 0.0
        )
        
        XCTAssertGreaterThanOrEqual(result.passProbability, 0.2)
        XCTAssertLessThanOrEqual(result.passProbability, 0.3)
    }
    
    func test_calculate_probabilityBoundedBetweenLimits() async {
        // Test extreme cases never exceed bounds
        let perfectScores: [UUID: Double] = [UUID(): 1.0, UUID(): 1.0]
        let perfectWeights = perfectScores.mapValues { _ in 0.5 }
        
        let perfectResult = await calculator.calculate(
            categoryScores: perfectScores,
            categoryWeights: perfectWeights,
            daysUntilExam: 0,
            questionsAnswered: 500,
            averageVelocity: 20.0
        )
        
        XCTAssertLessThanOrEqual(perfectResult.passProbability, 0.95)
        
        let zeroScores: [UUID: Double] = [UUID(): 0.0, UUID(): 0.0]
        let zeroWeights = zeroScores.mapValues { _ in 0.5 }
        
        let zeroResult = await calculator.calculate(
            categoryScores: zeroScores,
            categoryWeights: zeroWeights,
            daysUntilExam: 1,
            questionsAnswered: 5,
            averageVelocity: 0.1
        )
        
        XCTAssertGreaterThanOrEqual(zeroResult.passProbability, 0.2)
    }
    
    func test_calculate_withWeightedCategories() async {
        let uuid1 = UUID()
        let uuid2 = UUID()
        
        let categoryScores: [UUID: Double] = [
            uuid1: 0.90,  // High score
            uuid2: 0.40   // Low score
        ]
        
        // Scenario 1: uuid1 is 80% of exam
        let weights1: [UUID: Double] = [
            uuid1: 0.8,
            uuid2: 0.2
        ]
        
        let resultWeighted1 = await calculator.calculate(
            categoryScores: categoryScores,
            categoryWeights: weights1,
            daysUntilExam: 14,
            questionsAnswered: 100,
            averageVelocity: 5.0
        )
        
        // Scenario 2: uuid1 is 20% of exam
        let weights2: [UUID: Double] = [
            uuid1: 0.2,
            uuid2: 0.8
        ]
        
        let resultWeighted2 = await calculator.calculate(
            categoryScores: categoryScores,
            categoryWeights: weights2,
            daysUntilExam: 14,
            questionsAnswered: 100,
            averageVelocity: 5.0
        )
        
        XCTAssertGreater(
            resultWeighted1.passProbability,
            resultWeighted2.passProbability,
            "Weighting the strong category higher should increase readiness"
        )
    }
    
    func test_calculate_confidenceInterval() async {
        let categoryScores: [UUID: Double] = [UUID(): 0.70, UUID(): 0.70]
        let weights = categoryScores.mapValues { _ in 0.5 }
        
        let result = await calculator.calculate(
            categoryScores: categoryScores,
            categoryWeights: weights,
            daysUntilExam: 14,
            questionsAnswered: 100,
            averageVelocity: 5.0
        )
        
        XCTAssertLessThan(result.confidenceLower, result.passProbability)
        XCTAssertGreater(result.confidenceUpper, result.passProbability)
        XCTAssertGreaterThanOrEqual(result.confidenceLower, 0.0)
        XCTAssertLessThanOrEqual(result.confidenceUpper, 1.0)
    }
}