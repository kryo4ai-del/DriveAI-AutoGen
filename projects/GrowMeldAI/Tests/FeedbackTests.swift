import XCTest
@testable import DriveAI

final class FeedbackTests: XCTestCase {
    
    let userId = "test-user"
    let questionId = UUID()
    let categoryId = "verkehrszeichen"
    
    // MARK: - Initialization & Validation
    
    func testFeedbackInitialization() {
        let feedback = Feedback(
            userId: userId,
            questionId: questionId,
            categoryId: categoryId,
            text: "Gutes Feedback",
            type: .suggestion
        )
        
        XCTAssertEqual(feedback.userId, userId)
        XCTAssertEqual(feedback.questionId, questionId)
        XCTAssertEqual(feedback.categoryId, categoryId)
        XCTAssertEqual(feedback.text, "Gutes Feedback")
        XCTAssertEqual(feedback.type, .suggestion)
        XCTAssertFalse(feedback.isSynced)
    }
    
    func testFeedbackDefaultValues() {
        let feedback = Feedback(
            userId: userId,
            text: "Minimal feedback"
        )
        
        XCTAssertNil(feedback.questionId)
        XCTAssertNil(feedback.categoryId)
        XCTAssertEqual(feedback.type, .other)
        XCTAssertNil(feedback.serverTimestamp)
        XCTAssertFalse(feedback.isSynced)
    }
    
    // MARK: - Fix #1: Input Validation
    
    func testValidFeedback() throws {
        let feedback = Feedback(
            userId: userId,
            text: "Dies ist valides Feedback"
        )
        
        try feedback.validate()  // Should not throw
    }
    
    func testEmptyFeedbackThrows() throws {
        let feedback = Feedback(
            userId: userId,
            text: ""
        )
        
        XCTAssertThrowsError(try feedback.validate()) { error in
            guard let feedbackError = error as? FeedbackError else {
                XCTFail("Wrong error type")
                return
            }
            XCTAssertEqual(feedbackError, .invalidInput)
        }
    }
    
    func testWhitespaceFeedbackThrows() throws {
        let feedback = Feedback(
            userId: userId,
            text: "   \n\t   "
        )
        
        XCTAssertThrowsError(try feedback.validate())
    }
    
    func testFeedbackExceedsMaxLength() throws {
        let tooLong = String(repeating: "a", count: 2001)
        let feedback = Feedback(
            userId: userId,
            text: tooLong
        )
        
        XCTAssertThrowsError(try feedback.validate()) { error in
            guard let feedbackError = error as? FeedbackError,
                  case .invalidInput = feedbackError else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func testFeedbackAtMaxLength() throws {
        let maxLength = String(repeating: "a", count: 2000)
        let feedback = Feedback(
            userId: userId,
            text: maxLength
        )
        
        try feedback.validate()  // Should not throw
    }
    
    // MARK: - Fix #2: Sanitization
    
    func testSanitizationTrimsWhitespace() {
        let feedback = Feedback(
            userId: userId,
            text: "   Feedback mit Leerzeichen   \n"
        )
        
        let sanitized = feedback.sanitized()
        XCTAssertEqual(sanitized.text, "Feedback mit Leerzeichen")
    }
    
    func testSanitizationTruncatesLongText() {
        let tooLong = String(repeating: "a", count: 2500)
        let feedback = Feedback(
            userId: userId,
            text: tooLong
        )
        
        let sanitized = feedback.sanitized()
        XCTAssertEqual(sanitized.text.count, 2000)
    }
    
    func testSanitizationPreservesTrimmedText() {
        let text = "Valid feedback"
        let feedback = Feedback(
            userId: userId,
            text: text
        )
        
        let sanitized = feedback.sanitized()
        XCTAssertEqual(sanitized.text, text)
    }
    
    // MARK: - Fix #3: Timestamp Handling
    
    func testCreatedAtSetOnInit() {
        let before = Date()
        let feedback = Feedback(
            userId: userId,
            text: "Test"
        )
        let after = Date()
        
        XCTAssert(before <= feedback.createdAt && feedback.createdAt <= after)
    }
    
    func testServerTimestampNotSetInitially() {
        let feedback = Feedback(
            userId: userId,
            text: "Test"
        )
        
        XCTAssertNil(feedback.serverTimestamp)
    }
    
    func testEffectiveTimestampUsesServerWhenAvailable() {
        var feedback = Feedback(
            userId: userId,
            text: "Test"
        )
        
        let serverTime = Date().addingTimeInterval(100)
        feedback.serverTimestamp = serverTime
        
        XCTAssertEqual(feedback.effectiveTimestamp, serverTime)
    }
    
    func testEffectiveTimestampUsesCreatedWhenServerNil() {
        let feedback = Feedback(
            userId: userId,
            text: "Test"
        )
        
        XCTAssertEqual(feedback.effectiveTimestamp, feedback.createdAt)
    }
    
    // MARK: - Feedback Types
    
    func testAllFeedbackTypes() {
        let types: [FeedbackType] = [.bugReport, .suggestion, .questionError, .other]
        
        for type in types {
            let feedback = Feedback(
                userId: userId,
                text: "Test",
                type: type
            )
            
            XCTAssertEqual(feedback.type, type)
        }
    }
    
    // MARK: - Codable Support
    
    func testFeedbackCodable() throws {
        let original = Feedback(
            userId: userId,
            questionId: questionId,
            categoryId: categoryId,
            text: "Test feedback",
            type: .bugReport
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Feedback.self, from: encoded)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.userId, original.userId)
        XCTAssertEqual(decoded.text, original.text)
        XCTAssertEqual(decoded.type, original.type)
    }
    
    // MARK: - App Version
    
    func testAppVersionSet() {
        let feedback = Feedback(
            userId: userId,
            text: "Test"
        )
        
        XCTAssertNotNil(feedback.appVersion)
        XCTAssertFalse(feedback.appVersion.isEmpty)
    }
}