import XCTest
import Foundation
@testable import DriveAI

final class QuestionTests: XCTestCase {
    
    // MARK: - Validation
    
    func testQuestionValidatesEmptyText() throws {
        let invalidQuestion = Question(
            id: UUID(),
            quizId: UUID(),
            text: "   ",  // Whitespace only
            options: ["A", "B", "C", "D"],
            correctAnswerIndex: 0,
            difficulty: .beginner,
            explanation: "E"
        )
        
        XCTAssertThrowsError(try invalidQuestion.validate()) { error in
            guard case QuestionError.emptyText = error else {
                XCTFail("Expected emptyText error")
                return
            }
        }
    }
    
    func testQuestionValidatesOptionCount() throws {
        // ❌ Only 3 options
        let tooFewOptions = Question(
            id: UUID(),
            quizId: UUID(),
            text: "Question?",
            options: ["A", "B", "C"],
            correctAnswerIndex: 0,
            difficulty: .beginner,
            explanation: "E"
        )
        
        XCTAssertThrowsError(try tooFewOptions.validate()) { error in
            guard case QuestionError.invalidOptionCount(let count) = error else {
                XCTFail("Expected invalidOptionCount error")
                return
            }
            XCTAssertEqual(count, 3)
        }
        
        // ❌ Too many options
        let tooManyOptions = Question(
            id: UUID(),
            quizId: UUID(),
            text: "Question?",
            options: ["A", "B", "C", "D", "E"],
            correctAnswerIndex: 0,
            difficulty: .beginner,
            explanation: "E"
        )
        
        XCTAssertThrowsError(try tooManyOptions.validate())
    }
    
    func testQuestionValidatesCorrectAnswerIndex() throws {
        let invalidIndex = Question(
            id: UUID(),
            quizId: UUID(),
            text: "Question?",
            options: ["A", "B", "C", "D"],
            correctAnswerIndex: 4,  // Out of bounds
            difficulty: .beginner,
            explanation: "E"
        )
        
        XCTAssertThrowsError(try invalidIndex.validate()) { error in
            guard case QuestionError.invalidCorrectAnswerIndex = error else {
                XCTFail("Expected invalidCorrectAnswerIndex error")
                return
            }
        }
    }
    
    func testQuestionCorrectAnswerProperty() throws {
        let question = Question(
            id: UUID(),
            quizId: UUID(),
            text: "Question?",
            options: ["Wrong", "Correct", "Wrong", "Wrong"],
            correctAnswerIndex: 1,
            difficulty: .beginner,
            explanation: "E"
        )
        
        XCTAssertEqual(question.correctAnswer, "Correct")
    }
    
    // MARK: - Codable (Serialization)
    
    func testQuestionEncodesAndDecodes() throws {
        let original = Question(
            id: UUID(),
            quizId: UUID(),
            text: "Question?",
            options: ["A", "B", "C", "D"],
            correctAnswerIndex: 2,
            difficulty: .advanced,
            explanation: "E"
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Question.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.text, decoded.text)
        XCTAssertEqual(original.correctAnswerIndex, decoded.correctAnswerIndex)
    }
}