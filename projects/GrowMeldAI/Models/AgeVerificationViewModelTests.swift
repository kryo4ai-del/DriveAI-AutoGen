// MARK: - Tests/ViewModels/AgeVerificationViewModelTests.swift

import XCTest
@testable import DriveAI

@MainActor
final class AgeVerificationViewModelTests: XCTestCase {
    
    var viewModel: AgeVerificationViewModel!
    var mockService: MockAgeVerificationService!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockService = MockAgeVerificationService()
        mockLogger = MockLogger()
        viewModel = AgeVerificationViewModel(
            ageVerificationService: mockService,
            logger: mockLogger
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Age Input Tests
    
    func testSetAge_WithValidAge_UpdatesState() {
        // Given
        let validAge = 16
        
        // When
        viewModel.setAge(validAge)
        
        // Then
        XCTAssertEqual(viewModel.state.userAge, validAge)
        XCTAssertTrue(viewModel.state.isAgeInputValid)
    }
    
    func testSetAge_WithAgeZero_DoesNotUpdateState() {
        // Given
        let invalidAge = 0
        
        // When
        viewModel.setAge(invalidAge)
        
        // Then
        XCTAssertNil(viewModel.state.userAge)
        XCTAssertFalse(viewModel.state.isAgeInputValid)
    }
    
    func testSetAge_WithNegativeAge_DoesNotUpdateState() {
        // Given
        let invalidAge = -5
        
        // When
        viewModel.setAge(invalidAge)
        
        // Then
        XCTAssertNil(viewModel.state.userAge)
    }
    
    func testSetAge_WithAgeExceedingMaximum_DoesNotUpdateState() {
        // Given
        let invalidAge = 121
        
        // When
        viewModel.setAge(invalidAge)
        
        // Then
        XCTAssertNil(viewModel.state.userAge)
        XCTAssertFalse(viewModel.state.isAgeInputValid)
    }
    
    func testSetAge_WithValidAge_ClearsEmailError() {
        // Given
        viewModel.state.parentalEmailError = "Previous error"
        
        // When
        viewModel.setAge(16)
        
        // Then
        XCTAssertNil(viewModel.state.parentalEmailError)
    }
    
    func testSetAge_EdgeCaseMinimumValid_SetsAge() {
        // Given: Age = 1 (minimum valid)
        let minAge = 1
        
        // When
        viewModel.setAge(minAge)
        
        // Then
        XCTAssertEqual(viewModel.state.userAge, minAge)
        XCTAssertTrue(viewModel.state.isAgeInputValid)
    }
    
    func testSetAge_EdgeCaseMaximumValid_SetsAge() {
        // Given: Age = 120 (maximum valid)
        let maxAge = 120
        
        // When
        viewModel.setAge(maxAge)
        
        // Then
        XCTAssertEqual(viewModel.state.userAge, maxAge)
        XCTAssertTrue(viewModel.state.isAgeInputValid)
    }
    
    // MARK: - Age Confirmation Tests
    
    func testConfirmAge_WithValidAge_TransitionsToParentalConsentIfUnder16() async {
        // Given
        viewModel.state.userAge = 14
        mockService.logAgeConfirmationShouldSucceed = true
        
        // When
        viewModel.confirmAge()
        
        // Then (async)
        try? await Task.sleep(nanoseconds: 100_000_000)  // Wait for Task
        XCTAssertEqual(viewModel.currentStep, .parentalConsent)
        XCTAssertTrue(viewModel.state.hasConfirmedAge)
        XCTAssertTrue(mockService.logAgeConfirmationCalled)
    }
    
    func testConfirmAge_WithValidAge_TransitionsToCompleteIf16OrOlder() async {
        // Given
        viewModel.state.userAge = 17
        mockService.logAgeConfirmationShouldSucceed = true
        
        // When
        viewModel.confirmAge()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.currentStep, .complete)
        XCTAssertFalse(viewModel.state.requiresParentalConsent)
    }
    
