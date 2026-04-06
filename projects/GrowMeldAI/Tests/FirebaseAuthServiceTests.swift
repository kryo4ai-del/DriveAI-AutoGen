// Tests/FirebaseAuthServiceTests.swift
@MainActor
final class FirebaseAuthServiceTests: XCTestCase {
    var sut: FirebaseAuthService!
    var mockAuth: MockAuth!
    
    override func setUp() {
        super.setUp()
        mockAuth = MockAuth()
        sut = FirebaseAuthService(firebaseAuth: mockAuth)
    }
    
    func testSignInSuccess() async throws {
        // Arrange
        let credentials = AuthCredentials(email: "test@example.com", password: "password123")
        
        // Act
        let user = try await sut.signIn(with: credentials)
        
        // Assert
        XCTAssertEqual(user.email, "test@example.com")
    }
    
    func testSignInInvalidEmail() async {
        // Arrange
        let credentials = AuthCredentials(email: "invalid", password: "password123")
        
        // Act & Assert
        do {
            _ = try await sut.signIn(with: credentials)
            XCTFail("Should throw invalidEmail")
        } catch AuthError.invalidEmail {
            // Expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
}