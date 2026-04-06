// Tests/Models/QuestionResultTests.swift
import XCTest
@testable import DriveAI

final class QuestionResultTests: XCTestCase {
    
    var mockQuestion: Question!
    var mockUser: User!
    
    override func setUp() {
        super.setUp()
        
        mockQuestion = Question(
            id: "q1",
            category: .trafficSigns,
            text: "Test?",
            imageURL: nil,
            answers: [
                Answer(id: "a1", text: "A"),
                Answer(id: "a2", text: "B")
            ],
            correctAnswerIndex: 0,
            explanation: "Explanation",
            difficulty: .easy
        )
        
        mockUser = User(name: "Test User", examDate: Date().addingTimeInterval(86400 * 30))
    }
    
    // MARK: - Happy Path
    
    func test_questionResult_initialization_correct_answer() {
        // When
        let result = QuestionResult(
            question: mockQuestion,
            userId: mockUser.id,
            selectedAnswerIndex: 0,
            isCorrect: true,
            timeSpentSeconds: 30
        )
        
        // Then
        XCTAssertEqual(result.questionId, "q1")
        XCTAssertEqual(result.userId, mockUser.id)
        XCTAssertEqual(result.category, .trafficSigns)  // ✅ FIX: Category captured
        XCTAssertTrue(result.isCorrect)
        XCTAssertEqual(result.timeSpentSeconds, 30)
    }
    
    func test_questionResult_initialization_wrong_answer() {
        // When
        let result = QuestionResult(
            question: mockQuestion,
            userId: mockUser.id,
            selectedAnswerIndex: 1,
            isCorrect: false,
            timeSpentSeconds: 45
        )
        
        // Then
        XCTAssertEqual(result.selectedAnswerIndex, 1)
        XCTAssertFalse(result.isCorrect)
    }
    
    func test_questionResult_captures_category_at_save_time() {
        // Given: Two results from same user, different categories
        let question1 = mockQuestion!
        
        let question2 = Question(
            id: "q2",
            category: .rightOfWay,  // Different category
            text: "Other?",
            imageURL: nil,
            answers: [Answer(id: "a1", text: "A")],
            correctAnswerIndex: 0,
            explanation: "Test",
            difficulty: .medium
        )
        
        // When
        let result1 = QuestionResult(
            question: question1,
            userId: mockUser.id,
            selectedAnswerIndex: 0,
            isCorrect: true,
            timeSpentSeconds: 30
        )
        
        let result2 = QuestionResult(
            question: question2,
            userId: mockUser.id,
            selectedAnswerIndex: 0,
            isCorrect: true,
            timeSpentSeconds: 25
        )
        
        // Then: Categories are correctly captured
        XCTAssertEqual(result1.category, .trafficSigns)
        XCTAssertEqual(result2.category, .rightOfWay)
        // ✅ No N+1 lookups needed later
    }
    
    func test_questionResult_codable_serialization() throws {
        // Given
        let result = QuestionResult(
            question: mockQuestion,
            userId: mockUser.id,
            selectedAnswerIndex: 0,
            isCorrect: true,
            timeSpentSeconds: 30
        )
        
        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(result)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(QuestionResult.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, result.id)
        XCTAssertEqual(decoded.questionId, result.questionId)
        XCTAssertEqual(decoded.category, result.category)
        XCTAssertEqual(decoded.isCorrect, result.isCorrect)
    }
    
    // MARK: - Edge Cases
    
    func test_questionResult_zero_time_spent() {
        // Scenario: User selects immediately
        let result = QuestionResult(
            question: mockQuestion,
            userId: mockUser.id,
            selectedAnswerIndex: 0,
            isCorrect: true,
            timeSpentSeconds: 0
        )
        
        XCTAssertEqual(result.timeSpentSeconds, 0)
    }
    
    func test_questionResult_very_long_time_spent() {
        // Scenario: User pauses for 10 minutes
        let result = QuestionResult(
            question: mockQuestion,
            userId: mockUser.id,
            selectedAnswerIndex: 0,
            isCorrect: false,
            timeSpentSeconds: 600
        )
        
        XCTAssertEqual(result.timeSpentSeconds, 600)
    }
    
    func test_questionResult_generates_unique_ids() {
        // When: Creating multiple results
        let result1 = QuestionResult(
            question: mockQuestion,
            userId: mockUser.id,
            selectedAnswerIndex: 0,
            isCorrect: true,
            timeSpentSeconds: 30
        )
        
        let result2 = QuestionResult(
            question: mockQuestion,
            userId: mockUser.id,
            selectedAnswerIndex: 0,
            isCorrect: true,
            timeSpentSeconds: 30
        )
        
        // Then: Each result has unique ID
        XCTAssertNotEqual(result1.id, result2.id)
    }
    
    // MARK: - Performance Tests
    
    func test_questionResult_initialization_performance() {
        self.measure {
            _ = QuestionResult(
                question: mockQuestion,
                userId: mockUser.id,
                selectedAnswerIndex: 0,
                isCorrect: true,
                timeSpentSeconds: 30
            )
        }
    }
}