import XCTest
@testable import DriveAI

final class ExamReadinessModelsTests: XCTestCase {
    
    // MARK: - CategoryReadiness Tests
    
    func testCategoryReadinessPercentageCalculation_ValidScores() {
        // Given: Category with 7 correct out of 10
        let category = CategoryReadiness(
            id: "traffic_signs",
            name: "Verkehrszeichen",
            icon: "signpost.right",
            totalQuestions: 10,
            correctAnswers: 7,
            averageScore: 0.7,
            lastStudied: Date(),
            strength: .strong
        )
        
        // When: Calculate percentage
        let percentage = category.percentage
        
        // Then: Should be 70%
        XCTAssertEqual(percentage, 70)
    }
    
    func testCategoryReadinessPercentageCalculation_ZeroTotal() {
        // Given: Category with no questions
        let category = CategoryReadiness(
            id: "empty",
            name: "Empty",
            icon: nil,
            totalQuestions: 0,
            correctAnswers: 0,
            averageScore: 0.0,
            lastStudied: nil,
            strength: .weak
        )
        
        // When: Calculate percentage
        let percentage = category.percentage
        
        // Then: Should be 0% (safe divide)
        XCTAssertEqual(percentage, 0)
    }
    
    func testCategoryReadinessPercentageCalculation_EdgeCases() {
        let testCases: [(total: Int, correct: Int, expected: Int)] = [
            (1, 1, 100),      // Perfect score
            (1, 0, 0),        // Zero score
            (3, 1, 33),       // Rounding
            (100, 75, 75),    // Large set
        ]
        
        for (total, correct, expected) in testCases {
            let category = CategoryReadiness(
                id: "test_\(total)",
                name: "Test",
                icon: nil,
                totalQuestions: total,
                correctAnswers: correct,
                averageScore: Double(correct) / Double(total),
                lastStudied: nil,
                strength: .weak
            )
            
            XCTAssertEqual(category.percentage, expected, 
                          "Failed for \(correct)/\(total)")
        }
    }
    
    func testCategoryReadinessRecommendedSessionSize() {
        let testCases: [(strength: StrengthRating, expected: Int)] = [
            (.weak, 15),
            (.moderate, 12),
            (.strong, 10),
            (.excellent, 5),
        ]
        
        for (strength, expected) in testCases {
            let category = CategoryReadiness(
                id: "test",
                name: "Test",
                icon: nil,
                totalQuestions: 100,
                correctAnswers: 50,
                averageScore: 0.5,
                lastStudied: nil,
                strength: strength
            )
            
            XCTAssertEqual(category.recommendedSessionSize, expected,
                          "Failed for \(strength.label)")
        }
    }
    
    // MARK: - ExamReadinessScore Tests
    
    func testExamReadinessScoreReadyThreshold() {
        let readyScore = ExamReadinessScore(
            overall: 0.75,
            percentageInt: 75,
            level: .ready,
            calculatedAt: Date(),
            weakCategoryCount: 0,
            strongCategoryCount: 5,
            categoriesAboveThreshold: 8
        )
        
        let notReadyScore = ExamReadinessScore(
            overall: 0.45,
            percentageInt: 45,
            level: .notReady,
            calculatedAt: Date(),
            weakCategoryCount: 3,
            strongCategoryCount: 1,
            categoriesAboveThreshold: 2
        )
        
        XCTAssertTrue(readyScore.isReady)
        XCTAssertFalse(notReadyScore.isReady)
    }
    
    func testExamReadinessScoreRecommendations() {
        let testCases: [(level: ReadinessLevel, hasText: Bool)] = [
            (.notReady, true),
            (.partiallyReady, true),
            (.ready, true),
            (.excellent, true),
        ]
        
        for (level, shouldHaveText) in testCases {
            let score = ExamReadinessScore(
                overall: 0.5,
                percentageInt: 50,
                level: level,
                calculatedAt: Date(),
                weakCategoryCount: 1,
                strongCategoryCount: 0,
                categoriesAboveThreshold: 0
            )
            
            if shouldHaveText {
                XCTAssertFalse(score.recommendation.isEmpty,
                              "Missing recommendation for \(level.label)")
            }
        }
    }
    
    func testExamReadinessScoreCodable() throws {
        // Given: Score object
        let original = ExamReadinessScore(
            overall: 0.75,
            percentageInt: 75,
            level: .ready,
            calculatedAt: Date(),
            weakCategoryCount: 2,
            strongCategoryCount: 5,
            categoriesAboveThreshold: 7
        )
        
        // When: Encode and decode
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ExamReadinessScore.self, from: encoded)
        
