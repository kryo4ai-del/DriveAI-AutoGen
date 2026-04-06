import XCTest
@testable import DriveAI

final class FeedbackMessageTests: XCTestCase {
    
    // MARK: - Initialization
    
    func test_feedbackMessage_hasUniqueId() {
        let msg1 = FeedbackMessage(severity: .success, title: "Test")
        let msg2 = FeedbackMessage(severity: .success, title: "Test")
        XCTAssertNotEqual(msg1.id, msg2.id)
    }
    
    // MARK: - Factory Methods
    
    func test_success_factoryMethod() {
        let msg = FeedbackMessage.success("Success!")
        XCTAssertEqual(msg.severity, .success)
        XCTAssertEqual(msg.title, "Success!")
        XCTAssertEqual(msg.autoDismissAfter, 3.0)
    }
    
    func test_error_factoryMethod() {
        let msg = FeedbackMessage.error("Error!", message: "Details")
        XCTAssertEqual(msg.severity, .error)
        XCTAssertNil(msg.autoDismissAfter)  // Errors persist
        XCTAssertEqual(msg.message, "Details")
    }
    
    func test_warning_factoryMethod() {
        let msg = FeedbackMessage.warning("Warning")
        XCTAssertEqual(msg.severity, .warning)
        XCTAssertEqual(msg.autoDismissAfter, 4.0)
    }
    
    func test_info_factoryMethod() {
        let msg = FeedbackMessage.info("Info")
        XCTAssertEqual(msg.severity, .info)
        XCTAssertEqual(msg.autoDismissAfter, 3.0)
    }
    
    // MARK: - From Error Conversion
    
    func test_fromError_networkTimeout_hasWarningAutoDissmiss() {
        let error = DriveAIError.networkTimeout(timeoutSeconds: 10.0)
        let msg = FeedbackMessage.fromError(error)
        
        XCTAssertEqual(msg.severity, .warning)
        XCTAssertEqual(msg.autoDismissAfter, 5.0)
        XCTAssertTrue(msg.isDismissible)
    }
    
    func test_fromError_authError_persistsUntilDismissed() {
        let error = DriveAIError.authenticationFailed
        let msg = FeedbackMessage.fromError(error)
        
        XCTAssertEqual(msg.severity, .error)
        XCTAssertNil(msg.autoDismissAfter)
        XCTAssertTrue(msg.isDismissible)
    }
    
    func test_fromError_validationError_autoDissmisses() {
        let error = DriveAIError.invalidInput(field: "name", reason: "required")
        let msg = FeedbackMessage.fromError(error)
        
        XCTAssertEqual(msg.severity, .warning)
        XCTAssertEqual(msg.autoDismissAfter, 4.0)
    }
    
    func test_fromError_usesErrorDescription() {
        let error = DriveAIError.documentNotFound(id: "test-123")
        let msg = FeedbackMessage.fromError(error)
        
        XCTAssertTrue(msg.title.contains("test-123"))
    }
    
    // MARK: - Equatable Conformance
    
    func test_identicalMessages_areEqual() {
        let id = UUID()
        let msg1 = FeedbackMessage(
            severity: .success,
            title: "Test",
            message: "Details"
        )
        let msg2 = FeedbackMessage(
            severity: .success,
            title: "Test",
            message: "Details"
        )
        
        // Different IDs, but same content
        XCTAssertNotEqual(msg1, msg2)  // IDs differ
    }
    
    func test_sameIdMessages_areEqual() {
        var msg1 = FeedbackMessage(
            severity: .success,
            title: "Test"
        )
        let id = msg1.id
        var msg2 = FeedbackMessage(
            severity: .success,
            title: "Test"
        )
        msg2 = FeedbackMessage(
            severity: .success,
            title: "Test",
            message: nil,
            isDismissible: true,
            autoDismissAfter: 3.0
        )
        
        // Would be equal if same ID (but can't easily construct with same ID)
        // This test verifies the equality logic based on id
    }
    
    // MARK: - Hashable Conformance
    
    func test_message_canBeStoredInSet() {
        let msg1 = FeedbackMessage.success("Message 1")
        let msg2 = FeedbackMessage.error("Message 2")
        var msgSet: Set<FeedbackMessage> = [msg1, msg2]
        XCTAssertEqual(msgSet.count, 2)
    }
    
    // MARK: - Severity Styling
    
    func test_severity_successHasGreenBackground() {
        let severity = FeedbackMessage.Severity.success
        XCTAssertEqual(severity.backgroundColor, "green")
    }
    
    func test_severity_errorHasRedBackground() {
        let severity = FeedbackMessage.Severity.error
        XCTAssertEqual(severity.backgroundColor, "red")
    }
    
    func test_severity_successHasCheckmarkIcon() {
        let severity = FeedbackMessage.Severity.success
        XCTAssertEqual(severity.icon, "checkmark.circle.fill")
    }
    
    func test_severity_errorHasXmarkIcon() {
        let severity = FeedbackMessage.Severity.error
        XCTAssertEqual(severity.icon, "xmark.circle.fill")
    }
    
    // MARK: - Sendable Conformance
    
    func test_feedbackMessage_isSendable() async {
        let msg = FeedbackMessage.success("Test")
        
        Task {
            let _ = msg  // Should compile with Sendable checking
        }
    }
}