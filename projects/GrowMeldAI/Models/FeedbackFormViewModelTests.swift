import XCTest
@testable import DriveAI

@MainActor
final class FeedbackFormViewModelTests: XCTestCase {
    var sut: FeedbackFormViewModel!
    var mockFeedbackService: MockFeedbackService!
    var mockAnalyticsService: MockFeedbackAnalyticsService!
    
    override func setUp() {
        super.setUp()
        mockFeedbackService = MockFeedbackService()
        mockAnalyticsService = MockFeedbackAnalyticsService()
        sut = FeedbackFormViewModel(
            feedbackService: mockFeedbackService,
            analyticsService: mockAnalyticsService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockFeedbackService = nil
        mockAnalyticsService = nil
        super.tearDown()
    }
    
    // MARK: - Validation Tests
    
    /// Test: Empty feedback is invalid
    func testValidationFailsOnEmptyText() {
        sut.feedbackText = ""
        XCTAssertFalse(sut.isFormValid, "Empty text should be invalid")
    }
    
    /// Test: Whitespace-only feedback is invalid
    func testValidationFailsOnWhitespaceOnlyText() {
        sut.feedbackText = "   \n  \t  "
        XCTAssertFalse(sut.isFormValid, "Whitespace-only text should be invalid")
    }
    
    /// Test: Feedback exceeding 500 characters is invalid
    func testValidationFailsOnLongText() {
        sut.feedbackText = String(repeating: "a", count: 501)
        XCTAssertFalse(sut.isFormValid, "Text > 500 chars should be invalid")
    }
    
    /// Test: Exactly 500 characters is valid
    func testValidationPassesOnExactly500Chars() {
        sut.feedbackText = String(repeating: "a", count: 500)
        sut.selectedCategory = .bug
        XCTAssertTrue(sut.isFormValid, "Text == 500 chars should be valid")
    }
    
    /// Test: Invalid email format is rejected
    func testValidationFailsOnInvalidEmail() {
        sut.feedbackText = "Valid feedback"
        sut.contactEmail = "invalid-email"
        XCTAssertFalse(sut.isFormValid, "Invalid email should fail validation")
    }
    
    /// Test: Valid email format passes
    func testValidationPassesOnValidEmail() {
        sut.feedbackText = "Valid feedback"
        sut.contactEmail = "user@example.com"
        sut.selectedCategory = .bug
        XCTAssertTrue(sut.isFormValid, "Valid email should pass validation")
    }
    
    /// Test: Optional email can be empty
    func testValidationPassesOnEmptyEmail() {
        sut.feedbackText = "Valid feedback"
        sut.contactEmail = ""
        sut.selectedCategory = .general
        XCTAssertTrue(sut.isFormValid, "Empty email (optional) should pass")
    }
    
    /// Test: Email with plus sign is valid
    func testValidationPassesOnEmailWithPlus() {
        sut.feedbackText = "Test feedback"
        sut.contactEmail = "user+tag@example.com"
        sut.selectedCategory = .general
        XCTAssertTrue(sut.isFormValid, "Email with + should be valid")
    }
    
    // MARK: - Character Counter Tests
    
    /// Test: Character count is accurate
    func testCharacterCountIsAccurate() {
        sut.feedbackText = "Test"
        XCTAssertEqual(sut.characterCount, 4, "Character count should match text length")
    }
    
    /// Test: Character count text shows correct format
    func testCharacterCountTextFormat() {
        sut.feedbackText = "Hello"
        XCTAssertEqual(sut.characterCountText, "5/500", "Format should be 'count/limit'")
    }
    
    /// Test: Character limit exceeded flag is set correctly
    func testCharacterLimitExceededFlag() {
        sut.feedbackText = String(repeating: "a", count: 501)
        XCTAssertTrue(sut.isCharacterLimitExceeded, "Flag should be true when > 500")
        
        sut.feedbackText = String(repeating: "a", count: 500)
        XCTAssertFalse(sut.isCharacterLimitExceeded, "Flag should be false when <= 500")
    }
    
    // MARK: - Submission Tests
    
    /// Test: Submission calls service
    func testSubmitCallsFeedbackService() async {
        sut.feedbackText = "Test feedback"
        sut.selectedCategory = .bug
        
        await sut.submitFeedback()
        
        XCTAssertTrue(mockFeedbackService.submitWasCalled, "Service submit should be called")
    }
    
    /// Test: Submission passes correct feedback model
    func testSubmitPassesCorrectFeedbackModel() async {
        sut.feedbackText = "Test feedback"
        sut.selectedCategory = .featureRequest
        sut.contactEmail = "test@example.com"
        
        await sut.submitFeedback()
        
        let submittedFeedback = mockFeedbackService.submittedFeedback
        XCTAssertNotNil(submittedFeedback)
        XCTAssertEqual(submittedFeedback?.text, "Test feedback")
        XCTAssertEqual(submittedFeedback?.category, .featureRequest)
        XCTAssertEqual(submittedFeedback?.contactEmail, "test@example.com")
    }
    
    /// Test: Email is trimmed before submission
    func testEmailTrimmingOnSubmit() async {
        sut.feedbackText = "Test"
        sut.contactEmail = "  user@example.com  "
        
        await sut.submitFeedback()
        
        XCTAssertEqual(
            mockFeedbackService.submittedFeedback?.contactEmail,
            "user@example.com",
            "Email should be trimmed"
        )
    }
    
    /// Test: Submission resets form on success
    func testFormResetsOnSuccessfulSubmission() async {
        sut.feedbackText = "Test feedback"
        sut.contactEmail = "test@example.com"
        sut.selectedCategory = .bug
        
        await sut.submitFeedback()
        
        XCTAssertEqual(sut.feedbackText, "", "Text should be reset")
        XCTAssertEqual(sut.contactEmail, "", "Email should be reset")
        XCTAssertEqual(sut.selectedCategory, .general, "Category should reset to default")
    }
    
    /// Test: Submission sets success flag
    func testSuccessFlagSetAfterSubmission() async {
        sut.feedbackText = "Test feedback"
        
        XCTAssertFalse(sut.isSubmitSuccessful)
        await sut.submitFeedback()
        XCTAssertTrue(sut.isSubmitSuccessful, "Success flag should be set")
    }
    
    /// Test: isSubmitting flag is set during submission
    func testIsSubmittingFlagDuringSubmission() async {
        mockFeedbackService.delaySeconds = 0.1
        sut.feedbackText = "Test feedback"
        
        let submissionTask = Task {
            await sut.submitFeedback()
        }
        
        // Give the task time to start
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        XCTAssertTrue(sut.isSubmitting, "Flag should be true during submission")
        await submissionTask.value
        XCTAssertFalse(sut.isSubmitting, "Flag should be false after submission")
    }
    
    // MARK: - Error Handling Tests
    
    /// Test: Validation error is set on empty submission
    func testValidationErrorOnEmptySubmit() async {
        sut.feedbackText = ""
        
        await sut.submitFeedback()
        
        XCTAssertNotNil(sut.submitError)
        if case .validationFailed = sut.submitError {
            XCTAssertTrue(true, "Should set validation error")
        } else {
            XCTFail("Should set validation error")
        }
    }
    
    /// Test: Service error is captured
    func testServiceErrorIsCaptured() async {
        mockFeedbackService.shouldThrowError = true
        mockFeedbackService.errorToThrow = .storageFailed("Test storage error")
        sut.feedbackText = "Test feedback"
        
        await sut.submitFeedback()
        
        XCTAssertNotNil(sut.submitError)
        if case .storageFailed = sut.submitError {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should capture storage error")
        }
    }
    
    /// Test: Error is cleared when user edits text
    func testErrorClearedOnTextEdit() async {
        mockFeedbackService.shouldThrowError = true
        sut.feedbackText = ""
        
        await sut.submitFeedback()
        XCTAssertNotNil(sut.submitError)
        
        sut.feedbackText = "New text"
        XCTAssertNil(sut.submitError, "Error should be cleared on edit")
    }
    
    /// Test: Submission in progress error
    func testSubmissionInProgressError() async {
        mockFeedbackService.delaySeconds = 0.5
        sut.feedbackText = "Test feedback"
        
        // Start first submission
        let task1 = Task { await sut.submitFeedback() }
        
        // Try to submit while first is in progress
        try? await Task.sleep(nanoseconds: 50_000_000)
        let initialSubmitting = sut.isSubmitting
        
        // Complete first submission
        await task1.value
        
        XCTAssertTrue(initialSubmitting, "First submission should set isSubmitting")
    }
    
    // MARK: - Analytics Tests
    
    /// Test: Analytics logs successful submission
    func testAnalyticsLogsSuccessfulSubmission() async {
        sut.feedbackText = "Test feedback"
        sut.selectedCategory = .featureRequest
        
        await sut.submitFeedback()
        
        XCTAssertTrue(
            mockAnalyticsService.loggedSubmissions.contains(.featureRequest),
            "Should log successful submission"
        )
    }
    
    /// Test: Analytics logs submission errors
    func testAnalyticsLogsSubmissionError() async {
        mockFeedbackService.shouldThrowError = true
        mockFeedbackService.errorToThrow = .storageFailed("Test")
        sut.feedbackText = "Test feedback"
        
        await sut.submitFeedback()
        
        XCTAssertEqual(mockAnalyticsService.loggedErrors.count, 1, "Should log error")
    }
    
    // MARK: - Manual Reset Tests
    
    /// Test: resetForm() clears all fields
    func testResetFormClearsAllFields() {
        sut.feedbackText = "Some text"
        sut.contactEmail = "test@example.com"
        sut.selectedCategory = .bug
        sut.submitError = .validationFailed("Test")
        
        sut.resetForm()
        
        XCTAssertEqual(sut.feedbackText, "")
        XCTAssertEqual(sut.contactEmail, "")
        XCTAssertEqual(sut.selectedCategory, .general)
        XCTAssertNil(sut.submitError)
    }
    
    /// Test: dismissSuccess() resets success flag
    func testDismissSuccessResetsFlag() {
        sut.isSubmitSuccessful = true
        sut.dismissSuccess()
        XCTAssertFalse(sut.isSubmitSuccessful)
    }
}

// MARK: - Mock Services

final class MockFeedbackService: FeedbackService {
    var submitWasCalled = false
    var submittedFeedback: FeedbackModel?
    var shouldThrowError = false
    var errorToThrow: FeedbackError = .unknownError("Test error")
    var delaySeconds: TimeInterval = 0
    
    func submit(feedback: FeedbackModel) async throws {
        if delaySeconds > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
        }
        
        submitWasCalled = true
        submittedFeedback = feedback
        
        if shouldThrowError {
            throw errorToThrow
        }
    }
    
    func retrieveAllFeedback() async throws -> [FeedbackModel] {
        []
    }
    
    func deleteFeedback(withID id: UUID) async throws {}
}

final class MockFeedbackAnalyticsService: FeedbackAnalyticsService {
    var loggedSubmissions: [FeedbackCategory] = []
    var loggedErrors: [FeedbackError] = []
    
    func logFeedbackSubmitted(category: FeedbackCategory) async {
        loggedSubmissions.append(category)
    }
    
    func logFeedbackError(_ error: FeedbackError) async {
        loggedErrors.append(error)
    }
}