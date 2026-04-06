// Features/Auth/Application/Tests/SignInViewModelTests.swift

import XCTest
@testable import DriveAI

@MainActor
final class SignInViewModelTests: XCTestCase {
    var sut: SignInViewModel!
    var mockAuthUseCase: MockAuthUseCase!
    
    override func setUp() {
        super.setUp()
        mockAuthUseCase = MockAuthUseCase()
        sut = SignInViewModel(authUseCase: mockAuthUseCase)
    }
    
    override func tearDown() {
        sut = nil
        mockAuthUseCase = nil
        super.tearDown()
    }
    
    // MARK: - Form Validation
    
    func test_emptyEmail_invalidForm() {
        sut.email = ""
        sut.password = "password123"
        
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_invalidEmail_invalidForm() {
        sut.email = "notanemail"
        sut.password = "password123"
        
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_emptyPassword_invalidForm() {
        sut.email = "test@example.com"
        sut.password = ""
        
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_validEmailAndPassword_validForm() {
        sut.email = "test@example.com"
        sut.password = "password123"
        
        XCTAssertTrue(sut.isFormValid)
    }
    
    func test_validFormWithWhitespace_trims() {
        sut.email = "  test@example.com  "
        sut.password = "password123"
        
        XCTAssertTrue(sut.isFormValid)
    }
    
    // MARK: - Valid Email Formats
    
    func test_emailWithPlus_valid() {
        sut.email = "user+tag@example.com"
        sut.password = "password123"
        
        XCTAssertTrue(sut.isFormValid)
    }
    
    func test_emailWithDot_valid() {
        sut.email = "user.name@example.com"
        sut.password = "password123"
        
        XCTAssertTrue(sut.isFormValid)
    }
    
    func test_emailWithSubdomain_valid() {
        sut.email = "user@mail.example.co.uk"
        sut.password = "password123"
        
        XCTAssertTrue(sut.isFormValid)
    }
    
    // MARK: - Invalid Email Formats
    
    func test_emailMissingAtSymbol_invalid() {
        sut.email = "userexample.com"
        sut.password = "password123"
        
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_emailWithoutLocalPart_invalid() {
        sut.email = "@example.com"
        sut.password = "password123"
        
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_emailWithoutDomain_invalid() {
        sut.email = "user@"
        sut.password = "password123"
        
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_emailWithSpace_invalid() {
        sut.email = "user @example.com"
        sut.password = "password123"
        
        XCTAssertFalse(sut.isFormValid)
    }
    
    // MARK: - Happy Path
    
    func test_signIn_successClears errorAndLoading() async {
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.errorMessage = "Previous error"
        
        let testUser = AuthUser(
            id: "user-123",
            email: "test@example.com",
            createdAt: Date()
        )
        
        mockAuthUseCase.signInResult = testUser
        mockAuthUseCase.signInShouldSucceed = true
        
        await sut.signIn()
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Error Scenarios
    
    func test_signIn_invalidCredentialsError() async {
        sut.email = "test@example.com"
        sut.password = "wrongpassword"
        
        mockAuthUseCase.signInShouldSucceed = false
        mockAuthUseCase.signInError = AuthError.invalidCredentials
        
        await sut.signIn()
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_signIn_networkError_displaysNetworkMessage() async {
        sut.email = "test@example.com"
        sut.password = "password123"
        
        mockAuthUseCase.signInShouldSucceed = false
        mockAuthUseCase.signInError = AuthError.networkError(URLError(.networkConnectionLost))
        
        await sut.signIn()
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssert(sut.errorMessage?.contains("network") ?? false || sut.errorMessage?.contains("internet") ?? false)
    }
    
    func test_signIn_userNotFoundError() async {
        sut.email = "nonexistent@example.com"
        sut.password = "password123"
        
        mockAuthUseCase.signInShouldSucceed = false
        mockAuthUseCase.signInError = AuthError.userNotFound
        
        await sut.signIn()
        
        XCTAssertNotNil(sut.errorMessage)
    }
    
    // MARK: - Password Visibility
    
    func test_togglePasswordVisibility() {
        XCTAssertFalse(sut.isPasswordVisible)
        
        sut.isPasswordVisible = true
        XCTAssertTrue(sut.isPasswordVisible)
        
        sut.isPasswordVisible = false
        XCTAssertFalse(sut.isPasswordVisible)
    }
    
    // MARK: - Loading State
    
    func test_signIn_setsLoadingState() async {
        sut.email = "test@example.com"
        sut.password = "password123"
        
        mockAuthUseCase.signInShouldSucceed = true
        mockAuthUseCase.signInResult = AuthUser(
            id: "user-123",
            email: "test@example.com",
            createdAt: Date()
        )
        
        let signInTask = Task {
            await sut.signIn()
        }
        
        try? await Task.sleep(nanoseconds: 1000)
        
        await signInTask.value
        
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Error Clearing
    
    func test_clearError_removesErrorMessage() {
        sut.errorMessage = "Some error"
        
        sut.clearError()
        
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Edge Cases
    
    func test_signIn_withVeryLongEmail() async {
        let longEmail = String(repeating: "a", count: 240) + "@example.com"
        sut.email = longEmail
        sut.password = "password123"
        
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_signIn_withEmojis_invalid() {
        sut.email = "test😀@example.com"
        sut.password = "password123"
        
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_signIn_formValidationNotAffectedByLoadingState() {
        sut.email = "test@example.com"
        sut.password = "password123"
        
        let validBefore = sut.isFormValid
        sut.isLoading = true
        let validAfter = sut.isFormValid
        
        XCTAssertEqual(validBefore, validAfter)
    }
}