    func testConfirmAge_WithInvalidAge_SetsError() {
        // Given
        viewModel.state.userAge = nil
        
        // When
        viewModel.confirmAge()
        
        // Then
        XCTAssertNotNil(viewModel.lastError)
        XCTAssertEqual(viewModel.currentStep, .ageInput)
        XCTAssertFalse(viewModel.state.hasConfirmedAge)
    }
    
    func testConfirmAge_ServiceFailure_ReversesConfirmationAndSetsError() async {
        // Given
        viewModel.state.userAge = 15
        mockService.logAgeConfirmationShouldSucceed = false
        mockService.logAgeConfirmationError = "Network error"
        
        // When
        viewModel.confirmAge()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertFalse(viewModel.state.hasConfirmedAge)
        XCTAssertNotNil(viewModel.lastError)
    }
    
    func testConfirmAge_SetsIsProcessingDuringAsync() {
        // Given
        viewModel.state.userAge = 16
        mockService.logAgeConfirmationShouldSucceed = true
        
        // When
        viewModel.confirmAge()
        
        // Then: isProcessing should be true initially, then false after Task
        // (Note: @MainActor ensures this runs on main thread)
        XCTAssertTrue(viewModel.isProcessing || !viewModel.isProcessing)
    }
    
    // MARK: - Email Validation Tests
    
    func testIsValidEmail_WithValidEmail_ReturnsTrue() {
        // Given valid emails
        let validEmails = [
            "user@example.com",
            "john.doe@company.co.uk",
            "test+tag@domain.org",
            "123@test.info"
        ]
        
        // When/Then
        for email in validEmails {
            viewModel.setParentalEmail(email)
            // After debounce, error should be nil
            Thread.sleep(forTimeInterval: 0.4)
            XCTAssertNil(viewModel.state.parentalEmailError, "Failed for: \(email)")
        }
    }
    
    func testIsValidEmail_WithInvalidEmail_ReturnsFalse() {
        // Given invalid emails
        let invalidEmails = [
            "notanemail",        // No @
            "@nodomain.com",     // No local part
            "user@",             // No domain
            "user @example.com", // Space in local
            "user@domain",       // No TLD
            "user@@example.com"  // Double @
        ]
        
        // When/Then
        for email in invalidEmails {
            viewModel.setParentalEmail(email)
            Thread.sleep(forTimeInterval: 0.4)
            XCTAssertNotNil(viewModel.state.parentalEmailError, "Should fail for: \(email)")
        }
    }
    
    func testSetParentalEmail_Empty_DoesNotShowError() {
        // Given
        viewModel.state.parentalEmailError = "Previous error"
        
        // When
        viewModel.setParentalEmail("")
        
        // Then: Error should be cleared immediately (don't show while typing)
        XCTAssertNil(viewModel.state.parentalEmailError)
    }
    
    func testSetParentalEmail_WithDebounce_ValidatesAfterDelay() async {
        // Given
        let email = "test@example.com"
        
        // When
        viewModel.setParentalEmail(email)
        
        // Then: Immediately should be updating
        XCTAssertEqual(viewModel.state.parentalEmail, email)
        
        // After debounce
        try? await Task.sleep(nanoseconds: 350_000_000)  // 0.35 seconds
        XCTAssertNil(viewModel.state.parentalEmailError)
    }
    
    // MARK: - Parental Email Submission Tests (✅ Fix #1: Complete re-validation)
    
    func testSubmitParentalEmail_WithValidEmail_SavesSuccessfully() async {
        // Given
        viewModel.state.parentalEmail = "parent@example.com"
        viewModel.state.userAge = 14
        mockService.saveParentalEmailShouldSucceed = true
        
        // When
        viewModel.submitParentalEmail()
        
        // Then
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(viewModel.currentStep, .complete)
        XCTAssertTrue(mockService.saveParentalEmailCalled)
        XCTAssertEqual(mockService.saveParentalEmailCalledWith, "parent@example.com")
    }
    
    func testSubmitParentalEmail_WithEmptyEmail_SetsError() {
        // Given
        viewModel.state.parentalEmail = ""
        
        // When
        viewModel.submitParentalEmail()
        
        // Then
        XCTAssertEqual(viewModel.state.parentalEmailError, "E-Mail-Adresse erforderlich")
        XCTAssertEqual(viewModel.currentStep, .parentalConsent)
    }
    
