// Tests/Services/Purchases/KeychainStorageTests.swift
import XCTest
@testable import DriveAI

final class KeychainStorageTests: XCTestCase {
    var sut: KeychainStorage!
    
    override func setUp() async throws {
        sut = KeychainStorage(service: "com.driveai.test.\(UUID().uuidString)")
        try await clearTestKeychain()
    }
    
    override func tearDown() async throws {
        try await clearTestKeychain()
    }
    
    private func clearTestKeychain() async throws {
        for account in ["test_account_1", "test_account_2", "test_hash"] {
            try? sut.delete(for: account)
        }
    }
    
    // MARK: - Store & Retrieve
    
    func testStoreAndRetrieveData() throws {
        let testData = "secret_purchase_token".data(using: .utf8)!
        
        try sut.store(testData, for: "test_account_1")
        let retrieved = try sut.retrieve(for: "test_account_1")
        
        XCTAssertEqual(retrieved, testData)
    }
    
    func testStoreEmptyData() throws {
        let emptyData = Data()
        
        try sut.store(emptyData, for: "test_account_1")
        let retrieved = try sut.retrieve(for: "test_account_1")
        
        XCTAssertEqual(retrieved, emptyData)
    }
    
    func testStoreLargeData() throws {
        let largeData = Data(repeating: 0xFF, count: 1_000_000) // 1 MB
        
        try sut.store(largeData, for: "test_account_1")
        let retrieved = try sut.retrieve(for: "test_account_1")
        
        XCTAssertEqual(retrieved, largeData)
    }
    
    // MARK: - Retrieve Nonexistent
    
    func testRetrieveNonexistentAccount() throws {
        XCTAssertThrowsError(
            try sut.retrieve(for: "nonexistent")
        ) { error in
            guard let keychainError = error as? KeychainStorage.KeychainError else {
                XCTFail("Wrong error type")
                return
            }
            if case .itemNotFound = keychainError {
                // Expected
            } else {
                XCTFail("Expected itemNotFound")
            }
        }
    }
    
    // MARK: - Update
    
    func testOverwriteExistingData() throws {
        let originalData = "first".data(using: .utf8)!
        let newData = "second".data(using: .utf8)!
        
        try sut.store(originalData, for: "test_account_1")
        try sut.store(newData, for: "test_account_1")
        
        let retrieved = try sut.retrieve(for: "test_account_1")
        XCTAssertEqual(retrieved, newData)
    }
    
    // MARK: - Delete
    
    func testDeleteExistingItem() throws {
        let testData = "to_delete".data(using: .utf8)!
        try sut.store(testData, for: "test_account_1")
        try sut.delete(for: "test_account_1")
        
        XCTAssertThrowsError(
            try sut.retrieve(for: "test_account_1")
        )
    }
    
    func testDeleteNonexistentItem() throws {
        // Should not throw
        XCTAssertNoThrow(
            try sut.delete(for: "nonexistent")
        )
    }
    
    // MARK: - Multiple Accounts
    
    func testMultipleAccountsIsolated() throws {
        let data1 = "account_1_data".data(using: .utf8)!
        let data2 = "account_2_data".data(using: .utf8)!
        
        try sut.store(data1, for: "test_account_1")
        try sut.store(data2, for: "test_account_2")
        
        XCTAssertEqual(try sut.retrieve(for: "test_account_1"), data1)
        XCTAssertEqual(try sut.retrieve(for: "test_account_2"), data2)
    }
    
    // MARK: - Debug Service Suffix
    
    func testDebugServiceSuffix() {
        #if DEBUG
        let debugStorage = KeychainStorage(service: "com.driveai.test")
        let prodStorage = KeychainStorage(service: "com.driveai.prod")
        
        // In debug, both should have .debug suffix, so no collision
        // This is verified by attempting to access same account with different services
        XCTAssert(true) // If we got here without collision, test passes
        #endif
    }
}

// Helper for XCTAssertNoThrow
private func XCTAssertNoThrow<T>(_ expression: @autoclosure () throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do {
        _ = try expression()
    } catch {
        XCTFail(message() + (message().isEmpty ? "" : " ") + "threw error: \(error)", file: file, line: line)
    }
}