import XCTest
@testable import DriveAI

final class QuestionDomainTests: XCTestCase {
    
    // MARK: - Happy Path: Valid Question Creation
    
    func testValidQuestionCreation() throws {
        let question = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "What does a red traffic light mean?",
            answers: ["Stop", "Caution", "Go"],
            correctAnswerIndex: 0,
            difficulty: .easy,
            imageURL: "http://example.com/light.jpg",
            explanation: "Red means stop."
        )
        
        XCTAssertEqual(question.id, "q1")
        XCTAssertEqual(question.text, "What does a red traffic light mean?")
        XCTAssertEqual(question.answers.count, 3)
        XCTAssertEqual(question.correctAnswer, "Stop")
    }
    
    func testAllCategoriesSupported() throws {
        for category in QuestionDomain.QuestionCategory.allCases {
            let question = try QuestionDomain(
                id: "q_\(category.rawValue)",
                category: category,
                text: "Test question",
                answers: ["A", "B", "C"],
                correctAnswerIndex: 0,
                difficulty: .medium,
                imageURL: nil,
                explanation: "Test"
            )
            XCTAssertEqual(question.category, category)
        }
    }
    
    func testAllDifficultiesSupported() throws {
        for difficulty in [QuestionDomain.Difficulty.easy, .medium, .hard] {
            let question = try QuestionDomain(
                id: "q_\(difficulty.rawValue)",
                category: .trafficSigns,
                text: "Test question",
                answers: ["A", "B", "C"],
                correctAnswerIndex: 0,
                difficulty: difficulty,
                imageURL: nil,
                explanation: "Test"
            )
            XCTAssertEqual(question.difficulty, difficulty)
        }
    }
    
    // MARK: - Edge Cases: Valid Boundaries
    
    func testMinimumAnswerCount() throws {
        let question = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "Question",
            answers: ["A", "B", "C"],  // Minimum: 3
            correctAnswerIndex: 0,
            difficulty: .easy,
            imageURL: nil,
            explanation: "Explain"
        )
        XCTAssertEqual(question.answers.count, 3)
    }
    
    func testMaximumAnswerCount() throws {
        let question = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "Question",
            answers: ["A", "B", "C", "D", "E"],  // Maximum: 5
            correctAnswerIndex: 2,
            difficulty: .easy,
            imageURL: nil,
            explanation: "Explain"
        )
        XCTAssertEqual(question.answers.count, 5)
    }
    
    func testCorrectAnswerIndexBoundaries() throws {
        let question = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "Question",
            answers: ["A", "B", "C"],
            correctAnswerIndex: 2,  // Last index
            difficulty: .easy,
            imageURL: nil,
            explanation: "Explain"
        )
        XCTAssertEqual(question.correctAnswerIndex, 2)
        XCTAssertEqual(question.correctAnswer, "C")
    }
    
    // MARK: - Invalid Inputs: Validation Failures
    
    func testEmptyQuestionTextThrows() throws {
        XCTAssertThrowsError(
            try QuestionDomain(
                id: "q1",
                category: .trafficSigns,
                text: "",  // Empty!
                answers: ["A", "B", "C"],
                correctAnswerIndex: 0,
                difficulty: .easy,
                imageURL: nil,
                explanation: "Explain"
            )
        ) { error in
            guard let validationError = error as? QuestionDomain.ValidationError else {
                XCTFail("Expected ValidationError")
                return
            }
            XCTAssertEqual(validationError, .emptyQuestion)
        }
    }
    
    func testWhitespaceOnlyQuestionThrows() throws {
        XCTAssertThrowsError(
            try QuestionDomain(
                id: "q1",
                category: .trafficSigns,
                text: "   \t\n   ",  // Only whitespace
                answers: ["A", "B", "C"],
                correctAnswerIndex: 0,
                difficulty: .easy,
                imageURL: nil,
                explanation: "Explain"
            )
        ) { error in
            XCTAssert(error is QuestionDomain.ValidationError)
        }
    }
    
    func testTooFewAnswersThrows() throws {
        XCTAssertThrowsError(
            try QuestionDomain(
                id: "q1",
                category: .trafficSigns,
                text: "Question",
                answers: ["A", "B"],  // Only 2 — minimum is 3
                correctAnswerIndex: 0,
                difficulty: .easy,
                imageURL: nil,
                explanation: "Explain"
            )
        ) { error in
            guard let validationError = error as? QuestionDomain.ValidationError else {
                XCTFail("Expected ValidationError")
                return
            }
            XCTAssertEqual(validationError, .invalidAnswerCount)
        }
    }
    
    func testTooManyAnswersThrows() throws {
        XCTAssertThrowsError(
            try QuestionDomain(
                id: "q1",
                category: .trafficSigns,
                text: "Question",
                answers: ["A", "B", "C", "D", "E", "F"],  // 6 — maximum is 5
                correctAnswerIndex: 0,
                difficulty: .easy,
                imageURL: nil,
                explanation: "Explain"
            )
        ) { error in
            XCTAssert(error is QuestionDomain.ValidationError)
        }
    }
    
    func testNegativeCorrectAnswerIndexThrows() throws {
        XCTAssertThrowsError(
            try QuestionDomain(
                id: "q1",
                category: .trafficSigns,
                text: "Question",
                answers: ["A", "B", "C"],
                correctAnswerIndex: -1,  // Invalid!
                difficulty: .easy,
                imageURL: nil,
                explanation: "Explain"
            )
        ) { error in
            XCTAssert(error is QuestionDomain.ValidationError)
        }
    }
    
    func testOutOfBoundsCorrectAnswerIndexThrows() throws {
        XCTAssertThrowsError(
            try QuestionDomain(
                id: "q1",
                category: .trafficSigns,
                text: "Question",
                answers: ["A", "B", "C"],
                correctAnswerIndex: 5,  // Only 3 answers (indices 0–2)
                difficulty: .easy,
                imageURL: nil,
                explanation: "Explain"
            )
        ) { error in
            guard let validationError = error as? QuestionDomain.ValidationError else {
                XCTFail("Expected ValidationError")
                return
            }
            XCTAssertEqual(validationError, .invalidCorrectAnswerIndex)
        }
    }
    
    // MARK: - Codable: JSON Serialization
    
    func testQuestionEncodesAndDecodesSuccessfully() throws {
        let original = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "What does a red light mean?",
            answers: ["Stop", "Caution", "Go"],
            correctAnswerIndex: 0,
            difficulty: .medium,
            imageURL: "http://example.com/light.jpg",
            explanation: "Red means stop."
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(QuestionDomain.self, from: encoded)
        
        XCTAssertEqual(decoded, original)
    }
    
    func testCodableEnforcesValidation() throws {
        let invalidJSON = """
        {
            "id": "q1",
            "category": "traffic_signs",
            "text": "",
            "answers": [],
            "correctAnswerIndex": 99,
            "difficulty": "easy",
            "imageURL": null,
            "explanation": "Test"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(
            try decoder.decode(QuestionDomain.self, from: invalidJSON)
        ) { error in
            XCTAssert(error is QuestionDomain.ValidationError)
        }
    }
    
    // MARK: - Hashable & Equatable
    
    func testQuestionHashability() throws {
        let q1 = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "Question",
            answers: ["A", "B", "C"],
            correctAnswerIndex: 0,
            difficulty: .easy,
            imageURL: nil,
            explanation: "Explain"
        )
        
        let q2 = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "Question",
            answers: ["A", "B", "C"],
            correctAnswerIndex: 0,
            difficulty: .easy,
            imageURL: nil,
            explanation: "Explain"
        )
        
        var set: Set<QuestionDomain> = [q1]
        XCTAssertTrue(set.contains(q2))
    }
    
    func testQuestionEquality() throws {
        let q1 = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "Question",
            answers: ["A", "B", "C"],
            correctAnswerIndex: 0,
            difficulty: .easy,
            imageURL: nil,
            explanation: "Explain"
        )
        
        let q2 = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "Question",
            answers: ["A", "B", "C"],
            correctAnswerIndex: 0,
            difficulty: .easy,
            imageURL: nil,
            explanation: "Explain"
        )
        
        XCTAssertEqual(q1, q2)
    }
    
    func testQuestionInequalityOnDifferentText() throws {
        let q1 = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "Question A",
            answers: ["A", "B", "C"],
            correctAnswerIndex: 0,
            difficulty: .easy,
            imageURL: nil,
            explanation: "Explain"
        )
        
        let q2 = try QuestionDomain(
            id: "q1",
            category: .trafficSigns,
            text: "Question B",
            answers: ["A", "B", "C"],
            correctAnswerIndex: 0,
            difficulty: .easy,
            imageURL: nil,
            explanation: "Explain"
        )
        
        XCTAssertNotEqual(q1, q2)
    }
}