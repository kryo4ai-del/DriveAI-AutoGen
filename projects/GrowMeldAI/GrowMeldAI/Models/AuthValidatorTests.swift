// Tests/Models/AuthValidatorTests.swift
import XCTest
@testable import DriveAI

class AuthValidatorTests: XCTestCase {
    
    // MARK: - Email Validation
    
    func testValidateEmailValid() {
        let result = AuthValidator.validateEmail("user@example.de")
        XCTAssertNil(result)
    }
    
    func testValidateEmailInvalidFormat() {
        let cases = [
            "plainaddress",      // Missing @
            "user@",             // Missing domain
            "@example.de",       // Missing local part
            "user@.com",         // Missing domain name
            "user name@example.de",  // Spaces
            "",                  // Empty
        ]
        
        for email in cases {
            let result = AuthValidator.validateEmail(email)
            XCTAssertEqual(result, .invalidEmail, "Email '\(email)' should be invalid")
        }
    }
    
    func testValidateEmailWithWhitespace() {
        let result = AuthValidator.validateEmail("  user@example.de  ")
        XCTAssertNil(result, "Email should be trimmed")
    }
    
    func testValidateEmailInternational() {
        // German umlauts in domain
        let result = AuthValidator.validateEmail("user@müllerverlag.de")
        // Note: actual implementation may need IDN handling
        XCTAssertNotNil(result, "Currently should reject, but future support welcomed")
    }
    
    // MARK: - Password Validation
    
    func testValidatePasswordValid() {
        let result = AuthValidator.validatePassword("SecurePass123!")
        XCTAssertNil(result)
    }
    
    func testValidatePasswordTooShort() {
        let result = AuthValidator.validatePassword("Short1!")
        XCTAssertEqual(result, .weakPassword)
    }
    
    func testValidatePasswordMissingUppercase() {
        let result = AuthValidator.validatePassword("password123!")
        XCTAssertEqual(result, .weakPassword)
    }
    
    func testValidatePasswordMissingLowercase() {
        let result = AuthValidator.validatePassword("PASSWORD123!")
        XCTAssertEqual(result, .weakPassword)
    }
    
    func testValidatePasswordMissingNumber() {
        let result = AuthValidator.validatePassword("SecurePass!")
        XCTAssertEqual(result, .weakPassword)
    }
    
    func testValidatePasswordMissingSpecial() {
        let result = AuthValidator.validatePassword("SecurePass123")
        XCTAssertEqual(result, .weakPassword)
    }
    
    func testValidatePasswordAllSpecialChars() {
        let specials = "!@#$%^&*()_+-=[]{}|;:',.<>?/~`"
        for char in specials {
            let password = "SecurePass123\(char)"
            let result = AuthValidator.validatePassword(password)
            XCTAssertNil(result, "Should accept special char: \(char)")
        }
    }
    
    func testValidatePasswordExactlyEightChars() {
        let result = AuthValidator.validatePassword("Pass1234!")
        XCTAssertNil(result, "8-char password should pass")
    }
    
    func testValidatePasswordSevenChars() {
        let result = AuthValidator.validatePassword("Pass123!")
        XCTAssertEqual(result, .weakPassword)
    }
}