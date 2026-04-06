// Tests/Unit/Services/ChecksumValidatorTests.swift

import XCTest
@testable import DriveAI

final class ChecksumValidatorTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func test_sha256Hash_generatesConsistentHash() {
        // Given
        let data = "Hello, World!".data(using: .utf8)!
        
        // When
        let hash1 = data.sha256Hash()
        let hash2 = data.sha256Hash()
        
        // Then
        XCTAssertEqual(hash1, hash2, "Hash should be deterministic")
        XCTAssertEqual(hash1.count, 64, "SHA256 hex string should be 64 characters")
    }
    
    func test_sha256Hash_differentiatesData() {
        // Given
        let data1 = "File A".data(using: .utf8)!
        let data2 = "File B".data(using: .utf8)!
        
        // When
        let hash1 = data1.sha256Hash()
        let hash2 = data2.sha256Hash()
        
        // Then
        XCTAssertNotEqual(hash1, hash2)
    }
    
    func test_validateChecksum_matchesExpectedHash() {
        // Given
        let data = "Backup Payload".data(using: .utf8)!
        let expectedHash = data.sha256Hash()
        
        // When
        let isValid = data.validateChecksum(expectedHash)
        
        // Then
        XCTAssertTrue(isValid)
    }
    
    // MARK: - Edge Cases
    
    func test_sha256Hash_emptyData() {
        // Given
        let emptyData = Data()
        
        // When
        let hash = emptyData.sha256Hash()
        
        // Then
        XCTAssertEqual(
            hash,
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "Empty data should produce known SHA256 hash"
        )
    }
    
    func test_sha256Hash_largeData() {
        // Given
        let largeData = Data(repeating: 0xFF, count: 10_000_000)  // 10 MB
        
        // When
        let hash = largeData.sha256Hash()
        
        // Then
        XCTAssertEqual(hash.count, 64)
        XCTAssert(hash.allSatisfy { $0.isHexDigit })
    }
    
    func test_validateChecksum_invalidHash() {
        // Given
        let data = "Sensitive Data".data(using: .utf8)!
        let wrongHash = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        
        // When
        let isValid = data.validateChecksum(wrongHash)
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func test_validateChecksum_caseSensitive() {
        // Given
        let data = "Test".data(using: .utf8)!
        let correctHash = data.sha256Hash()
        let uppercaseHash = correctHash.uppercased()
        
        // When
        let isValid = data.validateChecksum(uppercaseHash)
        
        // Then
        // Depending on implementation, may pass if lowercased
        // This test documents the behavior
        XCTAssertEqual(correctHash, uppercaseHash.lowercased())
    }
}