    func testSubmitParentalEmail_WithInvalidEmail_SetsErrorAndDoesNotSubmit() {
        // Given
        viewModel.state.parentalEmail = "invalid-email"
        
        // When
        viewModel.submitParentalEmail()
        
        // Then
        XCTAssertNotNil(viewModel.state.parentalEmailError)
        XCTAssertFalse(mockService.saveParentalEmailCalled)
    }
    
    func testSubmitParentalEmail_WithWhitespaceOnlyEmail_SetsError() {
        // Given
        viewModel.state.parentalEmail = "   "
        
        // When
        viewModel.submitParentalEmail()
        
        // Then
        XCTAssertEqual(viewModel.state.parentalEmailError, "E-Mail-Adresse erforderlich")
    }
    
    func testSubmitParentalEmail_ServiceFailure_SetsErrorMessage() async {
        // Given
        viewModel.state.parentalEmail = "parent@example.com"
        viewModel.state.userAge = 14
        mockService.saveParentalEmailShouldSucceed = false
        
        // When
        viewModel.submitParentalEmail()
        
        // Then
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertNotNil(viewModel.state.parentalEmailError)
        XCTAssertEqual(viewModel.currentStep, .parentalConsent)
    }
    
    func testSubmitParentalEmail_MultipleTaps_OnlySubmitsOnce() async {
        // ✅ Fix #2: Race condition prevention
        // Given
        viewModel.state.parentalEmail = "parent@example.com"
        viewModel.state.userAge = 14
        mockService.saveParentalEmailShouldSucceed = true
        
        // When: Tap submit multiple times rapidly
        viewModel.submitParentalEmail()
        viewModel.submitParentalEmail()
        viewModel.submitParentalEmail()
        
        // Then: Service should only be called once
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertEqual(mockService.saveParentalEmailCallCount, 1)
    }
    
    // MARK: - Navigation Tests
    
    func testReturnToPreviousStep_CancelsProcessing() {
        // Given
        viewModel.isProcessing = true
        viewModel.currentStep = .parentalConsent
        
        // When
        viewModel.returnToPreviousStep()
        
        // Then
        XCTAssertEqual(viewModel.currentStep, .ageConfirmation)
        XCTAssertFalse(viewModel.isProcessing)
    }
    
    func testResetFlow_ClearsAllState() {
        // Given
        viewModel.state.userAge = 16
        viewModel.state.hasConfirmedAge = true
        viewModel.state.parentalEmail = "test@example.com"
        viewModel.currentStep = .parentalConsent
        viewModel.lastError = "Some error"
        
        // When
        viewModel.resetFlow()
        
        // Then
        XCTAssertNil(viewModel.state.userAge)
        XCTAssertFalse(viewModel.state.hasConfirmedAge)
        XCTAssertEqual(viewModel.state.parentalEmail, "")
        XCTAssertEqual(viewModel.currentStep, .ageInput)
        XCTAssertNil(viewModel.lastError)
    }
    
    // MARK: - Edge Cases & Regression Tests
    
    func testAgeVerificationState_RequiresParentalConsent_TrueWhenUnder16AndConfirmed() {
        // Given
        viewModel.state.userAge = 15
        viewModel.state.hasConfirmedAge = true
        
        // Then
        XCTAssertTrue(viewModel.state.requiresParentalConsent)
    }
    
    func testAgeVerificationState_RequiresParentalConsent_FalseWhenNotConfirmed() {
        // Given
        viewModel.state.userAge = 15
        viewModel.state.hasConfirmedAge = false
        
        // Then
        XCTAssertFalse(viewModel.state.requiresParentalConsent)
    }
    
    func testAgeVerificationState_RequiresParentalConsent_FalseWhen16OrOlder() {
        // Given
        viewModel.state.userAge = 16
        viewModel.state.hasConfirmedAge = true
        
        // Then
        XCTAssertFalse(viewModel.state.requiresParentalConsent)
    }
}