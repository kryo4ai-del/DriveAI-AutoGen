import XCTest
@testable import DriveAI

final class FeedbackModelsTests: XCTestCase {
    
    // MARK: - FeedbackCategory Tests
    
    func testFeedbackCategoryRawValues() {
        XCTAssertEqual(FeedbackCategory.bug.rawValue, "bug")
        XCTAssertEqual(FeedbackCategory.featureRequest.rawValue, "feature_request")
        XCTAssertEqual(FeedbackCategory.question.rawValue, "question")
        XCTAssertEqual(FeedbackCategory.other.rawValue, "other")
    }
    
    func testFeedbackCategoryGermanLabels() {
        XCTAssertEqual(FeedbackCategory.bug.germanLabel, "Fehler melden")
        XCTAssertEqual(FeedbackCategory.featureRequest.germanLabel, "Funktion vorschlagen")
        XCTAssertEqual(FeedbackCategory.question.germanLabel, "Frage stellen")
        XCTAssertEqual(FeedbackCategory.other.germanLabel, "Sonstiges")
    }
    
    func testFeedbackCategoryAllCases() {
        let allCases = FeedbackCategory.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.bug))
        XCTAssertTrue(allCases.contains(.featureRequest))
    }
    
    // MARK: - UserFeedback Initialization
    
    func testUserFeedbackInitWithDefaults() {
        let feedback = UserFeedback(
            category: .bug,
            message: "Test message"
        )
        
        XCTAssertNotNil(feedback.id)
        XCTAssertEqual(feedback.category, .bug)
        XCTAssertEqual(feedback.message, "Test message")
        XCTAssertEqual(feedback.appVersion, Bundle.main.appVersion)
        XCTAssertEqual(feedback.osVersion, UIDevice.current.systemVersion)
        XCTAssertTrue(feedback.timestamp <= Date())  // Just created
    }
    
    func testUserFeedbackInitWithCustomValues() {
        let customDate = Date(timeIntervalSince1970: 1000000000)
        let customId = UUID()
        
        let feedback = UserFeedback(
            id: customId,
            timestamp: customDate,
            category: .question,
            message: "Custom feedback",
            appVersion: "2.0",
            osVersion: "17.1"
        )
        
        XCTAssertEqual(feedback.id, customId)
        XCTAssertEqual(feedback.timestamp, customDate)
        XCTAssertEqual(feedback.appVersion, "2.0")
        XCTAssertEqual(feedback.osVersion, "17.1")
    }
    
    // MARK: - Validation Tests
    
    func testValidateAcceptsValidMessage() throws {
        let validMessages = [
            "12345",              // Exactly 5 chars
            "This is feedback",
            String(repeating: "a", count: 500)  // Max length
        ]
        
        for message in validMessages {
            XCTAssertNoThrow(try UserFeedback.validate(message: message))
        }
    }
    
    func testValidateRejectsEmptyMessage() {
        let emptyMessages = ["", "   ", "\n\t"]
        
        for message in emptyMessages {
            XCTAssertThrowsError(try UserFeedback.validate(message: message)) { error in
                if let validationError = error as? UserFeedback.ValidationError {
                    XCTAssertEqual(validationError, .empty)
                } else {
                    XCTFail("Expected ValidationError.empty, got \(type(of: error))")
                }
            }
        }
    }
    
    func testValidateRejectsTooShortMessage() {
        let shortMessages = ["a", "ab", "123", "1234"]  // All < 5
        
        for message in shortMessages {
            XCTAssertThrowsError(try UserFeedback.validate(message: message)) { error in
                if let validationError = error as? UserFeedback.ValidationError {
                    if case .tooShort(let minLength) = validationError {
                        XCTAssertEqual(minLength, 5)
                    } else {
                        XCTFail("Expected .tooShort, got \(validationError)")
                    }
                }
            }
        }
    }
    
    func testValidateRejectsTooLongMessage() {
        let longMessage = String(repeating: "x", count: 501)
        
        XCTAssertThrowsError(try UserFeedback.validate(message: longMessage)) { error in
            if let validationError = error as? UserFeedback.ValidationError {
                if case .tooLong(let maxLength) = validationError {
                    XCTAssertEqual(maxLength, 500)
                } else {
                    XCTFail("Expected .tooLong, got \(validationError)")
                }
            }
        }
    }
    
    func testValidateTrimsWhitespace() {
        // Message with padding should be valid if core is >= 5 chars
        let paddedMessage = "   Hello World   "
        XCTAssertNoThrow(try UserFeedback.validate(message: paddedMessage))
        
        // But padding-only should fail
        let paddingOnly = "     "
        XCTAssertThrowsError(try UserFeedback.validate(message: paddingOnly))
    }
    
    // MARK: - Identifiable Conformance
    
    func testUserFeedbackIsIdentifiable() {
        let feedback1 = UserFeedback(category: .bug, message: "Message 1")
        let feedback2 = UserFeedback(category: .bug, message: "Message 2")
        
        XCTAssertNotEqual(feedback1.id, feedback2.id)
        XCTAssertEqual(feedback1.id, feedback1.id)
    }
}