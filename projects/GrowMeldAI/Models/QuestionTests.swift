import XCTest
@testable import DriveAI

final class QuestionTests: XCTestCase {
    
    // MARK: - Happy Path Tests
    
    func testValidQuestionCreation() {
        let question = Question(
            id: UUID(),
            categoryId: UUID(),
            category: "Verkehrszeichen",
            text: "What does this sign mean?",
            imagePath: "sign_stop",
            options: ["Stop", "Warning", "Yield", "Speed Limit"],
            correctAnswerIndex: 0,
            explanation: "This is a stop sign.",
            difficultyLevel: 2,
            officialReference: "StVO §40"
        )
        
        XCTAssertTrue(question.isValid, "Valid question should pass validation")
        XCTAssertEqual(question.options.count, 4)
        XCTAssertEqual(question.correctAnswerIndex, 0)
    }
    
    func testQuestionCodableRoundTrip() throws {
        let original = TestData.sampleQuestion
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Question.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.text, decoded.text)
        XCTAssertEqual(original.correctAnswerIndex, decoded.correctAnswerIndex)
    }
    
    func testQuestionHashable() {
        let q1 = TestData.sampleQuestion
        let q2 = TestData.sampleQuestion
        
        var set = Set<Question>()
        set.insert(q1)
        set.insert(q2)
        
        XCTAssertEqual(set.count, 1, "Identical questions should hash to same value")
    }
    
    // MARK: - Edge Cases
    
    func testQuestionWithEmptyText() {
        let question = Question(
            id: UUID(),
            categoryId: UUID(),
            category: "Test",
            text: "",
            imagePath: nil,
            options: ["A", "B", "C", "D"],
            correctAnswerIndex: 0,
            explanation: "Valid explanation",
            difficultyLevel: 1,
            officialReference: nil
        )
        
        XCTAssertFalse(question.isValid, "Empty text should fail validation")
    }
    
    func testQuestionWithWrongOptionCount() {
        let question = Question(
            id: UUID(),
            categoryId: UUID(),
            category: "Test",
            text: "Valid question",
            imagePath: nil,
            options: ["A", "B", "C"], // Only 3 instead of 4
            correctAnswerIndex: 0,
            explanation: "Valid explanation",
            difficultyLevel: 1,
            officialReference: nil
        )
        
        XCTAssertFalse(question.isValid, "Wrong option count should fail validation")
    }
    
    func testQuestionWithInvalidCorrectAnswerIndex() {
        let question = Question(
            id: UUID(),
            categoryId: UUID(),
            category: "Test",
            text: "Valid question",
            imagePath: nil,
            options: ["A", "B", "C", "D"],
            correctAnswerIndex: 5, // Out of bounds
            explanation: "Valid explanation",
            difficultyLevel: 1,
            officialReference: nil
        )
        
        XCTAssertFalse(question.isValid, "Out-of-bounds answer index should fail")
    }
    
    func testQuestionWithEmptyExplanation() {
        let question = Question(
            id: UUID(),
            categoryId: UUID(),
            category: "Test",
            text: "Valid question",
            imagePath: nil,
            options: ["A", "B", "C", "D"],
            correctAnswerIndex: 0,
            explanation: "", // Empty
            difficultyLevel: 1,
            officialReference: nil
        )
        
        XCTAssertFalse(question.isValid, "Empty explanation should fail validation")
    }
    
    func testQuestionWithDifficultyBoundaries() {
        for difficulty in [1, 2, 3, 4, 5] {
            let question = Question(
                id: UUID(),
                categoryId: UUID(),
                category: "Test",
                text: "Valid",
                imagePath: nil,
                options: ["A", "B", "C", "D"],
                correctAnswerIndex: 0,
                explanation: "Valid",
                difficultyLevel: difficulty,
                officialReference: nil
            )
            
            XCTAssertTrue(question.isValid, "Difficulty \(difficulty) should be valid")
        }
    }
    
    func testQuestionWithNilOptionalFields() {
        let question = Question(
            id: UUID(),
            categoryId: UUID(),
            category: "Test",
            text: "Valid question",
            imagePath: nil, // Optional
            options: ["A", "B", "C", "D"],
            correctAnswerIndex: 0,
            explanation: "Valid explanation",
            difficultyLevel: 1,
            officialReference: nil // Optional
        )
        
        XCTAssertTrue(question.isValid, "Nil optional fields should be allowed")
    }
    
    // MARK: - Failure Scenarios
    
    func testQuestionDecodingWithMissingFields() throws {
        let invalidJSON = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440001",
            "text": "Missing options"
        }
        """
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(
            try decoder.decode(Question.self, from: invalidJSON.data(using: .utf8)!)
        ) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testQuestionDecodingWithWrongTypes() throws {
        let invalidJSON = """
        {
            "id": "not-a-uuid",
            "category_id": "550e8400-e29b-41d4-a716-446655440002",
            "category": "Test",
            "text": "Question",
            "options": ["A", "B", "C", "D"],
            "correct_answer": "zero",
            "explanation": "Explanation"
        }
        """
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(
            try decoder.decode(Question.self, from: invalidJSON.data(using: .utf8)!)
        )
    }
}