import XCTest
@testable import DriveAI

class QuestionAnswerIdempotentTests: XCTestCase {
    var sut: QuestionAnswer!
    
    // HAPPY PATH: Idempotency key is consistent
    func test_idempotencyKey_consistent() {
        // Arrange
        let deviceID = "device123"
        let questionID = "q456"
        let sessionID = "session789"
        
        let answer1 = QuestionAnswer(
            id: UUID().uuidString,
            questionID: questionID,
            selectedOptionIndex: 0,
            isCorrect: true,
            category: "traffic_signs",
            timestamp: Date(),
            deviceID: deviceID,
            sessionID: sessionID
        )
        
        let answer2 = QuestionAnswer(
            id: UUID().uuidString, // Different UUID!
            questionID: questionID,
            selectedOptionIndex: 0,
            isCorrect: true,
            category: "traffic_signs",
            timestamp: Date(timeIntervalSince1970: 0), // Different time!
            deviceID: deviceID,
            sessionID: sessionID
        )
        
        // Act
        let key1 = answer1.idempotencyKey
        let key2 = answer2.idempotencyKey
        
        // Assert: Same key despite different UUIDs/timestamps
        XCTAssertEqual(key1, key2, "Idempotency key should only depend on device, question, session")
    }
    
    // EDGE CASE: Different questions produce different keys
    func test_idempotencyKey_differentQuestions_differentKeys() {
        // Arrange
        let deviceID = "device123"
        let sessionID = "session789"
        
        let answer1 = QuestionAnswer(
            id: UUID().uuidString,
            questionID: "q1",
            selectedOptionIndex: 0,
            isCorrect: true,
            category: "traffic_signs",
            timestamp: Date(),
            deviceID: deviceID,
            sessionID: sessionID
        )
        
        let answer2 = QuestionAnswer(
            id: UUID().uuidString,
            questionID: "q2", // Different!
            selectedOptionIndex: 0,
            isCorrect: true,
            category: "traffic_signs",
            timestamp: Date(),
            deviceID: deviceID,
            sessionID: sessionID
        )
        
        // Act & Assert
        XCTAssertNotEqual(answer1.idempotencyKey, answer2.idempotencyKey)
    }
    
    // INVALID INPUT: Missing device ID handled
    func test_idempotencyKey_withoutDeviceID_generatesKey() {
        // Arrange
        let answer = QuestionAnswer(
            id: UUID().uuidString,
            questionID: "q1",
            selectedOptionIndex: 0,
            isCorrect: true,
            category: "traffic_signs",
            timestamp: Date(),
            deviceID: "", // Empty!
            sessionID: "session789"
        )
        
        // Act
        let key = answer.idempotencyKey
        
        // Assert: Key still generated (no crash)
        XCTAssertFalse(key.isEmpty)
    }
}