import XCTest
@testable import DriveAI

final class FeedbackErrorTests: XCTestCase {
    
    func testValidationErrorDescriptions() {
        let errors: [(UserFeedback.ValidationError, String)] = [
            (.empty, "Feedback darf nicht leer sein"),
            (.tooShort(minLength: 5), "Feedback muss mindestens 5 Zeichen lang sein"),
            (.tooLong(maxLength: 500), "Feedback darf höchstens 500 Zeichen lang sein")
        ]
        
        for (error, expectedDesc) in errors {
            XCTAssertEqual(error.errorDescription, expectedDesc)
        }
    }
    
    func testFeedbackErrorDescriptions() {
        let persistenceError = FeedbackError.persistenceError("Disk full")
        XCTAssertTrue(persistenceError.errorDescription?.contains("Speicher") ?? false)
        
        let validationError = FeedbackError.validationFailed("Test")
        XCTAssertEqual(validationError.errorDescription, "Test")
        
        let storageError = FeedbackError.storageExhausted
        XCTAssertTrue(storageError.errorDescription?.contains("Speicherplatz") ?? false)
    }
    
    func testFeedbackErrorRecoverySuggestions() {
        let persistenceError = FeedbackError.persistenceError("Network timeout")
        XCTAssertTrue(persistenceError.recoverySuggestion?.contains("später") ?? false)
        
        let storageError = FeedbackError.storageExhausted
        XCTAssertTrue(storageError.recoverySuggestion?.contains("wartet") ?? false)
    }
    
    func testErrorIsLocalizedError() {
        let error: Error = FeedbackError.validationFailed("Test")
        let localizedError = error as? LocalizedError
        XCTAssertNotNil(localizedError)
    }
}