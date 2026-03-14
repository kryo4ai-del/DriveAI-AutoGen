import XCTest
@testable import DriveAI

final class SimulationResultTests: XCTestCase {
    
    // MARK: - Initialization & Validation
    
    @Test
    func testValidResultInitialization() throws {
        let categories = [
            CategoryScore(categoryId: "s1", categoryName: "Signs", correct: 9, total: 10)
        ]
        
        let result = try SimulationResult(
            totalQuestions: 30,
            correctAnswers: 27,
            categoryScores: categories,
            durationSeconds: 1245
        )
        
        #expect(result.totalQuestions == 30)
        #expect(result.correctAnswers == 27)
        #expect(result.score == 0.9)
        #expect(result.passed == true)
    }
    
    @Test
    func testZeroQuestionsThrowsValidationError() {
        let categories: [CategoryScore] = []
        
        XCTAssertThrowsError(
            try SimulationResult(
                totalQuestions: 0,  // Invalid
                correctAnswers: 0,
                categoryScores: categories,
                durationSeconds: 0
            )
        ) { error in
            guard let validationError = error as? SimulationResult.ValidationError else {
                XCTFail("Wrong error type")
                return
            }
            #expect(validationError == .invalidQuestionCount("totalQuestions muss > 0 sein"))
        }
    }
    
    @Test
    func testCorrectAnswersExceedsTotal() {
        let categories = [
            CategoryScore(categoryId: "s1", categoryName: "Signs", correct: 10, total: 10)
        ]
        
        XCTAssertThrowsError(
            try SimulationResult(
                totalQuestions: 30,
                correctAnswers: 35,  // Exceeds total
                categoryScores: categories,
                durationSeconds: 1000
            )
        ) { error in
            guard let validationError = error as? SimulationResult.ValidationError else {
                XCTFail("Wrong error type")
                return
            }
            #expect(validationError == .invalidAnswerCount("correctAnswers (35) außerhalb 0...30"))
        }
    }
    
    @Test
    func testNegativeDurationThrows() {
        let categories = [
            CategoryScore(categoryId: "s1", categoryName: "Signs", correct: 9, total: 10)
        ]
        
        XCTAssertThrowsError(
            try SimulationResult(
                totalQuestions: 30,
                correctAnswers: 27,
                categoryScores: categories,
                durationSeconds: -100  // Invalid
            )
        ) { error in
            guard let validationError = error as? SimulationResult.ValidationError else {
                XCTFail("Wrong error type")
                return
            }
            #expect(validationError == .invalidDuration("durationSeconds darf nicht negativ sein"))
        }
    }
    
    @Test
    func testCategoryTotalMismatchThrows() {
        let categories = [
            CategoryScore(categoryId: "s1", categoryName: "Signs", correct: 9, total: 10),
            CategoryScore(categoryId: "s2", categoryName: "Rules", correct: 8, total: 9)  // Total = 19, but we say 30
        ]
        
        XCTAssertThrowsError(
            try SimulationResult(
                totalQuestions: 30,  // Mismatch with category totals (19)
                correctAnswers: 27,
                categoryScores: categories,
                durationSeconds: 1000
            )
        ) { error in
            guard let validationError = error as? SimulationResult.ValidationError else {
                XCTFail("Wrong error type")
                return
            }
            #expect(validationError == .categoryMismatch("Category total (19) ≠ totalQuestions (30)"))
        }
    }
    
    // MARK: - Score Computation
    
    @Test
    func testScoreCalculation_Perfect() throws {
        let result = try SimulationResult(
            totalQuestions: 30,
            correctAnswers: 30,
            categoryScores: [],
            durationSeconds: 1000
        )
        
        #expect(result.score == 1.0)
        #expect(result.passed == true)
    }
    
    @Test
    func testScoreCalculation_Passing() throws {
        let result = try SimulationResult(
            totalQuestions: 30,
            correctAnswers: 27,  // 90%
            categoryScores: [],
            durationSeconds: 1000
        )
        
        #expect(result.score == 0.90)
        #expect(result.passed == true)
    }
    
    @Test
    func testScoreCalculation_OneBelowPass() throws {
        let result = try SimulationResult(
            totalQuestions: 30,
            correctAnswers: 26,  // 86.67%
            categoryScores: [],
            durationSeconds: 1000
        )
        
        #expect(result.score < 0.90)
        #expect(result.passed == false)
    }
    
    @Test
    func testScoreCalculation_Zero() throws {
        let result = try SimulationResult(
            totalQuestions: 30,
            correctAnswers: 0,
            categoryScores: [],
            durationSeconds: 1000
        )
        
        #expect(result.score == 0.0)
        #expect(result.passed == false)
    }
    
    // MARK: - Duration Formatting
    
    @Test
    func testDurationFormatted_ExactMinutes() throws {
        let result = try SimulationResult(
            totalQuestions: 30,
            correctAnswers: 27,
            categoryScores: [],
            durationSeconds: 1200  // 20 minutes
        )
        
        #expect(result.durationFormatted == "20:00")
    }
    
    @Test
    func testDurationFormatted_MinutesAndSeconds() throws {
        let result = try SimulationResult(
            totalQuestions: 30,
            correctAnswers: 27,
            categoryScores: [],
            durationSeconds: 1245  // 20:45
        )
        
        #expect(result.durationFormatted == "20:45")
    }
    
    @Test
    func testDurationFormatted_UnderOneMinute() throws {
        let result = try SimulationResult(
            totalQuestions: 30,
            correctAnswers: 27,
            categoryScores: [],
            durationSeconds: 45  // 0:45
        )
        
        #expect(result.durationFormatted == "00:45")
    }
    
    // MARK: - Codable (Persistence)
    
    @Test
    func testEncodingAndDecoding() throws {
        let original = SimulationResult.previewPass
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(SimulationResult.self, from: data)
        
        #expect(decoded.id == original.id)
        #expect(decoded.totalQuestions == original.totalQuestions)
        #expect(decoded.correctAnswers == original.correctAnswers)
        #expect(decoded.score == original.score)
        #expect(decoded.durationSeconds == original.durationSeconds)
    }
    
    @Test
    func testDecodingInvalidDataThrows() throws {
        let invalidJSON = """
        {
            "id": "not-a-uuid",
            "totalQuestions": 30,
            "correctAnswers": 27,
            "categoryScores": [],
            "completedAt": "2026-03-13T10:00:00Z",
            "durationSeconds": 1000
        }
        """
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        XCTAssertThrowsError(
            try decoder.decode(SimulationResult.self, from: invalidJSON.data(using: .utf8)!)
        )
    }
}