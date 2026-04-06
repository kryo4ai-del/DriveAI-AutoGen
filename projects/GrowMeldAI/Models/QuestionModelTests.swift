import XCTest
@testable import DriveAI

final class QuestionModelTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testQuestionInitialization() {
        let question = TestQuestions.validQuestion
        
        XCTAssertEqual(question.text, "Was bedeutet das Stoppschild?")
        XCTAssertEqual(question.category, .trafficSigns)
        XCTAssertEqual(question.options.count, 3)
        XCTAssertEqual(question.correctAnswerIndex, 0)
    }
    
    func testQuestionIdentifiable() {
        let question1 = TestQuestions.validQuestion
        let question2 = TestQuestions.validQuestion
        
        XCTAssertEqual(question1.id, question2.id)
    }
    
    // MARK: - Codable Tests
    
    func testQuestionEncode() throws {
        let question = TestQuestions.validQuestion
        let encoder = JSONEncoder()
        
        let encoded = try encoder.encode(question)
        XCTAssertGreater(encoded.count, 0)
    }
    
    func testQuestionDecode() throws {
        let question = TestQuestions.validQuestion
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let encoded = try encoder.encode(question)
        let decoded = try decoder.decode(Question.self, from: encoded)
        
        XCTAssertEqual(decoded.id, question.id)
        XCTAssertEqual(decoded.text, question.text)
        XCTAssertEqual(decoded.correctAnswerIndex, question.correctAnswerIndex)
    }
    
    func testQuestionDecodeWithMissingField() throws {
        let json = """
        {
            "id": "12345678-1234-5678-1234-567812345678",
            "category": "Verkehrszeichen",
            "text": "Test",
            "options": ["A"],
            "explanation": "Test"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        XCTAssertThrowsError(
            try decoder.decode(Question.self, from: json)
        ) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testQuestionDecodeWithInvalidCategory() throws {
        let json = """
        {
            "id": "12345678-1234-5678-1234-567812345678",
            "category": "InvalidCategory",
            "text": "Test",
            "options": ["A"],
            "correctAnswer": 0,
            "explanation": "Test",
            "difficulty": "easy",
            "topicTags": []
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        XCTAssertThrowsError(
            try decoder.decode(Question.self, from: json)
        )
    }
    
    // MARK: - Validation Tests
    
    func testValidQuestionWithAllFields() {
        let question = TestQuestions.validQuestion
        
        XCTAssertFalse(question.text.isEmpty)
        XCTAssertTrue(question.correctAnswerIndex < question.options.count)
        XCTAssert(question.options.count >= 2)
    }
    
    func testInvalidAnswerIndex() {
        let question = TestQuestions.questionsWithInvalidIndex
        
        XCTAssertGreaterThanOrEqual(
            question.correctAnswerIndex,
            question.options.count
        )
    }
    
    func testEmptyQuestionText() {
        let question = TestQuestions.questionWithEmptyText
        
        XCTAssertTrue(question.text.isEmpty)
    }
    
    // MARK: - Category Tests
    
    func testAllCategoriesAvailable() {
        let categories = QuestionCategory.allCases
        
        XCTAssertGreaterThan(categories.count, 0)
        XCTAssert(categories.contains(.trafficSigns))
        XCTAssert(categories.contains(.rightOfWay))
    }
    
    func testCategoryDisplayName() {
        let category = QuestionCategory.trafficSigns
        
        XCTAssertEqual(category.displayName, "Verkehrszeichen")
    }
    
    // MARK: - Difficulty Tests
    
    func testDifficultyEncoding() throws {
        let difficulties: [Difficulty] = [.easy, .medium, .hard]
        let encoder = JSONEncoder()
        
        for difficulty in difficulties {
            let encoded = try encoder.encode(difficulty)
            XCTAssertGreater(encoded.count, 0)
        }
    }
}