        // Then: Should match
        XCTAssertEqual(decoded.overall, original.overall)
        XCTAssertEqual(decoded.level, original.level)
        XCTAssertEqual(decoded.weakCategoryCount, original.weakCategoryCount)
    }
    
    // MARK: - ReadinessTrendPoint Tests
    
    func testReadinessTrendPointIdentifiable() {
        let point1 = ReadinessTrendPoint(
            id: UUID(),
            date: Date(),
            score: 75,
            weakCategoryCount: 2
        )
        
        let point2 = ReadinessTrendPoint(
            id: UUID(),
            date: Date(),
            score: 75,
            weakCategoryCount: 2
        )
        
        // Should have different IDs
        XCTAssertNotEqual(point1.id, point2.id)
    }
    
    func testReadinessTrendPointDayOfWeek_German() {
        // Given: A Monday date
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "de_DE")
        
        let components = DateComponents(
            year: 2024,
            month: 3,
            day: 18  // Monday
        )
        guard let mondayDate = calendar.date(from: components) else {
            XCTFail("Could not create test date")
            return
        }
        
        let point = ReadinessTrendPoint(
            id: UUID(),
            date: mondayDate,
            score: 75,
            weakCategoryCount: 1
        )
        
        // When: Get day of week
        let dayOfWeek = point.dayOfWeek
        
        // Then: Should be "Mo" in German
        XCTAssertEqual(dayOfWeek.lowercased(), "mo")
    }
    
    // MARK: - StrengthRating Enum Tests
    
    func testStrengthRatingComparison() {
        XCTAssertLessThan(StrengthRating.weak, .moderate)
        XCTAssertLessThan(StrengthRating.moderate, .strong)
        XCTAssertLessThan(StrengthRating.strong, .excellent)
        XCTAssertEqual(StrengthRating.weak, .weak)
    }
    
    func testStrengthRatingLabel() {
        XCTAssertEqual(StrengthRating.weak.label, "Schwach")
        XCTAssertEqual(StrengthRating.moderate.label, "Mäßig")
        XCTAssertEqual(StrengthRating.strong.label, "Stark")
        XCTAssertEqual(StrengthRating.excellent.label, "Ausgezeichnet")
    }
    
    func testStrengthRatingColorName() {
        XCTAssertEqual(StrengthRating.weak.colorName, "red")
        XCTAssertEqual(StrengthRating.moderate.colorName, "yellow")
        XCTAssertEqual(StrengthRating.strong.colorName, "green")
        XCTAssertEqual(StrengthRating.excellent.colorName, "blue")
    }
    
    // MARK: - ReadinessLevel Enum Tests
    
    func testReadinessLevelComparison() {
        XCTAssertLessThan(ReadinessLevel.notReady, .partiallyReady)
        XCTAssertLessThan(ReadinessLevel.partiallyReady, .ready)
        XCTAssertLessThan(ReadinessLevel.ready, .excellent)
    }
    
    func testReadinessLevelLabel() {
        XCTAssertEqual(ReadinessLevel.notReady.label, "Nicht bereit")
        XCTAssertEqual(ReadinessLevel.partiallyReady.label, "Teilweise bereit")
        XCTAssertEqual(ReadinessLevel.ready.label, "Bereit")
        XCTAssertEqual(ReadinessLevel.excellent.label, "Ausgezeichnet")
    }
    
    // MARK: - ExamReadinessError Tests
    
    func testExamReadinessErrorDescriptions() {
        let error1 = ExamReadinessError.noCategoryData(reason: "DB empty")
        XCTAssertTrue(error1.errorDescription?.contains("nicht verfügbar") ?? false)
        XCTAssertTrue(error1.errorDescription?.contains("DB empty") ?? false)
        
        let error2 = ExamReadinessError.persistenceFailure("No space")
        XCTAssertTrue(error2.errorDescription?.contains("Speicherfehler") ?? false)
        
        let error3 = ExamReadinessError.invalidCategoryId("xyz")
        XCTAssertTrue(error3.errorDescription?.contains("xyz") ?? false)
    }
    
    func testExamReadinessErrorRecoverySuggestion() {
        let error1 = ExamReadinessError.noCategoryData(reason: "test")
        XCTAssertNotNil(error1.recoverySuggestion)
        XCTAssertTrue(error1.recoverySuggestion?.contains("später") ?? false)
        
        let error2 = ExamReadinessError.corruptTrendData(categoryId: "test")
        XCTAssertNotNil(error2.recoverySuggestion)
    }
}